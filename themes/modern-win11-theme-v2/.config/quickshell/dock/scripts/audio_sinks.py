#!/usr/bin/env python3
import subprocess, re, sys, json

def get_sinks():
    try:
        out = subprocess.check_output(['wpctl', 'status'], text=True, timeout=2)
    except Exception:
        return []
    
    in_sinks = False
    sinks = []
    for line in out.splitlines():
        if 'Sinks:' in line:
            in_sinks = True
            continue
        if in_sinks:
            if 'Sources:' in line or 'Filters:' in line or 'Streams:' in line or 'Settings' in line:
                break
            if not line.strip() or '├─' in line and 'Sinks' not in line:
                continue
            m = re.search(r'([*]?)\s*(\d+)\.\s+(.*?)(?:\s+\[vol:|$)', line)
            if m:
                is_active = (m.group(1) == '*')
                sink_id = int(m.group(2))
                raw_name = m.group(3).strip()
                # Clean up ugly driver names if present
                clean_name = raw_name
                sinks.append({
                    'id': sink_id,
                    'name': clean_name,
                    'active': is_active
                })
    return sinks

def set_sink(sink_id):
    try:
        subprocess.run(['wpctl', 'set-default', str(sink_id)], timeout=2)
    except Exception:
        pass

if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == 'set':
        set_sink(sys.argv[2])
    else:
        print(json.dumps(get_sinks()))

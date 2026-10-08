#!/usr/bin/env python3
"""
Konachan image fetcher & thumbnail processor for EWW anime sidebar widget.
- Strict isolation between SFW (konachan.net + local tag blocklist) and NSFW (konachan.com)
- Generates 340x210 PNG cards with alpha-masked transparent rounded corners (20px radius)
- Dynamically tints cards with the active Matugen color palette
- Balances male and female anime characters matching theme hue
"""

import json
import os
import sys
import urllib.request
import urllib.parse
import hashlib
import time
import random
import subprocess
import glob
import re
import colorsys

CACHE_BASE = os.path.expanduser("~/.cache/eww-anime")
SFW_RAW_DIR = os.path.join(CACHE_BASE, "sfw")
SFW_CARDS_DIR = os.path.join(CACHE_BASE, "cards_sfw")
NSFW_RAW_DIR = os.path.join(CACHE_BASE, "nsfw")
NSFW_CARDS_DIR = os.path.join(CACHE_BASE, "cards_nsfw")

STATE_FILE = os.path.join(CACHE_BASE, "state.json")
TRIGGER_FILE = os.path.join(CACHE_BASE, "trigger")
COLORS_SCSS = os.path.expanduser("~/.config/eww/colors.scss")

MAX_CACHE = 40
DISPLAY_COUNT = 6

# Strict SFW endpoint and local blocklist
API_SFW = "https://konachan.net/post.json"
API_NSFW = "https://konachan.com/post.json"

BAD_TAGS = {
    "nude", "panties", "bikini", "underwear", "cleavage", "nsfw",
    "nipples", "sex", "breasts", "swimsuit", "lingerie", "naked",
    "areola", "pussy", "penis", "ass", "topless", "bottomless"
}

for d in [SFW_RAW_DIR, SFW_CARDS_DIR, NSFW_RAW_DIR, NSFW_CARDS_DIR]:
    os.makedirs(d, exist_ok=True)


def get_matugen_colors() -> dict:
    colors = {
        "primary": "#ffb2b7",
        "surface": "#1a1112",
        "container": "#271d1e",
        "outline": "#9f8c8d"
    }
    if os.path.exists(COLORS_SCSS):
        try:
            with open(COLORS_SCSS, "r") as f:
                content = f.read()
            for key in colors.keys():
                m = re.search(rf"\${key}:\s*([^;]+);", content)
                if m:
                    colors[key] = m.group(1).strip()
        except Exception:
            pass
    return colors


def get_color_theme_tags(primary_hex: str) -> dict:
    clean_hex = primary_hex.strip().lstrip('#')
    try:
        r, g, b = [int(clean_hex[i:i+2], 16) / 255.0 for i in (0, 2, 4)]
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        hue = h * 360.0
    except Exception:
        hue = 350.0
        s = 0.8

    if s < 0.15:
        return {
            "general": ["monochrome", "black_hair", "white_hair"],
            "male": ["male", "black_hair"],
            "female": ["female", "white_hair"]
        }

    if hue >= 335 or hue < 15:
        return {
            "general": ["red_hair", "red", "rose"],
            "male": ["male", "red_hair"],
            "female": ["female", "red_hair"]
        }
    elif 15 <= hue < 45:
        return {
            "general": ["pink_hair", "pink"],
            "male": ["male", "pink_hair"],
            "female": ["female", "pink_hair"]
        }
    elif 45 <= hue < 75:
        return {
            "general": ["orange_hair", "warm", "autumn"],
            "male": ["male", "orange_hair"],
            "female": ["female", "orange_hair"]
        }
    elif 75 <= hue < 110:
        return {
            "general": ["blonde_hair", "yellow"],
            "male": ["male", "blonde_hair"],
            "female": ["female", "blonde_hair"]
        }
    elif 110 <= hue < 165:
        return {
            "general": ["green_hair", "green"],
            "male": ["male", "green_hair"],
            "female": ["female", "green_hair"]
        }
    elif 165 <= hue < 210:
        return {
            "general": ["teal_hair", "aqua", "cyan"],
            "male": ["male", "teal_hair"],
            "female": ["female", "aqua"]
        }
    elif 210 <= hue < 265:
        return {
            "general": ["blue_hair", "blue"],
            "male": ["male", "blue_hair"],
            "female": ["female", "blue_hair"]
        }
    else:
        return {
            "general": ["purple_hair", "violet", "purple"],
            "male": ["male", "purple_hair"],
            "female": ["female", "purple_hair"]
        }


def load_state() -> dict:
    default_state = {
        "nsfw": False,
        "query": "",
        "sfw_page": 1,
        "nsfw_page": 1,
        "sfw_offset": 0,
        "nsfw_offset": 0,
        "last_theme_color": ""
    }
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return {**default_state, **json.load(f)}
        except Exception:
            pass
    return default_state


def save_state(state: dict):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)
    with open(TRIGGER_FILE, "w") as f:
        f.write(str(time.time()))


def sanitize_filename(url: str) -> str:
    h = hashlib.md5(url.encode()).hexdigest()
    return f"{h}.jpg"


def process_card(raw_path: str, primary_color: str, is_nsfw: bool) -> str:
    """
    Produces a 340x210 PNG with alpha-masked transparent rounded corners (20px radius)
    and delicate Matugen color grading.
    """
    base_name = os.path.splitext(os.path.basename(raw_path))[0]
    color_slug = primary_color.strip().lstrip('#')[:6]
    target_dir = NSFW_CARDS_DIR if is_nsfw else SFW_CARDS_DIR
    card_path = os.path.join(target_dir, f"card_{base_name}_{color_slug}.png")

    if os.path.exists(card_path):
        return card_path

    cmd = [
        "magick", raw_path,
        "-resize", "340x210^",
        "-gravity", "center",
        "-extent", "340x210",
        "(", "+clone", "-fill", primary_color, "-colorize", "12%", ")",
        "-compose", "blend", "-define", "compose:args=88,12", "-composite",
        "-alpha", "set",
        "(", "+clone", "-alpha", "transparent", "-background", "none",
        "-fill", "white", "-draw", "roundrectangle 0,0,339,209,20,20", ")",
        "-compose", "DstIn", "-composite",
        card_path
    ]
    try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=8)
        if os.path.exists(card_path):
            return card_path
    except Exception:
        pass
    return ""


def fetch_posts(api_url: str, page: int = 1, tags: str = "", limit: int = 8) -> list:
    params = urllib.parse.urlencode({
        "tags": tags,
        "limit": limit,
        "page": page,
    })
    url = f"{api_url}?{params}"
    headers = {"User-Agent": "eww-anime-sidebar/2.0"}
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode())
    except Exception:
        return []


def download_image(img_url: str, dest_dir: str) -> str | None:
    filename = sanitize_filename(img_url)
    dest = os.path.join(dest_dir, filename)
    if os.path.exists(dest):
        return dest
    headers = {"User-Agent": "eww-anime-sidebar/2.0"}
    req = urllib.request.Request(img_url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            data = resp.read()
        with open(dest, "wb") as f:
            f.write(data)
        return dest
    except Exception:
        return None


def fetch_theme_batch(is_nsfw: bool):
    state = load_state()
    matugen = get_matugen_colors()
    primary = matugen.get("primary", "#ffb2b7")
    theme_tags = get_color_theme_tags(primary)

    if is_nsfw:
        api_url = API_NSFW
        raw_dir = NSFW_RAW_DIR
        page = state.get("nsfw_page", 1)
        base_tag = ""
    else:
        api_url = API_SFW
        raw_dir = SFW_RAW_DIR
        page = state.get("sfw_page", 1)
        base_tag = "rating:s"

    tag_gen = random.choice(theme_tags["general"])
    tag_male = random.choice(theme_tags["male"])

    q_gen = f"{base_tag} {tag_gen}".strip()
    q_male = f"{base_tag} {tag_male}".strip()

    posts_gen = fetch_posts(api_url, page=page, tags=q_gen, limit=6)
    posts_male = fetch_posts(api_url, page=page, tags=q_male, limit=6)

    combined = []
    for g, m in zip(posts_gen, posts_male):
        combined.append(g)
        combined.append(m)
    if len(posts_gen) > len(posts_male):
        combined.extend(posts_gen[len(posts_male):])
    elif len(posts_male) > len(posts_gen):
        combined.extend(posts_male[len(posts_gen):])

    if len(combined) < 4:
        fallback_q = f"{base_tag} {theme_tags['general'][0]}".strip()
        combined = fetch_posts(api_url, page=page, tags=fallback_q, limit=8)

    processed_count = 0
    for p in combined:
        if not is_nsfw:
            if p.get("rating", "s") != "s":
                continue
            post_tag_set = set(p.get("tags", "").split())
            if post_tag_set & BAD_TAGS:
                continue

        url = p.get("sample_url") or p.get("file_url")
        if url:
            raw = download_image(url, raw_dir)
            if raw:
                c = process_card(raw, primary, is_nsfw)
                if c:
                    processed_count += 1

    if is_nsfw:
        state["nsfw_page"] = page + 1
    else:
        state["sfw_page"] = page + 1
    state["last_theme_color"] = primary
    save_state(state)


def get_active_cards(is_nsfw: bool) -> list:
    matugen = get_matugen_colors()
    primary = matugen.get("primary", "#ffb2b7")
    color_slug = primary.strip().lstrip('#')[:6]

    cards_dir = NSFW_CARDS_DIR if is_nsfw else SFW_CARDS_DIR
    raw_dir = NSFW_RAW_DIR if is_nsfw else SFW_RAW_DIR

    cards = sorted(
        glob.glob(os.path.join(cards_dir, f"card_*_{color_slug}.png")),
        key=os.path.getmtime,
        reverse=True
    )

    if len(cards) < DISPLAY_COUNT:
        raws = sorted(
            [f for f in glob.glob(os.path.join(raw_dir, "*.jpg")) if not f.startswith(".")],
            key=os.path.getmtime,
            reverse=True
        )
        for r in raws:
            c = process_card(r, primary, is_nsfw)
            if c and c not in cards:
                cards.append(c)
            if len(cards) >= DISPLAY_COUNT * 2:
                break

    if len(cards) < DISPLAY_COUNT:
        fetch_theme_batch(is_nsfw)
        cards = sorted(
            glob.glob(os.path.join(cards_dir, f"card_*_{color_slug}.png")),
            key=os.path.getmtime,
            reverse=True
        )

    return cards


def build_output() -> str:
    state = load_state()
    is_nsfw = state.get("nsfw", False)
    matugen = get_matugen_colors()
    primary = matugen.get("primary", "#ffb2b7")

    cards = get_active_cards(is_nsfw)
    offset_key = "nsfw_offset" if is_nsfw else "sfw_offset"
    offset = state.get(offset_key, 0)
    total = len(cards)

    selected = []
    if total > 0:
        for i in range(DISPLAY_COUNT):
            idx = (offset + i) % total
            selected.append(cards[idx])
    else:
        placeholder = os.path.expanduser("~/.config/eww/assets/placeholder.png")
        selected = [placeholder] * DISPLAY_COUNT

    while len(selected) < DISPLAY_COUNT:
        selected.append(os.path.expanduser("~/.config/eww/assets/placeholder.png"))

    res = {
        "img1": selected[0],
        "img2": selected[1],
        "img3": selected[2],
        "img4": selected[3],
        "img5": selected[4],
        "img6": selected[5],
        "nsfw": is_nsfw,
        "nsfw_label": "ON" if is_nsfw else "OFF",
        "nsfw_class": "active" if is_nsfw else "inactive",
        "count": total,
        "source": "Konachan" if is_nsfw else "Konachan (SFW)",
        "theme_color": primary
    }
    return json.dumps(res)


def cmd_next():
    state = load_state()
    is_nsfw = state.get("nsfw", False)
    offset_key = "nsfw_offset" if is_nsfw else "sfw_offset"
    state[offset_key] = state.get(offset_key, 0) + DISPLAY_COUNT
    cards = get_active_cards(is_nsfw)
    if len(cards) <= state[offset_key]:
        fetch_theme_batch(is_nsfw)
    save_state(state)


def cmd_fetch():
    state = load_state()
    is_nsfw = state.get("nsfw", False)
    fetch_theme_batch(is_nsfw)
    cmd_next()


def cmd_toggle_nsfw():
    state = load_state()
    state["nsfw"] = not state.get("nsfw", False)
    save_state(state)
    get_active_cards(state["nsfw"])
    print(build_output(), flush=True)


def cmd_watch():
    state = load_state()
    is_nsfw = state.get("nsfw", False)
    get_active_cards(is_nsfw)

    print(build_output(), flush=True)

    last_mtime = 0
    if os.path.exists(TRIGGER_FILE):
        last_mtime = os.path.getmtime(TRIGGER_FILE)

    last_colors_mtime = 0
    if os.path.exists(COLORS_SCSS):
        last_colors_mtime = os.path.getmtime(COLORS_SCSS)

    counter = 0
    while True:
        time.sleep(0.5)
        counter += 1

        triggered = False

        if os.path.exists(TRIGGER_FILE):
            mtime = os.path.getmtime(TRIGGER_FILE)
            if mtime != last_mtime:
                last_mtime = mtime
                triggered = True

        if os.path.exists(COLORS_SCSS):
            c_mtime = os.path.getmtime(COLORS_SCSS)
            if c_mtime != last_colors_mtime:
                last_colors_mtime = c_mtime
                current_nsfw = load_state().get("nsfw", False)
                fetch_theme_batch(current_nsfw)
                triggered = True

        if counter >= 120:
            counter = 0
            st = load_state()
            curr_nsfw = st.get("nsfw", False)
            off_key = "nsfw_offset" if curr_nsfw else "sfw_offset"
            st[off_key] = st.get(off_key, 0) + DISPLAY_COUNT
            save_state(st)
            triggered = True

        if triggered:
            print(build_output(), flush=True)


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "watch"
    if action == "watch":
        cmd_watch()
    elif action == "next":
        cmd_next()
    elif action == "fetch":
        cmd_fetch()
    elif action == "toggle_nsfw":
        cmd_toggle_nsfw()
    elif action == "get":
        print(build_output())
    else:
        print(f"Unknown action {action}", file=sys.stderr)

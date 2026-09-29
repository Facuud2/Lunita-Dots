#!/usr/bin/env python3
# ==============================================================================
# 🍎 macOS Sonoma / Sequoia Tab Bar for Kitty
# Refined Cupertino pill tabs with clean title formatting, balanced margins,
# and a fully functional '+' new-tab button.
# ==============================================================================

import sys
from kitty.tab_bar import (
    CellRange,
    DrawData,
    ExtraData,
    TabBarData,
    TabExtent,
    as_rgb,
)
from kitty.fast_data_types import Screen

# macOS Dark Surface Colors (Cupertino HIG)
ACTIVE_TAB_BG = as_rgb(0x3A3A3C)    # Cupertino active surface
ACTIVE_TAB_FG = as_rgb(0xFFFFFF)    # Pure white
INACTIVE_TAB_BG = as_rgb(0x242426)  # Dark translucent surface
INACTIVE_TAB_FG = as_rgb(0x8E8E93)  # Apple system gray
PLUS_BG = as_rgb(0x2C2C2E)          # Rounded button surface
PLUS_FG = as_rgb(0xD1D1D6)          # Button icon white/silver
MUTED_GRAY = as_rgb(0x636366)       # Subtle gray for Apple branding

ROUNDED_LEFT = ""
ROUNDED_RIGHT = ""


def _find_cell_ranges() -> list[TabExtent] | None:
    """Find the cell_ranges list from Kitty's TabBar.update caller frame."""
    for depth in range(1, 10):
        try:
            frame = sys._getframe(depth)
            f_locals = frame.f_locals
            if "cell_ranges" in f_locals and isinstance(f_locals["cell_ranges"], list):
                return f_locals["cell_ranges"]
            if "cr" in f_locals and isinstance(f_locals["cr"], list):
                return f_locals["cr"]
        except Exception:
            break
    return None


def _format_tab_title(raw_title: str, index: int, is_single: bool) -> str:
    """Extract a concise, authentic macOS tab title (folder name or process)."""
    title = (raw_title or "").strip()

    # 1. Remove 'username@hostname:' prefix injected by default zsh termsupport
    if "@" in title and ":" in title:
        title = title.split(":", 1)[1].strip()

    # 2. Extract clean folder name or process name
    if title in ("~", "", "$HOME"):
        clean = "~"
    elif "/" in title:
        parts = [p for p in title.rstrip("/").split("/") if p]
        clean = parts[-1] if parts else "~"
    else:
        clean = title

    # Cap maximum title length so pills remain compact and balanced
    if len(clean) > 16:
        clean = clean[:15] + "…"

    # If multiple tabs are open, prefix with index so they are easy to navigate
    if not is_single:
        return f"{index} · {clean}"
    return clean


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    default_bg = as_rgb(int(draw_data.default_bg))
    is_single_tab = (index == 1 and is_last)

    # 1. Left margin on the very first tab
    if index == 1:
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        screen.cursor.bold = False
        screen.cursor.italic = False
        screen.draw(" ")

    # 2. Format title cleanly (no raw 'user@host:path')
    display_title = _format_tab_title(tab.title, index, is_single_tab)

    # 3. Choose tab colors
    tab_bg = ACTIVE_TAB_BG if tab.is_active else INACTIVE_TAB_BG
    tab_fg = ACTIVE_TAB_FG if tab.is_active else INACTIVE_TAB_FG

    # Ensure font style is clean normal (no italic/serif fallbacks)
    screen.cursor.bold = False
    screen.cursor.italic = False

    # Left rounded cap
    screen.cursor.bg = default_bg
    screen.cursor.fg = tab_bg
    screen.draw(ROUNDED_LEFT)

    # Pill inner body with balanced padding
    screen.cursor.bg = tab_bg
    screen.cursor.fg = tab_fg
    screen.draw(f"  {display_title}  ")

    # Right rounded cap
    screen.cursor.bg = default_bg
    screen.cursor.fg = tab_bg
    screen.draw(ROUNDED_RIGHT)

    # Record the precise end position of the tab pill
    tab_pill_end = screen.cursor.x

    # Gap between tabs
    screen.cursor.bg = default_bg
    screen.cursor.fg = default_bg
    screen.draw(" ")

    # 4. Trailing elements on last tab: Interactive '+' button & Apple logo
    if is_last:
        screen.draw(" ")
        plus_start = screen.cursor.x

        # '+' Button left cap
        screen.cursor.bg = default_bg
        screen.cursor.fg = PLUS_BG
        screen.cursor.bold = False
        screen.cursor.italic = False
        screen.draw(ROUNDED_LEFT)

        # '+' Button body with balanced padding matching tab pills
        screen.cursor.bg = PLUS_BG
        screen.cursor.fg = PLUS_FG
        screen.cursor.bold = False
        screen.cursor.italic = False
        screen.draw("  +  ")

        # '+' Button right cap
        screen.cursor.bg = default_bg
        screen.cursor.fg = PLUS_BG
        screen.cursor.bold = False
        screen.cursor.italic = False
        screen.draw(ROUNDED_RIGHT)

        plus_end = screen.cursor.x

        # Register synthetic TabExtent for the '+' button so single-click creates a new tab
        if not extra_data.for_layout:
            cr = _find_cell_ranges()
            if cr is not None:
                cr.append(TabExtent(tab_id=-1, x=CellRange(plus_start, plus_end)))

        # Apple logo branding on the far right (not registered as any tab)
        apple_text = " "
        cur_x = screen.cursor.x
        remaining = screen.columns - cur_x - len(apple_text) - 1
        if remaining > 2:
            screen.cursor.bg = default_bg
            screen.cursor.fg = MUTED_GRAY
            screen.cursor.bold = False
            screen.cursor.italic = False
            screen.draw(" " * remaining)
            screen.draw(apple_text)

    # Return tab_pill_end so Kitty's caller only maps this tab to its own pill,
    # leaving '+' and the Apple logo completely outside the tab's rename/focus region.
    return tab_pill_end

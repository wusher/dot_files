#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path

STATE_FILE = ".workstate"

STATES = {
    "wip": ("󱨎", "#9ece6a"),
    "review": ("󰔟", "#ff00ff"),
    "feedback": ("󰤉", "#ff5f87"),
    "fixing-ci": ("󰙨", "#ff5f87"),
    "exploring": ("󱗖", "#449dab"),
    "blocked": ("󰜺", "#e0af68"),
    "post-deploy": ("", "#e0af68"),
    "done": ("󰄬", "#2da44e"),
}


def run(cmd: list[str]) -> str:
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


def project_root(path: Path) -> Path:
    root = run(["git", "-C", str(path), "rev-parse", "--show-toplevel"])
    if root:
        return Path(root)
    cur = path
    while True:
        if (cur / STATE_FILE).exists():
            return cur
        if cur.parent == cur:
            return path
        cur = cur.parent


def main() -> int:
    pane_path = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    text_color = sys.argv[2] if len(sys.argv) > 2 else "#a9b1d6"
    activity_flag = sys.argv[3] if len(sys.argv) > 3 else "0"
    bell_flag = sys.argv[4] if len(sys.argv) > 4 else "0"
    default_icon = sys.argv[5] if len(sys.argv) > 5 else None

    root = project_root(pane_path)
    state_path = root / STATE_FILE
    state = state_path.read_text(encoding="utf-8").strip().lower() if state_path.exists() else ""

    if state in STATES:
        icon, color = STATES[state]
        if default_icon is not None:
            print(icon)
        else:
            print(f"#[fg={color}]{icon}#[fg={text_color}]")
    else:
        if default_icon is not None:
            icon = default_icon
        elif activity_flag == "1":
            icon = "󰈈"
        elif bell_flag == "1":
            icon = "󰂞"
        else:
            icon = ""
        print(icon)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

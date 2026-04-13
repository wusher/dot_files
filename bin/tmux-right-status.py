#!/usr/bin/env python3

import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

CACHE_FILE = Path("/tmp/tmux-status-cache.json")
CACHE_TTL = 3  # seconds for most data
SYS_CACHE_TTL = 5  # seconds for system stats (battery, cpu, memory)
MEETING_SOON_MINUTES = 30
MEETING_URGENT_MINUTES = 10
MEETING_ALERT_BG = "#f7768e"
MEETING_ALERT_BG_CURRENT = "#f05a76"
MEETING_ALERT_FG = "#1f2335"


def load_cache(ttl: int = CACHE_TTL) -> dict | None:
    try:
        if CACHE_FILE.exists():
            mtime = CACHE_FILE.stat().st_mtime
            if (time.time() - mtime) < ttl:
                with CACHE_FILE.open("r", encoding="utf-8") as f:
                    return json.load(f)
    except Exception:
        pass
    return None


def save_cache(data: dict) -> None:
    try:
        with CACHE_FILE.open("w", encoding="utf-8") as f:
            json.dump(data, f)
    except Exception:
        pass


def run(cmd: list[str]) -> str:
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


def run_quiet(cmd: list[str]) -> bool:
    try:
        result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return result.returncode == 0
    except Exception:
        return False


def truncate_text(text: str, max_len: int) -> str:
    if len(text) <= max_len:
        return text
    if max_len <= 3:
        return text[:max_len]
    return text[: max_len - 3] + "..."


def next_meeting() -> dict | None:
    raw = run([str(Path.home() / "bin" / "cal_next"), "--raw"])
    if not raw or raw == "NONE":
        return None

    parts = raw.split("\t", 1)
    if len(parts) != 2:
        return None

    try:
        start_ts = int(parts[0])
    except ValueError:
        return None

    now_ts = int(time.time())
    if start_ts < now_ts:
        return None

    title = parts[1].strip() or "(No title)"
    minutes_until = int((start_ts - now_ts + 59) // 60)
    return {"title": title, "minutes_until": minutes_until}


def option_cache_name(option_name: str) -> str:
    return "@meeting_prev_" + option_name.replace("@", "").replace("-", "_")


def save_option_for_restore(option_name: str) -> None:
    value = run(["tmux", "show-option", "-gv", option_name])
    run_quiet(["tmux", "set-option", "-gq", option_cache_name(option_name), value])


def restore_option(option_name: str) -> None:
    cached = run(["tmux", "show-option", "-gv", option_cache_name(option_name)])
    if cached:
        run_quiet(["tmux", "set-option", "-gq", option_name, cached])


def apply_meeting_alert_style(is_urgent: bool) -> None:
    active = run(["tmux", "show-option", "-gv", "@meeting_alert"]) == "1"

    if is_urgent and not active:
        for option_name in [
            "@status_bg",
            "@status_fg",
            "status-style",
            "status-left-style",
            "status-right-style",
            "window-status-format",
            "window-status-current-format",
            "window-status-activity-style",
            "window-status-bell-style",
        ]:
            save_option_for_restore(option_name)

        run_quiet(["tmux", "set-option", "-gq", "@status_bg", MEETING_ALERT_BG])
        run_quiet(["tmux", "set-option", "-gq", "@status_fg", MEETING_ALERT_FG])
        run_quiet(["tmux", "set-option", "-gq", "@meeting_alert", "1"])
        run_quiet(["tmux", "set-option", "-gq", "status-style", f"bg={MEETING_ALERT_BG},fg={MEETING_ALERT_FG}"])
        run_quiet(["tmux", "set-option", "-gq", "status-left-style", f"bg={MEETING_ALERT_BG},fg={MEETING_ALERT_FG}"])
        run_quiet(["tmux", "set-option", "-gq", "status-right-style", f"bg={MEETING_ALERT_BG},fg={MEETING_ALERT_FG}"])
        run_quiet([
            "tmux",
            "set-option",
            "-gq",
            "window-status-format",
            '#[fg=#{@status_bg},bg=#{@status_bg}]#[fg=#{@status_fg},bg=#{@status_bg}]#($HOME/bin/tmux-workstate.py "#{pane_current_path}" "#{@status_fg}" "#{window_activity_flag}" "#{window_bell_flag}") #I:#(basename "#{pane_current_path}" | sed -E "s/^fleet(io)?-//" | cut -c1-15)#[fg=#{@status_bg},bg=#{@status_bg}]',
        ])
        run_quiet([
            "tmux",
            "set-option",
            "-gq",
            "window-status-current-format",
            f'#[fg=#{{@status_bg}},bg={MEETING_ALERT_BG_CURRENT},bold]#[fg={MEETING_ALERT_FG},bg={MEETING_ALERT_BG_CURRENT},bold] #I:#(basename "#{{pane_current_path}}" | sed -E "s/^fleet(io)?-//" | cut -c1-15)#[fg={MEETING_ALERT_BG_CURRENT},bg=#{{@status_bg}},nobold]',
        ])
        run_quiet(["tmux", "set-option", "-gq", "window-status-activity-style", f"fg={MEETING_ALERT_FG},bg={MEETING_ALERT_BG},bold"])
        run_quiet(["tmux", "set-option", "-gq", "window-status-bell-style", f"fg={MEETING_ALERT_FG},bg={MEETING_ALERT_BG_CURRENT},bold"])
        return

    if not is_urgent and active:
        for option_name in [
            "@status_bg",
            "@status_fg",
            "status-style",
            "status-left-style",
            "status-right-style",
            "window-status-format",
            "window-status-current-format",
            "window-status-activity-style",
            "window-status-bell-style",
        ]:
            restore_option(option_name)

        run_quiet(["tmux", "set-option", "-gq", "@meeting_alert", "0"])


def meeting_branch_label(meeting: dict | None) -> str | None:
    if not meeting:
        return None

    minutes_until = int(meeting.get("minutes_until", 9999))
    if minutes_until > MEETING_SOON_MINUTES:
        return None

    title = truncate_text(meeting.get("title", "(No title)"), 18)
    countdown = "now" if minutes_until <= 0 else f"{minutes_until}m"
    return f"󰃰 {title} {countdown}"


def git_segment(path: str, meeting: dict | None = None) -> str:
    meeting_label = meeting_branch_label(meeting)

    if not path:
        return f" {meeting_label}" if meeting_label else " -"

    if run(["git", "-C", path, "rev-parse", "--is-inside-work-tree"]) != "true":
        return f" {meeting_label}" if meeting_label else " -"

    branch = run(["git", "-C", path, "symbolic-ref", "--short", "HEAD"])
    if not branch:
        branch = run(["git", "-C", path, "rev-parse", "--short", "HEAD"])

    display_branch = meeting_label if meeting_label else branch

    porcelain = run(["git", "-C", path, "status", "--porcelain"])
    dirty = ""
    untracked = ""
    sync = ""
    if porcelain:
        lines = porcelain.splitlines()
        has_staged = False
        has_unstaged = False
        has_untracked = False

        for line in lines:
            if line.startswith("??"):
                has_untracked = True
                continue
            if len(line) >= 2:
                if line[0] != " ":
                    has_staged = True
                if line[1] != " ":
                    has_unstaged = True

        if has_staged and has_unstaged:
            dirty = " #[fg=#2ac3de]●#[fg=#e0af68]"
        elif has_staged:
            dirty = " #[fg=#9ece6a]●#[fg=#e0af68]"
        elif has_unstaged:
            dirty = " #[fg=#f7768e]●#[fg=#e0af68]"

        if has_untracked:
            untracked = " #[fg=#f7768e]◯#[fg=#e0af68]"

    ahead = 0
    behind = 0
    counts = run(["git", "-C", path, "rev-list", "--left-right", "--count", "@{upstream}...HEAD"])
    if counts:
        parts = counts.split()
        if len(parts) >= 2:
            try:
                behind = int(parts[0])
                ahead = int(parts[1])
            except ValueError:
                behind = 0
                ahead = 0

    if ahead > 0 and behind > 0:
        sync = " #[fg=#bb9af7]⇅#[fg=#e0af68]"
    elif ahead > 0:
        sync = " #[fg=#7aa2f7]↑#[fg=#e0af68]"
    elif behind > 0:
        sync = " #[fg=#e0af68]↓#[fg=#e0af68]"

    status = f"{dirty}{untracked}{sync}"
    separator = " #[fg=#414868]│#[fg=#e0af68]" if status else ""
    return f" {display_branch}{separator}{status}"


def count_active_processes() -> dict[str, int]:
    """Run ps aux once and count all patterns."""
    try:
        result = subprocess.run(
            ["ps", "aux"],
            capture_output=True,
            text=True
        )
        counts = {"claude": 0, "opencode": 0, "codex": 0}
        for line in result.stdout.splitlines():
            lower = line.lower()
            if "grep" in lower:
                continue
            parts = line.split()
            if len(parts) <= 2:
                continue
            try:
                cpu = float(parts[2])
            except ValueError:
                continue
            if cpu <= 3.0:
                continue
            if "claude" in lower:
                counts["claude"] += 1
            elif "opencode" in lower:
                counts["opencode"] += 1
            elif "codex" in lower:
                counts["codex"] += 1
        return counts
    except Exception:
        return {"claude": 0, "opencode": 0, "codex": 0}


def battery_segment() -> str:
    """Get battery percentage and charging status."""
    try:
        result = run(["pmset", "-g", "batt"])
        if not result:
            return ""
        
        # Parse pmset output for percentage and charging state
        # Example: "Now drawing from 'Battery Power' -InternalBattery-0 85%; discharging"
        # Extract percentage
        pct_match = re.search(r'(\d+)%', result)
        pct = int(pct_match.group(1)) if pct_match else 0
        pct = min(99, max(0, pct))
        
        # Check if charging (avoid matching "discharging")
        lower = result.lower()
        is_charging = (
            "ac power" in lower
            or "; charging" in lower
            or "; charged" in lower
            or "; finishing charge" in lower
        )
        
        if is_charging and pct < 95:
            return f"#[fg=#e0af68]󰚥 {pct}%"

        if pct < 20:
            return f"#[fg=#ff5f87]󰁺 {pct}%"
        if pct <= 60:
            return f"#[fg=#bb9af7]󰁽 {pct}%"
        if pct < 80:
            return f"#[default]󰂁 {pct}%"
        return f"#[default]󰁹 {pct}%"
    except Exception:
        return ""


def cpu_memory_segment() -> str:
    """Get CPU and memory usage."""
    cpu_pct = 0
    mem_pct = 0

    inactive_style = run(["tmux", "show-option", "-gv", "window-status-style"])
    fg_match = re.search(r"(?:^|,)fg=([^,]+)", inactive_style)
    inactive_fg_style = "#[default]"
    if fg_match:
        inactive_fg = fg_match.group(1).strip()
        if inactive_fg != "default":
            inactive_fg_style = f"#[fg={inactive_fg}]"
    
    try:
        # Get CPU usage - sample once, wait 0.5s, sample again
        result = run(["top", "-l", "2", "-n", "0", "-F"])
        lines = result.split('\n')
        
        # Find CPU usage line (will appear twice, we want the second one)
        cpu_line = ""
        for line in lines:
            if 'CPU usage:' in line:
                cpu_line = line
        
        if cpu_line:
            # Parse: "CPU usage: 15.23% user, 5.12% sys, 79.65% idle"
            user_match = re.search(r'(\d+\.?\d*)%\s+user', cpu_line)
            sys_match = re.search(r'(\d+\.?\d*)%\s+sys', cpu_line)
            if user_match and sys_match:
                user = float(user_match.group(1))
                sys = float(sys_match.group(1))
                cpu_pct = int(user + sys)
    except Exception:
        pass
    
    try:
        # Get memory usage using vm_stat to match Activity Monitor
        # Activity Monitor shows: App Memory + Wired + Compressed (excluding cached)
        result = run(["vm_stat"])
        if result:
            # Parse vm_stat output
            page_size = 16384  # 16KB on Apple Silicon, 4KB on Intel
            
            wired = re.search(r'Pages wired down:\s+(\d+)', result)
            active = re.search(r'Pages active:\s+(\d+)', result)
            speculative = re.search(r'Pages speculative:\s+(\d+)', result)
            compressed = re.search(r'Pages occupied by compressor:\s+(\d+)', result)
            
            # Get total memory
            total_result = run(["sysctl", "-n", "hw.memsize"])
            if total_result and wired and active:
                total_bytes = int(total_result)
                total_gb = total_bytes / (1024**3)
                
                # Calculate used memory (matches Activity Monitor)
                # Used = Wired + Active + Speculative + Compressed
                wired_pages = int(wired.group(1))
                active_pages = int(active.group(1))
                spec_pages = int(speculative.group(1)) if speculative else 0
                compressed_pages = int(compressed.group(1)) if compressed else 0
                
                used_pages = wired_pages + active_pages + spec_pages + compressed_pages
                used_gb = (used_pages * page_size) / (1024**3)
                
                mem_pct = int((used_gb / total_gb) * 100)
    except Exception:
        pass

    cpu_pct = min(99, max(0, cpu_pct))
    mem_pct = min(99, max(0, mem_pct))

    cpu_color = None if cpu_pct <= 75 else "#e0af68" if cpu_pct <= 90 else "#f7768e"
    mem_color = None if mem_pct <= 70 else "#e0af68" if mem_pct <= 85 else "#f7768e"

    cpu_part = f"{inactive_fg_style}󰻠 {cpu_pct:02d}%" if cpu_color is None else f"#[fg={cpu_color}]󰻠 {cpu_pct:02d}%"
    mem_part = f"{inactive_fg_style}󰍜 {mem_pct:02d}%" if mem_color is None else f"#[fg={mem_color}]󰍜 {mem_pct:02d}%"

    return f"{cpu_part} {mem_part}"


def time_until_reset() -> str:
    now = datetime.now()
    midnight_pt = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    midnight_pt = midnight_pt - timedelta(hours=8)
    if now > midnight_pt:
        midnight_pt = midnight_pt + timedelta(days=1)
    
    diff = midnight_pt - now
    hours = int(diff.total_seconds() // 3600)
    minutes = int((diff.total_seconds() % 3600) // 60)
    
    if hours > 0:
        return f"{hours}h"
    return f"{minutes}m"


def get_claude_usage() -> tuple[int, int]:
    today = datetime.now().date()
    claude_tokens = 0
    claude_file = Path.home() / ".claude/stats-cache.json"
    
    if claude_file.exists():
        try:
            with claude_file.open("r", encoding="utf-8") as f:
                data = json.load(f)
            day = today.isoformat()
            for entry in data.get("dailyModelTokens", []):
                if entry.get("date") != day:
                    continue
                tokens_by_model = entry.get("tokensByModel", {})
                claude_tokens = sum(
                    int(v) for k, v in tokens_by_model.items() if str(k).startswith("claude-")
                )
                break
        except Exception:
            claude_tokens = 0
    
    limit = 2_000_000
    pct = min(100, int((claude_tokens / limit) * 100)) if limit > 0 else 0
    
    return claude_tokens, pct


def fmt_tokens(value: int) -> str:
    if value >= 1_000_000:
        return f"{value / 1_000_000:.1f}M"
    if value >= 1_000:
        return f"{value / 1_000:.1f}k"
    return str(value)


def compact_path(path: str) -> str:
    name = Path(path).name or path
    if name.startswith("fleetio-"):
        return name[8:]
    if name.startswith("fleet-"):
        return name[6:]
    return name


def main() -> int:
    pane_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    meeting = next_meeting()
    urgent_meeting = bool(meeting and meeting.get("minutes_until", 9999) <= MEETING_URGENT_MINUTES)
    apply_meeting_alert_style(urgent_meeting)
    
    # Try cache first (use fast TTL for git/path, slow TTL for system stats)
    cached = load_cache(CACHE_TTL)
    cached_sys = load_cache(SYS_CACHE_TTL)
    
    # Use cached system stats if available
    if cached_sys and cached_sys.get("battery") is not None:
        battery = cached_sys.get("battery", "")
        cpu_mem = cached_sys.get("cpu_mem", "")
    else:
        battery = battery_segment()
        cpu_mem = cpu_memory_segment()
        # Save system stats with their own TTL
        save_cache({"battery": battery, "cpu_mem": cpu_mem, "path": "sys"})
    
    # Use cached git/path if available
    if cached and cached.get("path") == pane_path:
        print(cached["output"])
        return 0
    
    # Compute git/path data
    git = git_segment(pane_path, meeting)
    process_counts = count_active_processes()
    
    battery = battery_segment()
    cpu_mem = cpu_memory_segment()
    
    output_parts = []
    
    # Path
    output_parts.append(f"#[fg=#414868]│ #[fg=#9ece6a] {compact_path(pane_path)}")
    
    # Git
    output_parts.append(f"#[fg=#414868]│ #[fg=#e0af68]{git}")
    
    # CPU/Memory
    output_parts.append(f"#[fg=#414868]│ {cpu_mem}")
    
    # AI process count
    openai_count = process_counts["codex"] + process_counts["opencode"]
    output_parts.append(f"#[fg=#414868]│ #[fg=#7aa2f7]🤖{openai_count} ")
    
    output = " ".join(output_parts)

    # Save everything together
    save_cache({
        "path": pane_path, 
        "output": output,
        "battery": battery,
        "cpu_mem": cpu_mem
    })
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

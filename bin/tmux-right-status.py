#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

CACHE_FILE = Path("/tmp/tmux-status-cache.json")
CACHE_TTL = 3  # seconds for most data
SYS_CACHE_TTL = 5  # seconds for system stats (battery, cpu, memory)


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


def git_segment(path: str) -> str:
    if not path:
        return " -"

    if run(["git", "-C", path, "rev-parse", "--is-inside-work-tree"]) != "true":
        return " -"

    branch = run(["git", "-C", path, "symbolic-ref", "--short", "HEAD"])
    if not branch:
        branch = run(["git", "-C", path, "rev-parse", "--short", "HEAD"])

    porcelain = run(["git", "-C", path, "status", "--porcelain"])
    dirty = ""
    untracked = ""
    if porcelain:
        lines = porcelain.splitlines()
        if any(not line.startswith("??") for line in lines):
            dirty = "*"
        if any(line.startswith("??") for line in lines):
            untracked = "?"

    return f" {branch}{dirty}{untracked}"


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
            if cpu <= 1.0:
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
        import re
        
        # Extract percentage
        pct_match = re.search(r'(\d+)%', result)
        pct = pct_match.group(1) if pct_match else "0"
        
        # Check if charging
        is_charging = 'AC Power' in result or 'charging' in result.lower() or 'charged' in result.lower()
        
        # Use only one emoji based on status
        icon = "⚡" if is_charging else "🔋"
        
        return f"{icon}{pct}%"
    except Exception:
        return ""


def cpu_memory_segment() -> str:
    """Get CPU and memory usage."""
    cpu_pct = 0
    mem_pct = 0
    
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
            import re
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
            import re
            
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

    cpu_color = "#9ece6a" if cpu_pct <= 75 else "#e0af68" if cpu_pct <= 90 else "#f7768e"
    mem_color = "#9ece6a" if mem_pct <= 70 else "#e0af68" if mem_pct <= 85 else "#f7768e"

    return f"#[fg={cpu_color}]󰻠 {cpu_pct:02d}% #[fg={mem_color}]󰍜 {mem_pct:02d}%"


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
    home = str(Path.home())
    shown = path.replace(home, "~")
    if len(shown) <= 36:
        return shown
    return "..." + shown[-33:]


def main() -> int:
    pane_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    
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
    git = git_segment(pane_path)
    _, claude_pct = get_claude_usage()
    reset_time = time_until_reset()
    process_counts = count_active_processes()
    
    battery = battery_segment()
    cpu_mem = cpu_memory_segment()
    
    output_parts = []
    
    # Battery (if available)
    if battery:
        output_parts.append(f"#[fg=#9ece6a]{battery}")
    
    # CPU/Memory
    output_parts.append(cpu_mem)
    
    # Path
    output_parts.append(f"#[fg=#414868]│ #[fg=#9ece6a] {compact_path(pane_path)}")
    
    # Git
    output_parts.append(f"#[fg=#414868]│ #[fg=#e0af68]{git}")
    
    # Claude usage
    output_parts.append(f"#[fg=#414868]│ #[fg=#bb9af7]󰚩 {claude_pct}%  {reset_time}")
    
    # Process counts
    output_parts.append(f"#[fg=#414868]│ #[fg=#e0af68]{process_counts['claude']} #[fg=#7aa2f7]{process_counts['codex']} #[fg=#9ece6a]{process_counts['opencode']}")
    
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

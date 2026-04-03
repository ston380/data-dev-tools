#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
dir=$(echo "$input" | jq -r '.workspace.current_dir')
hostname=$(hostname -s)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
max_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Extract token usage data
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
current_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')

# Extract model information
model_display=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')

# Get battery level and charging status
batt_output=$(pmset -g batt)
battery=$(echo "$batt_output" | grep -o '[0-9]*%' | head -1)
charging=$(echo "$batt_output" | grep -q 'AC Power' && echo "yes" || echo "no")

# Line 1: Directory@hostname with battery
if [ -n "$battery" ]; then
    # Strip the % sign to compare numerically
    batt_num="${battery%%%}"
    if [ "$batt_num" -le 20 ]; then
        batt_color="\033[38;5;196m"  # Red for <= 20%
    elif [ "$batt_num" -le 50 ]; then
        batt_color="\033[38;5;214m"  # Orange for <= 50%
    else
        batt_color="\033[38;5;34m"   # Green for > 50%
    fi
    if [ "$charging" = "yes" ]; then
        batt_icon=" "
    else
        batt_icon="⚡"
    fi
    status=$(printf "\033[2m%s\033[0m\033[38;5;208m@%s\033[0m ${batt_color}%s%s\033[0m" "$dir" "$hostname" "$batt_icon" "$battery")
else
    status=$(printf "\033[2m%s\033[0m\033[38;5;208m@%s\033[0m" "$dir" "$hostname")
fi

# Build model indicator (used on progress bar line)
model_tag=""
if [ -n "$model_display" ]; then
    model_short=""
    version=""
    version=$(echo "$model_display" | grep -oE '[0-9]+\.[0-9]+' | head -1)

    if echo "$model_display" | grep -qi "opus"; then
        if [ -n "$version" ]; then
            model_short="\033[38;5;99mOpus $version\033[0m"
        else
            model_short="\033[38;5;99mOpus\033[0m"
        fi
    elif echo "$model_display" | grep -qi "sonnet"; then
        if [ -n "$version" ]; then
            model_short="\033[38;5;75mSonnet $version\033[0m"
        else
            model_short="\033[38;5;75mSonnet\033[0m"
        fi
    elif echo "$model_display" | grep -qi "haiku"; then
        if [ -n "$version" ]; then
            model_short="\033[38;5;114mHaiku $version\033[0m"
        else
            model_short="\033[38;5;114mHaiku\033[0m"
        fi
    fi

    if echo "$model_id" | grep -qi "fast"; then
        model_short+=" \033[38;5;226m⚡\033[0m"
    fi

    if [ -n "$model_short" ]; then
        model_tag=$(printf "[%b] " "$model_short")
    fi
fi

# Line 2: Git info
line2=""

# Get git information (skip optional locks for performance)
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
    # Get repository name (basename of git root directory)
    repo_root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
    repo_name=$(basename "$repo_root" 2>/dev/null)

    # Get current branch
    branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)

    # If branch is empty, try to get detached HEAD info
    if [ -z "$branch" ]; then
        branch=$(git -C "$dir" --no-optional-locks describe --tags --exact-match 2>/dev/null || echo "detached")
    fi

    # Add git info to line 2 if available
    if [ -n "$repo_name" ] && [ -n "$branch" ]; then
        git_info=$(printf "\033[38;5;105m%s\033[0m:\033[38;5;141m%s\033[0m" "$repo_name" "$branch")

        # Check working tree status
        git_status_symbol=""
        if git -C "$dir" --no-optional-locks diff --quiet 2>/dev/null && git -C "$dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            # Check for untracked files
            if [ -z "$(git -C "$dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
                git_status_symbol=$(printf "\033[38;5;34m✓\033[0m")  # Green checkmark for clean
            else
                git_status_symbol=$(printf "\033[38;5;214m?\033[0m")  # Orange ? for untracked
            fi
        elif ! git -C "$dir" --no-optional-locks diff --quiet 2>/dev/null; then
            git_status_symbol=$(printf "\033[38;5;196m✗\033[0m")  # Red X for uncommitted changes
        elif ! git -C "$dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            git_status_symbol=$(printf "\033[38;5;214m±\033[0m")  # Orange ± for staged changes
        fi

        git_info+=" $git_status_symbol"

        # Check ahead/behind remote
        upstream=$(git -C "$dir" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$dir" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null)
            behind=$(git -C "$dir" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null)

            if [ -n "$ahead" ] && [ "$ahead" -gt 0 ]; then
                git_info+=$(printf " \033[38;5;34m↑%s\033[0m" "$ahead")  # Green up arrow for ahead
            fi

            if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
                git_info+=$(printf " \033[38;5;196m↓%s\033[0m" "$behind")  # Red down arrow for behind
            fi
        fi

        # Add git info to line 2
        line2="$git_info"
    fi
fi

# Add line 2 to status if it has content
if [ -n "$line2" ]; then
    status+=$(printf "\n%s" "$line2")
fi

# Line 3: Context window progress bar (if available)
if [ -n "$used_pct" ]; then
    bar_width=20
    filled=$(printf "%.0f" "$(echo "$used_pct * $bar_width / 100" | bc -l)")
    empty=$((bar_width - filled))

    # Choose color based on usage
    if [ "$(echo "$used_pct >= 90" | bc -l)" -eq 1 ]; then
        color="\033[38;5;196m"  # Red for 90%+
    elif [ "$(echo "$used_pct >= 70" | bc -l)" -eq 1 ]; then
        color="\033[38;5;214m"  # Orange for 70-89%
    else
        color="\033[38;5;34m"   # Green for <70%
    fi

    # Build retro progress bar
    bar=""
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    # Format context window size
    ctx_size=""
    if [ -n "$max_tokens" ] && [ "$max_tokens" != "0" ]; then
        max_k=$(echo "scale=0; $max_tokens / 1000" | bc -l)
        ctx_size=$(printf " [%sK]" "$max_k")
    fi

    # Add progress bar on line 3 with model name prefix
    status+=$(printf "\n%b${color}%s %.0f%%%s\033[0m" "$model_tag" "$bar" "$used_pct" "$ctx_size")
fi

# Line 4: Session token usage and cache efficiency (if available)
if [ -n "$total_input" ] && [ -n "$total_output" ]; then
    # Format token counts in K (thousands)
    total_in_k=$(echo "scale=1; $total_input / 1000" | bc -l)
    total_out_k=$(echo "scale=1; $total_output / 1000" | bc -l)

    # Build token usage line
    token_line=$(printf "\033[38;5;243mTokens: ↑%sK ↓%sK\033[0m" "$total_in_k" "$total_out_k")

    # Add cache efficiency if cache data is available
    if [ -n "$cache_read" ] && [ -n "$current_input" ] && [ "$current_input" != "0" ]; then
        # Calculate cache hit percentage
        cache_pct=$(echo "scale=1; ($cache_read / $current_input) * 100" | bc -l)

        # Color code cache efficiency
        if [ "$(echo "$cache_pct >= 50" | bc -l)" -eq 1 ]; then
            cache_color="\033[38;5;34m"  # Green for good cache usage
        elif [ "$(echo "$cache_pct >= 20" | bc -l)" -eq 1 ]; then
            cache_color="\033[38;5;214m"  # Orange for moderate cache usage
        else
            cache_color="\033[38;5;243m"  # Gray for low cache usage
        fi

        token_line+=$(printf " ${cache_color}Cache: %.0f%%\033[0m" "$cache_pct")
    fi

    status+=$(printf "\n%s" "$token_line")
fi

echo "$status"

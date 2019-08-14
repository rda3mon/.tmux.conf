#!/usr/bin/env bash

# Credit: Referenced from https://github.com/tmux-plugins/tpm 

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#source "$CURRENT_DIR/scripts/helpers.sh"

cpu_interpolation=(
	"\#{mem_percentage}"
)
cpu_commands=(
	"#($CURRENT_DIR/scripts/mem_percentage.sh)"
)

get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

do_interpolation() {
	local all_interpolated="$1"
	echo $all_interpolated > /tmp/test
	for ((i=0; i<${#cpu_commands[@]}; i++)); do
		all_interpolated=${all_interpolated/${cpu_interpolation[$i]}/${cpu_commands[$i]}}
	done
	echo $all_interpolated >> /tmp/test
	echo "$all_interpolated"
}

set_tmux_option() {
	local option=$1
	local value=$2
	tmux set-option -gq "$option" "$value"
}

update_tmux_option() {
	local option=$1
	local option_value=$(get_tmux_option "$option")
	local new_option_value=$(do_interpolation "$option_value")
	set_tmux_option "$option" "$new_option_value"
}


main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}
main

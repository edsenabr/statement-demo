# Author: edsena@amazon.com
# this helper scripts aims to provide auto-complete for any batch file written in bash. you need jq istalled for that to work
# you need to declare a AUTOCOMPLETE_OPTIONS variable in your script with the following structure (infinite levels of recursion are supported)
# 
# AUTOCOMPLETE_OPTIONS=$(cat <<-EOF
# {
#   "option_1": {
#       "suboption_1_1": null,
#       "suboption_1_2": null
#   },
#   "option_2": {
#       "suboption_2_1": null,
#       "suboption_2_2": {
# 	      "suboption_2_2_1": null,
# 	      "suboption_2_2_2": null
# 			}
#   },
#   "option_3": null
# }
# EOF
# );
sourced=
if [[ "$0" != "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"  ]]; then
			script=$(basename ${BASH_SOURCE[${#BASH_SOURCE[@]}-1]})
      echo autocomplete: removing old entries

      for entry in $(complete -p | grep $script | awk '{print $NF}'); do
        echo "autocomplete:   removing $entry"
        complete -r $entry
      done;
			source /dev/stdin << EOF
				__auto_complete_$script() {
					local completed=("\${COMP_WORDS[@]:1:\${COMP_CWORD}-1}")
					local completing=\${COMP_WORDS[COMP_CWORD]}
					completion=\$(\$1 --auto-complete \${completed[*]})
					COMPREPLY=( \$(compgen -W "\${completion}" -- \${completing}) )
					return 0
				}
EOF
      echo autocomplete: adding entry for $script
      complete -F __auto_complete_$script $script
      echo autocomplete: done
      sourced=1
elif [[ $1 == "--auto-complete" ]]; then
	shift
	query=
	while [ $# -gt 0 ]; do
		query="$query.$1 | "
		shift
	done
	query="$query . |= keys | @tsv"
	RESULT=$(jq -r "$query" <<< $AUTOCOMPLETE_OPTIONS 2> /dev/null)
	echo $RESULT
	exit 0;
fi;

#!/usr/bin/env bash

## Get project's directory
__GOTO_SOURCE="${BASH_SOURCE[0]}"
while [ -h "${__GOTO_SOURCE}" ]; do
  __GOTO_DIR="$( cd -P "$( dirname "${__GOTO_SOURCE}" )" >/dev/null 2>&1 && pwd )"
  __GOTO_SOURCE="$(readlink "${__GOTO_SOURCE}")"
  [[ ${__GOTO_SOURCE} != /* ]] && __GOTO_SOURCE="${__GOTO_DIR}/${__GOTO_SOURCE}"
done
__GOTO_WORKDIR="$( cd -P "$( dirname "${__GOTO_SOURCE}" )" >/dev/null 2>&1 && pwd )"
__GOTO_SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

## Function for printing multiple strings
function goto_user_info() {
	for m in "${@}"; do
		echo "${m}"
	done
}

## Project's direcctory
## Default: ${__GOTO_WORKDIR}. To change this, issue goto set-pdir /some/path
export _goto_workdir="$(python3 ${__GOTO_WORKDIR}/state.py get_workdir)"
export _goto_projectdir="$(python3 ${__GOTO_WORKDIR}/state.py get_workdir)"

## Simple help menu
function __goto_help() {
    echo -e "Goto -- help menu\n"
	echo -e " alias\t\tChange directory to the given alias name"
    echo -e " set <alias>\tSet an alias to this location"
    echo -e " rm  <alias>\tRemove alias from list"
    echo -e " list\t\tList saved aliases"
    echo -e " show-projects\tGet projects"
	echo -e " project\tNavigate to an available project"
	echo -e " set-pdir\tSet a new project path"
    echo -e " help\t\tShow this message and exit"
    echo -e "\n"
}

## _goto cd function
function _goto() {
	is_alias="$(python3 ${__GOTO_WORKDIR}/state.py check ${1})"
	if [[ "${is_alias%%::::*}" == "True" ]]; then
		cd "${is_alias##*::::}"
	else
		subpath="$(python3 "${__GOTO_WORKDIR}/state.py" "check_paths" "${1}")"
		if [[ ! -d "${_goto_projectdir}/${subpath}" ]]; then
			echo "Error: ${subpath} is not a directory or it does not exist"
			return 1
		fi
		echo "Changing directory to --- ${_goto_workdir}/${subpath}"
		cd "${_goto_projectdir}/${subpath}"
	fi
}

## goto routine
function goto() {
	if [[ "${#}" -eq "0" ]]; then
		__goto_help
		return 0
	fi

	while [[ "${#}" -gt "0" ]]; do
		case "${1}" in
			"alias")
				if [[ -z "${2}" ]]; then
					echo "You need to give an alias name"
					return 1
				fi
				echo "Changing directory alias --- ${2}"
				cd "$(python3 "${__GOTO_WORKDIR}/state.py" "alias" "${2}")"
				shift 2;;
			"set")
				if [[ -z "${2}" ]]; then
					echo "You need to give an alias name"
					return 1
				fi
				python3 "${__GOTO_WORKDIR}/state.py" "add" "${2}" "${PWD}"
				shift 2;;
			"list")
				aliases="$(python3 ${__GOTO_WORKDIR}/state.py list)"
				echo "Aliases"
				_IFS="${IFS}"
				IFS=","
				for i in ${aliases}; do
					echo -e "  ${i%%::::*} @ ${i##*::::}"
				done
				IFS="${_IFS}"
				shift 1
				return 0;;
			"rm")
				python3 "${__GOTO_WORKDIR}/state.py" "rm" "${2}"
				shift 2;;
			"show-projects")
				echo "Projects"
				goto_user_info $(ls "${_goto_projectdir}")
				shift 1;;
			"set-pdir")
				if [[ -z "${2}" ]]; then
					echo "What dir?"
					return 1
				fi
				python3 "${__GOTO_WORKDIR}/state.py" "set_workdir" "${2}"
				export _goto_projectdir="$(python3 ${__GOTO_WORKDIR}/state.py get_workdir)"
				shift 2;;
			"project"|"-p")
				if [[ -z "${2}" ]]; then
					echo "Which project?"
					return 1
				fi
				_goto "${2}"
				shift 2;;
			"help")
				__goto_help
				return 0;;				
			*)
				_goto "${@}"
				return 0;;
		esac
	done
	
}


_goto_completions_dir() {
    local cur prev

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

	aliases="$(python3 ${__GOTO_WORKDIR}/state.py list)"

	calianses=""
	_IFS="${IFS}"
	IFS=","
	for i in ${aliases}; do
		calianses="${calianses} ${i%%::::*}"
	done
	IFS="${_IFS}"

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "alias set list rm project -p show-projects set-pdir help ${calianses}" -- ${cur}))
            ;;
        2)
			case ${prev} in
				"project" | "show-projects"| "-p")
					for i in $(ls "${_goto_projectdir}"); do
						if [[ -d "${_goto_projectdir}/${i}" ]]; then
							COMPREPLY+=($(compgen -W "${i}" -- "${cur}"))
						fi
					done;;
				"rm" | "alias")
					aliases="$(python3 ${__GOTO_WORKDIR}/state.py list)"
					_IFS="${IFS}"
					IFS=","
					for i in ${aliases}; do
						COMPREPLY+=($(compgen -W "${i%%::::*}" -- "${cur}"))
					done
					IFS="${_IFS}";;
            esac;;
        *)
            COMPREPLY=();;
    esac
}


complete -F _goto_completions_dir goto


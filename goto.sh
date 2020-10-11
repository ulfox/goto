#!/usr/bin/env bash -e

## Get project's directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do
  DIR="$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}"
done
__WORKDIR="$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )"
__SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

## Function for printing multiple strings
function user_info() {
	for m in "${@}"; do
		echo "${m}"
	done
}

## Project's direcctory
## Default: ${__WORKDIR}. To change this, issue goto set-pdir /some/path
export _goto_workdir="$(python3 ${__WORKDIR}/state.py get_workdir)"

## Simple help menu
function help() {
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
	is_alias="$(python3 ${__WORKDIR}/state.py check ${1})"
	if [[ "${is_alias%%::::*}" == "True" ]]; then
		cd "${is_alias##*::::}"
	else
		subpath="$(python3 "${__WORKDIR}/state.py" "check_paths" "${@}")"
		if [[ ! -d "${_goto_workdir}${subpath}" ]]; then
			echo "Error: ${subpath} is not a directory or it does not exist"
			return 1
		fi
		echo "Changing directory to --- ${_goto_workdir}${subpath}"
		cd "${_goto_workdir}${subpath}"
	fi
}

## goto routine
function goto() {
	if [[ "${#}" -eq "0" ]]; then
		help
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
				cd "$(python3 "${__WORKDIR}/state.py" "alias" "${2}")"
				shift 2;;
			"set")
				if [[ -z "${2}" ]]; then
					echo "You need to give an alias name"
					return 1
				fi
				python3 "${__WORKDIR}/state.py" "add" "${2}" "${PWD}"
				shift 2;;
			"list")
				aliases="$(python3 ${__WORKDIR}/state.py list)"
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
				python3 "${__WORKDIR}/state.py" "rm" "${2}"
				shift 2;;
			"show-projects")
				echo "Projects"
				user_info $(ls "${_goto_workdir}")
				shift 1;;
			"set-pdir")
				if [[ -z "${2}" ]]; then
					echo "What dir?"
					return 1
				fi
				python3 "${__WORKDIR}/state.py" "set_workdir" "${2}"
				export _goto_workdir="$(python3 ${__WORKDIR}/state.py get_workdir)"
				shift 2;;
			"project")
				if [[ -z "${2}" ]]; then
					echo "Which project?"
					return 1
				fi
				_goto "${2}"
				shift 2;;
			"help")
				help
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

	aliases="$(python3 ${__WORKDIR}/state.py list)"

	calianses=""
	_IFS="${IFS}"
	IFS=","
	for i in ${aliases}; do
		calianses="${calianses} ${i%%::::*}"
	done
	IFS="${_IFS}"

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "alias set list rm project show-projects set-pdir help ${calianses}" -- ${cur}))
            ;;
        2)
			case ${prev} in
				"project" | "show-projects")
					for i in $(ls "${_goto_workdir}"); do
						if [[ -d "${_goto_workdir}/${i}" ]]; then
							COMPREPLY+=($(compgen -W "${i}" -- "${cur}"))
						fi
					done;;
				"rm")
					aliases="$(python3 ${__WORKDIR}/state.py list)"
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


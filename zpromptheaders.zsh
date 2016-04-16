#!/bin/zsh -f

#This defines the function git_prompt_header twice: The first definition is a fallback for plain-ASCII terminals, whereas the second definition is compatible with 256-color xterm-compatible terminals, such as xterm and Terminal.app.
#
#If you have hashvis (https://github.com/boredzo/hashvis) installed, the 256-color function will automatically use it to format commit hashes.
#
#To use this function, call it from your PS1 definition, like so:
# setopt PROMPT_SUBST
# export PS1=$'$(git_prompt_header || echo ___)\n'
#
#(I put the usual prompt decorations in $RPS1, which is the right-side prompt.)

function git_prompt_header {
	git status --porcelain >/dev/null 2>&1
	if [[ "$?" -eq 0 ]]; then
		git_HEAD=$(git rev-parse --short=8 HEAD 2>/dev/null || echo -n '(no commit)')
		if [[ "$?" -ne 0 ]]; then
			git_HEAD='(no commit)'
		fi
		git_branch=$(git symbolic-ref --short HEAD || echo '(no branch)')
		git_tag=$(git tag --points-at HEAD 2>/dev/null | tr '\n' ',' | sed -e 's/,$//')
		git_output="_git: ${git_tag:-$git_HEAD}@${git_branch}_"

		echo

		echo -n "$git_output" | sed -e 's/%/%%/g' | tr -d $'\n'
	else
		return 1
	fi
}

#xterm-256color version
if [[ "x$TERM" == "xxterm-256color" ]]; then

function git_prompt_header {
	git status --porcelain >/dev/null 2>&1
	if [[ "$?" -eq 0 ]]; then
		(echo -n | hashvis >/dev/null) 2>/dev/null
		if [[ "$?" -eq 0 ]]; then
			git_HEAD=$(git rev-parse HEAD 2>/dev/null)
			if [[ "$?" -eq 0 ]]; then
				git_HEAD=$(echo -n $git_HEAD | hashvis --one-line | sed -e "s/$git_HEAD//")
			else
				git_HEAD='(no commit)'
			fi
		else
			git_HEAD=$(git rev-parse --short=8 HEAD 2>/dev/null || echo -n '(no commit)')
			if [[ "$?" -ne 0 ]]; then
				git_HEAD='(no commit)'
			fi
		fi
		git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo '(no branch)')
		git_tag=$(git tag --points-at HEAD 2>/dev/null | tr '\n' ',' | sed -e 's/,$//')
		git_output_part1="git: ${git_tag:-$git_HEAD}"
		git_output_part2="@$git_branch"

		echo

		#Slightly-darker background for xterm-256color, plus underline
		echo -n "\033[48;5;${PROMPT_GIT_XTERM_BACKGROUND_COLOR:-${PROMPT_XTERM_BACKGROUND_COLOR:=234}}m\033[4m "

		echo -n "$git_output_part1" | sed -e 's/%/%%/g' | tr -d $'\n'
		echo -n "\033[48;5;${PROMPT_GIT_XTERM_BACKGROUND_COLOR:-${PROMPT_XTERM_BACKGROUND_COLOR:=234}}m\033[4m"
		echo -n "$git_output_part2" | sed -e 's/%/%%/g' | tr -d $'\n'

		#Reset color
		echo $' \033[0m'
	else
		return 1
	fi
}

fi #xterm-256color

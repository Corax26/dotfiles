# .bashrc

########################### Source external scripts ###########################

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

# Source specific before (e.g. env var)
if [[ -f $HOME/.bashrc_specific_before ]]; then
    . $HOME/.bashrc_specific_before
fi


################################# Setup prompt ################################

# Colors for display
if [[ $(tput colors) -ge 256 ]]; then
    BLACK="\[\e[38;5;0m\]"
    BLUE="\[\e[38;5;27m\]"
    GREEN="\[\e[38;5;28m\]"
    CYAN="\[\e[38;5;37m\]"
    RED="\[\e[38;5;160m\]"
    MAGENTA="\[\e[38;5;99m\]"
    YELLOW="\[\e[38;5;214m\]"
    WHITE="\[\e[38;5;255m\]"
else
    BLACK="\[$(tput setf 0)\]"
    BLUE="\[$(tput setf 62)\]"
    GREEN="\[$(tput setf 2)\]"
    CYAN="\[$(tput setf 3)\]"
    RED="\[$(tput setf 4)\]"
    MAGENTA="\[$(tput setf 5)\]"
    YELLOW="\[$(tput setf 6)\]"
    WHITE="\[$(tput setf 7)\]"
fi

RESET_COLOR="\[$(tput sgr0)\]"
BOLD="\[$(tput bold)\]"
REV="\[$(tput rev)\]"

# Prompt
[[ $UID -eq 0 ]] && MK="#" || MK="$"
PS1="$GREEN[$BOLD$RED\u$RESET_COLOR$YELLOW@$MAGENTA\h$YELLOW:$BOLD$CYAN\w$RESET_COLOR$GREEN]$MK$RESET_COLOR "


################################ Bash settings ################################

# Use vi bindings
set -o vi

# Enable extended glob (needed for dir_in_path)
shopt -s extglob
# Do not match . and .. with globs (e.g. .*)
export GLOBIGNORE=.
# Setting GLOBIGNORE also sets dotglob, disable it
shopt -u dotglob


##################### Various command settings and aliases #####################

# Colors
# ls
eval $(dircolors ~/.dir_colors)
# gcc (4.9+)
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# ip (iproute2 4.1+)
if ip -c -V > /dev/null 2>&1; then
    alias ip='ip -c'
fi

# Use vimpager as pager and less
if [[ -x $HOME/bin/vimpager ]]; then
    export PAGER=$HOME/bin/vimpager
    alias less=$PAGER
    alias zless=$PAGER
fi

# Git autocompletion
command -v git > /dev/null && . ~/.git-completion.bash
# Completion for complex aliases that __git doesn't manage to recognise
_git_l() { _git_log; }
_git_lp() { _git_log; }
_git_ls() { _git_log; }

# Editor
export SVN_EDITOR=vim
export EDITOR=vim

# Alias
alias lsdir='ls --group-directories-first'
alias clip='xclip -sel clipboard'
alias dd='dd bs=1M status=progress conv=fsync'

# Make readelf always use the wide format, for all toolchains
for readelf in $(find ${PATH//:/ } -name '*readelf' -printf '%f '); do
    alias $readelf="$readelf -W"
done

# Alias adresses
export iftp="kbrodsky@iftpserv2.insa-lyon.fr"
export tw_cs="kxb414@tw.cs.bham.ac.uk"


################################## Functions ##################################

# Internal function to check # of arguments of the calling function
# $1 is caller's $#, $2 is the needed # of arguments
_need_nb_args()
{
    [[ $1 -lt $2 ]] &&
        { echo "${FUNCNAME[1]}: not enough arguments ($2 needed)"; return 1; }
    return 0
}

## PATH manipulation

# $1 in ${!2}? ($2 = PATH by default)
# (${!2} = the expansion of the variable named by $2)
dir_in_path()
{
    local var=${2:-PATH}
    [[ $1 && ${!var} ==  ?(*:)$1?(:*) ]]
}

# Append $1 to ${!2}? ($2 = PATH by default)
append_to_path()
{
    _need_nb_args $# 1 || return 1
    local var=${2:-PATH}
    remove_from_path "$1" "$var"
    export "$var"="${!var:+${!var}:}$1"
}

# Prepend $1 to ${!2}? ($2 = PATH by default)
prepend_to_path()
{
    _need_nb_args $# 1 || return 1
    local var=${2:-PATH}
    remove_from_path "$1" "$var"
    export "$var"="$1${!var:+:${!var}}"
}

# Remove $1 from ${!2}? ($2 = PATH by default)
remove_from_path()
{
    _need_nb_args $# 1 || return 1
    local var=${2:-PATH}

    if dir_in_path "$1" "$var"; then
        # If IFS is not set, we must not restore an empty value (here we restore
        # the default value)
        local old_ifs="${IFS-$' \t\n'}"
        IFS=:
        # Read all paths and put them in an array
        # IFS must only be set for read, otherwise it just doesn't work
        read -a p_array <<< "${!var}"

        # For each path, if it matches $1, remove it from the array
        for i in "${!p_array[@]}"; do
            [[ ${p_array[i]} == $1 ]] && unset -v 'p_array[i]'
        done

        # Set PATH with the new value (IFS being set to :, array's elements will
        # be concatenated using : )
        export "$var"="${p_array[*]}"

        IFS="$old_ifs"
        return 0
    fi
    return 1
}

multigrep()
{
    _need_nb_args $# 2 || return 1
    grep -Pzo ${@:1:$(($#-2))} "(?s)${@: -2: 1}" "${@: -1}"
}

launch_silent_bg()
{
    _need_nb_args $# 1 || return 1
    "$@" > /dev/null 2>&1 < /dev/null &
}

launch_detached()
{
    _need_nb_args $# 1 || return 1
    launch_silent_bg "$@"
    disown
}

launch_silent_bg_wait()
{
    _need_nb_args $# 1 || return 1
    while pgrep "$1" > /dev/null; do
        sleep 1s
    done
    launch_silent_bg "$@"
}

cat_dir()
{
    [[ ${1,,} == '-r' ]] && { local recursive=1; shift; }
    _need_nb_args $# 1 || return 1

    local d f
    for d; do
        d=${d%/}
        echo "> In $d/"
        for f in "$d"/*; do
            [[ -f $f ]] && { echo ">> $(basename $f)"; cat "$f"; }
        done

        if [[ $recursive ]]; then
            for f in "$d"/*; do
                [[ -d $f ]] && cat_dir -r "$f"
            done
        fi
    done
}

# print_binary <number> [<width of blocks in bits> [<min number of blocks>]]
print_binary()
{
    _need_nb_args $# 1 || return 1
    perl -E '
        my ($num, $width, $pad) = @ARGV; my @blocks;
        do { unshift @blocks, $num & ((1 << $width) - 1) } while $num >>= $width;
        printf "%0${width}b ", $_ for (0) x ($pad - @blocks), @blocks; say' \
            $(($1)) ${2:-8} ${3:-0}
    # Note: arithmetic evaluation of $1 automatically converts hex or octal
    # to decimal, otherwise we'd need to tell Perl which base is used
}

dl_files_recursive()
{
    _need_nb_args $# 1 || return 1
    wget -r --no-parent -nd --reject='*htm*' -e robots=off "$1"
}

pacman_size()
{
    _need_nb_args $# 1 || return 1
    pacman -Qql $(pacman -Qqs "$@") | grep -v '/$' | tr '\n' '\0' \
        | du -hc --files0-from=- | tail -n 1
}

pacman_ls()
{
    pacman -Qql "$@" | grep -v '/$' | xargs ls -l --color
}

pacman_list()
{
    pacman --color always -Ql "$@" | grep -v '/usr/share/locale'
}

########################## Other environment settings #########################

# Add ~/bin to PATH (prepend to be able to shadow commands)
prepend_to_path "$HOME/bin"
export SYSTEMD_PAGER=


# Source specific
if [[ -f $HOME/.bashrc_specific ]]; then
    . $HOME/.bashrc_specific
fi

# vim: set ts=4 sw=4 sts=4 et:

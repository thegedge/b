# vi: ft=fish

set fish_greeting ""

# fish_vi_key_bindings

set -x DISABLE_SPRING 0
set -x OPT_SHOW 1
set -x OPT_ISEQ_CACHE 0
set -x OPT_AOT_RUBY 1
set -x OPT_AOT_YAML 1
set -x OPT_PRE_BOOTSCALE 1
set -x OPT_TOXIPROXY_CACHE 1

function fish_mode_prompt --description "Displays the current mode"
  # Do nothing if not in vi mode
  if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case default
        set_color magenta
        echo 'N'
      case insert
        set_color cyan
        echo 'I'
      case replace-one
        set_color --bold green
        echo 'R'
      case visual
        set_color --bold red
        echo 'V'
    end
    set_color normal
    echo -n ' '
  end
end

set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

set -g fish_color_cwd blue

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_show_informative_status 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡ '
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

function fish_prompt
  set last_status $status

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  printf '%s ' (__fish_git_prompt)

  set -l jobs (count (jobs))
  if test $jobs -ne 0
    set_color white
    printf '↩'
    set_color white -o
    printf '%d ' $jobs
    set_color normal
  end

  if test $last_status -ne 0
      set_color red
      printf '✗'
      set_color red -o
      printf '%d ' $last_status
      set_color normal
  end

  set_color normal
end

set -x EDITOR vim
set -x VISUAL $EDITOR
set -x GIT_EDITOR $EDITOR
set -x HOMEBREW_EDITOR $EDITOR

function prepend_path --argument-names 'new'
  set -l index 1
  for entry in $PATH
    if test $new = $entry
      set -e PATH[$index]
      break
    end
    set -l index (math $index + 1)
  end
  set -gx PATH $new $PATH 2>/dev/null
end

prepend_path /usr/local/bin
prepend_path /usr/local/sbin
prepend_path /usr/local/texlive/2016basic/bin/x86_64-darwin
prepend_path ~/bin
prepend_path ~/bin/_git
prepend_path ~/.gem/bin
prepend_path ~/.cargo/bin
prepend_path ./node_modules/.bin
prepend_path ~/src/google-cloud-sdk/bin


set -U FZF_TMUX 1

function make_completion --argument-names alias command
    echo "
    function __alias_completion_$alias
        set -l cmd (commandline -o)
        set -e cmd[1]
        complete -C\"$command \$cmd\"
    end
    " | .
    complete -c $alias -a "(__alias_completion_$alias)"
end

gpg-agent --daemon >/dev/null 2>&1

function kick-gpg-agent
  set -l pid (ps xo pid,command | grep -E "^\d+ gpg-agent" | awk '{print $1}')
  set -gx GPG_AGENT_INFO /Users/burke/.gnupg/S.gpg-agent:$pid:1
end
kick-gpg-agent
set -x GPG_TTY (tty)

awk '
  /^[^#]/ {
    cmd=$0
    sub(/.*?:/, "", cmd)
    gsub(/&&/, "; and", cmd)
    gsub(/\|\|/, "; or", cmd)
    print "function "$1"; "cmd" $argv; end"
  }
' < ~/.sshrc.d/aliases | while read line; eval "$line"; end

eval (gdircolors -c ~/.sshrc.d/LS_COLORS | sed 's/setenv/set -gx/')
function ls
  gls --color=auto -F $argv
end

# Go
set -gx GOPATH "$HOME"
set -gx GOROOT_BOOTSTRAP "$HOME/src/go1.4"

# Java
# set -gx JAVA_HOME (/usr/libexec/java_home -v 1.8)

function gh
  cd (_gh $argv)
end

function ghs
  cd (_gh Shopify $argv)
end

function ghb
  cd (_gh burke $argv)
end

function git
  set -l toplevel (command git rev-parse --show-toplevel 2>/dev/null)
  if test "$toplevel" = "$HOME" -a "$argv[1]" = "clean"
    echo "Do NOT run git clean in this repository." >&2
  else
    command git $argv
  end
end

function ]gs
  set -l prj (_]g "$HOME/src/github.com/Shopify" $argv)
  cd "$HOME/src/github.com/Shopify/$prj"
end

function ]gb
  set -l prj (_]g "$HOME/src/github.com/burke" $argv)
  cd "$HOME/src/github.com/burke/$prj"
end

if test -f /opt/dev/dev.fish
  source /opt/dev/dev.fish
end

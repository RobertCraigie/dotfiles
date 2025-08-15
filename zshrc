export DISABLE_AUTO_UPDATE=true

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export KEYTIMEOUT=1

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fzf-tab
)

source $ZSH/oh-my-zsh.sh

# User configuration

eval "$(/opt/homebrew/bin/brew shellenv)"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

HOMEBREW_NO_AUTO_UPDATE=1

# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# alias nvm="$NVM_DIR/nvm-exec"
# alias nvm="$NVM_DIR/nvm.sh"

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP
setopt globdots

# export LDFLAGS="-L/opt/homebrew/opt/ruby@3.1/lib"

alias gg=lazygit
alias n=nvim

# pnpm
alias p=pnpm
export PNPM_HOME="/Users/robert/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# vim mode
bindkey -v

# alias for easier go coverage reporting
go_cover () { 
    t="/tmp/go-cover.$$.tmp"
    go test -coverprofile=$t $@ && go tool cover -html=$t
}

# quiet logs
# https://github.com/direnv/direnv/issues/203
export DIRENV_LOG_FORMAT=
eval "$(direnv hook zsh)"

export DENO_INSTALL="/Users/robert/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# bun completions
[ -s "/Users/robert/.bun/_bun" ] && source "/Users/robert/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix

# php
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# opam configuration
[[ ! -r /Users/robert/.opam/opam-init/init.zsh ]] || source /Users/robert/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

source <(fzf --zsh)

source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh

# source <(jj util completion zsh)

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  autoload -Uz -- "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
  ghostty-integration
  unfunction ghostty-integration
fi

fcp() {
  fzf -m | pbcopy
}

frm() {
  fzf -m | xargs rm
}

clone() {
  if [ -z "$1" ]; then
    echo "Error: No GitHub URL provided."
    echo "Usage: clone_github_repo <github-url>"
    return 1
  fi

  local url="$1"

  if [[ "$url" != *"github.com"* ]]; then
    echo "Error: The provided URL does not appear to be a GitHub URL: $url"
    return 1
  fi

  # 3. Remove trailing ".git" if present
  local clean_url="${url%.git}"

  # 4. Extract the part after "github.com/" => e.g. "org/repo"
  local path="${clean_url#*github.com/}"

  # 5. Extract org and repo using parameter expansion
  #    org = everything up to the first slash
  #    repo = everything after the first slash
  local org="${path%%/*}"
  local repo="${path#*/}"

  # 6. Basic validation
  if [ -z "$org" ] || [ -z "$repo" ]; then
    echo "Error: Could not parse organization/repository from URL."
    echo "       Make sure the URL is in the form https://github.com/<org>/<repo>.git"
    return 1
  fi

  local target_dir="$HOME/github.com/$org/$repo"

  # 7. Check if the target directory already exists
  if [ -d "$target_dir" ]; then
    echo "Error: The directory '$target_dir' already exists."
    echo "       To clone again, remove or rename this directory first."
    return 1
  fi

  # 8. Perform the clone
  /usr/bin/git clone "$url" "$target_dir"
}

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.3/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.3/sbin:$PATH"
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"

export PATH=$PATH:/Users/robert/.spicetify

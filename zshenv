. "$HOME/.cargo/env"

# Codon compiler path (added by install script)
export PATH=/Users/robert/.codon/bin:$PATH

export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$NVM_DIR:$PATH"
export PATH="$PATH:/opt/homebrew/opt/capstone/lib"
export PIP_REQUIRE_VIRTUALENV=true
export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
export DYLD_LIBRARY_PATH=/opt/homebrew/Cellar/capstone/5.0.3/lib
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export PATH="/Users/robert/Library/Python/3.9/bin:$PATH"
export PATH="/Users/robert/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"

# pdm
export PATH=/Users/robert/Library/Python/3.10/bin:$PATH

export PATH=/Users/robert/.local/bin:$PATH

export PATH=/Users/robert/.local/share/bob/nvim-bin:$PATH

export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  && \. "$NVM_DIR/nvm.sh"

alias g="git"
alias rg="rg --type-add 'proto:*.proto' --type-add 'build:BUILD' --type-add 'test:*[tT]est*'"
alias ls="exa"
alias vi="nvim"
alias ff="firefox"

if [ "$(uname -s)" = "Linux" ]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
  alias fd='fdfind'
fi

# Rust
alias cbr="cargo build --release"
alias cc="cargo clippy"
alias cr="cargo run"


# Get the most recent commits by a user
function commits() {
  usage="Usage: commits name num_commits OR commits num_commits"

  if [ $# -eq 0 ]; then
    echo $usage
  elif [ $# -eq 1]; then
    g l | rg "$(git config user.name)" | head -$1
  elif [ $# -eq 2 ]; then
    g l | rg $1 | head -$2
  else
    echo "Invalid number of arguments. $usage"
  fi
}

# Search for a number of strings in a chain using rg
function chained_rg() {
  usage="Usage: chained_rg [flags] STR1 STR2 ..."

  if [ $# -eq 0 ]; then
    echo "No strings provided."
    return 1
  fi

  # Check if the first argument starts with a hyphen (flag)
  if [[ $1 == -* ]]; then
    rg_flags+=("$1")
    shift
  fi

  # Perform the initial search with the first argument
  local cmd="rg ${rg_flags[*]} '$1'"

  # Construct the chain of commands with subsequent args
  shift
  for arg in "$@"; do
    cmd+=" -l | xargs rg '$arg'"
  done

  # Execute the command
  eval "$cmd"
}

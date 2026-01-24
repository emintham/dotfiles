alias vi="nvim"
alias t="tmux a -t"
alias p="pnpm"
alias ls="exa"
alias ge="gemini"
alias g="git"
alias fm="fastmod"
alias cl="claude"

# Project specific
alias rpi="ssh jay@rpi.local"
alias td="p tauri dev"

if [ "$(uname -s)" = "Linux" ]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
  alias fd='fdfind'
fi

# Rust
alias c="cargo"
alias cb="c build"
alias cbr="cb --release"
alias cc="c clippy"
alias cr="c run"
alias ct="c test"
alias csp="c sqlx prepare"
alias cc="c check"

# Get the most recent commits by a user
function commits() {
  usage="Usage: commits name num_commits OR commits num_commits"

  if [ $# -eq 0 ]; then
    echo $usage
  elif [ $# -eq 1 ]; then
    g l | rg "$(git config user.name)" | head -$1
  elif [ $# -eq 2 ]; then
    g l | rg $1 | head -$2
  else
    echo "Invalid number of arguments. $usage"
  fi
}
export -f commits

# Search for a number of strings in a chain using rg
function chained_rg() {
  usage="Usage: chained_rg [flags] STR1 STR2 ..."

  if [ $# -eq 0 ]; then
    echo "No strings provided."
    return 1
  fi

  # Check if rg is installed
  if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) is not installed."
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
export -f chained_rg

mkcd() {
  # Check if a directory name was provided
  if [ -z "$1" ]; then
    echo "Usage: mkcd <directory_name>"
    return 1
  fi

  # Create the directory
  mkdir -p "$1" &&

  # Change into the newly created directory
  cd "$1"
}
export -f mkcd

# pipe-able function to sort files by latest creation time
# e.g. ls | sort_by_latest_creation
function sort_by_latest_creation() {
  # Check if stat command is available
  if ! command -v stat &> /dev/null; then
    echo "Error: stat command is not available."
    return 1
  fi

  xargs -I {} sh -c 'stat --printf="%W\t%n\n" "$1"' _ {} \
    | sort -t $'\t' -k1,1nr \
    | cut -d $'\t' -f2-
}
export -f sort_by_latest_creation

# Setup a new bare-worktree repo
# Usage: gcl <repo>
function gcl() {
  local url=$1
  local basename=$(basename "$url" .git)

  mkcd "$basename"

  git clone --bare "$url" .bare

  echo "gitdir: .bare" > .git
  git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

  git worktree add main
}
export -f gcl

# Creates a worktree
# Usage: wt <branch>
function wt() {
  local branch=$1

  git worktree add "../$branch" -b "$branch"
  cd "../$branch"
}
export -f wt

# Deletes a worktree
# Usage: rmwt <branch>
function rmwt() {
  local branch=$1

  git worktree remove "../$branch"
  rm -rf "../$branch"
}
export -f rmwt

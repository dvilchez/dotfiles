#!/bin/bash
#
# git-smart-commit.sh
#
# An AI-powered git commit assistant that performs code review
# based on software design principles and generates commit messages.
#
# Usage:
#   git-smart-commit [--no-verify] [--level=normal|strict|relaxed]
#
# Options:
#   --no-verify     Skip the code review and just generate a commit message
#   --level=LEVEL   Set the strictness level for code review (relaxed, normal, strict)
#
# Installation:
#   1. Save this script as git-smart-commit.sh in your PATH
#   2. Make it executable: chmod +x git-smart-commit.sh
#   3. Add an alias to your .gitconfig:
#      [alias]
#        smart-commit = !git-smart-commit.sh
#
# Version: 1.0

# ---- Global Variables ----
TEMP_FILE=""
REVIEW_LEVEL="normal"
SKIP_VERIFY=false
LLM_COMMAND="llm" # Adjust this to match your LLM CLI tool
EDITOR=${EDITOR:-$(git config core.editor || echo "vim")} # Default editor

# ---- Logging Functions ----
function log_info() {
  echo -e "\033[0;34m[INFO]\033[0m $1"
}

function log_success() {
  echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

function log_warning() {
  echo -e "\033[0;33m[WARNING]\033[0m $1"
}

function log_error() {
  echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# ---- Function Definitions ----

# Display usage information
function show_usage() {
  echo "Usage: git-smart-commit [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --no-verify          Skip code review and just generate commit message"
  echo "  --level=LEVEL        Set review strictness (relaxed, normal, strict)"
  echo "  --help               Show this help message"
  echo ""
  echo "Example:"
  echo "  git-smart-commit --level=strict"
}

# Parse command line arguments
function parse_args() {
  while (( "$#" )); do
    case "$1" in
      --no-verify)
        SKIP_VERIFY=true
        shift
        ;;
      --level=*)
        REVIEW_LEVEL="${1#*=}"
        if [[ ! "$REVIEW_LEVEL" =~ ^(relaxed|normal|strict)$ ]]; then
          log_error "Invalid level. Use relaxed, normal, or strict."
          show_usage
          exit 1
        fi
        shift
        ;;
      --help)
        show_usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
    esac
  done
}

# Safely create a temporary file
function create_temp_file() {
  TEMP_FILE=$(mktemp)
  if [ ! -f "$TEMP_FILE" ]; then
    log_error "Failed to create temporary file"
    exit 1
  fi
}

# Clean up temporary files
function cleanup() {
  if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"
    log_info "Temporary files cleaned up"
  fi
}

# Check if there are staged changes
function check_staged_changes() {
  local staged_diff
  staged_diff=$(git diff --staged --name-only)
  
  if [ -z "$staged_diff" ]; then
    log_error "No changes staged for commit"
    exit 1
  fi
  
  return 0
}

# Get full diff and file contents
function build_review_context() {
  local staged_file_list
  staged_file_list=$(git diff --staged --name-only)
  
  # Write the diff to the context file
  echo "# CHANGES (DIFF)" >> "$TEMP_FILE"
  git diff --staged >> "$TEMP_FILE"
  echo -e "\n\n" >> "$TEMP_FILE"
  
  # For each file that has changes, add its full content
  echo "# FULL FILE CONTENTS" >> "$TEMP_FILE"
  for current_file in $staged_file_list; do
    # Skip binary files and deleted files
    if [ -f "$current_file" ] && ! git check-attr -a -- "$current_file" | grep -q "binary: set"; then
      echo -e "\n\n## FILE: $current_file" >> "$TEMP_FILE"
      echo -e "\`\`\`" >> "$TEMP_FILE"
      git show ":$current_file" 2>/dev/null >> "$TEMP_FILE" || cat "$current_file" >> "$TEMP_FILE"
      echo -e "\`\`\`" >> "$TEMP_FILE"
    fi
  done
}

# Generate a review prompt based on the strictness level
function generate_review_prompt() {
  local base_prompt="Review this code with special attention to these software design and engineering principles:"
  local ending="I have provided both the changes (diff) and the full content of the files. First review the changes, then examine the full files to understand the context.\n\nBegin your response with PASS or FAIL on a single line.\n\nIf you find issues, format your response as follows:\n\n1. For each issue, clearly state:\n   - FILE: The specific file where the issue exists\n   - LOCATION: Line number or function/method name\n   - CODE: The specific chunk of problematic code (keep it short and focused)\n   - ISSUE: A clear explanation of what's wrong\n   - SUGGESTION: A brief recommendation to fix it\n\n2. Group similar issues together.\n\n3. Only include actual problems, not minor stylistic preferences.\n\n4. Focus on the most critical issues first."

  # Core principles included in all levels
  local core_principles="
1. FUNCTION SIZE & FOCUS:
   - Are functions short (ideally <20 lines)?
   - Does each function do exactly one thing?
   - Are function names descriptive of their purpose?

2. DOMAIN-ORIENTED DESIGN:
   - Does the code use domain terminology?
   - Are abstractions aligned with business concepts?
   - Is the code organized around domain concepts rather than technical details?

3. SOLID PRINCIPLES:
   - Single Responsibility: Does each component have one reason to change?
   - Open/Closed: Can the code be extended without modification?
   - Liskov Substitution: Are subtypes properly substitutable?
   - Interface Segregation: Are interfaces client-specific rather than general?
   - Dependency Inversion: Does code depend on abstractions rather than implementations?

4. CUPID PROPERTIES:
   - Composable: Can elements be combined easily?
   - Unix philosophy: Does each part do one thing well?
   - Predictable: Is behavior consistent and intuitive?
   - Idiomatic: Does it follow standard conventions?
   - Domain-based: Does it speak the language of the problem domain?"

  # Additional principles for normal and strict levels
  local normal_principles="
5. CODE CLEANLINESS:
   - Is the code free of commented-out code blocks?
   - Are there appropriate comments for complex logic but not for obvious operations?
   - Is there consistent indentation and formatting?
   - Are naming conventions consistent throughout the codebase?

6. ERROR HANDLING:
   - Does the code gracefully handle expected errors?
   - Are exceptions/errors specific rather than generic?
   - Are error messages helpful and descriptive?

7. DRY (Don't Repeat Yourself):
   - Is there duplicated logic that could be abstracted?
   - Are similar code patterns consolidated into reusable functions/components?"

  # Additional principles for strict level only
  local strict_principles="
8. TESTABILITY:
   - Is the code structured to be testable?
   - Are dependencies injectable or mockable?
   - Are side effects isolated from pure logic?
   - Are edge cases identifiable and testable?

9. PERFORMANCE CONSIDERATIONS:
   - Are there any obvious performance bottlenecks?
   - Are expensive operations optimized appropriately?
   - Are there any N+1 query problems or similar inefficiencies?

10. SECURITY PRACTICES:
    - Is user input properly validated and sanitized?
    - Are there any potential injection vulnerabilities?
    - Is sensitive data properly protected?
    - Are authentication and authorization properly implemented?

11. LANGUAGE-SPECIFIC IDIOMS:
    - Does the code leverage language features appropriately?
    - Are modern/preferred patterns used instead of deprecated approaches?
    - Does it follow the ecosystem's standard practices?

12. DOCUMENTATION:
    - Do complex functions/classes have clear documentation?
    - Are public APIs well-documented?
    - Do code comments explain \"why\" rather than just \"what\"?
    - Is there appropriate inline documentation for non-obvious decisions?"

  # Construct the prompt based on level
  local prompt="$base_prompt\n$core_principles"
  
  if [[ "$REVIEW_LEVEL" == "normal" || "$REVIEW_LEVEL" == "strict" ]]; then
    prompt="$prompt\n$normal_principles"
  fi
  
  if [[ "$REVIEW_LEVEL" == "strict" ]]; then
    prompt="$prompt\n$strict_principles"
  fi
  
  prompt="$prompt\n\n$ending"
  
  # Add a note about the review level
  if [[ "$REVIEW_LEVEL" == "relaxed" ]]; then
    prompt="$prompt\n\nNOTE: This is a relaxed review focusing only on core principles."
  elif [[ "$REVIEW_LEVEL" == "strict" ]]; then
    prompt="$prompt\n\nNOTE: This is a strict review. Be thorough and point out all issues, even minor ones."
  fi
  
  echo -e "$prompt"
}

# Perform the code review
function perform_code_review() {
  local prompt
  prompt=$(generate_review_prompt)
  
  log_info "Reviewing code (level: $REVIEW_LEVEL)..."
  local review_result
  review_result=$(cat "$TEMP_FILE" | $LLM_COMMAND "$prompt")
  
  local first_line
  first_line=$(echo "$review_result" | head -n 1)
  local remainder
  remainder=$(echo "$review_result" | tail -n +2)
  
  if [[ "$first_line" == "PASS" ]]; then
    log_success "Design principles review passed!"
    return 0
  else
    log_error "Review found issues:"
    echo ""
    echo "$remainder"
    echo ""
    return 1
  fi
}

# Generate a commit message
function generate_commit_message() {
  local staged_changes
  staged_changes=$(git diff --staged)
  
  # Use a prompt that requests both title and description
  local commit_msg
  commit_msg=$(echo "$staged_changes" | $LLM_COMMAND "Write a git commit message with both a title and description:

1. TITLE: First line should be in format 'type: brief description' (e.g., 'feat: added login button'). 
   - Use past tense (e.g., 'added', 'fixed', 'updated')
   - Do NOT use 'I' or address the user
   - Keep under 50 characters

2. DESCRIPTION: After a blank line, provide 2-3 sentences explaining what was changed and why.
   - Be specific but concise
   - Use bullet points if helpful
   - Keep each line under 72 characters

RESPOND WITH ONLY THE EXACT COMMIT MESSAGE (title + blank line + description), nothing else.")
  
  # Check if we got a message
  if [ -z "$commit_msg" ]; then
    log_warning "Could not generate commit message. Using default message."
    commit_msg="chore: updated code

Updated code with necessary changes to improve functionality."
  fi
  
  echo "$commit_msg"
}

# Perform the commit with git's standard message editor
function do_commit() {
  local commit_msg="$1"
  
  # Create temporary file with the message
  local message_file=$(mktemp)
  echo "$commit_msg" > "$message_file"
  
  # Use git commit with the message file directly (not as template)
  log_info "Opening editor to finalize commit message..."
  
  # The -F flag uses the file content directly as the commit message
  # The --edit flag opens the editor to allow changes
  git commit -F "$message_file" --edit
  
  # Cleanup
  rm "$message_file"
  
  log_success "Commit completed"
}

# Ask user what they want to do after a failed review
function handle_failed_review() {
  local commit_msg="$1"
  
  echo "What would you like to do?"
  echo "  [c] Commit anyway (ignore issues)"
  echo "  [s] Show the diff again"
  echo "  [a] Abort the commit"
  echo -n "Your choice [c/s/a]: "
  
  read -r answer
  case "$answer" in
    c|C)
      do_commit "$commit_msg"
      return 0
      ;;
    s|S)
      # Show the diff again
      git diff --staged
      handle_failed_review "$commit_msg"
      ;;
    a|A|*)
      log_warning "Commit aborted. Please fix the issues and try again."
      return 1
      ;;
  esac
}

# Set up trap with more robust handling
function setup_traps() {
  # Define trap function for different signals
  function trap_handler() {
    local signal=$1
    log_warning "Received signal: $signal"
    
    case $signal in
      EXIT)
        # Normal exit
        cleanup
        ;;
      INT|TERM)
        # Interrupted or terminated
        log_warning "Process interrupted"
        cleanup
        exit 130
        ;;
      *)
        # Other signals
        log_warning "Unexpected signal"
        cleanup
        exit 1
        ;;
    esac
  }
  
  # Set up traps for different signals
  trap 'trap_handler EXIT' EXIT
  trap 'trap_handler INT' INT
  trap 'trap_handler TERM' TERM
}

# Main function
function main() {
  # Parse and validate arguments first
  parse_args "$@"
  
  # Set up traps for signal handling
  setup_traps
  
  # Check for staged changes
  check_staged_changes
  
  # If --no-verify flag is passed, skip review
  if [[ "$SKIP_VERIFY" == true ]]; then
    log_info "Skipping code review due to --no-verify flag"
    commit_msg=$(generate_commit_message)
    do_commit "$commit_msg"
    return 0
  fi
  
  # Create temporary file
  create_temp_file
  
  # Build review context
  build_review_context
  
  # Perform code review
  if perform_code_review; then
    # Review passed, generate commit message and commit
    commit_msg=$(generate_commit_message)
    do_commit "$commit_msg"
  else
    # Review failed, give user options on how to proceed
    commit_msg=$(generate_commit_message)
    handle_failed_review "$commit_msg"
  fi
}

# Execute main function
main "$@"

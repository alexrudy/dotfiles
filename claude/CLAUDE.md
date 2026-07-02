<!--
Personal global instructions for Claude Code.
Source of truth: ~/.dotfiles/claude/CLAUDE.md (symlinked to ~/.claude/CLAUDE.md
by claude/bin/install-claude.sh). Edit here, not the symlink.
-->

# Personal global instructions

## Writing pull request bodies

A PR body is a short narrative about a decision, not an inventory of the diff.
The diff already shows *what* changed; the body explains *why*, and flags what a
reviewer or a future reader needs to know. Write it like a note to a colleague.

- **Lead with the why.** Open with the problem or motivation and the decision you
  made — not a list of changed files.
- **Prose over scaffolding.** Default to one to three short paragraphs. Don't
  reach for `## Summary` / `## Changes` / `## Test plan` headers unless the PR is
  genuinely large. First person is good ("I'm leaving the single-update path in
  place because…").
- **Don't re-render the diff.** Don't enumerate every file, function, or symbol,
  and don't wrap every identifier in backticks. Name only the pieces needed to
  follow the reasoning; trust the diff for the rest.
- **Keep the honest hedges.** Say what you're unsure about, what to watch after
  it ships, what you deliberately left out, and any follow-ups. These caveats are
  the most valuable part of a body and the easiest to drop.
- **Scale to the change.** A one-line change gets a one-sentence body. Reserve
  design-doc depth — sections, tables, enumerated trade-offs — for PRs that are
  genuinely a design decision.
- **Respect the repo.** If a project has its own PR template or conventions,
  follow those over this guidance.

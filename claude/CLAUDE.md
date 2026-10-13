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
- **Open with the effect, then the cause.** Start from what a reader would notice
  ("Features behind production flags are off on a local stack"), then say why it
  happens and what the PR does about it.
- **Prose over scaffolding.** Default to one to three short paragraphs. Don't
  reach for `## Summary` / `## Changes` / `## Test plan` headers unless the PR is
  genuinely large. First person is good ("I'm leaving the single-update path in
  place because…").
- **Don't re-render the diff.** Don't enumerate every file, function, or symbol,
  and don't wrap every identifier in backticks. Name only the pieces needed to
  follow the reasoning; trust the diff for the rest.
- **Say what the change is before how it works.** Open an explanation with what
  the new thing is ("A reduced experiment is…"), then the approach in a few
  sentences. Summarize an algorithm ("condenses redundant rules") rather than
  walking through its steps. A secondary capability, like recording reasoning
  for a later report, gets one sentence.
- **Leave out code structure and abandoned approaches.** Dispatch patterns,
  helper layout, and the approach you tried first belong in code comments or a
  design doc, unless a reviewer needs them to judge the change.
- **Mention verification only when it went beyond the diff.** A staging run or a
  manual check is worth a line. The tests the PR adds are already in the diff,
  so don't recount them.
- **Write plainly.** Describe behavior rather than shorthand: "a filter that
  might match in production but can't match locally", not "a filter the local
  stack can't answer". Give each idea its own sentence, and cut a sentence the
  previous one already implies.
- **Keep the honest hedges.** Say what you're unsure about, what to watch after
  it ships, what you deliberately left out, and the gaps this change leaves open.
  These caveats are the most valuable part of a body and the easiest to drop.
- **Describe this PR, not the roadmap.** Leave out the follow-up PRs and where
  the project goes next. A PR should stand on its own.
- **Scale to the change.** A one-line change gets a one-sentence body. Reserve
  design-doc depth — sections, tables, enumerated trade-offs — for PRs that are
  genuinely a design decision.
- **Respect the repo.** If a project has its own PR template or conventions,
  follow those over this guidance.

@private/AGENTS.md

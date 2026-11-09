# Runwell Brain — guide for AI agents

A Runwell plugin (a Rails engine loaded into a Runwell install), key `brain`. It isn't an app on
its own: run it from a Runwell checkout with `bin/rails "plugins:link[../runwell-brain]"`. What it
is for and where it's going: `docs/brain.md`.

Read first, in Runwell's repository: `docs/plugin-contract.md` (everything a plugin may rely on;
use nothing else of the core's) and `AGENTS.md` (the conventions plugin code follows too).

## Layout

- `lib/brain/engine.rb`: routes, the association on clients and work, and the registrations (the
  `client_panel`, `work_panel` and `note_row` slots, the stylesheet, the agent brief)
- `app/models/brain/section.rb`: one section of a brain (`brain_sections`): the six kinds, writing,
  confirming, staleness, a note added in
- `app/models/brain/brief.rb`: the brain's part of a task's brief
- `app/models/brain/subject.rb`: whose brain a route or a note belongs to
- `app/controllers/brain/*`: read (JSON for agents), write, confirm, add a note; every action has
  an authorization rule and an agent tool
- `app/views/brain/*`: the tab, a section card, the note row's Add to brain

## Rules

- The plugin owns `brain_sections`, pointing at clients and work by id; it never adds columns to
  core tables. Plugins load outside Bundler: use only the gems Runwell bundles.
- Nothing reaches the client portal: brains hold candid things.
- AI never writes a brain unasked: proposals (a later release) wait for a person's yes.
- Views follow Runwell's ReActionView rules (strict locals, `herb:key` on loops, no inline CSS) and
  draw with rune_ui and the contract's helpers; CSS reads the design tokens.
- Migrations are safe on a live install.

## State machines

Each one's rules live once, on a model; views, controllers, the brief and the JSON ask it, never
keep a copy (Runwell's own convention):

- A section: empty (nothing written, or cleared), current (confirmed within `STALE_AFTER`) or stale
  (`Section#state`, `STATES` for the words; agents see `state` and `confirmable`). Writing confirms
  it; writing it blank clears it back to empty; only a written section can be confirmed
  (`confirmable?`; `confirm!` raises `Section::Refused`, and the controller refuses with the reason)
- A section's key: `Section::KINDS` / `KEYS`, which the tools' descriptions and the note menu read
- Whose brain: `Subject::KINDS` (client, work), which the routes' constraint reads
- Whether a note can go to a brain: `Subject.promotable?` (on a client, work, section of work, or a
  task with a work or client), the one rule for the note menu and `for_note`

# Runwell Brain

What everyone should know about each client and piece of work, in one short page that's kept
true, so it isn't only in one person's head. A plugin for
[Runwell](https://github.com/Martin-Business-Consultants/runwellv2). Why and where it's going:
[docs/brain.md](docs/brain.md).

## What it does (0.4)

- **A Brain tab** on every client and piece of work, with the sections your install keeps
  (Settings › Plugins › Brain: six to start, renamed, reordered, added to or archived; clients, work
  or one kind of work can have their own). Each is a few lines of rich text, written in place.
- **Kept true**: writing a section confirms it, and **Still true** confirms it as it stands. Each
  is empty, current or stale (nobody's confirmed it in six months).
- **A keeper** per brain: each night a stale section becomes a review task for them, closed when
  someone writes or confirms it.
- **Every version kept**: who wrote it, how, what changed from the one before, and **Restore**.
- **In the history**: every write, confirmation, decision and question shows in the client's or
  work's History tab, the changes feed agents read, and webhooks.
- **A decisions log**: each decision with when, who decided, what and why, and the task it came from.
- **Questions**: when someone (or an AI) needs something the brain doesn't say, they ask; it's a
  task for the keeper, answered on the task straight into the brain.
- **Add to brain** on a note: it goes to the end of the section you pick, credited to who wrote it.
- **In every task's brief** (Copy for AI): the parts that bear on the task (and those always in
  briefs), recent and relevant decisions, and what isn't known yet, within a budget; the rest is
  named for `show_brain`.
- **Agent tools**, with the caller's permissions: `show_brain`, `write_brain_section`,
  `confirm_brain_section`, `restore_brain_section`, `set_brain_keeper`, `add_brain_decision`,
  `remove_brain_decision`, `ask_brain_question`, `answer_brain_question`, `add_note_to_brain`, and
  for settings `show_brain_settings`, `add_brain_kind`, `update_brain_kind`.

Staff only: nothing here reaches the client portal.

Needs Runwell 6.0 or later: it's drawn with runeui (`ui :card`, `ui :badge`, `ui :button`,
`ui :field`) and its stylesheet reads runeui's tokens only (shadcn's names and `--ui-*`).

## Install

In Runwell, Settings › Plugins: add `Martin-Business-Consultants/runwell-brain`, then switch it on.

To work on it, from a Runwell checkout beside it: `bin/rails "plugins:link[../runwell-brain]"`,
`bin/rails db:migrate`, `bin/dev`.

## Release

Bump `lib/brain/version.rb`, commit, then `git tag v0.2.0 && git push --tags`. The workflow
publishes the release; installs see it in Settings › Plugins.

## Licence

FSL-1.1-MIT ([LICENSE.md](LICENSE.md)).

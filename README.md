# Runwell Brain

What everyone should know about each client and piece of work, in one short page that's kept
true, so it isn't only in one person's head. A plugin for
[Runwell](https://github.com/Martin-Business-Consultants/runwellv2). Why and where it's going:
[docs/brain.md](docs/brain.md).

## What it does (0.1)

- **A Brain tab** on every client and piece of work, with six sections: what it's about, people,
  how we work together, what's unique, history and landmines, decisions. Each is a few lines of
  rich text, written in place.
- **Kept true**: writing a section confirms it, and **Still true** confirms it as it stands. Each
  shows who confirmed it and when; one nobody has confirmed in six months says so.
- **Add to brain** on any note on a client, a piece of work, a section or a task: the note goes to
  the end of the section you pick, credited to who wrote it.
- **In every task's brief** (Copy for AI): what's known about the task's client and its work, so an
  AI starts with the context a teammate would have.
- **Agent tools**, with the caller's permissions: `show_brain`, `write_brain_section`,
  `confirm_brain_section`, `add_note_to_brain`.

Staff only: nothing here reaches the client portal.

## Install

In Runwell, Settings › Plugins: add `Martin-Business-Consultants/runwell-brain`, then switch it on.

To work on it, from a Runwell checkout beside it: `bin/rails "plugins:link[../runwell-brain]"`,
`bin/rails db:migrate`, `bin/dev`.

## Release

Bump `lib/brain/version.rb`, commit, then `git tag v0.2.0 && git push --tags`. The workflow
publishes the release; installs see it in Settings › Plugins.

## Licence

FSL-1.1-MIT ([LICENSE.md](LICENSE.md)).

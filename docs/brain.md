# A brain for every client and piece of work

## The problem

What makes a client manageable mostly isn't in tasks or work: who really decides, how they like
to approve, what went wrong last time, when their busy season is. That knowledge lives in one
person's head, or in notes nobody rereads. When that person is out or leaves, the next one
starts from zero, and the client feels it.

## What a brain is

A short, current, curated page per client and per piece of work: what you'd hand a new teammate
on day one. Not a notes feed or a document store; its value is that it's distilled and kept true.
It starts with six sections, free text inside each (an install renames, reorders, adds to and
archives them in Settings › Plugins › Brain, and can give clients, work, or one kind of work their own):

- **What it's about**: their business, how they make money, what success looks like
- **People**: who decides, who influences, how each likes to be reached
- **How we work together**: approvals, budgets, response times, channels
- **What's unique**: quirks, constraints, seasonality, their words for things
- **History and landmines**: what went wrong before, promises made
- **Decisions**: a log of what was decided, when, by whom, and why, each entry its own

Structured, filterable facts (a contract value, a renewal date) stay custom fields.

## Keeping it true is the hard part

1. **Capture without essays.** Notes, emailed requests, meeting transcripts and closed work already
   carry the knowledge. "Add to brain" on a note moves it in; later, an AI pass proposes updates
   with a link to the source.
2. **A person accepts** (to come). Today agents write sections as people do, and every version is
   kept and can be put back; next, AI's changes wait as suggestions a person accepts.
3. **Sources and freshness.** Each section shows who last confirmed it and when, and every version
   with what changed. A section nobody has confirmed in six months is stale, and each night it
   becomes a review task for the brain's keeper; writing or confirming it closes the task.
4. **Gaps fill themselves.** When an agent (or anyone) needs something the brain doesn't say, it asks:
   a task for the keeper, whose answer goes into the brain.
5. **Contradictions surface** as proposals to change a fact, never a second fact beside it (to come).
6. **Everyone sees it change.** Every write, confirmation, decision and question goes into the
   client's or work's history, the changes feed agents catch up on, and webhooks.

## Where it pays off

- **Agents get the right context**: every task's brief (Copy for AI) carries the parts of its client's
  and work's brain that bear on it (some always), recent decisions and what isn't known yet, within a
  budget, and names the rest for show_brain.
- **Handoffs**: a new lead reads one page, not two years of notes.
- **Onboarding**: the empty sections are a discovery checklist.

## Risks

- Candid content ("hard to work with") must never reach the client portal.
- AI confabulation: every proposed fact needs a source, and a person's yes.
- Over-structuring: a few sections with free text, not a form.

## Plan

- **0.1 (this release)**: a Brain tab on clients and work with the six sections, each edited in
  place and confirmed, stale after six months; "Add to brain" on any note; the brain in every
  task's brief; agent tools to read, write, confirm and add.
- **Next**: AI proposals from new notes, emails and transcripts through a review queue; nightly
  tasks for the lead to review stale sections; section restrictions by role.

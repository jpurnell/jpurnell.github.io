# Session Summary: Guidelines Clone Isolation

| Date | Phase | Status |
| :--- | :--- | :--- |
| 2026-07-06 | Infrastructure / guidelines hygiene | COMPLETED |

## 1. Core Objective

Stop this project's `development-guidelines/` clone from pushing project-specific
content into the **shared** template repo (`github.com/jpurnell/development-guidelines`).

## 2. Problem

The nested clone was sitting on `main` (tracking the shared template's `origin/main`).
A prior session had followed the guidelines workflow and committed project artifacts —
a quality-gate report (`project/library/latestReport.json`) and a fix summary — directly onto
`main`, leaving an unpushed commit aimed at the shared template.

## 3. Work Completed

- Removed the stray commit from `main` (report + fix summary deleted; regenerable).
- Created and switched the clone to **`project-state/justinpurnell-com`** (pushed, tracked),
  matching the framework's ownership model — project state lives on a per-project branch,
  never on the template `main`.
- Added an inner `.gitignore` for regenerable artifacts (`latestReport.json`, `.DS_Store`).
- Reset local `main` back to the pristine template.

## 4. Design Decisions

- **Decision:** Use `project-state/<project>` isolation rather than fully detaching the clone.
- **Rationale:** Preserves the framework's cross-machine recovery model while making template
  pollution structurally impossible.

## 5. State / Verification

- Clone on `project-state/justinpurnell-com`, working tree clean, `main` = pristine template.
- Part of a fleet-wide migration (see the Ignite project's summary for the systemic fix).

## 6. Next Steps

- Before committing anything inside `development-guidelines/`, confirm the branch is
  `project-state/…`, not `main`. The template's `setup.swift` now enforces this automatically.

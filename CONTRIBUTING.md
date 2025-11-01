Contributing — SF_Helpers extension

Quick dev checklist

- Branching
  - Create topic branches off `main` with the pattern: `feature/<short-desc>`, `bugfix/<short-desc>`, or `chore/<short-desc>`.
  - Open PRs against `main` and include a short description of the change, affected files, and reproduction steps.

- Coding & style
  - Keep changes minimal and non-invasive.
  - For embedded Lua inside XML: avoid `<`, `>`, `<=`, `>=` (these break the XML parser). Use `sf.isGt()` and `sf.isGe()` helpers instead of direct comparators inside XML-embedded Lua.
  - Use `sf.DebugOut()`/`sf.ErrorOut()` for production logging; while debugging, `Debug.console()` is allowed — do not remove debug statements until the issue is resolved and reviewed.

- Runtime checks
  - Before editing code: make a copy of the campaign DB (the one used for testing) and the extension folder.
  - Launch FGU and load the extension. Reproduce the issue and copy `console.log` for debugging; include timestamps and relevant node paths in the PR description.

- Database access & windowreferences
  - Use `DB.getChild(node, "shortcut")` + `DB.getText(child, "recordname", "")` when reading windowreference `recordname` fields — this avoids edge cases where a nested value isn't returned by `DB.getValue(node, "shortcut.recordname")`.
  - When `recordname` starts with leading dots (e.g. `....inventorylist.id-00009`), implement a "walk-up" resolver that counts the dots and concatenates the suffix against the weapon node path.

- Tests
  - Add minimal tests or repeatable steps in the PR body showing how you verified the change (include sample DB node paths if helpful).
  - Keep debug `Debug.console` traces until the change is validated in FGU.

- PR checklist
  - Explain the problem and the fix in the PR description.
  - State which DB/test campaign you used and the reproduction steps.
  - Confirm the change does not create recursion or UI re-entry issues (e.g., avoid setValue inside onValueChanged handlers that re-trigger the same handler).

Branch & PR naming examples

- feature/fix-vehicle-persistence
- bugfix/grenade-inventory-sync

Contact

- Leave notes in the PR or open an issue for any follow-up work (cleanup of debug logs, additional refactors).
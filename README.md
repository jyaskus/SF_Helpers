# SF Helpers Extension

Enhancement suite for Fantasy Grounds Unity's Starfinder ruleset. This extension streamlines repetitive GM/player workflows and fills in quality-of-life gaps while staying close to the stock UI.

## What's Included

1. **Character Ability Pop-Up** – Surfaces the full ability score recipe (base, racial/theme, boosts, gear) so you can diagnose odd totals without drilling into the database.

2. **Companion Defaults Wizard** – Adds a smart sync button on companions that pushes level-based stats from the owner, locks the derived fields, and shows the XP cost for the next rank.

3. **Vehicle Builder** – Provides a guided builder from the Vehicles tab. Pick grafts and upgrades, preview the math in real time, then spawn the finished vehicle record with a single click.

4. **Grenade Auto-Reloads** – Double-clicking a grenade weapon keeps the weapon `uses` node and the inventory stack in lockstep, instantly refunding or deducting grenades as they’re consumed.

5. **NPC Organizations Ledger** – Adds an "NPC : Orgs" library entry with color-coded ranks and quick links back to NPCs or companions, making faction rosters easy to browse in play.

## Usage Notes

- Embedded Lua inside XML controls cannot use `<`, `>`, `<=`, or `>=`. Use the helper comparisons (`sf.isGt`, `sf.isGe`, etc.) instead.
- Prefer `sf.DebugOut`/`sf.ErrorOut` for logging. Keep `Debug.console` in place only while actively troubleshooting.
- When reading `windowreference` fields like weapon shortcuts, retrieve both class and record name via `DB.getValue(node, "shortcut")` to avoid nil values in split fields.
- Vehicle builder creates finished vehicles under the owning charsheet's `vehicles` node (not the temporary builder node) and prefixes auto-generated names with the character name.

## Contributing

See `.github/copilot-instructions.md` for the active workspace checklist. When submitting PRs, include:

- Repro steps, including campaign DB nodes and console excerpts if applicable.
- Validation notes from Fantasy Grounds Unity (e.g., grenade reload test results, vehicle creation).
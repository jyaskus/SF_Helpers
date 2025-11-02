# SF Helpers Extension

Enhancement suite for Fantasy Grounds Unity's Starfinder ruleset. This extension streamlines repetitive GM/player workflows and fills in quality-of-life gaps while staying close to the stock UI.

## What's Included

1. **Character Ability Pop-Up Enhancements**  
   Track the breakdown of ability modifiers (base, racial, theme, incremental boosts, item bonuses). The vanilla sheet only exposes totals; this pop-up lets you audit every contributing source quickly.

2. **Companion Defaults Wizard**  
   Adds a wizard button on companion sheets that syncs level-based stats directly from the owning character. Helpful metadata like training cost to reach the next level is populated and locked to prevent accidental edits.

3. **Vehicle Builder**  
   Adds a gear-sprocket button to the Vehicles tab that opens an interactive builder. Choose grafts/options, preview derived stats, then generate the finished vehicle in a single click instead of dragging every component manually.

4. **Grenade Quality-of-Life Reloads**  
   Double-clicking a grenade weapon entry now aligns the weapon's `uses` with the linked inventory item count and deducts any used grenades from inventory automatically.

5. **NPC Organizations Ledger**  
   Introduces an "NPC : Orgs" entry under the World section. Track organizations, attach NPC rosters, and open detailed pop-ups for each member (including links back to NPC or companion records).

## Usage Notes

- Embedded Lua inside XML controls cannot use `<`, `>`, `<=`, or `>=`. Use the helper comparisons (`sf.isGt`, `sf.isGe`, etc.) instead.
- Prefer `sf.DebugOut`/`sf.ErrorOut` for logging. Keep `Debug.console` in place only while actively troubleshooting.
- When reading `windowreference` fields like weapon shortcuts, retrieve both class and record name via `DB.getValue(node, "shortcut")` to avoid nil values in split fields.
- Vehicle builder creates finished vehicles under the owning charsheet's `vehicles` node (not the temporary builder node) and prefixes auto-generated names with the character name.

## Contributing

See `.github/copilot-instructions.md` for the active workspace checklist. When submitting PRs, include:

- Repro steps, including campaign DB nodes and console excerpts if applicable.
- Validation notes from Fantasy Grounds Unity (e.g., grenade reload test results, vehicle creation).
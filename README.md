# fgu_fixes
QoL fixes and helpers for Fantasy Grounds Unity (Starfinder / Pathfinder).

This repository contains a Fantasy Grounds Unity extension that provides a set of quality-of-life improvements for Starfinder character sheets, vehicle and companion helpers, and various UX fixes.

Key points for contributors

- Embedded Lua in XML: Lua scripts placed inside XML files for window controls are parsed by FGU's XML loader. Those embedded scripts cannot contain raw XML-sensitive comparison operators like `<`, `>`, `<=`, `>=` (they will break XML parsing or the FGU compiler). Use provided helper functions instead (see below).

- Use helper comparisons: Use `sf.isGt(x,y)` and `sf.isGe(x,y)` for greater-than and greater-or-equal checks respectively when writing Lua inside XML script blocks. These wrappers avoid risky symbols and centralize numeric checks.

- Logging conventions:
	- During development and testing, `Debug.console()` is convenient for rapid output in the debug console.
	- Before committing production code, replace `Debug.console()` with `sf.DebugOut()` for normal extension debug output, or `sf.ErrorOut()` for messages that should be visible only to the GM/host.

- FGU script naming pattern: `extension.xml` loads Lua script files and registers them under a script name. When calling functions from outside a script file you must call them with that prefix. Example:

	- `veh_builder.lua` is registered as `vehBuilder` in `extension.xml`.
	- To call `createVehicle()` from another script or XML control, call `vehBuilder.createVehicle(...)`.

- Limited Lua environment: Fantasy Grounds' Lua is not a full desktop Lua; only basic libraries and FGU API functions are available. Keep code simple and avoid advanced external dependencies.

Structure

- `xml/` — XML window classes and UI definitions (charsheets, vehicle builder, companion UI)
- `scripts/` — Lua helper scripts (sf_helper.lua, veh_builder.lua)
- `Data/` — data modules used by the extension
- `graphics/` and `tokens/` — UI assets

How to test

1. Edit the XML or Lua file you are working on.
2. Reload extensions in Fantasy Grounds (reload ruleset / restart if necessary).
3. Use the FGU debug console and `sf.DebugOut()` output for verification.

If you add or change embedded XML scripts, remember to avoid raw `<`/`>` comparisons and to prefer `sf.isGt`/`sf.isGe`.

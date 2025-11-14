# Fantasy Grounds Unity Extension - AI Coding Instructions

## Project Overview
This is a Fantasy Grounds Unity (FGU) extension providing QoL fixes and additional functionality for Starfinder and Pathfinder rulesets. The extension follows FGU's XML-based UI framework with Lua scripting.

## Architecture & Key Components

### Extension Structure
- `extension.xml` - Main extension manifest with loadorder 234, imports CoreRPG ruleset
- `xml/sfrpg_fixes.xml` - Core UI fixes for Starfinder character sheets (ability score calculations)
- `scripts/` - Lua business logic organized by functional areas
- `graphics/` - UI assets (icons, buttons, frames, tabs) with clear naming conventions
- `tokens/` - Game tokens for dice and resources

### Critical Patterns

#### XML Window Classes
UI elements use FGU's windowclass system with precise positioning via `<bounds>` or `<anchored>` tags:
```xml
<number_charabilityscore name="strength" source="abilities.strength.score">
    <anchored to="abilityScoreframe" position="insidetopleft" offset="105,26" />
</number_charabilityscore>
```

#### Lua Script Organization
- `sf_helper.lua` - Global utilities (comparison functions, dice rolling, string manipulation)
- `handlers.lua` - Roll result handlers with DC checking and chat output (deleted)
- `init_sf.lua` - Extension initialization, database setup, and option registration (deleted)
- `oob_helpers.lua` - Out-of-band message handling for multiplayer coordination (deleted)

#### Database Node Patterns
Extensions create public database nodes for shared data:
```lua
local tNode = DB.createNode(dbRootName);
DB.setPublic(tNode, true);
```

#### Script Naming Convention
Functions use descriptive prefixes:
- `update*()` - Recalculate derived values
- `onValueChanged()` - React to user input
- `register*()` - Initialize handlers/options
- `handle*()` - Process specific events

### Key Integration Points

#### Ability Score System
The extension overrides SFRPG ability score calculations with custom boost logic:
- Base score + racial + theme + point buy + ability boosts
- Boosts add +2 if total ≤16, +1 if >16
- Point buy limited to 10 points total with real-time validation

#### Galactic Trade System
Complete homebrew trading system with:
- Supply tier management (None/Basic/Good/Luxury)
- Morale calculations based on quarters and supplies
- Weekly resolution with environmental modifiers
- Out-of-band messaging for multiplayer state sync

#### Vehicle Builder System
Custom vehicle creation tool for Starfinder:
- Level-based stat calculation with vehicle type modifiers
- Size, origin, and special ability selection
- Real-time total calculations for all vehicle stats
- Export functionality to create FGU vehicle records
- Integration with character sheet vehicle inventory

#### Ruleset Wizard Integration
Provides UI components for dynamic rule configuration:
- Custom combobox controls with filtering
- Die field modifiers for homebrew mechanics
- Database manipulation through OOB messages

## Development Workflows

### Testing Changes
Extensions auto-reload in FGU when files change. Test UI changes by:
1. Modify XML/Lua files
2. Reload extension in FGU
3. Open affected character sheets/windows

### Asset Management
Graphics follow strict naming: `{category}_{descriptor}_{state}.png`
- States: `_down`, `_hover`, `_dark` for interactive elements
- Categories: `button`, `tab`, `icon`, `frame`

### Debugging
Use `Debug.console()` for runtime logging during development and `sf.sendChat()` for user-visible messages.

Important embedded-Lua constraints (XML script blocks)

- XML-embedded Lua scripts (script nodes inside window controls) cannot include raw XML-sensitive comparison symbols such as `<`, `>`, `<=`, `>=` or variations. These characters either break XML parsing or cause FGU's Lua compiler to fail when loading the extension.

- Use the provided helper comparison functions instead:
    - `sf.isGt(x, y)` — returns true if x > y
    - `sf.isGe(x, y)` — returns true if x >= y

- Logging: it's fine to use `Debug.console()` while developing. Before committing production code, replace `Debug.console()` calls with `sf.DebugOut()` for general debug logging or `sf.ErrorOut()` for messages that should only be shown to the GM/host.

- Script calling pattern: `extension.xml` registers Lua files under script names. When calling functions from other scripts or XML you must prefix the function with the registered script name, for example `vehBuilder.createVehicle(...)` or `CompanionData.getLevelHP(...)`. This is FGU's runtime binding and avoids assumptions about global function visibility.

- Limited Lua: Remember FGU provides a constrained Lua runtime; keep logic simple and avoid depending on non-standard Lua libraries or features.

## Extension-Specific Conventions

- All global functions use `sf.` namespace for utilities
- UI elements reference data sources with dotted notation: `abilities.strength.score`
- Button controls use consistent `bounds` positioning relative to parent elements
- Custom window classes extend existing FGU templates with `merge="join"`
- OOB messages handle multiplayer synchronization for custom data structures

## Common Modification Patterns

### Adding New Ability Calculations
1. Create number control with bounds positioning
2. Add update function with tonumber() safety checks
3. Wire onValueChanged() to trigger recalculation
4. Include validation limits (like point buy caps)

### Extending UI Components
1. Define new windowclass or extend existing with merge="join"
2. Use consistent anchoring to existing elements
3. Add supporting Lua scripts in appropriate category files
4. Register any new handlers in init functions

### Creating Database Records
When creating new database records (like vehicles):
1. Use `DB.createChild()` to create new nodes
2. Set values with proper type specification: `DB.setValue(node, "field", "type", value)`
3. Create nested structures (like movements, specialabilities) as child nodes
4. Use windowreference type for link fields with class and recordname
5. Follow FGU's expected node structure for compatibility
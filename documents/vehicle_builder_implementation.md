# Vehicle Builder Implementation Summary

## Overview
The Vehicle Builder extension allows users to create custom Starfinder vehicles with calculated stats based on level, type, size, origin, and special abilities. The builder exports fully-compatible FGU vehicle records with complete graft metadata.

## Key Features

### 1. Vehicle Calculation System
- **Level-based Stats** (1-20): HP, EAC, KAC, Hardness, Speed, Attack, Piloting
- **Vehicle Types**: Boat, Submersible, Cruiser, Cycle, Tank, Truck, Walker, Fast Flyer, Hovering Flyer
- **Sizes**: Medium, Large, Huge, Gargantuan, Colossal
- **Origins**: Standard, Junk, Custom, Military
- **Special Abilities**: Armored, Racer, Transport, Hover, Junk, Hybrid Aircraft

### 2. Real-time Calculations
- All totals update automatically when selections change
- Price calculations include all modifiers
- Collision damage scales with size
- Movement speeds calculated with type/size/special modifiers
- Overland speed includes transport bonus (20% if transport special selected)

### 3. Export Functionality
The builder creates complete FGU vehicle records with:
- All base stats (HP, AC, Hardness, Attack, etc.)
- Movement data (speed, full speed, overland mph)
- Collision damage and DC
- **Graft metadata** stored in parts section
- Proper windowreference links for UI integration
- Special abilities with descriptions

## Graft System Implementation

### Structure
Each vehicle has three types of grafts exported:

1. **Type Graft** (parts.id-00001)
   - Defines base vehicle characteristics
   - Includes cover type, modifiers, passengers, speed multiplier
   - Examples: "Cruiser (Land Vehicle)", "Boat (water vehicle)"

2. **Size Graft** (parts.id-00002)
   - Applies size-based modifiers
   - Includes adjustments for HP, collision damage, passengers, etc.
   - Examples: "Gargantuan", "Huge", "Medium"

3. **Special Grafts** (parts.id-00003, id-00004)
   - Up to 2 special abilities
   - Each with unique adjustments and descriptions
   - Examples: "Armored", "Racer", "Hover", "Transport"

### Export Format
Each graft is stored in two ways:
```xml
<!-- String value for display -->
<typegraft type="string">Cruiser (Land Vehicle)</typegraft>

<!-- Link to parts entry -->
<typegraftlink type="windowreference">
  <class>item</class>
  <recordname>....vehicles.id-XXXX.parts.id-00001</recordname>
</typegraftlink>

<!-- Full parts entry -->
<parts>
  <id-00001>
    <name type="string">Cruiser (Land Vehicle)</name>
    <subtype type="string">Type Graft</subtype>
    <type type="string">Vehicle</type>
    <cover type="string">Improved cover</cover>
    <modifiers type="string">+0 Piloting, –2 attack (–4 at full speed)</modifiers>
    <passengers type="number">3</passengers>
    <speed type="string">(Full): speed × 25</speed>
    <link type="windowreference">
      <class>item</class>
      <recordname>..parts.id-00001</recordname>
    </link>
  </id-00001>
</parts>
```

## File Structure

### XML Files
- `xml/veh_builder.xml` - Vehicle builder UI with calculation fields

### Lua Scripts
- `scripts/veh_builder.lua` - Vehicle record creation and graft generation
  - `vehBuilder_createVehicleRecord()` - Main export function
  - `createTypeGraftPart()` - Type graft creation
  - `createSizeGraftPart()` - Size graft creation
  - `createSpecialGraftPart()` - Special graft creation
  - `getTypeGraftData()` - Type graft definitions
  - `getSizeGraftData()` - Size graft definitions
  - `getSpecialGraftData()` - Special graft definitions

### Registration
- `extension.xml` - Registers vehBuilder script with proper namespace

## Compatibility

### FGU UI Integration
Builder-created vehicles are fully compatible with the FGU UI:
- Appear in character sheet vehicle list
- Show in Modifications section with links
- Can be edited using FGU's native tools
- Display all stats correctly

### Example Output
When exported, vehicles show in the Modifications section like:
- **Cruiser (Land Vehicle)** *(linked to type graft)*
- **Gargantuan** *(linked to size graft)*
- **Armored** *(linked to special graft)*

## Future Enhancements
Potential areas for expansion:
- Token/portrait selection
- Weapon system integration in parts
- Origin graft implementation
- Additional special abilities
- Vehicle modification slots pre-population
- Export to library for reuse

## Testing Notes
Tested with:
- UI drag-and-drop created vehicles
- Builder-exported vehicles
- Comparison against official vehicle exports
- Verification of all graft metadata fields

All tests confirm complete compatibility between builder exports and UI-created vehicles.

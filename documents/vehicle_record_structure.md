# Fantasy Grounds Unity Vehicle Record Structure

## Overview
This document summarizes the structure of vehicle records as exported/imported in Fantasy Grounds Unity (FGU), based on analysis of both sample exports and vehicles created by the extension's builder. It is intended as a reference for future development and troubleshooting.

---

## Top-Level Vehicle Fields
Each vehicle is a child node under `<vehicles>`, with a unique id (e.g., `<id-00001>`). The following fields are commonly present:

- `name` (string): Vehicle name
- `level` (number): Vehicle level
- `converted` (number): 1 if converted by extension, else omitted
- `locked` (number): 0/1 for edit lock
- `price` (string): Cost
- `cover` (string): Cover type (e.g., total)
- `passengers` (number): Max passengers
- `space` (number): Space occupied (often 0)
- `sizegraft` (string): Size description
- `sizegraftlink` (windowreference): Link to size graft part
- `specialgraft` (string): Special graft name (optional)
- `specialgraftlink` (windowreference): Link to special graft part
- `typegraft` (string): Type graft name (optional)
- `typegraftlink` (windowreference): Link to type graft part
- `origingraftlink` (windowreference): Link to origin graft part
- `token` (token): Token image (optional)
- `picture` (token): Portrait image (optional)
- `token3Dflat` (token): 3D token (optional)

---

## Subrecords
### 1. `attack`
- `mod` (number): Attack modifier
- `full` (number): Full attack modifier

### 2. `collision`
- `damage.total` (string): Collision damage (e.g., 5d8 b)
- `dc.total` (number): Collision DC

### 3. `defenses`
- `eac.total` (number): EAC
- `kac.total` (number): KAC
- `hardness.total` (number): Hardness

### 4. `hp`
- `total` (number): Total HP
- `broken` (number): HP threshold for broken
- `base` (number): Base HP (often 0)
- `wounds` (number): Wounds (often 0)

### 5. `pilot`
- `total` (number): Piloting modifier

### 6. `modslots`
- `total` (number): Mod slots

### 7. `movements`
- Each movement is a child node (e.g., `<id-00001>`) with:
  - `speed` (number): Base speed
  - `fullspeed` (number): Full speed
  - `overland` (number): Overland speed (mph)
  - `name` (string): Movement description

### 8. `specialabilities`
- Each is a child node (e.g., `<id-00001>`) with:
  - `name` (string): Feature name
  - `text` (string): Description
  - `locked` (number): 1 if locked
  - `shortcut` (windowreference): Link to ability (optional)

### 9. `parts`
- Each is a child node (e.g., `<id-00001>`) representing a graft or component
- **Type Graft** (id-00001): Vehicle type (Boat, Cruiser, Tank, etc.)
  - `name`: e.g., "Cruiser (Land Vehicle)"
  - `subtype`: "Type Graft"
  - `type`: "Vehicle"
  - `description`: Type description
  - `modifiers`: Piloting/attack modifiers
  - `passengers`: Base passenger count
  - `cover`: Cover type
  - `speed`: Speed multiplier info
  - `link`: Self-reference to parts entry
- **Size Graft** (id-00002): Vehicle size (Medium, Large, Huge, etc.)
  - `name`: e.g., "Gargantuan"
  - `subtype`: "Size Graft"
  - `type`: "Vehicle"
  - `adjustments`: Size-based stat modifications
  - `link`: Self-reference to parts entry
- **Special Graft** (id-00003+): Special abilities (Armored, Racer, Hover, etc.)
  - `name`: e.g., "Armored"
  - `subtype`: "Special Graft"
  - `type`: "Vehicle"
  - `adjustments`: or `special`: Stat modifications
  - `description`: Special ability description
  - `link`: Self-reference to parts entry
- **Weapon/System parts**: Additional equipment
  - Full weapon or item record structure
  - `subtype`: "Heavy", "Small Arms", etc.
  - `type`: "Weapon"

### 10. `ppabilities`
- Empty node for power points or abilities (future use)

---

## Graft System
Vehicles created in the FGU UI use a "graft" system where:
1. **Type Graft** defines base vehicle type and movement
2. **Size Graft** applies size-based modifiers
3. **Special Grafts** (1-2) add unique features

Each graft is stored in two places:
- As a string value: `typegraft`, `sizegraft`, `specialgraft`
- As a full parts entry with `link` pointing to itself
- With a windowreference link: `typegraftlink`, `sizegraftlink`, `specialgraftlink`

Example:
```xml
<typegraft type="string">Cruiser (Land Vehicle)</typegraft>
<typegraftlink type="windowreference">
  <class>item</class>
  <recordname>....vehicles.id-00010.parts.id-00001</recordname>
</typegraftlink>
```

---

## Observed Optional/Variant Fields
- `picture`, `token`, `token3Dflat`: For visual representation
- `specialgraft`, `typegraft`, `sizegraft`: Sometimes as string, sometimes only as link
- `parts`: May include weapons, armor, or other systems as subrecords
- `movements`: May be empty if not set

---

## Notes
- Vehicles built by dragging grafts/components in the UI may have more detailed `parts` subrecords.
- Vehicles exported by the extension may omit some optional fields (e.g., `picture`, `token`).
- Weapon systems can be included as part subrecords under `parts`.
- All windowreference fields (`link`, `sizegraftlink`, etc.) are for FGU UI linking and may be empty.

---

## Example Vehicle Node (abridged)
```xml
<id-00001>
  <name type="string">Truck w Gun</name>
  <level type="number">10</level>
  <attack>...</attack>
  <collision>...</collision>
  <defenses>...</defenses>
  <hp>...</hp>
  <movements>...</movements>
  <parts>...</parts>
  <specialabilities>...</specialabilities>
  <token type="token"></token>
  <sizegraftlink>...</sizegraftlink>
  <specialgraftlink>...</specialgraftlink>
  <typegraftlink>...</typegraftlink>
  <origingraftlink>...</origingraftlink>
</id-00001>
```

---

## Summary
- All core stats, movement, and defense fields are present in both builder and UI-created vehicles.
- `parts` subrecords include graft entries (type, size, special) that define the vehicle's characteristics.
- Each graft is stored as both a string field and a full parts entry with a windowreference link.
- Visual fields (`token`, `picture`, `token3Dflat`) are optional but supported.
- Windowreference fields are for UI linking and point to the parts entries.

## Builder Export Updates
Our vehicle builder now exports vehicles with complete graft metadata:
- **Type Graft** (parts.id-00001): Vehicle type with cover, modifiers, passengers, speed
- **Size Graft** (parts.id-00002): Size with adjustments for stats
- **Special Graft** (parts.id-00003+): Special abilities with adjustments/descriptions

This makes builder-created vehicles fully compatible with the FGU UI, allowing them to appear in the Modifications section with proper links.

This document should be updated as new vehicle features or subrecords are discovered.

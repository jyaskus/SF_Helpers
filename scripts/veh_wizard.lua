--
-- veh_wizard.lua
-- Helper functions and state management for the vehicle wizard that edits
-- existing vehicle records directly instead of creating new ones.
--

vehWizard = vehWizard or {}

local STATE_CHILD_NAME = "vehwizard"
local LEVEL_PRICE = { 700, 1600, 2600, 4000, 6000, 8500, 13000, 19000, 27000, 36000, 50000, 73000, 100000, 150000, 230000, 345000, 520000, 750000, 1150000, 1750000 }
local LEVEL_SPEED = { 25, 25, 25, 25, 25, 30, 30, 30, 35, 35, 35, 40, 40, 40, 45, 45, 45, 50, 50, 50 }
local LEVEL_EAC = { 12, 13, 14, 15, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 35 }
local LEVEL_HP = { 12, 20, 30, 40, 55, 75, 95, 120, 135, 150, 165, 185, 205, 230, 255, 280, 310, 340, 370, 400 }
local LEVEL_HARDNESS = { 5, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
local LEVEL_DICE_COUNT = { 4, 5, 6, 5, 5, 6, 6, 7, 8, 9, 10, 11, 12, 14, 15, 17, 18, 20, 23, 25 }
local LEVEL_DICE_SIZE = { 4, 4, 4, 6, 8, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10 }
local LEVEL_COLLISION_DC = { 10, 11, 12, 13, 13, 14, 15, 16, 16, 17, 18, 19, 19, 20, 21, 22, 22, 23, 24, 25 }
local LEVEL_MOD_SLOTS = { 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5 }

local WORKING_CHILD = "working"

local TYPE_RULES = {
  ["boat"] = {
    cycler = "Boat",
    display = "Boat (Water Vehicle)",
    subtype = " (Water Vehicle)",
    passengers = 2,
    fullspeed = 15,
    piloting = 0,
    attack = -2,
    attackfull = -4,
    cover = "partial",
    description = "Boats travel on the surface of the water and can be powered by a wide variety of propulsion methods."
  },
  ["cruiser"] = {
    cycler = "Cruiser",
    display = "Cruiser (Land Vehicle)",
    subtype = " (Land Vehicle)",
    passengers = 3,
    fullspeed = 25,
    piloting = -1,
    attack = -2,
    attackfull = -4,
    cover = "improved",
    pricePct = 0.10,
    kacMod = 1,
    hpPct = 0.10,
    description = "The Cruiser uses powerful propulsion methods that enable travel at high speeds over open terrain."
  },
  ["cycle"] = {
    cycler = "Cycle",
    display = "Cycle (Land Vehicle)",
    subtype = " (Land Vehicle)",
    passengers = 1,
    fullspeed = 20,
    piloting = 2,
    attack = -1,
    attackfull = -3,
    cover = "none",
    pricePct = -0.10,
    kacMod = -2,
    eacMod = -2,
    hpPct = -0.10,
    notes = "Cycles cannot increase passengers beyond 1 with other Grafts.",
    description = "Cycles are vehicles that the pilot and sometimes a passenger ride directly on top of, and they can have a wide variety of uses."
  },
  ["fast flyer"] = {
    cycler = "Fast Flyer",
    display = "Fast Flyer (Air Vehicle)",
    subtype = " (Air Vehicle)",
    passengers = 2,
    fullspeed = 25,
    piloting = -1,
    attack = -2,
    attackfull = -5,
    cover = "total",
    pricePct = 0.20,
    kacMod = -2,
    eacMod = -2,
    hpPct = -0.10,
    speedMod = 15,
    notes = "Fast Flyers move continuously forward to stay airborne and have no ground movement speed.",
    description = "These speedy vehicles are designed for continuous forward movement and generally have wings and landing gear."
  },
  ["hovering flyer"] = {
    cycler = "Hovering Flyer",
    display = "Hovering Flyer (Air Vehicle)",
    subtype = " (Air Vehicle)",
    passengers = 2,
    fullspeed = 20,
    piloting = 0,
    attack = -1,
    attackfull = -4,
    cover = "cover",
    pricePct = 0.20,
    kacMod = -1,
    eacMod = -1,
    hpPct = -0.10,
    notes = "Hovering Flyers can move as easily horizontally as vertically, needing no runway to take off.",
    description = "These rotor or hover pad powered air vehicles provide maximum stability and maneuverability."
  },
  ["submersible"] = {
    cycler = "Submersible",
    display = "Submersible (Water Vehicle)",
    subtype = " (Water Vehicle)",
    passengers = 2,
    fullspeed = 10,
    piloting = -2,
    attack = -2,
    attackfull = -5,
    cover = "total",
    pricePct = 0.20,
    hardnessPct = 0.20,
    notes = "Submersibles cannot use Grafts or Mods that would reduce cover less than total cover.",
    description = "These vehicles can submerge completely in a liquid (usually water) for extended periods."
  },
  ["tank"] = {
    cycler = "Tank",
    display = "Tank (Land Vehicle)",
    subtype = " (Land Vehicle)",
    passengers = 1,
    fullspeed = 10,
    piloting = -1,
    attack = -2,
    attackfull = -4,
    cover = "total",
    pricePct = 0.35,
    speedMod = -5,
    kacMod = 2,
    eacMod = 2,
    hardnessPct = 0.20,
    description = "These heavily armored vehicles resist damage, maneuver ponderously, and are rarely available to civilians."
  },
  ["truck"] = {
    cycler = "Truck",
    display = "Truck (Land Vehicle)",
    subtype = " (Land Vehicle)",
    passengers = 3,
    fullspeed = 20,
    piloting = -1,
    attack = -3,
    attackfull = -5,
    cover = "cover",
    hpPct = 0.10,
    description = "These rugged ground vehicles transport passengers or cargo."
  },
  ["walker"] = {
    cycler = "Walker",
    display = "Walker (Land Vehicle)",
    subtype = " (Land Vehicle)",
    passengers = 2,
    fullspeed = 10,
    piloting = 1,
    attack = -2,
    attackfull = -6,
    cover = "improved",
    description = "These relatively slow vehicles use numerous legs to stride over challenging terrain with ease."
  }
}

local TYPE_RULE_INDEX = {}

local function registerTypeRule(key)
  local rule = TYPE_RULES[key]
  if not rule then
    return
  end

  rule.key = key
  rule.cyclerLower = rule.cycler:lower() or key:lower();
  rule.displayLower = rule.display:lower() or rule.cycler:lower() or key:lower();

  TYPE_RULE_INDEX[key] = key
  TYPE_RULE_INDEX[rule.cyclerLower] = key
  TYPE_RULE_INDEX[rule.displayLower] = key
end

registerTypeRule("boat")
registerTypeRule("cruiser")
registerTypeRule("cycle")
registerTypeRule("fast flyer")
registerTypeRule("hovering flyer")
registerTypeRule("submersible")
registerTypeRule("tank")
registerTypeRule("truck")
registerTypeRule("walker")

local function clampLevel(nLevel)
  local n = tonumber(nLevel) or 1
  if n < 1 then
    return 1
  end
  if n > 20 then
    return 20
  end
  return math.floor(n)
end

local function setNumberValue(control, value)
  if control and control.setValue then
    control.setValue(value or 0)
  end
end

local function setStringValue(control, value)
  if control and control.setValue then
    control.setValue(value or "")
  end
end

local function asString(value)
  if value == nil then
    return ""
  end
  if type(value) == "string" then
    return value
  end
  return tostring(value)
end

local function lowerString(value)
  return asString(value):lower()
end

local function normalizeString(value)
  if not value then
    return ""
  end

  local normalized = lowerString(value)
  normalized = normalized:gsub("^%s+", "")
  normalized = normalized:gsub("%s+$", "")
  normalized = normalized:gsub("%s+", " ")
  return normalized
end

local function resolveTypeKey(value)
  local normalized = normalizeString(value)
  if normalized == "" then
    return nil
  end

  local key = TYPE_RULE_INDEX[normalized]
  if key then
    return key
  end

  local base = normalized:match("^(.-)%s*%(")
  if base and base ~= "" then
    return TYPE_RULE_INDEX[base]
  end

  return nil
end

local function trySetCyclerValue(control, value)
  if not control or not value then
    return
  end

  local attempts = { "setListValue", "setStringValue", "setValue" }
  for _, methodName in ipairs(attempts) do
    local method = control[methodName]
    if method then
      local ok = pcall(method, control, value)
      if ok then
        return true
      end
    end
  end

  return false
end

local function clearTypeFields(w)
  if not w then
    return
  end

  setStringValue(w.VehSubTypeLabel, "")
  setStringValue(w.sVehDescription, "")
  setStringValue(w.sVehTypeNotes, "")
  setStringValue(w.sVehCover, "none")

  setNumberValue(w.nBasePassengers, 0)
  setNumberValue(w.nBaseFullSpeedMult, 0)
  setNumberValue(w.nBasePilotingMod, 0)
  setNumberValue(w.nBaseAttackMod, 0)
  setNumberValue(w.nBaseAttackFullMod, 0)
  setNumberValue(w.nVehTypeSpeedMod, 0)
  setNumberValue(w.nVehTypeEACmod, 0)
  setNumberValue(w.nVehTypeKACmod, 0)
  setNumberValue(w.nVehTypeHP, 0)
  setNumberValue(w.nVehTypeHardness, 0)
  setNumberValue(w.nVehTypePrice, 0)
end

local function rebuildTypeUI(w, rule)
  if not w then
    return nil
  end

  clearTypeFields(w)

  if not rule then
    return nil
  end

  setStringValue(w.VehSubTypeLabel, rule.subtype or "")
  setStringValue(w.sVehDescription, rule.description or "")
  setStringValue(w.sVehTypeNotes, rule.notes or "")
  setStringValue(w.sVehCover, rule.cover or "none")

  setNumberValue(w.nBasePassengers, rule.passengers or 0)
  setNumberValue(w.nBaseFullSpeedMult, rule.fullspeed or 0)
  setNumberValue(w.nBasePilotingMod, rule.piloting or 0)
  setNumberValue(w.nBaseAttackMod, rule.attack or 0)
  setNumberValue(w.nBaseAttackFullMod, rule.attackfull or 0)
  setNumberValue(w.nVehTypeSpeedMod, rule.speedMod or 0)
  setNumberValue(w.nVehTypeEACmod, rule.eacMod or 0)
  setNumberValue(w.nVehTypeKACmod, rule.kacMod or 0)

  local basePrice = (w.nBasePrice and w.nBasePrice.getValue and w.nBasePrice.getValue()) or 0
  local baseHP = (w.nBaseHP and w.nBaseHP.getValue and w.nBaseHP.getValue()) or 0
  local baseHardness = (w.nBaseHardness and w.nBaseHardness.getValue and w.nBaseHardness.getValue()) or 0

  local priceAdj = 0
  if rule.pricePct then
    priceAdj = math.floor(basePrice * rule.pricePct)
    setNumberValue(w.nVehTypePrice, priceAdj)
  end

  local hpAdj = 0
  if rule.hpPct then
    hpAdj = math.floor(baseHP * rule.hpPct)
    setNumberValue(w.nVehTypeHP, hpAdj)
  end

  local hardnessAdj = 0
  if rule.hardnessPct then
    hardnessAdj = math.floor(baseHardness * rule.hardnessPct)
    setNumberValue(w.nVehTypeHardness, hardnessAdj)
  end

  return {
    key = rule.key,
    label = rule.cycler,
    display = rule.display or rule.cycler,
    subtype = rule.subtype or "",
    cover = rule.cover or "none",
    description = rule.description or "",
    notes = rule.notes or "",
    passengers = rule.passengers or 0,
    fullspeed = rule.fullspeed or 0,
    piloting = rule.piloting or 0,
    attack = rule.attack or 0,
    attackfull = rule.attackfull or 0,
    speedmod = rule.speedMod or 0,
    eacmod = rule.eacMod or 0,
    kacmod = rule.kacMod or 0,
    hpmod = hpAdj,
    hardnessmod = hardnessAdj,
    pricemod = priceAdj
  }
end

local function applyLevelTables(w, nLevel)
  if not w then
    return
  end

  local nIndex = clampLevel(nLevel)

  setNumberValue(w.nBasePrice, LEVEL_PRICE[nIndex])
  setNumberValue(w.nBaseSpeed, LEVEL_SPEED[nIndex])

  local nEAC = LEVEL_EAC[nIndex] or 0
  setNumberValue(w.nBaseEAC, nEAC)
  setNumberValue(w.nBaseKAC, nEAC + 2)

  setNumberValue(w.nBaseHP, LEVEL_HP[nIndex])
  setNumberValue(w.nBaseHardness, LEVEL_HARDNESS[nIndex])
  setNumberValue(w.nBaseDiceCount, LEVEL_DICE_COUNT[nIndex])
  setNumberValue(w.nBaseDiceSize, LEVEL_DICE_SIZE[nIndex])
  setNumberValue(w.nBaseCollisionDC, LEVEL_COLLISION_DC[nIndex])
  setNumberValue(w.nBaseModSlots, LEVEL_MOD_SLOTS[nIndex])

  if w.StringCyclerVehType and w.StringCyclerVehType.updateVehType then
    w.StringCyclerVehType.updateVehType()
  end
  if w.StringCyclerVehSize and w.StringCyclerVehSize.updateVehSize then
    w.StringCyclerVehSize.updateVehSize()
  end
  if w.StringCyclerVehOrigin and w.StringCyclerVehOrigin.updateVehOrigin then
    w.StringCyclerVehOrigin.updateVehOrigin()
  end
  if w.StringCyclerVehSpecial1 and w.StringCyclerVehSpecial1.updateSpecial1 then
    w.StringCyclerVehSpecial1.updateSpecial1()
  end
  if w.StringCyclerVehSpecial2 and w.StringCyclerVehSpecial2.updateSpecial2 then
    w.StringCyclerVehSpecial2.updateSpecial2()
  end
end

local function getVehicleNode(w)
  if not w then
    return nil
  end

  if w._vehicleNode then
    return w._vehicleNode
  end

  if w.getDatabaseNode then
    local node = w.getDatabaseNode()
    w._vehicleNode = node
    return node
  end

  return nil
end

local function getWizardState(w)
  if not w then
    return nil
  end

  if w._wizardState then
    return w._wizardState
  end

  local nodeVehicle = getVehicleNode(w)
  if not nodeVehicle then
    return nil
  end

  w._wizardState = vehWizard.ensureWizardState(nodeVehicle)
  return w._wizardState
end

local function getWorkingNode(nodeState)
  if not nodeState then
    return nil
  end

  local nodeWorking = DB.getChild(nodeState, WORKING_CHILD)
  if not nodeWorking then
    nodeWorking = DB.createChild(nodeState, WORKING_CHILD)
  end

  return nodeWorking
end

local function persistWorkingBase(nodeState, nLevel)
  if not nodeState then
    return
  end

  local nodeWorking = getWorkingNode(nodeState)
  if not nodeWorking then
    return
  end

  local nIndex = clampLevel(nLevel)

  DB.setValue(nodeWorking, "level", "number", nIndex)
  DB.setValue(nodeWorking, "price", "number", LEVEL_PRICE[nIndex] or 0)
  DB.setValue(nodeWorking, "speed", "number", LEVEL_SPEED[nIndex] or 0)
  DB.setValue(nodeWorking, "eac", "number", LEVEL_EAC[nIndex] or 0)
  DB.setValue(nodeWorking, "kac", "number", (LEVEL_EAC[nIndex] or 0) + 2)
  DB.setValue(nodeWorking, "hp", "number", LEVEL_HP[nIndex] or 0)
  DB.setValue(nodeWorking, "hardness", "number", LEVEL_HARDNESS[nIndex] or 0)
  DB.setValue(nodeWorking, "dicecount", "number", LEVEL_DICE_COUNT[nIndex] or 0)
  DB.setValue(nodeWorking, "dicesize", "number", LEVEL_DICE_SIZE[nIndex] or 0)
  DB.setValue(nodeWorking, "collisiondc", "number", LEVEL_COLLISION_DC[nIndex] or 0)
  DB.setValue(nodeWorking, "modslots", "number", LEVEL_MOD_SLOTS[nIndex] or 0)
end

local function persistTypeSelection(nodeState, ruleKey, tData)
  if not nodeState then
    return false
  end

  local nodeWorking = getWorkingNode(nodeState)
  if not nodeWorking then
    return false
  end

  local nodeType = DB.getChild(nodeWorking, "type")
  local previousKey = ""
  if nodeType then
    previousKey = DB.getValue(nodeType, "key", "") or ""
  end

  if not ruleKey or not tData then
    if nodeType then
      DB.deleteChild(nodeWorking, "type")
    end
    return normalizeString(previousKey) ~= ""
  end

  if not nodeType then
    nodeType = DB.createChild(nodeWorking, "type")
  end

  DB.setValue(nodeType, "key", "string", ruleKey)
  DB.setValue(nodeType, "label", "string", tData.label or "")
  DB.setValue(nodeType, "display", "string", tData.display or "")
  DB.setValue(nodeType, "subtype", "string", tData.subtype or "")
  DB.setValue(nodeType, "cover", "string", tData.cover or "none")
  DB.setValue(nodeType, "description", "string", tData.description or "")
  DB.setValue(nodeType, "notes", "string", tData.notes or "")
  DB.setValue(nodeType, "passengers", "number", tData.passengers or 0)
  DB.setValue(nodeType, "fullspeed", "number", tData.fullspeed or 0)
  DB.setValue(nodeType, "piloting", "number", tData.piloting or 0)
  DB.setValue(nodeType, "attack", "number", tData.attack or 0)
  DB.setValue(nodeType, "attackfull", "number", tData.attackfull or 0)
  DB.setValue(nodeType, "speedmod", "number", tData.speedmod or 0)
  DB.setValue(nodeType, "eacmod", "number", tData.eacmod or 0)
  DB.setValue(nodeType, "kacmod", "number", tData.kacmod or 0)
  DB.setValue(nodeType, "hpmod", "number", tData.hpmod or 0)
  DB.setValue(nodeType, "hardnessmod", "number", tData.hardnessmod or 0)
  DB.setValue(nodeType, "pricemod", "number", tData.pricemod or 0)

  return normalizeString(previousKey) ~= ruleKey
end

local function updateVehicleTypeFields(nodeVehicle, ruleKey)
  if not nodeVehicle then
    return
  end

  if not ruleKey or not TYPE_RULES[ruleKey] then
    DB.setValue(nodeVehicle, "typegraft", "string", "")
    DB.setValue(nodeVehicle, "typegraftlink", "windowreference", "", "")
    return
  end

  local rule = TYPE_RULES[ruleKey]
  DB.setValue(nodeVehicle, "typegraft", "string", rule.display or rule.cycler)

  local sClass, sRecord = "", ""
  if VehicleGraftData and VehicleGraftData.getTypeGraftReference then
    sClass, sRecord = VehicleGraftData.getTypeGraftReference(rule.cycler)
  elseif getTypeGraftReference then
    sClass, sRecord = getTypeGraftReference(rule.cycler)
  end

  if sClass and sClass ~= "" and sRecord and sRecord ~= "" then
    DB.setValue(nodeVehicle, "typegraftlink", "windowreference", sClass, sRecord)
  else
    DB.setValue(nodeVehicle, "typegraftlink", "windowreference", "", "")
  end
end

local function refreshTotals(w)
  if not w or not w.button_update_totals or not w.button_update_totals.onButtonPress then
    return
  end

  w.button_update_totals.onButtonPress()
end

-----------------------------------------------------------------------
-- Window helpers
-----------------------------------------------------------------------

function vehWizard.open(nodeVehicle)
  if not nodeVehicle then
    sf.ErrorOut("Vehicle wizard requires a vehicle record node.")
    return nil
  end

  return Interface.openWindow("vehWizard", nodeVehicle)
end

function vehWizard.onInit(w)
  if not w then
    return
  end

  local nodeVehicle = getVehicleNode(w)
  if not nodeVehicle then
    sf.ErrorOut("Vehicle wizard window opened without a vehicle record node.")
    return
  end

  w._vehicleNode = nodeVehicle
  w._wizardState = vehWizard.ensureWizardState(nodeVehicle)
  w._syncing = false

  vehWizard.cacheBaseSnapshot(w)
  vehWizard.syncUIFromRecord(w)
end

function vehWizard.onClose(w)
  if not w then
    return
  end

  w._vehicleNode = nil
  w._wizardState = nil
  w._syncing = nil
end

-----------------------------------------------------------------------
-- State helpers
-----------------------------------------------------------------------

function vehWizard.ensureWizardState(nodeVehicle)
  if not nodeVehicle then
    return nil
  end

  local nodeState = DB.getChild(nodeVehicle, STATE_CHILD_NAME)
  if not nodeState then
    nodeState = DB.createChild(nodeVehicle, STATE_CHILD_NAME)
    if nodeState then
      DB.setPublic(nodeState, true)
    end
  end

  return nodeState
end

function vehWizard.cacheBaseSnapshot(w)
  local nodeVehicle = getVehicleNode(w)
  local nodeState = getWizardState(w)
  if not nodeVehicle or not nodeState then
    return
  end

  if DB.getValue(nodeState, "initialized", 0) == 1 then
    return
  end

  local tNumericFields = {
    { path = "level", default = 1 },
    { path = "hp.total", default = 0 },
    { path = "hp.broken", default = 0 },
    { path = "attack.mod", default = 0 },
    { path = "attack.full", default = 0 },
    { path = "pilot.total", default = 0 },
    { path = "defenses.eac.total", default = 0 },
    { path = "defenses.kac.total", default = 0 },
    { path = "defenses.hardness.total", default = 0 },
    { path = "collision.dc.total", default = 0 },
    { path = "modslots.total", default = 0 }
  }

  for _, entry in ipairs(tNumericFields) do
    local nValue = DB.getValue(nodeVehicle, entry.path, entry.default or 0)
    DB.setValue(nodeState, "base." .. entry.path, "number", nValue)
  end

  local tStringFields = {
    { path = "price", default = "0" },
    { path = "typegraft", default = "" },
    { path = "sizegraft", default = "" },
    { path = "origingraft", default = "" },
    { path = "specialgraft", default = "" },
    { path = "cover", default = "" }
  }

  for _, entry in ipairs(tStringFields) do
    local sValue = DB.getValue(nodeVehicle, entry.path, entry.default or "")
    DB.setValue(nodeState, "base." .. entry.path, "string", sValue)
  end

  DB.setValue(nodeState, "initialized", "number", 1)
end

function vehWizard.syncUIFromRecord(w)
  local nodeVehicle = w._vehicleNode
  if not nodeVehicle then
    return
  end

  local nodeState = getWizardState(w)
  local sStoredType = DB.getValue(nodeVehicle, "typegraft", "")
  local sTypeKey = resolveTypeKey(sStoredType)

  if (not sTypeKey or sTypeKey == "") and nodeState then
    local nodeWorking = getWorkingNode(nodeState)
    if nodeWorking then
      local nodeType = DB.getChild(nodeWorking, "type")
      if nodeType then
        sTypeKey = resolveTypeKey(DB.getValue(nodeType, "key", ""))
      end
    end
  end

  w._syncing = true
  w._suspendTypeUpdate = not (sTypeKey and TYPE_RULES[sTypeKey])

  if sTypeKey and w.StringCyclerVehType and TYPE_RULES[sTypeKey] then
    trySetCyclerValue(w.StringCyclerVehType, TYPE_RULES[sTypeKey].cycler)
  end

  local nLevel = DB.getValue(nodeVehicle, "level", 1)
  if w.nLevel then
    w.nLevel.setValue(nLevel)
  end

  applyLevelTables(w, nLevel)

  w._suspendTypeUpdate = nil

  if sTypeKey and TYPE_RULES[sTypeKey] then
    onTypeChanged(w, TYPE_RULES[sTypeKey].cycler)
  else
    clearTypeFields(w)
  end

  w._syncing = false
end

function onLevelChanged(w)
  if not w or not w.nLevel then
    return
  end

  local nLevel = clampLevel(w.nLevel.getValue())

  if w.nLevel.getValue() ~= nLevel then
    w._syncing = true
    w.nLevel.setValue(nLevel)
    w._syncing = false
  end

  applyLevelTables(w, nLevel)
  refreshTotals(w)

  local nodeState = getWizardState(w)
  persistWorkingBase(nodeState, nLevel)

  if w._syncing then
    return
  end

  local nodeVehicle = getVehicleNode(w)
  if not nodeVehicle then
    return
  end

  local nCurrent = DB.getValue(nodeVehicle, "level", 1)
  if nCurrent ~= nLevel then
    DB.setValue(nodeVehicle, "level", "number", nLevel)
    sf.DebugOut("Vehicle wizard set level to " .. tostring(nLevel) .. " for " .. nodeVehicle.getPath())
    vehWizard.resetStepsFrom(w, 1)
  end
end

function onTypeChanged(w, sValue)
  if not w then
    return
  end

  if w._suspendTypeUpdate then
    clearTypeFields(w)
    w._currentTypeKey = nil
    return
  end

  local sKey = resolveTypeKey(sValue)
  if not sKey then
    clearTypeFields(w)
    persistTypeSelection(getWizardState(w), nil, nil)
    updateVehicleTypeFields(getVehicleNode(w), nil)
    w._currentTypeKey = nil
    return
  end

  local rule = TYPE_RULES[sKey]
  if not rule then
    return
  end

  w._currentTypeKey = sKey

  local tData = rebuildTypeUI(w, rule)
  if not tData then
    return
  end

  local nodeState = getWizardState(w)
  local changed = persistTypeSelection(nodeState, sKey, tData)

  updateVehicleTypeFields(getVehicleNode(w), sKey)

  if not w._syncing and changed then
    vehWizard.resetStepsFrom(w, 2)
  end
end

-----------------------------------------------------------------------
-- Reset helpers (stubs for upcoming steps)
-----------------------------------------------------------------------

function vehWizard.resetStepsFrom(w, nStep)
  if not w then
    return
  end

  local nodeState = w._wizardState or vehWizard.ensureWizardState(w._vehicleNode)
  if not nodeState then
    return
  end

  DB.setValue(nodeState, "reset_from_step", "number", nStep or 1)
  sf.DebugOut("Vehicle wizard queued reset from step " .. tostring(nStep or 1))
end

function vehWizard.resetAll(w)
  vehWizard.resetStepsFrom(w, 1)
end

return vehWizard

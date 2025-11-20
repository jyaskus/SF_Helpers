--
-- veh_parts.lua
-- Shared helpers for creating vehicle part subrecords that mirror
-- the Fantasy Grounds SFRPG vehicle structure.
--

vehParts = vehParts or {}

local PART_IDS = {
  type = "id-00001",
  size = "id-00002",
  special1 = "id-00003",
  special2 = "id-00004",
  origin = "id-00005"
}

vehParts.PART_IDS = PART_IDS

local TYPE_PART_DATA = {
  boat = {
    name = "Boat (water vehicle)",
    cover = "Partial cover",
    modifiers = "+0 Piloting, –2 attack (–4 at full speed)",
    passengers = 2,
    speed = "speed × 15"
  },
  submersible = {
    name = "Submersible (water vehicle)",
    cover = "Total cover",
    modifiers = "–1 Piloting, –3 attack (–5 at full speed)",
    passengers = 2,
    speed = "speed × 10"
  },
  cruiser = {
    name = "Cruiser (Land Vehicle)",
    cover = "Improved cover",
    modifiers = "+0 Piloting, –2 attack (–4 at full speed)",
    passengers = 3,
    speed = "(Full): speed × 25"
  },
  cycle = {
    name = "Cycle (Land Vehicle)",
    cover = "None",
    modifiers = "+1 Piloting, –1 attack (–3 at full speed)",
    passengers = 1,
    speed = "speed × 15"
  },
  tank = {
    name = "Tank (Land Vehicle)",
    cover = "Total cover",
    modifiers = "–2 Piloting, –4 attack (–6 at full speed)",
    passengers = 3,
    speed = "speed × 15"
  },
  truck = {
    name = "Truck (Land Vehicle)",
    cover = "Cover",
    modifiers = "–1 Piloting, –3 attack (–5 at full speed)",
    passengers = 3,
    speed = "speed × 20"
  },
  walker = {
    name = "Walker (Land Vehicle)",
    cover = "Improved cover",
    modifiers = "–1 Piloting, –3 attack (–5 at full speed)",
    passengers = 2,
    speed = "speed × 15"
  },
  ["fast flyer"] = {
    name = "Fast Flyer (Air Vehicle)",
    cover = "Cover",
    modifiers = "+1 Piloting, –1 attack (–3 at full speed)",
    passengers = 2,
    speed = "speed × 40"
  },
  ["hovering flyer"] = {
    name = "Hovering Flyer (Air Vehicle)",
    cover = "Improved cover",
    modifiers = "+0 Piloting, –2 attack (–4 at full speed)",
    passengers = 3,
    speed = "speed × 20"
  }
}

local DEFAULT_TYPE_KEY = "cruiser"

local function asString(value)
  if value == nil then
    return ""
  end
  if type(value) == "string" then
    return value
  end
  return tostring(value)
end

local function normalizeTypeKey(value)
  local sValue = asString(value)
  if sValue == "" then
    return DEFAULT_TYPE_KEY
  end
  local lowered = sValue:lower()
  if TYPE_PART_DATA[lowered] then
    return lowered
  end
  return DEFAULT_TYPE_KEY
end

local function getNodePath(node)
  if not node then
    return ""
  end

  local status, sPath = pcall(DB.getPath, node)
  if status and sPath and sPath ~= "" then
    return sPath
  end

  if node.getPath then
    local ok, legacyPath = pcall(node.getPath, node)
    if ok and legacyPath and legacyPath ~= "" then
      return legacyPath
    end
  end

  return ""
end

local function ensurePartsNode(nodeVehicle)
  if not nodeVehicle then
    return nil
  end

  local nodeParts = DB.getChild(nodeVehicle, "parts")
  if not nodeParts then
    nodeParts = DB.createChild(nodeVehicle, "parts")
  end
  return nodeParts
end

local function setDescription(partNode, sText)
  if not partNode then
    return
  end

  local nodeDescription = DB.getChild(partNode, "description")
  if not sText or sText == "" then
    if nodeDescription then
      DB.deleteNode(nodeDescription)
    end
    return
  end

  nodeDescription = nodeDescription or DB.createChild(partNode, "description", "formattedtext")
  if nodeDescription then
    DB.setValue(nodeDescription, "", "formattedtext", "<p>" .. sText .. "</p>")
  end
end

local function setStandardItemFields(partNode)
  if not partNode then
    return
  end

  DB.setValue(partNode, "ac", "number", 10)
  DB.setValue(partNode, "acpenalty", "number", 0)
  DB.setValue(partNode, "hardness", "number", 0)
  DB.setValue(partNode, "hp", "number", 0)
  DB.setValue(partNode, "abilityscore", "number", 0)
  DB.setValue(partNode, "strength_enc", "number", 0)
end

function vehParts.getPartLink(nodeVehicle, partId)
  if not nodeVehicle or not partId or partId == "" then
    return ""
  end

  local nodeParts = DB.getChild(nodeVehicle, "parts")
  if nodeParts then
    local nodePart = DB.getChild(nodeParts, partId)
    if nodePart then
      local sExistingPath = getNodePath(nodePart)
      if sExistingPath ~= "" then
        return sExistingPath
      end
    end
  end

  local sVehiclePath = getNodePath(nodeVehicle)
  if sVehiclePath == "" then
    return ""
  end

  return sVehiclePath .. ".parts." .. partId
end

local function normalizeKey(value, defaultValue)
  local sValue = lowerString(value)
  if sValue == "" then
    return defaultValue
  end
  return sValue
end

function vehParts.ensureTypePart(nodeVehicle, sTypeKey)
  if not nodeVehicle then
    return nil
  end

  local nodeParts = ensurePartsNode(nodeVehicle)
  if not nodeParts then
    return nil
  end

  local partNode = DB.getChild(nodeParts, PART_IDS.type)
  if not partNode then
    partNode = DB.createChild(nodeParts, PART_IDS.type)
  end
  if not partNode then
    return nil
  end

  local key = normalizeTypeKey(sTypeKey)
  local template = TYPE_PART_DATA[key] or TYPE_PART_DATA[DEFAULT_TYPE_KEY]

  DB.setValue(partNode, "name", "string", template.name or asString(sTypeKey))
  DB.setValue(partNode, "subtype", "string", "Type Graft")
  DB.setValue(partNode, "type", "string", "Vehicle")
  DB.setValue(partNode, "locked", "number", 1)
  DB.setValue(partNode, "level", "number", 0)
  DB.setValue(partNode, "magicitem", "number", 0)

  DB.setValue(partNode, "cover", "string", template.cover or "")
  DB.setValue(partNode, "modifiers", "string", template.modifiers or "")
  DB.setValue(partNode, "passengers", "number", template.passengers or 0)
  DB.setValue(partNode, "speed", "string", template.speed or "")

  if VehicleGraftData and VehicleGraftData.getTypeGraftData then
    local graftData = VehicleGraftData.getTypeGraftData(key)
    if graftData then
      setDescription(partNode, graftData.description)
    end
  end
  setStandardItemFields(partNode)

  local sPartPath = getNodePath(partNode)
  if sPartPath ~= "" then
    DB.setValue(partNode, "link", "windowreference", "item", sPartPath)
  else
    DB.setValue(partNode, "link", "windowreference", "item", "..parts." .. PART_IDS.type)
  end

  return partNode, sPartPath
end

local function applySimplePart(partNode, sName, sSubtype, sDescription)
  if not partNode then
    return
  end

  DB.setValue(partNode, "name", "string", sName or "")
  DB.setValue(partNode, "subtype", "string", sSubtype or "")
  DB.setValue(partNode, "type", "string", "Vehicle")
  DB.setValue(partNode, "locked", "number", 1)
  DB.setValue(partNode, "level", "number", 0)
  DB.setValue(partNode, "magicitem", "number", 0)
  setDescription(partNode, sDescription)
  setStandardItemFields(partNode)
end

local function ensurePartNode(nodeVehicle, partKey)
  local nodeParts = ensurePartsNode(nodeVehicle)
  if not nodeParts then
    return nil
  end

  local partId = PART_IDS[partKey] or partKey
  if not partId then
    return nil
  end

  local nodePart = DB.getChild(nodeParts, partId)
  if not nodePart then
    nodePart = DB.createChild(nodeParts, partId)
  end
  return nodePart, partId
end

local function finalizePartLink(nodeVehicle, nodePart, partId)
  if not nodePart then
    return ""
  end

  local sPartPath = getNodePath(nodePart)
  if sPartPath ~= "" then
    DB.setValue(nodePart, "link", "windowreference", "item", sPartPath)
    return sPartPath
  end

  local fallbackId = partId or nodePart.getName()
  if fallbackId and fallbackId ~= "" then
    local sVehiclePath = getNodePath(nodeVehicle)
    if sVehiclePath ~= "" then
      sPartPath = sVehiclePath .. ".parts." .. fallbackId
      DB.setValue(nodePart, "link", "windowreference", "item", sPartPath)
    else
      DB.setValue(nodePart, "link", "windowreference", "item", "..parts." .. fallbackId)
    end
  end

  return sPartPath
end

function vehParts.ensureSizePart(nodeVehicle, sSizeKey)
  if not nodeVehicle then
    return nil
  end

  local nodePart, partId = ensurePartNode(nodeVehicle, "size")
  if not nodePart then
    return nil
  end

  local key = normalizeKey(sSizeKey, "large")
  local graftData = VehicleGraftData and VehicleGraftData.getSizeGraftData and VehicleGraftData.getSizeGraftData(key) or nil
  local sName = (graftData and graftData.name) or sSizeKey or "Size"

  applySimplePart(nodePart, sName, "Size Graft", graftData and graftData.description)

  if graftData and graftData.adjustments and graftData.adjustments ~= "" then
    DB.setValue(nodePart, "adjustments", "string", graftData.adjustments)
  else
    DB.deleteChild(nodePart, "adjustments")
  end

  local sPartPath = finalizePartLink(nodeVehicle, nodePart, partId)
  return nodePart, sPartPath
end

function vehParts.ensureOriginPart(nodeVehicle, sOriginKey)
  if not nodeVehicle then
    return nil
  end

  local nodePart, partId = ensurePartNode(nodeVehicle, "origin")
  if not nodePart then
    return nil
  end

  local key = normalizeKey(sOriginKey, "factory-made")
  local graftData = VehicleGraftData and VehicleGraftData.getOriginGraftData and VehicleGraftData.getOriginGraftData(key) or nil
  local sName = (graftData and graftData.name) or sOriginKey or "Origin"

  applySimplePart(nodePart, sName, "Origin Graft", graftData and graftData.description)

  if graftData and graftData.adjustments and graftData.adjustments ~= "" then
    DB.setValue(nodePart, "adjustments", "string", graftData.adjustments)
  else
    DB.deleteChild(nodePart, "adjustments")
  end

  local sPartPath = finalizePartLink(nodeVehicle, nodePart, partId)
  return nodePart, sPartPath
end

local function getSpecialPartId(slot)
  if slot == 2 then
    return PART_IDS.special2
  end
  return PART_IDS.special1
end

function vehParts.ensureSpecialPart(nodeVehicle, slot, sSpecialKey)
  if not nodeVehicle then
    return nil
  end

  local partId = getSpecialPartId(slot)
  if not partId then
    return nil
  end

  local nodePart = ensurePartNode(nodeVehicle, partId)
  if not nodePart then
    return nil
  end

  local key = normalizeKey(sSpecialKey, "racer")
  local graftData = VehicleGraftData and VehicleGraftData.getSpecialGraftData and VehicleGraftData.getSpecialGraftData(key) or nil
  local sName = (graftData and graftData.name) or sSpecialKey or "Special"

  applySimplePart(nodePart, sName, "Special Graft", graftData and graftData.description)

  if graftData and graftData.adjustments and graftData.adjustments ~= "" then
    DB.setValue(nodePart, "adjustments", "string", graftData.adjustments)
  else
    DB.deleteChild(nodePart, "adjustments")
  end

  if graftData and graftData.special and graftData.special ~= "" then
    DB.setValue(nodePart, "special", "string", graftData.special)
  else
    DB.deleteChild(nodePart, "special")
  end

  local sPartPath = finalizePartLink(nodeVehicle, nodePart, partId)
  return nodePart, sPartPath
end

function vehParts.clearPart(nodeVehicle, partKey)
  if not nodeVehicle or not partKey then
    return
  end

  local partId = PART_IDS[partKey] or partKey
  if not partId then
    return
  end

  local nodeParts = DB.getChild(nodeVehicle, "parts")
  if not nodeParts then
    return
  end

  DB.deleteChild(nodeParts, partId)
end

return vehParts

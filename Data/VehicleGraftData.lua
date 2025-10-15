--
-- Vehicle Graft Reference Data
-- Contains all vehicle graft information and FGU reference links
--

-- Type Grafts with their actual FGU recordnames
local typeGrafts = {
  ["boat"] = {
    name = "Boat (water vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.boat"
  },
  ["submersible"] = {
    name = "Submersible (water vehicle)", 
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.submersible"
  },
  ["cruiser"] = {
    name = "Cruiser (Land Vehicle)",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.cruiser"
  },
  ["cycle"] = {
    name = "Cycle (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.cycle"
  },
  ["tank"] = {
    name = "Tank (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.tank"
  },
  ["truck"] = {
    name = "Truck (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.truck"
  },
  ["walker"] = {
    name = "Walker (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.walker"
  },
  ["fast flyer"] = {
    name = "Fast Flyer (Air Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.fastflyer"
  },
  ["hovering flyer"] = {
    name = "Hovering Flyer (Air Vehicle)",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.hoveringflyer"
  }
}

-- Size Grafts with their actual FGU recordnames
local sizeGrafts = {
  ["medium"] = {
    name = "Medium",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.medium"
  },
  ["large"] = {
    name = "Large", 
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.large"
  },
  ["huge"] = {
    name = "Huge",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.huge"
  },
  ["gargantuan"] = {
    name = "Gargantuan",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.gargantuan"
  },
  ["colossal"] = {
    name = "Colossal",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.colossal"
  }
}

-- Special Grafts with their actual FGU recordnames
local specialGrafts = {
  ["all-terrain"] = {
    name = "All-terrain",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.allterrain"
  },
  ["amphibious"] = {
    name = "Amphibious",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.amphibious"
  },
  ["armored"] = {
    name = "Armored",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.armored"
  },
  ["computer-assisted"] = {
    name = "Computer-assisted",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.computerassisted"
  },
  ["hover"] = {
    name = "Hover",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.hover"
  },
  ["hybrid aircraft"] = {
    name = "Hybrid aircraft",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.hybridaircraft"
  },
  ["junk"] = {
    name = "Junk",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.junk"
  },
  ["luxury"] = {
    name = "Luxury",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.luxury"
  },
  ["racer"] = {
    name = "Racer",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.racer"
  },
  ["transport"] = {
    name = "Transport",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.transport"
  }
}

-- Origin Grafts with their actual FGU recordnames
local originGrafts = {
  ["experimental"] = {
    name = "Experimental",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.experimental"
  },
  ["factory-made"] = {
    name = "Factory-made",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.factorymade"
  },
  ["prototype"] = {
    name = "Prototype",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.prototype"
  }
}

-- Public accessor functions for type grafts
function getTypeGraftData(sVehType)
  local sKey = string.lower(sVehType);
  return typeGrafts[sKey];
end

function getTypeGraftReference(sVehType)
  local graftData = getTypeGraftData(sVehType);
  if graftData then
    return graftData.class, graftData.recordname;
  end
  return "reference_vehicle_part", "reference.vehicle_parts.cruiser";  -- Default fallback
end

-- Public accessor functions for size grafts
function getSizeGraftData(sSize)
  local sKey = string.lower(sSize);
  return sizeGrafts[sKey];
end

function getSizeGraftReference(sSize)
  local graftData = getSizeGraftData(sSize);
  if graftData then
    return graftData.class, graftData.recordname;
  end
  return "reference_vehicle_part", "reference.vehicle_parts.large";  -- Default fallback
end

-- Public accessor functions for special grafts  
function getSpecialGraftData(sSpecial)
  local sKey = string.lower(sSpecial);
  return specialGrafts[sKey];
end

function getSpecialGraftReference(sSpecial)
  local graftData = getSpecialGraftData(sSpecial);
  if graftData then
    return graftData.class, graftData.recordname;
  end
  return nil, nil;  -- No fallback for special grafts
end

-- Public accessor functions for origin grafts
function getOriginGraftData(sOrigin)
  local sKey = string.lower(sOrigin);
  return originGrafts[sKey];
end

function getOriginGraftReference(sOrigin)
  local graftData = getOriginGraftData(sOrigin);
  if graftData then
    return graftData.class, graftData.recordname;
  end
  return nil, nil;  -- No fallback for origin grafts
end

-- Debug function to list all available grafts
function listAllGrafts()
  Debug.console("=== Vehicle Graft Reference Data ===");
  Debug.console("Type Grafts:");
  for k, v in pairs(typeGrafts) do
    Debug.console("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  Debug.console("Size Grafts:");
  for k, v in pairs(sizeGrafts) do
    Debug.console("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  Debug.console("Special Grafts:");
  for k, v in pairs(specialGrafts) do
    Debug.console("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  Debug.console("Origin Grafts:");
  for k, v in pairs(originGrafts) do
    Debug.console("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
end
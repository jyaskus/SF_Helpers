--
-- Vehicle Graft Reference Data
-- Contains all vehicle graft information and FGU reference links
--

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

-- Type Grafts with their actual FGU recordnames
local typeGrafts = {
  ["boat"] = {
    name = "Boat (water vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.boat",
    description = "Boats move through calm water with ease, but struggle against currents and waves."
  },
  ["submersible"] = {
    name = "Submersible (water vehicle)", 
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.submersible",
    description = "These vehicles can submerge completely in a liquid (usually water) for extended periods, providing access to strange new realms for nonaquatic creatures."
  },
  ["cruiser"] = {
    name = "Cruiser (Land Vehicle)",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.cruiser",
    description = "Cruisers are the most common vehicles, designed for long-distance travel and passenger comfort on paved roads and highways."
  },
  ["cycle"] = {
    name = "Cycle (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.cycle",
    description = "These fast, maneuverable open-air ground vehicles are suitable for one or two Medium creatures and can move through tight spaces."
  },
  ["tank"] = {
    name = "Tank (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.tank",
    description = "These heavily armored military ground vehicles provide maximum protection for passengers and crew at the cost of speed and maneuverability."
  },
  ["truck"] = {
    name = "Truck (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.truck",
    description = "These rugged ground vehicles transport passengers or cargo."
  },
  ["walker"] = {
    name = "Walker (Land Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.walker",
    description = "These relatively slow vehicles use numerous legs to stride over challenging terrain with ease."
  },
  ["fast flyer"] = {
    name = "Fast Flyer (Air Vehicle)",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.fastflyer",
    description = "These sleek aircraft sacrifice protection for incredible speed, perfect for racing or rapid transit through open skies."
  },
  ["hovering flyer"] = {
    name = "Hovering Flyer (Air Vehicle)",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.hoveringflyer",
    description = "These slower air vehicles provide maximum maneuverability and are often propelled by large rotors or hover pads"
  }
}

-- Size Grafts with their actual FGU recordnames
local sizeGrafts = {
  ["medium"] = {
    name = "Medium",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.medium",
    description = "Medium vehicles are compact and maneuverable, suitable for small groups or individual travelers.",
    adjustments = "decrease collision damage by 1 die, increase collision DC by 1. If the piloting modifier is negative, increase it by 1 (to a minimum of +0)."
  },
  ["large"] = {
    name = "Large", 
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.large",
    description = "Large vehicles provide increased passenger capacity and cargo space while maintaining reasonable maneuverability.",
    adjustments = "none"
  },
  ["huge"] = {
    name = "Huge",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.huge",
    description = "Huge vehicles excel at moving sizable cargo and ferrying passengers",
    adjustments = "Increase price by 10%, increase collision damage by 1 die, decrease collision DC by 1, decrease Piloting and attack modifiers by 1, increase passenger limit by 100%"
  },
  ["gargantuan"] = {
    name = "Gargantuan",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.gargantuan",
    description = "Gargantuan vehicles are massive transports capable of carrying large groups and substantial cargo loads.",
    adjustments = "increase price by 10%, increase HP by 10%, increase collision dice by 2 dice, decrease collision DC by 2, decrease Piloting and attack modifiers by 1, increase passenger limit by 200%"
  },
  ["colossal"] = {
    name = "Colossal",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.colossal",
    description = "Colossal vehicles are the largest civilian transports, serving as mobile bases or massive cargo haulers.",
    adjustments = "increase price by 120%, increase HP by 20%, increase collision dice damage by 3 dice, decrease collision DC by 3, decrease Piloting and attack modifiers by 2, increase passenger limit by 400%"
  }
}

-- Special Grafts with their actual FGU recordnames
local specialGrafts = {
  ["all-terrain"] = {
    name = "All-terrain",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.allterrain",
    description = "Designed for off-road travel, these rugged vehicles withstand rough terrain, weather and abuse like no other.",
    adjustments = "Increase price by 5%, decrease speed by 5 feet, decrease full speed by 25 feet, decrease attack modifiers by 1. When moving through difficult terrain, the vehicle treat every other space of difficult terrain as a space of normal terrain. (3/4 move rather than 1/2).",
    special = ""
  },
  ["amphibious"] = {
    name = "Amphibious",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.amphibious",
    description = "These vehicles can operate both on land and in water, seamlessly transitioning between environments.",
    adjustments = "Increase price by 10%. Vehicle becomes a land and water vehicle, gaining either a ground speed equal to its swim speed or vice versa.",
    special = "The vehicle must have a type graft that provides either a land speed or a swim speed."
  },
  ["armored"] = {
    name = "Armored",
    class = "reference_vehicle_part", 
    recordname = "reference.vehicle_parts.armored",
    description = "These robust vehicles are fitted with armored plates or shielding systems that allow them to withstand punishing conditions.",
    adjustments = "Increase price by 20%, decrease speed by 10 feet, increase EAC and KAC by 2, increase Hit Points by 10%, increase hardness by 10%, increase cover by 1 step (partial cover becomes cover, cover becomes improved cover, etc.)",
    special = "The vehicle can not have the tank type graft."
  },
  ["computer-assisted"] = {
    name = "Computer-assisted",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.computerassisted",
    description = "The vehicle is equipped with a limited virtual intelligence that can control the vehicle for short periods of time. It gains an autopilot with a Piloting skill equal to 4 + (1.5 * vehicle level)",
    special = ""
  },
  ["hover"] = {
    name = "Hover",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.hover",
    description = "The vehicles movement is based on hover technology achieving lift through powerful jets or antigravity fields. They are relatively fragile, due to the lower overall mass required to function properly.",
    adjustments = "Increase price by 10%, increase speed by 5 feet, decrease EAC and KAC by 1, decrease HP by 20%. The vehicle becomes a land and water vehicle and gains a hover speed equal to its land speed, ignoring difficult terrain.",
    special = "The vehicle must have the boat type graft or any type graft that grants a land speed."
  },
  ["hybrid aircraft"] = {
    name = "Hybrid aircraft",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.hybridaircraft",
    description = "These vehicles operate just as effectively on land as they do in the air, whether they use extendable wings or jet propulsion.",
    adjustments = "Increase price by 15%, increase speed by 10 feet, decrease EAC and KAC by 1, decrease HP by 10%. The vehicle gains both a fly speed and land speed.",
    special = "The vehicle must have a land speed or fly speed to apply this special graft."
  },
  ["junk"] = {
    name = "Junk",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.junk",
    description = "<b>Systems</b>: The vehicle gains the Unstable Engine system.<p><b>Unstable Engine:</b> Once the vehicle becomes broken, its engine explodes in 1d4 rounds (even if it's been wrecked), dealing 1d6 fire damage in a 10-foot burst around the vehicle; this damage increases to 3d6 for anyone riding the vehicle. At 3rd level and every odd level thereafter, the burst deals an additional 1d6 damage (or an additional 2d6 damage to riders). Creatures can take half damage with a successful Reflex save (DC = the vehicle's collision DC).</p>",
    adjustments = "Decrease price by 20%, decrease full speed by 50 feet, decrease Piloting modifier by 3, decrease attack modifiers by 1. The vehicle gains the broken condition when reduced to 75% of its Hit Points instead of 50%.",
    special = "If you have access to inert electronic and mechanical junk, this graft instead reduces vehicle price by 50%. This requires at least 10 bulk of junk for a Medium vehicle. For each size category larger than Medium, multiply the junk required by 8."
  },
  ["luxury"] = {
    name = "Luxury",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.luxury",
    description = "These vehicles are built for comfort and boast amenities like fully adjustable heated seats, chilled beverage holders, and premium sound systems. The vehicle gains a planetary comm unit and an autocontrol with a Piloting bonus of 4 + (1.5 * vehicle level)",
    adjustments = "increase price by 20%, increase attack modifiers by 1. (maximum +0)",
    special = ""
  },
  ["racer"] = {
    name = "Racer",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.racer",
    description = "Designed entirely for speed, these vehicles are designed for a single pilot for the purposes of racing or high velocity transportation, they also make excellent stunt fighters.",
    adjustments = "Increase speed by 5 feet, decrease Hit Points by 10%, decrease hardness by 20%, decrease passengers by 50%. After recalculating speed, increase full speed by 25%.",
    special = ""
  },
  ["transport"] = {
    name = "Transport",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.transport",
    description = "These vehicles tend to be large and ponderous, but are capable of high speeds over long distances.",
    adjustments = "Increase price by 10%, decrease Piloting modifier by 1, increase passengers by 100%.",
    special = ""
  }
}

-- Origin Grafts with their actual FGU recordnames
local originGrafts = {
  ["experimental"] = {
    name = "Experimental",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.experimental",
    description = "Created by mechanical artisans, these one-of-a-kind vehicles are an expression of their creators' vision.",
    adjustments = "Decrease price by 50%, increase modification slots by 1.",
    special = "The vehicle must have been created by someone with the Experimental vehicle alternate class feature."
  },
  ["factory-made"] = {
    name = "Factory-made",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.factorymade",
    description = "Mass-produced in assembly lines, these vehicles are reliable, well-tested, and easy to repair with standardized parts. When in a settlement or area with replacement parts, decrease repair costs by 10% and repair time by 25%.",
    adjustments = "Decrease cost by 10%, decrease modification slots by 1, decrease repair costs by 10% and repair time by 25%.",
    special = ""
  },
  ["prototype"] = {
    name = "Prototype",
    class = "reference_vehicle_part",
    recordname = "reference.vehicle_parts.prototype",
    description = "Cutting-edge test vehicles incorporating experimental technologies and unproven designs. Increase repair time and costs by 20%.",
    adjustments = "Increase price by 10%, increase modification slots by 1.",
    special = ""
  }
}

-- Public accessor functions for type grafts
function getTypeGraftData(sVehType)
  local sKey = lowerString(sVehType);
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
  local sKey = lowerString(sSize);
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
  local sKey = lowerString(sSpecial);
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
  local sKey = lowerString(sOrigin);
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
  sf.DebugOut("=== Vehicle Graft Reference Data ===");
  sf.DebugOut("Type Grafts:");
  for k, v in pairs(typeGrafts) do
    sf.DebugOut("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  sf.DebugOut("Size Grafts:");
  for k, v in pairs(sizeGrafts) do
    sf.DebugOut("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  sf.DebugOut("Special Grafts:");
  for k, v in pairs(specialGrafts) do
    sf.DebugOut("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
  sf.DebugOut("Origin Grafts:");
  for k, v in pairs(originGrafts) do
    sf.DebugOut("  " .. k .. " -> " .. v.name .. " (" .. v.recordname .. ")");
  end
end
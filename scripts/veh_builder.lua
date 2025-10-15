--
-- Vehicle Builder - Functions for creating vehicle records
--

function vehBuilder_createVehicleRecord(charNode, w)
  -- Validate inputs
  if not charNode then
    Debug.console("ERROR: No character DB node provided");
    return;
  end

  if not w then
    Debug.console("ERROR: No window reference provided");
    return;
  end

  Debug.console("Creating vehicle for character: " .. charNode.getPath());

  -- Load vehicle graft reference data
  local reference = loadVehicleGraftReference();
  if not reference then
    Debug.console("ERROR: Could not load vehicle graft reference data");
    return;
  end

  -- Get vehicle properties from the builder
  local nLevel = w.nLevel.getValue() or 1;
  local sVehType = w.StringCyclerVehType.getStringValue() or "cruiser";
  local sSize = w.StringCyclerVehSize.getStringValue() or "large";
  local sOrigin = w.StringCyclerVehOrigin.getStringValue() or "";
  local sSpecial1 = w.StringCyclerVehSpecial1.getStringValue() or "none";
  local sSpecial2 = w.StringCyclerVehSpecial2.getStringValue() or "none";

  -- Debug output for origin
  Debug.console("Vehicle Origin Value: '" .. tostring(sOrigin) .. "'");
  Debug.console("Origin empty check: " .. tostring(sOrigin == ""));
  Debug.console("Origin none check: " .. tostring(sOrigin == "none"));
  Debug.console("Origin standard check: " .. tostring(sOrigin == "standard"));
  Debug.console("Will create origin graft: " .. tostring(sOrigin ~= "" and sOrigin ~= "none" and sOrigin ~= "standard"));

  -- Get total stats
  local nTotalPrice = w.nTotalPrice.getValue() or 0;
  local nTotalSpeed = w.nTotalSpeed.getValue() or 0;
  local nTotalFullSpeed = w.nTotalFullSpeedMult.getValue() or 0;
  local nTotalOverlandSpeed = w.nTotalOverlandSpeed.getValue() or 0;
  local nTotalPiloting = w.nTotalPilotingMod.getValue() or 0;
  local nTotalAttack = w.nTotalAttackMod.getValue() or 0;
  local nTotalAttackFull = w.nTotalAttackFullMod.getValue() or 0;
  local nTotalEAC = w.nTotalEAC.getValue() or 0;
  local nTotalKAC = w.nTotalKAC.getValue() or 0;
  local nTotalHardness = w.nTotalHardness.getValue() or 0;
  local nTotalHP = w.nTotalHP.getValue() or 0;
  local nBrokenHP = w.nBrokenHP.getValue() or 0;
  local nTotalPassengers = w.nTotalPassengers.getValue() or 0;
  local nTotalDiceCount = w.nTotalDiceCount.getValue() or 0;
  local nTotalDiceSize = w.nTotalDiceSize.getValue() or 0;
  local nTotalCollisionDC = w.nTotalCollisionDC.getValue() or 0;
  local nTotalModSlots = w.nTotalModSlots.getValue() or 0;
  local sTotalVehCover = w.sTotalVehCover.getValue() or "total";

  -- Generate vehicle name
  local sUserVehName = w.sVehName.getValue() or "";
  local sVehicleName;
  
  if sUserVehName ~= "" then
    -- Use user-provided vehicle name
    sVehicleName = sUserVehName;
  else
    -- Fall back to default auto-generated pattern
    local sCharName = DB.getValue(charNode, "name", "Character");
    sVehicleName = "(" .. sCharName .. ") " .. sVehType:gsub("^%l", string.upper);
  end

  -- Calculate movement type based on vehicle type
  local sMovementType = getMovementType(sVehType);

  -- Build vehicle description with special abilities
  local sDescription = buildVehicleDescription(sVehType, sSize, sOrigin, sSpecial1, sSpecial2, w);

  -- Create the vehicles node if it doesn't exist
  local vehiclesNode = DB.createChild(charNode, "vehicles");
  if not vehiclesNode then
    Debug.console("ERROR: Could not create vehicles node");
    return;
  end

  -- Create a new vehicle entry
  local newVehicle = DB.createChild(vehiclesNode);
  if not newVehicle then
    Debug.console("ERROR: Could not create new vehicle entry");
    return;
  end

  -- Set basic properties
  DB.setValue(newVehicle, "name", "string", sVehicleName);
  DB.setValue(newVehicle, "level", "number", nLevel);
  DB.setValue(newVehicle, "converted", "number", 1);
  DB.setValue(newVehicle, "locked", "number", 0);
  DB.setValue(newVehicle, "price", "string", tostring(nTotalPrice));
  -- Set sizegraft to just the capitalized size name (not the full descriptive string)
  DB.setValue(newVehicle, "sizegraft", "string", sSize:gsub("^%l", string.upper));
  DB.setValue(newVehicle, "cover", "string", sTotalVehCover);
  DB.setValue(newVehicle, "passengers", "number", nTotalPassengers);
  DB.setValue(newVehicle, "space", "number", 0);

  -- Set attack values
  DB.setValue(newVehicle, "attack.mod", "number", nTotalAttack);
  DB.setValue(newVehicle, "attack.full", "number", nTotalAttackFull);

  -- Set pilot values
  DB.setValue(newVehicle, "pilot.total", "number", nTotalPiloting);

  -- Set defenses
  DB.setValue(newVehicle, "defenses.eac.total", "number", nTotalEAC);
  DB.setValue(newVehicle, "defenses.kac.total", "number", nTotalKAC);
  DB.setValue(newVehicle, "defenses.hardness.total", "number", nTotalHardness);

  -- Set HP values
  DB.setValue(newVehicle, "hp.total", "number", nTotalHP);
  DB.setValue(newVehicle, "hp.broken", "number", nBrokenHP);
  DB.setValue(newVehicle, "hp.base", "number", 0);
  DB.setValue(newVehicle, "hp.wounds", "number", 0);

  -- Set collision damage
  local sCollisionDmg = tostring(nTotalDiceCount) .. "d" .. tostring(nTotalDiceSize) .. " b";
  DB.setValue(newVehicle, "collision.damage.total", "string", sCollisionDmg);
  DB.setValue(newVehicle, "collision.dc.total", "number", nTotalCollisionDC);

  -- Set mod slots
  DB.setValue(newVehicle, "modslots.total", "number", nTotalModSlots);

  -- Create movement entries based on vehicle type and special abilities
  createMovementEntries(newVehicle, sVehType, sSpecial1, sSpecial2, nTotalSpeed, nTotalFullSpeed, nTotalOverlandSpeed);

  -- Create special abilities node and add description
  local specialAbilitiesNode = DB.createChild(newVehicle, "specialabilities");
  if sDescription and sDescription ~= "" then
    local specialAbility = DB.createChild(specialAbilitiesNode);
    DB.setValue(specialAbility, "name", "string", "Vehicle Features");
    DB.setValue(specialAbility, "text", "string", sDescription);
    DB.setValue(specialAbility, "locked", "number", 1);
    
    -- Create empty shortcut
    local shortcutNode = DB.createChild(specialAbility, "shortcut", "windowreference");
    DB.setValue(shortcutNode, "class", "string", "npc_specialability");
    DB.setValue(shortcutNode, "recordname", "string", "");
  end

  -- Create parts node and add grafts in specific order with hardcoded IDs
  local partsNode = DB.createChild(newVehicle, "parts");
  
  -- Create Type Graft entry (always id-00001)
  local typeGraftPart = DB.createChild(partsNode, "id-00001");
  createTypeGraftPart(typeGraftPart, sVehType);
  
  -- Create Size Graft entry (always id-00002)  
  local sizeGraftPart = DB.createChild(partsNode, "id-00002");
  createSizeGraftPart(sizeGraftPart, sSize);
  
  -- Create Special Graft entries with hardcoded IDs
  -- Special Graft 1 (id-00003 if exists)
  if sSpecial1 ~= "none" then
    local specialGraftPart1 = DB.createChild(partsNode, "id-00003");
    createSpecialGraftPart(specialGraftPart1, sSpecial1, w);
  end
  
  -- Special Graft 2 (id-00004 if exists)
  if sSpecial2 ~= "none" then
    local specialGraftPart2 = DB.createChild(partsNode, "id-00004");
    createSpecialGraftPart(specialGraftPart2, sSpecial2, w);
  end
  
  -- Origin Graft (always id-00005 if exists)
  if sOrigin ~= "" and sOrigin ~= "none" and sOrigin ~= "standard" then
    local originGraftPart = DB.createChild(partsNode, "id-00005");
    createOriginGraftPart(originGraftPart, sOrigin, reference);
  end
  
  DB.createChild(newVehicle, "ppabilities");

  -- Set size string (in addition to sizegraft)
  DB.setValue(newVehicle, "size", "string", sSize:gsub("^%l", string.upper));
  
  -- Set typegraft string and link (always links to id-00001)
  local sTypeGraftName = getTypeGraftName(sVehType);
  DB.setValue(newVehicle, "typegraft", "string", sTypeGraftName);
  local typegraftlink = DB.createChild(newVehicle, "typegraftlink", "windowreference");
  DB.setValue(typegraftlink, "class", "string", "item");
  -- Use hardcoded relative path to type graft (always id-00001)
  local typeGraftRelPath = "....vehicles." .. newVehicle.getName() .. ".parts.id-00001";
  DB.setValue(typegraftlink, "recordname", "string", typeGraftRelPath);
  
  -- Set sizegraft link (always links to id-00002)
  local sizegraftlink = DB.createChild(newVehicle, "sizegraftlink", "windowreference");
  DB.setValue(sizegraftlink, "class", "string", "item");
  -- Use hardcoded relative path to size graft (always id-00002)
  local sizeGraftRelPath = "....vehicles." .. newVehicle.getName() .. ".parts.id-00002";
  DB.setValue(sizegraftlink, "recordname", "string", sizeGraftRelPath);
  
  -- Set specialgraft string and links if applicable
  if sSpecial1 ~= "none" then
    DB.setValue(newVehicle, "specialgraft", "string", sSpecial1:gsub("^%l", string.upper));
    local specialgraftlink = DB.createChild(newVehicle, "specialgraftlink", "windowreference");
    DB.setValue(specialgraftlink, "class", "string", "item");
    -- Use hardcoded relative path to first special graft (always id-00003)
    local specialGraftRelPath = "....vehicles." .. newVehicle.getName() .. ".parts.id-00003";
    DB.setValue(specialgraftlink, "recordname", "string", specialGraftRelPath);
  else
    local specialgraftlink = DB.createChild(newVehicle, "specialgraftlink", "windowreference");
    DB.setValue(specialgraftlink, "class", "string", "");
    DB.setValue(specialgraftlink, "recordname", "string", "");
  end

  -- Set origin graft link if applicable
  if sOrigin ~= "none" and sOrigin ~= "standard" and sOrigin ~= "" then
    -- Origin graft is always created as id-00005
    DB.setValue(newVehicle, "origingraft", "string", sOrigin:gsub("^%l", string.upper));
    local origingraftlink = DB.createChild(newVehicle, "origingraftlink", "windowreference");
    DB.setValue(origingraftlink, "class", "string", "item");
    local originGraftRelPath = "....vehicles." .. newVehicle.getName() .. ".parts.id-00005";
    DB.setValue(origingraftlink, "recordname", "string", originGraftRelPath);
  else
    -- Create empty origin graft link
    local origingraftlink = DB.createChild(newVehicle, "origingraftlink", "windowreference");
    DB.setValue(origingraftlink, "class", "string", "");
    DB.setValue(origingraftlink, "recordname", "string", "");
  end

  Debug.console("Vehicle base data created successfully: " .. sVehicleName);
  
  -- Return the vehicle node so we can create the link AFTER this function completes
  return newVehicle;
end

-- Helper function to create the vehicle link after the vehicle is fully in the database
function vehBuilder_createVehicleLink(vehicleNode)
  if not vehicleNode then
    Debug.console("ERROR: No vehicle node provided for link creation");
    return false;
  end
  
  -- Get the absolute database path for the vehicle
  local vehiclePath = vehicleNode.getPath();
  
  Debug.console("Creating vehicle link for: " .. vehiclePath);
  
  -- Use DB.setValue with windowreference type (matching SFRPG's approach)
  -- This is the same pattern used in record_char_inventory.xml line 505
  DB.setValue(vehicleNode, "link", "windowreference", "charvehicle", vehiclePath);
  
  Debug.console("Vehicle link created successfully");
  Debug.console("  class: charvehicle");
  Debug.console("  path: " .. vehiclePath);
  
  return true;
end

function buildSizeGraft(sSize, sVehType)
  -- Define dimensions based on size
  local dimensions = {
    medium = { width = 5, length = 5, height = 5 },
    large = { width = 10, length = 10, height = 10 },
    huge = { width = 15, length = 15, height = 15 },
    gargantuan = { width = 20, length = 20, height = 20 },
    colossal = { width = 30, length = 30, height = 30 }
  };

  local dim = dimensions[sSize] or dimensions.large;
  local sizeCapitalized = sSize:gsub("^%l", string.upper);
  local vehTypeText = getVehicleTypeText(sVehType);
  
  return sizeCapitalized .. " " .. vehTypeText .. " (" .. dim.width .. " ft. wide, " .. dim.length .. " ft. long, " .. dim.height .. " ft. high)";
end

function getMovementType(sVehType)
  -- Determine movement type based on vehicle type
  -- Convert to lowercase for table lookup
  local sKey = string.lower(sVehType);
  
  local movements = {
    boat = "swim",
    submersible = "swim",
    cruiser = "drive",
    cycle = "drive",
    tank = "drive",
    truck = "drive",
    walker = "walk",
    ["fast flyer"] = "fly",
    ["hovering flyer"] = "fly"
  };
  
  return movements[sKey] or "drive";
end

function getVehicleTypeText(sVehType)
  -- Get descriptive vehicle type text
  -- Convert to lowercase for table lookup
  local sKey = string.lower(sVehType);
  
  local typeTexts = {
    boat = "water vehicle",
    submersible = "water vehicle",
    cruiser = "land vehicle",
    cycle = "land vehicle",
    tank = "land vehicle",
    truck = "land vehicle",
    walker = "land vehicle",
    ["fast flyer"] = "air vehicle",
    ["hovering flyer"] = "air vehicle"
  };
  
  return typeTexts[sKey] or "land vehicle";
end

function buildVehicleDescription(sVehType, sSize, sOrigin, sSpecial1, sSpecial2, window)
  local descriptions = {};

  -- Add vehicle type description
  table.insert(descriptions, "Type: " .. sVehType:gsub("^%l", string.upper));
  
  -- Add size
  table.insert(descriptions, "Size: " .. sSize:gsub("^%l", string.upper));

  -- Add origin if not standard
  if sOrigin ~= "none" and sOrigin ~= "standard" then
    table.insert(descriptions, "Origin: " .. sOrigin:gsub("^%l", string.upper));
    
    -- Add origin notes if available
    local sOriginNotes = window.nOriginNotes.getValue();
    if sOriginNotes and sOriginNotes ~= "" then
      table.insert(descriptions, sOriginNotes);
    end
  end

  -- Add special1 if not none
  if sSpecial1 ~= "none" then
    table.insert(descriptions, "Special: " .. sSpecial1:gsub("^%l", string.upper));
    
    local sSpecial1Notes = window.sSpecial1Notes.getValue();
    if sSpecial1Notes and sSpecial1Notes ~= "" then
      table.insert(descriptions, sSpecial1Notes);
    end
  end

  -- Add special2 if not none
  if sSpecial2 ~= "none" then
    table.insert(descriptions, "Special: " .. sSpecial2:gsub("^%l", string.upper));
    
    local sSpecial2Notes = window.sSpecial2Notes.getValue();
    if sSpecial2Notes and sSpecial2Notes ~= "" then
      table.insert(descriptions, sSpecial2Notes);
    end
  end

  -- Add vehicle type notes
  local sVehTypeNotes = window.sVehTypeNotes.getValue();
  if sVehTypeNotes and sVehTypeNotes ~= "" then
    table.insert(descriptions, sVehTypeNotes);
  end

  return table.concat(descriptions, "\\n\\n");
end

-- Create Type Graft part entry
function createTypeGraftPart(partNode, sVehType)
  local typeData = getTypeGraftData(sVehType);
  
  DB.setValue(partNode, "name", "string", typeData.name);
  DB.setValue(partNode, "subtype", "string", "Type Graft");
  DB.setValue(partNode, "type", "string", "Vehicle");
  DB.setValue(partNode, "locked", "number", 1);
  DB.setValue(partNode, "level", "number", 0);
  DB.setValue(partNode, "magicitem", "number", 0);
  
  DB.setValue(partNode, "cover", "string", typeData.cover);
  DB.setValue(partNode, "modifiers", "string", typeData.modifiers);
  DB.setValue(partNode, "passengers", "number", typeData.passengers);
  DB.setValue(partNode, "speed", "string", typeData.speed);
  
  -- Create link pointing to self (always id-00001 for type graft)
  local linkNode = DB.createChild(partNode, "link", "windowreference");
  DB.setValue(linkNode, "class", "string", "item");
  -- Use hardcoded relative path for type graft
  local relativePath = "..parts.id-00001";
  DB.setValue(linkNode, "recordname", "string", relativePath);
  
  Debug.console("Type graft link created: class=item, recordname=" .. relativePath);
  
  -- Set standard item fields
  DB.setValue(partNode, "ac", "number", 10);
  DB.setValue(partNode, "acpenalty", "number", 0);
  DB.setValue(partNode, "hardness", "number", 0);
  DB.setValue(partNode, "hp", "number", 0);
  DB.setValue(partNode, "abilityscore", "number", 0);
  DB.setValue(partNode, "strength_enc", "number", 0);
end

-- Create Size Graft part entry
function createSizeGraftPart(partNode, sSize)
  local sizeData = getSizeGraftData(sSize);
  
  DB.setValue(partNode, "name", "string", sizeData.name);
  DB.setValue(partNode, "subtype", "string", "Size Graft");
  DB.setValue(partNode, "type", "string", "Vehicle");
  DB.setValue(partNode, "locked", "number", 1);
  DB.setValue(partNode, "level", "number", 0);
  DB.setValue(partNode, "magicitem", "number", 0);
  
  if sizeData.adjustments and sizeData.adjustments ~= "" then
    DB.setValue(partNode, "adjustments", "string", sizeData.adjustments);
  end
  
  -- Create link pointing to self (always id-00002 for size graft)
  local linkNode = DB.createChild(partNode, "link", "windowreference");
  DB.setValue(linkNode, "class", "string", "item");
  -- Use hardcoded relative path for size graft
  local relativePath = "..parts.id-00002";
  DB.setValue(linkNode, "recordname", "string", relativePath);
  
  -- Set standard item fields
  DB.setValue(partNode, "ac", "number", 10);
  DB.setValue(partNode, "acpenalty", "number", 0);
  DB.setValue(partNode, "hardness", "number", 0);
  DB.setValue(partNode, "hp", "number", 0);
  DB.setValue(partNode, "abilityscore", "number", 0);
  DB.setValue(partNode, "strength_enc", "number", 0);
end

-- Create Special Graft part entry
function createSpecialGraftPart(partNode, sSpecial, window)
  local specialData = getSpecialGraftData(sSpecial);
  
  DB.setValue(partNode, "name", "string", specialData.name);
  DB.setValue(partNode, "subtype", "string", "Special Graft");
  DB.setValue(partNode, "type", "string", "Vehicle");
  DB.setValue(partNode, "locked", "number", 1);
  DB.setValue(partNode, "level", "number", 0);
  DB.setValue(partNode, "magicitem", "number", 0);
  
  if specialData.adjustments and specialData.adjustments ~= "" then
    DB.setValue(partNode, "adjustments", "string", specialData.adjustments);
  end
  
  if specialData.special and specialData.special ~= "" then
    DB.setValue(partNode, "special", "string", specialData.special);
  end
  
  -- Get the part node name (should be id-00003 or id-00004)
  local partNodeName = partNode.getName();
  -- Set the self-link using hardcoded relative path
  DB.setValue(partNode, "link", "windowreference", "reference_vehicle_part", "..parts." .. partNodeName);
  
  -- Set standard item fields
  DB.setValue(partNode, "ac", "number", 10);
  DB.setValue(partNode, "acpenalty", "number", 0);
  DB.setValue(partNode, "hardness", "number", 0);
  DB.setValue(partNode, "hp", "number", 0);
  DB.setValue(partNode, "abilityscore", "number", 0);
  DB.setValue(partNode, "strength_enc", "number", 0);
end

-- Get Type Graft data
function getTypeGraftData(sVehType)
  -- Convert to lowercase for table lookup
  local sKey = string.lower(sVehType);
  
  local typeGrafts = {
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
  };
  
  return typeGrafts[sKey] or typeGrafts.cruiser;
end

-- Get Type Graft display name
function getTypeGraftName(sVehType)
  local typeData = getTypeGraftData(sVehType);
  return typeData.name;
end

-- Get Size Graft data
function getSizeGraftData(sSize)
  -- Convert to lowercase for table lookup
  local sKey = string.lower(sSize);
  
  local sizeGrafts = {
    medium = { 
      name = "Medium",
      adjustments = ""
    },
    large = { 
      name = "Large",
      adjustments = ""
    },
    huge = { 
      name = "Huge",
      adjustments = "Increase price by 10%, increase collision damage by 1 die, decrease collision DC by 1, decrease Piloting and attack modifiers by 1, increase passenger limit by 100%."
    },
    gargantuan = { 
      name = "Gargantuan",
      adjustments = "Increase price by 10%, increase Hit Points by 10%, increase collision damage by 2 dice, decrease collision DC by 2, decrease Piloting and attack modifiers by 1, increase passenger limit by 200%."
    },
    colossal = { 
      name = "Colossal",
      adjustments = "Increase price by 20%, increase Hit Points by 20%, increase collision damage by 3 dice, decrease collision DC by 3, decrease Piloting and attack modifiers by 2, increase passenger limit by 400%."
    }
  };
  
  return sizeGrafts[sKey] or sizeGrafts.large;
end

-- Get Special Graft data
function getSpecialGraftData(sSpecial)
  -- Convert to lowercase for table lookup
  local sKey = string.lower(sSpecial);
  
  local specialGrafts = {
    armored = { 
      name = "Armored",
      adjustments = "Increase price by 20%, decrease speed by 10 feet, increase EAC and KAC by 2, increase Hit Points by 10%, increase hardness by 10%, increase cover by 1 step (partial cover becomes cover, cover becomes improved cover, etc.)",
      special = "Increase price by 20%, decrease speed by 10 feet, increase EAC and KAC by 2, increase Hit Points by 10%, increase hardness by 10%, increase cover by 1 step (partial cover becomes cover, cover becomes improved cover, etc.)"
    },
    racer = { 
      name = "Racer",
      adjustments = "Increase speed by 5 feet, decrease Hit Points by 10%, decrease hardness by 20%, decrease passengers by 50%. After recalculating speed, increase full speed by 25%.",
      special = ""
    },
    transport = { 
      name = "Transport",
      adjustments = "Increase price by 10%, decrease full speed by 100 feet, increase passenger limit by 200%.",
      special = ""
    },
    hover = { 
      name = "Hover",
      adjustments = "Increase price by 10%, increase speed by 5 feet, increase Piloting modifier by 1. The vehicle ignores difficult terrain.",
      special = "The vehicle must have the boat type graft or any type graft that grants a land speed."
    },
    junk = { 
      name = "Junk",
      adjustments = "Decrease price by 20%, decrease full speed by 50 feet, decrease Piloting modifier by 3, decrease attack modifiers by 1. The vehicle gains the broken condition when reduced to 75% of its Hit Points instead of 50%.",
      special = "If you have access to inert electronic and mechanical junk, this graft instead reduces vehicle price by 50%. This requires at least 10 bulk of junk for a Medium vehicle. For each size category larger than Medium, multiply the junk required by 8"
    },
    ["hybrid aircraft"] = { 
      name = "Hybrid aircraft",
      adjustments = "Increase price by 30%, increase full speed by 200 feet. The vehicle gains a fly speed equal to its land speed.",
      special = "The vehicle must have a land speed. Cannot have the Tank type graft."
    }
  };
  
  return specialGrafts[sKey] or { name = sSpecial:gsub("^%l", string.upper), adjustments = "", special = "" };
end

-- Function to create movement entries based on vehicle type and special abilities
function createMovementEntries(vehicleNode, sVehType, sSpecial1, sSpecial2, nSpeed, nFullSpeed, nOverland)
  local movementsNode = DB.createChild(vehicleNode, "movements");
  
  -- Determine base movement type from vehicle type
  local baseMovementType = getMovementType(sVehType);
  local movementTypes = {};
  
  -- Add base movement type
  table.insert(movementTypes, baseMovementType);
  
  -- Check special abilities for additional movement types
  local specials = { sSpecial1, sSpecial2 };
  for _, special in ipairs(specials) do
    if special then
      local sKey = string.lower(special);
      
      -- Amphibious adds swim movement
      if sKey == "amphibious" then
        if not hasMovementType(movementTypes, "swim") then
          table.insert(movementTypes, "swim");
        end
      
      -- Hover adds hover movement (and requires land speed)
      elseif sKey == "hover" then
        if not hasMovementType(movementTypes, "hover") then
          table.insert(movementTypes, "hover");
        end
        -- Ensure we have land movement for hover
        if not hasMovementType(movementTypes, "drive") and not hasMovementType(movementTypes, "walk") then
          if not hasMovementType(movementTypes, "drive") then
            table.insert(movementTypes, "drive");
          end
        end
      
      -- Hybrid aircraft adds fly movement  
      elseif sKey == "hybrid aircraft" then
        if not hasMovementType(movementTypes, "fly") then
          table.insert(movementTypes, "fly");
        end
        -- Ensure we have land movement for hybrid aircraft
        if not hasMovementType(movementTypes, "drive") and not hasMovementType(movementTypes, "walk") then
          if not hasMovementType(movementTypes, "drive") then
            table.insert(movementTypes, "drive");
          end
        end
      end
    end
  end
  
  -- Create movement entries for each movement type
  for _, movementType in ipairs(movementTypes) do
    local movement = DB.createChild(movementsNode);
    DB.setValue(movement, "speed", "number", nSpeed);
    DB.setValue(movement, "fullspeed", "number", nFullSpeed);
    DB.setValue(movement, "overland", "number", nOverland);
    
    -- Set clean movement type name
    DB.setValue(movement, "name", "string", movementType);
  end
end

-- Helper function to check if a movement type already exists in the list
function hasMovementType(movementTypes, targetType)
  for _, movementType in ipairs(movementTypes) do
    if movementType == targetType then
      return true;
    end
  end
  return false;
end

-- Function to create origin graft parts
function createOriginGraftPart(partNode, originGraft, reference)
  if not originGraft or originGraft == "" then
    return;
  end
  
  local originData = nil;
  for _, origin in ipairs(reference.originGrafts) do
    if origin.name == originGraft then
      originData = origin;
      break;
    end
  end
  
  if not originData then
    Debug.console("Origin graft not found in reference: " .. originGraft);
    return;
  end
  
  -- Set basic part properties
  DB.setValue(partNode, "name", "string", originData.name);
  DB.setValue(partNode, "shortdescription", "string", originData.description);
  DB.setValue(partNode, "subtype", "string", originData.subtype);
  DB.setValue(partNode, "type", "string", "Vehicle");
  DB.setValue(partNode, "locked", "number", 1);
  DB.setValue(partNode, "level", "number", 0);
  DB.setValue(partNode, "magicitem", "number", 0);
  
  -- Set the self-link for the origin graft (id-00005)
  DB.setValue(partNode, "link", "windowreference", "reference_vehicle_part", "..parts.id-00005");
  
  -- Set standard item fields
  DB.setValue(partNode, "ac", "number", 10);
  DB.setValue(partNode, "acpenalty", "number", 0);
  DB.setValue(partNode, "hardness", "number", 0);
  DB.setValue(partNode, "hp", "number", 0);
  DB.setValue(partNode, "abilityscore", "number", 0);
  DB.setValue(partNode, "strength_enc", "number", 0);
  
  Debug.console("Created origin graft: " .. originData.name .. " as id-00005");
end

-- Function to load vehicle graft reference data
function loadVehicleGraftReference()
  -- Return the reference data directly since FG doesn't support require()
  local reference = {
    typeGrafts = {
      {
        name = "Air",
        subtype = "Type Graft",
        description = "This vehicle is designed to move through the air."
      },
      {
        name = "Land",
        subtype = "Type Graft", 
        description = "This vehicle is designed to move on land."
      },
      {
        name = "Sea",
        subtype = "Type Graft",
        description = "This vehicle is designed to move on or through water."
      },
      {
        name = "Space",
        subtype = "Type Graft",
        description = "This vehicle is designed to move through space."
      },
      {
        name = "Boat",
        subtype = "Type Graft",
        description = "This vehicle is a small watercraft."
      },
      {
        name = "Bike",
        subtype = "Type Graft", 
        description = "This vehicle is a two-wheeled land vehicle."
      },
      {
        name = "Car",
        subtype = "Type Graft",
        description = "This vehicle is a four-wheeled land vehicle."
      },
      {
        name = "Mech",
        subtype = "Type Graft",
        description = "This vehicle is a piloted robotic suit."
      },
      {
        name = "Walker",
        subtype = "Type Graft",
        description = "This vehicle moves on mechanical legs."
      }
    },
    
    sizeGrafts = {
      {
        name = "Medium",
        subtype = "Size Graft",
        description = "This vehicle is Medium sized."
      },
      {
        name = "Large",
        subtype = "Size Graft",
        description = "This vehicle is Large sized."
      },
      {
        name = "Huge", 
        subtype = "Size Graft",
        description = "This vehicle is Huge sized."
      },
      {
        name = "Gargantuan",
        subtype = "Size Graft", 
        description = "This vehicle is Gargantuan sized."
      },
      {
        name = "Colossal",
        subtype = "Size Graft",
        description = "This vehicle is Colossal sized."
      }
    },
    
    specialGrafts = {
      {
        name = "Enclosed",
        subtype = "Special Graft",
        description = "This vehicle provides total cover to its occupants.",
        adjustments = "+2 EAC, +2 KAC against attacks from outside",
        special = "Occupants have total cover from attacks originating outside the vehicle"
      },
      {
        name = "Enhanced Sensors",
        subtype = "Special Graft", 
        description = "This vehicle has advanced sensor arrays.",
        adjustments = "+4 to Perception checks",
        special = "Can detect targets at twice normal range"
      },
      {
        name = "Fast",
        subtype = "Special Graft",
        description = "This vehicle is built for speed.",
        adjustments = "+10 ft. speed",
        special = "Increase all movement speeds by 10 feet"
      },
      {
        name = "Manipulator Arms",
        subtype = "Special Graft",
        description = "This vehicle has mechanical arms for manipulation.",
        adjustments = "",
        special = "Can manipulate objects as if the pilot had Str 20"
      },
      {
        name = "Rugged",
        subtype = "Special Graft",
        description = "This vehicle is built to withstand punishment.",
        adjustments = "+5 HP, +2 Hardness",
        special = "Resistant to environmental damage"
      },
      {
        name = "Weapon Mount (Light)",
        subtype = "Special Graft",
        description = "This vehicle can mount light weapons.",
        adjustments = "",
        special = "Can mount weapons of light bulk or smaller"
      },
      {
        name = "Weapon Mount (Heavy)",
        subtype = "Special Graft", 
        description = "This vehicle can mount heavy weapons.",
        adjustments = "",
        special = "Can mount weapons of heavy bulk"
      },
      {
        name = "Cargo Hold",
        subtype = "Special Graft",
        description = "This vehicle has extra cargo space.",
        adjustments = "",
        special = "Double normal cargo capacity"
      },
      {
        name = "Luxury",
        subtype = "Special Graft",
        description = "This vehicle provides exceptional comfort.",
        adjustments = "",
        special = "Passengers gain +2 morale bonus on saves against fear and fatigue"
      },
      {
        name = "Stealth",
        subtype = "Special Graft",
        description = "This vehicle is designed to avoid detection.",
        adjustments = "+10 Stealth",
        special = "Can attempt Stealth checks while moving"
      },
      {
        name = "Reinforced",
        subtype = "Special Graft",
        description = "This vehicle has extra armor plating.",
        adjustments = "+1 EAC, +1 KAC, +3 Hardness",
        special = "Gains damage reduction equal to half its hardness"
      },
      {
        name = "Amphibious",
        subtype = "Special Graft",
        description = "This vehicle can operate on land and in water.",
        adjustments = "",
        special = "Gains swim speed equal to half its land speed"
      }
    },
    
    originGrafts = {
      {
        name = "experimental",
        subtype = "Origin Graft",
        description = "This vehicle is an experimental design with cutting-edge technology. Requires Experimental Vehicle class feature (Mechanic)."
      },
      {
        name = "factory-made",
        subtype = "Origin Graft", 
        description = "This vehicle was manufactured in a standardized factory setting. Repairs cost 10% less and take 25% less time."
      },
      {
        name = "prototype",
        subtype = "Origin Graft",
        description = "This vehicle is a prototype design with advanced features. Repairs cost 20% more and take 20% more time."
      }
    }
  };
  
  Debug.console("Loaded vehicle graft reference data successfully");
  return reference;
end

--
-- veh_wizard.lua
-- Helper functions and state management for the vehicle wizard that edits
-- existing vehicle records directly instead of creating new ones.
--

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

local VEH_TYPES = {
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
    description = "Cycles are light vehicles that the pilot and sometimes a passenger ride directly on top of."
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

local SIZE_GRAFTS = {
  ["Medium"] = {
    cost      = 0,   -- percentage increase
    HP        = 0,   -- percentage increase
    collDice  = -1,  -- additional collision DC dice
    collDC    = 1,   -- collision DC modifier
    piloting  = 1,   -- piloting check modifier
    attacks   = 0,   -- attack roll modifier
    passengers = 0    -- passenger capacity multiplier
  },
  ["Large"] = {
    cost      = 0,   -- percentage increase
    HP        = 0,   -- percentage increase
    collDice  = 0,   -- additional collision DC dice
    collDC    = 0,   -- collision DC modifier
    piloting  = 0,   -- piloting check modifier
    attacks   = 0,   -- attack roll modifier
    passengers = 0    -- passenger capacity multiplier
  },
  ["Huge"] = {
    cost      = 0.10, -- percentage increase
    HP        = 0,    -- percentage increase
    collDice  = 1,    -- additional collision DC dice
    collDC    = -1,   -- collision DC modifier
    piloting  = -1,   -- piloting check modifier
    attacks   = -1,   -- attack roll modifier
    passengers = 1     -- passenger capacity multiplier
  },
  ["Gargantuan"] = {
    cost      = 0.10, -- percentage increase
    HP        = 0.10, -- percentage increase
    collDice  = 2,    -- additional collision DC dice
    collDC    = -2,   -- collision DC modifier
    piloting  = -1,   -- piloting check modifier
    attacks   = -1,   -- attack roll modifier
    passengers = 2     -- passenger capacity multiplier
  },
  ["Colossal"] = {
    cost      = 0.20, -- percentage increase
    HP        = 0.20, -- percentage increase
    collDice  = 3,    -- additional collision DC dice
    collDC    = -3,   -- collision DC modifier
    piloting  = -2,   -- piloting check modifier
    attacks   = -2,   -- attack roll modifier
    passengers = 4     -- passenger capacity multiplier
  }
}

local SPECIAL_GRAFTS = {
  ["All-terrain"] = {
    cost = 0.05,
    speed = -5,
    fullspeed = -25,
    attacks = -1,
    notes = "When moving through difficult terrain, treat every other space of difficult terrain as normal terrain."
  },
  ["Amphibious"] = {
    cost = 0.10,
    notes = "Vehicle becomes both a water and land vehicle, granting both a land and swim speed."
  },
  ["Armored"] = {
    cost = 0.20,    
    EAC = 2,
    KAC = 2,
    hardness = 0.10,
    HP = 0.10,
    speed = -10,
    notes = "Increases vehicle hardness and HP, but reduces speed."
  },
  ["Computer-Assisted Controls"] = {
    cost = 0.05,
    notes = "Vehicle gains an autopilot with Piloting bonus of 4 + 1.5 * vehicles level."
  },
  ["Hover"] = {
    cost = 0.10,
    speed = 5,
    EAC = -1,
    KAC = -1,
    HP = -0.20,
    notes = "Vehicle becomes a land and water vehicle, gaining the hover trait to its movement. It hovers 5 ft over surfaces, ignoring difficult terrain."
  },
  ["Hybrid Aircraft"] = {
    cost = 0.15,
    speed = 10,
    EAC = -1,
    KAC = -1,
    HP = -0.10,
    notes = "Vehicle gains both a fly speed and a land speed. It can switch between the two modes as a free action."
  },
  ["Junk"] = {
    cost = -0.50,
    fullspeed = -50,
    piloting = -3,
    attacks = -1,
    notes = "Unstable Engine: If the engine is broken, it explodes in 1d4 rounds dealing 1d6 dmg in a 10 ft burst. This increases by by 1d6 at 3rd level and ever odd level after."
  },
  ["Luxury"] = {
    cost = 0.20,
    attacks = 1,
    notes = "Gains a planetary comm unit and auto-control with Piloting bonus of 4 + 1.5 * vehicles level."
  },
  ["Racer"] = {
    cost = 0,
    speed = 5,
    HP = -0.10,
    hardness = -0.20,
    passengers = -0.50,
    notes = "Designed for speed, this vehicle sacrifices durability and passenger capacity."
  },
  ["Transport"] = {
    cost = 0,
    overland = 0.20,
    piloting = -1,
    passengers = 1.00,
    notes = "These large cumbersome vehicles are capable of high speeds over long distances."
  }
}

local ORIGIN_GRAFTS = {
  ["Experimental"] = {
    cost = -0.50,
    mods = 1,
    notes = "These prototypes are created by those with experimental vehicle class feature (mechanics)."
  },
  ["Factory-Made"] = {
    cost = -0.10,
    mods = - 1,
    notes = "While in a settlement, decrease repair costs by 10% and repair time by 25%."
  },
  ["Prototype"] = {
    cost = 0.10,
    mods = 1,
    notes = "These custom vehicles increase repair costs and repair times by 20%."
  }
}

function updateVehicleMetaData(nodeVehicle)
  if not nodeVehicle then
    Debug.console("No vehicle node provided; cannot continue vehicle meta update.");
    return;
  end

  -- determine base values as set by the vehicle level
  local nLevel = DB.getValue(nodeVehicle, "level", 0);
  if nLevel < 1 or nLevel > 20 then
    Debug.console("Vehicle level is out of range; cannot continue vehicle meta update.");
    return;
  else
    Debug.console("Updating vehicle meta data for level " .. nLevel);
  end

  -- step 1: base values defined from level
  local baseMeta = {};
  baseMeta.price = LEVEL_PRICE[nLevel] or 0;
  baseMeta.speed = LEVEL_SPEED[nLevel] or 0;
  baseMeta.eac = LEVEL_EAC[nLevel] or 0;
  baseMeta.kac = (LEVEL_EAC[nLevel] or 0) + 2; -- KAC is always EAC + 2
  baseMeta.hp = LEVEL_HP[nLevel] or 0;
  baseMeta.hardness = LEVEL_HARDNESS[nLevel] or 0;
  baseMeta.diceCount = LEVEL_DICE_COUNT[nLevel] or 0;
  baseMeta.diceSize = LEVEL_DICE_SIZE[nLevel] or 0;
  baseMeta.collisionDC = LEVEL_COLLISION_DC[nLevel] or 0;
  baseMeta.modSlots = LEVEL_MOD_SLOTS[nLevel] or 0;

  -- step 2: veh type graft
  local sVehType = DB.getValue(nodeVehicle, "typegraft", "");
  local sVehTypeClean = sVehType:match("^(.-)%s*%(")
  if sVehTypeClean == nil or sVehTypeClean == "" then
    sVehTypeClean = sVehType;
  end
  sVehTypeClean = sVehTypeClean:gsub("%s+$", "");
  if sVehTypeClean == "" then
    Debug.console("Vehicle type graft not set; cannot continue vehicle meta update.");
    return;
  else
    Debug.console("Vehicle type graft: " .. sVehTypeClean);
  end

  local typeMeta = VEH_TYPES[sVehTypeClean:lower()];

  -- typeInfo example:
  --  ["boat"] = {
  --    cycler = "Boat",
  --    display = "Boat (Water Vehicle)",
  --    subtype = " (Water Vehicle)",
  --    passengers = 2,
  --    fullspeed = 15,
  --    piloting = 0,
  --    attack = -2,
  --    attackfull = -4,
  --    cover = "partial",
  --    description = "Boats travel on the surface of the water and can be powered by a wide variety of propulsion methods."

  -- step 3: vehicle size graft
  local sVehSize = DB.getValue(nodeVehicle, "sizegraft", "");
  if sVehSize == "" then
    Debug.console("Vehicle type graft not set; cannot continue vehicle meta update.");
    return;
  end

  local sizeMeta = SIZE_GRAFTS[sVehSize];
  if not sizeMeta then
    Debug.console("Vehicle size graft invalid; cannot continue vehicle meta update.");
    return;
  else
    Debug.console("Vehicle size graft: " .. sVehSize);
  end

  --    ["colossal"] = {
  --    cost      = 0.20, -- percentage increase
  --    HP        = 0.20, -- percentage increase
  --    collDice  = 3,    -- additional collision DC dice
  --    collDC    = -3,   -- collision DC modifier
  --    piloting  = -2,   -- piloting check modifier
  --    attacks   = -2,   -- attack roll modifier
  --    passenger = 4     -- passenger capacity multiplier

  -- step 4: origin graft
  local sVehOrigin = DB.getValue(nodeVehicle, "origingraft", "");
  -- can be blank
  local originMeta = {};
  if sVehOrigin ~= "" then
    originMeta = ORIGIN_GRAFTS[sVehOrigin];
    Debug.console("Vehicle origin graft: " .. sVehOrigin);
  else
    Debug.console("No origin graft selected.");
  end

  -- step 5: special graft(s)
  local sVehSpecial1 = DB.getValue(nodeVehicle, "specialgraft", "");
  -- can be blank
  local specialMeta1 = {};
  if sVehSpecial1 ~= "" then
    specialMeta1 = SPECIAL_GRAFTS[sVehSpecial1];
    Debug.console("Vehicle special graft 1: " .. sVehSpecial1);
  end

  -- <vehicle>.<id-00001>.<parts>.<id-00001>.<subtype> = "Special Graft"
  
  local specialMeta2 = {};
  local sVehSpecial2 = nil;
  -- loop through the parts and look for special grafts
  local nodeParts = nodeVehicle.getChild("parts");
  if nodeParts then
    for _,v in pairs(nodeParts.getChildren()) do
      local sName = DB.getValue(v, "name", "");
      local sPartType = DB.getValue(v, "subtype", "");
      if sPartType == "Special Graft" then
        if not (sName == sVehSpecial1) then
          sVehSpecial2 = sName;
          specialMeta2 = SPECIAL_GRAFTS[sName];
          Debug.console("Vehicle special graft 2: " .. sName);
        end
      end
    end
  end


  -- then, last step, apply modifiers and calculate final values ... then update the vehicle record

  -- PRICE
  local nPrice = baseMeta.price;
  if (typeMeta and typeMeta.pricePct) then
    nPrice = nPrice + (typeMeta.pricePct * baseMeta.price);
  end
  if (sizeMeta and sizeMeta.cost) then
    nPrice = nPrice + (sizeMeta.cost * baseMeta.price);
  end
  if (specialMeta1 and specialMeta1.cost) then
    nPrice = nPrice + (specialMeta1.cost * baseMeta.price);
  end
  if (specialMeta2 and specialMeta2.cost) then
    nPrice = nPrice + (specialMeta2.cost * baseMeta.price);
  end
  if (originMeta and originMeta.cost) then
    nPrice = nPrice + (originMeta.cost * baseMeta.price); -- each mod slot adds 5000 credits
  end
  DB.createChild(nodeVehicle, "price", "number").setValue(nPrice);

  -- PASSENGERS
  local nPassengers = typeMeta.passengers;
  if (sizeMeta and sizeMeta.passengers) then
    nPassengers = nPassengers + (nPassengers * sizeMeta.passengers);
  end
  if (specialMeta1 and specialMeta1.passengers) then
    nPassengers = nPassengers + (specialMeta1.passengers * typeMeta.passengers);
  end
  if (specialMeta2 and specialMeta2.passengers) then
    nPassengers = nPassengers + (specialMeta2.passengers * typeMeta.passengers);
  end
  
  if sf.isGt(0, nPassengers) then
    nPassengers = 0; -- can't have negative passengers
  end
  if sVehTypeClean == "Cycle" and sf.isGt(nPassengers, 1) then
    nPassengers = 1; -- cycles can only hold 1 passenger
  end
  DB.createChild(nodeVehicle, "passengers", "number").setValue(nPassengers);

  -- PILOTING
  -- local nPiloting = window.nBasePilotingMod.getValue() + window.nSizePilotingMod.getValue() + window.nSpecial1PilotingMod.getValue() + window.nSpecial2PilotingMod.getValue();
  local nPiloting = typeMeta.piloting;
  if (specialMeta1 and specialMeta1.piloting) then
    nPiloting = nPiloting + specialMeta1.piloting;
  end
  if (specialMeta2 and specialMeta2.piloting) then
    nPiloting = nPiloting + specialMeta2.piloting;
  end
  if (sizeMeta and sizeMeta.piloting) then
    nPiloting = nPiloting + sizeMeta.piloting; -- each mod slot adds 5000 credits
  end
  DB.createChild(nodeVehicle, "pilot.total", "number").setValue(nPiloting);

  -- ATTACKS (attack.mod and attack.full)
  -- local nAttack = window.nBaseAttackMod.getValue() + window.nSizeAttackMod.getValue() + window.nSpecial1AttackMod.getValue() + window.nSpecial2AttackMod.getValue();
  local nAttack = sizeMeta.attacks + (typeMeta.attack or 0);
  local nAttackFull = sizeMeta.attacks + (typeMeta.attackfull or 0);
  if (specialMeta1 and specialMeta1.attacks) then
    nAttack = nAttack + specialMeta1.attacks;
    nAttackFull = nAttackFull + specialMeta1.attacks;
  end
  if (specialMeta2 and specialMeta2.attacks) then
    nAttack = nAttack + specialMeta2.attacks;
    nAttackFull = nAttackFull + specialMeta2.attacks;
  end
  if nAttack > 0 then
    nAttack = 0; -- can't have positive attack mods
  end
  if nAttackFull > 0 then
    nAttackFull = 0; -- can't have positive attack mods
  end
  DB.createChild(nodeVehicle, "attack.mod", "number").setValue(nAttack);
  DB.createChild(nodeVehicle, "attack.full", "number").setValue(nAttackFull);

  -- EAC and KAC
  local nEAC = baseMeta.eac + (sizeMeta.eacMod or 0) + (typeMeta.eacMod or 0);
  if (specialMeta1 and specialMeta1.EAC) then
    nEAC = nEAC + specialMeta1.EAC;
  end
  if (specialMeta2 and specialMeta2.EAC) then
    nEAC = nEAC + specialMeta2.EAC;
  end
  DB.createChild(nodeVehicle, "defenses.eac.total", "number").setValue(nEAC);

  local nKAC = baseMeta.kac + (sizeMeta.kacMod or 0) + (typeMeta.kacMod or 0);
  if (specialMeta1 and specialMeta1.KAC) then
    nKAC = nKAC + specialMeta1.KAC;
  end
  if (specialMeta2 and specialMeta2.KAC) then
    nKAC = nKAC + specialMeta2.KAC;
  end  
  DB.createChild(nodeVehicle, "defenses.kac.total", "number").setValue(nKAC);

  -- HP and Broken HP
  local nHP = baseMeta.hp;
  if (typeMeta and typeMeta.hpPct) then
    nHP = nHP + (typeMeta.hpPct * baseMeta.hp);
  end
  if (sizeMeta and sizeMeta.HP) then
    nHP = nHP + (sizeMeta.HP * baseMeta.hp);
  end
  if (specialMeta1 and specialMeta1.HP) then
    nHP = nHP + (specialMeta1.HP * baseMeta.hp);
  end
  if (specialMeta2 and specialMeta2.HP) then
    nHP = nHP + (specialMeta2.HP * baseMeta.hp);
  end
  nHP = math.floor(nHP);
  DB.createChild(nodeVehicle, "hp.total", "number").setValue(nHP);

  local nBrokenHP = math.floor(nHP * 0.50); -- default broken HP is 50% of total HP
  if sVehSpecial1 == "Junk" or sVehSpecial2 == "Junk" then
    nBrokenHP = math.floor(nHP * 0.75); -- junk vehicles have 75% broken HP
  end
  DB.createChild(nodeVehicle, "hp.broken", "number").setValue(nBrokenHP);

  -- local nHardness = window.nBaseHardness.getValue() + window.nVehTypeHardness.getValue() + window.nSpecial1Hardness.getValue() + window.nSpecial2Hardness.getValue();
  local nHardness = baseMeta.hardness;
  if (typeMeta and typeMeta.hardnessPct) then
    nHardness = nHardness + (typeMeta.hardnessPct * baseMeta.hardness);
  end
  if (specialMeta1 and specialMeta1.hardness) then
    nHardness = nHardness + (specialMeta1.hardness * baseMeta.hardness);
  end
  if (specialMeta2 and specialMeta2.hardness) then
    nHardness = nHardness + (specialMeta2.hardness * baseMeta.hardness);
  end
  nHardness = math.floor(nHardness);
  DB.createChild(nodeVehicle, "defenses.hardness.total", "number").setValue(nHardness);

  -- COLLISION DICE AND DC
  local nDice = baseMeta.diceCount;
  if (sizeMeta and sizeMeta.collDice) then
    nDice = nDice + sizeMeta.collDice;
  end

  local nDiceSize = baseMeta.diceSize;
  local sDice = nDice .. "d" .. nDiceSize .. " B";
  DB.createChild(nodeVehicle, "collision.damage.total", "string").setValue(sDice);

  -- colision DC / collision.dc.total
  local nCollDC = baseMeta.collisionDC;
  if (sizeMeta and sizeMeta.collDC) then
    nCollDC = nCollDC + sizeMeta.collDC;
  end
  DB.createChild(nodeVehicle, "collision.dc.total", "number").setValue(nCollDC);

  -- mod slots ... modslots.total
  local nModSlots = baseMeta.modSlots;
  if (originMeta and originMeta.mods) then
    nModSlots = nModSlots + originMeta.mods;
  end
  DB.createChild(nodeVehicle, "modslots.total", "number").setValue(nModSlots);

  -- COVER
  local sCover = typeMeta.cover or "none";
  if sVehSpecial1 == "Armored" or sVehSpecial2 == "Armored" then
    if sCover == "" or sCover == "none" then
      sCover = "partial";
    elseif sCover == "partial" then
      sCover = "cover";
    elseif sCover == "cover" then
      sCover = "improved";
    elseif sCover == "improved" then
      sCover = "total";
    end
  end

  DB.createChild(nodeVehicle, "cover", "string").setValue(sCover);

  -- SPEED, Base
  local nSpeed = baseMeta.speed + (typeMeta.speedMod or 0);
  Debug.console("Base speed: " .. baseMeta.speed .. ", Type mod: " .. (typeMeta.speedMod or 0) );
  if (specialMeta1 and specialMeta1.speed) then
    nSpeed = nSpeed + specialMeta1.speed;
  end
  if (specialMeta2 and specialMeta2.speed) then
    nSpeed = nSpeed + specialMeta2.speed;
  end
  Debug.console("adjusted Base speed: " .. nSpeed);

  -- SPEED, Full
  local nFullSpeed = nSpeed * (typeMeta.fullspeed or 1);
  Debug.console("Full speed before specials: " .. nFullSpeed);

  if (specialMeta1 and specialMeta1.fullspeed) then
    nFullSpeed = nFullSpeed + specialMeta1.fullspeed;
  end
  if (specialMeta2 and specialMeta2.fullspeed) then
    nFullSpeed = nFullSpeed + specialMeta2.fullspeed;
  end
  Debug.console("Full speed after special grafts: " .. nFullSpeed);

  if sVehSpecial1 == "Racer" or sVehSpecial2 == "Racer" then
    nFullSpeed = math.floor(nFullSpeed * 1.25); -- +25% bonus for racers
  end
  Debug.console("Final full speed: " .. nFullSpeed);

  -- SPEED, Overland
  local nOverland = math.floor(nFullSpeed / 10);
  Debug.console("Overland speed before specials: " .. nOverland);

  if sVehSpecial1 == "Transport" or sVehSpecial2 == "Transport" then
    nOverland = math.floor(nOverland * 1.20); -- +20% bonus for transport
  end
  Debug.console("Final overland speed: " .. nOverland);

  createMovementEntries(nodeVehicle, sVehTypeClean, sVehSpecial1, sVehSpecial2, nSpeed, nFullSpeed, nOverland);

  -- SPECIAL ABILITIES NOTES
  -- Build vehicle description with special abilities
  local sDescription = buildVehicleDescription(sVehTypeClean, sVehSize, sVehOrigin, sVehSpecial1, sVehSpecial2, w);

  -- Set special abilities entry
  local specialAbilitiesNode = DB.createChild(nodeVehicle, "specialabilities");
  if sDescription and sDescription ~= "" then
    local specialAbility = DB.createChild(specialAbilitiesNode);
    DB.setValue(specialAbility, "name", "string", "Vehicle Features");
    DB.setValue(specialAbility, "text", "string", sDescription);
    DB.setValue(specialAbility, "locked", "number", 1);
    
    -- Create shortcut windowreference with empty recordname
    DB.setValue(specialAbility, "shortcut", "windowreference", "npc_specialability", "");
  end

  -- DB.setValue(nodeVehicle, "vehicleSubType", "string", typeInfo.subtype)
  -- DB.setValue(nodeVehicle, "description", "string", typeInfo.description)
end

function getMovementType(sVehType)
  -- Determine movement type based on vehicle type
  -- Convert to lowercase for table lookup
  local sKey = sVehType:lower();
  
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

-- Function to create movement entries based on vehicle type and special abilities
function createMovementEntries(vehicleNode, sVehType, sSpecial1, sSpecial2, nSpeed, nFullSpeed, nOverland)
  local movementsNode = DB.createChild(vehicleNode, "movements");
  Debug.console("Creating movement entries for vehicle type: " .. sVehType);
  
    -- Determine base movement type from vehicle type
  local baseMovementType = getMovementType(sVehType:lower());
  local movementTypes = {};

  Debug.console("Base movement type: " .. baseMovementType);
  
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
        if not hasMovementType(movementTypes, "drive") then
          table.insert(movementTypes, "drive");
        end
      
      -- Hover adds hover movement (and requires land speed)
      elseif sKey == "hover"  then
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
      elseif (sKey == "hybrid aircraft" ) then
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
    local sOriginNotes = ORIGIN_GRAFTS[sOrigin] and ORIGIN_GRAFTS[sOrigin].notes or "";
    if sOriginNotes and sOriginNotes ~= "" then
      table.insert(descriptions, sOriginNotes);
    end
  end

  -- Add special1 if not none
  if sSpecial1 and sSpecial1 ~= "" and sSpecial1 ~= "none" then
    table.insert(descriptions, "Special: " .. sSpecial1:gsub("^%l", string.upper));
    
    local sSpecial1Notes = SPECIAL_GRAFTS[sSpecial1] and SPECIAL_GRAFTS[sSpecial1].notes or "";
    if sSpecial1Notes and sSpecial1Notes ~= "" then
      table.insert(descriptions, sSpecial1Notes);
    end
  end

  -- Add special2 if not none
  if sSpecial2 and sSpecial2 ~= "" and sSpecial2 ~= "none" then
    table.insert(descriptions, "Special: " .. sSpecial2:gsub("^%l", string.upper));
    
    local sSpecial2Notes = SPECIAL_GRAFTS[sSpecial2] and SPECIAL_GRAFTS[sSpecial2].notes or "";
    if sSpecial2Notes and sSpecial2Notes ~= "" then
      table.insert(descriptions, sSpecial2Notes);
    end
  end

  -- Add vehicle type notes
  local sVehTypeNotes = VEH_TYPES[sVehType] and VEH_TYPES[sVehType].notes or "";
  if sVehTypeNotes and sVehTypeNotes ~= "" then
    table.insert(descriptions, sVehTypeNotes);
  end

  return table.concat(descriptions, "\\n\\n");
end
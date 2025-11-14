local bOverrideApplied = false;
local bDesktopHooked = false;
local bInitHandlerRegistered = false;

local function logMessage(sText)
  if Debug and Debug.console then
    Debug.console("SF Helpers - " .. sText);
  end
end

local function applyCompanionOverride()
  if bOverrideApplied then
    return true;
  end
  if not CombatManager2 or not CombatManager2.addCompanion then
    logMessage("Companion override: CombatManager2 or addCompanion not found.");
    return false;
  end

  local fOriginal = CombatManager2.addCompanion;

  CombatManager2.addCompanion = function(tCustom)
    if fOriginal then
      logMessage("Companion override: Calling original function.");
      fOriginal(tCustom);
    else
      logMessage("Companion override: No original function, calling addCompanion directly.");
      CombatManager2.addCompanion(tCustom);
    end

    if not tCustom.nodeRecord or not tCustom.nodeCT then
      logMessage("Companion override: Missing nodeRecord or nodeCT.");
      return true;
    end

    logMessage("Companion override: created companion attacks node");
    local nodeAttacks = DB.createChild(tCustom.nodeCT, "attacks");

    if nodeAttacks and CombatManager2.addNPCAttacks then
      -- logMessage("Companion override: calling addNPCAttacks.");
      -- CombatManager2.addNPCAttacks(tCustom.nodeRecord, nodeAttacks);
      logMessage("Companion override: manually Adding NPC attacks.");  
      local nAttacks = 0;
      -- Melee attacks
      local sMeleeAttacks = DB.getValue(tCustom.nodeRecord, "melee", "")
      if sMeleeAttacks ~= "" then
        local sMeleeAttack = string.gsub(sMeleeAttacks, " and ", "|")
        local aAttacks = StringManager.split(sMeleeAttacks, "|", false)
        local sMeleeAttacks = table.concat(aAttacks, " and ")
        local nodeValue = DB.createChild(nodeAttacks)

        if nodeValue then
          DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sMeleeAttacks));
          DB.setValue(nodeValue, "type", "number", 0);
          nAttacks = nAttacks + 1;
        end
      end

      --Ranged
      local sRangedAttacks = DB.getValue(tCustom.nodeRecord, "ranged", "");
      if sRangedAttacks ~= "" then
        local sRangedAttacks = string.gsub(sRangedAttacks, " or ", "|");
        local aAttacks = StringManager.split(sRangedAttacks, "|", false);
        local sRangedAttacks = table.concat(aAttacks, " or ");
        local nodeValue = DB.createChild(nodeAttacks);

        if nodeValue then
          DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sRangedAttacks));
          DB.setValue(nodeValue, "type", "number", 2);
          nAttacks = nAttacks + 1;
        end
      end
    end

    logMessage("Companion override: Finished adding companion attacks.");

    return true;
  end

  bOverrideApplied = true;
  logMessage("Companion attack carry-over enabled.");
  return true;
end

local function hookDesktopInit()
  if bDesktopHooked then
    return;
  end
  if not Interface or not Interface.onDesktopInit then
    return;
  end

  bDesktopHooked = true;

  local fPrevDesktopInit = Interface.onDesktopInit;
  Interface.onDesktopInit = function()
    if fPrevDesktopInit then
      fPrevDesktopInit();
    end
    applyCompanionOverride();
  end
end

local function ensureOverride()
  if applyCompanionOverride() then
    return;
  end

  hookDesktopInit();

  if not bInitHandlerRegistered and ScriptManager and ScriptManager.addInitHandler then
    bInitHandlerRegistered = true;
    ScriptManager.addInitHandler(function()
      hookDesktopInit();
      applyCompanionOverride();
    end);
  end
end

ensureOverride();

function onInit()
  ensureOverride();
end
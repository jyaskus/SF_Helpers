

function isGt(nValue, nTest)
  return (nValue > nTest);
end
function isGe(nValue, nTest)
  return (nValue >= nTest);
end

function d4()
  local nRoll = math.random(1,4);
  return nRoll;
end

-- Lightweight table dumper for debugging rRoll/OOB payloads. Limits recursion to avoid huge output.
-- debugDump removed in production: keep function list minimal

function d6()
  local nRoll = math.random(1,6);
  return nRoll;
end

function d8()
  local nRoll = math.random(1,8);
  return nRoll;
end

function d10()
  local nRoll = math.random(1,10);
  return nRoll;
end

function d20()
  local nRoll = math.random(1,20);
  return nRoll;
end

function d38()
  local nRoll = math.random(1,38);
  return nRoll;
end

function computeDays(sTravelTime)
  local nDays = 60;

  if sTravelTime == "5d6" then
    nDays = d6() + d6() + d6() + d6() + d6();
  end
  if sTravelTime == "3d6" then
    nDays = d6() + d6() + d6();
  end
  if sTravelTime == "2d6" then
    nDays = d6() + d6();
  end
  if sTravelTime == "1d6" then
    nDays = d6();
  end

  if sTravelTime == "1d6+2" then
    nDays = d6() + 2;
  end
  if sTravelTime == "7d6" then
    nDays = d6() + d6() + d6() + d6() + d6() + d6() + d6();
  end
  if sTravelTime == "10d6" then
    nDays = d6() + d6() + d6() + d6() + d6() + d6() + d6() + d6() + d6() + d6();
  end

  return nDays;
end

function getPOC_System(nRoll)
  local sSystem = "";
  local sPort = "";

  for k, v in pairs(OGLData.getDestinationsPOC()) do
    -- convert string to number
    local nValue = tonumber(k);
    -- system="Pact Worlds", port="All God's Rest" },
    if nRoll == nValue then
      sSystem = v["system"];
      sPort = v["port"];
    end
  end
  return sSystem;
end
function getPOC_Port(nRoll)
  local sSystem = "";
  local sPort = "";

  for k, v in pairs(OGLData.getDestinationsPOC()) do
    -- convert string to number
    local nValue = tonumber(k);
    -- system="Pact Worlds", port="All God's Rest" },
    if nRoll == nValue then
      sSystem = v["system"];
      sPort = v["port"];
    end
  end
  return sPort;
end

function getLocation(sSystem)
  local sName = "(destination port)";
  if sSystem == "Pact Worlds" then
    local nRoll = math.random(1,31);
    sName = OGLData.getPactWorldPort(nRoll);
  end
  if sSystem == "Near Space" then
    local nRoll = math.random(1,20);
    sName = OGLData.getNearSpacePort(nRoll);
  end
  if sSystem == "the Vast" then
    local nRoll = math.random(1,14);
    sName = OGLData.getVastPort(nRoll);
  end
  Debug.console("getLocation: " .. sSystem .. " , " .. sName);
  return sName;
end

function getSellBP()
  local nRoll = d8();
  if nRoll == 8 then
    nRoll = nRoll + d8();
  end
  return nRoll;
end

function updateInsurance()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nInsurance","",0);
  local tActions = DB.getChildren("galacticTrade.insurance_list");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local nCost = DB.getChild(nodeAction,"nCost").getValue();
    nTotal = nTotal + nCost;
  end

  DB.findNode("galacticTrade.nInsurance").setValue(nTotal);
end

function updateSupplies()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nSupplies","",0);
  local tActions = DB.getChildren("galacticTrade.supplies_list");
  local nTotal = 0;

  local nToday = DB.getValue("galacticTrade.nDays", 0);

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local nCost = DB.getChild(nodeAction,"nCost").getValue();
    local nDate = DB.getChild(nodeAction,"nDate").getValue();

    local nExpired = nDate + 30;
    if sf.isGt(nToday,nExpired) then
      nCost = 0;  -- expired
    end
    if sf.isGe(nExpired, nToday) and sf.isGe(nToday, nDate) then
      nCost = 0; -- in use
    end
    nTotal = nTotal + nCost;
  end

  DB.findNode("galacticTrade.nLifestyle").setValue(nTotal);
end

function updateStarships()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nStarships","",0);
  local tActions = DB.getChildren("galacticTrade.starships_list");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local nCost = DB.getChild(nodeAction,"nCost").getValue();
    nTotal = nTotal + nCost;
  end

  DB.findNode("galacticTrade.nStarships").setValue(nTotal);
end

function updateExpansions()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nExpansions","",0);
  local tActions = DB.getChildren("galacticTrade.expansion_list");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local nCost = DB.getChild(nodeAction,"nCost").getValue();
    nTotal = nTotal + nCost;
  end

  DB.findNode("galacticTrade.nExpansions").setValue(nTotal);
end

function updateCargo()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nCargo","",0);
  local tActions = DB.getChildren("galacticTrade.cargo_list");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local nBuy = DB.getValue(nodeAction,"nBuy",0); -- DB.getChild(nodeAction,"nBuy").getValue();
    nTotal = nTotal + nBuy;
  end

  DB.findNode("galacticTrade.nCargo").setValue(nTotal);
  -- Debug.console("updateCargo: " .. nCargo .. " updated to " .. nTotal);
end

function getCargoName(nRoll)
  local sName = OGLData.getCargoTypes(nRoll);
  Debug.console(nRoll .. " : " .. sName);
  return sName;
end

function getDestination(nRoll)
  local sName = OGLData.getDestSystem(nRoll);
  Debug.console(nRoll .. " : " .. sName);
  return sName;
end

function getDestinationRoll(sDest)
  local nRoll = 0;
  nRoll = OGLData.getDestSystemRoll(sDest);
  Debug.console("getDestinationRoll: " .. sDest .. " = nRoll " .. nRoll);
  return nRoll;
end

function getDestSellMod(nRoll)
  local sName = OGLData.getDestSellMod(nRoll);
  Debug.console(nRoll .. " : " .. sName);
  return sName;
end

function getDestTravel(nRoll)
  local sName = OGLData.getTravelTime(nRoll);
  Debug.console(nRoll .. " : " .. sName);
  return sName;
end

-- cargo complication name
function getCompName(nRoll)
  local sName = OGLData.getCargoCompName(nRoll);
  --Debug.console(nRoll .. " : " .. sName);
  return sName;
end

-- cargo complication name
function getCompDetail(nRoll)
  local sName = OGLData.getCargoCompDetail(nRoll);
  --Debug.console(nRoll .. " : " .. sName);
  return sName;
end


--
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- nAPL
function getBuyDC(nAPL)
  local nDC = 10 + math.floor(1.5*nAPL);
  return nDC;
end
function getSellDC(nAPL)
  local nDC = 15 + math.floor(1.5*nAPL);
  return nDC;
end

function stringRemoveMod(sActionName)
  local sName = sActionName;
  local sDelimiter = " %[";
  local nParen = string.find(sActionName, sDelimiter);

  if nParen then 
    sName = string.sub(sActionName,1,(nParen -1));
  end
  return sName;
end

  -- Updates melee and ranged attack strings based on metadata and BAB
  function updateAttackStrings(nodeCompanion)
    -- Get BAB
    local nBAB = DB.getValue(nodeCompanion, "attackbonus_base", 0)
    -- Get level
    local nLevel = DB.getValue(nodeCompanion, "level", 1)

    -- Helper to extract name from attack string
    local function extractName(sAttack, sDefault)
      -- Try to get the name before any + or (
      local sName = sAttack:match("^%s*([%a%s%-']+)")
      if sName and #sName > 0 then
        return sName:gsub("%s+$", "")
      end
      return sDefault
    end

    -- Melee
    local sMelee = DB.getValue(nodeCompanion, "melee", "");
    local sMeleeName = extractName(sMelee, "melee");
    local sMeleeDamage = CompanionData.getLevelMeleeDamage and CompanionData.getLevelMeleeDamage(nLevel) or "";
    local sNewMelee = string.format("%s +%d (%s)", sMeleeName, nBAB, sMeleeDamage);
    DB.setValue(nodeCompanion, "melee", "string", sNewMelee);

    -- Ranged
    local sRanged = DB.getValue(nodeCompanion, "ranged", "");
    local sRangedName = extractName(sRanged, "ranged");
    local sRangedDamage = CompanionData.getLevelRangedDamage and CompanionData.getLevelRangedDamage(nLevel) or "";
    local sNewRanged = string.format("%s +%d (%s)", sRangedName, nBAB, sRangedDamage);
    DB.setValue(nodeCompanion, "ranged", "string", sNewRanged);
  end

function sendChat(sMessage, bGMonly)
  local rMessage = ChatManager.createBaseMessage("ChatAction", nValue);
  if bGMonly == nil then 
    bGMonly = false;
  end
  rMessage.text = rMessage.text .. sMessage;
  rMessage.icon = "";
  rMessage.font = "reference-i";
  rMessage.secret = bGMonly;
  Comm.deliverChatMessage(rMessage);
end

function sendMsg(sMessage, sFontName)
  local rMessage = ChatManager.createBaseMessage("ChatAction", nValue);

  rMessage.text = rMessage.text .. sMessage;
  rMessage.icon = "";
  rMessage.font = sFontName;
  rMessage.secret = false;
  Comm.deliverChatMessage(rMessage);
end



function recalcDate()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nCargo","",0);
  local tActions = DB.getChildren("galacticTrade.cargo_log");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nTravel = DB.getValue(nodeAction, "nTravelTime",0); --   DB.getChild(nodeAction,"nTravel").getValue();
    nTotal = nTotal + nTravel;
  end

  DB.findNode("galacticTrade.nDate").setValue(nTotal);
  Debug.console("recalcDate: " .. nTotal);
end

function recalcIncome()
  if not Session.IsHost then
    return;
  end

  local nCargo = DB.getValue("galacticTrade.nCargo","",0);
  local tActions = DB.getChildren("galacticTrade.cargo_log");
  local nTotal = 0;

  -- hide any without required skill training
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nProfit = DB.getValue(nodeAction, "nProfit",0); --DB.getChild(nodeAction,"nProfit").getValue();
    nTotal = nTotal + nProfit;
  end

  DB.findNode("galacticTrade.nBP").setValue(nTotal);
  Debug.console("recalcIncome: " .. nTotal);
end

function getParadox(nDice)
  -- returns the related paradox value
  local nValue = DB.getValue("galacticTrade.nParadox" ..  nDice,"",0);
  return nValue;					  
end

function setParadox(nDice, nValue)
  local sParadox = "galacticTrade.nParadox" .. nDice;
  -- Prefer authoritative host-side DB updates. If the node doesn't exist, create it with an explicit type so clients can read it.
  if Session.IsHost then
    -- Create or set the child value under the galacticTrade root with explicit type
    -- setValue(sourcenode, [subpath], type, value)
    DB.findNode(sParadox).setValue(nValue);
    Debug.console("setParadox: " .. sParadox .. " set to " .. tostring(nValue));
  end
end

function updateParadox(nDice, nValue)
  if Session.IsHost then
    setParadox(nDice, nValue)
    return;
  end
  -- client: send numeric OOB
  local msgOOB = {};
  msgOOB.type = OOBhandler.OOB_MSGTYPE_PARADOX_DICE;
  msgOOB.nDice = nDice;
  msgOOB.nValue = nValue;
  Debug.console("OOB send (numeric)");
  Comm.deliverOOBMessage(msgOOB);
end

-- update by DB node path: preferred for list-item rolls
function updatepNode(dbNode, nValue)
  if Session.IsHost then
    local pNode = DB.findNode(dbNode);
    if pNode then
  pNode.setValue(nValue);
  Debug.console("updatepNode: set " .. tostring(dbNode) .. " = " .. tostring(nValue));
    else
  Debug.console("updatepNode: cannot find node " .. tostring(dbNode));
    end
    return;
  end
  -- client: send OOB with path
  local msgOOB = {};
  msgOOB.type = OOBhandler.OOB_MSGTYPE_PARADOX_DICE;
  msgOOB.dbNode = dbNode;
  msgOOB.nValue = nValue;
  Debug.console("OOB send (path)");
  Comm.deliverOOBMessage(msgOOB);
end

function testOGL(orgLevel)
	local msg = "ORG (" .. orgLevel .. ") max followers (";	

	for k, v in pairs(OGLData.getOrganizations()) do
		if k == orgLevel then
			msg = msg .. v["followers"];
		end
 	end
	msg = msg .. ")";
	ChatManager.SystemMessage(msg);
	Debug.console(msg);
end

-- followers, members, member_CR, officers, officer_CR, power --
function ORG_followers(orgLevel)
	local followers = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			followers = tonumber(v["followers"]);
		end
 	end
	return followers;
end
function ORG_members(orgLevel)
	local members = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			members = tonumber(v["members"]);
		end
 	end
	return members;
end
function ORG_members_CR(orgLevel)
	local members_CR = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			members_CR = tonumber(v["members_CR"]);
		end
 	end
  -- Debug.console("members_CR=" .. members_CR);
	return members_CR;
end
function ORG_officers(orgLevel)
	local officers = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			officers = tonumber(v["officers"]);
		end
 	end
	return officers;
end
function ORG_officers_CR(orgLevel)
	local officers_CR = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			officers_CR = tonumber(v["officers_CR"]);
		end
 	end
	return officers_CR;
end
function ORG_power(orgLevel)
	local power = 0;	

	for k, v in pairs(OGLData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			power = tonumber(v["power"]);
		end
 	end
	return power;
end

-- count total officers
function countOfficers(sDBnode)
  if not Session.IsHost then
    return;
  end

  if sDBnode == nil or sDBnode == "" then
    return;
  end

  Debug.console("countFollowers: " .. DB.getText(sDBnode));
  

  local tActions = DB.getChildren(sDBnode);
  local nTotal = 0;

  -- count officers
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nRank = DB.getChild(nodeAction,"npc_rank").getValue();
    if nRank == 2 then
      nTotal = nTotal + 1;
    end
    Debug.console("countOfficers: " .. sName .. " rank=" .. nRank);
  end

  DB.findNode("galacticTrade.nOfficers").setValue(nTotal);
  Debug.console("countOfficers: " .. nTotal);
end

-- count total members
function countMembers(sDBnode)
  if not Session.IsHost then
    return;
  end

  Debug.console("countFollowers: " .. sDBnode);
  if sDBnode == nil or sDBnode == "" then
    return;
  end

  local tActions = DB.getChildren(sDBnode);
  local nTotal = 0;

  -- count members
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nRank = DB.getChild(nodeAction,"npc_rank").getValue();
    if (nRank == 1) then
      nTotal = nTotal + 1;
    end
    Debug.console("countMembers: " .. sName .. " rank=" .. nRank);
  end

  DB.findNode("galacticTrade.nMembers").setValue(nTotal);
  Debug.console("countMembers: " .. nTotal);
end

-- count total followers
function countFollowers(sDBnode)
  if not Session.IsHost then
    return;
  end

  Debug.console("countFollowers: " .. sDBnode);
  if sDBnode == nil or sDBnode == "" then
    return;
  end

  local tActions = DB.getChildren(sDBnode);
  local nTotal = 0;

  -- count followers
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nRank = DB.getChild(nodeAction,"npc_rank").getValue();
    if (nRank == "0") then
      nTotal = nTotal + 1;
    end
    Debug.console("countFollowers: " .. sName .. " rank=" .. nRank);    
  end

  DB.findNode("galacticTrade.nFollowers").setValue(nTotal);
  Debug.console("countFollowers: " .. nTotal);
end



-- Distribute NPCs across levels based on total members and max level
-- This function ensures that each level has at least one NPC and distributes the remaining members
function distributeNPCs(total_members, max_level)
    local distribution = {}
    local remaining_members = total_members

    -- Step 1: Assign one NPC to each level
    for level = max_level, 1, -1 do
        if remaining_members <= 0 then
          distribution[level]=0;
        else
          distribution[level] = 1
          remaining_members = remaining_members - 1
        end
    end

    -- Step 2: Iteratively balance from the lowest level up
     while remaining_members > 0 do
        local next_level = findNextLevel(1, max_level, distribution);
        distribution[next_level] = distribution[next_level] + 1
        remaining_members = remaining_members - 1
    end


    return distribution
end

-- Function to determine the next level to assign an NPC
function findNextLevel(curr_level, max_level, distribution)
  -- If we've reached the max level, return it
  if curr_level == max_level then
    return curr_level;
  end

  -- check if any of the levels from top down are still zero
  for nLevel = max_level, 1, -1 do
    if distribution[nLevel] == 0 then
      return nLevel;
    end
  end

  -- If the current level has less than twice the next level, return this level for assignment
  local nCurrent = distribution[curr_level];
  local nNext = distribution[curr_level + 1];
  -- If the current level has less than twice the next level, return this level for assignment
  if nCurrent < (2 * nNext) then
    return curr_level;
  end

  return findNextLevel(curr_level + 1, max_level, distribution);
end


function testMembers(orgLevel)
    if orgLevel == nil or orgLevel < 1 or orgLevel > 20 then
        Debug.console("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_members(orgLevel);
    local max_CR = ORG_members_CR(orgLevel);
    local max_level = convertCRtoLevel(max_CR);

    Debug.console("Org level: " .. orgLevel .. " has Total members: " .. total_members .. ", Max CR: " .. max_CR);
    local hierarchy = distributeNPCs(total_members, max_level)

    -- Print results
    printDistribution(hierarchy, max_level);
end

function distributeMembers(orgLevel)
    if orgLevel == nil or orgLevel < 1 or orgLevel > 20 then
        Debug.console("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_members(orgLevel);
    local max_CR        = ORG_members_CR(orgLevel);
    local max_level     = convertCRtoLevel(max_CR);

    Debug.console("Org level: " .. orgLevel .. " has Total members: " .. total_members .. ", Max CR: " .. max_CR);
    local hierarchy = distributeNPCs(total_members, max_level)

    -- Print results
    local output = "Members Distribution\n\n" .. "   CR : NPCs\n";
    for level = max_level, 1, -1 do
    local sCR = 0.0;
    -- Format CR based on level
    if level > 2 then
      sCR = string.format(" %5.0f", convertLevelToCR(level));
    else
      sCR = string.format("%3.1f", convertLevelToCR(level));
    end
    local nCount = string.format("%3d", hierarchy[level]);
    output = output .. string.format("%5s : %3d \n",sCR,nCount);
  end
  return output;
end

function distributeOfficers(orgLevel)
  if orgLevel == nil or orgLevel < 1 or orgLevel > 20 then
    Debug.console("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
    orgLevel = math.random(1, 20);
  end
  local total_members = ORG_officers(orgLevel);
  local max_CR        = ORG_officers_CR(orgLevel);
  local max_level     = convertCRtoLevel(max_CR);

  Debug.console("Org level: " .. orgLevel .. " has Total officers: " .. total_members .. ", Max CR: " .. max_CR);
  local hierarchy = distributeNPCs(total_members, max_level)

  -- Print results
  local output = "Officers Distribution\n\n" .. "   CR : NPCs\n";
  for level = max_level, 1, -1 do
    local sCR = 0.0;
    -- Format CR based on level
    if level > 2 then
      sCR = string.format(" %5.0f", convertLevelToCR(level));
    else
      sCR = string.format("%3.1f", convertLevelToCR(level));
    end
    local nCount = string.format("%3d", hierarchy[level]);
    output = output .. string.format("%5s : %3d \n",sCR,nCount);
  end
  return output;
end

function testOfficers(orgLevel)
    if orgLevel == nil or orgLevel < 1 or orgLevel > 20 then
        Debug.console("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_officers(orgLevel);
    local max_CR        = ORG_officers_CR(orgLevel);
    local max_level = convertCRtoLevel(max_CR);

    Debug.console("Org level: " .. orgLevel .. " has Total officers: " .. total_members .. ", Max CR: " .. max_CR);
    local hierarchy = distributeNPCs(total_members, max_level)

    -- Print results
    printDistribution(hierarchy, max_level);
end

function printDistribution(hierarchy, max_level)
  for level = max_level, 1, -1 do
        local sCR = convertLevelToCR(level);
        Debug.console("CR " .. convertLevelToCR(level) .. " : " .. hierarchy[level] .. " NPCs");
    end
end

function convertLevelToCR(level)
    local levelMap = {0.3, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9} -- Mapping levels 1 to 11

    if level >= 1 and level <= #levelMap then
        return levelMap[level] -- Return the corresponding CR value
    else
        return 0; -- Handle cases where level is out of range
    end
end

function convertCRtoLevel(CR)
    local levelMap = {0.3, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9} -- Mapping levels 1 to 11

    for level, value in ipairs(levelMap) do
        if value == CR then
            return level -- Return the corresponding level
        end
    end

    return 0; -- Handle cases where CR is not found
end

-- dumpGalacticTrade removed: keep runtime logs minimal
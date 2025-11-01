-- enable to view more terse debug messages
DEBUG_CONSOLE = false;

function ErrorOut(sMessage)
  if Session.IsHost then
    Debug.console("ERROR: " .. sMessage);
  end
end

function DebugOut(sMessage)
  if DEBUG_CONSOLE == true then
    Debug.console(sMessage);
  end
end

function isDebug()
  return DEBUG_CONSOLE;
end

function enableDebug()
  DEBUG_CONSOLE=true;
end

function disableDebug()
  DEBUG_CONSOLE=false;
end

-- comparison helpers
function isGt(nValue, nTest)
  return (nValue > nTest);
end
function isGe(nValue, nTest)
  return (nValue >= nTest);
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

-- followers, members, member_CR, officers, officer_CR, power --
function ORG_followers(orgLevel)
	local followers = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			followers = tonumber(v["followers"]);
		end
 	end
	return followers;
end
function ORG_members(orgLevel)
	local members = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			members = tonumber(v["members"]);
		end
 	end
	return members;
end
function ORG_members_CR(orgLevel)
	local members_CR = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			members_CR = tonumber(v["members_CR"]);
		end
 	end
  sf.DebugOut("members_CR=" .. members_CR);
	return members_CR;
end
function ORG_officers(orgLevel)
	local officers = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			officers = tonumber(v["officers"]);
		end
 	end
	return officers;
end
function ORG_officers_CR(orgLevel)
	local officers_CR = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
		if tonumber(k) == orgLevel then
			officers_CR = tonumber(v["officers_CR"]);
		end
 	end
	return officers_CR;
end
function ORG_power(orgLevel)
	local power = 0;	

	for k, v in pairs(OrganizationData.getOrganizations()) do
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

  sf.DebugOut("countFollowers: " .. DB.getText(sDBnode));
  

  local tActions = DB.getChildren(sDBnode);
  local nTotal = 0;

  -- count officers
  for _,nodeAction in pairs(tActions) do
    local sName = DB.getChild(nodeAction,"sName").getValue();
    local nRank = DB.getChild(nodeAction,"npc_rank").getValue();
    if nRank == 2 then
      nTotal = nTotal + 1;
    end
    sf.DebugOut("countOfficers: " .. sName .. " rank=" .. nRank);
  end

  DB.findNode("galacticTrade.nOfficers").setValue(nTotal);
  sf.DebugOut("countOfficers: " .. nTotal);
end

-- count total members
function countMembers(sDBnode)
  if not Session.IsHost then
    return;
  end

  sf.DebugOut("countFollowers: " .. sDBnode);
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
    sf.DebugOut("countMembers: " .. sName .. " rank=" .. nRank);
  end

  DB.findNode("galacticTrade.nMembers").setValue(nTotal);
  sf.DebugOut("countMembers: " .. nTotal);
end

-- count total followers
function countFollowers(sDBnode)
  if not Session.IsHost then
    return;
  end

  sf.DebugOut("countFollowers: " .. sDBnode);
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
    sf.DebugOut("countFollowers: " .. sName .. " rank=" .. nRank);    
  end

  DB.findNode("galacticTrade.nFollowers").setValue(nTotal);
  sf.DebugOut("countFollowers: " .. nTotal);
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
        sf.DebugOut("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_members(orgLevel);
    local max_CR = ORG_members_CR(orgLevel);
    local max_level = convertCRtoLevel(max_CR);

    sf.DebugOut("Org level: " .. orgLevel .. " has Total members: " .. total_members .. ", Max CR: " .. max_CR);
    local hierarchy = distributeNPCs(total_members, max_level)

    -- Print results
    printDistribution(hierarchy, max_level);
end

function distributeMembers(orgLevel)
    if orgLevel == nil or orgLevel < 1 or orgLevel > 20 then
        sf.DebugOut("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_members(orgLevel);
    local max_CR        = ORG_members_CR(orgLevel);
    local max_level     = convertCRtoLevel(max_CR);

    sf.DebugOut("Org level: " .. orgLevel .. " has Total members: " .. total_members .. ", Max CR: " .. max_CR);
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
    sf.DebugOut("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
    orgLevel = math.random(1, 20);
  end
  local total_members = ORG_officers(orgLevel);
  local max_CR        = ORG_officers_CR(orgLevel);
  local max_level     = convertCRtoLevel(max_CR);

  sf.DebugOut("Org level: " .. orgLevel .. " has Total officers: " .. total_members .. ", Max CR: " .. max_CR);
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
        sf.ErrorOut("Invalid orgLevel: " .. tostring(orgLevel) .. ". Using random level.");
        orgLevel = math.random(1, 20);
    end
    local total_members = ORG_officers(orgLevel);
    local max_CR        = ORG_officers_CR(orgLevel);
    local max_level = convertCRtoLevel(max_CR);

    sf.DebugOut("Org level: " .. orgLevel .. " has Total officers: " .. total_members .. ", Max CR: " .. max_CR);
    local hierarchy = distributeNPCs(total_members, max_level)

    -- Print results
    printDistribution(hierarchy, max_level);
end

function printDistribution(hierarchy, max_level)
  for level = max_level, 1, -1 do
        local sCR = convertLevelToCR(level);
        sf.DebugOut("CR " .. convertLevelToCR(level) .. " : " .. hierarchy[level] .. " NPCs");
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

-- Chat message helpers
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

local sf_organization_help_text = "<h>Organizations</h><p>Every organization has the following characteristics. See the Organizations table below for level-based guidance on an organization's statistics.</p><p><b>Level:</b> Each organization has a level, which helps inform its other statistics and is generally equal to 2 lower than the PCs' level. The GM might allow extra adventures to raise it to a maximum of 2 higher than the PCs' level.</p><p><b>Followers:</b> These people aren't a formal part of the organization but devote some share of their energies to it. They might be loyal customers, adoring fans, social media followers, voters, worshipers, and so forth. Followers have their own lives but are reasonably dedicated to the organization. For every follower, there are another five to 10 people with a casual interest toward the organization. Followers are always CR 1/3.</p><p><b>Members:</b> These people are full-time members of the organization. They're a military organization's soldiers, a political campaign's permanent staff and volunteers, or a business's employees. They carry out their assigned duties and are assumed to be loyal—but not fanatically so—to the organization's leadership. Members are much lower CR than the PCs' level. While membership covers a spread of CRs, generally, each higher CR has half as many people in it as the CR before it; for example, a 6th-level organization with 14 members will probably have two CR 1 members, four CR 1/2 members, and eight CR 1/3 members.</p><p><b>Lieutenants:</b> These people are more important full-time employees of the organization—the priests, the military officers, the social media representatives, and so forth. They follow the same CR spread as members. Often, one or more lieutenants will be fully realized NPCs, serving as figureheads for the organization.</p><p><b>Power:</b> At the GM's discretion, an organization can be called upon to act mechanically by performing skill checks. Perhaps a PC-run military unit can identify a new alien threat, or the promoter for the PCs' music group can try to score a record deal. In this case, the PCs roll a d20 on behalf of the organization and add its power bonus. The GM determines whether the organization can use the appropriate skill and assigns the DC according to the difficulty of what the PCs attempt to achieve.</p>";

function getSF_organization_help_text()
  return sf_organization_help_text;
end

local pcOrganizations = {
    ["1"] =  { followers=      "10", members=   "2", members_CR="0.3", officers=  "0", officers_CR="0", power= "5" },
    ["2"] =  { followers=      "25", members=   "4", members_CR="0.3", officers=  "0", officers_CR="0", power= "7" },
    ["3"] =  { followers=      "50", members=   "6", members_CR="0.3", officers=  "1", officers_CR="1", power= "8" },
    ["4"] =  { followers=     "100", members=   "9", members_CR="0.5", officers=  "1", officers_CR="1", power="10" },
    ["5"] =  { followers=     "250", members=  "13", members_CR="0.5", officers=  "1", officers_CR="1", power="12" },

    ["6"] =  { followers=     "500", members=  "18", members_CR=  "1", officers=  "2", officers_CR="2", power="13" },
    ["7"] =  { followers=    "1000", members=  "27", members_CR=  "1", officers=  "2", officers_CR="2", power="15" },
    ["8"] =  { followers=    "2500", members=  "36", members_CR=  "1", officers=  "3", officers_CR="3", power="16" },
    ["9"] =  { followers=    "5000", members=  "53", members_CR=  "1", officers=  "5", officers_CR="3", power="18" },
    ["10"] = { followers=   "10000", members=  "75", members_CR=  "2", officers=  "7", officers_CR="4", power="19" },

    ["11"] = { followers=   "25000", members=  "99", members_CR=  "2", officers= "10", officers_CR="4", power="21" },
    ["12"] = { followers=   "50000", members= "150", members_CR=  "2", officers= "15", officers_CR="5", power="22" },
    ["13"] = { followers=  "100000", members= "215", members_CR=  "2", officers= "22", officers_CR="5", power="24" },
    ["14"] = { followers=  "250000", members= "300", members_CR=  "3", officers= "30", officers_CR="6", power="25" },
    ["15"] = { followers=  "500000", members= "425", members_CR=  "3", officers= "42", officers_CR="6", power="27" },

    ["16"] = { followers= "1000000", members= "600", members_CR=  "3", officers= "60", officers_CR="7", power="28" },
    ["17"] = { followers= "2500000", members= "850", members_CR=  "3", officers= "85", officers_CR="7", power="30" },
    ["18"] = { followers= "5000000", members="1200", members_CR=  "4", officers="120", officers_CR="8", power="31" },
    ["19"] = { followers="10000000", members="1700", members_CR=  "4", officers="170", officers_CR="8", power="33" },
    ["20"] = { followers="99999999", members="2400", members_CR=  "4", officers="240", officers_CR="9", power="35" }
  }

function getOrganizations()
  return pcOrganizations;
end

function getORGdata(nLevel)
  if (nLevel < 1) then
    nLevel = 1;
  end
  if (nLevel > 20) then
    nLevel = 20;
  end

  return pcOrganizations[nLevel];
end

function orgFollowers(nLevel)
  if (nLevel < 1) then
    nLevel = 1;
  end
  if (nLevel > 20) then
    nLevel = 20;
  end
    
  return getORGdata(nLevel)["followers"];
end

function getLeadershipText()
  local sfText= "<b>LEADERSHIP SYSTEM</b><p>In this leadership system, PCs manage an organization: a group of people with some sense of collective identity. The party is in charge as a group, although a single PC might serve as the nominal head. For instance, one PC might take on the position of CEO for a business with the other PCs representing members of the board or other high executives.</p><p>The leadership system isn't a mechanical boost or a campaign reward, nor is it strictly tied to a character's progression; rather, the system follows the logic of an ongoing campaign. In some cases, running and improving the PCs' organization could be central to the campaign's victory conditions.</p><p>Perhaps the PCs are underbosses of an Akitonian crime ring, and their goal in the campaign is to forge an interstellar criminal network stretching from Verces to Absalom Station. The organization might exist in the background, allowing for a different style of campaign to unfold. Perhaps the PCs command a deep-space exploratory vessel, and the organization is their trusty crew, gaining in ability and confidence just as the PCs do.</p><p>The leadership system here presents a framework that GMs and other players can flesh out together, depending on the circumstances of their campaign, and can represent anything from the Corpse Fleet to the Absalom Station Orchid Fanciers' Club.</p><p><b>ORGANIZATIONS</b></p><p>Tending a gradually growing organization is a satisfying use of leadership in a campaign that features it; the players succeed when their organization does, and they gradually become potentates of various sorts. There are several other ways to use organizations more actively in a campaign.</p><p>A campaign that has the PCs running an organization should occasionally call for power checks, much as it might call for Diplomacy or Stealth checks. If the PCs lead a band, for instance, they might use their organization's power checks to get into restricted social gatherings, mobilize flash mobs, or sic lawyers on those using their music without permission.</p><p>Organizations can serve as sources of friendly NPCs and safe locations, and a campaign that features an organization should give the PCs plenty of chances to talk with their allies, employees, and supporters. Giving players a chance to customize a home base or the ability to recruit NPCs they like into their organization can lead to fun storytelling opportunities.</p><p>Finally, the organization can serve as a source of plot points and adventures for the PCs, who are the highest-level and most powerful characters in the organization and likely to be called on when trouble arises. However, GMs should be cautious about making the organization feel like a liability. Ideally, the PCs should want to initiate adventures themselves to expand or strengthen their organization.</p>";
  return sfText;
end
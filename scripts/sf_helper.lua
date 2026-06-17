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


-- comparison helpers
function isGt(nValue, nTest)
  return (nValue > nTest);
end
function isGe(nValue, nTest)
  return (nValue >= nTest);
end

function defaultOrgName()
  return "<< NPC Org >>";
end

function defaultNPCname()
  return "<< Org NPC  >>";
end

function defaultName(sName)
  return "<< " .. sName .. " >>";
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

function getText_StarshipCriticals()
  local sfText ="<h>Rolling a natural 20</h> \
  <p>This is a list of the optional ways to give any crew member the potential to achive extraordinary results when attempting starship crew actions.</p>\
<p><h>Captain Actions</h></p>\
  <p><b>Demand</b></p>\
  <p>You can attempt the demand crew action with the targeted crew member one additional time during the current starship combat.</p>\
  <p><b>Encourage</b></p>\
  <p>Increase the bonus granted to the target crew member's action to +4</p>\
  <p><b>Moving Speech</b></p>\
  <p>Your crew members also gain +2 bonus to all checks that phase, as if you had used the encourage action to aid them all.</p>\
  <p><b>Orders</b></p>\
  <p>You can take one additional crew action during this turn.</p>\
  <p><b>Taunt</b></p>\
  <p>The penalty your taunt action applies to an enemy ship continues through all three phases of combat instead of just one.</p>\
<p><h>Chief Mate Actions</h></p>\
  <p><b>Hard Turn</b></p>\
  <p>You improve the manueverability of your ship by one step until the start of the next turn.</p>\
  <p><b>Maintenance Panel Access</b></p>\
  <p>The next time an engineer attempts an Engineering check to divert power, they can roll twice and use the better result.</p>\
  <p><b>Manual Realignment</b></p>\
  <p>The next time a science officer attempts a Computers check to scan, they can roll twice and use the better result.</p>\
  <p><b>Maximise Speed</b></p>\
  <p>The speed of the starship increases by 2 until the end of the next turn.</p>\
  <p><b>Targeting Aid</b></p>\
  <p>Choose an enemy starship, all gunners on your starship gain the benefits of the targeting aid crew action until the end of the turn.</p>\
<p><h>Engineer Actions</h></p>\
  <p><b>Divert</b></p>\
  <p>The results depend on where the extra power was sent.<list><li><b>Engines</b>Lower the turn value by 1 this round.</li><li><b>Sensors</b>Science officers can roll their checks twice and keep the better result.</li><li><b>Shields</b>Restore 10% of PCU instead of 5% and retain any extra HP until the start of the next turn.</li><li><b>Weapons</b>Treat any weapon dice roll of 1 as the maximum value instead.</li></list></p>\
  <p><b>Hold it Together</b></p>\
  <p>Treat the targeted ships system critical level as two steps lower for 1d4 rounds.</p>\
  <p><b>Overpower</b></p>\
  <p>One of the three targeted systems also benefits of the Divert critical effect.</p>\
  <p><b>Patch</b></p>\
  <p>If the targeted system recieves another critical hit, it removes the patch but doesnt trigger additional critical damage.</p>\
  <p><b>Quick Fix</b></p>\
  <p>Your efforts results in a lasting repair, remove the critical damage condition from the system for 1 day instead of 1 hour.</p>\
<p><h>Magic Officer Actions</h></p>\
  <p><b>Eldritch Shot</b></p>\
  <p>On your next attack with the augmented weapon, treat each damage die roll that results in a 1 as a 2 instead.</p>\
  <p><b>Mystic Haze</b></p>\
  <p>The granted enhancement bonus to AC increases to +2 and also affects your starship TL.</p>\
  <p><b>Precognition</b></p>\
  <p>Increase your starship's circumstance bonus to the Piloting check by +4.</p>\
  <p><b>Psychic Currents</b></p>\
  <p>Increase your starship's speed by 2 until the start of the next turn.</p>\
  <p><b>Scrying</b></p>\
  <p>The next time one of your starship's weapons deal damage to the targeted ships Hull Points, it has a 25% chance to also deal critical damage to a random system.</p>\
<p><h>Pilot Actions</h></p>\
  <p><b>Audacious Gambit</b></p>\
  <p>You gain a +4 circumstance bonus to your ships AC and TL until the start of the next round.</p>\
  <p><b>Full Power</b></p>\
  <p>Add only 1 to your starship's distance between turns.</p>\
  <p><b>Manuever</b></p>\
  <p>You gain the effects of a successful evade stunt until the start of the next turn.</p>\
  <p><b>Stunt</b></p>\
  <p>The results differ depending on the specific stunt performed.</p><list><li><b>Back Off</b>Your starship can move up to its full speed and make turns as normal.</li><li><b>Barrel Roll</b>You gain the effects of a successful evade stunt until the start of the next turn.</li><li><b>Evade</b>Increase the bonus to AC and TL by +4 instead.</li><li><b>Flip and Burn</b>The starship move up to its full speed without turning and then rotate 180 degrees to face the aft edge after the movement.</li><li><b>Flyby</b>The gunner gain a +2 circumstance bonus to the associated check.</li><li><b>Ramming Speed</b>You gain a +2 circumstance bonus to the gunnery check to ram and deal additional damage to the targeted starship equal to your starships tier.</li><li><b>Slide</b>At the end of the movement, your starship can turn once step.</li></list>\
<p><h>Science Officer Actions</h></p>\
  <p><b>Advanced ECM/Rapid Jam</b></p>\
  <p>Gunners aboard the target starship also suffer a -2 penalty to their gunnery checks during this round.</p>\
  <p><b>Balance</b></p>\
  <p>Before distributing the shield points, first add 5% of the PCU as if power had been diverted.</p>\
  <p><b>Improve Countermeasures</b></p>\
  <p>Gunners aboard the target starship take a -2 penalty to their gunnery checks during this round.</p>\
  <p><b>Insidious Electronics</b></p>\
  <p>You also gain critical effects of either the active ECM, scan or target systems science officer action (your choice).</p>\
  <p><b>Lock On</b></p>\
  <p>Until the start of the next round, any attacks by your starship score a critical hit on a natural roll of 19 or 20.</p>\
  <p><b>Recall Beacon</b></p>\
  <p>Upon moving to the warp puck's hex, your starship can turn to face any direction before starting to move.</p>\
  <p><b>Scan</b></p>\
  <p>The next time one of your starship's weapons deal damage to the targeted ships Hull Points, it has a 25% chance to also deal critical damage to a random system.</p>\
  <p><b>Target System</b></p>\
  <p>The effects of target system last until the start of the next round.</p>\
<p><h>Open Crew Actions</h></p>\
  <p><b>Lead Boarding Party</b></p>\
  <p>You inflict critical damage to an additional starship system, determined randomly.</p>";

  return sfText;
end


local sf_resolve_points_text =
  "<h>SPECIALIZED USES FOR RESOLVE POINTS</h> \
  <p>Specialized uses include new ways to use your Resolve Points. These are split into four categories: defensive, offensive, transport, and utility. As part of your daily preparations, you can select one new way to use your Resolve Points per category. Each specialized use that a character with Resolve Points selects can be used once per day.</p> \
  <h>Defensive Specialized Uses</h> \
  <p>This category covers primarily protective uses of Resolve Points.</p> \
    <p><b>Critical Cancellation:</b> As a reaction when an enemy critically hits you, you can spend Resolve Points to turn aside their attack. If you spend 1 Resolve Point, the attack doesn't trigger critical hit effects. If you spend 2 Resolve Points, that attack becomes a hit rather than a critical hit; its damage isn't doubled, and it doesn't trigger critical hit effects.</p> \
    <p><b>Extra Reaction:</b> When a reaction you have access to would be triggered, but you have already expended your reaction for the round, you can spend 1 Resolve Point to immediately gain a reaction. This allows you to use the triggered reaction. This doesn't allow you to use more than one reaction in response to the same trigger.</p> \
    <p><b>Inspiring Support:</b> When you successfully provide covering fire to an ally during combat, you can spend 1 Resolve Point to bolster that ally's spirits. If you do, that ally restores a number of Stamina Points equal to your level.</p> \
    <p><b>Invigorating Spell:</b> When you cast a harmless spell on an ally, you can spend 1 Resolve Point to adapt your spell to heal their wounds. If you do, that ally restores a number of Hit Points equal to the level of the spell x 2, in addition to the normal effects of the spell. If your spell would affect more than one ally, select one of those allies for this ability to affect.</p> \
    <p><b>Miraculous Recovery:</b> On your turn, if you have a condition which has a duration measured in rounds, you can spend a number of Resolve Points equal to one-quarter your maximum (minimum 1, maximum equal to the condition's remaining duration) to recover from the condition. At the beginning of your next turn, you lose the condition.</p> \
    <p><b>Sudden Resistance:</b> When you take damage from a significant enemy, you can spend 1 Resolve Point as a reaction to temporarily gain resistance—equal to your remaining Resolve Points—to the type of damage you were dealt, whether that damage was a type of kinetic (bludgeoning, piercing, or slashing) or energy (acid, cold, electricity, fire, or sonic) damage. If you were dealt energy damage, this is energy resistance against that energy type. If you were dealt more than one damage type, select one of those damage types to gain resistance to. In either case, this effect lasts for 3 rounds and doesn't apply against the damage that triggered the use of this ability.</p> \
  <h>Offensive Specialized Uses</h> \
  <p>This category covers uses of Resolve Points that pack an offensive punch.</p> \
    <p><b>Bolster Spell:</b> When you cast a spell, you can spend Resolve Points to increase the saving throw DC of that spell by 1 for each Resolve Point you spend. You can't increase the spell's DC higher than the DC of the highest-level spell that you can cast.</p> \
    <p><b>Double Critical:</b> If you critically hit with a weapon that has two or more critical hit effects, you can spend 1 Resolve Point to apply the effects of two critical hit effects, rather than one.</p> \
    <p><b>Expansive Critical:</b> When you roll initiative, you can spend a number of Resolve Points equal to one-quarter your maximum (minimum 1, maximum 3) to increase the ease with which you critically hit. For the duration of that combat, you apply critical hit effects when you roll a 19 or a 20 on the die and would hit your target, rather than only on a 20. This only applies your weapon's critical hit effect; it doesn't double the damage dealt by your attack.</p> \
    <p><b>Instant Reload:</b> You can spend 1 Resolve Point to reload a weapon you're holding without using an action. You must have the appropriate ammunition to reload your weapon in this way.</p> \
    <p><b>Momentary Proficiency:</b> When you're holding a weapon that you aren't proficient with, you can spend 1 Resolve Point to temporarily learn how to wield that weapon. For 1 minute, you become proficient with that specific weapon. If you're 3rd level or higher, you can spend 1 additional Resolve Point to also gain weapon specialization with that specific weapon for the same duration.</p> \
    <p><b>Sudden Stop:</b> When you damage a creature with an attack of opportunity that was triggered by that creature's movement, you can spend 2 Resolve Points to halt them in their tracks. If you do, their movement immediately ends.</p> \
  <h>Transport Specialized Uses</h> \
  <p>This category involves uses of Resolve Points related to vehicles, starships, and other forms of transport.</p> \
    <p><b>Boarding Expert:</b> When you board a vehicle, you can spend Resolve Points to increase your chances of success. If you spend 1 Resolve Point, you automatically succeed at any Acrobatics or Athletics check required to board. If you spend 2 Resolve Points, you automatically succeed at any Acrobatics or Athletics check required to board, and you don't provoke an attack of opportunity for boarding.</p> \
    <p><b>Efficient Racer:</b> When you're piloting a vehicle during a vehicle chase, you can spend 1 Resolve Point while taking a double maneuver action. If you do, you can take three pilot actions during that double maneuver, rather than two.</p> \
    <p><b>Masterful Mech Pilot:</b> If you take a full action to pilot a mech, you can spend 1 Resolve Point to grant the mech you're operating two additional move actions or standard actions that turn (in any combination), rather than one. This doesn't increase the maximum number of additional actions the mech can have per turn.</p> \
    <p><b>Opportunistic Positioning:</b> At the beginning of starship combat, if your positioning would be determined randomly, you can spend 1 Resolve Point to alter your starship's position. After the GM has placed the starships, you can do one of the following: change your facing or move your starship up to three hexes. If you spend 2 Resolve Points, you can do both.</p> \
    <p><b>Quick Modifications:</b> You can spend 1 Resolve Point to install or remove a vehicle modification in 10 minutes, rather than 4 hours.</p> \
    <p><b>Reliable Gunner:</b> When you fire a starship weapon during starship combat (such as by using the shoot, fire at will, or snap shot crew action), you can spend 1 Resolve Point to increase the range of one of the starship weapons you fire by 5 hexes. When you fire a weapon while on a moving vehicle, you can spend 1 Resolve Point to reduce the penalties to attack rolls imposed by the vehicle by 2.</p> \
    <p><b>Temporary Patch:</b> During starship combat, you can spend 1 Resolve Point to ignore the penalties your starship has accumulated from critical damage for the duration of your crew action. This doesn't apply to anyone else's crew actions, nor does it remove the critical damage condition from any systems.</p> \
  <h>Utility Specialized Uses</h> \
  <p>This category's uses of Resolve Points can be useful in a pinch.</p> \
    <p><b>Exceptional Aid:</b> When you attempt to aid another on a skill check, you can spend 1 Resolve Point to roll your skill check twice and use the higher result. If you succeed, the creature you're aiding gains a +3 bonus to their skill check, rather than the +2 you would usually grant.</p> \
    <p><b>Just the Thing:</b> As a standard action, you can reach into your backpack, pocket, or other suitable storage space, and spend Resolve Points to acquire an item you can afford but don't own. The item must have a bulk of 1 or less, and an item level no greater than your level - 1. You immediately lose a number of credits equal to the value of the item, as this ability assumes you prepurchased or traded for this item at some point in the past. If the item you pull out is a consumable item (such as a grenade, serum, or spell gem), you must spend 1 Resolve Point. Otherwise, you must spend a number of Resolve Points equal to half the item level.</p> \
    <p><b>Quick Fusion:</b> When you apply a fusion seal to a weapon, you can spend Resolve Points to reduce the time it takes for that fusion to function. If you spend 1 Resolve Point, that fusion seal functions after 10 minutes rather than the normal 24 hours. If you spend 2 Resolve Points, that fusion seal functions immediately after you transfer it.</p> \
    <p><b>Rapid Moves:</b> You can spend 1 Resolve Point to take an additional move action on your turn. You can't use this ability on a round that you take a full action.</p> \
    <p><b>Skilled Hacker:</b> When you take an additional major action during a dynamic hacking encounter (Starfinder Tech Revolution 70), you can spend 1 Resolve Point to ignore the cumulative penalty that taking that additional action would impose on your skill checks for the turn.</p><p></p>";

function getText_SpecializedResolvePoints()
  return sf_resolve_points_text;
end
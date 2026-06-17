--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local dbRootName = "SF_Helpers";


-- Initialization
function onInit()
	--- list extensions to help with debugging
	sf.sendChat("Loading QoL improvements for Starfinder 1e", true);

  -- add options
	registerOptions();

	if not Session.IsHost then
    return;
  end
  -- create the database root node
  local tNode = DB.createNode(dbRootName);
  DB.setPublic(tNode, true);
  
  -- load data from OGL
  -- loadOGLData();

	-- share the data to clients
	-- DB.findNode(dbRootName).setPublic(true);
end

function registerOptions()
    -- options for the new features added in this extension, all are ENABLED by default

    -- 1. **Character Ability Pop-Up** – Surfaces the full ability score recipe (base, racial/theme, boosts, gear) so you can track the base starting values, racial modifiers, boosts and item modifiers - rather than simply the total stat score.
    -- 2. **Vehicle Builder** – Provides a guided builder from the Vehicles tab. Start by setting the vehicle level which determines all of its metadata. Then pick grafts (size, type, specials) to define you vehicle, preview the math in real time, then spawn the finished vehicle record with a single click. This allows for rapid prototyping of new vehicles.
    -- 3. **Grenade Auto-Reloads** – Double-clicking a grenade weapon keeps the weapon `uses` node and the inventory stack in lockstep, instantly refunding or deducting grenades as they’re consumed.

    OptionsManager.registerOption2("SF_option_helper_ability_wizard", true, "SF_option_header_debug", "SF_option_helper_ability_wizard", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

    OptionsManager.registerOption2("SF_option_helper_vehicle_wizard", true, "SF_option_header_debug", "SF_option_helper_vehicle_wizard", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

    OptionsManager.registerOption2("SF_option_helper_grenade_autoreload", true, "SF_option_header_debug", "SF_option_helper_grenade_autoreload", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

    OptionsManager.registerOption2("SF_option_helper_starship_crits", true, "SF_option_header_debug", "SF_option_helper_starship_crits", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

    OptionsManager.registerOption2("SF_option_helper_resolve_usage", true, "SF_option_header_debug", "SF_option_helper_resolve_usage", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

    OptionsManager.registerOption2("SF_option_helper_companion_wizard", true, "SF_option_header_debug", "SF_option_helper_companion_wizard", "option_entry_cycler", 
      { labels = "SF_option_val_on", values = "on", baselabel = "SF_option_val_off", baseval = "off", default = "on" });

end

---Checks if the Ability Wizard is enabled
---@return boolean "true if option is on"
function isAbilityWizard_On()
	return OptionsManager.isOption("SF_option_helper_ability_wizard", "on");
end

---Checks if the Vehicle Wizard is enabled.
---@return boolean "true if option is on"
function isVehicleWizard_On()
	return OptionsManager.isOption("SF_option_helper_vehicle_wizard", "on");
end

---Checks if the Grenade Auto-Reload option is enabled.
---@return boolean "true if option is on"
function isGrenadeAutoReload_On()
	return OptionsManager.isOption("SF_option_helper_grenade_autoreload", "on");
end

---Checks if the Starship Crew Action Critical Effects option is enabled.
---@return boolean "true if option is on"
function isStarshipCrits_On()
	return OptionsManager.isOption("SF_option_helper_starship_crits", "on");
end

---Checks if the Resolve Usage option is enabled.
---@return boolean "true if option is on"
function isResolveUsage_On()
	return OptionsManager.isOption("SF_option_helper_resolve_usage", "on");
end

---Checks if the Companion Wizard is enabled
---@return boolean "true if option is on"
function isCompanionWizard_On()
	return OptionsManager.isOption("SF_option_helper_companion_wizard", "on");
end
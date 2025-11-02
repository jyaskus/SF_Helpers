--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local dbRootName = "organizations";
local createRequestWindowName = "popup_orgs";

-- set global or such for max fate


-- Initialization
function onInit()
	--- list extensions to help with debugging
	sf.sendChat("Loading QoL improvements for Starfinder 1e", true);

	-- add icons
	-- registerButtons();	

	if Session.IsHost then
		local tNode = DB.createNode(dbRootName);
		DB.setPublic(tNode, true);	  
	else
	  -- players will have it shared via public
	  return;
	end

	-- add options, mostly just a DEBUG
	-- registerOptions();
	-- checkOptions();
  -- loadOGLData();

	-- share the data to clients
	-- DB.findNode(dbRootName).setPublic(true);
end
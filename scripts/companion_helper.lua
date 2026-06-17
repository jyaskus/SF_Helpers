--local helper = _G.sf_companionHelper;
--if not helper then
--  helper = {};
--  _G.sf_companionHelper = helper;
--end

tSizeDefaults = tSizeDefaults or {
  diminutive = { space = 1, reach = 0 },
  tiny = { space = 2.5, reach = 0 },
  small = { space = 5, reach = 5 },
  medium = { space = 5, reach = 5 },
  large = { space = 10, reach = 10 },
  huge = { space = 15, reach = 15 },
};

local tFieldToControl = {
  space = "nSpace",
  reach = "nReach",
};

local function getValidSizeValue(sSize)
  Debug.console("Validating size value: " .. tostring(sSize));
  if tSizeDefaults[sSize:lower()] then
    return sSize;
  end
  return "Medium";
end


function syncNumberControl(window, sControl, nValue)
  if not window or not sControl then
    return;
  end
  local control = window[sControl];
  if control then
    window._bUpdatingSizeFields = true;
    control.setValue(nValue);
    window._bUpdatingSizeFields = false;
  end
end

local function applyNumericField(window, nodeRoot, sField, nValue, bForce)
  if not nodeRoot then
    return;
  end

  local nodeChild = DB.getChild(nodeRoot, sField);
  if bForce or not nodeChild then
    DB.setValue(nodeRoot, sField, "number", nValue);
    syncNumberControl(window, tFieldToControl[sField], nValue);
  end
end

function applySizeValues(window, nodeRoot, sSize, bForce)
  if not nodeRoot then
    return;
  end

  local sValidSize = getValidSizeValue(sSize);
  local tEntry = tSizeDefaults[sValidSize:lower()];
  if not tEntry then
    return;
  end

  if bForce then
    DB.setValue(nodeRoot, "size", "string", sValidSize);
  end

  applyNumericField(window, nodeRoot, "space", tEntry.space, bForce);
  applyNumericField(window, nodeRoot, "reach", tEntry.reach, bForce);
end

function ensureSizeDefaults(window)
  if not window then
    return;
  end

  local nodeRoot = window.getDatabaseNode();
  if not nodeRoot then
    return;
  end

  local sSize = getValidSizeValue(DB.getValue(nodeRoot, "size", "medium"));
  DB.setValue(nodeRoot, "size", "string", sSize);
  applySizeValues(window, nodeRoot, sSize, false);
end

function onSizeCyclerInit(window, control)
  if not window then
    return;
  end

  ensureSizeDefaults(window);

  if control then
    local nodeRoot = window.getDatabaseNode();
    if nodeRoot then
      local sSize = getValidSizeValue(DB.getValue(nodeRoot, "size", "medium"));
      control.setValue(sSize);
    end
  end
end

function onSizeCyclerChanged(window, control)
  if not window then
    return;
  end

  local nodeRoot = window.getDatabaseNode();
  if not nodeRoot then
    return;
  end

  -- grab it from the DB holding the stringcycler value rather than the control directly
  local sSize = DB.getValue(nodeRoot, "sSize", "Medium");

  local sValidSize = getValidSizeValue(sSize);
  DB.setValue(nodeRoot, "size", "string", sValidSize);
  applySizeValues(window, nodeRoot, sValidSize, true);
end

function onSpaceInit(window, control)
  if not window or not control then
    return;
  end

  ensureSizeDefaults(window);
  local nodeRoot = window.getDatabaseNode();
  if nodeRoot then
    control.setValue(DB.getValue(nodeRoot, "space", 0));
  end
end

function onSpaceChanged(window, control)
  if not window or not control then
    return;
  end

  if window._bUpdatingSizeFields then
    return;
  end

  local nodeRoot = window.getDatabaseNode();
  if nodeRoot then
    DB.setValue(nodeRoot, "space", "number", control.getValue() or 0);
  end
end

function onReachInit(window, control)
  if not window or not control then
    return;
  end

  ensureSizeDefaults(window);
  local nodeRoot = window.getDatabaseNode();
  if nodeRoot then
    control.setValue(DB.getValue(nodeRoot, "reach", 0));
  end
end

function onReachChanged(window, control)
  if not window or not control then
    return;
  end

  if window._bUpdatingSizeFields then
    return;
  end

  local nodeRoot = window.getDatabaseNode();
  if nodeRoot then
    DB.setValue(nodeRoot, "reach", "number", control.getValue() or 0);
  end
end
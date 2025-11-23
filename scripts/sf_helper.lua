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
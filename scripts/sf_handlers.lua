-- default result handler, for nation action checks
function resultHandler(rSource, rTarget, rRoll)

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  local sActionName = rMessage.text;
  rMessage.text = rMessage.text .. " vs DC " .. rRoll.DC;

  local nDC = tonumber(rRoll.DC);
  local nTotal = ActionsManager.total(rRoll);

  -- remove any modifiers after the name
  sActionName = sf.stringRemoveMod(sActionName);
  local sActionText="-action text-";

  if nTotal < nDC then
    sActionText = "check failed";
  end
  if nTotal >= nDC then
    sActionText = "check successful";
    local nDiff = nTotal - nDC;
    local nBonus = math.floor(nDiff / 5);
    if nBonus > 0 then
      sActionText = "check successful\n increase results by +/- " .. nBonus;
    end
  end

  -- send message to chat
  rMessage.text = rMessage.text .. "\n" .. sActionText;
  Comm.deliverChatMessage(rMessage);
end

-- default result handler, for nation action checks
function orgResultHandler(rSource, rTarget, rRoll)

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  local sActionName = rMessage.text;
  local nTotal = ActionsManager.total(rRoll);

  -- send message to chat
  Comm.deliverChatMessage(rMessage);
end

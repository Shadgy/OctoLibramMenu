-- Native Vanilla key bindings. No default keys are assigned or overwritten.
local M = OctoLibramMenu
M.BINDING_ACTIONS = { "OCTOLIBRAMMENU_ITEM1", "OCTOLIBRAMMENU_ITEM2", "OCTOLIBRAMMENU_ITEM3",
    "OCTOLIBRAMMENU_ITEM4", "OCTOLIBRAMMENU_FINAL", "OCTOLIBRAMMENU_CYCLE", "OCTOLIBRAMMENU_TOGGLE" }

function M:ValidBindingAction(action)
    for _, known in ipairs(self.BINDING_ACTIONS) do if action == known then return true end end
    return false
end

function M:GetLibramChoices()
    local choices, seen = {}, {}
    local function add(id, name)
        id = tonumber(id)
        if not id or id < 1 or seen[id] then return end
        if not name then
            name = GetItemInfo(id)
            if not name and id == M.FINAL_ID then name = M.FINAL_NAME end
        end
        seen[id] = true
        table.insert(choices, { id = id, name = name or ("Libram #" .. id) })
    end
    if self.equipped then add(self.equipped.id, self.equipped.name) end
    for _, item in ipairs(self.items or {}) do add(item.id, item.name) end
    for i = 1, 4 do add(self.db.bindingItems and self.db.bindingItems[i]) end
    add(self.db.cycleItemID)
    table.sort(choices, function(a, b) return a.name < b.name end)
    return choices
end

function M:SelectBindingItem(index, id)
    if not self.ready or type(index) ~= "number" or index < 1 or index > 4 or index ~= math.floor(index) then return false end
    id = tonumber(id)
    local valid = false
    for _, item in ipairs(self:GetLibramChoices()) do if item.id == id then valid = true end end
    if not valid then return false end
    self.db.bindingItems[index] = id
    if self.SyncSettings then self:SyncSettings() end
    return true
end

function M:SelectCycleItem(id)
    if not self.ready then return false end
    id = tonumber(id)
    if id == self.FINAL_ID then return false end
    local valid = false
    for _, item in ipairs(self:GetLibramChoices()) do if item.id == id then valid = true end end
    if not valid then return false end
    self.db.cycleItemID = id
    if self.SyncSettings then self:SyncSettings() end
    return true
end

function M:EquipBoundItem(index)
    if not self.ready then return false end
    local id = self.db.bindingItems and self.db.bindingItems[index]
    if not id then self:Message("Choose a libram for this slot in Key bindings first."); return false end
    return self:EquipID(id)
end

function M:CycleLibram()
    if not self.ready then return false end
    if self.pendingID then self:Message("Wait for the previous swap to finish."); return false end
    local partner = self.db.cycleItemID
    if not partner or partner == self.FINAL_ID then
        self:Message("Choose the second libram for the cycle in Key bindings first.")
        return false
    end
    self:Scan()
    local haveFinal = self.equipped and self.equipped.id == self.FINAL_ID or false
    local havePartner = self.equipped and self.equipped.id == partner or false
    for _, item in ipairs(self.items) do
        if item.id == self.FINAL_ID then haveFinal = true end
        if item.id == partner then havePartner = true end
    end
    if not haveFinal or not havePartner then self:Message("Both cycle librams must be equipped or in your bags."); return false end
    if self.equipped and self.equipped.id == self.FINAL_ID then return self:EquipID(partner) end
    return self:EquipID(self.FINAL_ID)
end

function M:GetBindingKeys(action)
    if type(GetBindingKey) ~= "function" then return {} end
    local first, second = GetBindingKey(action)
    local keys = {}
    if first then table.insert(keys, first) end
    if second then table.insert(keys, second) end
    return keys
end

function M:GetBindingLabel(action)
    local keys = self:GetBindingKeys(action)
    if table.getn(keys) == 0 then return "Not bound" end
    return table.concat(keys, " / ")
end

function M:BindingStatus(message)
    self.bindingMessage = message
    if self.SyncSettings then self:SyncSettings() end
end

function M:ChangeBinding(action, key, replace)
    if not self.ready or not self:ValidBindingAction(action) then return false, "Unknown binding action." end
    if type(SetBinding) ~= "function" or type(GetBindingAction) ~= "function" or type(SaveBindings) ~= "function"
        or type(GetCurrentBindingSet) ~= "function" then return false, "Key binding APIs are unavailable in this client." end
    if key ~= nil and (type(key) ~= "string" or key == "") then return false, "Choose a valid key." end
    local existing = key and GetBindingAction(key) or nil
    if existing and existing ~= "" and existing ~= action and not replace then
        return false, key .. " is already assigned to " .. existing .. ". Clear it in the game's Key Bindings first."
    end
    local old = self:GetBindingKeys(action)
    local before = {}
    for _, previous in ipairs(old) do before[previous] = GetBindingAction(previous) or "" end
    if key then before[key] = GetBindingAction(key) or "" end
    local function rollback()
        for previous, assigned in pairs(before) do
            pcall(SetBinding, previous, assigned ~= "" and assigned or nil)
        end
        for previous, assigned in pairs(before) do
            local ok, currentAction = pcall(GetBindingAction, previous)
            if not ok or (currentAction or "") ~= assigned then return false end
        end
        return true
    end
    local function failed(message)
        if not rollback() then return false, "Binding update failed. Review the game's Key Bindings; some previous keys could not be restored." end
        return false, message
    end
    for _, previous in ipairs(old) do
        if GetBindingAction(previous) == action then
            local ok, result = pcall(SetBinding, previous)
            if not ok or not result or result == 0 then return failed("The previous key could not be cleared.") end
        end
    end
    if key then
        local ok, result = pcall(SetBinding, key, action)
        if not ok or not result or result == 0 then return failed("That key cannot be assigned.") end
    end
    local current = GetCurrentBindingSet()
    if current ~= 1 and current ~= 2 then return failed("The active binding set is unavailable.") end
    local ok, result = pcall(SaveBindings, current)
    if not ok or result == false or result == 0 then
        local restored = rollback()
        if restored then pcall(SaveBindings, current) end
        if not restored then return false, "The key could not be saved or fully restored. Review the game's Key Bindings." end
        return false, "The key could not be saved. Review the game's Key Bindings before trying again."
    end
    return true
end

function M:AssignBinding(action, key, replace)
    local ok, message = self:ChangeBinding(action, key, replace)
    self:BindingStatus(ok and ("Assigned " .. key .. ".") or message)
    return ok, message
end

function M:ClearBinding(action)
    self:CancelBindingCapture()
    local ok, message = self:ChangeBinding(action, nil, false)
    self:BindingStatus(ok and "Key binding cleared." or message)
    return ok, message
end

function M:CancelBindingCapture()
    self.captureAction = nil
    if self.captureFrame then self.captureFrame:EnableKeyboard(false); self.captureFrame:Hide() end
    if self.SyncSettings then self:SyncSettings() end
end

function M:StartBindingCapture(action)
    if not self.ready or not self:ValidBindingAction(action) then return false end
    if not self.captureFrame then return false end
    self.captureAction = action
    self.bindingMessage = "Press a key. Escape cancels; Backspace clears this action."
    self.captureFrame:Show(); self.captureFrame:EnableKeyboard(true)
    if self.SyncSettings then self:SyncSettings() end
    return true
end

function M:BindingKeyPressed(key)
    if not self.captureAction then return end
    if key == "ESCAPE" then self:CancelBindingCapture(); self:BindingStatus("Key capture cancelled."); return end
    if key == "SHIFT" or key == "CTRL" or key == "ALT" or key == "UNKNOWN"
        or key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL"
        or key == "LALT" or key == "RALT" then return end
    local action = self.captureAction
    if key == "BACKSPACE" then self:CancelBindingCapture(); self:ClearBinding(action); return end
    if IsShiftKeyDown() then key = "SHIFT-" .. key end
    if IsControlKeyDown() then key = "CTRL-" .. key end
    if IsAltKeyDown() then key = "ALT-" .. key end
    self:CancelBindingCapture()
    self:AssignBinding(action, key, false)
end

function M:InitBindings()
    if type(self.db.bindingItems) ~= "table" then self.db.bindingItems = {} end
    for index, id in pairs(self.db.bindingItems) do
        if type(index) ~= "number" or index < 1 or index > 4 or index ~= math.floor(index)
            or type(id) ~= "number" or id < 1 or id ~= math.floor(id) then self.db.bindingItems[index] = nil end
    end
    if type(self.db.cycleItemID) ~= "number" or self.db.cycleItemID < 1 or self.db.cycleItemID ~= math.floor(self.db.cycleItemID)
        or self.db.cycleItemID == self.FINAL_ID then self.db.cycleItemID = nil end
    if self.captureFrame then return end
    self.captureFrame = CreateFrame("Frame", "OctoLibramMenuKeyCapture", UIParent)
    self.captureFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.captureFrame:SetAllPoints(UIParent)
    self.captureFrame:EnableMouse(false)
    self.captureFrame:EnableKeyboard(false)
    self.captureFrame:SetScript("OnKeyDown", function() M:BindingKeyPressed(arg1) end)
    self.captureFrame:SetScript("OnHide", function() M.captureAction = nil; this:EnableKeyboard(false) end)
    self.captureFrame:Hide()
end

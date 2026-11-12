-- WoW 1.12 / Lua 5.0. No automatic equipment changes.
OctoLibramMenu = { VERSION = "0.3.3", SLOT = 18, FINAL_ID = 58240,
    FINAL_NAME = "Libram of Final Judgement", items = {}, elapsed = 0, scanElapsed = 0 }
local M = OctoLibramMenu
M.SOUNDS = {
    { id = "LOL", name = "LoL - Retreat Ping", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\LoLDanger.wav" },
    { id = "MGS", name = "Metal Gear - Alert", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\MetalGear.wav" },
    { id = "FINISH", name = "Mortal Kombat - Finish Him", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\FinishHim.wav" },
    { id = "MARIO", name = "Mario - Coin", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\MarioCoin.wav" },
    { id = "SONIC", name = "Sonic - Ring", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\SonicRing.wav" },
    { id = "VINE", name = "Vine Boom", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\VineBoom.wav" },
    { id = "WINDOWS", name = "Windows XP - Error", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\WindowsError.wav" },
    { id = "DUNDUN", name = "Law and Order - Dun Dun", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\DunDun.wav" },
    { id = "AIRHORN", name = "Air Horn", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\AirHorn.wav" },
    { id = "GONG", name = "Boxing Arena Gong", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\BoxingGong.wav" },
    { id = "SIREN", name = "Warning Siren", sound = "Interface\\AddOns\\OctoLibramMenu\\Sounds\\WarningSiren.wav" }
}

local function normalizeSoundVolume(value)
    value = tonumber(value)
    -- Subtracting a non-finite value from itself gives NaN, including on Lua 5.0.
    if not value or value - value ~= 0 then return nil end
    value = math.max(0, math.min(200, value))
    return math.floor(value / 10 + 0.5) * 10
end

function M:Message(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffd166OctoLibramMenu:|r " .. text) end
end

function M:ItemID(link)
    local _, _, id = string.find(link or "", "item:(%d+)")
    return tonumber(id)
end

function M:ReadItem(link, bag, slot)
    local id = self:ItemID(link)
    if not id then return nil end
    local _, _, linkName = string.find(link, "%[(.+)%]")
    local name, _, quality, _, _, subtype, _, equipLoc, texture = GetItemInfo(id)
    if not equipLoc then self.cachePending = true end
    -- A known relic is safe even before GetItemInfo has populated its cache.
    if bag ~= nil and equipLoc ~= "INVTYPE_RELIC" and id ~= self.FINAL_ID then return nil end
    -- The enUS client may carry another class's relic; quest books named
    -- 'Libram ...' must also pass the equip-location check above.
    if bag ~= nil and id ~= self.FINAL_ID and subtype ~= "Libram" and subtype ~= "Librams"
        and not string.find(name or linkName or "", "^Libram ") then return nil end
    return { id = id, name = name or linkName or ("Item " .. id), link = link,
        texture = texture or (id == self.FINAL_ID and "Interface\\Icons\\INV_Relics_LibramofTruth")
            or "Interface\\Icons\\INV_Misc_Book_11", quality = quality, bag = bag, slot = slot }
end

function M:Scan()
    self.cachePending = false
    self.equipped = self:ReadItem(GetInventoryItemLink("player", self.SLOT))
    local items, seen = {}, {}
    self.final = self.equipped and self.equipped.id == self.FINAL_ID and self.equipped or nil
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = self:ReadItem(GetContainerItemLink(bag, slot), bag, slot)
            if item and not seen[item.id] then
                seen[item.id] = true
                table.insert(items, item)
                if item.id == self.FINAL_ID and not self.final then self.final = item end
            end
        end
    end
    table.sort(items, function(a, b) return a.name < b.name end)
    self.items = items
    if self.pendingID and self.equipped and self.equipped.id == self.pendingID then
        self.pendingID, self.pendingAt = nil, nil
    end
    if self.Refresh then self:Refresh() end
    if self.SyncSettings then self:SyncSettings() end
end

function M:TargetBelowThreshold()
    if not UnitExists("target") or not UnitCanAttack("player", "target") then return false end
    if UnitIsDeadOrGhost("target") then return false end
    local health, maximum = UnitHealth("target"), UnitHealthMax("target")
    -- Nampower may provide absolute health. Always use a matched pair.
    if type(GetUnitField) == "function" then
        local okH, rawH = pcall(GetUnitField, "target", "health")
        local okM, rawM = pcall(GetUnitField, "target", "maxHealth")
        if okH and okM and type(rawH) == "number" and type(rawM) == "number" and rawM > 0 then
            health, maximum = rawH, rawM
        end
    end
    if type(health) ~= "number" or type(maximum) ~= "number" or maximum <= 0 or health <= 0 then return false end
    return health * 100 <= maximum * 35
end

function M:UpdateAlert()
    local below = self:TargetBelowThreshold()
    self.alert = self.db.alertEnabled ~= false and below and self.final ~= nil
    if self.RefreshAlert then self:RefreshAlert() end
    self:UpdateSound(below)
end

function M:TargetGUID()
    if type(UnitGUID) == "function" then
        local ok, guid = pcall(UnitGUID, "target")
        if ok and type(guid) == "string" and guid ~= "" then return guid end
    end
    if type(GetUnitGUID) == "function" then
        local ok, guid = pcall(GetUnitGUID, "target")
        if ok and type(guid) == "string" and guid ~= "" then return guid end
    end
    local exists, guid = UnitExists("target")
    if exists and type(guid) == "string" and guid ~= "" then return guid end
end

function M:TargetIdentity()
    if not UnitExists("target") then return nil end
    local guid = self:TargetGUID()
    if guid then return guid end
    local name = type(UnitName) == "function" and UnitName("target") or "target"
    return (name or "target") .. ":" .. (self.targetSerial or 0)
end

function M:TargetNpcID()
    local guid = self:TargetGUID()
    if not guid then return nil end
    if string.len(guid) == 18 and string.find(guid, "^0[xX][fF]130%x+$") then
        return tonumber(string.sub(guid, 7, 12), 16)
    end
    local _, _, id = string.find(guid, "^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    return tonumber(id)
end

function M:IsBossTarget()
    if not UnitExists("target") or type(UnitIsPlayer) == "function" and UnitIsPlayer("target") then return false end
    if type(UnitPlayerControlled) == "function" and UnitPlayerControlled("target") then return false end
    local guid = self:TargetGUID()
    if guid and (string.find(guid, "^Pet%-") or string.find(guid, "^0[xX][fF]140")) then return false end
    local data = OctoLibramMenuBosses
    local id = self:TargetNpcID()
    if data and id and data.ids[id] then return true end
    if type(UnitClassification) == "function" and UnitClassification("target") == "worldboss" then return true end
    -- An available NPC ID takes priority over a potentially ambiguous name.
    if id then return false end
    local name = type(UnitName) == "function" and UnitName("target") or nil
    -- The generic Chess name 'King' is only safe when its ID is available.
    return data and name ~= "King" and name and data.names[name] == true or false
end

function M:PlayAlertSound(preview)
    local volume = self.db.soundVolume
    if volume == 0 then return false end
    local selected
    for _, sound in ipairs(self.SOUNDS) do if sound.id == self.db.soundChoice then selected = sound; break end end
    selected = selected or self.SOUNDS[1]
    if type(PlaySoundFile) ~= "function" then
        if preview then self:Message("Sound playback is unavailable in this client.") end
        return false
    end
    local path = selected.sound
    if volume ~= 100 then
        -- The Vanilla client plays custom files at their encoded volume.
        path = string.gsub(path, "\\Sounds\\", "\\Sounds\\Volume\\" .. volume .. "\\", 1)
    end
    local ok, result = pcall(PlaySoundFile, path)
    if not ok or result == false then
        if preview then self:Message("The sound could not be played. Check the game's sound settings.") end
        return false
    end
    return true
end

function M:UpdateSound(below)
    local key = self:TargetIdentity()
    local entering = below and key and (not self.soundWasBelow or self.soundTarget ~= key)
    -- Prime the latch even while muted; changing settings below the threshold
    -- must not replay a sound on every refresh.
    self.soundWasBelow, self.soundTarget = below and true or false, key
    if entering and self.db.soundEnabled and (not self.db.soundBossesOnly or self:IsBossTarget()) then
        self:PlayAlertSound(false)
    end
end

function M:EquipID(id)
    if not self.ready then return false end
    if UnitIsDeadOrGhost("player") then self:Message("Cannot change librams while dead."); return false end
    if CursorHasItem() or SpellIsTargeting() then self:Message("Clear the cursor or finish targeting a spell first."); return false end
    -- Re-scan at click time: bag sorting must never equip a stale bag slot.
    self:Scan()
    if self.equipped and self.equipped.id == id then return true end
    if self.pendingID then self:Message("Wait for the previous swap to finish."); return false end
    local chosen
    for _, item in ipairs(self.items) do if item.id == id then chosen = item; break end end
    if not chosen then self:Message("That libram is not in your bags."); return false end
    local _, _, locked = GetContainerItemInfo(chosen.bag, chosen.slot)
    if locked or IsInventoryItemLocked(self.SLOT) then self:Message("That item is temporarily locked. Try again."); return false end
    self.pendingID, self.pendingAt = id, GetTime()
    -- Same manual swap mechanism as installed TrinketMenu/ItemRack; slot 18
    -- is swappable during combat. Never defer a click to a later combat end.
    PickupContainerItem(chosen.bag, chosen.slot)
    if CursorHasItem() then
        PickupInventoryItem(self.SLOT)
        -- Return any displaced item (or a rejected pickup) safely to its origin.
        if CursorHasItem() then ClearCursor() end
    end
    self:Scan()
    self:UpdateAlert()
    return true
end

function M:EquipFinal()
    return self:EquipID(self.FINAL_ID)
end

function M:Tick(delta)
    if not self.ready then return end
    self.elapsed = self.elapsed + (delta or 0)
    if self.elapsed < 0.1 then return end
    self.elapsed = 0
    if self.dirty then self.dirty = nil; self:Scan() end
    self.scanElapsed = self.scanElapsed + 0.1
    if self.scanElapsed >= 1 then
        self.scanElapsed = 0
        if self.cachePending then self:Scan() end
    end
    if self.pendingID and GetTime() - self.pendingAt >= 2 then
        self:Scan()
        if self.pendingID then
            self.pendingID, self.pendingAt = nil, nil
            self:Message("Swap not confirmed. Check your relic slot and try again.")
        end
    end
    self:UpdateAlert()
    if self.UpdateUI then self:UpdateUI() end
end

function M:Initialize()
    if self.ready or self.disabled then return end
    local _, class = UnitClass("player")
    if class ~= "PALADIN" then self.disabled = true; return end
    if type(OctoLibramMenuDB) ~= "table" then OctoLibramMenuDB = {} end
    self.db = OctoLibramMenuDB
    local defaults = { scale = 1, shown = true, locked = false, keepOpen = false, direction = "RIGHT", columns = 4,
        showMinimap = true, showTooltips = true, alertEnabled = true, minimapAngle = 225,
        soundEnabled = false, soundBossesOnly = false, soundChoice = "LOL" }
    for key, value in pairs(defaults) do if self.db[key] == nil then self.db[key] = value end end
    -- Retired cue IDs migrate to the new default; current selections survive
    -- later logins. All other saved preferences remain in the same table.
    local validSound = false
    for _, sound in ipairs(self.SOUNDS) do if self.db.soundChoice == sound.id then validSound = true; break end end
    if not validSound then self.db.soundChoice = "LOL" end
    self.db.soundVolume = normalizeSoundVolume(self.db.soundVolume) or 100
    self.db.scale = math.max(0.6, math.min(2, tonumber(self.db.scale) or 1))
    self.db.columns = math.max(1, math.min(8, math.floor(tonumber(self.db.columns) or 4)))
    if self.db.direction ~= "LEFT" then self.db.direction = "RIGHT" end
    local angle = tonumber(self.db.minimapAngle) or 225
    self.db.minimapAngle = angle - math.floor(angle / 360) * 360
    self.ready = true
    self:CreateUI()
    self:Scan()
    if self.InitBindings then self:InitBindings() end
    if self.CreateSettingsUI then self:CreateSettingsUI() end
    self:UpdateAlert()
    self:Message("Settings: ESC > LibramMenu, right-click the minimap button, or /olm.")
end

function M:OnEvent(name, unit)
    if name == "PLAYER_LOGIN" or name == "PLAYER_ENTERING_WORLD" then self:Initialize() end
    if not self.ready then return end
    if name == "PLAYER_TARGET_CHANGED" then
        self.targetSerial = (self.targetSerial or 0) + 1
        self:UpdateAlert()
    elseif (name == "UNIT_HEALTH" or name == "UNIT_MAXHEALTH") and unit == "target" then
        self:UpdateAlert()
    elseif name == "UPDATE_BINDINGS" and self.SyncSettings then self:SyncSettings()
    elseif name == "BAG_UPDATE" or name == "ITEM_LOCK_CHANGED" or name == "PLAYER_ENTERING_WORLD"
        or name == "UNIT_INVENTORY_CHANGED" and unit == "player" then
        self.dirty = true
    end
end

function M:SetOption(key, value)
    if not self.ready then return false end
    if key == "soundVolume" then
        value = normalizeSoundVolume(value)
        if not value then return false end
        self.db.soundVolume = value
        if self.SyncSettings then self:SyncSettings() end
        return true
    end
    if key == "shown" or key == "keepOpen" or key == "locked" or key == "showMinimap"
        or key == "showTooltips" or key == "alertEnabled" or key == "soundEnabled" or key == "soundBossesOnly" then
        value = value == true or value == 1
    elseif key == "scale" or key == "columns" or key == "minimapAngle" then
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then return false end
        if key == "scale" then value = math.max(0.6, math.min(2, value))
        elseif key == "columns" then value = math.max(1, math.min(8, math.floor(value)))
        else value = value - math.floor(value / 360) * 360 end
    elseif key == "direction" then
        if value ~= "LEFT" and value ~= "RIGHT" then return false end
    elseif key == "soundChoice" then
        local valid = false
        for _, sound in ipairs(self.SOUNDS) do if value == sound.id then valid = true end end
        if not valid then return false end
    else return false end
    self.db[key] = value
    if key == "keepOpen" and not value and self.menu then self.menu:Hide() end
    if key == "showTooltips" and not value and self.ClearTooltip then self:ClearTooltip() end
    if key == "locked" and value and self.dragging and self.EndDrag then self:EndDrag() end
    if key == "scale" then self:ApplyPosition() end
    self:Refresh()
    self:UpdateAlert()
    if self.SyncSettings then self:SyncSettings() end
    return true
end

function M:ResetPosition()
    if not self.ready then return end
    self.db.position = nil; self.db.scale = 1; self.db.shown = true
    self.db.direction = "RIGHT"; self.db.minimapAngle = 225
    self:ApplyPosition(); self:Refresh(); self:UpdateAlert()
    if self.SyncSettings then self:SyncSettings() end
end

function M:Slash(message)
    if not self.ready then self:Message("This addon is available to paladins only."); return end
    local _, _, command, value = string.find(string.lower(message or ""), "^%s*(%S*)%s*(.-)%s*$")
    if (command == "" or command == "options" or command == "config") and self.OpenOptions then
        self:OpenOptions()
    elseif command == "show" or command == "hide" then
        self:SetOption("shown", command == "show")
    elseif command == "lock" or command == "unlock" then
        self:SetOption("locked", command == "lock")
        self:Message(self.db.locked and "Position locked." or "Position unlocked: Alt / Ctrl / Shift + drag to move.")
    elseif command == "keepopen" then
        self:SetOption("keepOpen", not self.db.keepOpen)
        self:Message(self.db.keepOpen and "Libram menu always shown." or "Libram menu opens on hover.")
    elseif command == "left" or command == "right" then
        self:SetOption("direction", string.upper(command))
    elseif command == "scale" and tonumber(value) then
        self:SetOption("scale", value)
    elseif command == "columns" and tonumber(value) then
        self:SetOption("columns", value)
    elseif command == "reset" then
        self:ResetPosition()
    elseif command == "minimap" then
        self:SetOption("showMinimap", not self.db.showMinimap)
    elseif command == "final" then self:EquipFinal()
    elseif command == "cycle" and self.CycleLibram then self:CycleLibram()
    else
        self:Message("Hover: select a libram | click: equip | right-click: pin menu | Alt/Ctrl/Shift + drag: move.")
        self:Message("/olm options | show | hide | lock | unlock | keepopen | minimap | left | right | scale 1 | columns 4 | reset | final | cycle")
    end
end

local events = CreateFrame("Frame", "OctoLibramMenuEvents")
events:SetScript("OnEvent", function() M:OnEvent(event, arg1) end)
events:SetScript("OnUpdate", function() M:Tick(arg1) end)
for _, name in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_HEALTH",
    "UNIT_MAXHEALTH", "BAG_UPDATE", "UNIT_INVENTORY_CHANGED", "ITEM_LOCK_CHANGED", "UPDATE_BINDINGS" }) do events:RegisterEvent(name) end
SLASH_OCTOLIBRAMMENU1 = "/olm"
SlashCmdList["OCTOLIBRAMMENU"] = function(message) M:Slash(message) end

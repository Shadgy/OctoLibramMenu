-- WoW 1.12 / Lua 5.0. No automatic equipment changes.
OctoLibramMenu = { VERSION = "0.2.1", SLOT = 18, FINAL_ID = 58240,
    FINAL_NAME = "Libram of Final Judgement", items = {}, elapsed = 0, scanElapsed = 0 }
local M = OctoLibramMenu

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
    self.alert = self.db.alertEnabled ~= false and self:TargetBelowThreshold() and self.final ~= nil
    if self.RefreshAlert then self:RefreshAlert() end
end

function M:EquipID(id)
    if not self.ready then return false end
    if UnitIsDeadOrGhost("player") then self:Message("Nie mozna zmienic libramu po smierci."); return false end
    if CursorHasItem() or SpellIsTargeting() then self:Message("Najpierw oproznij kursor lub zakoncz wybieranie celu czaru."); return false end
    -- Re-scan at click time: bag sorting must never equip a stale bag slot.
    self:Scan()
    if self.equipped and self.equipped.id == id then return true end
    if self.pendingID then self:Message("Poczekaj na wynik poprzedniej podmiany."); return false end
    local chosen
    for _, item in ipairs(self.items) do if item.id == id then chosen = item; break end end
    if not chosen then self:Message("Tego libramu nie ma w torbach."); return false end
    local _, _, locked = GetContainerItemInfo(chosen.bag, chosen.slot)
    if locked or IsInventoryItemLocked(self.SLOT) then self:Message("Przedmiot jest chwilowo zablokowany. Kliknij ponownie."); return false end
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
            self:Message("Brak potwierdzenia podmiany. Sprawdz slot libramu i kliknij ponownie.")
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
        showMinimap = true, showTooltips = true, alertEnabled = true, minimapAngle = 225 }
    for key, value in pairs(defaults) do if self.db[key] == nil then self.db[key] = value end end
    self.db.scale = math.max(0.6, math.min(2, tonumber(self.db.scale) or 1))
    self.db.columns = math.max(1, math.min(8, math.floor(tonumber(self.db.columns) or 4)))
    if self.db.direction ~= "LEFT" then self.db.direction = "RIGHT" end
    local angle = tonumber(self.db.minimapAngle) or 225
    self.db.minimapAngle = angle - math.floor(angle / 360) * 360
    self.ready = true
    self:CreateUI()
    if self.CreateSettingsUI then self:CreateSettingsUI() end
    self:Scan()
    self:UpdateAlert()
    self:Message("Ustawienia: ESC > LibramMenu lub PPM na przycisku minimapy. /olm")
end

function M:OnEvent(name, unit)
    if name == "PLAYER_LOGIN" or name == "PLAYER_ENTERING_WORLD" then self:Initialize() end
    if not self.ready then return end
    if name == "PLAYER_TARGET_CHANGED" or (name == "UNIT_HEALTH" or name == "UNIT_MAXHEALTH") and unit == "target" then
        self:UpdateAlert()
    elseif name == "BAG_UPDATE" or name == "ITEM_LOCK_CHANGED" or name == "PLAYER_ENTERING_WORLD"
        or name == "UNIT_INVENTORY_CHANGED" and unit == "player" then
        self.dirty = true
    end
end

function M:SetOption(key, value)
    if not self.ready then return false end
    if key == "shown" or key == "keepOpen" or key == "locked" or key == "showMinimap"
        or key == "showTooltips" or key == "alertEnabled" then
        value = value == true or value == 1
    elseif key == "scale" or key == "columns" or key == "minimapAngle" then
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then return false end
        if key == "scale" then value = math.max(0.6, math.min(2, value))
        elseif key == "columns" then value = math.max(1, math.min(8, math.floor(value)))
        else value = value - math.floor(value / 360) * 360 end
    elseif key == "direction" then
        if value ~= "LEFT" and value ~= "RIGHT" then return false end
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
    if not self.ready then self:Message("Dodatek jest przeznaczony dla paladyna."); return end
    local _, _, command, value = string.find(string.lower(message or ""), "^%s*(%S*)%s*(.-)%s*$")
    if (command == "" or command == "options" or command == "config") and self.OpenOptions then
        self:OpenOptions()
    elseif command == "show" or command == "hide" then
        self:SetOption("shown", command == "show")
    elseif command == "lock" or command == "unlock" then
        self:SetOption("locked", command == "lock")
        self:Message(self.db.locked and "Pozycja zablokowana." or "Pozycja odblokowana: Alt / Ctrl / Shift + przeciagniecie.")
    elseif command == "keepopen" then
        self:SetOption("keepOpen", not self.db.keepOpen)
        self:Message(self.db.keepOpen and "Menu stale otwarte." or "Menu otwierane po najechaniu.")
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
    else
        self:Message("Najedz: menu | kliknij libram: zaloz | PPM: przypnij/odepnij menu | Alt/Ctrl/Shift + przeciagniecie: przesun.")
        self:Message("/olm options | show | hide | lock | unlock | keepopen | minimap | left | right | scale 1 | columns 4 | reset | final")
    end
end

local events = CreateFrame("Frame", "OctoLibramMenuEvents")
events:SetScript("OnEvent", function() M:OnEvent(event, arg1) end)
events:SetScript("OnUpdate", function() M:Tick(arg1) end)
for _, name in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_HEALTH",
    "UNIT_MAXHEALTH", "BAG_UPDATE", "UNIT_INVENTORY_CHANGED", "ITEM_LOCK_CHANGED" }) do events:RegisterEvent(name) end
SLASH_OCTOLIBRAMMENU1 = "/olm"
SlashCmdList["OCTOLIBRAMMENU"] = function(message) M:Slash(message) end

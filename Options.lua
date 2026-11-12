-- Standalone Vanilla options: ESC menu and minimap entry points.
local M = OctoLibramMenu

local function tooltip(owner, title, detail)
    if M.db.showTooltips == false then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title, 1, 0.82, 0)
    if detail then GameTooltip:AddLine(detail, 0.9, 0.9, 0.9, true) end
    GameTooltip:Show()
end

local function hint(frame, title, detail)
    frame:SetScript("OnEnter", function() tooltip(this, title, detail) end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function label(parent, text, x, y, font)
    local textFrame = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    textFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    textFrame:SetText(text)
    return textFrame
end

local function button(parent, name, text, width, height)
    local result = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    result:SetWidth(width); result:SetHeight(height)
    result:SetText(text)
    return result
end

local function slider(parent, name, key, minimum, maximum, step, y, low, high)
    local control = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    control:SetWidth(450); control:SetHeight(16)
    control:SetPoint("TOPLEFT", parent, "TOPLEFT", 35, y)
    control:SetMinMaxValues(minimum, maximum); control:SetValueStep(step)
    control.optionKey, control.optionStep = key, step
    getglobal(name .. "Low"):SetText(low)
    getglobal(name .. "High"):SetText(high)
    control:SetScript("OnValueChanged", function()
        if M.syncingOptions then return end
        local value = math.floor(this:GetValue() / this.optionStep + 0.5) * this.optionStep
        M:SetOption(this.optionKey, value)
    end)
    return control
end

function M:OpenOptions()
    if not self.ready then return end
    if not self.options then self:CreateSettingsUI() end
    if GameMenuFrame and GameMenuFrame:IsVisible() then
        if HideUIPanel then HideUIPanel(GameMenuFrame) else GameMenuFrame:Hide() end
    end
    self:SyncSettings()
    self.options:Show()
end

function M:SyncSettings()
    if not self.options or self.syncingOptions then return end
    self.syncingOptions = true
    for key, check in pairs(self.optionChecks) do check:SetChecked(self.db[key] and 1 or nil) end
    self.scaleSlider:SetValue(self.db.scale)
    self.columnsSlider:SetValue(self.db.columns)
    self.soundVolumeSlider:SetValue(self.db.soundVolume)
    getglobal("OctoLibramMenuScaleText"):SetText("Scale: " .. math.floor(self.db.scale * 100 + 0.5) .. "%")
    getglobal("OctoLibramMenuColumnsText"):SetText("Menu columns: " .. self.db.columns)
    getglobal("OctoLibramMenuSoundVolumeText"):SetText("Alert volume: " .. self.db.soundVolume .. "%")
    self.directionLeft:SetText(self.db.direction == "LEFT" and "|cffffd166Left|r" or "Left")
    self.directionRight:SetText(self.db.direction == "RIGHT" and "|cffffd166Right|r" or "Right")
    if self.bindingRows then
        local choices = self.GetLibramChoices and self:GetLibramChoices() or {}
        for _, row in ipairs(self.bindingRows) do
            row.keyButton:SetText(self.GetBindingLabel and self:GetBindingLabel(row.action) or "Not bound")
            if row.selector then
                local id
                if row.index then id = self.db.bindingItems and self.db.bindingItems[row.index]
                else id = self.db.cycleItemID end
                local name = id and ("Item " .. id) or "Choose a libram"
                local available = 0
                for _, item in ipairs(choices) do if item.id == id then name = item.name; break end end
                for _, item in ipairs(choices) do
                    if row.index or item.id ~= self.FINAL_ID then available = available + 1 end
                end
                if available > 0 then row.previous:Enable(); row.next:Enable()
                else
                    row.previous:Disable(); row.next:Disable()
                    if not id then name = "Put librams in your bags" end
                end
                row.itemLabel:SetText(name)
            end
        end
        if self.captureAction then self.bindingStatus:SetText("Press a key now. Escape cancels; Backspace clears this binding.")
        else self.bindingStatus:SetText(self.bindingMessage or "Choose a libram, then set a key. Keys use the game's active binding set.") end
    end
    if self.soundChoiceButton then
        for _, sound in ipairs(self.SOUNDS or {}) do
            if sound.id == self.db.soundChoice then self.soundChoiceButton:SetText(sound.name); break end
        end
    end
    self.syncingOptions = nil
    self:UpdateMinimapButton()
end

function M:SelectOptionsTab(key)
    if not self.optionPages[key] then return end
    self.activeOptionsTab = key
    if self.CancelBindingCapture then self:CancelBindingCapture() end
    if self.soundMenu then self.soundMenu:Hide() end
    for name, page in pairs(self.optionPages) do
        if name == key then page:Show() else page:Hide() end
        local text = name == "general" and "General" or name == "bindings" and "Key bindings" or "Sound"
        self.optionTabs[name]:SetText(name == key and ("|cffffd166" .. text .. "|r") or text)
    end
    self:SyncSettings()
end

function M:RotateSelectedLibram(row, direction)
    local choices = {}
    for _, item in ipairs(self:GetLibramChoices()) do
        if row.index or item.id ~= self.FINAL_ID then table.insert(choices, item) end
    end
    if table.getn(choices) == 0 then
        self.bindingMessage = "No librams available. Put a libram in your bags and try again."
        self:SyncSettings()
        return
    end
    local selected
    if row.index then selected = self.db.bindingItems[row.index] else selected = self.db.cycleItemID end
    local index = direction > 0 and 0 or table.getn(choices) + 1
    for i, item in ipairs(choices) do if item.id == selected then index = i; break end end
    index = index + direction
    if index < 1 then index = table.getn(choices) elseif index > table.getn(choices) then index = 1 end
    if row.index then self:SelectBindingItem(row.index, choices[index].id)
    else self:SelectCycleItem(choices[index].id) end
    self.bindingMessage = nil
    self:SyncSettings()
end

function M:UpdateMinimapButton()
    local icon = self.minimapButton
    if not icon then return end
    if self.db.locked and self.minimapDragging then
        self.minimapDragging = nil
        icon:SetScript("OnUpdate", nil)
    end
    if self.db.showMinimap then icon:Show() else icon:Hide() end
    -- pfUI can collect the icon into its own button bar and manage its anchors.
    -- Retain visibility/clicks while respecting that placement.
    if icon:GetParent() ~= Minimap then self.minimapDragging = nil; return end
    local angle = math.rad(self.db.minimapAngle or 225)
    local x, y = math.cos(angle), math.sin(angle)
    local radiusX, radiusY = Minimap:GetWidth() / 2 + 8, Minimap:GetHeight() / 2 + 8
    local shape = GetMinimapShape and GetMinimapShape() or nil
    if not shape and pfUI and pfUI.minimap then shape = "SQUARE" end
    if shape == "SQUARE" then
        local scale = math.max(math.abs(x), math.abs(y))
        if scale > 0 then x, y = x / scale, y / scale end
    end
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", Minimap, "CENTER", x * radiusX, y * radiusY)
end

function M:DragMinimapButton()
    if self.minimapButton:GetParent() ~= Minimap then self.minimapDragging = nil; return end
    if not self.minimapDragging or self.db.locked then return end
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local angle = math.deg(math.atan2(cursorY / scale - centerY, cursorX / scale - centerX))
    self.db.minimapAngle = angle - math.floor(angle / 360) * 360
    self:UpdateMinimapButton()
end

function M:CreateMinimapButton()
    if self.minimapButton or not Minimap then return end
    local icon = CreateFrame("Button", "OctoLibramMenuMinimapButton", Minimap)
    self.minimapButton = icon
    icon:SetWidth(32); icon:SetHeight(32)
    icon:SetFrameStrata("MEDIUM")
    icon:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    icon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    icon:RegisterForDrag("LeftButton")
    icon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    icon.icon = icon:CreateTexture(nil, "BACKGROUND")
    icon.icon:SetWidth(20); icon.icon:SetHeight(20)
    icon.icon:SetPoint("CENTER", icon, "CENTER", 0, 0)
    icon.icon:SetTexture("Interface\\Icons\\INV_Relics_LibramofTruth")
    icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon.border = icon:CreateTexture(nil, "OVERLAY")
    icon.border:SetWidth(54); icon.border:SetHeight(54)
    icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
    icon.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    icon:SetScript("OnClick", function()
        if this:GetParent() ~= Minimap then M.minimapDragging = nil end
        if M.minimapDragging then return end
        if arg1 == "RightButton" then M:OpenOptions()
        else M:SetOption("shown", not M.db.shown) end
    end)
    icon:SetScript("OnEnter", function()
        tooltip(this, "OctoLibramMenu", "Left click: show / hide librams.\nRight click: settings.\nDrag: move icon when unlocked.")
    end)
    icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    icon:SetScript("OnDragStart", function()
        if M.db.locked or this:GetParent() ~= Minimap then return end
        GameTooltip:Hide()
        M.minimapDragging = true
        this:SetScript("OnUpdate", function() M:DragMinimapButton() end)
    end)
    icon:SetScript("OnDragStop", function()
        M:DragMinimapButton()
        M.minimapDragging = nil
        this:SetScript("OnUpdate", nil)
    end)
    icon:SetScript("OnHide", function()
        M.minimapDragging = nil
        this:SetScript("OnUpdate", nil)
    end)
    self:UpdateMinimapButton()
end

function M:InstallGameMenuButton()
    if self.gameMenuButton or not GameMenuFrame or not GameMenuButtonContinue then return end
    local continue = GameMenuButtonContinue
    local menuButton = CreateFrame("Button", "GameMenuButtonOctoLibramMenu", GameMenuFrame, "GameMenuButtonTemplate")
    self.gameMenuButton = menuButton
    menuButton:SetWidth(continue:GetWidth())
    local height = continue:GetHeight()
    if not height or height < 1 then height = 20 end
    menuButton:SetHeight(height)
    menuButton:SetText("LibramMenu")
    local point, relative, relativePoint, x, y = continue:GetPoint()
    -- Some menu versions pin Continue to the bottom of the parent instead of
    -- the button chain. Place the new row after Quit in that layout.
    if (relative == GameMenuFrame or relative == "GameMenuFrame")
        and string.find(relativePoint or point or "", "BOTTOM") and GameMenuButtonQuit then
        menuButton:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -2)
    elseif point then menuButton:SetPoint(point, relative or GameMenuFrame, relativePoint or point, x or 0, y or 0)
    elseif GameMenuButtonQuit then menuButton:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -2)
    else menuButton:SetPoint("BOTTOM", GameMenuFrame, "BOTTOM", 0, 40) end
    continue:ClearAllPoints()
    continue:SetPoint("TOP", menuButton, "BOTTOM", 0, -2)
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + height + 2)
    menuButton:SetScript("OnClick", function() M:OpenOptions() end)
end

function M:CreateBindingOptions(page)
    label(page, "Select a libram with the arrows, then click its key button.", 27, -117, "GameFontHighlightSmall")
    self.bindingRows = {}
    for i = 1, 7 do
        local row = {}
        local y = -145 - (i - 1) * 46
        if i <= 4 then row.index, row.action = i, "OCTOLIBRAMMENU_ITEM" .. i
        elseif i == 5 then row.action = "OCTOLIBRAMMENU_FINAL"
        elseif i == 6 then row.action = "OCTOLIBRAMMENU_CYCLE"
        else row.action = "OCTOLIBRAMMENU_TOGGLE" end
        local title = i <= 4 and ("Libram " .. i) or i == 5 and "Equip Final Judgement"
            or i == 6 and "Cycle: Final Judgement <->" or "Pin / unpin libram menu"
        row.title = label(page, title, 27, y, "GameFontNormalSmall")
        row.selector = i <= 4 or i == 6
        if row.selector then
            row.previous = button(page, "OctoLibramMenuBindingPrevious" .. i, "<", 22, 22)
            row.previous:SetPoint("TOPLEFT", page, "TOPLEFT", 27, y - 15)
            row.previous.bindingRow = row
            row.previous:SetScript("OnClick", function() M:RotateSelectedLibram(this.bindingRow, -1) end)
            row.next = button(page, "OctoLibramMenuBindingNext" .. i, ">", 22, 22)
            row.next:SetPoint("TOPLEFT", page, "TOPLEFT", 277, y - 15)
            row.next.bindingRow = row
            row.next:SetScript("OnClick", function() M:RotateSelectedLibram(this.bindingRow, 1) end)
            row.itemLabel = label(page, "Choose a libram", 54, y - 20, "GameFontHighlightSmall")
            row.itemLabel:SetWidth(218); row.itemLabel:SetJustifyH("LEFT")
            hint(row.previous, "Previous libram", "Choose from equipped librams, bag items, and saved selections.")
            hint(row.next, "Next libram", "Choose from equipped librams, bag items, and saved selections.")
        else
            row.itemLabel = label(page, i == 5 and self.FINAL_NAME or "Keep the bag menu open or return to hover mode.", 27, y - 20, "GameFontHighlightSmall")
            row.itemLabel:SetWidth(270); row.itemLabel:SetJustifyH("LEFT")
        end
        row.keyButton = button(page, "OctoLibramMenuBindingKey" .. i, "Not bound", 126, 24)
        row.keyButton:SetPoint("TOPLEFT", page, "TOPLEFT", 309, y - 13)
        row.keyButton.bindingAction = row.action
        row.keyButton:SetScript("OnClick", function() M:StartBindingCapture(this.bindingAction) end)
        row.clearButton = button(page, "OctoLibramMenuBindingClear" .. i, "Clear", 55, 24)
        row.clearButton:SetPoint("TOPLEFT", page, "TOPLEFT", 441, y - 13)
        row.clearButton.bindingAction = row.action
        row.clearButton:SetScript("OnClick", function() M:ClearBinding(this.bindingAction); M:SyncSettings() end)
        hint(row.keyButton, "Assign shortcut", "Click, then press a key or a key with Alt, Ctrl, or Shift. Existing shortcuts are not overwritten. Keys are saved in the game's active account or character binding set.")
        self.bindingRows[i] = row
    end
    self.bindingStatus = label(page, "", 27, -480, "GameFontHighlightSmall")
    self.bindingStatus:SetWidth(468); self.bindingStatus:SetHeight(28); self.bindingStatus:SetJustifyH("LEFT")
end

function M:CreateSoundOptions(page)
    self.soundChecks = {}
    local entries = {
        { "soundEnabled", "Play an alert sound", "Play one sound when a living hostile target enters the 35% health range. This is independent of the visual highlight." },
        { "soundBossesOnly", "Bosses only", "Limit sound to the included raid/world-boss roster or targets classified as world bosses. The visual highlight still works on other enemies." }
    }
    for i, entry in ipairs(entries) do
        local name = "OctoLibramMenuOption" .. entry[1]
        local check = CreateFrame("CheckButton", name, page, "OptionsCheckButtonTemplate")
        check:SetWidth(24); check:SetHeight(24)
        check:SetPoint("TOPLEFT", page, "TOPLEFT", 25, -125 - (i - 1) * 38)
        getglobal(name .. "Text"):SetText(entry[2])
        check.optionKey = entry[1]
        check:SetScript("OnClick", function()
            local checked = this:GetChecked()
            M:SetOption(this.optionKey, checked == 1 or checked == true)
        end)
        hint(check, entry[2], entry[3])
        self.optionChecks[entry[1]], self.soundChecks[entry[1]] = check, check
    end
    local explanation = label(page, "The alert plays once when an eligible target enters the execute range.\nIt never equips a libram automatically.", 27, -215, "GameFontHighlightSmall")
    explanation:SetWidth(468); explanation:SetJustifyH("LEFT")
    label(page, "Alert sound", 27, -275)
    self.soundChoiceButton = button(page, "OctoLibramMenuSoundChoice", "Choose a sound", 324, 28)
    self.soundChoiceButton:SetPoint("TOPLEFT", page, "TOPLEFT", 27, -300)
    self.soundPreviewButton = button(page, "OctoLibramMenuSoundPreview", "Play sample", 135, 28)
    self.soundPreviewButton:SetPoint("TOPLEFT", page, "TOPLEFT", 361, -300)
    self.soundPreviewButton:SetScript("OnClick", function() M:PlayAlertSound(true) end)
    self.soundVolumeSlider = slider(page, "OctoLibramMenuSoundVolume", "soundVolume", 0, 200, 10, -370, "0%", "200%")
    hint(self.soundVolumeSlider, "Alert volume", "Adjust the volume of the alert and sample. Set it to 0% to mute them.")
    self.soundMenu = CreateFrame("Frame", "OctoLibramMenuSoundMenu", page)
    self.soundMenu:SetWidth(468)
    self.soundMenu:SetHeight(12 + math.ceil(table.getn(self.SOUNDS or {}) / 2) * 28)
    -- Open above the selector: eleven choices fit inside the dialog without
    -- reaching its footer or Close button.
    self.soundMenu:SetPoint("BOTTOMLEFT", self.soundChoiceButton, "TOPLEFT", 0, 2)
    self.soundMenu:SetFrameLevel(page:GetFrameLevel() + 8)
    self.soundMenu:EnableMouse(true)
    self.soundMenu:SetClampedToScreen(true)
    self.soundMenu:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    self.soundMenu:SetBackdropColor(0.05, 0.05, 0.05, 1)
    self.soundButtons = {}
    for i, sound in ipairs(self.SOUNDS or {}) do
        local row = math.floor((i - 1) / 2)
        local column = (i - 1) - row * 2
        local choice = button(self.soundMenu, "OctoLibramMenuSound" .. i, sound.name, 226, 24)
        choice:SetPoint("TOPLEFT", self.soundMenu, "TOPLEFT", 6 + column * 230, -6 - row * 28)
        choice.soundID = sound.id
        choice:SetScript("OnClick", function() M:SetOption("soundChoice", this.soundID); M.soundMenu:Hide() end)
        self.soundButtons[i] = choice
    end
    self.soundMenu:Hide()
    self.soundChoiceButton:SetScript("OnClick", function()
        if M.soundMenu:IsVisible() then M.soundMenu:Hide() else M.soundMenu:Show() end
    end)
    local footnote = label(page, "Play sample works even when alerts are disabled, so you can preview\nthe sound before enabling it. Game sound settings still apply.", 27, -435, "GameFontHighlightSmall")
    footnote:SetWidth(468); footnote:SetJustifyH("LEFT")
end

function M:CreateSettingsUI()
    if self.options then return end
    local panel = CreateFrame("Frame", "OctoLibramMenuOptions", UIParent)
    self.options = panel
    panel:SetWidth(520); panel:SetHeight(560)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true); panel:EnableMouse(true); panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 } })
    panel:SetBackdropColor(0.08, 0.08, 0.08, 1)
    panel:SetScript("OnDragStart", function() this:StartMoving() end)
    panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    panel:SetScript("OnShow", function() M:SyncSettings() end)
    panel:SetScript("OnHide", function()
        GameTooltip:Hide(); this:StopMovingOrSizing()
        if M.CancelBindingCapture then M:CancelBindingCapture() end
        if M.soundMenu then M.soundMenu:Hide() end
    end)
    label(panel, "OctoLibramMenu " .. self.VERSION, 25, -24, "GameFontNormalLarge")
    local subtitle = label(panel, "Settings are saved for this character and apply immediately.", 25, -50, "GameFontHighlightSmall")
    subtitle:SetWidth(468); subtitle:SetJustifyH("LEFT")
    self.optionTabs, self.optionPages = {}, {}
    local tabNames = { "general", "bindings", "sound" }
    for i, name in ipairs(tabNames) do
        local tab = button(panel, "OctoLibramMenuTab" .. name, name, 150, 26)
        tab:SetPoint("TOPLEFT", panel, "TOPLEFT", 27 + (i - 1) * 160, -74)
        tab.optionTab = name
        tab:SetScript("OnClick", function() M:SelectOptionsTab(this.optionTab) end)
        self.optionTabs[name] = tab
        local page = CreateFrame("Frame", "OctoLibramMenuPage" .. name, panel)
        page:SetAllPoints(panel)
        self.optionPages[name] = page
    end
    local general = self.optionPages.general
    self.optionChecks = {}
    local checks = {
        { "shown", "Show libram panel", "Show the equipped libram and its selection menu." },
        { "keepOpen", "Librams always shown", "Keep the librams in your bags visible beside the equipped libram." },
        { "locked", "Locked", "Prevent moving the libram panel and minimap button." },
        { "showMinimap", "Show minimap button", "Left click toggles the libram panel; right click opens these settings." },
        { "showTooltips", "Show tooltips", "Show item details and control hints when you hover." },
        { "alertEnabled", "Highlight Final Judgement at 35% HP", "Show a highlighted swap button for a living hostile target at 35% health or less." }
    }
    for i, entry in ipairs(checks) do
        local name = "OctoLibramMenuOption" .. entry[1]
        local check = CreateFrame("CheckButton", name, general, "OptionsCheckButtonTemplate")
        check:SetWidth(24); check:SetHeight(24)
        check:SetPoint("TOPLEFT", general, "TOPLEFT", 25, -120 - (i - 1) * 28)
        getglobal(name .. "Text"):SetText(entry[2])
        check.optionKey = entry[1]
        check:SetScript("OnClick", function()
            local checked = this:GetChecked()
            M:SetOption(this.optionKey, checked == 1 or checked == true)
        end)
        hint(check, entry[2], entry[3])
        self.optionChecks[entry[1]] = check
    end
    local separator = general:CreateTexture(nil, "ARTWORK")
    separator:SetTexture(0.6, 0.5, 0.25, 0.5)
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", general, "TOPLEFT", 25, -298)
    separator:SetPoint("TOPRIGHT", general, "TOPRIGHT", -25, -298)
    self.scaleSlider = slider(general, "OctoLibramMenuScale", "scale", 0.6, 2, 0.05, -330, "60%", "200%")
    self.columnsSlider = slider(general, "OctoLibramMenuColumns", "columns", 1, 8, 1, -384, "1", "8")
    label(general, "Menu direction", 27, -423)
    self.directionLeft = button(general, "OctoLibramMenuDirectionLeft", "Left", 120, 24)
    self.directionRight = button(general, "OctoLibramMenuDirectionRight", "Right", 120, 24)
    self.directionLeft:SetPoint("TOPLEFT", general, "TOPLEFT", 218, -418)
    self.directionRight:SetPoint("TOPLEFT", general, "TOPLEFT", 344, -418)
    self.directionLeft:SetScript("OnClick", function() M:SetOption("direction", "LEFT") end)
    self.directionRight:SetScript("OnClick", function() M:SetOption("direction", "RIGHT") end)
    local footer = label(general, "Alt / Ctrl / Shift + drag: move the unlocked panel.\nEquipment changes only on your click or key press.", 27, -465, "GameFontHighlightSmall")
    footer:SetWidth(468); footer:SetJustifyH("LEFT")
    self.resetButton = button(general, "OctoLibramMenuResetPosition", "Reset position", 140, 24)
    self.resetButton:SetPoint("BOTTOMLEFT", general, "BOTTOMLEFT", 27, 22)
    self.resetButton:SetScript("OnClick", function() M:ResetPosition() end)
    local close = button(panel, "OctoLibramMenuOptionsClose", "Close", 100, 24)
    close:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -27, 22)
    close:SetScript("OnClick", function() M.options:Hide() end)
    self.optionsClose = close
    self:CreateBindingOptions(self.optionPages.bindings)
    self:CreateSoundOptions(self.optionPages.sound)
    table.insert(UISpecialFrames, "OctoLibramMenuOptions")
    self:SelectOptionsTab("general")
    panel:Hide()
    self:CreateMinimapButton()
    self:InstallGameMenuButton()
    self:SyncSettings()
end

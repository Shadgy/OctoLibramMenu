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
    getglobal("OctoLibramMenuScaleText"):SetText("Scale: " .. math.floor(self.db.scale * 100 + 0.5) .. "%")
    getglobal("OctoLibramMenuColumnsText"):SetText("Menu columns: " .. self.db.columns)
    self.directionLeft:SetText(self.db.direction == "LEFT" and "|cffffd166Left|r" or "Left")
    self.directionRight:SetText(self.db.direction == "RIGHT" and "|cffffd166Right|r" or "Right")
    self.syncingOptions = nil
    self:UpdateMinimapButton()
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

function M:CreateSettingsUI()
    if self.options then return end
    local panel = CreateFrame("Frame", "OctoLibramMenuOptions", UIParent)
    self.options = panel
    panel:SetWidth(440); panel:SetHeight(520)
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
    panel:SetScript("OnHide", function() GameTooltip:Hide(); this:StopMovingOrSizing() end)
    label(panel, "OctoLibramMenu " .. self.VERSION, 25, -24, "GameFontNormalLarge")
    local subtitle = label(panel, "Settings are saved for this character and apply immediately.", 25, -50, "GameFontHighlightSmall")
    subtitle:SetWidth(390); subtitle:SetJustifyH("LEFT")
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
        local check = CreateFrame("CheckButton", name, panel, "OptionsCheckButtonTemplate")
        check:SetWidth(24); check:SetHeight(24)
        check:SetPoint("TOPLEFT", panel, "TOPLEFT", 25, -80 - (i - 1) * 28)
        getglobal(name .. "Text"):SetText(entry[2])
        check.optionKey = entry[1]
        check:SetScript("OnClick", function()
            local checked = this:GetChecked()
            M:SetOption(this.optionKey, checked == 1 or checked == true)
        end)
        hint(check, entry[2], entry[3])
        self.optionChecks[entry[1]] = check
    end
    local separator = panel:CreateTexture(nil, "ARTWORK")
    separator:SetTexture(0.6, 0.5, 0.25, 0.5)
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", panel, "TOPLEFT", 25, -258)
    separator:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -25, -258)
    local function slider(name, key, min, max, step, y, low, high)
        local control = CreateFrame("Slider", name, panel, "OptionsSliderTemplate")
        control:SetWidth(370); control:SetHeight(16)
        control:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, y)
        control:SetMinMaxValues(min, max); control:SetValueStep(step)
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
    self.scaleSlider = slider("OctoLibramMenuScale", "scale", 0.6, 2, 0.05, -290, "60%", "200%")
    self.columnsSlider = slider("OctoLibramMenuColumns", "columns", 1, 8, 1, -344, "1", "8")
    label(panel, "Menu direction", 27, -383)
    self.directionLeft = button(panel, "OctoLibramMenuDirectionLeft", "Left", 100, 24)
    self.directionRight = button(panel, "OctoLibramMenuDirectionRight", "Right", 100, 24)
    self.directionLeft:SetPoint("TOPLEFT", panel, "TOPLEFT", 178, -378)
    self.directionRight:SetPoint("TOPLEFT", panel, "TOPLEFT", 284, -378)
    self.directionLeft:SetScript("OnClick", function() M:SetOption("direction", "LEFT") end)
    self.directionRight:SetScript("OnClick", function() M:SetOption("direction", "RIGHT") end)
    local footer = label(panel, "Alt / Ctrl / Shift + drag: move the unlocked panel.\nFinal Judgement is equipped only when you click.", 27, -425, "GameFontHighlightSmall")
    footer:SetWidth(386); footer:SetJustifyH("LEFT")
    self.resetButton = button(panel, "OctoLibramMenuResetPosition", "Reset position", 140, 24)
    self.resetButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 27, 22)
    self.resetButton:SetScript("OnClick", function() M:ResetPosition() end)
    local close = button(panel, "OctoLibramMenuOptionsClose", "Close", 100, 24)
    close:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -27, 22)
    close:SetScript("OnClick", function() M.options:Hide() end)
    self.optionsClose = close
    table.insert(UISpecialFrames, "OctoLibramMenuOptions")
    panel:Hide()
    self:CreateMinimapButton()
    self:InstallGameMenuButton()
    self:SyncSettings()
end

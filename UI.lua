local M = OctoLibramMenu
BINDING_HEADER_OCTOLIBRAMMENU = "OctoLibramMenu"
BINDING_NAME_OCTOLIBRAMMENU_FINAL = "Zaloz Libram of Final Judgement"
BINDING_NAME_OCTOLIBRAMMENU_TOGGLE = "Przypnij / odepnij menu libramow"

local function backdrop(frame)
    frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    frame:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
    frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

function M:BeginDrag(source)
    if not self.db.locked and (IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()) then
        self.dragSource = source or self.root
        self.dragging = true
        self.root:StartMoving()
    end
end

function M:EndDrag()
    if not self.dragging then return end
    self.dragging = nil
    self.draggedButton, self.dragSource = self.dragSource, nil
    self.root:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self.root:GetPoint()
    self.db.position = { point = point, relativePoint = relativePoint, x = x, y = y }
    self:Refresh()
end

function M:OpensLeft(width)
    local left = self.db.direction == "LEFT"
    local xLeft, xRight = self.root:GetLeft(), self.root:GetRight()
    local screenWidth = UIParent:GetWidth() / self.db.scale
    if xLeft and xRight then
        if left and xRight - width < 4 then left = false
        elseif not left and xLeft + width > screenWidth - 4 then left = true end
    end
    return left
end

function M:ApplyPosition()
    self.root:SetScale(self.db.scale)
    self.root:ClearAllPoints()
    local pos = self.db.position
    if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
        self.root:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x, pos.y)
    else self.root:SetPoint("CENTER", UIParent, "CENTER", 0, -120) end
end

function M:Tooltip(button)
    if self.db.showTooltips == false then return end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    if button.role == "main" and self.equipped then
        GameTooltip:SetInventoryItem("player", self.SLOT)
    elseif button.item and button.item.bag ~= nil then
        GameTooltip:SetBagItem(button.item.bag, button.item.slot)
    else GameTooltip:SetText("Libramy") end
    if button.role == "final" then
        GameTooltip:AddLine("Cel ma 35% HP lub mniej. Kliknij, aby zalozyc.", 1, 0.82, 0.2, true)
    elseif button.role == "main" then
        GameTooltip:AddLine("Najedz: wybor libramu. PPM: przypnij menu.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Alt / Ctrl / Shift + przeciagniecie: przesun panel.", 0.8, 0.8, 0.8, true)
    else GameTooltip:AddLine("Kliknij, aby zalozyc libram.", 0.8, 0.8, 0.8, true) end
    GameTooltip:Show()
    self.tooltipButton = button
end

function M:ClearTooltip()
    GameTooltip:Hide()
    self.tooltipButton = nil
end

function M:ButtonClick(button, mouseButton)
    -- Dropping a moved panel must not also activate the dragged item.
    if self.draggedButton == button then self.draggedButton = nil; return end
    if self.dragging or IsAltKeyDown() then return end
    local item = button.role == "main" and self.equipped or button.item
    if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsVisible() then
        if item then ChatFrameEditBox:Insert(item.link) end
        return
    end
    if button.role == "main" then
        if mouseButton == "RightButton" then
            self:SetOption("keepOpen", not self.db.keepOpen)
        elseif self.equipped then UseInventoryItem(self.SLOT) end
    elseif item and self:EquipID(item.id) then
        self:ClearTooltip()
        if not self.db.keepOpen then self.menu:Hide() end
    end
end

function M:MakeButton(name, parent, role)
    local button = CreateFrame("Button", name, parent)
    button.role = role
    button:SetWidth(36); button:SetHeight(36)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    button.border:SetPoint("TOPLEFT", button, "TOPLEFT", -7, 7)
    button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 7, -7)
    button.cooldown = CreateFrame("Model", name .. "Cooldown", button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints(button)
    button.cooldown:EnableMouse(false)
    -- Gold border above cooldown, with four narrow strips and a soft pulse.
    button.glow = CreateFrame("Frame", nil, button)
    button.glow:SetAllPoints(button)
    button.glow:SetFrameLevel(button.cooldown:GetFrameLevel() + 2)
    local edges = { { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" },
        { "TOPLEFT", "BOTTOMLEFT" }, { "TOPRIGHT", "BOTTOMRIGHT" } }
    for i, points in ipairs(edges) do
        local edge = button.glow:CreateTexture(nil, "OVERLAY")
        edge:SetTexture(1, 0.72, 0.08, 1)
        edge:SetPoint(points[1], button.glow, points[1], 0, 0)
        edge:SetPoint(points[2], button.glow, points[2], 0, 0)
        if i <= 2 then edge:SetHeight(3) else edge:SetWidth(3) end
    end
    button.glow:Hide()
    -- Countdown lives separately so it also appears on non-highlighted items.
    button.timer = CreateFrame("Frame", nil, button)
    button.timer:SetAllPoints(button)
    button.timer:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
    button.timeText = button.timer:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.timeText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button:SetScript("OnEnter", function()
        M.leaveAt = nil
        if this.role == "main" then M:OpenMenu() end
        M:Tooltip(this)
    end)
    button:SetScript("OnLeave", function() M:ClearTooltip() end)
    button:SetScript("OnMouseDown", function() M.draggedButton = nil end)
    button:SetScript("OnClick", function() M:ButtonClick(this, arg1) end)
    button:SetScript("OnDragStart", function() M:BeginDrag(this) end)
    button:SetScript("OnDragStop", function() M:EndDrag() end)
    return button
end

function M:CreateUI()
    self.root = CreateFrame("Frame", "OctoLibramMenuFrame", UIParent)
    self.root:SetWidth(48); self.root:SetHeight(48)
    self.root:SetFrameStrata("MEDIUM")
    self.root:SetMovable(true); self.root:EnableMouse(true)
    self.root:SetClampedToScreen(true)
    self.root:RegisterForDrag("LeftButton")
    self.root:SetScript("OnMouseDown", function() M.draggedButton = nil end)
    self.root:SetScript("OnDragStart", function() M:BeginDrag(this) end)
    self.root:SetScript("OnDragStop", function() M:EndDrag() end)
    self.root:SetScript("OnHide", function() M:ClearTooltip(); M:EndDrag() end)
    backdrop(self.root)
    self.main = self:MakeButton("OctoLibramMenuCurrent", self.root, "main")
    self.main:SetPoint("TOPLEFT", self.root, "TOPLEFT", 6, -6)
    self.quick = self:MakeButton("OctoLibramMenuFinal", self.root, "final")
    self.quick:Hide()
    self.quick.label = self.quick.glow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.quick.label:SetPoint("TOP", self.quick, "BOTTOM", 0, -4)
    self.quick.label:SetText("<=35%")
    self.menu = CreateFrame("Frame", "OctoLibramMenuFlyout", self.root)
    self.menu:SetFrameLevel(self.root:GetFrameLevel() + 5)
    self.menu:EnableMouse(true)
    self.menu:SetClampedToScreen(true)
    backdrop(self.menu)
    self.menu:SetScript("OnEnter", function() M.leaveAt = nil end)
    self.menu:SetScript("OnHide", function() M:ClearTooltip() end)
    self.menu:Hide()
    self.buttons = {}
    self:ApplyPosition()
end

function M:LayoutMenu()
    local count = table.getn(self.items)
    local columns = math.min(self.db.columns, math.max(1, count))
    local rows = math.max(1, math.ceil(count / columns))
    local width, height = 12 + columns * 40, 12 + rows * 40
    local left = self:OpensLeft(width)
    local bottom = self.root:GetBottom()
    local above = bottom and bottom < height + 14
    self.menu:ClearAllPoints()
    local edge = left and "RIGHT" or "LEFT"
    if above then self.menu:SetPoint("BOTTOM" .. edge, self.root, "TOP" .. edge, 0, 14)
    else self.menu:SetPoint("TOP" .. edge, self.root, "BOTTOM" .. edge, 0, -14) end
    self.menu:SetWidth(width)
    self.menu:SetHeight(height)
    for i, item in ipairs(self.items) do
        local button = self.buttons[i]
        if not button then
            button = self:MakeButton("OctoLibramMenuItem" .. i, self.menu, "item")
            self.buttons[i] = button
        end
        button.item = item
        button.icon:SetTexture(item.texture)
        button:ClearAllPoints()
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) - row * columns
        if left then
            button:SetPoint("TOPRIGHT", self.menu, "TOPRIGHT", -6 - col * 40, -6 - row * 40)
        else button:SetPoint("TOPLEFT", self.menu, "TOPLEFT", 6 + col * 40, -6 - row * 40) end
        button:Show()
    end
    for i = count + 1, table.getn(self.buttons) do self.buttons[i].item = nil; self.buttons[i]:Hide() end
    if count == 0 then self.menu:Hide() end
end

function M:OpenMenu()
    if not self.ready or not self.db.shown then return end
    self:Scan()
    if table.getn(self.items) > 0 then self.menu:Show(); self.leaveAt = nil end
end

function M:Refresh()
    if not self.root then return end
    -- A scan can replace or move a hovered bag record. Hide the old tooltip.
    if self.tooltipButton then self:ClearTooltip() end
    self.main.item = self.equipped
    self.main.icon:SetTexture(self.equipped and self.equipped.texture or "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged")
    self.quick.item = self.final
    self.quick.icon:SetTexture(self.final and self.final.texture or "Interface\\Icons\\INV_Relics_LibramofTruth")
    self.quick:ClearAllPoints()
    if self:OpensLeft(90) then
        self.quick:SetPoint("RIGHT", self.root, "LEFT", -6, 0)
    else self.quick:SetPoint("LEFT", self.root, "RIGHT", 6, 0) end
    self:LayoutMenu()
    if self.db.shown then self.root:Show() else self.root:Hide() end
    if self.db.keepOpen and table.getn(self.items) > 0 then self.menu:Show() end
    self:RefreshAlert()
end

function M:RefreshAlert()
    if not self.root then return end
    local equippedFinal = self.equipped and self.equipped.id == self.FINAL_ID
    if self.alert and equippedFinal then self.main.glow:Show() else self.main.glow:Hide() end
    if self.alert and not equippedFinal and self.db.shown then self.quick:Show(); self.quick.glow:Show()
    else self.quick:Hide() end
    for _, button in ipairs(self.buttons) do
        if self.alert and button.item and button.item.id == self.FINAL_ID then button.glow:Show()
        else button.glow:Hide() end
    end
    if self.tooltipButton and not self.tooltipButton:IsVisible() then self:ClearTooltip() end
end

function M:ButtonCooldown(button, inventory)
    local start, duration, enabled, locked
    if inventory and self.equipped then
        start, duration, enabled = GetInventoryItemCooldown("player", self.SLOT)
        locked = IsInventoryItemLocked(self.SLOT)
    elseif button.item and button.item.bag ~= nil then
        start, duration, enabled = GetContainerItemCooldown(button.item.bag, button.item.slot)
        local _, _, itemLocked = GetContainerItemInfo(button.item.bag, button.item.slot)
        locked = itemLocked
    end
    CooldownFrame_SetTimer(button.cooldown, start or 0, duration or 0, enabled or 0)
    button.icon:SetDesaturated(locked and 1 or nil)
    local remaining = (start or 0) + (duration or 0) - GetTime()
    if remaining > 1.5 and enabled == 1 then
        button.timeText:SetText(remaining >= 60 and (math.ceil(remaining / 60) .. "m") or math.ceil(remaining))
    else button.timeText:SetText("") end
end

function M:UpdateUI()
    if not self.root or not self.root:IsVisible() then return end
    local pulse = 0.7 + 0.3 * math.sin(GetTime() * 5)
    self.main.glow:SetAlpha(pulse); self.quick.glow:SetAlpha(pulse)
    self:ButtonCooldown(self.main, true)
    if self.quick:IsVisible() then self:ButtonCooldown(self.quick) end
    if self.menu:IsVisible() then
        for _, button in ipairs(self.buttons) do
            if button:IsVisible() then self:ButtonCooldown(button); button.glow:SetAlpha(pulse) end
        end
        if not self.db.keepOpen and not self.dragging then
            if MouseIsOver(self.root) or MouseIsOver(self.quick) and self.quick:IsVisible() or MouseIsOver(self.menu) then
                self.leaveAt = nil
            elseif not self.leaveAt then self.leaveAt = GetTime()
            elseif GetTime() - self.leaveAt > 0.35 then self.menu:Hide(); self.leaveAt = nil end
        end
    end
end

CombatLogSetRetentionTime(20)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:SetOwner(parent, "ANCHOR_NONE");
	tooltip:SetPoint("TOP", "UIParent", "TOP", 0, -25);
	tooltip.default = 1;
end)

-- AchievementAlertFrame
hooksecurefunc("AchievementAlertFrame_FixAnchors", function()
	if ( not AchievementAlertFrame1 ) then return end
	AchievementAlertFrame1:ClearAllPoints()
	AchievementAlertFrame1:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end)

-- movable options window
InterfaceOptionsFrame:SetMovable(true)
InterfaceOptionsFrame:RegisterForDrag("LeftButton")
InterfaceOptionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
InterfaceOptionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local fx = CreateFrame("Frame", nil)
fx:SetScript("OnEvent", function(self, event, name)
	if name == "Blizzard_CombatLog" then
		-- print("trying to disable combatlog")
		-- fully disable blizzard's combatlog		
		
		-- step 1, check when it fires
		local oldCombatLog_AddEvent = CombatLog_AddEvent
		CombatLog_AddEvent = function(...)
			print(...)
			oldCombatLog_AddEvent(...)
		end
		
		-- remoooooove it :p
		-- Blizzard_CombatLog_QuickButton_OnClick = function() end
		COMBATLOG:GetScript("OnHide")(COMBATLOG)
		COMBATLOG:SetScript("OnShow", nil)
	end
end)
fx:RegisterEvent("ADDON_LOADED")

RaidFramePanelOptions.raidFramesHeight = { text = "RAID_FRAMES_HEIGHT", minValue = 12, maxValue = 72, valueStep = 2 }
RaidFramePanelOptions.raidFramesWidth = { text = "RAID_FRAMES_WIDTH", minValue = 24, maxValue = 144, valueStep = 2 }
	
CompactRaidFrameContainer.flowHorizontalSpacing = 1

-- move default unit frames
--[[
PlayerFrame:ClearAllPoints()
PlayerFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -30, 190)
TargetFrame:ClearAllPoints()
TargetFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 30, 190)
--]]


local landmounts = {
	"Swift Mistsaber",
}

local airmounts = {
	"Snowy Gryphon",
}

local function GetMount(allowed)
	local ml = {}
	local nc = GetNumCompanions(MOUNT)
	for i = 1, nc do
		local _, mn = GetCompanionInfo(MOUNT, i)
		ml[i] = mn
	end
	for k, v in pairs(allowed) do
		for i = 1, nc do
			if ml[i] == v then return i end
		end
	end
end

-- mount command
function clcMount()
	if IsMounted() then DismissCompanion(MOUNT) return end
	
	local mount
	if IsFlyableArea() then
		mount = GetMount(airmounts)
	else
		mount = GetMount(landmounts)
	end
	
	if mount then CallCompanion(MOUNT, mount) end
end

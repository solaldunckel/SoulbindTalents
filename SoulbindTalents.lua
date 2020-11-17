local _, SoulbindTalents = ...

local defaults_settings = {
	profile = {
		disableFX = false,
		conduitTooltipRank = false,
	}
}

SoulbindTalents = LibStub("AceAddon-3.0"):NewAddon(SoulbindTalents, "SoulbindTalents")

LibStub("AceEvent-3.0"):Embed(SoulbindTalents)
LibStub("AceHook-3.0"):Embed(SoulbindTalents)

SOULBIND_TAB = 4

local CONDUIT_RANKS = {
	[1] = C_Soulbinds.GetConduitItemLevel(0, 1),
	[2] = C_Soulbinds.GetConduitItemLevel(0, 2),
	[3] = C_Soulbinds.GetConduitItemLevel(0, 3),
	[4] = C_Soulbinds.GetConduitItemLevel(0, 4),
	[5] = C_Soulbinds.GetConduitItemLevel(0, 5),
	[6] = C_Soulbinds.GetConduitItemLevel(0, 6),
	[7] = C_Soulbinds.GetConduitItemLevel(0, 7),
}

function SoulbindTalents:OnEnable()
	self.db = LibStub("AceDB-3.0"):New("SoulbindTalentsDB", defaults_settings, true)
	self.settings = self.db.profile

	self:SetupOptions()

	self:RegisterEvent("SOULBIND_FORGE_INTERACTION_ENDED")
	self:RegisterEvent("SOULBIND_ACTIVATED")
	self:RegisterEvent("ADDON_LOADED")

	self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
	self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
	self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')

	if self.settings.disableFX then
		SetCVar("ShakeStrengthUI", 0)
	end
end

function SoulbindTalents:SetupOptions()
	self.options = {
		type = "group",
		set = function(info, val) self.db.profile[info[#info]] = val end,
		get = function(info) return self.db.profile[info[#info]] end,
		args = {
			author = {
				type = "description",
				name = "|cffffd100Author: |r Kygo @ EU-Hyjal",
				order = 1
			},
			version = {
				type = "description",
				name = "|cffffd100Version: |r" .. GetAddOnMetadata("SoulbindTalents", "Version"),
				order = 2
			},
			title = {
				type = "description",
				fontSize = "large",
				name = "\n\n|cffffd100Options :|r\n\n",
				order = 3
			},
			disableFX = {
				name = "Disable FX",
				desc = "Disable Shaking, Link Animations, Background Animations..",
				width = "full",
				type = "toggle",
				order = 10,
			},
			conduitTooltipRank = {
				name = "Show Conduit Rank on Tooltip",
				desc = "Replace Item Level of Conduits by its Rank",
				type = "toggle",
				width = "full",
				order = 11,
			},
		}
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("SoulbindTalents", self.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SoulbindTalents", "SoulbindTalents")
end

function SoulbindTalents:AppendSoulbindFrame()
	SoulbindViewer:SetParent(PlayerTalentFrameSoulbind)
	SoulbindViewer:SetScale(0.85)

	SoulbindViewer:ClearAllPoints()
	SoulbindViewer:SetPoint("TOPLEFT", PlayerTalentFrameSoulbind)
	SoulbindViewer:SetPoint("BOTTOMRIGHT", PlayerTalentFrameSoulbind)

	SoulbindViewer.CloseButton:Hide()
	SoulbindViewer.Border:Hide()
	SoulbindViewer.ShadowTop:Hide()
	SoulbindViewer.ShadowLeft:Hide()
	SoulbindViewer.ShadowBottom:Hide()
	SoulbindViewer.ShadowRight:Hide()

	SoulbindViewer.Background:ClearAllPoints()
	SoulbindViewer.Background:SetParent(PlayerTalentFrameSoulbind)
	SoulbindViewer.Background:SetDrawLayer("BACKGROUND", -1)
	SoulbindViewer.Background:SetPoint("TOPLEFT", PlayerTalentFrameSoulbind)
	SoulbindViewer.Background:SetPoint("BOTTOMRIGHT", PlayerTalentFrameSoulbind)

	SoulbindViewer.ConduitList.ScrollBar:ClearAllPoints()
	SoulbindViewer.ConduitList.ScrollBar:SetPoint("TOPRIGHT", SoulbindViewer.ConduitList, -6, 0)
	SoulbindViewer.ConduitList.ScrollBar:SetPoint("BOTTOMRIGHT", SoulbindViewer.ConduitList, -6, 0)

	if self.settings.disableFX then
		SoulbindViewer.Fx:Hide()
		SoulbindViewer:SetSheenAnimationsPlaying(false)
	end

	SoulbindViewer.ActivateFX:ClearAllPoints()
	SoulbindViewer.ActivateFX:SetPoint("TOPLEFT", SoulbindViewer, "TOPLEFT", 197, -22)

	SoulbindViewer.ActivateFX2:ClearAllPoints()
	SoulbindViewer.ActivateFX2:SetPoint("TOPLEFT", SoulbindViewer, "TOPLEFT", 197, -22)

	SoulbindViewer.Background2:ClearAllPoints()
	SoulbindViewer.Background2:SetParent(PlayerTalentFrameSoulbind)

	SoulbindViewer.BackgroundBlackOverlay:SetParent(PlayerTalentFrameSoulbind)
	SoulbindViewer.BackgroundBlackOverlay:SetDrawLayer("BACKGROUND", -1)

	SoulbindViewer.ActivateSoulbindButton:ClearAllPoints()
	SoulbindViewer.ActivateSoulbindButton:SetPoint("BOTTOM", SoulbindViewer, "BOTTOM", -90, 15)

	SoulbindViewer.SelectGroup:ClearAllPoints()
	SoulbindViewer.SelectGroup:SetPoint("LEFT", SoulbindViewer, "LEFT", 15, 0)
end

function SoulbindTalents:RestoreSoulbindFrame()
	SoulbindViewer:SetParent(UIParent)
	SoulbindViewer:SetScale(1)

	SoulbindViewer:ClearAllPoints()
	SoulbindViewer:SetPoint("CENTER")

	SoulbindViewer.CloseButton:Show()
	SoulbindViewer.Border:Show()
	SoulbindViewer.ShadowTop:Show()
	SoulbindViewer.ShadowLeft:Show()
	SoulbindViewer.ShadowBottom:Show()
	SoulbindViewer.ShadowRight:Show()

	SoulbindViewer.Background:ClearAllPoints()
	SoulbindViewer.Background:SetParent(SoulbindViewer)
	SoulbindViewer.Background:SetPoint("TOPLEFT", SoulbindViewer, "TOPLEFT", 26, -25)

	SoulbindViewer.ConduitList.ScrollBar:ClearAllPoints()
	SoulbindViewer.ConduitList.ScrollBar:SetPoint("TOPRIGHT", SoulbindViewer.ConduitList, "TOPRIGHT", -6, -36)

	if self.settings.disableFX then
		SoulbindViewer.Fx:Hide()
	end

	SoulbindViewer.ActivateFX:ClearAllPoints()
	SoulbindViewer.ActivateFX:SetPoint("TOPLEFT", SoulbindViewer, "TOPLEFT", 212, -45)

	SoulbindViewer.ActivateFX2:ClearAllPoints()
	SoulbindViewer.ActivateFX2:SetPoint("TOPLEFT", SoulbindViewer, "TOPLEFT", 212, -45)

	SoulbindViewer.Background2:ClearAllPoints()
	SoulbindViewer.Background2:SetParent(SoulbindViewer)

	SoulbindViewer.BackgroundBlackOverlay:SetParent(SoulbindViewer)
	SoulbindViewer.BackgroundBlackOverlay:SetDrawLayer("BACKGROUND", -1)

	SoulbindViewer.ActivateSoulbindButton:ClearAllPoints()
	SoulbindViewer.ActivateSoulbindButton:SetPoint("TOP", SoulbindViewer, "BOTTOM", -93, 72)

	SoulbindViewer.SelectGroup:ClearAllPoints()
	SoulbindViewer.SelectGroup:SetPoint("LEFT", SoulbindViewer, "LEFT", 42, 15)
end

function SoulbindTalents:ShowSoulbindsTab()
	if not SoulbindViewer:IsShown() then
		local soulbindID = C_Soulbinds.GetActiveSoulbindID();
		local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
		local covenantData = C_Covenants.GetCovenantData(soulbindData.covenantID);
		SoulbindViewer:Init(covenantData, soulbindData);

		self:AppendSoulbindFrame()

		SoulbindViewer:Show();
	end

	PlayerTalentFrameSoulbind:Show()
	PlayerTalentFrame:SetTitle("Soulbinds")
	PlayerTalentFrame:SetHeight(588)
end

function SoulbindTalents:HideSoulbindsTab()
	PlayerTalentFrameSoulbind:Hide()
	if SoulbindViewer:IsShown() then
		SoulbindViewer:Hide();
		ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
	end
	PlayerTalentFrameTab1:Show()
	PlayerTalentFrameTab2:Show()
	if self.petTab then
		PlayerTalentFrameTab3:Show()
	end
	if self.soulbindID ~= 0 then
		PlayerTalentFrameTab4:Show()
	end
end

function SoulbindTalents:PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);

	if (selectedTab == TALENTS_TAB) then
		self:HideSoulbindsTab()
		PlayerTalentFrame:SetHeight(468)
	elseif (selectedTab == SPECIALIZATION_TAB) then
		self:HideSoulbindsTab()
		PlayerTalentFrame:SetHeight(468)
	elseif (selectedTab == PET_SPECIALIZATION_TAB) then
		self:HideSoulbindsTab()
		PlayerTalentFrame:SetHeight(468)
	elseif (selectedTab == SOULBIND_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_HidePetSpecTab();
		self:ShowSoulbindsTab();
		PlayerTalentFrame_SetExpanded(true);
	end
end

function SoulbindTalents:PlayerTalentFrame_Close()
	self:HideSoulbindsTab()
	self:RestoreSoulbindFrame()
end

function SoulbindTalents:PlayerTalentFrame_OnHide()
	if not PlayerTalentFrame:IsShown() then
		self:HideSoulbindsTab()
		self:RestoreSoulbindFrame()
	end
end

function SoulbindTalents:SoulbindViewer_OnOpen()
	if not PlayerTalentFrame:IsShown() then
		ToggleTalentFrame(4)
	elseif PlayerTalentFrame:IsShown() then
		local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
		if (selectedTab ~= SOULBIND_TAB) then
			PanelTemplates_SetTab(PlayerTalentFrame, 4)
			self:PlayerTalentFrame_Refresh()
		end
	end
	if C_Soulbinds.CanModifySoulbind() then
		PlayerTalentFrameTab1:Hide()
		PlayerTalentFrameTab2:Hide()
		if self.petTab then
			PlayerTalentFrameTab3:Hide()
		end
		PlayerTalentFrameTab4:Hide()
	end
end

local ItemLevelPattern = gsub(ITEM_LEVEL, "%%d", "(%%d+)")

function SoulbindTalents:ConduitTooltip_Rank(tooltip, rank)
	local text, level
	local textLeft = tooltip.textLeft
	if not textLeft then
		local tooltipName = tooltip:GetName()
		textLeft = setmetatable({}, { __index = function(t, i)
			local line = _G[tooltipName .. "TextLeft" .. i]
			t[i] = line
			return line
		end })
		tooltip.textLeft = textLeft
	end
	for i = 2, 5 do
		if _G[tooltip:GetName() .. "TextLeft" .. i] then
			local line = textLeft[i]
			text = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText() or ""
			level = string.match(text, ItemLevelPattern)
			if (level) then
				line:SetText("Rank " .. rank)
				return ;
			end
		end
	end
end

function SoulbindTalents:TooltipHook(tooltip)
	if not self.settings.conduitTooltipRank then return end

	local name, itemLink = tooltip:GetItem()
	if not name then return end

	if C_Soulbinds.IsItemConduitByItemInfo(itemLink) then
		local itemLevel = select(4, GetItemInfo(itemLink))

		for rank, level in pairs(CONDUIT_RANKS) do
			if itemLevel == level then
				self:ConduitTooltip_Rank(tooltip, rank);
			end
		end
	end
end

function SoulbindTalents:ConduitRank(conduit, conduitData)
	local itemID = conduitData.conduitItemID;
	local item = Item:CreateFromItemID(itemID);
	local itemCallback = function()
		conduit.ConduitName:SetSize(150, 30);
		conduit.ConduitName:SetText(item:GetItemName());
		conduit.ConduitName:SetHeight(conduit.ConduitName:GetStringHeight());

		local yOffset = conduit.ConduitName:GetNumLines() > 1 and -6 or 0;
		conduit.ConduitName:ClearAllPoints();
		conduit.ConduitName:SetPoint("BOTTOMLEFT", conduit.Icon, "RIGHT", 10, yOffset);
		conduit.ConduitName:SetWidth(150);

		conduit.ItemLevel:SetPoint("TOPLEFT", conduit.ConduitName, "BOTTOMLEFT", 0, 0);
		conduit.ItemLevel:SetText("Rank " .. conduitData.conduitRank);
		conduit.ItemLevel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end;
	item:ContinueOnItemLoad(itemCallback);

	local conduitSpecName = conduitData.conduitSpecName;
	if conduitSpecName then
		local specIDs = C_SpecializationInfo.GetSpecIDs(conduitData.conduitSpecSetID);

		local isCurrentSpec = C_SpecializationInfo.MatchesCurrentSpecSet(conduitData.conduitSpecSetID);
		if isCurrentSpec then
			conduit.Spec.stateAlpha = 1;
			conduit.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
			conduit.ItemLevel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		else
			conduit.Spec.stateAlpha = .4;
			conduit.Spec.stateAtlas = "soulbinds_collection_specborder_secondary";
			conduit.ItemLevel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end
		conduit.Spec.Icon:SetAlpha(conduit.Spec.stateAlpha);

		conduit.Spec:Show();
	else
		conduit.ItemLevel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		conduit.Spec:Hide();
		conduit.Spec:SetScript("OnEnter", nil);
		conduit.Spec:SetScript("OnLeave", nil);
		conduit.Spec.stateAlpha = 1;
		conduit.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
	end

	conduit:Update();
end

function SoulbindTalents:AnimationFX(viewer)
	if self.settings.disableFX then
		viewer.ForgeSheen.Anim:SetPlaying(false);
		viewer.BackgroundSheen1.Anim:SetPlaying(false);
		viewer.BackgroundSheen2.Anim:SetPlaying(false);
		viewer.GridSheen.Anim:SetPlaying(false);
		viewer.BackgroundRuneLeft.Anim:SetPlaying(false);
		viewer.BackgroundRuneRight.Anim:SetPlaying(false);
		viewer.ConduitList.Fx.ChargeSheen.Anim:SetPlaying(false);
	end
end

function SoulbindTalents:NodeFX(viewer)
	if self.settings.disableFX then
		viewer.FlowAnim1:Stop();
		viewer.FlowAnim2:Stop();
		viewer.FlowAnim3:Stop();
		viewer.FlowAnim4:Stop();
		viewer.FlowAnim5:Stop();
		viewer.FlowAnim6:Stop();
	end
end

function SoulbindTalents:SOULBIND_FORGE_INTERACTION_ENDED()
	self:HideSoulbindsTab()
	if PlayerTalentFrame:IsShown() then
		ToggleTalentFrame(4)
		self:RestoreSoulbindFrame()
	end
end

function SoulbindTalents:SOULBIND_ACTIVATED()
	self.soulbindID = C_Soulbinds.GetActiveSoulbindID();
	PlayerTalentFrameTab4:SetShown(self.soulbindID ~= 0 and true or false)
end

function SoulbindTalents:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TalentUI" then
		if UIParentLoadAddOn("Blizzard_Soulbinds") then
			self:SecureHook('PlayerTalentFrame_Refresh')
			self:SecureHook('PlayerTalentFrame_Close')
			self:HookScript(PlayerTalentFrame, "OnHide", "PlayerTalentFrame_OnHide")

			local _, playerClass = UnitClass("player");
			if (playerClass == "HUNTER") then
				self.petTab = true
			end

			local PlayerTalentFrameTab4 = CreateFrame("Button", "$parentTab4", PlayerTalentFrame, "PlayerTalentTabTemplate")
			PlayerTalentFrameTab4:SetPoint("LEFT", self.petTab and PlayerTalentFrameTab3 or PlayerTalentFrameTab2, "RIGHT", -15, 0)
			PlayerTalentFrameTab4:SetText("Soulbinds")
			PlayerTalentFrameTab4:SetID(SOULBIND_TAB)

			if ElvUI then
				local Engine = unpack(ElvUI)
				Engine:GetModule('Skins'):HandleTab(PlayerTalentFrameTab4)
				SoulbindViewer.backdrop:Hide()
			end

			self.soulbindID = C_Soulbinds.GetActiveSoulbindID();
			PlayerTalentFrameTab4:SetShown(self.soulbindID ~= 0 and true or false)

			PanelTemplates_SetNumTabs(PlayerTalentFrame, 4)

			local PlayerTalentFrameSoulbind = CreateFrame("Frame", "PlayerTalentFrameSoulbind", PlayerTalentFrame)
			PlayerTalentFrameSoulbind:SetFrameLevel(1)
			PlayerTalentFrameSoulbind:SetPoint("TOPLEFT", PlayerTalentFrameInset)
			PlayerTalentFrameSoulbind:SetPoint("BOTTOMRIGHT", PlayerTalentFrameInset)
			PlayerTalentFrameSoulbind:Hide()
		end
	elseif addon == "Blizzard_Soulbinds" then
		if UIParentLoadAddOn("Blizzard_TalentUI") then
			self:Hook(SoulbindViewer, "Open", "SoulbindViewer_OnOpen", true)
			self:SecureHook(ConduitListConduitButtonMixin, "Init", "ConduitRank")
			self:SecureHook(SoulbindViewer, "SetSheenAnimationsPlaying", "AnimationFX")
			self:SecureHook(SoulbindTreeNodeLinkMixin, "SetState", "NodeFX")
		end
	end
end

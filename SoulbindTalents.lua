local _, SoulbindTalents = ...

SoulbindTalents = LibStub("AceAddon-3.0"):NewAddon(SoulbindTalents, "SoulbindTalents")

LibStub("AceEvent-3.0"):Embed(SoulbindTalents)
LibStub("AceHook-3.0"):Embed(SoulbindTalents)

SOULBIND_TAB = 4

function SoulbindTalents:OnEnable()
	self:RegisterEvent("SOULBIND_FORGE_INTERACTION_STARTED")
	self:RegisterEvent("SOULBIND_FORGE_INTERACTION_ENDED")
	self:RegisterEvent("ADDON_LOADED")
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

	-- SoulbindViewer.Fx:Hide()
	-- SoulbindViewer.ActivateFX:SetAlpha(0)
	-- SoulbindViewer.ActivateFX2:SetAlpha(0)

	SoulbindViewer.Background2:ClearAllPoints()
	SoulbindViewer.Background2:SetParent(PlayerTalentFrameSoulbind)

	SoulbindViewer.BackgroundBlackOverlay:SetParent(PlayerTalentFrameSoulbind)
	SoulbindViewer.BackgroundBlackOverlay:SetDrawLayer("BACKGROUND", -1)

	SoulbindViewer.ActivateSoulbindButton:ClearAllPoints()
	SoulbindViewer.ActivateSoulbindButton:SetPoint("BOTTOM", SoulbindViewer, "BOTTOM", -93, 15)

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

		SoulbindTalents:AppendSoulbindFrame()

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
	if not PlayerTalentFrameSoulbind:IsShown() then
		ToggleTalentFrame(4)
	end
end

function SoulbindTalents:SOULBIND_FORGE_INTERACTION_STARTED()
	self.forge = true
	if (self.forge) then
		PlayerTalentFrameTab1:Hide()
		PlayerTalentFrameTab2:Hide()
		if self.petTab then
			PlayerTalentFrameTab3:Hide()
		end
		PlayerTalentFrameTab4:Hide()
	end
end

function SoulbindTalents:SOULBIND_FORGE_INTERACTION_ENDED()
	self.forge = false
	PlayerTalentFrameTab1:Show()
	PlayerTalentFrameTab2:Show()
	if self.petTab then
		PlayerTalentFrameTab3:Show()
	end
	PlayerTalentFrameTab4:Show()
	self:HideSoulbindsTab()
	if PlayerTalentFrame:IsShown() then
		ToggleTalentFrame(4)
		self:RestoreSoulbindFrame()
	end
end

function SoulbindTalents:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TalentUI" then
		if UIParentLoadAddOn("Blizzard_Soulbinds") then
			self:SecureHook('PlayerTalentFrame_Refresh')
			self:SecureHook('PlayerTalentFrame_Close')
			self:HookScript(PlayerTalentFrame, "OnHide", "PlayerTalentFrame_OnHide")

			local anchorTab = PlayerTalentFrameTab2

			local _, playerClass = UnitClass("player");
			if (playerClass == "HUNTER") then
				self.petTab = true
				anchorTab = PlayerTalentFrameTab3
			end

			local PlayerTalentFrameTab4 = CreateFrame("Button", "$parentTab4", PlayerTalentFrame, "PlayerTalentTabTemplate")
			PlayerTalentFrameTab4:SetPoint("LEFT", anchorTab, "RIGHT", -15, 0)
			PlayerTalentFrameTab4:SetText("Soulbinds")
			PlayerTalentFrameTab4:SetID(SOULBIND_TAB)

			local soulbindID = C_Soulbinds.GetActiveSoulbindID();
			PlayerTalentFrameTab4:SetShown(soulbindID ~= 0 and true or false)

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
		end
	end
end

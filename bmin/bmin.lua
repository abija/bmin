-- event frame
local BMinEventFrame

-- restock
function BMinRestock(pName, count, stack, quantity)
	quantity = quantity or 1
	local buy = floor((count - GetItemCount(pName)) / stack)
	if buy <= 0 then return end

	if MerchantFrame:IsVisible() then
		for i = 1, GetMerchantNumItems() do
			local name, tex, price, qty, available, usable = GetMerchantItemInfo(i)
			if name then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, invTexture = GetItemInfo(GetMerchantItemLink(i))
				if name == pName then
					print(pName.." found")
					print("buying "..buy.." times")
					for j = 1, buy do
						BuyMerchantItem(i, quantity)
					end
				end
			end
		end
	end
end

function BMinRestockQ(pName, count, maxq)
	maxq = maxq or 1
	local needed = count - GetItemCount(pName)
	if needed <= 0 then return end
	
	local buy = floor(needed / maxq)
	local xbuy = needed - buy * maxq

	if MerchantFrame:IsVisible() then
		for i = 1, GetMerchantNumItems() do
			local name, tex, price, qty, available, usable = GetMerchantItemInfo(i)
			if name then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, invTexture = GetItemInfo(GetMerchantItemLink(i))
				if name == pName then
					print(pName.." found")
					print("buying "..buy.." stacks")
					for j = 1, buy do
						BuyMerchantItem(i, maxq)
					end
					if xbuy > 0 then
						print("buying "..xbuy.." single items")
						BuyMerchantItem(i, xbuy)
					end
				end
			end
		end
	end
end

-- event handler
function OnEvent(this, event, arg1, arg2, arg3)
	if event == "PLAYER_ENTERING_WORLD" then
		-- max camera distance
		SetCVar("CameraDistanceMaxFactor", 4)
		SetCVar("cameraDistanceMax", 50)
		return
	end
	
	if (event == "MERCHANT_SHOW") then
		local localclass, trueclass = UnitClass("player")
		local level = UnitLevel("player")
		local player = UnitName("player")

		-- frozon
		---[[
		if player == "Frozon" and GetRealmName() == "Ravencrest" then
			BMinRestockQ("Resilient Parchment", 80, 20)
			BMinRestockQ("Heavy Parchment", 60, 20)
			BMinRestockQ("Common Parchment", 60, 20)
			BMinRestockQ("Light Parchment", 60, 20)
			
			--[[
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Lion's Ink", 30, 20) end
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Ethereal Ink", 40, 20) end
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Jadefire Ink", 30, 20) end
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Celestial Ink", 30, 20) end
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Shimmering Ink", 30, 20) end
			if GetItemCount("Ink of the Sea") > 100 then BMinRestockQ("Midnight Ink", 20, 20) end
			--]]
		end
		--]]
		
		-- auto repair module
		if CanGuildBankRepair() or CanMerchantRepair() then
			local repaircost = GetRepairAllCost()
			local money = GetMoney()
			if (money < repaircost) and not CanGuildBankRepair() then 
				print("not enough money for full repair")
			elseif (repaircost > 0) then
				print(floor(repaircost/10000 + 0.5).."g repair cost")
				RepairAllItems(1)
				RepairAllItems()
			end
		end
		
		-- auto sell gray stuff
		local bag, slot
		for bag = 0, 4 do
			if GetContainerNumSlots(bag) > 0 then
				for slot = 1, GetContainerNumSlots(bag) do
					local _, _, _, quality = GetContainerItemInfo(bag, slot)
					-- skip regexp where appropiate
					if (quality == 0 or quality == -1) then
						-- check link color
						local link = GetContainerItemLink(bag, slot)
						for color in string.gmatch (link, "|c(%x+)|Hitem:.+|h%[.-%]|h|r") do
							if color == "ff9d9d9d" then
								print("selling "..link)
								UseContainerItem(bag, slot)
							end
						end
					end
				end
			end
		end
		
	end
end

local timecheck = 0
local tracking = 1
bminautotracking = false

function OnUpdate(this, elapsed)
	if not bminautotracking then return end
	
	timecheck = timecheck + elapsed
	
	if UnitChannelInfo("player") then return end
	if not IsFlying() then return end
	
	if timecheck > 3 then
		timecheck = 0
		SetTracking(tracking)
		if tracking == 1 then tracking = 2
		else tracking = 1 end
	end
end

function OnLoad()
	BMinEventFrame = CreateFrame("Frame")
	BMinEventFrame:Hide()
	BMinEventFrame:SetScript("OnEvent", OnEvent)
	if UnitName("player") == "Ferie" then
		BMinEventFrame:Show()
		BMinEventFrame:SetScript("OnUpdate", OnUpdate)
	end
	
	BMinEventFrame:RegisterEvent("MERCHANT_SHOW")
	BMinEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	print("Loaded!")
end

function ListChildren(f, pad)
	if not pad then pad = "" end
	if not f:GetName() then return end
	print(pad..f:GetName())
	pad = pad.."----"
	local kids = { f:GetChildren() }
	for _, child in ipairs(kids) do 
		ListChildren(child, pad)
	end
end

function CancelAllAuctions()
	local i = 1
	local n = 1
	while n do
		n = GetAuctionItemInfo("owner",i)
		if n then
			CancelAuction(i)
		end
		i = i + 1
	end
	print((i-2) .. " auctions cancelled")
end

-- load
OnLoad();
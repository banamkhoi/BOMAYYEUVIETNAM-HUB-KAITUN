-- ======================================================
-- FULL KAITUN BLOX FRUITS (AUTO PIRATE & FIXED COORDS)
-- ======================================================

_G = _G or {}
_G.SelectWeapon = "Melee" 
_G.MobHeight = 15         -- Giảm khoảng cách đứng trên đầu mob để tránh va vướng công trình
_G.BringRange = 250       
_G.MaxBringMobs = 15
_G.FruitSkills = { Z = true, X = true, C = true, V = true, F = false }

_B = false
PosMon = nil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local plr = Players.LocalPlayer

-- 1. TỰ ĐỘNG CHỌN TEAM PIRATE KHI MỚI VÀO GAME
repeat
	task.wait(0.1)
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
	end)
until plr.Team ~= nil and (plr.Team.Name == "Pirates" or plr.Team.Name == "Pirate")

-- 2. BYPASS & CHỐNG AFK
pcall(function()
	plr.Idled:Connect(function()
		VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end)

	hookfunction(require(ReplicatedStorage.Effect.Container.Death), function() end)
	hookfunction(require(ReplicatedStorage:WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end)
	hookfunction(error, function() end)
	hookfunction(warn, function() end)

	if workspace:FindFirstChild("Rocks") then workspace.Rocks:Destroy() end
	if workspace._WorldOrigin:FindFirstChild("Foam;") then workspace._WorldOrigin["Foam;"]:Destroy() end
end)

-- 3. CHUẨN HÓA TỌA ĐỘ QUEST & BÃI QUÁI (ĐÃ FIX TỌA ĐỘ CHUẨN BỀ MẶT ĐẤT)
local QuestData = {
	-- Sea 1
	{ MinLvl = 1, MaxLvl = 9, Mob = "Bandit", QuestName = "BanditQuest1", QuestId = 1, NPCPos = CFrame.new(1059, 16, 1549), MobPos = CFrame.new(1145, 17, 1634) },
	{ MinLvl = 10, MaxLvl = 14, Mob = "Monkey", QuestName = "JungleQuest", QuestId = 1, NPCPos = CFrame.new(-1598, 37, 153), MobPos = CFrame.new(-1496, 37, 36) },
	{ MinLvl = 15, MaxLvl = 29, Mob = "Gorilla", QuestName = "JungleQuest", QuestId = 2, NPCPos = CFrame.new(-1598, 37, 153), MobPos = CFrame.new(-1237, 6, -486) },
	
	-- Sea 3 (Ví dụ mẫu)
	{ MinLvl = 1500, MaxLvl = 1524, Mob = "Pirate Millionaire", QuestName = "PortTownQuest", QuestId = 1, NPCPos = CFrame.new(-290, 7, 5343), MobPos = CFrame.new(-712, 98, 5711) },
	{ MinLvl = 1525, MaxLvl = 1574, Mob = "Pistol Billionaire", QuestName = "PortTownQuest", QuestId = 2, NPCPos = CFrame.new(-290, 7, 5343), MobPos = CFrame.new(-723, 147, 5931) },
	{ MinLvl = 2200, MaxLvl = 2249, Mob = "Peanut Scout", QuestName = "PenautQuest", QuestId = 1, NPCPos = CFrame.new(-2013, 37, -10140), MobPos = CFrame.new(-1993, 187, -10103) }
}

-- 4. HÀM XỬ LÝ DI CHUYỂN & VŨ KHÍ
local function _tp(cframe)
	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.CFrame = cframe
	end
end

local function GetCurrentQuestData()
	local myLevel = plr.Data.Level.Value
	for _, q in ipairs(QuestData) do
		if myLevel >= q.MinLvl and myLevel <= q.MaxLvl then
			return q
		end
	end
	return nil
end

local function HasQuest()
	return plr.PlayerGui.Main:FindFirstChild("Quest") and plr.PlayerGui.Main.Quest.Visible
end

local function EquipWeapon(weaponName)
	if not weaponName then return end
	if plr.Backpack:FindFirstChild(weaponName) then
		plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(weaponName))
	end
end

local function BringEnemy()
	if not PosMon or not _B then return end
	local count = 0
	for _, mob in pairs(workspace.Enemies:GetChildren()) do
		if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
			if (mob.HumanoidRootPart.Position - PosMon).Magnitude <= _G.BringRange then
				if count < _G.MaxBringMobs then
					mob.HumanoidRootPart.CFrame = CFrame.new(PosMon)
					mob.HumanoidRootPart.CanCollide = false
					mob.Humanoid.WalkSpeed = 0
					count = count + 1
				end
			end
		end
	end
end

-- 5. LOGIC DIỆT QUÁI
local G = {}
function G.Alive(mob)
	return mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0
end

function G.Kill(mob)
	if not G.Alive(mob) then return end
	local hrp = mob:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not mob:GetAttribute("Locked") then
		mob:SetAttribute("Locked", hrp.CFrame)
	end

	PosMon = (mob:GetAttribute("Locked")).Position
	_B = true
	BringEnemy()

	EquipWeapon(_G.SelectWeapon)
	_tp(hrp.CFrame * CFrame.new(0, _G.MobHeight, 0))
end

-- 6. MAIN LOOP
task.spawn(function()
	while task.wait(0.1) do
		pcall(function()
			-- Auto Stats
			if plr.Data.Points.Value > 0 then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
				ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 1)
			end

			local questInfo = GetCurrentQuestData()
			if questInfo then
				if not HasQuest() then
					-- Bay đứng sát NPC nhận Quest (không cộng thêm chiều cao)
					_tp(questInfo.NPCPos)
					task.wait(0.3)
					ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questInfo.QuestName, questInfo.QuestId)
				else
					-- Tìm quái theo tên
					local targetMob = nil
					for _, mob in pairs(workspace.Enemies:GetChildren()) do
						if mob.Name == questInfo.Mob and G.Alive(mob) then
							targetMob = mob
							break
						end
					end

					if targetMob then
						G.Kill(targetMob)
					else
						-- Nếu quái chưa spawn, đứng chờ tại bãi cách mặt đất 10-15 studs
						_tp(questInfo.MobPos * CFrame.new(0, 10, 0))
					end
				end
			end
		end)
	end
end)

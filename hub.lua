pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhTuanDzai-Hub/FastAttackLoL/refs/heads/main/FastAttack.lua"))() end)

-- ======================================================
-- FULL KAITUN BLOX FRUITS (FAST ATTACK DÒNG 1 + AUTO FARM)
-- ======================================================

_G = _G or {}
_G.MobHeight = 25         -- Khoảng cách cố định 25 studs trên đầu quái
_G.BringRange = 250       
_G.MaxBringMobs = 15

_B = false
PosMon = nil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local plr = Players.LocalPlayer

-- 1. TỰ ĐỘNG CHỌN PHE PIRATE
repeat
	task.wait(0.1)
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
	end)
until plr.Team ~= nil and (plr.Team.Name == "Pirates" or plr.Team.Name == "Pirate")

-- 2. HÀM ÉP TỰ ĐỘNG CẦM MELEE (NEVER UNEQUIP)
local function ForceEquipMelee()
	local char = plr.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool and (currentTool.ToolTip == "Melee" or currentTool.Name == "Combat") then
		return
	end

	for _, tool in pairs(plr.Backpack:GetChildren()) do
		if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.Name == "Combat") then
			humanoid:EquipTool(tool)
			break
		end
	end
end

-- 3. NOCLIP VÀ TRIỆT TIÊU LỖI ĐỔI VŨ KHÍ
RunService.Stepped:Connect(function()
	if plr.Character then
		for _, part in pairs(plr.Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
		ForceEquipMelee()
	end
end)

-- 4. BYPASS ANTI-CHEAT & ANTI-AFK
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

-- 5. BẢNG DỮ LIỆU QUEST & TỌA ĐỘ BÃI QUÁI
local QuestData = {
	-- Sea 1
	{ MinLvl = 1, MaxLvl = 9, Mob = "Bandit", QuestName = "BanditQuest1", QuestId = 1, NPCPos = CFrame.new(1059, 16, 1549), MobPos = CFrame.new(1145, 17, 1634) },
	{ MinLvl = 10, MaxLvl = 14, Mob = "Monkey", QuestName = "JungleQuest", QuestId = 1, NPCPos = CFrame.new(-1598, 37, 153), MobPos = CFrame.new(-1496, 37, 36) },
	{ MinLvl = 15, MaxLvl = 29, Mob = "Gorilla", QuestName = "JungleQuest", QuestId = 2, NPCPos = CFrame.new(-1598, 37, 153), MobPos = CFrame.new(-1237, 6, -486) },
	
	-- Sea 3
	{ MinLvl = 1500, MaxLvl = 1524, Mob = "Pirate Millionaire", QuestName = "PortTownQuest", QuestId = 1, NPCPos = CFrame.new(-290, 7, 5343), MobPos = CFrame.new(-712, 98, 5711) },
	{ MinLvl = 1525, MaxLvl = 1574, Mob = "Pistol Billionaire", QuestName = "PortTownQuest", QuestId = 2, NPCPos = CFrame.new(-290, 7, 5343), MobPos = CFrame.new(-723, 147, 5931) },
	{ MinLvl = 2200, MaxLvl = 2249, Mob = "Peanut Scout", QuestName = "PenautQuest", QuestId = 1, NPCPos = CFrame.new(-2013, 37, -10140), MobPos = CFrame.new(-1993, 187, -10103) }
}

-- 6. HÀM DI CHUYỂN & KHÓA VỊ TRÍ TRÊN KHÔNG
local function _tp(cframe)
	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
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

-- 7. LOGIC DIỆT QUÁI (KÍCH HOẠT NHẤP CHUỘT LIÊN TỤC ĐỂ MỒ MÃ FAST ATTACK)
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

	ForceEquipMelee()
	_tp(hrp.CFrame * CFrame.new(0, _G.MobHeight, 0))

	-- Tạo sự kiện nhấp chuột liên tục để kích hoạt module Fast Attack
	VirtualUser:CaptureController()
	VirtualUser:Button1Down(Vector2.new(500, 500))
end

-- 8. MAIN KAITUN LOOP
task.spawn(function()
	while task.wait(0.1) do
		pcall(function()
			-- Tự động tăng điểm Melee & Defense
			if plr.Data.Points.Value > 0 then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
				ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 1)
			end

			local questInfo = GetCurrentQuestData()
			if questInfo then
				if not HasQuest() then
					_tp(questInfo.NPCPos)
					task.wait(0.3)
					ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questInfo.QuestName, questInfo.QuestId)
				else
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
						_tp(questInfo.MobPos * CFrame.new(0, _G.MobHeight, 0))
					end
				end
			end
		end)
	end
end)

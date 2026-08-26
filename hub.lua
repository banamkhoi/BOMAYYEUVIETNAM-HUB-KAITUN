loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhTuanDzai-Hub/FastAttackLoL/refs/heads/main/FastAttack.lua"))()

-- Chờ game load hoàn tất
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- HIỂN THỊ UI "KAITUN HUB: ON"
local plr = game:GetService("Players").LocalPlayer
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or plr:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("KaitunCheckGui") then
	parentGui.KaitunCheckGui:Destroy()
end

local sgui = Instance.new("ScreenGui")
sgui.Name = "KaitunCheckGui"
sgui.Parent = parentGui

local lbl = Instance.new("TextLabel")
lbl.Parent = sgui
lbl.Size = UDim2.new(0, 220, 0, 45)
lbl.Position = UDim2.new(0.5, -110, 0.05, 0)
lbl.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
lbl.BorderColor3 = Color3.fromRGB(0, 255, 127)
lbl.BorderSizePixel = 2
lbl.TextColor3 = Color3.fromRGB(0, 255, 127)
lbl.Text = "KAITUN HUB: ON"
lbl.TextSize = 18
lbl.Font = Enum.Font.SourceSansBold

-- ======================================================
-- FULL KAITUN LOGIC (TWEEN FLY CHỐNG BAN + 25 STUDS FLOAT)
-- ======================================================

_G = _G or {}
_G.MobHeight = 25         -- Khoảng cách 25 studs trên đầu quái
_G.BringRange = 250       
_G.MaxBringMobs = 15
_G.FlySpeed = 300         -- Tốc độ bay an toàn chống Anti-Cheat (studs/s)

_B = false
PosMon = nil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local currentTween = nil
local currentTarget = nil

-- Auto chọn phe Pirate
task.spawn(function()
	repeat
		task.wait(0.1)
		pcall(function()
			ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
		end)
	until plr.Team ~= nil and (plr.Team.Name == "Pirates" or plr.Team.Name == "Pirate")
end)

-- Bắt buộc luôn cầm Melee (Không thể cất hay đổi)
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

-- Noclip + Auto Equip Melee liên tục
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

-- Anti AFK
plr.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- HÀM BAY AN TOÀN (TWEEN FLY SYSTEM)
local function _tp(cframe)
	if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = plr.Character.HumanoidRootPart
	local distance = (hrp.Position - cframe.Position).Magnitude

	-- Ở khoảng cách gần (< 15 studs) -> Giữ vị trí cố định trên không
	if distance <= 15 then
		if currentTween then
			currentTween:Cancel()
			currentTween = nil
		end
		hrp.Velocity = Vector3.new(0, 0, 0)
		hrp.CFrame = cframe
	else
		-- Ở khoảng cách xa -> Bay mượt mà bằng TweenService
		if not currentTween or (currentTarget and (currentTarget.Position - cframe.Position).Magnitude > 5) then
			if currentTween then currentTween:Cancel() end
			currentTarget = cframe
			local timeToFly = distance / _G.FlySpeed
			local tweenInfo = TweenInfo.new(timeToFly, Enum.EasingStyle.Linear)
			currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = cframe})
			currentTween:Play()
		end
	end
end

-- Bảng Quest
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

local function GetCurrentQuestData()
	if not plr:FindFirstChild("Data") or not plr.Data:FindFirstChild("Level") then return nil end
	local myLevel = plr.Data.Level.Value
	for _, q in ipairs(QuestData) do
		if myLevel >= q.MinLvl and myLevel <= q.MaxLvl then
			return q
		end
	end
	return nil
end

local function HasQuest()
	return plr.PlayerGui:FindFirstChild("Main") and plr.PlayerGui.Main:FindFirstChild("Quest") and plr.PlayerGui.Main.Quest.Visible
end

local function BringEnemy()
	if not PosMon or not _B or not workspace:FindFirstChild("Enemies") then return end
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

	VirtualUser:CaptureController()
	VirtualUser:Button1Down(Vector2.new(500, 500))
end

-- Vòng lặp Farm chính
task.spawn(function()
	while task.wait(0.1) do
		pcall(function()
			if plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Points") and plr.Data.Points.Value > 0 then
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
					if workspace:FindFirstChild("Enemies") then
						for _, mob in pairs(workspace.Enemies:GetChildren()) do
							if mob.Name == questInfo.Mob and G.Alive(mob) then
								targetMob = mob
								break
							end
						end
					end

					if targetMob then
						G.Kill(targetMob)
					else
						_tp(questInfo.MobPos * CFrame.new(0, _G.MobHeight, 0))
					InitBypasses()

local MasterIslandDatabase = {
    ["Starter Island (Pirate)"] = CFrame.new(-2709.67, 24.52, 2104.24),
    ["Starter Island (Marine)"] = CFrame.new(-2566.43, 6.85, 2045.28),
    ["Jungle"] = CFrame.new(-1601.65, 36.85, 153.38),
    ["Pirate Village"] = CFrame.new(-1140.16, 4.75, 3827.42),
    ["Desert"] = CFrame.new(897.52, 6.43, 4388.57),
    ["Middle Town"] = CFrame.new(-690.33, 15.09, 1583.51),
    ["Frozen Village"] = CFrame.new(1385.58, 87.27, -1298.54),
    ["Marine Fortress"] = CFrame.new(-5036.23, 28.65, 4324.52),
    ["Skylands Lower"] = CFrame.new(-4840.42, 717.52, -2623.51),
    ["Skylands Upper 1"] = CFrame.new(-4970.20, 858.20, -1900.50),
    ["Skylands Upper 2"] = CFrame.new(-7859.10, 5544.19, -381.47),
    ["Prison"] = CFrame.new(4875.24, 5.65, 735.21),
    ["Colosseum"] = CFrame.new(-1580.05, 6.35, -2986.48),
    ["Magma Village"] = CFrame.new(-5313.37, 10.95, 8515.29),
    ["Underwater City"] = CFrame.new(61122.65, 18.50, 1569.40),
    ["Fountain City"] = CFrame.new(5259.82, 37.35, 4050.03),
    ["Mob Island"] = CFrame.new(-2850.20, 7.30, 5300.10),

    -- Sea 2 Islands
    ["Cafeteria / Rose Kingdom"] = CFrame.new(-425.32, 73.10, 1837.25),
    ["Usoap's Island"] = CFrame.new(4765.21, 8.21, 2851.35),
    ["Green Zone"] = CFrame.new(-2440.15, 73.20, -3216.42),
    ["Graveyard"] = CFrame.new(-5495.12, 48.52, -794.15),
    ["Snow Mountain"] = CFrame.new(609.52, 401.24, -5372.15),
    ["Hot and Cold (Fire)"] = CFrame.new(-6064.12, 15.95, -4902.32),
    ["Hot and Cold (Ice)"] = CFrame.new(-5400.20, 15.80, -5250.40),
    ["Cursed Ship"] = CFrame.new(923.12, 125.10, 32852.12),
    ["Ice Castle"] = CFrame.new(6142.15, 294.12, -6742.15),
    ["Forgotten Island"] = CFrame.new(-3054.12, 236.12, -10142.15),
    ["Dark Arena"] = CFrame.new(3782.12, 14.12, -3451.12),
    ["Factory"] = CFrame.new(448.50, 199.40, -441.40),

    -- Sea 3 Islands
    ["Port Town"] = CFrame.new(-290.12, 44.12, 5580.12),
    ["Hydra Island"] = CFrame.new(5833.12, 52.12, -1105.12),
    ["Great Tree"] = CFrame.new(-2512.12, 298.12, -10142.15),
    ["Floating Turtle"] = CFrame.new(-13234.12, 331.12, -7625.12),
    ["Haunted Castle"] = CFrame.new(-9479.12, 142.12, 5566.12),
    ["Castle on the Sea"] = CFrame.new(-5496.20, 313.80, -2841.50),
    ["Chocolate Island"] = CFrame.new(-2020.12, 38.12, -12025.12),
    ["Candy Island"] = CFrame.new(151.12, 23.12, -12774.12),
    ["Ice Cream Island"] = CFrame.new(-820.40, 65.20, -10900.50),
    ["Peanut Island"] = CFrame.new(-1900.20, 38.50, -10250.80),
    ["Tiki Outpost"] = CFrame.new(-16533.12, 55.12, 1052.12),
    ["Temple of Time"] = CFrame.new(28282.50, 14896.80, 105.10),
    ["Mirage Island"] = CFrame.new(-5500.12, 300.12, -4500.12),
    ["Kitsune Island"] = CFrame.new(-28500.12, 15.12, 6500.12)
}

local MasterMobDatabase = {
    -- Sea 1 Mobs
    { FullName = "Bandit", MobName = "Bandit", LevelRequest = 1, IsBoss = false, Quest = { QuestName = "BanditsQuest1", QuestCFrame = CFrame.new(1060, 16, 1547), QuestLevel = 1, QuestNPC = "Bandit Quest Giver" }, SpawnLocation = { CFrame.new(1038, 16, 1547), CFrame.new(1080, 16, 1580) }, ExpReward = 300, BeliReward = 250 },
    { FullName = "Monkey", MobName = "Monkey", LevelRequest = 15, IsBoss = false, Quest = { QuestName = "JungleQuest", QuestCFrame = CFrame.new(-1601, 37, 153), QuestLevel = 1, QuestNPC = "Jungle Adventurer" }, SpawnLocation = { CFrame.new(-1620, 37, 140), CFrame.new(-1580, 37, 170) }, ExpReward = 800, BeliReward = 500 },
    { FullName = "Gorilla", MobName = "Gorilla", LevelRequest = 20, IsBoss = false, Quest = { QuestName = "JungleQuest", QuestCFrame = CFrame.new(-1601, 37, 153), QuestLevel = 2, QuestNPC = "Jungle Adventurer" }, SpawnLocation = { CFrame.new(-1240, 6, -490), CFrame.new(-1210, 6, -520) }, ExpReward = 1200, BeliReward = 700 },
    { FullName = "The Gorilla King", MobName = "The Gorilla King", LevelRequest = 25, IsBoss = true, Quest = { QuestName = "JungleQuest", QuestCFrame = CFrame.new(-1601, 37, 153), QuestLevel = 3, QuestNPC = "Jungle Adventurer" }, SpawnLocation = { CFrame.new(-1130, 6, -495) }, ExpReward = 4500, BeliReward = 2000 },
    { FullName = "Pirate", MobName = "Pirate", LevelRequest = 30, IsBoss = false, Quest = { QuestName = "BuggyQuest1", QuestCFrame = CFrame.new(-1140, 4, 3828), QuestLevel = 1, QuestNPC = "Pirate Adventurer" }, SpawnLocation = { CFrame.new(-1200, 4, 3880) }, ExpReward = 2000, BeliReward = 1000 },
    { FullName = "Brute", MobName = "Brute", LevelRequest = 40, IsBoss = false, Quest = { QuestName = "BuggyQuest1", QuestCFrame = CFrame.new(-1140, 4, 3828), QuestLevel = 2, QuestNPC = "Pirate Adventurer" }, SpawnLocation = { CFrame.new(-1370, 4, 4000) }, ExpReward = 3500, BeliReward = 1500 },
    { FullName = "Bobby", MobName = "Bobby", LevelRequest = 55, IsBoss = true, Quest = { QuestName = "BuggyQuest1", QuestCFrame = CFrame.new(-1140, 4, 3828), QuestLevel = 3, QuestNPC = "Pirate Adventurer" }, SpawnLocation = { CFrame.new(-1130, 14, 4080) }, ExpReward = 8000, BeliReward = 3500 },
    { FullName = "Desert Bandit", MobName = "Desert Bandit", LevelRequest = 60, IsBoss = false, Quest = { QuestName = "DesertQuest", QuestCFrame = CFrame.new(897, 7, 4388), QuestLevel = 1, QuestNPC = "Desert Adventurer" }, SpawnLocation = { CFrame.new(930, 7, 4420) }, ExpReward = 5000, BeliReward = 2000 },
    { FullName = "Desert Officer", MobName = "Desert Officer", LevelRequest = 75, IsBoss = false, Quest = { QuestName = "DesertQuest", QuestCFrame = CFrame.new(897, 7, 4388), QuestLevel = 2, QuestNPC = "Desert Adventurer" }, SpawnLocation = { CFrame.new(1580, 4, 4360) }, ExpReward = 7500, BeliReward = 2500 },
    { FullName = "Snow Bandit", MobName = "Snow Bandit", LevelRequest = 90, IsBoss = false, Quest = { QuestName = "SnowQuest", QuestCFrame = CFrame.new(1385, 87, -1298), QuestLevel = 1, QuestNPC = "Snow Adventurer" }, SpawnLocation = { CFrame.new(1280, 87, -1350) }, ExpReward = 10000, BeliReward = 3000 },
    { FullName = "Snowman", MobName = "Snowman", LevelRequest = 100, IsBoss = false, Quest = { QuestName = "SnowQuest", QuestCFrame = CFrame.new(1385, 87, -1298), QuestLevel = 2, QuestNPC = "Snow Adventurer" }, SpawnLocation = { CFrame.new(1200, 105, -1480) }, ExpReward = 13000, BeliReward = 3500 },
    { FullName = "Yeti", MobName = "Yeti", LevelRequest = 110, IsBoss = true, Quest = { QuestName = "SnowQuest", QuestCFrame = CFrame.new(1385, 87, -1298), QuestLevel = 3, QuestNPC = "Snow Adventurer" }, SpawnLocation = { CFrame.new(1185, 105, -1500) }, ExpReward = 18000, BeliReward = 5000 },
    { FullName = "Chief Petty Officer", MobName = "Chief Petty Officer", LevelRequest = 120, IsBoss = false, Quest = { QuestName = "MarineQuest2", QuestCFrame = CFrame.new(-5036, 29, 4324), QuestLevel = 1, QuestNPC = "Marine Leader" }, SpawnLocation = { CFrame.new(-4880, 21, 4260) }, ExpReward = 22000, BeliReward = 4000 },
    { FullName = "Vice Admiral", MobName = "Vice Admiral", LevelRequest = 130, IsBoss = true, Quest = { QuestName = "MarineQuest2", QuestCFrame = CFrame.new(-5036, 29, 4324), QuestLevel = 2, QuestNPC = "Marine Leader" }, SpawnLocation = { CFrame.new(-5010, 21, 4350) }, ExpReward = 30000, BeliReward = 7500 },
    { FullName = "Sky Bandit", MobName = "Sky Bandit", LevelRequest = 150, IsBoss = false, Quest = { QuestName = "SkyQuest", QuestCFrame = CFrame.new(-4840, 718, -2623), QuestLevel = 1, QuestNPC = "Sky Adventurer" }, SpawnLocation = { CFrame.new(-4980, 718, -2600) }, ExpReward = 35000, BeliReward = 4500 },
    { FullName = "Dark Master", MobName = "Dark Master", LevelRequest = 175, IsBoss = false, Quest = { QuestName = "SkyQuest", QuestCFrame = CFrame.new(-4840, 718, -2623), QuestLevel = 2, QuestNPC = "Sky Adventurer" }, SpawnLocation = { CFrame.new(-5220, 718, -2250) }, ExpReward = 45000, BeliReward = 5000 },
    { FullName = "Prisoner", MobName = "Prisoner", LevelRequest = 190, IsBoss = false, Quest = { QuestName = "PrisonerQuest", QuestCFrame = CFrame.new(5308, 1, 475), QuestLevel = 1, QuestNPC = "Jailer" }, SpawnLocation = { CFrame.new(5400, 1, 480) }, ExpReward = 50000, BeliReward = 5500 },
    { FullName = "Dangerous Prisoner", MobName = "Dangerous Prisoner", LevelRequest = 210, IsBoss = false, Quest = { QuestName = "PrisonerQuest", QuestCFrame = CFrame.new(5308, 1, 475), QuestLevel = 2, QuestNPC = "Jailer" }, SpawnLocation = { CFrame.new(5520, 1, 680) }, ExpReward = 60000, BeliReward = 6000 },
    { FullName = "Warden", MobName = "Warden", LevelRequest = 220, IsBoss = true, Quest = { QuestName = "ImpelQuest", QuestCFrame = CFrame.new(5190, 1, 650), QuestLevel = 1, QuestNPC = "Head Jailer" }, SpawnLocation = { CFrame.new(5220, 1, 680) }, ExpReward = 75000, BeliReward = 8000 },
    { FullName = "Chief Warden", MobName = "Chief Warden", LevelRequest = 230, IsBoss = true, Quest = { QuestName = "ImpelQuest", QuestCFrame = CFrame.new(5190, 1, 650), QuestLevel = 2, QuestNPC = "Head Jailer" }, SpawnLocation = { CFrame.new(5220, 1, 680) }, ExpReward = 90000, BeliReward = 10000 },
    { FullName = "Swan", MobName = "Swan", LevelRequest = 240, IsBoss = true, Quest = { QuestName = "ImpelQuest", QuestCFrame = CFrame.new(5190, 1, 650), QuestLevel = 3, QuestNPC = "Head Jailer" }, SpawnLocation = { CFrame.new(5220, 1, 680) }, ExpReward = 110000, BeliReward = 15000 },
    { FullName = "Toga Warrior", MobName = "Toga Warrior", LevelRequest = 250, IsBoss = false, Quest = { QuestName = "ColosseumQuest", QuestCFrame = CFrame.new(-1580, 7, -2986), QuestLevel = 1, QuestNPC = "Colosseum Master" }, SpawnLocation = { CFrame.new(-1780, 50, -2700) }, ExpReward = 120000, BeliReward = 6500 },
    { FullName = "Gladiator", MobName = "Gladiator", LevelRequest = 275, IsBoss = false, Quest = { QuestName = "ColosseumQuest", QuestCFrame = CFrame.new(-1580, 7, -2986), QuestLevel = 2, QuestNPC = "Colosseum Master" }, SpawnLocation = { CFrame.new(-1320, 50, -3300) }, ExpReward = 140000, BeliReward = 7000 },
    { FullName = "Military Soldier", MobName = "Military Soldier", LevelRequest = 300, IsBoss = false, Quest = { QuestName = "MagmaQuest", QuestCFrame = CFrame.new(-5313, 12, 8515), QuestLevel = 1, QuestNPC = "Magma Officer" }, SpawnLocation = { CFrame.new(-5400, 11, 8450) }, ExpReward = 160000, BeliReward = 7500 },
    { FullName = "Military Spy", MobName = "Military Spy", LevelRequest = 325, IsBoss = false, Quest = { QuestName = "MagmaQuest", QuestCFrame = CFrame.new(-5313, 12, 8515), QuestLevel = 2, QuestNPC = "Magma Officer" }, SpawnLocation = { CFrame.new(-5800, 86, 8820) }, ExpReward = 180000, BeliReward = 8000 },
    { FullName = "Magma Admiral", MobName = "Magma Admiral", LevelRequest = 350, IsBoss = true, Quest = { QuestName = "MagmaQuest", QuestCFrame = CFrame.new(-5313, 12, 8515), QuestLevel = 3, QuestNPC = "Magma Officer" }, SpawnLocation = { CFrame.new(-5690, 18, 8790) }, ExpReward = 250000, BeliReward = 20000 },
    { FullName = "Fishman Warrior", MobName = "Fishman Warrior", LevelRequest = 375, IsBoss = false, Quest = { QuestName = "FishmanQuest", QuestCFrame = CFrame.new(61122, 18, 1569), QuestLevel = 1, QuestNPC = "Underwater Guard" }, SpawnLocation = { CFrame.new(60880, 18, 1540) }, ExpReward = 220000, BeliReward = 8500 },
    { FullName = "Fishman Commando", MobName = "Fishman Commando", LevelRequest = 400, IsBoss = false, Quest = { QuestName = "FishmanQuest", QuestCFrame = CFrame.new(61122, 18, 1569), QuestLevel = 2, QuestNPC = "Underwater Guard" }, SpawnLocation = { CFrame.new(61920, 18, 1490) }, ExpReward = 260000, BeliReward = 9000 },
    { FullName = "Fishman Lord", MobName = "Fishman Lord", LevelRequest = 425, IsBoss = true, Quest = { QuestName = "FishmanQuest", QuestCFrame = CFrame.new(61122, 18, 1569), QuestLevel = 3, QuestNPC = "Underwater Guard" }, SpawnLocation = { CFrame.new(61350, 18, 1470) }, ExpReward = 350000, BeliReward = 25000 },
    { FullName = "God's Guard", MobName = "God's Guard", LevelRequest = 450, IsBoss = false, Quest = { QuestName = "SkyExp1Quest", QuestCFrame = CFrame.new(-4721, 843, -1949), QuestLevel = 1, QuestNPC = "Sky Master" }, SpawnLocation = { CFrame.new(-4710, 845, -1927) }, ExpReward = 300000, BeliReward = 9500 },
    { FullName = "Shanda", MobName = "Shanda", LevelRequest = 475, IsBoss = false, Quest = { QuestName = "SkyExp1Quest", QuestCFrame = CFrame.new(-7859, 5544, -381), QuestLevel = 2, QuestNPC = "Sky Master" }, SpawnLocation = { CFrame.new(-7678, 5566, -497) }, ExpReward = 350000, BeliReward = 10000 },
    { FullName = "Wysper", MobName = "Wysper", LevelRequest = 500, IsBoss = true, Quest = { QuestName = "SkyExp1Quest", QuestCFrame = CFrame.new(-7859, 5544, -381), QuestLevel = 3, QuestNPC = "Sky Master" }, SpawnLocation = { CFrame.new(-7920, 5544, -420) }, ExpReward = 450000, BeliReward = 30000 },
    { FullName = "Royal Squad", MobName = "Royal Squad", LevelRequest = 525, IsBoss = false, Quest = { QuestName = "SkyExp2Quest", QuestCFrame = CFrame.new(-7906, 5634, -1411), QuestLevel = 1, QuestNPC = "Sky Lord" }, SpawnLocation = { CFrame.new(-7624, 5658, -1467) }, ExpReward = 400000, BeliReward = 10500 },
    { FullName = "Royal Soldier", MobName = "Royal Soldier", LevelRequest = 550, IsBoss = false, Quest = { QuestName = "SkyExp2Quest", QuestCFrame = CFrame.new(-7906, 5634, -1411), QuestLevel = 2, QuestNPC = "Sky Lord" }, SpawnLocation = { CFrame.new(-7836, 5645, -1790) }, ExpReward = 450000, BeliReward = 11000 },
    { FullName = "Thunder God", MobName = "Thunder God", LevelRequest = 575, IsBoss = true, Quest = { QuestName = "SkyExp2Quest", QuestCFrame = CFrame.new(-7906, 5634, -1411), QuestLevel = 3, QuestNPC = "Sky Lord" }, SpawnLocation = { CFrame.new(-7750, 5600, -2300) }, ExpReward = 600000, BeliReward = 35000 },
    { FullName = "Galley Pirate", MobName = "Galley Pirate", LevelRequest = 625, IsBoss = false, Quest = { QuestName = "FountainQuest", QuestCFrame = CFrame.new(5259, 37, 4050), QuestLevel = 1, QuestNPC = "Fountain Guard" }, SpawnLocation = { CFrame.new(5551, 78, 3930) }, ExpReward = 550000, BeliReward = 11500 },
    { FullName = "Galley Captain", MobName = "Galley Captain", LevelRequest = 650, IsBoss = false, Quest = { QuestName = "FountainQuest", QuestCFrame = CFrame.new(5259, 37, 4050), QuestLevel = 2, QuestNPC = "Fountain Guard" }, SpawnLocation = { CFrame.new(5441, 42, 4950) }, ExpReward = 600000, BeliReward = 12000 },

    -- Sea 2 Mobs
    { FullName = "Raider", MobName = "Raider", LevelRequest = 700, IsBoss = false, Quest = { QuestName = "Area1Quest", QuestCFrame = CFrame.new(-425, 73, 1837), QuestLevel = 1, QuestNPC = "Cafe Manager" }, SpawnLocation = { CFrame.new(-480, 73, 1880) }, ExpReward = 700000, BeliReward = 12500 },
    { FullName = "Mercenary", MobName = "Mercenary", LevelRequest = 725, IsBoss = false, Quest = { QuestName = "Area1Quest", QuestCFrame = CFrame.new(-425, 73, 1837), QuestLevel = 2, QuestNPC = "Cafe Manager" }, SpawnLocation = { CFrame.new(-920, 73, 1720) }, ExpReward = 750000, BeliReward = 13000 },
    { FullName = "Diamond", MobName = "Diamond", LevelRequest = 750, IsBoss = true, Quest = { QuestName = "Area1Quest", QuestCFrame = CFrame.new(-425, 73, 1837), QuestLevel = 3, QuestNPC = "Cafe Manager" }, SpawnLocation = { CFrame.new(-1580, 195, -120) }, ExpReward = 1000000, BeliReward = 40000 },
    { FullName = "Swan Pirate", MobName = "Swan Pirate", LevelRequest = 775, IsBoss = false, Quest = { QuestName = "Area2Quest", QuestCFrame = CFrame.new(638, 73, 918), QuestLevel = 1, QuestNPC = "Kingdom Commander" }, SpawnLocation = { CFrame.new(880, 73, 1220) }, ExpReward = 850000, BeliReward = 13500 },
    { FullName = "Factory Staff", MobName = "Factory Staff", LevelRequest = 800, IsBoss = false, Quest = { QuestName = "Area2Quest", QuestCFrame = CFrame.new(638, 73, 918), QuestLevel = 2, QuestNPC = "Kingdom Commander" }, SpawnLocation = { CFrame.new(280, 73, -120) }, ExpReward = 950000, BeliReward = 14000 },
    { FullName = "Jeremy", MobName = "Jeremy", LevelRequest = 850, IsBoss = true, Quest = { QuestName = "Area2Quest", QuestCFrame = CFrame.new(638, 73, 918), QuestLevel = 3, QuestNPC = "Kingdom Commander" }, SpawnLocation = { CFrame.new(2310, 450, 780) }, ExpReward = 1300000, BeliReward = 45000 },
    { FullName = "Marine Lieutenant", MobName = "Marine Lieutenant", LevelRequest = 875, IsBoss = false, Quest = { QuestName = "MarineQuest3", QuestCFrame = CFrame.new(-2440, 73, -3216), QuestLevel = 1, QuestNPC = "Greenzone Officer" }, SpawnLocation = { CFrame.new(-2820, 73, -3020) }, ExpReward = 1100000, BeliReward = 14500 },
    { FullName = "Marine Captain", MobName = "Marine Captain", LevelRequest = 900, IsBoss = false, Quest = { QuestName = "MarineQuest3", QuestCFrame = CFrame.new(-2440, 73, -3216), QuestLevel = 2, QuestNPC = "Greenzone Officer" }, SpawnLocation = { CFrame.new(-1880, 73, -3320) }, ExpReward = 1200000, BeliReward = 15000 },
    { FullName = "Fajita", MobName = "Fajita", LevelRequest = 925, IsBoss = true, Quest = { QuestName = "MarineQuest3", QuestCFrame = CFrame.new(-2440, 73, -3216), QuestLevel = 3, QuestNPC = "Greenzone Officer" }, SpawnLocation = { CFrame.new(-2120, 95, -4280) }, ExpReward = 1600000, BeliReward = 50000 },
    { FullName = "Zombie", MobName = "Zombie", LevelRequest = 950, IsBoss = false, Quest = { QuestName = "ZombieQuest", QuestCFrame = CFrame.new(-5495, 48, -794), QuestLevel = 1, QuestNPC = "Grave Keeper" }, SpawnLocation = { CFrame.new(-5620, 48, -720) }, ExpReward = 1350000, BeliReward = 15500 },
    { FullName = "Vampire", MobName = "Vampire", LevelRequest = 975, IsBoss = false, Quest = { QuestName = "ZombieQuest", QuestCFrame = CFrame.new(-5495, 48, -794), QuestLevel = 2, QuestNPC = "Grave Keeper" }, SpawnLocation = { CFrame.new(-6020, 7, -1320) }, ExpReward = 1500000, BeliReward = 16000 },
    { FullName = "Snow Trooper", MobName = "Snow Trooper", LevelRequest = 1000, IsBoss = false, Quest = { QuestName = "SnowMountainQuest", QuestCFrame = CFrame.new(609, 401, -5372), QuestLevel = 1, QuestNPC = "Mountain Scout" }, SpawnLocation = { CFrame.new(480, 401, -5280) }, ExpReward = 1650000, BeliReward = 16500 },
    { FullName = "Winter Warrior", MobName = "Winter Warrior", LevelRequest = 1050, IsBoss = false, Quest = { QuestName = "SnowMountainQuest", QuestCFrame = CFrame.new(609, 401, -5372), QuestLevel = 2, QuestNPC = "Mountain Scout" }, SpawnLocation = { CFrame.new(1180, 430, -5180) }, ExpReward = 1800000, BeliReward = 17000 },
    { FullName = "Lab Subordinate", MobName = "Lab Subordinate", LevelRequest = 1100, IsBoss = false, Quest = { QuestName = "IceSideQuest", QuestCFrame = CFrame.new(-6064, 16, -4902), QuestLevel = 1, QuestNPC = "Cold Researcher" }, SpawnLocation = { CFrame.new(-5820, 16, -4820) }, ExpReward = 2000000, BeliReward = 17500 },
    { FullName = "Horned Warrior", MobName = "Horned Warrior", LevelRequest = 1125, IsBoss = false, Quest = { QuestName = "IceSideQuest", QuestCFrame = CFrame.new(-6064, 16, -4902), QuestLevel = 2, QuestNPC = "Cold Researcher" }, SpawnLocation = { CFrame.new(-6420, 16, -5820) }, ExpReward = 2200000, BeliReward = 18000 },
    { FullName = "Magma Ninja", MobName = "Magma Ninja", LevelRequest = 1150, IsBoss = false, Quest = { QuestName = "FireSideQuest", QuestCFrame = CFrame.new(-5430, 16, -5295), QuestLevel = 1, QuestNPC = "Hot Researcher" }, SpawnLocation = { CFrame.new(-5220, 16, -5480) }, ExpReward = 2400000, BeliReward = 18500 },
    { FullName = "Lava Pirate", MobName = "Lava Pirate", LevelRequest = 1175, IsBoss = false, Quest = { QuestName = "FireSideQuest", QuestCFrame = CFrame.new(-5430, 16, -5295), QuestLevel = 2, QuestNPC = "Hot Researcher" }, SpawnLocation = { CFrame.new(-5280, 42, -4820) }, ExpReward = 2600000, BeliReward = 19000 },
    { FullName = "Smoke Admiral", MobName = "Smoke Admiral", LevelRequest = 1150, IsBoss = true, Quest = { QuestName = "FireSideQuest", QuestCFrame = CFrame.new(-5430, 16, -5295), QuestLevel = 3, QuestNPC = "Hot Researcher" }, SpawnLocation = { CFrame.new(-5080, 16, -5350) }, ExpReward = 3200000, BeliReward = 60000 },
    { FullName = "Ship Deckhand", MobName = "Ship Deckhand", LevelRequest = 1250, IsBoss = false, Quest = { QuestName = "ShipQuest1", QuestCFrame = CFrame.new(1038, 125, 32911), QuestLevel = 1, QuestNPC = "Ship Engineer" }, SpawnLocation = { CFrame.new(1180, 125, 32880) }, ExpReward = 3000000, BeliReward = 19500 },
    { FullName = "Ship Officer", MobName = "Ship Officer", LevelRequest = 1275, IsBoss = false, Quest = { QuestName = "ShipQuest1", QuestCFrame = CFrame.new(1038, 125, 32911), QuestLevel = 2, QuestNPC = "Ship Engineer" }, SpawnLocation = { CFrame.new(620, 125, 32880) }, ExpReward = 3200000, BeliReward = 20000 },
    { FullName = "Ship Steward", MobName = "Ship Steward", LevelRequest = 1300, IsBoss = false, Quest = { QuestName = "ShipQuest2", QuestCFrame = CFrame.new(968, 125, 33244), QuestLevel = 1, QuestNPC = "Ship Manager" }, SpawnLocation = { CFrame.new(920, 125, 33380) }, ExpReward = 3400000, BeliReward = 20500 },
    { FullName = "Ship Captain", MobName = "Ship Captain", LevelRequest = 1325, IsBoss = false, Quest = { QuestName = "ShipQuest2", QuestCFrame = CFrame.new(968, 125, 33244), QuestLevel = 2, QuestNPC = "Ship Manager" }, SpawnLocation = { CFrame.new(1080, 125, 33380) }, ExpReward = 3600000, BeliReward = 21000 },
    { FullName = "Arctic Warrior", MobName = "Arctic Warrior", LevelRequest = 1350, IsBoss = false, Quest = { QuestName = "FrostQuest", QuestCFrame = CFrame.new(5667, 28, -6482), QuestLevel = 1, QuestNPC = "Ice Castle Guard" }, SpawnLocation = { CFrame.new(5980, 28, -6220) }, ExpReward = 3800000, BeliReward = 21500 },
    { FullName = "Snow Lurker", MobName = "Snow Lurker", LevelRequest = 1375, IsBoss = false, Quest = { QuestName = "FrostQuest", QuestCFrame = CFrame.new(5667, 28, -6482), QuestLevel = 2, QuestNPC = "Ice Castle Guard" }, SpawnLocation = { CFrame.new(5520, 28, -6820) }, ExpReward = 4000000, BeliReward = 22000 },
    { FullName = "Awakened Ice Admiral", MobName = "Awakened Ice Admiral", LevelRequest = 1400, IsBoss = true, Quest = { QuestName = "FrostQuest", QuestCFrame = CFrame.new(5667, 28, -6482), QuestLevel = 3, QuestNPC = "Ice Castle Guard" }, SpawnLocation = { CFrame.new(6470, 295, -6840) }, ExpReward = 5000000, BeliReward = 70000 },
    { FullName = "Sea Soldier", MobName = "Sea Soldier", LevelRequest = 1425, IsBoss = false, Quest = { QuestName = "ForgottenQuest", QuestCFrame = CFrame.new(-3054, 236, -10142), QuestLevel = 1, QuestNPC = "Water Guard" }, SpawnLocation = { CFrame.new(-3020, 236, -9820) }, ExpReward = 4200000, BeliReward = 22500 },
    { FullName = "Water Fighter", MobName = "Water Fighter", LevelRequest = 1450, IsBoss = false, Quest = { QuestName = "ForgottenQuest", QuestCFrame = CFrame.new(-3054, 236, -10142), QuestLevel = 2, QuestNPC = "Water Guard" }, SpawnLocation = { CFrame.new(-3380, 236, -10480) }, ExpReward = 4500000, BeliReward = 23000 },
    { FullName = "Tide Keeper", MobName = "Tide Keeper", LevelRequest = 1475, IsBoss = true, Quest = { QuestName = "ForgottenQuest", QuestCFrame = CFrame.new(-3054, 236, -10142), QuestLevel = 3, QuestNPC = "Water Guard" }, SpawnLocation = { CFrame.new(-3720, 77, -11475) }, ExpReward = 6000000, BeliReward = 75000 },

    -- Sea 3 Mobs
    { FullName = "Pirate Millionaire", MobName = "Pirate Millionaire", LevelRequest = 1500, IsBoss = false, Quest = { QuestName = "PortTownQuest", QuestCFrame = CFrame.new(-290, 44, 5580), QuestLevel = 1, QuestNPC = "Port Officer" }, SpawnLocation = { CFrame.new(-380, 44, 5520) }, ExpReward = 4800000, BeliReward = 23500 },
    { FullName = "Pistol Billionaire", MobName = "Pistol Billionaire", LevelRequest = 1525, IsBoss = false, Quest = { QuestName = "PortTownQuest", QuestCFrame = CFrame.new(-290, 44, 5580), QuestLevel = 2, QuestNPC = "Port Officer" }, SpawnLocation = { CFrame.new(-220, 44, 5820) }, ExpReward = 5100000, BeliReward = 24000 },
    { FullName = "Stone", MobName = "Stone", LevelRequest = 1550, IsBoss = true, Quest = { QuestName = "PortTownQuest", QuestCFrame = CFrame.new(-290, 44, 5580), QuestLevel = 3, QuestNPC = "Port Officer" }, SpawnLocation = { CFrame.new(-1050, 40, 6770) }, ExpReward = 7000000, BeliReward = 80000 },
    { FullName = "Amazon Warrior", MobName = "Amazon Warrior", LevelRequest = 1575, IsBoss = false, Quest = { QuestName = "AmazonQuest", QuestCFrame = CFrame.new(5833, 52, -1105), QuestLevel = 1, QuestNPC = "Hydra Scout" }, SpawnLocation = { CFrame.new(5720, 52, -1020) }, ExpReward = 5400000, BeliReward = 24500 },
    { FullName = "Female Islander", MobName = "Female Islander", LevelRequest = 1600, IsBoss = false, Quest = { QuestName = "AmazonQuest", QuestCFrame = CFrame.new(5833, 52, -1105), QuestLevel = 2, QuestNPC = "Hydra Scout" }, SpawnLocation = { CFrame.new(5420, 600, 320) }, ExpReward = 5700000, BeliReward = 25000 },
    { FullName = "Giant Islander", MobName = "Giant Islander", LevelRequest = 1625, IsBoss = false, Quest = { QuestName = "AmazonQuest2", QuestCFrame = CFrame.new(5441, 600, 750), QuestLevel = 1, QuestNPC = "Hydra Leader" }, SpawnLocation = { CFrame.new(4820, 600, 720) }, ExpReward = 6000000, BeliReward = 25500 },
    { FullName = "Island Empress", MobName = "Island Empress", LevelRequest = 1675, IsBoss = true, Quest = { QuestName = "AmazonQuest2", QuestCFrame = CFrame.new(5441, 600, 750), QuestLevel = 3, QuestNPC = "Hydra Leader" }, SpawnLocation = { CFrame.new(5700, 600, 200) }, ExpReward = 8500000, BeliReward = 90000 },
    { FullName = "Marine Commodore", MobName = "Marine Commodore", LevelRequest = 1700, IsBoss = false, Quest = { QuestName = "GreatTreeQuest", QuestCFrame = CFrame.new(-2512, 298, -10142), QuestLevel = 1, QuestNPC = "Tree Officer" }, SpawnLocation = { CFrame.new(-2280, 298, -10220) }, ExpReward = 6600000, BeliReward = 26000 },
    { FullName = "Marine Rear Admiral", MobName = "Marine Rear Admiral", LevelRequest = 1725, IsBoss = false, Quest = { QuestName = "GreatTreeQuest", QuestCFrame = CFrame.new(-2512, 298, -10142), QuestLevel = 2, QuestNPC = "Tree Officer" }, SpawnLocation = { CFrame.new(-2820, 298, -9620) }, ExpReward = 7000000, BeliReward = 26500 },
    { FullName = "Kilo Admiral", MobName = "Kilo Admiral", LevelRequest = 1750, IsBoss = true, Quest = { QuestName = "GreatTreeQuest", QuestCFrame = CFrame.new(-2512, 298, -10142), QuestLevel = 3, QuestNPC = "Tree Officer" }, SpawnLocation = { CFrame.new(2880, 73, -7230) }, ExpReward = 10000000, BeliReward = 100000 },
    { FullName = "Fishman Raider", MobName = "Fishman Raider", LevelRequest = 1775, IsBoss = false, Quest = { QuestName = "DeepForestQuest", QuestCFrame = CFrame.new(-13234, 331, -7625), QuestLevel = 1, QuestNPC = "Turtle Adventurer" }, SpawnLocation = { CFrame.new(-13020, 331, -7920) }, ExpReward = 7400000, BeliReward = 27000 },
    { FullName = "Fishman Captain", MobName = "Fishman Captain", LevelRequest = 1800, IsBoss = false, Quest = { QuestName = "DeepForestQuest", QuestCFrame = CFrame.new(-13234, 331, -7625), QuestLevel = 2, QuestNPC = "Turtle Adventurer" }, SpawnLocation = { CFrame.new(-13520, 331, -7120) }, ExpReward = 7800000, BeliReward = 27500 },
    { FullName = "Forest Pirate", MobName = "Forest Pirate", LevelRequest = 1825, IsBoss = false, Quest = { QuestName = "DeepForest2Quest", QuestCFrame = CFrame.new(-13234, 331, -7625), QuestLevel = 1, QuestNPC = "Turtle Ranger" }, SpawnLocation = { CFrame.new(-13420, 331, -7920) }, ExpReward = 8200000, BeliReward = 28000 },
    { FullName = "Mythological Pirate", MobName = "Mythological Pirate", LevelRequest = 1850, IsBoss = false, Quest = { QuestName = "DeepForest2Quest", QuestCFrame = CFrame.new(-13234, 331, -7625), QuestLevel = 2, QuestNPC = "Turtle Ranger" }, SpawnLocation = { CFrame.new(-13720, 480, -6920) }, ExpReward = 8600000, BeliReward = 28500 },
    { FullName = "Captain Elephant", MobName = "Captain Elephant", LevelRequest = 1875, IsBoss = true, Quest = { QuestName = "DeepForest2Quest", QuestCFrame = CFrame.new(-13234, 331, -7625), QuestLevel = 3, QuestNPC = "Turtle Ranger" }, SpawnLocation = { CFrame.new(-13380, 320, -8470) }, ExpReward = 12000000, BeliReward = 110000 },
    
    -- HOÀN THIỆN TỪ LEVEL 1900 ĐẾN MAX LEVEL
    { FullName = "Jungle Pirate", MobName = "Jungle Pirate", LevelRequest = 1900, IsBoss = false, Quest = { QuestName = "DeepForest3Quest", QuestCFrame = CFrame.new(-12580, 331, -9870), QuestLevel = 1, QuestNPC = "Forest Guard" }, SpawnLocation = { CFrame.new(-12180, 331, -10480), CFrame.new(-12220, 331, -10520) }, ExpReward = 9000000, BeliReward = 29000 },
    { FullName = "Musketeer Pirate", MobName = "Musketeer Pirate", LevelRequest = 1925, IsBoss = false, Quest = { QuestName = "DeepForest3Quest", QuestCFrame = CFrame.new(-12580, 331, -9870), QuestLevel = 2, QuestNPC = "Forest Guard" }, SpawnLocation = { CFrame.new(-13280, 390, -9780), CFrame.new(-13320, 390, -9820) }, ExpReward = 9400000, BeliReward = 29500 },
    { FullName = "Beautiful Pirate", MobName = "Beautiful Pirate", LevelRequest = 1950, IsBoss = true, Quest = { QuestName = "DeepForest3Quest", QuestCFrame = CFrame.new(-12580, 331, -9870), QuestLevel = 3, QuestNPC = "Forest Guard" }, SpawnLocation = { CFrame.new(-12680, 14, -9620) }, ExpReward = 13000000, BeliReward = 120000 },
    
    -- Haunted Castle
    { FullName = "Reborn Skeleton", MobName = "Reborn Skeleton", LevelRequest = 1975, IsBoss = false, Quest = { QuestName = "HauntedQuest1", QuestCFrame = CFrame.new(-9479, 142, 5566), QuestLevel = 1, QuestNPC = "Grave Skeleton" }, SpawnLocation = { CFrame.new(-8780, 142, 6020), CFrame.new(-8820, 142, 5980) }, ExpReward = 9800000, BeliReward = 30000 },
    { FullName = "Living Zombie", MobName = "Living Zombie", LevelRequest = 2000, IsBoss = false, Quest = { QuestName = "HauntedQuest1", QuestCFrame = CFrame.new(-9479, 142, 5566), QuestLevel = 2, QuestNPC = "Grave Skeleton" }, SpawnLocation = { CFrame.new(-10120, 142, 5820), CFrame.new(-10160, 142, 5860) }, ExpReward = 10200000, BeliReward = 30500 },
    { FullName = "Demonic Soul", MobName = "Demonic Soul", LevelRequest = 2025, IsBoss = false, Quest = { QuestName = "HauntedQuest2", QuestCFrame = CFrame.new(-9515, 172, 6078), QuestLevel = 1, QuestNPC = "Ghost Warden" }, SpawnLocation = { CFrame.new(-9480, 172, 6180), CFrame.new(-9520, 172, 6140) }, ExpReward = 10600000, BeliReward = 31000 },
    { FullName = "Possessed Mummy", MobName = "Possessed Mummy", LevelRequest = 2050, IsBoss = false, Quest = { QuestName = "HauntedQuest2", QuestCFrame = CFrame.new(-9515, 172, 6078), QuestLevel = 2, QuestNPC = "Ghost Warden" }, SpawnLocation = { CFrame.new(-9580, 6, 6220), CFrame.new(-9620, 6, 6180) }, ExpReward = 11000000, BeliReward = 31500 },
    
    -- Sea of Treats
    { FullName = "Peanut Scout", MobName = "Peanut Scout", LevelRequest = 2075, IsBoss = false, Quest = { QuestName = "PeanutQuest", QuestCFrame = CFrame.new(-1900, 38, -10250), QuestLevel = 1, QuestNPC = "Peanut Chef" }, SpawnLocation = { CFrame.new(-2120, 38, -10120), CFrame.new(-2080, 38, -10160) }, ExpReward = 11400000, BeliReward = 32000 },
    { FullName = "Peanut President", MobName = "Peanut President", LevelRequest = 2100, IsBoss = false, Quest = { QuestName = "PeanutQuest", QuestCFrame = CFrame.new(-1900, 38, -10250), QuestLevel = 2, QuestNPC = "Peanut Chef" }, SpawnLocation = { CFrame.new(-2180, 38, -9820), CFrame.new(-2140, 38, -9860) }, ExpReward = 11800000, BeliReward = 32500 },
    { FullName = "Ice Cream Chef", MobName = "Ice Cream Chef", LevelRequest = 2125, IsBoss = false, Quest = { QuestName = "IceCreamQuest", QuestCFrame = CFrame.new(-820, 65, -10900), QuestLevel = 1, QuestNPC = "Frosty Chef" }, SpawnLocation = { CFrame.new(-620, 65, -10980), CFrame.new(-660, 65, -10940) }, ExpReward = 12200000, BeliReward = 33000 },
    { FullName = "Ice Cream Commander", MobName = "Ice Cream Commander", LevelRequest = 2150, IsBoss = false, Quest = { QuestName = "IceCreamQuest", QuestCFrame = CFrame.new(-820, 65, -10900), QuestLevel = 2, QuestNPC = "Frosty Chef" }, SpawnLocation = { CFrame.new(-880, 65, -11280), CFrame.new(-840, 65, -11240) }, ExpReward = 12600000, BeliReward = 33500 },
    { FullName = "Cookie Crafter", MobName = "Cookie Crafter", LevelRequest = 2175, IsBoss = false, Quest = { QuestName = "CakeQuest1", QuestCFrame = CFrame.new(-2020, 38, -12025), QuestLevel = 1, QuestNPC = "Bake Master" }, SpawnLocation = { CFrame.new(-2380, 38, -12120), CFrame.new(-2340, 38, -12160) }, ExpReward = 13000000, BeliReward = 34000 },
    { FullName = "Cake Guard", MobName = "Cake Guard", LevelRequest = 2200, IsBoss = false, Quest = { QuestName = "CakeQuest1", QuestCFrame = CFrame.new(-2020, 38, -12025), QuestLevel = 2, QuestNPC = "Bake Master" }, SpawnLocation = { CFrame.new(-1580, 38, -12320), CFrame.new(-1540, 38, -12360) }, ExpReward = 13400000, BeliReward = 34500 },
    { FullName = "Baking Staff", MobName = "Baking Staff", LevelRequest = 2225, IsBoss = false, Quest = { QuestName = "CakeQuest2", QuestCFrame = CFrame.new(-1920, 38, -12850), QuestLevel = 1, QuestNPC = "Cake Helper" }, SpawnLocation = { CFrame.new(-1820, 38, -12980), CFrame.new(-1860, 38, -12940) }, ExpReward = 13800000, BeliReward = 35000 },
    { FullName = "Head Baker", MobName = "Head Baker", LevelRequest = 2250, IsBoss = false, Quest = { QuestName = "CakeQuest2", QuestCFrame = CFrame.new(-1920, 38, -12850), QuestLevel = 2, QuestNPC = "Cake Helper" }, SpawnLocation = { CFrame.new(-2180, 38, -12920), CFrame.new(-2140, 38, -12960) }, ExpReward = 14200000, BeliReward = 35500 },
    { FullName = "Cake Queen", MobName = "Cake Queen", LevelRequest = 2275, IsBoss = true, Quest = { QuestName = "CakeQuest2", QuestCFrame = CFrame.new(-1920, 38, -12850), QuestLevel = 3, QuestNPC = "Cake Helper" }, SpawnLocation = { CFrame.new(-710, 381, -11000) }, ExpReward = 18000000, BeliReward = 130000 },
    { FullName = "Cocoa Warrior", MobName = "Cocoa Warrior", LevelRequest = 2300, IsBoss = false, Quest = { QuestName = "ChocQuest", QuestCFrame = CFrame.new(151, 23, -12774), QuestLevel = 1, QuestNPC = "Choc Guard" }, SpawnLocation = { CFrame.new(220, 23, -12580), CFrame.new(260, 23, -12620) }, ExpReward = 14600000, BeliReward = 36000 },
    { FullName = "Chocolate Bar Battler", MobName = "Chocolate Bar Battler", LevelRequest = 2325, IsBoss = false, Quest = { QuestName = "ChocQuest", QuestCFrame = CFrame.new(151, 23, -12774), QuestLevel = 2, QuestNPC = "Choc Guard" }, SpawnLocation = { CFrame.new(420, 23, -12880), CFrame.new(380, 23, -12840) }, ExpReward = 15000000, BeliReward = 36500 },
    { FullName = "Sweet Thief", MobName = "Sweet Thief", LevelRequest = 2350, IsBoss = false, Quest = { QuestName = "CandyQuest", QuestCFrame = CFrame.new(-1200, 23, -12200), QuestLevel = 1, QuestNPC = "Candy Lord" }, SpawnLocation = { CFrame.new(-1020, 23, -12380), CFrame.new(-1060, 23, -12340) }, ExpReward = 15400000, BeliReward = 37000 },
    { FullName = "Candy Rebel", MobName = "Candy Rebel", LevelRequest = 2375, IsBoss = false, Quest = { QuestName = "CandyQuest", QuestCFrame = CFrame.new(-1200, 23, -12200), QuestLevel = 2, QuestNPC = "Candy Lord" }, SpawnLocation = { CFrame.new(-1380, 23, -12520), CFrame.new(-1340, 23, -12480) }, ExpReward = 15800000, BeliReward = 37500 },

    -- Tiki Outpost
    { FullName = "Isle Outlaw", MobName = "Isle Outlaw", LevelRequest = 2400, IsBoss = false, Quest = { QuestName = "TikiQuest1", QuestCFrame = CFrame.new(-16533, 55, 1052), QuestLevel = 1, QuestNPC = "Tiki Chief" }, SpawnLocation = { CFrame.new(-16280, 55, 1220), CFrame.new(-16320, 55, 1180) }, ExpReward = 16200000, BeliReward = 38000 },
    { FullName = "Island Boy", MobName = "Island Boy", LevelRequest = 2425, IsBoss = false, Quest = { QuestName = "TikiQuest1", QuestCFrame = CFrame.new(-16533, 55, 1052), QuestLevel = 2, QuestNPC = "Tiki Chief" }, SpawnLocation = { CFrame.new(-16820, 55, 1420), CFrame.new(-16860, 55, 1380) }, ExpReward = 16600000, BeliReward = 38500 },
    { FullName = "Sun-kissed Warrior", MobName = "Sun-kissed Warrior", LevelRequest = 2450, IsBoss = false, Quest = { QuestName = "TikiQuest2", QuestCFrame = CFrame.new(-16200, 55, 450), QuestLevel = 1, QuestNPC = "Tiki Scout" }, SpawnLocation = { CFrame.new(-15980, 55, 220), CFrame.new(-16020, 55, 260) }, ExpReward = 17000000, BeliReward = 39000 },
    { FullName = "Isle Champion", MobName = "Isle Champion", LevelRequest = 2475, IsBoss = false, Quest = { QuestName = "TikiQuest2", QuestCFrame = CFrame.new(-16200, 55, 450), QuestLevel = 2, QuestNPC = "Tiki Scout" }, SpawnLocation = { CFrame.new(-16480, 55, -120), CFrame.new(-16520, 55, -80) }, ExpReward = 17400000, BeliReward = 39500 },
    { FullName = "Serpent Hunter", MobName = "Serpent Hunter", LevelRequest = 2500, IsBoss = false, Quest = { QuestName = "TikiQuest3", QuestCFrame = CFrame.new(-16800, 85, -450), QuestLevel = 1, QuestNPC = "Tiki Elder" }, SpawnLocation = { CFrame.new(-17120, 85, -620), CFrame.new(-17080, 85, -580) }, ExpReward = 17800000, BeliReward = 40000 },
    { FullName = "Skull Pirate", MobName = "Skull Pirate", LevelRequest = 2525, IsBoss = false, Quest = { QuestName = "TikiQuest3", QuestCFrame = CFrame.new(-16800, 85, -450), QuestLevel = 2, QuestNPC = "Tiki Elder" }, SpawnLocation = { CFrame.new(-17420, 85, -320), CFrame.new(-17380, 85, -360) }, ExpReward = 18200000, BeliReward = 40500 }
}
							
		end)
	end
end)

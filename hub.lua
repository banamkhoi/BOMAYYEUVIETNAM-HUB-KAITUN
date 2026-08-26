repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local plr = Players.LocalPlayer

-- HIỂN THỊ UI "KAITUN HUB: ON"
pcall(function()
	local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or plr:WaitForChild("PlayerGui")
	if parentGui:FindFirstChild("KaitunCheckGui") then parentGui.KaitunCheckGui:Destroy() end

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
end)

-- CẤU HÌNH CƠ BẢN
_G = _G or {}
_G.MobHeight = 12         -- Hạ độ cao xuống 12 studs để trúng Hitbox Melee
_G.BringRange = 250       
_G.MaxBringMobs = 15
_G.FlySpeed = 200         -- Giữ 200 để né Anti-cheat/Rubberband

_B = false
PosMon = nil

local currentTween = nil
local currentTarget = nil

-- 1. LOAD EXTERNAL FAST ATTACK
task.spawn(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/thienvl1395-dot/script/refs/heads/main/attack.lua"))()
	end)
end)

-- 2. AUTO CHỌN PHE PIRATE
task.spawn(function()
	repeat
		task.wait(0.1)
		pcall(function()
			ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
		end)
	until plr.Team ~= nil and (plr.Team.Name == "Pirates" or plr.Team.Name == "Pirate")
end)

-- 3. HÀM ÉP CẦM MELEE
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

-- 4. NOCLIP + KEEP MELEE
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

-- 5. ANTI AFK
plr.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- 6. TWEEN FLY SYSTEM
local function _tp(cframe)
	if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = plr.Character.HumanoidRootPart
	local distance = (hrp.Position - cframe.Position).Magnitude

	if distance <= 15 then
		if currentTween then
			currentTween:Cancel()
			currentTween = nil
		end
		hrp.Velocity = Vector3.new(0, 0, 0)
		hrp.CFrame = cframe
	else
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

-- 7. DỮ LIỆU QUEST & FARM LOGIC
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
end

-- VÒNG LẶP FARM CHÍNH
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
					_B = false
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
						_B = false
						_tp(questInfo.MobPos * CFrame.new(0, _G.MobHeight, 0))
					end
				end
			end
		end)
	end
end)

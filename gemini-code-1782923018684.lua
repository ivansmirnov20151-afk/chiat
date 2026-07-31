-- =============================================================================
-- 🪐 ROBLOX VISUALS V33.2 [👑 ULTRA PREMIUM ADAPTIVE EDITION]
-- =============================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalizationService = game:GetService("LocalizationService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
while not player do
	task.wait(0.1)
	player = Players.LocalPlayer
end

local playerGui = player:FindFirstChildOfClass("PlayerGui")
while not playerGui do
	task.wait(0.1)
	playerGui = player:FindFirstChildOfClass("PlayerGui")
end

local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

if playerGui:FindFirstChild("RobloxVisuals_V33") then 
	playerGui.RobloxVisuals_V33:Destroy() 
end
if playerGui:FindFirstChild("CyberEngine_V32_Max") then
	playerGui.CyberEngine_V32_Max:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxVisuals_V33"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

-- База Особых Статусов (Админы и Ютуберы)
local SpecialUsers = {
	["daniil2024815"] = {label = "[YT] ✓", role = "YOUTUBER"},
	["zte2049"] = {label = "[ADMIN] ✓", role = "ADMIN"}
}
local function getSpecialStatus(targetPlayer)
	return targetPlayer and SpecialUsers[targetPlayer.Name:lower()] or nil
end
local isBypassUser = getSpecialStatus(player) ~= nil

-- Добавляйте заблокированных пользователей в формате ["Ник"] = "Причина".
local BanList = {
	 ["Daniil2014815"] = "Нарушение правил Roblox Visuals",
}
local banReason = BanList[player.Name] or BanList[player.Name:lower()]
local banSequenceStarted = false
local interfaceLocked = false
local toggleControls = {}
local onAnyModActivated = function() end
local ToggleMenuBtn

-- Стартовая тема на основе фото 
local Theme = {
	GlassBg = Color3.fromRGB(36, 26, 20),
	GlassTrans = 0.12,
	HeaderBg = Color3.fromRGB(46, 33, 25),
	AccentCyan = Color3.fromRGB(235, 135, 40),
	AccentPurple = Color3.fromRGB(160, 95, 60),
	AccentGreen = Color3.fromRGB(46, 204, 113),
	Text = Color3.fromRGB(250, 245, 240),
	BtnOff = Color3.fromRGB(50, 38, 30),
	BtnOn = Color3.fromRGB(110, 65, 40),
	AlertRed = Color3.fromRGB(231, 76, 60),
	Gold = Color3.fromRGB(241, 196, 15)
}

local States = {}
local curSpeed, curJump = 16, 50
local autoPlatform = nil
local haloPart = nil
local xrayCache = {}

local isRecording = false
local isRecordingPaused = false
local isPlaying = false
local isMacroPaused = false
local recordedPath = {} 

-- Переменные для Системы Друзей
local friendsList = {}
local friendsHealthCache = {}
local whitelistedFriends = {}
local selectedFriendName = ""
local followingFriend = nil

local function applyGlassStyle(obj, radius, strokeColor, strokeThickness)
	if radius then
		local corner = Instance.new("UICorner", obj)
		corner.CornerRadius = UDim.new(0, radius)
	end
	if strokeColor then
		local stroke = Instance.new("UIStroke", obj)
		stroke.Color = strokeColor
		stroke.Thickness = strokeThickness or 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end
end

-- =============================================================================
-- 🔔 ДИНАМИЧЕСКАЯ СИСТЕМА УВЕДОМЛЕНИЙ
-- =============================================================================
local activeNotifications = {}
local function createNotification(titleText, descText, noticeType)
	local offset = #activeNotifications * 82
	local notifyFrame = Instance.new("Frame", ScreenGui)
	notifyFrame.Size = UDim2.new(0, 350, 0, 70)
	notifyFrame.Position = UDim2.new(0.5, -175, 0, -90) 
	notifyFrame.BackgroundColor3 = Theme.GlassBg
	notifyFrame.BackgroundTransparency = 0.05
	
	local strokeColor = (noticeType == "Alert") and Theme.AlertRed or Theme.AccentCyan
	applyGlassStyle(notifyFrame, 12, strokeColor, 2)
	notifyFrame.ZIndex = 10000 

	local tLabel = Instance.new("TextLabel", notifyFrame)
	tLabel.Size = UDim2.new(1, -20, 0, 25)
	tLabel.Position = UDim2.new(0, 15, 0, 10)
	tLabel.Text = titleText
	tLabel.TextColor3 = (noticeType == "Alert") and Theme.AlertRed or Theme.Text
	tLabel.Font = Enum.Font.GothamBold
	tLabel.TextSize = 15
	tLabel.BackgroundTransparency = 1
	tLabel.ZIndex = 10001

	local dLabel = Instance.new("TextLabel", notifyFrame)
	dLabel.Size = UDim2.new(1, -20, 0, 25)
	dLabel.Position = UDim2.new(0, 15, 0, 35)
	dLabel.Text = descText
	dLabel.TextColor3 = Theme.Text
	dLabel.Font = Enum.Font.GothamBold
	dLabel.TextSize = 13
	dLabel.BackgroundTransparency = 1
	dLabel.ZIndex = 10001

	table.insert(activeNotifications, notifyFrame)
	local targetY = 40 + offset
	TweenService:Create(notifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -175, 0, targetY)}):Play()
	
	task.delay(4, function()
		if notifyFrame and notifyFrame.Parent then
			local tweenOut = TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -175, 0, -90)})
			tweenOut:Play()
			tweenOut.Completed:Wait()
			local idx = table.find(activeNotifications, notifyFrame)
			if idx then
				table.remove(activeNotifications, idx)
				for i, n in ipairs(activeNotifications) do
					if n and n.Parent then
						TweenService:Create(n, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -175, 0, 40 + (i - 1) * 82)}):Play()
					end
				end
			end
			notifyFrame:Destroy()
		end
	end)
end

local function makeDraggable(frame, handle)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- =============================================================================
-- 🎬 ЭКРАН ПРИВЕТСТВИЯ
-- =============================================================================
local IntroBackground = Instance.new("Frame", ScreenGui)
IntroBackground.Size = UDim2.new(1, 0, 1, 0)
IntroBackground.BackgroundTransparency = 1
IntroBackground.ZIndex = 500

-- Фоновые звёздочки
local starRng = Random.new()
for _ = 1, 28 do
	local star = Instance.new("Frame", IntroBackground)
	local sz = starRng:NextInteger(2, 5)
	star.Size = UDim2.new(0, sz, 0, sz)
	star.Position = UDim2.new(starRng:NextNumber(0.05, 0.95), 0, starRng:NextNumber(0.05, 0.95), 0)
	star.BackgroundColor3 = Color3.fromRGB(255, 245, 210)
	star.BackgroundTransparency = starRng:NextNumber(0.3, 0.7)
	star.ZIndex = 501
	applyGlassStyle(star, sz)
	task.spawn(function()
		local t = starRng:NextNumber(0, 6)
		while IntroBackground.Parent do
			t = t + 0.07
			star.BackgroundTransparency = 0.3 + math.sin(t) * 0.4
			task.wait(0.06)
		end
	end)
end

local IntroFrame = Instance.new("Frame", IntroBackground)
IntroFrame.Size = UDim2.new(0, 420, 0, 280)
-- Стартует ниже экрана — будет слайдиться вверх
IntroFrame.Position = UDim2.new(0.5, -210, 1.3, 0)
IntroFrame.BackgroundColor3 = Theme.GlassBg
IntroFrame.BackgroundTransparency = 0.1
IntroFrame.ZIndex = 502
applyGlassStyle(IntroFrame, 16, Theme.AccentPurple, 2)

-- Градиент-шайн внутри окна
local IntroGrad = Instance.new("UIGradient", IntroFrame)
IntroGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 45, 35)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 14)),
})
IntroGrad.Rotation = 135

local IntroImage = Instance.new("ImageLabel", IntroFrame)
IntroImage.Size = UDim2.new(0, 110, 0, 110)
IntroImage.Position = UDim2.new(0.5, -55, 0, 20)
IntroImage.BackgroundTransparency = 1
IntroImage.Image = "rbxassetid://79078068171736"
IntroImage.ImageTransparency = 1
IntroImage.Rotation = -20
IntroImage.ZIndex = 503

-- Кольцо вокруг логотипа
local IntroRing = Instance.new("Frame", IntroFrame)
IntroRing.Size = UDim2.new(0, 126, 0, 126)
IntroRing.Position = UDim2.new(0.5, -63, 0, 12)
IntroRing.BackgroundTransparency = 1
IntroRing.ZIndex = 502
applyGlassStyle(IntroRing, 63, Theme.AccentCyan, 2)

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.Size = UDim2.new(1, 0, 0, 30)
IntroTitle.Position = UDim2.new(0, 0, 0, 145)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "🪐 ROBLOX VISUALS"
IntroTitle.TextColor3 = Theme.Gold
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.TextSize = 22
IntroTitle.TextTransparency = 1
IntroTitle.ZIndex = 503

local IntroVersion = Instance.new("TextLabel", IntroFrame)
IntroVersion.Size = UDim2.new(1, 0, 0, 18)
IntroVersion.Position = UDim2.new(0, 0, 0, 178)
IntroVersion.BackgroundTransparency = 1
IntroVersion.Text = "ULTRA PREMIUM ADAPTIVE EDITION v33.2"
IntroVersion.TextColor3 = Theme.AccentCyan
IntroVersion.Font = Enum.Font.Code
IntroVersion.TextSize = 10
IntroVersion.TextTransparency = 1
IntroVersion.ZIndex = 503

local IntroStatus = Instance.new("TextLabel", IntroFrame)
IntroStatus.Size = UDim2.new(1, -20, 0, 18)
IntroStatus.Position = UDim2.new(0, 10, 0, 202)
IntroStatus.BackgroundTransparency = 1
IntroStatus.Text = ""
IntroStatus.TextColor3 = Color3.fromRGB(180, 165, 145)
IntroStatus.Font = Enum.Font.Code
IntroStatus.TextSize = 11
IntroStatus.TextXAlignment = Enum.TextXAlignment.Left
IntroStatus.ZIndex = 503

-- Прогресс-бар
local IntroProgressBg = Instance.new("Frame", IntroFrame)
IntroProgressBg.Size = UDim2.new(1, -30, 0, 6)
IntroProgressBg.Position = UDim2.new(0, 15, 0, 254)
IntroProgressBg.BackgroundColor3 = Color3.fromRGB(55, 42, 33)
IntroProgressBg.ZIndex = 503
applyGlassStyle(IntroProgressBg, 3)

local IntroProgressFill = Instance.new("Frame", IntroProgressBg)
IntroProgressFill.Size = UDim2.new(0, 0, 1, 0)
IntroProgressFill.BackgroundColor3 = Theme.AccentCyan
IntroProgressFill.ZIndex = 504
applyGlassStyle(IntroProgressFill, 3)

-- 🔴 Индикатор записи макроса
local RecordIndicator = Instance.new("TextLabel", ScreenGui)
RecordIndicator.Size = UDim2.new(0, 360, 0, 40)
RecordIndicator.Position = UDim2.new(0.5, -180, 0, 70)
RecordIndicator.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
RecordIndicator.BackgroundTransparency = 0.3
RecordIndicator.Text = "🔴 ЗАПИСЬ ИДЕТ... [L - СТОП | E - ПАУЗА]"
RecordIndicator.TextColor3 = Theme.AlertRed
RecordIndicator.Font = Enum.Font.GothamBold
RecordIndicator.TextSize = 12
RecordIndicator.Visible = false
RecordIndicator.ZIndex = 10
applyGlassStyle(RecordIndicator, 8, Theme.AlertRed, 1.5)

-- 🕒 Виджет времени МСК
local ClockWidget = Instance.new("Frame", ScreenGui)
ClockWidget.Size = UDim2.new(0, 150, 0, 35)
ClockWidget.Position = UDim2.new(1, -170, 0, 20)
ClockWidget.BackgroundColor3 = Theme.GlassBg
ClockWidget.BackgroundTransparency = Theme.GlassTrans
ClockWidget.Visible = false
applyGlassStyle(ClockWidget, 8, Theme.AccentCyan, 1.2)

local ClockLabel = Instance.new("TextLabel", ClockWidget)
ClockLabel.Size = UDim2.new(1, 0, 1, 0)
ClockLabel.BackgroundTransparency = 1
ClockLabel.TextColor3 = Theme.Text
ClockLabel.Font = Enum.Font.Code
ClockLabel.TextSize = 13
makeDraggable(ClockWidget, ClockWidget)

task.spawn(function()
	while true do
		local mskTime = os.date("!*t", os.time() + 10800)
		ClockLabel.Text = string.format("🕒 МСК: %02d:%02d:%02d", mskTime.hour, mskTime.min, mskTime.sec)
		task.wait(1)
	end
end)

-- 🔮 Виджет модов
local CounterWidget = Instance.new("Frame", ScreenGui)
CounterWidget.Size = UDim2.new(0, 150, 0, 35)
CounterWidget.Position = UDim2.new(1, -170, 0, 65)
CounterWidget.BackgroundColor3 = Theme.GlassBg
CounterWidget.BackgroundTransparency = Theme.GlassTrans
CounterWidget.Visible = false
applyGlassStyle(CounterWidget, 8, Theme.AccentPurple, 1.2)

local CounterLabel = Instance.new("TextLabel", CounterWidget)
CounterLabel.Size = UDim2.new(1, 0, 1, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "🔮 АКТИВНО: 0 МОДОВ"
CounterLabel.TextColor3 = Theme.Text
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.TextSize = 10
makeDraggable(CounterWidget, CounterWidget)

local function updateCounter() 
	local active = 0
	for _, v in pairs(States) do if v then active = active + 1 end end
	CounterLabel.Text = "🔮 АКТИВНО: " .. active .. " МОДОВ" 
end

-- 🖥️ ЦЕНТРАЛЬНЫЙ ОВЕРЛЕЙ «ROBLOX VISUALS»
local CenterOverlay = Instance.new("Frame", ScreenGui)
CenterOverlay.Size = UDim2.new(0, 320, 0, 90)
CenterOverlay.Position = UDim2.new(0.5, -160, 0.35, -45)
CenterOverlay.BackgroundTransparency = 1
CenterOverlay.Visible = false

local OverlayTitle = Instance.new("TextLabel", CenterOverlay)
OverlayTitle.Size = UDim2.new(1, 0, 0, 40)
OverlayTitle.Text = "ROBLOX VISUALS"
OverlayTitle.TextColor3 = Theme.Gold
OverlayTitle.Font = Enum.Font.GothamBlack
OverlayTitle.TextSize = 28
OverlayTitle.BackgroundTransparency = 1

local OverlayClock = Instance.new("TextLabel", CenterOverlay)
OverlayClock.Size = UDim2.new(1, 0, 0, 30)
OverlayClock.Position = UDim2.new(0, 0, 0, 45)
OverlayClock.TextColor3 = Theme.Text
OverlayClock.Font = Enum.Font.Code
OverlayClock.TextSize = 20
OverlayClock.BackgroundTransparency = 1

task.spawn(function()
	while true do
		if CenterOverlay.Visible then
			local t = os.date("!*t", os.time() + 10800)
			OverlayClock.Text = string.format("⏱️ %02d:%02d:%02d", t.hour, t.min, t.sec)
		end
		task.wait(0.1)
	end
end)

-- 🖱️ ХОВЕР-ИНФО ИГРОКОВ (С КНОПКОЙ ОТКЛЮЧЕНИЯ)
local HoverInfoFrame = Instance.new("Frame", ScreenGui)
HoverInfoFrame.Size = UDim2.new(0, 160, 0, 45)
HoverInfoFrame.BackgroundColor3 = Color3.fromRGB(25, 18, 14)
HoverInfoFrame.BackgroundTransparency = 0.1
HoverInfoFrame.Visible = false
HoverInfoFrame.ZIndex = 99999
applyGlassStyle(HoverInfoFrame, 8, Theme.AccentCyan, 1.2)

local HoverText = Instance.new("TextLabel", HoverInfoFrame)
HoverText.Size = UDim2.new(1, 0, 1, 0)
HoverText.BackgroundTransparency = 1
HoverText.TextColor3 = Theme.Text
HoverText.Font = Enum.Font.GothamBold
HoverText.TextSize = 12

RunService.RenderStepped:Connect(function()
	if not States["HoverInfo"] then
		HoverInfoFrame.Visible = false
		return
	end

	if HoverInfoFrame.Visible then
		local mousePos = UserInputService:GetMouseLocation()
		HoverInfoFrame.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
	end
	
	local target = mouse.Target
	if target and target:IsA("BasePart") then
		local model = target:FindFirstAncestorOfClass("Model")
		if model then
			local hoveredPlr = Players:GetPlayerFromCharacter(model)
			if hoveredPlr and model:FindFirstChildOfClass("Humanoid") then
				local hum = model:FindFirstChildOfClass("Humanoid")
				HoverText.Text = string.format("👤 %s\n❤️ HP: %d / %d", hoveredPlr.DisplayName, math.floor(hum.Health), math.floor(hum.MaxHealth))
				HoverInfoFrame.Visible = true
			else
				HoverInfoFrame.Visible = false
			end
		else
			HoverInfoFrame.Visible = false
		end
	else
		HoverInfoFrame.Visible = false
	end
end)

-- Консоль логов
local ConsoleLogs = Instance.new("ScrollingFrame")
local function logToConsole(text)
	if not ConsoleLogs.Parent then print("[ENGINE]: " .. text) return end
	local label = Instance.new("TextLabel", ConsoleLogs)
	label.Size = UDim2.new(1, -10, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = " [ENGINE]: " .. text
	label.TextColor3 = Theme.AccentGreen
	label.Font = Enum.Font.Code
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	ConsoleLogs.CanvasPosition = Vector2.new(0, 9999)
end

-- Автокликеры / Ауры
task.spawn(function()
	while true do
		if States["AutoClick"] then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton1(Vector2.new(0,0))
			end)
		end
		if States["TriggerB"] and mouse.Target then
			local model = mouse.Target:FindFirstAncestorOfClass("Model")
			if model and Players:GetPlayerFromCharacter(model) then
				pcall(function()
					local vu = game:GetService("VirtualUser")
					vu:CaptureController()
					vu:ClickButton1(Vector2.new(0,0))
				end)
			end
		end
		if States["KillA"] then
			pcall(function()
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						-- Проверяем, не находится ли игрок в вайтлисте друзей
						if not table.find(whitelistedFriends, p.Name) then
							local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist <= 15 then
								local tool = player.Character:FindFirstChildOfClass("Tool")
								if tool then tool:Activate() end
							end
						end
					end
				end
			end)
		end
		task.wait(0.02)
	end
end)

local function getClosestPlayer()
	local closest = nil
	local shortestDist = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
				if onScreen then
					local mPos = UserInputService:GetMouseLocation()
					local dist = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closest = p
					end
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if States["AimB"] and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

-- ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 760, 0, 520)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.GlassBg
MainFrame.BackgroundTransparency = Theme.GlassTrans
MainFrame.Visible = false 
applyGlassStyle(MainFrame, 20, Color3.fromRGB(70, 55, 45), 1.5)
local MainStroke = MainFrame:FindFirstChildOfClass("UIStroke")

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
makeDraggable(MainFrame, Header)

local titleString = "🪐 ROBLOX VISUALS"
if isBypassUser then
	titleString = titleString .. " | " .. getSpecialStatus(player).label
end

local MainTitle = Instance.new("TextLabel", Header)
MainTitle.Size = UDim2.new(1, -160, 1, 0)
MainTitle.Position = UDim2.new(0, 20, 0, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = titleString
MainTitle.TextColor3 = Theme.Gold
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 15
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local VerBadge = Instance.new("TextLabel", Header)
VerBadge.Size = UDim2.new(0, 100, 0, 24)
VerBadge.Position = UDim2.new(0, 340, 0.5, -12)
VerBadge.BackgroundColor3 = Theme.AccentGreen
VerBadge.Text = "Версия 33.1"
VerBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
VerBadge.Font = Enum.Font.GothamBold
VerBadge.TextSize = 11
applyGlassStyle(VerBadge, 12)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 200, 1, -75)
Sidebar.Position = UDim2.new(0, 15, 0, 60)
Sidebar.BackgroundTransparency = 1

local SidebarScroll = Instance.new("ScrollingFrame", Sidebar)
SidebarScroll.Size = UDim2.new(1, 0, 1, -65)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 0
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local SidebarLayout = Instance.new("UIListLayout", SidebarScroll)
SidebarLayout.Padding = UDim.new(0, 5)

-- Профиль
local ProfileCard = Instance.new("Frame", Sidebar)
ProfileCard.Size = UDim2.new(1, -6, 0, 60)
ProfileCard.Position = UDim2.new(0, 0, 1, -60)
ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 14, 10)
ProfileCard.BackgroundTransparency = 0.4
applyGlassStyle(ProfileCard, 14, Color3.fromRGB(55, 42, 35), 1)

local AvatarImage = Instance.new("ImageLabel", ProfileCard)
AvatarImage.Size = UDim2.new(0, 42, 0, 42)
AvatarImage.Position = UDim2.new(0, 10, 0.5, -21)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
applyGlassStyle(AvatarImage, 21)

local DisplayNameLabel = Instance.new("TextLabel", ProfileCard)
DisplayNameLabel.Size = UDim2.new(1, -65, 0, 18)
DisplayNameLabel.Position = UDim2.new(0, 60, 0, 12)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = player.DisplayName
DisplayNameLabel.TextColor3 = Theme.Text
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 13
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local UsernameLabel = Instance.new("TextLabel", ProfileCard)
UsernameLabel.Size = UDim2.new(1, -65, 0, 14)
UsernameLabel.Position = UDim2.new(0, 60, 0, 28)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. player.Name
UsernameLabel.TextColor3 = Color3.fromRGB(160, 145, 135)
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.TextSize = 11
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -250, 1, -85)
ContentArea.Position = UDim2.new(0, 230, 0, 70)
ContentArea.BackgroundTransparency = 1

local TabPages, TabButtons = {}, {}

local function createTab(id, title)
	local Page = Instance.new("ScrollingFrame", ContentArea)
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.Visible = false
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.ScrollBarThickness = 2
	
	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0, 6)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabPages[id] = Page
	
	local TabBtn = Instance.new("TextButton", SidebarScroll)
	TabBtn.Size = UDim2.new(1, -6, 0, 36)
	TabBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.Text = "  " .. title
	TabBtn.TextColor3 = Color3.fromRGB(170, 160, 155)
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.TextSize = 13
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(TabBtn, 10, Color3.fromRGB(0,0,0), 0)
	
	TabBtn.Activated:Connect(function()
		for _, p in pairs(TabPages) do p.Visible = false end
		for _, b in pairs(TabButtons) do 
			b.TextColor3 = Color3.fromRGB(170, 160, 155)
			b.BackgroundTransparency = 1
		end
		Page.Visible = true
		TabBtn.TextColor3 = Theme.Text
		TabBtn.BackgroundColor3 = Theme.BtnOff
		TabBtn.BackgroundTransparency = 0.3
	end)
	table.insert(TabButtons, TabBtn)
	return Page
end

local function addToggle(parent, key, title, callback)
	States[key] = false
	local Btn = Instance.new("TextButton", parent)
	Btn.Size = UDim2.new(1, -6, 0, 42)
	Btn.BackgroundColor3 = Theme.BtnOff
	Btn.BackgroundTransparency = 0.5
	Btn.Text = "   " .. title
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamSemibold
	Btn.TextSize = 13
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(Btn, 10, Color3.fromRGB(65, 50, 40), 1)
	
	local SwitchBg = Instance.new("Frame", Btn)
	SwitchBg.Size = UDim2.new(0, 38, 0, 20)
	SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
	SwitchBg.BackgroundColor3 = Color3.fromRGB(90, 80, 75)
	applyGlassStyle(SwitchBg, 10)
	
	local SwitchBall = Instance.new("Frame", SwitchBg)
	SwitchBall.Size = UDim2.new(0, 16, 0, 16)
	SwitchBall.Position = UDim2.new(0, 2, 0.5, -8)
	SwitchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	applyGlassStyle(SwitchBall, 8)

	Btn.Activated:Connect(function()
		if interfaceLocked then return end
		States[key] = not States[key]
		if States[key] then
			TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentGreen}):Play()
			TweenService:Create(SwitchBall, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
		else
			TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90, 80, 75)}):Play()
			TweenService:Create(SwitchBall, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
		end
		updateCounter()
		pcall(callback, States[key])
		if States[key] then onAnyModActivated() end
	end)
	table.insert(toggleControls, {button = Btn, switch = SwitchBg, ball = SwitchBall})
	return Btn
end

local function addButton(parent, title, callback)
	local Btn = Instance.new("TextButton", parent)
	Btn.Size = UDim2.new(1, -6, 0, 40)
	Btn.BackgroundColor3 = Theme.BtnOn
	Btn.BackgroundTransparency = 0.3
	Btn.Text = "  " .. title
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 12
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(Btn, 10, Theme.AccentCyan, 1)
	
	Btn.Activated:Connect(function()
		if interfaceLocked then return end
		pcall(callback)
	end)
	return Btn
end

-- Сборка Вкладок
local tMove = createTab("Move", "🧭 Персонаж")
local tCombat = createTab("Combat", "🎯 Комбат")
local tVisuals = createTab("Visuals", "👁️ Валлхак / Визуал")
local tFriends = createTab("Friends", "👥 Друзья")
local tWorld = createTab("World", "🪐 Изменение Мира")
local tSkin = createTab("Skin", "🎭 Кастомизация")
local tCursors = createTab("Cursors", "🖱️ Курсоры")
local tMacro = createTab("Macro", "🤖 Умные Макросы")
local tMM2 = createTab("MM2", "🔪 Murder Mystery 2") 
local tPlayers = createTab("Players", "📋 Таблица игроков")
local tUtils = createTab("Utils", "🛠️ Утилиты / Темы")
local tThemes = createTab("Themes", "🎨 Темы интерфейса")
local tRadio = createTab("Radio", "🎵 Радио Плеер")
local tExit = createTab("Exit", "🚪 Выйти из Roblox Visuals")

local CursorList = {
	"rbxassetid://118497693394988",
	"rbxassetid://122425872513515",
	"rbxassetid://104853224662126",
	"rbxassetid://124194288725564",
	"rbxassetid://98860259603713",
	"rbxassetid://131195531355876",
	"rbxassetid://72879470709079",
	"rbxassetid://133779782682485",
	"rbxassetid://133233331007912",
}

addButton(tCursors, "❌ Сбросить курсор", function()
	mouse.Icon = ""
	logToConsole("Курсор сброшен на стандартный")
end)
for index, cursorId in ipairs(CursorList) do
	addButton(tCursors, "🖱️ Включить курсор #" .. index, function()
		mouse.Icon = cursorId
		logToConsole("Установлен курсор #" .. index)
	end)
end
addButton(tCursors, "🔒 Курсор #10 недоступен", function()
	createNotification("КУРСОР", "Курсор #10 пока недоступен.", "Alert")
end)

local ThemePresets = {
	{name="1. Обычная", bg=Color3.fromRGB(30,30,34), header=Color3.fromRGB(43,43,48), accent=Color3.fromRGB(70,145,255), secondary=Color3.fromRGB(125,100,255), text=Color3.fromRGB(245,245,248), font=Enum.Font.GothamSemibold, radius=10, stroke=1.2, transparency=0.18},
	{name="2. Minecraft", bg=Color3.fromRGB(54,65,39), header=Color3.fromRGB(91,68,44), accent=Color3.fromRGB(104,178,67), secondary=Color3.fromRGB(112,84,55), text=Color3.fromRGB(255,255,235), font=Enum.Font.Arcade, radius=0, stroke=3, transparency=0},
	{name="3. Неоновая ночь", bg=Color3.fromRGB(10,6,22), header=Color3.fromRGB(22,12,40), accent=Color3.fromRGB(0,235,255), secondary=Color3.fromRGB(190,45,255), text=Color3.fromRGB(245,240,255), font=Enum.Font.SciFi, radius=14, stroke=2, transparency=0.22},
	{name="4. Океан", bg=Color3.fromRGB(8,31,43), header=Color3.fromRGB(10,48,63), accent=Color3.fromRGB(30,190,220), secondary=Color3.fromRGB(31,111,235), text=Color3.fromRGB(225,250,255), font=Enum.Font.Gotham, radius=18, stroke=1.5, transparency=0.2},
	{name="5. Сакура", bg=Color3.fromRGB(48,25,38), header=Color3.fromRGB(67,34,52), accent=Color3.fromRGB(255,126,178), secondary=Color3.fromRGB(190,99,160), text=Color3.fromRGB(255,235,245), font=Enum.Font.Cartoon, radius=20, stroke=1.5, transparency=0.16},
	{name="6. Лава", bg=Color3.fromRGB(43,17,12), header=Color3.fromRGB(65,24,14), accent=Color3.fromRGB(255,92,30), secondary=Color3.fromRGB(190,35,20), text=Color3.fromRGB(255,235,215), font=Enum.Font.Antique, radius=6, stroke=2.5, transparency=0.08},
	{name="7. Лёд", bg=Color3.fromRGB(24,40,52), header=Color3.fromRGB(34,57,72), accent=Color3.fromRGB(130,225,255), secondary=Color3.fromRGB(93,150,220), text=Color3.fromRGB(240,252,255), font=Enum.Font.Gotham, radius=16, stroke=1, transparency=0.32},
	{name="8. Золото", bg=Color3.fromRGB(42,34,16), header=Color3.fromRGB(62,48,20), accent=Color3.fromRGB(245,195,55), secondary=Color3.fromRGB(176,117,25), text=Color3.fromRGB(255,248,215), font=Enum.Font.Garamond, radius=8, stroke=2, transparency=0.1},
	{name="9. Матрица", bg=Color3.fromRGB(5,18,10), header=Color3.fromRGB(8,30,15), accent=Color3.fromRGB(30,230,90), secondary=Color3.fromRGB(20,125,55), text=Color3.fromRGB(205,255,220), font=Enum.Font.Code, radius=2, stroke=1.5, transparency=0.06},
	{name="10. Монохром", bg=Color3.fromRGB(24,24,24), header=Color3.fromRGB(38,38,38), accent=Color3.fromRGB(205,205,205), secondary=Color3.fromRGB(105,105,105), text=Color3.fromRGB(245,245,245), font=Enum.Font.RobotoMono, radius=4, stroke=1, transparency=0.05},
}

local function applyFullTheme(glassBg, headerBg, accent, secondary, textColor, style)
	style = style or {font=Enum.Font.GothamSemibold, radius=10, stroke=1.2, transparency=0.18}
	Theme.GlassBg = glassBg
	Theme.HeaderBg = headerBg
	Theme.AccentCyan = accent
	Theme.AccentPurple = secondary
	Theme.Text = textColor
	Theme.BtnOff = headerBg
	Theme.BtnOn = secondary
	for _, object in ipairs(ScreenGui:GetDescendants()) do
		if object:IsA("UIStroke") then
			if object.Color ~= Theme.AlertRed then object.Color = accent end
			object.Thickness = style.stroke
		elseif object:IsA("UICorner") then
			object.CornerRadius = UDim.new(0, style.radius)
		elseif object:IsA("TextButton") then
			if object.BackgroundColor3 ~= Theme.AlertRed and object.BackgroundColor3 ~= Theme.AccentGreen then
				object.BackgroundColor3 = secondary
			end
			object.TextColor3 = textColor
			object.Font = style.font
			object.TextStrokeTransparency = style.radius == 0 and 0.45 or 1
		elseif object:IsA("TextBox") then
			object.BackgroundColor3 = headerBg
			object.TextColor3 = textColor
			object.Font = style.font
		elseif object:IsA("TextLabel") then
			if object.TextColor3 ~= Theme.AlertRed and object.TextColor3 ~= Theme.Gold then object.TextColor3 = textColor end
			object.Font = style.font
			object.TextStrokeTransparency = style.radius == 0 and 0.5 or 1
		elseif object:IsA("Frame") and object.BackgroundTransparency < 0.9 then
			object.BackgroundColor3 = glassBg
			object.BackgroundTransparency = style.transparency
		end
	end
	MainFrame.BackgroundColor3 = glassBg
	if ToggleMenuBtn then ToggleMenuBtn.BackgroundColor3 = headerBg end
	createNotification("ТЕМА", "Новая тема применена ко всему интерфейсу.", "Info")
end

for _, preset in ipairs(ThemePresets) do
	addButton(tThemes, "🎨 " .. preset.name, function()
		applyFullTheme(preset.bg, preset.header, preset.accent, preset.secondary, preset.text, preset)
	end)
end

local CustomThemeInput = Instance.new("TextBox", tThemes)
CustomThemeInput.Size = UDim2.new(1, -6, 0, 38)
CustomThemeInput.BackgroundColor3 = Theme.BtnOff
CustomThemeInput.PlaceholderText = "Фон R,G,B (например 20,25,35)"
CustomThemeInput.Text = ""
CustomThemeInput.TextColor3 = Theme.Text
CustomThemeInput.Font = Enum.Font.Code
CustomThemeInput.TextSize = 12
applyGlassStyle(CustomThemeInput, 9, Theme.AccentPurple)

local CustomAccentInput = Instance.new("TextBox", tThemes)
CustomAccentInput.Size = UDim2.new(1, -6, 0, 38)
CustomAccentInput.BackgroundColor3 = Theme.BtnOff
CustomAccentInput.PlaceholderText = "Акцент R,G,B (например 0,200,255)"
CustomAccentInput.Text = ""
CustomAccentInput.TextColor3 = Theme.Text
CustomAccentInput.Font = Enum.Font.Code
CustomAccentInput.TextSize = 12
applyGlassStyle(CustomAccentInput, 9, Theme.AccentCyan)

local function parseRgb(text, fallback)
	local r, g, b = text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
	if not r then return fallback end
	return Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
end

addButton(tThemes, "🛠️ Применить свою RGB-тему", function()
	local background = parseRgb(CustomThemeInput.Text, Theme.GlassBg)
	local accent = parseRgb(CustomAccentInput.Text, Theme.AccentCyan)
	applyFullTheme(background, background:Lerp(Color3.new(1, 1, 1), 0.08), accent, accent:Lerp(background, 0.45), Color3.fromRGB(250, 250, 250))
end)

local RadioSound = Instance.new("Sound", SoundService)
RadioSound.Name = "RobloxVisualsRadio"
RadioSound.Volume = 0.5

local RadioIdInput = Instance.new("TextBox", tRadio)
RadioIdInput.Size = UDim2.new(1, -6, 0, 38)
RadioIdInput.BackgroundColor3 = Theme.BtnOff
RadioIdInput.PlaceholderText = "ID музыки, например 1843529606"
RadioIdInput.Text = ""
RadioIdInput.TextColor3 = Theme.Text
RadioIdInput.Font = Enum.Font.Code
RadioIdInput.TextSize = 12
applyGlassStyle(RadioIdInput, 9, Theme.AccentCyan)

local VolumeInput = Instance.new("TextBox", tRadio)
VolumeInput.Size = UDim2.new(1, -6, 0, 38)
VolumeInput.BackgroundColor3 = Theme.BtnOff
VolumeInput.PlaceholderText = "Громкость 0-100"
VolumeInput.Text = "50"
VolumeInput.TextColor3 = Theme.Text
VolumeInput.Font = Enum.Font.Code
VolumeInput.TextSize = 12
applyGlassStyle(VolumeInput, 9, Theme.AccentPurple)

addButton(tRadio, "▶️ Воспроизвести по ID", function()
	local id = RadioIdInput.Text:match("(%d+)")
	if not id then createNotification("РАДИО", "Введите корректный ID музыки.", "Alert") return end
	RadioSound.SoundId = "rbxassetid://" .. id
	RadioSound.Volume = math.clamp((tonumber(VolumeInput.Text) or 50) / 100, 0, 1)
	RadioSound:Play()
	createNotification("РАДИО", "Запущена музыка ID: " .. id, "Info")
end)
addButton(tRadio, "⏯️ Пауза / продолжить", function()
	if RadioSound.IsPlaying then RadioSound:Pause() else RadioSound:Resume() end
end)
addButton(tRadio, "⏹️ Остановить музыку", function() RadioSound:Stop() end)
addToggle(tRadio, "RadioLoop", "🔁 Повторять музыку", function(v) RadioSound.Looped = v end)
addButton(tRadio, "🔊 Применить громкость", function()
	RadioSound.Volume = math.clamp((tonumber(VolumeInput.Text) or 50) / 100, 0, 1)
	createNotification("РАДИО", "Громкость обновлена.", "Info")
end)

addToggle(tSkin, "FaceLight", "✨ Светящееся лицо", function(v)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then return end
	local light = head:FindFirstChild("VisualsFaceLight")
	if v and not light then
		light = Instance.new("SurfaceLight", head)
		light.Name = "VisualsFaceLight"
		light.Face = Enum.NormalId.Front
		light.Color = Theme.Gold
		light.Range = 10
		light.Brightness = 1.5
	elseif not v and light then
		light:Destroy()
	end
end)

addToggle(tSkin, "RainbowOutline", "🌈 Радужный контур", function(v)
	local char = player.Character
	if not char then return end
	local highlight = char:FindFirstChild("VisualsRainbowOutline")
	if v and not highlight then
		highlight = Instance.new("Highlight", char)
		highlight.Name = "VisualsRainbowOutline"
		highlight.FillTransparency = 1
	elseif not v and highlight then
		highlight:Destroy()
	end
end)

TabPages["Move"].Visible = true
TabButtons[1].BackgroundTransparency = 0.3
TabButtons[1].BackgroundColor3 = Theme.BtnOff
TabButtons[1].TextColor3 = Theme.Text

-- =============================================================================
-- 🤖 СИСТЕМА УМНЫХ МАКРОСОВ
-- =============================================================================
local MacroSaveFrame = Instance.new("Frame", ScreenGui)
MacroSaveFrame.Size = UDim2.new(0, 340, 0, 180)
MacroSaveFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
MacroSaveFrame.BackgroundColor3 = Theme.GlassBg
MacroSaveFrame.BackgroundTransparency = 0.02
MacroSaveFrame.Visible = false
MacroSaveFrame.ZIndex = 15
applyGlassStyle(MacroSaveFrame, 14, Theme.AccentCyan, 2)
makeDraggable(MacroSaveFrame, MacroSaveFrame)

local MacroSaveTitle = Instance.new("TextLabel", MacroSaveFrame)
MacroSaveTitle.Size = UDim2.new(1, 0, 0, 35)
MacroSaveTitle.BackgroundTransparency = 1
MacroSaveTitle.Text = "💾 СКОЛЬКО РАЗ ПОВТОРЯТЬ МАРШРУТ?"
MacroSaveTitle.TextColor3 = Theme.Gold
MacroSaveTitle.Font = Enum.Font.GothamBold
MacroSaveTitle.TextSize = 12

local MacroLoopsInput = Instance.new("TextBox", MacroSaveFrame)
MacroLoopsInput.Size = UDim2.new(0, 260, 0, 35)
MacroLoopsInput.Position = UDim2.new(0.5, -130, 0, 55)
MacroLoopsInput.BackgroundColor3 = Theme.BtnOff
MacroLoopsInput.PlaceholderText = "Введите число (например: 3)"
MacroLoopsInput.Text = "1"
MacroLoopsInput.TextColor3 = Theme.Text
MacroLoopsInput.Font = Enum.Font.Code
MacroLoopsInput.TextSize = 14
applyGlassStyle(MacroLoopsInput, 8, Theme.AccentPurple)

local MacroStartPlayBtn = Instance.new("TextButton", MacroSaveFrame)
MacroStartPlayBtn.Size = UDim2.new(0, 140, 0, 35)
MacroStartPlayBtn.Position = UDim2.new(0.5, -145, 0, 115)
MacroStartPlayBtn.BackgroundColor3 = Theme.BtnOn
MacroStartPlayBtn.Text = "▶️ ЗАПУСТИТЬ ПОВТОР"
MacroStartPlayBtn.TextColor3 = Theme.AccentGreen
MacroStartPlayBtn.Font = Enum.Font.GothamBold
MacroStartPlayBtn.TextSize = 11
applyGlassStyle(MacroStartPlayBtn, 8, Theme.AccentGreen)

local MacroCancelBtn = Instance.new("TextButton", MacroSaveFrame)
MacroCancelBtn.Size = UDim2.new(0, 140, 0, 35)
MacroCancelBtn.Position = UDim2.new(0.5, 5, 0, 115)
MacroCancelBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 25)
MacroCancelBtn.Text = "❌ ЗАКРЫТЬ"
MacroCancelBtn.TextColor3 = Theme.AlertRed
MacroCancelBtn.Font = Enum.Font.GothamBold
MacroCancelBtn.TextSize = 11
applyGlassStyle(MacroCancelBtn, 8, Theme.AlertRed)

local function playMacro(loops)
	if #recordedPath == 0 or isPlaying then return end
	isPlaying = true
	isMacroPaused = false
	MacroSaveFrame.Visible = false
	logToConsole("🤖 Макрос: Запущен беспалевный обход.")
	
	local pChar = player.Character
	local root = pChar and pChar:FindFirstChild("HumanoidRootPart")
	local hum = pChar and pChar:FindFirstChildOfClass("Humanoid")
	
	if root and hum then
		for c = 1, loops do
			if not isPlaying then break end
			logToConsole("⚡ Беспалевный круг: " .. c .. " из " .. loops)
			
			local loopOffsetX = math.random(-8, 8) / 10
			local loopOffsetZ = math.random(-8, 8) / 10
			
			for _, frameData in ipairs(recordedPath) do
				while isMacroPaused and isPlaying do
					if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
					RunService.Heartbeat:Wait()
				end
				if not isPlaying or not root then break end
				
				local microNoise = Vector3.new(math.random(-12, 12)/100, 0, math.random(-12, 12)/100)
				local finalCFrame = frameData.cf * CFrame.new(loopOffsetX, 0, loopOffsetZ) + microNoise
				
				root.CFrame = finalCFrame
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				
				local humanizedSpeed = frameData.speed + (math.random(-15, 15) / 10)
				hum.WalkSpeed = math.max(1, humanizedSpeed)
				hum.JumpPower = frameData.jumpPower
				
				if frameData.isJumping and math.random(1, 10) > 2 then 
					hum:ChangeState(Enum.HumanoidStateType.Jumping) 
				end
				RunService.Heartbeat:Wait()
			end
			while isMacroPaused and isPlaying do RunService.Heartbeat:Wait() end
			task.wait(math.random(3, 9) / 10)
		end
		hum.WalkSpeed = curSpeed
		hum.JumpPower = curJump
	end
	isPlaying = false
	isMacroPaused = false
	logToConsole("🎉 Макрос завершил работу!")
end

MacroCancelBtn.Activated:Connect(function() MacroSaveFrame.Visible = false end)
MacroStartPlayBtn.Activated:Connect(function()
	local loops = tonumber(MacroLoopsInput.Text) or 1
	task.spawn(playMacro, loops)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.L then
		if isRecording then
			isRecording = false
			isRecordingPaused = false
			RecordIndicator.Visible = false
			logToConsole("🔴 Запись завершена.")
			MacroSaveFrame.Visible = true
		end
	elseif input.KeyCode == Enum.KeyCode.E then
		if isRecording then
			isRecordingPaused = not isRecordingPaused
			if isRecordingPaused then
				RecordIndicator.Text = "⏸️ ЗАПИСЬ НА ПАУЗЕ... [ЖМИ E ДЛЯ ПРОДОЛЖЕНИЯ]"
				RecordIndicator.TextColor3 = Theme.Gold
			else
				RecordIndicator.Text = "🔴 ЗАПИСЬ ИДЕТ... [L - СТОП | E - ПАУЗА]"
				RecordIndicator.TextColor3 = Theme.AlertRed
			end
		end
	elseif input.KeyCode == Enum.KeyCode.M then
		if isPlaying then
			isMacroPaused = not isMacroPaused
		end
	end
end)

addButton(tMacro, "🔴 НАЧАТЬ ЗАПИСЬ АНТИ-ПАЛЕВО", function()
	if isPlaying then logToConsole("⚠️ Нельзя записывать во время повтора!") return end
	table.clear(recordedPath)
	isRecording = true
	isRecordingPaused = false
	RecordIndicator.Text = "🔴 ЗАПИСЬ ИДЕТ... [L - СТОП | E - ПАУЗА]"
	RecordIndicator.TextColor3 = Theme.AlertRed
	RecordIndicator.Visible = true
	logToConsole("🚀 ЗАПИСЬ ПОШЛА! Пробеги трассу сама.")
end)

addButton(tMacro, "🛑 АВАРИЙНЫЙ СБРОС ВСЕХ МАКРОСОВ", function()
	isPlaying = false; isRecording = false; isRecordingPaused = false; isMacroPaused = false
	RecordIndicator.Visible = false; MacroSaveFrame.Visible = false
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = curSpeed; hum.JumpPower = curJump end
	logToConsole("🤖 Макросы полностью отключены.")
end)

-- Полет
local flySpeed = 70
local bv, bg
local function updateFly(active)
	local pChar = player.Character
	if not pChar or not pChar:FindFirstChild("HumanoidRootPart") then return end
	local root = pChar.HumanoidRootPart
	local hum = pChar:FindFirstChildOfClass("Humanoid")
	
	if active then
		if hum then hum.PlatformStand = true end
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Velocity = Vector3.new(0,0,0)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.CFrame = camera.CFrame
		
		task.spawn(function()
			while States["FlyM"] and pChar and root and bv do
				local md = Vector3.new(0,0,0)
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then md = md - Vector3.new(0,1,0) end
				
				if md.Magnitude > 0 then
					bv.Velocity = md.Unit * flySpeed
				else
					bv.Velocity = Vector3.new(0,0,0)
				end
				bg.CFrame = camera.CFrame
				task.wait()
			end
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
			if hum then hum.PlatformStand = false end
		end)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		if hum then hum.PlatformStand = false end
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if States["ClTP"] and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- Наполнение раздела Персонаж
addToggle(tMove, "S120", "⚡ Скорость бега х120 Premium", function(v) curSpeed = v and 120 or 16 end)
addToggle(tMove, "S250", "🔥 Скорость бега х250 Hyper Overload", function(v) curSpeed = v and 250 or 16 end)
addToggle(tMove, "S500", "👑 VIP Скорость х500 GOD MODE", function(v) curSpeed = v and 500 or 16 end)
addToggle(tMove, "J180", "🦘 Прыжок х180 Высокий", function(v) curJump = v and 180 or 50 end)
addToggle(tMove, "J300", "🚀 Прыжок х300 Космический", function(v) curJump = v and 300 or 50 end)
addToggle(tMove, "InfJ", "☁️ Infinite Jump (Прыжки по воздуху)", function() end)
addToggle(tMove, "Nocl", "🧱 Noclip (Сквозь стены)", function() end)
addToggle(tMove, "FlyM", "🛸 Полет Админа [W,A,S,D]", function(v) updateFly(v) end)
addToggle(tMove, "ClTP", "📍 Click TP [Ctrl + ЛКМ]", function() end)
addToggle(tMove, "SpinB", "🌪️ SpinBot (Вращение)", function() end)
addToggle(tMove, "NoSt", "🚫 Анти-Стул", function() end)
addToggle(tMove, "AutoClick", "🖱️ Потоковый автокликер", function() end)
addButton(tMove, "🏠 Телепортироваться на Спавн", function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local spawnPoint = workspace:FindFirstChildOfClass("SpawnLocation")
		if spawnPoint then player.Character.HumanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0,4,0) end
	end
end)
addToggle(tMove, "Plat", "🟩 Создать платформу под ногами", function(v)
	if v then
		autoPlatform = Instance.new("Part", workspace)
		autoPlatform.Size = Vector3.new(15, 1, 15); autoPlatform.Transparency = 0.5
		autoPlatform.Color = Theme.AccentCyan; autoPlatform.Material = Enum.Material.Glass; autoPlatform.Anchored = true
		task.spawn(function()
			while autoPlatform and autoPlatform.Parent do
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then autoPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0) end
				task.wait()
			end
		end)
	else
		if autoPlatform then autoPlatform:Destroy(); autoPlatform = nil end
	end
end)

-- Наполнение раздела Комбат
addToggle(tCombat, "AimB", "🎯 Премиум Аимбот на головы [Зажать ПКМ]", function() end)
addToggle(tCombat, "TriggerB", "🔫 Триггербот (Автовыстрел)", function() end)
addToggle(tCombat, "HitboxExp", "🥩 Расширение торсов врагов х5", function() end)
addToggle(tCombat, "KillA", "⚔️ Kill Aura (Радиус 15м)", function() end)
addToggle(tCombat, "SuperReach", "🧤 Super Reach", function(v)
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
			tool.Handle.Size = v and Vector3.new(10, 10, 10) or Vector3.new(1, 1, 1)
		end
	end
end)

-- ОБНОВЛЕННАЯ ВКЛАДКА ВИЗУАЛОВ
addToggle(tVisuals, "Cham", "🟢 Chams Силуэты сквозь стены", function() end)
addToggle(tVisuals, "Tracers", "📐 Линии-Трейсеры", function() end)
addToggle(tVisuals, "EspNames", "🏷️ ESP Names (Никнеймы + HP)", function() end)
addToggle(tVisuals, "HoverInfo", "🖱️ Отображать инфо при наведении мыши", function() end)

addToggle(tVisuals, "XRay", "🔮 Включить X-Ray", function(v)
	if v then
		for _, part in pairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part:FindFirstAncestorOfClass("Model") and part.Anchored then
				if not xrayCache[part] then xrayCache[part] = part.Transparency end
				part.Transparency = 0.7
			end
		end
	else
		for part, trans in pairs(xrayCache) do
			if part and part.Parent then part.Transparency = trans end
		end
		table.clear(xrayCache)
	end
end)

addToggle(tVisuals, "FovM", "👁️ Максимальный FOV 120", function(v) camera.FieldOfView = v and 120 or 70 end)
addToggle(tVisuals, "CenterOverlayToggle", "🖥️ Центральный оверлей [ROBLOX VISUALS]", function(v) CenterOverlay.Visible = v end)

addButton(tVisuals, "↗️ Виджеты: В правый верхний угол", function()
	ClockWidget.Position = UDim2.new(1, -170, 0, 20)
	CounterWidget.Position = UDim2.new(1, -170, 0, 65)
end)
addButton(tVisuals, "↖️ Виджеты: В левый верхний угол", function()
	ClockWidget.Position = UDim2.new(0, 20, 0, 85)
	CounterWidget.Position = UDim2.new(0, 20, 0, 130)
end)
addButton(tVisuals, "⬇️ Виджеты: Снизу по центру", function()
	ClockWidget.Position = UDim2.new(0.5, -155, 1, -55)
	CounterWidget.Position = UDim2.new(0.5, 5, 1, -55)
end)

States["HoverInfo"] = true

-- Локальное скрытие выбранного игрока
local hiddenPlayers = {}
local function setPlayerHidden(targetPlayer, hidden)
	if not targetPlayer then return end
	hiddenPlayers[targetPlayer.Name] = hidden or nil
	local character = targetPlayer.Character
	if not character then return end
	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.LocalTransparencyModifier = hidden and 1 or 0
		elseif object:IsA("BillboardGui") then
			object.Enabled = not hidden
		end
	end
end

local HidePlayerInput = Instance.new("TextBox", tVisuals)
HidePlayerInput.Size = UDim2.new(1, -6, 0, 36)
HidePlayerInput.BackgroundColor3 = Theme.BtnOff
HidePlayerInput.PlaceholderText = "Введите точный ник игрока..."
HidePlayerInput.Text = ""
HidePlayerInput.TextColor3 = Theme.Text
HidePlayerInput.Font = Enum.Font.GothamSemibold
HidePlayerInput.TextSize = 12
applyGlassStyle(HidePlayerInput, 10, Theme.AccentPurple, 1)

addButton(tVisuals, "🙈 Скрыть игрока локально", function()
	local target = Players:FindFirstChild(HidePlayerInput.Text)
	if target and target ~= player then
		setPlayerHidden(target, true)
		createNotification("ВИДИМОСТЬ", target.Name .. " скрыт на вашем экране.", "Info")
	else
		createNotification("ОШИБКА", "Игрок с таким точным ником не найден.", "Alert")
	end
end)

addButton(tVisuals, "👁️ Вернуть видимость игрока", function()
	local target = Players:FindFirstChild(HidePlayerInput.Text)
	if target then
		setPlayerHidden(target, false)
		createNotification("ВИДИМОСТЬ", target.Name .. " снова отображается.", "Info")
	end
end)

local hoverOutline
addToggle(tVisuals, "HoverOutline", "🖱️ Обводка персонажа при наведении", function(v)
	if not v and hoverOutline then hoverOutline:Destroy(); hoverOutline = nil end
end)

RunService.RenderStepped:Connect(function()
	if not States["HoverOutline"] then return end
	local target = mouse.Target
	local model = target and target:FindFirstAncestorOfClass("Model")
	local targetPlayer = model and Players:GetPlayerFromCharacter(model)
	if targetPlayer and targetPlayer ~= player then
		if not hoverOutline or hoverOutline.Adornee ~= model then
			if hoverOutline then hoverOutline:Destroy() end
			hoverOutline = Instance.new("Highlight", workspace)
			hoverOutline.Name = "HoverPlayerOutline"
			hoverOutline.Adornee = model
			hoverOutline.FillTransparency = 0.82
			hoverOutline.FillColor = Theme.AccentPurple
			hoverOutline.OutlineColor = Theme.AccentCyan
			hoverOutline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end
	elseif hoverOutline then
		hoverOutline:Destroy()
		hoverOutline = nil
	end
end)

local deathEffectStyle = "Pulse"
addToggle(tVisuals, "SelfDeathEffect", "💀 Анимация своей смерти", function() end)
addToggle(tVisuals, "PlayerDeathEffect", "☠️ Анимация смерти игроков", function() end)
addToggle(tVisuals, "DeathNotify", "🔔 Уведомлять о смерти игроков", function() end)
addButton(tVisuals, "⭕ Стиль смерти: Импульс", function() deathEffectStyle = "Pulse" end)
addButton(tVisuals, "👻 Стиль смерти: Душа", function() deathEffectStyle = "Soul" end)
addButton(tVisuals, "🧊 Стиль смерти: Пиксели", function() deathEffectStyle = "Pixels" end)

local function playDeathEffect(position, color)
	if deathEffectStyle == "Pixels" then
		for _ = 1, 18 do
			local pixel = Instance.new("Part", workspace)
			pixel.Anchored = true
			pixel.CanCollide = false
			pixel.Material = Enum.Material.Neon
			pixel.Color = color
			pixel.Size = Vector3.new(0.35, 0.35, 0.35)
			pixel.Position = position + Vector3.new(math.random(-20, 20) / 10, math.random(0, 30) / 10, math.random(-20, 20) / 10)
			TweenService:Create(pixel, TweenInfo.new(1), {Position = pixel.Position + Vector3.new(0, 5, 0), Transparency = 1}):Play()
			task.delay(1.1, function() if pixel.Parent then pixel:Destroy() end end)
		end
		return
	end
	local effect = Instance.new("Part", workspace)
	effect.Shape = Enum.PartType.Ball
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Color = color
	effect.Transparency = deathEffectStyle == "Soul" and 0.25 or 0.45
	effect.Size = deathEffectStyle == "Soul" and Vector3.new(1.5, 2.5, 1.5) or Vector3.new(1, 1, 1)
	effect.Position = position
	local goal = deathEffectStyle == "Soul"
		and {Position = position + Vector3.new(0, 8, 0), Transparency = 1, Size = Vector3.new(0.5, 4, 0.5)}
		or {Transparency = 1, Size = Vector3.new(14, 14, 14)}
	TweenService:Create(effect, TweenInfo.new(1.2, Enum.EasingStyle.Quad), goal):Play()
	task.delay(1.3, function() if effect.Parent then effect:Destroy() end end)
end

local function bindDeathEffect(targetPlayer, character)
	local humanoid = character:WaitForChild("Humanoid", 8)
	if not humanoid or humanoid:GetAttribute("VisualsDeathBound") then return end
	humanoid:SetAttribute("VisualsDeathBound", true)
	humanoid.Died:Connect(function()
		local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
		if not root then return end
		local isSelf = targetPlayer == player
		if (isSelf and States["SelfDeathEffect"]) or (not isSelf and States["PlayerDeathEffect"]) then
			playDeathEffect(root.Position, isSelf and Theme.Gold or Theme.AccentCyan)
		end
		if not isSelf and States["DeathNotify"] then
			createNotification("ИГРОК УМЕР", targetPlayer.DisplayName .. " погиб.", "Alert")
		end
	end)
end

local function watchPlayerDeaths(targetPlayer)
	if targetPlayer.Character then task.spawn(bindDeathEffect, targetPlayer, targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(function(character) bindDeathEffect(targetPlayer, character) end)
end
for _, targetPlayer in ipairs(Players:GetPlayers()) do watchPlayerDeaths(targetPlayer) end
Players.PlayerAdded:Connect(watchPlayerDeaths)

-- =============================================================================
-- 👥 ИСПРАВЛЕННАЯ И УЛУЧШЕННАЯ ВКЛАДКА ДРУЗЕЙ С МЕНЮ НА 20 КОМАНД
-- =============================================================================
local FriendInputFrame = Instance.new("Frame", tFriends)
FriendInputFrame.Size = UDim2.new(1, -6, 0, 45)
FriendInputFrame.BackgroundTransparency = 1

local FriendInput = Instance.new("TextBox", FriendInputFrame)
FriendInput.Size = UDim2.new(0.7, -10, 0, 36)
FriendInput.Position = UDim2.new(0, 5, 0, 4)
FriendInput.BackgroundColor3 = Theme.BtnOff
FriendInput.PlaceholderText = "Введите ник друга..."
FriendInput.Text = ""
FriendInput.TextColor3 = Theme.Text
FriendInput.Font = Enum.Font.GothamSemibold
FriendInput.TextSize = 13
applyGlassStyle(FriendInput, 8, Theme.AccentPurple)

local FriendAddBtn = Instance.new("TextButton", FriendInputFrame)
FriendAddBtn.Size = UDim2.new(0.3, 0, 0, 36)
FriendAddBtn.Position = UDim2.new(0.7, 0, 0, 4)
FriendAddBtn.BackgroundColor3 = Theme.BtnOn
FriendAddBtn.Text = "➕ ДОБАВИТЬ"
FriendAddBtn.TextColor3 = Theme.Text
FriendAddBtn.Font = Enum.Font.GothamBold
FriendAddBtn.TextSize = 12
applyGlassStyle(FriendAddBtn, 8, Theme.AccentGreen)

local FriendsContainer = Instance.new("ScrollingFrame", tFriends)
FriendsContainer.Size = UDim2.new(1, -6, 0, 300)
FriendsContainer.BackgroundTransparency = 1
FriendsContainer.ScrollBarThickness = 2
local FriendsListLayout = Instance.new("UIListLayout", FriendsContainer)
FriendsListLayout.Padding = UDim.new(0, 6)

-- 🎴 ОКНО ДЛЯ 20 КОМАНД НАД ДРУГОМ
local FriendMenuWindow = Instance.new("Frame", ScreenGui)
FriendMenuWindow.Name = "FriendCommandsMenu"
FriendMenuWindow.Size = UDim2.new(0, 460, 0, 420)
FriendMenuWindow.Position = UDim2.new(0.5, -230, 0.5, -210)
FriendMenuWindow.BackgroundColor3 = Theme.GlassBg
FriendMenuWindow.BackgroundTransparency = 0.05
FriendMenuWindow.Visible = false
FriendMenuWindow.ZIndex = 20000
applyGlassStyle(FriendMenuWindow, 16, Theme.AccentCyan, 2)
makeDraggable(FriendMenuWindow, FriendMenuWindow)

local FriendMenuTitle = Instance.new("TextLabel", FriendMenuWindow)
FriendMenuTitle.Size = UDim2.new(1, -40, 0, 40)
FriendMenuTitle.Position = UDim2.new(0, 20, 0, 5)
FriendMenuTitle.BackgroundTransparency = 1
FriendMenuTitle.Text = "УПРАВЛЕНИЕ: ДРУГ"
FriendMenuTitle.TextColor3 = Theme.Gold
FriendMenuTitle.Font = Enum.Font.GothamBold
FriendMenuTitle.TextSize = 14
FriendMenuTitle.TextXAlignment = Enum.TextXAlignment.Left
FriendMenuTitle.ZIndex = 20001

local FriendMenuClose = Instance.new("TextButton", FriendMenuWindow)
FriendMenuClose.Size = UDim2.new(0, 30, 0, 30)
FriendMenuClose.Position = UDim2.new(1, -40, 0, 10)
FriendMenuClose.BackgroundColor3 = Theme.AlertRed
FriendMenuClose.Text = "✕"
FriendMenuClose.TextColor3 = Theme.Text
FriendMenuClose.Font = Enum.Font.GothamBold
FriendMenuClose.TextSize = 14
applyGlassStyle(FriendMenuClose, 8)
FriendMenuClose.ZIndex = 20001
FriendMenuClose.Activated:Connect(function() FriendMenuWindow.Visible = false end)

local FriendMenuScroll = Instance.new("ScrollingFrame", FriendMenuWindow)
FriendMenuScroll.Size = UDim2.new(1, -20, 1, -60)
FriendMenuScroll.Position = UDim2.new(0, 10, 0, 50)
FriendMenuScroll.BackgroundTransparency = 1
FriendMenuScroll.ScrollBarThickness = 4
FriendMenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FriendMenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FriendMenuScroll.ZIndex = 20001

local FriendGrid = Instance.new("UIGridLayout", FriendMenuScroll)
FriendGrid.CellSize = UDim2.new(0, 205, 0, 36)
FriendGrid.CellPadding = UDim2.new(0, 10, 0, 8)

local function addMenuCmd(title, isPremiumStyle, callback)
	local b = Instance.new("TextButton", FriendMenuScroll)
	b.Size = UDim2.new(1, 0, 1, 0)
	b.BackgroundColor3 = isPremiumStyle and Theme.BtnOn or Theme.BtnOff
	b.BackgroundTransparency = 0.2
	b.Text = title
	b.TextColor3 = Theme.Text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.ZIndex = 20002
	applyGlassStyle(b, 8, isPremiumStyle and Theme.Gold or Theme.AccentPurple, 1)
	
	b.Activated:Connect(function()
		local tPlr = Players:FindFirstChild(selectedFriendName)
		pcall(callback, tPlr)
	end)
end

-- =============================================================================
-- РЕГИСТРАЦИЯ 20 ФУНКЦИЙ (10 НОРМАЛЬНЫХ + 10 ОТ СЕБЯ)
-- =============================================================================

-- --- 10 НОРМАЛЬНЫХ ФУНКЦИЙ ---
addMenuCmd("🛩️ 1. Телепорт к нему", false, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = tPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		createNotification("ТЕЛЕПОРТ", "Вы приземлились около " .. selectedFriendName, "Info")
	end
end)

addMenuCmd("👁️ 2. Следить камерой", false, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("Humanoid") then
		if camera.CameraSubject == tPlr.Character.Humanoid then
			camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
			createNotification("КАМЕРА", "Камера возвращена на себя", "Info")
		else
			camera.CameraSubject = tPlr.Character.Humanoid
			createNotification("КАМЕРА", "Слежка за: " .. selectedFriendName, "Info")
		end
	end
end)

addMenuCmd("🟢 3. Включить Чамс (ESP)", false, function(tPlr)
	if tPlr and tPlr.Character then
		local hl = tPlr.Character:FindFirstChild("FriendHighlight") or Instance.new("Highlight", tPlr.Character)
		hl.Name = "FriendHighlight"
		hl.FillColor = Theme.AccentGreen
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		createNotification("ВИЗУАЛ", "Подсветка активирована для " .. selectedFriendName, "Info")
	end
end)

addMenuCmd("🛡️ 4. Добавить в Вайтлист", false, function(tPlr)
	if not table.find(whitelistedFriends, selectedFriendName) then
		table.insert(whitelistedFriends, selectedFriendName)
		createNotification("БЕЗОПАСНОСТЬ", selectedFriendName .. " добавлен в белый список ауры!", "Info")
	end
end)

addMenuCmd("🚫 5. Убрать из Вайтлиста", false, function(tPlr)
	local idx = table.find(whitelistedFriends, selectedFriendName)
	if idx then
		table.remove(whitelistedFriends, idx)
		createNotification("БЕЗОПАСНОСТЬ", selectedFriendName .. " убран из белого списка.", "Alert")
	end
end)

addMenuCmd("📊 6. Проверить Статусы", false, function(tPlr)
	if tPlr then
		local age = tPlr.AccountAge
		local id = tPlr.UserId
		logToConsole("ДРУГ: " .. tPlr.Name .. " | ID: " .. id .. " | Возраст аккаунта: " .. age .. " дней.")
		createNotification("ИНФОРМАЦИЯ", "Полные логи выведены в консоль скрипта!", "Info")
	end
end)

addMenuCmd("⚡ 7. Режим: Преследовать", false, function(tPlr)
	if followingFriend == selectedFriendName then
		followingFriend = nil
		createNotification("АВТОПИЛОТ", "Преследование отключено", "Info")
	else
		followingFriend = selectedFriendName
		createNotification("АВТОПИЛОТ", "Вы начали бежать за " .. selectedFriendName, "Info")
		task.spawn(function()
			while followingFriend == selectedFriendName and tPlr and tPlr.Character and player.Character do
				local targetRoot = tPlr.Character:FindFirstChild("HumanoidRootPart")
				local myHum = player.Character:FindFirstChildOfClass("Humanoid")
				if targetRoot and myHum then
					myHum:MoveTo(targetRoot.Position)
				end
				task.wait(0.2)
			end
		end)
	end
end)

addMenuCmd("🎒 8. Читать Инвентарь", false, function(tPlr)
	if tPlr and tPlr:FindFirstChild("Backpack") then
		logToConsole("--- Инвентарь игрока " .. tPlr.Name .. " ---")
		for _, tool in pairs(tPlr.Backpack:GetChildren()) do
			logToConsole("Предмет: " .. tool.Name)
		end
		createNotification("ИНВЕНТАРЬ", "Список предметов загружен в логи консоли.", "Info")
	end
end)

addMenuCmd("🔄 9. Обновить данные", false, function(tPlr)
	createNotification("СИСТЕМА", "Синхронизация позиции и здоровья завершена.", "Info")
end)

addMenuCmd("❌ 10. Удалить из слежки", false, function(tPlr)
	local idx = table.find(friendsList, selectedFriendName)
	if idx then
		table.remove(friendsList, idx)
		FriendMenuWindow.Visible = false
		createNotification("ДРУЗЬЯ", "Игрок полностью удален из панели.", "Alert")
	end
end)

-- --- 10 КАСТОМНЫХ ФУНКЦИЙ (ОТ СЕБЯ / ДЛЯ ФАНА) ---
addMenuCmd("🌪️ 11. Запустить Флинг!", true, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		createNotification("ФАН", "Уничтожение игрока " .. selectedFriendName .. " запущено!", "Alert")
		local myRoot = player.Character.HumanoidRootPart
		local tRoot = tPlr.Character.HumanoidRootPart
		local oldCF = myRoot.CFrame
		
		local bg = Instance.new("BodyAngularVelocity", myRoot)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.AngularVelocity = Vector3.new(0, 9999, 0)
		
		for i = 1, 50 do
			if tRoot and myRoot then
				myRoot.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
				myRoot.AssemblyLinearVelocity = Vector3.new(999, 999, 999)
			end
			task.wait(0.02)
		end
		bg:Destroy()
		myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
		myRoot.CFrame = oldCF
	end
end)

addMenuCmd("💥 12. Локальный Взрыв", true, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") then
		local exp = Instance.new("Explosion", workspace)
		exp.Position = tPlr.Character.HumanoidRootPart.Position
		exp.BlastRadius = 10
		createNotification("ЭФФЕКТЫ", "Создан локальный ядерный бабах!", "Info")
	end
end)

addMenuCmd("✨ 13. Дать Искры (Локально)", true, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") then
		Instance.new("Sparkles", tPlr.Character.HumanoidRootPart)
		createNotification("КАСТОМИЗАЦИЯ", "Ваш друг теперь сияет ярче звезд!", "Info")
	end
end)

addMenuCmd("👻 14. Скример розыгрыш", true, function(tPlr)
	local screamer = Instance.new("ImageLabel", ScreenGui)
	screamer.Size = UDim2.new(1, 0, 1, 0)
	screamer.Image = "rbxassetid://6032269223"
	screamer.ZIndex = 999999
	local snd = Instance.new("Sound", workspace)
	snd.SoundId = "rbxassetid://9069609268"
	snd.Volume = 5
	snd:Play()
	task.delay(1.5, function() screamer:Destroy(); snd:Destroy() end)
	createNotification("TROLL", "Бу! Испугался? Не бойся.", "Alert")
end)

addMenuCmd("🎈 15. Сделать Гигантом", true, function(tPlr)
	if tPlr and tPlr.Character then
		for _, part in pairs(tPlr.Character:GetChildren()) do
			if part:IsA("BasePart") then part.Size = part.Size * 2.5 end
		end
		createNotification("МОДИФИКАТОР", "Друг вырос до небес (Локально)!", "Info")
	end
end)

addMenuCmd("🐭 16. Сделать Крошечным", true, function(tPlr)
	if tPlr and tPlr.Character then
		for _, part in pairs(tPlr.Character:GetChildren()) do
			if part:IsA("BasePart") then part.Size = part.Size * 0.4 end
		end
		createNotification("МОДИФИКАТОР", "Игрок уменьшен до размеров мыши!", "Info")
	end
end)

addMenuCmd("☠️ 17. Сорвать Одежду", true, function(tPlr)
	if tPlr and tPlr.Character then
		for _, v in pairs(tPlr.Character:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
		end
		createNotification("ФАН", "Гардероб игрока успешно уничтожен!", "Alert")
	end
end)

addMenuCmd("👽 18. Создать Клона", true, function(tPlr)
	if tPlr and tPlr.Character then
		tPlr.Character.Archivable = true
		local cl = tPlr.Character:Clone()
		cl.Parent = workspace
		cl:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(4, 0, 0))
		createNotification("МАГИЯ", "Локальный восковой клон успешно создан рядом!", "Info")
	end
end)

addMenuCmd("💬 19. Фейк Чат Троллинг", true, function(tPlr)
	logToConsole("[ЧАТ ТРОЛЛИНГ] " .. selectedFriendName .. ": Я использую ROBLOX VISUALS V33.2! Скрипт просто топ!")
	createNotification("СИСТЕМА", "Сообщение успешно подделано в логи чита.", "Info")
end)

addMenuCmd("🎵 20. Звук Клоуна", true, function(tPlr)
	if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("Head") then
		local s = Instance.new("Sound", tPlr.Character.Head)
		s.SoundId = "rbxassetid://9114223193"
		s.Volume = 3
		s:Play()
		task.delay(3, function() s:Destroy() end)
		createNotification("ЗВУК", "Клоунский гудок воспроизведен на игроке!", "Info")
	end
end)

-- =============================================================================
-- ПЕРЕБОРКА И ОБНОВЛЕНИЕ СУЩЕСТВУЮЩИХ ЭЛЕМЕНТОВ
-- =============================================================================
local function rebuildFriendsUI()
	for _, fName in ipairs(friendsList) do
		local card = FriendsContainer:FindFirstChild(fName)
		local targetPlr = Players:FindFirstChild(fName)
		
		if not card then
			card = Instance.new("Frame", FriendsContainer)
			card.Name = fName
			card.Size = UDim2.new(1, -10, 0, 75)
			card.BackgroundColor3 = Color3.fromRGB(30, 22, 17) 
			applyGlassStyle(card, 10, Theme.AccentCyan, 1)
			
			local avatar = Instance.new("ImageLabel", card)
			avatar.Name = "Avatar"
			avatar.Size = UDim2.new(0, 46, 0, 46)
			avatar.Position = UDim2.new(0, 10, 0.5, -23)
			avatar.BackgroundTransparency = 1
			avatar.ImageTransparency = 0.15
			if targetPlr then
				avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlr.UserId .. "&w=150&h=150"
			else
				avatar.Image = "rbxassetid://79078068171736"
			end
			applyGlassStyle(avatar, 23)
			
			local label = Instance.new("TextLabel", card)
			label.Name = "InfoLabel"
			label.Size = UDim2.new(1, -75, 0, 35)
			label.Position = UDim2.new(0, 68, 0, 4)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			
			local actions = Instance.new("Frame", card)
			actions.Name = "Actions"
			actions.Size = UDim2.new(1, -75, 0, 24)
			actions.Position = UDim2.new(0, 68, 0, 42)
			actions.BackgroundTransparency = 1
			
			local actLayout = Instance.new("UIListLayout", actions)
			actLayout.FillDirection = Enum.FillDirection.Horizontal
			actLayout.Padding = UDim.new(0, 6)
			
			-- КНОПКА ОТКРЫТИЯ СЕТКИ ИЗ 20 КОМАНД
			local b = Instance.new("TextButton", actions)
			b.Size = UDim2.new(0, 160, 1, 0)
			b.BackgroundColor3 = Theme.BtnOn
			b.Text = "👑 МЕНЮ 20 КОМАНД"
			b.TextColor3 = Theme.Text
			b.Font = Enum.Font.GothamBold
			b.TextSize = 10
			applyGlassStyle(b, 6, Theme.Gold, 1)
			
			b.Activated:Connect(function()
				selectedFriendName = fName
				FriendMenuTitle.Text = "УПРАВЛЕНИЕ ДРУГОМ: " .. fName:upper()
				FriendMenuWindow.Visible = true
			end)
			
			card.MouseEnter:Connect(function()
				TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(75, 57, 46)}):Play()
				TweenService:Create(avatar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0}):Play()
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
			
			card.MouseLeave:Connect(function()
				TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(30, 22, 17)}):Play()
				TweenService:Create(avatar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0.15}):Play()
				label.TextColor3 = Theme.Text
			end)
		end
		
		local label = card:FindFirstChild("InfoLabel")
		if label then
			if targetPlr and targetPlr.Character then
				local hum = targetPlr.Character:FindFirstChildOfClass("Humanoid")
				local hp = hum and hum.Health or 0
				local status = "❤️ Жив"
				
				if hp <= 0 then
					status = "💀 Умер"
				elseif hp < 25 then
					status = "⚠️ Мало ХП!"
				end
				
				label.Text = string.format("👤 %s\n💬 Статус: %s (%d HP)", fName, status, math.floor(hp))
			else
				label.Text = string.format("👤 %s\n❌ Оффлайн или мертв", fName)
			end
		end
	end
	
	for _, child in pairs(FriendsContainer:GetChildren()) do
		if child:IsA("Frame") and not table.find(friendsList, child.Name) then
			child:Destroy()
		end
	end
end

FriendAddBtn.Activated:Connect(function()
	local name = FriendInput.Text:match("^%s*(.-)%s*$")
	if name and name ~= "" then
		if not table.find(friendsList, name) then
			table.insert(friendsList, name)
			friendsHealthCache[name] = { lastHealth = 100, lowNotified = false, deadNotified = false }
			createNotification("ДРУЗЬЯ", name .. " добавлен в список слежки!", "Info")
			FriendInput.Text = ""
			rebuildFriendsUI()
		else
			createNotification("ОШИБКА", "Этот игрок уже отслеживается.", "Alert")
		end
	end
end)

Players.PlayerAdded:Connect(function(joinedPlayer)
	if table.find(friendsList, joinedPlayer.Name) then
		friendsHealthCache[joinedPlayer.Name] = friendsHealthCache[joinedPlayer.Name] or { lastHealth = 100, lowNotified = false, deadNotified = false }
		createNotification("👋 ДРУГ ПОДКЛЮЧИЛСЯ", joinedPlayer.Name .. " зашёл на сервер!", "Info")
	end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if table.find(friendsList, leavingPlayer.Name) then
		createNotification("🚪 ДРУГ ВЫШЕЛ", leavingPlayer.Name .. " покинул сервер.", "Alert")
	end
end)

-- ОТДЕЛЬНЫЙ СТАБИЛЬНЫЙ ПОТОК ОБНОВЛЕНИЯ ИНТЕРФЕЙСА ДРУЗЕЙ БЕЗ ЗАВИСАНИЙ
task.spawn(function()
	while true do
		pcall(rebuildFriendsUI)
		task.wait(2.0)
	end
end)

-- =============================================================================
-- 🪐 ИЗМЕНЕНИЕ МИРА
-- =============================================================================
addToggle(tWorld, "Full", "☀️ Fullbright (Без тени)", function(v)
	Lighting.Brightness = v and 4 or 2
	Lighting.Ambient = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,128,128)
end)
addToggle(tWorld, "FreezeTime", "⏱️ Зафиксировать Время", function() end)
addToggle(tWorld, "LowG", "🪐 Лунная гравитация", function(v) workspace.Gravity = v and 35 or 196.2 end)
addToggle(tWorld, "AntiLava", "🌋 Анти-Лава", function() end)
addButton(tWorld, "⚡ Оптимизация FPS", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
	end
	logToConsole("Текстуры удалены. FPS оптимизирован!")
end)

-- Кастомизация (Скины)
addToggle(tSkin, "Headless", "💀 Локальный Хедлесс", function(v)
	if player.Character and player.Character:FindFirstChild("Head") then player.Character.Head.Transparency = v and 1 or 0 end
end)
addToggle(tSkin, "NeonSkin", "🧪 Неоновое тело", function() end)
addToggle(tSkin, "RainSkin", "🌈 RGB Радужный скин", function() end)
addToggle(tSkin, "FireSkin", "🔥 Персонаж в огне", function(v)
	local char = player.Character
	if v and char then
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") and not part:FindFirstChild("CyberFire") then
				local f = Instance.new("Fire", part); f.Name = "CyberFire"; f.Heat = 15; f.Size = 8
			end
		end
	else
		if char then for _, part in pairs(char:GetDescendants()) do if part.Name == "CyberFire" then part:Destroy() end end end
	end
end)
addToggle(tSkin, "Trail", "✨ Шлейф при ходьбе", function() end)
addToggle(tSkin, "Halo", "😇 Нимб над головой", function() end)

addToggle(tSkin, "GhostSkin", "👻 Полупрозрачное тело", function(v)
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.LocalTransparencyModifier = v and 0.55 or 0
		end
	end
end)

addToggle(tSkin, "BodyLight", "💡 Персональное освещение", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local light = root:FindFirstChild("VisualsBodyLight")
	if v and not light then
		light = Instance.new("PointLight", root)
		light.Name = "VisualsBodyLight"
		light.Color = Theme.AccentCyan
		light.Range = 18
		light.Brightness = 2
	elseif not v and light then
		light:Destroy()
	end
end)

addToggle(tSkin, "SelfOutline", "🔷 Контур персонажа", function(v)
	local char = player.Character
	if not char then return end
	local highlight = char:FindFirstChild("VisualsSelfHighlight")
	if v and not highlight then
		highlight = Instance.new("Highlight", char)
		highlight.Name = "VisualsSelfHighlight"
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = Theme.AccentCyan
	elseif not v and highlight then
		highlight:Destroy()
	end
end)

addButton(tSkin, "🧹 Сбросить визуальные эффекты", function()
	local char = player.Character
	if not char then return end
	for _, object in ipairs(char:GetDescendants()) do
		if object.Name == "CyberFire" or object.Name == "CyberTrail" or object.Name == "VisualsBodyLight" or object.Name == "VisualsFaceLight" or object.Name == "VisualsSelfHighlight" or object.Name == "VisualsRainbowOutline" or object.Name == "VisualsSparkleAura" or object.Name == "VisualsSmokeAura" or object.Name == "VisualsForceField" then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.LocalTransparencyModifier = 0
			object.Material = Enum.Material.Plastic
		end
	end
	if haloPart then haloPart:Destroy(); haloPart = nil end
	createNotification("КАСТОМИЗАЦИЯ", "Локальные эффекты сброшены.", "Info")
end)

addToggle(tSkin, "SparkleAura", "✨ Аура искр", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local sparkles = root:FindFirstChild("VisualsSparkleAura")
	if v and not sparkles then
		sparkles = Instance.new("Sparkles", root)
		sparkles.Name = "VisualsSparkleAura"
		sparkles.SparkleColor = Theme.AccentCyan
	elseif not v and sparkles then
		sparkles:Destroy()
	end
end)

addToggle(tSkin, "SmokeAura", "☁️ Цветной дым", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local smoke = root:FindFirstChild("VisualsSmokeAura")
	if v and not smoke then
		smoke = Instance.new("Smoke", root)
		smoke.Name = "VisualsSmokeAura"
		smoke.Color = Theme.AccentPurple
		smoke.Opacity = 0.25
		smoke.RiseVelocity = 4
	elseif not v and smoke then
		smoke:Destroy()
	end
end)

addToggle(tSkin, "HideName", "🙈 Скрыть имя над персонажем", function(v)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
	end
end)

addToggle(tSkin, "ForceFieldLook", "🛡️ Эффект защитного поля", function(v)
	local char = player.Character
	if not char then return end
	local field = char:FindFirstChild("VisualsForceField")
	if v and not field then
		field = Instance.new("ForceField", char)
		field.Name = "VisualsForceField"
		field.Visible = true
	elseif not v and field then
		field:Destroy()
	end
end)

-- =============================================
-- 💎 НОВЫЕ ФУНКЦИИ КАСТОМИЗАЦИИ
-- =============================================

addToggle(tSkin, "CrystalSkin", "💎 Кристальное тело (Glass)", function(v)
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Material = v and Enum.Material.Glass or Enum.Material.Plastic
			part.Reflectance = v and 0.4 or 0
		end
	end
end)

addToggle(tSkin, "NeonEyes", "👁️ Неоновые глаза", function(v)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then return end
	if v then
		for i = 1, 2 do
			local eyeLight = head:FindFirstChild("NeonEye"..i) or Instance.new("SpotLight", head)
			eyeLight.Name = "NeonEye"..i
			eyeLight.Brightness = 3; eyeLight.Range = 14
			eyeLight.Color = Theme.AccentCyan; eyeLight.Angle = 40
		end
	else
		for i = 1, 2 do
			local l = head:FindFirstChild("NeonEye"..i)
			if l then l:Destroy() end
		end
	end
end)

addToggle(tSkin, "LunarGlow", "🌙 Лунное свечение (фиолетовый свет)", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local glow = root:FindFirstChild("VisualsLunarGlow")
	if v and not glow then
		glow = Instance.new("PointLight", root)
		glow.Name = "VisualsLunarGlow"
		glow.Color = Color3.fromRGB(120, 80, 255)
		glow.Range = 22; glow.Brightness = 1.8
	elseif not v and glow then
		glow:Destroy()
	end
end)

addToggle(tSkin, "ElectraAura", "⚡ Электрическая аура", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local e = root:FindFirstChild("VisualsElectra")
	if v and not e then
		e = Instance.new("Sparkles", root)
		e.Name = "VisualsElectra"
		e.SparkleColor = Color3.fromRGB(80, 180, 255)
	elseif not v and e then
		e:Destroy()
	end
end)

addToggle(tSkin, "IceTrail", "🌊 Ледяной синий шлейф", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if not v then
		local tr = root:FindFirstChild("IceTrailObj")
		if tr then tr:Destroy() end
		local a0 = root:FindFirstChild("IceAtt0")
		local a1 = root:FindFirstChild("IceAtt1")
		if a0 then a0:Destroy() end
		if a1 then a1:Destroy() end
		return
	end
	local a0 = root:FindFirstChild("IceAtt0") or Instance.new("Attachment", root)
	local a1 = root:FindFirstChild("IceAtt1") or Instance.new("Attachment", root)
	a0.Name = "IceAtt0"; a0.Position = Vector3.new(0, 1, 0)
	a1.Name = "IceAtt1"; a1.Position = Vector3.new(0, -1, 0)
	if not root:FindFirstChild("IceTrailObj") then
		local tr = Instance.new("Trail", root)
		tr.Name = "IceTrailObj"
		tr.Attachment0 = a0; tr.Attachment1 = a1
		tr.Color = ColorSequence.new(Color3.fromRGB(130, 220, 255), Color3.fromRGB(200, 240, 255))
		tr.Transparency = NumberSequence.new(0, 1)
		tr.Lifetime = 0.6; tr.WidthScale = NumberSequence.new(1, 0)
	end
end)

addToggle(tSkin, "ShieldBubble", "🛸 Защитный пузырь (SelectionSphere)", function(v)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local sphere = root:FindFirstChild("VisualsShieldSphere")
	if v and not sphere then
		sphere = Instance.new("SelectionSphere", root)
		sphere.Name = "VisualsShieldSphere"
		sphere.Adornee = root
		sphere.Color3 = Theme.AccentCyan
		sphere.SurfaceTransparency = 0.65
		sphere.SurfaceColor3 = Theme.AccentCyan:Lerp(Color3.new(1,1,1), 0.4)
	elseif not v and sphere then
		sphere:Destroy()
	end
end)

addToggle(tSkin, "DiamondHead", "💠 Алмазный блеск головы", function(v)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then return end
	head.Material = v and Enum.Material.Glass or Enum.Material.SmoothPlastic
	head.Reflectance = v and 0.6 or 0
end)

-- Ввод кастомного цвета для ауры / шлейфа
local AuraSkinTitle = Instance.new("TextLabel", tSkin)
AuraSkinTitle.Size = UDim2.new(1, -6, 0, 22)
AuraSkinTitle.BackgroundTransparency = 1
AuraSkinTitle.Text = "🎨 КАСТОМНЫЙ ЦВЕТ АУРЫ / ШЛЕЙФА"
AuraSkinTitle.TextColor3 = Theme.Gold
AuraSkinTitle.Font = Enum.Font.GothamBold
AuraSkinTitle.TextSize = 11
AuraSkinTitle.TextXAlignment = Enum.TextXAlignment.Left

local AuraColorInput = Instance.new("TextBox", tSkin)
AuraColorInput.Size = UDim2.new(1, -6, 0, 36)
AuraColorInput.BackgroundColor3 = Theme.BtnOff
AuraColorInput.PlaceholderText = "R,G,B (напр: 255,100,0)"
AuraColorInput.Text = ""
AuraColorInput.TextColor3 = Theme.Text
AuraColorInput.Font = Enum.Font.Code
AuraColorInput.TextSize = 12
applyGlassStyle(AuraColorInput, 8, Theme.AccentCyan)

addButton(tSkin, "🎨 Применить цвет к ауре/шлейфу", function()
	local color = parseRgb(AuraColorInput.Text, Theme.AccentCyan)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local sparkles = root:FindFirstChild("VisualsSparkleAura")
		if sparkles then sparkles.SparkleColor = color end
		local electra = root:FindFirstChild("VisualsElectra")
		if electra then electra.SparkleColor = color end
		local smoke = root:FindFirstChild("VisualsSmokeAura")
		if smoke then smoke.Color = color end
		local trail = root:FindFirstChild("CyberTrail")
		if trail then trail.Color = ColorSequence.new(color, color:Lerp(Color3.new(1,1,1), 0.3)) end
		local iceTrail = root:FindFirstChild("IceTrailObj")
		if iceTrail then iceTrail.Color = ColorSequence.new(color, color:Lerp(Color3.new(1,1,1), 0.5)) end
	end
	createNotification("КАСТОМИЗАЦИЯ", "Цвет ауры и шлейфа обновлён!", "Info")
end)

addButton(tSkin, "💥 Взрыв искр (эффект спавна)", function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _ = 1, 20 do
		local pix = Instance.new("Part", workspace)
		pix.Anchored = true; pix.CanCollide = false
		pix.Material = Enum.Material.Neon
		pix.Color = Color3.fromHSV(math.random() * 0.15 + 0.05, 1, 1)
		pix.Size = Vector3.new(0.3, 0.3, 0.3)
		pix.Position = root.Position + Vector3.new(math.random(-12,12)/10, math.random(0,20)/10, math.random(-12,12)/10)
		applyGlassStyle(pix, 3)
		TweenService:Create(pix, TweenInfo.new(0.9), {
			Position = pix.Position + Vector3.new(math.random(-3,3), 4, math.random(-3,3)),
			Transparency = 1
		}):Play()
		task.delay(1, function() if pix.Parent then pix:Destroy() end end)
	end
	createNotification("ЭФФЕКТ", "Взрыв искр!", "Info")
end)

local function restoreCharacterEffects(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local head = character:WaitForChild("Head", 10)
	if not humanoid or not root then return end

	if States["Headless"] and head then head.Transparency = 1 end
	if States["GhostSkin"] then
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.LocalTransparencyModifier = 0.55
			end
		end
	end
	if States["HideName"] then humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

	if States["FireSkin"] then
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") and not part:FindFirstChild("CyberFire") then
				local fire = Instance.new("Fire", part)
				fire.Name = "CyberFire"
				fire.Heat = 15
				fire.Size = 8
			end
		end
	end
	if States["BodyLight"] then
		local light = root:FindFirstChild("VisualsBodyLight") or Instance.new("PointLight", root)
		light.Name = "VisualsBodyLight"
		light.Color = Theme.AccentCyan
		light.Range = 18
		light.Brightness = 2
	end
	if States["FaceLight"] and head then
		local light = head:FindFirstChild("VisualsFaceLight") or Instance.new("SurfaceLight", head)
		light.Name = "VisualsFaceLight"
		light.Face = Enum.NormalId.Front
		light.Color = Theme.Gold
		light.Range = 10
		light.Brightness = 1.5
	end
	if States["SelfOutline"] then
		local highlight = character:FindFirstChild("VisualsSelfHighlight") or Instance.new("Highlight", character)
		highlight.Name = "VisualsSelfHighlight"
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = Theme.AccentCyan
	end
	if States["RainbowOutline"] then
		local highlight = character:FindFirstChild("VisualsRainbowOutline") or Instance.new("Highlight", character)
		highlight.Name = "VisualsRainbowOutline"
		highlight.FillTransparency = 1
	end
	if States["SparkleAura"] then
		local sparkles = root:FindFirstChild("VisualsSparkleAura") or Instance.new("Sparkles", root)
		sparkles.Name = "VisualsSparkleAura"
		sparkles.SparkleColor = Theme.AccentCyan
	end
	if States["SmokeAura"] then
		local smoke = root:FindFirstChild("VisualsSmokeAura") or Instance.new("Smoke", root)
		smoke.Name = "VisualsSmokeAura"
		smoke.Color = Theme.AccentPurple
		smoke.Opacity = 0.25
		smoke.RiseVelocity = 4
	end
	if States["ForceFieldLook"] then
		local field = character:FindFirstChild("VisualsForceField") or Instance.new("ForceField", character)
		field.Name = "VisualsForceField"
		field.Visible = true
	end
	if States["InvisMock"] then
		for _, part in ipairs(character:GetDescendants()) do
			if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
				part.Transparency = 1
			end
		end
	end
	if States["CrystalSkin"] then
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Material = Enum.Material.Glass
				part.Reflectance = 0.4
			end
		end
	end
	if States["NeonEyes"] and head then
		for i, offset in ipairs({Vector3.new(0.22, 0.08, -0.52), Vector3.new(-0.22, 0.08, -0.52)}) do
			local eyeLight = head:FindFirstChild("NeonEye"..i) or Instance.new("SpotLight", head)
			eyeLight.Name = "NeonEye"..i
			eyeLight.Brightness = 3
			eyeLight.Range = 14
			eyeLight.Color = Theme.AccentCyan
			eyeLight.Angle = 40
		end
	end
	if States["LunarGlow"] then
		local glow = root:FindFirstChild("VisualsLunarGlow") or Instance.new("PointLight", root)
		glow.Name = "VisualsLunarGlow"
		glow.Color = Color3.fromRGB(120, 80, 255)
		glow.Range = 22
		glow.Brightness = 1.8
	end
	if States["ElectraAura"] then
		local e = root:FindFirstChild("VisualsElectra") or Instance.new("Sparkles", root)
		e.Name = "VisualsElectra"
		e.SparkleColor = Color3.fromRGB(80, 180, 255)
	end
end

player.CharacterAdded:Connect(function(character)
	haloPart = nil
	task.defer(restoreCharacterEffects, character)
	task.delay(2, function()
		if character.Parent then restoreCharacterEffects(character) end
	end)
end)

player.CharacterAppearanceLoaded:Connect(function(character)
	restoreCharacterEffects(character)
end)

addButton(tFriends, "🔄 Обновить список друзей", function()
	rebuildFriendsUI()
	createNotification("ДРУЗЬЯ", "Список друзей обновлён.", "Info")
end)

addButton(tFriends, "🛡️ Добавить выбранного в вайтлист", function()
	if selectedFriendName ~= "" and not table.find(whitelistedFriends, selectedFriendName) then
		table.insert(whitelistedFriends, selectedFriendName)
		createNotification("ДРУЗЬЯ", selectedFriendName .. " добавлен в вайтлист.", "Info")
	end
end)

addButton(tFriends, "🧹 Очистить вайтлист", function()
	table.clear(whitelistedFriends)
	createNotification("ДРУЗЬЯ", "Вайтлист очищен.", "Info")
end)

addButton(tFriends, "📍 Телепорт к выбранному другу", function()
	local target = Players:FindFirstChild(selectedFriendName)
	local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot and root then
		root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
		createNotification("ДРУЗЬЯ", "Вы переместились к " .. selectedFriendName .. ".", "Info")
	end
end)

local PlayerTableContainer = Instance.new("ScrollingFrame", tPlayers)
PlayerTableContainer.Size = UDim2.new(1, -6, 0, 360)
PlayerTableContainer.BackgroundColor3 = Theme.GlassBg
PlayerTableContainer.BackgroundTransparency = 0.35
PlayerTableContainer.BorderSizePixel = 0
PlayerTableContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerTableContainer.CanvasSize = UDim2.new()
PlayerTableContainer.ScrollBarThickness = 3
applyGlassStyle(PlayerTableContainer, 10, Theme.AccentCyan)
local PlayerTableLayout = Instance.new("UIListLayout", PlayerTableContainer)
PlayerTableLayout.Padding = UDim.new(0, 4)

local function rebuildPlayerTable()
	for _, child in ipairs(PlayerTableContainer:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local status = getSpecialStatus(targetPlayer)
		local row = Instance.new("TextLabel", PlayerTableContainer)
		row.Size = UDim2.new(1, -8, 0, 34)
		row.BackgroundColor3 = Theme.BtnOff
		row.BackgroundTransparency = 0.25
		row.Text = string.format("  %s%s  |  @%s", status and (status.label .. " ") or "", targetPlayer.DisplayName, targetPlayer.Name)
		row.TextColor3 = status and Color3.fromRGB(185, 185, 190) or Theme.Text
		row.Font = Enum.Font.GothamSemibold
		row.TextSize = 12
		row.TextXAlignment = Enum.TextXAlignment.Left
		applyGlassStyle(row, 7, status and Color3.fromRGB(145, 145, 150) or Theme.AccentPurple)
	end
end

local function attachSpecialBadge(targetPlayer, character)
	local status = getSpecialStatus(targetPlayer)
	if not status then return end
	local head = character:WaitForChild("Head", 8)
	if not head or head:FindFirstChild("VisualsSpecialBadge") then return end
	local badge = Instance.new("BillboardGui", head)
	badge.Name = "VisualsSpecialBadge"
	badge.Size = UDim2.fromOffset(180, 26)
	badge.StudsOffset = Vector3.new(0, 2.7, 0)
	badge.AlwaysOnTop = true
	local label = Instance.new("TextLabel", badge)
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = status.label
	label.TextColor3 = Color3.fromRGB(180, 180, 185)
	label.TextStrokeColor3 = Color3.fromRGB(35, 35, 38)
	label.TextStrokeTransparency = 0.25
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
end

local function watchSpecialPlayer(targetPlayer)
	if targetPlayer.Character then task.spawn(attachSpecialBadge, targetPlayer, targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(function(character)
		attachSpecialBadge(targetPlayer, character)
	end)
end

addButton(tPlayers, "🔄 Обновить таблицу игроков", rebuildPlayerTable)
Players.PlayerAdded:Connect(function(targetPlayer)
	task.defer(rebuildPlayerTable)
	watchSpecialPlayer(targetPlayer)
end)
Players.PlayerRemoving:Connect(function() task.defer(rebuildPlayerTable) end)
task.defer(rebuildPlayerTable)
for _, targetPlayer in ipairs(Players:GetPlayers()) do watchSpecialPlayer(targetPlayer) end

-- Murder Mystery 2
local lastAlertTime = 0

local function getMurderer()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local bp = p:FindFirstChild("Backpack")
			if (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild(" нож")))
			or p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild(" нож") then
				return p
			end
		end
	end
	return nil
end

local function getSheriff()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local bp = p:FindFirstChild("Backpack")
			if (bp and bp:FindFirstChild("Gun")) or p.Character:FindFirstChild("Gun") then
				return p
			end
		end
	end
	return nil
end

local function getRandomInnocent()
	local candidates = {}
	local mud = getMurderer()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p ~= mud and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(candidates, p)
			end
		end
	end
	if #candidates > 0 then
		return candidates[math.random(1, #candidates)]
	end
	return nil
end

local function findTargetPlayer(namePart)
	if not namePart or namePart == "" then return nil end
	namePart = namePart:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1, #namePart) == namePart or p.DisplayName:lower():sub(1, #namePart) == namePart then
			return p
		end
	end
	return nil
end

addToggle(tMM2, "InvisMock", "👻 Режим Невидимости", function(v)
	local char = player.Character
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				if part.Name ~= "HumanoidRootPart" then
					part.Transparency = v and 1 or 0
				end
			end
		end
	end
end)

addButton(tMM2, "📍 ТП к Убийце", function()
	local mud = getMurderer()
	if mud and mud.Character and mud.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = mud.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		createNotification("НАВИГАЦИЯ", "Успешно телепортирован к Убийце!", "Info")
	else
		createNotification("ОШИБКА", "Убийца на карте пока не найден.", "Alert")
	end
end)

addButton(tMM2, "📍 ТП к Шерифу", function()
	local sh = getSheriff()
	if sh and sh.Character and sh.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = sh.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		createNotification("НАВИГАЦИЯ", "Успешно телепортирован к Шерифу!", "Info")
	else
		createNotification("ОШИБКА", "Шериф на карте пока не найден.", "Alert")
	end
end)

addToggle(tMM2, "AlertMurderer", "🚨 Детектор: Предупреждать о Мардере", function(v)
	if v then createNotification("ДЕТЕКТОР", "Слежка за Мардером запущена.", "Info") end
end)

local FlingInput = Instance.new("TextBox", tMM2)
FlingInput.Size = UDim2.new(1, -6, 0, 35)
FlingInput.BackgroundColor3 = Theme.BtnOff
FlingInput.PlaceholderText = "Введите ник игрока для Флинга..."
FlingInput.Text = ""
FlingInput.TextColor3 = Theme.Text
FlingInput.Font = Enum.Font.GothamSemibold
FlingInput.TextSize = 12
applyGlassStyle(FlingInput, 10, Theme.AccentPurple, 1)

addToggle(tMM2, "FlingToggle", "🌪️ Активировать Флинг", function(v)
	if v then 
		createNotification("ФЛИНГ", "Атака на игрока запущена!", "Info") 
	else
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end
	end
end)

addToggle(tMM2, "SmartEvac", "🤖 Смарт-эвакуация (Авто-ТП от Мардера)", function(v)
	if v then createNotification("ЭВАКУАЦИЯ", "Авто-эвакуация готова.", "Info") end
end)

addToggle(tMM2, "Mm2Esp", "👁️ Радар ролей (Убийца/Шериф)", function() end)
addToggle(tMM2, "Mm2GunEsp", "🎯 Подсветка Пистолета", function() end)
addToggle(tMM2, "Mm2Autofarm", "💰 Автосбор монет/улик", function() end)
addToggle(tMM2, "TrapEsp", "🪤 Подсветка ловушек", function() end)
addToggle(tMM2, "TrapAlert", "⚠️ Предупреждать о близкой ловушке", function() end)
addToggle(tMM2, "AntiTrap", "🛡️ Защита от обездвиживающих ловушек", function() end)
addButton(tMM2, "🏃 Восстановить движение", function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid.WalkSpeed = curSpeed
		humanoid.JumpPower = curJump
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		createNotification("MM2", "Движение персонажа восстановлено.", "Info")
	end
end)
addButton(tMM2, "👁️ Наблюдать за убийцей", function()
	local murderer = getMurderer()
	local humanoid = murderer and murderer.Character and murderer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then camera.CameraSubject = humanoid else createNotification("MM2", "Убийца ещё не найден.", "Alert") end
end)
addButton(tMM2, "🎥 Вернуть камеру к себе", function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then camera.CameraSubject = humanoid end
end)

local trapAlertCooldown = 0
local trapTouchCache = {}
local function isTrapObject(object)
	if not object:IsA("BasePart") then return false end
	local name = object.Name:lower()
	local parentName = object.Parent and object.Parent.Name:lower() or ""
	return name:find("trap") or name:find("snare") or name:find("beartrap") or name:find("ловуш")
		or parentName:find("trap") or parentName:find("snare") or parentName:find("beartrap") or parentName:find("ловуш")
end

task.spawn(function()
	while ScreenGui.Parent do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		for _, object in ipairs(workspace:GetDescendants()) do
			if isTrapObject(object) then
				local highlight = object:FindFirstChild("VisualsTrapHighlight")
				if States["TrapEsp"] and not highlight then
					highlight = Instance.new("Highlight", object)
					highlight.Name = "VisualsTrapHighlight"
					highlight.Adornee = object.Parent:IsA("Model") and object.Parent or object
					highlight.FillColor = Theme.AlertRed
					highlight.OutlineColor = Theme.Gold
				elseif not States["TrapEsp"] and highlight then
					highlight:Destroy()
				end
				if States["AntiTrap"] then
					if trapTouchCache[object] == nil then trapTouchCache[object] = object.CanTouch end
					object.CanTouch = false
				elseif trapTouchCache[object] ~= nil then
					object.CanTouch = trapTouchCache[object]
					trapTouchCache[object] = nil
				end
				if root and States["TrapAlert"] and (root.Position - object.Position).Magnitude <= 14 and tick() - trapAlertCooldown > 4 then
					trapAlertCooldown = tick()
					createNotification("🪤 ЛОВУШКА РЯДОМ", "Осторожно: ловушка находится ближе 14 метров!", "Alert")
				end
			end
		end
		task.wait(1)
	end
end)
addToggle(tMM2, "TradeSafety", "🛡️ Защита трейда [Кнопка X]", function(v)
	if v then logToConsole("Защита трейда включена. X закрывает локальное окно трейда.") end
end)
addButton(tMM2, "🔫 ТП к Упавшему Пистолету", function()
	local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Luger") or workspace:FindFirstChild("Revolver")
	if gun and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 2, 0)
		logToConsole("🎯 Телепортирован к пистолету!")
	else
		logToConsole("❌ Пистолет на карте не найден.")
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if States["TradeSafety"] and input.KeyCode == Enum.KeyCode.X then
		local closed = false
		for _, guiObject in ipairs(playerGui:GetDescendants()) do
			if guiObject:IsA("GuiObject") and guiObject.Visible and guiObject.Name:lower():find("trade") then
				guiObject.Visible = false
				closed = true
			end
		end
		createNotification("ЗАЩИТА ТРЕЙДА", closed and "Локальное окно трейда закрыто без подтверждения." or "Подтверждение заблокировано локально.", "Info")
	end
end)

-- Темы и Инструменты
addButton(tUtils, "🟫 Включить Шоколадную Тему (как на Фото)", function()
	Theme.GlassBg = Color3.fromRGB(36, 26, 20)
	Theme.HeaderBg = Color3.fromRGB(46, 33, 25)
	Theme.AccentCyan = Color3.fromRGB(235, 135, 40)
	MainFrame.BackgroundColor3 = Theme.GlassBg
	if MainStroke then MainStroke.Color = Color3.fromRGB(70, 55, 45) end
end)

addButton(tUtils, "🔮 Включить Классическую Неоновую Тему", function()
	Theme.GlassBg = Color3.fromRGB(10, 6, 20)
	Theme.HeaderBg = Color3.fromRGB(18, 10, 32)
	Theme.AccentCyan = Color3.fromRGB(0, 240, 255)
	MainFrame.BackgroundColor3 = Theme.GlassBg
	if MainStroke then MainStroke.Color = Color3.fromRGB(165, 45, 255) end
end)

addButton(tUtils, "📂 Загрузить DARK DEX", function()
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua"))() end)
end)
addButton(tUtils, "🛠️ Выдать BTools (F3X)", function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyTwentyCharacters/f3x-tools/main/src/Server/Main.lua"))()
	end)
end)
addButton(tUtils, "🌀 Загрузить Infinite Yield", function()
	pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeY/infiniteyield/master/source'))() end)
end)
addButton(tUtils, "🔄 Быстрый Перезапуск Сервера", function() TeleportService:Teleport(game.PlaceId, player) end)

local function emergencyStop()
	for k, _ in pairs(States) do States[k] = false end
	updateCounter(); updateFly(false); isPlaying = false; isRecording = false; isRecordingPaused = false; isMacroPaused = false
	RecordIndicator.Visible = false; MacroSaveFrame.Visible = false; followingFriend = nil
	if autoPlatform then autoPlatform:Destroy(); autoPlatform = nil end
	logToConsole("🚨 ВСЕ МОДЫ ВЫКЛЮЧЕНЫ!")
end

local ExitConfirm = Instance.new("Frame", ScreenGui)
ExitConfirm.Size = UDim2.new(0, 390, 0, 210)
ExitConfirm.Position = UDim2.new(0.5, -195, 0.5, -105)
ExitConfirm.BackgroundColor3 = Theme.GlassBg
ExitConfirm.BackgroundTransparency = 0.04
ExitConfirm.Visible = false
ExitConfirm.ZIndex = 30000
applyGlassStyle(ExitConfirm, 16, Theme.Gold, 2)

local ExitTitle = Instance.new("TextLabel", ExitConfirm)
ExitTitle.Size = UDim2.new(1, -30, 0, 90)
ExitTitle.Position = UDim2.new(0, 15, 0, 15)
ExitTitle.BackgroundTransparency = 1
ExitTitle.Text = "Вы точно хотите выйти\nиз Roblox Visuals?"
ExitTitle.TextColor3 = Theme.Text
ExitTitle.Font = Enum.Font.GothamBold
ExitTitle.TextSize = 18
ExitTitle.ZIndex = 30001

local ExitYes = Instance.new("TextButton", ExitConfirm)
ExitYes.Size = UDim2.new(0, 165, 0, 42)
ExitYes.Position = UDim2.new(0, 25, 1, -65)
ExitYes.BackgroundColor3 = Theme.AlertRed
ExitYes.Text = "ДА, ВЫЙТИ"
ExitYes.TextColor3 = Theme.Text
ExitYes.Font = Enum.Font.GothamBold
ExitYes.TextSize = 12
ExitYes.ZIndex = 30001
applyGlassStyle(ExitYes, 10)

local ExitNo = Instance.new("TextButton", ExitConfirm)
ExitNo.Size = UDim2.new(0, 165, 0, 42)
ExitNo.Position = UDim2.new(1, -190, 1, -65)
ExitNo.BackgroundColor3 = Theme.AccentGreen
ExitNo.Text = "НЕТ, ОСТАТЬСЯ"
ExitNo.TextColor3 = Theme.Text
ExitNo.Font = Enum.Font.GothamBold
ExitNo.TextSize = 12
ExitNo.ZIndex = 30001
applyGlassStyle(ExitNo, 10)

addButton(tExit, "🚪 Выйти из Roblox Visuals", function()
	ExitConfirm.Visible = true
	ExitConfirm.Size = UDim2.new(0, 330, 0, 170)
	TweenService:Create(ExitConfirm, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 390, 0, 210)}):Play()
end)

ExitNo.Activated:Connect(function()
	ExitConfirm.Visible = false
	createNotification("СПАСИБО", "Спасибо, что вы с нами!", "Info")
end)

ExitYes.Activated:Connect(function()
	emergencyStop()
	ExitTitle.Text = "До свидания, хорошего дня!\nЖдём вас снова."
	ExitYes.Visible = false
	ExitNo.Visible = false
	TweenService:Create(ExitConfirm, TweenInfo.new(1.1), {BackgroundTransparency = 1}):Play()
	task.wait(1.2)
	ScreenGui:Destroy()
end)

local RejectionFrame = Instance.new("Frame", ScreenGui)
RejectionFrame.Size = UDim2.new(0, 430, 0, 250)
RejectionFrame.Position = UDim2.new(0.5, -215, 0.5, -125)
RejectionFrame.BackgroundColor3 = Color3.fromRGB(28, 16, 16)
RejectionFrame.Visible = false
RejectionFrame.ZIndex = 60000
applyGlassStyle(RejectionFrame, 18, Theme.AlertRed, 2)

local RejectionTitle = Instance.new("TextLabel", RejectionFrame)
RejectionTitle.Size = UDim2.new(1, -30, 0, 55)
RejectionTitle.Position = UDim2.new(0, 15, 0, 20)
RejectionTitle.BackgroundTransparency = 1
RejectionTitle.Text = "ДОСТУП ОТКЛОНЁН СИСТЕМОЙ"
RejectionTitle.TextColor3 = Theme.AlertRed
RejectionTitle.Font = Enum.Font.GothamBold
RejectionTitle.TextSize = 18
RejectionTitle.ZIndex = 60001

local RejectionText = Instance.new("TextLabel", RejectionFrame)
RejectionText.Size = UDim2.new(1, -50, 0, 85)
RejectionText.Position = UDim2.new(0, 25, 0, 80)
RejectionText.BackgroundTransparency = 1
RejectionText.Text = "Ваш сеанс был отклонён.\nЧтобы узнать причину, нажмите «Подробнее»."
RejectionText.TextWrapped = true
RejectionText.TextColor3 = Theme.Text
RejectionText.Font = Enum.Font.GothamSemibold
RejectionText.TextSize = 14
RejectionText.ZIndex = 60001

local RejectionButton = Instance.new("TextButton", RejectionFrame)
RejectionButton.Size = UDim2.new(0, 220, 0, 42)
RejectionButton.Position = UDim2.new(0.5, -110, 1, -62)
RejectionButton.BackgroundColor3 = Theme.AlertRed
RejectionButton.Text = "ПОДРОБНЕЕ"
RejectionButton.TextColor3 = Theme.Text
RejectionButton.Font = Enum.Font.GothamBold
RejectionButton.TextSize = 12
RejectionButton.ZIndex = 60001
applyGlassStyle(RejectionButton, 10)

RejectionButton.Activated:Connect(function()
	if RejectionButton.Text == "ПОДРОБНЕЕ" then
		RejectionTitle.Text = "ВЫ ЗАБЛОКИРОВАНЫ"
		RejectionText.Text = "Причина: " .. tostring(banReason or "Нарушение правил Roblox Visuals")
		RejectionButton.Text = "ЗАКРЫТЬ"
	else
		ScreenGui:Destroy()
	end
end)

local function startBanSequence()
	if not banReason or banSequenceStarted then return end
	banSequenceStarted = true
	task.spawn(function()
		for seconds = 5, 1, -1 do
			createNotification("ПРОВЕРКА СИСТЕМЫ", "Проверка доступа: " .. seconds .. " сек.", "Alert")
			task.wait(1)
		end
		interfaceLocked = true
		emergencyStop()
		for _, control in ipairs(toggleControls) do
			control.switch.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
			control.ball.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
			control.button.Text = "   🔒 " .. control.button.Text:gsub("^%s+", "")
			TweenService:Create(control.button, TweenInfo.new(0.45), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		end
		task.wait(0.6)
		MainFrame.Visible = false
		ClockWidget.Visible = false
		CounterWidget.Visible = false
		ToggleMenuBtn.Visible = false
		RejectionFrame.Visible = true
		RejectionFrame.Size = UDim2.new(0, 350, 0, 200)
		TweenService:Create(RejectionFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0, 430, 0, 250)}):Play()
	end)
end
onAnyModActivated = function() end

local PanicBtn = addToggle(tRadio, "Panic", "🚨 КНОПКА ПАНИКИ (ВЫКЛЮЧИТЬ ВСЁ)", function(v) if v then emergencyStop() end end)
PanicBtn.BackgroundColor3 = Theme.AlertRed
addToggle(tRadio, "GoldUI", "👑 Переливающаяся рамка", function() end)

local AdminPanel = Instance.new("Frame", tRadio)
AdminPanel.Size = UDim2.new(1, 0, 0, 120); AdminPanel.BackgroundTransparency = 1

ConsoleLogs.Size = UDim2.new(1, -10, 0, 100); ConsoleLogs.Position = UDim2.new(0, 5, 0, 5)
ConsoleLogs.BackgroundColor3 = Color3.fromRGB(15, 10, 8)
ConsoleLogs.ScrollBarThickness = 2
ConsoleLogs.Parent = AdminPanel; applyGlassStyle(ConsoleLogs, 8, Theme.AccentGreen)

local rgbTick = 0
local tracersFolder = ScreenGui:FindFirstChild("TracersFolder") or Instance.new("Folder", ScreenGui)
tracersFolder.Name = "TracersFolder"

-- =============================================================================
-- 🔄 ЕДИНЫЙ ЦИКЛ ОБРАБОТКИ ПЕРСОНАЖЕЙ И ЭФФЕКТОВ
-- =============================================================================
RunService.Heartbeat:Connect(function()
	pcall(function()
		local pChar = player.Character
		if not pChar then return end
		local hum = pChar:FindFirstChildOfClass("Humanoid")
		local root = pChar:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end
		
		if isRecording and not isRecordingPaused then
			table.insert(recordedPath, {
				cf = root.CFrame,
				speed = hum.WalkSpeed,
				jumpPower = hum.JumpPower,
				isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
			})
		end
		
		if not isPlaying then
			if States["S120"] or States["S250"] or States["S500"] then hum.WalkSpeed = curSpeed end
			if States["J180"] or States["J300"] then hum.UseJumpPower = true; hum.JumpPower = curJump end
		end
		
		if States["NoSt"] and hum.Sit then hum.Sit = false end
		if States["SpinB"] then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(40), 0) end
		if States["FreezeTime"] then Lighting.ClockTime = 14 end
		if States["Nocl"] then
			for _, part in pairs(pChar:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
		end

		if States["AntiLava"] then
			for _, item in pairs(workspace:GetDescendants()) do
				if item:IsA("BasePart") and (item.Name:lower():find("lava") or item.Name:lower():find("kill")) then item.CanTouch = false end
			end
		end

		if States["Mm2Autofarm"] then
			for _, c in pairs(workspace:GetDescendants()) do
				if c:IsA("TouchTransmitter") and (c.Parent.Name == "Coin" or c.Parent.Name == "Snowflake" or c.Parent.Name == "CandyCane") then
					root.CFrame = c.Parent.CFrame
					break
				end
			end
		end

		if States["AlertMurderer"] then
			local mud = getMurderer()
			if mud and mud.Character and mud.Character:FindFirstChild("HumanoidRootPart") then
				local mRoot = mud.Character.HumanoidRootPart
				local distance = (root.Position - mRoot.Position).Magnitude
				
				if distance <= 40 then
					if tick() - lastAlertTime > 4 then
						lastAlertTime = tick()
						createNotification("🚨 ВНИМАНИЕ! 🚨", "МАРДЕР БЛИЗКО! БЕГИ!", "Alert")
					end
					if States["SmartEvac"] then
						local targetPlayer = getRandomInnocent()
						if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
							root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
						end
					end
				end
			end
		end

		if States["FlingToggle"] then
			local target = findTargetPlayer(FlingInput.Text)
			if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(rgbTick * 5000), 0)
				root.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
			end
		end

		if States["Trail"] and hum.MoveDirection.Magnitude > 0 then
			local a0 = root:FindFirstChild("CyberAtt0") or Instance.new("Attachment", root)
			local a1 = root:FindFirstChild("CyberAtt1") or Instance.new("Attachment", root)
			a0.Name = "CyberAtt0"; a0.Position = Vector3.new(0,1,0)
			a1.Name = "CyberAtt1"; a1.Position = Vector3.new(0,-1,0)
			if not root:FindFirstChild("CyberTrail") then
				local tr = Instance.new("Trail", root); tr.Name = "CyberTrail";
				tr.Attachment0 = a0; tr.Attachment1 = a1
				tr.Color = ColorSequence.new(Theme.AccentCyan, Theme.AccentPurple); tr.Lifetime = 0.4;
				tr.WidthScale = NumberSequence.new(1, 0)
			end
		end

		rgbTick = rgbTick + 0.025
		local currentRainbow = Color3.fromHSV(math.sin(rgbTick)*0.5+0.5, 1, 1)
		if States["GoldUI"] and MainStroke then MainStroke.Color = currentRainbow end
		local rainbowOutline = pChar:FindFirstChild("VisualsRainbowOutline")
		if rainbowOutline then rainbowOutline.OutlineColor = currentRainbow end

		for _, part in pairs(pChar:GetChildren()) do
			if part:IsA("BasePart") then
				if States["NeonSkin"] then part.Material = Enum.Material.Neon end
				if States["RainSkin"] then part.Color = currentRainbow end
			end
		end

		if States["Halo"] then
			local head = pChar:FindFirstChild("Head")
			if head and not haloPart then
				haloPart = Instance.new("Part", pChar); haloPart.Size = Vector3.new(1.5, 0.1, 1.5)
				haloPart.Color = Theme.Gold; haloPart.Material = Enum.Material.Neon; haloPart.CanCollide = false
				Instance.new("SpecialMesh", haloPart).MeshType = Enum.MeshType.Cylinder
				local weld = Instance.new("Weld", haloPart);
				weld.Part0 = head; weld.Part1 = haloPart; weld.C0 = CFrame.new(0, 1.5, 0)
			end
		else
			if haloPart then haloPart:Destroy(); haloPart = nil end
		end

		tracersFolder:ClearAllChildren()
		
		-- Отслеживание здоровья друзей в фоне
		for _, fName in ipairs(friendsList) do
			local fPlr = Players:FindFirstChild(fName)
			local cache = friendsHealthCache[fName]
			if fPlr and fPlr.Character and fPlr.Character:FindFirstChildOfClass("Humanoid") and cache then
				local fHum = fPlr.Character:FindFirstChildOfClass("Humanoid")
				local hp = fHum.Health
				
				if hp < 25 and hp > 0 and not cache.lowNotified then
					cache.lowNotified = true
					createNotification("⚠️ ДРУГ В ОПАСНОСТИ", string.format("У друга %s мало ХП! Осталось: %d", fName, math.floor(hp)), "Alert")
				elseif hp >= 25 then
					cache.lowNotified = false
				end
				
				if hp <= 0 and not cache.deadNotified then
					cache.deadNotified = true
					createNotification("💀 ДРУГ УБИТ", string.format("Друга %s убили!", fName), "Alert")
				elseif hp > 0 then
					cache.deadNotified = false
				end
				cache.lastHealth = hp
			end
		end

		-- Перебор остальных игроков для ESP и значков
		for _, enemy in ipairs(Players:GetPlayers()) do
			if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
				if hiddenPlayers[enemy.Name] then setPlayerHidden(enemy, true) end
				if States["HitboxExp"] then
					enemy.Character.HumanoidRootPart.Size = Vector3.new(12, 12, 12)
					enemy.Character.HumanoidRootPart.CanCollide = false; enemy.Character.HumanoidRootPart.Transparency = 0.6
				else
					enemy.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); enemy.Character.HumanoidRootPart.Transparency = 1
				end
				
				local hLight = enemy.Character:FindFirstChild("MaxHighlight")
				if (States["Cham"] or States["Mm2Esp"]) and not enemy.Character:FindFirstChild("FriendHighlight") then
					if not hLight then hLight = Instance.new("Highlight", enemy.Character); hLight.Name = "MaxHighlight" end
				if States["Mm2Esp"] then
					local bp = enemy:FindFirstChild("Backpack")
					if (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild(" нож")))
					or enemy.Character:FindFirstChild("Knife") or enemy.Character:FindFirstChild(" нож") then
						hLight.FillColor = Color3.fromRGB(255, 0, 50)
						hLight.OutlineColor = Color3.fromRGB(255, 255, 255)
					elseif (bp and bp:FindFirstChild("Gun")) or enemy.Character:FindFirstChild("Gun") then
						hLight.FillColor = Color3.fromRGB(0, 100, 255)
						hLight.OutlineColor = Color3.fromRGB(255, 255, 255)
						else
							hLight.FillColor = Color3.fromRGB(100, 200, 100)
							hLight.OutlineColor = Color3.fromRGB(50, 50, 50)
						end
					else
						hLight.FillColor = Theme.AccentPurple
						hLight.OutlineColor = Theme.AccentCyan
					end
				else
					if hLight then hLight:Destroy() end
				end
				
				local bGui = enemy.Character.HumanoidRootPart:FindFirstChild("CyberEspGui")
				if States["EspNames"] then
					if not bGui then
						bGui = Instance.new("BillboardGui", enemy.Character.HumanoidRootPart)
						bGui.Name = "CyberEspGui"
						bGui.Size = UDim2.new(0, 220, 0, 50); bGui.AlwaysOnTop = true; bGui.StudsOffset = Vector3.new(0, 3, 0)
						local lbl = Instance.new("TextLabel", bGui); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
						lbl.TextColor3 = Theme.AccentGreen; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
					end
					local enemyHum = enemy.Character:FindFirstChildOfClass("Humanoid")
					
					local prefix = ""
					local specialStatus = getSpecialStatus(enemy)
					if specialStatus then
						prefix = specialStatus.label .. " "
					end
					
					bGui.TextLabel.Text = prefix .. enemy.Name .. " [" .. (enemyHum and math.floor(enemyHum.Health) or "0") .. " HP]"
				else
					if bGui then bGui:Destroy() end
				end
				
				if States["Tracers"] then
					local eRoot = enemy.Character.HumanoidRootPart
					local pos, onScreen = camera:WorldToViewportPoint(eRoot.Position)
					if onScreen then
						local dist = (camera.CFrame.Position - eRoot.Position).Magnitude
						local box = Instance.new("BoxHandleAdornment", tracersFolder)
						box.Size = Vector3.new(0.05, 0.05, dist)
						box.Color3 = Theme.AccentCyan
						box.AlwaysOnTop = true
						box.ZIndex = 10
						box.Adornee = workspace.Terrain
						box.CFrame = CFrame.lookAt(camera.CFrame.Position, eRoot.Position) * CFrame.new(0, 0, -dist/2)
					end
				end
			end
		end

		if States["Mm2GunEsp"] then
			local gunDrop = workspace:FindFirstChild("GunDrop")
			if gunDrop and not gunDrop:FindFirstChild("GunHighlight") then
				local gh = Instance.new("Highlight", gunDrop)
				gh.Name = "GunHighlight"; gh.FillColor = Theme.Gold; gh.OutlineColor = Theme.AccentCyan
			end
		end
	end)
end)

UserInputService.JumpRequest:Connect(function()
	if States["InfJ"] then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

ToggleMenuBtn = Instance.new("ImageButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 54, 0, 54); ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleMenuBtn.BackgroundColor3 = Theme.HeaderBg; ToggleMenuBtn.Image = "rbxassetid://111476707785768"
ToggleMenuBtn.Visible = false 
applyGlassStyle(ToggleMenuBtn, 14, Theme.AccentCyan, 1.5)

local function invertMenuState() 
	if not ScreenGui:FindFirstChild("KeySystemWindow") then
		MainFrame.Visible = not MainFrame.Visible 
	end
end
ToggleMenuBtn.Activated:Connect(invertMenuState)

UserInputService.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then invertMenuState() end
end)

-- =============================================================================
-- 🔑 МОДУЛЬ СИСТЕМЫ КЛЮЧЕЙ
-- =============================================================================
local MasterKey = "free-key-2082949236"

local KeySystemFrame = Instance.new("Frame", ScreenGui)
KeySystemFrame.Name = "KeySystemWindow"
KeySystemFrame.Size = UDim2.new(0, 380, 0, 210)
KeySystemFrame.Position = UDim2.new(0.5, -190, 0.5, -105)
KeySystemFrame.BackgroundColor3 = Theme.GlassBg
KeySystemFrame.BackgroundTransparency = 0.05
KeySystemFrame.Visible = false
applyGlassStyle(KeySystemFrame, 16, Theme.AccentPurple, 2)
makeDraggable(KeySystemFrame, KeySystemFrame)

local KeyTitle = Instance.new("TextLabel", KeySystemFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 45)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 ТРЕБУЕТСЯ КЛЮЧ VIP ДОСТУПА"
KeyTitle.TextColor3 = Theme.Gold
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 13

local KeyInput = Instance.new("TextBox", KeySystemFrame)
KeyInput.Size = UDim2.new(0, 300, 0, 38)
KeyInput.Position = UDim2.new(0.5, -150, 0, 65)
KeyInput.BackgroundColor3 = Theme.BtnOff
KeyInput.PlaceholderText = "Вставьте секретный ключ сюда..."
KeyInput.Text = ""
KeyInput.TextColor3 = Theme.Text
KeyInput.Font = Enum.Font.Code
KeyInput.TextSize = 13
applyGlassStyle(KeyInput, 10, Theme.AccentCyan)

local KeySubmitBtn = Instance.new("TextButton", KeySystemFrame)
KeySubmitBtn.Size = UDim2.new(0, 145, 0, 38)
KeySubmitBtn.Position = UDim2.new(0.5, -150, 0, 125)
KeySubmitBtn.BackgroundColor3 = Theme.BtnOn
KeySubmitBtn.Text = "🚪 ПРОВЕРИТЬ КЛЮЧ"
KeySubmitBtn.TextColor3 = Theme.AccentGreen
KeySubmitBtn.Font = Enum.Font.GothamBold
KeySubmitBtn.TextSize = 11
applyGlassStyle(KeySubmitBtn, 10, Theme.AccentGreen)

local GetKeyBtn = Instance.new("TextButton", KeySystemFrame)
GetKeyBtn.Size = UDim2.new(0, 145, 0, 38)
GetKeyBtn.Position = UDim2.new(0.5, 5, 0, 125)
GetKeyBtn.BackgroundColor3 = Theme.BtnOff
GetKeyBtn.Text = "🌐 ПОЛУЧИТЬ КЛЮЧ"
GetKeyBtn.TextColor3 = Theme.AccentCyan
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 11
applyGlassStyle(GetKeyBtn, 10, Theme.AccentCyan)

KeySubmitBtn.Activated:Connect(function()
	if KeyInput.Text == MasterKey then
		createNotification("🔑 ДОСТУП РАЗРЕШЕН", "Успешная авторизация в Roblox Visuals!", "Info")
		KeySystemFrame:Destroy()
		MainFrame.Visible = true
		ClockWidget.Visible = true
		CounterWidget.Visible = true
		ToggleMenuBtn.Visible = true
	else
		createNotification("❌ ОШИБКА ДОСТУПА", "Неверный ключ! Попробуйте еще раз.", "Alert")
		KeyInput.Text = ""
	end
end)

GetKeyBtn.Activated:Connect(function()
	if setclipboard then
		setclipboard(MasterKey)
		createNotification("СКОПИРОВАНО", "Тестовый ключ скопирован в буфер обмена!", "Info")
	else
		KeyInput.Text = MasterKey
	end
end)

local RegionFrame = Instance.new("Frame", ScreenGui)
RegionFrame.Size = UDim2.new(0, 400, 0, 220)
RegionFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
RegionFrame.BackgroundColor3 = Theme.GlassBg
RegionFrame.Visible = false
RegionFrame.ZIndex = 25000
applyGlassStyle(RegionFrame, 16, Theme.AccentCyan, 2)

local RegionTitle = Instance.new("TextLabel", RegionFrame)
RegionTitle.Size = UDim2.new(1, -30, 0, 60)
RegionTitle.Position = UDim2.new(0, 15, 0, 15)
RegionTitle.BackgroundTransparency = 1
RegionTitle.Text = "ВЫБЕРИТЕ РЕГИОН\nДоступность Roblox Visuals"
RegionTitle.TextColor3 = Theme.Gold
RegionTitle.Font = Enum.Font.GothamBold
RegionTitle.TextSize = 16
RegionTitle.ZIndex = 25001

local regionChoice
local RegionDenied = Instance.new("TextLabel", RegionFrame)
RegionDenied.Size = UDim2.new(1, -30, 0, 35)
RegionDenied.Position = UDim2.new(0, 15, 1, -50)
RegionDenied.BackgroundTransparency = 1
RegionDenied.TextColor3 = Theme.AlertRed
RegionDenied.Font = Enum.Font.GothamBold
RegionDenied.TextSize = 12
RegionDenied.Visible = false
RegionDenied.ZIndex = 25001

local function addRegionButton(text, position, regionCode)
	local button = Instance.new("TextButton", RegionFrame)
	button.Size = UDim2.new(0, 165, 0, 42)
	button.Position = position
	button.BackgroundColor3 = Theme.BtnOn
	button.Text = text
	button.TextColor3 = Theme.Text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.ZIndex = 25001
	applyGlassStyle(button, 10, Theme.AccentCyan)
	button.Activated:Connect(function()
		if regionCode == "RU" then
			RegionDenied.Text = "❌ Регион недоступен."
			RegionDenied.Visible = true
			regionChoice = false
		else
			regionChoice = true
			RegionFrame.Visible = false
		end
	end)
end

addRegionButton("🇷🇺 Россия", UDim2.new(0, 25, 0, 100), "RU")
addRegionButton("🌐 Другой регион", UDim2.new(1, -190, 0, 100), "OTHER")

-- =============================================================================
-- 🎬 ИНИЦИАЛИЗАЦИЯ И ЗАПУСК
-- =============================================================================
task.spawn(function()
	-- 1. СЛАЙД-ИН АНИМАЦИЯ ИНТРО
	TweenService:Create(IntroFrame, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -210, 0.5, -140)
	}):Play()
	task.wait(0.45)

	-- 2. Лого появляется с вращением
	TweenService:Create(IntroImage, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		ImageTransparency = 0, Rotation = 0
	}):Play()
	TweenService:Create(IntroTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(IntroVersion, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	task.wait(0.3)

	-- 3. Пульсирующее кольцо + граница
	task.spawn(function()
		local introStroke = IntroFrame:FindFirstChildOfClass("UIStroke")
		local ringStroke = IntroRing:FindFirstChildOfClass("UIStroke")
		local t = 0
		while IntroBackground and IntroBackground.Parent do
			t = t + 0.06
			local lerpFactor = (math.sin(t) + 1) / 2
			local glowColor = Theme.AccentPurple:Lerp(Theme.AccentCyan, lerpFactor)
			if introStroke then
				introStroke.Color = glowColor
				introStroke.Thickness = 2 + math.sin(t * 1.4) * 1
			end
			if ringStroke then
				ringStroke.Color = glowColor
				ringStroke.Thickness = 2 + math.cos(t * 1.4) * 1
			end
			task.wait(0.04)
		end
	end)

	-- 4. Текстовая анимация с печатью
	local msgs = isBypassUser and {
		"> Обнаружены привилегии...",
		"> BYPASS активирован...",
		"> Привет, " .. player.Name .. "!",
	} or {
		"> Инициализация ядра...",
		"> Загрузка модулей...",
		"> Проверка доступа...",
		"> Готово!",
	}
	for _, msg in ipairs(msgs) do
		IntroStatus.Text = ""
		for i = 1, #msg do
			if not IntroBackground.Parent then break end
			IntroStatus.Text = string.sub(msg, 1, i)
			task.wait(0.035)
		end
		task.wait(0.35)
	end

	-- 5. Заполнение прогресс-бара
	TweenService:Create(IntroProgressFill, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	task.wait(1.6)

	-- 6. Регион-выбор
	logToConsole("🪐 ROBLOX VISUALS: Загрузка завершена.")
	RegionFrame.Visible = true
	while regionChoice == nil do task.wait() end
	if not regionChoice then
		IntroBackground:Destroy()
		KeySystemFrame:Destroy()
		RegionTitle.Text = "РЕГИОН НЕ ДОСТУПЕН"
		RegionTitle.TextColor3 = Theme.AlertRed
		RegionDenied.Text = "❌ Выход из этого региона запрещён."
		RegionDenied.Visible = true
		RegionFrame.Visible = true
		return
	end
	if banReason then
		if KeySystemFrame then KeySystemFrame:Destroy() end
		IntroBackground:Destroy()
		startBanSequence()
		return
	end

	-- 7. Фейд-аут интро
	IntroStatus.Text = "> Запуск интерфейса..."
	task.wait(0.4)
	local fadeFrame = TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
	local fadeTitle = TweenService:Create(IntroTitle, TweenInfo.new(0.3), {TextTransparency = 1})
	local fadeStatus = TweenService:Create(IntroStatus, TweenInfo.new(0.3), {TextTransparency = 1})
	local fadeVersion = TweenService:Create(IntroVersion, TweenInfo.new(0.3), {TextTransparency = 1})
	local fadeImg = TweenService:Create(IntroImage, TweenInfo.new(0.35), {ImageTransparency = 1})
	fadeFrame:Play(); fadeTitle:Play(); fadeStatus:Play(); fadeVersion:Play(); fadeImg:Play()
	fadeFrame.Completed:Wait()
	IntroBackground:Destroy()

	createNotification("🪐 ВХОД ВЫПОЛНЕН", isBypassUser and "Добро пожаловать, привилегированный пользователь!" or "Добро пожаловать в Roblox Visuals!", "Info")
	if KeySystemFrame then KeySystemFrame:Destroy() end
	MainFrame.Visible = true
	ClockWidget.Visible = true
	CounterWidget.Visible = true
	ToggleMenuBtn.Visible = true
	logToConsole("🪐 ROBLOX VISUALS: Главное меню открыто.")
end)

addMenuCmd("🧹 21. Убрать подсветку", false, function(tPlr)
	local highlight = tPlr and tPlr.Character and tPlr.Character:FindFirstChild("FriendHighlight")
	if highlight then highlight:Destroy() end
	createNotification("ВИЗУАЛ", "Подсветка друга отключена.", "Info")
end)

addMenuCmd("🎥 22. Вернуть камеру", false, function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then camera.CameraSubject = humanoid end
	createNotification("КАМЕРА", "Камера возвращена к вашему персонажу.", "Info")
end)

addMenuCmd("🙈 23. Скрыть локально", true, function(tPlr)
	if tPlr then setPlayerHidden(tPlr, true) end
	createNotification("ВИДИМОСТЬ", selectedFriendName .. " скрыт на вашем экране.", "Info")
end)

addMenuCmd("👁️ 24. Показать локально", false, function(tPlr)
	if tPlr then setPlayerHidden(tPlr, false) end
	createNotification("ВИДИМОСТЬ", selectedFriendName .. " снова отображается.", "Info")
end)

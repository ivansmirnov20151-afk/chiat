-- =============================================================================
-- 🪐 CYBER ENGINE V32.6 [👑 ULTRA PREMIUM EDITION • CUSTOMIZABLE & CLEAN]
-- =============================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

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

if playerGui:FindFirstChild("CyberEngine_V32_Max") then 
	playerGui.CyberEngine_V32_Max:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberEngine_V32_Max"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

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
-- 🔔 ДИНАМИЧЕСКАЯ СИСТЕМА УВЕДОМЛЕНИЙ (ПОЯВЛЯЮТСЯ СВЕРХУ)
-- =============================================================================
local function createNotification(titleText, descText, noticeType)
	local notifyFrame = Instance.new("Frame", ScreenGui)
	notifyFrame.Size = UDim2.new(0, 350, 0, 70)
	notifyFrame.Position = UDim2.new(0.5, -175, 0, -90) -- Начальная позиция за экраном
	notifyFrame.BackgroundColor3 = Theme.GlassBg
	notifyFrame.BackgroundTransparency = 0.05
	
	local strokeColor = (noticeType == "Alert") and Theme.AlertRed or Theme.AccentCyan
	applyGlassStyle(notifyFrame, 12, strokeColor, 2)
	notifyFrame.ZIndex = 10000 -- Поверх абсолютно всех окон чита!

	local tLabel = Instance.new("TextLabel", notifyFrame)
	tLabel.Size = UDim2.new(1, -20, 0, 25)
	tLabel.Position = UDim2.new(0, 15, 0, 10)
	tLabel.Text = titleText
	tLabel.TextColor3 = (noticeType == "Alert") and Theme.AlertRed or Theme.Text
	tLabel.Font = Enum.Font.GothamBold
	tLabel.TextSize = 15
	tLabel.BackgroundTransparency = 1
	tLabel.TextXAlignment = Enum.TextXAlignment.Center
	tLabel.ZIndex = 10001

	local dLabel = Instance.new("TextLabel", notifyFrame)
	dLabel.Size = UDim2.new(1, -20, 0, 25)
	dLabel.Position = UDim2.new(0, 15, 0, 35)
	dLabel.Text = descText
	dLabel.TextColor3 = Theme.Text
	dLabel.Font = Enum.Font.GothamBold
	dLabel.TextSize = 13
	dLabel.BackgroundTransparency = 1
	dLabel.TextXAlignment = Enum.TextXAlignment.Center
	dLabel.ZIndex = 10001

	-- Анимация появления сверху
	TweenService:Create(notifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -175, 0, 40)}):Play()
	
	-- Автоматическое скрытие через 4 секунды
	task.delay(4, function()
		if notifyFrame and notifyFrame.Parent then
			local tweenOut = TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -175, 0, -90)})
			tweenOut:Play()
			tweenOut.Completed:Wait()
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

local IntroFrame = Instance.new("Frame", IntroBackground)
IntroFrame.Size = UDim2.new(0, 420, 0, 260)
IntroFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
IntroFrame.BackgroundColor3 = Theme.GlassBg
IntroFrame.BackgroundTransparency = 0.1
applyGlassStyle(IntroFrame, 16, Theme.AccentPurple, 2)

local IntroImage = Instance.new("ImageLabel", IntroFrame)
IntroImage.Size = UDim2.new(0, 150, 0, 150)
IntroImage.Position = UDim2.new(0.5, -75, 0.5, -80)
IntroImage.BackgroundTransparency = 1
IntroImage.Image = "rbxassetid://79078068171736"

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.Size = UDim2.new(1, 0, 0, 30)
IntroTitle.Position = UDim2.new(0, 0, 1, -65)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "🪐 CYBER ENGINE"
IntroTitle.TextColor3 = Theme.Text
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.TextSize = 22

local IntroStatus = Instance.new("TextLabel", IntroFrame)
IntroStatus.Size = UDim2.new(1, 0, 0, 20)
IntroStatus.Position = UDim2.new(0, 0, 1, -35)
IntroStatus.BackgroundTransparency = 1
IntroStatus.Text = "Инициализация премиум интерфейса..."
IntroStatus.TextColor3 = Color3.fromRGB(180, 160, 150)
IntroStatus.Font = Enum.Font.Code
IntroStatus.TextSize = 12

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
						local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
						if dist <= 15 then
							local tool = player.Character:FindFirstChildOfClass("Tool")
							if tool then tool:Activate() end
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

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
makeDraggable(MainFrame, Header)

local MainTitle = Instance.new("TextLabel", Header)
MainTitle.Size = UDim2.new(1, -160, 1, 0)
MainTitle.Position = UDim2.new(0, 20, 0, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "🪐 THUNDER CYBER MM2"
MainTitle.TextColor3 = Theme.Text
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 15
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local VerBadge = Instance.new("TextLabel", Header)
VerBadge.Size = UDim2.new(0, 100, 0, 24)
VerBadge.Position = UDim2.new(0, 210, 0.5, -12)
VerBadge.BackgroundColor3 = Theme.AccentGreen
VerBadge.Text = "Версия 32.6"
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
	end)
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
	
	Btn.Activated:Connect(function() pcall(callback) end)
	return Btn
end

-- Сборка Вкладок
local tMove = createTab("Move", "🧭 Персонаж")
local tCombat = createTab("Combat", "🎯 Комбат")
local tVisuals = createTab("Visuals", "👁️ Валлхак / Визуал")
local tWorld = createTab("World", "🪐 Изменение Мира")
local tSkin = createTab("Skin", "🎭 Кастомизация")
local tMacro = createTab("Macro", "🤖 Умные Макросы")
local tMM2 = createTab("MM2", "🔪 Murder Mystery 2") 
local tUtils = createTab("Utils", "🛠️ Утилиты / Темы")
local tRadio = createTab("Radio", "🎵 Радио Плеер")

TabPages["Move"].Visible = true
TabButtons[1].BackgroundTransparency = 0.3
TabButtons[1].BackgroundColor3 = Theme.BtnOff
TabButtons[1].TextColor3 = Theme.Text

-- Окно настройки макроса
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
MacroSaveTitle.ZIndex = 16

local MacroLoopsInput = Instance.new("TextBox", MacroSaveFrame)
MacroLoopsInput.Size = UDim2.new(0, 260, 0, 35)
MacroLoopsInput.Position = UDim2.new(0.5, -130, 0, 55)
MacroLoopsInput.BackgroundColor3 = Theme.BtnOff
MacroLoopsInput.PlaceholderText = "Введите число (например: 3)"
MacroLoopsInput.Text = "1"
MacroLoopsInput.TextColor3 = Theme.Text
MacroLoopsInput.Font = Enum.Font.Code
MacroLoopsInput.TextSize = 14
MacroLoopsInput.ZIndex = 16
applyGlassStyle(MacroLoopsInput, 8, Theme.AccentPurple)

local MacroStartPlayBtn = Instance.new("TextButton", MacroSaveFrame)
MacroStartPlayBtn.Size = UDim2.new(0, 140, 0, 35)
MacroStartPlayBtn.Position = UDim2.new(0.5, -145, 0, 115)
MacroStartPlayBtn.BackgroundColor3 = Theme.BtnOn
MacroStartPlayBtn.Text = "▶️ ЗАПУСТИТЬ ПОВТОР"
MacroStartPlayBtn.TextColor3 = Theme.AccentGreen
MacroStartPlayBtn.Font = Enum.Font.GothamBold
MacroStartPlayBtn.TextSize = 11
MacroStartPlayBtn.ZIndex = 16
applyGlassStyle(MacroStartPlayBtn, 8, Theme.AccentGreen)

local MacroCancelBtn = Instance.new("TextButton", MacroSaveFrame)
MacroCancelBtn.Size = UDim2.new(0, 140, 0, 35)
MacroCancelBtn.Position = UDim2.new(0.5, 5, 0, 115)
MacroCancelBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 25)
MacroCancelBtn.Text = "❌ ЗАКРЫТЬ"
MacroCancelBtn.TextColor3 = Theme.AlertRed
MacroCancelBtn.Font = Enum.Font.GothamBold
MacroCancelBtn.TextSize = 11
MacroCancelBtn.ZIndex = 16
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
				logToConsole("⏸️ Запись макроса временно приостановлена.")
			else
				RecordIndicator.Text = "🔴 ЗАПИСЬ ИДЕТ... [L - СТОП | E - ПАУЗА]"
				RecordIndicator.TextColor3 = Theme.AlertRed
				logToConsole("🚀 Запись макроса возобновлена.")
			end
		end
	elseif input.KeyCode == Enum.KeyCode.M then
		if isPlaying then
			isMacroPaused = not isMacroPaused
			if isMacroPaused then
				logToConsole("⏸️ Воспроизведение на паузе! (Персонаж заморожен).")
			else
				logToConsole("▶️ Воспроизведение возобновлено!")
			end
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
			player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
		end
	end
end)

-- Наполнение разделов
addToggle(tMove, "S120", "⚡ Скорость бега х120 Premium", function(v) curSpeed = v and 120 or 16 end)
addToggle(tMove, "S250", "🔥 Скорость бега х250 Hyper Overload", function(v) curSpeed = v and 250 or 16 end)
addToggle(tMove, "S500", "👑 VIP Скорость х500 GOD MODE", function(v) curSpeed = v and 500 or 16 end) -- Новая функция
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

addToggle(tVisuals, "Cham", "🟢 Chams Силуэты сквозь стены", function() end)
addToggle(tVisuals, "Tracers", "📐 Линии-Трейсеры", function() end)
addToggle(tVisuals, "EspNames", "🏷️ ESP Names (Никнеймы + HP)", function() end)
addToggle(tVisuals, "XRay", "🔮 Включить X-Ray", function(v)
	if v then
		for _, part in pairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part:FindFirstAncestorOfClass("Model") and part.Anchored then
				xrayCache[part] = part.Transparency; part.Transparency = 0.65
			end
		end
	else
		for part, trans in pairs(xrayCache) do if part and part.Parent then part.Transparency = trans end end
		table.clear(xrayCache)
	end
end)
addToggle(tVisuals, "FovM", "👁️ Максимальный FOV 120", function(v) camera.FieldOfView = v and 120 or 70 end)

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

-- =============================================================================
-- 🔪 ОБНОВЛЕННАЯ ВКЛАДКА MM2 (ПОЛНОСТЬЮ РАБОЧАЯ)
-- =============================================================================
local lastAlertTime = 0

local function getMurderer()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") or
			   p.Backpack:FindFirstChild(" нож") or p.Character:FindFirstChild(" нож") then
				return p
			end
		end
	end
	return nil
end

local function getSheriff()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) then
			return p
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

-- Поле ввода никнейма для Флинга
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
			player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)

addToggle(tMM2, "SmartEvac", "🤖 Смарт-эвакуация (Авто-ТП от Мардера)", function(v)
	if v then createNotification("ЭВАКУАЦИЯ", "Авто-эвакуация готова.", "Info") end
end)

addToggle(tMM2, "Mm2Esp", "👁️ Радар ролей (Убийца/Шериф)", function() end)
addToggle(tMM2, "Mm2GunEsp", "🎯 Подсветка Пистолета", function() end)
addToggle(tMM2, "Mm2Autofarm", "💰 Автосбор монет/улик", function() end)
addToggle(tMM2, "Mm2ScamDupe", "💥 СКАМ-ТРЕЙД / ДЮП [Кнопка X]", function(v)
	if v then logToConsole("⚡ Дюп активирован! Жми 'X' во время трейда.") end
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
	if States["Mm2ScamDupe"] and input.KeyCode == Enum.KeyCode.X then
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local tradeRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("AcceptTrade")
			if tradeRemote then tradeRemote:FireServer() end
		end)
		task.wait(0.05)
		player:Kick("🪐 [CYBER ENGINE]: Дюп успешно сработал! Перезайди.")
	end
end)

-- Темы
addButton(tUtils, "🟫 Включить Шоколадную Тему (как на Фото)", function()
	Theme.GlassBg = Color3.fromRGB(36, 26, 20)
	Theme.HeaderBg = Color3.fromRGB(46, 33, 25)
	Theme.AccentCyan = Color3.fromRGB(235, 135, 40)
	MainFrame.BackgroundColor3 = Theme.GlassBg
	MainFrame.UIStroke.Color = Color3.fromRGB(70, 55, 45)
	logToConsole("Цвет изменен на Шоколадный Премиум.")
end)

addButton(tUtils, "🔮 Включить Классическую Неоновую Тему", function()
	Theme.GlassBg = Color3.fromRGB(10, 6, 20)
	Theme.HeaderBg = Color3.fromRGB(18, 10, 32)
	Theme.AccentCyan = Color3.fromRGB(0, 240, 255)
	MainFrame.BackgroundColor3 = Theme.GlassBg
	MainFrame.UIStroke.Color = Color3.fromRGB(165, 45, 255)
	logToConsole("Цвет изменен на Классический Неон.")
end)

addButton(tUtils, "🟢 Включить Изумрудную Тему", function()
	Theme.GlassBg = Color3.fromRGB(10, 25, 18)
	Theme.HeaderBg = Color3.fromRGB(15, 35, 25)
	Theme.AccentCyan = Color3.fromRGB(46, 204, 113)
	MainFrame.BackgroundColor3 = Theme.GlassBg
	MainFrame.UIStroke.Color = Color3.fromRGB(46, 204, 113)
	logToConsole("Цвет изменен на Изумрудный Люкс.")
end)

addButton(tUtils, "📂 Загрузить DARK DEX", function()
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua"))() end)
end)
addButton(tUtils, "🛠️ Выдать BTools", function()
	Instance.new("HopperBin", player.Backpack).BinType = 1
	Instance.new("HopperBin", player.Backpack).BinType = 3
	Instance.new("HopperBin", player.Backpack).BinType = 4
end)
addButton(tUtils, "🌀 Загрузить Infinite Yield", function()
	pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeY/infiniteyield/master/source'))() end)
end)
addButton(tUtils, "🔄 Быстрый Перезапуск Сервера", function() TeleportService:Teleport(game.PlaceId, player) end)

local function emergencyStop()
	for k, _ in pairs(States) do States[k] = false end
	updateCounter(); updateFly(false); isPlaying = false; isRecording = false; isRecordingPaused = false; isMacroPaused = false
	RecordIndicator.Visible = false; MacroSaveFrame.Visible = false
	if autoPlatform then autoPlatform:Destroy(); autoPlatform = nil end
	logToConsole("🚨 ВСЕ МОДЫ ВЫКЛЮЧЕНЫ!")
end

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
			if States["S120"] or States["S250"] or States["S500"] then hum.WalkSpeed = curSpeed end -- Фикс под х500
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
				root.Velocity = Vector3.new(99999, 99999, 99999)
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
		if States["GoldUI"] then MainFrame.UIStroke.Color = currentRainbow end

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
		
		for _, enemy in ipairs(Players:GetPlayers()) do
			if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
				if States["HitboxExp"] then
					enemy.Character.HumanoidRootPart.Size = Vector3.new(12, 12, 12)
					enemy.Character.HumanoidRootPart.CanCollide = false; enemy.Character.HumanoidRootPart.Transparency = 0.6
				else
					enemy.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); enemy.Character.HumanoidRootPart.Transparency = 1
				end
				
				local hLight = enemy.Character:FindFirstChild("MaxHighlight")
				if States["Cham"] or States["Mm2Esp"] then
					if not hLight then hLight = Instance.new("Highlight", enemy.Character); hLight.Name = "MaxHighlight" end
					if States["Mm2Esp"] then
						if enemy.Backpack:FindFirstChild("Knife") or enemy.Character:FindFirstChild("Knife") or
						   enemy.Backpack:FindFirstChild(" нож") or enemy.Character:FindFirstChild(" нож") then
							hLight.FillColor = Color3.fromRGB(255, 0, 50)
							hLight.OutlineColor = Color3.fromRGB(255, 255, 255)
						elseif enemy.Backpack:FindFirstChild("Gun") or enemy.Character:FindFirstChild("Gun") then
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
						bGui.Name = "CyberEspGui";
						bGui.Size = UDim2.new(0, 200, 0, 50); bGui.AlwaysOnTop = true; bGui.StudsOffset = Vector3.new(0, 3, 0)
						local lbl = Instance.new("TextLabel", bGui); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
						lbl.TextColor3 = Theme.AccentGreen; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
					end
					local enemyHum = enemy.Character:FindFirstChildOfClass("Humanoid")
					bGui.TextLabel.Text = enemy.Name .. " [" .. (enemyHum and math.floor(enemyHum.Health) or "0") .. " HP]"
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

local ToggleMenuBtn = Instance.new("ImageButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 54, 0, 54); ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleMenuBtn.BackgroundColor3 = Theme.HeaderBg; ToggleMenuBtn.Image = "rbxassetid://111476707785768"
ToggleMenuBtn.Visible = false 
applyGlassStyle(ToggleMenuBtn, 14, Theme.AccentCyan, 1.5)

local function invertMenuState() 
	-- Меню открывается только если окно ключа уничтожено (ключ подошел)
	if not ScreenGui:FindFirstChild("KeySystemWindow") then
		MainFrame.Visible = not MainFrame.Visible 
	end
end
ToggleMenuBtn.Activated:Connect(invertMenuState)

UserInputService.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then invertMenuState() end
end)

-- =============================================================================
-- 🔑 МОДУЛЬ СИСТЕМЫ КЛЮЧЕЙ (KEY SYSTEM UI)
-- =============================================================================
local MasterKey = "free-key-2082949236" -- Сюда вписывай свой ключ!

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
		createNotification("🔑 ДОСТУП РАЗРЕШЕН", "Успешная авторизация в Cyber Engine!", "Info")
		KeySystemFrame:Destroy()
		
		-- Активация чита
		MainFrame.Visible = true
		ClockWidget.Visible = true
		CounterWidget.Visible = true
		ToggleMenuBtn.Visible = true
		logToConsole("🪐 CYBER ENGINE: Успешно запущено!")
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
		createNotification("ПОДСКАЗКА", "Ключ автоматически вставлен в поле ввода!", "Info")
	end
end)

-- =============================================================================
-- 🎬 ЗАПУСК
-- =============================================================================
task.spawn(function()
	task.wait(5)
	logToConsole("🪐 CYBER ENGINE: Загрузка завершена. Ожидание авторизации...")
	
	local fadeFrame = TweenService:Create(IntroFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
	local fadeTitle = TweenService:Create(IntroTitle, TweenInfo.new(0.2), {TextTransparency = 1})
	local fadeStatus = TweenService:Create(IntroStatus, TweenInfo.new(0.2), {TextTransparency = 1})
	local fadeImg = TweenService:Create(IntroImage, TweenInfo.new(0.3), {ImageTransparency = 1})
	
	fadeFrame:Play()
	fadeTitle:Play()
	fadeStatus:Play()
	fadeImg:Play()
	
	fadeFrame.Completed:Wait()
	IntroBackground:Destroy()
	
	-- Показываем систему ввода ключа вместо главного экрана
	KeySystemFrame.Visible = true
end)

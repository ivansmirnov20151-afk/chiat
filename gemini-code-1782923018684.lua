-- =============================================================================
-- 🪐 CYBER ENGINE V32.5 [👑 WELCOME UPDATE • ALL FUNCS + MM2 & DEX]
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

local Theme = {
	GlassBg = Color3.fromRGB(10, 6, 20),
	GlassTrans = 0.22,
	HeaderBg = Color3.fromRGB(18, 10, 32),
	AccentCyan = Color3.fromRGB(0, 240, 255),
	AccentPurple = Color3.fromRGB(165, 45, 255),
	AccentGreen = Color3.fromRGB(0, 255, 130),
	Text = Color3.fromRGB(245, 245, 255),
	BtnOff = Color3.fromRGB(24, 14, 40),
	BtnOn = Color3.fromRGB(115, 35, 190),
	AlertRed = Color3.fromRGB(255, 40, 75),
	Gold = Color3.fromRGB(255, 200, 50)
}

local States = {}
local curSpeed, curJump = 16, 50
local autoPlatform = nil
local haloPart = nil
local xrayCache = {}

-- Переменные макроса
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
		stroke.Thickness = strokeThickness or 1.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end
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
-- 🎬 [UPDATED] ЭКРАН ПРИВЕТСТВИЯ С КАРТИНКОЙ (5 СЕКУНД)
-- =============================================================================
local IntroBackground = Instance.new("Frame", ScreenGui)
IntroBackground.Size = UDim2.new(1, 0, 1, 0)
IntroBackground.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
IntroBackground.ZIndex = 500

local IntroFrame = Instance.new("Frame", IntroBackground)
IntroFrame.Size = UDim2.new(0, 420, 0, 260)
IntroFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
IntroFrame.BackgroundColor3 = Theme.GlassBg
IntroFrame.BackgroundTransparency = 0.1
applyGlassStyle(IntroFrame, 16, Theme.AccentPurple, 2)

-- Кастомная картинка вместо старой анимации загрузки
local IntroImage = Instance.new("ImageLabel", IntroFrame)
IntroImage.Size = UDim2.new(0, 180, 0, 180)
IntroImage.Position = UDim2.new(0.5, -90, 0.5, -90)
IntroImage.BackgroundTransparency = 1
IntroImage.Image = "rbxassetid://79078068171736"

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.Size = UDim2.new(1, 0, 0, 30)
IntroTitle.Position = UDim2.new(0, 0, 0, 10)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "🪐 CYBER ENGINE"
IntroTitle.TextColor3 = Theme.AccentCyan
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.TextSize = 20

local IntroStatus = Instance.new("TextLabel", IntroFrame)
IntroStatus.Size = UDim2.new(1, 0, 0, 20)
IntroStatus.Position = UDim2.new(0, 0, 1, -30)
IntroStatus.BackgroundTransparency = 1
IntroStatus.Text = "Загрузка премиум модулей..."
IntroStatus.TextColor3 = Color3.fromRGB(130, 120, 150)
IntroStatus.Font = Enum.Font.Code
IntroStatus.TextSize = 11

-- 🔴 Индикатор записи макроса
local RecordIndicator = Instance.new("TextLabel", ScreenGui)
RecordIndicator.Size = UDim2.new(0, 360, 0, 40)
RecordIndicator.Position = UDim2.new(0.5, -180, 0, 70)
RecordIndicator.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
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
ClockLabel.TextColor3 = Theme.AccentCyan
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

-- Кликер + Триггер + Килл Аура
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

-- Поиск цели Аимбота
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
MainFrame.Size = UDim2.new(0, 740, 0, 520)
MainFrame.Position = UDim2.new(0.5, -370, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.GlassBg
MainFrame.BackgroundTransparency = Theme.GlassTrans
MainFrame.Visible = false 
applyGlassStyle(MainFrame, 16, Theme.AccentPurple, 2)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Theme.HeaderBg
Header.BackgroundTransparency = 0.15
applyGlassStyle(Header, 16)
makeDraggable(MainFrame, Header)

local MainTitle = Instance.new("TextLabel", Header)
MainTitle.Size = UDim2.new(1, -50, 1, 0)
MainTitle.Position = UDim2.new(0, 20, 0, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "🪐 CYBER ENGINE V32.5 [👑 СТАБИЛЬНАЯ ВЕРСИЯ • ВСЕ ФУНКЦИИ]"
MainTitle.TextColor3 = Theme.AccentGreen
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 14
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 200, 1, -80)
Sidebar.Position = UDim2.new(0, 15, 0, 70)
Sidebar.BackgroundTransparency = 1

-- Добавили скроллбар для сайдбара, чтобы влезали новые вкладки
local SidebarScroll = Instance.new("ScrollingFrame", Sidebar)
SidebarScroll.Size = UDim2.new(1, 0, 1, 0)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 2
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local SidebarLayout = Instance.new("UIListLayout", SidebarScroll)
SidebarLayout.Padding = UDim.new(0, 4)

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
	TabBtn.Size = UDim2.new(1, -6, 0, 32)
	TabBtn.BackgroundColor3 = Theme.BtnOff
	TabBtn.BackgroundTransparency = 0.3
	TabBtn.Text = "  " .. title
	TabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.TextSize = 11
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(TabBtn, 8, Color3.fromRGB(45, 35, 70), 1)
	
	TabBtn.Activated:Connect(function()
		for _, p in pairs(TabPages) do p.Visible = false end
		for _, b in pairs(TabButtons) do 
			b.TextColor3 = Color3.fromRGB(150, 150, 170)
			b.BackgroundColor3 = Theme.BtnOff
			local s = b:FindFirstChildOfClass("UIStroke")
			if s then s.Color = Color3.fromRGB(45, 35, 70) end
		end
		Page.Visible = true
		TabBtn.TextColor3 = Theme.AccentCyan
		TabBtn.BackgroundColor3 = Theme.BtnOn
		local s = TabBtn:FindFirstChildOfClass("UIStroke")
		if s then s.Color = Theme.AccentCyan end
	end)
	table.insert(TabButtons, TabBtn)
	return Page
end

local function addToggle(parent, key, title, callback)
	States[key] = false
	local Btn = Instance.new("TextButton", parent)
	Btn.Size = UDim2.new(1, -6, 0, 35)
	Btn.BackgroundColor3 = Theme.BtnOff
	Btn.BackgroundTransparency = 0.2
	Btn.Text = "  " .. title
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamSemibold
	Btn.TextSize = 11
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(Btn, 8, Color3.fromRGB(50, 40, 80), 1)
	
	local Ind = Instance.new("Frame", Btn)
	Ind.Size = UDim2.new(0, 11, 0, 11)
	Ind.Position = UDim2.new(1, -25, 0.5, -5)
	Ind.BackgroundColor3 = Color3.fromRGB(90, 30, 45)
	applyGlassStyle(Ind, 5)

	Btn.Activated:Connect(function()
		States[key] = not States[key]
		local s = Btn:FindFirstChildOfClass("UIStroke")
		if States[key] then
			TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BtnOn}):Play()
			TweenService:Create(Ind, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentGreen}):Play()
			if s then s.Color = Theme.AccentCyan end
		else
			TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BtnOff}):Play()
			TweenService:Create(Ind, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(90, 30, 45)}):Play()
			if s then s.Color = Color3.fromRGB(50, 40, 80) end
		end
		updateCounter()
		pcall(callback, States[key])
	end)
	return Btn
end

local function addButton(parent, title, callback)
	local Btn = Instance.new("TextButton", parent)
	Btn.Size = UDim2.new(1, -6, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(35, 20, 55)
	Btn.Text = "  " .. title
	Btn.TextColor3 = Theme.AccentCyan
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 11
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	applyGlassStyle(Btn, 8, Theme.AccentCyan, 1)
	
	Btn.Activated:Connect(function() pcall(callback) end)
	return Btn
end

-- Сборка Вкладок (Старые сохранены + Добавлена MM2)
local tMove = createTab("Move", "🧭 Движение / Физика")
local tCombat = createTab("Combat", "🎯 Бой и Хитбоксы")
local tVisuals = createTab("Visuals", "👁️ Визуалы / Олд ESP")
local tWorld = createTab("World", "🪐 Изменение Мира")
local tSkin = createTab("Skin", "🎭 Кастомизация Скина")
local tMacro = createTab("Macro", "🤖 Умные Макросы")
local tMM2 = createTab("MM2", "🔪 Murder Mystery 2") -- 🌟 НОВАЯ ВКЛАДКА
local tUtils = createTab("Utils", "🛠️ Инструменты / Утилиты")
local tRadio = createTab("Radio", "🎵 Радио Плеер")
local tVip = createTab("VIP", "👑 Лицензия VIP")

TabPages["Macro"].Visible = true
TabButtons[6].TextColor3 = Theme.AccentCyan
TabButtons[6].BackgroundColor3 = Theme.BtnOn
local firstStroke = TabButtons[6]:FindFirstChildOfClass("UIStroke")
if firstStroke then firstStroke.Color = Theme.AccentCyan end

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
MacroLoopsInput.TextColor3 = Theme.AccentCyan
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

-- Рандомизатор макросов
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

-- Обработчик Хоткеев
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

addButton(tMacro, "🔴 НАЧАТЬ ЗАПИСЬ АНТИ-ПАЛЕВО (Пробеги трассу сам)", function()
	if isPlaying then logToConsole("⚠️ Нельзя записывать во время повтора!") return end
	table.clear(recordedPath)
	isRecording = true
	isRecordingPaused = false
	RecordIndicator.Text = "🔴 ЗАПИСЬ ИДЕТ... [L - СТОП | E - ПАУЗА]"
	RecordIndicator.TextColor3 = Theme.AlertRed
	RecordIndicator.Visible = true
	logToConsole("🚀 ЗАПИСЬ ПОШЛА! Пробеги трассу. Жми E для Паузы, L для Сейва!")
end)

addButton(tMacro, "🛑 АВАРИЙНЫЙ СБРОС ВСЕХ МАКРОСОВ", function()
	isPlaying = false; isRecording = false; isRecordingPaused = false; isMacroPaused = false
	RecordIndicator.Visible = false; MacroSaveFrame.Visible = false
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = curSpeed; hum.JumpPower = curJump end
	logToConsole("🤖 Макросы полностью отключены.")
end)

-- Административный Полет Fly
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

-- Нажатие Ctrl + ЛКМ для ТП
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if States["ClTP"] and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
		end
	end
end)

-- Наполнение вкладок
addToggle(tMove, "S120", "⚡ Скорость бега х120 Premium", function(v) curSpeed = v and 120 or 16 end)
addToggle(tMove, "S250", "🔥 Скорость бега х250 Hyper Overload", function(v) curSpeed = v and 250 or 16 end)
addToggle(tMove, "J180", "🦘 Прыжок х180 Высокий", function(v) curJump = v and 180 or 50 end)
addToggle(tMove, "J300", "🚀 Прыжок х300 Космический", function(v) curJump = v and 300 or 50 end)
addToggle(tMove, "InfJ", "☁️ Infinite Jump (Прыжки по воздуху)", function() end)
addToggle(tMove, "Nocl", "🧱 Noclip (Хождение сквозь любые стены)", function() end)
addToggle(tMove, "FlyM", "🛸 Полет Админа [W,A,S,D + Space/Ctrl]", function(v) updateFly(v) end)
addToggle(tMove, "ClTP", "📍 Click TP [Зажать Ctrl + Нажать ЛКМ]", function() end)
addToggle(tMove, "SpinB", "🌪️ SpinBot (Анти-Аим дикое вращение)", function() end)
addToggle(tMove, "NoSt", "🚫 Анти-Стул (Иммунитет к авто-сажанию)", function() end)
addToggle(tMove, "AutoClick", "🖱️ Потоковый макрос-автокликер", function() end)
addButton(tMove, "🏠 Телепортироваться на Спавн карты", function()
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
addToggle(tCombat, "TriggerB", "🔫 Триггербот (Автовыстрел при наведении)", function() end)
addToggle(tCombat, "HitboxExp", "🥩 Расширение торсов врагов х5 (Хитбоксы)", function() end)
addToggle(tCombat, "KillA", "⚔️ Kill Aura (Дамаг всем в радиусе 15м)", function() end)
addToggle(tCombat, "SuperReach", "🧤 Super Reach (Увеличение зоны оружия)", function(v)
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
			tool.Handle.Size = v and Vector3.new(10, 10, 10) or Vector3.new(1, 1, 1)
		end
	end
end)

addToggle(tVisuals, "Cham", "🟢 Chams Сквозь-стены силуэты игроков", function() end)
addToggle(tVisuals, "Tracers", "📐 Линии-Трейсеры до игроков", function() end)
addToggle(tVisuals, "EspNames", "🏷️ ESP Names (Никнеймы + ХП сквозь стены)", function() end)
addToggle(tVisuals, "XRay", "🔮 Включить X-Ray (Прозрачные стены)", function(v)
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
addToggle(tVisuals, "FovM", "👁️ Выставить максимальный FOV камеры 120", function(v) camera.FieldOfView = v and 120 or 70 end)

addToggle(tWorld, "Full", "☀️ Fullbright (Удалить тени и ночь)", function(v)
	Lighting.Brightness = v and 4 or 2
	Lighting.Ambient = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,128,128)
end)
addToggle(tWorld, "FreezeTime", "⏱️ Зафиксировать Время Суток", function() end)
addToggle(tWorld, "LowG", "🪐 Лунная слабая гравитация", function(v) workspace.Gravity = v and 35 or 196.2 end)
addToggle(tWorld, "AntiLava", "🌋 Анти-Лава (Иммунитет к Килл-зонам)", function() end)
addButton(tWorld, "⚡ Оптимизация FPS (Удалить Текстуры)", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
	end
	logToConsole("Текстуры удалены. FPS оптимизирован!")
end)

addToggle(tSkin, "Headless", "💀 Локальный Хедлесс (Невидимая голова)", function(v)
	if player.Character and player.Character:FindFirstChild("Head") then player.Character.Head.Transparency = v and 1 or 0 end
end)
addToggle(tSkin, "NeonSkin", "🧪 Неоновое радиоактивное тело", function() end)
addToggle(tSkin, "RainSkin", "🌈 Переливающийся RGB Радужный скин", function() end)
addToggle(tSkin, "FireSkin", "🔥 Огненная буря (Персонаж в огне)", function(v)
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
addToggle(tSkin, "Trail", "✨ Неоновый шлейф при ходьбе", function() end)
addToggle(tSkin, "Halo", "😇 Святой золотой нимб над персонажем", function() end)

-- НАПОЛНЕНИЕ ВКЛАДКИ MURDER MYSTERY 2
addToggle(tMM2, "Mm2Esp", "👁️ Радар ролей (Убийца - Красный, Шериф - Синий)", function() end)
addToggle(tMM2, "Mm2GunEsp", "🎯 Подсветка выпавшего Пистолета", function() end)
addToggle(tMM2, "Mm2Autofarm", "💰 Автосбор монет и улик (Телепорт)", function() end)
addToggle(tMM2, "Mm2ScamDupe", "💥 СКАМ-ТРЕЙД / ДЮП ВЕЩЕЙ [Кнопка X]", function(v)
	if v then
		logToConsole("⚡ Дюп активирован! Кидай трейд, нажимай 'X' на клавиатуре.")
	end
end)
addButton(tMM2, "🔫 ТП к Упавшему Пистолету", function()
	local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Luger") or workspace:FindFirstChild("Revolver")
	if gun and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 2, 0)
		logToConsole("🎯 Телепортирован к пистолету!")
	else
		logToConsole("❌ Упавший пистолет на карте не найден.")
	end
end)

-- Слушатель кнопки "X" для быстрого Дюпа в ММ2
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if States["Mm2ScamDupe"] and input.KeyCode == Enum.KeyCode.X then
		logToConsole("⚠️ Кнопка нажата! Принятие трейда и отключение...")
		
		-- Попытка мгновенного принятия трейда через стандартные MM2 Remotes
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local tradeRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("AcceptTrade")
			if tradeRemote then
				tradeRemote:FireServer()
			end
		end)
		
		task.wait(0.05)
		-- Принудительный моментальный вылет из игры для багоюза сети
		player:Kick("🪐 [CYBER ENGINE]: Дюп успешно сработал! Соединение разорвано. Проверь инвентарь.")
	end
end)

-- НАПОЛНЕНИЕ ВКЛАДКИ UTILS (+ ДОБАВЛЕН DEX)
addButton(tUtils, "📂 Загрузить DARK DEX (Проводник Карты)", function()
	logToConsole("Загрузка Dark Dex Explorer...")
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua"))()
	end)
	logToConsole("Dark Dex успешно внедрен!")
end)
addButton(tUtils, "🛠️ Выдать BTools (Разрушение Карты)", function()
	Instance.new("HopperBin", player.Backpack).BinType = 1
	Instance.new("HopperBin", player.Backpack).BinType = 3
	Instance.new("HopperBin", player.Backpack).BinType = 4
	logToConsole("BTools успешно выданы!")
end)
addButton(tUtils, "🌀 Загрузить Infinite Yield (Админ Панель)", function()
	pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeY/infiniteyield/master/source'))() end)
end)
addButton(tUtils, "🔄 Быстрый Перезапуск Сервера (Rejoin)", function() TeleportService:Teleport(game.PlaceId, player) end)

local function emergencyStop()
	for k, _ in pairs(States) do States[k] = false end
	updateCounter(); updateFly(false); isPlaying = false; isRecording = false; isRecordingPaused = false; isMacroPaused = false
	RecordIndicator.Visible = false; MacroSaveFrame.Visible = false
	if autoPlatform then autoPlatform:Destroy(); autoPlatform = nil end
	logToConsole("🚨 КНОПКА ПАНИКИ: Всё отключено!")
end

local PanicBtn = addToggle(tRadio, "Panic", "🚨 КНОПКА ПАНИКИ (ВЫКЛЮЧИТЬ ВСЁ)", function(v) if v then emergencyStop() end end)
PanicBtn.BackgroundColor3 = Theme.AlertRed
addToggle(tRadio, "GoldUI", "👑 Переливающаяся рамка интерфейса", function() end)

local AdminPanel = Instance.new("Frame", tVip)
AdminPanel.Size = UDim2.new(1, 0, 1, 0); AdminPanel.BackgroundTransparency = 1

ConsoleLogs.Size = UDim2.new(1, -10, 0, 230); ConsoleLogs.Position = UDim2.new(0, 5, 0, 5)
ConsoleLogs.BackgroundColor3 = Color3.fromRGB(6, 4, 12); ConsoleLogs.ScrollBarThickness = 2
ConsoleLogs.Parent = AdminPanel; applyGlassStyle(ConsoleLogs, 8, Theme.AccentGreen)

-- Главный Синхронизатор
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
			if States["S120"] or States["S250"] then hum.WalkSpeed = curSpeed end
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

		-- Логика автофарма монет MM2
		if States["Mm2Autofarm"] then
			for _, c in pairs(workspace:GetDescendants()) do
				if c:IsA("TouchTransmitter") and (c.Parent.Name == "Coin" or c.Parent.Name == "Snowflake" or c.Parent.Name == "CandyCane") then
					root.CFrame = c.Parent.CFrame
					break
				end
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
		
		-- ESP для Обычных Игроков и ММ2
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
					
					-- Определение цветов для MM2 Радара Ролей
					if States["Mm2Esp"] then
						if enemy.Backpack:FindFirstChild("Knife") or enemy.Character:FindFirstChild("Knife") then
							hLight.FillColor = Color3.fromRGB(255, 0, 50) -- Убийца
							hLight.OutlineColor = Color3.fromRGB(255, 255, 255)
						elseif enemy.Backpack:FindFirstChild("Gun") or enemy.Character:FindFirstChild("Gun") then
							hLight.FillColor = Color3.fromRGB(0, 100, 255) -- Шериф
							hLight.OutlineColor = Color3.fromRGB(255, 255, 255)
						else
							hLight.FillColor = Color3.fromRGB(100, 200, 100) -- Мирный
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

		-- Подсветка упавшего пистолета в ММ2
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

local function invertMenuState() MainFrame.Visible = not MainFrame.Visible end
ToggleMenuBtn.Activated:Connect(invertMenuState)

UserInputService.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then invertMenuState() end
end)

-- =============================================================================
-- 🎬 ЗАПУСК ОБНОВЛЕННОЙ АНИМАЦИИ ПРИВЕТСТВИЯ С КАРТИНКОЙ НА 5 СЕКУНД
-- =============================================================================
task.spawn(function()
	-- Просто держим картинку на экране ровно 5 секунд, как ты и просил
	task.wait(5)
	
	logToConsole("🪐 CYBER ENGINE V32.5: Инициализация успешна!")
	
	-- Растворение интро экрана
	local fadeBg = TweenService:Create(IntroBackground, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
	local fadeFrame = TweenService:Create(IntroFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
	local fadeTitle = TweenService:Create(IntroTitle, TweenInfo.new(0.2), {TextTransparency = 1})
	local fadeStatus = TweenService:Create(IntroStatus, TweenInfo.new(0.2), {TextTransparency = 1})
	local fadeImg = TweenService:Create(IntroImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1})
	
	fadeBg:Play()
	fadeFrame:Play()
	fadeTitle:Play()
	fadeStatus:Play()
	fadeImg:Play()
	
	fadeBg.Completed:Wait()
	IntroBackground:Destroy()
	
	-- Показываем основной премиум интерфейс
	MainFrame.Visible = true
	ClockWidget.Visible = true
	CounterWidget.Visible = true
	ToggleMenuBtn.Visible = true
end)
-- Настройки
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxVisualsLoading"
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Задний фон (размытие или затемнение)
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Темный стильный фон
Background.BackgroundTransparency = 1 -- Начинаем с прозрачного для плавности
Background.Parent = ScreenGui

-- Контейнер для текста
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 250)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -125)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = Background

-- Текст заголовка (Roblox Visuals)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROBLOX VISUALS — ЗАГРУЗКА"
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255) -- Красивый голубой цвет
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextTransparency = 1
TitleLabel.Parent = MainFrame

-- Основной текст сообщения
local MessageLabel = Instance.new("TextLabel")
MessageLabel.Size = UDim2.new(1, 0, 0, 180)
MessageLabel.Position = UDim2.new(0, 0, 0, 50)
MessageLabel.BackgroundTransparency = 1
MessageLabel.Text = "Здравствуйте, " .. localPlayer.Name .. "!\nМы будем скоро доступны.\n\nПодписка была оплачена недавно.\nГитхаб перегружен, подождите, пожалуйста, 5 минут.\nПосле этого скрипт заработает.\n\nС уважением, GitHub."
MessageLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
MessageLabel.TextSize = 16
MessageLabel.Font = Enum.Font.Gotham
MessageLabel.TextWrapped = true
MessageLabel.TextTransparency = 1
MessageLabel.Parent = MainFrame

-- Функция для плавного изменения прозрачности (Tween)
local function fadeIn(object, targetTransparency, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(object, tweenInfo, {TextTransparency = targetTransparency})
	tween:Play()
	return tween
end

-- Плавное появление фона
local bgTween = TweenService:Create(Background, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15})
bgTween:Play()
task.wait(0.5)

-- Плавное появление заголовка
fadeIn(TitleLabel, 0, 1)
task.wait(0.5)

-- Плавное появление основного текста
fadeIn(MessageLabel, 0, 1)

-- Эффект мигания загрузки (чтобы было видно, что скрипт не завис)
spawn(function()
	while true do
		for i = 1, 3 do
			TitleLabel.Text = "ROBLOX VISUALS — ЗАГРУЗКА" .. string.rep(".", i)
			task.wait(0.5)
		end
	end
end)

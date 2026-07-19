-- Создание интерфейса
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Проверка на повторный запуск (чтобы интерфейсы не накладывались)
if CoreGui:FindFirstChild("XenoNotification") then
    CoreGui.XenoNotification:Destroy()
end

local XenoNotification = Instance.new("ScreenGui")
XenoNotification.Name = "XenoNotification"
XenoNotification.Parent = CoreGui
XenoNotification.ResetOnSpawn = false

-- Добавляем эффект размытия на задний план
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting
TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 15}):Play()

-- Главный фрейм (Окно)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 250)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = XenoNotification

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Обводка
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "XENO BETA"
Title.TextColor3 = Color3.fromRGB(255, 65, 65) -- Красный акцент для важного уведомления
Title.TextSize = 18
Title.Parent = MainFrame

-- Текст сообщения
local Message = Instance.new("TextLabel")
Message.Name = "Message"
Message.Size = UDim2.new(1, -40, 0, 120)
Message.Position = UDim2.new(0, 20, 0, 50)
Message.BackgroundTransparency = 1
Message.Font = Enum.Font.Gotham
Message.Text = "Приносим извинения, но нам придётся завершить нашу работу бэта версии, так как поддерживание бэты имел маленький срок, но срок использования закончился. Спасибо, что вы были с нами!"
Message.TextColor3 = Color3.fromRGB(220, 220, 220)
Message.TextSize = 14
Message.TextWrapped = true
Message.TextYAlignment = Enum.TextYAlignment.Top
Message.Parent = MainFrame

-- Кнопка Закрыть
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 150, 0, 35)
CloseButton.Position = UDim2.new(0.5, -75, 1, -55)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.Text = "Закрыть"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = CloseButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(50, 50, 50)
ButtonStroke.Thickness = 1
ButtonStroke.Parent = CloseButton

-- Анимация появления (плавное проявление)
MainFrame.BackgroundTransparency = 1
Title.TextTransparency = 1
Message.TextTransparency = 1
CloseButton.BackgroundTransparency = 1
CloseButton.TextTransparency = 1
UIStroke.Transparency = 1
ButtonStroke.Transparency = 1

local function fadeIn()
    local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(Title, info, {TextTransparency = 0}):Play()
    TweenService:Create(Message, info, {TextTransparency = 0}):Play()
    TweenService:Create(CloseButton, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(CloseButton, info, {TextTransparency = 0}):Play()
    TweenService:Create(UIStroke, info, {Transparency = 0}):Play()
    TweenService:Create(ButtonStroke, info, {Transparency = 0}):Play()
end

fadeIn()

-- Эффекты при наведении на кнопку
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
end)

-- Закрытие интерфейса с анимацией затухания
CloseButton.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(Blur, info, {Size = 0}):Play()
    TweenService:Create(MainFrame, info, {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, info, {TextTransparency = 1}):Play()
    TweenService:Create(Message, info, {TextTransparency = 1}):Play()
    TweenService:Create(CloseButton, info, {BackgroundTransparency = 1}):Play()
    TweenService:Create(CloseButton, info, {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, info, {Transparency = 1}):Play()
    TweenService:Create(ButtonStroke, info, {Transparency = 1}):Play()
    
    task.wait(0.3)
    XenoNotification:Destroy()
    Blur:Destroy()
end)

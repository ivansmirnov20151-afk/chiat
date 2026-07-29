if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("RobloxVisualsUpdateNotice")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RobloxVisualsUpdateNotice"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local background = Instance.new("Frame", gui)
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
background.BackgroundTransparency = 1
TweenService:Create(background, TweenInfo.new(0.6), {BackgroundTransparency = 0.08}):Play()

local card = Instance.new("Frame", background)
card.Size = UDim2.fromOffset(440, 260)
card.Position = UDim2.new(0.5, -220, 0.5, -130)
card.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
card.BackgroundTransparency = 0.04
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(75, 155, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel", card)
title.Size = UDim2.new(1, -40, 0, 55)
title.Position = UDim2.fromOffset(20, 28)
title.BackgroundTransparency = 1
title.Text = "ROBLOX VISUALS"
title.TextColor3 = Color3.fromRGB(235, 245, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 25

local status = Instance.new("TextLabel", card)
status.Size = UDim2.new(1, -50, 0, 95)
status.Position = UDim2.fromOffset(25, 90)
status.BackgroundTransparency = 1
status.Text = "Сейчас идёт обновление.\nПожалуйста, зайдите в этот скрипт позже."
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(175, 195, 220)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 16

local badge = Instance.new("TextLabel", card)
badge.Size = UDim2.fromOffset(220, 38)
badge.Position = UDim2.new(0.5, -110, 1, -60)
badge.BackgroundColor3 = Color3.fromRGB(35, 75, 125)
badge.Text = "ТЕХНИЧЕСКИЕ РАБОТЫ"
badge.TextColor3 = Color3.fromRGB(240, 248, 255)
badge.Font = Enum.Font.GothamBold
badge.TextSize = 12
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 10)

card.Size = UDim2.fromOffset(360, 210)
TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(440, 260)}):Play()

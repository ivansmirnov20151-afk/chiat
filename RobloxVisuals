-- =============================================================================
-- ROBLOX VISUALS LEGAL EDITION · v6.66 HALLOWEEN 🎃 (всё в одном скрипте)
-- Только косметика на стороне клиента: интерфейс, темы, курсоры, визуальные
-- настройки и анимации потери HP. Никаких читов.
--
-- КАК ПОДКЛЮЧИТЬ (Roblox Studio, ВАША игра):
--   StarterPlayer > StarterPlayerScripts > Insert Object > LocalScript
--   Вставить весь этот код. Меню: RightShift или кнопка "V" слева сверху.
-- =============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local old = playerGui:FindFirstChild("VisualsLegal")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "VisualsLegal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

-- =============================================================================
-- Утилиты
-- =============================================================================
local animSpeed = 1.0
local rgb = Color3.fromRGB

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function tw(obj, t, goal, style, dir)
	if not obj then return end
	local tween = TweenService:Create(
		obj,
		TweenInfo.new(math.max(0.02, t / animSpeed), style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
	return tween
end

local function corner(obj, r)
	local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", obj)
	c.CornerRadius = UDim.new(0, r)
	return c
end

-- =============================================================================
-- Темы
-- =============================================================================
local Themes = {
	{name = "Roblox Visuals", bg = rgb(16, 18, 20), header = rgb(24, 27, 30), accent = rgb(52, 211, 120), text = rgb(244, 247, 245), sub = rgb(140, 150, 146), btn = rgb(30, 34, 37)},
	{name = "Liquid Glass", bg = rgb(24, 20, 28), header = rgb(36, 30, 44), accent = rgb(235, 135, 40), text = rgb(250, 245, 240), sub = rgb(180, 170, 165), btn = rgb(48, 38, 52)},
	{name = "Dark Blue", bg = rgb(14, 14, 18), header = rgb(22, 22, 28), accent = rgb(80, 140, 255), text = rgb(245, 245, 250), sub = rgb(150, 150, 165), btn = rgb(30, 30, 38)},
	{name = "Neon", bg = rgb(12, 8, 24), header = rgb(24, 12, 44), accent = rgb(0, 245, 255), text = rgb(250, 245, 255), sub = rgb(180, 150, 210), btn = rgb(36, 20, 60)},
	{name = "Ocean", bg = rgb(8, 28, 40), header = rgb(12, 44, 62), accent = rgb(30, 200, 240), text = rgb(235, 250, 255), sub = rgb(150, 195, 220), btn = rgb(18, 58, 80)},
	{name = "Forest", bg = rgb(16, 28, 18), header = rgb(26, 44, 28), accent = rgb(60, 210, 100), text = rgb(245, 255, 245), sub = rgb(165, 205, 170), btn = rgb(32, 58, 36)},
	{name = "Sunset", bg = rgb(38, 18, 24), header = rgb(58, 26, 34), accent = rgb(255, 115, 60), text = rgb(255, 245, 240), sub = rgb(215, 165, 165), btn = rgb(72, 34, 44)},
	{name = "Purple", bg = rgb(26, 14, 38), header = rgb(42, 22, 60), accent = rgb(185, 95, 255), text = rgb(250, 242, 255), sub = rgb(195, 165, 220), btn = rgb(56, 30, 80)},
	{name = "Light", bg = rgb(235, 238, 245), header = rgb(250, 252, 255), accent = rgb(45, 125, 245), text = rgb(25, 30, 40), sub = rgb(90, 100, 115), btn = rgb(215, 222, 235)},
}

local Theme = {}
for k, v in pairs(Themes[1]) do Theme[k] = v end
local themed = {}
local onThemeChanged = {}

local function bind(obj, prop, key)
	obj[prop] = Theme[key]
	table.insert(themed, {obj, prop, key})
end

local function applyTheme(t)
	for k, v in pairs(t) do Theme[k] = v end
	for i = #themed, 1, -1 do
		local e = themed[i]
		if e[1] and e[1].Parent then
			tw(e[1], 0.35, {[e[2]] = Theme[e[3]]})
		else
			table.remove(themed, i)
		end
	end
	for _, f in ipairs(onThemeChanged) do task.spawn(f) end
end

-- =============================================================================
-- Настройки (флаги)
-- =============================================================================
local S = {
	fullbright = false, noFog = false,
	hoverOutline = true, hoverInfo = true,
	hud = true, hideDefaultHp = false,
	vignette = true, shake = true, dmgSelf = true, dmgOthers = false,
	lowPulse = true, healFlash = true,
	cursor = false, cursorStyle = "Neon", clickFx = true,
	fps = false,
}

-- =============================================================================
-- Реестр настроек (для конфигов), клавиши, стиль переключателей
-- =============================================================================
local NS = {}                         -- общее пространство имён между секциями
local DEFAULT_CONFIG = [[
# Вставьте сюда свой конфиг (вкладка «Конфиг» → «Создать конфиг»). Он применяется при каждом запуске.
]]
local Registry, RegistryOrder = {}, {}
local ToggleStyle = "pill"
local toggleRedraws = {}
local Keybinds = {
	menu = Enum.KeyCode.RightShift, pause = Enum.KeyCode.P, photo = Enum.KeyCode.H,
	music = Enum.KeyCode.Q, hud = Enum.KeyCode.M, bright = Enum.KeyCode.B, marker = Enum.KeyCode.K,
}
local IdOverride = {
	{"Fullbright", "fullbright"}, {"Убрать туман", "no_fog"}, {"Угол обзора", "fov"}, {"Время суток (час)", "clock_time"},
	{"Масштаб меню", "menu_scale"}, {"Скорость анимаций", "anim_speed"}, {"Размытие картинки", "blur"},
	{"Свечение (Bloom)", "bloom"}, {"Счётчик FPS", "fps_counter"}, {"Мини-список игроков", "player_list"},
	{"Показывать прицел", "crosshair"}, {"Снег", "snow"}, {"Дождь", "rain"}, {"Шлейф", "trail"}, {"Нимб", "halo"},
	{"Красная виньетка", "damage_vignette"}, {"Тряска камеры", "damage_shake"}, {"Цифры урона над собой", "damage_numbers_self"},
	{"Цифры урона над другими", "damage_numbers_others"}, {"Кастомный курсор", "custom_cursor"},
}
local cyr = {"a","b","v","g","d","e","zh","z","i","y","k","l","m","n","o","p","r","s","t","u","f","h","ts","ch","sh","sch","","y","","e","yu","ya"}
local function slugify(title)
	local out = {}
	local ok = pcall(function()
		for _, cp in utf8.codes(title) do
			if cp >= 0x41 and cp <= 0x5A then cp += 32 end
			if cp >= 0x410 and cp <= 0x42F then cp += 32 end
			if (cp >= 0x30 and cp <= 0x39) or (cp >= 0x61 and cp <= 0x7A) then
				table.insert(out, string.char(cp))
			elseif cp >= 0x430 and cp <= 0x44F then
				table.insert(out, cyr[cp - 0x42F])
			elseif cp == 0x451 or cp == 0x401 then
				table.insert(out, "e")
			else
				table.insert(out, "_")
			end
		end
	end)
	local r = table.concat(out):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
	if not ok or r == "" then r = "setting" end
	return r:sub(1, 40)
end
local function registerSetting(kind, title, get, set, id, min, max)
	if not id then
		for _, pair in ipairs(IdOverride) do
			if title:find(pair[1], 1, true) then id = pair[2] break end
		end
	end
	id = id or slugify(title)
	local base, n = id, 1
	while Registry[id] do n += 1; id = base .. "_" .. n end
	Registry[id] = {kind = kind, title = title, get = get, set = set, default = get(), min = min, max = max}
	table.insert(RegistryOrder, id)
	return id
end
local function toggleSetting(id)
	local r = Registry[id]
	if r and r.kind == "toggle" then r.set(not r.get()) end
end
local function setToggleStyle(name)
	ToggleStyle = name
	for i = #toggleRedraws, 1, -1 do
		local fn = toggleRedraws[i]
		if not fn() then table.remove(toggleRedraws, i) end
	end
end

-- =============================================================================
-- Уведомления
-- =============================================================================
local toastBaseY = 118
local activeToasts = {}
local function notify(title, desc)
	local f = new("Frame", {
		Size = UDim2.fromOffset(10, 42), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 70), BackgroundTransparency = 0.06, ZIndex = 3000,
	}, gui)
	bind(f, "BackgroundColor3", "bg"); corner(f, 21)
	local st = new("UIStroke", {Thickness = 1, Transparency = 0.45}, f); bind(st, "Color", "accent")
	new("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 18)}, f)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	}, f)
	local t = new("TextLabel", {
		Size = UDim2.fromOffset(0, 42), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
		Text = tostring(title), Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = 1, ZIndex = 3001,
	}, f); bind(t, "TextColor3", "accent")
	new("Frame", {Size = UDim2.fromOffset(26, 1), BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 3001}, f)
	local d = new("TextLabel", {
		Size = UDim2.fromOffset(0, 42), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
		Text = tostring(desc), Font = Enum.Font.GothamSemibold, TextSize = 13, LayoutOrder = 3, ZIndex = 3001,
	}, f); bind(d, "TextColor3", "text")

	table.insert(activeToasts, f)
	local function layout()
		for i, n in ipairs(activeToasts) do
			local k = #activeToasts - i
			tw(n, 0.3, {Position = UDim2.new(0.5, 0, 1, -(toastBaseY + k * 52))}, Enum.EasingStyle.Back)
		end
	end
	layout()
	task.delay(3.4, function()
		local idx = table.find(activeToasts, f)
		if idx then table.remove(activeToasts, idx) end
		tw(f, 0.25, {Position = UDim2.new(0.5, 0, 1, 70)})
		layout()
		task.delay(0.3, function() f:Destroy() end)
	end)
end

-- =============================================================================
-- Главное окно
-- =============================================================================
local Main = new("Frame", {
	Size = UDim2.fromOffset(620, 420), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.08, Visible = false, ZIndex = 10,
}, gui)
bind(Main, "BackgroundColor3", "bg"); corner(Main, 16)
local mainStroke = new("UIStroke", {Thickness = 1.5}, Main); bind(mainStroke, "Color", "accent")
local mainScale = new("UIScale", {Scale = 1}, Main)

local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 0.2, ZIndex = 11}, Main)
bind(Header, "BackgroundColor3", "header"); corner(Header, 16)

local Title = new("TextLabel", {
	Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
	Text = "🪐 ROBLOX VISUALS  ·  Legal Edition", Font = Enum.Font.GothamBold, TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
}, Header); bind(Title, "TextColor3", "accent")

local CloseBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -40, 0.5, -14),
	Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12, BackgroundColor3 = rgb(231, 76, 60),
	TextColor3 = rgb(255, 255, 255), ZIndex = 12,
}, Header); corner(CloseBtn, 8)

local Sidebar = new("ScrollingFrame", {
	Size = UDim2.new(0, 160, 1, -64), Position = UDim2.fromOffset(10, 56), BackgroundTransparency = 1,
	BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(), ZIndex = 11,
}, Main)
new("UIListLayout", {Padding = UDim.new(0, 4)}, Sidebar)

local Content = new("Frame", {
	Size = UDim2.new(1, -190, 1, -64), Position = UDim2.fromOffset(180, 56), BackgroundTransparency = 1, ZIndex = 11,
}, Main)

local function draggable(frame, handle)
	local dragging, startInput, startPos = false, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; startInput = i.Position; startPos = frame.Position
			local c; c = i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false; c:Disconnect() end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end
draggable(Main, Header)

local menuOpen = false
local function setMenu(v)
	menuOpen = v
	if v then
		Main.Visible = true
		mainScale.Scale = 0.9
		tw(mainScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
	else
		local t = tw(mainScale, 0.2, {Scale = 0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.2, function() if not menuOpen then Main.Visible = false end end)
	end
end
CloseBtn.Activated:Connect(function() setMenu(false) end)

local ToggleBtn = new("TextButton", {
	Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(16, 16), Text = "V",
	Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 300,
}, gui)
bind(ToggleBtn, "BackgroundColor3", "header"); bind(ToggleBtn, "TextColor3", "accent"); corner(ToggleBtn, 14)
local tbStroke = new("UIStroke", {Thickness = 1.8}, ToggleBtn); bind(tbStroke, "Color", "accent")
local tbScale = new("UIScale", {Scale = 1}, ToggleBtn)
ToggleBtn.MouseEnter:Connect(function() tw(tbScale, 0.15, {Scale = 1.1}) end)
ToggleBtn.MouseLeave:Connect(function() tw(tbScale, 0.15, {Scale = 1}) end)
ToggleBtn.Activated:Connect(function() setMenu(not menuOpen) end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Keybinds.menu then setMenu(not menuOpen) end
end)

-- =============================================================================
-- Вкладки и элементы UI
-- =============================================================================
local pages, tabButtons = {}, {}

local function createTab(title)
	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 12,
	}, Content)
	new("UIListLayout", {Padding = UDim.new(0, 6)}, page)
	new("UIPadding", {PaddingRight = UDim.new(0, 6)}, page)

	local b = new("TextButton", {
		Size = UDim2.new(1, -4, 0, 34), BackgroundTransparency = 1, Text = "  " .. title,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
	}, Sidebar)
	corner(b, 8)
	b.TextColor3 = Theme.sub
	b.BackgroundColor3 = Theme.btn
	b.Activated:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		for _, tb in pairs(tabButtons) do
			tw(tb, 0.2, {TextColor3 = Theme.sub, BackgroundTransparency = 1})
		end
		page.Visible = true
		tw(b, 0.2, {TextColor3 = Theme.text, BackgroundTransparency = 0.3})
	end)
	table.insert(pages, page)
	table.insert(tabButtons, b)
	return page, b
end

local function hoverFx(btn, target)
	local sc = new("UIScale", {Scale = 1}, target)
	btn.MouseEnter:Connect(function() tw(sc, 0.15, {Scale = 1.025}) end)
	btn.MouseLeave:Connect(function() tw(sc, 0.15, {Scale = 1}) end)
	btn.MouseButton1Down:Connect(function() tw(sc, 0.08, {Scale = 0.97}) end)
	btn.MouseButton1Up:Connect(function() tw(sc, 0.12, {Scale = 1.025}) end)
end

local function addLabel(parent, text)
	local l = new("TextLabel", {
		Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1, Text = text,
		Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
	}, parent)
	bind(l, "TextColor3", "sub")
	return l
end

local function addButton(parent, title, cb)
	local b = new("TextButton", {
		Size = UDim2.new(1, -8, 0, 38), BackgroundTransparency = 0.25, Text = "  " .. title,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
	}, parent)
	bind(b, "BackgroundColor3", "btn"); bind(b, "TextColor3", "text"); corner(b, 10)
	local st = new("UIStroke", {Thickness = 1}, b); bind(st, "Color", "accent")
	hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
	return b
end

local function addToggle(parent, title, default, cb, id)
	local holder = new("Frame", {Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 0.35, ZIndex = 13}, parent)
	bind(holder, "BackgroundColor3", "btn"); corner(holder, 10)
	local btn = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "   " .. title,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	}, holder); bind(btn, "TextColor3", "text")
	local sw = new("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10), ZIndex = 14}, holder)
	local swCorner = corner(sw, 10)
	local swScale = new("UIScale", {Scale = 1}, sw)
	local ball = new("Frame", {
		Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = rgb(255, 255, 255), ZIndex = 15,
	}, sw); corner(ball, 8)
	local mark = new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamBlack,
		TextSize = 14, TextColor3 = rgb(255, 255, 255), ZIndex = 15,
	}, sw)
	hoverFx(btn, holder)

	local state = default and true or false
	local function layoutStyle()
		if ToggleStyle == "square" then
			sw.Size = UDim2.fromOffset(24, 24); sw.Position = UDim2.new(1, -36, 0.5, -12)
			swCorner.CornerRadius = UDim.new(0, 6); ball.Visible = false
		elseif ToggleStyle == "dot" then
			sw.Size = UDim2.fromOffset(16, 16); sw.Position = UDim2.new(1, -28, 0.5, -8)
			swCorner.CornerRadius = UDim.new(0, 8); ball.Visible = false
		else
			sw.Size = UDim2.fromOffset(40, 20); sw.Position = UDim2.new(1, -52, 0.5, -10)
			swCorner.CornerRadius = UDim.new(0, 10); ball.Visible = true
		end
	end
	local function visual(animate)
		local col = state and rgb(46, 204, 113) or rgb(231, 76, 60)
		mark.Text = (ToggleStyle == "square") and (state and "✓" or "✕") or ""
		local pos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		if animate then
			tw(sw, 0.18, {BackgroundColor3 = col})
			tw(ball, 0.18, {Position = pos}, Enum.EasingStyle.Back)
			if ToggleStyle ~= "pill" then
				swScale.Scale = 1.35
				tw(swScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
			end
		else
			sw.BackgroundColor3 = col; ball.Position = pos
		end
	end
	layoutStyle(); visual(false)
	table.insert(toggleRedraws, function()
		if not holder.Parent then return false end
		layoutStyle(); visual(false)
		return true
	end)
	local function setState(v, fire)
		state = v and true or false
		visual(true)
		if fire then pcall(cb, state) end
	end
	btn.Activated:Connect(function() setState(not state, true) end)
	if default then task.defer(function() pcall(cb, true) end) end
	registerSetting("toggle", title, function() return state end, function(v) setState(v, true) end, id)
	return holder
end

local function addSlider(parent, title, min, max, default, decimals, cb, id)
	local holder = new("Frame", {Size = UDim2.new(1, -8, 0, 54), BackgroundTransparency = 0.35, ZIndex = 13}, parent)
	bind(holder, "BackgroundColor3", "btn"); corner(holder, 10)
	local label = new("TextLabel", {
		Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(12, 6), BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	}, holder); bind(label, "TextColor3", "text")
	local bar = new("Frame", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 38), BorderSizePixel = 0, ZIndex = 14}, holder)
	bind(bar, "BackgroundColor3", "header"); corner(bar, 3)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 15}, bar)
	bind(fill, "BackgroundColor3", "accent"); corner(fill, 3)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0, ZIndex = 16,
	}, bar); corner(knob, 7)

	local cur = default
	local function set(v, fire)
		v = math.clamp(v, min, max)
		local m = 10 ^ decimals
		v = math.floor(v * m + 0.5) / m
		local a = (v - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		cur = v
		label.Text = title .. ": " .. v
		if fire then pcall(cb, v) end
	end
	set(default, false)

	local dragging = false
	local function fromX(x)
		set(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), true)
	end
	holder.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; fromX(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	registerSetting("slider", title, function() return cur end, function(v) set(v, true) end, id, min, max)
	return holder
end

local pVisual = createTab("👁️ Визуал")
local pHp = createTab("❤️ Анимации HP")
local pCursor = createTab("🖱️ Курсоры")
local pTheme = createTab("🎨 Темы")
local pUi = createTab("⚙️ Интерфейс")

-- общие переменные между секциями (лимит Luau: 200 локальных на функцию)
local V = {}
do
-- =============================================================================
-- Визуал мира (только локально, без преимуществ в игре)
end
do
-- =============================================================================
V.orig = {
	Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
}
V.cc = Instance.new("ColorCorrectionEffect")
V.cc.Name = "VisualsLegalCC"; V.cc.Parent = Lighting

addLabel(pVisual, "ОСВЕЩЕНИЕ И КАРТИНКА")
addToggle(pVisual, "☀️ Яркое освещение (Fullbright)", false, function(v)
	S.fullbright = v
	if v then
		Lighting.Brightness = 3; Lighting.Ambient = rgb(200, 200, 200)
		Lighting.OutdoorAmbient = rgb(200, 200, 200); Lighting.GlobalShadows = false
	else
		Lighting.Brightness = V.orig.Brightness; Lighting.Ambient = V.orig.Ambient
		Lighting.OutdoorAmbient = V.orig.OutdoorAmbient; Lighting.GlobalShadows = V.orig.GlobalShadows
	end
end)
addToggle(pVisual, "🌫️ Убрать туман", false, function(v)
	S.noFog = v
	Lighting.FogEnd = v and 1e6 or V.orig.FogEnd
	Lighting.FogStart = v and 1e6 or V.orig.FogStart
end)
addSlider(pVisual, "Угол обзора (FOV)", 40, 120, camera.FieldOfView, 0, function(v) camera.FieldOfView = v end)
addSlider(pVisual, "Время суток (час)", 0, 24, Lighting.ClockTime, 1, function(v) Lighting.ClockTime = v end)
addSlider(pVisual, "Насыщенность", -1, 1, 0, 2, function(v) V.cc.Saturation = v end)
addSlider(pVisual, "Контраст", -0.5, 0.5, 0, 2, function(v) V.cc.Contrast = v end)
addLabel(pVisual, "НАВЕДЕНИЕ НА ИГРОКОВ")
addToggle(pVisual, "✨ Обводка игрока при наведении", true, function(v) S.hoverOutline = v end)
addToggle(pVisual, "ℹ️ Карточка игрока (ник + HP) при наведении", true, function(v) S.hoverInfo = v end)
addLabel(pVisual, "ИНФОРМАЦИЯ")
V.fpsLabel = new("TextLabel", {
	Size = UDim2.fromOffset(160, 24), Position = UDim2.new(1, -176, 0, 12), BackgroundTransparency = 1,
	Text = "", Font = Enum.Font.Code, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
	Visible = false, ZIndex = 200,
}, gui); bind(V.fpsLabel, "TextColor3", "accent")
addToggle(pVisual, "📊 Счётчик FPS и пинга", false, function(v)
	S.fps = v; V.fpsLabel.Visible = v
end)

end
do
-- =============================================================================
-- HP: полоска, призрачный след, вспышка, тряска, цифры урона
end
do
-- =============================================================================
local Hud = new("Frame", {
	Size = UDim2.fromOffset(340, 24), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -64),
	BackgroundColor3 = rgb(15, 15, 18), BackgroundTransparency = 0.25, ZIndex = 100,
}, gui)
corner(Hud, 12)
V.hudStroke = new("UIStroke", {Thickness = 1.6, Color = rgb(80, 80, 90)}, Hud)
local hudScale = new("UIScale", {Scale = 1}, Hud)

local GhostBar = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(255, 215, 120), BorderSizePixel = 0, ZIndex = 101,
}, Hud); corner(GhostBar, 12)
local HpBar = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(46, 204, 113), BorderSizePixel = 0, ZIndex = 102,
}, Hud); corner(HpBar, 12)
local HpText = new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "100 / 100",
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = rgb(255, 255, 255),
	TextStrokeTransparency = 0.6, ZIndex = 103,
}, Hud)

-- Красная/зелёная виньетка по краям экрана
local function makeEdge(anchor, pos, size, rot)
	local f = new("Frame", {
		AnchorPoint = anchor, Position = pos, Size = size, BackgroundColor3 = rgb(220, 20, 30),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 90,
	}, gui)
	new("UIGradient", {Rotation = rot, Transparency = NumberSequence.new(0, 1)}, f)
	return f
end
local edges = {
	makeEdge(Vector2.new(0.5, 0), UDim2.fromScale(0.5, 0), UDim2.fromScale(1, 0.28), 90),
	makeEdge(Vector2.new(0.5, 1), UDim2.fromScale(0.5, 1), UDim2.fromScale(1, 0.28), -90),
	makeEdge(Vector2.new(0, 0.5), UDim2.fromScale(0, 0.5), UDim2.fromScale(0.2, 1), 0),
	makeEdge(Vector2.new(1, 0.5), UDim2.fromScale(1, 0.5), UDim2.fromScale(0.2, 1), 180),
}
local function flashEdges(color, strength)
	for _, e in ipairs(edges) do
		e.BackgroundColor3 = color
		e.BackgroundTransparency = 1 - strength
		tw(e, 0.6, {BackgroundTransparency = 1})
	end
end

-- Тряска камеры
local shakeMag = 0
RunService:BindToRenderStep("VisualsLegalShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if shakeMag > 0.01 then
		camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * shakeMag, (math.random() - 0.5) * shakeMag, 0)
		shakeMag = shakeMag * math.exp(-dt * 9)
	end
end)

function V.hpColor(r)
	return rgb(231, 76, 60):Lerp(rgb(46, 204, 113), math.clamp(r * 1.25, 0, 1))
end

local ghostToken = 0
V.currentRatio = 1
local function updateHud(h, maxH)
	maxH = math.max(maxH, 1)
	local r = math.clamp(h / maxH, 0, 1)
	local lost = r < V.currentRatio
	V.currentRatio = r
	HpText.Text = math.max(0, math.floor(h + 0.5)) .. " / " .. math.floor(maxH + 0.5)
	tw(HpBar, 0.2, {Size = UDim2.fromScale(r, 1), BackgroundColor3 = V.hpColor(r)})
	ghostToken += 1
	local my = ghostToken
	if lost then
		task.delay(0.45, function()
			if my == ghostToken then tw(GhostBar, 0.5, {Size = UDim2.fromScale(r, 1)}) end
		end)
	else
		GhostBar.Size = UDim2.fromScale(r, 1)
	end
end

local function screenNumber(amount, color, prefix)
	local l = new("TextLabel", {
		Size = UDim2.fromOffset(80, 28), AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, math.random(-60, 60), 1, -92), BackgroundTransparency = 1,
		Text = prefix .. math.floor(amount + 0.5), Font = Enum.Font.GothamBlack, TextSize = 22,
		TextColor3 = color, TextStrokeTransparency = 0.4, ZIndex = 110,
	}, gui)
	local sc = new("UIScale", {Scale = 0.5}, l)
	tw(sc, 0.2, {Scale = 1.2}, Enum.EasingStyle.Back)
	tw(l, 0.9, {Position = l.Position - UDim2.fromOffset(0, 45)})
	task.delay(0.5, function() tw(l, 0.4, {TextTransparency = 1, TextStrokeTransparency = 1}) end)
	Debris:AddItem(l, 1.2)
end

local function worldNumber(hum, amount, color)
	local char = hum.Parent
	local part = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
	if not part then return end
	local off = Vector3.new((math.random() - 0.5) * 2, 2.5, 0)
	local bb = new("BillboardGui", {Size = UDim2.fromOffset(100, 40), StudsOffset = off, AlwaysOnTop = true, Adornee = part}, gui)
	local l = new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "-" .. math.floor(amount + 0.5),
		Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = color, TextStrokeTransparency = 0.4,
	}, bb)
	local sc = new("UIScale", {Scale = 0.4}, l)
	tw(sc, 0.2, {Scale = 1.2}, Enum.EasingStyle.Back)
	tw(bb, 0.9, {StudsOffset = off + Vector3.new(0, 3, 0)})
	task.delay(0.5, function() tw(l, 0.4, {TextTransparency = 1, TextStrokeTransparency = 1}) end)
	Debris:AddItem(bb, 1.2)
end

local function onDamage(hum, amount, isSelf)
	if isSelf then
		if S.vignette then flashEdges(rgb(220, 20, 30), math.clamp(0.35 + amount / 60, 0.35, 0.85)) end
		if S.shake then shakeMag = math.max(shakeMag, math.clamp(amount / 15, 0.3, 2) * 0.3) end
		hudScale.Scale = 1.12
		tw(hudScale, 0.35, {Scale = 1}, Enum.EasingStyle.Elastic)
		V.hudStroke.Color = rgb(231, 76, 60)
		tw(V.hudStroke, 0.5, {Color = rgb(80, 80, 90)})
		if S.hud then screenNumber(amount, rgb(255, 80, 80), "-") end
		if S.dmgSelf then worldNumber(hum, amount, rgb(255, 80, 80)) end
	elseif S.dmgOthers then
		worldNumber(hum, amount, rgb(255, 200, 80))
	end
end

local function onHeal(amount)
	if S.healFlash then flashEdges(rgb(46, 204, 113), 0.3) end
	V.hudStroke.Color = rgb(46, 204, 113)
	tw(V.hudStroke, 0.5, {Color = rgb(80, 80, 90)})
	if S.hud then screenNumber(amount, rgb(80, 255, 140), "+") end
end

local function watchHumanoid(hum, isSelf)
	local last = hum.Health
	if isSelf then updateHud(hum.Health, hum.MaxHealth) end
	hum.HealthChanged:Connect(function(h)
		local diff = h - last
		last = h
		if diff < -0.5 then onDamage(hum, -diff, isSelf)
		elseif diff > 0.5 and isSelf then onHeal(diff) end
		if isSelf then updateHud(h, hum.MaxHealth) end
	end)
end

local function hookCharacter(plr, char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then watchHumanoid(hum, plr == player) end
end
local function hookPlayer(plr)
	if plr.Character then task.spawn(hookCharacter, plr, plr.Character) end
	plr.CharacterAdded:Connect(function(c) hookCharacter(plr, c) end)
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)

addLabel(pHp, "ПОЛОСКА И ЭФФЕКТЫ ПОТЕРИ HP")
addToggle(pHp, "❤️ Своя полоска HP с «призрачным» следом", true, function(v) S.hud = v; Hud.Visible = v end)
addToggle(pHp, "🙈 Скрыть стандартную полоску Roblox", false, function(v)
	S.hideDefaultHp = v
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, not v) end)
end)
addToggle(pHp, "🩸 Красная виньетка при уроне", true, function(v) S.vignette = v end)
addToggle(pHp, "📳 Лёгкая тряска камеры при уроне", true, function(v) S.shake = v end)
addToggle(pHp, "💥 Цифры урона над собой", true, function(v) S.dmgSelf = v end)
addToggle(pHp, "🎯 Цифры урона над другими игроками", false, function(v) S.dmgOthers = v end)
addToggle(pHp, "💚 Зелёная вспышка при лечении", true, function(v) S.healFlash = v end)
addToggle(pHp, "🚨 Пульсация полоски при HP ниже 25%", true, function(v) S.lowPulse = v end)
addButton(pHp, "🧪 Тест эффекта урона (только на экране)", function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		local fake = math.random(10, 30)
		onDamage(hum, fake, true)
		V.currentRatio = math.clamp(V.currentRatio - fake / hum.MaxHealth, 0, 1)
		task.delay(1.2, function() updateHud(hum.Health, hum.MaxHealth) end)
	end
end)

end
do
-- =============================================================================
-- Курсоры
end
do
-- =============================================================================
V.Cursor = new("Frame", {
	Size = UDim2.fromOffset(28, 28), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
	Visible = false, ZIndex = 100000,
}, gui)
V.cursorScale = new("UIScale", {Scale = 1}, V.Cursor)

local function setCursorStyle(name)
	S.cursorStyle = name
	for _, c in ipairs(V.Cursor:GetChildren()) do
		if not c:IsA("UIScale") then c:Destroy() end
	end
	local col = Theme.accent
	local center = {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 100001, BorderSizePixel = 0}
	local function shape(size, color, tr)
		local f = new("Frame", center, V.Cursor)
		f.Size = size; f.BackgroundColor3 = color; f.BackgroundTransparency = tr or 0
		return f
	end
	if name == "Dot" then
		corner(shape(UDim2.fromOffset(8, 8), col), 4)
	elseif name == "Ring" then
		local f = shape(UDim2.fromOffset(20, 20), col, 1)
		corner(f, 10); new("UIStroke", {Color = col, Thickness = 2}, f)
	elseif name == "Cross" then
		shape(UDim2.fromOffset(2, 20), col); shape(UDim2.fromOffset(20, 2), col)
	elseif name == "Diamond" then
		local f = shape(UDim2.fromOffset(14, 14), col)
		f.Rotation = 45; corner(f, 3); new("UIStroke", {Color = rgb(255, 255, 255), Thickness = 1.5}, f)
	else -- Neon
		local f = shape(UDim2.fromOffset(16, 16), col)
		corner(f, 8); new("UIStroke", {Color = rgb(255, 255, 255), Thickness = 1.5}, f)
		local glow = shape(UDim2.fromOffset(26, 26), col, 0.8); corner(glow, 13)
	end
end
setCursorStyle("Neon")
table.insert(onThemeChanged, function() setCursorStyle(S.cursorStyle) end)

function V.setCursorEnabled(v)
	S.cursor = v
	V.Cursor.Visible = v
	UIS.MouseIconEnabled = not v
	if v then UIS.MouseIcon = "" end
end

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and S.cursor and S.clickFx then
		local mp = UIS:GetMouseLocation()
		local r = new("Frame", {
			Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(mp.X, mp.Y),
			BackgroundTransparency = 0.2, BackgroundColor3 = Theme.accent, ZIndex = 99999,
		}, gui)
		corner(r, 30)
		tw(r, 0.4, {Size = UDim2.fromOffset(54, 54), BackgroundTransparency = 1})
		Debris:AddItem(r, 0.5)
	end
end)

local CursorIds = {
	"rbxassetid://118497693394988", "rbxassetid://122425872513515", "rbxassetid://104853224662126",
	"rbxassetid://124194288725564", "rbxassetid://98860259603713", "rbxassetid://131195531355876",
	"rbxassetid://72879470709079", "rbxassetid://133779782682485", "rbxassetid://133233331007912",
}

addLabel(pCursor, "ВЕКТОРНЫЙ КУРСОР (с анимацией при наведении)")
addToggle(pCursor, "✨ Включить кастомный курсор", false, V.setCursorEnabled)
addToggle(pCursor, "🌊 Волна при клике", true, function(v) S.clickFx = v end)
addButton(pCursor, "● Точка", function() setCursorStyle("Dot") end)
addButton(pCursor, "◯ Кольцо", function() setCursorStyle("Ring") end)
addButton(pCursor, "✛ Прицел", function() setCursorStyle("Cross") end)
addButton(pCursor, "◆ Ромб", function() setCursorStyle("Diamond") end)
addButton(pCursor, "💠 Неон", function() setCursorStyle("Neon") end)
addLabel(pCursor, "ТЕКСТУРНЫЕ КУРСОРЫ (по ID)")
for i, id in ipairs(CursorIds) do
	addButton(pCursor, "🖱️ Курсор #" .. i, function()
		V.setCursorEnabled(false)
		UIS.MouseIconEnabled = true
		UIS.MouseIcon = id
		notify("КУРСОР", "Установлен курсор #" .. i)
	end)
end
addButton(pCursor, "❌ Вернуть стандартный курсор", function()
	V.setCursorEnabled(false)
	UIS.MouseIconEnabled = true
	UIS.MouseIcon = ""
	notify("КУРСОР", "Стандартный курсор возвращён")
end)

end
do
-- =============================================================================
-- Темы
end
do
-- =============================================================================
addLabel(pTheme, "ВЫБЕРИТЕ ТЕМУ ИНТЕРФЕЙСА")
for _, t in ipairs(Themes) do
	addButton(pTheme, "🎨 " .. t.name, function()
		applyTheme(t)
		notify("ТЕМА", "Применена: " .. t.name)
	end)
end

end
do
-- =============================================================================
-- Интерфейс
end
do
-- =============================================================================
addLabel(pUi, "МАСШТАБ И АНИМАЦИИ")
addSlider(pUi, "Масштаб меню", 0.7, 1.4, 1, 2, function(v) mainScale.Scale = v end)
addSlider(pUi, "Скорость анимаций", 0.3, 3, 1, 1, function(v) animSpeed = v end)
addLabel(pUi, "ГОРЯЧИЕ КЛАВИШИ: RightShift — открыть/закрыть меню")
addButton(pUi, "🔄 Сбросить всё визуальное", function()
	Lighting.Brightness = V.orig.Brightness; Lighting.Ambient = V.orig.Ambient
	Lighting.OutdoorAmbient = V.orig.OutdoorAmbient; Lighting.GlobalShadows = V.orig.GlobalShadows
	Lighting.FogEnd = V.orig.FogEnd; Lighting.FogStart = V.orig.FogStart
	V.cc.Saturation = 0; V.cc.Contrast = 0
	camera.FieldOfView = 70
	V.setCursorEnabled(false); UIS.MouseIconEnabled = true; UIS.MouseIcon = ""
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
	notify("СБРОС", "Визуальные настройки сброшены (перезапустите скрипт для сброса переключателей)")
end)

end
do
-- =============================================================================
-- Наведение на игроков + позиция курсора + пульсация низкого HP + FPS
end
do
-- =============================================================================
local hoverHl = Instance.new("Highlight")
hoverHl.FillTransparency = 1
hoverHl.OutlineTransparency = 0
hoverHl.Enabled = false
hoverHl.Parent = camera
bind(hoverHl, "OutlineColor", "accent")

local Info = new("Frame", {
	Size = UDim2.fromOffset(170, 50), BackgroundTransparency = 1, Visible = false, ZIndex = 400,
}, gui)
bind(Info, "BackgroundColor3", "bg"); corner(Info, 10)
local infoStroke = new("UIStroke", {Thickness = 1.3, Transparency = 1}, Info); bind(infoStroke, "Color", "accent")
local infoName = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 20), Position = UDim2.fromOffset(8, 5), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 401,
}, Info); bind(infoName, "TextColor3", "text")
local infoBg = new("Frame", {Size = UDim2.new(1, -16, 0, 10), Position = UDim2.fromOffset(8, 30), BackgroundColor3 = rgb(20, 20, 24), BackgroundTransparency = 1, ZIndex = 401}, Info)
corner(infoBg, 5)
local infoFill = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(46, 204, 113), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 402}, infoBg)
corner(infoFill, 5)

local hoveredPlayer = nil
local function showInfo(show)
	local a = show and 0.15 or 1
	tw(Info, 0.15, {BackgroundTransparency = a})
	tw(infoStroke, 0.15, {Transparency = show and 0 or 1})
	tw(infoName, 0.15, {TextTransparency = show and 0 or 1})
	tw(infoBg, 0.15, {BackgroundTransparency = show and 0.3 or 1})
	tw(infoFill, 0.15, {BackgroundTransparency = show and 0 or 1})
end

local fpsAcc, fpsN = 0, 0
local fpsTimer = 0

RunService.RenderStepped:Connect(function(dt)
	local mp = UIS:GetMouseLocation()

	if S.cursor then V.Cursor.Position = UDim2.fromOffset(mp.X, mp.Y) end

	-- Наведение на кнопки интерфейса
	local overGui = false
	if S.cursor then
		for _, o in ipairs(playerGui:GetGuiObjectsAtPosition(mp.X, mp.Y)) do
			if o:IsA("TextButton") or o:IsA("ImageButton") then overGui = true break end
		end
	end

	-- Наведение на игрока в мире
	local plr
	local target = mouse.Target
	if target then
		local model = target:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			local p = Players:GetPlayerFromCharacter(model)
			if p and p ~= player then plr = p end
		end
	end

	if S.hoverOutline and plr then
		hoverHl.Adornee = plr.Character
		hoverHl.Enabled = true
	else
		hoverHl.Enabled = false
	end

	if S.hoverInfo and plr and plr.Character then
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			infoName.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
			local r = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			infoFill.Size = UDim2.fromScale(r, 1)
			infoFill.BackgroundColor3 = V.hpColor(r)
		end
		Info.Position = UDim2.fromOffset(mp.X + 20, mp.Y + 20)
		Info.Visible = true
		if hoveredPlayer ~= plr then showInfo(true) end
	else
		if hoveredPlayer then showInfo(false) end
	end
	hoveredPlayer = (S.hoverInfo and plr) or nil

	-- Плавный рост курсора при наведении
	if S.cursor then
		local goal = (overGui or plr) and 1.6 or 1
		V.cursorScale.Scale += (goal - V.cursorScale.Scale) * math.min(1, dt * 14)
	end

	-- Пульсация при низком HP
	if S.hud and S.lowPulse and V.currentRatio < 0.25 and V.currentRatio > 0 then
		local p = (math.sin(os.clock() * 8) + 1) / 2
		V.hudStroke.Color = rgb(80, 80, 90):Lerp(rgb(255, 60, 60), p)
		V.hudStroke.Thickness = 1.6 + p * 1.6
	elseif V.hudStroke.Thickness ~= 1.6 then
		V.hudStroke.Thickness = 1.6
	end

	-- FPS и пинг
	if S.fps then
		fpsAcc += dt; fpsN += 1; fpsTimer += dt
		if fpsTimer >= 0.5 then
			local fps = math.floor(fpsN / fpsAcc + 0.5)
			local ping = 0
			pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			V.fpsLabel.Text = fps .. " FPS · " .. ping .. " ms"
			fpsAcc, fpsN, fpsTimer = 0, 0, 0
		end
	end
end)

end
do
-- =============================================================================
-- Старт
end
do
-- =============================================================================
-- =============================================================================
-- ======================  РАСШИРЕНИЕ v2: ХАБ, HUD, МИР+, УТИЛИТЫ  ============
-- =============================================================================
V.SoundService = game:GetService("SoundService")
V.TeleportService = game:GetService("TeleportService")

-- Настройки запуска (меняйте здесь)
V.SHOW_START_MENU = true   -- показывать стартовое меню игры при входе
V.SHOW_GREETING = true     -- приветственное уведомление

V.pHub = createTab("🏠 Хаб / Меню игры")
V.pHudTab = createTab("📊 HUD")
V.pWorld2 = createTab("🌍 Мир+")
V.pChar = createTab("🧍 Персонаж")
V.pTools = createTab("🛠️ Утилиты")

function V.addInput(parent, placeholder, default, height, multiline)
	local tb = new("TextBox", {
		Size = UDim2.new(1, -8, 0, height or 36), BackgroundTransparency = 0.35, PlaceholderText = placeholder,
		Text = default or "", Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		MultiLine = multiline or false, TextWrapped = multiline or false, ClearTextOnFocus = false, ZIndex = 13,
	}, parent)
	bind(tb, "BackgroundColor3", "btn"); bind(tb, "TextColor3", "text"); bind(tb, "PlaceholderColor3", "sub")
	corner(tb, 10)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingRight = UDim.new(0, 10)}, tb)
	return tb
end

-- История уведомлений (перехватываем notify)
V.NotifHistory = {}
V.toastsEnabled = true
do
	local baseNotify = notify
	notify = function(title, desc)
		table.insert(V.NotifHistory, 1, {title, desc, os.date("%H:%M:%S")})
		if #V.NotifHistory > 30 then table.remove(V.NotifHistory) end
		if V.toastsEnabled then baseNotify(title, desc) end
	end
end

-- Универсальное диалоговое окно
function V.dialog(title, text, yesText, noText, onYes)
	local overlay = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1, ZIndex = 2000, Active = true,
	}, gui)
	local box = new("Frame", {
		Size = UDim2.fromOffset(360, 200), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.05, ZIndex = 2001,
	}, overlay)
	bind(box, "BackgroundColor3", "bg"); corner(box, 16)
	local st = new("UIStroke", {Thickness = 1.8}, box); bind(st, "Color", "accent")
	local sc = new("UIScale", {Scale = 0.8}, box)
	local t = new("TextLabel", {
		Size = UDim2.new(1, -32, 0, 28), Position = UDim2.fromOffset(16, 12), BackgroundTransparency = 1, Text = title,
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2002,
	}, box); bind(t, "TextColor3", "accent")
	local d = new("TextLabel", {
		Size = UDim2.new(1, -32, 1, -110), Position = UDim2.fromOffset(16, 46), BackgroundTransparency = 1, Text = text,
		Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 2002,
	}, box); bind(d, "TextColor3", "text")

	local function close()
		tw(overlay, 0.15, {BackgroundTransparency = 1}); tw(sc, 0.15, {Scale = 0.8})
		task.delay(0.16, function() overlay:Destroy() end)
	end
	local function mkBtn(txt, x, color, cb)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(150, 38), Position = UDim2.new(0, x, 1, -52), Text = txt, Font = Enum.Font.GothamBold,
			TextSize = 13, TextColor3 = rgb(255, 255, 255), BackgroundColor3 = color, ZIndex = 2003,
		}, box)
		corner(b, 10); hoverFx(b, b)
		b.Activated:Connect(cb)
	end
	if noText then
		mkBtn(yesText or "OK", 20, rgb(231, 76, 60), function() close(); if onYes then pcall(onYes) end end)
		mkBtn(noText, 190, rgb(70, 130, 80), close)
	else
		mkBtn(yesText or "OK", 105, rgb(70, 130, 80), close)
	end
	tw(overlay, 0.2, {BackgroundTransparency = 0.5})
	tw(sc, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
end

end
do
-- ---------------------------------------------------------------------------
-- Стартовое меню игры / меню паузы (клавиша P)
end
do
-- ---------------------------------------------------------------------------
V.menuBlur = Instance.new("BlurEffect")
V.menuBlur.Size = 0; V.menuBlur.Name = "VisualsLegalMenuBlur"; V.menuBlur.Parent = Lighting

V.Start = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 1500, Active = true}, gui)
bind(V.Start, "BackgroundColor3", "bg")

V.stars = {}
V.rng = Random.new()
for _ = 1, 40 do
	local sz = V.rng:NextInteger(2, 4)
	local s = new("Frame", {
		Size = UDim2.fromOffset(sz, sz), Position = UDim2.fromScale(V.rng:NextNumber(), V.rng:NextNumber()),
		BackgroundColor3 = rgb(255, 245, 215), BorderSizePixel = 0, ZIndex = 1501,
	}, V.Start)
	corner(s, sz)
	table.insert(V.stars, {s, V.rng:NextNumber(0, 6)})
end

V.StartPanel = new("Frame", {
	Size = UDim2.fromOffset(320, 380), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1, ZIndex = 1502,
}, V.Start)
local panelScale = new("UIScale", {Scale = 1}, V.StartPanel)
local StartTitle = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "ROBLOX VISUALS",
	Font = Enum.Font.GothamBlack, TextSize = 34, ZIndex = 1503,
}, V.StartPanel); bind(StartTitle, "TextColor3", "accent")
local StartSub = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1,
	Text = "Добро пожаловать, " .. player.DisplayName, Font = Enum.Font.GothamSemibold, TextSize = 13, ZIndex = 1503,
}, V.StartPanel); bind(StartSub, "TextColor3", "sub")
local StartList = new("Frame", {
	Size = UDim2.new(1, 0, 1, -96), Position = UDim2.fromOffset(0, 92), BackgroundTransparency = 1, ZIndex = 1503,
}, V.StartPanel)
new("UIListLayout", {Padding = UDim.new(0, 10)}, StartList)

local function addStartBtn(text, cb)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 0.2, Text = text,
		Font = Enum.Font.GothamBold, TextSize = 15, ZIndex = 1504,
	}, StartList)
	bind(b, "BackgroundColor3", "btn"); bind(b, "TextColor3", "text"); corner(b, 12)
	local st = new("UIStroke", {Thickness = 1.3}, b); bind(st, "Color", "accent")
	hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
	return b
end

V.startOpen = false
local playBtn
V.pauseHooks = {}   -- заполняется ниже: открыть/закрыть меню паузы (клавиша P)
function V.showStart(v, pause)
	if pause and v and V.pauseHooks.open then
		V.pauseHooks.open(); V.startOpen = true; return
	end
	if not v and V.pauseHooks.isOpen and V.pauseHooks.isOpen() then
		V.pauseHooks.close(); V.startOpen = false; return
	end
	V.startOpen = v
	if v then
		StartTitle.Text = pause and "ПАУЗА" or "ROBLOX VISUALS"
		playBtn.Text = pause and "▶  ПРОДОЛЖИТЬ" or "▶  ИГРАТЬ"
		V.Start.Visible = true
		V.Start.BackgroundTransparency = 1
		tw(V.Start, 0.3, {BackgroundTransparency = 0.15}); tw(V.menuBlur, 0.3, {Size = 18})
		panelScale.Scale = 0.85
		tw(panelScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
	else
		tw(V.Start, 0.25, {BackgroundTransparency = 1}); tw(V.menuBlur, 0.25, {Size = 0})
		tw(panelScale, 0.2, {Scale = 0.9})
		task.delay(0.26, function() if not V.startOpen then V.Start.Visible = false end end)
	end
end

function V.exitGame()
	V.dialog("🚪 ВЫЙТИ ИЗ ИГРЫ?", "Вы действительно хотите выйти из игры?", "Выйти", "Остаться", function()
		player:Kick("Вы вышли из игры через ROBLOX VISUALS. До встречи!")
	end)
end
function V.rejoin()
	V.dialog("🔄 ПЕРЕЗАЙТИ?", "Вы будете перемещены на новый сервер этой игры.", "Перезайти", "Отмена", function()
		pcall(function() V.TeleportService:Teleport(game.PlaceId, player) end)
	end)
end
function V.respawn()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
end

playBtn = addStartBtn("▶  ИГРАТЬ", function() V.showStart(false) end)
addStartBtn("⚙️  НАСТРОЙКИ", function() V.showStart(false); setMenu(true) end)
addStartBtn("🔄  ПЕРЕЗАЙТИ НА СЕРВЕР", V.rejoin)
addStartBtn("🚪  ВЫЙТИ ИЗ ИГРЫ", V.exitGame)

end
do
-- ---------------------------------------------------------------------------
-- Вкладка: Хаб / Меню игры
end
do
-- ---------------------------------------------------------------------------
addLabel(V.pHub, "МЕНЮ ИГРЫ")
addButton(V.pHub, "🏠 Открыть меню игры (клавиша P)", function() setMenu(false); V.showStart(true, true) end)
addButton(V.pHub, "🔄 Перезайти на сервер", V.rejoin)
addButton(V.pHub, "💀 Сбросить персонажа (респавн)", V.respawn)
addButton(V.pHub, "🚪 Выйти из игры", V.exitGame)
addLabel(V.pHub, "ИНФОРМАЦИЯ О СЕРВЕРЕ")
V.srvLabel = addLabel(V.pHub, "")
V.srvLabel.Size = UDim2.new(1, -8, 0, 44); V.srvLabel.TextWrapped = true
V.srvLabel.TextYAlignment = Enum.TextYAlignment.Top; V.srvLabel.Font = Enum.Font.Code
addButton(V.pHub, "ℹ️ Показать данные сервера уведомлением", function()
	notify("СЕРВЕР", #Players:GetPlayers() .. " игроков · Place " .. game.PlaceId)
end)
V.clockLabel = new("TextLabel", {
	Size = UDim2.fromOffset(260, 22), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 38),
	BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Right, TextStrokeTransparency = 0.6, Visible = false, ZIndex = 200,
}, gui); bind(V.clockLabel, "TextColor3", "text")
addToggle(V.pHub, "🕒 Часы и таймер сессии на экране", false, function(v) V.clockLabel.Visible = v end)
addLabel(V.pHub, "НАСТРОЙКИ МЕНЮ")
addSlider(V.pHub, "Прозрачность меню", 0, 0.8, 0.08, 2, function(v) Main.BackgroundTransparency = v end)
addToggle(V.pHub, "📱 Мобильный режим (крупное меню)", false, function(v) mainScale.Scale = v and 1.25 or 1 end)

end
do
-- ---------------------------------------------------------------------------
-- Вкладка: HUD
end
do
-- ---------------------------------------------------------------------------
local InfoBox = new("Frame", {
	Size = UDim2.fromOffset(240, 60), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0),
	BackgroundTransparency = 1, ZIndex = 120,
}, gui)
new("UIListLayout", {Padding = UDim.new(0, 2)}, InfoBox)
local function hudLine()
	local l = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextStrokeTransparency = 0.6, Visible = false, ZIndex = 121,
	}, InfoBox)
	bind(l, "TextColor3", "accent")
	return l
end
V.coordLbl, V.speedLbl, V.compLbl = hudLine(), hudLine(), hudLine()

addLabel(V.pHudTab, "ИНФОРМАЦИЯ НА ЭКРАНЕ")
addToggle(V.pHudTab, "📍 Координаты (XYZ)", false, function(v) V.coordLbl.Visible = v end)
addToggle(V.pHudTab, "💨 Спидометр", false, function(v) V.speedLbl.Visible = v end)
addToggle(V.pHudTab, "🧭 Компас", false, function(v) V.compLbl.Visible = v end)

-- Список игроков
local PList = new("Frame", {
	Size = UDim2.fromOffset(200, 10), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 70),
	BackgroundTransparency = 0.3, Visible = false, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 120,
}, gui)
bind(PList, "BackgroundColor3", "bg"); corner(PList, 10)
new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, PList)
new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, PList)
local function rebuildPList()
	for _, c in ipairs(PList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for i, p in ipairs(Players:GetPlayers()) do
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = i, ZIndex = 121}, PList)
		local av = new("ImageLabel", {
			Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(0, 2), BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48", ZIndex = 122,
		}, row)
		corner(av, 11)
		local nm = new("TextLabel", {
			Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(28, 0), BackgroundTransparency = 1,
			Text = p.DisplayName, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 122,
		}, row)
		bind(nm, "TextColor3", "text")
	end
end
Players.PlayerAdded:Connect(function() task.wait(0.2); rebuildPList() end)
Players.PlayerRemoving:Connect(function() task.defer(rebuildPList) end)
rebuildPList()
addToggle(V.pHudTab, "👥 Мини-список игроков", false, function(v) PList.Visible = v end)

-- Прицел
local Cross = new("Frame", {
	Size = UDim2.fromOffset(60, 60), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1, Visible = false, ZIndex = 95,
}, gui)
local crossStyles = {"Plus", "Dot", "Circle", "Gap"}
local crossIdx, crossSize = 1, 10
local function buildCross()
	for _, c in ipairs(Cross:GetChildren()) do c:Destroy() end
	local col, s, style = Theme.accent, crossSize, crossStyles[crossIdx]
	local function bar(w, h, x, y)
		return new("Frame", {
			Size = UDim2.fromOffset(w, h), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, x, 0.5, y),
			BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 96,
		}, Cross)
	end
	if style == "Plus" then
		bar(2, s * 2, 0, 0); bar(s * 2, 2, 0, 0)
	elseif style == "Dot" then
		corner(bar(5, 5, 0, 0), 3)
	elseif style == "Circle" then
		local f = bar(s * 2, s * 2, 0, 0)
		f.BackgroundTransparency = 1; corner(f, s)
		new("UIStroke", {Color = col, Thickness = 2}, f)
	else
		bar(2, s, 0, -s * 1.2); bar(2, s, 0, s * 1.2); bar(s, 2, -s * 1.2, 0); bar(s, 2, s * 1.2, 0); bar(2, 2, 0, 0)
	end
end
buildCross()
table.insert(onThemeChanged, buildCross)
addLabel(V.pHudTab, "ПРИЦЕЛ В ЦЕНТРЕ ЭКРАНА")
addToggle(V.pHudTab, "➕ Показывать прицел", false, function(v) Cross.Visible = v end)
addSlider(V.pHudTab, "Размер прицела", 4, 30, 10, 0, function(v) crossSize = v; buildCross() end)
addButton(V.pHudTab, "🔁 Сменить стиль прицела", function()
	crossIdx = crossIdx % #crossStyles + 1
	buildCross()
	notify("ПРИЦЕЛ", "Стиль: " .. crossStyles[crossIdx])
end)

-- Кинематографичные полосы
local barTop = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, ZIndex = 85}, gui)
local barBot = new("Frame", {
	Size = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
	BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, ZIndex = 85,
}, gui)
addLabel(V.pHudTab, "КИНО")
addToggle(V.pHudTab, "🎬 Кинематографичные чёрные полосы", false, function(v)
	local h = v and 0.11 or 0
	tw(barTop, 0.5, {Size = UDim2.new(1, 0, h, 0)}); tw(barBot, 0.5, {Size = UDim2.new(1, 0, h, 0)})
end)

end
do
-- ---------------------------------------------------------------------------
-- Вкладка: Мир+
end
do
-- ---------------------------------------------------------------------------
local bgBlur = Instance.new("BlurEffect")
bgBlur.Size = 0; bgBlur.Name = "VisualsLegalBlur"; bgBlur.Parent = Lighting
local bloom = Instance.new("BloomEffect")
bloom.Enabled = false; bloom.Intensity = 1; bloom.Size = 24; bloom.Threshold = 0.9
bloom.Name = "VisualsLegalBloom"; bloom.Parent = Lighting

addLabel(V.pWorld2, "ЭФФЕКТЫ КАМЕРЫ")
addSlider(V.pWorld2, "Размытие картинки", 0, 24, 0, 0, function(v) bgBlur.Size = v end)
addToggle(V.pWorld2, "✨ Свечение (Bloom)", false, function(v) bloom.Enabled = v end)
addSlider(V.pWorld2, "Сила свечения", 0, 3, 1, 1, function(v) bloom.Intensity = v end)
addSlider(V.pWorld2, "Макс. дальность зума камеры", 5, 200, player.CameraMaxZoomDistance, 0, function(v)
	player.CameraMaxZoomDistance = v
end)

addLabel(V.pWorld2, "ЦВЕТОВЫЕ ФИЛЬТРЫ")
local tints = {
	{"Нормальный", rgb(255, 255, 255)}, {"Сепия", rgb(255, 225, 185)}, {"Холодный", rgb(195, 222, 255)},
	{"Тёплый", rgb(255, 222, 195)}, {"Зелёный", rgb(205, 255, 215)}, {"Розовый", rgb(255, 210, 232)},
}
local tintIdx = 1
addButton(V.pWorld2, "🎞️ Следующий цветовой фильтр", function()
	tintIdx = tintIdx % #tints + 1
	tw(V.cc, 0.5, {TintColor = tints[tintIdx][2]})
	notify("ФИЛЬТР", tints[tintIdx][1])
end)

addLabel(V.pWorld2, "ВРЕМЯ И ПОГОДА (только у вас на экране)")
V.autoTime, V.autoSpeed = false, 1
addToggle(V.pWorld2, "🌗 Автосмена времени суток", false, function(v) V.autoTime = v end)
addSlider(V.pWorld2, "Скорость суток (часов/мин)", 0.1, 6, 1, 1, function(v) V.autoSpeed = v end)

V.WPart = Instance.new("Part")
V.WPart.Name = "VisualsWeather"; V.WPart.Anchored = true; V.WPart.CanCollide = false; V.WPart.CanQuery = false
V.WPart.CanTouch = false; V.WPart.Transparency = 1; V.WPart.Size = Vector3.new(80, 1, 80); V.WPart.Parent = camera

local snow = Instance.new("ParticleEmitter")
snow.Enabled = false; snow.Rate = 160; snow.Lifetime = NumberRange.new(6, 8); snow.Speed = NumberRange.new(8, 12)
snow.EmissionDirection = Enum.NormalId.Bottom; snow.SpreadAngle = Vector2.new(25, 25)
snow.Size = NumberSequence.new(0.3); snow.Color = ColorSequence.new(rgb(255, 255, 255))
snow.Transparency = NumberSequence.new(0.2); snow.LightEmission = 0.4
snow.Rotation = NumberRange.new(0, 360); snow.RotSpeed = NumberRange.new(-60, 60); snow.Parent = V.WPart

local rain = Instance.new("ParticleEmitter")
rain.Enabled = false; rain.Rate = 500; rain.Lifetime = NumberRange.new(0.9, 1.1); rain.Speed = NumberRange.new(70, 90)
rain.EmissionDirection = Enum.NormalId.Bottom; rain.SpreadAngle = Vector2.new(3, 3)
rain.Size = NumberSequence.new(0.18); rain.Color = ColorSequence.new(rgb(170, 200, 255))
rain.Transparency = NumberSequence.new(0.5); rain.Orientation = Enum.ParticleOrientation.VelocityParallel
rain.Parent = V.WPart

addToggle(V.pWorld2, "❄️ Снег", false, function(v) snow.Enabled = v end)
addToggle(V.pWorld2, "🌧️ Дождь", false, function(v) rain.Enabled = v end)

end
do
-- ---------------------------------------------------------------------------
-- Вкладка: Персонаж (косметика, видна только вам)
end
do
-- ---------------------------------------------------------------------------
local cosm = {trail = false, glow = false, halo = false}
local function applyCosm()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local head = char and char:FindFirstChild("Head")
	if not root then return end

	local tr = root:FindFirstChild("VLTrail")
	if cosm.trail and not tr then
		local a0 = new("Attachment", {Name = "VLA0", Position = Vector3.new(0, 1, 0)}, root)
		local a1 = new("Attachment", {Name = "VLA1", Position = Vector3.new(0, -1, 0)}, root)
		new("Trail", {
			Name = "VLTrail", Attachment0 = a0, Attachment1 = a1, Lifetime = 0.7, LightEmission = 0.6,
			Color = ColorSequence.new(Theme.accent), Transparency = NumberSequence.new(0.1, 1),
			WidthScale = NumberSequence.new(1, 0),
		}, root)
	elseif not cosm.trail and tr then
		tr:Destroy()
		local a0, a1 = root:FindFirstChild("VLA0"), root:FindFirstChild("VLA1")
		if a0 then a0:Destroy() end
		if a1 then a1:Destroy() end
	end

	local gl = root:FindFirstChild("VLGlow")
	if cosm.glow and not gl then
		new("PointLight", {Name = "VLGlow", Color = Theme.accent, Range = 16, Brightness = 2}, root)
	elseif not cosm.glow and gl then
		gl:Destroy()
	end

	local ha = char:FindFirstChild("VLHalo")
	if cosm.halo and head and not ha then
		local p = new("Part", {
			Name = "VLHalo", Size = Vector3.new(0.2, 2.2, 2.2), Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon,
			Color = Theme.accent, CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
			CFrame = head.CFrame * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		}, char)
		local w = Instance.new("WeldConstraint")
		w.Part0 = head; w.Part1 = p; w.Parent = p
	elseif not cosm.halo and ha then
		ha:Destroy()
	end
end
table.insert(onThemeChanged, function()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local tr = root and root:FindFirstChild("VLTrail")
	if tr then tr.Color = ColorSequence.new(Theme.accent) end
	local gl = root and root:FindFirstChild("VLGlow")
	if gl then gl.Color = Theme.accent end
	local ha = char:FindFirstChild("VLHalo")
	if ha then ha.Color = Theme.accent end
end)
player.CharacterAdded:Connect(function(c)
	c:WaitForChild("HumanoidRootPart", 5)
	task.wait(0.3)
	applyCosm()
end)

addLabel(V.pChar, "КОСМЕТИКА ПЕРСОНАЖА (видна только вам)")
addToggle(V.pChar, "✨ Шлейф при движении", false, function(v) cosm.trail = v; applyCosm() end)
addToggle(V.pChar, "💡 Свечение вокруг персонажа", false, function(v) cosm.glow = v; applyCosm() end)
addToggle(V.pChar, "😇 Нимб над головой", false, function(v) cosm.halo = v; applyCosm() end)

end
do
-- ---------------------------------------------------------------------------
-- Вкладка: Утилиты
end
do
-- ---------------------------------------------------------------------------
addLabel(V.pTools, "ЗАМЕТКИ (хранятся до выхода из игры)")
V.addInput(V.pTools, "Ваши заметки...", "", 110, true)

addLabel(V.pTools, "СЕКУНДОМЕР")
V.swRunning, V.swStart, V.swAccum = false, 0, 0
V.swLabel = addLabel(V.pTools, "⏱️ 00:00.0")
V.swLabel.Font = Enum.Font.Code; V.swLabel.TextSize = 16
addButton(V.pTools, "⏯️ Секундомер: старт / стоп", function()
	if V.swRunning then V.swAccum += os.clock() - V.swStart; V.swRunning = false
	else V.swStart = os.clock(); V.swRunning = true end
end)
addButton(V.pTools, "↩️ Секундомер: сброс", function() V.swRunning = false; V.swAccum = 0 end)

addLabel(V.pTools, "РАДИО (ID вашей музыки из Roblox)")
local Radio = Instance.new("Sound")
Radio.Name = "VisualsRadio"; Radio.Volume = 0.5; Radio.Parent = V.SoundService
local radioBox = V.addInput(V.pTools, "ID аудио, например 1843529606", "", 36, false)
addButton(V.pTools, "▶️ Играть по ID", function()
	local id = radioBox.Text:match("%d+")
	if not id then notify("РАДИО", "Введите числовой ID аудио"); return end
	Radio.SoundId = "rbxassetid://" .. id
	Radio:Play()
	notify("РАДИО", "Запущено: " .. id)
end)
addButton(V.pTools, "⏯️ Пауза / продолжить", function()
	if Radio.IsPlaying then Radio:Pause() else Radio:Resume() end
end)
addButton(V.pTools, "⏹️ Остановить", function() Radio:Stop() end)
addToggle(V.pTools, "🔁 Повтор", false, function(v) Radio.Looped = v end)
addSlider(V.pTools, "Громкость радио", 0, 1, 0.5, 2, function(v) Radio.Volume = v end)

addLabel(V.pTools, "ЗВУКИ И УВЕДОМЛЕНИЯ")
V.clickSnd = Instance.new("Sound")
V.clickSnd.SoundId = "rbxassetid://6895079853"; V.clickSnd.Volume = 0.5; V.clickSnd.Parent = V.SoundService
V.uiSound = true
addToggle(V.pTools, "🔊 Звук нажатия кнопок меню", true, function(v) V.uiSound = v end)
addSlider(V.pTools, "Громкость звуков меню", 0, 1, 0.5, 2, function(v) V.clickSnd.Volume = v end)
addToggle(V.pTools, "🔔 Всплывающие уведомления", true, function(v) V.toastsEnabled = v end)
addButton(V.pTools, "📜 Центр уведомлений (последние 6)", function()
	local lines = {}
	for i = 1, math.min(6, #V.NotifHistory) do
		local n = V.NotifHistory[i]
		table.insert(lines, "[" .. n[3] .. "] " .. n[1] .. ": " .. n[2])
	end
	V.dialog("🔔 УВЕДОМЛЕНИЯ", #lines > 0 and table.concat(lines, "\n") or "Пока пусто", "Закрыть")
end)

V.photoMode = false
function V.setPhoto(v)
	V.photoMode = v
	gui.Enabled = not v
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not v) end)
	if not v and S.hideDefaultHp then
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) end)
	end
	if not v and S.hotbar then
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)
	end
end
addLabel(V.pTools, "ФОТО-РЕЖИМ")
addButton(V.pTools, "📸 Фото-режим (скрыть интерфейс, вернуть — клавиша H)", function()
	setMenu(false)
	notify("ФОТО-РЕЖИМ", "Нажмите H, чтобы вернуть интерфейс")
	task.delay(2.4, function() V.setPhoto(true) end)
end)

end
do
-- ---------------------------------------------------------------------------
-- Горячие клавиши и звук кликов
end
do
-- ---------------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if V.uiSound then
			local pos = input.UserInputType == Enum.UserInputType.Touch
				and Vector2.new(input.Position.X, input.Position.Y) or UIS:GetMouseLocation()
			for _, o in ipairs(playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
				if o:IsA("TextButton") and o:IsDescendantOf(gui) then V.clickSnd:Play() break end
			end
		end
		return
	end
	if gpe then return end
	if input.KeyCode == Keybinds.pause then
		V.showStart(not V.startOpen, true)
		if V.startOpen == false then return end
		setMenu(false)
	elseif input.KeyCode == Keybinds.photo then
		V.setPhoto(not V.photoMode)
	end
end)

end
do
-- ---------------------------------------------------------------------------
-- Общий цикл новых функций
end
do
-- ---------------------------------------------------------------------------
local sessionStart = os.clock()
local infoT = 0
local compDirs = {"С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"}

RunService.RenderStepped:Connect(function()
	V.WPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 35, 0))
end)

RunService.Heartbeat:Connect(function(dt)
	if V.Start.Visible then
		local t = os.clock()
		for _, s in ipairs(V.stars) do s[1].BackgroundTransparency = 0.25 + math.sin(t * 1.5 + s[2]) * 0.4 end
	end
	if V.autoTime then Lighting.ClockTime = (Lighting.ClockTime + dt / 60 * V.autoSpeed) % 24 end

	infoT += dt
	if infoT < 0.1 then return end
	infoT = 0

	local sess = math.floor(os.clock() - sessionStart)
	if V.clockLabel.Visible then
		V.clockLabel.Text = string.format("🕒 %s · сессия %02d:%02d:%02d", os.date("%H:%M"), sess // 3600, sess % 3600 // 60, sess % 60)
	end
	if V.pHub.Visible then
		V.srvLabel.Text = "Игроков: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
			.. "  ·  Place ID: " .. game.PlaceId
			.. string.format("\nВ игре: %02d:%02d:%02d", sess // 3600, sess % 3600 // 60, sess % 60)
	end
	if V.swLabel.Parent then
		local t = V.swAccum + (V.swRunning and (os.clock() - V.swStart) or 0)
		V.swLabel.Text = string.format("⏱️ %02d:%04.1f", math.floor(t / 60), t % 60)
	end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		if V.coordLbl.Visible then
			local p = root.Position
			V.coordLbl.Text = string.format("X %d  Y %d  Z %d", math.floor(p.X + 0.5), math.floor(p.Y + 0.5), math.floor(p.Z + 0.5))
		end
		if V.speedLbl.Visible then
			local v = root.AssemblyLinearVelocity
			V.speedLbl.Text = "Скорость: " .. math.floor(Vector3.new(v.X, 0, v.Z).Magnitude + 0.5) .. " stud/s"
		end
	end
	if V.compLbl.Visible then
		local look = camera.CFrame.LookVector
		local ang = math.deg(math.atan2(look.X, -look.Z)) % 360
		local idx = math.floor((ang + 22.5) / 45) % 8 + 1
		V.compLbl.Text = "Курс: " .. compDirs[idx] .. " " .. math.floor(ang + 0.5) .. "°"
	end
end)

end
do
-- =============================================================================
-- Старт
end
do
-- =============================================================================
-- =============================================================================
-- ======================  РАСШИРЕНИЕ v3  =====================================
-- Друзья, музыка, небо, свой инвентарь, эффекты наведения, интро, поиск, док
end
do
-- =============================================================================
V.GuiService = game:GetService("GuiService")
V.SHOW_INTRO = true   -- красивая анимация при запуске (клик — пропустить)

V.pFriends, V.tabFriends = createTab("👥 Друзья")
V.pMusic = createTab("🎵 Музыка")
V.pSky = createTab("🌌 Небо")
V.pInv = createTab("🎒 Инвентарь")
V.pFx = createTab("✨ Эффекты наведения")

function V.gotoTab(page)
	for _, p in ipairs(pages) do p.Visible = false end
	for i, tb in ipairs(tabButtons) do
		local active = pages[i] == page
		tw(tb, 0.2, {TextColor3 = active and Theme.text or Theme.sub, BackgroundTransparency = active and 0.3 or 1})
	end
	page.Visible = true
end

function V.parseRgb(text, fallback)
	local r, g, b = tostring(text):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
	if not r then return fallback end
	return rgb(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
end

end
do
-- ---------------------------------------------------------------------------
-- ✨ Эффекты при наведении на персонажа: блёстки, свет, кольцо
end
do
-- ---------------------------------------------------------------------------
local sparkle = Instance.new("ParticleEmitter")
sparkle.Name = "VLSparkle"
sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
sparkle.Enabled = false; sparkle.Rate = 35; sparkle.Lifetime = NumberRange.new(0.8, 1.4)
sparkle.Speed = NumberRange.new(1, 3); sparkle.SpreadAngle = Vector2.new(180, 180)
sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 0)})
sparkle.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
sparkle.LightEmission = 1; sparkle.Rotation = NumberRange.new(0, 360); sparkle.RotSpeed = NumberRange.new(-120, 120)
sparkle.Color = ColorSequence.new(Theme.accent)

local sparkleLight = Instance.new("PointLight")
sparkleLight.Name = "VLHoverLight"; sparkleLight.Range = 10; sparkleLight.Brightness = 1.2; sparkleLight.Enabled = false

local ring = Instance.new("Part")
ring.Name = "VLRing"; ring.Anchored = true; ring.CanCollide = false; ring.CanQuery = false; ring.CanTouch = false
ring.CastShadow = false; ring.Material = Enum.Material.Neon; ring.Shape = Enum.PartType.Cylinder
ring.Size = Vector3.new(0.15, 5, 5); ring.Transparency = 1; ring.Color = Theme.accent; ring.Parent = workspace

local fxSparkle, fxRainbow, fxRing = true, false, false

RunService.RenderStepped:Connect(function()
	local plr
	local t = mouse.Target
	if t then
		local model = t:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			local p = Players:GetPlayerFromCharacter(model)
			if p and p ~= player then plr = p end
		end
	end
	local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	local col = fxRainbow and Color3.fromHSV((os.clock() * 0.3) % 1, 0.6, 1) or Theme.accent

	if fxSparkle and root then
		if sparkle.Parent ~= root then sparkle.Parent = root; sparkleLight.Parent = root end
		sparkle.Enabled = true; sparkleLight.Enabled = true
		sparkle.Color = ColorSequence.new(col); sparkleLight.Color = col
	else
		sparkle.Enabled = false; sparkleLight.Enabled = false
	end

	if fxRing and root then
		local pulse = 1 + 0.12 * math.sin(os.clock() * 4)
		ring.Color = col
		ring.Size = Vector3.new(0.15, 5 * pulse, 5 * pulse)
		ring.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
		ring.Transparency += (0.35 - ring.Transparency) * 0.2
	else
		ring.Transparency += (1 - ring.Transparency) * 0.25
	end
end)

addLabel(V.pFx, "ЭФФЕКТЫ ПРИ НАВЕДЕНИИ МЫШИ НА ИГРОКА (видны только вам)")
addToggle(V.pFx, "✨ Блёстки и свет вокруг персонажа", true, function(v) fxSparkle = v end)
addToggle(V.pFx, "🌈 Радужные блёстки", false, function(v) fxRainbow = v end)
addToggle(V.pFx, "⭕ Пульсирующее кольцо под игроком", false, function(v) fxRing = v end)
addToggle(V.pFx, "🖱️ Обводка при наведении", true, function(v) S.hoverOutline = v end)
addToggle(V.pFx, "ℹ️ Карточка игрока при наведении", true, function(v) S.hoverInfo = v end)

end
do
-- ---------------------------------------------------------------------------
-- 🎒 Свой инвентарь сверху
end
do
-- ---------------------------------------------------------------------------
S.hotbar = false
local Hotbar = new("Frame", {
	Size = UDim2.fromOffset(10, 62), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -90),
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Visible = false, ZIndex = 130,
}, gui)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
	HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
}, Hotbar)

local toolOrder = {}
local function collectTools()
	local present = {}
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then present[t] = true end end end
	local ch = player.Character
	if ch then for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") then present[t] = true end end end
	for i = #toolOrder, 1, -1 do if not present[toolOrder[i]] then table.remove(toolOrder, i) end end
	for t in pairs(present) do if not table.find(toolOrder, t) then table.insert(toolOrder, t) end end
end

local function toggleTool(tool)
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum or not tool then return end
	if tool.Parent == ch then hum:UnequipTools() else hum:EquipTool(tool) end
end

local lastSig = ""
local function refreshHotbar(force)
	collectTools()
	local sig = ""
	for _, t in ipairs(toolOrder) do sig ..= t.Name .. (t.Parent == player.Character and "*" or "") .. ";" end
	if sig == lastSig and not force then return end
	lastSig = sig
	for _, c in ipairs(Hotbar:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	for i, tool in ipairs(toolOrder) do
		local equipped = tool.Parent == player.Character
		local b = new("TextButton", {
			Size = UDim2.fromOffset(58, 58), BackgroundTransparency = 0.15, Text = "", LayoutOrder = i, ZIndex = 131,
		}, Hotbar)
		bind(b, "BackgroundColor3", "bg"); corner(b, 12)
		local st = new("UIStroke", {Thickness = equipped and 2.6 or 1, Transparency = equipped and 0 or 0.55}, b)
		bind(st, "Color", "accent")
		if tool.TextureId ~= "" then
			new("ImageLabel", {
				Size = UDim2.fromOffset(40, 40), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1, Image = tool.TextureId, ZIndex = 132,
			}, b)
		else
			local nm = new("TextLabel", {
				Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 1,
				Text = tool.Name, Font = Enum.Font.GothamBold, TextSize = 10, TextWrapped = true, ZIndex = 132,
			}, b)
			bind(nm, "TextColor3", "text")
		end
		local num = new("TextLabel", {
			Size = UDim2.fromOffset(16, 14), Position = UDim2.fromOffset(4, 2), BackgroundTransparency = 1,
			Text = tostring(i), Font = Enum.Font.GothamBlack, TextSize = 10, ZIndex = 133,
		}, b)
		bind(num, "TextColor3", "accent")
		local sc = new("UIScale", {Scale = equipped and 1.12 or 1}, b)
		b.MouseEnter:Connect(function() tw(sc, 0.12, {Scale = equipped and 1.2 or 1.1}) end)
		b.MouseLeave:Connect(function() tw(sc, 0.12, {Scale = equipped and 1.12 or 1}) end)
		b.Activated:Connect(function() toggleTool(tool); task.defer(refreshHotbar, true) end)
	end
end

task.spawn(function()
	while gui.Parent do
		if S.hotbar then pcall(refreshHotbar, false) end
		task.wait(0.2)
	end
end)

local numKeys = {
	Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five,
	Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
}
UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not S.hotbar then return end
	local idx = table.find(numKeys, input.KeyCode)
	if idx and toolOrder[idx] then toggleTool(toolOrder[idx]); task.defer(refreshHotbar, true) end
end)

addLabel(V.pInv, "СВОЙ ИНВЕНТАРЬ (инструменты из вашей игры)")
addToggle(V.pInv, "🎒 Инвентарь сверху вместо стандартного", false, function(v)
	S.hotbar = v
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not v) end)
	toastBaseY = 118
	if v then
		Hotbar.Visible = true
		Hotbar.Position = UDim2.new(0.5, 0, 0, -90)
		refreshHotbar(true)
		tw(Hotbar, 0.4, {Position = UDim2.new(0.5, 0, 0, 12)}, Enum.EasingStyle.Back)
	else
		tw(Hotbar, 0.25, {Position = UDim2.new(0.5, 0, 0, -90)})
		task.delay(0.26, function() if not S.hotbar then Hotbar.Visible = false end end)
	end
end)
addLabel(V.pInv, "Клик по слоту — взять / убрать. Клавиши 1–9 тоже работают.")

-- Меню при Esc (меню Roblox закрыть нельзя, оно остаётся)
local escHook = false
V.GuiService.MenuOpened:Connect(function()
	if escHook then setMenu(false); V.showStart(true, true) end
end)
V.GuiService.MenuClosed:Connect(function()
	if escHook and V.startOpen then V.showStart(false) end
end)
addToggle(V.pHub, "⎋ Открывать моё меню вместе с Esc (меню Roblox останется)", false, function(v) escHook = v end)

end
do
-- ---------------------------------------------------------------------------
-- 🎵 Музыка
end
do
-- ---------------------------------------------------------------------------
V.Music = Instance.new("Sound")
V.Music.Name = "VisualsMusic"; V.Music.Volume = 0.5; V.Music.Parent = V.SoundService
V.playlist, V.trackIdx, V.shuffleOn, V.repeatOn = {}, 0, false, true
-- (объявлено выше) local rebuildPlaylist

local function playTrack(i)
	local t = V.playlist[i]
	if not t then return end
	V.trackIdx = i
	V.Music.SoundId = "rbxassetid://" .. t.id
	V.Music.TimePosition = 0
	V.Music:Play()
	notify("🎵 ИГРАЕТ", t.name)
	if V.rebuildPlaylist then V.rebuildPlaylist() end
end
function V.nextTrack()
	if #V.playlist == 0 then return end
	playTrack(V.shuffleOn and math.random(#V.playlist) or (V.trackIdx % #V.playlist + 1))
end
function V.prevTrack()
	if #V.playlist == 0 then return end
	playTrack((V.trackIdx - 2) % #V.playlist + 1)
end
function V.toggleMusic()
	if #V.playlist == 0 then notify("🎵 МУЗЫКА", "Плейлист пуст — добавьте трек"); return end
	if V.trackIdx == 0 then playTrack(1)
	elseif V.Music.IsPlaying then V.Music:Pause()
	elseif V.Music.IsPaused then V.Music:Resume()
	else V.Music:Play() end
end
V.Music.Ended:Connect(function() if V.repeatOn then V.nextTrack() end end)

addLabel(V.pMusic, "ПЛЕЕР")
local nowLbl = addLabel(V.pMusic, "🎵 Ничего не играет")
nowLbl.Font = Enum.Font.GothamBold; nowLbl.TextSize = 12
local progHolder = new("Frame", {Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 0.35, ZIndex = 13}, V.pMusic)
bind(progHolder, "BackgroundColor3", "btn"); corner(progHolder, 10)
local timeLbl = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 4), BackgroundTransparency = 1, Text = "00:00 / 00:00",
	Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
}, progHolder); bind(timeLbl, "TextColor3", "text")
local progBar = new("Frame", {Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 0, 28), BorderSizePixel = 0, ZIndex = 14}, progHolder)
bind(progBar, "BackgroundColor3", "header"); corner(progBar, 3)
local progFill = new("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 15}, progBar)
bind(progFill, "BackgroundColor3", "accent"); corner(progFill, 3)

local ctlRow = new("Frame", {Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, ZIndex = 13}, V.pMusic)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6)}, ctlRow)
local function ctlBtn(txt, cb)
	local b = new("TextButton", {
		Size = UDim2.new(0.25, -5, 1, 0), BackgroundTransparency = 0.25, Text = txt, Font = Enum.Font.GothamBold,
		TextSize = 16, ZIndex = 14,
	}, ctlRow)
	bind(b, "BackgroundColor3", "btn"); bind(b, "TextColor3", "text"); corner(b, 10)
	local st = new("UIStroke", {Thickness = 1}, b); bind(st, "Color", "accent")
	hoverFx(b, b)
	b.Activated:Connect(cb)
end
ctlBtn("⏮", V.prevTrack); ctlBtn("⏯", V.toggleMusic); ctlBtn("⏭", V.nextTrack)
ctlBtn("⏹", function() V.Music:Stop(); V.trackIdx = 0; if V.rebuildPlaylist then V.rebuildPlaylist() end end)

addSlider(V.pMusic, "Громкость музыки", 0, 1, 0.5, 2, function(v) V.Music.Volume = v end)
addToggle(V.pMusic, "🔀 Случайный порядок", false, function(v) V.shuffleOn = v end)
addToggle(V.pMusic, "🔁 Автопереход к следующему треку", true, function(v) V.repeatOn = v end)

addLabel(V.pMusic, "ДОБАВИТЬ ТРЕК")
local trkName = V.addInput(V.pMusic, "Название трека", "", 36, false)
local trkId = V.addInput(V.pMusic, "ID аудио (число)", "", 36, false)
addLabel(V.pMusic, "ПЛЕЙЛИСТ (хранится до выхода из игры)")
local PL = new("Frame", {Size = UDim2.new(1, -8, 0, 10), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 13}, V.pMusic)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, PL)

V.rebuildPlaylist = function()
	for _, c in ipairs(PL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for i, t in ipairs(V.playlist) do
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 0.4, LayoutOrder = i, ZIndex = 14}, PL)
		bind(row, "BackgroundColor3", "btn"); corner(row, 8)
		local pb = new("TextButton", {
			Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1, Text = (i == V.trackIdx and "▶ " or "   ") .. i .. ". " .. t.name,
			Font = i == V.trackIdx and Enum.Font.GothamBold or Enum.Font.GothamSemibold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
		}, row)
		bind(pb, "TextColor3", i == V.trackIdx and "accent" or "text")
		pb.Activated:Connect(function() playTrack(i) end)
		local rm = new("TextButton", {
			Size = UDim2.fromOffset(30, 26), Position = UDim2.new(1, -36, 0.5, -13), Text = "✕", Font = Enum.Font.GothamBold,
			TextSize = 12, BackgroundColor3 = rgb(231, 76, 60), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
		}, row)
		corner(rm, 6)
		rm.Activated:Connect(function()
			table.remove(V.playlist, i)
			if V.trackIdx == i then V.Music:Stop(); V.trackIdx = 0 elseif V.trackIdx > i then V.trackIdx -= 1 end
			V.rebuildPlaylist()
		end)
	end
end

addButton(V.pMusic, "➕ Добавить в плейлист", function()
	local id = trkId.Text:match("%d+")
	if not id then notify("МУЗЫКА", "Введите числовой ID аудио"); return end
	local name = trkName.Text:match("%S") and trkName.Text or ("Трек " .. id)
	table.insert(V.playlist, {name = name, id = id})
	trkName.Text = ""; trkId.Text = ""
	V.rebuildPlaylist()
	notify("МУЗЫКА", "Добавлено: " .. name)
end)

-- мини-плеер в меню игры (пауза / старт)
local Mini = new("Frame", {Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 330), BackgroundTransparency = 0.35, ZIndex = 1503}, V.StartPanel)
bind(Mini, "BackgroundColor3", "btn"); corner(Mini, 12)
local miniLbl = new("TextLabel", {
	Size = UDim2.new(1, -118, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
	Text = "🎵 Плейлист пуст", Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1504,
}, Mini); bind(miniLbl, "TextColor3", "text")
local function miniBtn(txt, x, cb)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, x, 0.5, -15), BackgroundTransparency = 0.3, Text = txt,
		Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 1504,
	}, Mini)
	bind(b, "BackgroundColor3", "header"); bind(b, "TextColor3", "text"); corner(b, 8)
	hoverFx(b, b)
	b.Activated:Connect(cb)
end
miniBtn("⏮", -108, V.prevTrack); miniBtn("⏯", -72, V.toggleMusic); miniBtn("⏭", -36, V.nextTrack)

task.spawn(function()
	local function fmt(s) s = math.max(0, math.floor(s)); return string.format("%02d:%02d", s // 60, s % 60) end
	while gui.Parent do
		local t = V.playlist[V.trackIdx]
		local label = t and ((V.Music.IsPlaying and "🎵 " or "⏸ ") .. t.name) or "🎵 Ничего не играет"
		nowLbl.Text = label
		miniLbl.Text = t and label or "🎵 Плейлист пуст"
		if V.Music.TimeLength > 0 then
			timeLbl.Text = fmt(V.Music.TimePosition) .. " / " .. fmt(V.Music.TimeLength)
			progFill.Size = UDim2.fromScale(math.clamp(V.Music.TimePosition / V.Music.TimeLength, 0, 1), 1)
		else
			timeLbl.Text = "00:00 / 00:00"; progFill.Size = UDim2.fromScale(0, 1)
		end
		task.wait(0.25)
	end
end)

end
do
-- ---------------------------------------------------------------------------
-- 🌌 Небо
end
do
-- ---------------------------------------------------------------------------
local skyObj = Lighting:FindFirstChildOfClass("Sky")
if not skyObj then
	skyObj = Instance.new("Sky"); skyObj.Name = "VisualsLegalSky"; skyObj.Parent = Lighting
end
local atm = Lighting:FindFirstChildOfClass("Atmosphere")
if not atm then
	atm = Instance.new("Atmosphere"); atm.Name = "VisualsLegalAtmosphere"
	atm.Density = 0; atm.Haze = 0; atm.Glare = 0; atm.Parent = Lighting
end
local faces = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
local origSky = {stars = skyObj.StarCount, sun = skyObj.SunAngularSize, moon = skyObj.MoonAngularSize, faces = {}}
for _, f in ipairs(faces) do origSky.faces[f] = skyObj[f] end
local origAtm = {Color = atm.Color, Decay = atm.Decay, Density = atm.Density, Haze = atm.Haze, Glare = atm.Glare, Offset = atm.Offset}
local origShift = {top = Lighting.ColorShift_Top, bottom = Lighting.ColorShift_Bottom}
local origClock = Lighting.ClockTime

local skyPresets = {
	{"🌇 Закат", clock = 17.8, color = rgb(255, 170, 120), decay = rgb(255, 110, 80), density = 0.35, haze = 1.5, glare = 0.4, stars = 0, shift = rgb(255, 140, 90)},
	{"🌌 Звёздная ночь", clock = 0, color = rgb(40, 50, 90), decay = rgb(20, 20, 50), density = 0.2, haze = 0.5, glare = 0, stars = 3000, shift = rgb(0, 0, 0)},
	{"🪐 Космос", clock = 0, color = rgb(20, 10, 40), decay = rgb(60, 20, 90), density = 0, haze = 0, glare = 0, stars = 5000, shift = rgb(80, 40, 140)},
	{"🌅 Рассвет", clock = 5.8, color = rgb(255, 190, 170), decay = rgb(255, 130, 130), density = 0.4, haze = 1.8, glare = 0.5, stars = 300, shift = rgb(255, 170, 130)},
	{"🌸 Розовое небо", clock = 14, color = rgb(255, 190, 225), decay = rgb(255, 150, 200), density = 0.4, haze = 1, glare = 0.2, stars = 0, shift = rgb(255, 170, 220)},
	{"🌫️ Туманное утро", clock = 7, color = rgb(200, 205, 215), decay = rgb(150, 155, 165), density = 0.55, haze = 3, glare = 0, stars = 0, shift = rgb(190, 195, 205)},
	{"☣️ Токсичное небо", clock = 15, color = rgb(160, 255, 160), decay = rgb(100, 200, 90), density = 0.45, haze = 2, glare = 0.2, stars = 0, shift = rgb(120, 255, 120)},
	{"🌊 Бирюзовый день", clock = 13, color = rgb(150, 235, 245), decay = rgb(90, 190, 220), density = 0.3, haze = 1, glare = 0.1, stars = 0, shift = rgb(120, 220, 240)},
}

local function applySkyPreset(p)
	if p.clock and not V.autoTime then tw(Lighting, 1.5, {ClockTime = p.clock}) end
	tw(atm, 1.5, {Color = p.color, Decay = p.decay, Density = p.density, Haze = p.haze, Glare = p.glare})
	tw(skyObj, 1.5, {StarCount = p.stars})
	tw(Lighting, 1.5, {ColorShift_Top = p.shift})
	notify("🌌 НЕБО", p[1])
end

addLabel(V.pSky, "СКИНЫ НЕБА (только у вас на экране)")
for _, p in ipairs(skyPresets) do
	addButton(V.pSky, p[1], function() applySkyPreset(p) end)
end
addLabel(V.pSky, "ТОНКАЯ НАСТРОЙКА")
addSlider(V.pSky, "Количество звёзд", 0, 5000, skyObj.StarCount, 0, function(v) skyObj.StarCount = v end)
addSlider(V.pSky, "Размер солнца", 0, 60, skyObj.SunAngularSize, 0, function(v) skyObj.SunAngularSize = v end)
addSlider(V.pSky, "Размер луны", 0, 60, skyObj.MoonAngularSize, 0, function(v) skyObj.MoonAngularSize = v end)
addSlider(V.pSky, "Плотность атмосферы", 0, 1, atm.Density, 2, function(v) atm.Density = v end)
addSlider(V.pSky, "Дымка", 0, 10, atm.Haze, 1, function(v) atm.Haze = v end)
addLabel(V.pSky, "СВОЙ СКАЙБОКС (ID картинок)")
local skyBox = V.addInput(V.pSky, "1 ID на все стороны или 6 ID: bk dn ft lf rt up", "", 36, false)
addButton(V.pSky, "🖼️ Применить скайбокс по ID", function()
	local ids = {}
	for id in skyBox.Text:gmatch("%d+") do table.insert(ids, id) end
	if #ids == 1 then
		for _, f in ipairs(faces) do skyObj[f] = "rbxassetid://" .. ids[1] end
	elseif #ids == 6 then
		for i, f in ipairs(faces) do skyObj[f] = "rbxassetid://" .. ids[i] end
	else
		notify("НЕБО", "Нужен 1 или 6 ID"); return
	end
	notify("🌌 НЕБО", "Скайбокс применён")
end)
addButton(V.pSky, "♻️ Сбросить небо", function()
	for _, f in ipairs(faces) do skyObj[f] = origSky.faces[f] end
	tw(skyObj, 1, {StarCount = origSky.stars, SunAngularSize = origSky.sun, MoonAngularSize = origSky.moon})
	tw(atm, 1, origAtm)
	tw(Lighting, 1, {ColorShift_Top = origShift.top, ColorShift_Bottom = origShift.bottom})
	if not V.autoTime then tw(Lighting, 1, {ClockTime = origClock}) end
	notify("🌌 НЕБО", "Небо возвращено")
end)

end
do
-- ---------------------------------------------------------------------------
-- 👥 Друзья
end
do
-- ---------------------------------------------------------------------------
V.friendsList = {}
V.onlineInfo, V.isRobloxFriend, V.lastState = {}, {}, {}
local statusChecked = false
-- (объявлено выше) local rebuildFriends, refreshStatuses

local function friendState(f)
	if Players:GetPlayerByUserId(f.userId) then return "server", "В этом сервере", rgb(46, 204, 113) end
	local info = V.onlineInfo[f.userId]
	if info and info.IsOnline then
		if info.GameId and tostring(info.GameId) ~= "" then
			return "game", "В игре: " .. tostring(info.LastLocation or "?"), rgb(241, 196, 15)
		end
		return "online", "Онлайн", rgb(52, 152, 219)
	end
	if V.isRobloxFriend[f.userId] and statusChecked then return "offline", "Оффлайн", rgb(130, 130, 140) end
	if not V.isRobloxFriend[f.userId] then return "unknown", "Не друг в Roblox · виден только на этом сервере", rgb(130, 130, 140) end
	return "unknown", "Статус не проверен", rgb(130, 130, 140)
end

local friendNameBox = V.addInput(V.pFriends, "Ник игрока Roblox", "", 36, false)
local friendSummary
addButton(V.pFriends, "➕ Привязать друга по нику", function()
	local name = friendNameBox.Text:match("^%s*(.-)%s*$")
	if name == "" then return end
	for _, f in ipairs(V.friendsList) do
		if f.name:lower() == name:lower() then notify("ДРУЗЬЯ", "Уже в списке"); return end
	end
	task.spawn(function()
		local ok, uid = pcall(Players.GetUserIdFromNameAsync, Players, name)
		if not ok or not uid then notify("ДРУЗЬЯ", "Игрок «" .. name .. "» не найден"); return end
		local okF, isF = pcall(player.IsFriendsWith, player, uid)
		V.isRobloxFriend[uid] = okF and isF or false
		table.insert(V.friendsList, {name = name, userId = uid})
		friendNameBox.Text = ""
		notify("👥 ДРУЗЬЯ", name .. " привязан")
		V.rebuildFriends()
		V.refreshStatuses()
	end)
end)
addButton(V.pFriends, "📥 Импортировать моих друзей Roblox (до 40)", function()
	task.spawn(function()
		local ok, pages_ = pcall(Players.GetFriendsAsync, Players, player.UserId)
		if not ok then notify("ДРУЗЬЯ", "Не удалось загрузить друзей"); return end
		local added = 0
		while true do
			for _, item in ipairs(pages_:GetCurrentPage()) do
				if added >= 40 then break end
				local exists = false
				for _, f in ipairs(V.friendsList) do if f.userId == item.Id then exists = true break end end
				if not exists then
					table.insert(V.friendsList, {name = item.Username, userId = item.Id})
					V.isRobloxFriend[item.Id] = true
					added += 1
				end
			end
			if added >= 40 or pages_.IsFinished then break end
			local okN = pcall(function() pages_:AdvanceToNextPageAsync() end)
			if not okN then break end
		end
		notify("👥 ДРУЗЬЯ", "Добавлено друзей: " .. added)
		V.rebuildFriends()
		V.refreshStatuses()
	end)
end)
addButton(V.pFriends, "🔄 Обновить статусы", function() V.refreshStatuses() end)
local autoFriends = false
addToggle(V.pFriends, "⏱️ Автообновление статусов (каждые 30 с)", false, function(v) autoFriends = v end)
friendSummary = addLabel(V.pFriends, "Друзей в списке: 0")

local FList = new("Frame", {Size = UDim2.new(1, -8, 0, 10), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 13}, V.pFriends)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, FList)

V.rebuildFriends = function()
	for _, c in ipairs(FList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local onlineCount = 0
	for i, f in ipairs(V.friendsList) do
		local key, text, color = friendState(f)
		if key == "server" or key == "game" or key == "online" then onlineCount += 1 end
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 0.35, LayoutOrder = i, ZIndex = 14}, FList)
		bind(row, "BackgroundColor3", "btn"); corner(row, 10)
		local av = new("ImageLabel", {
			Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(8, 6), BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. f.userId .. "&w=100&h=100", ZIndex = 15,
		}, row)
		corner(av, 18)
		new("Frame", {
			Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(34, 34), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 17,
		}, av).Name = "Dot"
		corner(av.Dot, 5)
		local nm = new("TextLabel", {
			Size = UDim2.new(1, -150, 0, 20), Position = UDim2.fromOffset(52, 5), BackgroundTransparency = 1, Text = f.name,
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
		}, row)
		bind(nm, "TextColor3", "text")
		new("TextLabel", {
			Size = UDim2.new(1, -150, 0, 16), Position = UDim2.fromOffset(52, 26), BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
		}, row)
		local rm = new("TextButton", {
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -36, 0.5, -14), Text = "✕", Font = Enum.Font.GothamBold,
			TextSize = 12, BackgroundColor3 = rgb(231, 76, 60), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
		}, row)
		corner(rm, 6)
		rm.Activated:Connect(function()
			table.remove(V.friendsList, i)
			V.rebuildFriends()
		end)
		local info = V.onlineInfo[f.userId]
		if key == "game" and info and info.PlaceId and info.GameId then
			local jb = new("TextButton", {
				Size = UDim2.fromOffset(70, 28), Position = UDim2.new(1, -112, 0.5, -14), Text = "Зайти", Font = Enum.Font.GothamBold,
				TextSize = 11, BackgroundColor3 = rgb(70, 130, 80), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
			}, row)
			corner(jb, 6)
			jb.Activated:Connect(function()
				V.dialog("👥 ПРИСОЕДИНИТЬСЯ?", "Зайти к игроку " .. f.name .. "?", "Зайти", "Отмена", function()
					pcall(function() V.TeleportService:TeleportToPlaceInstance(info.PlaceId, info.GameId, player) end)
				end)
			end)
		end
	end
	friendSummary.Text = "Друзей в списке: " .. #V.friendsList .. "  ·  онлайн: " .. onlineCount
	V.tabFriends.Text = "  👥 Друзья" .. (onlineCount > 0 and (" (" .. onlineCount .. ")") or "")
end

V.refreshStatuses = function()
	task.spawn(function()
		local ok, res = pcall(function() return player:GetFriendsOnline(200) end)
		if ok and type(res) == "table" then
			V.onlineInfo = {}
			for _, info in ipairs(res) do V.onlineInfo[info.VisitorId] = info end
			statusChecked = true
			for _, f in ipairs(V.friendsList) do
				local key = friendState(f)
				local prev = V.lastState[f.userId]
				V.lastState[f.userId] = key
				if prev and prev ~= key and key ~= "server" and prev ~= "server" then
					if key == "online" or key == "game" then
						notify("👥 ДРУГ ОНЛАЙН", f.name .. " зашёл в Roblox")
					elseif key == "offline" then
						notify("👥 ДРУГ ВЫШЕЛ", f.name .. " теперь оффлайн")
					end
				end
			end
		else
			notify("👥 ДРУЗЬЯ", "Статусы Roblox недоступны (в Studio это не работает)")
		end
		V.rebuildFriends()
	end)
end

Players.PlayerAdded:Connect(function(p)
	for _, f in ipairs(V.friendsList) do
		if f.userId == p.UserId then
			notify("👥 ДРУГ ЗАШЁЛ", p.DisplayName .. " на вашем сервере")
			task.defer(V.rebuildFriends)
		end
	end
end)
Players.PlayerRemoving:Connect(function(p)
	for _, f in ipairs(V.friendsList) do
		if f.userId == p.UserId then
			notify("👥 ДРУГ ВЫШЕЛ", p.DisplayName .. " покинул сервер")
			task.defer(V.rebuildFriends)
		end
	end
end)
task.spawn(function()
	while gui.Parent do
		task.wait(30)
		if autoFriends and #V.friendsList > 0 then V.refreshStatuses() end
	end
end)

end
do
-- ---------------------------------------------------------------------------
-- 🎨 Создатель своей темы
end
do
-- ---------------------------------------------------------------------------
addLabel(pTheme, "СОЗДАТЬ СВОЮ ТЕМУ (цвета в формате R,G,B)")
local thName = V.addInput(pTheme, "Название темы", "Моя тема", 36, false)
local thBg = V.addInput(pTheme, "Фон: 24,20,30", "24, 20, 30", 36, false)
local thHeader = V.addInput(pTheme, "Шапка: 36,28,44", "36, 28, 44", 36, false)
local thAccent = V.addInput(pTheme, "Акцент: 0,220,255", "0, 220, 255", 36, false)
local thText = V.addInput(pTheme, "Текст: 250,250,250", "250, 250, 250", 36, false)
addButton(pTheme, "✨ Применить свою тему", function()
	local bg = V.parseRgb(thBg.Text, Theme.bg)
	local header = V.parseRgb(thHeader.Text, Theme.header)
	applyTheme({
		name = thName.Text, bg = bg, header = header, accent = V.parseRgb(thAccent.Text, Theme.accent),
		text = V.parseRgb(thText.Text, Theme.text), sub = rgb(180, 180, 185), btn = header,
	})
	notify("🎨 ТЕМА", "Своя тема применена")
end)

end
do
-- ---------------------------------------------------------------------------
-- ⚡ Быстрая панель (док)
end
do
-- ---------------------------------------------------------------------------
local Dock = new("Frame", {
	Size = UDim2.fromOffset(10, 44), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14),
	BackgroundTransparency = 0.25, AutomaticSize = Enum.AutomaticSize.X, Visible = false, ZIndex = 140,
}, gui)
bind(Dock, "BackgroundColor3", "bg"); corner(Dock, 22)
local dockStroke = new("UIStroke", {Thickness = 1.4}, Dock); bind(dockStroke, "Color", "accent")
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
	HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
}, Dock)
new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, Dock)
local function dockBtn(icon, cb)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(38, 32), BackgroundTransparency = 0.3, Text = icon, Font = Enum.Font.GothamBold, TextSize = 15, ZIndex = 141,
	}, Dock)
	bind(b, "BackgroundColor3", "btn"); bind(b, "TextColor3", "text"); corner(b, 10)
	hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
end
dockBtn("🏠", function() setMenu(false); V.showStart(not V.startOpen, true) end)
dockBtn("⚙️", function() setMenu(not menuOpen) end)
dockBtn("🎵", V.toggleMusic)
dockBtn("👥", function() setMenu(true); V.gotoTab(V.pFriends) end)
dockBtn("📸", function()
	setMenu(false)
	notify("ФОТО-РЕЖИМ", "Нажмите H, чтобы вернуть интерфейс")
	task.delay(2.4, function() V.setPhoto(true) end)
end)
dockBtn("💀", V.respawn)
addToggle(pUi, "⚡ Быстрая панель внизу экрана", false, function(v) Dock.Visible = v end)

end
do
-- ---------------------------------------------------------------------------
-- 🔍 Поиск функций
end
do
-- ---------------------------------------------------------------------------
Title.Size = UDim2.fromOffset(320, 48)
local Search = new("TextBox", {
	Size = UDim2.fromOffset(170, 28), Position = UDim2.new(1, -250, 0.5, -14), PlaceholderText = "🔍 Поиск функций...",
	Text = "", ClearTextOnFocus = false, Font = Enum.Font.GothamSemibold, TextSize = 12, ZIndex = 12,
}, Header)
bind(Search, "BackgroundColor3", "btn"); bind(Search, "TextColor3", "text"); bind(Search, "PlaceholderColor3", "sub")
corner(Search, 8)

local function itemText(c)
	if c:IsA("TextButton") then return c.Text end
	local b = c:FindFirstChildWhichIsA("TextButton", true)
	if b and b.Text ~= "" then return b.Text end
	local l = c:FindFirstChildWhichIsA("TextLabel")
	return l and l.Text or ""
end
Search:GetPropertyChangedSignal("Text"):Connect(function()
	local q = Search.Text:lower()
	local bestPage, bestCount = nil, 0
	for _, p in ipairs(pages) do
		local count = 0
		for _, c in ipairs(p:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextBox") then
				if q == "" then
					c.Visible = true
				else
					local match = false
					if c:IsA("TextButton") or c:IsA("Frame") then
						match = itemText(c):lower():find(q, 1, true) ~= nil
					end
					c.Visible = match
					if match then count += 1 end
				end
			end
		end
		if count > bestCount then bestCount = count; bestPage = p end
	end
	if q ~= "" and bestPage then V.gotoTab(bestPage) end
end)

end
do
-- ---------------------------------------------------------------------------
-- 🚀 Анимация запуска
end
do
-- ---------------------------------------------------------------------------
function V.playIntro(done)
	local intro = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(8, 6, 12), ZIndex = 1900, Active = true}, gui)
	local skip = false
	intro.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then skip = true end
	end)

	local istars = {}
	for _ = 1, 70 do
		local sz = V.rng:NextInteger(1, 4)
		local f = new("Frame", {
			Size = UDim2.fromOffset(sz, sz), Position = UDim2.fromScale(V.rng:NextNumber(), V.rng:NextNumber()),
			BackgroundColor3 = rgb(255, 245, 215), BackgroundTransparency = V.rng:NextNumber(0.2, 0.8), BorderSizePixel = 0, ZIndex = 1901,
		}, intro)
		corner(f, sz)
		table.insert(istars, {f, V.rng:NextNumber(0.02, 0.12)})
	end
	local conn = RunService.Heartbeat:Connect(function(dt)
		for _, s in ipairs(istars) do
			local y = s[1].Position.Y.Scale - s[2] * dt
			if y < 0 then y = 1 end
			s[1].Position = UDim2.fromScale(s[1].Position.X.Scale, y)
		end
	end)

	local function ringPulse(delay)
		task.delay(delay, function()
			if not intro.Parent then return end
			local r = new("Frame", {
				Size = UDim2.fromOffset(40, 40), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45),
				BackgroundTransparency = 1, ZIndex = 1902,
			}, intro)
			corner(r, 400)
			local st = new("UIStroke", {Color = Theme.accent, Thickness = 3}, r)
			tw(r, 1.4, {Size = UDim2.fromOffset(900, 900)}, Enum.EasingStyle.Quad)
			tw(st, 1.4, {Transparency = 1})
			Debris:AddItem(r, 1.6)
		end)
	end

	local holder = new("Frame", {
		Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45), BackgroundTransparency = 1, ZIndex = 1903,
	}, intro)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center}, holder)
	local letters = {}
	local word = "ROBLOX VISUALS"
	for i = 1, #word do
		local ch = word:sub(i, i)
		local l = new("TextLabel", {
			Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
			Text = ch == " " and "  " or ch, Font = Enum.Font.GothamBlack, TextSize = 46, TextColor3 = Theme.accent,
			TextTransparency = 1, ZIndex = 1904,
		}, holder)
		new("UIScale", {Scale = 0.3}, l)
		table.insert(letters, l)
	end

	local line = new("Frame", {
		Size = UDim2.fromOffset(0, 3), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.45, 42),
		BackgroundColor3 = Theme.accent, BorderSizePixel = 0, ZIndex = 1903,
	}, intro)
	corner(line, 2)
	local sub = new("TextLabel", {
		Size = UDim2.fromOffset(400, 20), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.45, 56),
		BackgroundTransparency = 1, Text = "L E G A L   E D I T I O N", Font = Enum.Font.Code, TextSize = 13,
		TextColor3 = rgb(200, 200, 210), TextTransparency = 1, ZIndex = 1903,
	}, intro)

	local status = new("TextLabel", {
		Size = UDim2.fromOffset(320, 18), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.71),
		BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 11, TextColor3 = rgb(170, 170, 185), ZIndex = 1903,
	}, intro)
	local back = new("Frame", {
		Size = UDim2.fromOffset(320, 6), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.75),
		BackgroundColor3 = rgb(30, 26, 38), BorderSizePixel = 0, ZIndex = 1903,
	}, intro)
	corner(back, 3)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.accent, BorderSizePixel = 0, ZIndex = 1904}, back)
	corner(fill, 3)

	task.spawn(function()
		local function w(t)
			local e = os.clock() + t
			while os.clock() < e and not skip do task.wait() end
		end
		w(0.3)
		ringPulse(0); ringPulse(0.25)
		for _, l in ipairs(letters) do
			tw(l, 0.35, {TextTransparency = 0}, Enum.EasingStyle.Quad)
			tw(l:FindFirstChildOfClass("UIScale"), 0.45, {Scale = 1}, Enum.EasingStyle.Back)
			w(0.06)
		end
		w(0.25)
		tw(line, 0.7, {Size = UDim2.fromOffset(380, 3)}, Enum.EasingStyle.Quart)
		w(0.4)
		tw(sub, 0.5, {TextTransparency = 0})
		w(0.3)
		local steps = {
			{"Загрузка тем...", 0.25}, {"Подготовка курсоров...", 0.5},
			{"Инициализация HUD...", 0.75}, {"Готово!", 1},
		}
		for _, s in ipairs(steps) do
			status.Text = s[1]
			tw(fill, 0.4, {Size = UDim2.fromScale(s[2], 1)})
			w(0.45)
		end
		w(0.3)
		tw(intro, 0.6, {GroupTransparency = 1})
		w(0.65)
		skip = false
		task.wait(0.05)
		conn:Disconnect()
		intro:Destroy()
		done()
	end)
end

end
do
-- =============================================================================
-- ======================  РАСШИРЕНИЕ v4  =====================================
-- Меню паузы (клавиша P) как у Roblox + карточка игрока с валютой
end
do
-- =============================================================================

end
do
-- ---------- форматирование чисел и сбор статистики игрока ----------
local function commas(n)
	local s = tostring(math.floor(math.abs(n)))
	s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	s = s:gsub("^,", "")
	return (n < 0 and "-" or "") .. s
end
local function fmtVal(v)
	if type(v) == "number" then
		if v % 1 ~= 0 then return string.format("%.1f", v) end
		return commas(v)
	end
	return tostring(v)
end
function V.collectStats(plr)
	local list = {}
	local ls = plr:FindFirstChild("leaderstats")
	if ls then
		for _, v in ipairs(ls:GetChildren()) do
			if v:IsA("ValueBase") then table.insert(list, {v.Name, fmtVal(v.Value)}) end
		end
	end
	return list
end
function V.collectAttrs(plr)
	local list = {}
	for k, v in pairs(plr:GetAttributes()) do
		local tv = type(v)
		if tv == "number" or tv == "string" or tv == "boolean" then table.insert(list, {k, fmtVal(v)}) end
	end
	table.sort(list, function(a, b) return a[1] < b[1] end)
	return list
end
function V.statsSummary(plr)
	local parts = {}
	for i, s in ipairs(V.collectStats(plr)) do
		if i > 3 then break end
		table.insert(parts, s[1] .. ": " .. s[2])
	end
	return #parts > 0 and table.concat(parts, "  ·  ") or "—"
end

end
do
-- ---------- мини-карточка игрока ----------
local Card = new("Frame", {
	Size = UDim2.fromOffset(340, 466), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 0.04, Visible = false, ZIndex = 2600, Active = true,
}, gui)
bind(Card, "BackgroundColor3", "bg"); corner(Card, 16)
local cardStroke = new("UIStroke", {Thickness = 1.8}, Card); bind(cardStroke, "Color", "accent")
local cardScale = new("UIScale", {Scale = 1}, Card)
draggable(Card, Card)

local cardClose = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 10), Text = "✕", Font = Enum.Font.GothamBold,
	TextSize = 12, BackgroundColor3 = rgb(231, 76, 60), TextColor3 = rgb(255, 255, 255), ZIndex = 2605,
}, Card)
corner(cardClose, 8)
local cardAvatar = new("ImageLabel", {
	Size = UDim2.fromOffset(88, 88), Position = UDim2.fromOffset(16, 16), BackgroundTransparency = 0.3, ZIndex = 2601,
}, Card)
bind(cardAvatar, "BackgroundColor3", "btn"); corner(cardAvatar, 14)
local cardName = new("TextLabel", {
	Size = UDim2.new(1, -150, 0, 22), Position = UDim2.fromOffset(116, 16), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2601,
}, Card); bind(cardName, "TextColor3", "accent")
local cardUser = new("TextLabel", {
	Size = UDim2.new(1, -150, 0, 16), Position = UDim2.fromOffset(116, 38), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2601,
}, Card); bind(cardUser, "TextColor3", "sub")
local cardMeta = new("TextLabel", {
	Size = UDim2.new(1, -132, 0, 52), Position = UDim2.fromOffset(116, 56), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 2601,
}, Card); bind(cardMeta, "TextColor3", "text")
local statsHeader = new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 20), Position = UDim2.fromOffset(16, 118), BackgroundTransparency = 1,
	Text = "💰 ВАЛЮТА И СТАТИСТИКА", Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2601,
}, Card); bind(statsHeader, "TextColor3", "sub")
local cardStats = new("ScrollingFrame", {
	Size = UDim2.new(1, -28, 0, 176), Position = UDim2.fromOffset(14, 142), BackgroundTransparency = 0.6, BorderSizePixel = 0,
	ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 2601,
}, Card)
bind(cardStats, "BackgroundColor3", "btn"); corner(cardStats, 10)
new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, cardStats)
new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6)}, cardStats)

local cardPlayer, cardSig = nil, ""
local function statRow(parent, order, a, b, header)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, header and 20 or 24), BackgroundTransparency = 1, LayoutOrder = order, ZIndex = 2602}, parent)
	local l = new("TextLabel", {
		Size = header and UDim2.fromScale(1, 1) or UDim2.new(0.55, 0, 1, 0), BackgroundTransparency = 1, Text = a,
		Font = header and Enum.Font.GothamBold or Enum.Font.GothamSemibold, TextSize = header and 10 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2603,
	}, row)
	bind(l, "TextColor3", header and "sub" or "text")
	if b then
		local v = new("TextLabel", {
			Size = UDim2.new(0.45, 0, 1, 0), Position = UDim2.fromScale(0.55, 0), BackgroundTransparency = 1, Text = b,
			Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2603,
		}, row)
		bind(v, "TextColor3", "accent")
	end
end

local function renderCard(force)
	local plr = cardPlayer
	if not plr or not plr.Parent then
		if Card.Visible then Card.Visible = false; notify("ИГРОК", "Игрок вышел из игры") end
		cardPlayer = nil
		return
	end
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	local hp = hum and (math.floor(hum.Health + 0.5) .. " / " .. math.floor(hum.MaxHealth + 0.5)) or "—"
	cardMeta.Text = string.format(
		"Аккаунту: %d дн.\nКоманда: %s\nHP: %s%s",
		plr.AccountAge, plr.Team and plr.Team.Name or "—", hp,
		plr.MembershipType == Enum.MembershipType.Premium and "\n⭐ Premium" or ""
	)
	local stats, attrs = V.collectStats(plr), V.collectAttrs(plr)
	local sig = ""
	for _, s in ipairs(stats) do sig ..= s[1] .. "=" .. s[2] .. ";" end
	sig ..= "|"
	for _, s in ipairs(attrs) do sig ..= s[1] .. "=" .. s[2] .. ";" end
	if sig == cardSig and not force then return end
	cardSig = sig
	for _, c in ipairs(cardStats:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local order = 0
	if #stats > 0 then
		for _, s in ipairs(stats) do order += 1; statRow(cardStats, order, s[1], s[2], false) end
	else
		order += 1; statRow(cardStats, order, "Игра не показывает валюту этого игрока", nil, true)
	end
	if #attrs > 0 then
		order += 1; statRow(cardStats, order, "ДОПОЛНИТЕЛЬНО", nil, true)
		for _, s in ipairs(attrs) do order += 1; statRow(cardStats, order, s[1], s[2], false) end
	end
end

function V.openPlayerCard(plr)
	if not plr then return end
	cardPlayer = plr
	cardAvatar.Image = "rbxthumb://type=AvatarBust&id=" .. plr.UserId .. "&w=150&h=150"
	cardName.Text = plr.DisplayName .. (plr == player and "  (вы)" or "")
	cardUser.Text = "@" .. plr.Name
	Card.Visible = true
	cardScale.Scale = 0.85
	tw(cardScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
	renderCard(true)
end
cardClose.Activated:Connect(function()
	tw(cardScale, 0.15, {Scale = 0.85})
	task.delay(0.15, function() Card.Visible = false; cardPlayer = nil end)
end)

local function cardButton(text, y, color, cb)
	local b = new("TextButton", {
		Size = UDim2.new(1, -28, 0, 34), Position = UDim2.fromOffset(14, y), BackgroundTransparency = 0.15, Text = text,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = rgb(255, 255, 255), BackgroundColor3 = color, ZIndex = 2602,
	}, Card)
	corner(b, 10); hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
end
cardButton("➕ Добавить в друзья Roblox", 330, rgb(52, 120, 200), function()
	if not cardPlayer or cardPlayer == player then notify("ИГРОК", "Это вы"); return end
	StarterGui:SetCore("PromptSendFriendRequest", cardPlayer)
end)
cardButton("👥 Привязать в мой список друзей", 372, rgb(70, 130, 80), function()
	local plr = cardPlayer
	if not plr or plr == player then notify("ИГРОК", "Это вы"); return end
	for _, f in ipairs(V.friendsList) do
		if f.userId == plr.UserId then notify("ДРУЗЬЯ", "Уже в списке"); return end
	end
	local okF, isF = pcall(player.IsFriendsWith, player, plr.UserId)
	V.isRobloxFriend[plr.UserId] = okF and isF or false
	table.insert(V.friendsList, {name = plr.Name, userId = plr.UserId})
	V.rebuildFriends()
	notify("👥 ДРУЗЬЯ", plr.Name .. " привязан")
end)
cardButton("🚫 Заблокировать игрока", 414, rgb(190, 70, 60), function()
	if not cardPlayer or cardPlayer == player then notify("ИГРОК", "Это вы"); return end
	StarterGui:SetCore("PromptBlockPlayer", cardPlayer)
end)

task.spawn(function()
	while gui.Parent do
		if Card.Visible then pcall(renderCard, false) end
		task.wait(0.5)
	end
end)

-- клик по игроку в мире открывает карточку (по желанию)
V.clickCard = false
UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not V.clickCard then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local t = mouse.Target
		local model = t and t:FindFirstAncestorOfClass("Model")
		local plr = model and Players:GetPlayerFromCharacter(model)
		if plr then V.openPlayerCard(plr) end
	end
end)
addToggle(V.pFx, "🧾 Клик по игроку в мире открывает его карточку", false, function(v) V.clickCard = v end)

end
do
-- ---------- меню паузы: копия меню Roblox ----------
local PauseOverlay = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1,
	Visible = false, ZIndex = 1600, Active = true,
}, gui)
local PausePanel = new("Frame", {
	Size = UDim2.fromOffset(800, 520), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 0.06, ZIndex = 1601,
}, PauseOverlay)
bind(PausePanel, "BackgroundColor3", "bg"); corner(PausePanel, 18)
local pauseStroke = new("UIStroke", {Thickness = 1.6}, PausePanel); bind(pauseStroke, "Color", "accent")
local pauseScale = new("UIScale", {Scale = 1}, PausePanel)

local pauseTitle = new("TextLabel", {
	Size = UDim2.new(0.6, 0, 0, 40), Position = UDim2.fromOffset(20, 10), BackgroundTransparency = 1,
	Text = "⏸  ПАУЗА  ·  ROBLOX VISUALS", Font = Enum.Font.GothamBlack, TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1602,
}, PausePanel); bind(pauseTitle, "TextColor3", "accent")
local pauseCount = new("TextLabel", {
	Size = UDim2.new(0.4, -20, 0, 40), Position = UDim2.new(0.6, 0, 0, 10), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 1602,
}, PausePanel); bind(pauseCount, "TextColor3", "sub")

local PauseContent = new("Frame", {
	Size = UDim2.new(1, -32, 1, -190), Position = UDim2.fromOffset(16, 56), BackgroundTransparency = 1, ZIndex = 1602,
}, PausePanel)
local BarA = new("Frame", {
	Size = UDim2.new(1, -32, 0, 44), Position = UDim2.new(0, 16, 1, -122), BackgroundTransparency = 0.35, ZIndex = 1602,
}, PausePanel)
bind(BarA, "BackgroundColor3", "btn"); corner(BarA, 14)
local BarB = new("Frame", {
	Size = UDim2.new(1, -32, 0, 50), Position = UDim2.new(0, 16, 1, -68), BackgroundTransparency = 1, ZIndex = 1602,
}, PausePanel)

local pausePages, pauseTabs, curPauseTab = {}, {}, 1
local function pausePage()
	local pg = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ScrollBarThickness = 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 1603,
	}, PauseContent)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
	new("UIPadding", {PaddingRight = UDim.new(0, 6)}, pg)
	table.insert(pausePages, pg)
	return pg
end
local pgPlayers, pgSettings, pgHelp = pausePage(), pausePage(), pausePage()

local function selectPauseTab(i)
	curPauseTab = i
	for j, pg in ipairs(pausePages) do pg.Visible = (j == i) end
	for j, tb in ipairs(pauseTabs) do
		tw(tb, 0.2, {BackgroundColor3 = j == i and Theme.accent or Theme.header, TextColor3 = j == i and rgb(255, 255, 255) or Theme.text})
	end
end
table.insert(onThemeChanged, function() selectPauseTab(curPauseTab) end)

local TabsHolder = new("Frame", {Size = UDim2.new(0.55, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 1603}, BarA)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center,
}, TabsHolder)
new("UIPadding", {PaddingLeft = UDim.new(0, 8)}, TabsHolder)
local function pauseTab(text, i)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(110, 32), Text = text, Font = Enum.Font.GothamBold, TextSize = 12, BackgroundColor3 = Theme.header, ZIndex = 1604,
	}, TabsHolder)
	b.TextColor3 = Theme.text
	corner(b, 10); hoverFx(b, b)
	b.Activated:Connect(function() selectPauseTab(i) end)
	table.insert(pauseTabs, b)
end
pauseTab("👥 Игроки", 1); pauseTab("⚙️ Настройки", 2); pauseTab("❓ Помощь", 3)

-- цветные кружки тем внизу
local SwatchHolder = new("Frame", {
	Size = UDim2.new(0.45, -8, 1, 0), Position = UDim2.new(0.55, 0, 0, 0), BackgroundTransparency = 1, ZIndex = 1603,
}, BarA)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
	HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center,
}, SwatchHolder)
for _, t in ipairs(Themes) do
	local sw = new("TextButton", {Size = UDim2.fromOffset(24, 24), Text = "", BackgroundColor3 = t.accent, ZIndex = 1604}, SwatchHolder)
	corner(sw, 12)
	new("UIStroke", {Color = rgb(255, 255, 255), Thickness = 1.5, Transparency = 0.5}, sw)
	hoverFx(sw, sw)
	sw.Activated:Connect(function() applyTheme(t); notify("🎨 ТЕМА", t.name) end)
end

-- нижние кнопки действий
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, BarB)
local pauseOpen = false
local closePause
local function actionBtn(text, color, cb)
	local b = new("TextButton", {
		Size = UDim2.new(0.25, -6, 1, 0), Text = text, Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = rgb(255, 255, 255), BackgroundColor3 = color, BackgroundTransparency = 0.1, ZIndex = 1604,
	}, BarB)
	corner(b, 12); hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
end
actionBtn("💀 Сбросить персонажа", rgb(120, 90, 50), function()
	V.dialog("💀 СБРОСИТЬ ПЕРСОНАЖА?", "Персонаж будет возрождён.", "Сбросить", "Отмена", function()
		V.respawn(); closePause()
	end)
end)
actionBtn("🔄 Перезайти", rgb(52, 120, 200), V.rejoin)
actionBtn("🚪 Выйти из игры", rgb(190, 70, 60), V.exitGame)
actionBtn("▶ Продолжить", rgb(70, 130, 80), function() closePause() end)

-- вкладка «Игроки»
addLabel(pgPlayers, "Нажмите на игрока — откроется карточка с валютой и статистикой")
local statLabels = {}
local function refreshPlayersTab()
	for _, c in ipairs(pgPlayers:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	table.clear(statLabels)
	for i, p in ipairs(Players:GetPlayers()) do
		local row = new("TextButton", {
			Size = UDim2.new(1, -8, 0, 56), BackgroundTransparency = 0.35, Text = "", AutoButtonColor = false,
			LayoutOrder = i, ZIndex = 1604,
		}, pgPlayers)
		bind(row, "BackgroundColor3", "btn"); corner(row, 12); hoverFx(row, row)
		local av = new("ImageLabel", {
			Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=100&h=100", ZIndex = 1605,
		}, row)
		corner(av, 20)
		local nm = new("TextLabel", {
			Size = UDim2.new(0.42, -60, 0, 20), Position = UDim2.fromOffset(58, 8), BackgroundTransparency = 1,
			Text = p.DisplayName .. (p == player and " (вы)" or ""), Font = Enum.Font.GothamBold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1605,
		}, row)
		bind(nm, "TextColor3", "text")
		local un = new("TextLabel", {
			Size = UDim2.new(0.42, -60, 0, 16), Position = UDim2.fromOffset(58, 30), BackgroundTransparency = 1,
			Text = "@" .. p.Name, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1605,
		}, row)
		bind(un, "TextColor3", "sub")
		local st = new("TextLabel", {
			Size = UDim2.new(0.58, -30, 1, 0), Position = UDim2.new(0.42, 0, 0, 0), BackgroundTransparency = 1,
			Text = V.statsSummary(p), Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1605,
		}, row)
		bind(st, "TextColor3", "accent")
		new("TextLabel", {
			Size = UDim2.fromOffset(16, 56), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "›",
			Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = rgb(150, 150, 160), ZIndex = 1605,
		}, row)
		statLabels[p] = st
		row.Activated:Connect(function() V.openPlayerCard(p) end)
	end
	pauseCount.Text = "Игроков: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
end
Players.PlayerAdded:Connect(function() if pauseOpen then task.wait(0.3); refreshPlayersTab() end end)
Players.PlayerRemoving:Connect(function() if pauseOpen then task.defer(refreshPlayersTab) end end)
task.spawn(function()
	while gui.Parent do
		if pauseOpen then
			for p, l in pairs(statLabels) do
				if p.Parent and l.Parent then l.Text = V.statsSummary(p) end
			end
		end
		task.wait(1)
	end
end)

-- вкладка «Настройки»
local ugs
pcall(function() ugs = UserSettings():GetService("UserGameSettings") end)
local function ugsGet(prop, default)
	local ok, v = pcall(function() return ugs[prop] end)
	if ok and v ~= nil then return v end
	return default
end
local function ugsSet(prop, val)
	local ok = pcall(function() ugs[prop] = val end)
	if not ok then notify("НАСТРОЙКИ", "Эту настройку нельзя изменить из скрипта") end
end
addLabel(pgSettings, "НАСТРОЙКИ ROBLOX")
addSlider(pgSettings, "Общая громкость", 0, 1, ugsGet("MasterVolume", 1), 2, function(v) ugsSet("MasterVolume", v) end)
addSlider(pgSettings, "Чувствительность мыши", 0.1, 4, ugsGet("MouseSensitivity", 1), 2, function(v) ugsSet("MouseSensitivity", v) end)
addToggle(pgSettings, "↕️ Инверсия камеры по вертикали", ugsGet("CameraYInverted", false), function(v) ugsSet("CameraYInverted", v) end)
addLabel(pgSettings, "МУЗЫКА")
addButton(pgSettings, "⏮ Предыдущий трек", V.prevTrack)
addButton(pgSettings, "⏯ Играть / пауза", V.toggleMusic)
addButton(pgSettings, "⏭ Следующий трек", V.nextTrack)
addLabel(pgSettings, "МОДЫ")
addButton(pgSettings, "🪐 Открыть полное меню ROBLOX VISUALS", function() closePause(); setMenu(true) end)
addToggle(pgSettings, "🧾 Клик по игроку в мире открывает карточку", false, function(v) V.clickCard = v end)

-- вкладка «Помощь»
local helpText = new("TextLabel", {
	Size = UDim2.new(1, -8, 0, 260), BackgroundTransparency = 1, TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 1604,
	Text = "ГОРЯЧИЕ КЛАВИШИ\n\n"
		.. "P — меню паузы (это окно)\n"
		.. "RightShift — меню модов\n"
		.. "H — вернуть интерфейс после фото-режима\n"
		.. "1–9 — взять предмет (если включён свой инвентарь)\n\n"
		.. "КАРТОЧКА ИГРОКА\n\n"
		.. "Во вкладке «Игроки» нажмите на игрока: увидите его валюту и статистику "
		.. "(то, что игра показывает в leaderstats), команду, HP и возраст аккаунта.\n\n"
		.. "Внизу — кружки тем: нажмите, чтобы мгновенно сменить цвет интерфейса.",
}, pgHelp)
bind(helpText, "TextColor3", "text")

-- открыть / закрыть
local pauseBase = 1
local function updatePauseScale()
	local vp = camera.ViewportSize
	pauseBase = math.clamp(math.min(vp.X / 860, vp.Y / 580), 0.45, 1)
end
local function openPause()
	pauseOpen = true
	updatePauseScale()
	refreshPlayersTab()
	selectPauseTab(curPauseTab)
	PauseOverlay.Visible = true
	PauseOverlay.BackgroundTransparency = 1
	tw(PauseOverlay, 0.3, {BackgroundTransparency = 0.45})
	tw(V.menuBlur, 0.3, {Size = 14})
	pauseScale.Scale = pauseBase * 0.88
	tw(pauseScale, 0.35, {Scale = pauseBase}, Enum.EasingStyle.Back)
end
closePause = function()
	pauseOpen = false
	V.startOpen = false
	tw(PauseOverlay, 0.25, {BackgroundTransparency = 1})
	tw(V.menuBlur, 0.25, {Size = 0})
	tw(pauseScale, 0.2, {Scale = pauseBase * 0.92})
	task.delay(0.26, function() if not pauseOpen then PauseOverlay.Visible = false end end)
end
V.pauseHooks.open = openPause
V.pauseHooks.close = closePause
V.pauseHooks.isOpen = function() return pauseOpen end
selectPauseTab(1)

end
do
-- =============================================================================
-- v5: Центральные сообщения, плашка HUD, карточка музыки, Cooldowns, Hot Keys
end
do
-- =============================================================================
V.pPanels = createTab("🧩 Панели")
local MarketplaceService = game:GetService("MarketplaceService")
local hudHidden = false
NS.hudHiddenFn = function() return hudHidden end

-- >> центральное сообщение с размытием фона
local cmBlur = Instance.new("BlurEffect")
cmBlur.Name = "VisualsLegalCenterBlur"; cmBlur.Size = 0; cmBlur.Parent = Lighting
local cmQueue, cmBusy = {}, false
local showNextCenter
showNextCenter = function()
	if cmBusy then return end
	local item = table.remove(cmQueue, 1)
	if not item then return end
	cmBusy = true
	local overlay = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, ZIndex = 3500,
	}, gui)
	local box = new("Frame", {
		Size = UDim2.fromOffset(440, 10), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.04, Active = true, ZIndex = 3501,
	}, overlay)
	bind(box, "BackgroundColor3", "bg"); corner(box, 18)
	local st = new("UIStroke", {Thickness = 1.6}, box); bind(st, "Color", "accent")
	new("UIPadding", {
		PaddingTop = UDim.new(0, 22), PaddingBottom = UDim.new(0, 22),
		PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24),
	}, box)
	new("UIListLayout", {
		Padding = UDim.new(0, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	}, box)
	local t = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = tostring(item.title), Font = Enum.Font.GothamBlack, TextSize = 20, TextWrapped = true, LayoutOrder = 1, ZIndex = 3502,
	}, box); bind(t, "TextColor3", "accent")
	local d = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = tostring(item.text), Font = Enum.Font.Gotham, TextSize = 14, TextWrapped = true, LayoutOrder = 2, ZIndex = 3502,
	}, box); bind(d, "TextColor3", "text")
	local b = new("TextButton", {
		Size = UDim2.fromOffset(160, 38), Text = item.btn or "OK", Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = rgb(10, 22, 14), LayoutOrder = 3, ZIndex = 3502,
	}, box)
	bind(b, "BackgroundColor3", "accent"); corner(b, 12); hoverFx(b, b)
	local sc = new("UIScale", {Scale = 0.85}, box)
	tw(overlay, 0.25, {BackgroundTransparency = 0.55}); tw(cmBlur, 0.25, {Size = 20})
	tw(sc, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
	local closed = false
	local function close()
		if closed then return end
		closed = true
		tw(overlay, 0.2, {BackgroundTransparency = 1}); tw(cmBlur, 0.2, {Size = 0}); tw(sc, 0.2, {Scale = 0.9})
		task.delay(0.22, function()
			overlay:Destroy(); cmBusy = false; showNextCenter()
		end)
	end
	b.Activated:Connect(close); overlay.Activated:Connect(close)
	task.delay(item.auto or 12, close)
end
local function centerMessage(title, text, btn, auto)
	table.insert(cmQueue, {title = title, text = text, btn = btn, auto = auto})
	showNextCenter()
end
NS.centerMessage = centerMessage

-- >> плашка HUD: логотип + FPS + пинг
local Pill = new("Frame", {
	Size = UDim2.fromOffset(10, 38), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromOffset(70, 19),
	BackgroundTransparency = 0.1, ZIndex = 150,
}, gui)
bind(Pill, "BackgroundColor3", "bg"); corner(Pill, 19)
local pillStroke = new("UIStroke", {Thickness = 1, Transparency = 0.55}, Pill); bind(pillStroke, "Color", "accent")
new("UIPadding", {PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 14)}, Pill)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
	VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
}, Pill)
local logo = new("TextLabel", {
	Size = UDim2.fromOffset(26, 26), Text = "RV", Font = Enum.Font.GothamBlack, TextSize = 12,
	TextColor3 = rgb(8, 20, 12), LayoutOrder = 1, ZIndex = 151,
}, Pill)
bind(logo, "BackgroundColor3", "accent"); corner(logo, 8)
local function pillText(order, txt, themeKey, font)
	local l = new("TextLabel", {
		Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = txt,
		Font = font or Enum.Font.GothamSemibold, TextSize = 12, LayoutOrder = order, ZIndex = 151,
	}, Pill)
	bind(l, "TextColor3", themeKey)
	return l
end
pillText(2, "Roblox Visuals", "text", Enum.Font.GothamBold)
pillText(3, "•", "sub")
local pillFps = pillText(4, "-- FPS", "text")
pillText(5, "•", "sub")
local pillPing = pillText(6, "-- ms", "text")

-- >> карточка музыки
local trackMeta = {}
local function fetchMeta(id)
	if trackMeta[id] ~= nil then return trackMeta[id] end
	trackMeta[id] = false
	task.spawn(function()
		local ok, info = pcall(function() return MarketplaceService:GetProductInfo(tonumber(id), Enum.InfoType.Asset) end)
		if ok and type(info) == "table" then
			trackMeta[id] = {name = info.Name or "—", artist = info.Creator and info.Creator.Name or "—"}
		end
	end)
	return false
end

local MCard = new("Frame", {
	Size = UDim2.fromOffset(310, 122), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 66),
	BackgroundTransparency = 0.08, Visible = false, ZIndex = 150,
}, gui)
bind(MCard, "BackgroundColor3", "bg"); corner(MCard, 16)
local mcStroke = new("UIStroke", {Thickness = 1, Transparency = 0.55}, MCard); bind(mcStroke, "Color", "accent")
draggable(MCard, MCard)
local cover = new("Frame", {Size = UDim2.fromOffset(54, 54), Position = UDim2.fromOffset(12, 12), ZIndex = 151}, MCard)
bind(cover, "BackgroundColor3", "accent"); corner(cover, 12)
new("UIGradient", {Rotation = 45, Transparency = NumberSequence.new(0, 0.55)}, cover)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "♪", Font = Enum.Font.GothamBlack, TextSize = 26,
	TextColor3 = rgb(10, 24, 16), ZIndex = 152,
}, cover)
local mcTitle = new("TextLabel", {
	Size = UDim2.new(1, -120, 0, 22), Position = UDim2.fromOffset(78, 14), BackgroundTransparency = 1, Text = "—",
	Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 151,
}, MCard); bind(mcTitle, "TextColor3", "text")
local mcArtist = new("TextLabel", {
	Size = UDim2.new(1, -120, 0, 18), Position = UDim2.fromOffset(78, 38), BackgroundTransparency = 1, Text = "—",
	Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 151,
}, MCard); bind(mcArtist, "TextColor3", "sub")
local mcNote = new("TextLabel", {
	Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -36, 0, 14), BackgroundTransparency = 1, Text = "♫",
	Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 151,
}, MCard); bind(mcNote, "TextColor3", "accent")
local mcLeft = new("TextLabel", {
	Size = UDim2.fromOffset(40, 14), Position = UDim2.fromOffset(12, 74), BackgroundTransparency = 1, Text = "0:00",
	Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 151,
}, MCard); bind(mcLeft, "TextColor3", "sub")
local mcRight = new("TextLabel", {
	Size = UDim2.fromOffset(44, 14), Position = UDim2.new(1, -56, 0, 74), BackgroundTransparency = 1, Text = "-0:00",
	Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 151,
}, MCard); bind(mcRight, "TextColor3", "sub")
local mcBar = new("Frame", {
	Size = UDim2.new(1, -112, 0, 5), Position = UDim2.fromOffset(56, 79), BorderSizePixel = 0, ZIndex = 151,
}, MCard)
bind(mcBar, "BackgroundColor3", "btn"); corner(mcBar, 3)
local mcFill = new("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 152}, mcBar)
bind(mcFill, "BackgroundColor3", "accent"); corner(mcFill, 3)
local mcSeek = new("TextButton", {
	Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, -6), BackgroundTransparency = 1, Text = "", ZIndex = 153,
}, mcBar)
mcSeek.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		local a = math.clamp((i.Position.X - mcBar.AbsolutePosition.X) / math.max(mcBar.AbsoluteSize.X, 1), 0, 1)
		if V.Music.TimeLength > 0 then V.Music.TimePosition = a * V.Music.TimeLength end
	end
end)
local mcRow = new("Frame", {
	Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 88), BackgroundTransparency = 1, ZIndex = 151,
}, MCard)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12),
	HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
}, mcRow)
local function mcBtn(txt, cb)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(40, 26), BackgroundTransparency = 1, Text = txt, Font = Enum.Font.GothamBlack, TextSize = 16, ZIndex = 152,
	}, mcRow)
	bind(b, "TextColor3", "text"); hoverFx(b, b)
	b.Activated:Connect(function() pcall(cb) end)
	return b
end
mcBtn("⏮", function() V.prevTrack() end)
local mcPlay = mcBtn("⏯", function() V.toggleMusic() end)
mcBtn("⏭", function() V.nextTrack() end)
mcBtn("↗", function() setMenu(true); V.gotoTab(V.pMusic) end)

-- >> Cooldowns
local cooldowns = {}
local combatEntry = {name = "Combat", secs = 15, endsAt = 0, builtin = true}
local combatOn = false
local cdPanel = new("Frame", {
	Size = UDim2.fromOffset(230, 10), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -16, 0.5, 0), BackgroundTransparency = 0.08, Visible = false, ZIndex = 150,
}, gui)
bind(cdPanel, "BackgroundColor3", "bg"); corner(cdPanel, 14)
local cdStroke = new("UIStroke", {Thickness = 1, Transparency = 0.55}, cdPanel); bind(cdStroke, "Color", "accent")
new("UIPadding", {
	PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
}, cdPanel)
new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, cdPanel)
draggable(cdPanel, cdPanel)
local cdHead = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "⏱  Cooldowns", Font = Enum.Font.GothamBold, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, ZIndex = 151,
}, cdPanel); bind(cdHead, "TextColor3", "accent")
local cdLabels = {}
local cdListUi
local rebuildCdList
local function cdEntries()
	local list = {}
	for _, e in ipairs(cooldowns) do table.insert(list, e) end
	if combatOn then table.insert(list, combatEntry) end
	return list
end
local function rebuildCdPanel()
	for _, c in ipairs(cdPanel:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	table.clear(cdLabels)
	for i, e in ipairs(cdEntries()) do
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = i, ZIndex = 151}, cdPanel)
		local nm = new("TextLabel", {
			Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Text = e.name, Font = Enum.Font.GothamSemibold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 152,
		}, row); bind(nm, "TextColor3", "text")
		local tm = new("TextLabel", {
			Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.fromScale(0.6, 0), BackgroundTransparency = 1, Text = "готово",
			Font = Enum.Font.Code, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 152,
		}, row); bind(tm, "TextColor3", "sub")
		cdLabels[e] = tm
	end
end
local function startCooldown(e)
	e.endsAt = os.clock() + e.secs
	e.notified = false
end
local function parseKey(name)
	if not name or name == "" then return nil end
	local ok, kc = pcall(function() return Enum.KeyCode[name:upper():gsub("%s", "")] end)
	if ok and kc then return kc end
	return nil
end
local function addCooldown(name, secs, keyName, toolName)
	if #cooldowns >= 12 then notify("COOLDOWNS", "Максимум 12 таймеров"); return end
	local e = {
		name = tostring(name):sub(1, 24), secs = math.clamp(tonumber(secs) or 10, 1, 3600),
		key = keyName or "", tool = toolName or "", endsAt = 0,
	}
	e.keyCode = parseKey(e.key)
	table.insert(cooldowns, e)
	rebuildCdPanel()
	if rebuildCdList then rebuildCdList() end
end
local function clearCooldowns()
	table.clear(cooldowns)
	rebuildCdPanel()
	if rebuildCdList then rebuildCdList() end
end
NS.addCooldown = addCooldown
NS.clearCooldowns = clearCooldowns
NS.cooldowns = cooldowns

-- запуск таймеров по клавише
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	for _, e in ipairs(cooldowns) do
		if e.keyCode and input.KeyCode == e.keyCode and os.clock() >= e.endsAt then startCooldown(e) end
	end
end)
-- запуск таймеров по предмету (Tool)
local hookedTools = setmetatable({}, {__mode = "k"})
local function hookTool(tool)
	if hookedTools[tool] then return end
	hookedTools[tool] = true
	tool.Activated:Connect(function()
		for _, e in ipairs(cooldowns) do
			if e.tool ~= "" and e.tool:lower() == tool.Name:lower() and os.clock() >= e.endsAt then startCooldown(e) end
		end
	end)
end
task.spawn(function()
	while gui.Parent do
		local bp = player:FindFirstChildOfClass("Backpack")
		if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then hookTool(t) end end end
		if player.Character then
			for _, t in ipairs(player.Character:GetChildren()) do if t:IsA("Tool") then hookTool(t) end end
		end
		task.wait(1)
	end
end)
-- таймер боя: запускается, когда вы получаете урон
local function hookCombat(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	local last = hum.Health
	hum.HealthChanged:Connect(function(h)
		if h < last - 0.5 and combatOn then startCooldown(combatEntry) end
		last = h
	end)
end
if player.Character then task.spawn(hookCombat, player.Character) end
player.CharacterAdded:Connect(hookCombat)

-- >> Hot Keys
V.HotkeyDefs = {
	{"menu", "Меню Roblox Visuals"}, {"pause", "Меню паузы"}, {"music", "Карточка музыки"},
	{"hud", "Скрыть / показать панели"}, {"bright", "Яркое освещение"}, {"marker", "Метка по курсору"},
	{"photo", "Вернуть интерфейс (фото-режим)"},
}
local hkPanel = new("Frame", {
	Size = UDim2.fromOffset(250, 10), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 16, 1, -16), BackgroundTransparency = 0.08, Visible = false, ZIndex = 150,
}, gui)
bind(hkPanel, "BackgroundColor3", "bg"); corner(hkPanel, 14)
local hkStroke = new("UIStroke", {Thickness = 1, Transparency = 0.55}, hkPanel); bind(hkStroke, "Color", "accent")
new("UIPadding", {
	PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
}, hkPanel)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, hkPanel)
draggable(hkPanel, hkPanel)
local hkHead = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "⌨  Hot Keys", Font = Enum.Font.GothamBold, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, ZIndex = 151,
}, hkPanel); bind(hkHead, "TextColor3", "accent")
V.rebinding = nil
local chips = {}
local function keyLabel(id)
	if V.rebinding == id then return "…" end
	local kc = Keybinds[id]
	return kc and kc.Name or "—"
end
local function refreshChips()
	for id, list in pairs(chips) do
		for _, c in ipairs(list) do c.Text = keyLabel(id) end
	end
end
local function startRebind(id)
	V.rebinding = id
	refreshChips()
	notify("HOT KEYS", "Нажмите новую клавишу (Esc — отмена)")
end
local function chipRow(parent, id, label, order, zBase, compact)
	local row = new("TextButton", {
		Size = UDim2.new(1, compact and -8 or 0, 0, compact and 36 or 24), BackgroundTransparency = compact and 0.35 or 1,
		Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = zBase,
	}, parent)
	if compact then bind(row, "BackgroundColor3", "btn"); corner(row, 10); hoverFx(row, row) end
	local l = new("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(compact and 12 or 0, 0), BackgroundTransparency = 1, Text = label,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = zBase + 1,
	}, row); bind(l, "TextColor3", "text")
	local chip = new("TextLabel", {
		Size = UDim2.fromOffset(52, 22), Position = UDim2.new(1, compact and -62 or -52, 0.5, -11), Text = keyLabel(id),
		Font = Enum.Font.Code, TextSize = 12, ZIndex = zBase + 1,
	}, row)
	bind(chip, "BackgroundColor3", "header"); bind(chip, "TextColor3", "accent"); corner(chip, 7)
	chips[id] = chips[id] or {}
	table.insert(chips[id], chip)
	row.Activated:Connect(function() startRebind(id) end)
end
for i, def in ipairs(V.HotkeyDefs) do chipRow(hkPanel, def[1], def[2], i, 151, false) end
NS.refreshChips = refreshChips

UIS.InputBegan:Connect(function(input)
	if not V.rebinding or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local id = V.rebinding
	local kc = input.KeyCode
	task.defer(function()
		V.rebinding = nil
		if kc ~= Enum.KeyCode.Escape and kc ~= Enum.KeyCode.Unknown then
			Keybinds[id] = kc
			notify("HOT KEYS", id .. " → " .. kc.Name)
		end
		refreshChips()
	end)
end)

-- >> видимость панелей и горячие клавиши
local function updatePanelsVisibility()
	local hide = hudHidden
	Pill.Visible = (S.hudPill ~= false) and not hide
	MCard.Visible = (S.musicCard ~= false) and not hide and V.trackIdx > 0
	cdPanel.Visible = (S.cdPanel == true) and not hide and #cdEntries() > 0
	hkPanel.Visible = (S.hkPanel == true) and not hide
end
NS.updatePanelsVisibility = updatePanelsVisibility

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or V.rebinding then return end
	local kc = input.KeyCode
	if kc == Keybinds.music then toggleSetting("music_card")
	elseif kc == Keybinds.hud then
		hudHidden = not hudHidden
		updatePanelsVisibility()
	elseif kc == Keybinds.bright then toggleSetting("fullbright") end
end)

-- >> вкладка «Панели»
addLabel(V.pPanels, "ПАНЕЛИ НА ЭКРАНЕ (перетаскиваются мышью)")
addToggle(V.pPanels, "🟩 Плашка Roblox Visuals (FPS и пинг)", true, function(v) S.hudPill = v; updatePanelsVisibility() end, "hud_pill")
addToggle(V.pPanels, "🎵 Карточка музыки (клавиша Q)", true, function(v) S.musicCard = v; updatePanelsVisibility() end, "music_card")
addToggle(V.pPanels, "⏱ Панель Cooldowns", false, function(v) S.cdPanel = v; updatePanelsVisibility() end, "cooldown_panel")
addToggle(V.pPanels, "⌨ Панель Hot Keys", false, function(v) S.hkPanel = v; updatePanelsVisibility() end, "hotkey_panel")
addToggle(V.pPanels, "⚔️ Таймер боя (запускается при получении урона)", false, function(v)
	combatOn = v; rebuildCdPanel(); updatePanelsVisibility()
end, "combat_timer")
addSlider(V.pPanels, "Длительность таймера боя (сек)", 3, 60, 15, 0, function(v) combatEntry.secs = v end, "combat_secs")
addToggle(V.pPanels, "🔔 Уведомлять, когда таймер готов", true, function(v) S.cdNotify = v end, "cooldown_notify")

addLabel(V.pPanels, "НОВЫЙ ТАЙМЕР (Cooldown)")
local cdName = V.addInput(V.pPanels, "Название (например: Жемчуг)", "", 36, false)
local cdSecs = V.addInput(V.pPanels, "Секунд (например: 30)", "", 36, false)
local cdKey = V.addInput(V.pPanels, "Клавиша запуска, необязательно (например: V)", "", 36, false)
local cdTool = V.addInput(V.pPanels, "Предмет (Tool) для запуска, необязательно", "", 36, false)
addButton(V.pPanels, "➕ Добавить таймер", function()
	if cdName.Text:match("%S") then
		addCooldown(cdName.Text, cdSecs.Text, cdKey.Text, cdTool.Text)
		cdName.Text = ""; cdSecs.Text = ""; cdKey.Text = ""; cdTool.Text = ""
	else
		notify("COOLDOWNS", "Введите название таймера")
	end
end)
cdListUi = new("Frame", {Size = UDim2.new(1, -8, 0, 10), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 13}, V.pPanels)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, cdListUi)
rebuildCdList = function()
	for _, c in ipairs(cdListUi:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for i, e in ipairs(cooldowns) do
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 0.4, LayoutOrder = i, ZIndex = 14}, cdListUi)
		bind(row, "BackgroundColor3", "btn"); corner(row, 8)
		local info = e.name .. "  ·  " .. e.secs .. " с"
		if e.key ~= "" then info = info .. "  ·  [" .. e.key:upper() .. "]" end
		if e.tool ~= "" then info = info .. "  ·  " .. e.tool end
		local l = new("TextLabel", {
			Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = info,
			Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
		}, row); bind(l, "TextColor3", "text")
		local go = new("TextButton", {
			Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -66, 0.5, -12), Text = "▶", Font = Enum.Font.GothamBold,
			TextSize = 11, BackgroundColor3 = rgb(46, 204, 113), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
		}, row); corner(go, 6)
		go.Activated:Connect(function() startCooldown(e) end)
		local rm = new("TextButton", {
			Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -34, 0.5, -12), Text = "✕", Font = Enum.Font.GothamBold,
			TextSize = 11, BackgroundColor3 = rgb(231, 76, 60), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
		}, row); corner(rm, 6)
		rm.Activated:Connect(function()
			local idx = table.find(cooldowns, e)
			if idx then table.remove(cooldowns, idx) end
			rebuildCdPanel(); rebuildCdList(); updatePanelsVisibility()
		end)
	end
	updatePanelsVisibility()
end

addLabel(V.pPanels, "ГОРЯЧИЕ КЛАВИШИ (нажмите на строку и затем на новую клавишу)")
for i, def in ipairs(V.HotkeyDefs) do chipRow(V.pPanels, def[1], def[2], 100 + i, 14, true) end

-- >> вид переключателей в темах
addLabel(pTheme, "ВИД ПЕРЕКЛЮЧАТЕЛЕЙ (красный = выкл, зелёный = вкл)")
for _, st in ipairs({{"pill", "💊 Таблетка с шариком"}, {"square", "⬛ Квадрат с галочкой"}, {"dot", "🔴 Точка"}}) do
	addButton(pTheme, st[2], function()
		setToggleStyle(st[1])
		notify("🎨 ПЕРЕКЛЮЧАТЕЛИ", st[2])
	end)
end

-- >> обновление панелей
local pillAcc, pillN, pillT = 0, 0, 0
RunService.Heartbeat:Connect(function(dt)
	pillAcc += dt; pillN += 1; pillT += dt
	if pillT >= 0.5 then
		local fps = math.floor(pillN / math.max(pillAcc, 0.001) + 0.5)
		local ping = 0
		pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
		pillFps.Text = fps .. " FPS"
		pillPing.Text = ping .. " ms"
		pillAcc, pillN, pillT = 0, 0, 0
	end
end)

task.spawn(function()
	local function fmt(s) s = math.max(0, math.floor(s)); return string.format("%d:%02d", s // 60, s % 60) end
	while gui.Parent do
		local meta
		local t = V.playlist[V.trackIdx]
		if t then meta = fetchMeta(t.id) end
		mcTitle.Text = t and t.name or "—"
		mcArtist.Text = (meta and meta.artist) or "Roblox аудио"
		mcPlay.Text = V.Music.IsPlaying and "⏸" or "▶"
		if V.Music.TimeLength > 0 then
			mcFill.Size = UDim2.fromScale(math.clamp(V.Music.TimePosition / V.Music.TimeLength, 0, 1), 1)
			mcLeft.Text = fmt(V.Music.TimePosition)
			mcRight.Text = "-" .. fmt(V.Music.TimeLength - V.Music.TimePosition)
		else
			mcFill.Size = UDim2.fromScale(0, 1); mcLeft.Text = "0:00"; mcRight.Text = "-0:00"
		end
		updatePanelsVisibility()
		task.wait(0.25)
	end
end)

task.spawn(function()
	while gui.Parent do
		local now = os.clock()
		for e, lbl in pairs(cdLabels) do
			local left = e.endsAt - now
			if left > 0 then
				lbl.Text = string.format("%d:%02d", math.floor(left) // 60, math.floor(left) % 60)
				lbl.TextColor3 = Theme.accent
			else
				lbl.Text = "готово"
				lbl.TextColor3 = Theme.sub
				if e.endsAt > 0 and not e.notified then
					e.notified = true
					if S.cdNotify then notify("⏱ ГОТОВО", e.name) end
				end
			end
		end
		task.wait(0.1)
	end
end)
rebuildCdPanel()
updatePanelsVisibility()


end
do
-- =============================================================================
-- v5: 3D-метки на карте (базы, фармилки, важные точки)
end
do
-- =============================================================================
local pMarks = createTab("📍 Метки")
local markerIcons = {"📍", "🏠", "🌾", "⚔️", "💎", "⭐", "🚩", "🔥"}
local markerColors = {
	rgb(52, 211, 120), rgb(255, 170, 60), rgb(90, 170, 255), rgb(255, 90, 100), rgb(190, 120, 255), rgb(255, 230, 90),
}
local Markers, markerSeq = {}, 0
local markerFolder = Instance.new("Folder")
markerFolder.Name = "VisualsMarkers"; markerFolder.Parent = workspace
local markerMaxDist, markerMeters, markersVisible, autoDeath = 5000, true, true, true
local curIcon, curColor = 1, 1
local rebuildMarkerList

local function fmtDist(studs)
	if markerMeters then return math.floor(studs * 0.28 + 0.5) .. "m" end
	return math.floor(studs + 0.5) .. " st"
end

local function removeMarker(id)
	for i, m in ipairs(Markers) do
		if m.id == id then
			m.part:Destroy(); m.bb:Destroy()
			table.remove(Markers, i)
			if rebuildMarkerList then rebuildMarkerList() end
			return
		end
	end
end

local function addMarker(name, pos, opts)
	opts = opts or {}
	if #Markers >= 60 then notify("МЕТКИ", "Слишком много меток (максимум 60)"); return nil end
	markerSeq += 1
	local iconIdx = math.clamp(opts.iconIdx or 1, 1, #markerIcons)
	local colorIdx = math.clamp(opts.colorIdx or 1, 1, #markerColors)
	local m = {
		id = markerSeq, name = tostring(name):sub(1, 40), pos = pos, iconIdx = iconIdx, colorIdx = colorIdx,
		icon = opts.icon or markerIcons[iconIdx], kind = opts.kind or "user",
		expires = opts.ttl and (os.clock() + opts.ttl) or nil,
	}
	m.part = new("Part", {
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1,
		Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(pos),
	}, markerFolder)
	m.bb = new("BillboardGui", {
		Adornee = m.part, Size = UDim2.fromOffset(170, 92), SizeOffset = Vector2.new(0, 0.5), AlwaysOnTop = true,
		MaxDistance = markerMaxDist, LightInfluence = 0, Enabled = markersVisible,
	}, markerFolder)
	local list = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}, m.bb)
	new("UIListLayout", {
		Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder,
	}, list)
	local pill = new("Frame", {Size = UDim2.fromOffset(10, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0.06, LayoutOrder = 1}, list)
	bind(pill, "BackgroundColor3", "bg"); corner(pill, 14)
	new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12)}, pill)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	}, pill)
	new("TextLabel", {
		Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = m.icon,
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = markerColors[colorIdx], LayoutOrder = 1,
	}, pill)
	local nm = new("TextLabel", {
		Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = m.name,
		Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = 2,
	}, pill); bind(nm, "TextColor3", "text")
	m.dist = new("TextLabel", {
		Size = UDim2.fromOffset(64, 20), BackgroundTransparency = 0.06, Text = "…", Font = Enum.Font.GothamBold,
		TextSize = 12, LayoutOrder = 2,
	}, list)
	bind(m.dist, "BackgroundColor3", "bg"); bind(m.dist, "TextColor3", "text"); corner(m.dist, 10)
	local dot = new("Frame", {Size = UDim2.fromOffset(10, 10), BackgroundColor3 = markerColors[colorIdx], LayoutOrder = 3}, list)
	corner(dot, 5)
	table.insert(Markers, m)
	if rebuildMarkerList then rebuildMarkerList() end
	return m.id
end
local function clearMarkers(kind)
	for i = #Markers, 1, -1 do
		if not kind or Markers[i].kind == kind then removeMarker(Markers[i].id) end
	end
end
NS.addMarker = addMarker
NS.removeMarker = removeMarker
NS.clearMarkers = clearMarkers
NS.Markers = Markers
NS.markerIcons = markerIcons

-- автометка места смерти
local deathMarkerId
local function hookDeath(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.Died:Connect(function()
		if not autoDeath then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if deathMarkerId then removeMarker(deathMarkerId) end
		deathMarkerId = addMarker("Смерть", root.Position, {icon = "☠️", colorIdx = 4, kind = "death"})
	end)
end
if player.Character then task.spawn(hookDeath, player.Character) end
player.CharacterAdded:Connect(hookDeath)

-- обновление расстояний
local markAcc = 0
RunService.Heartbeat:Connect(function(dt)
	markAcc += dt
	if markAcc < 0.1 then return end
	markAcc = 0
	local camPos = camera.CFrame.Position
	for i = #Markers, 1, -1 do
		local m = Markers[i]
		if m.expires and os.clock() > m.expires then
			removeMarker(m.id)
		else
			m.dist.Text = fmtDist((m.pos - camPos).Magnitude)
		end
	end
end)

-- >> интерфейс
addLabel(pMarks, "НАСТРОЙКИ МЕТОК")
addToggle(pMarks, "📍 Показывать метки в мире", true, function(v)
	markersVisible = v
	for _, m in ipairs(Markers) do m.bb.Enabled = v end
end, "markers_visible")
addToggle(pMarks, "☠️ Автометка места смерти", true, function(v) autoDeath = v end, "death_marker")
addToggle(pMarks, "📏 Расстояние в метрах (выкл — в studs)", true, function(v) markerMeters = v end, "units_meters")
addSlider(pMarks, "Дальность показа меток (studs)", 100, 20000, 5000, 0, function(v)
	markerMaxDist = v
	for _, m in ipairs(Markers) do m.bb.MaxDistance = v end
end, "marker_range")

addLabel(pMarks, "НОВАЯ МЕТКА (себе пометка, база, фармилка, важная точка)")
local markName = V.addInput(pMarks, "Название метки (например: База)", "", 36, false)
local iconBtn, colorBtn
iconBtn = addButton(pMarks, "Иконка: " .. markerIcons[1] .. "  (нажмите, чтобы сменить)", function()
	curIcon = curIcon % #markerIcons + 1
	iconBtn.Text = "  Иконка: " .. markerIcons[curIcon] .. "  (нажмите, чтобы сменить)"
end)
colorBtn = addButton(pMarks, "Цвет метки (нажмите, чтобы сменить)", function()
	curColor = curColor % #markerColors + 1
	colorBtn.TextColor3 = markerColors[curColor]
end)
colorBtn.TextColor3 = markerColors[1]

local function newName(raw)
	if raw and raw:match("%S") then return raw end
	return "Метка " .. (markerSeq + 1)
end
local function placeHere()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then notify("МЕТКИ", "Персонаж не найден"); return end
	addMarker(newName(markName.Text), root.Position, {iconIdx = curIcon, colorIdx = curColor})
	markName.Text = ""
end
local function placeAtCursor()
	local hit = mouse.Hit
	if not hit then notify("МЕТКИ", "Наведите курсор на поверхность"); return end
	addMarker(newName(markName.Text), hit.Position, {iconIdx = curIcon, colorIdx = curColor})
	markName.Text = ""
end
addButton(pMarks, "📍 Поставить метку здесь", placeHere)
addButton(pMarks, "🎯 Поставить метку по курсору (клавиша K)", placeAtCursor)
addButton(pMarks, "🧹 Удалить все свои метки", function() clearMarkers("user") end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or V.rebinding then return end
	if input.KeyCode == Keybinds.marker then placeAtCursor() end
end)

addLabel(pMarks, "СПИСОК МЕТОК")
local markList = new("Frame", {Size = UDim2.new(1, -8, 0, 10), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 13}, pMarks)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, markList)
rebuildMarkerList = function()
	for _, c in ipairs(markList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for i, m in ipairs(Markers) do
		local row = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 0.4, LayoutOrder = i, ZIndex = 14}, markList)
		bind(row, "BackgroundColor3", "btn"); corner(row, 8)
		local l = new("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
			Text = m.icon .. "  " .. m.name .. (m.kind ~= "user" and ("   (" .. m.kind .. ")") or ""),
			Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
		}, row); bind(l, "TextColor3", "text")
		local rm = new("TextButton", {
			Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -34, 0.5, -12), Text = "✕", Font = Enum.Font.GothamBold,
			TextSize = 11, BackgroundColor3 = rgb(231, 76, 60), TextColor3 = rgb(255, 255, 255), ZIndex = 15,
		}, row); corner(rm, 6)
		rm.Activated:Connect(function() removeMarker(m.id) end)
	end
end
rebuildMarkerList()


end
do
-- =============================================================================
-- v5: Чат: фильтр запрещённых слов и звук при упоминании ника
end
do
-- =============================================================================
local pChat = createTab("💬 Чат")
local TextChatService = game:GetService("TextChatService")
local newChat = TextChatService.ChatVersion == Enum.ChatVersion.TextChatService

local chatFilterOn, chatWarnCenter = false, true
local chatWords = {"discord.gg", "t.me/"}
local pingOn = false
local pingSound = Instance.new("Sound")
pingSound.Name = "VisualsPing"; pingSound.Volume = 0.8; pingSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
pingSound.Parent = V.SoundService

-- нижний регистр + кириллица, без знаков препинания и пробелов
local function normalizeText(s)
	local out = {}
	pcall(function()
		for _, cp in utf8.codes(s) do
			if cp >= 0x41 and cp <= 0x5A then cp += 32 end
			if cp >= 0x410 and cp <= 0x42F then cp += 32 end
			if cp == 0x451 or cp == 0x401 then cp = 0x435 end
			local keep = (cp >= 0x30 and cp <= 0x39) or (cp >= 0x61 and cp <= 0x7A) or (cp >= 0x430 and cp <= 0x44F)
			if keep then table.insert(out, utf8.char(cp)) end
		end
	end)
	return table.concat(out)
end
local function lowerText(s)
	local out = {}
	local ok = pcall(function()
		for _, cp in utf8.codes(s) do
			if cp >= 0x41 and cp <= 0x5A then cp += 32 end
			if cp >= 0x410 and cp <= 0x42F then cp += 32 end
			if cp == 0x401 then cp = 0x451 end
			table.insert(out, utf8.char(cp))
		end
	end)
	return ok and table.concat(out) or s:lower()
end
local function checkMessage(text)
	local norm = normalizeText(text)
	for _, w in ipairs(chatWords) do
		local nw = normalizeText(w)
		if #nw >= 3 and norm:find(nw, 1, true) then return w end
	end
	return nil
end
local function setChatWords(list)
	table.clear(chatWords)
	for _, w in ipairs(list) do
		w = tostring(w):match("^%s*(.-)%s*$")
		if #w >= 3 and #w <= 40 and #chatWords < 100 then table.insert(chatWords, w) end
	end
end
NS.chatWords = chatWords
NS.setChatWords = setChatWords

-- своё поле ввода чата (проверка до отправки)
local ChatBar = new("Frame", {
	Size = UDim2.fromOffset(400, 40), Position = UDim2.new(0, 16, 0, 270), BackgroundTransparency = 0.05,
	Visible = false, ZIndex = 700,
}, gui)
bind(ChatBar, "BackgroundColor3", "bg"); corner(ChatBar, 12)
local chatStroke = new("UIStroke", {Thickness = 1.4}, ChatBar); bind(chatStroke, "Color", "accent")
local chatBox = new("TextBox", {
	Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = "",
	PlaceholderText = "Сообщение (Enter — отправить, Esc — отмена)", Font = Enum.Font.Gotham, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 701,
}, ChatBar)
bind(chatBox, "TextColor3", "text"); bind(chatBox, "PlaceholderColor3", "sub")
local chatWarn = new("TextLabel", {
	Size = UDim2.fromOffset(400, 22), Position = UDim2.new(0, 16, 0, 244), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = rgb(255, 90, 90), TextXAlignment = Enum.TextXAlignment.Left,
	TextTransparency = 1, ZIndex = 701,
}, gui)
local warnToken = 0
local function showWarn(text)
	warnToken += 1
	local my = warnToken
	chatWarn.Text = text
	chatWarn.TextTransparency = 0
	task.delay(4, function()
		if my == warnToken then tw(chatWarn, 0.4, {TextTransparency = 1}) end
	end)
end
draggable(ChatBar, ChatBar)

local function sendChat(text)
	local ok = pcall(function()
		local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
		ch:SendAsync(text)
	end)
	if not ok then notify("ЧАТ", "Не удалось отправить сообщение") end
end
local function openChatBar()
	ChatBar.Visible = true
	task.defer(function()
		chatBox:CaptureFocus()
		task.wait()
		chatBox.Text = ""
	end)
end
chatBox.FocusLost:Connect(function(enter)
	if not enter then ChatBar.Visible = false; return end
	local text = chatBox.Text
	if not text:match("%S") then ChatBar.Visible = false; return end
	local bad = checkMessage(text)
	if bad then
		showWarn("🚫 Не отправлено: запрещённое слово «" .. bad .. "»")
		if chatWarnCenter then
			NS.centerMessage("🚫 Сообщение заблокировано", "В тексте есть слово из вашего списка запрещённых: «" .. bad .. "».\nОтредактируйте сообщение и отправьте снова.", "Понятно", 8)
		end
		task.defer(function() chatBox:CaptureFocus() end)
		return
	end
	chatBox.Text = ""
	ChatBar.Visible = false
	sendChat(text)
end)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not chatFilterOn or not newChat or ChatBar.Visible then return end
	if input.KeyCode == Enum.KeyCode.Slash then openChatBar() end
end)

local function applyFilterState(v)
	chatFilterOn = v
	if not newChat then
		if v then notify("ЧАТ", "Фильтр работает только с новым чатом (TextChatService)") end
		return
	end
	pcall(function() TextChatService.ChatInputBarConfiguration.Enabled = not v end)
	if v then notify("🛡️ ФИЛЬТР ЧАТА", "Пишите через клавишу /  (стандартное поле выключено)") end
	if not v then ChatBar.Visible = false end
end

-- звук при упоминании ника
pcall(function()
	TextChatService.MessageReceived:Connect(function(msg)
		if not pingOn then return end
		local src = msg.TextSource
		if not src or src.UserId == player.UserId then return end
		local low = lowerText(msg.Text or "")
		local hit = low:find(lowerText(player.Name), 1, true) or low:find(lowerText(player.DisplayName), 1, true)
		if hit then
			pingSound:Play()
			local who = Players:GetPlayerByUserId(src.UserId)
			notify("🔔 ВАС УПОМЯНУЛИ", (who and who.DisplayName or "?") .. ": " .. (msg.Text or ""):sub(1, 36))
		end
	end)
end)

-- >> интерфейс
addLabel(pChat, "ФИЛЬТР ЗАПРЕЩЁННЫХ СЛОВ (банворды, реклама чужих проектов)")
addToggle(pChat, "🛡️ Проверять сообщения перед отправкой", false, applyFilterState, "chat_filter")
addToggle(pChat, "🪧 Центральное предупреждение при блокировке", true, function(v) chatWarnCenter = v end, "chat_warn_center")
local wordsBox = V.addInput(pChat, "Слова через запятую или с новой строки", table.concat(chatWords, ", "), 90, true)
addButton(pChat, "💾 Сохранить список слов", function()
	local list = {}
	for w in wordsBox.Text:gmatch("[^,\n]+") do table.insert(list, w) end
	setChatWords(list)
	wordsBox.Text = table.concat(chatWords, ", ")
	notify("🛡️ ФИЛЬТР ЧАТА", "Слов в списке: " .. #chatWords)
end)
addLabel(pChat, "Слова сравниваются без пробелов и знаков (минимум 3 символа).")
local testBox = V.addInput(pChat, "Проверка: введите сообщение", "", 36, false)
addButton(pChat, "🔍 Проверить сообщение", function()
	local bad = checkMessage(testBox.Text)
	if bad then notify("🚫 БЛОК", "Найдено слово: " .. bad) else notify("✅ ОК", "Сообщение можно отправлять") end
end)

addLabel(pChat, "ПИНГ ПО НИКУ")
addToggle(pChat, "🔔 Звук, когда упоминают мой ник в чате", false, function(v)
	pingOn = v
	if v and not newChat then notify("ЧАТ", "Пинг работает только с новым чатом (TextChatService)") end
end, "chat_ping")
addSlider(pChat, "Громкость сигнала", 0, 1, 0.8, 2, function(v) pingSound.Volume = v end, "chat_ping_volume")
local pingIdBox = V.addInput(pChat, "ID своего звука (пусто — стандартный)", "", 36, false)
addButton(pChat, "🎵 Применить ID и проверить звук", function()
	local id = pingIdBox.Text:match("%d+")
	pingSound.SoundId = id and ("rbxassetid://" .. id) or "rbxasset://sounds/electronicpingshort.wav"
	pingSound:Play()
end)
NS.setPingSound = function(id)
	pingSound.SoundId = id and ("rbxassetid://" .. id) or "rbxasset://sounds/electronicpingshort.wav"
	pingIdBox.Text = id or ""
end
NS.getPingId = function() return pingIdBox.Text:match("%d+") end
NS.refreshWordsBox = function() wordsBox.Text = table.concat(chatWords, ", ") end


end
do
-- =============================================================================
-- v5: Защита AFK (анти-удочка): персонаж замирает, пока вы без движения
end
do
-- =============================================================================
local pGuard = createTab("🛡️ Защита")
local afk = {on = false, secs = 20, onlySpawn = false, radius = 60, frozen = false, last = os.clock()}
local spawnPos, spawnScanned = {}, false

local afkLabel = new("TextLabel", {
	Size = UDim2.fromOffset(260, 24), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70),
	BackgroundTransparency = 0.1, Text = "🛡️ AFK-защита активна", Font = Enum.Font.GothamBold, TextSize = 12,
	Visible = false, ZIndex = 160,
}, gui)
bind(afkLabel, "BackgroundColor3", "bg"); bind(afkLabel, "TextColor3", "accent"); corner(afkLabel, 12)

local function scanSpawns()
	spawnScanned = true
	pcall(function()
		for _, d in ipairs(workspace:GetDescendants()) do
			if d:IsA("SpawnLocation") and #spawnPos < 20 then table.insert(spawnPos, d.Position) end
		end
	end)
end
local function nearSpawn(pos)
	if not spawnScanned then scanSpawns() end
	for _, p in ipairs(spawnPos) do
		if (p - pos).Magnitude <= afk.radius then return true end
	end
	return false
end
local function release()
	if not afk.frozen then return end
	afk.frozen = false
	afkLabel.Visible = false
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored = false end
end
local function activity()
	afk.last = os.clock()
	release()
end
UIS.InputBegan:Connect(function() activity() end)
UIS.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
		or i.UserInputType == Enum.UserInputType.MouseWheel then activity() end
end)
player.CharacterAdded:Connect(function()
	afk.frozen = false; afkLabel.Visible = false; afk.last = os.clock()
end)

local afkAcc = 0
RunService.Heartbeat:Connect(function(dt)
	afkAcc += dt
	if afkAcc < 0.5 then return end
	afkAcc = 0
	if not afk.on or afk.frozen then return end
	if os.clock() - afk.last < afk.secs then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then return end
	if hum.FloorMaterial == Enum.Material.Air then return end
	if afk.onlySpawn and not nearSpawn(root.Position) then return end
	afk.frozen = true
	root.Anchored = true
	afkLabel.Visible = true
end)

addLabel(pGuard, "АНТИ-УДОЧКА (защита, пока вы AFK)")
addToggle(pGuard, "🛡️ Замораживать персонажа, если вы без движения", false, function(v)
	afk.on = v
	if not v then release() end
end, "afk_guard")
addSlider(pGuard, "Через сколько секунд без ввода", 5, 120, 20, 0, function(v) afk.secs = v end, "afk_secs")
addToggle(pGuard, "🏠 Только рядом со спавном", false, function(v) afk.onlySpawn = v end, "afk_only_spawn")
addSlider(pGuard, "Радиус спавна (studs)", 20, 300, 60, 0, function(v) afk.radius = v end, "afk_radius")
addLabel(pGuard, "Работает только на вас: любое нажатие клавиши или движение мыши освобождает.")
addLabel(pGuard, "Если игра двигает вас сама (сервером), защита может не помочь.")

-- >> ближайшие игроки (только те, кого вы видите)
local nearOn, nearRadius = false, 80
local NearPanel = new("Frame", {
	Size = UDim2.fromOffset(190, 10), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 16, 0.5, 0), BackgroundTransparency = 0.08, Visible = false, ZIndex = 150,
}, gui)
bind(NearPanel, "BackgroundColor3", "bg"); corner(NearPanel, 14)
local nearStroke = new("UIStroke", {Thickness = 1, Transparency = 0.55}, NearPanel); bind(nearStroke, "Color", "accent")
new("UIPadding", {
	PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
}, NearPanel)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, NearPanel)
draggable(NearPanel, NearPanel)
local nearHead = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "👥  Рядом", Font = Enum.Font.GothamBold, TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, ZIndex = 151,
}, NearPanel); bind(nearHead, "TextColor3", "accent")

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function canSee(head, char)
	local origin = camera.CFrame.Position
	rayParams.FilterDescendantsInstances = {player.Character}
	local res = workspace:Raycast(origin, head.Position - origin, rayParams)
	return res == nil or res.Instance:IsDescendantOf(char)
end
local nearAcc = 0
RunService.Heartbeat:Connect(function(dt)
	nearAcc += dt
	if nearAcc < 0.5 then return end
	nearAcc = 0
	NearPanel.Visible = nearOn and not NS.hudHiddenFn()
	if not NearPanel.Visible then return end
	for _, c in ipairs(NearPanel:GetChildren()) do
		if c:IsA("TextLabel") and c ~= nearHead then c:Destroy() end
	end
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local rows = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local ch = p.Character
		local head = ch and ch:FindFirstChild("Head")
		if p ~= player and head then
			local d = (head.Position - myRoot.Position).Magnitude
			if d <= nearRadius then
				local _, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen and canSee(head, ch) then table.insert(rows, {p.DisplayName, d}) end
			end
		end
	end
	table.sort(rows, function(a, b) return a[2] < b[2] end)
	for i = 1, math.min(#rows, 8) do
		local l = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = rows[i][1] .. "  ·  " .. math.floor(rows[i][2] * 0.28 + 0.5) .. "m",
			Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = i, ZIndex = 151,
		}, NearPanel); bind(l, "TextColor3", "text")
	end
	if #rows == 0 then
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "никого в поле зрения", Font = Enum.Font.Gotham,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Theme.sub, LayoutOrder = 1, ZIndex = 151,
		}, NearPanel)
	end
end)
addLabel(pGuard, "СПИСОК РЯДОМ (только игроки в поле зрения, не сквозь стены)")
addToggle(pGuard, "👥 Показывать ближайших игроков", false, function(v) nearOn = v end, "nearby_players")
addSlider(pGuard, "Радиус списка (studs)", 20, 300, 80, 0, function(v) nearRadius = v end, "nearby_radius")


end
do
-- =============================================================================
-- v5: Необязательная связь с игрой (события из вашего кода, сервер не нужен)
end
do
-- =============================================================================
local function clean(s, n)
	s = tostring(s or "")
	s = s:gsub("%c", " ")
	return s:sub(1, n or 80)
end

-- Если в вашей игре есть RemoteEvent «VisualsNotice» в ReplicatedStorage, ваш серверный код
-- может показывать игрокам плашки, сообщения и метки:
--   VisualsNotice:FireClient(player, "bar", "Заголовок", "Подпись")
--   VisualsNotice:FireAllClients("center", "Заголовок", "Текст")
--   VisualsNotice:FireAllClients("marker", "Ивент", x, y, z)
-- Без этого события работают как демо во вкладке «Панели» → кнопки теста.
task.spawn(function()
	local ev = game:GetService("ReplicatedStorage"):WaitForChild("VisualsNotice", 5)
	if not ev or not ev:IsA("RemoteEvent") then return end
	ev.OnClientEvent:Connect(function(kind, a, b, c, d)
		if kind == "bar" then
			notify(clean(a, 40), clean(b, 60))
		elseif kind == "center" then
			NS.centerMessage(clean(a, 60), clean(b, 240), "OK", 12)
		elseif kind == "marker" then
			local x, y, z = tonumber(b), tonumber(c), tonumber(d)
			if x and y and z and math.abs(x) < 1e6 and math.abs(y) < 1e6 and math.abs(z) < 1e6 then
				NS.addMarker(clean(a, 30), Vector3.new(x, y, z), {kind = "event", icon = "🔥", colorIdx = 2, ttl = 300})
			end
		end
	end)
end)

addLabel(V.pPanels, "ПРОВЕРКА УВЕДОМЛЕНИЙ")
addButton(V.pPanels, "📣 Плашка внизу (пример: Текущий — AirDrop • Мифический)", function()
	notify("Текущий", "AirDrop  •  Мифический")
end)
addButton(V.pPanels, "💬 Центральное сообщение с размытием (пример)", function()
	NS.centerMessage("🎁 Событие", "Так выглядит центральное сообщение: фон размывается, текст — по центру.", "Понятно", 10)
end)


end
do
-- =============================================================================
-- v5: Конфиги: текст с командами (вкл/выкл), сохранение, загрузка с GitHub
end
do
-- =============================================================================
local pCfg = createTab("💾 Конфиг")
local CONFIG_VERSION = "v1"
local cfgBox

local function onOff(v) return v and "on" or "off" end
local function parseBool(s)
	s = tostring(s):lower()
	if s == "on" or s == "true" or s == "1" or s == "yes" or s == "вкл" then return true end
	if s == "off" or s == "false" or s == "0" or s == "no" or s == "выкл" then return false end
	return nil
end
local function trim(s) return (tostring(s):match("^%s*(.-)%s*$")) end
local function splitPipe(s)
	local out = {}
	for part in (s .. "|"):gmatch("(.-)|") do table.insert(out, trim(part)) end
	return out
end

local function themeName()
	for _, t in ipairs(Themes) do
		if t.accent == Theme.accent and t.bg == Theme.bg then return t.name end
	end
	return "custom"
end

local function buildConfig()
	local L = {}
	local function add(s) table.insert(L, s) end
	add("# Roblox Visuals config " .. CONFIG_VERSION)
	add("# команды: on/off для переключателей, число для ползунков")
	add("theme = " .. themeName())
	add("toggle_style = " .. ToggleStyle)
	for _, def in ipairs(V.HotkeyDefs) do
		local kc = Keybinds[def[1]]
		if kc then add("bind." .. def[1] .. " = " .. kc.Name) end
	end
	for _, id in ipairs(RegistryOrder) do
		local r = Registry[id]
		if r.kind == "toggle" then add(id .. " = " .. onOff(r.get())) else add(id .. " = " .. tostring(r.get())) end
	end
	for _, w in ipairs(NS.chatWords) do add("banword = " .. w) end
	local pid = NS.getPingId()
	if pid then add("ping_sound = " .. pid) end
	for _, m in ipairs(NS.Markers) do
		if m.kind == "user" then
			add(string.format("marker = %s | %.1f | %.1f | %.1f | %d | %d", (m.name:gsub("|", "/")), m.pos.X, m.pos.Y, m.pos.Z, m.iconIdx, m.colorIdx))
		end
	end
	for _, e in ipairs(NS.cooldowns) do
		add(string.format("cooldown = %s | %d | %s | %s", (e.name:gsub("|", "/")), e.secs, e.key, (e.tool:gsub("|", "/"))))
	end
	for _, t in ipairs(V.playlist) do add("track = " .. (t.name:gsub("|", "/")) .. " | " .. t.id) end
	return table.concat(L, "\n")
end

local function applyConfig(text)
	if type(text) ~= "string" then return 0, 0, "пусто" end
	if #text > 24000 then return 0, 0, "файл слишком большой" end
	local applied, skipped = 0, 0
	local cleared = {}
	local function clearOnce(kind, fn)
		if not cleared[kind] then cleared[kind] = true; fn() end
	end
	local words = {}
	local sawWords = false
	for rawLine in text:gmatch("[^\r\n]+") do
		local line = trim(rawLine)
		if line ~= "" and line:sub(1, 1) ~= "#" then
			local key, val = line:match("^([%w_%.]+)%s*=%s*(.-)%s*$")
			local ok = false
			if key then
				key = key:lower()
				if key == "theme" then
					for _, t in ipairs(Themes) do
						if t.name:lower() == val:lower() then applyTheme(t); ok = true end
					end
				elseif key == "toggle_style" then
					if val == "pill" or val == "square" or val == "dot" then setToggleStyle(val); ok = true end
				elseif key:sub(1, 5) == "bind." then
					local id = key:sub(6)
					local okK, kc = pcall(function() return Enum.KeyCode[val] end)
					if Keybinds[id] and okK and kc then Keybinds[id] = kc; ok = true end
				elseif key == "banword" then
					sawWords = true
					if #val >= 3 and #val <= 40 then table.insert(words, val); ok = true end
				elseif key == "ping_sound" then
					local id = val:match("^%d+$")
					if id then NS.setPingSound(id); ok = true end
				elseif key == "marker" then
					local p = splitPipe(val)
					local x, y, z = tonumber(p[2]), tonumber(p[3]), tonumber(p[4])
					if p[1] and p[1] ~= "" and x and y and z and math.abs(x) < 1e6 and math.abs(y) < 1e6 and math.abs(z) < 1e6 then
						clearOnce("marker", function() NS.clearMarkers("user") end)
						NS.addMarker(p[1], Vector3.new(x, y, z), {iconIdx = tonumber(p[5]) or 1, colorIdx = tonumber(p[6]) or 1})
						ok = true
					end
				elseif key == "cooldown" then
					local p = splitPipe(val)
					if p[1] and p[1] ~= "" and tonumber(p[2]) then
						clearOnce("cooldown", function() NS.clearCooldowns() end)
						NS.addCooldown(p[1], p[2], p[3] or "", p[4] or "")
						ok = true
					end
				elseif key == "track" then
					local p = splitPipe(val)
					local id = p[2] and p[2]:match("^%d+$")
					if p[1] and p[1] ~= "" and id and #V.playlist < 60 then
						clearOnce("track", function() table.clear(V.playlist) end)
						table.insert(V.playlist, {name = p[1]:sub(1, 60), id = id})
						ok = true
					end
				else
					local r = Registry[key]
					if r then
						if r.kind == "toggle" then
							local b = parseBool(val)
							if b ~= nil then r.set(b); ok = true end
						else
							local n = tonumber(val)
							if n then r.set(math.clamp(n, r.min or n, r.max or n)); ok = true end
						end
					end
				end
			end
			if ok then applied += 1 else skipped += 1 end
		end
	end
	if sawWords then NS.setChatWords(words); NS.refreshWordsBox() end
	if cleared.track and V.rebuildPlaylist then V.rebuildPlaylist() end
	NS.refreshChips()
	NS.updatePanelsVisibility()
	return applied, skipped, nil
end
NS.applyConfig = applyConfig

local function applyAndReport(text, source)
	local a, s, err = applyConfig(text)
	if err then notify("💾 КОНФИГ", "Ошибка: " .. err); return end
	notify("💾 КОНФИГ", source .. ": применено " .. a .. ", пропущено " .. s)
end

-- >> интерфейс
addLabel(pCfg, "КОНФИГ — ТЕКСТ С КОМАНДАМИ (что включено, что выключено)")
cfgBox = V.addInput(pCfg, "Здесь появится ваш конфиг. Можно вставить чужой и нажать «Применить».", "", 240, true)
cfgBox.TextSize = 11
addButton(pCfg, "📤 Создать конфиг из моих настроек", function()
	cfgBox.Text = buildConfig()
	notify("💾 КОНФИГ", "Готово. Скопируйте текст (Ctrl+A, Ctrl+C) и выложите на GitHub")
end)
addButton(pCfg, "📥 Применить конфиг из поля", function() applyAndReport(cfgBox.Text, "Поле") end)
addLabel(pCfg, "КАК ПОДЕЛИТЬСЯ: нажмите «Создать», скопируйте текст (Ctrl+A, Ctrl+C) и отправьте другу или выложите на GitHub.")
addLabel(pCfg, "КАК ЗАГРУЗИТЬ: вставьте чужой текст в поле выше и нажмите «Применить».")
addLabel(pCfg, "АВТОЗАГРУЗКА: вставьте конфиг в начало скрипта (DEFAULT_CONFIG) — он применится при каждом запуске.")
addButton(pCfg, "♻️ Сбросить все настройки по умолчанию", function()
	V.dialog("♻️ СБРОС", "Все переключатели и ползунки вернутся к значениям по умолчанию.", "Сбросить", "Отмена", function()
		for _, id in ipairs(RegistryOrder) do
			local r = Registry[id]
			pcall(r.set, r.default)
		end
		notify("♻️ СБРОС", "Настройки возвращены")
	end)
end)

-- встроенный конфиг применяется при каждом запуске
task.delay(1.5, function()
	if type(DEFAULT_CONFIG) == "string" and DEFAULT_CONFIG:match("[%w_%.]+%s*=") then
		applyAndReport(DEFAULT_CONFIG, "Встроенный")
	end
end)


end
do
-- =============================================================================
-- ======================  РАСШИРЕНИЕ v6: HALLOWEEN 🎃  =======================
-- Страшный интерфейс, косметика персонажа, пиксельный редактор курсора,
-- режим стримера, хеллоуинский таб игроков, секретная история (версия x3)
-- Всё только на стороне клиента (видно только вам).
-- =============================================================================
V.H = {}
local H = V.H
H.VERSION = "6.66 Halloween"
H.SCARY_FONT = Enum.Font.Creepster
-- свои звуки (вставьте rbxassetid://... если хотите). Пусто = без звука.
H.SOUNDS = {
	laugh = "",                          -- смех тыквы в заставке
	thunder = "",                        -- гром
	scream = "rbxasset://sounds/uuhhh.mp3", -- скример
	candy = "rbxasset://sounds/electronicpingshort.wav",
}
function H.sound(key, vol)
	local id = H.SOUNDS[key]
	if not id or id == "" then return end
	local s = Instance.new("Sound")
	s.SoundId = id; s.Volume = vol or 0.8; s.Parent = V.SoundService or game:GetService("SoundService")
	s:Play()
	Debris:AddItem(s, 8)
end

H.Pal = {
	{"Тыква", rgb(255, 120, 20)}, {"Кровь", rgb(190, 10, 20)}, {"Яд", rgb(120, 255, 60)}, {"Ведьма", rgb(140, 50, 220)},
	{"Кость", rgb(235, 230, 210)}, {"Ночь", rgb(18, 12, 22)}, {"Призрак", rgb(190, 235, 255)}, {"Пламя", rgb(255, 205, 40)},
}
H.Theme = {name = "Halloween", bg = rgb(10, 6, 8), header = rgb(28, 10, 6), accent = rgb(255, 110, 10), text = rgb(255, 236, 215), sub = rgb(175, 120, 95), btn = rgb(36, 16, 12)}
H.BloodTheme = {name = "Blood Moon", bg = rgb(8, 2, 4), header = rgb(32, 4, 8), accent = rgb(205, 18, 30), text = rgb(255, 225, 225), sub = rgb(165, 90, 95), btn = rgb(38, 8, 12)}
H.WitchTheme = {name = "Witch", bg = rgb(10, 6, 16), header = rgb(22, 10, 34), accent = rgb(130, 255, 70), text = rgb(240, 255, 230), sub = rgb(150, 130, 170), btn = rgb(30, 16, 44)}
H.GhostTheme = {name = "Ghost", bg = rgb(8, 10, 14), header = rgb(18, 22, 30), accent = rgb(190, 235, 255), text = rgb(240, 248, 255), sub = rgb(130, 150, 170), btn = rgb(24, 30, 40)}
for _, t in ipairs({H.Theme, H.BloodTheme, H.WitchTheme, H.GhostTheme}) do table.insert(Themes, t) end

-- имя игрока (с учётом режима стримера)
H.hideName = false
function H.name(plr)
	plr = plr or player
	if H.hideName and plr == player then return "Стример" end
	return plr.DisplayName
end

-- строка выбора цвета
function H.colorRow(parent, title, cb)
	local holder = new("Frame", {Size = UDim2.new(1, -8, 0, 60), BackgroundTransparency = 0.35, ZIndex = 13}, parent)
	bind(holder, "BackgroundColor3", "btn"); corner(holder, 10)
	local l = new("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20), Position = UDim2.fromOffset(12, 4), BackgroundTransparency = 1, Text = title,
		Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	}, holder); bind(l, "TextColor3", "text")
	local row = new("Frame", {Size = UDim2.new(1, -20, 0, 26), Position = UDim2.fromOffset(12, 28), BackgroundTransparency = 1, ZIndex = 14}, holder)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6)}, row)
	for _, p in ipairs(H.Pal) do
		local b = new("TextButton", {Size = UDim2.fromOffset(26, 26), BackgroundColor3 = p[2], Text = "", ZIndex = 15}, row)
		corner(b, 13)
		new("UIStroke", {Color = rgb(0, 0, 0), Thickness = 1.5}, b)
		b.Activated:Connect(function()
			l.Text = title .. "  —  " .. p[1]
			pcall(cb, p[2])
		end)
	end
	return holder
end

-- toggle, который можно переключать из пресетов
function H.toggle(parent, title, default, cb)
	addToggle(parent, title, default, cb)
	return RegistryOrder[#RegistryOrder]
end
function H.setToggle(id, v)
	local r = id and Registry[id]
	if r and r.get() ~= v then pcall(r.set, v) end
end

V.pHallo = createTab("🎃 Хеллоуин")
V.pHChar = createTab("🧟 Персонаж+")
V.pPix = createTab("🖌️ Свой курсор")
V.pStream = createTab("🎥 Стример")
V.pBoard = createTab("💀 Таб игроков")
V.pFun = createTab("🦇 Страшилки")

end
do
-- ---------------------------------------------------------------------------
-- Страшное оформление меню
-- ---------------------------------------------------------------------------
local H = V.H
local decor = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 11, Visible = false}, Main)
H.menuDecor = decor
local function web(pos, anchor, rot)
	new("TextLabel", {
		Size = UDim2.fromOffset(46, 46), Position = pos, AnchorPoint = anchor, BackgroundTransparency = 1, Text = "🕸️",
		TextSize = 40, TextTransparency = 0.35, Rotation = rot, ZIndex = 19,
	}, decor)
end
web(UDim2.new(0, -8, 0, -8), Vector2.new(0, 0), 0)
web(UDim2.new(1, 8, 0, -8), Vector2.new(1, 0), 90)
web(UDim2.new(0, -8, 1, 8), Vector2.new(0, 1), -90)
web(UDim2.new(1, 8, 1, 8), Vector2.new(1, 1), 180)

-- капли крови под шапкой
local drips = {}
for i = 1, 14 do
	local d = new("Frame", {
		Size = UDim2.fromOffset(V.rng:NextInteger(3, 6), 0), Position = UDim2.new(i / 15, 0, 0, 46),
		BackgroundColor3 = rgb(150, 6, 14), BorderSizePixel = 0, ZIndex = 18,
	}, decor)
	corner(d, 3)
	table.insert(drips, d)
end
task.spawn(function()
	while gui.Parent do
		if decor.Visible and Main.Visible then
			local d = drips[V.rng:NextInteger(1, #drips)]
			local h = V.rng:NextInteger(10, 34)
			d.BackgroundTransparency = 0
			tw(d, 1.4, {Size = UDim2.fromOffset(d.Size.X.Offset, h)}, Enum.EasingStyle.Sine)
			task.delay(2.5, function()
				tw(d, 1, {BackgroundTransparency = 1})
				task.wait(1)
				d.Size = UDim2.fromOffset(d.Size.X.Offset, 0)
			end)
		end
		task.wait(V.rng:NextNumber(0.4, 1.2))
	end
end)

-- летучие мыши вокруг меню
local bats = {}
for i = 1, 4 do
	local b = new("TextLabel", {
		Size = UDim2.fromOffset(28, 28), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
		Text = "🦇", TextSize = 22, ZIndex = 20,
	}, decor)
	table.insert(bats, {b, i * 1.6, V.rng:NextNumber(0.6, 1.1)})
end
local glowT = 0
RunService.RenderStepped:Connect(function(dt)
	if not decor.Visible or not Main.Visible then return end
	glowT += dt
	for _, b in ipairs(bats) do
		local a = glowT * b[3] + b[2]
		b[1].Position = UDim2.new(0.5 + math.cos(a) * 0.56, 0, 0.5 + math.sin(a * 1.3) * 0.58, 0)
		b[1].Rotation = math.sin(glowT * 12 + b[2]) * 18
	end
	-- мерцающая обводка как свеча
	if mainStroke then
		mainStroke.Transparency = 0.15 + math.abs(math.noise(glowT * 3, 0.5)) * 0.8
		mainStroke.Thickness = 1.5 + math.abs(math.sin(glowT * 2)) * 1.5
	end
end)

function H.setScaryMenu(on)
	decor.Visible = on
	Title.Font = on and V.H.SCARY_FONT or Enum.Font.GothamBold
	Title.TextSize = on and 20 or 14
	for _, tb in ipairs(tabButtons) do
		tb.Font = on and Enum.Font.Fantasy or Enum.Font.GothamSemibold
		tb.TextSize = on and 13 or 12
	end
	ToggleBtn.Text = on and "🎃" or "V"
	ToggleBtn.TextSize = on and 24 or 20
end

-- ---------------------------------------------------------------------------
-- Экранные эффекты: туман, летучие мыши, призраки, молнии, виньетка
-- ---------------------------------------------------------------------------
local fx = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Active = false}, gui)
H.fxLayer = fx
local fxOn = {fog = true, bats = true, ghosts = false, lightning = true, vignette = true, grain = false}
H.fxOn = fxOn

local vig = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2}, fx)
for _, d in ipairs({{0, 90}, {1, 270}, {0.5, 0}, {0.5, 180}}) do
	local f = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(40, 0, 4), BorderSizePixel = 0, ZIndex = 2}, vig)
	new("UIGradient", {
		Rotation = d[2],
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(0.22, 1), NumberSequenceKeypoint.new(1, 1)}),
	}, f)
end

local fogs = {}
for i = 1, 3 do
	local f = new("Frame", {
		Size = UDim2.new(2, 0, 0.35, 0), Position = UDim2.new(-1, 0, 0.65 + i * 0.03, 0), BackgroundColor3 = rgb(120, 110, 130),
		BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 2,
	}, fx)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.3), NumberSequenceKeypoint.new(1, 0.1)}),
	}, f)
	table.insert(fogs, {f, 0.012 * i})
end

local flash = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(230, 230, 255), BackgroundTransparency = 1, ZIndex = 1990}, gui)
function H.lightning(strength)
	H.sound("thunder", 0.7)
	for _ = 1, V.rng:NextInteger(1, 3) do
		flash.BackgroundTransparency = 1 - (strength or 0.55)
		tw(flash, 0.12, {BackgroundTransparency = 1})
		task.wait(V.rng:NextNumber(0.08, 0.2))
	end
end

local grain = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1, ZIndex = 3}, fx)

function H.flyAcross(text, size)
	local y = V.rng:NextNumber(0.05, 0.6)
	local ltr = V.rng:NextNumber() > 0.5
	local b = new("TextLabel", {
		Size = UDim2.fromOffset(size, size), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Text = text,
		TextSize = size, Position = UDim2.fromScale(ltr and -0.05 or 1.05, y), ZIndex = 4,
	}, fx)
	local t = V.rng:NextNumber(4, 8)
	tw(b, t, {Position = UDim2.fromScale(ltr and 1.05 or -0.05, y + V.rng:NextNumber(-0.2, 0.2))}, Enum.EasingStyle.Linear)
	Debris:AddItem(b, t + 0.2)
	return b
end

local fxT, nextBat, nextGhost, nextBolt = 0, 3, 6, 12
RunService.Heartbeat:Connect(function(dt)
	fxT += dt
	fx.Visible = V.H.screenFx ~= false
	if not fx.Visible then return end
	vig.Visible = fxOn.vignette
	for _, f in ipairs(fogs) do
		f[1].Visible = fxOn.fog
		if fxOn.fog then
			local x = f[1].Position.X.Scale + f[2] * dt
			if x > 0 then x = -1 end
			f[1].Position = UDim2.new(x, 0, f[1].Position.Y.Scale, 0)
		end
	end
	grain.BackgroundTransparency = fxOn.grain and (0.9 + V.rng:NextNumber() * 0.08) or 1
	if fxOn.bats and fxT > nextBat then
		nextBat = fxT + V.rng:NextNumber(4, 12)
		for _ = 1, V.rng:NextInteger(1, 4) do
			local b = H.flyAcross("🦇", V.rng:NextInteger(18, 34))
			task.spawn(function()
				while b.Parent do b.Rotation = math.sin(os.clock() * 16) * 20; task.wait(0.05) end
			end)
		end
	end
	if fxOn.ghosts and fxT > nextGhost then
		nextGhost = fxT + V.rng:NextNumber(8, 18)
		local g = H.flyAcross("👻", V.rng:NextInteger(30, 50))
		g.TextTransparency = 0.4
	end
	if fxOn.lightning and fxT > nextBolt then
		nextBolt = fxT + V.rng:NextNumber(20, 45)
		task.spawn(H.lightning, 0.45)
	end
end)

-- ---------------------------------------------------------------------------
-- Хеллоуинский мир (освещение) + тыквы вокруг
-- ---------------------------------------------------------------------------
local saved
local cc = new("ColorCorrectionEffect", {Name = "VLH_CC", Enabled = false, TintColor = rgb(255, 205, 170), Saturation = -0.15, Contrast = 0.15, Brightness = -0.04}, Lighting)
function H.setWorld(on)
	if on then
		if not saved then
			saved = {
				ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
				FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, Brightness = Lighting.Brightness,
			}
		end
		Lighting.ClockTime = 0.2
		Lighting.Ambient = rgb(60, 30, 20)
		Lighting.OutdoorAmbient = rgb(70, 35, 45)
		Lighting.FogColor = rgb(35, 18, 30)
		Lighting.FogStart = 10
		Lighting.FogEnd = 260
		Lighting.Brightness = 1.2
		cc.Enabled = true
	else
		cc.Enabled = false
		if saved then
			for k, v in pairs(saved) do pcall(function() Lighting[k] = v end) end
			saved = nil
		end
	end
end

local pumpkinFolder
function H.makePumpkinPart(cf, size, parent)
	local m = new("Part", {
		Name = "VLH_Pumpkin", Shape = Enum.PartType.Ball, Size = Vector3.new(size, size * 0.85, size), Color = rgb(235, 110, 20),
		Material = Enum.Material.SmoothPlastic, Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CFrame = cf,
	}, parent)
	new("Part", {
		Name = "Stem", Size = Vector3.new(size * 0.15, size * 0.3, size * 0.15), Color = rgb(60, 110, 30), Material = Enum.Material.Wood,
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CFrame = cf * CFrame.new(0, size * 0.5, 0) * CFrame.Angles(0, 0, 0.25),
	}, m)
	local face = new("SurfaceGui", {Face = Enum.NormalId.Front, LightInfluence = 0, AlwaysOnTop = false, CanvasSize = Vector2.new(100, 100)}, m)
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "▲ ▲\nᗣᗣᗣ", TextScaled = true, Font = Enum.Font.GothamBlack,
		TextColor3 = rgb(255, 220, 60),
	}, face)
	new("PointLight", {Color = rgb(255, 140, 30), Range = size * 5, Brightness = 2, Shadows = false}, m)
	return m
end
function H.setPumpkins(on)
	if pumpkinFolder then pumpkinFolder:Destroy(); pumpkinFolder = nil end
	if not on then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	pumpkinFolder = new("Folder", {Name = "VLH_Pumpkins"}, workspace)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char, pumpkinFolder}
	for i = 1, 12 do
		local a = i / 12 * math.pi * 2
		local pos = root.Position + Vector3.new(math.cos(a) * 14, 6, math.sin(a) * 14)
		local hit = workspace:Raycast(pos, Vector3.new(0, -40, 0), params)
		local size = V.rng:NextNumber(1.6, 2.8)
		local y = hit and hit.Position.Y + size * 0.42 or root.Position.Y - 2
		local look = CFrame.lookAt(Vector3.new(pos.X, y, pos.Z), Vector3.new(root.Position.X, y, root.Position.Z))
		H.makePumpkinPart(look, size, pumpkinFolder)
	end
end

end
do
-- ---------------------------------------------------------------------------
-- Вкладка «Хеллоуин»
-- ---------------------------------------------------------------------------
local H = V.H
local p = V.pHallo
addLabel(p, "🎃 ХЕЛЛОУИН-РЕЖИМ  ·  v" .. H.VERSION)
addToggle(p, "🕸️ Страшное меню (паутина, кровь, мыши)", true, function(v) H.setScaryMenu(v) end)
addButton(p, "🎃 Тема: Halloween (оранжевая)", function() applyTheme(H.Theme) end)
addButton(p, "🩸 Тема: Blood Moon (кровавая)", function() applyTheme(H.BloodTheme) end)
addButton(p, "🧪 Тема: Witch (ведьминская)", function() applyTheme(H.WitchTheme) end)
addButton(p, "👻 Тема: Ghost (призрачная)", function() applyTheme(H.GhostTheme) end)
addLabel(p, "ЭКРАННЫЕ ЭФФЕКТЫ")
addToggle(p, "🌫️ Туман внизу экрана", true, function(v) H.fxOn.fog = v end)
addToggle(p, "🦇 Летучие мыши по экрану", true, function(v) H.fxOn.bats = v end)
addToggle(p, "👻 Пролетающие призраки", false, function(v) H.fxOn.ghosts = v end)
addToggle(p, "⚡ Случайные молнии", true, function(v) H.fxOn.lightning = v end)
addToggle(p, "🩸 Кровавая виньетка", true, function(v) H.fxOn.vignette = v end)
addToggle(p, "📼 Шум старой плёнки", false, function(v) H.fxOn.grain = v end)
addButton(p, "⚡ Ударить молнией сейчас", function() task.spawn(H.lightning, 0.7) end)
addLabel(p, "МИР (только у вас)")
addToggle(p, "🌑 Хеллоуинская ночь (свет, туман, тон)", true, function(v) H.setWorld(v) end)
addToggle(p, "🎃 Тыквы-фонари вокруг меня", false, function(v) H.setPumpkins(v) end)
addButton(p, "🔁 Переставить тыквы сюда", function() H.setPumpkins(true) end)

-- отсчёт до Хеллоуина
local cd = addLabel(p, "")
cd.Font = H.SCARY_FONT; cd.TextSize = 16
task.spawn(function()
	while gui.Parent do
		local now = os.date("*t")
		local target = os.time({year = now.year, month = 10, day = 31, hour = 0})
		if os.time() > target + 86400 then target = os.time({year = now.year + 1, month = 10, day = 31, hour = 0}) end
		local left = target - os.time()
		if left <= 0 then
			cd.Text = "🎃 СЕГОДНЯ ХЕЛЛОУИН! СЛАДОСТЬ ИЛИ ГАДОСТЬ!"
		else
			cd.Text = string.format("🕯️ До Хеллоуина: %dд %02dч %02dм %02dс", left // 86400, left % 86400 // 3600, left % 3600 // 60, left % 60)
		end
		task.wait(1)
	end
end)

end
do
-- ---------------------------------------------------------------------------
-- Персонаж+: большая хеллоуинская косметика (видна только вам)
-- ---------------------------------------------------------------------------
local H = V.H
local C = {
	pumpkin = false, hat = false, horns = false, wings = false, cape = false, eyes = false, scythe = false,
	ghost = false, skeleton = false, fire = false, smoke = false, sparkles = false, orbit = false,
	nametag = false, footprints = false, outline = false, aura = false, bodyColor = false, material = false,
}
H.C = C
local col = {accent = rgb(255, 120, 20), body = rgb(235, 230, 210), fire = rgb(255, 120, 20)}
local opt = {scale = 1, tag = "🎃 Тыквенный лорд", material = Enum.Material.Neon, orbitCount = 6, flap = 1}
local folder
local anim = {}       -- {weld, baseC0, kind, side}
local orbiters = {}
local mouthParts = {}
local originals = {}  -- part -> {Color, Material}
local hidden = {}     -- части, которые прячем локально
local ghostParts = {}

local function getChar()
	local c = player.Character
	if not c then return end
	return c, c:FindFirstChild("Head"), c:FindFirstChild("HumanoidRootPart"),
		c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"), c:FindFirstChildOfClass("Humanoid")
end

local function mk(base, c0, props)
	local p = Instance.new("Part")
	p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Massless = true; p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in pairs(props) do p[k] = v end
	p.CFrame = base.CFrame * c0
	local w = Instance.new("Weld")
	w.Part0 = base; w.Part1 = p; w.C0 = c0; w.Parent = p
	p.Parent = folder
	return p, w
end

local function restoreBody()
	for part, o in pairs(originals) do
		if part.Parent then part.Color = o[1]; part.Material = o[2] end
	end
	table.clear(originals)
	for part in pairs(hidden) do if part.Parent then part.LocalTransparencyModifier = 0 end end
	table.clear(hidden)
	table.clear(ghostParts)
end

local function bodyParts(char)
	local out = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and not d:IsDescendantOf(folder) then
			table.insert(out, d)
		end
	end
	return out
end

function H.rebuildChar()
	if folder then folder:Destroy() end
	table.clear(anim); table.clear(orbiters); table.clear(mouthParts)
	restoreBody()
	local char, head, root, torso, hum = getChar()
	if not (char and head and root) then return end
	for _, d in ipairs(root:GetChildren()) do
		if d.Name:sub(1, 4) == "VLH_" then d:Destroy() end
	end
	folder = new("Folder", {Name = "VLH_Cosmetics"}, char)
	local s = opt.scale
	local A = col.accent

	-- 🎃 тыквенная голова (смеётся ртом)
	if C.pumpkin then
		local ball = mk(head, CFrame.new(0, 0.15, 0), {Shape = Enum.PartType.Ball, Size = Vector3.new(2.5, 2.2, 2.5) * s, Color = rgb(235, 110, 20)})
		for i = -1, 1, 2 do
			mk(head, CFrame.new(i * 0.55 * s, 0.1, 0) , {Shape = Enum.PartType.Ball, Size = Vector3.new(1.4, 2.1, 2.3) * s, Color = rgb(220, 95, 15)})
		end
		mk(head, CFrame.new(0, 1.25 * s, 0) * CFrame.Angles(0, 0, 0.3), {Size = Vector3.new(0.25, 0.6, 0.25) * s, Color = rgb(60, 110, 30), Material = Enum.Material.Wood})
		for i = -1, 1, 2 do
			mk(head, CFrame.new(i * 0.45 * s, 0.45 * s, -1.17 * s) * CFrame.Angles(0, 0, math.rad(45)),
				{Size = Vector3.new(0.38, 0.38, 0.1) * s, Color = rgb(255, 220, 60), Material = Enum.Material.Neon})
		end
		mk(head, CFrame.new(0, 0.05 * s, -1.2 * s) * CFrame.Angles(0, 0, math.rad(45)), {Size = Vector3.new(0.2, 0.2, 0.1) * s, Color = rgb(255, 220, 60), Material = Enum.Material.Neon})
		for i = -2, 2 do
			local mp, mw = mk(head, CFrame.new(i * 0.28 * s, -0.4 * s, -1.12 * s + math.abs(i) * 0.06),
				{Size = Vector3.new(0.24, 0.22, 0.1) * s, Color = rgb(255, 220, 60), Material = Enum.Material.Neon})
			table.insert(mouthParts, {mp, mw, mw.C0, i})
		end
		new("PointLight", {Color = rgb(255, 150, 40), Range = 10, Brightness = 2}, ball)
		hidden[head] = true
		for _, a in ipairs(char:GetChildren()) do
			if a:IsA("Accessory") then
				local h = a:FindFirstChild("Handle")
				if h then hidden[h] = true end
			end
		end
		local face = head:FindFirstChildOfClass("Decal")
		if face then hidden[face] = true end
	end

	-- 🧙 шляпа ведьмы
	if C.hat then
		local y = (C.pumpkin and 1.3 or 0.75) * s
		local rot = CFrame.Angles(0, 0, math.rad(90))
		mk(head, CFrame.new(0, y, 0) * rot, {Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, 3.4, 3.4) * s, Color = rgb(30, 14, 40)})
		mk(head, CFrame.new(0, y + 0.18 * s, 0) * rot, {Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.25, 1.95, 1.95) * s, Color = A, Material = Enum.Material.Neon})
		local tiers = {{1.8, 0.6}, {1.4, 0.6}, {1.0, 0.55}, {0.65, 0.5}, {0.35, 0.45}}
		local yy, tilt = y + 0.2 * s, 0
		for i, t in ipairs(tiers) do
			yy += t[2] * s * 0.9
			tilt += (i > 2) and 0.18 or 0
			mk(head, CFrame.new(-tilt * 0.6 * s, yy, 0) * CFrame.Angles(0, 0, tilt * 0.6) * rot,
				{Shape = Enum.PartType.Cylinder, Size = Vector3.new(t[2], t[1], t[1]) * s, Color = rgb(30, 14, 40)})
		end
	end

	-- 😈 рога
	if C.horns then
		for i = -1, 1, 2 do
			mk(head, CFrame.new(i * 0.45 * s, 0.75 * s, -0.1) * CFrame.Angles(0, 0, -i * 0.45), {Size = Vector3.new(0.3, 0.7, 0.3) * s, Color = A, Material = Enum.Material.Neon})
			mk(head, CFrame.new(i * 0.68 * s, 1.2 * s, -0.1) * CFrame.Angles(0, 0, -i * 0.9), {Size = Vector3.new(0.18, 0.45, 0.18) * s, Color = A, Material = Enum.Material.Neon})
		end
	end

	-- 👁️ светящиеся глаза
	if C.eyes and not C.pumpkin then
		for i = -1, 1, 2 do
			local e = mk(head, CFrame.new(i * 0.22, 0.15, -0.6), {Shape = Enum.PartType.Ball, Size = Vector3.new(0.22, 0.22, 0.22), Color = A, Material = Enum.Material.Neon})
			new("PointLight", {Color = A, Range = 4, Brightness = 3}, e)
		end
	end

	-- 🦇 крылья летучей мыши (машут)
	if C.wings and torso then
		for i = -1, 1, 2 do
			local c0 = CFrame.new(i * 0.4, 0.5, 0.65)
			local _, w = mk(torso, c0, {Size = Vector3.new(2.8, 1.7, 0.1) * s, Color = rgb(35, 12, 45), Transparency = 0.05})
			table.insert(anim, {w, c0, "wing", i})
			local _, w2 = mk(torso, c0, {Size = Vector3.new(2.6, 0.12, 0.14) * s, Color = A, Material = Enum.Material.Neon})
			table.insert(anim, {w2, c0 * CFrame.new(0, 0.8 * s, 0), "wing", i})
		end
	end

	-- 🧛 плащ
	if C.cape and torso then
		local c0 = CFrame.new(0, 0.9, 0.6)
		local _, w = mk(torso, c0, {Size = Vector3.new(2.1, 3.4, 0.08) * s, Color = rgb(90, 0, 10), Material = Enum.Material.Fabric})
		table.insert(anim, {w, c0, "cape", 0})
	end

	-- ☠️ коса смерти за спиной
	if C.scythe and torso then
		local base = CFrame.new(0.2, 0, 0.75) * CFrame.Angles(0, 0, math.rad(35))
		mk(torso, base, {Size = Vector3.new(0.18, 5, 0.18) * s, Color = rgb(60, 40, 25), Material = Enum.Material.Wood})
		mk(torso, base * CFrame.new(-0.9 * s, 2.4 * s, 0) * CFrame.Angles(0, 0, math.rad(-15)), {Size = Vector3.new(1.9, 0.35, 0.06) * s, Color = rgb(200, 200, 210), Material = Enum.Material.Metal})
		mk(torso, base * CFrame.new(-1.75 * s, 2.05 * s, 0) * CFrame.Angles(0, 0, math.rad(-45)), {Size = Vector3.new(0.6, 0.25, 0.06) * s, Color = A, Material = Enum.Material.Neon})
	end

	-- 🔥 огонь / 💨 дым / ✨ искры
	if C.fire then
		local f = new("Fire", {Color = col.fire, SecondaryColor = rgb(40, 0, 0), Heat = 6, Size = 5}, root)
		f.Name = "VLH_Fire"
	end
	if C.smoke then
		new("Smoke", {Name = "VLH_Smoke", Color = rgb(40, 30, 50), Opacity = 0.25, RiseVelocity = 2, Size = 2}, root)
	end
	if C.sparkles then
		new("Sparkles", {Name = "VLH_Sparkles", SparkleColor = A}, root)
	end
	if C.aura then
		local pe = new("ParticleEmitter", {
			Name = "VLH_Aura", Rate = 18, Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(1, 2),
			SpreadAngle = Vector2.new(180, 180), LightEmission = 1, Color = ColorSequence.new(A),
			Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0)}),
			Transparency = NumberSequence.new(0.3, 1), Texture = "rbxasset://textures/particles/sparkles_main.dds",
		}, root)
		pe.Parent = root
	end

	-- 🍬 орбита из мини-тыкв и конфет
	if C.orbit then
		for i = 1, opt.orbitCount do
			local isP = i % 2 == 1
			local o = new("Part", {
				Name = "VLH_Orb", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false,
				Shape = Enum.PartType.Ball, Size = isP and Vector3.new(0.7, 0.6, 0.7) or Vector3.new(0.45, 0.45, 0.45),
				Color = isP and rgb(240, 110, 20) or A, Material = isP and Enum.Material.SmoothPlastic or Enum.Material.Neon,
			}, folder)
			table.insert(orbiters, {o, i / opt.orbitCount * math.pi * 2})
		end
	end

	-- 🏷️ своя надпись над головой
	if C.nametag then
		local bb = new("BillboardGui", {
			Name = "VLH_Tag", Size = UDim2.fromOffset(260, 50), StudsOffset = Vector3.new(0, (C.hat and 4.6 or 2.8) * s, 0),
			AlwaysOnTop = true, LightInfluence = 0, Adornee = head,
		}, folder)
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = opt.tag, Font = H.SCARY_FONT, TextScaled = true,
			TextColor3 = A, TextStrokeTransparency = 0, TextStrokeColor3 = rgb(0, 0, 0),
		}, bb)
	end

	-- ✨ обводка
	if C.outline or C.ghost or C.skeleton then
		new("Highlight", {
			Name = "VLH_Outline", Adornee = char, FillTransparency = C.ghost and 0.7 or 1,
			FillColor = rgb(200, 240, 255), OutlineColor = C.skeleton and rgb(0, 0, 0) or (C.ghost and rgb(200, 240, 255) or A),
			DepthMode = Enum.HighlightDepthMode.Occluded,
		}, folder)
	end

	-- цвет / материал тела, скелет, призрак
	for _, part in ipairs(bodyParts(char)) do
		local isAcc = part.Parent and part.Parent:IsA("Accessory")
		if not isAcc and (C.bodyColor or C.material or C.skeleton) then
			originals[part] = {part.Color, part.Material}
			if C.skeleton then
				part.Color = rgb(235, 230, 210); part.Material = Enum.Material.SmoothPlastic
			end
			if C.bodyColor then part.Color = col.body end
			if C.material then part.Material = opt.material end
		end
		if C.ghost then ghostParts[part] = true end
	end
end

-- анимации косметики
local t, footAcc = 0, 0
RunService.RenderStepped:Connect(function(dt)
	t += dt
	local char, head, root = getChar()
	if not char then return end
	for part in pairs(hidden) do if part.Parent then part.LocalTransparencyModifier = 1 end end
	for part in pairs(ghostParts) do if part.Parent and not hidden[part] then part.LocalTransparencyModifier = 0.6 end end
	for _, m in ipairs(mouthParts) do
		local laugh = math.abs(math.sin(t * 9 + m[4] * 0.6))
		m[2].C0 = m[3] * CFrame.new(0, -laugh * 0.12, 0)
		m[1].Size = Vector3.new(m[1].Size.X, (0.16 + laugh * 0.22) * opt.scale, m[1].Size.Z)
	end
	for _, a in ipairs(anim) do
		if a[3] == "wing" then
			local ang = 0.35 + math.sin(t * 5 * opt.flap) * 0.45
			a[1].C0 = a[2] * CFrame.Angles(0, a[4] * ang, 0) * CFrame.new(a[4] * 1.35 * opt.scale, 0, 0)
		elseif a[3] == "cape" then
			local v = root and root.AssemblyLinearVelocity.Magnitude or 0
			local sway = math.clamp(v / 30, 0, 0.9) + math.sin(t * 3) * 0.05
			a[1].C0 = a[2] * CFrame.Angles(sway, 0, 0) * CFrame.new(0, -1.7 * opt.scale, 0)
		end
	end
	if root then
		for i, o in ipairs(orbiters) do
			local a = t * 1.8 + o[2]
			o[1].CFrame = CFrame.new(root.Position + Vector3.new(math.cos(a) * 3.2, math.sin(t * 2 + i) * 0.6 + 0.5, math.sin(a) * 3.2)) * CFrame.Angles(0, -a, 0)
		end
		if C.footprints then
			footAcc += dt
			local vel = root.AssemblyLinearVelocity
			if footAcc > 0.22 and Vector3.new(vel.X, 0, vel.Z).Magnitude > 4 then
				footAcc = 0
				local fp = new("Part", {
					Name = "VLH_Foot", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false,
					Size = Vector3.new(0.7, 0.05, 1), Color = col.accent, Material = Enum.Material.Neon,
					CFrame = root.CFrame * CFrame.new((math.floor(t * 10) % 2 == 0) and 0.5 or -0.5, -2.95, 0),
				}, workspace)
				tw(fp, 2.5, {Transparency = 1})
				Debris:AddItem(fp, 2.6)
			end
		end
	end
end)

player.CharacterAdded:Connect(function(c)
	c:WaitForChild("HumanoidRootPart", 6)
	c:WaitForChild("Head", 6)
	task.wait(0.6)
	H.rebuildChar()
end)

-- интерфейс
local p = V.pHChar
local ids = {}
local function tog(key, title)
	ids[key] = H.toggle(p, title, C[key], function(v) C[key] = v; H.rebuildChar() end)
end
addLabel(p, "🧟 ХЕЛЛОУИН-КОСМЕТИКА (видна только вам)")
addLabel(p, "ГОЛОВА")
tog("pumpkin", "🎃 Тыквенная голова (смеётся)")
tog("hat", "🧙 Шляпа ведьмы")
tog("horns", "😈 Дьявольские рога")
tog("eyes", "👁️ Светящиеся глаза")
tog("nametag", "🏷️ Страшная надпись над головой")
local tagBox = V.addInput(p, "Текст надписи (Enter — применить)", opt.tag, 36, false)
tagBox.FocusLost:Connect(function()
	opt.tag = tagBox.Text ~= "" and tagBox.Text or opt.tag
	if C.nametag then H.rebuildChar() end
end)
addLabel(p, "ТЕЛО")
tog("wings", "🦇 Крылья летучей мыши (машут)")
tog("cape", "🧛 Плащ вампира (развевается)")
tog("scythe", "☠️ Коса смерти за спиной")
tog("skeleton", "💀 Режим скелета")
tog("ghost", "👻 Режим призрака (полупрозрачный)")
tog("bodyColor", "🎨 Свой цвет тела")
tog("material", "🧱 Свой материал тела")
local mats = {Enum.Material.Neon, Enum.Material.ForceField, Enum.Material.Glass, Enum.Material.Foil, Enum.Material.Slate, Enum.Material.Marble, Enum.Material.SmoothPlastic}
local matI = 1
local matBtn
matBtn = addButton(p, "🧱 Материал: Neon (нажмите, чтобы сменить)", function()
	matI = matI % #mats + 1
	opt.material = mats[matI]
	matBtn.Text = "  🧱 Материал: " .. opt.material.Name .. " (нажмите, чтобы сменить)"
	if C.material then H.rebuildChar() end
end)
addLabel(p, "ЭФФЕКТЫ")
tog("fire", "🔥 Проклятый огонь")
tog("smoke", "💨 Тёмный дым")
tog("sparkles", "✨ Искры")
tog("aura", "🌀 Призрачная аура")
tog("orbit", "🍬 Орбита из тыкв и конфет")
tog("footprints", "👣 Светящиеся следы")
tog("outline", "🖊️ Цветная обводка")
addLabel(p, "ЦВЕТА И РАЗМЕР")
H.colorRow(p, "🎨 Цвет косметики (рога, глаза, надпись, следы)", function(c) col.accent = c; H.rebuildChar() end)
H.colorRow(p, "🧍 Цвет тела", function(c) col.body = c; if C.bodyColor then H.rebuildChar() end end)
H.colorRow(p, "🔥 Цвет огня", function(c) col.fire = c; if C.fire then H.rebuildChar() end end)
addSlider(p, "Размер косметики", 0.6, 1.6, 1, 1, function(v) opt.scale = v; H.rebuildChar() end)
addSlider(p, "Скорость маха крыльев", 0.2, 3, 1, 1, function(v) opt.flap = v end)
addSlider(p, "Кол-во предметов на орбите", 2, 12, 6, 0, function(v) opt.orbitCount = v; if C.orbit then H.rebuildChar() end end)

addLabel(p, "ГОТОВЫЕ ОБРАЗЫ")
local function preset(on)
	for k, id in pairs(ids) do H.setToggle(id, on[k] == true) end
	H.rebuildChar()
end
addButton(p, "🎃 Джек-фонарь", function() col.accent = rgb(255, 120, 20); preset({pumpkin = true, cape = true, fire = true, nametag = true, orbit = true}) end)
addButton(p, "🧛 Вампир", function() col.accent = rgb(190, 10, 20); preset({cape = true, eyes = true, wings = true, outline = true, smoke = true}) end)
addButton(p, "🧙 Ведьма", function() col.accent = rgb(120, 255, 60); preset({hat = true, sparkles = true, aura = true, footprints = true}) end)
addButton(p, "💀 Скелет с косой", function() col.accent = rgb(140, 50, 220); preset({skeleton = true, scythe = true, eyes = true, smoke = true}) end)
addButton(p, "👻 Призрак", function() col.accent = rgb(190, 235, 255); preset({ghost = true, aura = true, eyes = true}) end)
addButton(p, "😈 Демон", function() col.accent = rgb(255, 40, 20); preset({horns = true, wings = true, fire = true, eyes = true, footprints = true}) end)
addButton(p, "❌ Снять всю косметику", function() preset({}) end)

end
do
-- ---------------------------------------------------------------------------
-- Редактор пиксельного курсора
-- ---------------------------------------------------------------------------
local H = V.H
local N = 16
local grid = {}            -- grid[y][x] = Color3 | nil
local function clearGrid() for y = 1, N do grid[y] = {} end end
clearGrid()
local saved = {}           -- {name, data}
local cur = {color = rgb(255, 120, 20), tool = "brush", mirror = false, px = 2, center = false, on = false}

local CH = {
	K = rgb(0, 0, 0), O = rgb(255, 120, 20), W = rgb(240, 236, 220), R = rgb(200, 15, 25), G = rgb(110, 230, 60),
	Y = rgb(255, 215, 50), P = rgb(140, 50, 220), D = rgb(40, 20, 50),
}
local PRESETS = {
	{"🎃 Тыквенная стрелка", false, {
		"K", "KK", "KOK", "KOOK", "KOOOK", "KOYOOK", "KOOOOOK", "KOYOOOOK", "KOOOOOOOK", "KOOOOOOOOK",
		"KOOOOOKKKKK", "KOOKOOK", "KOK.KOOK", "KK..KOOK", "K....KOOK", ".....KKK",
	}},
	{"💀 Череп", true, {
		"....KKKKKKKK", "...KWWWWWWWWK", "..KWWWWWWWWWWK", ".KWWWWWWWWWWWWK", ".KWWKKKWWKKKWWK", ".KWKKRKWWKRKKWK",
		".KWKKKKWWKKKKWK", ".KWWKKWWWWKKWWK", ".KWWWWWKKWWWWWK", "..KWWWWKKWWWWK", "...KWWWWWWWWK", "...KWKWKWKWWK",
		"...KWKWKWKWK", "....KKKKKKKK",
	}},
	{"👻 Призрак", true, {
		".....KKKKKK", "....KWWWWWWK", "...KWWWWWWWWK", "..KWWKKWWKKWWK", "..KWWKKWWKKWWK", "..KWWWWWWWWWWK",
		"..KWWWWKKWWWWK", "..KWWWWKKWWWWK", "..KWWWWWWWWWWK", "..KWWWWWWWWWWK", "..KWWWWWWWWWWK", "..KWKWWKWWKWWK",
		"..KK.KK.KK.KK",
	}},
	{"🪓 Коса", false, {
		"..KKKKKK", ".KWWWWWWKK", "KWWWWWWWWWK", ".KKKKKKRWWK", "......KR.KWK", "......KR..KK", ".....KR", ".....KR",
		"....KR", "....KR", "...KR", "...KR", "..KR", "..KR", ".KR", ".K",
	}},
}

local function encode()
	local out = {}
	for y = 1, N do
		for x = 1, N do
			local c = grid[y][x]
			table.insert(out, c and c:ToHex() or "------")
		end
	end
	return "PIX1:" .. table.concat(out)
end
local function decode(s)
	s = tostring(s):gsub("%s", "")
	if s:sub(1, 5) ~= "PIX1:" or #s < 5 + N * N * 6 then return false end
	clearGrid()
	local i = 6
	for y = 1, N do
		for x = 1, N do
			local h = s:sub(i, i + 5)
			if h ~= "------" then
				local ok, c = pcall(Color3.fromHex, h)
				if ok then grid[y][x] = c end
			end
			i += 6
		end
	end
	return true
end
local function loadPattern(rows)
	clearGrid()
	for y, row in ipairs(rows) do
		for x = 1, math.min(#row, N) do
			local ch = row:sub(x, x)
			if CH[ch] then grid[y][x] = CH[ch] end
		end
	end
end

-- сам курсор
local PC = new("Frame", {Size = UDim2.fromOffset(N * 2, N * 2), BackgroundTransparency = 1, ZIndex = 3000, Visible = false}, gui)
local pcPixels = {}
local function renderCursor()
	for _, f in ipairs(pcPixels) do f:Destroy() end
	table.clear(pcPixels)
	local s = cur.px
	PC.Size = UDim2.fromOffset(N * s, N * s)
	PC.AnchorPoint = cur.center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0)
	for y = 1, N do
		for x = 1, N do
			local c = grid[y][x]
			if c then
				table.insert(pcPixels, new("Frame", {
					Size = UDim2.fromOffset(s, s), Position = UDim2.fromOffset((x - 1) * s, (y - 1) * s),
					BackgroundColor3 = c, BorderSizePixel = 0, ZIndex = 3001,
				}, PC))
			end
		end
	end
end
function H.setPixelCursor(on)
	cur.on = on
	PC.Visible = on
	if on then
		pcall(V.setCursorEnabled, false)
		renderCursor()
	else
		UIS.MouseIconEnabled = true
	end
end
RunService.RenderStepped:Connect(function()
	if not cur.on then return end
	UIS.MouseIconEnabled = false
	local m = UIS:GetMouseLocation()
	PC.Position = UDim2.fromOffset(m.X, m.Y)
end)

-- окно редактора
local ED = new("Frame", {
	Size = UDim2.fromOffset(560, 440), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Visible = false, ZIndex = 1500, Active = true,
}, gui)
bind(ED, "BackgroundColor3", "bg"); corner(ED, 16)
local edStroke = new("UIStroke", {Thickness = 2}, ED); bind(edStroke, "Color", "accent")
local edHead = new("TextLabel", {
	Size = UDim2.new(1, -60, 0, 44), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
	Text = "🖌️ РЕДАКТОР КУРСОРА", Font = H.SCARY_FONT, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1502,
}, ED); bind(edHead, "TextColor3", "accent")
local edClose = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -40, 0, 8), Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12,
	BackgroundColor3 = rgb(200, 30, 30), TextColor3 = rgb(255, 255, 255), ZIndex = 1502,
}, ED); corner(edClose, 8)
edClose.Activated:Connect(function() ED.Visible = false end)
draggable(ED, edHead)

local CELL = 22
local board = new("Frame", {
	Size = UDim2.fromOffset(N * CELL, N * CELL), Position = UDim2.fromOffset(16, 52), BackgroundColor3 = rgb(40, 40, 46), BorderSizePixel = 0, ZIndex = 1501,
}, ED)
local cells = {}
local painting = false
local redrawCells, applyAt
for y = 1, N do
	cells[y] = {}
	for x = 1, N do
		local checker = ((x + y) % 2 == 0) and rgb(58, 58, 66) or rgb(46, 46, 52)
		local c = new("TextButton", {
			Size = UDim2.fromOffset(CELL - 1, CELL - 1), Position = UDim2.fromOffset((x - 1) * CELL, (y - 1) * CELL),
			BackgroundColor3 = checker, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 1502,
		}, board)
		c:SetAttribute("checker", checker)
		c.MouseButton1Down:Connect(function() painting = true; applyAt(x, y) end)
		c.MouseEnter:Connect(function() if painting then applyAt(x, y) end end)
		cells[y][x] = c
	end
end
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then painting = false end
end)

local preview = new("Frame", {Size = UDim2.fromOffset(N * 3, N * 3), Position = UDim2.fromOffset(16 + N * CELL + 16, 52), BackgroundColor3 = rgb(90, 90, 100), BorderSizePixel = 0, ZIndex = 1501}, ED)
corner(preview, 4)
local prevPix = {}
function redrawCells()
	for _, f in ipairs(prevPix) do f:Destroy() end
	table.clear(prevPix)
	for y = 1, N do
		for x = 1, N do
			local g = grid[y][x]
			cells[y][x].BackgroundColor3 = g or cells[y][x]:GetAttribute("checker")
			if g then
				table.insert(prevPix, new("Frame", {Size = UDim2.fromOffset(3, 3), Position = UDim2.fromOffset((x - 1) * 3, (y - 1) * 3), BackgroundColor3 = g, BorderSizePixel = 0, ZIndex = 1502}, preview))
			end
		end
	end
end

local function setPix(x, y, c)
	if x < 1 or x > N or y < 1 or y > N then return end
	grid[y][x] = c
	if cur.mirror then grid[y][N + 1 - x] = c end
end
local function fill(x, y, target, c)
	local stack, seen = {{x, y}}, {}
	while #stack > 0 do
		local p = table.remove(stack)
		local px, py = p[1], p[2]
		local key = py * 100 + px
		if px >= 1 and px <= N and py >= 1 and py <= N and not seen[key] and grid[py][px] == target then
			seen[key] = true
			grid[py][px] = c
			table.insert(stack, {px + 1, py}); table.insert(stack, {px - 1, py})
			table.insert(stack, {px, py + 1}); table.insert(stack, {px, py - 1})
		end
	end
end
local curSwatch
function applyAt(x, y)
	if cur.tool == "brush" then setPix(x, y, cur.color)
	elseif cur.tool == "erase" then setPix(x, y, nil)
	elseif cur.tool == "fill" then painting = false; if grid[y][x] ~= cur.color then fill(x, y, grid[y][x], cur.color) end
	elseif cur.tool == "pick" then
		painting = false
		if grid[y][x] then cur.color = grid[y][x]; curSwatch.BackgroundColor3 = cur.color end
		cur.tool = "brush"
	end
	redrawCells()
end

-- правая панель
local side = new("Frame", {
	Size = UDim2.new(1, -(16 + N * CELL + 32), 1, -120), Position = UDim2.fromOffset(16 + N * CELL + 16, 52 + N * 3 + 10),
	BackgroundTransparency = 1, ZIndex = 1501,
}, ED)
new("UIListLayout", {Padding = UDim.new(0, 6)}, side)
local palette = new("Frame", {Size = UDim2.new(1, 0, 0, 78), BackgroundTransparency = 1, ZIndex = 1501}, side)
new("UIGridLayout", {CellSize = UDim2.fromOffset(22, 22), CellPadding = UDim2.fromOffset(4, 4)}, palette)
local palColors = {
	rgb(0, 0, 0), rgb(255, 255, 255), rgb(240, 236, 220), rgb(128, 128, 128), rgb(255, 120, 20), rgb(255, 215, 50),
	rgb(200, 15, 25), rgb(110, 0, 10), rgb(110, 230, 60), rgb(30, 110, 30), rgb(140, 50, 220), rgb(60, 20, 90),
	rgb(80, 160, 255), rgb(0, 240, 255), rgb(255, 100, 200), rgb(120, 70, 30),
}
for _, c in ipairs(palColors) do
	local b = new("TextButton", {BackgroundColor3 = c, Text = "", ZIndex = 1502}, palette)
	corner(b, 5); new("UIStroke", {Color = rgb(0, 0, 0), Thickness = 1}, b)
	b.Activated:Connect(function() cur.color = c; curSwatch.BackgroundColor3 = c; if cur.tool ~= "fill" then cur.tool = "brush" end end)
end
local function sideBtn(text, cb)
	local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 26), Text = text, Font = Enum.Font.GothamSemibold, TextSize = 11, ZIndex = 1502}, side)
	bind(b, "BackgroundColor3", "btn"); bind(b, "TextColor3", "text"); corner(b, 7)
	b.Activated:Connect(function() pcall(cb, b) end)
	return b
end
local row = new("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, ZIndex = 1501}, side)
curSwatch = new("Frame", {Size = UDim2.fromOffset(26, 26), BackgroundColor3 = cur.color, ZIndex = 1502}, row); corner(curSwatch, 6)
local rgbBox = new("TextBox", {
	Size = UDim2.new(1, -32, 1, 0), Position = UDim2.fromOffset(32, 0), PlaceholderText = "R,G,B или #hex", Text = "",
	Font = Enum.Font.Code, TextSize = 11, ClearTextOnFocus = false, ZIndex = 1502,
}, row)
bind(rgbBox, "BackgroundColor3", "btn"); bind(rgbBox, "TextColor3", "text"); corner(rgbBox, 6)
rgbBox.FocusLost:Connect(function()
	local t = rgbBox.Text
	local c
	if t:match("^#?%x%x%x%x%x%x$") then local ok, r = pcall(Color3.fromHex, t:gsub("#", "")); if ok then c = r end
	else c = V.parseRgb and V.parseRgb(t, nil) end
	if c then cur.color = c; curSwatch.BackgroundColor3 = c end
end)
local toolBtns = {}
local function setTool(t)
	cur.tool = t
	for k, b in pairs(toolBtns) do b.TextColor3 = (k == t) and Theme.accent or Theme.text end
end
toolBtns.brush = sideBtn("🖌️ Кисть", function() setTool("brush") end)
toolBtns.erase = sideBtn("🧽 Ластик", function() setTool("erase") end)
toolBtns.fill = sideBtn("🪣 Заливка", function() setTool("fill") end)
toolBtns.pick = sideBtn("💧 Пипетка", function() setTool("pick") end)
sideBtn("🪞 Зеркало: выкл", function(b) cur.mirror = not cur.mirror; b.Text = "🪞 Зеркало: " .. (cur.mirror and "вкл" or "выкл") end)
sideBtn("🗑️ Очистить", function() clearGrid(); redrawCells() end)
setTool("brush")

-- нижняя панель: имя + сохранить
local nameBox = new("TextBox", {
	Size = UDim2.fromOffset(200, 32), Position = UDim2.new(0, 16, 1, -42), PlaceholderText = "Название курсора", Text = "",
	Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, ZIndex = 1502,
}, ED)
bind(nameBox, "BackgroundColor3", "btn"); bind(nameBox, "TextColor3", "text"); corner(nameBox, 8)
local saveBtn = new("TextButton", {
	Size = UDim2.fromOffset(150, 32), Position = UDim2.new(0, 226, 1, -42), Text = "💾 СОХРАНИТЬ", Font = Enum.Font.GothamBlack,
	TextSize = 13, TextColor3 = rgb(255, 255, 255), ZIndex = 1502,
}, ED)
bind(saveBtn, "BackgroundColor3", "accent"); corner(saveBtn, 8)
local centerBtn = new("TextButton", {
	Size = UDim2.fromOffset(150, 32), Position = UDim2.new(0, 386, 1, -42), Text = "🎯 Кончик: угол", Font = Enum.Font.GothamSemibold,
	TextSize = 11, ZIndex = 1502,
}, ED)
bind(centerBtn, "BackgroundColor3", "btn"); bind(centerBtn, "TextColor3", "text"); corner(centerBtn, 8)
centerBtn.Activated:Connect(function()
	cur.center = not cur.center
	centerBtn.Text = "🎯 Кончик: " .. (cur.center and "центр" or "угол")
end)

-- вкладка
local p = V.pPix
addLabel(p, "🖌️ СВОЙ ПИКСЕЛЬНЫЙ КУРСОР 16×16")
addButton(p, "🎨 Открыть режим создания", function()
	ED.Visible = true
	redrawCells()
	local sc = ED:FindFirstChildOfClass("UIScale") or new("UIScale", {}, ED)
	sc.Scale = 0.85; tw(sc, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
end)
local pixTog = H.toggle(p, "🖱️ Использовать пиксельный курсор", false, function(v) H.setPixelCursor(v) end)
addSlider(p, "Размер пикселя", 1, 4, 2, 0, function(v) cur.px = v; if cur.on then renderCursor() end end)
addLabel(p, "ГОТОВЫЕ ХЕЛЛОУИН-КУРСОРЫ (можно открыть и дорисовать)")
for _, pr in ipairs(PRESETS) do
	addButton(p, pr[1], function()
		loadPattern(pr[3]); cur.center = pr[2]
		centerBtn.Text = "🎯 Кончик: " .. (cur.center and "центр" or "угол")
		redrawCells()
		H.setToggle(pixTog, true); renderCursor()
	end)
end
addLabel(p, "МОИ СОХРАНЁННЫЕ КУРСОРЫ")
local savedHolder = new("Frame", {Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 13}, p)
new("UIListLayout", {Padding = UDim.new(0, 6)}, savedHolder)
local emptyLbl = addLabel(savedHolder, "Пока пусто — нарисуйте и нажмите «Сохранить»")
local codeBox = V.addInput(p, "Код курсора (PIX1:...) — можно скопировать другу", "", 60, true)
codeBox.TextSize = 9
addButton(p, "📤 Получить код текущего курсора", function() codeBox.Text = encode() end)
addButton(p, "📥 Загрузить курсор из кода", function()
	if decode(codeBox.Text) then redrawCells(); H.setToggle(pixTog, true); renderCursor(); notify("🖌️ КУРСОР", "Загружен из кода")
	else notify("🖌️ КУРСОР", "Неверный код") end
end)

local function addSavedButton(entry)
	emptyLbl.Visible = false
	addButton(savedHolder, "🖱️ " .. entry.name, function()
		decode(entry.data); cur.center = entry.center
		redrawCells(); H.setToggle(pixTog, true); renderCursor()
		notify("🖌️ КУРСОР", "Включён: " .. entry.name)
	end)
end
saveBtn.Activated:Connect(function()
	local any = false
	for y = 1, N do for x = 1, N do if grid[y][x] then any = true end end end
	if not any then notify("🖌️ КУРСОР", "Сначала нарисуйте что-нибудь") return end
	local name = nameBox.Text ~= "" and nameBox.Text or ("Курсор #" .. (#saved + 1))
	local entry = {name = name, data = encode(), center = cur.center}
	table.insert(saved, entry)
	addSavedButton(entry)
	H.setToggle(pixTog, true); renderCursor()
	ED.Visible = false
	notify("💾 СОХРАНЕНО", name .. " — курсор включён")
end)

-- стартовый рисунок в редакторе
loadPattern(PRESETS[1][3])

end
do
-- ---------------------------------------------------------------------------
-- Режим стримера: скрытый ввод чата, скрытие своих сообщений и ника
-- ---------------------------------------------------------------------------
local H = V.H
local TCS = game:GetService("TextChatService")
local newChat = TCS.ChatVersion == Enum.ChatVersion.TextChatService
local ST = {on = false, hideOwn = false, noBubbles = false, hideChat = false, mask = "dots"}
H.ST = ST

local bar = new("Frame", {
	Size = UDim2.fromOffset(420, 42), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -70),
	Visible = false, ZIndex = 400, BackgroundTransparency = 0.05,
}, gui)
bind(bar, "BackgroundColor3", "header"); corner(bar, 12)
local bs = new("UIStroke", {Thickness = 1.5}, bar); bind(bs, "Color", "accent")
local lock = new("TextLabel", {Size = UDim2.fromOffset(36, 42), BackgroundTransparency = 1, Text = "🔒", TextSize = 18, ZIndex = 401}, bar)
local box = new("TextBox", {
	Size = UDim2.new(1, -46, 1, -10), Position = UDim2.fromOffset(38, 5), BackgroundTransparency = 1, Text = "",
	PlaceholderText = "Режим стримера: нажмите / чтобы писать (текст скрыт)", Font = Enum.Font.Gotham,
	TextSize = 13, TextTransparency = 1, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 401,
}, bar)
bind(box, "PlaceholderColor3", "sub")
local mask = new("TextLabel", {
	Size = box.Size, Position = box.Position, BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamBold, TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 402, TextTruncate = Enum.TextTruncate.AtEnd,
}, bar)
bind(mask, "TextColor3", "text")
box:GetPropertyChangedSignal("Text"):Connect(function()
	local n = utf8.len(box.Text) or #box.Text
	if n == 0 then mask.Text = ""
	elseif ST.mask == "dots" then mask.Text = string.rep("•", math.min(n, 60))
	else mask.Text = "🎃 печатаю... (" .. n .. ")" end
end)
local function send(text)
	if text:match("^%s*$") then return end
	if not newChat then notify("🎥 СТРИМЕР", "Отправка работает только с новым чатом (TextChatService)") return end
	local ok, err = pcall(function()
		local ch = TCS:FindFirstChild("TextChannels") and TCS.TextChannels:FindFirstChild("RBXGeneral")
		ch:SendAsync(text)
	end)
	if not ok then notify("🎥 СТРИМЕР", "Не удалось отправить: " .. tostring(err)) end
end
box.FocusLost:Connect(function(enter)
	if enter then send(box.Text) end
	box.Text = ""
	tw(bs, 0.2, {Thickness = 1.5})
end)
box.Focused:Connect(function() tw(bs, 0.2, {Thickness = 3}) end)
UIS.InputBegan:Connect(function(i, gpe)
	if not ST.on or gpe then return end
	if i.KeyCode == Enum.KeyCode.Slash then
		task.defer(function() box:CaptureFocus(); box.Text = "" end)
	end
end)

local function applyStreamer()
	bar.Visible = ST.on
	pcall(function() TCS.ChatInputBarConfiguration.Enabled = not ST.on end)
	pcall(function() TCS.BubbleChatConfiguration.Enabled = not ST.noBubbles end)
	pcall(function() TCS.ChatWindowConfiguration.Enabled = not ST.hideChat end)
	if newChat then
		pcall(function()
			if ST.hideOwn then
				TCS.OnIncomingMessage = function(msg)
					local props = Instance.new("TextChatMessageProperties")
					if msg.TextSource and msg.TextSource.UserId == player.UserId then
						props.Text = "🔒 [скрыто режимом стримера]"
						props.PrefixText = "<font color='#ff7a14'>[Стример]</font>"
					end
					return props
				end
			else
				TCS.OnIncomingMessage = nil
			end
		end)
	end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.DisplayDistanceType = H.hideName and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer end
	if V.H.refreshBoard then V.H.refreshBoard() end
end
H.applyStreamer = applyStreamer
player.CharacterAdded:Connect(function() task.wait(1); applyStreamer() end)

local p = V.pStream
addLabel(p, "🎥 РЕЖИМ СТРИМЕРА")
addToggle(p, "🔒 Скрытый ввод чата (зрители не видят, что вы пишете)", false, function(v)
	ST.on = v; applyStreamer()
	if v then notify("🎥 СТРИМЕР", "Нажмите / чтобы писать. Текст скрыт, Enter — отправить") end
end)
addButton(p, "👁️ Маска ввода: точки ••• / «печатаю...»", function()
	ST.mask = ST.mask == "dots" and "typing" or "dots"
	notify("🎥 СТРИМЕР", ST.mask == "dots" and "Маска: точки" or "Маска: «печатаю...»")
end)
addToggle(p, "💬 Скрывать мои сообщения в окне чата (у себя на экране)", false, function(v) ST.hideOwn = v; applyStreamer() end)
addToggle(p, "🗨️ Убрать пузыри чата над головами", false, function(v) ST.noBubbles = v; applyStreamer() end)
addToggle(p, "🙈 Спрятать окно чата целиком", false, function(v) ST.hideChat = v; applyStreamer() end)
addToggle(p, "🪪 Скрыть мой ник (таб, над головой, история)", false, function(v) H.hideName = v; applyStreamer() end)
addLabel(p, "Важно: само отправленное сообщение другие игроки увидят как обычно.")

end
do
-- ---------------------------------------------------------------------------
-- Хеллоуинский таб игроков «ДОСКА ДУШ» (заменяет оригинальный)
-- ---------------------------------------------------------------------------
local H = V.H
local Players = game:GetService("Players")
local B = {enabled = true, open = true, hideCore = true}
H.B = B

local panel = new("Frame", {
	Size = UDim2.fromOffset(300, 80), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
	BackgroundColor3 = rgb(12, 4, 6), BackgroundTransparency = 0.08, ZIndex = 300, ClipsDescendants = true,
}, gui)
corner(panel, 14)
local pStroke = new("UIStroke", {Thickness = 2, Color = rgb(255, 110, 10)}, panel)
new("UIGradient", {Rotation = 90, Color = ColorSequence.new(rgb(60, 14, 8), rgb(10, 2, 6))}, panel)
local head = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "💀 ДОСКА ДУШ 💀", Font = H.SCARY_FONT,
	TextSize = 26, TextColor3 = rgb(255, 120, 20), ZIndex = 302,
}, panel)
new("UIStroke", {Color = rgb(80, 0, 0), Thickness = 1.5}, head)
local sub = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16), Position = UDim2.fromOffset(8, 34), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = rgb(180, 120, 95), ZIndex = 302, TextXAlignment = Enum.TextXAlignment.Left,
}, panel)
local statHdr = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16), Position = UDim2.fromOffset(8, 34), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = rgb(255, 160, 80), ZIndex = 302, TextXAlignment = Enum.TextXAlignment.Right,
}, panel)
local list = new("Frame", {Size = UDim2.new(1, -12, 1, -58), Position = UDim2.fromOffset(6, 54), BackgroundTransparency = 1, ZIndex = 301}, panel)
new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, list)
-- паутина в углу
new("TextLabel", {Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "🕸️", TextSize = 24, TextTransparency = 0.3, ZIndex = 303}, panel)
new("TextLabel", {Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, Text = "🎃", TextSize = 20, ZIndex = 303}, panel)

local ROW = 30
local rankIcons = {"👑", "💀", "☠️"}
local rowPool = {}

local function statsOf(plr)
	local out = {}
	local ls = plr:FindFirstChild("leaderstats")
	if ls then
		for _, v in ipairs(ls:GetChildren()) do
			if v:IsA("ValueBase") and #out < 3 then table.insert(out, {v.Name, v.Value}) end
		end
	end
	return out
end
local function fmt(v)
	if type(v) == "number" then
		if math.abs(v) >= 1e6 then return string.format("%.1fM", v / 1e6) end
		if math.abs(v) >= 1e3 then return string.format("%.1fK", v / 1e3) end
		return tostring(math.floor(v * 10 + 0.5) / 10)
	end
	return tostring(v)
end

local function getRow(i)
	local r = rowPool[i]
	if r then return r end
	local b = new("TextButton", {Size = UDim2.new(1, 0, 0, ROW), BackgroundColor3 = rgb(40, 12, 10), BackgroundTransparency = 0.3, Text = "", AutoButtonColor = false, ZIndex = 302, LayoutOrder = i}, list)
	corner(b, 8)
	local st = new("UIStroke", {Thickness = 1, Color = rgb(255, 110, 10), Transparency = 1}, b)
	local rank = new("TextLabel", {Size = UDim2.fromOffset(30, ROW), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = rgb(255, 200, 120), ZIndex = 303}, b)
	local av = new("ImageLabel", {Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(30, 4), BackgroundColor3 = rgb(20, 6, 6), ZIndex = 303}, b)
	corner(av, 11)
	local nm = new("TextLabel", {
		Size = UDim2.new(1, -170, 1, 0), Position = UDim2.fromOffset(58, 0), BackgroundTransparency = 1, Font = Enum.Font.Fantasy,
		TextSize = 14, TextColor3 = rgb(255, 236, 215), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 303,
	}, b)
	local stats = new("TextLabel", {
		Size = UDim2.fromOffset(110, ROW), Position = UDim2.new(1, -116, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Code,
		TextSize = 12, TextColor3 = rgb(255, 150, 60), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 303,
	}, b)
	r = {b = b, st = st, rank = rank, av = av, nm = nm, stats = stats}
	b.MouseEnter:Connect(function() tw(b, 0.15, {BackgroundTransparency = 0.05}) end)
	b.MouseLeave:Connect(function() tw(b, 0.15, {BackgroundTransparency = 0.3}) end)
	b.Activated:Connect(function()
		if r.plr and r.plr.Parent and V.openPlayerCard then pcall(V.openPlayerCard, r.plr) end
	end)
	rowPool[i] = r
	return r
end

local thumbs = {}
local function refresh()
	panel.Visible = B.enabled and B.open
	if not panel.Visible then return end
	local plrs = Players:GetPlayers()
	local firstStat
	for _, pl in ipairs(plrs) do
		local s = statsOf(pl)
		if #s > 0 then firstStat = s; break end
	end
	table.sort(plrs, function(a, b)
		local sa, sb = statsOf(a), statsOf(b)
		local va = sa[1] and tonumber(sa[1][2]) or 0
		local vb = sb[1] and tonumber(sb[1][2]) or 0
		if va ~= vb then return va > vb end
		return a.DisplayName:lower() < b.DisplayName:lower()
	end)
	local names = {}
	if firstStat then for _, s in ipairs(firstStat) do table.insert(names, s[1]) end end
	statHdr.Text = table.concat(names, " · ")
	sub.Text = "👻 Душ в ловушке: " .. #plrs .. " / " .. Players.MaxPlayers
	for i, pl in ipairs(plrs) do
		local r = getRow(i)
		r.plr = pl
		r.b.Visible = true
		r.rank.Text = rankIcons[i] or ("#" .. i)
		local me = pl == player
		r.nm.Text = (me and "🎃 " or "") .. H.name(pl)
		r.nm.TextColor3 = me and rgb(255, 160, 40) or rgb(255, 236, 215)
		r.st.Transparency = me and 0.1 or 1
		r.b.BackgroundColor3 = me and rgb(70, 22, 8) or (i % 2 == 0 and rgb(32, 8, 10) or rgb(44, 14, 10))
		local vals = {}
		for _, s in ipairs(statsOf(pl)) do table.insert(vals, fmt(s[2])) end
		r.stats.Text = #vals > 0 and table.concat(vals, " · ") or "🕯️"
		if me and H.hideName then
			r.av.Image = ""
		elseif thumbs[pl.UserId] then
			r.av.Image = thumbs[pl.UserId]
		else
			thumbs[pl.UserId] = ""
			task.spawn(function()
				local ok, img = pcall(function()
					return Players:GetUserThumbnailAsync(pl.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if ok then thumbs[pl.UserId] = img end
			end)
		end
	end
	for i = #plrs + 1, #rowPool do rowPool[i].b.Visible = false; rowPool[i].plr = nil end
	local shown = math.min(#plrs, 12)
	panel.Size = UDim2.fromOffset(300, 60 + shown * (ROW + 3))
end
H.refreshBoard = refresh

local function setCore()
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not (B.enabled and B.hideCore)) end)
end
Players.PlayerAdded:Connect(function(pl)
	refresh()
	if B.enabled then notify("👻 НОВАЯ ДУША", pl.DisplayName .. " попал(а) в ловушку...") end
end)
Players.PlayerRemoving:Connect(function(pl)
	task.defer(refresh)
	if B.enabled then notify("⚰️ ДУША СБЕЖАЛА", pl.DisplayName .. " исчез(ла) в тумане") end
end)
UIS.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.Tab and B.enabled then
		B.open = not B.open
		if B.open then
			panel.Position = UDim2.new(1, 320, 0, 12)
			refresh()
			tw(panel, 0.35, {Position = UDim2.new(1, -12, 0, 12)}, Enum.EasingStyle.Back)
		else
			panel.Visible = false
		end
	end
end)
task.spawn(function()
	local n = 0
	while gui.Parent do
		refresh()
		n += 1
		if n % 2 == 0 then setCore() end
		pStroke.Transparency = 0.1 + math.abs(math.sin(os.clock() * 2)) * 0.5
		task.wait(1)
	end
end)
setCore()
refresh()

local p = V.pBoard
addLabel(p, "💀 ХЕЛЛОУИНСКИЙ ТАБ ИГРОКОВ (Tab — показать/скрыть)")
addToggle(p, "💀 Доска душ вместо обычного таба", true, function(v) B.enabled = v; setCore(); refresh() end)
addToggle(p, "🚫 Убрать оригинальный таб Roblox", true, function(v) B.hideCore = v; setCore() end)
addButton(p, "↔️ Перенести доску: справа / слева", function()
	if panel.AnchorPoint.X == 1 then
		panel.AnchorPoint = Vector2.new(0, 0); panel.Position = UDim2.fromOffset(12, 60)
	else
		panel.AnchorPoint = Vector2.new(1, 0); panel.Position = UDim2.new(1, -12, 0, 12)
	end
end)
addLabel(p, "Нажмите на игрока в доске, чтобы открыть его карточку.")

end
do
-- ---------------------------------------------------------------------------
-- Страшилки: скример, охота за конфетами, гадание, шёпот
-- ---------------------------------------------------------------------------
local H = V.H
function H.jumpscare()
	local f = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), ZIndex = 2800}, gui)
	local face = new("TextLabel", {
		Size = UDim2.fromScale(0.2, 0.2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
		Text = ({"💀", "👺", "🎃", "👻", "🧟"})[V.rng:NextInteger(1, 5)], TextScaled = true, ZIndex = 2801,
	}, f)
	local txt = new("TextLabel", {
		Size = UDim2.new(1, 0, 0.15, 0), Position = UDim2.fromScale(0, 0.8), BackgroundTransparency = 1, Text = "БУ!",
		Font = H.SCARY_FONT, TextScaled = true, TextColor3 = rgb(220, 10, 20), ZIndex = 2801,
	}, f)
	H.sound("scream", 1)
	tw(face, 0.15, {Size = UDim2.fromScale(0.9, 0.9)}, Enum.EasingStyle.Back)
	for _ = 1, 10 do
		face.Position = UDim2.new(0.5, V.rng:NextInteger(-20, 20), 0.5, V.rng:NextInteger(-20, 20))
		f.BackgroundColor3 = (V.rng:NextNumber() > 0.5) and rgb(90, 0, 0) or rgb(0, 0, 0)
		task.wait(0.05)
	end
	tw(f, 0.5, {BackgroundTransparency = 1}); tw(face, 0.5, {TextTransparency = 1}); tw(txt, 0.5, {TextTransparency = 1})
	Debris:AddItem(f, 0.6)
end

local randomScare = false
task.spawn(function()
	while gui.Parent do
		task.wait(V.rng:NextNumber(90, 240))
		if randomScare then H.jumpscare() end
	end
end)

-- шёпот на экране
local whispers = {
	"кто-то стоит за тобой...", "не оборачивайся", "тыква следит за тобой 🎃", "ты слышал этот звук?",
	"Даня говорил, что здесь безопасно...", "полночь близко", "сладость или гадость?", "свет сейчас погаснет...",
}
local whisperOn = false
function H.whisper(text)
	local l = new("TextLabel", {
		Size = UDim2.fromOffset(420, 40), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(V.rng:NextNumber(0.25, 0.75), V.rng:NextNumber(0.2, 0.8)), BackgroundTransparency = 1,
		Text = text or whispers[V.rng:NextInteger(1, #whispers)], Font = H.SCARY_FONT, TextSize = 26,
		TextColor3 = rgb(200, 30, 30), TextTransparency = 1, ZIndex = 5,
	}, gui)
	tw(l, 1.2, {TextTransparency = 0.2})
	task.delay(2.5, function() tw(l, 1.5, {TextTransparency = 1, Position = l.Position + UDim2.fromOffset(0, -30)}) end)
	Debris:AddItem(l, 4.5)
end
task.spawn(function()
	while gui.Parent do
		task.wait(V.rng:NextNumber(25, 60))
		if whisperOn then H.whisper() end
	end
end)

-- охота за конфетами
local hunt = {on = false, score = 0, best = 0, folder = nil}
local scoreLbl
local function spawnCandy()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or not hunt.folder then return end
	local a = V.rng:NextNumber(0, math.pi * 2)
	local d = V.rng:NextNumber(10, 40)
	local c = new("Part", {
		Name = "VLH_Candy", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.4, 1.4, 1.4), Material = Enum.Material.Neon,
		Color = H.Pal[V.rng:NextInteger(1, #H.Pal)][2],
		Position = root.Position + Vector3.new(math.cos(a) * d, V.rng:NextNumber(0, 3), math.sin(a) * d),
	}, hunt.folder)
	new("PointLight", {Color = c.Color, Range = 8, Brightness = 2}, c)
	local bb = new("BillboardGui", {Size = UDim2.fromOffset(40, 40), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 1.6, 0)}, c)
	new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "🍬", TextScaled = true}, bb)
end
RunService.Heartbeat:Connect(function()
	if not hunt.on or not hunt.folder then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, c in ipairs(hunt.folder:GetChildren()) do
		c.CFrame = CFrame.new(c.Position) * CFrame.Angles(0, os.clock() * 2, 0)
		if (c.Position - root.Position).Magnitude < 4 then
			c:Destroy()
			hunt.score += 1
			hunt.best = math.max(hunt.best, hunt.score)
			H.sound("candy", 0.6)
			if scoreLbl then scoreLbl.Text = "🍬 Собрано: " .. hunt.score .. "   🏆 Рекорд: " .. hunt.best end
			if hunt.score % 10 == 0 then notify("🍬 ОХОТА", hunt.score .. " конфет! Тыквенный король доволен...") end
			spawnCandy()
		end
	end
end)

-- гадание тыквы
local fortunes = {
	"Сегодня тебе повезёт… если не выйдешь из дома в полночь.", "Друг принесёт тебе конфету. Не ешь её.",
	"Тень за тобой — не твоя.", "Твой следующий прыжок будет легендарным.", "Даня знает секрет. Спроси его.",
	"В этой игре есть секретный код. Ищи во вкладке версии…", "Конфеты — к удаче. Тыквы — к беде.",
}

local p = V.pFun
addLabel(p, "🦇 СТРАШИЛКИ И МИНИ-ИГРЫ")
addButton(p, "😱 Скример сейчас", function() task.spawn(H.jumpscare) end)
addToggle(p, "🎲 Случайные скримеры (раз в 1.5–4 мин)", false, function(v) randomScare = v end)
addToggle(p, "🗣️ Жуткий шёпот на экране", false, function(v) whisperOn = v; if v then H.whisper() end end)
addButton(p, "🔮 Гадание тыквы", function()
	notify("🔮 ТЫКВА ГОВОРИТ", fortunes[V.rng:NextInteger(1, #fortunes)])
end)
addLabel(p, "🍬 ОХОТА ЗА КОНФЕТАМИ (собирайте светящиеся конфеты вокруг)")
addToggle(p, "🍬 Играть", false, function(v)
	hunt.on = v
	if hunt.folder then hunt.folder:Destroy(); hunt.folder = nil end
	if v then
		hunt.score = 0
		hunt.folder = new("Folder", {Name = "VLH_Candies"}, workspace)
		for _ = 1, 8 do spawnCandy() end
		if scoreLbl then scoreLbl.Text = "🍬 Собрано: 0   🏆 Рекорд: " .. hunt.best end
	end
end)
scoreLbl = addLabel(p, "🍬 Собрано: 0   🏆 Рекорд: 0")
scoreLbl.TextSize = 13

end
do
-- ---------------------------------------------------------------------------
-- СТРАШНАЯ ЗАСТАВКА: чёрный экран → тыква смеётся → крутится → текст → буквы падают
-- ---------------------------------------------------------------------------
local H = V.H
function V.playHalloweenIntro(done)
	local finished = false
	local function finish()
		if finished then return end
		finished = true
		pcall(done)
	end
	local root = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), ZIndex = 1900, GroupTransparency = 0}, gui)
	local skip = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1990}, root)
	local skipHint = new("TextLabel", {
		Size = UDim2.fromOffset(300, 20), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -12), BackgroundTransparency = 1,
		Text = "нажмите, чтобы пропустить", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = rgb(90, 60, 50),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 1991, TextTransparency = 1,
	}, root)
	local skipped = false
	local function close()
		if skipped then return end
		skipped = true
		tw(root, 0.7, {GroupTransparency = 1})
		task.delay(0.75, function() root:Destroy() end)
		finish()
	end
	skip.Activated:Connect(close)

	-- красная дымка
	local haze = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(70, 0, 6), BackgroundTransparency = 1, ZIndex = 1901}, root)
	new("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 1)}), Rotation = 90}, haze)

	-- тыква (CanvasGroup, чтобы вращалась целиком)
	local PS = 220
	local pumpkin = new("CanvasGroup", {
		Size = UDim2.fromOffset(PS, PS), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1, GroupTransparency = 1, ZIndex = 1910,
	}, root)
	local psc = new("UIScale", {Scale = 0.3}, pumpkin)
	local function lobe(x, w, c)
		local f = new("Frame", {
			Size = UDim2.fromOffset(w, PS * 0.72), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(PS / 2 + x, PS * 0.57),
			BackgroundColor3 = c, BorderSizePixel = 0, ZIndex = 1911,
		}, pumpkin)
		corner(f, 999)
		return f
	end
	lobe(-55, 110, rgb(215, 90, 10)); lobe(55, 110, rgb(215, 90, 10))
	lobe(-28, 110, rgb(235, 110, 18)); lobe(28, 110, rgb(235, 110, 18))
	local mid = lobe(0, 100, rgb(250, 130, 25))
	new("UIGradient", {Rotation = 90, Color = ColorSequence.new(rgb(255, 255, 255), rgb(170, 120, 120))}, mid)
	local stem = new("Frame", {
		Size = UDim2.fromOffset(22, 44), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromOffset(PS / 2 + 6, PS * 0.25),
		BackgroundColor3 = rgb(70, 110, 30), Rotation = 14, ZIndex = 1912,
	}, pumpkin); corner(stem, 6)
	local glowC = rgb(255, 230, 80)
	local eyes = {}
	for i = -1, 1, 2 do
		local e = new("TextLabel", {
			Size = UDim2.fromOffset(56, 56), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(PS / 2 + i * 44, PS * 0.46),
			BackgroundTransparency = 1, Text = "▲", Font = Enum.Font.GothamBlack, TextSize = 58, TextColor3 = glowC, Rotation = i * 12, ZIndex = 1913,
		}, pumpkin)
		new("UIStroke", {Color = rgb(255, 120, 0), Thickness = 3, Transparency = 0.3}, e)
		table.insert(eyes, e)
	end
	local nose = new("TextLabel", {
		Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(PS / 2, PS * 0.6), BackgroundTransparency = 1,
		Text = "▼", Font = Enum.Font.GothamBlack, TextSize = 26, TextColor3 = glowC, ZIndex = 1913,
	}, pumpkin)
	local mouth = new("Frame", {
		Size = UDim2.fromOffset(130, 26), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(PS / 2, PS * 0.76),
		BackgroundColor3 = glowC, ZIndex = 1913,
	}, pumpkin); corner(mouth, 14)
	new("UIStroke", {Color = rgb(255, 120, 0), Thickness = 3, Transparency = 0.3}, mouth)
	for i = -2, 2 do
		new("Frame", {
			Size = UDim2.fromOffset(14, 12), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, i * 24, 0, -1),
			BackgroundColor3 = rgb(250, 130, 25), BorderSizePixel = 0, Rotation = 45, ZIndex = 1914,
		}, mouth)
	end

	-- текст (слоты фиксированной ширины, чтобы буквы можно было ронять)
	local function word(text, size, y, color)
		local holder = new("Frame", {
			Size = UDim2.fromOffset(0, size), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 50, 0.5, y), BackgroundTransparency = 1, ZIndex = 1920,
		}, root)
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Center}, holder)
		local letters = {}
		for _, ch in utf8.codes(text) do
			local c = utf8.char(ch)
			local slot = new("Frame", {Size = UDim2.fromOffset(c == " " and size * 0.3 or size * 0.62, size), BackgroundTransparency = 1, ZIndex = 1920}, holder)
			local l = new("TextLabel", {
				Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, -40), BackgroundTransparency = 1, Text = c, Font = H.SCARY_FONT,
				TextSize = size, TextColor3 = color, TextTransparency = 1, ZIndex = 1921,
			}, slot)
			local st = new("UIStroke", {Color = rgb(60, 0, 0), Thickness = 2, Transparency = 1}, l)
			if c ~= " " then table.insert(letters, {l, st}) end
		end
		return letters, holder
	end

	task.spawn(function()
		-- 1. чёрный экран
		task.wait(1.1)
		if skipped then return end
		tw(skipHint, 1, {TextTransparency = 0})
		-- 2. тыква появляется из тьмы
		tw(pumpkin, 1.4, {GroupTransparency = 0}, Enum.EasingStyle.Sine)
		tw(psc, 1.4, {Scale = 1.15}, Enum.EasingStyle.Back)
		tw(haze, 1.4, {BackgroundTransparency = 0.3})
		task.wait(1.5)
		if skipped then return end
		-- 3. смеётся
		H.sound("laugh", 1)
		local laughs = {"ХА", "ХА-ХА", "ХА-ХА-ХА", "ХИ-ХИ", "ХА!"}
		for i = 1, 14 do
			if skipped then return end
			local open = i % 2 == 0
			mouth.Size = UDim2.fromOffset(130, open and 50 or 20)
			pumpkin.Position = UDim2.new(0.5, V.rng:NextInteger(-6, 6), 0.5, V.rng:NextInteger(-6, 6))
			pumpkin.Rotation = V.rng:NextInteger(-6, 6)
			for _, e in ipairs(eyes) do e.TextColor3 = open and rgb(255, 60, 20) or glowC end
			nose.TextColor3 = open and rgb(255, 60, 20) or glowC
			if i % 3 == 0 then
				local l = new("TextLabel", {
					Size = UDim2.fromOffset(240, 60), AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5 + V.rng:NextNumber(-0.3, 0.3), 0.5 + V.rng:NextNumber(-0.35, 0.35)),
					BackgroundTransparency = 1, Text = laughs[V.rng:NextInteger(1, #laughs)], Font = H.SCARY_FONT, TextSize = V.rng:NextInteger(30, 56),
					TextColor3 = rgb(255, 110, 10), Rotation = V.rng:NextInteger(-20, 20), ZIndex = 1905,
				}, root)
				tw(l, 0.9, {TextTransparency = 1, Position = l.Position + UDim2.fromOffset(0, -30)})
				Debris:AddItem(l, 1)
			end
			task.wait(0.1)
		end
		mouth.Size = UDim2.fromOffset(130, 34)
		pumpkin.Rotation = 0
		if skipped then return end
		-- 4. вращается и уходит в начало (влево от надписи)
		tw(pumpkin, 1.3, {Rotation = 720, Position = UDim2.new(0.5, -330, 0.5, -20)}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		tw(psc, 1.3, {Scale = 0.6}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		task.wait(1.35)
		if skipped then return end
		pumpkin.Rotation = 0
		-- 5. страшный текст
		local big = word("ROBLOX VISUALS", 64, -20, rgb(255, 110, 10))
		local small = word("WELCOME", 34, 46, rgb(200, 20, 30))
		for _, L in ipairs(big) do
			if skipped then return end
			tw(L[1], 0.25, {TextTransparency = 0, Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back)
			tw(L[2], 0.25, {Transparency = 0})
			task.wait(0.07)
		end
		for _, L in ipairs(small) do
			if skipped then return end
			tw(L[1], 0.3, {TextTransparency = 0, Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Bounce)
			tw(L[2], 0.3, {Transparency = 0})
			task.wait(0.09)
		end
		-- мерцание
		for _ = 1, 6 do
			if skipped then return end
			local off = V.rng:NextNumber() > 0.5
			for _, L in ipairs(big) do L[1].TextTransparency = off and 0.6 or 0 end
			task.wait(V.rng:NextNumber(0.05, 0.15))
		end
		for _, L in ipairs(big) do L[1].TextTransparency = 0 end
		task.wait(0.5)
		if skipped then return end
		-- 6. некоторые буквы отпадают
		local all = {}
		for _, L in ipairs(big) do table.insert(all, L) end
		for _, L in ipairs(small) do table.insert(all, L) end
		local falls = 0
		for _, L in ipairs(all) do
			if V.rng:NextNumber() < 0.35 and falls < 6 then
				falls += 1
				task.delay(V.rng:NextNumber(0, 0.9), function()
					tw(L[1], 0.12, {Rotation = V.rng:NextInteger(-25, 25)})
					task.wait(0.25)
					tw(L[1], 1.1, {Position = UDim2.fromOffset(V.rng:NextInteger(-30, 30), 700), Rotation = V.rng:NextInteger(-200, 200)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					tw(L[2], 1.1, {Transparency = 1})
				end)
			end
		end
		-- тыква подмигивает
		task.wait(0.6)
		for _ = 1, 4 do mouth.Size = UDim2.fromOffset(130, 46); task.wait(0.08); mouth.Size = UDim2.fromOffset(130, 22); task.wait(0.08) end
		task.wait(1)
		if skipped then return end
		-- 7. молния и превращение в главное меню
		task.spawn(H.lightning, 0.8)
		task.wait(0.15)
		tw(psc, 0.6, {Scale = 0.1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		close()
	end)
	-- защита: если что-то пошло не так, меню всё равно откроется
	task.delay(16, close)
end

end
do
-- ---------------------------------------------------------------------------
-- Секретная история «Ночь в заброшенном особняке» (код ZTE2049)
-- ---------------------------------------------------------------------------
local H = V.H
function H.playStory()
	if H.storyOpen then return end
	H.storyOpen = true
	local me = H.name(player)
	local CAST = {
		narr = {"Рассказчик", "📜", rgb(180, 160, 140)},
		me = {me, "🧑", rgb(120, 200, 255)},
		danya = {"Даня", "🧒", rgb(120, 255, 120)},
		king = {"Тыквенный Король", "🎃", rgb(255, 120, 20)},
		ghost = {"Призрак дворецкого", "👻", rgb(200, 240, 255)},
		cat = {"Чёрный кот Барсик", "🐈‍⬛", rgb(200, 180, 255)},
	}
	local root = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1, ZIndex = 2500, Active = true}, gui)
	tw(root, 0.8, {BackgroundTransparency = 0})
	local bgEmoji = new("TextLabel", {
		Size = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.38), BackgroundTransparency = 1,
		Text = "🏚️", TextScaled = true, TextTransparency = 0.75, ZIndex = 2501,
	}, root)
	local title = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 60), Position = UDim2.fromOffset(0, 20), BackgroundTransparency = 1, Text = "НОЧЬ В ЗАБРОШЕННОМ ОСОБНЯКЕ",
		Font = H.SCARY_FONT, TextSize = 40, TextColor3 = rgb(255, 110, 10), ZIndex = 2502,
	}, root)
	local box = new("Frame", {
		Size = UDim2.new(0.8, 0, 0, 190), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -30),
		BackgroundColor3 = rgb(20, 8, 8), BackgroundTransparency = 0.1, ZIndex = 2502,
	}, root)
	corner(box, 16)
	local bstroke = new("UIStroke", {Thickness = 2, Color = rgb(255, 110, 10)}, box)
	local portrait = new("TextLabel", {Size = UDim2.fromOffset(110, 110), Position = UDim2.fromOffset(20, 40), BackgroundColor3 = rgb(40, 14, 10), Text = "", TextSize = 70, ZIndex = 2503}, box)
	corner(portrait, 55)
	local pst = new("UIStroke", {Thickness = 3}, portrait)
	local nameL = new("TextLabel", {
		Size = UDim2.new(1, -170, 0, 34), Position = UDim2.fromOffset(150, 10), BackgroundTransparency = 1, Text = "",
		Font = H.SCARY_FONT, TextSize = 28, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2503,
	}, box)
	local textL = new("TextLabel", {
		Size = UDim2.new(1, -170, 1, -90), Position = UDim2.fromOffset(150, 46), BackgroundTransparency = 1, Text = "",
		Font = Enum.Font.GothamMedium, TextSize = 17, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = rgb(255, 236, 215), ZIndex = 2503,
	}, box)
	local choiceRow = new("Frame", {Size = UDim2.new(1, -170, 0, 36), Position = UDim2.new(0, 150, 1, -46), BackgroundTransparency = 1, ZIndex = 2503}, box)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right}, choiceRow)
	local skipB = new("TextButton", {
		Size = UDim2.fromOffset(120, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 20), Text = "⏭ Закрыть",
		Font = Enum.Font.GothamBold, TextSize = 12, BackgroundColor3 = rgb(60, 10, 10), TextColor3 = rgb(255, 220, 200), ZIndex = 2504,
	}, root); corner(skipB, 8)

	local closed = false
	local function closeStory()
		if closed then return end
		closed = true
		tw(root, 0.6, {BackgroundTransparency = 1})
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then tw(d, 0.5, {TextTransparency = 1, BackgroundTransparency = 1}) end
			if d:IsA("Frame") then tw(d, 0.5, {BackgroundTransparency = 1}) end
			if d:IsA("UIStroke") then tw(d, 0.5, {Transparency = 1}) end
		end
		task.delay(0.7, function() root:Destroy(); H.storyOpen = false end)
	end
	skipB.Activated:Connect(closeStory)

	local clicked = Instance.new("BindableEvent")
	local typing = false
	local fullText = ""
	root.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if typing then typing = false; textL.Text = fullText else clicked:Fire() end
		end
	end)

	local function fx(kind)
		if kind == "thunder" then task.spawn(H.lightning, 0.8)
		elseif kind == "shake" then
			task.spawn(function()
				for _ = 1, 12 do box.Position = UDim2.new(0.5, V.rng:NextInteger(-8, 8), 1, -30 + V.rng:NextInteger(-5, 5)); task.wait(0.03) end
				box.Position = UDim2.new(0.5, 0, 1, -30)
			end)
		elseif kind == "red" then
			root.BackgroundColor3 = rgb(70, 0, 0); tw(root, 1.5, {BackgroundColor3 = rgb(0, 0, 0)})
		elseif kind == "gold" then
			root.BackgroundColor3 = rgb(90, 70, 0); tw(root, 2, {BackgroundColor3 = rgb(10, 6, 0)})
		end
	end

	local function say(who, text, scene, effect)
		if closed then return end
		local c = CAST[who]
		nameL.Text = c[1]; nameL.TextColor3 = c[3]
		portrait.Text = c[2]; pst.Color = c[3]; bstroke.Color = c[3]
		if scene then bgEmoji.Text = scene end
		if effect then fx(effect) end
		fullText = text
		typing = true
		textL.Text = ""
		local acc = ""
		for _, cp in utf8.codes(text) do
			if not typing or closed then break end
			acc ..= utf8.char(cp)
			textL.Text = acc
			task.wait(0.022)
		end
		textL.Text = text
		typing = false
		if not closed then clicked.Event:Wait() end
	end

	local function choose(options)
		local ev = Instance.new("BindableEvent")
		local btns = {}
		for i, o in ipairs(options) do
			local b = new("TextButton", {
				Size = UDim2.fromOffset(170, 34), Text = o, Font = Enum.Font.GothamBold, TextSize = 13, BackgroundColor3 = rgb(70, 20, 10),
				TextColor3 = rgb(255, 230, 200), ZIndex = 2505,
			}, choiceRow)
			corner(b, 8)
			new("UIStroke", {Color = rgb(255, 110, 10), Thickness = 1.5}, b)
			b.Activated:Connect(function() ev:Fire(i) end)
			table.insert(btns, b)
		end
		local r = ev.Event:Wait()
		for _, b in ipairs(btns) do b:Destroy() end
		return r
	end

	task.spawn(function()
		task.wait(1)
		say("narr", "31 октября. Полночь. На окраине Роблокс-сити стоит особняк, в который никто не заходил уже 100 лет...", "🏚️", "thunder")
		say("danya", me .. ", ну что, слабо зайти? Говорят, там спрятана ЗОЛОТАЯ ТЫКВА. Кто её найдёт — получит бесконечные конфеты!")
		say("me", "Даня, ты же сам вчера от своей тени убежал. Ладно... идём. Но ты первый!")
		say("narr", "Дверь со скрипом открывается сама. Внутри пахнет пылью и... тыквенным пирогом?", "🚪", "shake")
		say("cat", "Мяяяу. (Чёрный кот смотрит на вас светящимися глазами и уходит вверх по лестнице.)", "🕯️")
		say("danya", "Он зовёт нас! Я читал в интернете: если чёрный кот зовёт — надо идти. Или бежать. Забыл, что именно...")
		say("ghost", "Ууууу... Гости... Много лет никто не приходил... Король ждёт вас в бальном зале...", "👻", "red")
		say("danya", "АААА! ПРИЗРАК! " .. me .. ", держи меня! То есть... я держу тебя, чтобы ты не испугался!", nil, "shake")
		say("narr", "Вы входите в бальный зал. На троне из свечей сидит огромная тыква с короной. Её глаза вспыхивают огнём.", "👑", "thunder")
		say("king", "ХА-ХА-ХА! Смельчаки! Золотая тыква достанется только тому, кто отгадает мою загадку. Ошибёшься — станешь тыквой навсегда!", "🎃", "red")
		say("king", "Слушайте: «Что всегда идёт, но никогда не приходит?»")
		if closed then return end
		local pick = choose({"📅 Завтра", "👻 Призрак", "🎒 Даня на уроки"})
		if closed then return end
		if pick == 1 then
			say("me", "Завтра! Оно всегда идёт, но когда наступает — это уже «сегодня».")
			say("king", "НЕЕЕТ! Как ты догадался?! Триста лет никто не отгадывал...", nil, "shake")
			say("danya", "Это я ему подсказал! Ну... мысленно. Мы же лучшие друзья, у нас телепатия!")
			say("narr", "Тыквенный Король с грохотом рассыпается на тысячу конфет. В центре зала сияет ЗОЛОТАЯ ТЫКВА.", "🏆", "gold")
			say("ghost", "Спасибо, герои... Теперь мы свободны... Заходите в гости на следующий Хеллоуин... уууу...", "✨")
			say("danya", "Делим конфеты пополам! Ну, мне 60%, я же первый зашёл... ладно-ладно, 50 на 50 😄", "🍬")
		else
			if pick == 3 then
				say("danya", "ЭЙ! Я вообще-то хожу на уроки! Иногда. По четвергам.")
			end
			say("king", "НЕВЕРНО! ХА-ХА-ХА! Теперь ты — моя новая тыква!", "🎃", "red")
			say("narr", "Ваши ноги начинают оранжеветь... но вдруг Даня достаёт из кармана старую лакричную конфету.", nil, "shake")
			say("danya", "НА ТЕБЕ, ТЫКВЕННАЯ БОРОДА! Лакричная! Её даже призраки не едят!", "🍬")
			say("king", "ТОЛЬКО НЕ ЛАКРИЦА-А-А-А!!! (Король рассыпается в пыль)", "💥", "thunder")
			say("me", "Даня... ты спас меня. Правда, откуда у тебя в кармане конфета с прошлого года?")
			say("danya", "Не задавай лишних вопросов. Главное — Золотая тыква наша!", "🏆", "gold")
		end
		say("cat", "Мррр. (Кот подмигивает. Кажется, это был его план с самого начала...)", "🌕")
		if closed then return end
		-- титры
		box.Visible = false
		bgEmoji.Text = "🎃"
		title.Text = "В РОЛЯХ"
		local credits = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 420), Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.Fantasy,
			TextSize = 24, TextColor3 = rgb(255, 230, 200), ZIndex = 2503, TextYAlignment = Enum.TextYAlignment.Top,
			Text = table.concat({
				"🧑 " .. me .. " — Главный герой",
				"🧒 Даня — Лучший друг (и герой с лакрицей)",
				"🎃 Тыквенный Король — Сам себя",
				"👻 Призрак дворецкого — Ууууу",
				"🐈‍⬛ Кот Барсик — Тайный злодей",
				"",
				"Roblox Visuals v" .. H.VERSION,
				"Спасибо за игру! С Хеллоуином! 🎃",
			}, "\n\n"),
		}, root)
		tw(credits, 12, {Position = UDim2.new(0, 0, 0, 90)}, Enum.EasingStyle.Linear)
		task.wait(13)
		notify("🏆 ДОСТИЖЕНИЕ", "«Золотая тыква» — секретная история пройдена!")
		closeStory()
	end)
end

-- ---------------------------------------------------------------------------
-- Вкладка «Версия» (последняя). 3 нажатия на версию → секретное меню
-- ---------------------------------------------------------------------------
V.pVer = createTab("🧾 Версия")
local p = V.pVer
local verBtn = addButton(p, "🎃 Roblox Visuals  v" .. H.VERSION, function() end)
verBtn.Font = H.SCARY_FONT; verBtn.TextSize = 22; verBtn.Size = UDim2.new(1, -8, 0, 54)
addLabel(p, "ЧТО НОВОГО В ЭТОЙ ВЕРСИИ")
for _, line in ipairs({
	"🎃 Страшная заставка с смеющейся тыквой", "🕸️ Хеллоуин-интерфейс + 4 страшные темы",
	"🧟 Персонаж+: 19 новых элементов косметики и 6 образов", "🖌️ Редактор пиксельного курсора",
	"🎥 Режим стримера (скрытый ввод)", "💀 Доска душ вместо таба игроков",
	"🦇 Скримеры, шёпот, охота за конфетами, гадание", "❓ ...и кое-что спрятанное",
}) do addLabel(p, line) end

local secret = new("Frame", {Size = UDim2.new(1, -8, 0, 130), BackgroundColor3 = rgb(20, 2, 4), Visible = false, ZIndex = 13, ClipsDescendants = true}, p)
corner(secret, 12)
new("UIStroke", {Color = rgb(200, 10, 20), Thickness = 2}, secret)
new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "🔒 СЕКРЕТНОЕ МЕНЮ", Font = H.SCARY_FONT, TextSize = 24,
	TextColor3 = rgb(220, 20, 30), ZIndex = 14,
}, secret)
local codeIn = new("TextBox", {
	Size = UDim2.new(1, -150, 0, 36), Position = UDim2.fromOffset(12, 44), PlaceholderText = "Введите секретный код...", Text = "",
	Font = Enum.Font.Code, TextSize = 16, BackgroundColor3 = rgb(40, 8, 10), TextColor3 = rgb(255, 220, 200), ClearTextOnFocus = false, ZIndex = 14,
}, secret); corner(codeIn, 8)
local goB = new("TextButton", {
	Size = UDim2.fromOffset(120, 36), Position = UDim2.new(1, -132, 0, 44), Text = "▶ Ввести", Font = Enum.Font.GothamBlack, TextSize = 14,
	BackgroundColor3 = rgb(170, 10, 20), TextColor3 = rgb(255, 255, 255), ZIndex = 14,
}, secret); corner(goB, 8)
local hint = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 88), BackgroundTransparency = 1, Text = "Только избранные знают код...",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = rgb(160, 90, 90), ZIndex = 14, TextXAlignment = Enum.TextXAlignment.Left,
}, secret)

local clicks, lastClick = 0, 0
verBtn.Activated:Connect(function()
	local now = os.clock()
	if now - lastClick > 2 then clicks = 0 end
	lastClick = now
	clicks += 1
	if clicks >= 3 and not secret.Visible then
		clicks = 0
		secret.Visible = true
		secret.Size = UDim2.new(1, -8, 0, 0)
		tw(secret, 0.4, {Size = UDim2.new(1, -8, 0, 130)}, Enum.EasingStyle.Back)
		notify("🔒 ???", "Вы нашли секретное меню...")
		task.spawn(H.lightning, 0.4)
	elseif clicks < 3 and not secret.Visible then
		verBtn.TextColor3 = rgb(255, 40, 40)
		task.delay(0.15, function() verBtn.TextColor3 = Theme.text end)
	end
end)
local function tryCode()
	local code = codeIn.Text:gsub("%s", ""):upper()
	if code == "ZTE2049" then
		hint.Text = "✅ Код принят. История начинается..."
		hint.TextColor3 = rgb(120, 255, 120)
		codeIn.Text = ""
		if menuOpen and setMenu then pcall(setMenu, false) end
		H.playStory()
	else
		hint.Text = "❌ Неверный код. Тыква смеётся над тобой..."
		hint.TextColor3 = rgb(255, 80, 80)
		task.spawn(function()
			for _ = 1, 8 do secret.Position = UDim2.fromOffset(V.rng:NextInteger(-6, 6), 0); task.wait(0.03) end
			secret.Position = UDim2.fromOffset(0, 0)
		end)
	end
end
goB.Activated:Connect(tryCode)
codeIn.FocusLost:Connect(function(enter) if enter then tryCode() end end)

-- стартовая хеллоуин-настройка
applyTheme(H.Theme)
H.setScaryMenu(true)
H.setWorld(true)

end
do
	local total = 0
	for _, p in ipairs(pages) do
		for _, c in ipairs(p:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("Frame") then total += 1 end
		end
	end
	Title.Text = "🎃 ROBLOX VISUALS · " .. total .. " функций"
end

pages[1].Visible = true
tabButtons[1].TextColor3 = Theme.text
tabButtons[1].BackgroundTransparency = 0.3

local function afterIntro()
	if V.SHOW_START_MENU then
		V.showStart(true, false)
	else
		setMenu(true)
	end
end
if V.SHOW_INTRO then
	V.playHalloweenIntro(afterIntro)
else
	afterIntro()
end
if V.SHOW_GREETING then
	notify("🪐 ROBLOX VISUALS", "Привет, " .. player.DisplayName .. "! RightShift — меню, P — пауза")
end

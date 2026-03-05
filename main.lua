--[[
    ██████╗ ██╗  ██╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗██╗
    ██╔══██╗██║  ██║██╔═══██╗████╗  ██║██╔════╝██║   ██║██║
    ██████╔╝███████║██║   ██║██╔██╗ ██║█████╗  ██║   ██║██║
    ██╔═══╝ ██╔══██║██║   ██║██║╚██╗██║██╔══╝  ██║   ██║██║
    ██║     ██║  ██║╚██████╔╝██║ ╚████║███████╗╚██████╔╝██║
    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝

    PhoneUI — iPhone Dark Theme UI Library for Roblox
    Version : 1.2.0
    GitHub  : https://raw.githubusercontent.com/crackacheeky/phonelib/refs/heads/main/main.lua
--]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════
local Theme = {
    BG            = Color3.fromRGB(18,  18,  20),
    BGSecondary   = Color3.fromRGB(28,  28,  30),
    BGTertiary    = Color3.fromRGB(44,  44,  46),
    BGElevated    = Color3.fromRGB(58,  58,  60),
    Separator     = Color3.fromRGB(70,  70,  72),

    Blue          = Color3.fromRGB(10,  132, 255),
    Green         = Color3.fromRGB(48,  209, 88),
    Red           = Color3.fromRGB(255, 69,  58),
    Orange        = Color3.fromRGB(255, 159, 10),
    Purple        = Color3.fromRGB(191, 90,  242),
    Teal          = Color3.fromRGB(90,  200, 250),
    Yellow        = Color3.fromRGB(255, 214, 10),

    TextPrimary   = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextMuted     = Color3.fromRGB(110, 110, 120),

    RadiusXS      = UDim.new(0, 6),
    RadiusSM      = UDim.new(0, 10),
    RadiusMD      = UDim.new(0, 12),
    RadiusLG      = UDim.new(0, 16),
    RadiusXL      = UDim.new(0, 20),
    RadiusPill    = UDim.new(1,  0),

    Font          = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.GothamSemibold,
    FontReg       = Enum.Font.Gotham,
}

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Spring(obj, props, t)
    Tween(obj, props, t or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

local function Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or Theme.RadiusMD
    c.Parent = p
    return c
end

local function Stroke(col, thick, p, trans)
    local s = Instance.new("UIStroke")
    s.Color        = col   or Theme.Separator
    s.Thickness    = thick or 1
    s.Transparency = trans or 0
    s.Parent = p
    return s
end

local function Pad(t, r, b, l, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.Parent = p
    return pad
end

local function VList(spacing, p)
    local l = Instance.new("UIListLayout")
    l.FillDirection  = Enum.FillDirection.Vertical
    l.Padding        = UDim.new(0, spacing or 0)
    l.SortOrder      = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = p
    return l
end

local function HList(spacing, p)
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.Padding       = UDim.new(0, spacing or 0)
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.VerticalAlignment = Enum.VerticalAlignment.Center
    l.Parent = p
    return l
end

local function AutoHeight(scroll, list, pad)
    local function update()
        local h = list.AbsoluteContentSize.Y + (pad or 16)
        scroll.CanvasSize = UDim2.new(0, 0, 0, h)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function Hover(btn, base, over)
    btn.MouseEnter:Connect(function()    Tween(btn, {BackgroundColor3 = over}, 0.12) end)
    btn.MouseLeave:Connect(function()    Tween(btn, {BackgroundColor3 = base}, 0.12) end)
    btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = Theme.BGElevated}, 0.08) end)
    btn.MouseButton1Up:Connect(function()   Tween(btn, {BackgroundColor3 = over}, 0.12) end)
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local NotifGui, NotifHolder

local function EnsureNotif()
    if NotifGui and NotifGui.Parent then return end
    NotifGui = New("ScreenGui", {
        Name = "PhoneUI_Notifs", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999, Parent = CoreGui,
    })
    NotifHolder = New("Frame", {
        Name = "Holder",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
        Parent = NotifGui,
    })
    local l = VList(8, NotifHolder)
    l.VerticalAlignment = Enum.VerticalAlignment.Top
    Pad(16, 0, 16, 0, NotifHolder)
end

-- ══════════════════════════════════════════════════════════════
--  LIBRARY
-- ══════════════════════════════════════════════════════════════
local PhoneUI = {}
PhoneUI.__index = PhoneUI

function PhoneUI:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "PhoneUI"
    local body     = opts.Body     or ""
    local icon     = opts.Icon     or "📱"
    local duration = opts.Duration or 4
    local accent   = opts.Accent   or Theme.Blue

    EnsureNotif()

    -- card
    local card = New("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.BGTertiary,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    Corner(Theme.RadiusLG, card)
    Stroke(accent, 1, card, 0.5)

    -- accent strip
    local strip = New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        Parent = card,
    })
    Corner(Theme.RadiusPill, strip)

    -- inner layout
    local inner = New("Frame", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Parent = card,
    })
    Pad(10, 8, 10, 6, inner)
    HList(10, inner)

    -- icon
    local iconFrame = New("Frame", {
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.75,
        Parent = inner,
    })
    Corner(Theme.RadiusSM, iconFrame)
    New("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text = icon, TextScaled = true, Font = Theme.Font, Parent = iconFrame,
    })

    -- text
    local textFrame = New("Frame", {
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        Parent = inner,
    })
    VList(2, textFrame)
    New("TextLabel", {
        Size = UDim2.new(1,0,0,16), BackgroundTransparency=1,
        Text = title, TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.FontSemi, TextSize = 13,
        Parent = textFrame,
    })
    New("TextLabel", {
        Size = UDim2.new(1,0,0,14), BackgroundTransparency=1,
        Text = body, TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.FontReg, TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = textFrame,
    })

    -- progress bar
    local pb = New("Frame", {
        Size = UDim2.new(1,0,0,2),
        Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = accent,
        Parent = card,
    })
    Corner(Theme.RadiusPill, pb)

    -- animate in
    card.Position = UDim2.new(1, 10, 0, 0)
    Tween(card, {Position = UDim2.new(0,0,0,0)}, 0.35, Enum.EasingStyle.Quart)
    Tween(pb, {Size = UDim2.new(0,0,0,2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, {Position = UDim2.new(1,10,0,0), BackgroundTransparency=1}, 0.25)
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function PhoneUI:CreateWindow(opts)
    opts = opts or {}
    local title   = opts.Title    or "PhoneUI"
    local sub     = opts.Subtitle or ""
    local accent  = opts.Accent   or Theme.Blue
    local W       = opts.Width    or 340
    local H       = opts.Height   or 480

    -- ── ScreenGui ───────────────────────────────────────────
    local SG = New("ScreenGui", {
        Name = "PhoneUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
        Parent = CoreGui,
    })

    -- ── Root ────────────────────────────────────────────────
    local Root = New("Frame", {
        Name = "Root",
        Size = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = SG,
    })
    Corner(Theme.RadiusXL, Root)
    Stroke(Theme.Separator, 1, Root, 0.3)

    -- ── Title Bar (height = 46) ──────────────────────────────
    local TBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BGSecondary,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = Root,
    })
    Corner(Theme.RadiusXL, TBar)
    -- cover bottom corners
    New("Frame", {
        Size = UDim2.new(1,0,0,Theme.RadiusXL.Offset),
        Position = UDim2.new(0,0,1,-Theme.RadiusXL.Offset),
        BackgroundColor3 = Theme.BGSecondary,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TBar,
    })
    -- separator line
    New("Frame", {
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = TBar,
    })

    -- accent dot
    New("Frame", {
        Size = UDim2.new(0,8,0,8),
        Position = UDim2.new(0,14,0.5,-4),
        BackgroundColor3 = accent,
        ZIndex = 4,
        Parent = TBar,
    }){ Corner(Theme.RadiusPill, ...) }

    -- title label
    New("TextLabel", {
        Size = UDim2.new(1,-120,1,0),
        Position = UDim2.new(0,28,0,0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.Font,
        TextSize = 14,
        ZIndex = 4,
        Parent = TBar,
    })

    -- subtitle
    if sub ~= "" then
        New("TextLabel", {
            Size = UDim2.new(0,80,1,0),
            Position = UDim2.new(1,-120,0,0),
            BackgroundTransparency = 1,
            Text = sub,
            TextColor3 = Theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Theme.FontReg,
            TextSize = 10,
            ZIndex = 4,
            Parent = TBar,
        })
    end

    -- close button
    local CloseBtn = New("TextButton", {
        Size = UDim2.new(0,22,0,22),
        Position = UDim2.new(1,-32,0.5,-11),
        BackgroundColor3 = Theme.Red,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 10,
        Font = Theme.Font,
        ZIndex = 5,
        Parent = TBar,
    })
    Corner(Theme.RadiusPill, CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Root, {Size = UDim2.new(0,W,0,0)}, 0.2)
        task.delay(0.25, function() SG:Destroy() end)
    end)

    -- minimise button
    local MinBtn = New("TextButton", {
        Size = UDim2.new(0,22,0,22),
        Position = UDim2.new(1,-58,0.5,-11),
        BackgroundColor3 = Theme.Orange,
        Text = "−",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 13,
        Font = Theme.Font,
        ZIndex = 5,
        Parent = TBar,
    })
    Corner(Theme.RadiusPill, MinBtn)
    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Tween(Root, {Size = UDim2.new(0,W, 0, minimised and 46 or H)}, 0.25, Enum.EasingStyle.Quart)
    end)

    -- ── Tab Bar (height = 38, below title bar) ──────────────
    local TabBar = New("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1,0,0,38),
        Position = UDim2.new(0,0,0,46),
        BackgroundColor3 = Theme.BGSecondary,
        BorderSizePixel = 0,
        ZIndex = 3,
        ClipsDescendants = true,
        Parent = Root,
    })
    New("Frame", {
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = TabBar,
    })

    local TabScroll = New("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0,0,1,0),
        ZIndex = 4,
        Parent = TabBar,
    })
    local TabLayout = HList(0, TabScroll)
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X, 1, 0)
    end)

    -- ── Content (below tab bar, fills rest of window) ───────
    -- Total top = 46 + 38 = 84
    local Content = New("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -84),
        Position = UDim2.new(0, 0, 0, 84),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.BGElevated,
        CanvasSize = UDim2.new(0,0,0,0),
        ZIndex = 2,
        Parent = Root,
    })

    -- ── Dragging ────────────────────────────────────────────
    local drag, dStart, rStart = false, nil, nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dStart = i.Position; rStart = Root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            Root.Position = UDim2.new(rStart.X.Scale, rStart.X.Offset+d.X, rStart.Y.Scale, rStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)

    -- ── Window object ────────────────────────────────────────
    local Window  = {}
    local allTabs = {}
    local active  = nil

    -- entrance anim
    Root.Size = UDim2.new(0,W,0,0)
    task.defer(function()
        Spring(Root, {Size = UDim2.new(0,W,0,H)}, 0.4)
    end)

    -- ────────────────────────────────────────────────────────
    --  ADD TAB
    -- ────────────────────────────────────────────────────────
    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tName = tabOpts.Name or ("Tab "..#allTabs+1)
        local tIcon = tabOpts.Icon or ""

        -- Tab button
        local TBtn = New("TextButton", {
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 5,
            Parent = TabScroll,
        })
        Pad(0,14,0,14, TBtn)

        local TBtnInner = New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            ZIndex = 5,
            Parent = TBtn,
        })
        HList(5, TBtnInner)

        if tIcon ~= "" then
            New("TextLabel", {
                Size = UDim2.new(0,14,1,0),
                BackgroundTransparency = 1,
                Text = tIcon, TextScaled = true,
                Font = Theme.Font, ZIndex = 5,
                Parent = TBtnInner,
            })
        end

        local TLabel = New("TextLabel", {
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = tName,
            TextColor3 = Theme.TextMuted,
            Font = Theme.FontSemi,
            TextSize = 12,
            ZIndex = 5,
            Parent = TBtnInner,
        })

        -- indicator
        local Ind = New("Frame", {
            Size = UDim2.new(0,0,0,2),
            Position = UDim2.new(0.5,0,1,-2),
            AnchorPoint = Vector2.new(0.5,0),
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            ZIndex = 6,
            Parent = TBtn,
        })
        Corner(Theme.RadiusPill, Ind)

        -- Page — a Frame inside Content, full size, hidden by default
        local Page = New("Frame", {
            Name = tName,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 2,
            Parent = Content,
        })
        Pad(10,10,14,10, Page)
        local PList = VList(8, Page)

        -- auto-expand Content canvas when page content grows
        PList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Page.Visible then
                Content.CanvasSize = UDim2.new(0,0,0, PList.AbsoluteContentSize.Y + 24)
            end
        end)

        local tabData = {Btn=TBtn, Label=TLabel, Ind=Ind, Page=Page, List=PList}
        table.insert(allTabs, tabData)

        local function Activate()
            for _, t in ipairs(allTabs) do
                t.Page.Visible = false
                Tween(t.Label, {TextColor3 = Theme.TextMuted}, 0.15)
                Tween(t.Ind,   {Size = UDim2.new(0,0,0,2), Position = UDim2.new(0.5,0,1,-2)}, 0.2)
            end
            Page.Visible = true
            Content.CanvasPosition = Vector2.new(0,0)
            Content.CanvasSize = UDim2.new(0,0,0, PList.AbsoluteContentSize.Y + 24)
            Tween(TLabel, {TextColor3 = accent}, 0.15)
            Spring(Ind, {Size = UDim2.new(1,-20,0,2), Position = UDim2.new(0,10,1,-2)}, 0.3)
            active = tabData
        end

        TBtn.MouseButton1Click:Connect(Activate)
        if #allTabs == 1 then
            task.defer(Activate)
        end

        -- ── Tab API ──────────────────────────────────────────
        local Tab = {}

        -- ── Section header ──────────────────────────────────
        function Tab:AddSection(label)
            local f = New("Frame", {
                Size = UDim2.new(1,0,0,22),
                BackgroundTransparency = 1,
                ZIndex = 2,
                Parent = Page,
            })
            Pad(2,0,0,2, f)
            New("TextLabel", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = (label or ""):upper(),
                TextColor3 = Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontSemi,
                TextSize = 10,
                ZIndex = 2,
                Parent = f,
            })
        end

        -- ── Label ────────────────────────────────────────────
        function Tab:AddLabel(text, col)
            local lbl = New("TextLabel", {
                Size = UDim2.new(1,0,0,18),
                BackgroundTransparency = 1,
                Text = text or "",
                TextColor3 = col or Theme.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 13,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                Parent = Page,
            })
            return {SetText = function(_, t) lbl.Text = t end}
        end

        -- ── Divider ──────────────────────────────────────────
        function Tab:AddDivider()
            New("Frame", {
                Size = UDim2.new(1,0,0,1),
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = Page,
            })
        end

        -- ── Button ───────────────────────────────────────────
        function Tab:AddButton(o)
            o = o or {}
            local lbl  = o.Title    or "Button"
            local icon = o.Icon     or ""
            local sty  = o.Style    or "Primary"
            local cb   = o.Callback or function() end

            local palettes = {
                Primary   = {bg = accent,           txt = Color3.fromRGB(255,255,255)},
                Secondary = {bg = Theme.BGTertiary,  txt = accent},
                Danger    = {bg = Theme.Red,          txt = Color3.fromRGB(255,255,255)},
                Success   = {bg = Theme.Green,        txt = Color3.fromRGB(255,255,255)},
                Outline   = {bg = Color3.fromRGB(0,0,0), txt = accent},
            }
            local pal = palettes[sty] or palettes.Primary

            local Btn = New("TextButton", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = pal.bg,
                BackgroundTransparency = sty == "Outline" and 1 or 0,
                Text = (icon ~= "" and icon.."  " or "") .. lbl,
                TextColor3 = pal.txt,
                Font = Theme.FontSemi,
                TextSize = 13,
                ZIndex = 2,
                Parent = Page,
            })
            Corner(Theme.RadiusLG, Btn)
            if sty == "Outline" then Stroke(accent, 1.5, Btn, 0) end

            Btn.MouseButton1Down:Connect(function()
                Spring(Btn, {Size = UDim2.new(1,-6,0,38)}, 0.2)
            end)
            Btn.MouseButton1Up:Connect(function()
                Spring(Btn, {Size = UDim2.new(1,0,0,40)}, 0.25)
            end)
            Btn.MouseButton1Click:Connect(cb)
            Hover(Btn, pal.bg, Theme.BGElevated)
            return Btn
        end

        -- ── Toggle ───────────────────────────────────────────
        function Tab:AddToggle(o)
            o = o or {}
            local lbl    = o.Title       or "Toggle"
            local desc   = o.Description or ""
            local val    = o.Default     or false
            local col    = o.Accent      or Theme.Green
            local cb     = o.Callback    or function() end

            local rowH = desc ~= "" and 52 or 42

            local Row = New("Frame", {
                Size = UDim2.new(1,0,0,rowH),
                BackgroundColor3 = Theme.BGSecondary,
                ZIndex = 2,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Row)
            Stroke(Theme.Separator, 1, Row, 0.5)
            Pad(0,12,0,12, Row)

            New("TextLabel", {
                Size = UDim2.new(1,-62,0,18),
                Position = UDim2.new(0,0, 0.5, desc ~= "" and -12 or -9),
                BackgroundTransparency = 1,
                Text = lbl,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg, TextSize = 14,
                ZIndex = 3,
                Parent = Row,
            })
            if desc ~= "" then
                New("TextLabel", {
                    Size = UDim2.new(1,-62,0,13),
                    Position = UDim2.new(0,0, 0.5, 3),
                    BackgroundTransparency = 1,
                    Text = desc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Theme.FontReg, TextSize = 11,
                    ZIndex = 3,
                    Parent = Row,
                })
            end

            -- switch
            local Track = New("Frame", {
                Size = UDim2.new(0,48,0,28),
                Position = UDim2.new(1,-48, 0.5,-14),
                BackgroundColor3 = val and col or Theme.BGElevated,
                ZIndex = 3,
                Parent = Row,
            })
            Corner(Theme.RadiusPill, Track)

            local Thumb = New("Frame", {
                Size = UDim2.new(0,24,0,24),
                Position = UDim2.new(0, val and 22 or 2, 0.5,-12),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                ZIndex = 4,
                Parent = Track,
            })
            Corner(Theme.RadiusPill, Thumb)

            local function Refresh()
                Tween(Track, {BackgroundColor3 = val and col or Theme.BGElevated}, 0.2)
                Spring(Thumb, {Position = UDim2.new(0, val and 22 or 2, 0.5,-12)}, 0.3)
            end

            local CA = New("TextButton", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 5,
                Parent = Row,
            })
            CA.MouseButton1Click:Connect(function()
                val = not val; Refresh(); cb(val)
            end)
            Refresh()

            local obj = {}
            function obj:Set(v) val=v; Refresh(); cb(val) end
            function obj:Get() return val end
            return obj
        end

        -- ── Slider ───────────────────────────────────────────
        function Tab:AddSlider(o)
            o = o or {}
            local lbl   = o.Title    or "Slider"
            local mn    = o.Min      or 0
            local mx    = o.Max      or 100
            local def   = o.Default  or mn
            local step  = o.Step     or 1
            local col   = o.Accent   or accent
            local cb    = o.Callback or function() end

            local val = def

            local Card = New("Frame", {
                Size = UDim2.new(1,0,0,58),
                BackgroundColor3 = Theme.BGSecondary,
                ZIndex = 2,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Card)
            Stroke(Theme.Separator, 1, Card, 0.5)
            Pad(8,12,8,12, Card)

            -- top row: title + value
            local Top = New("Frame", {
                Size = UDim2.new(1,0,0,18),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = Card,
            })
            New("TextLabel", {
                Size = UDim2.new(0.7,0,1,0),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=Theme.TextPrimary,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontReg, TextSize=13, ZIndex=3, Parent=Top,
            })
            local ValLbl = New("TextLabel", {
                Size = UDim2.new(0.3,0,1,0),
                Position = UDim2.new(0.7,0,0,0),
                BackgroundTransparency=1,
                Text=tostring(val), TextColor3=col,
                TextXAlignment=Enum.TextXAlignment.Right,
                Font=Theme.Font, TextSize=12, ZIndex=3, Parent=Top,
            })

            -- track
            local TrackBG = New("Frame", {
                Size = UDim2.new(1,0,0,4),
                Position = UDim2.new(0,0,1,-6),
                BackgroundColor3 = Theme.BGElevated,
                ZIndex = 3,
                Parent = Card,
            })
            Corner(Theme.RadiusPill, TrackBG)

            local Fill = New("Frame", {
                Size = UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3 = col,
                ZIndex = 4,
                Parent = TrackBG,
            })
            Corner(Theme.RadiusPill, Fill)

            local pct0 = (val-mn)/(mx-mn)
            local Thumb = New("Frame", {
                Size = UDim2.new(0,18,0,18),
                Position = UDim2.new(pct0,-9,0.5,-9),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                ZIndex = 5,
                Parent = TrackBG,
            })
            Corner(Theme.RadiusPill, Thumb)

            local sliding = false

            local function Update(absX)
                local tp = TrackBG.AbsolutePosition.X
                local ts = TrackBG.AbsoluteSize.X
                local r  = math.clamp((absX-tp)/ts, 0, 1)
                local raw = mn + (mx-mn)*r
                val = math.clamp(math.round(raw/step)*step, mn, mx)
                local p = (val-mn)/(mx-mn)
                Fill.Size = UDim2.new(p,0,1,0)
                Thumb.Position = UDim2.new(p,-9,0.5,-9)
                ValLbl.Text = tostring(val)
                cb(val)
            end

            TrackBG.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true; Update(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            local obj = {}
            function obj:Set(v)
                val = math.clamp(v,mn,mx)
                local p = (val-mn)/(mx-mn)
                Tween(Fill,  {Size = UDim2.new(p,0,1,0)}, 0.15)
                Thumb.Position = UDim2.new(p,-9,0.5,-9)
                ValLbl.Text = tostring(val)
                cb(val)
            end
            function obj:Get() return val end
            return obj
        end

        -- ── Dropdown ─────────────────────────────────────────
        function Tab:AddDropdown(o)
            o = o or {}
            local lbl   = o.Title    or "Dropdown"
            local opts  = o.Options  or {}
            local def   = o.Default  or opts[1]
            local col   = o.Accent   or accent
            local cb    = o.Callback or function() end

            local val  = def
            local open = false

            local Wrap = New("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                ZIndex = 10,
                Parent = Page,
            })

            local Header = New("TextButton", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = Theme.BGSecondary,
                Text = "",
                ZIndex = 10,
                Parent = Wrap,
            })
            Corner(Theme.RadiusMD, Header)
            Stroke(Theme.Separator, 1, Header, 0.5)
            Pad(0,12,0,12, Header)

            New("TextLabel", {
                Size = UDim2.new(0.55,0,1,0),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=Theme.TextPrimary,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontReg, TextSize=13, ZIndex=11, Parent=Header,
            })
            local SelLbl = New("TextLabel", {
                Size = UDim2.new(0.35,0,1,0),
                Position = UDim2.new(0.6,0,0,0),
                BackgroundTransparency=1,
                Text=tostring(val or "Select…"), TextColor3=col,
                TextXAlignment=Enum.TextXAlignment.Right,
                Font=Theme.FontSemi, TextSize=12, ZIndex=11, Parent=Header,
            })
            local Chev = New("TextLabel", {
                Size = UDim2.new(0,12,1,0),
                Position = UDim2.new(1,-12,0,0),
                BackgroundTransparency=1,
                Text="›", TextColor3=Theme.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Center,
                Font=Theme.Font, TextSize=16, ZIndex=11, Parent=Header,
            })

            -- drop list
            local DList = New("Frame", {
                Size = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,1,4),
                BackgroundColor3 = Theme.BGTertiary,
                ClipsDescendants = true,
                ZIndex = 20,
                Parent = Wrap,
            })
            Corner(Theme.RadiusMD, DList)
            Stroke(Theme.Separator, 1, DList, 0.3)

            local DScroll = New("ScrollingFrame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                BorderSizePixel=0,
                ScrollBarThickness=2,
                ScrollBarImageColor3=Theme.Separator,
                CanvasSize=UDim2.new(0,0,0,0),
                ZIndex=20, Parent=DList,
            })
            local DLayout = VList(0, DScroll)
            DLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DScroll.CanvasSize = UDim2.new(0,0,0,DLayout.AbsoluteContentSize.Y)
            end)

            for _, opt in ipairs(opts) do
                local IBtn = New("TextButton", {
                    Size = UDim2.new(1,0,0,34),
                    BackgroundTransparency=1,
                    Text="", ZIndex=21, Parent=DScroll,
                })
                Pad(0,10,0,10, IBtn)
                New("Frame", {
                    Size=UDim2.new(1,0,0,1),
                    Position=UDim2.new(0,0,1,-1),
                    BackgroundColor3=Theme.Separator,
                    BorderSizePixel=0, ZIndex=21, Parent=IBtn,
                })
                New("TextLabel", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,
                    Text=tostring(opt),
                    TextColor3 = opt==val and col or Theme.TextPrimary,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Font=opt==val and Theme.FontSemi or Theme.FontReg,
                    TextSize=13, ZIndex=22, Parent=IBtn,
                })
                IBtn.MouseButton1Click:Connect(function()
                    val=opt; SelLbl.Text=tostring(opt); cb(opt)
                    open=false
                    Tween(DList, {Size=UDim2.new(1,0,0,0)}, 0.2)
                    Tween(Wrap,  {Size=UDim2.new(1,0,0,40)}, 0.2)
                    Tween(Chev,  {Rotation=0}, 0.2)
                end)
                Hover(IBtn, Color3.fromRGB(0,0,0), Theme.BGElevated)
            end

            Header.MouseButton1Click:Connect(function()
                open = not open
                local h = math.min(#opts,5)*34
                if open then
                    Spring(DList, {Size=UDim2.new(1,0,0,h)}, 0.3)
                    Spring(Wrap,  {Size=UDim2.new(1,0,0,40+h+4)}, 0.3)
                    Tween(Chev,  {Rotation=90}, 0.2)
                else
                    Tween(DList, {Size=UDim2.new(1,0,0,0)}, 0.2)
                    Tween(Wrap,  {Size=UDim2.new(1,0,0,40)}, 0.2)
                    Tween(Chev,  {Rotation=0}, 0.2)
                end
            end)

            local obj = {}
            function obj:Set(v) val=v; SelLbl.Text=tostring(v); cb(v) end
            function obj:Get() return val end
            return obj
        end

        -- ── Input ────────────────────────────────────────────
        function Tab:AddInput(o)
            o = o or {}
            local lbl   = o.Title       or "Input"
            local ph    = o.Placeholder or "Type here…"
            local def   = o.Default     or ""
            local col   = o.Accent      or accent
            local cb    = o.Callback    or function() end

            local Card = New("Frame", {
                Size=UDim2.new(1,0,0,60),
                BackgroundColor3=Theme.BGSecondary,
                ZIndex=2, Parent=Page,
            })
            Corner(Theme.RadiusMD, Card)
            Stroke(Theme.Separator,1,Card,0.5)
            Pad(7,12,7,12,Card)

            New("TextLabel", {
                Size=UDim2.new(1,0,0,14),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=Theme.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontSemi, TextSize=10, ZIndex=3, Parent=Card,
            })
            local IBox = New("TextBox", {
                Size=UDim2.new(1,0,0,26),
                Position=UDim2.new(0,0,0,18),
                BackgroundColor3=Theme.BGTertiary,
                Text=def, PlaceholderText=ph,
                PlaceholderColor3=Theme.TextMuted,
                TextColor3=Theme.TextPrimary,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontReg, TextSize=13,
                ClearTextOnFocus=false, ZIndex=3, Parent=Card,
            })
            Corner(Theme.RadiusSM, IBox)
            Pad(0,6,0,6,IBox)
            local iStroke = Stroke(Theme.Separator,1,IBox,0.5)
            IBox.Focused:Connect(function()   Tween(iStroke,{Color=col,Transparency=0},0.15) end)
            IBox.FocusLost:Connect(function(e) Tween(iStroke,{Color=Theme.Separator,Transparency=0.5},0.15); if e then cb(IBox.Text) end end)

            local obj={}
            function obj:Get() return IBox.Text end
            function obj:Set(v) IBox.Text=v end
            return obj
        end

        -- ── ColorPicker ──────────────────────────────────────
        function Tab:AddColorPicker(o)
            o = o or {}
            local lbl  = o.Title    or "Color"
            local def  = o.Default  or Theme.Blue
            local cb   = o.Callback or function() end

            local swatches = {
                Color3.fromRGB(10,132,255), Color3.fromRGB(48,209,88),
                Color3.fromRGB(255,69,58),  Color3.fromRGB(255,159,10),
                Color3.fromRGB(191,90,242), Color3.fromRGB(90,200,250),
                Color3.fromRGB(255,214,10), Color3.fromRGB(255,255,255),
            }

            local Card = New("Frame", {
                Size=UDim2.new(1,0,0,62),
                BackgroundColor3=Theme.BGSecondary,
                ZIndex=2, Parent=Page,
            })
            Corner(Theme.RadiusMD,Card)
            Stroke(Theme.Separator,1,Card,0.5)
            Pad(9,12,9,12,Card)

            New("TextLabel", {
                Size=UDim2.new(0.5,0,0,16),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=Theme.TextPrimary,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontReg, TextSize=13, ZIndex=3, Parent=Card,
            })

            local Row = New("Frame", {
                Size=UDim2.new(1,0,0,26),
                Position=UDim2.new(0,0,0,22),
                BackgroundTransparency=1, ZIndex=3, Parent=Card,
            })
            HList(6,Row)

            local sel = nil
            local selColor = def
            for _,c in ipairs(swatches) do
                local sw = New("TextButton", {
                    Size=UDim2.new(0,24,0,24),
                    BackgroundColor3=c, Text="", ZIndex=4, Parent=Row,
                })
                Corner(Theme.RadiusPill,sw)
                if c==def then Stroke(Color3.fromRGB(255,255,255),2,sw,0); sel=sw end
                sw.MouseButton1Click:Connect(function()
                    if sel then local s=sel:FindFirstChildOfClass("UIStroke"); if s then s:Destroy() end end
                    Stroke(Color3.fromRGB(255,255,255),2,sw,0)
                    sel=sw; selColor=c; cb(c)
                end)
            end

            local obj={}
            function obj:Get() return selColor end
            return obj
        end

        -- ── Keybind ──────────────────────────────────────────
        function Tab:AddKeybind(o)
            o = o or {}
            local lbl  = o.Title    or "Keybind"
            local def  = o.Default  or Enum.KeyCode.Insert
            local cb   = o.Callback or function() end

            local key       = def
            local listening = false

            local Row = New("Frame", {
                Size=UDim2.new(1,0,0,42),
                BackgroundColor3=Theme.BGSecondary,
                ZIndex=2, Parent=Page,
            })
            Corner(Theme.RadiusMD,Row)
            Stroke(Theme.Separator,1,Row,0.5)
            Pad(0,12,0,12,Row)

            New("TextLabel", {
                Size=UDim2.new(0.55,0,1,0),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=Theme.TextPrimary,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=Theme.FontReg, TextSize=13, ZIndex=3, Parent=Row,
            })

            local KBtn = New("TextButton", {
                Size=UDim2.new(0,76,0,26),
                Position=UDim2.new(1,-76,0.5,-13),
                BackgroundColor3=Theme.BGElevated,
                Text=key.Name, TextColor3=accent,
                Font=Theme.FontSemi, TextSize=11,
                ZIndex=3, Parent=Row,
            })
            Corner(Theme.RadiusSM,KBtn)

            KBtn.MouseButton1Click:Connect(function()
                listening=true; KBtn.Text="…"
                Tween(KBtn,{BackgroundColor3=accent},0.15)
                Tween(KBtn,{TextColor3=Color3.fromRGB(255,255,255)},0.15)
            end)
            UserInputService.InputBegan:Connect(function(i,p)
                if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; key=i.KeyCode; KBtn.Text=key.Name
                    Tween(KBtn,{BackgroundColor3=Theme.BGElevated},0.15)
                    Tween(KBtn,{TextColor3=accent},0.15)
                end
                if not p and i.KeyCode==key then cb(key) end
            end)

            local obj={}
            function obj:Get() return key end
            return obj
        end

        return Tab
    end -- AddTab

    -- ── Window controls ──────────────────────────────────────
    function Window:Toggle() Root.Visible = not Root.Visible end
    function Window:Show()   Root.Visible = true end
    function Window:Hide()   Root.Visible = false end
    function Window:Destroy() SG:Destroy() end

    return Window
end

return PhoneUI

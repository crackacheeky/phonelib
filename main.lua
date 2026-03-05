--[[
    ██████╗ ██╗  ██╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗██╗
    ██╔══██╗██║  ██║██╔═══██╗████╗  ██║██╔════╝██║   ██║██║
    ██████╔╝███████║██║   ██║██╔██╗ ██║█████╗  ██║   ██║██║
    ██╔═══╝ ██╔══██║██║   ██║██║╚██╗██║██╔══╝  ██║   ██║██║
    ██║     ██║  ██║╚██████╔╝██║ ╚████║███████╗╚██████╔╝██║
    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝
    
    PhoneUI — iPhone Dark Theme UI Library for Roblox
    Version: 1.0.0
    Author:  PhoneUI
    
    A pixel-perfect iOS 17 dark-mode inspired UI library.
    Silky animations, beautiful components, zero dependencies.
--]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════════════════════
--  THEME  (iOS 17 Dark Mode tokens)
-- ══════════════════════════════════════════════════════════════
local Theme = {
    -- Backgrounds
    BG          = Color3.fromRGB(0,   0,   0),      -- Pure black
    BGSecondary = Color3.fromRGB(28,  28,  30),     -- Elevated surface
    BGTertiary  = Color3.fromRGB(44,  44,  46),     -- Card fill
    BGElevated  = Color3.fromRGB(58,  58,  60),     -- Hover / pressed

    -- Separators
    Separator   = Color3.fromRGB(56,  56,  58),

    -- Accent Colors
    Blue        = Color3.fromRGB(10,  132, 255),
    Green       = Color3.fromRGB(48,  209, 88),
    Red         = Color3.fromRGB(255, 69,  58),
    Orange      = Color3.fromRGB(255, 159, 10),
    Purple      = Color3.fromRGB(191, 90,  242),
    Teal        = Color3.fromRGB(90,  200, 250),
    Yellow      = Color3.fromRGB(255, 214, 10),

    -- Text
    TextPrimary   = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(235, 235, 245),   -- ~60% opacity feel
    TextTertiary  = Color3.fromRGB(235, 235, 245),   -- ~30% opacity feel

    -- Transparency helpers (used with BackgroundTransparency)
    T0   = 0,
    T10  = 0.10,
    T20  = 0.20,
    T40  = 0.40,
    T60  = 0.60,
    T80  = 0.80,
    T90  = 0.90,

    -- Sizing
    RadiusXS = UDim.new(0, 6),
    RadiusSM = UDim.new(0, 10),
    RadiusMD = UDim.new(0, 14),
    RadiusLG = UDim.new(0, 18),
    RadiusXL = UDim.new(0, 22),
    RadiusPill = UDim.new(1, 0),

    -- Font
    Font     = Enum.Font.GothamBold,
    FontSemi = Enum.Font.GothamSemibold,
    FontReg  = Enum.Font.Gotham,
}

-- ══════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ══════════════════════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t or 0.2,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function Spring(obj, props, t)
    Tween(obj, props, t or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ══════════════════════════════════════════════════════════════
--  UI HELPERS
-- ══════════════════════════════════════════════════════════════
local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.RadiusMD
    c.Parent = parent
    return c
end

local function Stroke(color, thickness, parent, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Separator
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.Parent = parent
    return s
end

local function Padding(top, right, bottom, left, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

local function ListLayout(dir, spacing, parent, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, spacing or 0)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function SizeToContent(frame, layout, extraY)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset,
            0, layout.AbsoluteContentSize.Y + (extraY or 0)
        )
    end)
end

local function HoverEffect(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = hoverColor }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = normalColor }, 0.15)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.BGElevated }, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, { BackgroundColor3 = hoverColor }, 0.1)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local NotifHolder

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = New("ScreenGui", {
        Name = "PhoneUI_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = CoreGui,
    })
    NotifHolder = New("Frame", {
        Name = "Holder",
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -330, 0, 0),
        BackgroundTransparency = 1,
        Parent = sg,
    })
    ListLayout(Enum.FillDirection.Vertical, 8, NotifHolder)
    Padding(20, 0, 20, 0, NotifHolder)
end

-- ══════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ══════════════════════════════════════════════════════════════
local PhoneUI = {}
PhoneUI.__index = PhoneUI

-- ══════════════════════════════════════════════════════════════
--  NOTIFY  (standalone, always available)
-- ══════════════════════════════════════════════════════════════
function PhoneUI:Notify(options)
    options = options or {}
    local title    = options.Title   or "Notification"
    local body     = options.Body    or ""
    local icon     = options.Icon    or "📱"
    local duration = options.Duration or 4
    local accent   = options.Accent  or Theme.Blue

    EnsureNotifHolder()

    -- Card
    local card = New("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Theme.BGTertiary,
        BackgroundTransparency = 0.08,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    Corner(Theme.RadiusXL, card)
    Stroke(Theme.Separator, 1, card, 0.6)

    -- Accent bar left
    New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        Parent = card,
    }){ [1] = Corner(UDim.new(1, 0)) }

    local inner = New("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Parent = card,
    })
    Padding(10, 10, 10, 8, inner)

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = inner,
    })
    ListLayout(Enum.FillDirection.Horizontal, 10, row, nil, Enum.VerticalAlignment.Center)

    -- Icon box
    local iconBox = New("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.78,
        Parent = row,
    })
    Corner(Theme.RadiusSM, iconBox)
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextScaled = true,
        Font = Theme.Font,
        Parent = iconBox,
    })

    local textCol = New("Frame", {
        Size = UDim2.new(1, -46, 1, 0),
        BackgroundTransparency = 1,
        Parent = row,
    })
    ListLayout(Enum.FillDirection.Vertical, 2, textCol, nil, Enum.VerticalAlignment.Center)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.FontSemi,
        TextSize = 13,
        Parent = textCol,
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = body,
        TextColor3 = Theme.TextSecondary,
        TextTransparency = 0.35,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.FontReg,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = textCol,
    })

    -- Slide-in from right
    card.Position = UDim2.new(1, 20, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.4, Enum.EasingStyle.Quart)

    -- Progress bar
    local pbar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accent,
        Parent = card,
    })
    Tween(pbar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    -- Auto-dismiss
    task.delay(duration, function()
        Tween(card, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, 0.3)
        task.delay(0.35, function() card:Destroy() end)
    end)

    return card
end

-- ══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function PhoneUI:CreateWindow(options)
    options = options or {}
    local winTitle  = options.Title  or "PhoneUI"
    local subtitle  = options.Subtitle or ""
    local accent    = options.Accent or Theme.Blue
    local winWidth  = options.Width  or 340
    local winHeight = options.Height or 500

    -- ── ScreenGui ──────────────────────────────────────────────
    local ScreenGui = New("ScreenGui", {
        Name = "PhoneUI_" .. winTitle,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10,
        Parent = CoreGui,
    })

    -- ── Root Frame (the "phone") ───────────────────────────────
    local Root = New("Frame", {
        Name = "Window",
        Size = UDim2.new(0, winWidth, 0, winHeight),
        Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2),
        BackgroundColor3 = Theme.BGSecondary,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    Corner(Theme.RadiusXL, Root)
    Stroke(Theme.Separator, 1, Root, 0.4)

    -- Drop shadow simulation
    New("ImageLabel", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = Root,
    })

    -- ── Title Bar ─────────────────────────────────────────────
    local TitleBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.BGSecondary,
        Parent = Root,
    })
    -- Bottom separator line
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 0.3,
        Parent = TitleBar,
    })

    -- Accent dot
    New("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 16, 0.5, -4),
        BackgroundColor3 = accent,
        Parent = TitleBar,
    }){ [1] = Corner(Theme.RadiusPill) }

    New("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = winTitle,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Theme.Font,
        TextSize = 15,
        Parent = TitleBar,
    })

    if subtitle ~= "" then
        New("TextLabel", {
            Size = UDim2.new(0, 120, 1, 0),
            Position = UDim2.new(1, -130, 0, 0),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = Theme.TextSecondary,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Theme.FontReg,
            TextSize = 11,
            Parent = TitleBar,
        })
    end

    -- Close button
    local CloseBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = Theme.Red,
        Text = "✕",
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        Font = Theme.Font,
        Parent = TitleBar,
    })
    Corner(Theme.RadiusPill, CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Root, { Size = UDim2.new(0, winWidth, 0, 0), BackgroundTransparency = 1 }, 0.25)
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end)

    -- Minimize button
    local MinBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -72, 0.5, -14),
        BackgroundColor3 = Theme.Orange,
        Text = "−",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Theme.Font,
        Parent = TitleBar,
    })
    Corner(Theme.RadiusPill, MinBtn)
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Root, { Size = UDim2.new(0, winWidth, 0, 52) }, 0.3, Enum.EasingStyle.Quart)
        else
            Tween(Root, { Size = UDim2.new(0, winWidth, 0, winHeight) }, 0.3, Enum.EasingStyle.Quart)
        end
    end)

    -- ── Tab Bar ───────────────────────────────────────────────
    local TabBar = New("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = Theme.BG,
        ClipsDescendants = true,
        Parent = Root,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 0.3,
        Parent = TabBar,
    })
    local TabScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 1, 0),
        Parent = TabBar,
    })
    local TabList = ListLayout(Enum.FillDirection.Horizontal, 0, TabScroll)
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 1, 0)
    end)

    -- ── Content Area ─────────────────────────────────────────
    local ContentArea = New("ScrollingFrame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -92),
        Position = UDim2.new(0, 0, 0, 92),
        BackgroundColor3 = Theme.BG,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Separator,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Root,
    })

    -- ── Dragging ─────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Window object ─────────────────────────────────────────
    local Window = {}
    local tabs = {}
    local activeTab = nil

    -- Entrance animation
    Root.Size = UDim2.new(0, winWidth, 0, 0)
    Root.BackgroundTransparency = 1
    task.defer(function()
        Tween(Root, {
            Size = UDim2.new(0, winWidth, 0, winHeight),
            BackgroundTransparency = 0,
        }, 0.4, Enum.EasingStyle.Back)
    end)

    -- ── ADD TAB ───────────────────────────────────────────────
    function Window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or ("Tab " .. #tabs + 1)
        local tabIcon = tabOptions.Icon or ""

        -- Tab button
        local TabBtn = New("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabScroll,
        })
        Padding(0, 16, 0, 16, TabBtn)

        local TabInner = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = TabBtn,
        })
        ListLayout(Enum.FillDirection.Horizontal, 5, TabInner, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

        if tabIcon ~= "" then
            New("TextLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Text = tabIcon,
                TextScaled = true,
                Font = Theme.Font,
                Parent = TabInner,
            })
        end

        local TabLabel = New("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextSecondary,
            TextTransparency = 0.4,
            Font = Theme.FontSemi,
            TextSize = 13,
            Parent = TabInner,
        })

        -- Active indicator
        local Indicator = New("Frame", {
            Size = UDim2.new(0, 0, 0, 2),
            Position = UDim2.new(0.5, 0, 1, -2),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = accent,
            Parent = TabBtn,
        })
        Corner(Theme.RadiusPill, Indicator)

        -- Tab page (ScrollingFrame inside ContentArea)
        local Page = New("ScrollingFrame", {
            Name = tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Separator,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentArea,
        })
        Padding(10, 12, 14, 12, Page)

        local PageList = ListLayout(Enum.FillDirection.Vertical, 8, Page)
        SizeToContent(Page, PageList, 24)
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 24)
        end)

        local tabData = {
            Button    = TabBtn,
            Label     = TabLabel,
            Indicator = Indicator,
            Page      = Page,
        }
        table.insert(tabs, tabData)

        local function Activate()
            -- Deactivate all
            for _, t in ipairs(tabs) do
                t.Page.Visible = false
                Tween(t.Label, { TextColor3 = Theme.TextSecondary, TextTransparency = 0.4 }, 0.15)
                Tween(t.Indicator, { Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -2) }, 0.2, Enum.EasingStyle.Quart)
            end
            -- Activate this
            tabData.Page.Visible = true
            Tween(TabLabel, { TextColor3 = accent, TextTransparency = 0 }, 0.15)
            Tween(Indicator, {
                Size = UDim2.new(1, -20, 0, 2),
                Position = UDim2.new(0, 10, 1, -2)
            }, 0.25, Enum.EasingStyle.Back)
            activeTab = tabData
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        if #tabs == 1 then Activate() end

        -- ════════════════════════════════════════════════
        --  TAB OBJECT  (component builders)
        -- ════════════════════════════════════════════════
        local Tab = {}

        -- ── SECTION LABEL ───────────────────────────────
        function Tab:AddSection(label)
            local Frame = New("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = Page,
            })
            Padding(4, 4, 0, 4, Frame)
            New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = (label or ""):upper(),
                TextColor3 = Theme.TextSecondary,
                TextTransparency = 0.45,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontSemi,
                TextSize = 11,
                Parent = Frame,
            })
        end

        -- ── LABEL ───────────────────────────────────────
        function Tab:AddLabel(text, color)
            local lbl = New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text or "",
                TextColor3 = color or Theme.TextSecondary,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 13,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Page,
            })
            return { SetText = function(_, t) lbl.Text = t end }
        end

        -- ── BUTTON ──────────────────────────────────────
        function Tab:AddButton(opts)
            opts = opts or {}
            local btnLabel    = opts.Title or "Button"
            local btnIcon     = opts.Icon  or ""
            local btnStyle    = opts.Style or "Primary"
            local callback    = opts.Callback or function() end

            local styleColors = {
                Primary   = { bg = accent,       text = Theme.TextPrimary },
                Secondary = { bg = Theme.BGTertiary, text = accent },
                Danger    = { bg = Theme.Red,     text = Theme.TextPrimary },
                Success   = { bg = Theme.Green,   text = Theme.TextPrimary },
                Outline   = { bg = Color3.fromRGB(0,0,0), text = accent },
            }
            local sc = styleColors[btnStyle] or styleColors.Primary

            local Btn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = sc.bg,
                BackgroundTransparency = (btnStyle == "Outline") and 1 or 0,
                Text = (btnIcon ~= "" and btnIcon .. "  " or "") .. btnLabel,
                TextColor3 = sc.text,
                Font = Theme.FontSemi,
                TextSize = 14,
                Parent = Page,
            })
            Corner(Theme.RadiusXL, Btn)

            if btnStyle == "Outline" then
                Stroke(accent, 1.5, Btn, 0)
            end

            -- Press animation
            Btn.MouseButton1Down:Connect(function()
                Spring(Btn, { Size = UDim2.new(1, -8, 0, 40) }, 0.2)
            end)
            Btn.MouseButton1Up:Connect(function()
                Spring(Btn, { Size = UDim2.new(1, 0, 0, 42) }, 0.25)
            end)
            Btn.MouseButton1Click:Connect(function()
                callback()
            end)

            HoverEffect(Btn, sc.bg, Theme.BGElevated)
            return Btn
        end

        -- ── TOGGLE ──────────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local togTitle = opts.Title   or "Toggle"
            local togDesc  = opts.Description or ""
            local default  = opts.Default or false
            local callback = opts.Callback or function() end
            local togAccent = opts.Accent or Theme.Green

            local value = default

            local Row = New("Frame", {
                Size = UDim2.new(1, 0, 0, togDesc ~= "" and 54 or 44),
                BackgroundColor3 = Theme.BGSecondary,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Row)
            Stroke(Theme.Separator, 1, Row, 0.6)
            Padding(0, 14, 0, 14, Row)

            New("TextLabel", {
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.new(0, 0, 0.5, togDesc ~= "" and -14 or -9),
                BackgroundTransparency = 1,
                Text = togTitle,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 15,
                Parent = Row,
            })

            if togDesc ~= "" then
                New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14),
                    Position = UDim2.new(0, 0, 0.5, 4),
                    BackgroundTransparency = 1,
                    Text = togDesc,
                    TextColor3 = Theme.TextSecondary,
                    TextTransparency = 0.4,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Theme.FontReg,
                    TextSize = 12,
                    Parent = Row,
                })
            end

            -- Switch track
            local Track = New("Frame", {
                Size = UDim2.new(0, 50, 0, 30),
                Position = UDim2.new(1, -50, 0.5, -15),
                BackgroundColor3 = value and togAccent or Theme.BGElevated,
                Parent = Row,
            })
            Corner(Theme.RadiusPill, Track)

            -- Thumb
            local Thumb = New("Frame", {
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(0, value and 22 or 2, 0.5, -13),
                BackgroundColor3 = Theme.TextPrimary,
                Parent = Track,
            })
            Corner(Theme.RadiusPill, Thumb)
            -- Thumb shadow
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,220)),
                }),
                Rotation = 90,
                Parent = Thumb,
            })

            local function UpdateVisual()
                Tween(Track, { BackgroundColor3 = value and togAccent or Theme.BGElevated }, 0.2)
                Spring(Thumb, {
                    Position = UDim2.new(0, value and 22 or 2, 0.5, -13)
                }, 0.3)
            end

            -- Clickable area
            local ClickArea = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Row,
            })
            ClickArea.MouseButton1Click:Connect(function()
                value = not value
                UpdateVisual()
                callback(value)
            end)

            UpdateVisual()

            local togObj = {}
            function togObj:Set(v)
                value = v
                UpdateVisual()
                callback(value)
            end
            function togObj:Get() return value end
            return togObj
        end

        -- ── SLIDER ──────────────────────────────────────
        function Tab:AddSlider(opts)
            opts = opts or {}
            local sTitle    = opts.Title    or "Slider"
            local sMin      = opts.Min      or 0
            local sMax      = opts.Max      or 100
            local sDefault  = opts.Default  or sMin
            local sStep     = opts.Step     or 1
            local callback  = opts.Callback or function() end
            local sAccent   = opts.Accent   or accent

            local value = sDefault

            local Card = New("Frame", {
                Size = UDim2.new(1, 0, 0, 62),
                BackgroundColor3 = Theme.BGSecondary,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Card)
            Stroke(Theme.Separator, 1, Card, 0.6)
            Padding(10, 14, 10, 14, Card)

            local TopRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Parent = Card,
            })
            New("TextLabel", {
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sTitle,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 14,
                Parent = TopRow,
            })
            local ValLabel = New("TextLabel", {
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = sAccent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Theme.Font,
                TextSize = 13,
                Parent = TopRow,
            })

            -- Track background
            local TrackBG = New("Frame", {
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 1, -6),
                BackgroundColor3 = Theme.BGElevated,
                Parent = Card,
            })
            Corner(Theme.RadiusPill, TrackBG)

            -- Fill
            local Fill = New("Frame", {
                Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0),
                BackgroundColor3 = sAccent,
                Parent = TrackBG,
            })
            Corner(Theme.RadiusPill, Fill)

            -- Thumb
            local pct = (value - sMin) / (sMax - sMin)
            local Thumb = New("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(pct, -10, 0.5, -10),
                BackgroundColor3 = Theme.TextPrimary,
                ZIndex = 2,
                Parent = TrackBG,
            })
            Corner(Theme.RadiusPill, Thumb)

            -- Drag logic
            local sliding = false

            local function UpdateSlider(absX)
                local trackPos  = TrackBG.AbsolutePosition.X
                local trackSize = TrackBG.AbsoluteSize.X
                local rel = math.clamp((absX - trackPos) / trackSize, 0, 1)
                local raw = sMin + (sMax - sMin) * rel
                local stepped = math.round(raw / sStep) * sStep
                value = math.clamp(stepped, sMin, sMax)
                local newPct = (value - sMin) / (sMax - sMin)
                Fill.Size = UDim2.new(newPct, 0, 1, 0)
                Thumb.Position = UDim2.new(newPct, -10, 0.5, -10)
                ValLabel.Text = tostring(value)
                callback(value)
            end

            TrackBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            local slObj = {}
            function slObj:Set(v)
                value = math.clamp(v, sMin, sMax)
                local newPct = (value - sMin) / (sMax - sMin)
                Tween(Fill, { Size = UDim2.new(newPct, 0, 1, 0) }, 0.15)
                Thumb.Position = UDim2.new(newPct, -10, 0.5, -10)
                ValLabel.Text = tostring(value)
                callback(value)
            end
            function slObj:Get() return value end
            return slObj
        end

        -- ── DROPDOWN ────────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local dTitle    = opts.Title   or "Dropdown"
            local dOptions  = opts.Options or {}
            local dDefault  = opts.Default or dOptions[1]
            local callback  = opts.Callback or function() end
            local dAccent   = opts.Accent  or accent

            local value = dDefault
            local open  = false

            local Wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                Parent = Page,
            })

            local Header = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.BGSecondary,
                Text = "",
                Parent = Wrap,
            })
            Corner(Theme.RadiusMD, Header)
            Stroke(Theme.Separator, 1, Header, 0.6)
            Padding(0, 14, 0, 14, Header)

            New("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = dTitle,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 14,
                Parent = Header,
            })

            local SelectedLabel = New("TextLabel", {
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = value or "Select…",
                TextColor3 = dAccent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Theme.FontSemi,
                TextSize = 13,
                Parent = Header,
            })

            local ChevronLabel = New("TextLabel", {
                Size = UDim2.new(0, 14, 1, 0),
                Position = UDim2.new(1, -14, 0, 0),
                BackgroundTransparency = 1,
                Text = "›",
                TextColor3 = Theme.TextSecondary,
                TextTransparency = 0.4,
                TextXAlignment = Enum.TextXAlignment.Center,
                Font = Theme.Font,
                TextSize = 18,
                Parent = Header,
            })

            -- Dropdown list
            local DropList = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.BGTertiary,
                ClipsDescendants = true,
                ZIndex = 5,
                Parent = Wrap,
            })
            Corner(Theme.RadiusMD, DropList)
            Stroke(Theme.Separator, 1, DropList, 0.4)

            local DropScroll = New("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Separator,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ZIndex = 5,
                Parent = DropList,
            })
            local DropListLayout = ListLayout(Enum.FillDirection.Vertical, 0, DropScroll)
            DropListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropListLayout.AbsoluteContentSize.Y)
            end)

            for _, opt in ipairs(dOptions) do
                local ItemBtn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 6,
                    Parent = DropScroll,
                })
                Padding(0, 14, 0, 14, ItemBtn)
                New("Frame", {
                    Size = UDim2.new(1, 0, 0, 0.5),
                    Position = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.Separator,
                    BackgroundTransparency = 0.5,
                    ZIndex = 6,
                    Parent = ItemBtn,
                })
                New("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(opt),
                    TextColor3 = opt == value and dAccent or Theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = opt == value and Theme.FontSemi or Theme.FontReg,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = ItemBtn,
                })
                ItemBtn.MouseButton1Click:Connect(function()
                    value = opt
                    SelectedLabel.Text = tostring(opt)
                    callback(opt)
                    -- Close
                    open = false
                    local count = math.min(#dOptions, 5)
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                    Tween(Wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
                    Tween(ChevronLabel, { Rotation = 0 }, 0.2)
                end)
                HoverEffect(ItemBtn, Color3.fromRGB(0,0,0), Theme.BGElevated)
            end

            Header.MouseButton1Click:Connect(function()
                open = not open
                local count = math.min(#dOptions, 5)
                local listH = count * 36
                if open then
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, listH) }, 0.25, Enum.EasingStyle.Back)
                    Tween(Wrap, { Size = UDim2.new(1, 0, 0, 44 + listH + 4) }, 0.25, Enum.EasingStyle.Back)
                    Tween(ChevronLabel, { Rotation = 90 }, 0.2)
                else
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                    Tween(Wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
                    Tween(ChevronLabel, { Rotation = 0 }, 0.2)
                end
            end)

            local ddObj = {}
            function ddObj:Set(v)
                value = v
                SelectedLabel.Text = tostring(v)
                callback(v)
            end
            function ddObj:Get() return value end
            return ddObj
        end

        -- ── TEXT INPUT ──────────────────────────────────
        function Tab:AddInput(opts)
            opts = opts or {}
            local iTitle       = opts.Title       or "Input"
            local iPlaceholder = opts.Placeholder or "Type here…"
            local iDefault     = opts.Default     or ""
            local callback     = opts.Callback    or function() end
            local iAccent      = opts.Accent      or accent

            local Card = New("Frame", {
                Size = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = Theme.BGSecondary,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Card)
            Stroke(Theme.Separator, 1, Card, 0.6)
            Padding(8, 14, 8, 14, Card)

            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Text = iTitle,
                TextColor3 = Theme.TextSecondary,
                TextTransparency = 0.35,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontSemi,
                TextSize = 11,
                Parent = Card,
            })

            local InputBox = New("TextBox", {
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Theme.BGTertiary,
                Text = iDefault,
                PlaceholderText = iPlaceholder,
                PlaceholderColor3 = Theme.TextTertiary,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 14,
                ClearTextOnFocus = false,
                Parent = Card,
            })
            Corner(Theme.RadiusSM, InputBox)
            Padding(0, 8, 0, 8, InputBox)
            local inputStroke = Stroke(Theme.Separator, 1, InputBox, 0.5)

            InputBox.Focused:Connect(function()
                Tween(inputStroke, { Color = iAccent, Transparency = 0 }, 0.15)
            end)
            InputBox.FocusLost:Connect(function(enter)
                Tween(inputStroke, { Color = Theme.Separator, Transparency = 0.5 }, 0.15)
                if enter then callback(InputBox.Text) end
            end)

            local inObj = {}
            function inObj:Get() return InputBox.Text end
            function inObj:Set(v) InputBox.Text = v end
            return inObj
        end

        -- ── COLOR PICKER (simplified swatch picker) ─────
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local cpTitle    = opts.Title    or "Color"
            local cpDefault  = opts.Default  or Theme.Blue
            local callback   = opts.Callback or function() end

            local colors = {
                Color3.fromRGB(10,132,255),  Color3.fromRGB(48,209,88),
                Color3.fromRGB(255,69,58),   Color3.fromRGB(255,159,10),
                Color3.fromRGB(191,90,242),  Color3.fromRGB(90,200,250),
                Color3.fromRGB(255,214,10),  Color3.fromRGB(255,255,255),
            }

            local Card = New("Frame", {
                Size = UDim2.new(1, 0, 0, 68),
                BackgroundColor3 = Theme.BGSecondary,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Card)
            Stroke(Theme.Separator, 1, Card, 0.6)
            Padding(10, 14, 10, 14, Card)

            New("TextLabel", {
                Size = UDim2.new(0.5, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = cpTitle,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 14,
                Parent = Card,
            })

            local SwatchRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = Card,
            })
            ListLayout(Enum.FillDirection.Horizontal, 6, SwatchRow)

            local selectedSwatch = nil

            for _, c in ipairs(colors) do
                local sw = New("TextButton", {
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundColor3 = c,
                    Text = "",
                    Parent = SwatchRow,
                })
                Corner(Theme.RadiusPill, sw)
                if c == cpDefault then
                    Stroke(Theme.TextPrimary, 2, sw, 0)
                    selectedSwatch = sw
                end
                sw.MouseButton1Click:Connect(function()
                    if selectedSwatch then
                        local existingStroke = selectedSwatch:FindFirstChildOfClass("UIStroke")
                        if existingStroke then existingStroke:Destroy() end
                    end
                    Stroke(Theme.TextPrimary, 2, sw, 0)
                    selectedSwatch = sw
                    callback(c)
                end)
            end

            local cpObj = {}
            function cpObj:Get()
                return selectedSwatch and selectedSwatch.BackgroundColor3 or cpDefault
            end
            return cpObj
        end

        -- ── DIVIDER ─────────────────────────────────────
        function Tab:AddDivider()
            New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Separator,
                BackgroundTransparency = 0.4,
                Parent = Page,
            })
        end

        -- ── KEYBIND ─────────────────────────────────────
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local kTitle    = opts.Title    or "Keybind"
            local kDefault  = opts.Default  or Enum.KeyCode.RightShift
            local callback  = opts.Callback or function() end

            local key = kDefault
            local listening = false

            local Row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.BGSecondary,
                Parent = Page,
            })
            Corner(Theme.RadiusMD, Row)
            Stroke(Theme.Separator, 1, Row, 0.6)
            Padding(0, 14, 0, 14, Row)

            New("TextLabel", {
                Size = UDim2.new(0.55, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = kTitle,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.FontReg,
                TextSize = 14,
                Parent = Row,
            })

            local KeyBtn = New("TextButton", {
                Size = UDim2.new(0, 80, 0, 28),
                Position = UDim2.new(1, -80, 0.5, -14),
                BackgroundColor3 = Theme.BGElevated,
                Text = key.Name,
                TextColor3 = accent,
                Font = Theme.FontSemi,
                TextSize = 12,
                Parent = Row,
            })
            Corner(Theme.RadiusSM, KeyBtn)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "…"
                Tween(KeyBtn, { BackgroundColor3 = accent }, 0.15)
                Tween(KeyBtn, { TextColor3 = Theme.TextPrimary }, 0.15)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = input.KeyCode
                    KeyBtn.Text = key.Name
                    Tween(KeyBtn, { BackgroundColor3 = Theme.BGElevated }, 0.15)
                    Tween(KeyBtn, { TextColor3 = accent }, 0.15)
                end
                if not processed and input.KeyCode == key then
                    callback(key)
                end
            end)

            local kbObj = {}
            function kbObj:Get() return key end
            return kbObj
        end

        return Tab
    end -- AddTab

    -- ── SHOW / HIDE ───────────────────────────────────────────
    function Window:Toggle()
        Root.Visible = not Root.Visible
    end
    function Window:Hide()
        Tween(Root, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.25, function() Root.Visible = false end)
    end
    function Window:Show()
        Root.Visible = true
        Tween(Root, { BackgroundTransparency = 0 }, 0.2)
    end
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return PhoneUI

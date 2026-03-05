--[[
    ██████╗ ██╗  ██╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗██╗
    ██╔══██╗██║  ██║██╔═══██╗████╗  ██║██╔════╝██║   ██║██║
    ██████╔╝███████║██║   ██║██╔██╗ ██║█████╗  ██║   ██║██║
    ██╔═══╝ ██╔══██║██║   ██║██║╚██╗██║██╔══╝  ██║   ██║██║
    ██║     ██║  ██║╚██████╔╝██║ ╚████║███████╗╚██████╔╝██║
    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝

    PhoneUI  —  iPhone Dark Theme UI Library for Roblox
    Version  :  2.0.0
    GitHub   :  https://raw.githubusercontent.com/crackacheeky/phonelib/refs/heads/main/main.lua
--]]

-- ─────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local GuiParent
do
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    GuiParent = (ok and cg) or LocalPlayer:WaitForChild("PlayerGui")
end

-- ─────────────────────────────────────────────────────────────
--  THEME
-- ─────────────────────────────────────────────────────────────
local T = {
    B0  = Color3.fromRGB(  0,  0,  0),
    B1  = Color3.fromRGB( 18, 18, 20),
    B2  = Color3.fromRGB( 28, 28, 30),
    B3  = Color3.fromRGB( 44, 44, 46),
    B4  = Color3.fromRGB( 58, 58, 60),
    Sep = Color3.fromRGB( 56, 56, 58),

    Blue   = Color3.fromRGB( 10,132,255),
    Green  = Color3.fromRGB( 48,209, 88),
    Red    = Color3.fromRGB(255, 69, 58),
    Orange = Color3.fromRGB(255,159, 10),
    Purple = Color3.fromRGB(191, 90,242),
    Teal   = Color3.fromRGB( 90,200,250),
    Yellow = Color3.fromRGB(255,214, 10),
    White  = Color3.fromRGB(255,255,255),

    T1 = Color3.fromRGB(255,255,255),
    T2 = Color3.fromRGB(170,170,180),
    T3 = Color3.fromRGB( 90, 90,100),

    R4  = UDim.new(0, 4),
    R8  = UDim.new(0, 8),
    R12 = UDim.new(0,12),
    R16 = UDim.new(0,16),
    R20 = UDim.new(0,20),
    Roo = UDim.new(1, 0),

    FB = Enum.Font.GothamBold,
    FS = Enum.Font.GothamSemibold,
    FR = Enum.Font.Gotham,
}

-- ─────────────────────────────────────────────────────────────
--  TWEEN HELPERS
-- ─────────────────────────────────────────────────────────────
local function tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end
local function spring(obj, props, t) tw(obj,props,t or 0.4,Enum.EasingStyle.Back,   Enum.EasingDirection.Out) end
local function linear(obj, props, t) tw(obj,props,t or 0.2,Enum.EasingStyle.Linear, Enum.EasingDirection.Out) end
local function smooth(obj, props, t) tw(obj,props,t or 0.25,Enum.EasingStyle.Sine,  Enum.EasingDirection.Out) end

-- ─────────────────────────────────────────────────────────────
--  FACTORIES
-- ─────────────────────────────────────────────────────────────
local function New(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end

local function Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or T.R12
    c.Parent = p
    return c
end

local function Stroke(col, thick, p, trans)
    local s = Instance.new("UIStroke")
    s.Color        = col   or T.Sep
    s.Thickness    = thick or 1
    s.Transparency = trans or 0
    s.Parent       = p
    return s
end

local function Pad(top, right, bottom, left, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, top   or 0)
    pad.PaddingRight  = UDim.new(0, right or 0)
    pad.PaddingBottom = UDim.new(0,bottom or 0)
    pad.PaddingLeft   = UDim.new(0, left  or 0)
    pad.Parent = p
    return pad
end

local function VList(gap, p)
    local l = Instance.new("UIListLayout")
    l.FillDirection       = Enum.FillDirection.Vertical
    l.Padding             = UDim.new(0, gap or 0)
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = p
    return l
end

local function HList(gap, p)
    local l = Instance.new("UIListLayout")
    l.FillDirection     = Enum.FillDirection.Horizontal
    l.Padding           = UDim.new(0, gap or 0)
    l.SortOrder         = Enum.SortOrder.LayoutOrder
    l.VerticalAlignment = Enum.VerticalAlignment.Center
    l.Parent = p
    return l
end

local function Ripple(parent, col)
    local r = New("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = col or T.White,
        BackgroundTransparency = 0.72,
        ZIndex = parent.ZIndex + 10,
        Parent = parent,
    })
    Corner(T.Roo, r)
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.4
    spring(r, {Size=UDim2.new(0,sz,0,sz), BackgroundTransparency=1}, 0.5)
    task.delay(0.55, function() r:Destroy() end)
end

local function Hover(btn, base, over)
    btn.MouseEnter:Connect(function()       tw(btn,{BackgroundColor3=over},0.15) end)
    btn.MouseLeave:Connect(function()       tw(btn,{BackgroundColor3=base},0.15) end)
    btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=T.B4},0.08); Ripple(btn,over) end)
    btn.MouseButton1Up:Connect(function()   tw(btn,{BackgroundColor3=over},0.12) end)
end

-- ─────────────────────────────────────────────────────────────
--  NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────────────────────
local NotifSG, NotifHolder

local function EnsureNotifs()
    if NotifSG and NotifSG.Parent then return end
    NotifSG = New("ScreenGui", {
        Name="PhoneUI_Notifs", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=999, Parent=GuiParent,
    })
    NotifHolder = New("Frame", {
        Name="NotifHolder",
        Size=UDim2.new(0,290,1,0),
        Position=UDim2.new(1,-300,0,0),
        BackgroundTransparency=1,
        Parent=NotifSG,
    })
    local l = VList(8,NotifHolder)
    l.VerticalAlignment = Enum.VerticalAlignment.Top
    Pad(20,0,20,0,NotifHolder)
end

-- ─────────────────────────────────────────────────────────────
--  LIBRARY
-- ─────────────────────────────────────────────────────────────
local PhoneUI = {}
PhoneUI.__index = PhoneUI

function PhoneUI:Notify(o)
    o = o or {}
    local title    = o.Title    or "PhoneUI"
    local body     = o.Body     or ""
    local icon     = o.Icon     or "📱"
    local duration = o.Duration or 4
    local accent   = o.Accent   or T.Blue

    EnsureNotifs()

    local card = New("Frame", {
        Name="NotifCard",
        Size=UDim2.new(1,0,0,66),
        BackgroundColor3=T.B3,
        ClipsDescendants=true,
        Parent=NotifHolder,
    })
    Corner(T.R16,card)
    Stroke(accent,1,card,0.55)

    local bar = New("Frame", {Size=UDim2.new(0,3,1,0), BackgroundColor3=accent, Parent=card})
    Corner(T.Roo,bar)

    local inner = New("Frame", {
        Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1, Parent=card,
    })
    Pad(10,10,10,6,inner)
    HList(10,inner)

    local iBox = New("Frame", {Size=UDim2.new(0,34,0,34), BackgroundColor3=accent, BackgroundTransparency=0.78, Parent=inner})
    Corner(T.R8,iBox)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,TextScaled=true,Font=T.FB,Parent=iBox})

    local tc = New("Frame", {Size=UDim2.new(1,-44,1,0),BackgroundTransparency=1,Parent=inner})
    VList(3,tc)
    New("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=title,TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FS,TextSize=13,Parent=tc})
    New("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text=body,TextColor3=T.T2,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,Parent=tc})

    local pb = New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=accent,Parent=card})
    Corner(T.Roo,pb)

    card.Position = UDim2.new(1,20,0,0)
    smooth(card,{Position=UDim2.new(0,0,0,0)},0.38)
    linear(pb,{Size=UDim2.new(0,0,0,2)},duration)

    task.delay(duration,function()
        smooth(card,{Position=UDim2.new(1,20,0,0),BackgroundTransparency=1},0.28)
        task.delay(0.32,function() card:Destroy() end)
    end)
end

-- ─────────────────────────────────────────────────────────────
--  CREATE WINDOW
-- ─────────────────────────────────────────────────────────────
function PhoneUI:CreateWindow(o)
    o = o or {}
    local title  = o.Title    or "PhoneUI"
    local sub    = o.Subtitle or ""
    local accent = o.Accent   or T.Blue
    local W      = o.Width    or 340
    local H      = o.Height   or 480

    local SG = New("ScreenGui",{
        Name="PhoneUI_"..title, ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=50, Parent=GuiParent,
    })

    local Root = New("Frame",{
        Name="Root",
        Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=T.B1,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=SG,
    })
    Corner(T.R20,Root)
    Stroke(T.Sep,1,Root,0.25)

    -- depth gradient
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(36,36,40)),
            ColorSequenceKeypoint.new(1,T.B1),
        }),
        Rotation=135, Parent=Root,
    })

    -- ── TITLE BAR ────────────────────────────────────────────
    -- height: 48px
    local TBar = New("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundColor3=T.B2,
        BorderSizePixel=0,
        ZIndex=5, Parent=Root,
    })
    Corner(T.R20,TBar)
    -- fill bottom-half corners to square them
    New("Frame",{
        Size=UDim2.new(1,0,0,T.R20.Offset),
        Position=UDim2.new(0,0,1,-T.R20.Offset),
        BackgroundColor3=T.B2,
        BorderSizePixel=0,
        ZIndex=5, Parent=TBar,
    })
    -- separator line
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Sep,
        BorderSizePixel=0,
        ZIndex=6, Parent=TBar,
    })

    -- Traffic lights
    local function TrafficLight(xOff, col, sym)
        local btn = New("TextButton",{
            Size=UDim2.new(0,14,0,14),
            Position=UDim2.new(0,xOff,0.5,-7),
            BackgroundColor3=col,
            Text="", ZIndex=8, Parent=TBar,
        })
        Corner(T.Roo,btn)
        local lbl = New("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text=sym, TextColor3=Color3.fromRGB(60,10,10),
            TextScaled=true, Font=T.FB,
            TextTransparency=1, ZIndex=9, Parent=btn,
        })
        btn.MouseEnter:Connect(function()
            tw(btn,{BackgroundColor3=col:lerp(T.White,0.3)},0.1)
            tw(lbl,{TextTransparency=0},0.1)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn,{BackgroundColor3=col},0.1)
            tw(lbl,{TextTransparency=1},0.1)
        end)
        return btn
    end

    local CloseBtn = TrafficLight(14, T.Red,    "✕")
    local MinBtn   = TrafficLight(34, T.Orange, "−")

    CloseBtn.MouseButton1Click:Connect(function()
        smooth(Root,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.22)
        task.delay(0.25,function() SG:Destroy() end)
    end)

    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            smooth(Root,{Size=UDim2.new(0,W,0,48)},0.25)
        else
            spring(Root,{Size=UDim2.new(0,W,0,H)},0.42)
        end
    end)

    -- pulsing accent dot
    local dot = New("Frame",{
        Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0,58,0.5,-4),
        BackgroundColor3=accent,
        ZIndex=7, Parent=TBar,
    })
    Corner(T.Roo,dot)
    task.spawn(function()
        while dot and dot.Parent do
            tw(dot,{BackgroundTransparency=0.5},0.9,Enum.EasingStyle.Sine)
            task.wait(0.95)
            tw(dot,{BackgroundTransparency=0},0.9,Enum.EasingStyle.Sine)
            task.wait(0.95)
        end
    end)

    New("TextLabel",{
        Size=UDim2.new(1,-130,1,0),
        Position=UDim2.new(0,72,0,0),
        BackgroundTransparency=1,
        Text=title, TextColor3=T.T1,
        TextXAlignment=Enum.TextXAlignment.Left,
        Font=T.FB, TextSize=14,
        ZIndex=7, Parent=TBar,
    })
    if sub ~= "" then
        New("TextLabel",{
            Size=UDim2.new(0,64,1,0),
            Position=UDim2.new(1,-70,0,0),
            BackgroundTransparency=1,
            Text=sub, TextColor3=T.T3,
            TextXAlignment=Enum.TextXAlignment.Right,
            Font=T.FR, TextSize=10,
            ZIndex=7, Parent=TBar,
        })
    end

    -- ── TAB BAR ──────────────────────────────────────────────
    -- y=48, height=38
    local TabBar = New("Frame",{
        Size=UDim2.new(1,0,0,38),
        Position=UDim2.new(0,0,0,48),
        BackgroundColor3=T.B2,
        BorderSizePixel=0,
        ZIndex=4, ClipsDescendants=true, Parent=Root,
    })
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Sep,
        BorderSizePixel=0,
        ZIndex=5, Parent=TabBar,
    })
    local TabScroll = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=0,
        ScrollingDirection=Enum.ScrollingDirection.X,
        CanvasSize=UDim2.new(0,0,1,0),
        ZIndex=5, Parent=TabBar,
    })
    local TabLayout = HList(0,TabScroll)
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize=UDim2.new(0,TabLayout.AbsoluteContentSize.X,1,0)
    end)

    -- ── CONTENT SCROLL ───────────────────────────────────────
    -- y=86 (48+38), fills rest
    local ContentScroll = New("ScrollingFrame",{
        Name="ContentScroll",
        Size=UDim2.new(1,0,1,-86),
        Position=UDim2.new(0,0,0,86),
        BackgroundColor3=T.B1,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=T.B4,
        CanvasSize=UDim2.new(0,0,0,0),
        ZIndex=2, Parent=Root,
    })

    -- ── DRAG ─────────────────────────────────────────────────
    local drag,dSt,rSt=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; dSt=i.Position; rSt=Root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dSt
            Root.Position=UDim2.new(rSt.X.Scale,rSt.X.Offset+d.X,rSt.Y.Scale,rSt.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)

    -- ── WINDOW OBJECT ────────────────────────────────────────
    local Window   = {}
    local allTabs  = {}
    local active   = nil

    Root.Size=UDim2.new(0,W,0,0)
    Root.BackgroundTransparency=1
    task.defer(function()
        tw(Root,{BackgroundTransparency=0},0.2)
        spring(Root,{Size=UDim2.new(0,W,0,H)},0.45)
    end)

    -- ─────────────────────────────────────────────────────────
    --  ADD TAB
    -- ─────────────────────────────────────────────────────────
    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tName = tabOpts.Name or ("Tab "..#allTabs+1)
        local tIcon = tabOpts.Icon or ""

        local TBtn = New("TextButton",{
            Size=UDim2.new(0,0,1,0),
            AutomaticSize=Enum.AutomaticSize.X,
            BackgroundTransparency=1,
            Text="", ZIndex=6, Parent=TabScroll,
        })
        Pad(0,14,0,14,TBtn)

        local TInner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Parent=TBtn})
        HList(5,TInner)

        if tIcon~="" then
            New("TextLabel",{Size=UDim2.new(0,14,1,0),BackgroundTransparency=1,Text=tIcon,TextScaled=true,Font=T.FB,ZIndex=6,Parent=TInner})
        end

        local TLabel=New("TextLabel",{
            Size=UDim2.new(0,0,1,0),
            AutomaticSize=Enum.AutomaticSize.X,
            BackgroundTransparency=1,
            Text=tName, TextColor3=T.T3,
            Font=T.FS, TextSize=12,
            ZIndex=6, Parent=TInner,
        })

        local Ind=New("Frame",{
            Size=UDim2.new(0,0,0,2),
            Position=UDim2.new(0.5,0,1,-2),
            AnchorPoint=Vector2.new(0.5,0),
            BackgroundColor3=accent,
            BorderSizePixel=0,
            ZIndex=7, Parent=TBtn,
        })
        Corner(T.Roo,Ind)

        local TBg=New("Frame",{
            Size=UDim2.new(1,0,1,-2),
            BackgroundColor3=accent,
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ZIndex=5, Parent=TBtn,
        })
        Corner(T.R8,TBg)

        local Page=New("Frame",{
            Name=tName,
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Visible=false,
            ZIndex=2, Parent=ContentScroll,
        })
        Pad(10,10,16,10,Page)
        local PList=VList(8,Page)

        PList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Page.Visible then
                ContentScroll.CanvasSize=UDim2.new(0,0,0,PList.AbsoluteContentSize.Y+26)
            end
        end)

        local tabData={Btn=TBtn,Label=TLabel,Ind=Ind,Bg=TBg,Page=Page,List=PList}
        table.insert(allTabs,tabData)

        local function Activate()
            for _,td in ipairs(allTabs) do
                td.Page.Visible=false
                tw(td.Label,{TextColor3=T.T3},0.18)
                tw(td.Ind,{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,-2)},0.22)
                tw(td.Bg,{BackgroundTransparency=1},0.18)
            end
            Page.Visible=true
            ContentScroll.CanvasPosition=Vector2.new(0,0)
            ContentScroll.CanvasSize=UDim2.new(0,0,0,PList.AbsoluteContentSize.Y+26)
            tw(TLabel,{TextColor3=accent},0.18)
            tw(TBg,{BackgroundTransparency=0.88},0.18)
            spring(Ind,{Size=UDim2.new(1,-16,0,2),Position=UDim2.new(0,8,1,-2)},0.38)
            active=tabData
            Page.Position=UDim2.new(0.05,0,0,0)
            tw(Page,{Position=UDim2.new(0,0,0,0)},0.26,Enum.EasingStyle.Quart)
        end

        TBtn.MouseButton1Click:Connect(function()
            if active~=tabData then Activate() end
        end)
        if #allTabs==1 then task.defer(Activate) end

        -- ─────────────────────────────────────────────────────
        --  COMPONENTS
        -- ─────────────────────────────────────────────────────
        local Tab={}

        function Tab:AddSection(label)
            local f=New("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=2,Parent=Page})
            Pad(4,2,0,4,f)
            New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=(label or ""):upper(),TextColor3=T.T3,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FS,TextSize=10,ZIndex=2,Parent=f})
        end

        function Tab:AddLabel(text,col)
            local lbl=New("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=text or "",TextColor3=col or T.T2,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=12,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=Page})
            return{SetText=function(_,t) lbl.Text=t end}
        end

        function Tab:AddDivider()
            New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Sep,BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=2,Parent=Page})
        end

        -- BUTTON ──────────────────────────────────────────────
        function Tab:AddButton(o)
            o=o or {}
            local lbl  = o.Title    or "Button"
            local icon = o.Icon     or ""
            local sty  = o.Style    or "Primary"
            local cb   = o.Callback or function() end

            local pals={
                Primary  ={bg=accent,  txt=T.White, ov=accent:lerp(T.White,0.12)},
                Secondary={bg=T.B3,    txt=accent,  ov=T.B4},
                Danger   ={bg=T.Red,   txt=T.White, ov=T.Red:lerp(T.White,0.15)},
                Success  ={bg=T.Green, txt=T.White, ov=T.Green:lerp(T.White,0.15)},
                Outline  ={bg=T.B1,    txt=accent,  ov=T.B2},
            }
            local pal=pals[sty] or pals.Primary

            local Btn=New("TextButton",{
                Size=UDim2.new(1,0,0,42),
                BackgroundColor3=pal.bg,
                Text=(icon~="" and icon.."  " or "")..lbl,
                TextColor3=pal.txt,
                Font=T.FS, TextSize=13,
                ZIndex=2, Parent=Page,
            })
            Corner(T.R16,Btn)
            if sty=="Outline" then Stroke(accent,1.5,Btn,0) end

            Btn.MouseButton1Down:Connect(function()
                spring(Btn,{Size=UDim2.new(1,-8,0,40)},0.22)
                tw(Btn,{BackgroundTransparency=0.18},0.08)
            end)
            Btn.MouseButton1Up:Connect(function()
                spring(Btn,{Size=UDim2.new(1,0,0,42)},0.3)
                tw(Btn,{BackgroundTransparency=0},0.12)
            end)
            Btn.MouseButton1Click:Connect(function() cb() end)
            Hover(Btn,pal.bg,pal.ov)
            return Btn
        end

        -- TOGGLE ──────────────────────────────────────────────
        function Tab:AddToggle(o)
            o=o or {}
            local lbl  = o.Title       or "Toggle"
            local desc = o.Description or ""
            local val  = o.Default     or false
            local col  = o.Accent      or T.Green
            local cb   = o.Callback    or function() end

            local rowH = desc~="" and 54 or 44

            local Row=New("Frame",{
                Size=UDim2.new(1,0,0,rowH),
                BackgroundColor3=T.B2,
                ZIndex=2, Parent=Page,
            })
            Corner(T.R12,Row)
            local rowStroke=Stroke(T.Sep,1,Row,0.5)
            Pad(0,12,0,14,Row)

            New("TextLabel",{
                Size=UDim2.new(1,-62,0,18),
                Position=UDim2.new(0,0,0.5,desc~="" and -13 or -9),
                BackgroundTransparency=1,
                Text=lbl, TextColor3=T.T1,
                TextXAlignment=Enum.TextXAlignment.Left,
                Font=T.FR, TextSize=14, ZIndex=3, Parent=Row,
            })
            if desc~="" then
                New("TextLabel",{
                    Size=UDim2.new(1,-62,0,13),
                    Position=UDim2.new(0,0,0.5,4),
                    BackgroundTransparency=1,
                    Text=desc, TextColor3=T.T3,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Font=T.FR, TextSize=11, ZIndex=3, Parent=Row,
                })
            end

            local Track=New("Frame",{
                Size=UDim2.new(0,50,0,30),
                Position=UDim2.new(1,-50,0.5,-15),
                BackgroundColor3=val and col or T.B4,
                ZIndex=3, Parent=Row,
            })
            Corner(T.Roo,Track)

            local Thumb=New("Frame",{
                Size=UDim2.new(0,26,0,26),
                Position=UDim2.new(0,val and 22 or 2,0.5,-13),
                BackgroundColor3=T.White,
                ZIndex=5, Parent=Track,
            })
            Corner(T.Roo,Thumb)
            New("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,T.White),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,210)),
                }),
                Rotation=90, Parent=Thumb,
            })

            local function Refresh()
                tw(Track,{BackgroundColor3=val and col or T.B4},0.22)
                if val then
                    tw(rowStroke,{Color=col,Transparency=0.4},0.22)
                    tw(Row,{BackgroundColor3=col:lerp(T.B1,0.88)},0.22)
                else
                    tw(rowStroke,{Color=T.Sep,Transparency=0.5},0.22)
                    tw(Row,{BackgroundColor3=T.B2},0.22)
                end
                spring(Thumb,{Position=UDim2.new(0,val and 22 or 2,0.5,-13)},0.38)
            end

            local CA=New("TextButton",{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                Text="", ZIndex=6, Parent=Row,
            })
            CA.MouseButton1Click:Connect(function()
                val=not val; Refresh(); cb(val)
            end)
            Refresh()

            local obj={}
            function obj:Set(v) val=v; Refresh(); cb(val) end
            function obj:Get() return val end
            return obj
        end

        -- SLIDER ──────────────────────────────────────────────
        function Tab:AddSlider(o)
            o=o or {}
            local lbl  = o.Title    or "Slider"
            local mn   = o.Min      or 0
            local mx   = o.Max      or 100
            local def  = o.Default  or mn
            local step = o.Step     or 1
            local col  = o.Accent   or accent
            local cb   = o.Callback or function() end

            local val=math.clamp(def,mn,mx)

            local Card=New("Frame",{
                Size=UDim2.new(1,0,0,62),
                BackgroundColor3=T.B2,
                ZIndex=2, Parent=Page,
            })
            Corner(T.R12,Card)
            Stroke(T.Sep,1,Card,0.5)
            Pad(9,14,9,14,Card)

            local Top=New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,ZIndex=3,Parent=Card})
            New("TextLabel",{Size=UDim2.new(0.65,0,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=13,ZIndex=3,Parent=Top})
            local ValLbl=New("TextLabel",{Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0.65,0,0,0),BackgroundTransparency=1,Text=tostring(val),TextColor3=col,TextXAlignment=Enum.TextXAlignment.Right,Font=T.FB,TextSize=13,ZIndex=3,Parent=Top})

            -- Large invisible hit area at bottom of card (full width, 28px tall)
            local HitArea=New("TextButton",{
                Size=UDim2.new(1,0,0,28),
                Position=UDim2.new(0,0,1,-28),
                BackgroundTransparency=1,
                Text="", AutoButtonColor=false,
                ZIndex=8, Parent=Card,
            })

            -- Visual track sits centred inside hit area
            local TrackBG=New("Frame",{
                Size=UDim2.new(1,0,0,4),
                Position=UDim2.new(0,0,0.5,-2),
                BackgroundColor3=T.B4,
                ZIndex=4, Parent=HitArea,
            })
            Corner(T.Roo,TrackBG)

            local Fill=New("Frame",{
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=col,
                ZIndex=5, Parent=TrackBG,
            })
            Corner(T.Roo,Fill)

            local pct0=(val-mn)/(mx-mn)
            local Thumb=New("Frame",{
                Size=UDim2.new(0,20,0,20),
                Position=UDim2.new(pct0,-10,0.5,-10),
                BackgroundColor3=T.White,
                ZIndex=6, Parent=TrackBG,
            })
            Corner(T.Roo,Thumb)
            New("UIGradient",{
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.White),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,210))}),
                Rotation=90, Parent=Thumb,
            })

            local sliding=false

            local function UpdateVal(absX)
                local tp=TrackBG.AbsolutePosition.X
                local ts=TrackBG.AbsoluteSize.X
                if ts<=0 then return end
                local rel=math.clamp((absX-tp)/ts,0,1)
                val=math.clamp(math.round((mn+(mx-mn)*rel)/step)*step,mn,mx)
                local p=(val-mn)/(mx-mn)
                Fill.Size=UDim2.new(p,0,1,0)
                Thumb.Position=UDim2.new(p,sliding and -13 or -10,0.5,sliding and -13 or -10)
                ValLbl.Text=tostring(val)
                cb(val)
            end

            local function BeginSlide(inputX)
                sliding=true
                spring(Thumb,{Size=UDim2.new(0,26,0,26)},0.25)
                tw(Card,{BackgroundColor3=col:lerp(T.B1,0.88)},0.18)
                UpdateVal(inputX)
            end
            local function EndSlide()
                sliding=false
                spring(Thumb,{Size=UDim2.new(0,20,0,20)},0.3)
                tw(Card,{BackgroundColor3=T.B2},0.18)
            end

            HitArea.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    BeginSlide(i.Position.X)
                end
            end)
            TrackBG.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    BeginSlide(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    UpdateVal(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                    EndSlide()
                end
            end)

            local obj={}
            function obj:Set(v)
                val=math.clamp(v,mn,mx)
                local p=(val-mn)/(mx-mn)
                tw(Fill,{Size=UDim2.new(p,0,1,0)},0.18)
                Thumb.Position=UDim2.new(p,-10,0.5,-10)
                ValLbl.Text=tostring(val)
                cb(val)
            end
            function obj:Get() return val end
            return obj
        end

        -- DROPDOWN ────────────────────────────────────────────
        function Tab:AddDropdown(o)
            o=o or {}
            local lbl  = o.Title    or "Dropdown"
            local opts = o.Options  or {}
            local def  = o.Default  or opts[1]
            local col  = o.Accent   or accent
            local cb   = o.Callback or function() end

            local val  = def
            local open = false
            local itemH=36
            local maxShow=math.min(#opts,5)
            local listH=maxShow*itemH

            -- Wrapper expands downward; NOT clipped
            local Wrap=New("Frame",{
                Size=UDim2.new(1,0,0,42),
                BackgroundTransparency=1,
                BorderSizePixel=0,
                ClipsDescendants=false,
                ZIndex=30, Parent=Page,
            })

            local Header=New("TextButton",{
                Size=UDim2.new(1,0,0,42),
                BackgroundColor3=T.B2,
                Text="", ZIndex=30, Parent=Wrap,
            })
            Corner(T.R12,Header)
            local hStroke=Stroke(T.Sep,1,Header,0.5)
            Pad(0,12,0,14,Header)

            New("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=13,ZIndex=31,Parent=Header})
            local SelLbl=New("TextLabel",{Size=UDim2.new(0.34,0,1,0),Position=UDim2.new(0.57,0,0,0),BackgroundTransparency=1,Text=tostring(val or "Select…"),TextColor3=col,TextXAlignment=Enum.TextXAlignment.Right,Font=T.FS,TextSize=12,ZIndex=31,Parent=Header})
            local Chev=New("TextLabel",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),BackgroundTransparency=1,Text="›",TextColor3=T.T3,TextXAlignment=Enum.TextXAlignment.Center,Font=T.FB,TextSize=18,ZIndex=31,Parent=Header})

            -- Drop list: anchored directly below Header inside Wrap
            local DFrame=New("Frame",{
                Size=UDim2.new(1,0,0,0),
                Position=UDim2.new(0,0,0,46),
                BackgroundColor3=T.B3,
                ClipsDescendants=true,
                ZIndex=50, Parent=Wrap,
            })
            Corner(T.R12,DFrame)
            Stroke(T.Sep,1,DFrame,0.3)

            local DScroll=New("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                BorderSizePixel=0,
                ScrollBarThickness=2,
                ScrollBarImageColor3=T.Sep,
                CanvasSize=UDim2.new(0,0,0,0),
                ZIndex=51, Parent=DFrame,
            })
            local DLayout=VList(0,DScroll)
            DLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DScroll.CanvasSize=UDim2.new(0,0,0,DLayout.AbsoluteContentSize.Y)
            end)

            -- track all check labels so we can reset them
            local checkLabels={}

            for _,opt in ipairs(opts) do
                local IBtn=New("TextButton",{
                    Size=UDim2.new(1,0,0,itemH),
                    BackgroundTransparency=1,
                    Text="", ZIndex=52, Parent=DScroll,
                })
                Pad(0,12,0,14,IBtn)
                New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),BackgroundColor3=T.Sep,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=52,Parent=IBtn})

                local check=New("TextLabel",{
                    Size=UDim2.new(0,16,1,0),
                    Position=UDim2.new(1,-16,0,0),
                    BackgroundTransparency=1,
                    Text="✓", TextColor3=col,
                    TextScaled=true, Font=T.FB,
                    TextTransparency=opt==val and 0 or 1,
                    ZIndex=53, Parent=IBtn,
                })
                local optLbl=New("TextLabel",{
                    Size=UDim2.new(1,-20,1,0),
                    BackgroundTransparency=1,
                    Text=tostring(opt),
                    TextColor3=opt==val and col or T.T1,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Font=opt==val and T.FS or T.FR,
                    TextSize=13, ZIndex=53, Parent=IBtn,
                })
                table.insert(checkLabels,{check=check,lbl=optLbl,opt=opt})

                IBtn.MouseEnter:Connect(function() IBtn.BackgroundColor3=T.B4; tw(IBtn,{BackgroundTransparency=0},0.1) end)
                IBtn.MouseLeave:Connect(function() tw(IBtn,{BackgroundTransparency=1},0.1) end)

                IBtn.MouseButton1Click:Connect(function()
                    val=opt
                    SelLbl.Text=tostring(opt)
                    for _,ch in ipairs(checkLabels) do
                        local isMe=ch.opt==opt
                        tw(ch.check,{TextTransparency=isMe and 0 or 1},0.15)
                        tw(ch.lbl,{TextColor3=isMe and col or T.T1},0.15)
                        ch.lbl.Font=isMe and T.FS or T.FR
                    end
                    cb(opt)
                    open=false
                    smooth(DFrame,{Size=UDim2.new(1,0,0,0)},0.22)
                    smooth(Wrap,{Size=UDim2.new(1,0,0,42)},0.22)
                    tw(Chev,{Rotation=0},0.22)
                    tw(hStroke,{Color=T.Sep},0.2)
                end)
            end

            Header.MouseButton1Click:Connect(function()
                open=not open
                if open then
                    tw(hStroke,{Color=col},0.18)
                    spring(DFrame,{Size=UDim2.new(1,0,0,listH)},0.38)
                    spring(Wrap,{Size=UDim2.new(1,0,0,42+listH+8)},0.38)
                    tw(Chev,{Rotation=90},0.22)
                else
                    tw(hStroke,{Color=T.Sep},0.18)
                    smooth(DFrame,{Size=UDim2.new(1,0,0,0)},0.22)
                    smooth(Wrap,{Size=UDim2.new(1,0,0,42)},0.22)
                    tw(Chev,{Rotation=0},0.22)
                end
            end)

            local obj={}
            function obj:Set(v) val=v; SelLbl.Text=tostring(v); cb(v) end
            function obj:Get() return val end
            return obj
        end

        -- INPUT ───────────────────────────────────────────────
        function Tab:AddInput(o)
            o=o or {}
            local lbl = o.Title       or "Input"
            local ph  = o.Placeholder or "Type here…"
            local def = o.Default     or ""
            local col = o.Accent      or accent
            local cb  = o.Callback    or function() end

            local Card=New("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.B2,ZIndex=2,Parent=Page})
            Corner(T.R12,Card)
            local cStroke=Stroke(T.Sep,1,Card,0.5)
            Pad(8,14,8,14,Card)

            New("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text=lbl,TextColor3=T.T3,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FS,TextSize=10,ZIndex=3,Parent=Card})

            local IBox=New("TextBox",{
                Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,18),
                BackgroundColor3=T.B3,
                Text=def,PlaceholderText=ph,PlaceholderColor3=T.T3,
                TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,
                Font=T.FR,TextSize=13,ClearTextOnFocus=false,
                ZIndex=3,Parent=Card,
            })
            Corner(T.R8,IBox)
            Pad(0,8,0,8,IBox)
            local iStroke=Stroke(T.Sep,1,IBox,0.5)

            IBox.Focused:Connect(function()
                tw(iStroke,{Color=col,Transparency=0},0.18)
                tw(cStroke,{Color=col,Transparency=0.4},0.18)
                tw(Card,{BackgroundColor3=col:lerp(T.B1,0.92)},0.18)
            end)
            IBox.FocusLost:Connect(function(enter)
                tw(iStroke,{Color=T.Sep,Transparency=0.5},0.18)
                tw(cStroke,{Color=T.Sep,Transparency=0.5},0.18)
                tw(Card,{BackgroundColor3=T.B2},0.18)
                if enter then cb(IBox.Text) end
            end)

            local obj={}
            function obj:Get() return IBox.Text end
            function obj:Set(v) IBox.Text=v end
            return obj
        end

        -- COLOR PICKER ────────────────────────────────────────
        function Tab:AddColorPicker(o)
            o=o or {}
            local lbl=o.Title    or "Color"
            local def=o.Default  or T.Blue
            local cb =o.Callback or function() end

            local swatches={T.Blue,T.Green,T.Red,T.Orange,T.Purple,T.Teal,T.Yellow,T.White}

            local Card=New("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=T.B2,ZIndex=2,Parent=Page})
            Corner(T.R12,Card)
            Stroke(T.Sep,1,Card,0.5)
            Pad(10,14,10,14,Card)

            New("TextLabel",{Size=UDim2.new(0.5,0,0,16),BackgroundTransparency=1,Text=lbl,TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=13,ZIndex=3,Parent=Card})

            local Row=New("Frame",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,24),BackgroundTransparency=1,ZIndex=3,Parent=Card})
            HList(7,Row)

            local sel=nil
            local selColor=def

            for _,c in ipairs(swatches) do
                local sw=New("TextButton",{Size=UDim2.new(0,25,0,25),BackgroundColor3=c,Text="",ZIndex=4,Parent=Row})
                Corner(T.Roo,sw)
                local swStroke=Stroke(T.White,2,sw,1)
                if c==def then tw(swStroke,{Transparency=0},0); sel=sw; selColor=c end
                sw.MouseButton1Click:Connect(function()
                    if sel then
                        local s=sel:FindFirstChildOfClass("UIStroke")
                        if s then tw(s,{Transparency=1},0.15) end
                        spring(sel,{Size=UDim2.new(0,25,0,25)},0.25)
                    end
                    tw(swStroke,{Transparency=0},0.15)
                    spring(sw,{Size=UDim2.new(0,22,0,22)},0.25)
                    sel=sw; selColor=c; cb(c)
                end)
            end

            local obj={}
            function obj:Get() return selColor end
            return obj
        end

        -- KEYBIND ─────────────────────────────────────────────
        function Tab:AddKeybind(o)
            o=o or {}
            local lbl=o.Title    or "Keybind"
            local def=o.Default  or Enum.KeyCode.Insert
            local cb =o.Callback or function() end

            local key=def
            local listening=false

            local Row=New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.B2,ZIndex=2,Parent=Page})
            Corner(T.R12,Row)
            Stroke(T.Sep,1,Row,0.5)
            Pad(0,12,0,14,Row)

            New("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=T.FR,TextSize=13,ZIndex=3,Parent=Row})

            local KBtn=New("TextButton",{
                Size=UDim2.new(0,80,0,28),
                Position=UDim2.new(1,-80,0.5,-14),
                BackgroundColor3=T.B4,
                Text=key.Name, TextColor3=accent,
                Font=T.FS, TextSize=11,
                ZIndex=3, Parent=Row,
            })
            Corner(T.R8,KBtn)

            KBtn.MouseButton1Click:Connect(function()
                listening=true; KBtn.Text="…"
                spring(KBtn,{BackgroundColor3=accent},0.25)
                tw(KBtn,{TextColor3=T.White},0.15)
            end)
            UserInputService.InputBegan:Connect(function(i,p)
                if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; key=i.KeyCode; KBtn.Text=key.Name
                    tw(KBtn,{BackgroundColor3=T.B4},0.2)
                    tw(KBtn,{TextColor3=accent},0.15)
                end
                if not p and i.KeyCode==key then cb(key) end
            end)

            local obj={}
            function obj:Get() return key end
            return obj
        end

        return Tab
    end -- AddTab

    function Window:Toggle()
        if Root.Visible then
            smooth(Root,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.22)
            task.delay(0.24,function() Root.Visible=false end)
        else
            Root.Visible=true
            tw(Root,{BackgroundTransparency=0},0.2)
            spring(Root,{Size=UDim2.new(0,W,0,H)},0.4)
        end
    end
    function Window:Show()   Root.Visible=true;  tw(Root,{BackgroundTransparency=0},0.2); spring(Root,{Size=UDim2.new(0,W,0,H)},0.4) end
    function Window:Hide()   smooth(Root,{BackgroundTransparency=1},0.2); task.delay(0.22,function() Root.Visible=false end) end
    function Window:Destroy() SG:Destroy() end

    return Window
end

return PhoneUI

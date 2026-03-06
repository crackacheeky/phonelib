--[[
    PhoneUI  v3.0.0  —  iPhone Dark Theme UI Library
    GitHub: https://raw.githubusercontent.com/crackacheeky/phonelib/refs/heads/main/main.lua
--]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris           = game:GetService("Debris")
local LP               = Players.LocalPlayer

local GuiParent do
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    GuiParent = (ok and cg) or LP:WaitForChild("PlayerGui")
end

-- ─── iOS 17 DARK PALETTE ────────────────────────────────────
local K = {
    -- Layered backgrounds (iOS grouped)
    B0  = Color3.fromRGB(  0,  0,  0),   -- pure black
    B1  = Color3.fromRGB( 18, 18, 20),   -- window bg
    B2  = Color3.fromRGB( 28, 28, 30),   -- section bg
    B3  = Color3.fromRGB( 44, 44, 46),   -- row bg / card
    B4  = Color3.fromRGB( 56, 56, 58),   -- elevated
    B5  = Color3.fromRGB( 72, 72, 76),   -- pressed / track off
    Sep = Color3.fromRGB( 56, 56, 58),

    -- iOS system colours
    Blue   = Color3.fromRGB( 10,132,255),
    Green  = Color3.fromRGB( 52,211, 91),
    Red    = Color3.fromRGB(255, 69, 58),
    Orange = Color3.fromRGB(255,159, 10),
    Purple = Color3.fromRGB(191, 90,242),
    Teal   = Color3.fromRGB( 90,200,250),
    Yellow = Color3.fromRGB(255,214, 10),
    White  = Color3.fromRGB(255,255,255),

    -- Text hierarchy
    L1 = Color3.fromRGB(255,255,255),  -- primary
    L2 = Color3.fromRGB(155,155,165),  -- secondary
    L3 = Color3.fromRGB( 80, 80, 90),  -- tertiary / caption

    -- Radii
    r6  = UDim.new(0, 6),
    r10 = UDim.new(0,10),
    r12 = UDim.new(0,12),
    r14 = UDim.new(0,14),
    r18 = UDim.new(0,18),
    r22 = UDim.new(0,22),
    pill= UDim.new(1, 0),

    -- Fonts
    Bold = Enum.Font.GothamBold,
    Semi = Enum.Font.GothamSemibold,
    Reg  = Enum.Font.Gotham,
}

-- ─── TWEEN SHORTCUTS ────────────────────────────────────────
local function tw(o,p,t,sty,dir)
    TweenService:Create(o,TweenInfo.new(
        t   or 0.22,
        sty or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out),p):Play()
end
local function spring(o,p,t) tw(o,p,t or 0.45,Enum.EasingStyle.Back,  Enum.EasingDirection.Out) end
local function sine(o,p,t)   tw(o,p,t or 0.25,Enum.EasingStyle.Sine,  Enum.EasingDirection.Out) end
local function lin(o,p,t)    tw(o,p,t or 0.2, Enum.EasingStyle.Linear,Enum.EasingDirection.Out) end

-- ─── INSTANCE HELPERS ───────────────────────────────────────
local function N(cls,props)
    local o=Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end
local function Rnd(r,p)  local c=Instance.new("UICorner"); c.CornerRadius=r or K.r12; c.Parent=p end
local function Str(col,thick,p,tr)
    local s=Instance.new("UIStroke")
    s.Color=col or K.Sep; s.Thickness=thick or 1; s.Transparency=tr or 0; s.Parent=p; return s
end
local function Pad(t,r,b,l,p)
    local u=Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingBottom=UDim.new(0,b or 0); u.PaddingLeft=UDim.new(0,l or 0)
    u.Parent=p
end
local function VL(gap,p)
    local l=Instance.new("UIListLayout")
    l.FillDirection=Enum.FillDirection.Vertical; l.Padding=UDim.new(0,gap or 0)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.HorizontalAlignment=Enum.HorizontalAlignment.Center
    l.Parent=p; return l
end
local function HL(gap,p)
    local l=Instance.new("UIListLayout")
    l.FillDirection=Enum.FillDirection.Horizontal; l.Padding=UDim.new(0,gap or 0)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.VerticalAlignment=Enum.VerticalAlignment.Center
    l.Parent=p; return l
end

-- Ripple effect
local function Ripple(frame,col)
    local r=N("Frame",{
        Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=col or K.White,
        BackgroundTransparency=0.78, ZIndex=frame.ZIndex+8, Parent=frame,
    })
    Rnd(K.pill,r)
    local sz=math.max(frame.AbsoluteSize.X,frame.AbsoluteSize.Y)*2.6
    spring(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=1},0.5)
    Debris:AddItem(r,0.55)
end

-- ─── NOTIFICATION SYSTEM ────────────────────────────────────
local _nSG, _nHolder
local function ensureNotifs()
    if _nSG and _nSG.Parent then return end
    _nSG=N("ScreenGui",{Name="PhoneUI_Notifs",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,Parent=GuiParent})
    _nHolder=N("Frame",{Size=UDim2.new(0,290,1,0),Position=UDim2.new(1,-298,0,0),
        BackgroundTransparency=1,Parent=_nSG})
    local l=VL(8,_nHolder); l.VerticalAlignment=Enum.VerticalAlignment.Top
    Pad(18,0,18,0,_nHolder)
end

-- ════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ════════════════════════════════════════════════════════════
local PhoneUI={}; PhoneUI.__index=PhoneUI

function PhoneUI:Notify(o)
    o=o or {}
    local title=o.Title or "PhoneUI"; local body=o.Body or ""
    local icon=o.Icon or "📱"; local dur=o.Duration or 4; local ac=o.Accent or K.Blue
    ensureNotifs()

    local card=N("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=K.B3,
        ClipsDescendants=true,Parent=_nHolder})
    Rnd(K.r14,card); Str(ac,1,card,0.55)

    -- accent bar
    local ab=N("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=ac,Parent=card})
    Rnd(K.pill,ab)

    local inner=N("Frame",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,Parent=card})
    Pad(10,10,10,6,inner); HL(10,inner)

    local iF=N("Frame",{Size=UDim2.new(0,32,0,32),BackgroundColor3=ac,
        BackgroundTransparency=0.78,Parent=inner})
    Rnd(K.r10,iF)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,
        TextScaled=true,Font=K.Bold,Parent=iF})

    local tc=N("Frame",{Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,Parent=inner})
    VL(2,tc)
    N("TextLabel",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Text=title,
        TextColor3=K.L1,TextXAlignment=Enum.TextXAlignment.Left,Font=K.Semi,TextSize=13,Parent=tc})
    N("TextLabel",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,Text=body,
        TextColor3=K.L2,TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=11,
        TextTruncate=Enum.TextTruncate.AtEnd,Parent=tc})

    local pb=N("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=ac,Parent=card})
    Rnd(K.pill,pb)

    card.Position=UDim2.new(1,10,0,0)
    sine(card,{Position=UDim2.new(0,0,0,0)},0.36)
    lin(pb,{Size=UDim2.new(0,0,0,2)},dur)
    task.delay(dur,function()
        sine(card,{Position=UDim2.new(1,10,0,0),BackgroundTransparency=1},0.26)
        Debris:AddItem(card,0.3)
    end)
end

-- ════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ════════════════════════════════════════════════════════════
function PhoneUI:CreateWindow(o)
    o=o or {}
    local title  = o.Title    or "PhoneUI"
    local sub    = o.Subtitle or ""
    local accent = o.Accent   or K.Blue
    local W      = o.Width    or 340
    local H      = o.Height   or 480
    local TBAR   = 52    -- title bar height
    local TBBAR  = 40    -- tab bar height
    local CY     = TBAR+TBBAR  -- content starts at y=92

    -- ── ScreenGui ───────────────────────────────────────────
    local SG=N("ScreenGui",{Name="PhoneUI_"..title,ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=50,Parent=GuiParent})

    -- ── Root (no clipping — allows dropdown overlays) ────────
    local Root=N("Frame",{
        Name="Root",
        Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=K.B1,
        BorderSizePixel=0,
        ClipsDescendants=false,
        Parent=SG,
    })
    Rnd(K.r22,Root)
    -- Border stroke on root
    Str(K.Sep,1,Root,0.18)
    -- Gradient for depth
    N("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(30,30,34)),
            ColorSequenceKeypoint.new(1,K.B1),
        }),
        Rotation=160,Parent=Root,
    })

    -- Inner clip frame — same size, clips all UI children
    local Inner=N("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=1,
        Parent=Root,
    })
    Rnd(K.r22,Inner)

    -- ── TITLE BAR ───────────────────────────────────────────
    local TBar=N("Frame",{
        Size=UDim2.new(1,0,0,TBAR),
        BackgroundColor3=K.B2,
        BorderSizePixel=0,
        ZIndex=10,
        Parent=Inner,
    })
    -- Top-only rounding trick: round all, fill bottom
    Rnd(K.r22,TBar)
    N("Frame",{Size=UDim2.new(1,0,0,K.r22.Offset),
        Position=UDim2.new(0,0,1,-K.r22.Offset),
        BackgroundColor3=K.B2,BorderSizePixel=0,ZIndex=10,Parent=TBar})
    -- Hairline separator
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=K.Sep,BorderSizePixel=0,ZIndex=11,Parent=TBar})

    -- Traffic lights
    local function TLight(xOff,col,sym)
        local btn=N("TextButton",{
            Size=UDim2.new(0,13,0,13),Position=UDim2.new(0,xOff,0.5,-6),
            BackgroundColor3=col,Text="",AutoButtonColor=false,ZIndex=12,Parent=TBar})
        Rnd(K.pill,btn)
        local sym_lbl=N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=sym,TextColor3=Color3.fromRGB(60,0,0),TextScaled=true,Font=K.Bold,
            TextTransparency=1,ZIndex=13,Parent=btn})
        btn.MouseEnter:Connect(function()
            tw(btn,{BackgroundColor3=col:Lerp(K.White,0.28)},0.1)
            tw(sym_lbl,{TextTransparency=0},0.1)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn,{BackgroundColor3=col},0.1)
            tw(sym_lbl,{TextTransparency=1},0.1)
        end)
        return btn
    end

    local CloseBtn = TLight(12,K.Red,   "✕")
    local MinBtn   = TLight(30,K.Orange,"–")

    -- Pulsing accent dot
    local dot=N("Frame",{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,52,0.5,-3),
        BackgroundColor3=accent,ZIndex=12,Parent=TBar})
    Rnd(K.pill,dot)
    task.spawn(function()
        while dot and dot.Parent do
            tw(dot,{BackgroundTransparency=0.55},0.9,Enum.EasingStyle.Sine)
            task.wait(0.95)
            tw(dot,{BackgroundTransparency=0},0.9,Enum.EasingStyle.Sine)
            task.wait(0.95)
        end
    end)

    N("TextLabel",{Size=UDim2.new(1,-130,1,0),Position=UDim2.new(0,65,0,0),
        BackgroundTransparency=1,Text=title,TextColor3=K.L1,
        TextXAlignment=Enum.TextXAlignment.Left,Font=K.Bold,TextSize=14,ZIndex=12,Parent=TBar})
    if sub~="" then
        N("TextLabel",{Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-66,0,0),
            BackgroundTransparency=1,Text=sub,TextColor3=K.L3,
            TextXAlignment=Enum.TextXAlignment.Right,Font=K.Reg,TextSize=10,ZIndex=12,Parent=TBar})
    end

    -- ── TAB BAR ─────────────────────────────────────────────
    local TabBar=N("Frame",{
        Size=UDim2.new(1,0,0,TBBAR),
        Position=UDim2.new(0,0,0,TBAR),
        BackgroundColor3=K.B2,
        BorderSizePixel=0,
        ZIndex=9,
        ClipsDescendants=true,
        Parent=Inner,
    })
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=K.Sep,BorderSizePixel=0,ZIndex=10,Parent=TabBar})

    local TabScroll=N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.X,
        CanvasSize=UDim2.new(0,0,1,0),ZIndex=10,Parent=TabBar})
    local TabLayout=HL(0,TabScroll)
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize=UDim2.new(0,TabLayout.AbsoluteContentSize.X,1,0)
    end)

    -- The active underline lives INSIDE TabBar (not inside TBtn)
    -- so its width is absolute and doesn't depend on TBtn's AutomaticSize
    local IndBar=N("Frame",{
        Size=UDim2.new(0,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=accent,
        BorderSizePixel=0,
        ZIndex=12,
        Parent=TabBar,
    })
    Rnd(K.pill,IndBar)

    -- ── CONTENT ─────────────────────────────────────────────
    local ContentScroll=N("ScrollingFrame",{
        Name="Content",
        Size=UDim2.new(1,0,1,-CY),
        Position=UDim2.new(0,0,0,CY),
        BackgroundColor3=K.B1,
        BorderSizePixel=0,
        ScrollBarThickness=2,
        ScrollBarImageColor3=K.B5,
        CanvasSize=UDim2.new(0,0,0,0),
        ZIndex=2,
        Parent=Inner,
    })

    -- ── DRAG ────────────────────────────────────────────────
    local drag,ds,rs=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; rs=Root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Root.Position=UDim2.new(rs.X.Scale,rs.X.Offset+d.X,rs.Y.Scale,rs.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)

    -- ── WINDOW STATE ────────────────────────────────────────
    local Window={};  local allTabs={}; local activeTab=nil; local isOpen=true

    -- Close button
    CloseBtn.MouseButton1Click:Connect(function()
        tw(Root,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.28,Enum.EasingStyle.Quart)
        task.delay(0.32,function() SG:Destroy() end)
    end)
    -- Minimise button (just collapses to title bar, full re-open on next Toggle)
    local minimised=false
    MinBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        if minimised then
            sine(Root,{Size=UDim2.new(0,W,0,TBAR)},0.28)
        else
            spring(Root,{Size=UDim2.new(0,W,0,H)},0.44)
        end
    end)

    -- Entrance animation
    Root.Size=UDim2.new(0,W,0,0); Root.BackgroundTransparency=1
    task.defer(function()
        sine(Root,{BackgroundTransparency=0},0.3)
        spring(Root,{Size=UDim2.new(0,W,0,H)},0.52)
    end)

    -- ── ADD TAB ─────────────────────────────────────────────
    function Window:AddTab(tabOpts)
        tabOpts=tabOpts or {}
        local tName=tabOpts.Name or ("Tab "..#allTabs+1)
        local tIcon=tabOpts.Icon or ""

        -- Tab button (AutomaticSize X so text fits)
        local TBtn=N("TextButton",{
            Size=UDim2.new(0,0,1,0),
            AutomaticSize=Enum.AutomaticSize.X,
            BackgroundTransparency=1,
            Text="",AutoButtonColor=false,
            ZIndex=11,Parent=TabScroll,
        })
        Pad(0,16,0,16,TBtn)

        local TInner=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11,Parent=TBtn})
        HL(5,TInner)

        if tIcon~="" then
            N("TextLabel",{Size=UDim2.new(0,14,1,0),BackgroundTransparency=1,
                Text=tIcon,TextScaled=true,Font=K.Bold,ZIndex=11,Parent=TInner})
        end

        local TLabel=N("TextLabel",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundTransparency=1,Text=tName,TextColor3=K.L3,
            Font=K.Semi,TextSize=12,ZIndex=11,Parent=TInner,
        })

        -- Page
        local Page=N("Frame",{
            Name=tName,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            BorderSizePixel=0,Visible=false,ZIndex=3,Parent=ContentScroll,
        })
        Pad(12,10,18,10,Page)
        local PList=VL(8,Page)
        PList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Page.Visible then
                ContentScroll.CanvasSize=UDim2.new(0,0,0,PList.AbsoluteContentSize.Y+30)
            end
        end)

        local td={Btn=TBtn,Label=TLabel,Page=Page,List=PList}
        table.insert(allTabs,td)

        local function Activate()
            for _,t in ipairs(allTabs) do
                t.Page.Visible=false
                tw(t.Label,{TextColor3=K.L3},0.18)
            end
            Page.Visible=true
            ContentScroll.CanvasPosition=Vector2.new(0,0)
            ContentScroll.CanvasSize=UDim2.new(0,0,0,PList.AbsoluteContentSize.Y+30)
            tw(TLabel,{TextColor3=accent},0.18)
            activeTab=td

            -- Move the IndBar to sit under this TBtn using AbsolutePosition
            -- We do this after a brief yield so AutomaticSize has settled
            task.defer(function()
                local btnAbs=TBtn.AbsolutePosition
                local barAbs=TabBar.AbsolutePosition
                local relX=btnAbs.X-barAbs.X
                local btnW=TBtn.AbsoluteSize.X
                -- Animate underline to new position and width
                spring(IndBar,{
                    Size=UDim2.new(0,btnW-20,0,2),
                    Position=UDim2.new(0,relX+10,1,-2),
                },0.38)
            end)

            -- Slide-in
            Page.Position=UDim2.new(0.04,0,0,0)
            tw(Page,{Position=UDim2.new(0,0,0,0)},0.26,Enum.EasingStyle.Quart)
        end

        TBtn.MouseButton1Click:Connect(function()
            if activeTab~=td then Activate() end
        end)
        if #allTabs==1 then task.defer(Activate) end

        -- ─── COMPONENTS ────────────────────────────────────
        local Tab={}

        -- SECTION
        function Tab:AddSection(label)
            local f=N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,ZIndex=3,Parent=Page})
            Pad(6,2,0,2,f)
            N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=(label or ""):upper(),TextColor3=K.L3,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Semi,TextSize=10,ZIndex=3,Parent=f})
        end

        -- LABEL
        function Tab:AddLabel(text,col)
            local l=N("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
                Text=text or "",TextColor3=col or K.L2,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=12,
                TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=3,Parent=Page})
            return{SetText=function(_,t) l.Text=t end}
        end

        -- DIVIDER
        function Tab:AddDivider()
            N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=K.Sep,
                BackgroundTransparency=0.4,BorderSizePixel=0,ZIndex=3,Parent=Page})
        end

        -- BUTTON
        function Tab:AddButton(o)
            o=o or {}
            local lbl =o.Title    or "Button"
            local icon=o.Icon     or ""
            local sty =o.Style    or "Primary"
            local cb  =o.Callback or function()end

            local pals={
                Primary  ={bg=accent,  txt=K.White, ov=accent:Lerp(K.White,0.1)},
                Secondary={bg=K.B3,    txt=accent,  ov=K.B4},
                Danger   ={bg=K.Red,   txt=K.White, ov=K.Red:Lerp(K.White,0.12)},
                Success  ={bg=K.Green, txt=K.White, ov=K.Green:Lerp(K.White,0.12)},
                Outline  ={bg=K.B1,    txt=accent,  ov=K.B2},
            }
            local pal=pals[sty] or pals.Primary

            local Btn=N("TextButton",{
                Size=UDim2.new(1,0,0,44),BackgroundColor3=pal.bg,
                Text=(icon~="" and icon.."  " or "")..lbl,
                TextColor3=pal.txt,Font=K.Semi,TextSize=13,
                AutoButtonColor=false,ZIndex=3,Parent=Page,
            })
            Rnd(K.r14,Btn)
            if sty=="Outline" then Str(accent,1.5,Btn,0) end

            Btn.MouseButton1Down:Connect(function()
                spring(Btn,{Size=UDim2.new(1,-10,0,42)},0.22)
                tw(Btn,{BackgroundTransparency=0.2},0.08)
                Ripple(Btn,pal.ov)
            end)
            Btn.MouseButton1Up:Connect(function()
                spring(Btn,{Size=UDim2.new(1,0,0,44)},0.3)
                tw(Btn,{BackgroundTransparency=0},0.12)
            end)
            Btn.MouseEnter:Connect(function() tw(Btn,{BackgroundColor3=pal.ov},0.14) end)
            Btn.MouseLeave:Connect(function() tw(Btn,{BackgroundColor3=pal.bg},0.14) end)
            Btn.MouseButton1Click:Connect(cb)
            return Btn
        end

        -- TOGGLE
        function Tab:AddToggle(o)
            o=o or {}
            local lbl =o.Title       or "Toggle"
            local desc=o.Description or ""
            local val =o.Default     or false
            local col =o.Accent      or K.Green
            local cb  =o.Callback    or function()end

            local rowH=desc~="" and 56 or 46

            local Row=N("Frame",{Size=UDim2.new(1,0,0,rowH),BackgroundColor3=K.B3,ZIndex=3,Parent=Page})
            Rnd(K.r12,Row)
            local rStr=Str(K.Sep,1,Row,0.45)
            Pad(0,12,0,14,Row)

            N("TextLabel",{
                Size=UDim2.new(1,-68,0,20),
                Position=UDim2.new(0,0,0.5,desc~="" and -14 or -10),
                BackgroundTransparency=1,Text=lbl,TextColor3=K.L1,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=15,ZIndex=4,Parent=Row,
            })
            if desc~="" then
                N("TextLabel",{
                    Size=UDim2.new(1,-68,0,14),
                    Position=UDim2.new(0,0,0.5,6),
                    BackgroundTransparency=1,Text=desc,TextColor3=K.L3,
                    TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=11,ZIndex=4,Parent=Row,
                })
            end

            -- iOS-style switch: 51×31
            local Track=N("Frame",{
                Size=UDim2.new(0,51,0,31),
                Position=UDim2.new(1,-51,0.5,-15),
                BackgroundColor3=val and col or K.B5,
                ZIndex=4,Parent=Row,
            })
            Rnd(K.pill,Track)

            local Thumb=N("Frame",{
                Size=UDim2.new(0,27,0,27),
                Position=UDim2.new(0,val and 22 or 2,0.5,-13),
                BackgroundColor3=K.White,
                ZIndex=6,Parent=Track,
            })
            Rnd(K.pill,Thumb)
            N("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,K.White),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212)),
                }),
                Rotation=120,Parent=Thumb,
            })

            local function Refresh()
                tw(Track,{BackgroundColor3=val and col or K.B5},0.2)
                tw(rStr,{Color=val and col or K.Sep,Transparency=val and 0.25 or 0.45},0.2)
                tw(Row,{BackgroundColor3=val and col:Lerp(K.B1,0.9) or K.B3},0.2)
                spring(Thumb,{Position=UDim2.new(0,val and 22 or 2,0.5,-13)},0.42)
            end

            local hit=N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,ZIndex=7,Parent=Row})
            hit.MouseButton1Click:Connect(function() val=not val; Refresh(); cb(val) end)
            Refresh()

            local obj={}
            function obj:Set(v) val=v;Refresh();cb(val) end
            function obj:Get() return val end
            return obj
        end

        -- SLIDER
        function Tab:AddSlider(o)
            o=o or {}
            local lbl =o.Title    or "Slider"
            local mn  =o.Min      or 0
            local mx  =o.Max      or 100
            local def =o.Default  or mn
            local step=o.Step     or 1
            local col =o.Accent   or accent
            local cb  =o.Callback or function()end

            local val=math.clamp(def,mn,mx)

            local Card=N("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=K.B3,ZIndex=3,Parent=Page})
            Rnd(K.r12,Card)
            local cStr=Str(K.Sep,1,Card,0.45)
            Pad(10,14,10,14,Card)

            -- Title + value row
            local Top=N("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=4,Parent=Card})
            N("TextLabel",{Size=UDim2.new(0.65,0,1,0),BackgroundTransparency=1,Text=lbl,
                TextColor3=K.L1,TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=14,ZIndex=4,Parent=Top})
            local ValLbl=N("TextLabel",{Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0.65,0,0,0),
                BackgroundTransparency=1,Text=tostring(val),TextColor3=col,
                TextXAlignment=Enum.TextXAlignment.Right,Font=K.Bold,TextSize=14,ZIndex=4,Parent=Top})

            -- Large hit area (full width, 26px tall at bottom of card)
            local HitArea=N("TextButton",{
                Size=UDim2.new(1,0,0,26),
                Position=UDim2.new(0,0,1,-26),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,
                ZIndex=7,Parent=Card,
            })

            -- Thin visual track centred in HitArea
            local Track=N("Frame",{
                Size=UDim2.new(1,0,0,4),
                Position=UDim2.new(0,0,0.5,-2),
                BackgroundColor3=K.B5,ZIndex=4,Parent=HitArea,
            })
            Rnd(K.pill,Track)

            local Fill=N("Frame",{
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=col,ZIndex=5,Parent=Track,
            })
            Rnd(K.pill,Fill)

            local Thumb=N("Frame",{
                Size=UDim2.new(0,22,0,22),
                Position=UDim2.new((val-mn)/(mx-mn),-11,0.5,-11),
                BackgroundColor3=K.White,ZIndex=6,Parent=Track,
            })
            Rnd(K.pill,Thumb)
            N("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,K.White),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,210)),
                }),
                Rotation=120,Parent=Thumb,
            })

            local sliding=false

            local function SetVal(absX)
                local tp=Track.AbsolutePosition.X
                local ts=Track.AbsoluteSize.X
                if ts<=0 then return end
                local rel=math.clamp((absX-tp)/ts,0,1)
                val=math.clamp(math.round((mn+(mx-mn)*rel)/step)*step,mn,mx)
                local p=(val-mn)/(mx-mn)
                Fill.Size=UDim2.new(p,0,1,0)
                local thOff=sliding and -13 or -11
                local thSz=sliding and 26 or 22
                Thumb.Position=UDim2.new(p,thOff,0.5,thOff)
                Thumb.Size=UDim2.new(0,thSz,0,thSz)
                ValLbl.Text=tostring(val)
                cb(val)
            end

            local function StartSlide(x)
                if sliding then return end
                sliding=true
                spring(Thumb,{Size=UDim2.new(0,26,0,26)},0.25)
                tw(cStr,{Color=col,Transparency=0.15},0.18)
                tw(Card,{BackgroundColor3=col:Lerp(K.B1,0.91)},0.18)
                SetVal(x)
            end
            local function EndSlide()
                if not sliding then return end
                sliding=false
                spring(Thumb,{Size=UDim2.new(0,22,0,22)},0.3)
                tw(cStr,{Color=K.Sep,Transparency=0.45},0.18)
                tw(Card,{BackgroundColor3=K.B3},0.18)
            end

            -- Both HitArea and Track begin the slide
            for _,src in ipairs({HitArea,Track}) do
                src.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then
                        StartSlide(i.Position.X)
                    end
                end)
            end
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
                    or i.UserInputType==Enum.UserInputType.Touch) then
                    SetVal(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if (i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch) then
                    EndSlide()
                end
            end)

            local obj={}
            function obj:Set(v)
                val=math.clamp(v,mn,mx)
                local p=(val-mn)/(mx-mn)
                tw(Fill,{Size=UDim2.new(p,0,1,0)},0.18)
                Thumb.Position=UDim2.new(p,-11,0.5,-11)
                ValLbl.Text=tostring(val); cb(val)
            end
            function obj:Get() return val end
            return obj
        end

        -- DROPDOWN
        function Tab:AddDropdown(o)
            o=o or {}
            local lbl =o.Title    or "Dropdown"
            local opts=o.Options  or {}
            local def =o.Default  or opts[1]
            local col =o.Accent   or accent
            local cb  =o.Callback or function()end

            local val=def; local open=false
            local iH=38; local maxShow=math.min(#opts,5); local listH=maxShow*iH

            -- Wrapper (expands downward, not clipped)
            local Wrap=N("Frame",{
                Size=UDim2.new(1,0,0,44),
                BackgroundTransparency=1,BorderSizePixel=0,
                ClipsDescendants=false,ZIndex=40,Parent=Page,
            })

            local Hdr=N("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=K.B3,
                Text="",AutoButtonColor=false,ZIndex=40,Parent=Wrap})
            Rnd(K.r12,Hdr)
            local hStr=Str(K.Sep,1,Hdr,0.45)
            Pad(0,12,0,14,Hdr)

            N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=lbl,
                TextColor3=K.L1,TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=13,ZIndex=41,Parent=Hdr})
            local SelLbl=N("TextLabel",{Size=UDim2.new(0.34,0,1,0),Position=UDim2.new(0.57,0,0,0),
                BackgroundTransparency=1,Text=tostring(val or "Select…"),TextColor3=col,
                TextXAlignment=Enum.TextXAlignment.Right,Font=K.Semi,TextSize=12,ZIndex=41,Parent=Hdr})
            local Chev=N("TextLabel",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),
                BackgroundTransparency=1,Text="›",TextColor3=K.L3,
                TextXAlignment=Enum.TextXAlignment.Center,Font=K.Bold,TextSize=20,ZIndex=41,Parent=Hdr})

            -- Drop list — parented to ROOT so it floats above everything
            local DFrame=N("Frame",{
                Size=UDim2.new(0,W-20,0,0),
                BackgroundColor3=K.B4,
                ClipsDescendants=true,
                Visible=false,ZIndex=200,Parent=Root,
            })
            Rnd(K.r12,DFrame)
            Str(K.Sep,1,DFrame,0.2)

            local DScroll=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=K.Sep,
                CanvasSize=UDim2.new(0,0,0,0),ZIndex=201,Parent=DFrame})
            local DLayout=VL(0,DScroll)
            DLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DScroll.CanvasSize=UDim2.new(0,0,0,DLayout.AbsoluteContentSize.Y)
            end)

            local checks={}
            for _,opt in ipairs(opts) do
                local IBtn=N("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundTransparency=1,
                    Text="",AutoButtonColor=false,ZIndex=202,Parent=DScroll})
                Pad(0,12,0,14,IBtn)
                N("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),
                    BackgroundColor3=K.Sep,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=202,Parent=IBtn})
                local ck=N("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-16,0,0),
                    BackgroundTransparency=1,Text="✓",TextColor3=col,TextScaled=true,Font=K.Bold,
                    TextTransparency=opt==val and 0 or 1,ZIndex=203,Parent=IBtn})
                local oL=N("TextLabel",{Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,
                    Text=tostring(opt),TextColor3=opt==val and col or K.L1,
                    TextXAlignment=Enum.TextXAlignment.Left,Font=opt==val and K.Semi or K.Reg,
                    TextSize=13,ZIndex=203,Parent=IBtn})
                table.insert(checks,{ck=ck,lbl=oL,opt=opt})

                IBtn.MouseEnter:Connect(function() IBtn.BackgroundColor3=K.B5; tw(IBtn,{BackgroundTransparency=0},0.1) end)
                IBtn.MouseLeave:Connect(function() tw(IBtn,{BackgroundTransparency=1},0.1) end)
                IBtn.MouseButton1Click:Connect(function()
                    val=opt; SelLbl.Text=tostring(opt)
                    for _,ch in ipairs(checks) do
                        local me=ch.opt==opt
                        tw(ch.ck,{TextTransparency=me and 0 or 1},0.15)
                        tw(ch.lbl,{TextColor3=me and col or K.L1},0.15)
                        ch.lbl.Font=me and K.Semi or K.Reg
                    end
                    cb(opt)
                    open=false
                    sine(DFrame,{Size=UDim2.new(0,W-20,0,0)},0.2)
                    task.delay(0.22,function() DFrame.Visible=false end)
                    sine(Wrap,{Size=UDim2.new(1,0,0,44)},0.2)
                    tw(Chev,{Rotation=0},0.2)
                    tw(hStr,{Color=K.Sep},0.18)
                end)
            end

            local function PositionDropdown()
                -- Place DFrame below Hdr, in Root's coordinate space
                local hAbs=Hdr.AbsolutePosition
                local rAbs=Root.AbsolutePosition
                DFrame.Position=UDim2.new(0,hAbs.X-rAbs.X+10, 0,hAbs.Y-rAbs.Y+46)
            end

            Hdr.MouseButton1Click:Connect(function()
                open=not open
                if open then
                    PositionDropdown()
                    DFrame.Size=UDim2.new(0,W-20,0,0); DFrame.Visible=true
                    tw(hStr,{Color=col},0.18)
                    spring(DFrame,{Size=UDim2.new(0,W-20,0,listH)},0.38)
                    spring(Wrap,{Size=UDim2.new(1,0,0,44+listH+6)},0.38)
                    tw(Chev,{Rotation=90},0.22)
                else
                    tw(hStr,{Color=K.Sep},0.18)
                    sine(DFrame,{Size=UDim2.new(0,W-20,0,0)},0.22)
                    task.delay(0.24,function() DFrame.Visible=false end)
                    sine(Wrap,{Size=UDim2.new(1,0,0,44)},0.22)
                    tw(Chev,{Rotation=0},0.22)
                end
            end)

            local obj={}
            function obj:Set(v) val=v;SelLbl.Text=tostring(v);cb(v) end
            function obj:Get() return val end
            return obj
        end

        -- INPUT
        function Tab:AddInput(o)
            o=o or{}
            local lbl=o.Title       or "Input"
            local ph =o.Placeholder or "Type here…"
            local def=o.Default     or ""
            local col=o.Accent      or accent
            local cb =o.Callback    or function()end

            local Card=N("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=K.B3,ZIndex=3,Parent=Page})
            Rnd(K.r12,Card); local cStr=Str(K.Sep,1,Card,0.45); Pad(8,14,8,14,Card)

            N("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text=lbl,TextColor3=K.L3,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Semi,TextSize=10,ZIndex=4,Parent=Card})

            local IBox=N("TextBox",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,18),
                BackgroundColor3=K.B4,Text=def,PlaceholderText=ph,PlaceholderColor3=K.L3,
                TextColor3=K.L1,TextXAlignment=Enum.TextXAlignment.Left,
                Font=K.Reg,TextSize=13,ClearTextOnFocus=false,ZIndex=4,Parent=Card})
            Rnd(K.r10,IBox); Pad(0,8,0,8,IBox); local iStr=Str(K.Sep,1,IBox,0.5)

            IBox.Focused:Connect(function()
                tw(iStr,{Color=col,Transparency=0},0.18)
                tw(cStr,{Color=col,Transparency=0.28},0.18)
                tw(Card,{BackgroundColor3=col:Lerp(K.B1,0.92)},0.18)
            end)
            IBox.FocusLost:Connect(function(enter)
                tw(iStr,{Color=K.Sep,Transparency=0.5},0.18)
                tw(cStr,{Color=K.Sep,Transparency=0.45},0.18)
                tw(Card,{BackgroundColor3=K.B3},0.18)
                if enter then cb(IBox.Text) end
            end)

            local obj={}
            function obj:Get() return IBox.Text end
            function obj:Set(v) IBox.Text=v end
            return obj
        end

        -- COLOR PICKER
        function Tab:AddColorPicker(o)
            o=o or{}
            local lbl=o.Title    or "Color"
            local def=o.Default  or K.Blue
            local cb =o.Callback or function()end

            local sw_colors={K.Blue,K.Green,K.Red,K.Orange,K.Purple,K.Teal,K.Yellow,K.White}

            local Card=N("Frame",{Size=UDim2.new(1,0,0,66),BackgroundColor3=K.B3,ZIndex=3,Parent=Page})
            Rnd(K.r12,Card); Str(K.Sep,1,Card,0.45); Pad(10,14,10,14,Card)

            N("TextLabel",{Size=UDim2.new(0.5,0,0,18),BackgroundTransparency=1,Text=lbl,TextColor3=K.L1,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=13,ZIndex=4,Parent=Card})

            local Row=N("Frame",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,26),
                BackgroundTransparency=1,ZIndex=4,Parent=Card})
            HL(8,Row)

            local sel=nil; local selCol=def
            for _,sc in ipairs(sw_colors) do
                local sw=N("TextButton",{Size=UDim2.new(0,26,0,26),BackgroundColor3=sc,
                    Text="",AutoButtonColor=false,ZIndex=5,Parent=Row})
                Rnd(K.pill,sw)
                local swStr=Str(K.White,2.5,sw,1)
                if sc==def then tw(swStr,{Transparency=0},0); sel=sw; selCol=sc end
                sw.MouseButton1Click:Connect(function()
                    if sel then
                        local s=sel:FindFirstChildOfClass("UIStroke")
                        if s then tw(s,{Transparency=1},0.15) end
                        spring(sel,{Size=UDim2.new(0,26,0,26)},0.28)
                    end
                    tw(swStr,{Transparency=0},0.15)
                    spring(sw,{Size=UDim2.new(0,22,0,22)},0.28)
                    sel=sw; selCol=sc; cb(sc)
                end)
            end

            local obj={}; function obj:Get() return selCol end; return obj
        end

        -- KEYBIND
        function Tab:AddKeybind(o)
            o=o or{}
            local lbl=o.Title    or "Keybind"
            local def=o.Default  or Enum.KeyCode.Insert
            local cb =o.Callback or function()end

            local key=def; local listening=false

            local Row=N("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=K.B3,ZIndex=3,Parent=Page})
            Rnd(K.r12,Row); Str(K.Sep,1,Row,0.45); Pad(0,12,0,14,Row)

            N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=K.L1,
                TextXAlignment=Enum.TextXAlignment.Left,Font=K.Reg,TextSize=13,ZIndex=4,Parent=Row})

            local KBtn=N("TextButton",{
                Size=UDim2.new(0,82,0,30),Position=UDim2.new(1,-82,0.5,-15),
                BackgroundColor3=K.B5,Text=key.Name,TextColor3=accent,
                Font=K.Semi,TextSize=11,AutoButtonColor=false,ZIndex=4,Parent=Row,
            })
            Rnd(K.r10,KBtn)

            KBtn.MouseButton1Click:Connect(function()
                listening=true; KBtn.Text="…"
                spring(KBtn,{BackgroundColor3=accent},0.28)
                tw(KBtn,{TextColor3=K.White},0.15)
            end)
            UserInputService.InputBegan:Connect(function(i,p)
                if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; key=i.KeyCode; KBtn.Text=key.Name
                    tw(KBtn,{BackgroundColor3=K.B5},0.22)
                    tw(KBtn,{TextColor3=accent},0.15)
                end
                if not p and i.KeyCode==key then cb(key) end
            end)

            local obj={}; function obj:Get() return key end; return obj
        end

        return Tab
    end -- AddTab

    -- ── TOGGLE / SHOW / HIDE / DESTROY ──────────────────────
    -- FIX: Simply enable/disable the ScreenGui — no size/transparency tricks.
    -- The entrance spring runs once on creation. On re-open we just show the SG.
    function Window:Toggle()
        if isOpen then
            isOpen=false
            -- Scale down before hiding
            sine(Root,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.22)
            task.delay(0.24,function() SG.Enabled=false end)
        else
            isOpen=true
            SG.Enabled=true
            Root.BackgroundTransparency=1
            Root.Size=UDim2.new(0,W,0,0)
            sine(Root,{BackgroundTransparency=0},0.2)
            spring(Root,{Size=UDim2.new(0,W,0,H)},0.42)
        end
    end

    function Window:Show()
        if isOpen then return end
        isOpen=true; SG.Enabled=true
        Root.BackgroundTransparency=1; Root.Size=UDim2.new(0,W,0,0)
        sine(Root,{BackgroundTransparency=0},0.2)
        spring(Root,{Size=UDim2.new(0,W,0,H)},0.42)
    end

    function Window:Hide()
        if not isOpen then return end
        isOpen=false
        sine(Root,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.22)
        task.delay(0.24,function() SG.Enabled=false end)
    end

    function Window:Destroy()
        SG:Destroy()
    end

    return Window
end

return PhoneUI

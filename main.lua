--[[
  PhoneUI v4.0  —  Full iPhone OS UI for Roblox
  Looks and feels exactly like iOS 17:
    • Lock Screen  (swipe up to unlock)
    • SpringBoard  (home screen with app icons)
    • App launcher (zoom-in / zoom-out like iOS)
    • Dynamic Island notifications (expand/collapse)
    • Control Centre (swipe up from bottom)
    • Settings app built-in (WiFi, Appearance, etc.)
    • Draggable phone shell
  
  Toggle visibility:  PhoneUI:Toggle()
  GitHub: https://raw.githubusercontent.com/crackacheeky/phonelib/refs/heads/main/main.lua
--]]

-- ── Services ─────────────────────────────────────────────
local Plr = game:GetService("Players")
local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LP  = Plr.LocalPlayer

local GUI do
  local ok,cg = pcall(function() return game:GetService("CoreGui") end)
  GUI = (ok and cg) or LP:WaitForChild("PlayerGui")
end

-- ── Colour palette (iOS 17 dark) ─────────────────────────
local C = {
  Black  = Color3.fromRGB(0,0,0),
  Shell  = Color3.fromRGB(20,20,22),
  BG     = Color3.fromRGB(0,0,0),
  L1     = Color3.fromRGB(28,28,30),
  L2     = Color3.fromRGB(44,44,46),
  L3     = Color3.fromRGB(58,58,60),
  L4     = Color3.fromRGB(72,72,76),
  Sep    = Color3.fromRGB(56,56,58),
  White  = Color3.fromRGB(255,255,255),
  Blue   = Color3.fromRGB(10,132,255),
  Green  = Color3.fromRGB(52,211,91),
  Red    = Color3.fromRGB(255,69,58),
  Orange = Color3.fromRGB(255,159,10),
  Purple = Color3.fromRGB(191,90,242),
  Teal   = Color3.fromRGB(90,200,250),
  Yellow = Color3.fromRGB(255,214,10),
  Pink   = Color3.fromRGB(255,55,95),
  T1     = Color3.fromRGB(255,255,255),
  T2     = Color3.fromRGB(155,155,165),
  T3     = Color3.fromRGB(88,88,98),
  Bold   = Enum.Font.GothamBold,
  Semi   = Enum.Font.GothamSemibold,
  Reg    = Enum.Font.Gotham,
}

-- ── Tween shortcuts ──────────────────────────────────────
local function tw(o,p,t,s,d)
  if not o or not o.Parent then return end
  TS:Create(o,TweenInfo.new(t or .22,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play()
end
local function sp(o,p,t) tw(o,p,t or .45,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function sn(o,p,t) tw(o,p,t or .28,Enum.EasingStyle.Sine,Enum.EasingDirection.Out) end
local function qt(o,p,t) tw(o,p,t or .38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out) end

-- ── Instance helpers ─────────────────────────────────────
local function N(cls,props)
  local o = Instance.new(cls)
  for k,v in pairs(props or {}) do o[k]=v end
  return o
end
local function Rnd(r,p) local c=Instance.new("UICorner"); c.CornerRadius=r; c.Parent=p end
local function Pad(t,r,b,l,p)
  local u=Instance.new("UIPadding")
  u.PaddingTop=UDim.new(0,t) u.PaddingRight=UDim.new(0,r)
  u.PaddingBottom=UDim.new(0,b) u.PaddingLeft=UDim.new(0,l)
  u.Parent=p
end
local function VL(gap,p)
  local l=Instance.new("UIListLayout")
  l.FillDirection=Enum.FillDirection.Vertical
  l.Padding=UDim.new(0,gap) l.SortOrder=Enum.SortOrder.LayoutOrder
  l.HorizontalAlignment=Enum.HorizontalAlignment.Center
  l.Parent=p; return l
end
local function HL(gap,p)
  local l=Instance.new("UIListLayout")
  l.FillDirection=Enum.FillDirection.Horizontal
  l.Padding=UDim.new(0,gap) l.SortOrder=Enum.SortOrder.LayoutOrder
  l.VerticalAlignment=Enum.VerticalAlignment.Center
  l.Parent=p; return l
end

-- ════════════════════════════════════════════════════════
--   PHONE  constructor
-- ════════════════════════════════════════════════════════
local Phone = {}; Phone.__index = Phone

function Phone.new(opts)
  opts = opts or {}
  local self   = setmetatable({},Phone)
  local PW,PH  = 393, 680   -- iPhone 15 Pro screen size
  local accent = opts.Accent or C.Blue
  self.accent  = accent
  self.PW,self.PH = PW,PH
  self._visible  = true
  self._locked   = true
  self._ccOpen   = false
  self._apps     = {}
  self._dockApps = {}

  -- ── ScreenGui ─────────────────────────────────────────
  local SG = N("ScreenGui",{
    Name="PhoneUI_v4", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=200, Parent=GUI, Enabled=true,
  })
  self.SG = SG

  -- ── Phone Shell (physical body) ───────────────────────
  local Shell = N("Frame",{
    Name="Shell",
    Size=UDim2.new(0,PW+16,0,PH+28),
    Position=UDim2.new(.5,-(PW+16)/2,.5,-(PH+28)/2),
    BackgroundColor3=C.Shell,
    BorderSizePixel=0,
    Parent=SG,
  })
  Rnd(UDim.new(0,46),Shell)
  -- metal ring
  local ring = N("UIStroke",{Color=Color3.fromRGB(80,80,88),Thickness=2,Parent=Shell})
  self.Shell = Shell

  -- Side buttons (visual only)
  for _,b in ipairs({
    {s=UDim2.new(0,4,0,32),p=UDim2.new(0,-4,0,120)},   -- vol up
    {s=UDim2.new(0,4,0,52),p=UDim2.new(0,-4,0,162)},   -- vol dn
    {s=UDim2.new(0,4,0,72),p=UDim2.new(1,0,0,160)},    -- power
  }) do
    local btn=N("Frame",{Size=b.s,Position=b.p,BackgroundColor3=C.Shell,BorderSizePixel=0,Parent=Shell})
    Rnd(UDim.new(0,3),btn)
    N("UIStroke",{Color=Color3.fromRGB(80,80,88),Thickness=1,Parent=btn})
  end

  -- ── Screen ────────────────────────────────────────────
  local Screen = N("Frame",{
    Name="Screen",
    Size=UDim2.new(0,PW,0,PH),
    Position=UDim2.new(0,8,0,14),
    BackgroundColor3=C.Black,
    BorderSizePixel=0,
    ClipsDescendants=true,
    ZIndex=2,
    Parent=Shell,
  })
  Rnd(UDim.new(0,38),Screen)
  self.Screen = Screen

  -- ── Wallpaper ─────────────────────────────────────────
  local WP = N("Frame",{
    Size=UDim2.new(1,0,1,0), BackgroundColor3=C.Black,
    BorderSizePixel=0, ZIndex=2, Parent=Screen,
  })
  N("UIGradient",{
    Color=ColorSequence.new({
      ColorSequenceKeypoint.new(0,Color3.fromRGB(18,22,58)),
      ColorSequenceKeypoint.new(.45,Color3.fromRGB(8,8,18)),
      ColorSequenceKeypoint.new(1,Color3.fromRGB(42,8,60)),
    }),
    Rotation=165, Parent=WP,
  })
  self.Wallpaper = WP

  -- ── Status Bar (y=0, h=54) ────────────────────────────
  local SB = N("Frame",{
    Size=UDim2.new(1,0,0,54),
    BackgroundTransparency=1,
    ZIndex=80, Parent=Screen,
  })
  self.StatusBar = SB

  local TimeLbl = N("TextLabel",{
    Size=UDim2.new(0,70,1,0), Position=UDim2.new(0,22,0,0),
    BackgroundTransparency=1, Text="9:41",
    TextColor3=C.White, Font=C.Bold, TextSize=17,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=81, Parent=SB,
  })
  self._timeLbl = TimeLbl

  -- Battery / WiFi icons (right side)
  N("TextLabel",{
    Size=UDim2.new(0,90,1,0), Position=UDim2.new(1,-98,0,0),
    BackgroundTransparency=1, Text="▊▊▊  WiFi  ▓",
    TextColor3=C.White, Font=C.Bold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Right,
    ZIndex=81, Parent=SB,
  })

  -- Live clock
  task.spawn(function()
    while TimeLbl and TimeLbl.Parent do
      local h=tonumber(os.date("%I")); local m=os.date("%M")
      TimeLbl.Text = h..":"..m
      task.wait(15)
    end
  end)

  -- ── Dynamic Island ────────────────────────────────────
  local DI = N("Frame",{
    Name="DI",
    Size=UDim2.new(0,120,0,36),
    Position=UDim2.new(.5,-60,0,10),
    BackgroundColor3=C.Black,
    BorderSizePixel=0, ZIndex=90, Parent=Screen,
  })
  Rnd(UDim.new(0,18),DI)
  -- camera dot
  local camDot=N("Frame",{Size=UDim2.new(0,9,0,9),Position=UDim2.new(1,-22,0.5,-4),
    BackgroundColor3=Color3.fromRGB(18,50,100),BorderSizePixel=0,ZIndex=91,Parent=DI})
  Rnd(UDim.new(1,0),camDot)
  local faceDot=N("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(1,-35,0.5,-3),
    BackgroundColor3=Color3.fromRGB(28,28,32),BorderSizePixel=0,ZIndex=91,Parent=DI})
  Rnd(UDim.new(1,0),faceDot)
  self.DI = DI
  self._diContent = nil

  -- ── Home Indicator ────────────────────────────────────
  local HomeBar = N("TextButton",{
    Size=UDim2.new(0,134,0,5),
    Position=UDim2.new(.5,-67,1,-12),
    BackgroundColor3=C.White,
    BackgroundTransparency=.45,
    BorderSizePixel=0, Text="",
    AutoButtonColor=false,
    ZIndex=80, Parent=Screen,
  })
  Rnd(UDim.new(1,0),HomeBar)
  self.HomeBar = HomeBar
  -- Swipe home bar to open control centre
  HomeBar.MouseButton1Click:Connect(function() self:_toggleCC() end)

  -- ── Lock Screen ───────────────────────────────────────
  local LS = N("Frame",{
    Name="LockScreen", Size=UDim2.new(1,0,1,0),
    BackgroundColor3=C.Black, BorderSizePixel=0,
    ZIndex=70, Parent=Screen,
  })
  N("UIGradient",{
    Color=ColorSequence.new({
      ColorSequenceKeypoint.new(0,Color3.fromRGB(16,20,50)),
      ColorSequenceKeypoint.new(1,Color3.fromRGB(4,12,38)),
    }), Rotation=170, Parent=LS,
  })
  self.LockScreen = LS

  -- Lock clock
  local lsTime=N("TextLabel",{
    Size=UDim2.new(1,0,0,88), Position=UDim2.new(0,0,0,130),
    BackgroundTransparency=1, Text="9:41",
    TextColor3=C.White, Font=C.Bold, TextSize=80,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=71, Parent=LS,
  })
  local lsDate=N("TextLabel",{
    Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0,222),
    BackgroundTransparency=1, Text=os.date("%A, %B %d"),
    TextColor3=C.White, Font=C.Semi, TextSize=19,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=71, Parent=LS,
  })
  -- Swipe hint
  local swipeHint=N("TextLabel",{
    Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,1,-90),
    BackgroundTransparency=1, Text="⬆   Swipe up to unlock",
    TextColor3=C.White, Font=C.Semi, TextSize=15,
    TextXAlignment=Enum.TextXAlignment.Center,
    TextTransparency=.35, ZIndex=71, Parent=LS,
  })
  -- Pulse hint
  task.spawn(function()
    while swipeHint and swipeHint.Parent do
      sn(swipeHint,{TextTransparency=.65},1.2)
      task.wait(1.3)
      sn(swipeHint,{TextTransparency=.1},1.2)
      task.wait(1.3)
    end
  end)
  -- Live lock clock
  task.spawn(function()
    while lsTime and lsTime.Parent do
      local h=tonumber(os.date("%I")); local m=os.date("%M")
      lsTime.Text = h..":"..m
      task.wait(15)
    end
  end)

  -- Drag-up to unlock
  local _lsDrag,_lsY=false,0
  LS.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
      _lsDrag=true; _lsY=i.Position.Y
    end
  end)
  UIS.InputChanged:Connect(function(i)
    if _lsDrag then
      local delta = _lsY - i.Position.Y
      if delta > 70 then _lsDrag=false; self:_unlock() end
    end
  end)
  UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
      _lsDrag=false
    end
  end)

  -- ── SpringBoard ───────────────────────────────────────
  local SBrd = N("Frame",{
    Name="SpringBoard", Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1, BorderSizePixel=0,
    ZIndex=5, Visible=false, Parent=Screen,
  })
  self.SpringBoard = SBrd

  -- App grid (scrollable)
  local Grid = N("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-100),
    Position=UDim2.new(0,0,0,54),
    BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0),
    ZIndex=5, Parent=SBrd,
  })
  local GL = N("UIGridLayout",{
    CellSize=UDim2.new(0,72,0,90),
    CellPaddingSize=UDim2.new(0,16,0,10),
    HorizontalAlignment=Enum.HorizontalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Parent=Grid,
  })
  Pad(8,0,8,0,Grid)
  GL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Grid.CanvasSize=UDim2.new(0,0,0,GL.AbsoluteContentSize.Y+20)
  end)
  self.Grid = Grid

  -- Dock
  local Dock = N("Frame",{
    Size=UDim2.new(1,-32,0,82),
    Position=UDim2.new(0,16,1,-100),
    BackgroundColor3=C.White,
    BackgroundTransparency=.85,
    BorderSizePixel=0, ZIndex=6, Parent=SBrd,
  })
  Rnd(UDim.new(0,28),Dock)
  local DockRow=N("Frame",{
    Size=UDim2.new(1,-20,1,-14),
    Position=UDim2.new(0,10,0,7),
    BackgroundTransparency=1,ZIndex=6,Parent=Dock,
  })
  local dockHL=HL(14,DockRow)
  dockHL.HorizontalAlignment=Enum.HorizontalAlignment.Center
  self.DockRow = DockRow

  -- ── App View (full-screen app) ────────────────────────
  local AV = N("Frame",{
    Name="AppView", Size=UDim2.new(1,0,1,0),
    BackgroundColor3=C.BG, BorderSizePixel=0,
    ZIndex=40, Visible=false,
    ClipsDescendants=true, Parent=Screen,
  })
  self.AppView = AV

  -- App nav bar
  local ANB = N("Frame",{
    Size=UDim2.new(1,0,0,96),
    BackgroundColor3=C.L1,
    BorderSizePixel=0, ZIndex=41, Parent=AV,
  })
  Rnd(UDim.new(0,38),ANB)
  N("Frame",{Size=UDim2.new(1,0,0,38),Position=UDim2.new(0,0,1,-38),
    BackgroundColor3=C.L1,BorderSizePixel=0,ZIndex=41,Parent=ANB})
  N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
    BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=42,Parent=ANB})

  local BackBtn=N("TextButton",{
    Size=UDim2.new(0,80,0,34),Position=UDim2.new(0,10,0,54),
    BackgroundTransparency=1, Text="‹  Back",
    TextColor3=C.Blue, Font=C.Semi, TextSize=16,
    TextXAlignment=Enum.TextXAlignment.Left,
    AutoButtonColor=false, ZIndex=42, Parent=ANB,
  })
  local AppTitle=N("TextLabel",{
    Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,58),
    BackgroundTransparency=1, Text="",
    TextColor3=C.T1, Font=C.Bold, TextSize=20,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=42, Parent=ANB,
  })
  self.AppTitle = AppTitle

  BackBtn.MouseButton1Click:Connect(function() self:_closeApp() end)

  -- App scroll content
  local AC = N("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-96),
    Position=UDim2.new(0,0,0,96),
    BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0),
    ZIndex=41, Parent=AV,
  })
  self.AppContent = AC
  self._appList = VL(0,AC)

  -- ── Control Centre ────────────────────────────────────
  local CC = N("Frame",{
    Name="ControlCentre",
    Size=UDim2.new(1,-20,0,340),
    Position=UDim2.new(0,10,1,20),
    BackgroundColor3=C.L1,
    BackgroundTransparency=0.06,
    BorderSizePixel=0, ZIndex=75,
    ClipsDescendants=true,
    Parent=Screen,
  })
  Rnd(UDim.new(0,34),CC)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=0.3,Parent=CC})
  self.CC = CC

  N("TextLabel",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,14),
    BackgroundTransparency=1,Text="Control Centre",TextColor3=C.T2,
    Font=C.Semi,TextSize=13,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=76,Parent=CC})
  local ccHandle=N("Frame",{Size=UDim2.new(0,36,0,4),Position=UDim2.new(.5,-18,0,7),
    BackgroundColor3=C.White,BackgroundTransparency=.5,BorderSizePixel=0,ZIndex=76,Parent=CC})
  Rnd(UDim.new(1,0),ccHandle)

  -- CC quick-action tiles
  local ccGrid=N("Frame",{
    Size=UDim2.new(1,-24,0,168),Position=UDim2.new(0,12,0,48),
    BackgroundTransparency=1,ZIndex=76,Parent=CC,
  })
  local ccGL=N("UIGridLayout",{
    CellSize=UDim2.new(0,74,0,74),
    CellPaddingSize=UDim2.new(0,12,0,12),
    HorizontalAlignment=Enum.HorizontalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Parent=ccGrid,
  })
  self._ccToggles={}
  local ccTiles={
    {icon="✈️",lbl="Airplane",col=C.L3},
    {icon="📶",lbl="Cellular", col=C.Green},
    {icon="📡",lbl="Wi-Fi",    col=C.Blue},
    {icon="🔵",lbl="Bluetooth",col=C.Blue},
    {icon="🔦",lbl="Torch",    col=C.L3},
    {icon="🔕",lbl="Silent",   col=C.L3},
    {icon="📺",lbl="Mirror",   col=C.Blue},
    {icon="⏱️",lbl="Timer",    col=C.Orange},
  }
  for _,t in ipairs(ccTiles) do
    local on=false
    local tile=N("TextButton",{
      Size=UDim2.new(0,74,0,74),BackgroundColor3=C.L2,
      Text="",AutoButtonColor=false,ZIndex=77,Parent=ccGrid,
    })
    Rnd(UDim.new(0,22),tile)
    N("TextLabel",{Size=UDim2.new(1,0,0,42),Position=UDim2.new(0,0,0,8),
      BackgroundTransparency=1,Text=t.icon,TextScaled=true,
      Font=C.Bold,ZIndex=78,Parent=tile})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-18),
      BackgroundTransparency=1,Text=t.lbl,TextColor3=C.T2,
      Font=C.Semi,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=78,Parent=tile})
    tile.MouseButton1Click:Connect(function()
      on=not on
      tw(tile,{BackgroundColor3=on and t.col or C.L2},0.18)
    end)
    self._ccToggles[t.lbl]=tile
  end

  -- CC sliders
  local function CCSlider(y,icon,lbl)
    local row=N("Frame",{Size=UDim2.new(1,-24,0,38),Position=UDim2.new(0,12,0,y),
      BackgroundTransparency=1,ZIndex=76,Parent=CC})
    N("TextLabel",{Size=UDim2.new(0,26,1,0),BackgroundTransparency=1,Text=icon,
      TextScaled=true,ZIndex=77,Parent=row})
    local bg=N("Frame",{Size=UDim2.new(1,-36,0,4),Position=UDim2.new(0,30,0.5,-2),
      BackgroundColor3=C.L3,ZIndex=77,Parent=row})
    Rnd(UDim.new(1,0),bg)
    local fill=N("Frame",{Size=UDim2.new(0.7,0,1,0),BackgroundColor3=C.White,ZIndex=78,Parent=bg})
    Rnd(UDim.new(1,0),fill)
    local thumb=N("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0.7,-10,0.5,-10),
      BackgroundColor3=C.White,ZIndex=79,Parent=bg})
    Rnd(UDim.new(1,0),thumb)

    -- make slider draggable
    local sliding=false
    local hitArea=N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
      Text="",AutoButtonColor=false,ZIndex=80,Parent=bg})
    hitArea.InputBegan:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1
      or i.UserInputType==Enum.UserInputType.Touch then sliding=true end
    end)
    UIS.InputChanged:Connect(function(i)
      if not sliding then return end
      local tp=bg.AbsolutePosition.X; local ts=bg.AbsoluteSize.X
      if ts<=0 then return end
      local pct=math.clamp((i.Position.X-tp)/ts,0,1)
      fill.Size=UDim2.new(pct,0,1,0)
      thumb.Position=UDim2.new(pct,-10,0.5,-10)
    end)
    UIS.InputEnded:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1
      or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
  end
  CCSlider(226,"🔊","Volume")
  CCSlider(270,"☀️","Brightness")

  -- Close CC on screen tap
  Screen.InputBegan:Connect(function(i)
    if self._ccOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then
      self:_closeCC()
    end
  end)

  -- ── Drag to move phone ────────────────────────────────
  local _dragPhone,_dragStart,_posStart=false,nil,nil
  Shell.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
      _dragPhone=true; _dragStart=i.Position; _posStart=Shell.Position
    end
  end)
  UIS.InputChanged:Connect(function(i)
    if _dragPhone and i.UserInputType==Enum.UserInputType.MouseMovement then
      local d=i.Position-_dragStart
      Shell.Position=UDim2.new(_posStart.X.Scale,_posStart.X.Offset+d.X,
                                _posStart.Y.Scale,_posStart.Y.Offset+d.Y)
    end
  end)
  UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then _dragPhone=false end
  end)

  -- ── Entrance animation ────────────────────────────────
  Shell.Size=UDim2.new(0,PW+16,0,0)
  Shell.BackgroundTransparency=1
  task.defer(function()
    sn(Shell,{BackgroundTransparency=0},.3)
    sp(Shell,{Size=UDim2.new(0,PW+16,0,PH+28)},.55)
  end)

  return self
end

-- ════════════════════════════════════════════════════════
--  INTERNAL: Unlock
-- ════════════════════════════════════════════════════════
function Phone:_unlock()
  if not self._locked then return end
  self._locked=false
  local LS=self.LockScreen; local SB=self.SpringBoard

  qt(LS,{Position=UDim2.new(0,0,0,-self.PH-30),.4})
  task.delay(.1,function()
    SB.Visible=true
    SB.Size=UDim2.new(1,0,1,0)
    SB.Position=UDim2.new(0,0,0,40)
    tw(SB,{BackgroundTransparency=0},0)
    qt(SB,{Position=UDim2.new(0,0,0,0)},.38)
  end)
  task.delay(.44,function() LS.Visible=false end)
end

function Phone:_lock()
  if self._locked then return end
  self._locked=true
  self:_closeApp()
  local LS=self.LockScreen; local SB=self.SpringBoard
  LS.Position=UDim2.new(0,0,0,-self.PH-30)
  LS.Visible=true
  qt(SB,{Position=UDim2.new(0,0,0,40)},.32)
  qt(LS,{Position=UDim2.new(0,0,0,0)},.38)
  task.delay(.4,function() SB.Visible=false end)
end

-- ════════════════════════════════════════════════════════
--  INTERNAL: Control Centre
-- ════════════════════════════════════════════════════════
function Phone:_openCC()
  self._ccOpen=true
  sp(self.CC,{Position=UDim2.new(0,10,1,-350)},.42)
end
function Phone:_closeCC()
  self._ccOpen=false
  sn(self.CC,{Position=UDim2.new(0,10,1,20)},.3)
end
function Phone:_toggleCC()
  if self._ccOpen then self:_closeCC() else self:_openCC() end
end

-- ════════════════════════════════════════════════════════
--  INTERNAL: Open / Close App  (iOS zoom animation)
-- ════════════════════════════════════════════════════════
function Phone:_openApp(appData)
  local AV=self.AppView
  self.AppTitle.Text=appData.name
  self._currentApp=appData

  -- Rebuild content
  for _,c in ipairs(self.AppContent:GetChildren()) do
    if not c:IsA("UIListLayout") then c:Destroy() end
  end
  self.AppContent.CanvasSize=UDim2.new(0,0,0,0)
  self._appList=VL(0,self.AppContent)

  -- Call builder
  if appData.builder then
    appData.builder(self,self.AppContent,self._appList)
  end
  -- Auto canvas size
  self._appList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    self.AppContent.CanvasSize=UDim2.new(0,0,0,self._appList.AbsoluteContentSize.Y+40)
  end)

  -- Zoom from icon position
  local iconBtn=appData._btn
  local sAbs=self.Screen.AbsolutePosition
  local iAbs=iconBtn and iconBtn.AbsolutePosition or Vector2.new(self.PW/2,self.PH/2)
  local iSz =iconBtn and iconBtn.AbsoluteSize    or Vector2.new(60,60)
  local relX=iAbs.X-sAbs.X; local relY=iAbs.Y-sAbs.Y

  AV.Visible=true
  AV.Size=UDim2.new(0,iSz.X,0,iSz.Y)
  AV.Position=UDim2.new(0,relX,0,relY)
  AV.BackgroundTransparency=1

  tw(AV,{
    Size=UDim2.new(1,0,1,0),
    Position=UDim2.new(0,0,0,0),
    BackgroundTransparency=0,
  },.36,Enum.EasingStyle.Quart)
end

function Phone:_closeApp()
  local AV=self.AppView
  if not AV.Visible then return end
  local appData=self._currentApp
  local sAbs=self.Screen.AbsolutePosition
  local iAbs=appData and appData._btn and appData._btn.AbsolutePosition or Vector2.new(self.PW/2,self.PH/2)
  local iSz =appData and appData._btn and appData._btn.AbsoluteSize    or Vector2.new(60,60)
  local relX=iAbs.X-sAbs.X; local relY=iAbs.Y-sAbs.Y

  tw(AV,{
    Size=UDim2.new(0,iSz.X,0,iSz.Y),
    Position=UDim2.new(0,relX,0,relY),
    BackgroundTransparency=1,
  },.3,Enum.EasingStyle.Quart)
  task.delay(.32,function()
    AV.Visible=false
    self._currentApp=nil
  end)
end

-- ════════════════════════════════════════════════════════
--  ADD APP  (creates SpringBoard icon + registers builder)
-- ════════════════════════════════════════════════════════
function Phone:AddApp(opts)
  opts=opts or {}
  local name    = opts.Name    or "App"
  local icon    = opts.Icon    or "📱"
  local color   = opts.Color   or self.accent
  local inDock  = opts.InDock  or false
  local builder = opts.Builder or function()end
  local appData = {name=name,icon=icon,color=color,builder=builder}

  local parent = inDock and self.DockRow or self.Grid
  local iconSz = inDock and 58 or 62

  -- Icon wrapper (button + label stack)
  local wrap=N("Frame",{
    Size=UDim2.new(0,iconSz,0,inDock and iconSz or 86),
    BackgroundTransparency=1, ZIndex=5, Parent=parent,
  })
  local iconBtn=N("TextButton",{
    Size=UDim2.new(0,iconSz,0,iconSz),
    BackgroundColor3=color, Text="",
    AutoButtonColor=false, ZIndex=5, Parent=wrap,
  })
  Rnd(UDim.new(0,14),iconBtn)
  -- icon gradient
  N("UIGradient",{
    Color=ColorSequence.new({
      ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
      ColorSequenceKeypoint.new(1,color),
    }),
    Transparency=NumberSequence.new({
      NumberSequenceKeypoint.new(0,0.55),
      NumberSequenceKeypoint.new(1,0),
    }),
    Rotation=140, Parent=iconBtn,
  })
  N("TextLabel",{
    Size=UDim2.new(1,0,0,44), Position=UDim2.new(0,0,0,8),
    BackgroundTransparency=1, Text=icon,
    TextScaled=true, Font=C.Bold, ZIndex=6, Parent=iconBtn,
  })
  if not inDock then
    N("TextLabel",{
      Size=UDim2.new(0,iconSz+10,0,18),
      Position=UDim2.new(.5,-(iconSz+10)/2,0,iconSz+2),
      BackgroundTransparency=1, Text=name,
      TextColor3=C.White, Font=C.Semi, TextSize=11,
      TextXAlignment=Enum.TextXAlignment.Center,
      TextWrapped=true, ZIndex=5, Parent=wrap,
    })
  end
  appData._btn=iconBtn

  -- Press: scale down
  iconBtn.MouseButton1Down:Connect(function()
    sp(iconBtn,{Size=UDim2.new(0,iconSz-8,0,iconSz-8),.22})
  end)
  -- Release: scale up then open
  iconBtn.MouseButton1Click:Connect(function()
    sp(iconBtn,{Size=UDim2.new(0,iconSz,0,iconSz),.3})
    task.delay(.12,function() self:_openApp(appData) end)
  end)

  table.insert(self._apps,appData)
  return appData
end

-- ════════════════════════════════════════════════════════
--  DYNAMIC ISLAND NOTIFICATION  (true iOS style)
-- ════════════════════════════════════════════════════════
function Phone:Notify(opts)
  opts=opts or {}
  local title  = opts.Title    or "Notification"
  local body   = opts.Body     or ""
  local icon   = opts.Icon     or "📱"
  local appLbl = opts.App      or title
  local dur    = opts.Duration or 4
  local accent = opts.Accent   or self.accent

  local DI=self.DI
  local PW=self.PW

  -- Destroy old content
  if self._diContent then self._diContent:Destroy() end

  -- Phase 1: expand to pill notification
  sp(DI,{
    Size=UDim2.new(0,PW-40,0,60),
    Position=UDim2.new(.5,-(PW-40)/2,0,8),
  },.38)

  local content=N("Frame",{
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    ClipsDescendants=true,
    ZIndex=92,Parent=DI,
  })
  self._diContent=content
  Pad(0,16,0,16,content)

  task.delay(.18,function()
    if not content.Parent then return end
    local row=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=92,Parent=content})
    HL(10,row)
    -- App icon badge
    local badge=N("Frame",{Size=UDim2.new(0,38,0,38),BackgroundColor3=accent,
      BackgroundTransparency=.72,ZIndex=93,Parent=row})
    Rnd(UDim.new(0,10),badge)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,
      TextScaled=true,Font=C.Bold,ZIndex=94,Parent=badge})
    -- Text
    local tc=N("Frame",{Size=UDim2.new(1,-54,1,0),BackgroundTransparency=1,ZIndex=93,Parent=row})
    VL(1,tc)
    N("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,
      Text=appLbl:upper(),TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,
      Font=C.Semi,TextSize=10,ZIndex=94,Parent=tc})
    N("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
      Text=title,TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,
      Font=C.Bold,TextSize=14,ZIndex=94,Parent=tc})
    N("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,
      Text=body,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,
      Font=C.Reg,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=94,Parent=tc})
  end)

  -- Phase 2: shrink back to pill
  task.delay(dur,function()
    if not DI.Parent then return end
    if self._diContent==content then
      sn(content,{BackgroundTransparency=1},.18)
      task.delay(.2,function()
        if content.Parent then content:Destroy() end
        self._diContent=nil
      end)
    end
    sp(DI,{Size=UDim2.new(0,120,0,36),Position=UDim2.new(.5,-60,0,10)},.4)
  end)
end

-- ════════════════════════════════════════════════════════
--  SHOW / HIDE / TOGGLE
-- ════════════════════════════════════════════════════════
function Phone:Show()
  -- Simply enable the ScreenGui and animate Shell in
  self.SG.Enabled=true
  self._visible=true
  local S=self.Shell
  S.BackgroundTransparency=1
  S.Size=UDim2.new(0,self.PW+16,0,0)
  sn(S,{BackgroundTransparency=0},.28)
  sp(S,{Size=UDim2.new(0,self.PW+16,0,self.PH+28)},.52)
end

function Phone:Hide()
  -- Animate Shell out then disable ScreenGui
  self._visible=false
  local S=self.Shell
  sn(S,{Size=UDim2.new(0,self.PW+16,0,0),BackgroundTransparency=1},.28)
  task.delay(.32,function()
    self.SG.Enabled=false
  end)
end

function Phone:Toggle()
  -- Toggle uses _visible flag + SG.Enabled — NO size tricks that cause gray bars
  if self._visible then
    self:Hide()
  else
    self:Show()
  end
end

-- ════════════════════════════════════════════════════════
--  APP CONTENT BUILDERS  (helpers for app builders)
-- ════════════════════════════════════════════════════════

-- Section header inside app
function Phone:Section(parent,label)
  local f=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,ZIndex=42,Parent=parent})
  Pad(10,16,0,16,f)
  N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text=(label or ""):upper(),TextColor3=C.T3,
    TextXAlignment=Enum.TextXAlignment.Left,Font=C.Semi,TextSize=11,ZIndex=42,Parent=f})
  return f
end

-- iOS grouped card (rows stack inside it)
function Phone:Group(parent)
  local card=N("Frame",{
    Size=UDim2.new(1,-28,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundColor3=C.L1,
    BorderSizePixel=0,ZIndex=42,Parent=parent,
  })
  Rnd(UDim.new(0,16),card)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=card})
  local list=VL(0,card)
  return card,list
end

-- Row with left icon badge, title, right value, optional disclosure arrow
function Phone:Row(parent,opts)
  opts=opts or {}
  local h=opts.Height or 50
  local row=N("Frame",{Size=UDim2.new(1,0,0,h),BackgroundTransparency=1,ZIndex=43,Parent=parent})
  Pad(0,14,0,14,row)

  local xOff=0
  if opts.IconBg then
    local ib=N("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,0,.5,-15),
      BackgroundColor3=opts.IconBg,ZIndex=44,Parent=row})
    Rnd(UDim.new(0,8),ib)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=opts.Icon or "",
      TextScaled=true,Font=C.Bold,ZIndex=45,Parent=ib})
    xOff=42
  end
  N("TextLabel",{
    Size=UDim2.new(.5,0,1,0),Position=UDim2.new(0,xOff,0,0),
    BackgroundTransparency=1,Text=opts.Title or "",TextColor3=C.T1,
    TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=15,ZIndex=44,Parent=row,
  })
  local valLbl=N("TextLabel",{
    Size=UDim2.new(.38,0,1,0),Position=UDim2.new(.58,0,0,0),
    BackgroundTransparency=1,Text=opts.Value or "",TextColor3=C.T2,
    TextXAlignment=Enum.TextXAlignment.Right,Font=C.Reg,TextSize=15,ZIndex=44,Parent=row,
  })
  if opts.Disclosure~=false then
    N("TextLabel",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),
      BackgroundTransparency=1,Text="›",TextColor3=C.T3,
      TextXAlignment=Enum.TextXAlignment.Center,Font=C.Bold,TextSize=20,ZIndex=44,Parent=row})
  end
  -- hairline separator
  N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,xOff,1,-1),
    BackgroundColor3=C.Sep,BackgroundTransparency=.4,BorderSizePixel=0,ZIndex=43,Parent=row})
  -- hit area
  if opts.Callback then
    local hit=N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
      Text="",AutoButtonColor=false,ZIndex=46,Parent=row})
    hit.MouseButton1Down:Connect(function() tw(row,{BackgroundColor3=C.L2},0.08); row.BackgroundTransparency=0 end)
    hit.MouseButton1Up:Connect(function()   sn(row,{BackgroundTransparency=1},.2) end)
    hit.MouseButton1Click:Connect(opts.Callback)
  end
  return row,valLbl
end

-- iOS Toggle
function Phone:ToggleRow(parent,opts)
  opts=opts or {}
  local val=opts.Default or false
  local col=opts.Accent  or C.Green
  local cb =opts.Callback or function()end
  local row,_=self:Row(parent,{Title=opts.Title,Icon=opts.Icon,IconBg=opts.IconBg,Disclosure=false})

  local track=N("Frame",{Size=UDim2.new(0,51,0,31),Position=UDim2.new(1,-51,.5,-15),
    BackgroundColor3=val and col or C.L3,ZIndex=44,Parent=row})
  Rnd(UDim.new(1,0),track)
  local thumb=N("Frame",{Size=UDim2.new(0,27,0,27),
    Position=UDim2.new(0,val and 22 or 2,.5,-13),
    BackgroundColor3=C.White,ZIndex=46,Parent=track})
  Rnd(UDim.new(1,0),thumb)
  N("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.White),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,210)),
  }),Rotation=120,Parent=thumb})
  local function Refresh()
    tw(track,{BackgroundColor3=val and col or C.L3},.2)
    sp(thumb,{Position=UDim2.new(0,val and 22 or 2,.5,-13)},.42)
  end
  local hit=N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text="",AutoButtonColor=false,ZIndex=47,Parent=row})
  hit.MouseButton1Click:Connect(function() val=not val; Refresh(); cb(val) end)
  Refresh()
  local obj={}; function obj:Get() return val end; function obj:Set(v) val=v;Refresh();cb(v) end
  return obj
end

-- iOS Slider
function Phone:SliderRow(parent,opts)
  opts=opts or {}
  local mn=opts.Min or 0; local mx=opts.Max or 100
  local step=opts.Step or 1; local col=opts.Accent or C.Blue
  local val=math.clamp(opts.Default or mn,mn,mx)
  local cb=opts.Callback or function()end

  local card=N("Frame",{Size=UDim2.new(1,-28,0,66),BackgroundColor3=C.L1,ZIndex=42,Parent=parent})
  Rnd(UDim.new(0,16),card)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=card})
  Pad(10,14,10,14,card)

  local top=N("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=43,Parent=card})
  N("TextLabel",{Size=UDim2.new(.65,0,1,0),BackgroundTransparency=1,Text=opts.Title or "",
    TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=14,ZIndex=43,Parent=top})
  local vLbl=N("TextLabel",{Size=UDim2.new(.35,0,1,0),Position=UDim2.new(.65,0,0,0),
    BackgroundTransparency=1,Text=tostring(val),TextColor3=col,
    TextXAlignment=Enum.TextXAlignment.Right,Font=C.Bold,TextSize=14,ZIndex=43,Parent=top})

  local hitArea=N("TextButton",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,1,-28),
    BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=46,Parent=card})
  local bg=N("Frame",{Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,.5,-2),
    BackgroundColor3=C.L3,ZIndex=43,Parent=hitArea})
  Rnd(UDim.new(1,0),bg)
  local fill=N("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=col,ZIndex=44,Parent=bg})
  Rnd(UDim.new(1,0),fill)
  local thumb=N("Frame",{Size=UDim2.new(0,22,0,22),
    Position=UDim2.new((val-mn)/(mx-mn),-11,.5,-11),BackgroundColor3=C.White,ZIndex=45,Parent=bg})
  Rnd(UDim.new(1,0),thumb)

  local sliding=false
  local function setV(absX)
    local tp=bg.AbsolutePosition.X; local ts=bg.AbsoluteSize.X
    if ts<=0 then return end
    local r=math.clamp((absX-tp)/ts,0,1)
    val=math.clamp(math.round((mn+(mx-mn)*r)/step)*step,mn,mx)
    local p=(val-mn)/(mx-mn)
    fill.Size=UDim2.new(p,0,1,0)
    thumb.Position=UDim2.new(p,-11,.5,-11)
    vLbl.Text=tostring(val); cb(val)
  end
  for _,src in ipairs({hitArea,bg}) do
    src.InputBegan:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1
      or i.UserInputType==Enum.UserInputType.Touch then
        sliding=true; sp(thumb,{Size=UDim2.new(0,26,0,26)},.25); setV(i.Position.X)
      end
    end)
  end
  UIS.InputChanged:Connect(function(i)
    if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch) then setV(i.Position.X) end
  end)
  UIS.InputEnded:Connect(function(i)
    if sliding and (i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch) then
      sliding=false; sp(thumb,{Size=UDim2.new(0,22,0,22)},.3)
    end
  end)
  local obj={}
  function obj:Get() return val end
  function obj:Set(v)
    val=math.clamp(v,mn,mx); local p=(val-mn)/(mx-mn)
    tw(fill,{Size=UDim2.new(p,0,1,0)},.18)
    thumb.Position=UDim2.new(p,-11,.5,-11); vLbl.Text=tostring(val); cb(val)
  end
  return obj
end

-- Button
function Phone:Button(parent,opts)
  opts=opts or {}
  local pals={
    Primary  ={bg=opts.Accent or C.Blue, txt=C.White},
    Secondary={bg=C.L2,txt=opts.Accent or C.Blue},
    Danger   ={bg=C.Red,txt=C.White},
    Success  ={bg=C.Green,txt=C.White},
  }
  local pal=pals[opts.Style or "Primary"] or pals.Primary
  local btn=N("TextButton",{
    Size=UDim2.new(1,-28,0,48),
    BackgroundColor3=pal.bg,
    Text=(opts.Icon and opts.Icon.."  " or "")..(opts.Title or "Button"),
    TextColor3=pal.txt,Font=C.Semi,TextSize=15,
    AutoButtonColor=false,ZIndex=42,Parent=parent,
  })
  Rnd(UDim.new(0,16),btn)
  btn.MouseButton1Down:Connect(function()
    sp(btn,{Size=UDim2.new(1,-38,0,46)},.22)
    tw(btn,{BackgroundTransparency=.18},.08)
  end)
  btn.MouseButton1Up:Connect(function()
    sp(btn,{Size=UDim2.new(1,-28,0,48)},.3)
    tw(btn,{BackgroundTransparency=0},.12)
  end)
  btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=pal.bg:Lerp(C.White,.1)},.14) end)
  btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=pal.bg},.14) end)
  if opts.Callback then btn.MouseButton1Click:Connect(opts.Callback) end
  return btn
end

-- Dropdown
function Phone:Dropdown(parent,opts)
  opts=opts or {}
  local options=opts.Options or {}; local val=opts.Default or options[1]
  local col=opts.Accent or C.Blue; local cb=opts.Callback or function()end
  local open=false; local iH=42
  local maxShow=math.min(#options,5); local listH=maxShow*iH

  local wrap=N("Frame",{Size=UDim2.new(1,-28,0,52),BackgroundTransparency=1,
    ClipsDescendants=false,ZIndex=50,Parent=parent})
  local hdr=N("TextButton",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.L1,
    Text="",AutoButtonColor=false,ZIndex=50,Parent=wrap})
  Rnd(UDim.new(0,16),hdr)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=hdr})
  Pad(0,14,0,14,hdr)
  N("TextLabel",{Size=UDim2.new(.54,0,1,0),BackgroundTransparency=1,Text=opts.Title or "",
    TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=15,ZIndex=51,Parent=hdr})
  local selLbl=N("TextLabel",{Size=UDim2.new(.32,0,1,0),Position=UDim2.new(.58,0,0,0),
    BackgroundTransparency=1,Text=tostring(val or ""),TextColor3=col,
    TextXAlignment=Enum.TextXAlignment.Right,Font=C.Semi,TextSize=14,ZIndex=51,Parent=hdr})
  local chev=N("TextLabel",{Size=UDim2.new(0,12,1,0),Position=UDim2.new(1,-12,0,0),
    BackgroundTransparency=1,Text="›",TextColor3=C.T3,
    TextXAlignment=Enum.TextXAlignment.Center,Font=C.Bold,TextSize=20,ZIndex=51,Parent=hdr})

  -- Drop panel parented to Screen (escapes all scroll clipping)
  local screenParent=self.Screen
  local dp=N("Frame",{Size=UDim2.new(0,0,0,0),BackgroundColor3=C.L2,
    ClipsDescendants=true,Visible=false,ZIndex=200,Parent=screenParent})
  Rnd(UDim.new(0,16),dp)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.25,Parent=dp})
  local ds=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Sep,
    CanvasSize=UDim2.new(0,0,0,0),ZIndex=201,Parent=dp})
  local dl=VL(0,ds)
  dl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ds.CanvasSize=UDim2.new(0,0,0,dl.AbsoluteContentSize.Y)
  end)
  local checks={}
  for _,opt in ipairs(options) do
    local ib=N("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundTransparency=1,
      Text="",AutoButtonColor=false,ZIndex=202,Parent=ds})
    Pad(0,14,0,14,ib)
    N("Frame",{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,1,-1),
      BackgroundColor3=C.Sep,BackgroundTransparency=.5,BorderSizePixel=0,ZIndex=202,Parent=ib})
    local ck=N("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-16,0,0),
      BackgroundTransparency=1,Text="✓",TextColor3=col,TextScaled=true,Font=C.Bold,
      TextTransparency=opt==val and 0 or 1,ZIndex=203,Parent=ib})
    local ol=N("TextLabel",{Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,
      Text=tostring(opt),TextColor3=opt==val and col or C.T1,
      TextXAlignment=Enum.TextXAlignment.Left,Font=opt==val and C.Semi or C.Reg,
      TextSize=15,ZIndex=203,Parent=ib})
    table.insert(checks,{ck=ck,lbl=ol,opt=opt})
    ib.MouseEnter:Connect(function() ib.BackgroundColor3=C.L3; tw(ib,{BackgroundTransparency=0},.1) end)
    ib.MouseLeave:Connect(function() tw(ib,{BackgroundTransparency=1},.1) end)
    ib.MouseButton1Click:Connect(function()
      val=opt; selLbl.Text=tostring(opt)
      for _,ch in ipairs(checks) do
        local me=ch.opt==opt
        tw(ch.ck,{TextTransparency=me and 0 or 1},.15)
        tw(ch.lbl,{TextColor3=me and col or C.T1},.15)
        ch.lbl.Font=me and C.Semi or C.Reg
      end
      cb(opt); open=false
      sn(dp,{Size=UDim2.new(0,dp.AbsoluteSize.X,0,0)},.2)
      task.delay(.22,function() dp.Visible=false end)
      sn(wrap,{Size=UDim2.new(1,-28,0,52)},.2)
      tw(chev,{Rotation=0},.2)
    end)
  end
  local function openDrop()
    local hAbs=hdr.AbsolutePosition
    local sAbs=screenParent.AbsolutePosition
    local W=hdr.AbsoluteSize.X
    dp.Size=UDim2.new(0,W,0,0)
    dp.Position=UDim2.new(0,hAbs.X-sAbs.X,0,hAbs.Y-sAbs.Y+54)
    dp.Visible=true
    sp(dp,{Size=UDim2.new(0,W,0,listH)},.38)
    sp(wrap,{Size=UDim2.new(1,-28,0,52+listH+6)},.38)
    tw(chev,{Rotation=90},.22)
  end
  hdr.MouseButton1Click:Connect(function()
    open=not open
    if open then openDrop()
    else
      sn(dp,{Size=UDim2.new(0,dp.AbsoluteSize.X,0,0)},.22)
      task.delay(.24,function() dp.Visible=false end)
      sn(wrap,{Size=UDim2.new(1,-28,0,52)},.22)
      tw(chev,{Rotation=0},.22)
    end
  end)
  local obj={}
  function obj:Get() return val end
  function obj:Set(v) val=v;selLbl.Text=tostring(v);cb(v) end
  return obj
end

return Phone

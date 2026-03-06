--[[  PhoneUI v4.3  ]]

local Plr=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local LP=Plr.LocalPlayer
local GUI do
  local ok,cg=pcall(function()return game:GetService("CoreGui")end)
  GUI=(ok and cg)or LP:WaitForChild("PlayerGui")
end

local C={
  Black=Color3.fromRGB(0,0,0),Shell=Color3.fromRGB(22,22,24),
  BG=Color3.fromRGB(0,0,0),L1=Color3.fromRGB(28,28,30),
  L2=Color3.fromRGB(44,44,46),L3=Color3.fromRGB(58,58,60),
  Sep=Color3.fromRGB(56,56,58),White=Color3.fromRGB(255,255,255),
  Blue=Color3.fromRGB(10,132,255),Green=Color3.fromRGB(52,211,91),
  Red=Color3.fromRGB(255,69,58),Orange=Color3.fromRGB(255,159,10),
  Purple=Color3.fromRGB(191,90,242),Teal=Color3.fromRGB(90,200,250),
  Yellow=Color3.fromRGB(255,214,10),Pink=Color3.fromRGB(255,55,95),
  T1=Color3.fromRGB(255,255,255),T2=Color3.fromRGB(155,155,165),
  T3=Color3.fromRGB(88,88,98),
  Bold=Enum.Font.GothamBold,Semi=Enum.Font.GothamSemibold,Reg=Enum.Font.Gotham,
}

local function tw(o,p,t,s,d)
  if not o or not o.Parent then return end
  TS:Create(o,TweenInfo.new(t or .22,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play()
end
local sp=function(o,p,t)tw(o,p,t or.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out)end
local sn=function(o,p,t)tw(o,p,t or.28,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)end
local qt=function(o,p,t)tw(o,p,t or.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)end

local function N(cls,props)
  local o=Instance.new(cls)
  for k,v in pairs(props or{})do o[k]=v end
  return o
end
local function Rnd(r,p) N("UICorner",{CornerRadius=r,Parent=p}) end
local function Pad(t,r,b,l,p) N("UIPadding",{PaddingTop=UDim.new(0,t),PaddingRight=UDim.new(0,r),PaddingBottom=UDim.new(0,b),PaddingLeft=UDim.new(0,l),Parent=p}) end
local function VL(gap,p) return N("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=p}) end
local function HL(gap,p) return N("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=p}) end

local Phone={}; Phone.__index=Phone

function Phone.new(opts)
  opts=opts or{}
  local self=setmetatable({},Phone)
  local PW,PH=393,680
  self.PW,self.PH=PW,PH
  self.accent=opts.Accent or C.Blue
  self._visible=true;self._locked=true;self._ccOpen=false;self._apps={}
  self._settings={username="Player",displayName="",accentName="Blue",accentColor=C.Blue,wallpaper="Aurora"}

  -- SG: Global ZIndex so all numbers are absolute
  local SG=N("ScreenGui",{Name="PhoneUI",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=200,Parent=GUI})
  self.SG=SG

  -- SHELL (ZIndex 1-2)
  local Shell=N("Frame",{Name="Shell",
    Size=UDim2.new(0,PW+14,0,PH+26),
    Position=UDim2.new(.5,-(PW+14)/2,.5,-(PH+26)/2),
    BackgroundColor3=C.Shell,BorderSizePixel=0,ZIndex=1,Parent=SG})
  Rnd(UDim.new(0,44),Shell)
  N("UIStroke",{Color=Color3.fromRGB(75,75,82),Thickness=1.5,Parent=Shell})
  self.Shell=Shell

  for _,b in ipairs({
    {UDim2.new(0,4,0,30),UDim2.new(0,-4,0,100)},
    {UDim2.new(0,4,0,48),UDim2.new(0,-4,0,140)},
    {UDim2.new(0,4,0,64),UDim2.new(1,0,0,138)},
  }) do
    local s=N("Frame",{Size=b[1],Position=b[2],BackgroundColor3=C.Shell,BorderSizePixel=0,ZIndex=2,Parent=Shell})
    Rnd(UDim.new(0,3),s); N("UIStroke",{Color=Color3.fromRGB(75,75,82),Thickness=1,Parent=s})
  end

  -- SCREEN (ZIndex 3) — clips visually for rounded corners, does NOT affect input layering with Global ZIndex
  local Screen=N("Frame",{Name="Screen",Size=UDim2.new(0,PW,0,PH),Position=UDim2.new(0,7,0,13),
    BackgroundColor3=C.Black,BorderSizePixel=0,ClipsDescendants=true,ZIndex=3,Parent=Shell})
  Rnd(UDim.new(0,36),Screen)
  self.Screen=Screen

  -- ZIndex layout (Global):
  --  5  Wallpaper
  -- 10  SpringBoard / icons
  -- 15  LockScreen
  -- 20  UnlockBtn
  -- 25  StatusBar
  -- 35  AppView  (NO ClipsDescendants — Screen already clips)
  -- 45  CC
  -- 80  DynamicIsland  (child of SG, not Screen — never clipped by AppView)
  -- 200 Unlock btn overlay
  -- 500 Dropdown panels (child of SG)

  -- Wallpaper
  local WP=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.Black,BorderSizePixel=0,ZIndex=5,Parent=Screen})
  N("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(18,22,58)),
    ColorSequenceKeypoint.new(.45,Color3.fromRGB(8,8,18)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(42,8,60))}),Rotation=165,Parent=WP})
  self.Wallpaper=WP

  -- SpringBoard
  local SBrd=N("Frame",{Name="SpringBoard",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=10,Visible=false,Parent=Screen})
  self.SpringBoard=SBrd
  local Grid=N("ScrollingFrame",{Size=UDim2.new(1,0,1,-100),Position=UDim2.new(0,0,0,54),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=10,Parent=SBrd})
  local GL=N("UIGridLayout",{CellSize=UDim2.new(0,76,0,92),
    HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Parent=Grid})
  Pad(12,14,8,14,Grid)
  GL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Grid.CanvasSize=UDim2.new(0,0,0,GL.AbsoluteContentSize.Y+20)
  end)
  self.Grid=Grid

  local Dock=N("Frame",{Size=UDim2.new(1,-32,0,82),Position=UDim2.new(0,16,1,-100),
    BackgroundColor3=C.White,BackgroundTransparency=.85,BorderSizePixel=0,ZIndex=11,Parent=SBrd})
  Rnd(UDim.new(0,28),Dock)
  local DockRow=N("Frame",{Size=UDim2.new(1,-20,1,-14),Position=UDim2.new(0,10,0,7),BackgroundTransparency=1,ZIndex=11,Parent=Dock})
  local dHL=HL(14,DockRow); dHL.HorizontalAlignment=Enum.HorizontalAlignment.Center
  self.DockRow=DockRow

  -- LockScreen
  local LS=N("Frame",{Name="LockScreen",Size=UDim2.new(1,0,1,0),BackgroundColor3=C.Black,BorderSizePixel=0,ZIndex=15,Parent=Screen})
  N("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(16,20,50)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(4,12,38))}),Rotation=170,Parent=LS})
  self.LockScreen=LS
  local lsTime=N("TextLabel",{Size=UDim2.new(1,0,0,88),Position=UDim2.new(0,0,0,130),
    BackgroundTransparency=1,Text="9:41",TextColor3=C.White,Font=C.Bold,TextSize=80,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=16,Parent=LS})
  N("TextLabel",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,222),
    BackgroundTransparency=1,Text=os.date("%A, %B %d"),TextColor3=C.White,Font=C.Semi,TextSize=19,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=16,Parent=LS})
  task.spawn(function()
    while lsTime and lsTime.Parent do
      lsTime.Text=tostring(tonumber(os.date("%I")))..":"..os.date("%M"); task.wait(15)
    end
  end)

  -- Unlock button — ZIndex 20
  local UB=N("TextButton",{Size=UDim2.new(0,200,0,52),Position=UDim2.new(.5,-100,1,-130),
    BackgroundColor3=C.White,BackgroundTransparency=.2,BorderSizePixel=0,
    Text="🔓   Unlock",TextColor3=C.White,Font=C.Bold,TextSize=18,
    AutoButtonColor=false,ZIndex=20,Parent=Screen})
  Rnd(UDim.new(1,0),UB)
  N("UIStroke",{Color=C.White,Thickness=1.5,Transparency=.4,Parent=UB})
  self._unlockBtn=UB
  task.spawn(function()
    while UB and UB.Parent do
      sn(UB,{BackgroundTransparency=.45},1.0); task.wait(1.1)
      sn(UB,{BackgroundTransparency=.12},1.0); task.wait(1.1)
    end
  end)
  UB.MouseButton1Down:Connect(function() tw(UB,{Size=UDim2.new(0,188,0,48)},.1) end)
  UB.MouseButton1Click:Connect(function() tw(UB,{Size=UDim2.new(0,200,0,52)},.2); self:_unlock() end)

  -- Status bar — ZIndex 25
  local SBar=N("Frame",{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1,ZIndex=25,Parent=Screen})
  local TLbl=N("TextLabel",{Size=UDim2.new(0,70,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,
    Text="9:41",TextColor3=C.White,Font=C.Bold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=26,Parent=SBar})
  N("TextLabel",{Size=UDim2.new(0,90,1,0),Position=UDim2.new(1,-96,0,0),BackgroundTransparency=1,
    Text="▊▊▊  WiFi  ▓",TextColor3=C.White,Font=C.Bold,TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Right,ZIndex=26,Parent=SBar})
  task.spawn(function()
    while TLbl and TLbl.Parent do
      TLbl.Text=tostring(tonumber(os.date("%I")))..":"..os.date("%M"); task.wait(15)
    end
  end)
  self.StatusBar=SBar

  -- App View — ZIndex 35, NO ClipsDescendants (Screen already clips)
  local AV=N("Frame",{Name="AppView",Size=UDim2.new(1,0,1,0),BackgroundColor3=C.BG,
    BorderSizePixel=0,ZIndex=35,Visible=false,Parent=Screen})
  -- NO ClipsDescendants here — was causing rounding bleed artifacts
  self.AppView=AV
  local ANB=N("Frame",{Size=UDim2.new(1,0,0,96),BackgroundColor3=C.L1,BorderSizePixel=0,ZIndex=36,Parent=AV})
  Rnd(UDim.new(0,36),ANB)
  N("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=C.L1,BorderSizePixel=0,ZIndex=36,Parent=ANB})
  N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=37,Parent=ANB})
  local BackBtn=N("TextButton",{Size=UDim2.new(0,80,0,34),Position=UDim2.new(0,10,0,54),
    BackgroundTransparency=1,Text="‹  Back",TextColor3=C.Blue,Font=C.Semi,TextSize=16,
    TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=37,Parent=ANB})
  local AppTitle=N("TextLabel",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,58),
    BackgroundTransparency=1,Text="",TextColor3=C.T1,Font=C.Bold,TextSize=20,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=37,Parent=ANB})
  self.AppTitle=AppTitle
  BackBtn.MouseButton1Click:Connect(function() self:_closeApp() end)
  local AC=N("ScrollingFrame",{Size=UDim2.new(1,0,1,-96),Position=UDim2.new(0,0,0,96),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,
    CanvasSize=UDim2.new(0,0,0,0),ZIndex=36,Parent=AV})
  self.AppContent=AC

  -- CC — ZIndex 45
  local CC=N("Frame",{Name="CC",Size=UDim2.new(1,-20,0,340),Position=UDim2.new(0,10,1,20),
    BackgroundColor3=C.L1,BackgroundTransparency=.06,BorderSizePixel=0,ZIndex=45,
    ClipsDescendants=true,Parent=Screen})
  Rnd(UDim.new(0,32),CC)
  N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.3,Parent=CC})
  self.CC=CC
  N("TextLabel",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,14),BackgroundTransparency=1,
    Text="Control Centre",TextColor3=C.T2,Font=C.Semi,TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=46,Parent=CC})
  local ccH=N("Frame",{Size=UDim2.new(0,36,0,4),Position=UDim2.new(.5,-18,0,7),
    BackgroundColor3=C.White,BackgroundTransparency=.5,BorderSizePixel=0,ZIndex=46,Parent=CC})
  Rnd(UDim.new(1,0),ccH)
  local ccTF=N("Frame",{Size=UDim2.new(1,-24,0,168),Position=UDim2.new(0,12,0,48),
    BackgroundTransparency=1,ZIndex=46,Parent=CC})
  N("UIGridLayout",{CellSize=UDim2.new(0,74,0,74),HorizontalAlignment=Enum.HorizontalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder,Parent=ccTF})
  local ccItems={{"✈️","Airplane"},{"📶","Wi-Fi"},{"🔵","Bluetooth"},{"🔦","Torch"},
    {"🔕","Silent"},{"📺","Mirror"},{"⏱️","Timer"},{"🎵","Music"}}
  for _,t in ipairs(ccItems) do
    local on=false
    local tile=N("TextButton",{Size=UDim2.new(0,74,0,74),BackgroundColor3=C.L2,
      Text="",AutoButtonColor=false,ZIndex=47,Parent=ccTF})
    Rnd(UDim.new(0,20),tile)
    N("TextLabel",{Size=UDim2.new(1,0,0,42),Position=UDim2.new(0,0,0,8),BackgroundTransparency=1,
      Text=t[1],TextScaled=true,Font=C.Bold,ZIndex=48,Parent=tile})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-18),BackgroundTransparency=1,
      Text=t[2],TextColor3=C.T2,Font=C.Semi,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=48,Parent=tile})
    tile.MouseButton1Click:Connect(function()
      on=not on; tw(tile,{BackgroundColor3=on and C.Blue or C.L2},.18)
    end)
  end
  local function CCSlider(yPos,icon)
    local row=N("Frame",{Size=UDim2.new(1,-24,0,38),Position=UDim2.new(0,12,0,yPos),BackgroundTransparency=1,ZIndex=46,Parent=CC})
    N("TextLabel",{Size=UDim2.new(0,26,1,0),BackgroundTransparency=1,Text=icon,TextScaled=true,ZIndex=47,Parent=row})
    local bg=N("Frame",{Size=UDim2.new(1,-36,0,4),Position=UDim2.new(0,30,.5,-2),BackgroundColor3=C.L3,ZIndex=47,Parent=row})
    Rnd(UDim.new(1,0),bg)
    local fill=N("Frame",{Size=UDim2.new(.65,0,1,0),BackgroundColor3=C.White,ZIndex=48,Parent=bg}); Rnd(UDim.new(1,0),fill)
    local thumb=N("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(.65,-10,.5,-10),BackgroundColor3=C.White,ZIndex=49,Parent=bg}); Rnd(UDim.new(1,0),thumb)
    local sl=false
    local hit=N("TextButton",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,.5,-14),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=50,Parent=row})
    hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
    UIS.InputChanged:Connect(function(i)
      if not sl then return end
      local tp=bg.AbsolutePosition.X; local ts=bg.AbsoluteSize.X; if ts<=0 then return end
      local p=math.clamp((i.Position.X-tp)/ts,0,1)
      fill.Size=UDim2.new(p,0,1,0); thumb.Position=UDim2.new(p,-10,.5,-10)
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
  end
  CCSlider(226,"🔊"); CCSlider(270,"☀️")

  -- DYNAMIC ISLAND — child of SG (NOT Screen) so it's NEVER clipped by AppView/CC
  -- Positioned relative to SG so we track Shell position
  local DI=N("Frame",{Name="DI",Size=UDim2.new(0,120,0,36),
    BackgroundColor3=C.Black,BorderSizePixel=0,ZIndex=80,Parent=SG})
  Rnd(UDim.new(0,18),DI)
  N("Frame",{Size=UDim2.new(0,9,0,9),Position=UDim2.new(1,-22,.5,-4),BackgroundColor3=Color3.fromRGB(18,50,100),BorderSizePixel=0,ZIndex=81,Parent=DI}); Rnd(UDim.new(1,0),DI:FindFirstChildOfClass("Frame"))
  N("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(1,-35,.5,-3),BackgroundColor3=Color3.fromRGB(28,28,32),BorderSizePixel=0,ZIndex=81,Parent=DI}); Rnd(UDim.new(1,0),DI:FindFirstChild("Frame"))
  self.DI=DI; self._diContent=nil
  -- Keep DI positioned over the phone's screen top
  local function updateDIPos()
    if not Shell.Parent then return end
    local sx=Shell.Position.X.Offset; local sy=Shell.Position.Y.Offset
    -- Shell.Position might use Scale too if centered
    local abs=Shell.AbsolutePosition
    local sw=Shell.AbsoluteSize.X
    local diW=DI.AbsoluteSize.X
    DI.Position=UDim2.new(0,abs.X+7+(PW/2)-(diW/2),0,abs.Y+13+10)
  end
  -- Update on heartbeat while visible (cheap, only runs when phone is shown)
  task.spawn(function()
    while DI and DI.Parent do
      if self._visible then
        local abs=Shell.AbsolutePosition
        local diW=120
        DI.Position=UDim2.new(0,abs.X+7+(PW/2)-(diW/2),0,abs.Y+13+10)
      end
      task.wait(0)
    end
  end)

  -- Home indicator — ZIndex 25
  local HBar=N("TextButton",{Size=UDim2.new(0,134,0,5),Position=UDim2.new(.5,-67,1,-12),
    BackgroundColor3=C.White,BackgroundTransparency=.45,BorderSizePixel=0,
    Text="",AutoButtonColor=false,ZIndex=25,Parent=Screen})
  Rnd(UDim.new(1,0),HBar)
  HBar.MouseButton1Click:Connect(function() self:_toggleCC() end)
  self.HomeBar=HBar

  -- DRAG — UIS-level, only activate when click is within the Shell's top strip
  -- and NOT when an interactive element (button etc) is the input object
  local _drag,_ds,_ps=false,nil,nil
  UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end  -- game processed = UI element handled it
    if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    -- Check if within top drag zone of Shell
    local abs=Shell.AbsolutePosition; local sz=Shell.AbsoluteSize
    local mx,my=i.Position.X,i.Position.Y
    if mx>=abs.X and mx<=abs.X+sz.X and my>=abs.Y and my<=abs.Y+52 then
      _drag=true; _ds=Vector2.new(mx,my); _ps=Shell.Position
    end
  end)
  UIS.InputChanged:Connect(function(i)
    if not _drag then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement then
      Shell.Position=UDim2.new(_ps.X.Scale,_ps.X.Offset+(i.Position.X-_ds.X),
        _ps.Y.Scale,_ps.Y.Offset+(i.Position.Y-_ds.Y))
    end
  end)
  UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=false end
  end)

  -- Entrance animation
  Shell.Size=UDim2.new(0,PW+14,0,0); Shell.BackgroundTransparency=1
  task.defer(function()
    sn(Shell,{BackgroundTransparency=0},.3)
    sp(Shell,{Size=UDim2.new(0,PW+14,0,PH+26)},.52)
  end)

  return self
end

-- Unlock / Lock
function Phone:_unlock()
  if not self._locked then return end
  self._locked=false; self._unlockBtn.Visible=false
  local LS=self.LockScreen; local SB=self.SpringBoard
  qt(LS,{Position=UDim2.new(0,0,0,-self.PH-40)},.42)
  task.delay(.08,function()
    SB.Visible=true; SB.Position=UDim2.new(0,0,0,30)
    qt(SB,{Position=UDim2.new(0,0,0,0)},.36)
  end)
  task.delay(.45,function() LS.Visible=false end)
end
function Phone:_lock()
  if self._locked then return end
  self._locked=true; self:_closeApp()
  local LS=self.LockScreen; local SB=self.SpringBoard
  LS.Position=UDim2.new(0,0,0,-self.PH-40); LS.Visible=true
  qt(SB,{Position=UDim2.new(0,0,0,30)},.3)
  qt(LS,{Position=UDim2.new(0,0,0,0)},.4)
  task.delay(.38,function() SB.Visible=false; self._unlockBtn.Visible=true end)
end
function Phone:_openCC() self._ccOpen=true; sp(self.CC,{Position=UDim2.new(0,10,1,-350)},.42) end
function Phone:_closeCC() self._ccOpen=false; sn(self.CC,{Position=UDim2.new(0,10,1,20)},.28) end
function Phone:_toggleCC() if self._ccOpen then self:_closeCC() else self:_openCC() end end

function Phone:_openApp(appData)
  local AV=self.AppView; self.AppTitle.Text=appData.name; self._currentApp=appData
  for _,c in ipairs(self.AppContent:GetChildren()) do
    if not c:IsA("UIListLayout") then c:Destroy() end
  end
  self.AppContent.CanvasSize=UDim2.new(0,0,0,0)
  local list=VL(0,self.AppContent)
  list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    self.AppContent.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y+40)
  end)
  if appData.builder then appData.builder(self,self.AppContent) end
  local sAbs=self.Screen.AbsolutePosition
  local iAbs=appData._btn and appData._btn.AbsolutePosition or Vector2.new(self.PW/2,self.PH/2)
  local iSz=appData._btn and appData._btn.AbsoluteSize or Vector2.new(62,62)
  AV.Visible=true; AV.BackgroundTransparency=1
  AV.Size=UDim2.new(0,iSz.X,0,iSz.Y)
  AV.Position=UDim2.new(0,iAbs.X-sAbs.X,0,iAbs.Y-sAbs.Y)
  qt(AV,{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=0},.36)
end
function Phone:_closeApp()
  local AV=self.AppView; if not AV.Visible then return end
  local sAbs=self.Screen.AbsolutePosition; local appData=self._currentApp
  local iAbs=appData and appData._btn and appData._btn.AbsolutePosition or Vector2.new(self.PW/2,self.PH/2)
  local iSz=appData and appData._btn and appData._btn.AbsoluteSize or Vector2.new(62,62)
  qt(AV,{Size=UDim2.new(0,iSz.X,0,iSz.Y),Position=UDim2.new(0,iAbs.X-sAbs.X,0,iAbs.Y-sAbs.Y),BackgroundTransparency=1},.3)
  task.delay(.32,function() AV.Visible=false; self._currentApp=nil end)
end

function Phone:AddApp(opts)
  opts=opts or{}
  local name=opts.Name or "App"; local icon=opts.Icon or "📱"
  local color=opts.Color or self.accent; local inDock=opts.InDock
  local builder=opts.Builder or function()end
  local appData={name=name,icon=icon,color=color,builder=builder}
  local parent=inDock and self.DockRow or self.Grid
  local sz=inDock and 58 or 62
  local wrap=N("Frame",{Size=UDim2.new(0,sz,0,inDock and sz or 90),BackgroundTransparency=1,ZIndex=10,Parent=parent})
  local btn=N("TextButton",{Size=UDim2.new(0,sz,0,sz),BackgroundColor3=color,Text="",AutoButtonColor=false,ZIndex=10,Parent=wrap})
  Rnd(UDim.new(0,14),btn)
  N("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,color)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(1,0)}),Rotation=140,Parent=btn})
  N("TextLabel",{Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,8),BackgroundTransparency=1,Text=icon,TextScaled=true,Font=C.Bold,ZIndex=11,Parent=btn})
  if not inDock then
    N("TextLabel",{Size=UDim2.new(0,sz+16,0,20),Position=UDim2.new(.5,-(sz+16)/2,0,sz+2),BackgroundTransparency=1,Text=name,TextColor3=C.White,Font=C.Semi,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true,ZIndex=10,Parent=wrap})
  end
  appData._btn=btn
  btn.MouseButton1Down:Connect(function() sp(btn,{Size=UDim2.new(0,sz-8,0,sz-8)},.2) end)
  btn.MouseButton1Click:Connect(function()
    sp(btn,{Size=UDim2.new(0,sz,0,sz)},.3)
    task.delay(.1,function() self:_openApp(appData) end)
  end)
  table.insert(self._apps,appData); return appData
end

function Phone:Notify(opts)
  opts=opts or{}
  local title=opts.Title or""; local body=opts.Body or""
  local icon=opts.Icon or"📱"; local app=opts.App or title
  local dur=opts.Duration or 4; local accent=opts.Accent or self.accent
  local DI=self.DI; local PW=self.PW
  if self._diContent then pcall(function() self._diContent:Destroy() end); self._diContent=nil end
  -- Expand DI
  local diW=PW-40
  local abs=self.Shell.AbsolutePosition
  sp(DI,{Size=UDim2.new(0,diW,0,64)},.38)
  local content=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=81,Parent=DI})
  self._diContent=content; Pad(0,14,0,14,content)
  task.delay(.22,function()
    if not content.Parent then return end
    local row=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=81,Parent=content}); HL(10,row)
    local badge=N("Frame",{Size=UDim2.new(0,40,0,40),BackgroundColor3=accent,BackgroundTransparency=.72,ZIndex=82,Parent=row}); Rnd(UDim.new(0,10),badge)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,TextScaled=true,Font=C.Bold,ZIndex=83,Parent=badge})
    local tc=N("Frame",{Size=UDim2.new(1,-56,1,0),BackgroundTransparency=1,ZIndex=82,Parent=row}); VL(2,tc)
    N("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text=app:upper(),TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Semi,TextSize=10,ZIndex=83,Parent=tc})
    N("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=title,TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Bold,TextSize=14,ZIndex=83,Parent=tc})
    N("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Text=body,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=83,Parent=tc})
  end)
  task.delay(dur,function()
    if not DI.Parent then return end
    if self._diContent==content then
      sn(content,{BackgroundTransparency=1},.15)
      task.delay(.18,function() if content.Parent then content:Destroy() end; self._diContent=nil end)
    end
    sp(DI,{Size=UDim2.new(0,120,0,36)},.4)
  end)
end

function Phone:Show()
  self._visible=true; self.SG.Enabled=true
  local S=self.Shell; S.BackgroundTransparency=1; S.Size=UDim2.new(0,self.PW+14,0,0)
  sn(S,{BackgroundTransparency=0},.28); sp(S,{Size=UDim2.new(0,self.PW+14,0,self.PH+26)},.5)
end
function Phone:Hide()
  self._visible=false
  sn(self.Shell,{Size=UDim2.new(0,self.PW+14,0,0),BackgroundTransparency=1},.28)
  task.delay(.32,function() self.SG.Enabled=false end)
end
function Phone:Toggle() if self._visible then self:Hide() else self:Show() end end

-- ── Content helpers ───────────────────────────────────────
function Phone:Section(parent,label)
  local f=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,ZIndex=36,Parent=parent})
  Pad(10,16,0,16,f)
  N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=(label or""):upper(),TextColor3=C.T3,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Semi,TextSize=11,ZIndex=36,Parent=f})
  return f
end

function Phone:Group(parent)
  local card=N("Frame",{Size=UDim2.new(1,-28,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.L1,BorderSizePixel=0,ZIndex=36,Parent=parent})
  Rnd(UDim.new(0,16),card); N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=card})
  return card,VL(0,card)
end

function Phone:Row(parent,opts)
  opts=opts or{}
  local row=N("Frame",{Size=UDim2.new(1,0,0,opts.Height or 50),BackgroundTransparency=1,ZIndex=37,Parent=parent})
  Pad(0,14,0,14,row)
  local xOff=0
  if opts.IconBg then
    local ib=N("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,0,.5,-15),BackgroundColor3=opts.IconBg,ZIndex=38,Parent=row})
    Rnd(UDim.new(0,8),ib)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=opts.Icon or"",TextScaled=true,Font=C.Bold,ZIndex=39,Parent=ib})
    xOff=42
  end
  N("TextLabel",{Size=UDim2.new(.5,0,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundTransparency=1,Text=opts.Title or"",TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=15,ZIndex=38,Parent=row})
  local vLbl=N("TextLabel",{Size=UDim2.new(.38,0,1,0),Position=UDim2.new(.58,0,0,0),BackgroundTransparency=1,Text=opts.Value or"",TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Right,Font=C.Reg,TextSize=15,ZIndex=38,Parent=row})
  if opts.Disclosure~=false then
    N("TextLabel",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundTransparency=1,Text="›",TextColor3=C.T3,TextXAlignment=Enum.TextXAlignment.Center,Font=C.Bold,TextSize=20,ZIndex=38,Parent=row})
  end
  N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,xOff,1,-1),BackgroundColor3=C.Sep,BackgroundTransparency=.4,BorderSizePixel=0,ZIndex=37,Parent=row})
  if opts.Callback then
    local hit=N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=40,Parent=row})
    hit.MouseButton1Down:Connect(function() row.BackgroundColor3=C.L2; tw(row,{BackgroundTransparency=0},.06) end)
    hit.MouseButton1Up:Connect(function() sn(row,{BackgroundTransparency=1},.2) end)
    hit.MouseButton1Click:Connect(opts.Callback)
  end
  return row,vLbl
end

function Phone:ToggleRow(parent,opts)
  opts=opts or{}
  local val=opts.Default or false; local col=opts.Accent or C.Green; local cb=opts.Callback or function()end
  local row=self:Row(parent,{Title=opts.Title,Icon=opts.Icon,IconBg=opts.IconBg,Disclosure=false})
  local track=N("Frame",{Size=UDim2.new(0,51,0,31),Position=UDim2.new(1,-51,.5,-15),BackgroundColor3=val and col or C.L3,ZIndex=38,Parent=row})
  Rnd(UDim.new(1,0),track)
  local thumb=N("Frame",{Size=UDim2.new(0,27,0,27),Position=UDim2.new(0,val and 22 or 2,.5,-13),BackgroundColor3=C.White,ZIndex=40,Parent=track})
  Rnd(UDim.new(1,0),thumb)
  N("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.White),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,210))}),Rotation=120,Parent=thumb})
  local function Refresh()
    tw(track,{BackgroundColor3=val and col or C.L3},.2)
    sp(thumb,{Position=UDim2.new(0,val and 22 or 2,.5,-13)},.42)
  end
  N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=41,Parent=row}).MouseButton1Click:Connect(function()
    val=not val; Refresh(); cb(val)
  end)
  Refresh()
  return {Get=function()return val end,Set=function(_,v)val=v;Refresh();cb(v)end}
end

function Phone:SliderRow(parent,opts)
  opts=opts or{}
  local mn=opts.Min or 0; local mx=opts.Max or 100; local step=opts.Step or 1
  local col=opts.Accent or C.Blue; local val=math.clamp(opts.Default or mn,mn,mx)
  local cb=opts.Callback or function()end
  local card=N("Frame",{Size=UDim2.new(1,-28,0,66),BackgroundColor3=C.L1,ZIndex=36,Parent=parent})
  Rnd(UDim.new(0,16),card); N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=card}); Pad(10,14,10,14,card)
  local top=N("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=37,Parent=card})
  N("TextLabel",{Size=UDim2.new(.65,0,1,0),BackgroundTransparency=1,Text=opts.Title or"",TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=14,ZIndex=37,Parent=top})
  local vLbl=N("TextLabel",{Size=UDim2.new(.35,0,1,0),Position=UDim2.new(.65,0,0,0),BackgroundTransparency=1,Text=tostring(val),TextColor3=col,TextXAlignment=Enum.TextXAlignment.Right,Font=C.Bold,TextSize=14,ZIndex=37,Parent=top})
  local hit=N("TextButton",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,1,-28),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=40,Parent=card})
  local bg=N("Frame",{Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,.5,-2),BackgroundColor3=C.L3,ZIndex=37,Parent=hit}); Rnd(UDim.new(1,0),bg)
  local fill=N("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=col,ZIndex=38,Parent=bg}); Rnd(UDim.new(1,0),fill)
  local thumb=N("Frame",{Size=UDim2.new(0,22,0,22),Position=UDim2.new((val-mn)/(mx-mn),-11,.5,-11),BackgroundColor3=C.White,ZIndex=39,Parent=bg}); Rnd(UDim.new(1,0),thumb)
  local sl=false
  local function setV(absX)
    local tp=bg.AbsolutePosition.X; local ts=bg.AbsoluteSize.X; if ts<=0 then return end
    local r=math.clamp((absX-tp)/ts,0,1)
    val=math.clamp(math.round((mn+(mx-mn)*r)/step)*step,mn,mx)
    local p=(val-mn)/(mx-mn); fill.Size=UDim2.new(p,0,1,0); thumb.Position=UDim2.new(p,-11,.5,-11); vLbl.Text=tostring(val); cb(val)
  end
  for _,src in ipairs({hit,bg}) do
    src.InputBegan:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        sl=true; sp(thumb,{Size=UDim2.new(0,26,0,26)},.25); setV(i.Position.X)
      end
    end)
  end
  UIS.InputChanged:Connect(function(i) if sl and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then setV(i.Position.X)end end)
  UIS.InputEnded:Connect(function(i) if sl and i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false; sp(thumb,{Size=UDim2.new(0,22,0,22)},.3)end end)
  return {
    Get=function()return val end,
    Set=function(_,v)
      val=math.clamp(v,mn,mx); local p=(val-mn)/(mx-mn)
      tw(fill,{Size=UDim2.new(p,0,1,0)},.18); thumb.Position=UDim2.new(p,-11,.5,-11); vLbl.Text=tostring(val); cb(val)
    end
  }
end

function Phone:Button(parent,opts)
  opts=opts or{}
  local pals={Primary={bg=opts.Accent or C.Blue,txt=C.White},Secondary={bg=C.L2,txt=opts.Accent or C.Blue},Danger={bg=C.Red,txt=C.White},Success={bg=C.Green,txt=C.White}}
  local pal=pals[opts.Style or"Primary"]or pals.Primary
  local btn=N("TextButton",{Size=UDim2.new(1,-28,0,48),BackgroundColor3=pal.bg,
    Text=(opts.Icon and opts.Icon.."  "or"")..(opts.Title or"Button"),
    TextColor3=pal.txt,Font=C.Semi,TextSize=15,AutoButtonColor=false,ZIndex=36,Parent=parent})
  Rnd(UDim.new(0,16),btn)
  btn.MouseButton1Down:Connect(function() sp(btn,{Size=UDim2.new(1,-38,0,46)},.22); tw(btn,{BackgroundTransparency=.18},.08) end)
  btn.MouseButton1Up:Connect(function() sp(btn,{Size=UDim2.new(1,-28,0,48)},.3); tw(btn,{BackgroundTransparency=0},.12) end)
  btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=pal.bg:Lerp(C.White,.1)},.14) end)
  btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=pal.bg},.14) end)
  if opts.Callback then btn.MouseButton1Click:Connect(opts.Callback) end
  return btn
end

function Phone:Dropdown(parent,opts)
  opts=opts or{}
  local options=opts.Options or{}; local val=opts.Default or options[1]
  local col=opts.Accent or C.Blue; local cb=opts.Callback or function()end
  local iH=42; local maxShow=math.min(#options,5); local listH=maxShow*iH
  local open=false

  local wrap=N("Frame",{Size=UDim2.new(1,-28,0,52),BackgroundTransparency=1,ZIndex=50,Parent=parent})
  local hdr=N("TextButton",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.L1,Text="",AutoButtonColor=false,ZIndex=50,Parent=wrap})
  Rnd(UDim.new(0,16),hdr); N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.35,Parent=hdr}); Pad(0,14,0,14,hdr)
  N("TextLabel",{Size=UDim2.new(.54,0,1,0),BackgroundTransparency=1,Text=opts.Title or"",TextColor3=C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=C.Reg,TextSize=15,ZIndex=51,Parent=hdr})
  local selLbl=N("TextLabel",{Size=UDim2.new(.32,0,1,0),Position=UDim2.new(.58,0,0,0),BackgroundTransparency=1,Text=tostring(val or""),TextColor3=col,TextXAlignment=Enum.TextXAlignment.Right,Font=C.Semi,TextSize=14,ZIndex=51,Parent=hdr})
  local chev=N("TextLabel",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-16,0,0),BackgroundTransparency=1,Text="›",TextColor3=C.T3,TextXAlignment=Enum.TextXAlignment.Center,Font=C.Bold,TextSize=20,ZIndex=51,Parent=hdr})

  -- Panel parented to SG at ZIndex=500 — never clipped by anything
  local dp=N("Frame",{Size=UDim2.new(0,10,0,0),BackgroundColor3=C.L2,
    ClipsDescendants=true,Visible=false,ZIndex=500,Parent=self.SG})
  Rnd(UDim.new(0,14),dp); N("UIStroke",{Color=C.Sep,Thickness=1,Transparency=.25,Parent=dp})
  local dscr=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Sep,
    CanvasSize=UDim2.new(0,0,0,0),ZIndex=501,Parent=dp})
  local dl=VL(0,dscr)
  dl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    dscr.CanvasSize=UDim2.new(0,0,0,dl.AbsoluteContentSize.Y)
  end)

  local checks={}
  for _,opt in ipairs(options) do
    local ib=N("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=502,Parent=dscr})
    Pad(0,12,0,14,ib)
    N("Frame",{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,1,-1),BackgroundColor3=C.Sep,BackgroundTransparency=.5,BorderSizePixel=0,ZIndex=502,Parent=ib})
    local ck=N("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-16,0,0),BackgroundTransparency=1,Text="✓",TextColor3=col,TextScaled=true,Font=C.Bold,TextTransparency=opt==val and 0 or 1,ZIndex=503,Parent=ib})
    local ol=N("TextLabel",{Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text=tostring(opt),TextColor3=opt==val and col or C.T1,TextXAlignment=Enum.TextXAlignment.Left,Font=opt==val and C.Semi or C.Reg,TextSize=15,ZIndex=503,Parent=ib})
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
      tw(chev,{Rotation=0},.2)
    end)
  end

  hdr.MouseButton1Click:Connect(function()
    open=not open
    if open then
      -- Position computed fresh at click time using AbsolutePosition (screen coords)
      local ha=hdr.AbsolutePosition; local W=hdr.AbsoluteSize.X
      -- Clamp so dropdown doesn't go off-screen bottom
      local screenH=self.SG.AbsoluteSize and self.SG.AbsoluteSize.Y or 800
      local yPos=ha.Y+54
      if yPos+listH>screenH-20 then yPos=ha.Y-listH-4 end
      dp.Size=UDim2.new(0,W,0,0)
      dp.Position=UDim2.new(0,ha.X,0,yPos)
      dp.Visible=true
      sp(dp,{Size=UDim2.new(0,W,0,listH)},.38)
      tw(chev,{Rotation=90},.22)
    else
      sn(dp,{Size=UDim2.new(0,dp.AbsoluteSize.X,0,0)},.22)
      task.delay(.24,function() dp.Visible=false end)
      tw(chev,{Rotation=0},.22)
    end
  end)
  return {Get=function()return val end,Set=function(_,v)val=v;selLbl.Text=tostring(v);cb(v)end}
end

-- Settings helpers
local WPS={Aurora={{18,22,58},{8,8,18},{42,8,60},165},Midnight={{0,0,0},{10,10,10},{0,0,0},180},Ocean={{4,30,80},{2,12,40},{0,40,80},160},Sunset={{80,10,10},{20,8,8},{60,20,0},150},Forest={{8,40,16},{4,18,8},{0,30,20},170},Candy={{80,10,60},{30,4,50},{60,0,80},145}}
local ACS={Blue=Color3.fromRGB(10,132,255),Green=Color3.fromRGB(52,211,91),Purple=Color3.fromRGB(191,90,242),Red=Color3.fromRGB(255,69,58),Orange=Color3.fromRGB(255,159,10),Pink=Color3.fromRGB(255,55,95),Teal=Color3.fromRGB(90,200,250),Yellow=Color3.fromRGB(255,214,10)}
function Phone:SetWallpaper(n)
  local w=WPS[n];if not w then return end;self._settings.wallpaper=n
  local g=self.Wallpaper:FindFirstChildOfClass("UIGradient");if not g then return end
  g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(w[1][1],w[1][2],w[1][3])),ColorSequenceKeypoint.new(.45,Color3.fromRGB(w[2][1],w[2][2],w[2][3])),ColorSequenceKeypoint.new(1,Color3.fromRGB(w[3][1],w[3][2],w[3][3]))}); g.Rotation=w[4]
end
function Phone:SetAccent(n) local c=ACS[n];if not c then return end;self._settings.accentName=n;self._settings.accentColor=c;self.accent=c end
function Phone:GetAccentNames() local t={};for k in pairs(ACS)do table.insert(t,k)end;table.sort(t);return t end
function Phone:GetWallpaperNames() local t={};for k in pairs(WPS)do table.insert(t,k)end;table.sort(t);return t end

return Phone

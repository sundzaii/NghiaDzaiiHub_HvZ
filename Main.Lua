getgenv().deletewhendupefound = true

--// LIB
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local window = lib:NewWindow("🌊 NghiadzaiiHub")

local main = window:NewSection("Main")
local espsec = window:NewSection("ESP")

--// SERVICES
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera

local localplr = players.LocalPlayer

--// TOGGLES
local zombieesp = false
local humanesp = false
local aimlock = false
local tphuman = false
local hitbox = false

--// STORAGE
local espfolder = Instance.new("Folder")
espfolder.Name = "NghiaHubESP"
espfolder.Parent = game.CoreGui

local esptable = {}
local lockedtarget = nil

--// MENU COLOR
task.spawn(function()

task.wait(1)

pcall(function()

for _,v in pairs(game.CoreGui:GetDescendants()) do

if v:IsA("Frame") then
v.BackgroundColor3 = Color3.fromRGB(100,190,255)
end

if v:IsA("TextButton") then
v.BackgroundColor3 = Color3.fromRGB(70,160,255)
v.TextColor3 = Color3.new(1,1,1)
end

if v:IsA("TextLabel") then
v.TextColor3 = Color3.new(1,1,1)
end

end

end)

end)

--// CLEAR ESP
local function clearesp(plr)

if esptable[plr] then

for _,v in pairs(esptable[plr]) do

pcall(function()
v:Destroy()
end)

end

esptable[plr] = nil

end

end

--// HITBOX
local function applyhitbox(plr)

if not hitbox then
return
end

if plr.Team == game.Teams.Monsters
and plr.Character
and plr.Character:FindFirstChild("HumanoidRootPart") then

local hrp = plr.Character.HumanoidRootPart

hrp.Size = Vector3.new(12,12,12)
hrp.Transparency = 0.8
hrp.Material = Enum.Material.Neon
hrp.CanCollide = false
hrp.Massless = true

end

end

local function removehitbox(plr)

if plr.Character
and plr.Character:FindFirstChild("HumanoidRootPart") then

local hrp = plr.Character.HumanoidRootPart

hrp.Size = Vector3.new(2,2,1)
hrp.Transparency = 1
hrp.Material = Enum.Material.Plastic

end

end

--// ESP
local function makeesp(plr)

if plr == localplr then
return
end

clearesp(plr)

local char = plr.Character
if not char then
return
end

local head = char:FindFirstChild("Head")
local hum = char:FindFirstChild("Humanoid")

if not head or not hum or hum.Health <= 0 then
return
end

local isZombie = plr.Team == game.Teams.Monsters
local isHuman = plr.Team == game.Teams.Humans

if (isZombie and not zombieesp)
or (isHuman and not humanesp) then
return
end

-- HIGHLIGHT
local hl = Instance.new("Highlight")

hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.FillTransparency = 0.5
hl.OutlineTransparency = 0

if isZombie then

hl.FillColor = Color3.fromRGB(0,255,0)
hl.OutlineColor = Color3.fromRGB(0,255,0)

else

hl.FillColor = Color3.fromRGB(255,220,180)
hl.OutlineColor = Color3.fromRGB(255,220,180)

end

hl.Adornee = char
hl.Parent = espfolder

-- NAME
local bb = Instance.new("BillboardGui")

bb.Size = UDim2.new(0,80,0,16)
bb.StudsOffset = Vector3.new(0,2.5,0)
bb.AlwaysOnTop = true
bb.Adornee = head
bb.Parent = espfolder

local txt = Instance.new("TextLabel")

txt.BackgroundTransparency = 1
txt.Size = UDim2.new(1,0,1,0)

txt.TextScaled = false
txt.TextSize = 9

txt.Font = Enum.Font.GothamBold
txt.TextStrokeTransparency = 0.3

if isZombie then

txt.Text = "[Z] "..plr.Name
txt.TextColor3 = Color3.fromRGB(0,255,0)

else

txt.Text = "[H] "..plr.Name
txt.TextColor3 = Color3.fromRGB(255,220,180)

end

txt.Parent = bb

esptable[plr] = {hl,bb}

end

--// REFRESH
local function refreshesp()

for _,v in pairs(players:GetPlayers()) do

clearesp(v)
makeesp(v)

if hitbox then
applyhitbox(v)
end

end

end

--// TOGGLES
espsec:CreateToggle("Zombie ESP", function(state)

zombieesp = state
refreshesp()

end)

espsec:CreateToggle("Human ESP", function(state)

humanesp = state
refreshesp()

end)

main:CreateToggle("Aim Lock Zombie", function(state)

aimlock = state

end)

main:CreateToggle("Teleport Human", function(state)

tphuman = state

if not state then
lockedtarget = nil
end

end)

main:CreateToggle("Zombie Hitbox", function(state)

hitbox = state

for _,v in pairs(players:GetPlayers()) do

if state then
applyhitbox(v)
else
removehitbox(v)
end

end

end)

--// CLOSEST ZOMBIE
local function getclosestzombie()

local target = nil
local dist = math.huge

for _,v in pairs(players:GetPlayers()) do

if v ~= localplr
and v.Team == game.Teams.Monsters
and v.Character
and v.Character:FindFirstChild("Head")
and v.Character:FindFirstChild("Humanoid")
and v.Character.Humanoid.Health > 0 then

local pos,vis =
cam:WorldToViewportPoint(
v.Character.Head.Position
)

if vis then

local mag =
(
Vector2.new(pos.X,pos.Y)
-
Vector2.new(
cam.ViewportSize.X/2,
cam.ViewportSize.Y/2
)
).Magnitude

if mag < dist then

dist = mag          
target = v

end

end

end

end

return target

end

--// CLOSEST HUMAN
local function getclosesthuman()

local target = nil
local dist = math.huge

if not localplr.Character
or not localplr.Character:FindFirstChild("HumanoidRootPart") then
return nil
end

for _,v in pairs(players:GetPlayers()) do

if v ~= localplr
and v.Team == game.Teams.Humans
and v.Character
and v.Character:FindFirstChild("HumanoidRootPart")
and v.Character:FindFirstChild("Humanoid")
and v.Character.Humanoid.Health > 0 then

local mag =
(
localplr.Character.HumanoidRootPart.Position

v.Character.HumanoidRootPart.Position
).Magnitude

if mag < dist then

dist = mag
target = v

end

end

end

return target

end

--// LOOP
rs.RenderStepped:Connect(function()

-- AIMLOCK
if aimlock then

local target = getclosestzombie()

if target
and target.Character
and target.Character:FindFirstChild("Head") then

cam.CFrame = CFrame.lookAt(
cam.CFrame.Position,
target.Character.Head.Position
)

end

end

-- TP HUMAN LOCK
if tphuman then

_G.lasttphuman = _G.lasttphuman or 0

if not lockedtarget
or not lockedtarget.Parent
or not lockedtarget.Character
or not lockedtarget.Character:FindFirstChild("Humanoid")
or lockedtarget.Character.Humanoid.Health <= 0
or lockedtarget.Team ~= game.Teams.Humans then

lockedtarget = getclosesthuman()

end

if tick() - _G.lasttphuman > 0.05 then

_G.lasttphuman = tick()

if lockedtarget
and lockedtarget.Character
and lockedtarget.Character:FindFirstChild("HumanoidRootPart")
and localplr.Character
and localplr.Character:FindFirstChild("HumanoidRootPart") then

local hrp = localplr.Character.HumanoidRootPart
local thrp = lockedtarget.Character.HumanoidRootPart

local predict =
thrp.Position +
(thrp.Velocity * 0.22)

hrp.CFrame =
CFrame.new(predict)
*
CFrame.Angles(
0,
math.rad(math.random(-180,180)),
0
)

hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero

end

end

end

end)

--// EVENTS
players.PlayerAdded:Connect(function(plr)

plr.CharacterAdded:Connect(function()

task.wait(1)

refreshesp()

if hitbox then
applyhitbox(plr)
end

end)

end)

for _,v in pairs(players:GetPlayers()) do

v.CharacterAdded:Connect(function()

task.wait(1)

refreshesp()

if hitbox then
applyhitbox(v)
end

end)

end

refreshesp()

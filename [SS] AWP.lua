--[[
    floating flinger [FE]
    by MyWorld and Inkou
    discord.gg/pYVHtSJmEY
    no hats needed, r15 supported
]]

local reanimate = loadstring([[
--reanimate by MyWorld#4430 discord.gg/pYVHtSJmEY
local v3_net, v3_808 = Vector3.new(0, 25.1, 0), Vector3.new(8, 0, 8)
local function getNetlessVelocity(realPartVelocity)
    local mag = realPartVelocity.Magnitude
    if mag > 1 then
        local unit = realPartVelocity.Unit
        if (unit.Y > 0.25) or (unit.Y < -0.75) then
            return unit * (25.1 / unit.Y)
        end
    end
    return v3_net + realPartVelocity * v3_808
end
local simradius = "shp" --simulation radius (net bypass) method
--"shp" - sethiddenproperty
--"ssr" - setsimulationradius
--false - disable
local simrad = 1000 --simulation radius value
local healthHide = false --moves your head away every 3 seconds so players dont see your health bar (alignmode 4 only)
local reclaim = true --if you lost control over a part this will move your primary part to the part so you get it back (alignmode 4)
local novoid = true --prevents parts from going under workspace.FallenPartsDestroyHeight if you control them (alignmode 4 only)
local physp = nil --PhysicalProperties.new(0.01, 0, 1, 0, 0) --sets .CustomPhysicalProperties to this for each part
local noclipAllParts = false --set it to true if you want noclip
local antiragdoll = true --removes hingeConstraints and ballSocketConstraints from your character
local newanimate = false --disables the animate script and enables after reanimation
local discharscripts = true --disables all localScripts parented to your character before reanimation
local R15toR6 = true --tries to convert your character to r6 if its r15
local hatcollide = false --makes hats cancollide (credit to ShownApe) (works only with reanimate method 0)
local humState16 = true --enables collisions for limbs before the humanoid dies (using hum:ChangeState)
local addtools = false --puts all tools from backpack to character and lets you hold them after reanimation
local hedafterneck = true --disable aligns for head and enable after neck or torso is removed
local loadtime = game:GetService("Players").RespawnTime + 0.5 --anti respawn delay
local method = 3 --reanimation method
--methods:
--0 - breakJoints (takes [loadtime] seconds to load)
--1 - limbs
--2 - limbs + anti respawn
--3 - limbs + breakJoints after [loadtime] seconds
--4 - remove humanoid + breakJoints
--5 - remove humanoid + limbst
local alignmode = 4 --AlignPosition mode
--modes:
--1 - AlignPosition rigidity enabled true
--2 - 2 AlignPositions rigidity enabled both true and false
--3 - AlignPosition rigidity enabled false
--4 - CFrame
local flingpart = "HumanoidRootPart" --name of the part or the hat used for flinging
--the fling function
--usage: fling(target, duration, velocity)
--target can be set to: basePart, CFrame, Vector3, character model or humanoid (flings at mouse.Hit if argument not provided))
--duration (fling time in seconds) can be set to a number or a string convertable to the number (0.5s if not provided),
--velocity (fling part rotation velocity) can be set to a vector3 value (Vector3.new(20000, 20000, 20000) if not provided)

local lp = game:GetService("Players").LocalPlayer
local rs, ws, sg = game:GetService("RunService"), game:GetService("Workspace"), game:GetService("StarterGui")
local stepped, heartbeat, renderstepped = rs.Stepped, rs.Heartbeat, rs.RenderStepped
local twait, tdelay, rad, inf, abs, clamp = task.wait, task.delay, math.rad, math.huge, math.abs, math.clamp
local cf, v3 = CFrame.new, Vector3.new
local angles = CFrame.Angles
local v3_0, cf_0 = v3(0, 0, 0), cf(0, 0, 0)

local c = lp.Character
if not (c and c.Parent) then
    return
end

c:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (c and c.Parent) then
        c = nil
    end
end)

local clone, destroy, getchildren, getdescendants, isa = c.Clone, c.Destroy, c.GetChildren, c.GetDescendants, c.IsA

local function gp(parent, name, className)
    if typeof(parent) == "Instance" then
        for i, v in pairs(getchildren(parent)) do
            if (v.Name == name) and isa(v, className) then
                return v
            end
        end
    end
    return nil
end

local fenv = getfenv()

local shp = fenv.sethiddenproperty or fenv.set_hidden_property or fenv.set_hidden_prop or fenv.sethiddenprop
local ssr = fenv.setsimulationradius or fenv.set_simulation_radius or fenv.set_sim_radius or fenv.setsimradius or fenv.setsimrad or fenv.set_sim_rad

healthHide = healthHide and ((method == 0) or (method == 3)) and gp(c, "Head", "BasePart")

local reclaim, lostpart = reclaim and c.PrimaryPart, nil

local function align(Part0, Part1)
    
    local att0 = Instance.new("Attachment")
    att0.Position, att0.Orientation, att0.Name = v3_0, v3_0, "att0_" .. Part0.Name
    local att1 = Instance.new("Attachment")
    att1.Position, att1.Orientation, att1.Name = v3_0, v3_0, "att1_" .. Part1.Name

    if alignmode == 4 then
    
        local hide = false
        if Part0 == healthHide then
            healthHide = false
            tdelay(0, function()
                while twait(2.9) and Part0 and c do
                    hide = #Part0:GetConnectedParts() == 1
                    twait(0.1)
                    hide = false
                end
            end)
        end
        
        local rot = rad(0.05)
        local con0, con1 = nil, nil
        con0 = stepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            Part0.RotVelocity = Part1.RotVelocity
        end)
        local lastpos = Part0.Position
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1 and att1) then return con0:Disconnect() and con1:Disconnect() end
            if (not Part0.Anchored) and (Part0.ReceiveAge == 0) then
                if lostpart == Part0 then
                    lostpart = nil
                end
                rot = -rot
                local newcf = Part1.CFrame * att1.CFrame * angles(0, 0, rot)
                if Part1.Velocity.Magnitude > 0.01 then
                    Part0.Velocity = getNetlessVelocity(Part1.Velocity)
                else
                    Part0.Velocity = getNetlessVelocity((newcf.Position - lastpos) / delta)
                end
                lastpos = newcf.Position
                if lostpart and (Part0 == reclaim) then
                    newcf = lostpart.CFrame
                elseif hide then
                    newcf += v3(0, 3000, 0)
                end
                if novoid and (newcf.Y < ws.FallenPartsDestroyHeight + 0.1) then
                    newcf += v3(0, ws.FallenPartsDestroyHeight + 0.1 - newcf.Y, 0)
                end
                Part0.CFrame = newcf
            elseif (not Part0.Anchored) and (abs(Part0.Velocity.X) < 45) and (abs(Part0.Velocity.Y) < 25) and (abs(Part0.Velocity.Z) < 45) then
                lostpart = Part0
            end
        end)
    
    else
        
        Part0.CustomPhysicalProperties = physp
        if (alignmode == 1) or (alignmode == 2) then
            local ape = Instance.new("AlignPosition")
            ape.MaxForce, ape.MaxVelocity, ape.Responsiveness = inf, inf, inf
            ape.ReactionForceEnabled, ape.RigidityEnabled, ape.ApplyAtCenterOfMass = false, true, false
            ape.Attachment0, ape.Attachment1, ape.Name = att0, att1, "AlignPositionRtrue"
            ape.Parent = att0
        end
        
        if (alignmode == 2) or (alignmode == 3) then
            local apd = Instance.new("AlignPosition")
            apd.MaxForce, apd.MaxVelocity, apd.Responsiveness = inf, inf, inf
            apd.ReactionForceEnabled, apd.RigidityEnabled, apd.ApplyAtCenterOfMass = false, false, false
            apd.Attachment0, apd.Attachment1, apd.Name = att0, att1, "AlignPositionRfalse"
            apd.Parent = att0
        end
        
        local ao = Instance.new("AlignOrientation")
        ao.MaxAngularVelocity, ao.MaxTorque, ao.Responsiveness = inf, inf, inf
        ao.PrimaryAxisOnly, ao.ReactionTorqueEnabled, ao.RigidityEnabled = false, false, false
        ao.Attachment0, ao.Attachment1 = att0, att1
        ao.Parent = att0
        
        local con0, con1 = nil, nil
        local vel = Part0.Velocity
        con0 = renderstepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            Part0.Velocity = vel
        end)
        local lastpos = Part0.Position
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            vel = Part0.Velocity
            if Part1.Velocity.Magnitude > 0.01 then
                Part0.Velocity = getNetlessVelocity(Part1.Velocity)
            else
                Part0.Velocity = getNetlessVelocity((Part0.Position - lastpos) / delta)
            end
            lastpos = Part0.Position
        end)
    
    end

    att0:GetPropertyChangedSignal("Parent"):Connect(function()
        Part0 = att0.Parent
        if not isa(Part0, "BasePart") then
            att0 = nil
            if lostpart == Part0 then
                lostpart = nil
            end
            Part0 = nil
        end
    end)
    att0.Parent = Part0
    
    att1:GetPropertyChangedSignal("Parent"):Connect(function()
        Part1 = att1.Parent
        if not isa(Part1, "BasePart") then
            att1 = nil
            Part1 = nil
        end
    end)
    att1.Parent = Part1
end

local function respawnrequest()
    local ccfr, c = ws.CurrentCamera.CFrame, lp.Character
    lp.Character = nil
    lp.Character = c
    local con = nil
    con = ws.CurrentCamera.Changed:Connect(function(prop)
        if (prop ~= "Parent") and (prop ~= "CFrame") then
            return
        end
        ws.CurrentCamera.CFrame = ccfr
        con:Disconnect()
    end)
end

local destroyhum = (method == 4) or (method == 5)
local breakjoints = (method == 0) or (method == 4)
local antirespawn = (method == 0) or (method == 2) or (method == 3)

hatcollide = hatcollide and (method == 0)

addtools = addtools and lp:FindFirstChildOfClass("Backpack")

if type(simrad) ~= "number" then simrad = 1000 end
if shp and (simradius == "shp") then
    tdelay(0, function()
        while c do
            shp(lp, "SimulationRadius", simrad)
            heartbeat:Wait()
        end
    end)
elseif ssr and (simradius == "ssr") then
    tdelay(0, function()
        while c do
            ssr(simrad)
            heartbeat:Wait()
        end
    end)
end

if antiragdoll then
    antiragdoll = function(v)
        if isa(v, "HingeConstraint") or isa(v, "BallSocketConstraint") then
            v.Parent = nil
        end
    end
    for i, v in pairs(getdescendants(c)) do
        antiragdoll(v)
    end
    c.DescendantAdded:Connect(antiragdoll)
end

if antirespawn then
    respawnrequest()
end

if method == 0 then
    twait(loadtime)
    if not c then
        return
    end
end

if discharscripts then
    for i, v in pairs(getdescendants(c)) do
        if isa(v, "LocalScript") then
            v.Disabled = true
        end
    end
elseif newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate and (not animate.Disabled) then
        animate.Disabled = true
    else
        newanimate = false
    end
end

if addtools then
    for i, v in pairs(getchildren(addtools)) do
        if isa(v, "Tool") then
            v.Parent = c
        end
    end
end

pcall(function()
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local OLDscripts = {}

for i, v in pairs(getdescendants(c)) do
    if v.ClassName == "Script" then
        OLDscripts[v.Name] = true
    end
end

local scriptNames = {}

for i, v in pairs(getdescendants(c)) do
    if isa(v, "BasePart") then
        local newName, exists = tostring(i), true
        while exists do
            exists = OLDscripts[newName]
            if exists then
                newName = newName .. "_"    
            end
        end
        table.insert(scriptNames, newName)
        Instance.new("Script", v).Name = newName
    end
end

local hum = c:FindFirstChildOfClass("Humanoid")
if hum then
    for i, v in pairs(hum:GetPlayingAnimationTracks()) do
        v:Stop()
    end
end
c.Archivable = true
local cl = clone(c)
if hum and humState16 then
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    if destroyhum then
        twait(1.6)
    end
end
if destroyhum then
    pcall(destroy, hum)
end

if not c then
    return
end

local head, torso, root = gp(c, "Head", "BasePart"), gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart"), gp(c, "HumanoidRootPart", "BasePart")
if hatcollide then
    pcall(destroy, torso)
    pcall(destroy, root)
    pcall(destroy, c:FindFirstChildOfClass("BodyColors") or gp(c, "Health", "Script"))
end

local model = Instance.new("Model", c)
model:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (model and model.Parent) then
        model = nil
    end
end)

for i, v in pairs(getchildren(c)) do
    if v ~= model then
        if addtools and isa(v, "Tool") then
            for i1, v1 in pairs(getdescendants(v)) do
                if v1 and v1.Parent and isa(v1, "BasePart") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity, bv.MaxForce, bv.P, bv.Name = v3_0, v3(1000, 1000, 1000), 1250, "bv_" .. v.Name
                    bv.Parent = v1
                end
            end
        end
        v.Parent = model
    end
end

if breakjoints then
    model:BreakJoints()
else
    if head and torso then
        for i, v in pairs(getdescendants(model)) do
            if isa(v, "JointInstance") then
                local save = false
                if (v.Part0 == torso) and (v.Part1 == head) then
                    save = true
                end
                if (v.Part0 == head) and (v.Part1 == torso) then
                    save = true
                end
                if save then
                    if hedafterneck then
                        hedafterneck = v
                    end
                else
                    pcall(destroy, v)
                end
            end
        end
    end
    if method == 3 then
        task.delay(loadtime, pcall, model.BreakJoints, model)
    end
end

cl.Parent = ws
for i, v in pairs(getchildren(cl)) do
    v.Parent = c
end
pcall(destroy, cl)

local uncollide, noclipcon = nil, nil
if noclipAllParts then
    uncollide = function()
        if c then
            for i, v in pairs(getdescendants(c)) do
                if isa(v, "BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
else
    uncollide = function()
        if model then
            for i, v in pairs(getdescendants(model)) do
                if isa(v, "BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
end
noclipcon = stepped:Connect(uncollide)
uncollide()

for i, scr in pairs(getdescendants(model)) do
    if (scr.ClassName == "Script") and table.find(scriptNames, scr.Name) then
        local Part0 = scr.Parent
        if isa(Part0, "BasePart") then
            for i1, scr1 in pairs(getdescendants(c)) do
                if (scr1.ClassName == "Script") and (scr1.Name == scr.Name) and (not scr1:IsDescendantOf(model)) then
                    local Part1 = scr1.Parent
                    if (Part1.ClassName == Part0.ClassName) and (Part1.Name == Part0.Name) then
                        align(Part0, Part1)
                        pcall(destroy, scr)
                        pcall(destroy, scr1)
                        break
                    end
                end
            end
        end
    end
end

for i, v in pairs(getdescendants(c)) do
    if v and v.Parent and (not v:IsDescendantOf(model)) then
        if isa(v, "Decal") then
            v.Transparency = 1
        elseif isa(v, "BasePart") then
            v.Transparency = 1
            v.Anchored = false
        elseif isa(v, "ForceField") then
            v.Visible = false
        elseif isa(v, "Sound") then
            v.Playing = false
        elseif isa(v, "BillboardGui") or isa(v, "SurfaceGui") or isa(v, "ParticleEmitter") or isa(v, "Fire") or isa(v, "Smoke") or isa(v, "Sparkles") then
            v.Enabled = false
        end
    end
end

if newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate then
        animate.Disabled = false
    end
end

if addtools then
    for i, v in pairs(getchildren(c)) do
        if isa(v, "Tool") then
            v.Parent = addtools
        end
    end
end

local hum0, hum1 = model:FindFirstChildOfClass("Humanoid"), c:FindFirstChildOfClass("Humanoid")
if hum0 then
    hum0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum0 and hum0.Parent) then
            hum0 = nil
        end
    end)
end
if hum1 then
    hum1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum1 and hum1.Parent) then
            hum1 = nil
        end
    end)

    ws.CurrentCamera.CameraSubject = hum1
    local camSubCon = nil
    local function camSubFunc()
        camSubCon:Disconnect()
        if c and hum1 then
            ws.CurrentCamera.CameraSubject = hum1
        end
    end
    camSubCon = renderstepped:Connect(camSubFunc)
    if hum0 then
        hum0:GetPropertyChangedSignal("Jump"):Connect(function()
            if hum1 then
                hum1.Jump = hum0.Jump
            end
        end)
    else
        respawnrequest()
    end
end

local rb = Instance.new("BindableEvent", c)
rb.Event:Connect(function()
    pcall(destroy, rb)
    sg:SetCore("ResetButtonCallback", true)
    if destroyhum then
        if c then c:BreakJoints() end
        return
    end
    if model and hum0 and (hum0.Health > 0) then
        model:BreakJoints()
        hum0.Health = 0
    end
    if antirespawn then
        respawnrequest()
    end
end)
sg:SetCore("ResetButtonCallback", rb)

tdelay(0, function()
    while c do
        if hum0 and hum1 then
            hum1.Jump = hum0.Jump
        end
        wait()
    end
    sg:SetCore("ResetButtonCallback", true)
end)

R15toR6 = R15toR6 and hum1 and (hum1.RigType == Enum.HumanoidRigType.R15)
if R15toR6 then
    local part = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "UpperTorso", "BasePart") or gp(c, "LowerTorso", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
    if part then
        local cfr = part.CFrame
        local R6parts = { 
            head = {
                Name = "Head",
                Size = v3(2, 1, 1),
                R15 = {
                    Head = 0
                }
            },
            torso = {
                Name = "Torso",
                Size = v3(2, 2, 1),
                R15 = {
                    UpperTorso = 0.2,
                    LowerTorso = -0.8
                }
            },
            root = {
                Name = "HumanoidRootPart",
                Size = v3(2, 2, 1),
                R15 = {
                    HumanoidRootPart = 0
                }
            },
            leftArm = {
                Name = "Left Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftHand = -0.849,
                    LeftLowerArm = -0.174,
                    LeftUpperArm = 0.415
                }
            },
            rightArm = {
                Name = "Right Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    RightHand = -0.849,
                    RightLowerArm = -0.174,
                    RightUpperArm = 0.415
                }
            },
            leftLeg = {
                Name = "Left Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftFoot = -0.85,
                    LeftLowerLeg = -0.29,
                    LeftUpperLeg = 0.49
                }
            },
            rightLeg = {
                Name = "Right Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    RightFoot = -0.85,
                    RightLowerLeg = -0.29,
                    RightUpperLeg = 0.49
                }
            }
        }
        for i, v in pairs(getchildren(c)) do
            if isa(v, "BasePart") then
                for i1, v1 in pairs(getchildren(v)) do
                    if isa(v1, "Motor6D") then
                        v1.Part0 = nil
                    end
                end
            end
        end
        part.Archivable = true
        for i, v in pairs(R6parts) do
            local part = clone(part)
            part:ClearAllChildren()
            part.Name, part.Size, part.CFrame, part.Anchored, part.Transparency, part.CanCollide = v.Name, v.Size, cfr, false, 1, false
            for i1, v1 in pairs(v.R15) do
                local R15part = gp(c, i1, "BasePart")
                local att = gp(R15part, "att1_" .. i1, "Attachment")
                if R15part then
                    local weld = Instance.new("Weld")
                    weld.Part0, weld.Part1, weld.C0, weld.C1, weld.Name = part, R15part, cf(0, v1, 0), cf_0, "Weld_" .. i1
                    weld.Parent = R15part
                    R15part.Massless, R15part.Name = true, "R15_" .. i1
                    R15part.Parent = part
                    if att then
                        att.Position = v3(0, v1, 0)
                        att.Parent = part
                    end
                end
            end
            part.Parent = c
            R6parts[i] = part
        end
        local R6joints = {
            neck = {
                Parent = R6parts.torso,
                Name = "Neck",
                Part0 = R6parts.torso,
                Part1 = R6parts.head,
                C0 = cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rootJoint = {
                Parent = R6parts.root,
                Name = "RootJoint" ,
                Part0 = R6parts.root,
                Part1 = R6parts.torso,
                C0 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rightShoulder = {
                Parent = R6parts.torso,
                Name = "Right Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightArm,
                C0 = cf(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftShoulder = {
                Parent = R6parts.torso,
                Name = "Left Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.leftArm,
                C0 = cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            },
            rightHip = {
                Parent = R6parts.torso,
                Name = "Right Hip",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightLeg,
                C0 = cf(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftHip = {
                Parent = R6parts.torso,
                Name = "Left Hip" ,
                Part0 = R6parts.torso,
                Part1 = R6parts.leftLeg,
                C0 = cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            }
        }
        for i, v in pairs(R6joints) do
            local joint = Instance.new("Motor6D")
            for prop, val in pairs(v) do
                joint[prop] = val
            end
            R6joints[i] = joint
        end
        if hum1 then
            hum1.RigType, hum1.HipHeight = Enum.HumanoidRigType.R6, 0
        end
    end
end

local torso1 = torso
torso = gp(c, "Torso", "BasePart") or ((not R15toR6) and gp(c, torso.Name, "BasePart"))
if (typeof(hedafterneck) == "Instance") and head and torso and torso1 then
    local conNeck, conTorso, conTorso1 = nil, nil, nil
    local aligns = {}
    local function enableAligns()
        conNeck:Disconnect()
        conTorso:Disconnect()
        conTorso1:Disconnect()
        for i, v in pairs(aligns) do
            v.Enabled = true
        end
    end
    conNeck = hedafterneck.Changed:Connect(function(prop)
        if table.find({"Part0", "Part1", "Parent"}, prop) then
            enableAligns()
        end
    end)
    conTorso = torso:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    conTorso1 = torso1:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    for i, v in pairs(getdescendants(head)) do
        if isa(v, "AlignPosition") or isa(v, "AlignOrientation") then
            i = tostring(i)
            aligns[i] = v
            v:GetPropertyChangedSignal("Parent"):Connect(function()
                aligns[i] = nil
            end)
            v.Enabled = false
        end
    end
end

local flingpart0 = gp(model, flingpart, "BasePart") or gp(gp(model, flingpart, "Accessory"), "Handle", "BasePart")
local flingpart1 = gp(c, flingpart, "BasePart") or gp(gp(c, flingpart, "Accessory"), "Handle", "BasePart")

local fling = function() end
if flingpart0 and flingpart1 then
    flingpart0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart0 and flingpart0.Parent) then
            flingpart0 = nil
            fling = function() end
        end
    end)
    flingpart0.Archivable = true
    flingpart1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart1 and flingpart1.Parent) then
            flingpart1 = nil
            fling = function() end
        end
    end)
    local att0 = gp(flingpart0, "att0_" .. flingpart0.Name, "Attachment")
    local att1 = gp(flingpart1, "att1_" .. flingpart1.Name, "Attachment")
    if att0 and att1 then
        att0:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att0 and att0.Parent) then
                att0 = nil
                fling = function() end
            end
        end)
        att1:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att1 and att1.Parent) then
                att1 = nil
                fling = function() end
            end
        end)
        local lastfling = nil
        local mouse = lp:GetMouse()
        fling = function(target, duration, rotVelocity)
            if typeof(target) == "Instance" then
                if isa(target, "BasePart") then
                    target = target.Position
                elseif isa(target, "Model") then
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                elseif isa(target, "Humanoid") then
                    target = target.Parent
                    if not (target and isa(target, "Model")) then
                        return
                    end
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                else
                    return
                end
            elseif typeof(target) == "CFrame" then
                target = target.Position
            elseif typeof(target) ~= "Vector3" then
                target = mouse.Hit
                if target then
                    target = target.Position
                else
                    return
                end
            end
            if target.Y < ws.FallenPartsDestroyHeight + 5 then
                target = v3(target.X, ws.FallenPartsDestroyHeight + 5, target.Z)
            end
            lastfling = target
            if type(duration) ~= "number" then
                duration = tonumber(duration) or 0.5
            end
            if typeof(rotVelocity) ~= "Vector3" then
                rotVelocity = v3(20000, 20000, 20000)
            end
            if not (target and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.Archivable = true
            local flingpart = clone(flingpart0)
            flingpart.Transparency = 1
            flingpart.CanCollide = false
            flingpart.Name = "flingpart_" .. flingpart0.Name
            flingpart.Anchored = true
            flingpart.Velocity = v3_0
            flingpart.RotVelocity = v3_0
            flingpart.Position = target
            flingpart:GetPropertyChangedSignal("Parent"):Connect(function()
                if not (flingpart and flingpart.Parent) then
                    flingpart = nil
                end
            end)
            flingpart.Parent = flingpart1
            if flingpart0.Transparency > 0.5 then
                flingpart0.Transparency = 0.5
            end
            att1.Parent = flingpart
            local con = nil
            local rotchg = v3(0, rotVelocity.Unit.Y * -1000, 0)
            con = heartbeat:Connect(function(delta)
                if target and (lastfling == target) and flingpart and flingpart0 and flingpart1 and att0 and att1 then
                    flingpart.Orientation += rotchg * delta
                    flingpart0.RotVelocity = rotVelocity
                else
                    con:Disconnect()
                end
            end)
            if alignmode ~= 4 then
                local con = nil
                con = renderstepped:Connect(function()
                    if flingpart0 and target then
                        flingpart0.RotVelocity = v3_0
                    else
                        con:Disconnect()
                    end
                end)
            end
            twait(duration)
            if lastfling ~= target then
                if flingpart then
                    if att1 and (att1.Parent == flingpart) then
                        att1.Parent = flingpart1
                    end
                    pcall(destroy, flingpart)
                end
                return
            end
            target = nil
            if not (flingpart and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.RotVelocity = v3_0
            att1.Parent = flingpart1
            pcall(destroy, flingpart)
        end
    end
end

return function(...) return fling(...) end
]])

if type(reanimate) ~= "function" then return end
local fling = reanimate()
if type(fling) ~= "function" then return end

local lp = game:GetService("Players").LocalPlayer
local c = lp.Character
if not c then return end
local ws = game:GetService("Workspace")
c.AncestryChanged:Connect(function()
    if not c:IsDescendantOf(ws) then
        c = nil
    end
end)
local rs = game:GetService("RunService")
local stepped, renderstepped, heartbeat = rs.Stepped, rs.RenderStepped, rs.Heartbeat
local function gp(parent, name, classname)
    if typeof(parent) == "Instance" then
        for i, v in pairs(parent:GetChildren()) do
            if (v.Name == name) and v:IsA(classname) then
                return v
            end
        end
    end
    return nil
end

local function joint(name, parent, Part0, Part1, fakejoint)
    fakejoint.C0 = CFrame.new()
    fakejoint.C1 = CFrame.new()
    local joint = gp(parent, name, "Motor6D")
    if joint then
        fakejoint.C0 = joint.C0
        fakejoint.C1 = joint.C1
    end
    local con = nil
    con = stepped:Connect(function()
        if not c then
            return con:Disconnect()
        end
        local fix = nil
        fix = function()
            if not joint then 
                joint = Instance.new("Motor6D")
                joint.Changed:Connect(fix)
                joint.Destroying:Connect(function() joint = nil end)
            end
            joint.Part0 = Part0
            joint.Part1 = Part1
            joint.C0 = fakejoint.C0
            joint.C1 = fakejoint.C1
            joint.Parent = parent
        end
        fix()
    end)
end

local function part(name)
    local part = gp(c, name, "BasePart")
    if not part then
        part = Instance.new("Part")
        part.Name = name
        part.Transparency = 1
        part.CanCollide = false
        part.Massless = true
        part.Size = Vector3.new(1, 1, 1)
        part.Parent = c
    end
    local size = part.Size
    part.Destroying:Connect(function()
        part = nil
        c = nil
    end)
    local con = nil
    con = stepped:Connect(function()
        if not part then
            return con:Disconnect()
        end
        part.Anchored = false
        part.Name = name
        part.Size = size
        part.CanQuery = false
        part.CanTouch = false
        part.Parent = c
    end)
    return part
end

local Torso = part("Torso")
local RightArm = part("Right Arm")
local LeftArm = part("Left Arm")
local LeftLeg = part("Left Leg")
local RightLeg = part("Right Leg")
local Head = part("Head")
local HumanoidRootPart = part("HumanoidRootPart")

local RootJoint = {}
local RightShoulder = {}
local LeftShoulder = {}
local RightHip = {}
local LeftHip = {}
local Neck = {}

joint("Neck", Torso, Torso, Head, Neck)
joint("RootJoint", HumanoidRootPart, HumanoidRootPart, Torso, RootJoint)
joint("Right Shoulder", Torso, Torso, RightArm, RightShoulder)
joint("Left Shoulder", Torso, Torso, LeftArm, LeftShoulder)
joint("Right Hip", Torso, Torso, RightLeg, RightHip)
joint("Left Hip", Torso, Torso, LeftLeg, LeftHip)

local animate = gp(c, "Animate", "LocalScript")
if animate then
    animate.Disabled = true
end

local hum = c:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid", c)
local states = {
    [0]=false,[8]=true,
    [10]=false,[12]=false,
    [11]=false,[1]=false,
    [2]=true,[3]=true,
    [7]=true,[6]=false,
    [5]=true,[13]=false,
    [14]=false,[15]=false,
    [4]=false,[16]=false
}
for i, v in pairs(states) do
    hum:SetStateEnabled(i, v)
end
for i, v in pairs(hum:GetPlayingAnimationTracks()) do
    v:Stop()
end
hum.RigType = Enum.HumanoidRigType.R6
hum.BreakJointsOnDeath = false
hum.RequiresNeck = false
hum.MaxHealth = 0
hum.Health = 0
hum:ChangeState(8)

local attacking = false
local lastfling = 0
local mouse = lp:GetMouse()
mouse.Button1Down:Connect(function()
    local thisfling = tick()
    lastfling = thisfling
    if not attacking then
        attacking = true
        task.wait(0.4)
    end
    fling()
    if lastfling == thisfling then
        attacking = false
    end
end)

-- Created by 129K
local animations = {
        requip = {
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(-10)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(180), 0, math.rad(-15)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(210), 0, math.rad(-40)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(180), 0, math.rad(-10)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(1.5, -.5, 0);
        };
        lequip = {
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(60)) * CFrame.new(-1, -.75, 0);
        };
        runequip = {
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(-10)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(180), 0, math.rad(-15)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(210), 0, math.rad(-40)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(180), 0, math.rad(-10)) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(1.5, -.5, 0);
                CFrame.new(1.5, 0, 0);
        };
        rshoot = {
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(170), 0, 0) * CFrame.new(1.5, -.5, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(1.5, -.5, 0);
        };
        lshoot = {
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(170), 0, math.rad(60)) * CFrame.new(-1, -.75, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(60)) * CFrame.new(-1, -.75, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(80)) * CFrame.new(-.5, -.35, 0);
                CFrame.new(0, .5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(60)) * CFrame.new(-1, -.75, 0);
        };
}
local player = game:GetService("Players").LocalPlayer
local pmouse = player:GetMouse()
local char = player.Character
local bin = Instance.new("HopperBin", player.Backpack)
local barrelsize = .3
local handleweld = nil
local temp = true
local etemp = true
bin.Name = "L96A1 Magnum"
function weld(part0, part1, c0, c1, parent)
        local w = Instance.new("Weld", parent)
        w.Part0 = part0
        w.Part1 = part1
        w.C0 = c0
        w.C1 = c1
        w.Name = "NewWeld"
        return w
end
function interpolateCFrame(cf1, cf2)
        local t1 = {cf1:components()}
        local t2 = {cf2:components()}
        local newcf = {}
        for i, v in pairs(t1) do
                local dif = t2[i] - v
                if i < 4 then
                        local newValue = nil
                        if math.abs(dif) < .1 then
                                newValue = t2[i]
                        else
                                newValue = v +  ((dif/math.abs(dif)) * .1)
                        end
                        newcf[i] = newValue
                else
                        local newValue = nil
                        if math.abs(dif) < .1 then
                                newValue = t2[i]
                        else
                                newValue = v + ((dif/math.abs(dif)) * .1)
                        end
                        newcf[i] = newValue
                end
        end
        return CFrame.new(unpack(newcf))
end
function prop(name, sx, sy, sz, px, py, pz, anc, canc, col, par, mesh, meshtype, scalex, scaley, scalez, meshid, textureid)
        local part = Instance.new("Part", par)
        part.Name = name
        part.TopSurface = 0
        part.BottomSurface = 0
        part.formFactor = 3
        part.Size = Vector3.new(sx, sy, sz)
        part.Position = Vector3.new(px, py, pz)
        part.Anchored = anc
        part.CanCollide = canc
        part.BrickColor = BrickColor.new(col)
        if mesh then
                local m = Instance.new("SpecialMesh", part)
                m.MeshType = meshtype
                m.MeshId = meshid
                m.Scale = Vector3.new(scalex, scaley, scalez)
                m.TextureId = textureid
        end
        return part
end
function fade(part, speed)
        for i = part.Transparency, 1, speed do
                part.Transparency = i
                wait()
        end
        part:Destroy()
end
function clearWelds(par)
        for i, v in pairs(par:GetChildren()) do
                if v.Name == "NewWeld" and v:IsA("Weld") then
                        v:Destroy()
                end
        end
end
function sound(pitch, id, par)
        local s = Instance.new("Sound", par)
        s.Pitch = pitch
        s.SoundId = id
        return s
end
function traceRay(pos, pos2, col, trans)
        local distance = (pos - pos2).magnitude
        local trace = Instance.new("Part", char)
        trace.Anchored = true
        trace.CanCollide = false
        trace.TopSurface = 0
        trace.BottomSurface = 0
        trace.formFactor = 3
        trace.Size = Vector3.new(.2, .2, distance)
        trace.BrickColor = BrickColor.new(col)
        trace.Transparency = trans
        trace.CFrame = CFrame.new(pos2, pos) * CFrame.new(0, 0, -distance/2)
        return trace
end
clearWelds(char.Torso)
local back1 = prop("Part1", .1, .7, .5, 0, 0, 0, false, false, "Black", char, false)
local back1weld = weld(char.Torso, back1, CFrame.new(1, -2, .6) * CFrame.Angles(math.rad(90), math.rad(20), math.rad(90)), CFrame.new(), char.Torso)
local back2 = prop("Part2", .1, .2, .1, 0, 0, 0, false, false, "Grime", char, false)
local back2weld = weld(back1, back2, CFrame.new(0, -.25, -.35), CFrame.new(), char.Torso)
local back3 = prop("Part3", .1, .5, 1, 0, 0, 0, false, false, "Grime", char, false)
local back3weld = weld(back1, back3, CFrame.new(0, .1, -.75), CFrame.new(), char.Torso)
local back4 = prop("Part4", .1, .1, 1, 0, 0, 0, false, false, "Grime", char, false)
local back4weld = weld(back3, back4, CFrame.new(0, .3, 0), CFrame.new(), char.Torso)
local back5 = prop("Part5", .1, .1, .7, 0, 0, 0, false, false, "Grime", char, false)
local back5weld = weld(back1, back5, CFrame.new(0, .4, -1.6), CFrame.new(), char.Torso)
local trigger1 = prop("Part6", .1, .1, .6, 0, 0, 0, false, false, "Grime", char, false)
local trigger1weld = weld(back4, trigger1, CFrame.new(0, -.6, -.4) * CFrame.Angles(-math.rad(30), 0, 0), CFrame.new(), char.Torso)
local trigger2 = prop("Part7", .1, .1, .5, 0, 0, 0, false, false, "Grime", char, false)
local trigger2weld = weld(back4, trigger2, CFrame.new(0, -.675, -.8) * CFrame.Angles(math.rad(15), 0, 0), CFrame.new(), char.Torso)
local trigger3 = prop("Part8", .1, .1, .7, 0, 0, 0, false, false, "Grime", char, false)
local trigger3weld = weld(back4, trigger3, CFrame.new(0, -.4, -.95) * CFrame.Angles(math.rad(90), 0, 0), CFrame.new(), char.Torso)
local middle1 = prop("Part9", .1, .1, 1, 0, 0, 0, false, false, "Black", char, true, "Brick", .1, .0, .1, "", "") -- dis
local middle1weld = weld(back5, middle1, CFrame.new(0, .05, -.8), CFrame.new(), char.Torso)
local trigframe = prop("Part10", .1, .3, .3, 0, 0, 0, false, false, "Grime", char, true, "FileMesh", .3, .3, .3, "http://www.roblox.com/asset/?id=3270017", "")
local trigframeweld = weld(back5, trigframe, CFrame.new(0, -.2, -.3) * CFrame.Angles(0, math.rad(90), 0), CFrame.new(), char.Torso)
local middle2 = prop("Part11", .1, .3, 2, 0, 0, 0, false, false, "Grime", char, false)
local middle2weld = weld(middle1, middle2, CFrame.new(0, -.1, -.4), CFrame.new(), char.Torso)
local barrel = prop("Part12", .1, .1, 4, 0, 0, 0, false, false, "Black", char, true, "Brick", .5, .5, 1, "", "")
local barrelweld = weld(middle1, barrel, CFrame.new(0, -.05, -2), CFrame.new(), char.Torso)
local barrel2 = prop("Part13", barrelsize, 2, barrelsize, 0, 0, 0, false, false, "Black", char, false) Instance.new("CylinderMesh", barrel2)
local barrel2weld = weld(barrel, barrel2, CFrame.new(0, 0, -2.5) * CFrame.Angles(math.rad(90), 0, 0), CFrame.new(), char.Torso)
local scope1 = prop("Part14", .1, .2, .1, 0, 0, 0, false, false, "Black", char, true, "Brick", .5, .5, .5, "", "")
local scope1weld = weld(middle1, scope1, CFrame.new(0, .1, .25), CFrame.new(), char.Torso)
local scope2 = prop("Part14", .1, .2, .1, 0, 0, 0, false, false, "Black", char, true, "Brick", .5, .5, .5, "", "")
local scope2weld = weld(middle1, scope2, CFrame.new(0, .1, -.25), CFrame.new(), char.Torso)
local scope3 = prop("Part15", .1, 1.5, .1, 0, 0, 0, false, false, "Black", char, false) Instance.new("CylinderMesh", scope3)
local scope3weld = weld(middle1, scope3, CFrame.new(0, .2, 0) * CFrame.Angles(math.rad(90), 0, 0), CFrame.new(), char.Torso)
local scope4 = prop("Part16", .2, .3, .2, 0, 0, 0, false, false, "Black", char, true, "FileMesh", .2, .3, .2, "http://www.roblox.com/asset/?id=1033714", "")
local scope4weld = weld(middle1, scope4, CFrame.new(0, .2, .7) * CFrame.Angles(math.rad(270), 0, 0), CFrame.new(), char.Torso)
local scope5 = prop("Part17", .3, .35, .3, 0, 0, 0, false, false, "Black", char, true, "FileMesh", .3, .35, .3, "http://www.roblox.com/asset/?id=1033714", "")
local scope5weld = weld(middle1, scope5, CFrame.new(0, .2, -.7) * CFrame.Angles(math.rad(-270), 0, 0), CFrame.new(), char.Torso)
local rarmweld = weld(char.Torso, nil, CFrame.new(1.5, 0, 0), CFrame.new(), char.Torso)
local larmweld = weld(char.Torso, nil, CFrame.new(-1.5, 0, 0), CFrame.new(), char.Torso)
local gyro = Instance.new("BodyGyro", char.Torso)
gyro.P = 10000
gyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
pmouse.Move:connect(function()
        gyro.cframe = CFrame.new(char.Torso.Position, Vector3.new(pmouse.Hit.p.X, char.Torso.Position.Y, pmouse.Hit.p.Z))
end)
function onEquip(mouse)
        repeat wait() until etemp and temp
        etemp = false
        rarmweld.Part1 = char["Right Arm"]
        local frame = 1
        coroutine.wrap(function()
                while rarmweld and animations.requip[frame] do
                        rarmweld.C0 = interpolateCFrame(rarmweld.C0, animations.requip[frame])
                        if rarmweld.C0 == animations.requip[frame] then
                                frame = frame + 1
                        else
                                wait()
                        end
                end
        end)()
        repeat wait() until frame == 3
        back1weld.Part0 = nil
        handleweld = weld(char["Right Arm"], back1, CFrame.new(-.5, 1, -.3) * CFrame.Angles(math.rad(270), 0, 0), CFrame.new(), char.Torso)
        repeat wait() until frame == 5
        larmweld.Part1 = char["Left Arm"]
        local frame2 = 1
        coroutine.wrap(function()
                while larmweld and animations.lequip[frame2] do
                        larmweld.C0 = interpolateCFrame(larmweld.C0, animations.lequip[frame2])
                        if larmweld.C0 == animations.lequip[frame2] then
                                frame2 = frame2 + 1
                        else
                                wait()
                        end
                end
                etemp = true
        end)()
        repeat wait() until frame == 6
        mouse.Button1Down:connect(function()
                if not temp then return end
                temp = false
                local frame3 = 1
                coroutine.wrap(function()
                        while rarmweld and animations.rshoot[frame3] do
                                rarmweld.C0 = interpolateCFrame(rarmweld.C0, animations.rshoot[frame3])
                                if rarmweld.C0 == animations.rshoot[frame3] then
                                        frame3 = frame3 + 1
                                else
                                        wait()
                                end
                        end
                end)()
                local frame4 = 1
                coroutine.wrap(function()
                        while larmweld and animations.lshoot[frame4] do
                                larmweld.C0 = interpolateCFrame(larmweld.C0, animations.lshoot[frame4])
                                if larmweld.C0 == animations.lshoot[frame4] then
                                        frame4 = frame4 + 1
                                else
                                        wait()
                                end
                        end
                        wait(.1)
                        temp = true
                end)()
                local ray = Ray.new(barrel2.Position, (mouse.Hit.p - barrel2.Position).unit * 500)
                sound(2, "http://www.roblox.com/Asset/?id=16211041", barrel2):play()
                local hit, pos = workspace:FindPartOnRay(ray, char)
                if hit and hit.Parent:FindFirstChild("Humanoid") then
                        local dmg = math.random(70, 100)
                        if hit.Name ~= "Head" then
                                hit.Parent.Humanoid:TakeDamage(dmg)
                                hit.Parent.Humanoid.Sit = true
                        else
                                hit.Parent:BreakJoints()
                                sound(1, "http://www.roblox.com/asset/?id=1876552", workspace):play()
                        end
                        if game:GetService("Players"):GetPlayerFromCharacter(hit.Parent) == nil then return end
                        local bl = Instance.new("Part", workspace)
                        bl.Name = "Blood"
                        bl.BrickColor = BrickColor.new("Really red")
                        bl.FormFactor = 3
                        bl.TopSurface = 0
                        bl.BottomSurface = 0
                        bl.Size = Vector3.new(1, .1, 1)
                        bl.Position = hit.Parent.Head.Position + Vector3.new(0, 3, 0)
                        local bbg = Instance.new("BillboardGui", bl)
                        bbg.Adornee = bl
                        bbg.Size = UDim2.new(1, 0, 1, 0)
                        bbg.StudsOffset = Vector3.new(0, 1, 0)
                        local txt = Instance.new("TextLabel", bbg)
                        txt.Position = UDim2.new(0.5, 0, 0.5, 0)
                        txt.FontSize = "Size14"
                        txt.TextColor3 = Color3.new(1, 1, 1)
                        txt.Text = hit.Name ~= "Head" and dmg or "HEADSHOT"
                        coroutine.wrap(fade)(bl, 0.005)
                end
                if hit and hit.Parent:IsA("Hat") then
                        hit:BreakJoints()
                end
                Spawn(function()
                        local tr = traceRay(barrel2.Position, pos, "White", .5)
                        fade(tr, .01)
                end)
                repeat wait() until frame4 == 3
                sound(1, "http://roblox.com/asset/?id=10209881", middle2):play()
        end)
end
function onUnequip()
        repeat wait() until etemp and temp
        etemp = false
        local frame = 1
        coroutine.wrap(function()
                while rarmweld and animations.runequip[frame] do
                        rarmweld.C0 = interpolateCFrame(rarmweld.C0, animations.runequip[frame])
                        if rarmweld.C0 == animations.runequip[frame] then
                                frame = frame + 1
                        else
                                wait()
                        end
                end
                etemp = true
        end)()
        coroutine.wrap(function()
                while larmweld do
                        larmweld.C0 = interpolateCFrame(larmweld.C0, CFrame.new(-1.5, 0, 0))
                        if larmweld.C0 == CFrame.new(-1.5, 0, 0) then
                                break
                        else
                                wait()
                        end
                end
        end)()
        repeat wait() until frame == 4
        handleweld:Remove()
        back1weld:Remove()
        back1weld = weld(char.Torso, back1, CFrame.new(1, -2, .6) * CFrame.Angles(math.rad(90), math.rad(20), math.rad(90)), CFrame.new(), char.Torso)
        repeat wait() until frame == 7
        rarmweld.Part1 = nil
        larmweld.Part1 = nil
end
bin.Selected:connect(onEquip)
bin.Deselected:connect(onUnequip)

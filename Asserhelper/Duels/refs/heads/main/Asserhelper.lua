local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local ws = workspace
local cg = game:GetService("CoreGui")
local rep = game:GetService("ReplicatedStorage")

-- Killer Hub Loadstring Removed

local par = (gethui and gethui()) or cg
local cam = ws.CurrentCamera

-- Updated Color Palette to Blue Theme
local pd = Color3.fromRGB(10, 30, 60)   -- Dark Blue
local pm = Color3.fromRGB(20, 50, 110)  -- Medium Blue
local pl = Color3.fromRGB(40, 90, 180)  -- Light Blue
local pa = Color3.fromRGB(60, 130, 255) -- Bright Blue
local pb = Color3.fromRGB(120, 180, 255)-- Neon Blue
local pg = Color3.fromRGB(150, 210, 255)-- Sky Blue
local bgc = Color3.fromRGB(5, 10, 20)   -- Deep Background Blue
local wh = Color3.fromRGB(255, 255, 255)

local speed55 = false
local speedSteal = false
local spinbot = false
local autograb = false
local xrayon = false
local antirag = false
local floaton = false
local infjump = false

local xrayOg = {}
local xrayConns = {}
local conns = {}

local blocked = {
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Physics] = true,
    [Enum.HumanoidStateType.Dead] = true
}

local target = nil
local floatConn = nil
local floatSpeed = 56.1
local vertSpeed = 35

local movingDots = {}
local sprintMovingDots = {}

local function spinOn(c)
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end
    local bv = Instance.new("BodyAngularVelocity")
    bv.MaxTorque = Vector3.new(0, math.huge, 0)
    bv.AngularVelocity = Vector3.new(0, 40, 0)
    bv.Parent = hrp
end

local function spinOff(c)
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyAngularVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end

local function toggleSpin(b)
    spinbot = b
    if b then
        if plr.Character then
            spinOn(plr.Character)
        end
        table.insert(conns, plr.CharacterAdded:Connect(function(c)
            spinOn(c)
        end))
    else
        if plr.Character then
            spinOff(plr.Character)
        end
    end
end

local function createDots(parent)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 0
    container.Name = "DotBackground"
    
    local dots = {}
    for i = 1, 40 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = pa
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.Parent = container
        dot.ZIndex = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = pb
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        stroke.Parent = dot
        
        table.insert(dots, {
            frame = dot,
            sx = (math.random() - 0.5) * 0.015,
            sy = (math.random() - 0.5) * 0.015,
            pulse = math.random() * 2
        })
    end
    
    return container, dots
end

local anti = {}
local antiMode = nil
local ragConns = {}
local charCache = {}

local function cacheChar()
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return false end
    charCache = {
        char = c,
        hum = h,
        root = r
    }
    return true
end

local function killConns()
    for _, c in pairs(ragConns) do
        pcall(function() c:Disconnect() end)
    end
    ragConns = {}
end

local function isRagdoll()
    if not charCache.hum then return false end
    local s = charCache.hum:GetState()
    if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
        return true
    end
    local et = plr:GetAttribute("RagdollEndTime")
    if et then
        local n = workspace:GetServerTimeNow()
        if (et - n) > 0 then
            return true
        end
    end
    return false
end

local function removeCons()
    if not charCache.char then return end
    for _, d in pairs(charCache.char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and string.find(d.Name, "RagdollAttachment")) then
            pcall(function() d:Destroy() end)
        end
    end
end

local function forceExit()
    if not charCache.hum or not charCache.root then return end
    pcall(function()
        plr:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    if charCache.hum.Health > 0 then
        charCache.hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    charCache.root.Anchored = false
    charCache.root.AssemblyLinearVelocity = Vector3.zero
end

local function antiLoop()
    while antiMode == "v1" and charCache.hum do
        task.wait()
        if isRagdoll() then
            removeCons()
            forceExit()
        end
    end
end

local function setupCam()
    if not charCache.hum then return end
    table.insert(ragConns, rs.RenderStepped:Connect(function()
        if antiMode ~= "v1" then return end
        local c = workspace.CurrentCamera
        if c and charCache.hum and c.CameraSubject ~= charCache.hum then
            c.CameraSubject = charCache.hum
        end
    end))
end

local function onChar(c)
    task.wait(0.5)
    if not antiMode then return end
    if cacheChar() then
        if antiMode == "v1" then
            setupCam()
            task.spawn(antiLoop)
        end
    end
end

function anti.Enable(m)
    if m ~= "v1" then return end
    if antiMode == m then return end
    anti.Disable()
    if not cacheChar() then return end
    antiMode = m
    table.insert(ragConns, plr.CharacterAdded:Connect(onChar))
    setupCam()
    task.spawn(antiLoop)
end

function anti.Disable()
    if not antiMode then return end
    antiMode = nil
    killConns()
    charCache = {}
end

local AnimalsData = require(rep:WaitForChild("Datas"):WaitForChild("Animals"))

local animalCache = {}
local promptMem = {}
local stealMem = {}
local lastUid = nil
local lastPos = nil

local radius = 150
local stealing = false
local stealProg = 0
local curTarget = nil
local stealStart = 0
local stealConn = nil
local velConn = nil

local grabUI = nil
local progBar = nil
local dotsFolder = nil

local function hrp()
    local c = plr.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(n)
    local p = workspace.Plots:FindFirstChild(n)
    if not p then return false end
    local s = p:FindFirstChild("PlotSign")
    if s then
        local y = s:FindFirstChild("YourBase")
        if y and y:IsA("BillboardGui") then
            return y.Enabled == true
        end
    end
    return false
end

local function scanPlot(p)
    if not p or not p:IsA("Model") then return end
    if isMyBase(p.Name) then return end
    local pods = p:FindFirstChild("AnimalPodiums")
    if not pods then return end
    for _, pod in pairs(pods:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local name = "Unknown"
            local spawn = pod.Base:FindFirstChild("Spawn")
            if spawn then
                for _, c in pairs(spawn:GetChildren()) do
                    if c:IsA("Model") and c.Name ~= "PromptAttachment" then
                        name = c.Name
                        local info = AnimalsData[name]
                        if info and info.DisplayName then
                            name = info.DisplayName
                        end
                        break
                    end
                end
            end
            table.insert(animalCache, {
                name = name,
                plot = p.Name,
                slot = pod.Name,
                pos = pod:GetPivot().Position,
                uid = p.Name .. "_" .. pod.Name,
            })
        end
    end
end

local function setupScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10)
    if not plots then return end
    for _, p in pairs(plots:GetChildren()) do
        if p:IsA("Model") then
            scanPlot(p)
        end
    end
    plots.ChildAdded:Connect(function(p)
        if p:IsA("Model") then
            task.wait(0.5)
            scanPlot(p)
        end
    end)
    task.spawn(function()
        while task.wait(5) do
            if autograb then
                animalCache = {}
                for _, p in pairs(plots:GetChildren()) do
                    if p:IsA("Model") then
                        scanPlot(p)
                    end
                end
            end
        end
    end)
end

local function findPrompt(d)
    if not d then return nil end
    local cached = promptMem[d.uid]
    if cached and cached.Parent then
        return cached
    end
    local p = workspace.Plots:FindFirstChild(d.plot)
    if not p then return nil end
    local pods = p:FindFirstChild("AnimalPodiums")
    if not pods then return nil end
    local pod = pods:FindFirstChild(d.slot)
    if not pod then return nil end
    local b = pod:FindFirstChild("Base")
    if not b then return nil end
    local s = b:FindFirstChild("Spawn")
    if not s then return nil end
    local a = s:FindFirstChild("PromptAttachment")
    if not a then return nil end
    for _, pr in pairs(a:GetChildren()) do
        if pr:IsA("ProximityPrompt") then
            promptMem[d.uid] = pr
            return pr
        end
    end
    return nil
end

local function updateVel()
    local h = hrp()
    if not h then return end
    local cur = h.Position
    if lastPos then
        lastPos = cur
    else
        lastPos = cur
    end
end

local function shouldSteal(d)
    if not d or not d.pos then return false end
    local h = hrp()
    if not h then return false end
    return (h.Position - d.pos).Magnitude <= radius
end

local function buildCallbacks(p)
    if stealMem[p] then return end
    local data = {hold = {}, trig = {}, ready = true}
    local ok, c = pcall(getconnections, p.PromptButtonHoldBegan)
    if ok and type(c) == "table" then
        for _, con in pairs(c) do
            if type(con.Function) == "function" then
                table.insert(data.hold, con.Function)
            end
        end
    end
    local ok2, c2 = pcall(getconnections, p.Triggered)
    if ok2 and type(c2) == "table" then
        for _, con in pairs(c2) do
            if type(con.Function) == "function" then
                table.insert(data.trig, con.Function)
            end
        end
    end
    if #data.hold > 0 or #data.trig > 0 then
        stealMem[p] = data
    end
end

local function doSteal(p, d)
    local data = stealMem[p]
    if not data or not data.ready then return false end
    data.ready = false
    stealing = true
    stealProg = 0
    curTarget = d
    stealStart = tick()
    task.spawn(function()
        if #data.hold > 0 then
            for _, fn in pairs(data.hold) do
                task.spawn(fn)
            end
        end
        local st = tick()
        while tick() - st < 1.3 do
            stealProg = (tick() - st) / 1.3
            task.wait(0.05)
        end
        stealProg = 1
        if #data.trig > 0 then
            for _, fn in pairs(data.trig) do
                task.spawn(fn)
            end
        end
        task.wait(0.1)
        data.ready = true
        task.wait(0.3)
        stealing = false
        stealProg = 0
        curTarget = nil
    end)
    return true
end

local function attemptSteal(p, d)
    if not p or not p.Parent then return false end
    buildCallbacks(p)
    if not stealMem[p] then return false end
    return doSteal(p, d)
end

local function getNearest()
    local h = hrp()
    if not h then return nil end
    local n = nil
    local md = math.huge
    for _, d in pairs(animalCache) do
        if not isMyBase(d.plot) and d.pos then
            local dist = (h.Position - d.pos).Magnitude
            if dist < md then
                md = dist
                n = d
            end
        end
    end
    return n
end

local function setupGrabUI()
    if grabUI and grabUI.Parent then
        grabUI:Destroy()
    end
    grabUI = Instance.new("ScreenGui")
    grabUI.Name = "AsserGrabUI"
    grabUI.ResetOnSpawn = false
    grabUI.Parent = plr:WaitForChild("PlayerGui")
    
    local m = Instance.new("Frame")
    m.Size = UDim2.new(0, 280, 0, 24)
    m.Position = UDim2.new(0.5, -140, 1, -100)
    m.BackgroundColor3 = Color3.fromRGB(0, 15, 35)
    m.BackgroundTransparency = 0.15
    m.BorderSizePixel = 0
    m.Parent = grabUI
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = m
    
    local s = Instance.new("UIStroke")
    s.Thickness = 1.5
    s.Color = pa
    s.Transparency = 0.1
    s.Parent = m
    
    local gt = Instance.new("TextLabel")
    gt.Size = UDim2.new(1, 0, 1, 0)
    gt.BackgroundTransparency = 1
    gt.Text = "ASSER HUB AUTO GRAB"
    gt.TextColor3 = wh
    gt.Font = Enum.Font.GothamBold
    gt.TextSize = 10
    gt.ZIndex = 2
    gt.Parent = m

    dotsFolder = Instance.new("Folder")
    dotsFolder.Parent = m
    
    for i = 1, 30 do
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, math.random(2,4), 0, math.random(2,4))
        d.Position = UDim2.new(math.random(), 0, math.random(), 0)
        d.BackgroundColor3 = pa
        d.BackgroundTransparency = math.random(40,80)/100
        d.BorderSizePixel = 0
        d.Parent = dotsFolder
        local dc = Instance.new("UICorner")
        dc.CornerRadius = UDim.new(1,0)
        dc.Parent = d
        d:SetAttribute("Speed", math.random(3,15)/1000)
    end
    
    local pb_bg = Instance.new("Frame")
    pb_bg.Size = UDim2.new(0.92, 0, 0, 10)
    pb_bg.Position = UDim2.new(0.04, 0, 0.5, -5)
    pb_bg.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
    pb_bg.BackgroundTransparency = 0.3
    pb_bg.BorderSizePixel = 0
    pb_bg.Parent = m
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = pb_bg
    
    progBar = Instance.new("Frame")
    progBar.Size = UDim2.new(0, 0, 1, 0)
    progBar.BackgroundColor3 = pa
    progBar.BorderSizePixel = 0
    progBar.Parent = pb_bg
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = progBar
end

local function startGrab()
    autograb = true
    setupGrabUI()
    setupScanner()
    if stealConn then stealConn:Disconnect() end
    if velConn then velConn:Disconnect() end
    velConn = rs.Heartbeat:Connect(updateVel)
    stealConn = rs.Heartbeat:Connect(function()
        if not autograb then return end
        if stealing then return end
        local tar = getNearest()
        if not tar then return end
        if not shouldSteal(tar) then return end
        if lastUid ~= tar.uid then
            lastUid = tar.uid
        end
        local p = promptMem[tar.uid]
        if not p or not p.Parent then
            p = findPrompt(tar)
        end
        if p then
            attemptSteal(p, tar)
        end
    end)
end

local function stopGrab()
    autograb = false
    if stealConn then
        stealConn:Disconnect()
        stealConn = nil
    end
    if velConn then
        velConn:Disconnect()
        velConn = nil
    end
    if grabUI then
        grabUI:Destroy()
        grabUI = nil
    end
    progBar = nil
    dotsFolder = nil
    animalCache = {}
    promptMem = {}
    stealMem = {}
end

local function startFloat()
    floaton = true
    if floatConn then floatConn:Disconnect() end
    floatConn = rs.Heartbeat:Connect(function()
        if not floaton then return end
        local c = plr.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local np = nil
        local nd = math.huge
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local oh = p.Character:FindFirstChild("HumanoidRootPart")
                if oh then
                    local d = (h.Position - oh.Position).Magnitude
                    if d < nd then
                        nd = d
                        np = p
                    end
                end
            end
        end
        if np and np.Character then
            local th = np.Character:FindFirstChild("HumanoidRootPart")
            if th then
                target = np
                local dir = (th.Position - h.Position).Unit
                local hd = th.Position.Y - h.Position.Y
                local hv = dir * floatSpeed
                local vv = 0
                if hd > 2 then
                    vv = vertSpeed
                elseif hd < -2 then
                    vv = -vertSpeed * 0.5
                end
                h.AssemblyLinearVelocity = Vector3.new(hv.X, vv, hv.Z)
            end
        else
            h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            target = nil
        end
    end)
end

local function stopFloat()
    floaton = false
    target = nil
    if floatConn then
        floatConn:Disconnect()
        floatConn = nil
    end
    local c = plr.Character
    if c then
        local h = c:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

local function drag(obj)
    local d, i, s, p
    obj.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            d = true
            s = inp.Position
            p = obj.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    d = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            i = inp
        end
    end)
    uis.InputChanged:Connect(function(inp)
        if inp == i and d then
            local delta = inp.Position - s
            obj.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y)
        end
    end)
end

local gui = Instance.new("ScreenGui", par)
gui.Name = "ASSERHUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function new(c, props)
    local o = Instance.new(c)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            o[k] = v
        end
    end
    if props.Parent then
        o.Parent = props.Parent
    end
    return o
end

local main = new("Frame", {
    Name = "main",
    Size = UDim2.new(0, 160, 0, 172),
    Position = UDim2.new(0.5, -180, 0.5, -86),
    BackgroundTransparency = 1,
    Active = true,
    Draggable = true,
    Parent = gui
})
main.Visible = false

local bg = new("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = bgc,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = main
})

new("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = bg
})

local dotContainer, movingDots = createDots(bg)

local function mkGrad(p)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, pd),
        ColorSequenceKeypoint.new(0.3, pm),
        ColorSequenceKeypoint.new(0.6, pa),
        ColorSequenceKeypoint.new(1, pb)
    })
    g.Rotation = 0
    g.Parent = p
    return g
end

local grad = mkGrad(bg)

local stroke = new("UIStroke", {
    Color = pg,
    Thickness = 1.5,
    Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = bg
})

local stgrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, pd),
        ColorSequenceKeypoint.new(0.2, pa),
        ColorSequenceKeypoint.new(0.5, pb),
        ColorSequenceKeypoint.new(0.8, pa),
        ColorSequenceKeypoint.new(1, pd)
    }),
    Rotation = 0,
    Parent = stroke
})

drag(main)

local sprint = new("Frame", {
    Name = "sprint",
    Size = UDim2.new(0, 160, 0, 172),
    Position = UDim2.new(0.5, 20, 0.5, -86),
    BackgroundTransparency = 1,
    Active = true,
    Draggable = true,
    Parent = gui
})
sprint.Visible = false

local sbg = new("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = bgc,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = sprint
})

new("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = sbg
})

local sprintDotContainer, sprintMovingDots = createDots(sbg)

local sgrad = mkGrad(sbg)

local sst = new("UIStroke", {
    Color = pg,
    Thickness = 1.5,
    Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = sbg
})

local sstg = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, pd),
        ColorSequenceKeypoint.new(0.2, pa),
        ColorSequenceKeypoint.new(0.5, pb),
        ColorSequenceKeypoint.new(0.8, pa),
        ColorSequenceKeypoint.new(1, pd)
    }),
    Rotation = 0,
    Parent = sst
})

drag(sprint)

local tc = new("Frame", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    Parent = main
})
tc.Visible = false

local title = new("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Text = "ASSER HUB",
    TextColor3 = pb,
    Font = Enum.Font.GothamBlack,
    TextSize = 16,
    TextStrokeColor3 = pd,
    TextStrokeTransparency = 0.3,
    TextTransparency = 1,
    BackgroundTransparency = 1,
    Parent = tc
})

local line = new("Frame", {
    Size = UDim2.new(0.8, 0, 0, 1.5),
    Position = UDim2.new(0.1, 0, 1, -1.5),
    BackgroundColor3 = pa,
    BackgroundTransparency = 1,
    Parent = tc
})

new("UICorner", {
    CornerRadius = UDim.new(1, 0),
    Parent = line
})

local stc = new("Frame", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    Parent = sprint
})
stc.Visible = false

local sttl = new("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Text = "DUEL HELPER",
    TextColor3 = pb,
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
    TextStrokeColor3 = pd,
    TextStrokeTransparency = 0.3,
    TextTransparency = 1,
    BackgroundTransparency = 1,
    Parent = stc
})

local sline = new("Frame", {
    Size = UDim2.new(0.8, 0, 0, 1.5),
    Position = UDim2.new(0.1, 0, 1, -1.5),
    BackgroundColor3 = pa,
    BackgroundTransparency = 1,
    Parent = stc
})

new("UICorner", {
    CornerRadius = UDim.new(1, 0),
    Parent = sline
})

local function makeToggle(parent, txt, y, cb, def)
    local c = new("Frame", {
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.new(0, 8, 0, y),
        BackgroundTransparency = 1,
        Parent = parent
    })
    c.Visible = false
    
    local b = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 22, 32),
        BorderSizePixel = 0,
        Parent = c
    })
    
    new("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = b
    })
    
    local lbl = new("TextLabel", {
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = txt,
        TextColor3 = wh,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        Parent = b
    })
    
    local tbg = new("Frame", {
        Size = UDim2.new(0, 32, 0, 15),
        Position = UDim2.new(1, -40, 0.5, -7.5),
        BackgroundColor3 = Color3.fromRGB(18, 28, 38),
        BorderSizePixel = 0,
        Parent = b
    })
    
    new("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = tbg
    })
    
    local knob = new("Frame", {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(0, 2, 0.5, -5.5),
        BackgroundColor3 = pl,
        BorderSizePixel = 0,
        Parent = tbg
    })
    
    new("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = tbg
    })
    
    local active = def or false
    
    local function update()
        if active then
            ts:Create(knob, TweenInfo.new(0.12), {
                Position = UDim2.new(1, -13, 0.5, -5.5),
                BackgroundColor3 = pb
            }):Play()
            tbg.BackgroundColor3 = pd
        else
            ts:Create(knob, TweenInfo.new(0.12), {
                Position = UDim2.new(0, 2, 0.5, -5.5),
                BackgroundColor3 = pl
            }):Play()
            tbg.BackgroundColor3 = Color3.fromRGB(18, 28, 38)
        end
        cb(active)
    end
    
    update()
    
    btn.MouseButton1Click:Connect(function()
        active = not active
        update()
    end)
    
    return {
        Set = function(v) active = v update() end,
        Get = function() return active end,
        Container = c,
        ButtonBox = b
    }
end

local function xrayToggle(e)
    xrayon = e
    local function isBase(o)
        if not (o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation")) then
            return false
        end
        local n = o.Name:lower()
        local p = o.Parent and o.Parent.Name:lower() or ""
        return string.find(n, "base") or string.find(n, "claim") or string.find(p, "base") or string.find(p, "claim")
    end
    if e then
        for _, c in pairs(xrayConns) do
            if c then c:Disconnect() end
        end
        xrayConns = {}
        xrayOg = {}
        for _, o in pairs(workspace:GetDescendants()) do
            if isBase(o) then
                xrayOg[o] = o.LocalTransparencyModifier
                o.LocalTransparencyModifier = 0.8
            end
        end
        table.insert(xrayConns, workspace.DescendantAdded:Connect(function(o)
            if isBase(o) then
                xrayOg[o] = o.LocalTransparencyModifier
                o.LocalTransparencyModifier = 0.8
            end
        end))
        table.insert(xrayConns, plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            for _, o in pairs(workspace:GetDescendants()) do
                if isBase(o) then
                    if not xrayOg[o] then
                        xrayOg[o] = o.LocalTransparencyModifier
                    end
                    o.LocalTransparencyModifier = 0.8
                end
            end
        end))
    else
        for o, t in pairs(xrayOg) do
            if o and o.Parent then
                pcall(function() o.LocalTransparencyModifier = t end)
            end
        end
        for _, c in pairs(xrayConns) do
            if c then c:Disconnect() end
        end
        xrayConns = {}
        xrayOg = {}
    end
end

local speed1 = makeToggle(sprint, "SPEED [ NO STEALING ]", 34, function(v) speed55 = v end, false)
local speed2 = makeToggle(sprint, "SPEED [ STEALING ]", 66, function(v) speedSteal = v end, false)
local spintog = makeToggle(sprint, "SPINBOT", 98, function(v)
    spinbot = v
    toggleSpin(v)
end, false)
local grabtog = makeToggle(sprint, "AUTO GRAB", 130, function(v)
    autograb = v
    if v then
        startGrab()
    else
        stopGrab()
    end
end, false)

rs.Heartbeat:Connect(function()
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    local carry = false
    local a = h:FindFirstChildOfClass("Animator")
    if a then
        for _, t in pairs(a:GetPlayingAnimationTracks()) do
            if string.find(t.Animation.AnimationId, "71186871415348") then
                carry = true
                if speed55 then speed55 = false end
                break
            end
        end
    end
    if h.MoveDirection.Magnitude > 0 then
        local vel = (carry and speedSteal and 27) or (speed55 and 55) or 0
        if vel > 0 then
            r.AssemblyLinearVelocity = Vector3.new(h.MoveDirection.X * vel, r.AssemblyLinearVelocity.Y, h.MoveDirection.Z * vel)
        end
    end
end)

local oc = new("Frame", {
    Size = UDim2.new(1, 0, 1, -36),
    Position = UDim2.new(0, 0, 0, 36),
    BackgroundTransparency = 1,
    Parent = main
})
oc.Visible = false

local antitog = makeToggle(oc, "ANTI RAGDOLL", 5, function(v)
    antirag = v
    if v then
        anti.Enable("v1")
    else
        anti.Disable()
    end
end, false)

local floattog = makeToggle(oc, "FLOAT NEAREST", 37, function(v)
    floaton = v
    if v then
        startFloat()
    else
        stopFloat()
    end
end, false)

local jmptog = makeToggle(oc, "INF JUMP", 69, function(v) infjump = v end, false)
local xraytog = makeToggle(oc, "X-RAY", 101, function(v)
    xrayon = v
    xrayToggle(v)
end, false)

uis.JumpRequest:Connect(function()
    if infjump and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(plr.Character.HumanoidRootPart.AssemblyLinearVelocity.X, 52, plr.Character.HumanoidRootPart.AssemblyLinearVelocity.Z)
    end
end)

rs.Heartbeat:Connect(function(dt)
    grad.Rotation = (grad.Rotation + 80 * dt) % 360
    sgrad.Rotation = (sgrad.Rotation + 80 * dt) % 360
    stgrad.Rotation = (stgrad.Rotation + 60 * dt) % 360
    sstg.Rotation = (sstg.Rotation + 60 * dt) % 360
    
    if movingDots then
        for _, d in pairs(movingDots) do
            d.frame.Position = UDim2.new(
                (d.frame.Position.X.Scale + d.sx * dt * 30) % 1,
                0,
                (d.frame.Position.Y.Scale + d.sy * dt * 30) % 1,
                0
            )
            d.frame.BackgroundTransparency = math.sin(tick() * 2 + d.pulse) * 0.1 + 0.4
        end
    end
    
    if sprintMovingDots then
        for _, d in pairs(sprintMovingDots) do
            d.frame.Position = UDim2.new(
                (d.frame.Position.X.Scale + d.sx * dt * 30) % 1,
                0,
                (d.frame.Position.Y.Scale + d.sy * dt * 30) % 1,
                0
            )
            d.frame.BackgroundTransparency = math.sin(tick() * 2 + d.pulse) * 0.1 + 0.4
        end
    end
    
    if dotsFolder and autograb then
        for _, d in pairs(dotsFolder:GetChildren()) do
            local sp = d:GetAttribute("Speed")
            local ny = d.Position.Y.Scale - (sp or 0.01)
            if ny <= 0 then ny = 1 end
            d.Position = UDim2.new(d.Position.X.Scale, 0, ny, 0)
            d.BackgroundTransparency = 0.4 + math.abs(math.sin(tick()*3))/2
        end
    end
    
    if progBar and autograb then
        if stealing then
            progBar.Size = UDim2.new(math.min(progBar.Size.X.Scale + 0.05, stealProg), 0, 1, 0)
        else
            progBar.Size = UDim2.new(math.max(0, progBar.Size.X.Scale - 0.03), 0, 1, 0)
        end
    end
end)

local function animate()
    main.Visible = true
    sprint.Visible = true
    ts:Create(bg, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    ts:Create(stroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
    ts:Create(sbg, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    ts:Create(sst, TweenInfo.new(0.8), {Transparency = 0}):Play()
    task.wait(0.3)
    tc.Visible = true
    stc.Visible = true
    ts:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    ts:Create(line, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    ts:Create(sttl, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    ts:Create(sline, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.3)
    oc.Visible = true
    local togs = {antitog.Container, floattog.Container, jmptog.Container, xraytog.Container}
    for _, c in pairs(togs) do
        c.Visible = true
        task.wait(0.08)
    end
    task.wait(0.2)
    local stogs = {speed1.Container, speed2.Container, spintog.Container, grabtog.Container}
    for _, c in pairs(stogs) do
        c.Visible = true
        task.wait(0.08)
    end
end

plr.CharacterAdded:Connect(function(c)
    if antirag then
        anti.Enable("v1")
    end
    if spinbot then
        spinOn(c)
    end
    if floaton then
        startFloat()
    end
end)

local function statsUI()
    local sg = new("ScreenGui", {
        Name = "AsserStats",
        ResetOnSpawn = false,
        Parent = par
    })
    local sf = new("Frame", {
        Name = "main",
        Size = UDim2.new(0, 280, 0, 28),
        Position = UDim2.new(0.5, -140, 0, 5),
        BackgroundTransparency = 1,
        Active = true,
        Draggable = true,
        Parent = sg
    })
    sf.Visible = false
    local sb = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = bgc,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = sf
    })
    new("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = sb
    })
    
    local statsDotContainer, statsMovingDots = createDots(sb)
    
    local sgrad2 = mkGrad(sb)
    local sst2 = new("UIStroke", {
        Color = pg,
        Thickness = 1.5,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = sb
    })
    local sstg2 = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, pd),
            ColorSequenceKeypoint.new(0.2, pa),
            ColorSequenceKeypoint.new(0.5, pb),
            ColorSequenceKeypoint.new(0.8, pa),
            ColorSequenceKeypoint.new(1, pd)
        }),
        Rotation = 0,
        Parent = sstg2
    })
    local ld = new("Frame", {
        Size = UDim2.new(0, 1.5, 0.7, 0),
        Position = UDim2.new(0.33, -0.75, 0.15, 0),
        BackgroundColor3 = pa,
        BackgroundTransparency = 1,
        Parent = sf
    })
    local rd = new("Frame", {
        Size = UDim2.new(0, 1.5, 0.7, 0),
        Position = UDim2.new(0.66, -0.75, 0.15, 0),
        BackgroundColor3 = pa,
        BackgroundTransparency = 1,
        Parent = sf
    })
    local tl = new("TextLabel", {
        Size = UDim2.new(0.33, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = pb,
        Font = Enum.Font.GothamBlack,
        TextSize = 12,
        Text = "ASSER HUB",
        TextStrokeColor3 = pd,
        TextStrokeTransparency = 0.3,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = sf
    })
    local fpslbl = new("TextLabel", {
        Size = UDim2.new(0.33, 0, 1, 0),
        Position = UDim2.new(0.33, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = pb,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Text = "FPS: --",
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = sf
    })
    local pinglbl = new("TextLabel", {
        Size = UDim2.new(0.33, 0, 1, 0),
        Position = UDim2.new(0.66, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = pb,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Text = "PING: --ms",
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = sf
    })
    local fc = 0
    local lu = tick()
    
    rs.RenderStepped:Connect(function(dt)
        fc = fc + 1
        local ct = tick()
        if ct - lu >= 1 then
            local f = math.floor(fc / (ct - lu))
            fc = 0
            lu = ct
            fpslbl.Text = "FPS: " .. f
        end
        local p = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        pinglbl.Text = "PING: " .. math.floor(p) .. "ms"
    end)
    
    rs.Heartbeat:Connect(function(dt)
        sgrad2.Rotation = (sgrad2.Rotation + 80 * dt) % 360
        sstg2.Rotation = (sstg2.Rotation + 60 * dt) % 360
        
        if statsMovingDots then
            for _, d in pairs(statsMovingDots) do
                d.frame.Position = UDim2.new(
                    (d.frame.Position.X.Scale + d.sx * dt * 30) % 1,
                    0,
                    (d.frame.Position.Y.Scale + d.sy * dt * 30) % 1,
                    0
                )
                d.frame.BackgroundTransparency = math.sin(tick() * 2 + d.pulse) * 0.1 + 0.4
            end
        end
    end)
    
    drag(sf)
    uis.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.RightControl then
            sf.Visible = not sf.Visible
        end
    end)
    task.wait(1.5)
    sf.Visible = true
    ts:Create(sb, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    ts:Create(sst2, TweenInfo.new(0.6), {Transparency = 0}):Play()
    task.wait(0.2)
    ts:Create(ld, TweenInfo.new(0.4), {BackgroundTransparency = 0.4}):Play()
    ts:Create(rd, TweenInfo.new(0.4), {BackgroundTransparency = 0.4}):Play()
    ts:Create(tl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    ts:Create(fpslbl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    ts:Create(pinglbl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
end

task.spawn(animate)
task.spawn(statsUI)

uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then
        gui:Destroy()
    end
end)

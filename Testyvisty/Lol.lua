local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui    = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StatsService = game:GetService("Stats")

local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- === CLEANUP EXISTING GUIS ===
local function cleanupOldGUI()
    local guis = {"AsserDuels", "DropButtonGui", "MobileButtonsGui", "MenuToggleButtonGui", "SpeedConfigGui", "AsserSideMenuGui", "AsserNotifyGui", "RagdollTutorGui", "AsserAutoPlayGui", "StatsDisplay"}
    for _, name in ipairs(guis) do
        local old = CoreGui:FindFirstChild(name)
        if old then old:Destroy() end
        local old2 = PlayerGui:FindFirstChild(name)
        if old2 then old2:Destroy() end
    end
    if PlayerGui:FindFirstChild("AsserDuels") then
        PlayerGui:FindFirstChild("AsserDuels"):Destroy()
    end
end
cleanupOldGUI()

-- === UTILITY FUNCTIONS ===
local function makeDraggable(guiObj)
    local dragging, dragStart, startPos
    guiObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = guiObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === PING / FPS DISPLAY ===
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "StatsDisplay"
statsGui.ResetOnSpawn = false
statsGui.IgnoreGuiInset = true
statsGui.Parent = PlayerGui

local STATS_FULL_H = 55
local STATS_SHRUNK_H = 26

local statsMain = Instance.new("Frame", statsGui)
statsMain.Size = UDim2.new(0, 160, 0, STATS_FULL_H)
statsMain.Position = UDim2.new(0.5, -80, 0, 10)
statsMain.BackgroundColor3 = Color3.fromRGB(0, 25, 70)
statsMain.BorderSizePixel = 0
statsMain.ClipsDescendants = true
Instance.new("UICorner", statsMain).CornerRadius = UDim.new(0, 8)
local statsStroke = Instance.new("UIStroke", statsMain)
statsStroke.Thickness = 1.5; statsStroke.Color = Color3.fromRGB(0, 188, 255)
statsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
makeDraggable(statsMain)

local statsTop = Instance.new("Frame", statsMain)
statsTop.Size = UDim2.new(1, 0, 0, STATS_SHRUNK_H)
statsTop.BackgroundColor3 = Color3.fromRGB(0, 45, 120)
statsTop.BorderSizePixel = 0
Instance.new("UICorner", statsTop).CornerRadius = UDim.new(0, 8)

local statsTopFix = Instance.new("Frame", statsTop)
statsTopFix.Size = UDim2.new(1, 0, 0, 8)
statsTopFix.Position = UDim2.new(0, 0, 1, -8)
statsTopFix.BackgroundColor3 = Color3.fromRGB(0, 45, 120)
statsTopFix.BorderSizePixel = 0

local statsTitle = Instance.new("TextLabel", statsTop)
statsTitle.Size = UDim2.new(1, -30, 1, 0)
statsTitle.Position = UDim2.new(0, 10, 0, 0)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "Network Stats"
statsTitle.TextColor3 = Color3.new(1, 1, 1)
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 10
statsTitle.TextXAlignment = Enum.TextXAlignment.Left

local statsToggleBtn = Instance.new("TextButton", statsTop)
statsToggleBtn.Size = UDim2.new(0, 18, 0, 18)
statsToggleBtn.Position = UDim2.new(1, -24, 0.5, -9)
statsToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
statsToggleBtn.Text = "-"
statsToggleBtn.TextColor3 = Color3.new(1, 1, 1)
statsToggleBtn.Font = Enum.Font.GothamBold
statsToggleBtn.TextSize = 14
statsToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", statsToggleBtn).CornerRadius = UDim.new(0, 5)

local statsShrunk = false
statsToggleBtn.MouseButton1Click:Connect(function()
    statsShrunk = not statsShrunk
    TweenService:Create(statsMain, TweenInfo.new(0.2), {Size = UDim2.new(0, 160, 0, statsShrunk and STATS_SHRUNK_H or STATS_FULL_H)}):Play()
    statsToggleBtn.Text = statsShrunk and "+" or "-"
end)

local statsLabel = Instance.new("TextLabel", statsMain)
statsLabel.Size = UDim2.new(1, 0, 1, -STATS_SHRUNK_H)
statsLabel.Position = UDim2.new(0, 0, 0, STATS_SHRUNK_H)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextSize = 12
statsLabel.TextColor3 = Color3.fromRGB(0, 188, 255)
statsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statsLabel.TextStrokeTransparency = 0.5
statsLabel.Text = "0 ping | 0 fps"

local lastFpsUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastFpsUpdate >= 0.5 then
        lastFpsUpdate = now
        local ok, ping = pcall(function()
            return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        statsLabel.Text = (ok and ping or "?") .. " ping  |  " .. fps .. " fps"
    end
end)

-- === CONFIGURATIONS ===
local infinityJumpEnabled = false
local wasInfJumpOnBeforeLockIn = false
local jumpForce = 50
local clampFallSpeed = 80

local floaton = false
local vertSpeed = 35
local floatConn = nil

local aimbotEnabled = false
local LOCK_DISTANCE = 15

-- V1 Waypoints
local A1_P1 = Vector3.new(-472.59,-7.30,94.43)
local A1_P2 = Vector3.new(-484.55,-5.33,95.05)
local A1_P3 = Vector3.new(-472.59,-7.30,94.43)
local A1_P4 = Vector3.new(-471.25,-6.83,7.08)

local B1 = Vector3.new(-474.02,-7.30,25.55)
local B2 = Vector3.new(-484.92,-5.13,24.53)
local B3 = Vector3.new(-474.02,-7.30,25.55)
local B4 = Vector3.new(-470.93,-6.83,113.38)

-- V2 Waypoints
local rightWaypoints = {
    Vector3.new(-473.04, -6.99, 29.71),
    Vector3.new(-483.57, -5.10, 18.74),
    Vector3.new(-475.00, -6.99, 26.43),
    Vector3.new(-474.67, -6.94, 105.48),
}
local leftWaypoints = {
    Vector3.new(-472.49, -7.00, 90.62),
    Vector3.new(-484.62, -5.10, 100.37),
    Vector3.new(-475.08, -7.00, 93.29),
    Vector3.new(-474.22, -6.96, 16.18),
}

local SPEED_IDA  = 57
local SPEED_VOLTA = 29
local floatSpeed = 57

local asserFloating = false
local floatHeight   = 8

local auto1 = false
local auto2 = false

local autoPlayVersion = 1
local patrolMode = "none"
local currentWaypoint = 1

-- === RAGDOLL TP STATE ===
local RAGDOLL_COORDS = {
    left  = {Vector3.new(-477, -6, 94),  Vector3.new(-476, -6, 94)},
    right = {Vector3.new(-476, -7, 26),  Vector3.new(-475, -7, 26)},
}
local duelsTpEnabled   = false
local currentHumanoid  = nil
local wasStanding      = true
local ragdollActive    = false

local toggles   = {}
local uiStates  = {}
local uiCallbacks = {}

-- ==========================================================
-- === UNWALK ANIMATION LOGIC
-- ==========================================================
local unwalk = false
local savedAnims = {}
local unwalkWatcher = nil

local function isMovementAnim(anim)
    return anim and anim:IsA("Animation") and (
        anim.Name:lower():find("walk") or anim.Name:lower():find("run") or
        anim.Name:lower():find("jump") or anim.Name:lower():find("swim") or
        anim.Name:lower():find("fall") or anim.Name:lower():find("climb") or
        anim.Name:lower():find("idle") or anim.Name:lower():find("land") or
        anim.Name:lower():find("sit")  or anim.Name:lower():find("crouch")
    )
end

local function stopMovementAnims(hum)
    if not hum then return end
    for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
        local n = t.Name:lower()
        if n:find("walk") or n:find("run") or n:find("jump") or n:find("swim") or
           n:find("fall") or n:find("climb") or n:find("idle") or n:find("land") or
           n:find("sit") or n:find("crouch") then
            t:Stop()
        end
    end
end

local function saveAndClearAnim(anim)
    for _, v in ipairs(savedAnims) do if v.instance == anim then return end end
    table.insert(savedAnims, {instance = anim, id = anim.AnimationId})
    anim.AnimationId = ""
end

local function restoreAnims()
    for _, v in ipairs(savedAnims) do
        if v.instance then v.instance.AnimationId = v.id end
    end
end

local function unwalkAdded(desc)
    if unwalk and isMovementAnim(desc) then saveAndClearAnim(desc) end
end

local function scanUnwalk(character)
    local animate = character and character:FindFirstChild("Animate")
    if not animate then return end
    local function clear(folder, name)
        local anim = folder and folder:FindFirstChild(name)
        if anim and anim:IsA("Animation") then saveAndClearAnim(anim) end
    end
    clear(animate:FindFirstChild("walk"),     "WalkAnim")
    clear(animate:FindFirstChild("run"),      "RunAnim")
    clear(animate:FindFirstChild("jump"),     "JumpAnim")
    clear(animate:FindFirstChild("swim"),     "Swim")
    clear(animate:FindFirstChild("swimidle"), "SwimIdle")
    clear(animate:FindFirstChild("fall"),     "FallAnim")
    clear(animate:FindFirstChild("climb"),    "ClimbAnim")
    clear(animate:FindFirstChild("idle"),     "Animation1")
    clear(animate:FindFirstChild("idle"),     "Animation2")
    clear(animate:FindFirstChild("sit"),      "SitAnim")
    clear(animate:FindFirstChild("toolnone"), "ToolNoneAnim")
    clear(animate:FindFirstChild("toolsit"),  "ToolSitAnim")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then stopMovementAnims(hum) end
end

local function enableUnwalk()
    local char = lp.Character
    if not char then return end
    unwalk = true
    savedAnims = {}
    task.spawn(function()
        scanUnwalk(char)
        if unwalkWatcher then unwalkWatcher:Disconnect() end
        unwalkWatcher = char.DescendantAdded:Connect(unwalkAdded)
    end)
end

local function disableUnwalk()
    if unwalkWatcher then unwalkWatcher:Disconnect() unwalkWatcher = nil end
    restoreAnims()
    savedAnims = {}
    unwalk = false
end

lp.CharacterAdded:Connect(function(c)
    if unwalk then
        task.spawn(function()
            scanUnwalk(c)
            if unwalkWatcher then unwalkWatcher:Disconnect() end
            unwalkWatcher = c.DescendantAdded:Connect(unwalkAdded)
        end)
    end
end)

-- ==========================================================
-- === AIMBOT LOGIC
-- ==========================================================
local function getNearestPlayer()
    local character = lp.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local nearest, shortestDist = nil, LOCK_DISTANCE
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            local otherChar = player.Character
            if otherChar then
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    local dist = (rootPart.Position - otherRoot.Position).Magnitude
                    if dist < shortestDist then shortestDist = dist nearest = otherRoot end
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local character = lp.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local target = getNearestPlayer()
    if target then
        local direction = (target.Position - rootPart.Position).Unit
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(direction.X, 0, direction.Z))
    end
end)

-- ==========================================================
-- === V2 LOOP ENGINE
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if autoPlayVersion ~= 2 or patrolMode == "none" then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local waypoints = (patrolMode == "right") and rightWaypoints or leftWaypoints
    local targetPos = waypoints[currentWaypoint]
    local targetXZ = Vector3.new(targetPos.X, 0, targetPos.Z)
    local currentXZ = Vector3.new(root.Position.X, 0, root.Position.Z)
    local distance = (targetXZ - currentXZ).Magnitude
    if distance > 3 then
        local moveDirection = (targetXZ - currentXZ).Unit
        local speed = (currentWaypoint >= 3) and SPEED_VOLTA or SPEED_IDA
        root.AssemblyLinearVelocity = Vector3.new(moveDirection.X * speed, root.AssemblyLinearVelocity.Y, moveDirection.Z * speed)
    else
        currentWaypoint = (currentWaypoint == #waypoints) and 1 or currentWaypoint + 1
    end
end)

-- ==========================================================
-- === RAGDOLL TP LOGIC
-- ==========================================================
local function getCharacterRag()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function doubleTeleport(posTable)
    local character = getCharacterRag()
    character:PivotTo(CFrame.new(posTable[1]))
    task.wait(0.1)
    character:PivotTo(CFrame.new(posTable[2]))
end

local function getAnimalTarget()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local base = plot:FindFirstChild("DeliveryHitbox")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
            local target = plot:FindFirstChild("AnimalTarget", true)
            if target then return target.Position end
        end
    end
    return nil
end

local function performTeleport()
    local target = getAnimalTarget()
    if not target then return end
    local leftDist  = (target - RAGDOLL_COORDS.left[1]).Magnitude
    local rightDist = (target - RAGDOLL_COORDS.right[1]).Magnitude
    if leftDist > rightDist then doubleTeleport(RAGDOLL_COORDS.left)
    else doubleTeleport(RAGDOLL_COORDS.right) end
end

local function onCharacterAdded(character)
    currentHumanoid = character:WaitForChild("Humanoid")
    wasStanding  = true
    ragdollActive = false
end

if lp.Character then onCharacterAdded(lp.Character) end
lp.CharacterAdded:Connect(onCharacterAdded)

RunService.Heartbeat:Connect(function()
    if not duelsTpEnabled or not currentHumanoid then return end
    local currentState = currentHumanoid:GetState()
    if currentState == Enum.HumanoidStateType.Physics then
        if wasStanding then performTeleport() end
        ragdollActive = true; wasStanding = false
    else
        ragdollActive = false; wasStanding = true
    end
end)

-- ==========================================================
-- === MORE UTILITY
-- ==========================================================
local function hrp()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function go(pos, speed, cond)
    local r = hrp()
    if not r then return end
    while cond() and (r.Position - pos).Magnitude > 2 do
        local dir = (pos - r.Position).Unit
        r.AssemblyLinearVelocity = Vector3.new(dir.X * speed, r.AssemblyLinearVelocity.Y, dir.Z * speed)
        task.wait()
    end
end

-- === NOTIFICATION SYSTEM ===
local function showNotification(message)
    local notifyGui = Instance.new("ScreenGui", CoreGui)
    notifyGui.Name = "AsserNotifyGui"
    local notifyFrame = Instance.new("Frame", notifyGui)
    notifyFrame.Size = UDim2.new(0, 250, 0, 50); notifyFrame.Position = UDim2.new(1, 10, 0.85, 0)
    notifyFrame.BackgroundColor3 = Color3.fromRGB(0, 25, 70); notifyFrame.BorderSizePixel = 0
    Instance.new("UICorner", notifyFrame).CornerRadius = UDim.new(0, 8)
    local notifyStroke = Instance.new("UIStroke", notifyFrame)
    notifyStroke.Thickness = 1.5; notifyStroke.Color = Color3.fromRGB(0, 188, 255)
    local notifyText = Instance.new("TextLabel", notifyFrame)
    notifyText.Size = UDim2.new(1, -20, 1, 0); notifyText.Position = UDim2.new(0, 10, 0, 0)
    notifyText.BackgroundTransparency = 1; notifyText.Text = message
    notifyText.TextColor3 = Color3.new(1, 1, 1); notifyText.Font = Enum.Font.GothamBold
    notifyText.TextSize = 11; notifyText.TextWrapped = true
    notifyFrame:TweenPosition(UDim2.new(1, -260, 0.85, 0), "Out", "Quad", 0.5, true)
    task.delay(3.5, function()
        notifyFrame:TweenPosition(UDim2.new(1, 10, 0.85, 0), "In", "Quad", 0.5, true, function()
            notifyGui:Destroy()
        end)
    end)
end

-- === AUTOMATIC HITBOX LOGIC ===
local function createHitbox(plr)
    if plr == lp or not plr.Character then return end
    local char = plr.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or char:FindFirstChild("TrackHitboxAdornment") then return end
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "TrackHitboxAdornment"; hitbox.Adornee = root
    hitbox.Size = Vector3.new(4, 6, 2); hitbox.Color3 = Color3.fromRGB(0, 188, 255)
    hitbox.Transparency = 0.6; hitbox.ZIndex = 10; hitbox.AlwaysOnTop = true; hitbox.Parent = char
end

local function initializeAutomaticHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            if plr.Character then createHitbox(plr) end
            plr.CharacterAdded:Connect(function() task.wait(0.1) createHitbox(plr) end)
        end
    end
    Players.PlayerAdded:Connect(function(plr)
        if plr == lp then return end
        plr.CharacterAdded:Connect(function() task.wait(0.1) createHitbox(plr) end)
    end)
end

-- === LOCK IN (FLOAT) & BAT SPAM ===
local function stopFloat()
    if floatConn then floatConn:Disconnect() floatConn = nil end
    local c = lp.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

local function startFloat()
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not floaton then return end
        local c = lp.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local h = c.HumanoidRootPart
        local np, nd = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (h.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < nd then nd = d; np = p end
            end
        end
        if np and np.Character and np.Character:FindFirstChild("HumanoidRootPart") then
            local th  = np.Character.HumanoidRootPart
            local dir = (th.Position - h.Position).Unit
            local hd  = th.Position.Y - h.Position.Y
            local hv  = dir * floatSpeed
            local vv  = 0
            if hd > 2 then vv = vertSpeed elseif hd < -2 then vv = -vertSpeed * 0.5 end
            h.AssemblyLinearVelocity = Vector3.new(hv.X, vv, hv.Z)
        else
            h.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function toggleFloat(state)
    floaton = state
    aimbotEnabled = state
    if floaton then
        wasInfJumpOnBeforeLockIn = infinityJumpEnabled
        if infinityJumpEnabled then
            infinityJumpEnabled = false
            if toggles["Infinite Jump"] then toggles["Infinite Jump"].update(false) end
        end
        startFloat()
        task.spawn(function()
            while floaton do
                local character = lp.Character
                if character then
                    local bat = lp.Backpack:FindFirstChild("Bat") or character:FindFirstChild("Bat")
                    if bat then
                        if bat.Parent ~= character then bat.Parent = character end
                        bat:Activate()
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        stopFloat()
        if wasInfJumpOnBeforeLockIn then
            infinityJumpEnabled = true
            if toggles["Infinite Jump"] then toggles["Infinite Jump"].update(true) end
            wasInfJumpOnBeforeLockIn = false
        end
    end
end

-- === ASSER FLOAT LOGIC ===
local function updateAsserFloat()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local currentVel = root.AssemblyLinearVelocity
    if asserFloating then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = {char}
        local result = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), rp)
        if result then
            local yDiff = (result.Position.Y + floatHeight) - root.Position.Y
            if math.abs(yDiff) > 0.3 then
                root.AssemblyLinearVelocity = Vector3.new(currentVel.X, yDiff * 15, currentVel.Z)
            else
                root.AssemblyLinearVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)
            end
        end
    end
end
RunService.Heartbeat:Connect(updateAsserFloat)

-- === ANTI-RAGDOLL & KNOCKBACK ===
local AntiRagdollEnabled = false
local MAX_VELOCITY_DELTA = 40
local MAX_VELOCITY       = 25
local CLAMP_VELOCITY     = 15
local ragConns = {}

local function isKnockbackState(humanoid)
    local s = humanoid:GetState()
    return s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll
        or s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.GettingUp
end

local function enableControls()
    pcall(function()
        local module = lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
        require(module):GetControls():Enable()
    end)
end

local function cleanupRagdoll(char, animator)
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
        or (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B"))
        or obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
            obj:Destroy()
        end
    end
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("Motor6D") then obj.Enabled = true end
    end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        local name = track.Animation and track.Animation.Name:lower() or ""
        if name:find("rag") or name:find("fall") or name:find("hurt") or name:find("down") then track:Stop(0) end
    end
end

local function cleanAntiRagdoll()
    for _, conn in ipairs(ragConns) do if conn then conn:Disconnect() end end
    ragConns = {}
end

local function runAntiRagdoll()
    cleanAntiRagdoll()
    local char = lp.Character
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid")
    local hrp2     = char:WaitForChild("HumanoidRootPart")
    local animator = humanoid:WaitForChild("Animator")
    local camera   = Workspace.CurrentCamera
    local lastVel  = Vector3.zero
    local function onKnockback()
        if isKnockbackState(humanoid) then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            cleanupRagdoll(char, animator)
            camera.CameraSubject = humanoid
            enableControls()
        end
    end
    table.insert(ragConns, humanoid.StateChanged:Connect(onKnockback))
    pcall(function()
        table.insert(ragConns,
            ReplicatedStorage.Packages.Net["RE/CombatService/ApplyImpulse"].OnClientEvent:Connect(function()
                if isKnockbackState(humanoid) then hrp2.AssemblyLinearVelocity = Vector3.zero end
            end)
        )
    end)
    table.insert(ragConns, char.DescendantAdded:Connect(function()
        if isKnockbackState(humanoid) then cleanupRagdoll(char, animator) end
    end))
    table.insert(ragConns, RunService.Heartbeat:Connect(function()
        if isKnockbackState(humanoid) then
            cleanupRagdoll(char, animator)
            local vel = hrp2.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > MAX_VELOCITY_DELTA and vel.Magnitude > MAX_VELOCITY then
                hrp2.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, CLAMP_VELOCITY)
            end
            lastVel = vel
        end
    end))
    enableControls()
    cleanupRagdoll(char, animator)
end

local function toggleAntiRagdoll(state)
    AntiRagdollEnabled = state
    if state then runAntiRagdoll() else cleanAntiRagdoll() end
end

lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if AntiRagdollEnabled then runAntiRagdoll() end
end)

-- === INFINITE JUMP ===
RunService.Heartbeat:Connect(function()
    if not infinityJumpEnabled then return end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local h = char.HumanoidRootPart
        if h.AssemblyLinearVelocity.Y < -clampFallSpeed then
            h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, -clampFallSpeed, h.AssemblyLinearVelocity.Z)
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if not infinityJumpEnabled then return end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local h = char.HumanoidRootPart
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, jumpForce, h.AssemblyLinearVelocity.Z)
    end
end)

-- === WALK-FLING DROP ===
local _wfConns = {}
local _wfActive = false

local function startWalkFling()
    _wfActive = true
    table.insert(_wfConns, RunService.Stepped:Connect(function()
        if not _wfActive then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end))
    local co = coroutine.create(function()
        while _wfActive do
            RunService.Heartbeat:Wait()
            local c    = lp.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if not root then RunService.Heartbeat:Wait() continue end
            local vel = root.Velocity
            root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity = vel end
            RunService.Stepped:Wait()
            if root and root.Parent then root.Velocity = vel + Vector3.new(0, 0.1, 0) end
        end
    end)
    coroutine.resume(co)
    table.insert(_wfConns, co)
end

local function stopWalkFling()
    _wfActive = false
    for _, c in ipairs(_wfConns) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif typeof(c) == "thread" then pcall(task.cancel, c) end
    end
    _wfConns = {}
end

local dropRunning = false
local function triggerDrop()
    if dropRunning then return end
    dropRunning = true
    startWalkFling()
    task.delay(0.4, function() stopWalkFling() dropRunning = false end)
end

-- ==========================================================
-- === INSTA GRAB AUTO STEAL
-- ==========================================================
local stealActive = true
local stealConn = nil
local animalCache = {}
local promptCache = {}
local stealCache = {}
local isStealing = false
local STEAL_R = 7

local AnimalsData = {}
pcall(function()
    local rep = game:GetService("ReplicatedStorage")
    local datas = rep:FindFirstChild("Datas")
    if datas then
        local animals = datas:FindFirstChild("Animals")
        if animals then AnimalsData = require(animals) end
    end
end)

local function stealHRP()
    local c = lp.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots and workspace.Plots:FindFirstChild(plotName); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign"); if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
    for _, pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local name = "Unknown"
            local spawn = pod.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        name = child.Name
                        local info = AnimalsData[name]
                        if info and info.DisplayName then name = info.DisplayName end
                        break
                    end
                end
            end
            table.insert(animalCache, {
                name = name, plot = plot.Name, slot = pod.Name,
                worldPosition = pod:GetPivot().Position,
                uid = plot.Name .. "_" .. pod.Name,
            })
        end
    end
end

local function findPrompt(ad)
    if not ad then return nil end
    local cp = promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    local plot = plots:FindFirstChild(ad.plot); if not plot then return nil end
    local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return nil end
    local pod = pods:FindFirstChild(ad.slot); if not pod then return nil end
    local base = pod:FindFirstChild("Base"); if not base then return nil end
    local sp = base:FindFirstChild("Spawn"); if not sp then return nil end
    local att = sp:FindFirstChild("PromptAttachment"); if not att then return nil end
    for _, p in ipairs(att:GetChildren()) do
        if p:IsA("ProximityPrompt") then promptCache[ad.uid] = p; return p end
    end
end

local function buildCallbacks(prompt)
    if stealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then stealCache[prompt] = data end
end

local function execSteal(prompt)
    local data = stealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; isStealing = true
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01); data.ready = true; task.wait(0.01); isStealing = false
    end)
    return true
end

local function nearestAnimal()
    local h = stealHRP(); if not h then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(animalCache) do
        if not isMyBase(ad.plot) and ad.worldPosition then
            local d = (h.Position - ad.worldPosition).Magnitude
            if d < bestD then bestD = d; best = ad end
        end
    end
    return best
end

local function startStealLoop()
    if stealConn then stealConn:Disconnect() end
    stealConn = RunService.Heartbeat:Connect(function()
        if not stealActive or isStealing then return end
        local target = nearestAnimal(); if not target then return end
        local h = stealHRP(); if not h then return end
        if (h.Position - target.worldPosition).Magnitude > STEAL_R then return end
        local prompt = promptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = findPrompt(target) end
        if prompt then buildCallbacks(prompt); execSteal(prompt) end
    end)
end

local stealInitialized = false
local function initSteal()
    if stealInitialized then return end
    stealInitialized = true
    task.spawn(function()
        task.wait(2)
        local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
        plots.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end
        end)
        task.spawn(function()
            while task.wait(5) do
                animalCache = {}
                for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
            end
        end)
    end)
    startStealLoop()
end

-- ==========================================================
-- === UNIFIED AUTO PLAY DISPATCHER
-- ==========================================================
local sideToggles = {}

local function stopAutoLeft()
    auto1 = false
    if patrolMode == "left" then patrolMode = "none" end
end

local function stopAutoRight()
    auto2 = false
    if patrolMode == "right" then patrolMode = "none" end
end

local function runAutoLeft()
    if autoPlayVersion == 1 then
        auto1 = true
        task.spawn(function()
            go(A1_P1, SPEED_IDA,   function() return auto1 end)
            go(A1_P2, SPEED_IDA,   function() return auto1 end)
            go(A1_P3, SPEED_VOLTA, function() return auto1 end)
            go(A1_P4, SPEED_VOLTA, function() return auto1 end)
            auto1 = false
            if toggles["Auto Play Left"] then toggles["Auto Play Left"].update(false) end
            if sideToggles["Auto Play Left"] then sideToggles["Auto Play Left"](false) end
        end)
    else
        patrolMode = "left"; currentWaypoint = 1
    end
end

local function runAutoRight()
    if autoPlayVersion == 1 then
        auto2 = true
        task.spawn(function()
            go(B1, SPEED_IDA,   function() return auto2 end)
            go(B2, SPEED_IDA,   function() return auto2 end)
            go(B3, SPEED_VOLTA, function() return auto2 end)
            go(B4, SPEED_VOLTA, function() return auto2 end)
            auto2 = false
            if toggles["Auto Play Right"] then toggles["Auto Play Right"].update(false) end
            if sideToggles["Auto Play Right"] then sideToggles["Auto Play Right"](false) end
        end)
    else
        patrolMode = "right"; currentWaypoint = 1
    end
end

-- === DROP BUTTON GUI ===
local dropGui = Instance.new("ScreenGui", CoreGui)
dropGui.Name = "DropButtonGui"; dropGui.Enabled = false; dropGui.ResetOnSpawn = false

local dropBtn = Instance.new("TextButton", dropGui)
dropBtn.Size = UDim2.new(0, 90, 0, 36); dropBtn.Position = UDim2.new(0.5, -45, 0.2, 0)
dropBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); dropBtn.Text = "Drop"
dropBtn.TextColor3 = Color3.new(1, 1, 1); dropBtn.Font = Enum.Font.GothamBold; dropBtn.TextSize = 14; dropBtn.Active = true
makeDraggable(dropBtn)
Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 8)
local dropStroke = Instance.new("UIStroke", dropBtn)
dropStroke.Thickness = 1.5; dropStroke.Color = Color3.fromRGB(0, 220, 255); dropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dropBtn.MouseButton1Click:Connect(function()
    triggerDrop()
    dropBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    task.delay(0.2, function() dropBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) end)
end)

-- === SIDE MENU (MOBILE BUTTONS) ===
local sideGui = Instance.new("ScreenGui", CoreGui)
sideGui.Name = "AsserSideMenuGui"; sideGui.Enabled = false; sideGui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame", sideGui)
menuFrame.Size = UDim2.new(0, 180, 0, 210); menuFrame.Position = UDim2.new(1, -200, 0.1, 0); menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder; menuLayout.Padding = UDim.new(0, 10)

local function createSideButton(text, order, callback)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(1, 0, 0, 45); btn.BackgroundColor3 = Color3.fromRGB(0, 25, 70)
    btn.BorderSizePixel = 0; btn.LayoutOrder = order; btn.Text = "  "..text
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5; stroke.Color = Color3.fromRGB(0, 188, 255); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 10, 0, 10); indicator.Position = UDim2.new(1, -20, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    local active = false
    local function setVisual(state)
        active = state
        TweenService:Create(btn,       TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 25, 70)}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(15, 15, 15)}):Play()
    end
    btn.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        setVisual(active)
        if toggles[text] then uiStates[text] = active toggles[text].update(active) end
    end)
    sideToggles[text] = setVisual
    return btn, indicator
end

local function cancelAutoPlays()
    stopAutoLeft(); stopAutoRight()
    if sideToggles["Auto Play Left"]  then sideToggles["Auto Play Left"](false)   end
    if toggles["Auto Play Left"]      then toggles["Auto Play Left"].update(false)  end
    if sideToggles["Auto Play Right"] then sideToggles["Auto Play Right"](false)  end
    if toggles["Auto Play Right"]     then toggles["Auto Play Right"].update(false) end
    uiStates["Auto Play Left"]  = false
    uiStates["Auto Play Right"] = false
end

createSideButton("Auto Play Right", 1, function(v)
    if v then
        stopAutoLeft()
        if sideToggles["Auto Play Left"] then sideToggles["Auto Play Left"](false) end
        if toggles["Auto Play Left"] then toggles["Auto Play Left"].update(false) end
        uiStates["Auto Play Left"] = false
        runAutoRight()
    else stopAutoRight() end
end)

createSideButton("Auto Play Left", 2, function(v)
    if v then
        stopAutoRight()
        if sideToggles["Auto Play Right"] then sideToggles["Auto Play Right"](false) end
        if toggles["Auto Play Right"] then toggles["Auto Play Right"].update(false) end
        uiStates["Auto Play Right"] = false
        runAutoLeft()
    else stopAutoLeft() end
end)

createSideButton("Lock in", 3, function(v)
    toggleFloat(v)
    if v then cancelAutoPlays() end
end)

local dropBtnSide, dropIndicator = createSideButton("Drop", 4, function() end)
dropBtnSide.MouseButton1Click:Connect(function()
    cancelAutoPlays()
    if floaton then
        toggleFloat(false)
        if sideToggles["Lock in"] then sideToggles["Lock in"](false) end
        if toggles["Lock in"] then toggles["Lock in"].update(false) end
    end
    triggerDrop()
    dropBtnSide.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    dropIndicator.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    task.delay(0.5, function()
        dropBtnSide.BackgroundColor3 = Color3.fromRGB(0, 25, 70)
        dropIndicator.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    end)
end)

-- === MAIN UI SETUP ===
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AsserDuels"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 320); main.Position = UDim2.new(0.6, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 25, 70); main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 1.5; mainStroke.Color = Color3.fromRGB(0, 188, 255); mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 40); topBar.BackgroundColor3 = Color3.fromRGB(0, 45, 120); topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(1, -110, 1, 0); titleLbl.Position = UDim2.new(0, 15, 0, 0); titleLbl.Text = "Asser Duels"
titleLbl.BackgroundTransparency = 1; titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255); titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 16; titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local discBtn = Instance.new("TextButton", topBar)
discBtn.Size = UDim2.new(0, 70, 0, 24); discBtn.Position = UDim2.new(1, -85, 0.5, -12)
discBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); discBtn.Text = "Discord"; discBtn.TextColor3 = Color3.new(1, 1, 1); discBtn.Font = Enum.Font.GothamBold; discBtn.TextSize = 11
Instance.new("UICorner", discBtn).CornerRadius = UDim.new(0, 6)
discBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("https://discord.gg/NT6FtYuYG5") end
    discBtn.Text = "Copied!"; discBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    task.wait(1.5); discBtn.Text = "Discord"; discBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
end)

makeDraggable(main)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -95); scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 188, 255)

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

local function makeToggleBtn(txt, callback)
    uiCallbacks[txt] = callback; uiStates[txt] = false
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, -5, 0, 40); frame.BackgroundColor3 = Color3.fromRGB(0, 35, 95); frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = txt
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 34, 0, 20); toggle.Position = UDim2.new(1, -44, 0, 10); toggle.BackgroundColor3 = Color3.fromRGB(0, 15, 50); toggle.Text = ""
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = UDim2.new(0, 3, 0, 3); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local function updateVisual(active)
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 15, 50)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
    end
    toggle.MouseButton1Click:Connect(function()
        uiStates[txt] = not uiStates[txt]
        callback(uiStates[txt])
        updateVisual(uiStates[txt])
        if sideToggles[txt] then sideToggles[txt](uiStates[txt]) end
    end)
    return {frame = frame, update = updateVisual}
end

toggles["Auto Play Left"] = makeToggleBtn("Auto Play Left", function(v)
    if v then
        if uiStates["Auto Play Right"] then
            uiStates["Auto Play Right"] = false; stopAutoRight()
            if toggles["Auto Play Right"] then toggles["Auto Play Right"].update(false) end
            if sideToggles["Auto Play Right"] then sideToggles["Auto Play Right"](false) end
        end
        runAutoLeft()
    else stopAutoLeft() end
end)

toggles["Auto Play Right"] = makeToggleBtn("Auto Play Right", function(v)
    if v then
        if uiStates["Auto Play Left"] then
            uiStates["Auto Play Left"] = false; stopAutoLeft()
            if toggles["Auto Play Left"] then toggles["Auto Play Left"].update(false) end
            if sideToggles["Auto Play Left"] then sideToggles["Auto Play Left"](false) end
        end
        runAutoRight()
    else stopAutoRight() end
end)

toggles["Infinite Jump"]            = makeToggleBtn("Infinite Jump",            function(v) infinityJumpEnabled = v end)
toggles["Drop Button"]              = makeToggleBtn("Drop Button",              function(v) dropGui.Enabled = v end)
toggles["Mobile Buttons"]           = makeToggleBtn("Mobile Buttons",           function(v) sideGui.Enabled = v end)
toggles["Anti Ragdoll & Knockback"] = makeToggleBtn("Anti Ragdoll & Knockback", function(v) toggleAntiRagdoll(v) end)
toggles["Lock in"]                  = makeToggleBtn("Lock in",                  function(v) toggleFloat(v) if v then cancelAutoPlays() end end)

-- ✅ Unwalk Animation toggle added to main UI
toggles["Unwalk Animation"] = makeToggleBtn("Unwalk Animation", function(v)
    if v then enableUnwalk() else disableUnwalk() end
end)

local botBar = Instance.new("Frame", main)
botBar.Size = UDim2.new(1, 0, 0, 40); botBar.Position = UDim2.new(0, 0, 1, -40); botBar.BackgroundTransparency = 1
local saveBtn = Instance.new("TextButton", botBar)
saveBtn.Size = UDim2.new(1, -20, 0, 28); saveBtn.Position = UDim2.new(0, 10, 0.5, -14)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); saveBtn.Text = "Save Config"; saveBtn.TextColor3 = Color3.new(1, 1, 1); saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 12
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

-- === SPEED BILLBOARD ===
if CoreGui:FindFirstChild("CH_SpeedDisplay") then CoreGui.CH_SpeedDisplay:Destroy() end
local speedBillboard = Instance.new("BillboardGui")
speedBillboard.Name = "CH_SpeedDisplay"
speedBillboard.Size = UDim2.new(0, 90, 0, 26)
speedBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
speedBillboard.AlwaysOnTop = true
speedBillboard.ResetOnSpawn = false
local speedLabel = Instance.new("TextLabel", speedBillboard)
speedLabel.Size = UDim2.new(1, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 20
speedLabel.Text = "0 sp"
speedLabel.TextStrokeTransparency = 0
speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local function attachToCharacter(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if root then speedBillboard.Adornee = root; speedBillboard.Parent = CoreGui end
end

lp.CharacterAdded:Connect(function(newChar) task.wait(0.5); attachToCharacter(newChar) end)
RunService.RenderStepped:Connect(function()
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        speedLabel.Text = math.floor(char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude) .. " sp"
    end
end)
if lp.Character then attachToCharacter(lp.Character) end

-- === ASSER HELPER UI ===
local speedGui = Instance.new("ScreenGui", CoreGui)
speedGui.Name = "SpeedConfigGui"; speedGui.ResetOnSpawn = false

local HELPER_FULL_H = 260
local speedMain = Instance.new("Frame", speedGui)
speedMain.Size = UDim2.new(0, 180, 0, HELPER_FULL_H)
speedMain.Position = UDim2.new(0.1, 0, 0.2, 0)
speedMain.BackgroundColor3 = Color3.fromRGB(0, 25, 70); speedMain.BorderSizePixel = 0; speedMain.ClipsDescendants = true
Instance.new("UICorner", speedMain).CornerRadius = UDim.new(0, 10)
local speedStroke = Instance.new("UIStroke", speedMain)
speedStroke.Thickness = 1.5; speedStroke.Color = Color3.fromRGB(0, 188, 255); speedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
makeDraggable(speedMain)

local speedTitle = Instance.new("TextLabel", speedMain)
speedTitle.Size = UDim2.new(1, 0, 0, 30); speedTitle.BackgroundColor3 = Color3.fromRGB(0, 45, 120)
speedTitle.Text = "Asser helper"; speedTitle.TextColor3 = Color3.new(1, 1, 1); speedTitle.Font = Enum.Font.GothamBold; speedTitle.TextSize = 10
Instance.new("UICorner", speedTitle).CornerRadius = UDim.new(0, 10)

local expandBtn = Instance.new("TextButton", speedTitle)
expandBtn.Size = UDim2.new(0, 20, 0, 20); expandBtn.Position = UDim2.new(1, -25, 0.5, -10)
expandBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); expandBtn.Text = "-"; expandBtn.TextColor3 = Color3.new(1, 1, 1); expandBtn.Font = Enum.Font.GothamBold; expandBtn.TextSize = 14
Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0, 5)

local isShrunk = false
expandBtn.MouseButton1Click:Connect(function()
    isShrunk = not isShrunk
    TweenService:Create(speedMain, TweenInfo.new(0.2), {Size = UDim2.new(0, 180, 0, isShrunk and 30 or HELPER_FULL_H)}):Play()
    expandBtn.Text = isShrunk and "+" or "-"
end)

local function createSpeedBox(label, defaultVal, maxAllowed, posY, callback)
    local lbl2 = Instance.new("TextLabel", speedMain)
    lbl2.Size = UDim2.new(0, 100, 0, 30); lbl2.Position = UDim2.new(0, 10, 0, posY); lbl2.Text = label
    lbl2.BackgroundTransparency = 1; lbl2.TextColor3 = Color3.new(1, 1, 1); lbl2.Font = Enum.Font.GothamMedium; lbl2.TextSize = 10; lbl2.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", speedMain)
    box.Size = UDim2.new(0, 50, 0, 24); box.Position = UDim2.new(1, -60, 0, posY + 3)
    box.BackgroundColor3 = Color3.fromRGB(0, 15, 50); box.Text = tostring(defaultVal); box.TextColor3 = Color3.new(1, 1, 1); box.Font = Enum.Font.GothamBold; box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", box).Color = Color3.fromRGB(0, 188, 255)
    local last = defaultVal
    box.FocusLost:Connect(function()
        local raw = box.Text:gsub("%s+", "")
        local num = tonumber(raw)
        if not raw or raw == "" or not num or num <= 0 then box.Text = tostring(last) callback(last) return end
        if num > maxAllowed then num = maxAllowed end
        last = num; box.Text = tostring(num); callback(num)
    end)
end

createSpeedBox("Speed Going:",   57, 61,  37, function(v) SPEED_IDA   = v end)
createSpeedBox("Speed Coming:",  29, 31,  70, function(v) SPEED_VOLTA = v end)
createSpeedBox("Lock in Speed:", 57, 61, 103, function(v) floatSpeed  = v end)

local floatActionBtn = Instance.new("TextButton", speedMain)
floatActionBtn.Size = UDim2.new(0, 160, 0, 30); floatActionBtn.Position = UDim2.new(0, 10, 0, 136)
floatActionBtn.BackgroundColor3 = Color3.fromRGB(0, 15, 50); floatActionBtn.Text = "Float: OFF"
floatActionBtn.TextColor3 = Color3.new(1, 1, 1); floatActionBtn.Font = Enum.Font.GothamBold; floatActionBtn.TextSize = 11
Instance.new("UICorner", floatActionBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", floatActionBtn).Color = Color3.fromRGB(0, 188, 255)
floatActionBtn.MouseButton1Click:Connect(function()
    asserFloating = not asserFloating
    floatActionBtn.Text = asserFloating and "Float: ON" or "Float: OFF"
    floatActionBtn.BackgroundColor3 = asserFloating and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 15, 50)
end)

local tpDivider = Instance.new("TextLabel", speedMain)
tpDivider.Size = UDim2.new(1, -20, 0, 20); tpDivider.Position = UDim2.new(0, 10, 0, 178)
tpDivider.BackgroundTransparency = 1; tpDivider.Text = "— Duels TP —"
tpDivider.TextColor3 = Color3.fromRGB(0, 188, 255); tpDivider.Font = Enum.Font.GothamBold; tpDivider.TextSize = 10

local duelsTpBtn = Instance.new("TextButton", speedMain)
duelsTpBtn.Size = UDim2.new(0, 160, 0, 34); duelsTpBtn.Position = UDim2.new(0, 10, 0, 202)
duelsTpBtn.BackgroundColor3 = Color3.fromRGB(0, 15, 50); duelsTpBtn.Text = "Enable Duels TP"
duelsTpBtn.TextColor3 = Color3.new(1, 1, 1); duelsTpBtn.Font = Enum.Font.GothamBold; duelsTpBtn.TextSize = 11
duelsTpBtn.BorderSizePixel = 0
Instance.new("UICorner", duelsTpBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", duelsTpBtn).Color = Color3.fromRGB(0, 188, 255)
duelsTpBtn.MouseButton1Click:Connect(function()
    duelsTpEnabled = not duelsTpEnabled
    duelsTpBtn.Text = duelsTpEnabled and "Disable Duels TP" or "Enable Duels TP"
    duelsTpBtn.BackgroundColor3 = duelsTpEnabled and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 15, 50)
end)

-- === SAVE / LOAD ===
local configFolder = "AsserDuels"
local configFile   = configFolder.."/config.json"

local function saveConfig()
    if writefile then
        if not isfolder(configFolder) then makefolder(configFolder) end
        uiStates["SpeedGoing"]  = SPEED_IDA
        uiStates["SpeedComing"] = SPEED_VOLTA
        uiStates["LockInSpeed"] = floatSpeed
        writefile(configFile, HttpService:JSONEncode(uiStates))
    end
end

local function loadConfig()
    if isfile and isfile(configFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(configFile)) end)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                uiStates[k] = v
                if uiCallbacks[k] then uiCallbacks[k](v) end
                if toggles[k]    then toggles[k].update(v) end
                if sideToggles[k] then sideToggles[k](v) end
            end
            if data["SpeedGoing"]  then SPEED_IDA   = data["SpeedGoing"]  end
            if data["SpeedComing"] then SPEED_VOLTA  = data["SpeedComing"] end
            if data["LockInSpeed"] then floatSpeed   = data["LockInSpeed"] end
        end
    end
end

saveBtn.MouseButton1Click:Connect(function()
    saveConfig(); saveBtn.Text = "Saved!"; task.wait(1); saveBtn.Text = "Save Config"
end)

-- === MENU TOGGLE BUTTON ===
local toggleGui = Instance.new("ScreenGui", CoreGui)
toggleGui.Name = "MenuToggleButtonGui"; toggleGui.ResetOnSpawn = false
local toggleBtn = Instance.new("TextButton", toggleGui)
toggleBtn.Size = UDim2.new(0, 60, 0, 60); toggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); toggleBtn.Text = "Asser\nDuels"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0); toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 11
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleBtn).Color = Color3.fromRGB(255, 255, 255)
makeDraggable(toggleBtn)
local menuOpen = true
toggleBtn.MouseButton1Click:Connect(function() menuOpen = not menuOpen main.Visible = menuOpen end)

-- === ASSER AUTO PLAY VERSION UI ===
local apGui = Instance.new("ScreenGui", CoreGui)
apGui.Name = "AsserAutoPlayGui"; apGui.ResetOnSpawn = false

local apMain = Instance.new("Frame", apGui)
apMain.Size = UDim2.new(0, 200, 0, 115); apMain.Position = UDim2.new(0.5, -100, 0.05, 0)
apMain.BackgroundColor3 = Color3.fromRGB(0, 20, 60); apMain.BorderSizePixel = 0; apMain.ClipsDescendants = true
Instance.new("UICorner", apMain).CornerRadius = UDim.new(0, 10)
local apStroke = Instance.new("UIStroke", apMain)
apStroke.Thickness = 1.5; apStroke.Color = Color3.fromRGB(0, 188, 255); apStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
makeDraggable(apMain)

local apTitleBar = Instance.new("Frame", apMain)
apTitleBar.Size = UDim2.new(1, 0, 0, 30); apTitleBar.BackgroundColor3 = Color3.fromRGB(0, 45, 120); apTitleBar.BorderSizePixel = 0
Instance.new("UICorner", apTitleBar).CornerRadius = UDim.new(0, 10)

local apTitle = Instance.new("TextLabel", apTitleBar)
apTitle.Size = UDim2.new(1, -40, 1, 0); apTitle.Position = UDim2.new(0, 10, 0, 0); apTitle.BackgroundTransparency = 1
apTitle.Text = "Asser Auto Play version"; apTitle.TextColor3 = Color3.fromRGB(255, 255, 255); apTitle.Font = Enum.Font.GothamBold; apTitle.TextSize = 10; apTitle.TextXAlignment = Enum.TextXAlignment.Left

local apToggleBtn = Instance.new("TextButton", apTitleBar)
apToggleBtn.Size = UDim2.new(0, 22, 0, 22); apToggleBtn.Position = UDim2.new(1, -27, 0.5, -11)
apToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); apToggleBtn.Text = "-"; apToggleBtn.TextColor3 = Color3.new(1, 1, 1); apToggleBtn.Font = Enum.Font.GothamBold; apToggleBtn.TextSize = 14; apToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", apToggleBtn).CornerRadius = UDim.new(0, 5)

local apShrunk = false
apToggleBtn.MouseButton1Click:Connect(function()
    apShrunk = not apShrunk
    TweenService:Create(apMain, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, apShrunk and 30 or 115)}):Play()
    apToggleBtn.Text = apShrunk and "+" or "-"
end)

local apContent = Instance.new("Frame", apMain)
apContent.Size = UDim2.new(1, 0, 1, -30); apContent.Position = UDim2.new(0, 0, 0, 30); apContent.BackgroundTransparency = 1

local function makeApBtn(label, posY)
    local b = Instance.new("TextButton", apContent)
    b.Size = UDim2.new(1, -20, 0, 32); b.Position = UDim2.new(0, 10, 0, posY)
    b.BackgroundColor3 = Color3.fromRGB(0, 120, 255); b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.Text = label; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2; bs.Color = Color3.fromRGB(0, 220, 255)
    return b
end

local apV1Btn = makeApBtn("Auto Play v1  ✔", 5)
local apV2Btn = makeApBtn("Auto Play v2",    45)

local function setApVisual(v1Active)
    if v1Active then
        apV1Btn.BackgroundColor3 = Color3.fromRGB(0, 160, 80);  apV1Btn.Text = "Auto Play v1  ✔"
        apV2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); apV2Btn.Text = "Auto Play v2"
    else
        apV2Btn.BackgroundColor3 = Color3.fromRGB(0, 160, 80);  apV2Btn.Text = "Auto Play v2  ✔"
        apV1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); apV1Btn.Text = "Auto Play v1"
    end
end

local function switchToV1()
    autoPlayVersion = 1; patrolMode = "none"
    cancelAutoPlays(); setApVisual(true)
end

local function switchToV2()
    autoPlayVersion = 2; auto1 = false; auto2 = false
    cancelAutoPlays(); setApVisual(false)
end

apV1Btn.MouseButton1Click:Connect(function() if autoPlayVersion ~= 1 then switchToV1() end end)
apV2Btn.MouseButton1Click:Connect(function() if autoPlayVersion ~= 2 then switchToV2() end end)

setApVisual(true)

loadConfig()
initializeAutomaticHitboxes()
initSteal()

task.spawn(function()
    task.wait(1)
    showNotification("Insta grab is Automatically On")
end)

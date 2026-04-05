"if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)
pcall(function() if setfpscap then setfpscap(9999) end end)
local privateBuild = false

local SharedState = {
    ConveyorAnimals = {},
    BestConveyorGv = -1,
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
}

do

    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched += 1
                    end
                end
            end
        end
    end
    print("bullys hub NAO E SOURCE DO LETHAL")
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local IS_MOBILE = isMobile()


local FileName = "XisPublic_v1.json" 
local DefaultConfig = {
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        MobileControls = {X = 0.9, Y = 0.4},
        MobileBtn_TP = {X = 0.5, Y = 0.4},
        MobileBtn_CL = {X = 0.5, Y = 0.4},
        MobileBtn_SP = {X = 0.5, Y = 0.4},
        MobileBtn_IV = {X = 0.5, Y = 0.4},
        MobileBtn_UI = {X = 0.5, Y = 0.4},
        JobJoiner = {X = 0.5, Y = 0.85},
        AutoBuy   = {X = 0.01, Y = 0.35},
    }, 
    TpSettings = {
        Tool           = "Flying Carpet",
        Speed          = 2, 
        TpKey          = "T",
        CloneKey       = "V",
        TpOnLoad       = false,
        MinGenForTp    = "",
        CarpetSpeedKey = "Q",
        InfiniteJump   = false,
    },
    StealSpeed   = 20,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = true,
    PlayerESP    = true,
    FPSBoost     = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    ReturnToBrainrot = true,
    FloatEnabled = false,
    FloatKey = "F",
    ShowStealingHUD = true,
    DesyncVisualizer = false,
    ConveyorESP = false,
    AutoBackToBrainrot = false,
    PriorityList = {},
    DefaultToDisable = false,
    UILocked     = false,
    HideAdminPanel = false,
    HideAutoSteal = false,
    CompactAutoSteal = false,
    AutoKickOnSteal = false,
    InstantSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    DisableClickToAPOnMoby = false,
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    AutoResetOnBalloon = false,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    AutoTurretOnBrainrot = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = true,
    AutoTPOnFailedSteal = false,
    AutoTPPriority = true,
    KickKey = "",
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    DuelBaseESP = true,
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    DisableProximitySpamOnMoby = false,
    DisableClickToAPOnKawaifu = false,
    DisableProximitySpamOnKawaifu = false,
    HideKawaifuFromPanel = false,
    AutoStealSpeed = false,
    ShowJobJoiner = true,
    JobJoinerKey = "J",
    CurrentTheme = "rosa",
    ShowMiniActions = true,
    AutoHideMiniUI = false,
    MiniUIPos = {X = 0.01, Y = 0.35},
    MiniUILocked = false,
    Blacklist = {},
    BlacklistESP = true,
    BlacklistMsg = "BLOCKED",
    AutoBuyEnabled = false,
    AutoBuyKey = "K",
    AutoBuyRange = 17,
    AutoBuyColor = {R=0, G=220, B=255},
    HideAutoBuyUI = false,
    HideStealSpeedUI = false,
    HideStatusHUD = false,
    HideInvisPanel = false,
    HidePlatformUI = false,
    PlatformOffset = 12.5,
    PlatformTime = 10,
    UltraLightMode = false,
}


local Config = DefaultConfig

if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
        if type(decoded.Blacklist) ~= "table" then decoded.Blacklist = {} end
        Config = decoded
    end)
end
Config.ProximityAP = false

-- Aplica tema imediatamente nos valores da tabela Theme
-- (antes das UIs serem construidas, para que ja usem as cores certas)
if Config.CurrentTheme and THEMES and THEMES[Config.CurrentTheme] then
    for k, v in pairs(THEMES[Config.CurrentTheme]) do Theme[k] = v end
end

local function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do toSave[k] = v end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

local function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end

local HighlightName = "KaWaifu_NeonHighlight"
local function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
    _G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false

local function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = getControls()

local function kickPlayer()
    pcall(function()
        TeleportService:Teleport(1818, LocalPlayer)
    end)
    pcall(function()
        LocalPlayer:Kick("\BULLYS HUB - macaco prego <3")
    end)
end

local function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end


local function instantClone()
    if _G.isCloning then return end
    _G.isCloning = true

    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end

        local cloner =
            LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or char:FindFirstChild("Quantum Cloner")

        if not cloner then error("No Quantum Cloner") end

        pcall(function()
            hum:EquipTool(cloner)
        end)

        task.wait(0.05)

        cloner:Activate()
        task.wait(0.05)

        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.1)
        end

        if not Workspace:FindFirstChild(cloneName) then
            error("")
        end

        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if not tpButton then error("Teleport button missing") end

        tpButton.Visible = true

        if firesignal then
            firesignal(tpButton.MouseButton1Up)
        else
            local vim = cloneref and cloneref(game:GetService("VirtualInputManager")) or VirtualInputManager
            local inset = (cloneref and cloneref(game:GetService("GuiService")) or GuiService):GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset

            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end
    end)

    _G.isCloning = false
end

local function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 5

    local bestPromptSameLevel = nil
    local shortestDistSameLevel = math.huge

    local bestPromptFallback = nil
    local shortestDistFallback = math.huge
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, obj in ipairs(plots:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if maxY and part.Position.Y > maxY then
                else
                    local distance = (hrp.Position - part.Position).Magnitude
                    local yDifference = math.abs(playerY - part.Position.Y)

                    if distance < shortestDistFallback then
                        shortestDistFallback = distance
                        bestPromptFallback = obj
                    end

                    if yDifference <= Y_THRESHOLD then
                        if distance < shortestDistSameLevel then
                            shortestDistSameLevel = distance
                            bestPromptSameLevel = obj
                        end
                    end
                end
            end
        end
    end

    local targetPrompt = bestPromptSameLevel or bestPromptFallback

    if targetPrompt then
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        else
            targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end

local Theme = {
    Background      = Color3.fromRGB(20, 15, 20),   -- fundo escuro com tom rosa
    Surface         = Color3.fromRGB(35, 25, 35),   -- caixas
    SurfaceHighlight= Color3.fromRGB(50, 35, 50),   -- highlight

    Accent1         = Color3.fromRGB(255, 120, 200), -- rosa claro
    Accent2         = Color3.fromRGB(255, 70, 170),  -- rosa principal

    TextPrimary     = Color3.fromRGB(255, 240, 250),
    TextSecondary   = Color3.fromRGB(200, 160, 190),

    Success         = Color3.fromRGB(255, 120, 200), -- botÃµes ON
    Error           = Color3.fromRGB(255, 90, 140),  -- erro
}

-- ============================================================
-- SISTEMA DE TEMAS - sem `local` no top-level para nao exceder 200 locals
-- ============================================================
THEMES = {
    rosa = {
        Background       = Color3.fromRGB(20, 15, 20),
        Surface          = Color3.fromRGB(35, 25, 35),
        SurfaceHighlight = Color3.fromRGB(50, 35, 50),
        Accent1          = Color3.fromRGB(255, 120, 200),
        Accent2          = Color3.fromRGB(255, 70, 170),
        TextPrimary      = Color3.fromRGB(255, 240, 250),
        TextSecondary    = Color3.fromRGB(200, 160, 190),
        Success          = Color3.fromRGB(255, 120, 200),
        Error            = Color3.fromRGB(255, 90, 140),
        GlowColor1       = Color3.fromRGB(255, 120, 200),
        GlowColor2       = Color3.fromRGB(255, 70, 170),
    },
    ciano = {
        Background       = Color3.fromRGB(5, 18, 25),
        Surface          = Color3.fromRGB(10, 30, 40),
        SurfaceHighlight = Color3.fromRGB(15, 45, 58),
        Accent1          = Color3.fromRGB(0, 220, 255),
        Accent2          = Color3.fromRGB(0, 170, 230),
        TextPrimary      = Color3.fromRGB(220, 248, 255),
        TextSecondary    = Color3.fromRGB(140, 210, 230),
        Success          = Color3.fromRGB(0, 220, 255),
        Error            = Color3.fromRGB(255, 80, 120),
        GlowColor1       = Color3.fromRGB(0, 220, 255),
        GlowColor2       = Color3.fromRGB(0, 170, 230),
    },
    dourado = {
        Background       = Color3.fromRGB(15, 12, 5),
        Surface          = Color3.fromRGB(28, 22, 8),
        SurfaceHighlight = Color3.fromRGB(42, 33, 12),
        Accent1          = Color3.fromRGB(255, 215, 0),
        Accent2          = Color3.fromRGB(218, 165, 32),
        TextPrimary      = Color3.fromRGB(255, 245, 210),
        TextSecondary    = Color3.fromRGB(200, 170, 100),
        Success          = Color3.fromRGB(255, 215, 0),
        Error            = Color3.fromRGB(255, 90, 80),
        GlowColor1       = Color3.fromRGB(255, 215, 0),
        GlowColor2       = Color3.fromRGB(218, 165, 32),
    },
    prata = {
        Background       = Color3.fromRGB(12, 12, 18),
        Surface          = Color3.fromRGB(24, 24, 34),
        SurfaceHighlight = Color3.fromRGB(36, 36, 50),
        Accent1          = Color3.fromRGB(210, 215, 235),
        Accent2          = Color3.fromRGB(150, 155, 175),
        TextPrimary      = Color3.fromRGB(240, 240, 255),
        TextSecondary    = Color3.fromRGB(170, 170, 195),
        Success          = Color3.fromRGB(210, 215, 235),
        Error            = Color3.fromRGB(255, 90, 110),
        GlowColor1       = Color3.fromRGB(210, 215, 235),
        GlowColor2       = Color3.fromRGB(150, 155, 175),
    },
    preto = {
        Background       = Color3.fromRGB(4, 4, 6),
        Surface          = Color3.fromRGB(12, 12, 16),
        SurfaceHighlight = Color3.fromRGB(22, 22, 28),
        Accent1          = Color3.fromRGB(200, 200, 210),
        Accent2          = Color3.fromRGB(110, 110, 125),
        TextPrimary      = Color3.fromRGB(230, 230, 240),
        TextSecondary    = Color3.fromRGB(140, 140, 155),
        Success          = Color3.fromRGB(200, 200, 210),
        Error            = Color3.fromRGB(255, 70, 90),
        GlowColor1       = Color3.fromRGB(200, 200, 210),
        GlowColor2       = Color3.fromRGB(110, 110, 125),
    },
    roxo = {
        Background       = Color3.fromRGB(10, 5, 20),
        Surface          = Color3.fromRGB(22, 12, 40),
        SurfaceHighlight = Color3.fromRGB(35, 18, 60),
        Accent1          = Color3.fromRGB(180, 80, 255),
        Accent2          = Color3.fromRGB(130, 40, 210),
        TextPrimary      = Color3.fromRGB(240, 225, 255),
        TextSecondary    = Color3.fromRGB(170, 130, 210),
        Success          = Color3.fromRGB(180, 80, 255),
        Error            = Color3.fromRGB(255, 80, 120),
        GlowColor1       = Color3.fromRGB(180, 80, 255),
        GlowColor2       = Color3.fromRGB(130, 40, 210),
    },
    verde = {
        Background       = Color3.fromRGB(5, 15, 8),
        Surface          = Color3.fromRGB(10, 28, 14),
        SurfaceHighlight = Color3.fromRGB(15, 42, 20),
        Accent1          = Color3.fromRGB(0, 220, 80),
        Accent2          = Color3.fromRGB(0, 170, 60),
        TextPrimary      = Color3.fromRGB(220, 255, 230),
        TextSecondary    = Color3.fromRGB(130, 200, 150),
        Success          = Color3.fromRGB(0, 220, 80),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(0, 220, 80),
        GlowColor2       = Color3.fromRGB(0, 170, 60),
    },
    laranja = {
        Background       = Color3.fromRGB(15, 8, 3),
        Surface          = Color3.fromRGB(28, 15, 6),
        SurfaceHighlight = Color3.fromRGB(42, 22, 8),
        Accent1          = Color3.fromRGB(255, 140, 0),
        Accent2          = Color3.fromRGB(220, 100, 0),
        TextPrimary      = Color3.fromRGB(255, 240, 220),
        TextSecondary    = Color3.fromRGB(200, 155, 100),
        Success          = Color3.fromRGB(255, 140, 0),
        Error            = Color3.fromRGB(255, 60, 60),
        GlowColor1       = Color3.fromRGB(255, 140, 0),
        GlowColor2       = Color3.fromRGB(220, 100, 0),
    },
    vermelho = {
        Background       = Color3.fromRGB(18, 5, 5),
        Surface          = Color3.fromRGB(32, 10, 10),
        SurfaceHighlight = Color3.fromRGB(50, 16, 16),
        Accent1          = Color3.fromRGB(255, 50, 50),
        Accent2          = Color3.fromRGB(200, 20, 20),
        TextPrimary      = Color3.fromRGB(255, 230, 230),
        TextSecondary    = Color3.fromRGB(200, 140, 140),
        Success          = Color3.fromRGB(255, 50, 50),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(255, 50, 50),
        GlowColor2       = Color3.fromRGB(200, 20, 20),
    },
    cinza = {
        Background       = Color3.fromRGB(15, 15, 18),
        Surface          = Color3.fromRGB(28, 28, 32),
        SurfaceHighlight = Color3.fromRGB(42, 42, 48),
        Accent1          = Color3.fromRGB(160, 160, 180),
        Accent2          = Color3.fromRGB(120, 120, 140),
        TextPrimary      = Color3.fromRGB(230, 230, 235),
        TextSecondary    = Color3.fromRGB(160, 160, 170),
        Success          = Color3.fromRGB(160, 160, 180),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(160, 160, 180),
        GlowColor2       = Color3.fromRGB(120, 120, 140),
    },
}

-- Registros para update ao vivo de cores
_themeRegistry = {}
function TrackColor(element, colorType)
    if not _themeRegistry[colorType] then _themeRegistry[colorType] = {} end
    table.insert(_themeRegistry[colorType], element)
end


function applyTheme(themeName)
    local t = THEMES[themeName]
    if not t then return end

    -- Mapa: cor antiga -> cor nova (para todas as 3 transicoes possiveis)
    local colorMap = {}
    for k, oldColor in pairs(Theme) do
        if t[k] then
            colorMap[oldColor] = t[k]
        end
    end

    -- Atualiza tabela Theme in-place
    for k, v in pairs(t) do
        Theme[k] = v
    end
    Config.CurrentTheme = themeName
    SaveConfig()

    -- Percorre TODOS os descendentes de PlayerGui e substitui as cores
    local function matchColor(c1, c2)
        if not c1 or not c2 then return false end
        local dr = math.abs(c1.R - c2.R)
        local dg = math.abs(c1.G - c2.G)
        local db = math.abs(c1.B - c2.B)
        return (dr + dg + db) < 0.04
    end

    local function remapColor(c)
        if not c then return c end
        for oldC, newC in pairs(colorMap) do
            if matchColor(c, oldC) then return newC end
        end
        return c
    end

    local guiNames = {
        "AutoStealUI", "BullysAdminPanel", "SettingsUI", "StealSpeedUI",
        "BullysInvisPanel", "BullysStatusHUD", "BullysMobileControls", "BullysNotif",
        "BullysThemeUI", "PriorityListGUI", "BullysJobJoiner", "BullysPriorityAlert",
        "BullysSettings", "BullysPlatformUI"
    }

    for _, guiName in ipairs(guiNames) do
        local sg = PlayerGui:FindFirstChild(guiName)
        if sg then
            for _, obj in ipairs(sg:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Frame") or obj:IsA("TextButton") or
                       obj:IsA("TextBox") or obj:IsA("ScrollingFrame") or
                       obj:IsA("ImageLabel") then
                        if obj.BackgroundTransparency < 1 then
                            obj.BackgroundColor3 = remapColor(obj.BackgroundColor3)
                        end
                    end
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                        obj.TextColor3 = remapColor(obj.TextColor3)
                    end
                    if obj:IsA("UIStroke") then
                        obj.Color = remapColor(obj.Color)
                    end
                    if obj:IsA("ScrollingFrame") then
                        obj.ScrollBarImageColor3 = remapColor(obj.ScrollBarImageColor3)
                    end
                    if obj:IsA("UIGradient") then
                        -- atualiza gradient de stroke/frame
                        local kps = obj.Color.Keypoints
                        local changed = false
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            local nc = remapColor(kp.Value)
                            if nc ~= kp.Value then changed = true end
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, nc))
                        end
                        if changed then
                            obj.Color = ColorSequence.new(newKps)
                        end
                    end
                    if obj:IsA("Beam") then
                        local kps = obj.Color.Keypoints
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, remapColor(kp.Value)))
                        end
                        obj.Color = ColorSequence.new(newKps)
                    end
                end)
            end
            -- Frame raiz
            pcall(function()
                local root = sg:FindFirstChildWhichIsA("Frame")
                if root and root.BackgroundTransparency < 1 then
                    root.BackgroundColor3 = remapColor(root.BackgroundColor3)
                end
            end)
        end
    end

    -- Reconstroi nova UI (sincrono, ja com novo tema aplicado)
    task.spawn(function()
        local savedTab  = (_G.BullysSettingsUI and _G.BullysSettingsUI.currentTab) or "act"
        local wasVis    = _G.BullysSettingsUI and _G.BullysSettingsUI.panel and _G.BullysSettingsUI.panel.Visible
        if buildBullysSettingsUI then
            buildBullysSettingsUI()
        end
        task.wait()
        if _G.BullysSettingsUI then
            if _G.BullysSettingsUI.switchTab then
                _G.BullysSettingsUI.switchTab(savedTab)
            end
            if wasVis and _G.BullysSettingsUI.panel then
                _G.BullysSettingsUI.panel.Visible = true
            end
        end
        -- Reconstroi HUD e Mini UI com novas cores
        if _G.rebuildStatusHUD then
            _G.rebuildStatusHUD()
        end
        -- Update auto buy ring color to match new theme
        if _G.updateAutoBuyRingColor then _G.updateAutoBuyRingColor() end
        if _G.rebuildAutoBuyCirclePresets then _G.rebuildAutoBuyCirclePresets() end
        if buildMiniActionsUI then
            local miniWasVis = _G.MiniActionsUI and _G.MiniActionsUI.panel and _G.MiniActionsUI.panel.Visible
            buildMiniActionsUI()
            task.wait()
            if miniWasVis and _G.MiniActionsUI and _G.MiniActionsUI.panel then
                _G.MiniActionsUI.panel.Visible = true
            end
        end

        -- Atualiza racetrack borders com nova cor
        local guisRT = {"AutoStealUI","BullysAdminPanel","SettingsUI","StealSpeedUI","BullysInvisPanel","BullysSettings","BullysStatusHUD","BullysAutoBuyUI"}
        for _, gn in ipairs(guisRT) do
            local sg = PlayerGui:FindFirstChild(gn)
            if sg then
                for _, obj in ipairs(sg:GetDescendants()) do
                    if obj.Name == "RacetrackBorder" and obj:IsA("UIStroke") then
                        local g2 = obj:FindFirstChildOfClass("UIGradient")
                        if g2 then
                            g2.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0,   Theme.Background),
                                ColorSequenceKeypoint.new(0.3, Theme.Accent1),
                                ColorSequenceKeypoint.new(0.5, Theme.Accent2),
                                ColorSequenceKeypoint.new(0.7, Theme.Accent1),
                                ColorSequenceKeypoint.new(1,   Theme.Background),
                            }
                            obj.Color = Theme.Accent1
                        end
                    end
                end
            end
        end
    end)

    ShowNotification("TEMA", "Tema " .. themeName .. " aplicado!")
end

-- Helper: throttle de conexÃµes para evitar limite de 200 upvalues/conexÃµes
function createThrottledConnection(event, callback, throttleFrames)
    throttleFrames = throttleFrames or 3
    local frameCount = 0
    return event:Connect(function(...)
        frameCount = frameCount + 1
        if frameCount >= throttleFrames then
            frameCount = 0
            callback(...)
        end
    end)
end

-- ============================================================
-- RACETRACK BORDER ANIMATION (baseado no Goblin Hub v2)
-- Nao usa `local` no top-level para nao exceder 200 locals
-- ============================================================
function addRacetrackBorder(parentFrame, carColor, speed)
    if Config and Config.UltraLightMode then return end
    if not parentFrame or not parentFrame:IsA("Frame") then return end
    carColor = carColor or Theme.Accent1
    speed    = speed or 2.5

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RacetrackBorder"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness  = 6
    stroke.Color      = carColor
    stroke.Transparency = 0.3
    stroke.Parent = parentFrame

    local grad = Instance.new("UIGradient")
    local bg = Theme.Background
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   bg),
        ColorSequenceKeypoint.new(0.3, carColor),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, carColor),
        ColorSequenceKeypoint.new(1,   bg),
    }
    grad.Rotation = 0
    grad.Parent   = stroke

    local startTime = tick()
    local lastUp    = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parentFrame.Parent then
            conn:Disconnect()
            return
        end
        local now = tick()
        if now - lastUp < 0.016 then return end
        lastUp = now

        local W = parentFrame.AbsoluteSize.X
        local H = parentFrame.AbsoluteSize.Y
        if W <= 0 or H <= 0 then return end

        local perim    = (W + H) * 2
        local elapsed  = (now - startTime) % speed
        local progress = elapsed / speed
        local dist     = (progress * perim) % perim
        local rot      = 0

        if dist < W then
            rot = (dist / W) * 90
        elseif dist < W + H then
            rot = 90 + ((dist - W) / H) * 90
        elseif dist < W * 2 + H then
            rot = 180 + ((dist - W - H) / W) * 90
        else
            rot = 270 + ((dist - W * 2 - H) / H) * 90
        end

        grad.Rotation = rot

        local wave = math.sin(progress * math.pi * 2)
        local intensity = (wave + 1) * 0.5
        stroke.Transparency = 0.05 + intensity * 0.4
        stroke.Thickness    = 6 + math.sin(now * 5) * 0.15
    end)

    return stroke
end

local PRIORITY_LIST = {
   "Strawberry Elephant",
   "Meowl",
   "Skibidi Toilet",
   "Headless Horseman",
   "Dragon Gingerini",
   "Dragon Cannelloni",
   "Ketupat Bros",
   "Hydra Dragon Cannelloni",
   "La Supreme Combinasion",
   "Love Love Bear",
   "Ginger Gerat",
   "Cerberus",
   "Capitano Moby",
   "La Casa Boo",
   "Burguro and Fryuro",
   "Spooky and Pumpky",
   "Cooki and Milki",
   "Rosey and Teddy",
   "Popcuru and Fizzuru",
   "Reinito Sleighito",
   "Fragrama and Chocrama",
   "Garama and Madundung",
   "Ketchuru and Musturu",
   "La Secret Combinasion",
   "Tralaledon",
   "Tictac Sahur",
   "Ketupat Kepat",
   "Tang Tang Keletang",
   "Orcaledon",
   "La Ginger Sekolah",
   "Los Spaghettis",
   "Lavadorito Spinito",
   "Swaggy Bros",
   "La Taco Combinasion",
   "Los Primos",
   "Chillin Chili",
   "Tuff Toucan",
   "W or L",
   "Chillin Chili",
   "Chipso and Queso"
}

-- Load saved priority list from config (overrides defaults if saved)
do
    local saved = Config and Config.PriorityList
    if saved and type(saved) == "table" and #saved > 0 then
        PRIORITY_LIST = saved
    end
end

local function savePriorityToConfig()
    Config.PriorityList = {}
    for i, v in ipairs(PRIORITY_LIST) do Config.PriorityList[i] = v end
    SaveConfig()
end

local function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

local function CreateGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }
    g.Rotation = 45
    return g
end

local function ApplyViewportUIScale(targetFrame, designWidth, designHeight, minScale, maxScale)
    if not targetFrame then return end
    if not IS_MOBILE then return end
    local existing = targetFrame:FindFirstChildOfClass("UIScale")
    if existing then existing:Destroy() end
    local sc = Instance.new("UIScale")
    sc.Parent = targetFrame
    SharedState.MobileScaleObjects[targetFrame] = sc
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    else
        sc.Scale = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    end
end

SharedState.RefreshMobileScale = function()
    local s = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    for frame, sc in pairs(SharedState.MobileScaleObjects) do
        if frame and frame.Parent and sc and sc.Parent == frame then
            sc.Scale = s
        else
            SharedState.MobileScaleObjects[frame] = nil
        end
    end
end

local function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 10)

    MakeDraggable(restoreBtn, restoreBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

local function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function ShowNotification(title, text) end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

local function stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end

    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
        end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

local function setFPSBoost(enabled)
    Config.FPSBoost = enabled
    SaveConfig()
    if enabled then
        pcall(function() if setfpscap then setfpscap(9999) end end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or 
               v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v:Destroy()
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            stripVisuals(obj)
        end

        Workspace.DescendantAdded:Connect(function(obj)
            if Config.FPSBoost then
                stripVisuals(obj)
            end
        end)
    end
end
if Config.FPSBoost then task.spawn(function() task.wait(1); setFPSBoost(true) end) end
if Config.UltraLightMode then
    task.spawn(function()
        task.wait(2) -- wait for all UIs to be created
        for _,gn in ipairs({"AutoStealUI","BullysAdminPanel","SettingsUI","StealSpeedUI",
            "BullysInvisPanel","BullysStatusHUD","BullysSettings","BullysPlatformUI",
            "BullysAutoBuyUI","BullysMiniActions"}) do
            local sg = PlayerGui:FindFirstChild(gn)
            if sg then
                for _,obj in ipairs(sg:GetDescendants()) do
                    if obj.Name == "RacetrackBorder" and obj:IsA("UIStroke") then
                        obj:Destroy()
                    end
                end
            end
        end
    end)
end

local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    xrayEnabled = false,
    antiRagdollMode = Config.AntiRagdoll or 0,
    floatActive = false,
    isTpMoving = false,
    manualTargetEnabled = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    xrayDescConn = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel

local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end

    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end

    Connections.carpetSpeedConnection = RunService.Heartbeat:Connect(function()
    carpetSpeedConnection = Connections.carpetSpeedConnection
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local toolName = Config.TpSettings.Tool
        local hasTool = c:FindFirstChild(toolName)
        
        if not hasTool then
            local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tb then hum:EquipTool(tb) end
        end

        if hasTool then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * 140, 
                    hrp.AssemblyLinearVelocity.Y, 
                    md.Z * 140
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    Connections.infiniteJumpConnection = RunService.Heartbeat:Connect(function()
    infiniteJumpConnection = Connections.infiniteJumpConnection
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local now = tick()
        if now - JumpData.lastJumpTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        JumpData.lastJumpTime = now
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
    end)
end
if infiniteJumpEnabled then setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

local function isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

local function enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
local function disableXray()
    XrayState.xrayEnabled = false
    xrayEnabled = XrayState.xrayEnabled
    if Connections.xrayDescConn then Connections.xrayDescConn:Disconnect(); Connections.xrayDescConn = nil end
    xrayDescConn = Connections.xrayDescConn
    for part, val in pairs(XrayState.originalTransparency) do
        if part and part.Parent then part.LocalTransparencyModifier = val end
    end
    XrayState.originalTransparency = {}
    originalTransparency = XrayState.originalTransparency
end

if Config.XrayEnabled then
    enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end


local function startAntiRagdoll(mode)
    stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        stopAntiRagdollV2()
    end
    if mode == 0 then return end

    Connections.antiRagdollConn = RunService.Heartbeat:Connect(function()
    antiRagdollConn = Connections.antiRagdollConn
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if isRagdolled() then
            pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hrp.AssemblyLinearVelocity = Vector3.zero
            if Workspace.CurrentCamera.CameraSubject ~= hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BallSocketConstraint") or obj.Name:find("RagdollAttachment") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local AntiRagdollV2Data = {
    antiRagdollConns = {},
}
local antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

local cleanRagdollV2Scheduled = false
local function cleanRagdollV2(char)
    if not char then return end
    local carpetEquipped = false
    pcall(function()
        local toolName = Config.TpSettings.Tool or "Flying Carpet"
        local tool = char:FindFirstChild(toolName)
        if tool then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
            if not carpetEquipped then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
        end
    end)
    local descendants = char:GetDescendants()
    for _, d in ipairs(descendants) do
        if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
            or d:IsA("HingeConstraint")
            or (d:IsA("Attachment") and (d.Name == "A" or d.Name == "B")) then
            d:Destroy()
        elseif (d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and not carpetEquipped then
            d:Destroy()
        end
    end
    for _, d in ipairs(descendants) do
        if d:IsA("Motor6D") then d.Enabled = true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation and track.Animation.Name:lower() or ""
                if n:find("rag") or n:find("fall") or n:find("hurt") or n:find("down") then
                    track:Stop(0)
                end
            end
        end
    end
    task.defer(function()
        pcall(function()
            local pm = LocalPlayer:FindFirstChild("PlayerScripts")
            if pm then pm = pm:FindFirstChild("PlayerModule") end
            if pm then require(pm):GetControls():Enable() end
        end)
    end)
end
local function cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then cleanRagdollV2(char) end
    end)
end
local function isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end

local function hookAntiRagV2(char)
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end

    local lastVel = Vector3.new(0, 0, 0)

    local c1 = hum.StateChanged:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            local carpetActive = false
            pcall(function()
                local toolName = Config.TpSettings.Tool or "Flying Carpet"
                local tool = char:FindFirstChild(toolName)
                if tool and hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            carpetActive = true
                        end
                    end
                end
            end)
            if not carpetActive then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanRagdollV2(char)
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            pcall(function()
                local pm = LocalPlayer:FindFirstChild("PlayerScripts")
                if pm then pm = pm:FindFirstChild("PlayerModule") end
                if pm then require(pm):GetControls():Enable() end
            end)
        end
    end)
    table.insert(antiRagdollConns, c1)

    local c2 = char.DescendantAdded:Connect(function(desc)
        if isRagdollRelatedDescendant(desc) then
            cleanRagdollV2Debounced(char)
        end
    end)
    table.insert(antiRagdollConns, c2)

    pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg then
            local net = pkg:FindFirstChild("Net")
            if net then
                local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    local c3 = applyImp.OnClientEvent:Connect(function()
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                        end
                    end)
                    table.insert(antiRagdollConns, c3)
                end
            end
        end
    end)

    local c4 = RunService.Heartbeat:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            cleanRagdollV2(char)
            local vel = hrp.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                hrp.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, 15)
            end
        end
        lastVel = hrp.AssemblyLinearVelocity
    end)
    table.insert(antiRagdollConns, c4)

    cleanRagdollV2(char)
end

local function stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end

local function startAntiRagdollV2(enabled)
    stopAntiRagdoll()
    stopAntiRagdollV2()
    if not enabled then
        return
    end

    local char = LocalPlayer.Character
    if char then task.spawn(function() hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() hookAntiRagV2(c) end)
    end)
end

if antiRagdollMode > 0 then startAntiRagdoll(antiRagdollMode) end
Config.AntiRagdollV2 = true
startAntiRagdollV2(true)
if Config.AntiRagdollV2 then startAntiRagdollV2(true) end

do
    local plotBeam = nil
    local plotBeamAttachment0 = nil
    local plotBeamAttachment1 = nil

    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if text:find(LocalPlayer.DisplayName:lower(), 1, true) or text:find(LocalPlayer.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function createPlotBeam()
        if not Config.LineToBase then return end
        local myPlot = findMyPlot()
        if not myPlot or not myPlot.Parent then return end
        local character = LocalPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        plotBeamAttachment0 = hrp:FindFirstChild("PlotBeamAttach_Player") or Instance.new("Attachment")
        plotBeamAttachment0.Name = "PlotBeamAttach_Player"
        plotBeamAttachment0.Position = Vector3.new(0, 0, 0)
        plotBeamAttachment0.Parent = hrp
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart or not plotPart.Parent then return end
        plotBeamAttachment1 = plotPart:FindFirstChild("PlotBeamAttach_Plot") or Instance.new("Attachment")
        plotBeamAttachment1.Name = "PlotBeamAttach_Plot"
        plotBeamAttachment1.Position = Vector3.new(0, 5, 0)
        plotBeamAttachment1.Parent = plotPart
        plotBeam = hrp:FindFirstChild("PlotBeam") or Instance.new("Beam")
        plotBeam.Name = "PlotBeam"
        plotBeam.Attachment0 = plotBeamAttachment0
        plotBeam.Attachment1 = plotBeamAttachment1
        plotBeam.FaceCamera = true
        plotBeam.LightEmission = 1
        plotBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        plotBeam.Transparency = NumberSequence.new(0)
        plotBeam.Width0 = 0.7
        plotBeam.Width1 = 0.7
        plotBeam.TextureMode = Enum.TextureMode.Wrap
        plotBeam.TextureSpeed = 0
        plotBeam.Parent = hrp
    end

    local function resetPlotBeam()
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        if plotBeamAttachment1 then pcall(function() plotBeamAttachment1:Destroy() end) end
        plotBeam = nil
        plotBeamAttachment0 = nil
        plotBeamAttachment1 = nil
    end

    task.spawn(function()
        local checkCounter = 0
        RunService.Heartbeat:Connect(function()
            if not Config.LineToBase then return end
            checkCounter = checkCounter + 1
            if checkCounter >= 30 then
                checkCounter = 0
                if not plotBeam or not plotBeam.Parent or not plotBeamAttachment0 or not plotBeamAttachment0.Parent then
                    pcall(createPlotBeam)
                end
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.LineToBase and character then
            pcall(createPlotBeam)
        end
    end)

    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.2)
            if Config.LineToBase then createPlotBeam() end
        end)
    end

    _G.createPlotBeam = createPlotBeam
    _G.resetPlotBeam = resetPlotBeam
end

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas    = ReplicatedStorage:WaitForChild("Datas")
    local Shared   = ReplicatedStorage:WaitForChild("Shared")
    local Utils    = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer  = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData   = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils   = require(Utils:WaitForChild("NumberUtils"))

    local autoStealEnabled   = not Config.DefaultToDisable
    
    
    if Config.DefaultToPriority and Config.DefaultToHighest then
        Config.DefaultToHighest = false
    end
    if Config.DefaultToPriority and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    if Config.DefaultToHighest and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    
    if not Config.DefaultToPriority and not Config.DefaultToHighest and not Config.DefaultToNearest and not Config.DefaultToDisable then
        Config.DefaultToHighest = true
    end
    
    local stealNearestEnabled = false
    local stealHighestEnabled = false
    local stealPriorityEnabled = false
    
    if Config.DefaultToNearest then
        stealNearestEnabled = true
        Config.StealNearest = true
        Config.StealHighest = false
        Config.StealPriority = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToHighest then
        stealHighestEnabled = true
        Config.StealHighest = true
        Config.StealNearest = false
        Config.StealPriority = false
        Config.AutoTPPriority = false
    elseif Config.DefaultToPriority then
        stealPriorityEnabled = true
        Config.StealPriority = true
        Config.StealNearest = false
        Config.StealHighest = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToDisable then
        -- Disable mode: don't activate any steal mode on load
        stealNearestEnabled = false
        stealHighestEnabled = false
        stealPriorityEnabled = false
        Config.StealNearest = false
        Config.StealHighest = false
        Config.StealPriority = false
    else
        stealNearestEnabled = Config.StealNearest
        stealHighestEnabled = Config.StealHighest
        stealPriorityEnabled = Config.StealPriority
        
        if Config.InstantSteal == nil then Config.InstantSteal = false end
        if Config.StealPriority then
            Config.AutoTPPriority = true
        elseif Config.StealNearest then
            Config.AutoTPPriority = true
        elseif Config.StealHighest then
            Config.AutoTPPriority = false
        end
    end
    
    local instantStealEnabled = (Config.InstantSteal == true)
    local instantStealReady = false
    local instantStealDidInit = false
    local selectedTargetIndex = 1
    local selectedTargetUID   = nil 
    local allAnimalsCache    = {}
    local InternalStealCache = {}
    local PromptMemoryCache  = {}
    local activeProgressTween = nil
    local currentStealTargetUID = nil
    local petButtons         = {}

    -- â”€â”€ STEAL REMOTE RESOLVER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    -- Resolved once and cached. Used in all steal paths for maximum speed.
    
    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot)
        if not plot then return false end
        local channel = Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "Instance" then return owner == LocalPlayer end
            end
        end
        return false
    end
    
    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None" then return "" end
        local f = ""
        if mutationName == "Cursed" then f = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
        elseif mutationName == "Gold" then f = "<font color='rgb(255,215,0)'>Gold</font>"
        elseif mutationName == "Diamond" then f = "<font color='rgb(0,255,255)'>Diamond</font>"
        elseif mutationName == "YinYang" then f = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
        elseif mutationName == "Candy" then f = "<font color='rgb(255,105,180)'>Candy</font>"
        elseif mutationName == "Divine" then f = "<font color='rgb(255,255,255)'>Divine</font>"
        elseif mutationName == "Rainbow" then
            local cols = {"rgb(255,0,0)","rgb(255,127,0)","rgb(255,255,0)","rgb(0,255,0)","rgb(0,0,255)","rgb(75,0,130)","rgb(148,0,211)"}
            for i = 1, #mutationName do f = f.."<font color='"..cols[(i-1)%#cols+1].."'>"..mutationName:sub(i,i).."</font>" end
        else f = mutationName end
        return "<font weight='800'>"..f.." </font>"
    end

    local function get_all_pets()
        local out = {}
        for _, a in ipairs(allAnimalsCache) do
            if a.genValue >= 1 and not isMyBaseAnimal(a) then
                table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                    owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a, source="CARPET"})
            end
        end
        -- also include conveyor brainrots
        -- (REMOVED: conveyor detection disabled)
        return out
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoStealUI"; screenGui.ResetOnSpawn = false; screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.6 or 1
    frame.Size = UDim2.new(0, 300*mobileScale, 0, 630*mobileScale)
    frame.Position = UDim2.new(Config.Positions.AutoSteal.X, 0, Config.Positions.AutoSteal.Y, 0)
    frame.BackgroundColor3 = Theme.Background; frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Parent = screenGui
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1, -20, 0, 40) -- largura quase total
    logo.Position = UDim2.new(0, 10, 0, 5) -- bem no topo
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://15605014322"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = frame

    ApplyViewportUIScale(frame, 300, 630, 0.45, 0.8)
    AddMobileMinimize(frame, "AUTO STEAL")
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", frame)
    mainStroke.Color = Theme.Accent2; mainStroke.Thickness = 1.5; mainStroke.Transparency = 0.4
    CreateGradient(mainStroke)
    task.defer(function() if addRacetrackBorder then addRacetrackBorder(frame, Theme.Accent1, 3) end end)
    
    local header = Instance.new("Frame", frame); header.Size = UDim2.new(1,0,0,40); header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "AutoSteal") 
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = IS_MOBILE and UDim2.new(0.4,0,1,0) or UDim2.new(0.6,0,1,0)
    titleLabel.Position = UDim2.new(0,15,0,0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "AUTO STEAL"
    titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.TextPrimary; titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    if IS_MOBILE then
        local menuToggleBtn = Instance.new("TextButton", header)
        menuToggleBtn.Size = UDim2.new(0, 80, 0, 30)
        menuToggleBtn.Position = UDim2.new(1, -85, 0.5, -15)
        menuToggleBtn.BackgroundColor3 = Theme.Accent1
        menuToggleBtn.Text = "MENU"
        menuToggleBtn.Font = Enum.Font.GothamBold
        menuToggleBtn.TextSize = 12
        menuToggleBtn.TextColor3 = Color3.new(0, 0, 0)
        Instance.new("UICorner", menuToggleBtn).CornerRadius = UDim.new(0, 6)
        
        menuToggleBtn.MouseButton1Click:Connect(function()
            if settingsGui then
                settingsGui.Enabled = not settingsGui.Enabled
            end
        end)
    end

    local targetPanel = Instance.new("Frame", frame)
    targetPanel.Size = UDim2.new(1,-30,0,60); targetPanel.Position = UDim2.new(0,15,0,45)
    targetPanel.BackgroundColor3 = Theme.Surface; targetPanel.BorderSizePixel = 0
    Instance.new("UICorner", targetPanel).CornerRadius = UDim.new(0, 8)

    local targetHeader = Instance.new("TextLabel", targetPanel)
    targetHeader.Size = UDim2.new(1,-20,0,15); targetHeader.Position = UDim2.new(0,10,0,8)
    targetHeader.BackgroundTransparency = 1; targetHeader.Text = "CURRENT TARGET"
    targetHeader.Font = Enum.Font.GothamBold; targetHeader.TextSize = 10
    targetHeader.TextColor3 = Theme.TextSecondary; targetHeader.TextXAlignment = Enum.TextXAlignment.Left

    local targetLabel = Instance.new("TextLabel", targetPanel)
    targetLabel.Size = UDim2.new(1,-20,0,20); targetLabel.Position = UDim2.new(0,10,0,25)
    targetLabel.BackgroundTransparency = 1; targetLabel.Font = Enum.Font.GothamBold; targetLabel.TextSize = 16
    targetLabel.TextColor3 = Theme.TextPrimary; targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextTruncate = Enum.TextTruncate.AtEnd; targetLabel.Text = ""

    local progressBg = Instance.new("Frame", targetPanel)
    progressBg.Size = UDim2.new(1,0,0,5); progressBg.Position = UDim2.new(0,0,1,-4)
    progressBg.BackgroundColor3 = Color3.fromRGB(10,10,15); progressBg.BorderSizePixel = 0
    local progressBarFill = Instance.new("Frame", progressBg)
    progressBarFill.Size = UDim2.new(0,0,1,0); progressBarFill.BackgroundColor3 = Color3.fromRGB(255,120,200)
    progressBarFill.BorderSizePixel = 0; CreateGradient(progressBarFill)

    local selectLabel = Instance.new("TextLabel", frame)
    selectLabel.Size = UDim2.new(0.5,0,0,20); selectLabel.Position = UDim2.new(0,15,0,115)
    selectLabel.BackgroundTransparency = 1; selectLabel.Text = "AVAILABLE BRAINROTS"
    selectLabel.Font = Enum.Font.GothamBold; selectLabel.TextSize = 11
    selectLabel.TextColor3 = Theme.TextSecondary; selectLabel.TextXAlignment = Enum.TextXAlignment.Left

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1,-30,1,-254); listFrame.Position = UDim2.new(0,15,0,135)
    listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ScrollBarImageTransparency = 1; listFrame.ScrollBarThickness = 0
    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0,8); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1,-30,0,144); toggleBtnContainer.Position = UDim2.new(0,15,1,-154)
    toggleBtnContainer.BackgroundTransparency = 1
    
    local enableBtn = Instance.new("TextButton", toggleBtnContainer)
    local mobileButtonScale = IS_MOBILE and 1.3 or 1
    enableBtn.Size = UDim2.new(1,0,0,32*mobileButtonScale); enableBtn.BackgroundColor3 = Theme.Success
    enableBtn.Text = "ENABLED"; enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 13*mobileButtonScale; enableBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 8)
    
    local nearestBtn = Instance.new("TextButton", toggleBtnContainer)
    nearestBtn.Size = UDim2.new(0.48,0,0,28*mobileButtonScale); nearestBtn.Position = UDim2.new(0,0,0,36*mobileButtonScale)
    nearestBtn.BackgroundColor3 = Theme.SurfaceHighlight
    nearestBtn.Text = "NEAREST"; nearestBtn.Font = Enum.Font.GothamBold
    nearestBtn.TextSize = 11*mobileButtonScale; nearestBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 6)

    local highestBtn = Instance.new("TextButton", toggleBtnContainer)
    highestBtn.Size = UDim2.new(0.48,0,0,28*mobileButtonScale); highestBtn.Position = UDim2.new(0.52,0,0,36*mobileButtonScale)
    highestBtn.BackgroundColor3 = Theme.SurfaceHighlight
    highestBtn.Text = "HIGHEST"; highestBtn.Font = Enum.Font.GothamBold
    highestBtn.TextSize = 11*mobileButtonScale; highestBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", highestBtn).CornerRadius = UDim.new(0, 6)

    local priorityBtn = Instance.new("TextButton", toggleBtnContainer)
    priorityBtn.Size = UDim2.new(1,0,0,24*mobileButtonScale); priorityBtn.Position = UDim2.new(0,0,0,68*mobileButtonScale)
    priorityBtn.BackgroundColor3 = Theme.SurfaceHighlight
    priorityBtn.Text = "PRIORITY"; priorityBtn.Font = Enum.Font.GothamBold
    priorityBtn.TextSize = 11*mobileButtonScale; priorityBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", priorityBtn).CornerRadius = UDim.new(0, 6)

    local function updateUI(enabled, allPets)
        autoStealEnabled = enabled
        enableBtn.Text = enabled and "ENABLED" or "DISABLED"
        enableBtn.BackgroundColor3 = enabled and Theme.Success or Theme.SurfaceHighlight
        
        nearestBtn.BackgroundColor3 = stealNearestEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        nearestBtn.TextColor3 = stealNearestEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        highestBtn.BackgroundColor3 = stealHighestEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        highestBtn.TextColor3 = stealHighestEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        priorityBtn.BackgroundColor3 = stealPriorityEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        priorityBtn.TextColor3 = stealPriorityEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        if instantStealBtn then
            instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
            instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
            instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        end

        if selectedTargetUID and allPets then
            local found = false
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then
                    selectedTargetIndex = i
                    found = true
                    break
                end
            end
        end

        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            petButtons = {}
            if allPets and #allPets > 0 then
                for i = 1, #allPets do
                    local petData = allPets[i]
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = Theme.Surface
                    btn.Text = ""; btn.Parent = listFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
                    local bStroke = Instance.new("UIStroke", btn)
                    bStroke.Color = Theme.Accent1; bStroke.Thickness = 1; bStroke.Transparency = 1

                    local MUT_COLORS_UI = {
                        Cursed=Color3.fromRGB(200,0,0), Gold=Color3.fromRGB(255,215,0),
                        Diamond=Color3.fromRGB(0,255,255), YinYang=Color3.fromRGB(220,220,220),
                        Rainbow=Color3.fromRGB(255,100,200), Lava=Color3.fromRGB(255,100,20),
                        Candy=Color3.fromRGB(255,105,180), Divine=Color3.fromRGB(255,255,255)
                    }
                    local hasMut = petData.mutation and petData.mutation ~= "None"
                    local isEsteira = petData.source == "ESTEIRA"
                    local barCol = isEsteira and Color3.fromRGB(0,220,200)
                        or (hasMut and (MUT_COLORS_UI[petData.mutation] or Color3.fromRGB(210,130,255)) or Theme.Accent2)
                    local itemBar = Instance.new("Frame", btn)
                    itemBar.Size = UDim2.new(0,3,1,-8); itemBar.Position = UDim2.new(0,3,0,4)
                    itemBar.BackgroundColor3 = barCol; itemBar.BorderSizePixel = 0
                    Instance.new("UICorner",itemBar).CornerRadius = UDim.new(1,0)

                    local rankLabel = Instance.new("TextLabel", btn)
                    rankLabel.Size = UDim2.new(0,28,1,0); rankLabel.Position = UDim2.new(0,10,0,0)
                    rankLabel.BackgroundTransparency = 1; rankLabel.Text = "#"..i
                    rankLabel.Font = Enum.Font.GothamBlack; rankLabel.TextSize = 13
                    local infoLabel = Instance.new("TextLabel", btn)
                    infoLabel.Size = UDim2.new(1,-42,1,0); infoLabel.Position = UDim2.new(0,38,0,0)
                    infoLabel.BackgroundTransparency = 1; infoLabel.RichText = true
                    infoLabel.Text = formatMutationText(petData.mutation).."<font weight='700'>"..petData.petName.."</font> - <font weight='700'>"..petData.mpsText.."</font>"
                    infoLabel.Font = Enum.Font.GothamMedium; infoLabel.TextSize = 12
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    petButtons[i] = {button=btn, stroke=bStroke, rank=rankLabel, info=infoLabel, bar=itemBar}
                    
                    btn.MouseButton1Click:Connect(function()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid
                        State.manualTargetEnabled = true
                        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
                    end)
                end
            end
            SharedState.ListNeedsRedraw = false
        end
        
        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end

        for i, pb in ipairs(petButtons) do
            local sel = (i == selectedTargetIndex)
            pb.stroke.Transparency = sel and 0 or 1
            pb.button.BackgroundColor3 = sel and Theme.SurfaceHighlight or Theme.Surface
            pb.rank.TextColor3  = sel and Theme.Accent1 or Theme.TextSecondary
            pb.info.TextColor3  = sel and Theme.TextPrimary or Theme.TextSecondary
        end
        local ct = allPets and allPets[selectedTargetIndex]
        SharedState.SelectedPetData = ct
        if enabled then
            targetLabel.Text = ct and string.format("%s (%s)", ct.petName, ct.mpsText) or "Searching..."
        else targetLabel.Text = "Disabled" end
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)
    
    SharedState.UpdateAutoStealUI = function()
        updateUI(autoStealEnabled, get_all_pets())
    end
    
    enableBtn.MouseButton1Click:Connect(function()
        autoStealEnabled = not autoStealEnabled; SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)
    
    nearestBtn.MouseButton1Click:Connect(function()
        stealNearestEnabled = not stealNearestEnabled
        if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    highestBtn.MouseButton1Click:Connect(function()
        stealHighestEnabled = not stealHighestEnabled
        if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    priorityBtn.MouseButton1Click:Connect(function()
        stealPriorityEnabled = not stealPriorityEnabled
        if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    local customizePriorityBtn = Instance.new("TextButton", toggleBtnContainer)
    customizePriorityBtn.Size = UDim2.new(1,0,0,24); customizePriorityBtn.Position = UDim2.new(0,0,0,92)
    customizePriorityBtn.BackgroundColor3 = Theme.Accent2
    customizePriorityBtn.Text = "CUSTOMIZE PRIORITY"; customizePriorityBtn.Font = Enum.Font.GothamBold
    customizePriorityBtn.TextSize = 10; customizePriorityBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", customizePriorityBtn).CornerRadius = UDim.new(0, 6)
    customizePriorityBtn.Visible = not IS_MOBILE
    
    customizePriorityBtn.MouseButton1Click:Connect(function()
        local priorityGui = PlayerGui:FindFirstChild("PriorityListGUI")
        if priorityGui then
            priorityGui.Enabled = not priorityGui.Enabled
        end
    end)

    local instantStealBtn = Instance.new("TextButton", toggleBtnContainer)
    instantStealBtn.Size = UDim2.new(1,0,0,24*mobileButtonScale); instantStealBtn.Position = UDim2.new(0,0,0,116*mobileButtonScale)
    instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
    instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"; instantStealBtn.Font = Enum.Font.GothamBold
    instantStealBtn.TextSize = 10*mobileButtonScale; instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
    Instance.new("UICorner", instantStealBtn).CornerRadius = UDim.new(0, 6)

    instantStealBtn.MouseButton1Click:Connect(function()
        instantStealEnabled = not instantStealEnabled
        if not instantStealEnabled then
            instantStealReady = false
            instantStealDidInit = false
        end
        Config.InstantSteal = instantStealEnabled
        SaveConfig()
        instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
        instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    local function findProximityPromptForAnimal(animalData)
        if not animalData then return nil end
        local cp = PromptMemoryCache[animalData.uid]
        if cp and cp.Parent then return cp end
        local plot = Workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        
        
        local ch = Synchronizer:Get(plot.Name)
        if not ch then
            
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local attach = spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        for _, p in ipairs(attach:GetChildren()) do
                            if p:IsA("ProximityPrompt") then
                                PromptMemoryCache[animalData.uid] = p
                                return p
                            end
                        end
                    end
                end
            end
            return nil
        end
        
        local al = ch:Get("AnimalList")
        if not al then return nil end
        
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local targetSlot = animalData.slot
        
        
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == targetSlot then
                local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot))
                    break
                end
            end
        end
        
        
        if not foundPodium then
            foundPodium = podiums:FindFirstChild(animalData.slot)
        end
        
        if foundPodium then
            local base = foundPodium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then
                            PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
                
                
                local startPos = spawn.Position
                local slotX, slotZ = startPos.X, startPos.Z
                local nearestPrompt = nil
                local minDist = math.huge
                
                for _, desc in pairs(plot:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
                        local part = desc.Parent
                        local promptPos = nil
                        
                        if part and part:IsA("BasePart") then
                            promptPos = part.Position
                        elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                            promptPos = part.Parent.Position
                        end
                        
                        if promptPos then
                            local checkStartY = startPos.Y
                            if brainrotName:find("la secret combinasion") then
                                checkStartY = startPos.Y - 5
                            end
                            local horizontalDist = math.sqrt((promptPos.X - slotX)^2 + (promptPos.Z - slotZ)^2)
                            if horizontalDist < 5 and promptPos.Y > checkStartY then
                                local yDist = promptPos.Y - checkStartY
                                if yDist < minDist then
                                    minDist = yDist
                                    nearestPrompt = desc
                                end
                            end
                        end
                    end
                end
                
                if nearestPrompt then
                    PromptMemoryCache[animalData.uid] = nearestPrompt
                    return nearestPrompt
                end
            end
        end
        
        return nil
    end

    local STEAL_DURATION = 0.8

    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then return end
        local data = {holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true}
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table" then
            for _, conn in ipairs(conns1) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdCallbacks, conn.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table" then
            for _, conn in ipairs(conns2) do
                if type(conn.Function) == "function" then
                    table.insert(data.triggerCallbacks, conn.Function)
                end
            end
        end
        local ok3, conns3 = pcall(getconnections, prompt.PromptButtonHoldEnded)
        if ok3 and type(conns3) == "table" then
            for _, conn in ipairs(conns3) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdEndCallbacks, conn.Function)
                end
            end
        end
        if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) or (#data.holdEndCallbacks > 0) then
            InternalStealCache[prompt] = data
        end
    end

    local function runCallbackList(list)
        for _, fn in ipairs(list) do
            task.spawn(fn)
        end
    end

    local INSTANT_STEAL_RADIUS = 60
    local INSTANT_STEAL_COOLDOWN = 0.04
    local lastInstantStealTime = 0
    local function isMyPlot_Instant(plotName)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(plotName)
        if not plot then return false end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return false end
        local yb = sign:FindFirstChild("YourBase")
        return yb and yb:IsA("BillboardGui") and yb.Enabled
    end
    local function findNearestPrompt_Instant()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, math.huge, nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil, math.huge, nil end
        local bestPrompt, bestDist, bestName = nil, math.huge, nil
        for _, plot in ipairs(plots:GetChildren()) do
            if isMyPlot_Instant(plot.Name) then continue end
            local plotDist = math.huge
            pcall(function() plotDist = (plot:GetPivot().Position - hrp.Position).Magnitude end)
            if plotDist > INSTANT_STEAL_RADIUS + 40 then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, pod in ipairs(podiums:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if not spawn then continue end
                local dist = (spawn.Position - hrp.Position).Magnitude
                if dist > INSTANT_STEAL_RADIUS or dist >= bestDist then continue end
                local att = spawn:FindFirstChild("PromptAttachment")
                if not att then continue end
                local prompt = att:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.Parent and prompt.Enabled then
                    bestPrompt = prompt
                    bestDist = dist
                    bestName = pod.Name
                end
            end
        end
        return bestPrompt, bestDist, bestName
    end
    -- STEAL: fireproximityprompt + direct remote callbacks
    local function executeInstantSteal(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return end
        local now = os.clock()
        if now - lastInstantStealTime < INSTANT_STEAL_COOLDOWN then return end
        lastInstantStealTime = now

        -- Fire the proximity prompt (mimics real E press)
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end)

        -- Also fire server remote directly via getconnections callbacks
        task.spawn(function()
            buildStealCallbacks(prompt)
            local data = InternalStealCache[prompt]
            if data then
                if #data.holdCallbacks > 0 then
                    runCallbackList(data.holdCallbacks)
                end
                task.wait(0.05)
                if #data.triggerCallbacks > 0 then
                    runCallbackList(data.triggerCallbacks)
                end
            end
        end)
    end

    local function executeInternalStealAsync(prompt, animalUID)
        local data = InternalStealCache[prompt]
        if not data or not data.ready then return false end
        data.ready = false

        task.spawn(function()
            if currentStealTargetUID ~= animalUID then
                if activeProgressTween then activeProgressTween:Cancel() end
                progressBarFill.Size = UDim2.new(0, 0, 1, 0)
                currentStealTargetUID = animalUID
            end

            -- Hold begin
            if #data.holdCallbacks > 0 then
                runCallbackList(data.holdCallbacks)
            end

            progressBarFill.Size = UDim2.new(0, 0, 1, 0)
            progressBarFill.BackgroundTransparency = 0
            activeProgressTween = TweenService:Create(progressBarFill, TweenInfo.new(STEAL_DURATION, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
            activeProgressTween:Play()
            activeProgressTween.Completed:Wait()

            if currentStealTargetUID == animalUID and #data.triggerCallbacks > 0 then
                runCallbackList(data.triggerCallbacks)
            end

            data.ready = true
        end)

        return true
    end

    local function attemptSteal(prompt, animalUID)
        if not prompt or not prompt.Parent then return false end
        buildStealCallbacks(prompt)
        if not InternalStealCache[prompt] then return false end

        if currentStealTargetUID ~= animalUID then
            if activeProgressTween then
                activeProgressTween:Cancel()
                activeProgressTween = nil
            end
            progressBarFill.Size = UDim2.new(0, 0, 1, 0)
        end

        return executeInternalStealAsync(prompt, animalUID)
    end

    local function prebuildStealCallbacks()
        for _, prompt in pairs(PromptMemoryCache) do
            if prompt and prompt.Parent then
                buildStealCallbacks(prompt)
            end
        end
    end

    task.spawn(function()
        while task.wait(2) do
            if autoStealEnabled then
                prebuildStealCallbacks()
            end
        end
    end)

    local lastAnimalData = {}
    local function getAnimalHash(al)
        if not al then return "" end; local h=""
        for slot, d in pairs(al) do if type(d)=="table" then h=h..tostring(slot)..tostring(d.Index)..tostring(d.Mutation) end end
        return h
    end

    local function scanSinglePlot(plot)
        local changed = false
        pcall(function()
            local ch = Synchronizer:Get(plot.Name); if not ch then return end
            local al = ch:Get("AnimalList")
            local hash = getAnimalHash(al)
            if lastAnimalData[plot.Name]==hash then return end
            lastAnimalData[plot.Name]=hash; changed=true
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==plot.Name then table.remove(allAnimalsCache,i) end end
            local owner = ch:Get("Owner")
            if not owner or not Players:FindFirstChild(owner.Name) then return end
            local ownerName = owner.Name or "Unknown"
            if not al then return end
            for slot, ad in pairs(al) do
                if type(ad)=="table" then
                    local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                    if aInfo then
                        local mut = ad.Mutation or "None"
                        if mut == "Yin Yang" then mut = "YinYang" end
                        local traits = (ad.Traits and #ad.Traits>0) and table.concat(ad.Traits,", ") or "None"
                        local gv = AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil)
                        local gt = "$"..NumberUtils:ToString(gv).."/s"
                        table.insert(allAnimalsCache, {
                            name=aInfo.DisplayName or aName, genText=gt, genValue=gv,
                            mutation=mut, traits=traits, owner=ownerName,
                            plot=plot.Name, slot=tostring(slot), uid=plot.Name.."_"..tostring(slot)
                        })
                    end
                end
            end
        end)
        if changed then
            table.sort(allAnimalsCache, function(a,b) return a.genValue>b.genValue end)
            SharedState.ListNeedsRedraw = true
            
            
            if not hasShownPriorityAlert and Config.AlertsEnabled then
                task.spawn(function()
                    
                    local foundPriorityPet = nil
                    for i = 1, #PRIORITY_LIST do
                        local priorityName = PRIORITY_LIST[i]
                        local searchName = priorityName:lower()
                        
                        
                        for _, pet in ipairs(allAnimalsCache) do
                            if pet.name and pet.name:lower() == searchName then
                                foundPriorityPet = pet
                                break
                            end
                        end
                        
                        
                        if foundPriorityPet then
                            break
                        end
                    end
                    
                    if foundPriorityPet then
                        
                        local ownerUsername = foundPriorityPet.owner
                        local ownerPlayer = nil
                        
                        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                        if plot then
                            
                            local sync = Synchronizer
                            if not sync then
                                local Packages = ReplicatedStorage:FindFirstChild("Packages")
                                if Packages then
                                    local ok, syncModule = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                    if ok then sync = syncModule end
                                end
                            end
                            
                            if sync then
                                local ok, ch = pcall(function() return sync:Get(plot.Name) end)
                                if ok and ch then
                                    local owner = ch:Get("Owner")
                                    if owner then
  

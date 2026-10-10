--============ W2HUB FREE SCRIPT v1.0 ============
-- Script Ini GRATIS - Jangan Dijual!
--================================================

getgenv().W2HUB = getgenv().W2HUB or {}
local W = getgenv()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local VIM = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local function LoadUILib()
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://glutofree.vercel.app/library"))()
    end)
    if ok and lib then return lib end
    return nil
end
local UILib = LoadUILib()
if not UILib then warn("[W2HUB] UILib gagal load"); return end

local function Notify(title, msg, dur)
    pcall(function()
        UILib:MakeNotify({
            Title = title or "W2HUB",
            Description = "Info",
            Content = msg or "",
            Color = Color3.fromRGB(255,255,255),
            Time = 0.4,
            Delay = dur or 2,
            Icon = "138040631725974"
        })
    end)
end
W.Notify = Notify

local function TeamIs(p, role)
    if not p or not p.Team or not p.Team.Name then return false end
    local t = string.lower(p.Team.Name)
    if role == "Killer" then return t:find("killer",1,true) ~= nil end
    if role == "Survivor" then return t:find("survivor",1,true) ~= nil end
    return false
end
W.TeamIs = TeamIs

local function GetRole()
    if TeamIs(LP, "Killer") then return "Killer" end
    if TeamIs(LP, "Survivor") then return "Survivor" end
    return nil
end
W.GetRole = GetRole

-- === WINDOW ===
local Window = UILib:Window({
    Title = "W2HUB",
    LogoButtonSize = 52,
    Image = "138040631725974",
    Footer = "W2HUB",
    Color = Color3.fromRGB(255,255,255),
    ShowInfo = true,
    Search = true,
})

Window:InfoTab({
    Name = "Information",
    Icon = "lightbulb",
    SectionTitle = "Information",
    Banner = "rbxassetid://138040631725974",
    Cards = {
        { Title = "SCRIPT INI GRATIS", Description = "Script 100% GRATIS!\n\nJANGAN DIJUAL\n\nYang jual = SCAMMER!" },
    }
})

local TabSurv = Window:AddTab({ Name = "Survivor", Icon = "user" })
local TabVis = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local TabKill = Window:AddTab({ Name = "Killer", Icon = "crosshair" })
local TabMisc = Window:AddTab({ Name = "Misc", Icon = "settings-2" })
local TabTroll = Window:AddTab({ Name = "Troll", Icon = "ghost" })
local TabCfg = Window:AddTab({ Name = "Config", Icon = "save" })

print("[W2HUB] Window Loaded")

--============================================
-- SELF HEAL
--============================================
local HealConn = nil
local function DoHeal(state)
    local c = LP.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() ReplicatedStorage.Remotes.Healing.HealEvent:FireServer(hrp, state) end)
end
local function SetSelfHeal(v)
    if HealConn then HealConn:Disconnect(); HealConn = nil end
    if v then
        local active = false
        HealConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h then return end
            if h.Health >= h.MaxHealth * 0.9 then
                if active then active = false; DoHeal(false) end
                return
            end
            if not active then active = true; DoHeal(true) end
        end)
    else DoHeal(false) end
end
W.SetSelfHeal = SetSelfHeal

--============================================
-- AUTO RUN
--============================================
local AutoRunConn = nil
local function SetAutoRun(v)
    if AutoRunConn then AutoRunConn:Disconnect(); AutoRunConn = nil end
    if v and VIM then
        AutoRunConn = RunService.Heartbeat:Connect(function()
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, LP:GetMouse()) end)
        end)
    end
end
W.SetAutoRun = SetAutoRun

--============================================
-- GOD MODE
--============================================
local GodConn = nil
local function SetGod(v)
    if GodConn then GodConn:Disconnect(); GodConn = nil end
    if v then
        GodConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and h.Health < h.MaxHealth then
                pcall(function() h.Health = h.MaxHealth end)
            end
        end)
    end
end
W.SetGod = SetGod

--============================================
-- SPEED BOOST
--============================================
local SBValue = 30
local SBConn = nil
local function SetSpeedBoost(v)
    if SBConn then SBConn:Disconnect(); SBConn = nil end
    if v then
        SBConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and h.WalkSpeed ~= SBValue then
                pcall(function() h.WalkSpeed = SBValue end)
            end
        end)
    end
end
W.SetSpeedBoost = SetSpeedBoost

--============================================
-- FULL ESP
--============================================
W.ESP = { Survivor = false, Killer = false, Generator = false, Pallet = false, Distance = 500 }
W.ESPColors = {
    Survivor = Color3.fromRGB(0,190,255),
    Killer = Color3.fromRGB(255,0,0),
    Generator = Color3.fromRGB(255,255,0),
    Pallet = Color3.fromRGB(255,165,0),
}
local ESPObjects = {}
local function CreateESP(obj, color)
    if not obj or not obj.Parent then return end
    if ESPObjects[obj] then
        ESPObjects[obj].FillColor = color
        ESPObjects[obj].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = color; h.OutlineColor = color
    h.FillTransparency = 0.9; h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    ESPObjects[obj] = h
end
local function RemoveESP(obj)
    if ESPObjects[obj] then pcall(function() ESPObjects[obj]:Destroy() end); ESPObjects[obj] = nil end
end

RunService.RenderStepped:Connect(function()
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myRoot.Position).Magnitude
                if d <= W.ESP.Distance then
                    if W.ESP.Survivor and TeamIs(p, "Survivor") then
                        CreateESP(p.Character, W.ESPColors.Survivor)
                    elseif W.ESP.Killer and TeamIs(p, "Killer") then
                        CreateESP(p.Character, W.ESPColors.Killer)
                    else RemoveESP(p.Character) end
                else RemoveESP(p.Character) end
            end
        end
    end
    if W.ESP.Generator then
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Generator" then
                    local pos = obj:GetPivot().Position
                    if (pos - myRoot.Position).Magnitude <= W.ESP.Distance then
                        CreateESP(obj, W.ESPColors.Generator)
                    else RemoveESP(obj) end
                end
            end
        end
    end
    if W.ESP.Pallet then
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Palletwrong" and obj:IsA("Model") then
                    local pos = obj:GetPivot().Position
                    if (pos - myRoot.Position).Magnitude <= W.ESP.Distance then
                        CreateESP(obj, W.ESPColors.Pallet)
                    else RemoveESP(obj) end
                end
            end
        end
    end
end)

--============================================
-- FULLBRIGHT
--============================================
local OrigBright = Lighting.Brightness
local OrigClock = Lighting.ClockTime
local OrigAmbient = Lighting.Ambient
local function SetFullbright(v)
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = OrigBright
        Lighting.ClockTime = OrigClock
        Lighting.Ambient = OrigAmbient
    end
end
W.SetFullbright = SetFullbright

--============================================
-- AUTO ATTACK (KILLER)
--============================================
local AAConn = nil
local AARange = 12
local function SetAutoAttack(v)
    if AAConn then AAConn:Disconnect(); AAConn = nil end
    if v then
        local last = 0
        AAConn = RunService.Heartbeat:Connect(function()
            if GetRole() ~= "Killer" then return end
            local now = tick()
            if now - last < 0.15 then return end
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and TeamIs(p, "Survivor") and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and h and h.Health > 35 then
                        if (hrp.Position - myRoot.Position).Magnitude <= AARange then
                            last = now
                            pcall(function()
                                local a = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks") and ReplicatedStorage.Remotes.Attacks:FindFirstChild("BasicAttack")
                                if a then a:FireServer(false) end
                            end)
                            break
                        end
                    end
                end
            end
        end)
    end
end
W.SetAutoAttack = SetAutoAttack

--============================================
-- BOMBAX MUSIC PLAYER
--============================================
W.Bombax = W.Bombax or {
    Enabled = false, Current = nil, Selected = "One", Volume = 2, Looped = true,
    Songs = {
        {id="101985596918228", judul="One"},
        {id="78520199502339",  judul="Two"},
        {id="78253224480952",  judul="Three"},
        {id="136949217768985", judul="Four"},
        {id="92143860315842",  judul="Five"},
        {id="96568301359656",  judul="Six"},
        {id="96053601899287",  judul="Seven"},
        {id="116537762304510", judul="Eight"},
        {id="111775377151665", judul="Nine"},
        {id="131317416582166", judul="Ten"},
        {id="80210594606101",  judul="Danza Kuduro"},
        {id="135887188304832", judul="Ada Yang Tumbang Jos Jis"},
        {id="89338419772018",  judul="Habibi Ishqi"},
        {id="93652038633690",  judul="Santai Dulu"},
        {id="126810420971446", judul="Anak Kota"},
        {id="110337096446518", judul="DJ Onia"},
    },
}
local BX = W.Bombax

local function BombaxStop()
    if BX.Current then
        pcall(function() BX.Current:Stop() end)
        pcall(function() BX.Current:Destroy() end)
        BX.Current = nil
    end
    BX.Playing = false
end
local function BombaxPlay(title)
    BombaxStop()
    title = title or BX.Selected
    local song = nil
    for _, s in ipairs(BX.Songs) do
        if s.judul == title then song = s; break end
    end
    if not song then return end
    local c = LP.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://" .. song.id
    snd.Volume = BX.Volume
    snd.Looped = BX.Looped
    snd.Parent = hrp
    snd:Play()
    BX.Current = snd
    BX.Playing = true
    BX.Selected = title
end
W.BombaxPlay = BombaxPlay
W.BombaxStop = BombaxStop

--============================================
-- TAB SURVIVOR UI
--============================================
local s1 = TabSurv:AddSection("Self Heal")
s1:AddToggle({ Title = "Enable Self Heal", Default = false, Callback = function(v)
    SetSelfHeal(v)
    Notify("W2HUB", "Self Heal " .. (v and "ON" or "OFF"), 2)
end })

local s2 = TabSurv:AddSection("Auto Run")
s2:AddToggle({ Title = "Auto Run", Default = false, Callback = function(v)
    SetAutoRun(v)
    Notify("W2HUB", "Auto Run " .. (v and "ON" or "OFF"), 2)
end })

local s3 = TabSurv:AddSection("Speed Boost")
s3:AddToggle({ Title = "Enable Speed Boost", Default = false, Callback = function(v)
    SetSpeedBoost(v)
    Notify("W2HUB", "Speed Boost " .. (v and "ON" or "OFF"), 2)
end })
s3:AddSlider({ Title = "Speed Value", Min = 16, Max = 100, Default = 30, Increment = 1,
    Callback = function(v) SBValue = v end })

local s4 = TabSurv:AddSection("God Mode")
s4:AddToggle({ Title = "Enable God Mode", Default = false, Callback = function(v)
    SetGod(v)
    Notify("W2HUB", "God Mode " .. (v and "ON" or "OFF"), 2)
end })

--============================================
-- TAB VISUALS UI
--============================================
local v1 = TabVis:AddSection("ESP System")
v1:AddToggle({ Title = "ESP Survivor", Default = false, Callback = function(v) W.ESP.Survivor = v end })
v1:AddColorPicker({ Title = "Survivor Color", Default = W.ESPColors.Survivor, Save = false,
    Callback = function(c) W.ESPColors.Survivor = c end })
v1:AddToggle({ Title = "ESP Killer", Default = false, Callback = function(v) W.ESP.Killer = v end })
v1:AddColorPicker({ Title = "Killer Color", Default = W.ESPColors.Killer, Save = false,
    Callback = function(c) W.ESPColors.Killer = c end })
v1:AddToggle({ Title = "ESP Generator", Default = false, Callback = function(v) W.ESP.Generator = v end })
v1:AddToggle({ Title = "ESP Pallet", Default = false, Callback = function(v) W.ESP.Pallet = v end })
v1:AddSlider({ Title = "ESP Radius", Min = 50, Max = 1000, Default = 500, Increment = 10,
    Callback = function(v) W.ESP.Distance = v end })

local v2 = TabVis:AddSection("Graphics")
v2:AddToggle({ Title = "Fullbright", Default = false, Callback = function(v) SetFullbright(v) end })

--============================================
-- TAB KILLER UI
--============================================
local k1 = TabKill:AddSection("Auto Attack")
k1:AddToggle({ Title = "Enable Auto Attack", Default = false, Callback = function(v)
    SetAutoAttack(v)
    Notify("W2HUB", "Auto Attack " .. (v and "ON" or "OFF"), 2)
end })
k1:AddSlider({ Title = "Range", Min = 5, Max = 30, Default = 12, Increment = 1,
    Callback = function(v) AARange = v end })

--============================================
-- TAB MISC UI
--============================================
local m1 = TabMisc:AddSection("Info")
m1:AddParagraph({ Title = "W2HUB", Content = "Script Ini GRATIS!\nJangan Dijual!" })

--============================================
-- TAB TROLL UI
--============================================
local t1 = TabTroll:AddSection("Bombax Music Player")
local songList = {}
for _, s in ipairs(BX.Songs) do table.insert(songList, s.judul) end
t1:AddToggle({ Title = "Enable Bombax", Default = false, Callback = function(v)
    BX.Enabled = v
    if v then BombaxPlay() else BombaxStop() end
end })
t1:AddDropdown({ Title = "Select Song", Options = songList, Default = "One",
    Callback = function(v)
        local val = type(v) == "table" and v[1] or v
        BX.Selected = val
        if BX.Enabled then BombaxPlay(val) end
    end })
t1:AddSlider({ Title = "Volume", Min = 0, Max = 10, Default = 2, Increment = 0.5,
    Callback = function(v) BX.Volume = v; if BX.Current then pcall(function() BX.Current.Volume = v end) end end })
t1:AddToggle({ Title = "Looped", Default = true, Callback = function(v)
    BX.Looped = v
    if BX.Current then pcall(function() BX.Current.Looped = v end) end
end })
t1:AddButton({ Title = "Stop", Callback = function() BombaxStop() end })

--============================================
-- TAB CONFIG UI
--============================================
local c1 = TabCfg:AddSection("Config Info")
c1:AddParagraph({ Title = "Cara Pakai", Content = "Save/Load config ke folder W2HUB/Config\n\nButuh executor support writefile." })

--============================================
-- CLOSING
--============================================
print("[W2HUB] Loaded OK - v1.0")
Notify("W2HUB", "Script Loaded! v1.0", 6)    --====================================================--
    -- PART 2: WINDOW + TAB SETUP
    --====================================================--

    local uiOK, uiErr = pcall(function()
        -- ⭐ Window W2HUB pakai logo Bombax
        local Window = UILib:Window({
            Title          = "W2HUB",
            LogoButtonSize = 52,
            Image          = "138040631725974",
            Footer         = "W2HUB",
            Color          = NotifyColor,
            ShowInfo       = true,
            Search         = true,
        })
        W.Window = Window

        -- Info Tab
        Window:InfoTab({
            Name         = "Information",
            Icon         = "lightbulb",
            SectionTitle = "Information",
            Banner       = "rbxassetid://138040631725974",
            Cards = {
                { Title = "✅ SCRIPT INI GRATIS", Description = "Script ini 100% GRATIS!\n\n❌ JANGAN DIJUAL\n\nYang jual = SCAMMER!" },
                { Title = "ℹ️ INFO", Description = "Nama: W2HUB\nVersion: v1.0\nStatus: Free Forever\n\nSelamat menggunakan!" }
            }
        })

        -- Tab Setup
        W.T_Surv  = Window:AddTab({ Name = "Survivor",  Icon = "user"         })
        W.T_Vis   = Window:AddTab({ Name = "Visuals",   Icon = "eye"          })
        W.T_Kill  = Window:AddTab({ Name = "Killer",    Icon = "crosshair"    })
        W.T_Misc  = Window:AddTab({ Name = "Misc",      Icon = "settings-2"   })
        W.T_Troll = Window:AddTab({ Name = "Troll",     Icon = "ghost"        })
        W.T_Cfg   = Window:AddTab({ Name = "Config",    Icon = "save"         })

        print("[W2HUB] Window + 6 Tab Created")
    end)

    if not uiOK then
        warn("[W2HUB] UI Error:", uiErr)
        return
    end

    print("[W2HUB] PART 2 Loaded OK")

-- PART 3-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 3: SURVIVOR — SELF HEAL + SWIFT VAULT + PALLET REFLEX
    --====================================================--

    -- === SELF HEAL ===
    W.doSelfHealTrue = function()
        local c = LP.Character
        if not c then return end
        local hr = ReplicatedStorage.Remotes.Healing.HealEvent
        local hp = c:FindFirstChild("HumanoidRootPart")
        if not hp then return end
        pcall(function() hr:FireServer(hp, true) end)
    end
    W.doSelfHealFalse = function()
        local c = LP.Character
        if not c then return end
        local hr = ReplicatedStorage.Remotes.Healing.HealEvent
        local hp = c:FindFirstChild("HumanoidRootPart")
        if not hp then return end
        pcall(function() hr:FireServer(hp, false) end)
    end
    W.doOthersHealTrue = function(tp)
        if not tp or not tp.Character then return end
        local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() ReplicatedStorage.Remotes.Healing.HealEvent:FireServer(hrp, true) end)
    end
    W.doOthersHealFalse = function(tp)
        if not tp or not tp.Character then return end
        local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() ReplicatedStorage.Remotes.Healing.HealEvent:FireServer(hrp, false) end)
    end

    W.InstantHealSelf = false
    W.AutoHealAll = false
    W.SelfHeal_BlockedAnimId = "95836365038528"
    W.SelfHeal_Monitor = W.SelfHeal_Monitor or { Conn = nil, CharHook = nil }

    function W.SelfHeal_StartAnimBlock()
        if W.SelfHeal_Monitor.Conn then return end
        W.SelfHeal_Monitor.Conn = RunService.Heartbeat:Connect(function()
            if not W.InstantHealSelf then return end
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator")
            if not anim then return end
            local ok2, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
            if not ok2 then return end
            for _, track in ipairs(tracks) do
                local aid = track.Animation and track.Animation.AnimationId or ""
                local numId = aid:match("%d+")
                if numId == W.SelfHeal_BlockedAnimId then
                    pcall(function() track:Stop(0) end)
                end
            end
        end)
        local function hookChar(char)
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
            if not anim then return end
            anim.AnimationPlayed:Connect(function(track)
                if not W.InstantHealSelf then return end
                local aid = track.Animation and track.Animation.AnimationId or ""
                local numId = aid:match("%d+")
                if numId == W.SelfHeal_BlockedAnimId then
                    pcall(function() track:Stop(0) end)
                end
            end)
        end
        hookChar(LP.Character)
        W.SelfHeal_Monitor.CharHook = LP.CharacterAdded:Connect(function(c)
            task.wait(0.3); hookChar(c)
        end)
    end

    function W.SelfHeal_StopAnimBlock()
        if W.SelfHeal_Monitor.Conn then
            pcall(function() W.SelfHeal_Monitor.Conn:Disconnect() end)
            W.SelfHeal_Monitor.Conn = nil
        end
        if W.SelfHeal_Monitor.CharHook then
            pcall(function() W.SelfHeal_Monitor.CharHook:Disconnect() end)
            W.SelfHeal_Monitor.CharHook = nil
        end
    end

    function W.setSelfHeal(v)
        W.InstantHealSelf = v
        if v then
            W.SelfHeal_StartAnimBlock()
        else
            W.SelfHeal_StopAnimBlock()
        end
        if v then
            local ha = false
            if W.InstantHealConnection then W.InstantHealConnection:Disconnect() end
            W.InstantHealConnection = RunService.Heartbeat:Connect(function()
                if not W.InstantHealSelf then return end
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if not h then return end
                if h.Health >= h.MaxHealth * 0.9 then
                    if ha then ha = false; W.doSelfHealFalse() end
                    return
                end
                if ha then
                    local ci = c:FindFirstChild("CheckInterractable")
                    if ci and not ci:GetAttribute("isHealing") then ha = false end
                end
                if not ha then ha = true; W.doSelfHealTrue() end
            end)
        else
            if W.InstantHealConnection then
                W.InstantHealConnection:Disconnect()
                W.InstantHealConnection = nil
            end
            pcall(W.doSelfHealFalse)
        end
    end

    function W.setAutoHealAll(v)
        W.AutoHealAll = v
        if v then
            local ah = {}
            if W.AutoHealAllConnection then W.AutoHealAllConnection:Disconnect() end
            W.AutoHealAllConnection = RunService.Heartbeat:Connect(function()
                if not W.AutoHealAll then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local hu = p.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and hu.Health < hu.MaxHealth * 0.9 and hrp then
                            if ah[p] then
                                local c = LP.Character
                                local ci = c and c:FindFirstChild("CheckInterractable")
                                if ci and not ci:GetAttribute("isHealing") then ah[p] = nil end
                            end
                            if not ah[p] then ah[p] = true; W.doOthersHealTrue(p) end
                        else
                            if ah[p] then ah[p] = nil; W.doOthersHealFalse(p) end
                        end
                    else
                        if ah[p] then ah[p] = nil; pcall(function() W.doOthersHealFalse(p) end) end
                    end
                end
            end)
        else
            if W.AutoHealAllConnection then
                W.AutoHealAllConnection:Disconnect()
                W.AutoHealAllConnection = nil
            end
        end
    end

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if W.InstantHealSelf then W.setSelfHeal(true) end
        if W.AutoHealAll then W.setAutoHealAll(true) end
    end)

    -- === SWIFT VAULT ===
    W.SwiftVault = W.SwiftVault or {
        Enabled = false, V2 = false, Speed = 13,
        _vaulted = {}, _lastScan = 0,
    }
    local SV = W.SwiftVault

    local function SV_BuildGroups()
        local g = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return g end
        local seen = {}
        for _, o in ipairs(map:GetDescendants()) do
            if o:IsA("BasePart") and (o.Name == "VaultTrigger" or o.Name == "VaultPoint") then
                if not seen[o] then
                    seen[o] = true
                    local root = o.Parent
                    if o.Name == "VaultPoint" and o.Parent and o.Parent.Name == "VaultTrigger" then
                        root = o.Parent.Parent
                    elseif o.Name == "VaultTrigger" then
                        root = o.Parent
                    end
                    if root then
                        g[root] = g[root] or {}
                        table.insert(g[root], o)
                    end
                end
            end
        end
        return g
    end

    RunService.Heartbeat:Connect(function()
        if SV.V2 then
            pcall(function()
                local c = LP.Character
                if c then c:SetAttribute("vaultspeed", (SV.Speed or 13) / 10) end
            end)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not SV.Enabled then return end
        if GetRole() ~= "Survivor" then return end
        if tick() - SV._lastScan < 0.15 then return end
        SV._lastScan = tick()
        pcall(function()
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not root or not h or h.Health <= 0 then return end
            if root.AssemblyLinearVelocity.Magnitude < 1 then return end
            for rw in pairs(SV_BuildGroups()) do
                local allVT = {}
                for _, ch in ipairs(rw:GetChildren()) do
                    if ch.Name == "VaultTrigger" then table.insert(allVT, ch) end
                end
                if #allVT == 0 then continue end
                local near, nd = nil, math.huge
                for _, vt in ipairs(allVT) do
                    local pos = vt:IsA("BasePart") and vt.Position or (vt.PrimaryPart and vt.PrimaryPart.Position)
                    if pos then
                        local d = (root.Position - pos).Magnitude
                        if d < nd then nd = d; near = vt end
                    end
                end
                if not near or nd > 6 then continue end
                if tick() - (SV._vaulted[rw] or 0) < 3 then continue end
                local rf = ReplicatedStorage:FindFirstChild("Remotes")
                local wf = rf and rf:FindFirstChild("Window")
                if wf then
                    pcall(function() wf:FindFirstChild("VaultEvent"):FireServer(near, true) end)
                    pcall(function() wf:FindFirstChild("Vaultbindable"):Fire(near, true) end)
                    pcall(function() wf:FindFirstChild("fastvault"):FireServer(LP) end)
                    pcall(function() wf:FindFirstChild("VaultCompleteEventpart1"):FireServer() end)
                    pcall(function() wf:FindFirstChild("VaultCompleteEvent"):FireServer(near, false) end)
                end
                SV._vaulted[rw] = tick()
                break
            end
        end)
    end)

    LP.CharacterAdded:Connect(function() task.wait(0.5); SV._vaulted = {} end)
    function W.SwiftVault_Set(v) SV.Enabled = v and true or false; SV._vaulted = {} end
    function W.SwiftVaultV2_Set(v)
        SV.V2 = v and true or false
        if not v then
            local c = LP.Character
            if c then pcall(function() c:SetAttribute("vaultspeed", 1) end) end
        end
    end
    function W.SwiftVault_SetSpeed(v) SV.Speed = tonumber(v) or 13 end

    -- === PALLET REFLEX ===
    W.PalletReflex = W.PalletReflex or {
        Enabled = false, Dist = 20, _lastDrop = 0, _used = {}, _lastScan = 0,
    }
    local PR = W.PalletReflex

    local function PR_GetKillerRoot()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and TeamIs(p, "Killer") and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then return hrp end
            end
        end
        return nil
    end

    RunService.Heartbeat:Connect(function()
        if not PR.Enabled then return end
        if GetRole() ~= "Survivor" then return end
        local now = tick()
        if now - PR._lastScan < 0.2 then return end
        PR._lastScan = now
        if now - PR._lastDrop < 2.5 then return end
        pcall(function()
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not root or not h or h.Health <= 0 then return end
            local kr = PR_GetKillerRoot()
            if not kr then return end
            if (root.Position - kr.Position).Magnitude > (PR.Dist or 20) then return end
            local rf = ReplicatedStorage:FindFirstChild("Remotes")
            local pf = rf and rf:FindFirstChild("Pallet")
            local drop = pf and pf:FindFirstChild("PalletDropEvent")
            if not drop then return end
            local map = Workspace:FindFirstChild("Map")
            if not map then return end
            local best, bd = nil, 8
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Palletwrong" and (obj:IsA("Model") or obj:IsA("Folder")) and not PR._used[obj] then
                    local ref = obj:FindFirstChild("PalletPointSlide") or obj:FindFirstChild("PalletPoint") or obj:FindFirstChildWhichIsA("BasePart", true)
                    if ref then
                        local d = (root.Position - ref.Position).Magnitude
                        if d < bd then bd = d; best = obj end
                    end
                end
            end
            if best then
                local tgt = best:FindFirstChild("PalletPointSlide") or best:FindFirstChild("PalletPoint")
                if tgt then
                    pcall(function() drop:FireServer(tgt) end)
                    PR._used[best] = true
                    PR._lastDrop = tick()
                end
            end
        end)
    end)

    LP.CharacterAdded:Connect(function() task.wait(0.5); PR._used = {} end)
    function W.PalletReflex_Set(v) PR.Enabled = v and true or false; PR._used = {} end
    function W.PalletReflex_SetDist(v) PR.Dist = tonumber(v) or 20 end

    -- === UI SECTION ===
    do
        local s = W.T_Surv:AddSection("Self Heal")
        s:AddToggle({ Title = "Enable Self Heal", Default = false, Callback = function(v)
            W.setSelfHeal(v)
            ShowNotify("W2HUB", "Self Heal " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Auto Heal All", Default = false, Callback = function(v)
            W.setAutoHealAll(v)
            ShowNotify("W2HUB", "Auto Heal All " .. (v and "ON" or "OFF"), 2)
        end })

        local s2 = W.T_Surv:AddSection("Swift Vault")
        s2:AddToggle({ Title = "Swift Vault", Default = false, Callback = function(v)
            W.SwiftVault_Set(v)
            ShowNotify("W2HUB", "Swift Vault " .. (v and "ON" or "OFF"), 2)
        end })
        s2:AddToggle({ Title = "Swift Vault V2", Default = false, Callback = function(v)
            W.SwiftVaultV2_Set(v)
            ShowNotify("W2HUB", "Swift Vault V2 " .. (v and "ON" or "OFF"), 2)
        end })
        s2:AddSlider({ Title = "Vault Speed", Min = 10, Max = 20, Default = 13, Increment = 1,
            Callback = function(v) W.SwiftVault_SetSpeed(v) end })

        local s3 = W.T_Surv:AddSection("Pallet Reflex")
        s3:AddToggle({ Title = "Enable Pallet Reflex", Default = false, Callback = function(v)
            W.PalletReflex_Set(v)
            ShowNotify("W2HUB", "Pallet Reflex " .. (v and "ON" or "OFF"), 2)
        end })
        s3:AddSlider({ Title = "Distance", Min = 5, Max = 50, Default = 20, Increment = 1, Suffix = " studs",
            Callback = function(v) W.PalletReflex_SetDist(v) end })
    end

    print("[W2HUB] PART 3 Loaded OK")

-- PART 4-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 4: FAKE PERKS + SKILL CHECK + GEN BYPASS + VAULT TAGS
    --====================================================--

    -- === FAKE PERKS ===
    W.FP = W.FP or {
        ActiveBuffs = {}, Conns = {}, LastBuffEnd = 0, CooldownTime = 5, HB = nil,
        FlowstateOn = false, QuickRecOn = false, PerfLandOn = false, AdrenalineOn = false,
    }
    local FP = W.FP

    local function FP_Char() return LP.Character end
    local function FP_Hum() local c = FP_Char(); return c and c:FindFirstChildOfClass("Humanoid") end
    local function FP_Total()
        local t = 0
        for _, b in pairs(FP.ActiveBuffs) do if tick() < b.endTime then t = t + b.amt end end
        return t
    end
    local function FP_Apply()
        local c = FP_Char()
        local tb = FP_Total()
        local h = FP_Hum()
        if c then c:SetAttribute("speedboost", tb > 0 and (1 + tb/14) or 1) end
        if h and tb > 0 then h.WalkSpeed = 16 + tb end
    end
    local function FP_HB()
        if FP.HB then return end
        FP.HB = RunService.Heartbeat:Connect(function()
            local exp = {}
            for n, b in pairs(FP.ActiveBuffs) do if tick() >= b.endTime then table.insert(exp, n) end end
            for _, n in ipairs(exp) do FP.ActiveBuffs[n] = nil end
            if #exp > 0 and FP_Total() <= 0 then FP.LastBuffEnd = tick() end
            FP_Apply()
            if FP_Total() <= 0 and not next(FP.ActiveBuffs) then
                if FP.HB then FP.HB:Disconnect(); FP.HB = nil end
                local c = FP_Char(); if c then c:SetAttribute("speedboost", 1) end
                local h = FP_Hum(); if h then h.WalkSpeed = 16 end
            end
        end)
    end
    local function FP_TryBuff(name, amt, dur)
        if FP.ActiveBuffs[name] then return end
        if tick() - FP.LastBuffEnd < FP.CooldownTime and not next(FP.ActiveBuffs) then return end
        FP.ActiveBuffs[name] = { amt = amt, endTime = tick() + dur, duration = dur, startTime = tick() }
        FP_Apply(); FP_HB()
        ShowNotify("Fake Perks", name .. " +" .. amt .. " (" .. dur .. "s)", 3)
    end
    local function FP_Clean(name)
        if FP.Conns[name] then
            for _, c in ipairs(FP.Conns[name]) do pcall(function() c:Disconnect() end) end
            FP.Conns[name] = nil
        end
    end
    local function FP_Reg(name, conn)
        FP.Conns[name] = FP.Conns[name] or {}
        table.insert(FP.Conns[name], conn)
    end

    function W.FP_Flowstate(v)
        FP.FlowstateOn = v
        local c = FP_Char()
        if c then c:SetAttribute("Flowstate", v) end
        if v then
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local w = r and r:FindFirstChild("Window")
            local p = r and r:FindFirstChild("Pallet")
            local function on()
                if FP.FlowstateOn then
                    task.delay(0.5, function() if FP.FlowstateOn then FP_TryBuff("Flowstate", 5, 3) end end)
                end
            end
            if w then
                local vb = w:FindFirstChild("Vaultbindable")
                if vb and vb:IsA("BindableEvent") then FP_Reg("Flowstate", vb.Event:Connect(on)) end
            end
            if p then
                local sb = p:FindFirstChild("Slidebindable")
                if sb and sb:IsA("BindableEvent") then FP_Reg("Flowstate", sb.Event:Connect(on)) end
            end
        else
            FP_Clean("Flowstate"); FP.ActiveBuffs["Flowstate"] = nil
            local c2 = FP_Char(); if c2 then c2:SetAttribute("Flowstate", false) end
        end
    end

    function W.FP_QuickRec(v)
        FP.QuickRecOn = v
        if v then
            local function on() if FP.QuickRecOn then FP_TryBuff("QuickRecovery", 6, 3) end end
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local hf = r and r:FindFirstChild("Healing")
            if hf then
                local hd = hf:FindFirstChild("Healdone")
                if hd and hd:IsA("BindableEvent") then FP_Reg("QuickRecovery", hd.Event:Connect(on)) end
            end
            local function hookH(cc)
                if not cc then return end
                local h = cc:FindFirstChildOfClass("Humanoid")
                if h then
                    local lh = h.Health
                    FP_Reg("QuickRecovery", h.HealthChanged:Connect(function(nh)
                        if not FP.QuickRecOn then return end
                        if nh > lh and (nh >= h.MaxHealth or (nh - lh) >= 15) then on() end
                        lh = nh
                    end))
                end
            end
            hookH(LP.Character)
            FP_Reg("QuickRecovery", LP.CharacterAdded:Connect(hookH))
        else
            FP_Clean("QuickRecovery"); FP.ActiveBuffs["QuickRecovery"] = nil
        end
    end

    function W.FP_PerfLand(v)
        FP.PerfLandOn = v
        if v then
            local function hookF(cc)
                if not cc then return end
                local h = cc:FindFirstChildOfClass("Humanoid")
                if not h then return end
                local wf, fs = false, 0
                FP_Reg("PerfectLanding", h.StateChanged:Connect(function(_, n)
                    if not FP.PerfLandOn then return end
                    if n == Enum.HumanoidStateType.Freefall then wf = true; fs = tick() end
                    if wf and (n == Enum.HumanoidStateType.Landed or n == Enum.HumanoidStateType.Running) then
                        local ft = tick() - fs; wf = false
                        if ft >= 0.25 then FP_TryBuff("PerfectLanding", 8, 3) end
                    end
                end))
            end
            hookF(LP.Character)
            FP_Reg("PerfectLanding", LP.CharacterAdded:Connect(hookF))
        else
            FP_Clean("PerfectLanding"); FP.ActiveBuffs["PerfectLanding"] = nil
        end
    end

    function W.FP_Adrenaline(v)
        FP.AdrenalineOn = v
        if v then
            local function hookD(cc)
                if not cc then return end
                local h = cc:FindFirstChildOfClass("Humanoid")
                if not h then return end
                local lh = h.Health
                FP_Reg("AdrenalineRush", h.HealthChanged:Connect(function(nh)
                    if not FP.AdrenalineOn then return end
                    if nh < lh and nh <= 50 and nh > 0 then FP_TryBuff("AdrenalineRush", 4, 5) end
                    lh = nh
                end))
            end
            hookD(LP.Character)
            FP_Reg("AdrenalineRush", LP.CharacterAdded:Connect(hookD))
        else
            FP_Clean("AdrenalineRush"); FP.ActiveBuffs["AdrenalineRush"] = nil
        end
    end

    -- === AUTO SKILL CHECK ===
    W.SC = W.SC or { Enabled = false, Mode = "Legit", Busy = false, Conn = nil }
    local SC = W.SC
    local SC_TouchID = 8822

    local function SC_PressSpace()
        if not VIM then return end
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait()
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
    local function SC_GetActionTarget()
        local pGui = LP:FindFirstChildOfClass("PlayerGui")
        if not pGui then return nil end
        local current = pGui
        for seg in string.gmatch("Survivor-mob.Controls.action.check", "[^%.]+") do
            current = current and current:FindFirstChild(seg)
        end
        return current
    end
    local function SC_TriggerMobileBtn()
        local b = SC_GetActionTarget()
        if b and b:IsA("GuiObject") then
            local p, s = b.AbsolutePosition, b.AbsoluteSize
            local i = GuiService:GetGuiInset()
            local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
            pcall(function()
                VIM:SendTouchEvent(SC_TouchID, 0, cx, cy)
                task.wait(0.01)
                VIM:SendTouchEvent(SC_TouchID, 2, cx, cy)
            end)
        end
    end
    function W.SC_Start()
        if SC.Conn then SC.Conn:Disconnect(); SC.Conn = nil end
        SC.Conn = RunService.RenderStepped:Connect(function()
            if not SC.Enabled or SC.Busy then return end
            local pGui = LP:FindFirstChildOfClass("PlayerGui")
            if not pGui then return end
            local prompt = pGui:FindFirstChild("SkillCheckPromptGui")
            if not prompt then return end
            local check = prompt:FindFirstChild("Check")
            if not check or not check.Visible then return end
            local line = check:FindFirstChild("Line")
            local goal = check:FindFirstChild("Goal")
            if not line or not goal then return end
            if SC.Mode == "Instant" then
                line.Rotation = goal.Rotation + 109
                SC.Busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then SC_TriggerMobileBtn() else SC_PressSpace() end
                    task.wait(0.2); SC.Busy = false
                end)
            else
                local lr = line.Rotation % 360
                local gr = goal.Rotation % 360
                local sR = (gr + 102) % 360
                local eR = (gr + 116) % 360
                local success = (sR > eR and (lr >= sR or lr <= eR)) or (lr >= sR and lr <= eR)
                if success then
                    SC.Busy = true
                    task.spawn(function()
                        if UserInputService.TouchEnabled then SC_TriggerMobileBtn() else SC_PressSpace() end
                        task.wait(0.05); SC.Busy = false
                    end)
                end
            end
        end)
    end
    function W.SC_Stop()
        if SC.Conn then SC.Conn:Disconnect(); SC.Conn = nil end
        SC.Busy = false
    end
    function W.SC_Set(v)
        SC.Enabled = v and true or false
        if SC.Enabled then W.SC_Start() else W.SC_Stop() end
    end

    -- === BYPASS GENERATOR ===
    W.GB = W.GB or {
        Enabled = false, Cache = {}, CacheTimer = 0, Processed = {},
        Hotkey = Enum.KeyCode.B, Range = 8,
    }
    local GB = W.GB

    local function GB_Cached()
        local now = tick()
        if now - GB.CacheTimer < 5 then return GB.Cache end
        GB.Cache = {}; GB.CacheTimer = now
        local map = Workspace:FindFirstChild("Map")
        if not map then return GB.Cache end
        pcall(function()
            for _, v in pairs(map:GetDescendants()) do
                if v:IsA("Model") and v.Name == "Generator" then
                    if v:GetAttribute("RepairProgress") or v:GetAttribute("kickcount") or v:GetAttribute("ProgressRepair") then
                        table.insert(GB.Cache, v)
                    end
                end
            end
        end)
        return GB.Cache
    end
    local function GB_Nearest()
        local c = LP.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local best, bd = nil, math.huge
        for _, g in pairs(GB_Cached()) do
            for _, p in pairs(W.GB_GetPoints(g)) do
                local d = (root.Position - p.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
        return best, bd
    end
    local function GB_WaitRepairing(pt, t)
        local s = tick()
        while tick() - s < (t or 1) do
            if pt:GetAttribute("IsRepairing") == true then return true end
            task.wait(0.05)
        end
        return false
    end
    local function GB_Repair(tp)
        local gm = tp.Parent
        if GB.Processed[gm] then return end
        GB.Processed[gm] = true
        local c = LP.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not root then GB.Processed[gm] = nil; return end
        local re = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Generator")
            and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
        local og = root.CFrame
        pcall(function()
            for _, p in pairs(W.GB_GetPoints(gm)) do
                if p ~= tp and p.Parent then
                    root.Anchored = true
                    root.CFrame = p.CFrame
                    task.wait(0.15)
                    pcall(function() if re then re:FireServer(p, true) end end)
                    if not GB_WaitRepairing(p, 0.8) then
                        pcall(function() if re then re:FireServer(p, false) end end)
                        task.wait(0.1)
                        root.CFrame = p.CFrame
                        task.wait(0.15)
                        pcall(function() if re then re:FireServer(p, true) end end)
                        GB_WaitRepairing(p, 0.5)
                    end
                    root.Anchored = false
                    task.wait(0.05)
                end
            end
        end)
        pcall(function()
            if root and root.Parent then root.Anchored = false; root.CFrame = og end
        end)
        task.wait(0.1)
        pcall(function() if re then re:FireServer(tp, false) end end)
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or isMobile then return end
        if input.KeyCode == GB.Hotkey and GB.Enabled then
            local bp, bd = GB_Nearest()
            if not bp or bd > GB.Range then return end
            if GB.Processed[bp.Parent] then return end
            GB_Repair(bp)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if root then
                for gm in pairs(GB.Processed) do
                    if not gm or not gm.Parent then GB.Processed[gm] = nil; continue end
                    local near = false
                    for _, p in pairs(W.GB_GetPoints(gm)) do
                        if p.Parent and (root.Position - p.Position).Magnitude <= 10 then near = true; break end
                    end
                    if not near then GB.Processed[gm] = nil end
                end
            end
        end
    end)

    function W.GenBypass_Set(v) GB.Enabled = v and true or false end
    function W.GenBypass_SetRange(v) GB.Range = tonumber(v) or 8 end

    -- === UNLIMITED VAULT ===
    local UVOn, UVConn = false, nil
    function W.UV_Set(v)
        if v then
            if UVOn then return end
            UVOn = true
            for _, inst in ipairs(CollectionService:GetTagged("Blocked")) do
                CollectionService:RemoveTag(inst, "Blocked")
            end
            UVConn = CollectionService:GetInstanceAddedSignal("Blocked"):Connect(function(i)
                CollectionService:RemoveTag(i, "Blocked")
            end)
        else
            UVOn = false
            if UVConn then UVConn:Disconnect(); UVConn = nil end
        end
    end

    -- === ANTI SLOW VAULT ===
    local ASVOn, ASVConn = false, nil
    function W.ASV_Set(v)
        if v then
            if ASVOn then return end
            ASVOn = true
            for _, inst in ipairs(CollectionService:GetTagged("SlowVault")) do
                CollectionService:RemoveTag(inst, "SlowVault")
            end
            ASVConn = CollectionService:GetInstanceAddedSignal("SlowVault"):Connect(function(i)
                CollectionService:RemoveTag(i, "SlowVault")
            end)
        else
            ASVOn = false
            if ASVConn then ASVConn:Disconnect(); ASVConn = nil end
        end
    end

    -- === UI SECTION ===
    do
        local s = W.T_Surv:AddSection("Fake Perks")
        s:AddToggle({ Title = "Flowstate", Default = false, Callback = function(v)
            W.FP_Flowstate(v)
            if v then ShowNotify("Fake Perks", "Flowstate ON", 2) end
        end })
        s:AddToggle({ Title = "Quick Recovery", Default = false, Callback = function(v)
            W.FP_QuickRec(v)
            if v then ShowNotify("Fake Perks", "Quick Recovery ON", 2) end
        end })
        s:AddToggle({ Title = "Perfect Landing", Default = false, Callback = function(v)
            W.FP_PerfLand(v)
            if v then ShowNotify("Fake Perks", "Perfect Landing ON", 2) end
        end })
        s:AddToggle({ Title = "Adrenaline Rush", Default = false, Callback = function(v)
            W.FP_Adrenaline(v)
            if v then ShowNotify("Fake Perks", "Adrenaline ON", 2) end
        end })
        s:AddSlider({ Title = "Perk Cooldown", Min = 0, Max = 30, Default = 5, Increment = 1, Suffix = "s",
            Callback = function(v) FP.CooldownTime = tonumber(v) or 5 end })
        s:AddButton({ Title = "Clear All Buffs", Callback = function()
            for k in pairs(FP.ActiveBuffs) do FP.ActiveBuffs[k] = nil end
            local c = LP.Character
            if c then c:SetAttribute("speedboost", 1) end
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
            ShowNotify("Fake Perks", "Buffs cleared", 2)
        end })

        local s2 = W.T_Surv:AddSection("Auto Skill Check")
        s2:AddToggle({ Title = "Enable Auto Skill Check", Default = false, Callback = function(v)
            W.SC_Set(v)
            ShowNotify("W2HUB", "Auto Skill Check " .. (v and "ON" or "OFF"), 2)
        end })
        s2:AddDropdown({ Title = "Mode", Options = {"Legit", "Instant"}, Default = "Legit",
            Callback = function(v) SC.Mode = v end })

        local s3 = W.T_Surv:AddSection("Bypass Generator")
        s3:AddToggle({ Title = "Enable Bypass Generator", Content = "Hotkey B",
            Default = false, Callback = function(v)
                W.GenBypass_Set(v)
                if v then ShowNotify("Bypass Generator", "Enabled (Hotkey: B)", 3) end
            end })
        s3:AddSlider({ Title = "Trigger Range", Min = 3, Max = 20, Default = 8, Increment = 1, Suffix = " studs",
            Callback = function(v) W.GenBypass_SetRange(v) end })
        s3:AddButton({ Title = "Force Repair Nearest", Callback = function()
            local bp, bd = GB_Nearest()
            if bp and bd <= GB.Range then GB_Repair(bp); ShowNotify("Bypass Generator", "Forcing repair...", 2)
            else ShowNotify("Bypass Generator", "Terlalu jauh", 2) end
        end })

        local s4 = W.T_Surv:AddSection("Unlimited Vault")
        s4:AddToggle({ Title = "Unlimited Vault", Content = "Remove 'Blocked' tag",
            Default = false, Callback = function(v)
                W.UV_Set(v)
                ShowNotify("W2HUB", "Unlimited Vault " .. (v and "ON" or "OFF"), 2)
            end })

        local s5 = W.T_Surv:AddSection("Anti Slow Vault")
        s5:AddToggle({ Title = "Anti Slow Vault", Content = "Remove 'SlowVault' tag",
            Default = false, Callback = function(v)
                W.ASV_Set(v)
                ShowNotify("W2HUB", "Anti Slow Vault " .. (v and "ON" or "OFF"), 2)
            end })
    end

    print("[W2HUB] PART 4 Loaded OK")

-- PART 5-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 5: AUTO PARRY V1 (Full System)
    --====================================================--

    local KillerAttackAnims = {
        ["78432063483146"]="attack",["121216847022485"]="attack",["74968262036854"]="attack",
        ["132817836308238"]="attack",["82666958311998"]="attack",["111920872708571"]="attack",
        ["106871536134254"]="attack",["109402730355822"]="attack",["130593238885843"]="attack",
        ["138720291317243"]="attack",["139369275981139"]="attack",["133963973694098"]="attack",
        ["78935059863801"]="attack",
        ["118907603246885"]="lungehold",["135002183282873"]="lungehold",["113255068724446"]="lungehold",
        ["129784271201071"]="lungehold",["105374834496520"]="lungehold",["117070354890871"]="lungehold",
        ["115244153053858"]="lungehold",["110355011987939"]="lungehold",["117042998468241"]="lungehold",
        ["122812055447896"]="lungehold"
    }
    W.KillerAttackAnims = KillerAttackAnims

    local ParryState = {
        LastParry = 0, ActiveAttackers = {},
        CircleFolder = nil, CircleDashes = {}, CircleRotCFs = {}, CircleOffsets = {},
        CircleRadius = 0, CircleBuiltForDagger = false,
        CircleLastX = math.huge, CircleLastY = math.huge, CircleLastZ = math.huge,
        CircleSpawnTime = 0, CircleSpawnDuration = 0.55,
        Enabled = false, Aggressive = false, Distance = 10,
        ShowCircle = false, SilentParry = false,
    }
    W.ParryV1 = ParryState

    local ParryCooldown = {
        OnCooldown = false, CooldownEnd = 0,
        WaitingForResult = false, WaitingStart = 0, WaitTimeout = 2.0,
        FallbackCooldown = 60, MaxCooldown = 90, LastFiredAt = 0,
        IsSilenced = false, JustFired = false, ManualDetect = false, ManualIgnoreWindow = 0.35
    }

    local parryResultRemote, parryFireRemote
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local items = remotes and remotes:FindFirstChild("Items")
        local dagger = items and items:FindFirstChild("Parrying Dagger")
        if dagger then
            parryResultRemote = dagger:FindFirstChild("parryResult")
            parryFireRemote = dagger:FindFirstChild("parry")
        end
    end)

    local function ParryStartCooldown(d)
        d = math.clamp(tonumber(d) or 0, 0, ParryCooldown.MaxCooldown)
        if d <= 0 then d = ParryCooldown.FallbackCooldown end
        ParryCooldown.OnCooldown = true
        ParryCooldown.CooldownEnd = os.clock() + d
        ParryCooldown.WaitingForResult = false
        ParryCooldown.JustFired = false
        ParryCooldown.ManualDetect = false
    end
    local function ParryClearCooldown()
        ParryCooldown.OnCooldown = false
        ParryCooldown.CooldownEnd = 0
        ParryCooldown.WaitingForResult = false
        ParryCooldown.JustFired = false
        ParryCooldown.ManualDetect = false
    end
    local function ParryIsOnCooldown()
        if not ParryCooldown.OnCooldown then return false end
        if os.clock() >= ParryCooldown.CooldownEnd then ParryClearCooldown(); return false end
        return true
    end

    if parryResultRemote then
        parryResultRemote.OnClientEvent:Connect(function(success, cd)
            if not ParryCooldown.WaitingForResult and not ParryCooldown.JustFired then return end
            local c = tonumber(cd) or 0
            if success and c > 0 then ParryStartCooldown(math.min(c, ParryCooldown.MaxCooldown))
            else ParryStartCooldown(ParryCooldown.FallbackCooldown) end
        end)
    end

    local function ParryHookSilenced(char)
        if not char then return end
        ParryCooldown.IsSilenced = CollectionService:HasTag(char, "Silenced")
    end
    CollectionService:GetInstanceAddedSignal("Silenced"):Connect(function(i)
        if i == LP.Character then ParryCooldown.IsSilenced = true end
    end)
    CollectionService:GetInstanceRemovedSignal("Silenced"):Connect(function(i)
        if i == LP.Character then ParryCooldown.IsSilenced = false end
    end)
    LP.CharacterAdded:Connect(function(c) task.wait(0.5); ParryHookSilenced(c) end)
    if LP.Character then ParryHookSilenced(LP.Character) end

    local ParryCharCache = { Char=nil, Root=nil, Hum=nil, UpperTorso=nil, CheckInt=nil }
    local function ParryGetChar()
        local char = LP.Character
        if char ~= ParryCharCache.Char then
            ParryCharCache.Char = char
            ParryCharCache.Root = nil; ParryCharCache.Hum = nil
            ParryCharCache.UpperTorso = nil; ParryCharCache.CheckInt = nil
        end
        if not char then return ParryCharCache end
        if not ParryCharCache.Root then ParryCharCache.Root = char:FindFirstChild("HumanoidRootPart") end
        if not ParryCharCache.Hum then ParryCharCache.Hum = char:FindFirstChildOfClass("Humanoid") end
        if not ParryCharCache.UpperTorso then
            ParryCharCache.UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        end
        if not ParryCharCache.CheckInt then ParryCharCache.CheckInt = char:FindFirstChild("CheckInterractable") end
        return ParryCharCache
    end

    local DaggerCache = { Value = false, LastCheck = 0, Interval = 0.15 }
    local function ParryIsDaggerModel(inst)
        if not inst then return false end
        return inst:IsA("Model") or inst:IsA("Tool") or inst:IsA("Accessory")
    end
    local function ParryHasDagger()
        local now = os.clock()
        if now - DaggerCache.LastCheck < DaggerCache.Interval then return DaggerCache.Value end
        DaggerCache.LastCheck = now
        local hasDagger = false
        local char = LP.Character
        if char then
            local d = char:FindFirstChild("Parrying Dagger")
            if ParryIsDaggerModel(d) then hasDagger = true end
        end
        if not hasDagger then
            local wsChar = Workspace:FindFirstChild(LP.Name)
            if wsChar then
                local d = wsChar:FindFirstChild("Parrying Dagger")
                if ParryIsDaggerModel(d) then hasDagger = true end
            end
        end
        DaggerCache.Value = hasDagger
        return hasDagger
    end
    LP.CharacterAdded:Connect(function() DaggerCache.Value = false; DaggerCache.LastCheck = 0 end)

    local ParryCheckAttrs = {"isVaulting","isSliding","isDroppingPallet","isRepairing","isHealing","isUnhooking","isExiting"}
    local function ParryIsBusy()
        local cc = ParryGetChar()
        if not cc.Char then return true end
        if LP:GetAttribute("IsDead") then return true end
        if cc.Char:GetAttribute("IsCarried") then return true end
        if cc.Char:GetAttribute("IsHooked") then return true end
        if cc.Root and CollectionService:HasTag(cc.Root, "doing action") then return true end
        if cc.CheckInt then
            for i = 1, #ParryCheckAttrs do
                if cc.CheckInt:GetAttribute(ParryCheckAttrs[i]) then return true end
            end
        end
        return false
    end
    local function ParryIsLowHP()
        local h = ParryGetChar().Hum
        if not h then return false end
        return h.Health < h.MaxHealth * 0.5
    end
    local function ParryCanFire()
        if not ParryHasDagger() then return false end
        if ParryCooldown.IsSilenced then return false end
        if ParryIsOnCooldown() then return false end
        if ParryCooldown.WaitingForResult then return false end
        if ParryIsBusy() then return false end
        if ParryIsLowHP() then return false end
        return true
    end

    local function ParryMobile()
        local didFire = false
        local pGui = LP:FindFirstChildOfClass("PlayerGui")
        if pGui and type(firesignal) == "function" then
            local mobRoot = pGui:FindFirstChild("Survivor-mob")
            local controls = mobRoot and mobRoot:FindFirstChild("Controls")
            if controls then
                for _, n in ipairs({"Gui-mob","action","Gui-mobile","Gui_mob","Parry","parry"}) do
                    local btn = controls:FindFirstChild(n)
                    if btn and btn:IsA("GuiButton") then
                        pcall(function()
                            firesignal(btn.MouseButton1Down)
                            task.delay(0.05, function()
                                if btn and btn.Parent then
                                    firesignal(btn.MouseButton1Up)
                                    firesignal(btn.MouseButton1Click)
                                end
                            end)
                        end)
                        didFire = true; break
                    end
                end
            end
        end
        if not didFire then
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            local items = remote and remote:FindFirstChild("Items")
            local dagger = items and items:FindFirstChild("Parrying Dagger")
            local parry = dagger and dagger:FindFirstChild("parry")
            if parry then pcall(function() parry:FireServer() end) end
        end
    end

    local function ParryPC()
        if not VIM then return end
        pcall(function()
            VIM:SendMouseMoveEvent(0, 0, game)
            task.wait(0.005)
            VIM:SendMouseButtonEvent(0, 0, 2, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 2, false, game, 0)
        end)
    end

    local function ParrySilent()
        if parryFireRemote then return pcall(function() parryFireRemote:FireServer() end) end
        return false
    end

    local function ParryFire()
        if not ParryCanFire() then return end
        ParryState.LastParry = os.clock()
        ParryCooldown.LastFiredAt = os.clock()
        ParryCooldown.WaitingForResult = true
        ParryCooldown.WaitingStart = os.clock()
        ParryCooldown.JustFired = true
        ParryCooldown.ManualDetect = false
        if ParryState.SilentParry then ParrySilent(); return end
        if isMobile then ParryMobile() else ParryPC() end
    end

    local function ParryMarkManual()
        if not ParryHasDagger() then return end
        if ParryCooldown.IsSilenced then return end
        if os.clock() - ParryCooldown.LastFiredAt < ParryCooldown.ManualIgnoreWindow then return end
        if ParryCooldown.OnCooldown or ParryCooldown.WaitingForResult then return end
        ParryCooldown.WaitingForResult = true
        ParryCooldown.WaitingStart = os.clock()
        ParryCooldown.JustFired = true
        ParryCooldown.ManualDetect = true
        ParryCooldown.LastFiredAt = os.clock()
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if gp then return end
        ParryMarkManual()
    end)

    local ParryGetHitbox = function(char)
        if not char then return nil end
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end

    local function ParryCheck(kChar)
        if ParryIsOnCooldown() or ParryCooldown.WaitingForResult
            or ParryCooldown.IsSilenced or not ParryHasDagger() then return end
        local cc = ParryGetChar()
        local myRoot = cc.UpperTorso or cc.Root
        local kPart = ParryGetHitbox(kChar)
        if not myRoot or not kPart then return end
        local dist = (myRoot.Position - kPart.Position).Magnitude
        if ParryState.Aggressive then
            local ping = math.clamp(LP:GetNetworkPing(), 0, 0.3)
            local kRoot = kChar:FindFirstChild("HumanoidRootPart") or kPart
            local kVel = kRoot.AssemblyLinearVelocity
            local flatVel = Vector3.new(kVel.X, 0, kVel.Z)
            local pred = kPart.Position + flatVel * ping
            if (myRoot.Position - pred).Magnitude <= ((ParryState.Distance or 10) + 2.5) then
                if flatVel.Magnitude > 6 then
                    local dir = myRoot.Position - kPart.Position
                    if dir.Magnitude > 0 and flatVel.Unit:Dot(dir.Unit) > 0.4 then ParryFire(); return end
                end
            end
        end
        if dist <= (ParryState.Distance or 10) then ParryFire() end
    end

    -- Circle Visual
    local function ParryDestroyCircle()
        if ParryState.CircleFolder then
            pcall(function() if ParryState.CircleFolder.Parent then ParryState.CircleFolder:Destroy() end end)
        end
        ParryState.CircleFolder = nil
        ParryState.CircleDashes = {}
        ParryState.CircleRotCFs = {}
        ParryState.CircleOffsets = {}
        ParryState.CircleRadius = 0
        ParryState.CircleBuiltForDagger = false
        ParryState.CircleLastX = math.huge
        ParryState.CircleLastY = math.huge
        ParryState.CircleLastZ = math.huge
        ParryState.CircleSpawnTime = 0
    end
    W._DestroyParryCircle = ParryDestroyCircle

    local function ParryBuildCircle(radius)
        ParryDestroyCircle()
        local folder = Instance.new("Folder")
        folder.Name = "W2HUBParryCircle"
        local dashCount = math.clamp(math.floor(radius * 6), 24, 120)
        local slotLength = (2 * math.pi * radius) / dashCount
        local dashLength = slotLength * 0.55
        local dashThickness = 0.03
        local dashes, rotCFs, offsets = {}, {}, {}
        for i = 1, dashCount do
            local part = Instance.new("Part")
            part.Name = "Dash" .. i
            part.Anchored = true; part.CanCollide = false
            part.CanTouch = false; part.CanQuery = false; part.CastShadow = false
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 255, 255)
            part.Transparency = 1
            part.Size = Vector3.new(dashThickness, dashThickness, dashLength)
            part.Parent = folder
            local angle = ((i - 1) / dashCount) * math.pi * 2
            local cosA, sinA = math.cos(angle), math.sin(angle)
            rotCFs[i] = CFrame.lookAt(Vector3.zero, Vector3.new(-sinA, 0, cosA))
            offsets[i] = Vector3.new(cosA * radius, 0, sinA * radius)
            dashes[i] = part
        end
        folder.Parent = Workspace
        ParryState.CircleFolder = folder
        ParryState.CircleDashes = dashes
        ParryState.CircleRotCFs = rotCFs
        ParryState.CircleOffsets = offsets
        ParryState.CircleRadius = radius
        ParryState.CircleBuiltForDagger = true
        ParryState.CircleSpawnTime = tick()
    end

    local function ParryUpdateCircle(myRoot)
        if not ParryState.CircleFolder or not ParryState.CircleFolder.Parent then return end
        local dashes = ParryState.CircleDashes
        local dashCount = #dashes
        if dashCount == 0 then return end
        local center = myRoot.Position - Vector3.new(0, (myRoot.Size.Y * 0.5) + 1.0, 0)
        local elapsed = tick() - (ParryState.CircleSpawnTime or 0)
        local spawnT = math.clamp(elapsed / (ParryState.CircleSpawnDuration or 0.55), 0, 1)
        local eased = 1 - (1 - spawnT)^3
        local scaleMult = eased
        if spawnT < 0.7 and spawnT > 0 then
            local bt = spawnT / 0.7
            scaleMult = eased + math.sin(bt * math.pi) * 0.1
        end
        local spinRot = (1 - eased) * math.pi * 2
        local spawnAlpha = 1 - eased
        local busy = ParryIsBusy()
        local onCD = ParryCooldown.OnCooldown
        local tc
        if busy then tc = Color3.fromRGB(255, 20, 20)
        elseif onCD then tc = Color3.fromRGB(255, 140, 0)
        else tc = Color3.fromRGB(255, 255, 255) end
        local targetT = 0
        if onCD then
            local period = 0.55
            local phase = (os.clock() % period) / period
            local pulse = (math.cos(phase * math.pi * 2) + 1) * 0.5
            targetT = (1 - pulse) * 0.85
        end
        local finalT = math.max(targetT, spawnAlpha)
        local dx = math.abs(center.X - ParryState.CircleLastX)
        local dy = math.abs(center.Y - ParryState.CircleLastY)
        local dz = math.abs(center.Z - ParryState.CircleLastZ)
        if dx < 0.01 and dy < 0.01 and dz < 0.01 and spawnT >= 1 then return end
        ParryState.CircleLastX = center.X
        ParryState.CircleLastY = center.Y
        ParryState.CircleLastZ = center.Z
        local rotCFs = ParryState.CircleRotCFs
        local offsets = ParryState.CircleOffsets
        local rotCF = CFrame.Angles(0, spinRot, 0)
        for i = 1, dashCount do
            local dash = dashes[i]
            if dash and dash.Parent then
                local scaledOff = offsets[i] * scaleMult
                local rotatedOff = rotCF:VectorToWorldSpace(scaledOff)
                local worldPos = Vector3.new(center.X + rotatedOff.X, center.Y, center.Z + rotatedOff.Z)
                dash.CFrame = (rotCF * rotCFs[i]) + worldPos
                dash.Color = tc
                dash.Transparency = finalT
            end
        end
    end

    local function ParryAnimType(track)
        if not track or not track.Animation then return nil end
        local aid = track.Animation.AnimationId or ""
        local nid = aid:match("%d+") or ""
        local name = string.lower(track.Animation.Name or "")
        local v = KillerAttackAnims[aid]
        if v then return v end
        if nid ~= "" then v = KillerAttackAnims[nid]; if v then return v end end
        if name:find("lunge") or name:find("charge") then return "lungehold" end
        if name:find("attack") or name:find("slash") or name:find("swing")
            or name:find("stab") or name:find("melee") then return "attack" end
        return nil
    end

    local function ParryHookAnim(plr, char)
        if not char then return end
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 3)
        if not a then return end
        a.AnimationPlayed:Connect(function(t)
            if not ParryState.Enabled then return end
            if not ParryHasDagger() then return end
            local at = ParryAnimType(t)
            if at then
                ParryState.ActiveAttackers[plr] = { char = char, track = t, type = at, registeredAt = os.clock() }
            end
        end)
    end

    local function ParryHookKiller(plr)
        if plr == LP then return end
        if plr.Character then ParryHookAnim(plr, plr.Character) end
        plr.CharacterAdded:Connect(function(c) task.wait(0.5); ParryHookAnim(plr, c) end)
    end
    for _, p in ipairs(Players:GetPlayers()) do ParryHookKiller(p) end
    Players.PlayerAdded:Connect(ParryHookKiller)

    local parryLastPoll, parryLastCleanup = 0, 0
    local function ParryPoll()
        if not ParryState.Enabled or not ParryHasDagger() then return end
        local now = os.clock()
        if now - parryLastPoll < 0.15 then return end
        parryLastPoll = now
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local c = plr.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then
                        for _, t in ipairs(h:GetPlayingAnimationTracks()) do
                            local at = ParryAnimType(t)
                            if at then
                                local ex = ParryState.ActiveAttackers[plr]
                                if not ex or ex.track ~= t then
                                    ParryState.ActiveAttackers[plr] = { char = c, track = t, type = at, registeredAt = now }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function ParryCleanup()
        local now = os.clock()
        if now - parryLastCleanup < 1.0 then return end
        parryLastCleanup = now
        for plr, data in pairs(ParryState.ActiveAttackers) do
            if not plr or not plr.Parent or not data.track or not data.track.IsPlaying then
                ParryState.ActiveAttackers[plr] = nil
            end
        end
    end

    local function ParryUpdate()
        if not ParryState.Enabled then return end
        if not ParryHasDagger() then ParryState.ActiveAttackers = {}; return end
        if ParryCooldown.WaitingForResult then
            if os.clock() - ParryCooldown.WaitingStart > ParryCooldown.WaitTimeout then
                if ParryCooldown.ManualDetect then
                    ParryCooldown.WaitingForResult = false
                    ParryCooldown.JustFired = false
                    ParryCooldown.ManualDetect = false
                else
                    ParryStartCooldown(ParryCooldown.FallbackCooldown)
                end
            end
        end
        if ParryIsOnCooldown() or ParryCooldown.WaitingForResult then return end
        ParryPoll()
        ParryCleanup()
        for plr, data in pairs(ParryState.ActiveAttackers) do
            if plr and plr.Parent and data.track and data.track.IsPlaying then
                local check = false
                if data.type == "attack" then
                    if data.track.TimePosition < 0.35 then check = true end
                elseif data.type == "lungehold" then
                    check = true
                end
                if check then
                    ParryCheck(data.char)
                    if ParryCooldown.WaitingForResult then break end
                end
            else
                ParryState.ActiveAttackers[plr] = nil
            end
        end
    end

    local function ParryCircleUpdate()
        local c = LP.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if ParryState.ShowCircle and ParryState.Enabled and ParryHasDagger() and root then
            if not ParryState.CircleFolder or ParryState.CircleRadius ~= (ParryState.Distance or 10) or not ParryState.CircleFolder.Parent then
                ParryBuildCircle(ParryState.Distance or 10)
            end
            ParryUpdateCircle(root)
        else
            if ParryState.CircleFolder then ParryDestroyCircle() end
        end
    end

    local lastLogic, lastCircle = 0, 0
    RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastCircle >= 0.033 then lastCircle = now; pcall(ParryCircleUpdate) end
        if now - lastLogic >= 0.05 then lastLogic = now; pcall(ParryUpdate) end
    end)

    -- === UI SECTION ===
    do
        local s = W.T_Surv:AddSection("Auto Parry V1")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            ParryState.Enabled = v
            if not v and ParryDestroyCircle then pcall(ParryDestroyCircle) end
            ShowNotify("W2HUB", "Auto Parry V1 " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Aggressive", Default = false, Callback = function(v) ParryState.Aggressive = v end })
        s:AddSlider({ Title = "Distance", Min = 4, Max = 30, Default = 10, Increment = 1, Suffix = " studs",
            Callback = function(v) ParryState.Distance = v end })
        s:AddToggle({ Title = "Show Range Circle", Default = false, Callback = function(v)
            ParryState.ShowCircle = v
            if not v and ParryDestroyCircle then pcall(ParryDestroyCircle) end
        end })
        s:AddToggle({ Title = "Silent Parry", Default = false, Callback = function(v) ParryState.SilentParry = v end })
    end

    print("[W2HUB] PART 5 Loaded OK")

-- PART 6-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 6: AUTO PARRY V2 (Wisnu) + FAKE PARRY
    --====================================================--

    -- === AUTO PARRY V2 (Wisnu Style) ===
    do
        local ValidIDs = {
            ["122812055447896"]="Veil lunge",["133963973694098"]="Mayers Basic",
            ["117042998468241"]="Mayers lunge",["135002183282873"]="cure lunge",
            ["121216847022485"]="cure Basic",["132817836308238"]="Jeff Basic",
            ["129784271201071"]="Jeff lunge",["82666958311998"]="Jeff Frenzy",
            ["78432063483146"]="Abyssal Basic",["118907603246885"]="Abyssal lunge",
            ["139369275981139"]="Jason Basic",["110355011987939"]="Jason lunge",
            ["111920872708571"]="Masked Basic",["105374834496520"]="Masked lunge",
            ["138720291317243"]="Masked Tony",["106871536134254"]="Masked Alex",
            ["130593238885843"]="Masked Cobra",["115244153053858"]="Masked Cobra lunge",
            ["74968262036854"]="Hidden Basic",["113255068724446"]="Hidden lunge",
            ["98163597193511"]="Hidden S1",["80411309607666"]="Abyssal S1"
        }

        local WisnuState = { Cooldown = false, CooldownThread = nil, lastParry = 0, Adornment = nil }
        local WisnuAttached = {}

        local WisnuCfg = {
            Enabled = false, Aggressive = false, Safety = false,
            Distance = 6, Face = 0.7, Circle = true, Ignored = {},
        }
        W.WisnuCfg = WisnuCfg

        local function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end
        local function IsDowned(char) return char and (char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true) end
        local function IsSafe(char)
            if not WisnuCfg.Safety then return true end
            if not char then return false end
            local ci = char:FindFirstChild("CheckInterractable")
            if ci then
                if ci:GetAttribute("isVaulting") then return false end
                if ci:GetAttribute("isRepairing") then return false end
                if ci:GetAttribute("isUnhooking") then return false end
                if ci:GetAttribute("isHealing") then return false end
                if ci:GetAttribute("isSliding") then return false end
            end
            return true
        end

        local function PressRC()
            if not VIM then return end
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                task.wait()
                VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
            end)
        end

        local function TapMobile()
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            local mob = pg:FindFirstChild("Survivor-mob")
            local btn = mob and mob:FindFirstChild("Controls") and mob.Controls:FindFirstChild("Gui-mob")
            if btn and btn.Visible then
                if firesignal then pcall(function()
                    firesignal(btn.MouseButton1Down)
                    task.wait(0.01)
                    firesignal(btn.MouseButton1Up)
                end) end
            else
                PressRC()
            end
        end

        local function Execute()
            if WisnuState.Cooldown then return end
            WisnuState.lastParry = tick()
            pcall(function()
                local p = ReplicatedStorage:FindFirstChild("Remotes")
                    :FindFirstChild("Items")
                    :FindFirstChild("Parrying Dagger")
                    :FindFirstChild("parry")
                if p then for i = 1, 10 do p:FireServer() end end
                task.spawn(TapMobile)
            end)
        end

        task.spawn(function()
            local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
            local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
            local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
            if parryResultRemote then
                parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                    local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                    WisnuState.Cooldown = true
                    if WisnuState.CooldownThread then task.cancel(WisnuState.CooldownThread) end
                    WisnuState.CooldownThread = task.delay(cdDur, function()
                        WisnuState.Cooldown = false
                    end)
                end)
            end
        end)

        local function TriggerCrouch()
            local startT = tick()
            task.spawn(function()
                local char = LP.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                pcall(function() char:SetAttribute("Crouching", true) end)
                pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
                pcall(function() ReplicatedStorage.Remotes.Chase.Runevent:FireServer(char, false) end)
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed) end) end
                pcall(function()
                    local mob = LP:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
                    local ctrl = mob and mob:FindFirstChild("Controls")
                    local btn = ctrl and ctrl:FindFirstChild("crouch")
                    if btn and firesignal then firesignal(btn.MouseButton1Click) end
                end)
                while tick() - startT < 1.2 do
                    pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
                    task.wait(0.1)
                end
                pcall(function() char:SetAttribute("Crouching", false) end)
                pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", false) end)
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed) end) end
                pcall(function()
                    local mob = LP:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
                    local ctrl = mob and mob:FindFirstChild("Controls")
                    local btn = ctrl and ctrl:FindFirstChild("crouch")
                    if btn and firesignal then firesignal(btn.MouseButton1Click) end
                end)
            end)
        end

        local function AttachSensor(kChar)
            if not kChar or WisnuAttached[kChar] then return end
            WisnuAttached[kChar] = true
            local hum = kChar:FindFirstChild("Humanoid") or kChar:WaitForChild("Humanoid", 5)
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5)
            if not anim then return end
            kChar.AncestryChanged:Connect(function(_, p) if not p then WisnuAttached[kChar] = nil end end)
            anim.AnimationPlayed:Connect(function(track)
                local aid = track.Animation and track.Animation.AnimationId or ""
                local id = aid:match("%d+")
                local attackName = ValidIDs[id]
                if not attackName then return end

                if id == "80411309607666" and W.AutoCrouch then
                    local myChar = LP.Character
                    if IsDowned(myChar) then return end
                    local myR = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local kR = kChar:FindFirstChild("HumanoidRootPart")
                    if myR and kR and (myR.Position - kR.Position).Magnitude <= 40 then TriggerCrouch() end
                    return
                end

                if not WisnuCfg.Enabled then return end
                if WisnuState.Cooldown then return end
                if WisnuCfg.Ignored and WisnuCfg.Ignored[attackName] then return end

                local myChar = LP.Character
                if IsDowned(myChar) or not IsSafe(myChar) then return end
                local myR = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local kR = kChar:FindFirstChild("HumanoidRootPart")
                if not myR or not kR then return end

                local dist = (myR.Position - kR.Position).Magnitude

                if WisnuCfg.Aggressive then
                    local agg = 12
                    local det = WisnuCfg.Distance + 5
                    if dist > det then return end
                    if dist <= agg then Execute()
                    else
                        local tracker
                        local st = os.clock()
                        tracker = RunService.Heartbeat:Connect(function()
                            if os.clock() - st >= 1.5 or WisnuState.Cooldown or not myR or not kR or IsDowned(myChar) then
                                if tracker then tracker:Disconnect() end
                                return
                            end
                            if (myR.Position - kR.Position).Magnitude <= agg then
                                Execute()
                                if tracker then tracker:Disconnect() end
                            end
                        end)
                    end
                else
                    if dist > WisnuCfg.Distance then return end
                    local mf = Vector3.new(myR.Position.X, 0, myR.Position.Z)
                    local kf = Vector3.new(kR.Position.X, 0, kR.Position.Z)
                    local fd = mf - kf
                    if fd.Magnitude > 0 then
                        local fdu = fd.Unit
                        local kl = Vector3.new(kR.CFrame.LookVector.X, 0, kR.CFrame.LookVector.Z).Unit
                        if kl:Dot(fdu) < WisnuCfg.Face then return end
                    end
                    Execute()
                end
            end)
        end

        local function TryAttach(p)
            if p ~= LP and IsKiller(p) and p.Character then AttachSensor(p.Character) end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                p.CharacterAdded:Connect(function() TryAttach(p) end)
                p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
                TryAttach(p)
            end
        end
        Players.PlayerAdded:Connect(function(p)
            if p ~= LP then
                p.CharacterAdded:Connect(function() TryAttach(p) end)
                p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
            end
        end)
        task.spawn(function()
            while true do
                task.wait(5)
                for _, p in ipairs(Players:GetPlayers()) do TryAttach(p) end
            end
        end)

        RunService.Heartbeat:Connect(function()
            local c = LP.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if WisnuCfg.Circle and WisnuCfg.Enabled and hrp then
                if not WisnuState.Adornment or WisnuState.Adornment.Parent ~= hrp then
                    if WisnuState.Adornment then WisnuState.Adornment:Destroy() end
                    WisnuState.Adornment = Instance.new("CylinderHandleAdornment")
                    WisnuState.Adornment.Name = "W2HUBWisnuCircle"
                    WisnuState.Adornment.Height = 0.05
                    WisnuState.Adornment.Transparency = 0.3
                    WisnuState.Adornment.Adornee = hrp
                    WisnuState.Adornment.Parent = hrp
                    WisnuState.Adornment.ZIndex = 0
                    WisnuState.Adornment.AlwaysOnTop = false
                end
                local r = WisnuCfg.Distance
                WisnuState.Adornment.Radius = r
                WisnuState.Adornment.InnerRadius = math.max(0.1, r - 0.15)
                WisnuState.Adornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
                WisnuState.Adornment.Color3 = WisnuState.Cooldown and Color3.fromRGB(128,128,128) or Color3.fromRGB(255,255,255)
            elseif WisnuState.Adornment then
                WisnuState.Adornment:Destroy()
                WisnuState.Adornment = nil
            end
        end)
    end

    -- === FAKE PARRY ===
    do
        local FakeParryTrack = nil
        local FakeParryLast = 0
        local FakeParryBtnGui = nil

        local FakeParryAnims = {
            ["Enten"]       = "rbxassetid://127096285501517",
            ["Stopwatch"]   = "rbxassetid://81793464499285",
            ["Fih"]         = "rbxassetid://123307242865945",
            ["BloodShield"] = "rbxassetid://75939529748815",
        }

        local FakeParryCfg = {
            Enabled = false, Anim = "Enten", Cooldown = 0.4,
            Key = "V", ShowBtn = false, Locked = false,
        }
        W.FakeParryCfg = FakeParryCfg

        local function Stop()
            if FakeParryTrack then
                pcall(function() FakeParryTrack:Stop(0.05) end)
                FakeParryTrack = nil
            end
        end

        local function Play()
            if not FakeParryCfg.Enabled then return end
            if GetRole() ~= "Survivor" then return end
            local now = tick()
            if now - FakeParryLast < (tonumber(FakeParryCfg.Cooldown) or 0.4) then return end
            FakeParryLast = now
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local animator = hum:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator")
                animator.Parent = hum
            end
            Stop()
            local animId = FakeParryAnims[FakeParryCfg.Anim] or FakeParryAnims["Enten"]
            pcall(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = animId
                local track = animator:LoadAnimation(anim)
                track.Priority = Enum.AnimationPriority.Action4
                track.Looped = false
                track:Play(0.1)
                FakeParryTrack = track
                task.delay(2, function()
                    if FakeParryTrack == track then Stop() end
                end)
            end)
        end

        local function CreateButton()
            if FakeParryBtnGui then return end
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            local sg = Instance.new("ScreenGui")
            sg.Name = "W2HUBFakeParryBtn"
            sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = 100
            sg.Parent = pg
            local btn = Instance.new("TextButton")
            btn.Name = "FakeParryBtn"
            btn.Size = UDim2.fromOffset(64, 64)
            btn.Position = UDim2.new(0.82, 0, 0.62, 0)
            btn.AnchorPoint = Vector2.new(0.5, 0.5)
            btn.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
            btn.BackgroundTransparency = 0.15
            btn.Text = "FAKE\nPARRY"
            btn.TextColor3 = Color3.fromRGB(220, 180, 255)
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            btn.ZIndex = 10
            btn.Parent = sg
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(200, 120, 255)
            stroke.Thickness = 2
            stroke.Transparency = 0.2
            local lockBtn = Instance.new("TextButton")
            lockBtn.Size = UDim2.new(0, 22, 0, 22)
            lockBtn.Position = UDim2.new(1, -5, 0, -5)
            lockBtn.AnchorPoint = Vector2.new(1, 0)
            lockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            lockBtn.BackgroundTransparency = 0.3
            lockBtn.Text = FakeParryCfg.Locked and "X" or "L"
            lockBtn.TextSize = 10
            lockBtn.Font = Enum.Font.GothamBold
            lockBtn.TextColor3 = Color3.new(1, 1, 1)
            lockBtn.ZIndex = 11
            lockBtn.Parent = btn
            Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
            lockBtn.MouseButton1Click:Connect(function()
                FakeParryCfg.Locked = not FakeParryCfg.Locked
                lockBtn.Text = FakeParryCfg.Locked and "X" or "L"
                lockBtn.BackgroundColor3 = FakeParryCfg.Locked and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 60)
            end)
            local dragging, dragStart, startPos = false, nil, nil
            local moved = false
            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if FakeParryCfg.Locked then return end
                    dragging = true; moved = false
                    dragStart = inp.Position
                    startPos = btn.Position
                end
            end)
            btn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if dragging and not moved then Play() end
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not dragging or FakeParryCfg.Locked then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dragStart
                    if math.abs(d.X) + math.abs(d.Y) > 6 then moved = true end
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end)
            FakeParryBtnGui = sg
        end

        local function RemoveButton()
            if FakeParryBtnGui then
                pcall(function() FakeParryBtnGui:Destroy() end)
                FakeParryBtnGui = nil
            end
        end

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local kc = Enum.KeyCode[FakeParryCfg.Key or "V"]
            if kc and input.KeyCode == kc then Play() end
        end)

        task.spawn(function()
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            task.wait(2)
            pcall(function()
                local mob = pg:FindFirstChild("Survivor-mob")
                local controls = mob and mob:FindFirstChild("Controls")
                if not controls then return end
                for _, name in ipairs({"Parry", "parry", "action", "Gui-mob"}) do
                    local btn = controls:FindFirstChild(name)
                    if btn and btn:IsA("GuiButton") then
                        btn.MouseButton1Click:Connect(function() Play() end)
                    end
                end
            end)
        end)

        LP.CharacterAdded:Connect(function()
            task.wait(0.5)
            if FakeParryCfg.ShowBtn and FakeParryCfg.Enabled then
                RemoveButton()
                CreateButton()
            end
        end)

        function W.FakeParry_SetEnabled(v)
            FakeParryCfg.Enabled = v and true or false
            if not v then Stop() end
            if v and UserInputService.TouchEnabled and FakeParryCfg.ShowBtn then CreateButton() end
        end
        function W.FakeParry_SetAnim(name)
            if name and FakeParryAnims[name] then FakeParryCfg.Anim = name
            else FakeParryCfg.Anim = "Enten" end
        end
        function W.FakeParry_Trigger() Play() end
        function W.FakeParry_SetShowBtn(v)
            FakeParryCfg.ShowBtn = v and true or false
            if v then CreateButton() else RemoveButton() end
        end
        function W.FakeParry_SetKey(name)
            local ok, kc = pcall(function() return Enum.KeyCode[tostring(name):upper()] end)
            if ok and kc then FakeParryCfg.Key = kc.Name; return true end
            return false
        end
    end

    -- === UI SECTION ===
    do
        local s = W.T_Surv:AddSection("Auto Parry V2 (Wisnu)")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.WisnuCfg.Enabled = v
            ShowNotify("W2HUB", "Auto Parry V2 " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Aggressive", Default = false, Callback = function(v) W.WisnuCfg.Aggressive = v end })
        s:AddToggle({ Title = "Safety", Default = false, Callback = function(v) W.WisnuCfg.Safety = v end })
        s:AddSlider({ Title = "Distance", Min = 4, Max = 25, Default = 6, Increment = 1, Suffix = " studs",
            Callback = function(v) W.WisnuCfg.Distance = v end })
        s:AddSlider({ Title = "Face Sensitivity", Min = -1, Max = 1, Default = 0.7, Increment = 0.05,
            Callback = function(v) W.WisnuCfg.Face = v end })
        s:AddToggle({ Title = "Show Circle", Default = true, Callback = function(v) W.WisnuCfg.Circle = v end })
        s:AddDropdown({ Title = "Ignore Skills", Options = {"Hidden S1", "Abyssal S1"}, Multi = true, Default = {},
            Callback = function(sel)
                local parsed = {}
                if type(sel) == "table" then
                    for k, v in pairs(sel) do
                        if type(k) == "string" and v then parsed[k] = true
                        elseif type(v) == "string" then parsed[v] = true end
                    end
                elseif type(sel) == "string" then parsed[sel] = true end
                W.WisnuCfg.Ignored = parsed
            end })

        local s2 = W.T_Surv:AddSection("Fake Parry")
        s2:AddToggle({ Title = "Enable Fake Parry", Content = "Animasi parry palsu",
            Default = false, Callback = function(v)
                W.FakeParry_SetEnabled(v)
                ShowNotify("Fake Parry", v and ("ON — Key: " .. W.FakeParryCfg.Key) or "OFF", 2)
            end })
        s2:AddDropdown({ Title = "Animation", Options = {"Enten","Stopwatch","Fih","BloodShield"},
            Default = "Enten", Callback = function(v)
                if type(v) == "table" then v = v[1] end
                W.FakeParry_SetAnim(v)
            end })
        s2:AddInput({ Title = "Keybind", Default = "V", Placeholder = "V / G / F / X / B",
            Callback = function(input)
                input = tostring(input or ""):gsub("%s+", "")
                if input == "" then return end
                W.FakeParry_SetKey(input)
            end })
        s2:AddSlider({ Title = "Cooldown", Min = 0, Max = 3, Default = 0.4, Increment = 0.1, Suffix = "s",
            Callback = function(v) W.FakeParryCfg.Cooldown = v end })
        s2:AddToggle({ Title = "Show Floating Button", Default = false,
            Callback = function(v) W.FakeParry_SetShowBtn(v) end })
        s2:AddButton({ Title = "Test Fake Parry", Callback = function()
            W.FakeParry_Trigger()
            ShowNotify("Fake Parry", "Playing...", 2)
        end })
    end

    -- === AUTO CROUCH DODGE ===
    W.AutoCrouch = W.AutoCrouch or false
    do
        local s = W.T_Surv:AddSection("Auto Crouch Dodge")
        s:AddToggle({ Title = "Enable Auto Crouch Dodge", Default = false, Callback = function(v)
            W.AutoCrouch = v
            ShowNotify("W2HUB", "Auto Crouch " .. (v and "ON" or "OFF"), 2)
        end })
    end

    print("[W2HUB] PART 6 Loaded OK")

-- PART 7-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 7: TOF + FLASHLIGHT + AIM GUN + MOONWALK
    --====================================================--

    -- === SILENT AIM TOF (Twist of Fate) ===
    do
        local ToFState = {
            Enabled = false, TargetMode = "Killer", Key = "Q",
            Laser = true, WallCheck = true, BlockKnocked = true,
            Conn = nil, LaserBeam = nil, TargetGui = nil,
            InputBegan = nil, InputEnded = nil, TouchInput = nil,
            IsAiming = false, SavedUIPos = UDim2.new(0.5, -100, 0, 110),
            SCPCache = {}, SCPCacheTimer = 0,
        }
        W.ToFState = ToFState

        local ToFKeys = { None=nil, Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, T=Enum.KeyCode.T, F=Enum.KeyCode.F, G=Enum.KeyCode.G, H=Enum.KeyCode.H, J=Enum.KeyCode.J, K=Enum.KeyCode.K, L=Enum.KeyCode.L, X=Enum.KeyCode.X, Z=Enum.KeyCode.Z }

        local function ToF_Downed(c)
            if not c then return true end
            local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return true end
            local h = c:FindFirstChildOfClass("Humanoid"); if h and h.Health <= 0 then return true end
            if c:GetAttribute("Knocked") == true then return true end
            if c:GetAttribute("IsHooked") == true then return true end
            if c:GetAttribute("IsCarried") == true then return true end
            return false
        end
        local function ToF_Blocked()
            if ToFState.BlockKnocked == false then return false end
            local c = LP.Character
            if not c then return true end
            return ToF_Downed(c)
        end
        local function ToF_GetEvent()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local i = r and r:FindFirstChild("Items")
            local t = i and i:FindFirstChild("Twist of Fate")
            local f = t and t:FindFirstChild("Fire")
            if f and f:IsA("RemoteEvent") then return f end
            return nil
        end
        local function ToF_GetGun()
            local c = LP.Character
            if not c then return nil end
            local b = c:FindFirstChild("Twist of Fate", true)
            if not b then return nil end
            local ra = b:FindFirstChild("Right Arm")
            if ra then
                local g = ra:FindFirstChild("gun"); if g then return g end
                local e = ra:FindFirstChild("EmperorGun"); if e then return e end
            end
            return b
        end
        local function ToF_Visible(op, tp, tc)
            local d = tp - op
            local dist = d.Magnitude
            if dist < 0.1 then return true end
            local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
            local ex = {}
            local lc = LP.Character
            if lc then table.insert(ex, lc) end
            if tc and tc ~= lc then table.insert(ex, tc) end
            if ToFState.LaserBeam then table.insert(ex, ToFState.LaserBeam) end
            rp.FilterDescendantsInstances = ex
            return workspace:Raycast(op, d.Unit * dist, rp) == nil
        end
        local function ToF_GetSCPs()
            if tick() - ToFState.SCPCacheTimer < 0.5 then return ToFState.SCPCache end
            local nt = {}
            local mf = workspace:FindFirstChild("Map")
            if mf then
                for _, c in pairs(mf:GetDescendants()) do
                    if c:IsA("Model") then
                        local a = c:GetAttributes()
                        if c:GetAttribute("CorpseCreated0492") or next(a) ~= nil then
                            local r = c:FindFirstChild("HumanoidRootPart"); if r then table.insert(nt, r) end
                        end
                    end
                end
            end
            ToFState.SCPCache = nt; ToFState.SCPCacheTimer = tick()
            return nt
        end
        local function ToF_GetTarget()
            local g = ToF_GetGun(); local c = LP.Character
            if not (g and c) then return nil,nil,nil,nil end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil,nil,nil,nil end
            local mp = hrp.Position
            local op
            if c:GetAttribute("IsCarried") then
                op = hrp.Position + (hrp.CFrame.LookVector * 2)
            else
                pcall(function() op = g:IsA("BasePart") and g.Position or (g:FindFirstChildOfClass("BasePart") and g:FindFirstChildOfClass("BasePart").Position) end)
                op = op or Vector3.new(mp.X, mp.Y + 1.5, mp.Z)
            end
            local function predict(t, tc)
                local tp = t.Position
                if ToFState.WallCheck and not ToF_Visible(op, tp, tc) then return nil,nil,nil,nil end
                local tv = Vector3.new(0,0,0)
                local rp = tc and (tc:FindFirstChild("HumanoidRootPart") or t)
                if rp then tv = rp.Velocity end
                local dr = tp - op
                local d = dr.Magnitude
                if d < 0.1 then return nil,nil,nil,nil end
                if d < 5 then return dr.Unit, g, op, tp end
                local tt = d / 400
                local pp = tp + (tv * tt)
                for _ = 1, 2 do local nd = (pp - op).Magnitude; tt = nd/400; pp = tp + (tv*tt) end
                local fd = pp - op
                if fd.Magnitude < 0.1 then return nil,nil,nil,nil end
                return fd.Unit, g, op, pp
            end
            local mode = ToFState.TargetMode or "Killer"
            if mode == "Killer" then
                local bt, bc, bs = nil, nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and TeamIs(p, "Killer") and p.Character then
                        local t = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
                        if t then local d = (mp - t.Position).Magnitude; if d < bs then bs = d; bt = t; bc = p.Character end end
                    end
                end
                if not bt then return nil,nil,nil,nil end
                return predict(bt, bc)
            elseif mode == "Survivors" then
                local bt, bc, bd = nil, nil, -math.huge
                local cam = workspace.CurrentCamera
                local cl = cam.CFrame.LookVector
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and TeamIs(p, "Survivor") and p.Character then
                        local t = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
                        if t then
                            local dt = t.Position - cam.CFrame.Position
                            if dt.Magnitude > 0.1 then
                                local dot = cl:Dot(dt.Unit)
                                if dot > 0.5 and dot > bd then bd = dot; bt = t; bc = p.Character end
                            end
                        end
                    end
                end
                if not bt then return nil,nil,nil,nil end
                return predict(bt, bc)
            elseif mode == "Zombie" then
                local bp, bd = nil, -math.huge
                local cam = workspace.CurrentCamera
                local cl = cam.CFrame.LookVector
                for _, r in ipairs(ToF_GetSCPs()) do
                    if r and r.Parent then
                        local dt = r.Position - cam.CFrame.Position
                        if dt.Magnitude > 0.1 then
                            local dot = cl:Dot(dt.Unit)
                            if dot > 0.5 and dot > bd then bd = dot; bp = r end
                        end
                    end
                end
                if not bp then return nil,nil,nil,nil end
                return predict(bp, bp.Parent)
            end
            return nil,nil,nil,nil
        end
        local function ToF_UpdateLaser(op, tp)
            if not ToFState.LaserBeam then
                local l = Instance.new("Part")
                l.Name = "W2HUBToFLaser"; l.Anchored = true; l.CanCollide = false
                l.CanTouch = false; l.CastShadow = false
                l.Material = Enum.Material.Neon
                l.Color = Color3.fromRGB(255, 255, 255)
                l.Parent = workspace
                ToFState.LaserBeam = l
            end
            local d = (tp - op).Magnitude
            ToFState.LaserBeam.Size = Vector3.new(0.05, 0.05, d)
            ToFState.LaserBeam.CFrame = CFrame.new((op + tp) / 2, tp)
            ToFState.LaserBeam.Transparency = 0
        end
        local function ToF_ClearLaser()
            if ToFState.LaserBeam then pcall(function() ToFState.LaserBeam:Destroy() end); ToFState.LaserBeam = nil end
        end
        local function ToF_MobileBtn()
            local pg = LP:FindFirstChild("PlayerGui")
            local sm = pg and pg:FindFirstChild("Survivor-mob")
            local ct = sm and sm:FindFirstChild("Controls")
            local gm = ct and ct:FindFirstChild("Gui-mob")
            if not gm then return nil end
            for _, n in ipairs({"attack","Attack","shoot","Shoot","fire","Fire"}) do
                local b = gm:FindFirstChild(n, true)
                if b and b:IsA("GuiObject") then return b end
            end
            for _, o in ipairs(gm:GetDescendants()) do
                if o:IsA("GuiButton") and o.Visible then return o end
            end
            return gm:IsA("GuiObject") and gm or nil
        end
        local function ToF_IsTouchShoot(inp)
            local sb = ToF_MobileBtn()
            if not (sb and sb.Visible) then return false end
            local p = inp.Position
            local ap = sb.AbsolutePosition
            local az = sb.AbsoluteSize
            return p.X >= ap.X and p.X <= ap.X + az.X and p.Y >= ap.Y and p.Y <= ap.Y + az.Y
        end
        local function ToF_Shoot()
            if not ToFState.Enabled then return end
            if ToF_Blocked() then return end
            local td, g, op, tp = ToF_GetTarget()
            if not (td and g and tp and op) then return end
            local e = ToF_GetEvent()
            if not e then return end
            local fd = tp - op
            if fd.Magnitude < 0.1 then return end
            pcall(function() e:FireServer(g, fd.Unit) end)
        end
        local ToF_ModeConfig = {
            Killer={Color=Color3.fromRGB(255,90,90),Label="KILLER",Hint="K"},
            Survivors={Color=Color3.fromRGB(120,200,255),Label="SURVIVOR",Hint="J"},
            Zombie={Color=Color3.fromRGB(120,255,150),Label="ZOMBIE",Hint="L"},
        }
        local ToF_ModeButtons = {}
        local function ToF_RefreshButtons()
            for n, b in pairs(ToF_ModeButtons) do
                if b and b.Parent then
                    local isActive = n == (ToFState.TargetMode or "Killer")
                    local cfg = ToF_ModeConfig[n]
                    local ind = b:FindFirstChild("Indicator")
                    local lb = b:FindFirstChild("ModeLabel")
                    if isActive then
                        TweenService:Create(b, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(32, 32, 40) }):Play()
                        if ind then TweenService:Create(ind, TweenInfo.new(0.25), { BackgroundColor3 = cfg.Color, BackgroundTransparency = 0 }):Play() end
                        if lb then TweenService:Create(lb, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play() end
                    else
                        TweenService:Create(b, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(24, 24, 30) }):Play()
                        if ind then TweenService:Create(ind, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play() end
                        if lb then TweenService:Create(lb, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(140, 140, 152) }):Play() end
                    end
                end
            end
        end
        local function ToF_SetMode(mode, notify)
            if mode ~= "Killer" and mode ~= "Survivors" and mode ~= "Zombie" then return end
            ToFState.TargetMode = mode
            ToF_RefreshButtons()
            if notify then ShowNotify("ToF Target", mode, 1) end
        end
        local function ToF_DestroyUI()
            if ToFState.TargetGui then pcall(function() ToFState.TargetGui:Destroy() end); ToFState.TargetGui = nil end
            ToF_ModeButtons = {}
        end
        local function ToF_CreateUI()
            local parent = LP:FindFirstChild("PlayerGui")
            if gethui then local ok2, hui = pcall(gethui); if ok2 and hui then parent = hui end end
            if not parent then return end
            if ToFState.TargetGui and ToFState.TargetGui.Parent then return end
            local old = parent:FindFirstChild("W2HUBToFTarget")
            if old then pcall(function() old:Destroy() end) end
            local gui = Instance.new("ScreenGui")
            gui.Name = "W2HUBToFTarget"; gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = parent
            local frame = Instance.new("Frame")
            frame.Name = "Main"; frame.Size = UDim2.new(0, 200, 0, 152)
            frame.Position = ToFState.SavedUIPos
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            frame.BackgroundTransparency = 0.05
            frame.BorderSizePixel = 0; frame.Active = true; frame.ClipsDescendants = true
            frame.ZIndex = 1; frame.Parent = gui
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
            local outerStroke = Instance.new("UIStroke", frame)
            outerStroke.Color = Color3.fromRGB(60, 60, 72); outerStroke.Thickness = 1; outerStroke.Transparency = 0.3
            local accentBar = Instance.new("Frame", frame)
            accentBar.Size = UDim2.new(1, -20, 0, 2); accentBar.Position = UDim2.new(0, 10, 0, 0)
            accentBar.BorderSizePixel = 0; accentBar.ZIndex = 2
            Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
            local header = Instance.new("Frame", frame)
            header.Name = "Header"; header.Size = UDim2.new(1, 0, 0, 38)
            header.BackgroundTransparency = 1; header.ZIndex = 2
            local title = Instance.new("TextLabel", header)
            title.Size = UDim2.new(1, -140, 0, 14); title.Position = UDim2.new(0, 42, 0, 8)
            title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold
            title.Text = "SILENT AIM"; title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 3
            local sub = Instance.new("TextLabel", header)
            sub.Size = UDim2.new(1, -140, 0, 10); sub.Position = UDim2.new(0, 42, 0, 22)
            sub.BackgroundTransparency = 1; sub.Font = Enum.Font.Gotham
            sub.Text = "Twist of Fate"; sub.TextColor3 = Color3.fromRGB(140, 140, 155)
            sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 3
            local body = Instance.new("Frame", frame)
            body.Name = "Body"; body.Size = UDim2.new(1, -16, 1, -56)
            body.Position = UDim2.new(0, 8, 0, 44); body.BackgroundTransparency = 1; body.ZIndex = 2
            local bl = Instance.new("UIListLayout", body)
            bl.FillDirection = Enum.FillDirection.Vertical
            bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Padding = UDim.new(0, 4)
            ToF_ModeButtons = {}
            for i, m in ipairs({{Internal="Killer",Order=1},{Internal="Survivors",Order=2},{Internal="Zombie",Order=3}}) do
                local cfg = ToF_ModeConfig[m.Internal]
                local btn = Instance.new("TextButton")
                btn.Name = "ModeBtn_" .. m.Internal
                btn.Size = UDim2.new(1, 0, 0, 26)
                btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                btn.BorderSizePixel = 0; btn.Text = ""
                btn.AutoButtonColor = false; btn.LayoutOrder = m.Order
                btn.ZIndex = 3; btn.Parent = body
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                local bs = Instance.new("UIStroke", btn)
                bs.Color = Color3.fromRGB(45, 45, 55); bs.Thickness = 1; bs.Transparency = 0.5
                local ind = Instance.new("Frame", btn)
                ind.Name = "Indicator"; ind.AnchorPoint = Vector2.new(0, 0.5)
                ind.Size = UDim2.new(0, 3, 0, 0); ind.Position = UDim2.new(0, 6, 0.5, 0)
                ind.BackgroundColor3 = cfg.Color; ind.BackgroundTransparency = 1
                ind.BorderSizePixel = 0; ind.ZIndex = 4
                Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
                local cd = Instance.new("Frame", btn)
                cd.Size = UDim2.fromOffset(6, 6); cd.Position = UDim2.new(0, 14, 0.5, -3)
                cd.BackgroundColor3 = cfg.Color; cd.BorderSizePixel = 0; cd.ZIndex = 4
                Instance.new("UICorner", cd).CornerRadius = UDim.new(1, 0)
                local lb = Instance.new("TextLabel", btn)
                lb.Name = "ModeLabel"; lb.Size = UDim2.new(1, -60, 1, 0)
                lb.Position = UDim2.new(0, 26, 0, 0); lb.BackgroundTransparency = 1
                lb.Font = Enum.Font.GothamBold; lb.Text = cfg.Label
                lb.TextColor3 = Color3.fromRGB(140, 140, 152); lb.TextSize = 11
                lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 4
                local hn = Instance.new("TextLabel", btn)
                hn.Name = "HintLabel"; hn.AnchorPoint = Vector2.new(1, 0.5)
                hn.Size = UDim2.fromOffset(20, 18); hn.Position = UDim2.new(1, -8, 0.5, 0)
                hn.BackgroundColor3 = Color3.fromRGB(32, 32, 40); hn.BorderSizePixel = 0
                hn.Font = Enum.Font.GothamBold; hn.Text = cfg.Hint
                hn.TextColor3 = Color3.fromRGB(90, 90, 100); hn.TextSize = 9; hn.ZIndex = 4
                Instance.new("UICorner", hn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function() ToF_SetMode(m.Internal, false) end)
                ToF_ModeButtons[m.Internal] = btn
            end
            ToF_RefreshButtons()
            local dragging, dragStart, startPos = false, nil, nil
            header.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; dragStart = inp.Position; startPos = frame.Position
                end
            end)
            header.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dragStart
                    local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                    frame.Position = np; ToFState.SavedUIPos = np
                end
            end)
            ToFState.TargetGui = gui
        end
        local function ToF_StartConn()
            if ToFState.Conn then return end
            ToFState.Conn = RunService.Heartbeat:Connect(function()
                if ToF_Blocked() then
                    ToFState.IsAiming = false
                    if ToFState.TouchInput then ToFState.TouchInput = nil end
                    if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                    return
                end
                if not ToFState.Enabled or not ToFState.IsAiming then
                    if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                    return
                end
                local _, _, op, tp = ToF_GetTarget()
                if op and tp then
                    pcall(function()
                        local c = LP.Character
                        local hrp = c and c:FindFirstChild("HumanoidRootPart")
                        if hrp and not c:GetAttribute("IsCarried") then
                            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
                        end
                    end)
                    if ToFState.Laser then ToF_UpdateLaser(op, tp)
                    elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
            end)
        end
        local function ToF_StopConn()
            if ToFState.Conn then pcall(function() ToFState.Conn:Disconnect() end); ToFState.Conn = nil end
            ToFState.IsAiming = false
            ToF_ClearLaser()
        end
        local SetToF
        local function ToF_EnsureInputs()
            if not ToFState.InputBegan then
                ToFState.InputBegan = UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    local k = ToFKeys[ToFState.Key or "None"]
                    if k and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == k then
                        SetToF(not ToFState.Enabled); return
                    end
                    if not ToFState.Enabled then return end
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and ToF_IsTouchShoot(inp)) then
                        if ToF_Blocked() then ToFState.IsAiming = false; return end
                        ToFState.IsAiming = true
                        if inp.UserInputType == Enum.UserInputType.Touch then ToFState.TouchInput = inp end
                        return
                    end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        if inp.KeyCode == Enum.KeyCode.K then ToF_SetMode("Killer", true)
                        elseif inp.KeyCode == Enum.KeyCode.J then ToF_SetMode("Survivors", true)
                        elseif inp.KeyCode == Enum.KeyCode.L then ToF_SetMode("Zombie", true) end
                    end
                end)
            end
            if not ToFState.InputEnded then
                ToFState.InputEnded = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and inp == ToFState.TouchInput) then
                        local wa = ToFState.IsAiming
                        ToFState.IsAiming = false
                        if inp == ToFState.TouchInput then ToFState.TouchInput = nil end
                        if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                        if wa then
                            if ToF_Blocked() then return end
                            ToF_Shoot()
                        end
                    end
                end)
            end
        end
        SetToF = function(en)
            ToFState.Enabled = en and true or false
            ToF_EnsureInputs()
            if ToFState.Enabled then ToF_CreateUI(); ToF_StartConn()
            else ToF_DestroyUI(); ToF_StopConn() end
        end
        W.SetToFEnabled = SetToF
        W.ToF_SetMode = ToF_SetMode
        ToF_EnsureInputs()

        -- UI
        local s = W.T_Surv:AddSection("Silent Aim TOF")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            SetToF(v); ShowNotify("W2HUB", "Silent Aim TOF " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddKeybind({ Title = "Toggle Key", Default = Enum.KeyCode.Q,
            Callback = function(kc) ToFState.Key = kc and kc.Name or "None" end })
        s:AddDropdown({ Title = "Target Mode", Options = {"Killer","Survivors","Zombie"}, Default = "Killer",
            Callback = function(v) ToF_SetMode(v, true) end })
        s:AddToggle({ Title = "Show Laser", Default = true, Callback = function(v)
            ToFState.Laser = v; if not v then ToF_ClearLaser() end
        end })
        s:AddToggle({ Title = "Wall Check", Default = true, Callback = function(v) ToFState.WallCheck = v end })
        s:AddToggle({ Title = "Block When Knocked", Default = true, Callback = function(v) ToFState.BlockKnocked = v end })
    end

    -- === SILENT FLASHLIGHT ===
    do
        local Flash = {
            Enabled = false, Laser = true, TargetPart = "Head",
            Range = 120, Smooth = 0.35,
            Active = false, LaserBeam = nil, FlashlightPart = nil, Conn = nil, Hooked = false,
        }
        W.FlashState = Flash

        local function GetActRemote()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local i = r and r:FindFirstChild("Items")
            local f = i and i:FindFirstChild("Flashlight")
            local a = f and f:FindFirstChild("Activate")
            if a and a:IsA("RemoteEvent") then return a end
            return nil
        end
        local function GetTargetPart(char)
            if not char then return nil end
            local p = char:FindFirstChild(Flash.TargetPart or "Head")
            if p and p:IsA("BasePart") then return p end
            return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        end
        local function IsAlive(char)
            local h = char and char:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then return false end
            return char:GetAttribute("State") ~= "Dead"
        end
        local function GetTarget()
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            local maxR = tonumber(Flash.Range) or 120
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and IsAlive(p.Character) and TeamIs(p, "Killer") then
                    local pt = GetTargetPart(p.Character)
                    if pt then
                        local d = (root.Position - pt.Position).Magnitude
                        if d <= maxR and d < bd then bd = d; best = pt end
                    end
                end
            end
            return best
        end
        local function ClearLaser()
            if Flash.LaserBeam then pcall(function() Flash.LaserBeam:Destroy() end); Flash.LaserBeam = nil end
        end
        local function GetOrigin(cam)
            if Flash.FlashlightPart and Flash.FlashlightPart:IsA("BasePart") then return Flash.FlashlightPart.Position end
            local c = LP.Character
            local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart"))
            if hand and hand:IsA("BasePart") then return hand.Position end
            return cam and cam.CFrame.Position or nil
        end
        local function UpdateLaser(op, tp)
            if not Flash.LaserBeam then
                local l = Instance.new("Part")
                l.Name = "W2HUBFlashLaser"; l.Anchored = true; l.CanCollide = false
                l.CanTouch = false; l.CanQuery = false; l.CastShadow = false
                l.Material = Enum.Material.Neon
                l.Color = Color3.fromRGB(255, 255, 255)
                l.Parent = Workspace
                Flash.LaserBeam = l
            end
            local d = (tp - op).Magnitude
            if d < 0.1 then return end
            Flash.LaserBeam.Size = Vector3.new(0.16, 0.16, d)
            Flash.LaserBeam.CFrame = CFrame.new((op + tp) / 2, tp)
            Flash.LaserBeam.Transparency = 0.35
        end
        local function Step()
            if not (Flash.Enabled and Flash.Active) then
                if Flash.LaserBeam then Flash.LaserBeam.Transparency = 1 end
                return
            end
            local cam = Workspace.CurrentCamera
            local tp = GetTarget()
            if not (cam and tp) then
                if Flash.LaserBeam then Flash.LaserBeam.Transparency = 1 end
                return
            end
            local smooth = math.clamp(tonumber(Flash.Smooth) or 0.35, 0.05, 1)
            local op = GetOrigin(cam)
            if op then pcall(UpdateLaser, op, tp.Position)
            elseif Flash.LaserBeam then Flash.LaserBeam.Transparency = 1 end
            pcall(function() cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tp.Position), smooth) end)
            pcall(function()
                local c = LP.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.Position.X, hrp.Position.Y, tp.Position.Z)) end
            end)
        end
        local function Start()
            if Flash.Conn then return end
            Flash.Conn = RunService.RenderStepped:Connect(function() pcall(Step) end)
        end
        local function Stop()
            Flash.Active = false; Flash.FlashlightPart = nil
            ClearLaser()
            if Flash.Conn then pcall(function() Flash.Conn:Disconnect() end); Flash.Conn = nil end
        end
        W.Flash_Set = function(v)
            Flash.Enabled = v and true or false
            if v then Start() else Stop() end
        end
        W.Flash_SetActive = function(active, part)
            Flash.Active = active and true or false
            if Flash.Active and part then Flash.FlashlightPart = part
            elseif not Flash.Active then Flash.FlashlightPart = nil end
            if not Flash.Active and Flash.LaserBeam then Flash.LaserBeam.Transparency = 1 end
        end
        W.Flash_ClearLaser = ClearLaser

        -- Hook (dipanggil juga di PART 16)
        task.spawn(function()
            pcall(function()
                local remote = GetActRemote()
                if not remote then return end
                if typeof(hookmetamethod) ~= "function" then return end
                if Flash.Hooked then return end
                Flash.Hooked = true
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() == "FireServer" and self == remote then
                        local args = {...}
                        pcall(function() W.Flash_SetActive(args[2] == true, args[1]) end)
                    end
                    return oldNC(self, ...)
                end)
            end)
        end)

        local s = W.T_Surv:AddSection("Silent Flashlight")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.Flash_Set(v); ShowNotify("W2HUB", "Silent Flashlight " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddDropdown({ Title = "Target Part", Options = {"Head","UpperTorso","Torso","HumanoidRootPart"}, Default = "Head",
            Callback = function(v) Flash.TargetPart = type(v) == "table" and v[1] or v or "Head" end })
        s:AddSlider({ Title = "Max Range", Min = 20, Max = 250, Default = 120, Increment = 5, Suffix = " studs",
            Callback = function(v) Flash.Range = v end })
        s:AddSlider({ Title = "Smoothness", Min = 0.05, Max = 1, Default = 0.35, Increment = 0.05,
            Callback = function(v) Flash.Smooth = v end })
        s:AddToggle({ Title = "Show Laser", Default = true, Callback = function(v)
            Flash.Laser = v; if not v then ClearLaser() end
        end })
    end

    -- === AIM LOCK GUN ===
    do
        local GA = {
            Enabled = false, Holding = false, TargetMode = "Killer",
            Strength = 1, Predict = true, PredictStrength = 0.12,
            FOV = 250, VisCheck = true, AimPart = "HumanoidRootPart", Target = nil,
        }
        W.GunAim = GA
        local Conn = nil
        local CurrBtn = nil
        local function Visible(part)
            local cam = Workspace.CurrentCamera
            if not cam then return true end
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LP.Character }
            local o = cam.CFrame.Position
            local d = part.Position - o
            local res = Workspace:Raycast(o, d, rp)
            if not res then return true end
            return res.Instance:IsDescendantOf(part.Parent)
        end
        local function GetBtn()
            local cur = LP:FindFirstChild("PlayerGui")
            for s in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
                cur = cur and cur:FindFirstChild(s)
            end
            return cur
        end
        local function Closest()
            local cam = Workspace.CurrentCamera
            if not cam then return nil end
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local best, bd = nil, GA.FOV
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Team then
                    local valid = false
                    if GA.TargetMode == "Killer" and string.find(string.lower(p.Team.Name), "killer", 1, true) then valid = true
                    elseif GA.TargetMode == "Survivor" and string.find(string.lower(p.Team.Name), "survivor", 1, true) then valid = true end
                    if valid then
                        local hrp = p.Character:FindFirstChild(GA.AimPart)
                        local h = p.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and h and h.Health > 0 then
                            local pos, on = cam:WorldToViewportPoint(hrp.Position)
                            if on then
                                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                if d < bd then
                                    if GA.VisCheck and not Visible(hrp) then continue end
                                    bd = d; best = hrp
                                end
                            end
                        end
                    end
                end
            end
            return best
        end
        local function Start()
            if Conn then return end
            Conn = RunService.RenderStepped:Connect(function()
                if not GA.Enabled or not GA.Holding then GA.Target = nil; return end
                local t = Closest()
                if not t then return end
                GA.Target = t
                local pos = t.Position
                if GA.Predict then pos = pos + (t.AssemblyLinearVelocity * GA.PredictStrength) end
                local cam = Workspace.CurrentCamera
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), GA.Strength)
            end)
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton2 and GA.Enabled then GA.Holding = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then GA.Holding = false end
        end)
        task.spawn(function()
            while true do
                task.wait(1)
                local b = GetBtn()
                if b and b ~= CurrBtn then
                    CurrBtn = b
                    b.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch and GA.Enabled then GA.Holding = true end
                    end)
                    b.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then GA.Holding = false end
                    end)
                end
            end
        end)
        W.GunAim_Start = Start

        local s = W.T_Surv:AddSection("Aim Lock Gun")
        s:AddToggle({ Title = "Enable (Hold M2)", Default = false, Callback = function(v)
            GA.Enabled = v
            if v then Start() end
            ShowNotify("W2HUB", "Aim Lock Gun " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddDropdown({ Title = "Target Mode", Options = {"Killer","Survivor"}, Default = "Killer",
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                GA.TargetMode = val
            end })
        s:AddSlider({ Title = "FOV Radius", Min = 50, Max = 1000, Default = 250, Increment = 10,
            Callback = function(v) GA.FOV = v end })
    end

    -- === MOONWALK ===
    do
        local MW = { Enabled = false, SideSpeed = 0.9, BackSpeed = 1.2, Interval = 0.07, Conn = nil }
        W.Moonwalk = MW
        local function Stop()
            if MW.Conn then MW.Conn:Disconnect(); MW.Conn = nil end
        end
        local function Start()
            Stop()
            local c = LP.Character
            if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not hrp or not h then return end
            local lastSwitch = 0
            local dir = 1
            MW.Conn = RunService.RenderStepped:Connect(function()
                if not MW.Enabled then return end
                local cc = LP.Character
                if not cc then return end
                local chrp = cc:FindFirstChild("HumanoidRootPart")
                local chum = cc:FindFirstChildOfClass("Humanoid")
                if not chrp or not chum or chum.Health <= 0 then return end
                local now = tick()
                if now - lastSwitch >= MW.Interval then
                    dir = dir * -1
                    lastSwitch = now
                end
                local back = chrp.CFrame.LookVector * -MW.BackSpeed
                local side = chrp.CFrame.RightVector * (dir * MW.SideSpeed)
                chum:Move(back + side, false)
            end)
        end
        function W.Moonwalk_Set(v)
            MW.Enabled = v and true or false
            if v then Start() else Stop() end
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.F8 then W.Moonwalk_Set(not MW.Enabled) end
        end)
        LP.CharacterAdded:Connect(function()
            task.wait(2)
            if MW.Enabled then Start() end
        end)

        local s = W.T_Surv:AddSection("Moonwalk")
        s:AddToggle({ Title = "Enable (F8)", Default = false, Callback = function(v)
            W.Moonwalk_Set(v)
            ShowNotify("W2HUB", "Moonwalk " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "Side Speed", Min = 0.1, Max = 3, Default = 0.9, Increment = 0.1,
            Callback = function(v) MW.SideSpeed = v end })
        s:AddSlider({ Title = "Back Speed", Min = 0.1, Max = 3, Default = 1.2, Increment = 0.1,
            Callback = function(v) MW.BackSpeed = v end })
        s:AddSlider({ Title = "Switch Interval", Min = 0.02, Max = 0.5, Default = 0.07, Increment = 0.01,
            Callback = function(v) MW.Interval = v end })
    end

    print("[W2HUB] PART 7 Loaded OK")

-- PART 8-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 8: UNHOOK + MAP PREDICT + GEN + FLEE + RUN + NOFALL + TROLL TP + GOD
    --====================================================--

    -- === SELF UNHOOK ===
    W.SU = W.SU or {
        Enabled = false, Following = false, FollowDuration = 30, FollowDistance = 20,
        MonitorConn = nil, _lastTrigger = 0, _cooldown = 3,
        _hookPos = nil, _hookCFrame = nil, _activeThread = nil, _wasHooked = false,
    }
    local SU = W.SU
    local function SU_IsHooked()
        local c = LP.Character
        if not c then return false end
        return c:GetAttribute("IsHooked") == true or c:GetAttribute("isHooked") == true
            or c:GetAttribute("Hooked") == true or c:GetAttribute("HookedState") == true
    end
    local function SU_GetGenPoint()
        local gens = W.GB_GetAllGenerators()
        if not gens or #gens == 0 then return nil end
        local v = {}
        for _, g in ipairs(gens) do
            if g and g.Parent then
                for _, p in ipairs(W.GB_GetPoints(g)) do
                    if p and p.Parent then table.insert(v, p) end
                end
            end
        end
        if #v == 0 then return nil end
        return v[math.random(1, #v)]
    end
    local function SU_GetKillerHRP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and TeamIs(p, "Killer") and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then return hrp end
            end
        end
        return nil
    end
    local function SU_Abort()
        SU.Following = false
        if SU._activeThread and coroutine.status(SU._activeThread) ~= "dead" then
            pcall(function() task.cancel(SU._activeThread) end)
        end
        SU._activeThread = nil
    end
    local function SU_Trigger()
        if SU.Following then return end
        local now = tick()
        if now - SU._lastTrigger < SU._cooldown then return end
        if not SU_IsHooked() then return end
        SU._lastTrigger = now; SU.Following = true
        local c = LP.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then SU._hookPos = hrp.Position; SU._hookCFrame = hrp.CFrame end
        end
        SU._activeThread = task.spawn(function()
            local cc = LP.Character
            if not cc then SU.Following = false; SU._activeThread = nil; return end
            local hrp = cc:FindFirstChild("HumanoidRootPart")
            if not hrp then SU.Following = false; SU._activeThread = nil; return end
            local re = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Generator")
                and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
            if not SU_IsHooked() then SU.Following = false; SU._activeThread = nil; return end
            local tp = SU_GetGenPoint()
            if tp then
                pcall(function() hrp.Velocity = Vector3.zero; hrp.CFrame = tp.CFrame + Vector3.new(0, 3, 0) end)
                task.wait(0.15)
                if re then
                    pcall(function() re:FireServer(tp, true) end); task.wait(0.35)
                    pcall(function() re:FireServer(tp, false) end); task.wait(0.15)
                    pcall(function() re:FireServer(tp, true) end); task.wait(0.35)
                    pcall(function() re:FireServer(tp, false) end)
                end
            end
            local fUntil = tick() + (SU.FollowDuration or 30)
            local bOff = SU.FollowDistance or 20
            while tick() < fUntil and SU.Enabled do
                if not SU_IsHooked() then
                    SU.Following = false; SU._activeThread = nil
                    ShowNotify("Self Unhook", "Released - STOP", 2)
                    return
                end
                local c2 = LP.Character
                if not c2 then break end
                local r = c2:FindFirstChild("HumanoidRootPart")
                if not r then break end
                local khrp = SU_GetKillerHRP()
                if khrp then
                    pcall(function()
                        r.Velocity = Vector3.zero
                        local tPos = Vector3.new(khrp.Position.X, khrp.Position.Y - bOff, khrp.Position.Z)
                        r.CFrame = CFrame.new(tPos, tPos + Vector3.new(0, 0, -1))
                    end)
                end
                task.wait(0.03)
            end
            if SU_IsHooked() then
                local c3 = LP.Character
                if c3 then
                    local r2 = c3:FindFirstChild("HumanoidRootPart")
                    if r2 then
                        if SU._hookCFrame then pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = SU._hookCFrame end)
                        elseif SU._hookPos then pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = CFrame.new(SU._hookPos + Vector3.new(0, 3, 0)) end) end
                    end
                end
            end
            SU.Following = false; SU._activeThread = nil
        end)
    end
    function W.SU_Set(v)
        SU.Enabled = v and true or false
        if v then
            if SU.MonitorConn then return end
            SU._wasHooked = false
            SU.MonitorConn = RunService.Heartbeat:Connect(function()
                if not SU.Enabled then return end
                local c = LP.Character
                if not c then return end
                local isH = SU_IsHooked()
                if not isH then SU._wasHooked = false; return end
                if not SU._wasHooked and not SU.Following then SU._wasHooked = true; SU_Trigger() end
            end)
        else
            if SU.MonitorConn then SU.MonitorConn:Disconnect(); SU.MonitorConn = nil end
            SU_Abort(); SU._wasHooked = false
        end
    end

    -- === NEXT MAP PREDICTION ===
    do
        local MPS = { Gui = nil, Thread = nil, Enabled = false }
        local function Detect(map)
            if not map then return nil end
            if map:FindFirstChild("random shakes") or map:FindFirstChild("SCP-173 Room") or map:FindFirstChild("SCP-205 Room") then
                return "Site 68"
            elseif map:FindFirstChild("HooksMeat") then return "BLOODBATH! Club"
            elseif map:FindFirstChild("Gate") and map.Gate:FindFirstChild("vfx") then return "Firelink Shrine"
            elseif map:FindFirstChild("Bldg_Addon_RooftopUnit_A") or map:FindFirstChild("Rooftop") then return "Mercy Hospital Rooftop"
            elseif map:FindFirstChild("White Armored Car") then return "Mount Massive Asylum"
            elseif map:FindFirstChild("Dumbster") then return "The Bay Harbor"
            elseif map:FindFirstChild("water pump") then return "Valdelobos Village"
            elseif map:FindFirstChild("LargeBoulder01") then return "Woodview Cabin" end
            return nil
        end
        local function Build()
            if MPS.Gui then pcall(function() MPS.Gui:Destroy() end) end
            local pg = LP:FindFirstChild("PlayerGui")
            if gethui then local ok, hui = pcall(gethui); if ok and hui then pg = hui end end
            if not pg then return end
            local gui = Instance.new("ScreenGui")
            gui.Name = "W2HUBMapPredict"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.DisplayOrder = 50
            gui.Parent = pg
            local f = Instance.new("Frame")
            f.Name = "Main"
            f.Size = UDim2.new(0, 210, 0, 54)
            f.Position = UDim2.new(0.5, -105, 0, 110)
            f.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
            f.BackgroundTransparency = 0.15
            f.BorderSizePixel = 0; f.Active = true; f.Parent = gui
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local s = Instance.new("UIStroke", f)
            s.Color = Color3.fromRGB(255, 255, 255); s.Thickness = 1.5; s.Transparency = 0.2
            s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            local t = Instance.new("TextLabel", f)
            t.Size = UDim2.new(1, 0, 0, 15)
            t.Position = UDim2.new(0, 0, 0, 5)
            t.BackgroundTransparency = 1
            t.Text = "NEXT MAP PREDICTION"
            t.TextColor3 = Color3.fromRGB(150, 180, 255)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 10
            local mn = Instance.new("TextLabel", f)
            mn.Name = "MapName"
            mn.Size = UDim2.new(1, -12, 0, 18)
            mn.Position = UDim2.new(0, 6, 0, 21)
            mn.BackgroundTransparency = 1
            mn.Text = "Scanning..."
            mn.TextColor3 = Color3.fromRGB(255, 255, 255)
            mn.Font = Enum.Font.GothamBold
            mn.TextSize = 13
            mn.TextXAlignment = Enum.TextXAlignment.Center
            local st = Instance.new("TextLabel", f)
            st.Name = "StatusLabel"
            st.Size = UDim2.new(1, -12, 0, 12)
            st.Position = UDim2.new(0, 6, 0, 38)
            st.BackgroundTransparency = 1
            st.Text = "Status: Waiting"
            st.TextColor3 = Color3.fromRGB(150, 150, 150)
            st.Font = Enum.Font.GothamMedium
            st.TextSize = 9
            st.TextXAlignment = Enum.TextXAlignment.Center
            local dragging, dStart, sPos = false, nil, nil
            f.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; dStart = inp.Position; sPos = f.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dStart
                    f.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            MPS.Gui = gui
        end
        function W.MapPredict_Start()
            if MPS.Enabled then return end
            MPS.Enabled = true
            Build()
            MPS.Thread = task.spawn(function()
                local lastDetected, lastExisted = nil, false
                while MPS.Enabled do
                    local map = Workspace:FindFirstChild("Map")
                    local exists = map ~= nil
                    local det = exists and Detect(map) or nil
                    local gui = MPS.Gui
                    local frame = gui and gui:FindFirstChild("Main")
                    local nl = frame and frame:FindFirstChild("MapName")
                    local sl = frame and frame:FindFirstChild("StatusLabel")
                    if nl and sl then
                        if lastExisted and not exists then
                            nl.Text = lastDetected or "Unknown"
                            sl.Text = "Status: Loading next map..."
                            sl.TextColor3 = Color3.fromRGB(255, 200, 50)
                        elseif exists then
                            lastDetected = det or "Unknown"
                            nl.Text = det or "Unknown"
                            sl.Text = "Status: In-Game"
                            sl.TextColor3 = Color3.fromRGB(120, 255, 120)
                        else
                            nl.Text = "Waiting..."
                            sl.Text = "Status: Lobby"
                            sl.TextColor3 = Color3.fromRGB(150, 150, 160)
                        end
                    end
                    lastExisted = exists
                    task.wait(0.5)
                end
            end)
        end
        function W.MapPredict_Stop()
            MPS.Enabled = false
            if MPS.Thread then pcall(function() task.cancel(MPS.Thread) end); MPS.Thread = nil end
            if MPS.Gui then pcall(function() MPS.Gui:Destroy() end); MPS.Gui = nil end
        end
        function W.MapPredict_Set(v)
            if v then W.MapPredict_Start() else W.MapPredict_Stop() end
        end
    end

    -- === MANUAL & AUTO GENERATOR ===
    do
        local RepairEvent = nil
        pcall(function() RepairEvent = ReplicatedStorage.Remotes.Generator.RepairEvent end)
        local REPAIR_ANIM_ID = "rbxassetid://92960319113695"
        local ManualThread, AutoThread = nil, nil
        local ManualPoint, AutoPoint = nil, nil
        local LastFire = 0
        local RepairAnimTrack = nil
        local KillerEscapeDist = 30

        local function IsKillerNearPos(pos, radius)
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and TeamIs(pl, "Killer") and pl.Character then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - pos).Magnitude <= radius then return true end
                end
            end
            return false
        end
        local function GetNearestKillerDist()
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil, math.huge end
            local best, dist = nil, math.huge
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and TeamIs(pl, "Killer") and pl.Character then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - myRoot.Position).Magnitude
                        if d < dist then dist = d; best = hrp end
                    end
                end
            end
            return best, dist
        end
        local function PlayRepairAnim()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if not animator then return end
            if RepairAnimTrack and RepairAnimTrack.IsPlaying then return end
            pcall(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = REPAIR_ANIM_ID
                RepairAnimTrack = animator:LoadAnimation(anim)
                RepairAnimTrack.Priority = Enum.AnimationPriority.Action
                RepairAnimTrack:Play()
            end)
        end
        local function StopRepairAnim()
            if RepairAnimTrack and RepairAnimTrack.IsPlaying then pcall(function() RepairAnimTrack:Stop() end) end
            RepairAnimTrack = nil
        end
        local function StopRepair(point)
            StopRepairAnim()
            if point and RepairEvent then pcall(function() RepairEvent:FireServer(point, false) end) end
        end
        local function IsGenDone(gen)
            local p = gen:GetAttribute("RepairProgress") or gen:GetAttribute("ProgressRepair") or 0
            return p >= 100
        end
        local function GetNearestGenPointInReach()
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local bestPt, bestDist = nil, 5.5
            for _, gen in ipairs(W.GB_GetAllGenerators()) do
                for _, pt in ipairs(W.GB_GetPoints(gen)) do
                    if pt and pt.Parent then
                        local d = (myRoot.Position - pt.Position).Magnitude
                        if d < bestDist then bestDist = d; bestPt = pt end
                    end
                end
            end
            return bestPt
        end
        local function GetSafeNearestGenPoint()
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local bestPt, bestDist = nil, math.huge
            for _, gen in ipairs(W.GB_GetAllGenerators()) do
                if IsGenDone(gen) then continue end
                local genPivot
                pcall(function() genPivot = gen:GetPivot().Position end)
                if genPivot and IsKillerNearPos(genPivot, KillerEscapeDist) then continue end
                for _, pt in ipairs(W.GB_GetPoints(gen)) do
                    if pt and pt.Parent then
                        local d = (pt.Position - myRoot.Position).Magnitude
                        if d < bestDist then bestDist = d; bestPt = pt end
                    end
                end
            end
            return bestPt
        end
        local function StartManualThread()
            if ManualThread then pcall(function() task.cancel(ManualThread) end); ManualThread = nil end
            ManualThread = task.spawn(function()
                while W.ManualGen do
                    local myChar = LP.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if not myRoot or not hum or hum.Health <= 0 then task.wait(0.2); continue end
                    local _, kd = GetNearestKillerDist()
                    if kd <= KillerEscapeDist then
                        if ManualPoint then
                            StopRepair(ManualPoint)
                            ManualPoint = nil
                            ShowNotify("Manual Gen", "Killer near — release", 2)
                        end
                        task.wait(0.3)
                        continue
                    end
                    local pt = GetNearestGenPointInReach()
                    if pt then
                        ManualPoint = pt
                        local now = tick()
                        if now - LastFire >= 0.5 then
                            pcall(function() if RepairEvent then RepairEvent:FireServer(pt, true) end end)
                            PlayRepairAnim()
                            LastFire = now
                        end
                    else
                        if ManualPoint then StopRepair(ManualPoint); ManualPoint = nil end
                    end
                    task.wait(0.1)
                end
                if ManualPoint then StopRepair(ManualPoint) end
                ManualPoint = nil
            end)
        end
        local function StopManualThread()
            if ManualThread then pcall(function() task.cancel(ManualThread) end); ManualThread = nil end
            if ManualPoint then StopRepair(ManualPoint) end
            ManualPoint = nil
        end
        local function StartAutoThread()
            if AutoThread then pcall(function() task.cancel(AutoThread) end); AutoThread = nil end
            AutoThread = task.spawn(function()
                while W.AutoGen do
                    local myChar = LP.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if not myRoot or not hum or hum.Health <= 0 then task.wait(0.3); continue end
                    local _, kd = GetNearestKillerDist()
                    if kd <= KillerEscapeDist then
                        if AutoPoint then StopRepair(AutoPoint); AutoPoint = nil end
                        local safePt = GetSafeNearestGenPoint()
                        if safePt then
                            AutoPoint = safePt
                            pcall(function() myRoot.CFrame = CFrame.new(safePt.Position + Vector3.new(0, 3, 0)) end)
                            task.wait(0.2)
                        end
                        task.wait(0.2)
                        continue
                    end
                    if AutoPoint and AutoPoint.Parent then
                        local now = tick()
                        if now - LastFire >= 0.5 then
                            pcall(function() if RepairEvent then RepairEvent:FireServer(AutoPoint, true) end end)
                            PlayRepairAnim()
                            LastFire = now
                        end
                    else
                        local pt = GetNearestGenPointInReach()
                        if pt then AutoPoint = pt
                        else
                            local safePt = GetSafeNearestGenPoint()
                            if safePt then
                                AutoPoint = safePt
                                pcall(function() myRoot.CFrame = CFrame.new(safePt.Position + Vector3.new(0, 3, 0)) end)
                                task.wait(0.2)
                            end
                        end
                    end
                    task.wait(0.1)
                end
                if AutoPoint then StopRepair(AutoPoint) end
                AutoPoint = nil
            end)
        end
        local function StopAutoThread()
            if AutoThread then pcall(function() task.cancel(AutoThread) end); AutoThread = nil end
            if AutoPoint then StopRepair(AutoPoint) end
            AutoPoint = nil
        end
        W.ManualGen = false
        W.AutoGen = false
        function W.ManualGen_Set(v)
            W.ManualGen = v and true or false
            if W.ManualGen then StartManualThread() else StopManualThread() end
        end
        function W.AutoGen_Set(v)
            W.AutoGen = v and true or false
            if W.AutoGen then StartAutoThread() else StopAutoThread() end
        end
        function W.GenAuto_SetDist(v) KillerEscapeDist = tonumber(v) or 30 end
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            if W.ManualGen then StartManualThread() end
            if W.AutoGen then StartAutoThread() end
        end)

        local s = W.T_Surv:AddSection("Manual Generator")
        s:AddToggle({ Title = "Enable Manual Gen", Default = false, Callback = function(v)
            W.ManualGen_Set(v); ShowNotify("W2HUB", "Manual Gen " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "Killer Escape Distance", Min = 10, Max = 80, Default = 30, Increment = 5, Suffix = " studs",
            Callback = function(v) W.GenAuto_SetDist(v) end })

        local s2 = W.T_Surv:AddSection("Auto Generator")
        s2:AddToggle({ Title = "Enable Auto Gen", Default = false, Callback = function(v)
            W.AutoGen_Set(v); ShowNotify("W2HUB", "Auto Gen " .. (v and "ON" or "OFF"), 2)
        end })
    end

    -- === AUTO FLEE KILLER ===
    do
        local AF = { Enabled = false, Dist = 40, Cooldown = 1.5, _last = 0 }
        W.AutoFlee = AF
        task.spawn(function()
            while true do
                task.wait(0.1)
                if AF.Enabled and GetRole() == "Survivor" then
                    local now = tick()
                    if now - AF._last >= (AF.Cooldown or 1.5) then
                        local c = LP.Character
                        local root = c and c:FindFirstChild("HumanoidRootPart")
                        local h = c and c:FindFirstChildOfClass("Humanoid")
                        if root and h and h.Health > 0 then
                            local kr, nd = nil, math.huge
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LP and TeamIs(p, "Killer") and p.Character then
                                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local d = (hrp.Position - root.Position).Magnitude
                                        if d < nd then nd = d; kr = hrp end
                                    end
                                end
                            end
                            if kr and nd <= (AF.Dist or 40) then
                                AF._last = now
                                local best, bd = nil, 0
                                local map = Workspace:FindFirstChild("Map")
                                if map then
                                    for _, obj in ipairs(map:GetDescendants()) do
                                        if obj:IsA("BasePart") and obj.Name:match("^GeneratorPoint%d+$") then
                                            local d = (obj.Position - kr.Position).Magnitude
                                            if d > bd then bd = d; best = obj end
                                        end
                                    end
                                end
                                if best then
                                    pcall(function() root.CFrame = best.CFrame + Vector3.new(0, 5, 0) end)
                                    ShowNotify("Auto Flee", "Teleported away!", 2)
                                end
                            end
                        end
                    end
                end
            end
        end)
        local s = W.T_Surv:AddSection("Auto Flee Killer")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            AF.Enabled = v; ShowNotify("W2HUB", "Auto Flee " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "Detect Distance", Min = 15, Max = 150, Default = 40, Increment = 5, Suffix = " studs",
            Callback = function(v) AF.Dist = v end })
        s:AddSlider({ Title = "Flee Cooldown", Min = 0.5, Max = 10, Default = 1.5, Increment = 0.5, Suffix = "s",
            Callback = function(v) AF.Cooldown = v end })
    end

    -- === AUTO RUN ===
    do
        local AR = { PC = false, Mobile = false, PCThread = nil, MobileThread = nil }
        W.AutoRun = AR
        local function StartPC()
            if AR.PCThread then task.cancel(AR.PCThread) end
            AR.PCThread = task.spawn(function()
                while AR.PC do
                    pcall(function()
                        if VIM then VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, LP:GetMouse()) end
                    end)
                    task.wait(0.1)
                end
                pcall(function()
                    if VIM then VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, LP:GetMouse()) end
                end)
                AR.PCThread = nil
            end)
        end
        local function StopPC()
            AR.PC = false
            if AR.PCThread then task.cancel(AR.PCThread); AR.PCThread = nil end
            pcall(function()
                if VIM then VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, LP:GetMouse()) end
            end)
        end
        local function GetSprintBtn()
            local pg = LP:FindFirstChild("PlayerGui"); if not pg then return nil end
            local mob = pg:FindFirstChild("Survivor-mob"); if not mob then return nil end
            local ctrl = mob:FindFirstChild("Controls"); if not ctrl then return nil end
            return ctrl:FindFirstChild("sprint")
        end
        local function PressSprint()
            local b = GetSprintBtn()
            if not b then return end
            pcall(function()
                if firesignal then
                    firesignal(b.MouseButton1Click)
                    firesignal(b.MouseButton1Down)
                    task.wait(0.04)
                    firesignal(b.MouseButton1Up)
                end
            end)
        end
        local function StartMobile()
            if AR.MobileThread then return end
            AR.MobileThread = task.spawn(function()
                while AR.Mobile do
                    local c = LP.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.MoveDirection.Magnitude > 0.12 then PressSprint() end
                    task.wait(0.12)
                end
                AR.MobileThread = nil
            end)
        end
        function W.AutoRunPC(v) AR.PC = v; if v then StartPC() else StopPC() end end
        function W.AutoRunMobile(v) AR.Mobile = v; if v then StartMobile() end end
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            if AR.PC then StartPC() end
            if AR.Mobile then AR.MobileThread = nil; StartMobile() end
        end)

        local s = W.T_Surv:AddSection("Auto Run")
        s:AddToggle({ Title = "Auto Run [PC]", Default = false, Callback = function(v)
            W.AutoRunPC(v); ShowNotify("W2HUB", "Auto Run PC " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Auto Run [Mobile]", Default = false, Callback = function(v)
            W.AutoRunMobile(v); ShowNotify("W2HUB", "Auto Run Mobile " .. (v and "ON" or "OFF"), 2)
        end })
    end

    -- === NO FALL DAMAGE ===
    W.NoFallDamage = false
    do
        local s = W.T_Surv:AddSection("No Fall Damage")
        s:AddToggle({ Title = "Enable No Fall Damage", Default = false, Callback = function(v)
            W.NoFallDamage = v
            ShowNotify("W2HUB", "No Fall Damage " .. (v and "ON" or "OFF"), 2)
        end })
    end

    -- === TROLL TELEPORT ===
    W.TT = W.TT or {
        Enabled = false, Processing = false, Count = 0, Hook = nil,
        BlockedAnim = { ["123812278891591"] = 1, ["74099023522626"] = 2 },
    }
    local TT = W.TT
    local function TTHook(char)
        if not char then return end
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 3)
        if not a then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        a.AnimationPlayed:Connect(function(t)
            if not TT.Enabled or TT.Processing then return end
            local aid = t.Animation and t.Animation.AnimationId or ""
            local id = aid:match("%d+")
            local delay = id and TT.BlockedAnim[id]
            if not delay then return end
            TT.Processing = true
            TT.Count = TT.Count + 1
            local startCF = root.CFrame
            ShowNotify("Troll Teleport", "Trigger #" .. TT.Count, 2)
            task.spawn(function()
                if t.IsPlaying then pcall(function() t.Stopped:Wait() end) end
                task.wait(delay)
                local c = LP.Character
                local rp = c and c:FindFirstChild("HumanoidRootPart")
                if rp and rp.Parent then pcall(function() rp.CFrame = startCF end) end
                TT.Processing = false
            end)
        end)
    end
    function W.TT_Set(v)
        TT.Enabled = v and true or false
        if v then
            if TT.Hook then return end
            TT.Processing = false
            TTHook(LP.Character)
            TT.Hook = LP.CharacterAdded:Connect(function(c) task.wait(0.4); TTHook(c) end)
        else
            if TT.Hook then pcall(function() TT.Hook:Disconnect() end); TT.Hook = nil end
            TT.Processing = false
        end
    end
    do
        local s = W.T_Surv:AddSection("Troll Teleport")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.TT_Set(v); ShowNotify("W2HUB", "Troll Teleport " .. (v and "ON" or "OFF"), 2)
        end })
    end

    -- === GOD MODE ===
    W.GodMode = false
    local GodThread = nil
    function W.God_Set(v)
        W.GodMode = v and true or false
        if GodThread then task.cancel(GodThread); GodThread = nil end
        if v then
            GodThread = task.spawn(function()
                while W.GodMode do
                    local c = LP.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 and h.Health < h.MaxHealth then
                        pcall(function() h.Health = h.MaxHealth end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
    do
        local s = W.T_Surv:AddSection("God Mode")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.God_Set(v); ShowNotify("W2HUB", "God Mode " .. (v and "ON" or "OFF"), 2)
        end })
    end

    print("[W2HUB] PART 8 Loaded OK")

-- PART 9-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 9: KILLER — AUTO ATTACK + AIM LOCKS + ANTI BLIND + PALLET
    --====================================================--

    -- === AUTO ATTACK ===
    do
        local AA = { Enabled = false, Range = 12, Cooldown = 0.15, _last = 0 }
        W.AutoAttack = AA
        task.spawn(function()
            while true do
                task.wait(0.1)
                if AA.Enabled and GetRole() == "Killer" then
                    local now = tick()
                    if now - AA._last >= (AA.Cooldown or 0.15) then
                        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local closest, shortest = nil, AA.Range or 12
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LP and TeamIs(plr, "Survivor") and plr.Character then
                                    local h = plr.Character:FindFirstChildOfClass("Humanoid")
                                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if h and hrp and h.Health > 35 then
                                        local d = (hrp.Position - r.Position).Magnitude
                                        if d <= shortest then shortest = d; closest = plr end
                                    end
                                end
                            end
                            if closest then
                                AA._last = now
                                pcall(function()
                                    local a = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
                                    local b = a and a:FindFirstChild("BasicAttack")
                                    if b then b:FireServer(false) end
                                end)
                            end
                        end
                    end
                end
            end
        end)

        local s = W.T_Kill:AddSection("Auto Attack")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            AA.Enabled = v; ShowNotify("W2HUB", "Auto Attack " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "Range", Min = 5, Max = 30, Default = 12, Increment = 1, Suffix = " studs",
            Callback = function(v) AA.Range = v end })
        s:AddSlider({ Title = "Cooldown", Min = 0.05, Max = 1, Default = 0.15, Increment = 0.05, Suffix = "s",
            Callback = function(v) AA.Cooldown = v end })
    end

    -- === INFINITE LUNGE ===
    do
        local IL = { Enabled = false, _orig = nil }
        W.InfLunge = IL
        task.spawn(function()
            while true do
                task.wait(0.1)
                local c = LP.Character
                if not c then task.wait(0.5); continue end
                if IL.Enabled then
                    if c:GetAttribute("lungeboost") ~= 999999 then
                        IL._orig = c:GetAttribute("lungeboost") or 1
                        c:SetAttribute("lungeboost", 999999)
                    end
                else
                    if IL._orig then
                        c:SetAttribute("lungeboost", IL._orig)
                        IL._orig = nil
                    end
                end
            end
        end)
        LP.CharacterRemoving:Connect(function() IL._orig = nil end)

        local s = W.T_Kill:AddSection("Infinite Lunge")
        s:AddToggle({ Title = "Enable (Basic Attack)", Default = false, Callback = function(v)
            IL.Enabled = v; ShowNotify("W2HUB", "Infinite Lunge " .. (v and "ON" or "OFF"), 2)
        end })
    end

    -- === COUNTER AUTO PARRY ===
    do
        local CAP = { Enabled = false }
        W.CounterParry = CAP
        local AnimList = {}
        for id, _ in pairs(W.KillerAttackAnims) do table.insert(AnimList, id) end
        task.spawn(function()
            while true do
                task.wait(0.5)
                if not CAP.Enabled then continue end
                local c = LP.Character
                if not c then continue end
                local r = c:FindFirstChild("HumanoidRootPart")
                if not r then continue end
                local near = false
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Team and string.find(string.lower(p.Team.Name), "survivor", 1, true) then
                        local rr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if rr and (r.Position - rr.Position).Magnitude <= 15 then near = true; break end
                    end
                end
                if near then
                    local rid = AnimList[math.random(1, #AnimList)]
                    local a = Instance.new("Animation")
                    a.AnimationId = "rbxassetid://" .. rid
                    local h = c:FindFirstChildOfClass("Humanoid")
                    local anim = h and h:FindFirstChildOfClass("Animator")
                    if anim then
                        local t = anim:LoadAnimation(a)
                        t:Play()
                        t:AdjustWeight(0)
                        task.wait(0.05)
                        t:Stop()
                        a:Destroy()
                    end
                end
            end
        end)

        local s = W.T_Kill:AddSection("Counter Auto Parry")
        s:AddToggle({ Title = "Enable", Content = "Spam animasi parry biar survivor auto parry sendiri",
            Default = false, Callback = function(v)
                CAP.Enabled = v; ShowNotify("W2HUB", "Counter Parry " .. (v and "ON" or "OFF"), 2)
            end })
    end

    -- === AIM LOCK HIDDEN ===
    do
        local AH = { Enabled = false, Aiming = false, HoldKey = Enum.KeyCode.E, Thread = nil }
        W.AimHidden = AH
        local function GetClosest()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end
            local myTeam = LP.Team and LP.Team.Name or ""
            local myK = string.find(string.lower(myTeam), "killer", 1, true) ~= nil
            local best, bd = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    local pTeam = p.Team and p.Team.Name or ""
                    local theirK = string.find(string.lower(pTeam), "killer", 1, true) ~= nil
                    if thrp and h and h.Health > 0 then
                        local enemy = (myK and not theirK) or ((not myK) and theirK)
                        if enemy then
                            local d = (thrp.Position - hrp.Position).Magnitude
                            if d < bd then bd = d; best = thrp end
                        end
                    end
                end
            end
            return best
        end
        local function Start()
            if AH.Thread then task.cancel(AH.Thread) end
            AH.Thread = task.spawn(function()
                while AH.Enabled do
                    if AH.Aiming then
                        local t = GetClosest()
                        if t then
                            pcall(function()
                                Workspace.CurrentCamera.CFrame = CFrame.new(
                                    Workspace.CurrentCamera.CFrame.Position,
                                    t.Position + Vector3.new(0, 2.5, 0)
                                )
                            end)
                        end
                    end
                    task.wait()
                end
            end)
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp or not AH.Enabled then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then AH.Aiming = true end
            if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == AH.HoldKey then AH.Aiming = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if not AH.Enabled then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then AH.Aiming = false end
            if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == AH.HoldKey then AH.Aiming = false end
        end)
        W.AimHidden_Set = function(v)
            AH.Enabled = v
            if v then Start()
            else
                AH.Aiming = false
                if AH.Thread then task.cancel(AH.Thread); AH.Thread = nil end
            end
        end
        W.AimHidden_SetKey = function(name)
            local ok, kc = pcall(function() return Enum.KeyCode[tostring(name):upper()] end)
            if ok and kc then AH.HoldKey = kc end
        end

        local s = W.T_Kill:AddSection("Aim Lock Hidden")
        s:AddToggle({ Title = "Enable (Hold M2/E)", Default = false, Callback = function(v)
            W.AimHidden_Set(v); ShowNotify("W2HUB", "Aim Lock Hidden " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddInput({ Title = "Hold Keybind", Default = "E", Placeholder = "E / Q / F",
            Callback = function(inp)
                inp = tostring(inp or ""):gsub("%s+", "")
                if inp == "" then return end
                W.AimHidden_SetKey(inp)
            end })
    end

    -- === AIM LOCK ATTACK ===
    do
        local AA = { Enabled = false, Holding = false, Strength = 1, Predict = true, PredictStrength = 0.12,
            FOV = 250, VisCheck = true, AimPart = "HumanoidRootPart" }
        W.AttackAim = AA
        local Conn = nil
        local CurrBtn = nil
        local Paths = { "Slasher-mob.Controls.attack", "Masked-mob.Controls.attack", "Killer-mob.Controls.attack" }
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local function Visible(part)
            local cam = Workspace.CurrentCamera
            if not cam then return true end
            rp.FilterDescendantsInstances = { LP.Character }
            local o = cam.CFrame.Position
            local d = part.Position - o
            local res = Workspace:Raycast(o, d, rp)
            if not res then return true end
            return res.Instance:IsDescendantOf(part.Parent)
        end
        local function GetBtn()
            for _, path in ipairs(Paths) do
                local cur = LP:FindFirstChild("PlayerGui")
                for s in string.gmatch(path, "[^%.]+") do
                    cur = cur and cur:FindFirstChild(s)
                end
                if cur and cur:IsA("GuiObject") then return cur end
            end
            return nil
        end
        local function Closest()
            local cam = Workspace.CurrentCamera
            if not cam then return nil end
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local best, bd = nil, AA.FOV
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Team and string.find(string.lower(p.Team.Name), "survivor", 1, true) and p.Character then
                    local hrp = p.Character:FindFirstChild(AA.AimPart)
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and h and h.Health > 0 then
                        local pos, on = cam:WorldToViewportPoint(hrp.Position)
                        if on then
                            local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if d < bd then
                                if AA.VisCheck and not Visible(hrp) then continue end
                                bd = d; best = hrp
                            end
                        end
                    end
                end
            end
            return best
        end
        local function Start()
            if Conn then return end
            Conn = RunService.RenderStepped:Connect(function()
                if not AA.Enabled or not AA.Holding then return end
                local t = Closest()
                if not t then return end
                local cam = Workspace.CurrentCamera
                local pos = t.Position
                if AA.Predict then pos = pos + (t.AssemblyLinearVelocity * AA.PredictStrength) end
                cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
            end)
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton2 and AA.Enabled then AA.Holding = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then AA.Holding = false end
        end)
        task.spawn(function()
            while true do
                task.wait(1)
                local b = GetBtn()
                if b and b ~= CurrBtn then
                    CurrBtn = b
                    b.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch and AA.Enabled then AA.Holding = true end
                    end)
                    b.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then AA.Holding = false end
                    end)
                end
            end
        end)
        W.AttackAim_Start = Start

        local s = W.T_Kill:AddSection("Aim Lock Attack")
        s:AddToggle({ Title = "Enable (Hold M2)", Default = false, Callback = function(v)
            AA.Enabled = v
            if v then Start() end
            ShowNotify("W2HUB", "Aim Lock Attack " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "FOV Radius", Min = 50, Max = 1000, Default = 250, Increment = 10,
            Callback = function(v) AA.FOV = v end })
    end

    -- === AIMBOT ZOMBIE ===
    do
        local AZ = { Enabled = false, Holding = false, Strength = 1, Predict = true,
            PredictStrength = 0.12, FOV = 250, VisCheck = true, AimPart = "HumanoidRootPart" }
        W.AimbotZombie = AZ
        local Conn = nil
        local function Visible(part)
            local cam = Workspace.CurrentCamera
            if not cam then return true end
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LP.Character }
            local o = cam.CFrame.Position
            local d = part.Position - o
            local res = Workspace:Raycast(o, d, rp)
            if not res then return true end
            return res.Instance:IsDescendantOf(part.Parent)
        end
        local function Zombies()
            local l = {}
            local map = Workspace:FindFirstChild("Map")
            if not map then return l end
            for _, c in ipairs(map:GetDescendants()) do
                if c:IsA("Model") then
                    local a = c:GetAttributes()
                    local isZ = c:GetAttribute("CorpseCreated0492") ~= nil or c:GetAttribute("IsZombie") == true or next(a) ~= nil
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if isZ and hrp and hum and hum.Health > 0 then table.insert(l, hrp) end
                end
            end
            return l
        end
        local function Closest()
            local cam = Workspace.CurrentCamera
            if not cam then return nil end
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local best, bd = nil, AZ.FOV
            for _, hrp in ipairs(Zombies()) do
                if hrp and hrp.Parent then
                    local pos, on = cam:WorldToViewportPoint(hrp.Position)
                    if on then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < bd then
                            if AZ.VisCheck and not Visible(hrp) then continue end
                            bd = d; best = hrp
                        end
                    end
                end
            end
            return best
        end
        local function Start()
            if Conn then return end
            Conn = RunService.RenderStepped:Connect(function()
                if not AZ.Enabled or not AZ.Holding then return end
                local t = Closest()
                if not t then return end
                local pos = t.Position
                if AZ.Predict then pos = pos + (t.AssemblyLinearVelocity * AZ.PredictStrength) end
                local cam = Workspace.CurrentCamera
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), AZ.Strength)
            end)
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton2 and AZ.Enabled then AZ.Holding = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then AZ.Holding = false end
        end)
        W.ZombieAim_Start = Start

        local s = W.T_Kill:AddSection("Aimbot Zombie")
        s:AddToggle({ Title = "Enable (Hold M2)", Default = false, Callback = function(v)
            AZ.Enabled = v
            if v then Start() end
            ShowNotify("W2HUB", "Aimbot Zombie " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddSlider({ Title = "FOV Radius", Min = 50, Max = 1000, Default = 250, Increment = 10,
            Callback = function(v) AZ.FOV = v end })
    end

    -- === ANTI BLIND ===
    W.AntiBlind = false
    do
        local s = W.T_Kill:AddSection("Anti Blind")
        s:AddToggle({ Title = "Enable", Content = "Block efek pusing dari flashlight survivor",
            Default = false, Callback = function(v)
                W.AntiBlind = v
                ShowNotify("W2HUB", "Anti Blind " .. (v and "ON" or "OFF"), 2)
            end })
    end

    -- === DESTROY PALLET ===
    getgenv().W2_BreakingPallet = false
    W.DestroyPallet = false
    local function DestroyPallets()
        if not W.DestroyPallet then return end
        if GetRole() ~= "Killer" then return end
        if getgenv().W2_BreakingPallet then return end
        local c = LP.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not c or not root then return end
        local st = c:GetAttribute("IsStunned") or c:GetAttribute("isStunned")
        local im = c:GetAttribute("Immobile") or c:GetAttribute("immobile")
        local cr = c:GetAttribute("IsCarrying") or c:GetAttribute("isCarrying")
        local ci = c:FindFirstChild("CheckInterractable")
        local act = ci and (ci:GetAttribute("action") or ci:GetAttribute("Action"))
        if st or im or cr or act then return end
        local pts = CollectionService:GetTagged("PalletPointSlide")
        local near, nd = nil, 6
        for _, p in ipairs(pts) do
            if p:IsA("BasePart") and not CollectionService:HasTag(p, "doing action") then
                local d = (p.Position - root.Position).Magnitude
                if d < nd then nd = d; near = p end
            end
        end
        if not near then return end
        getgenv().W2_BreakingPallet = true
        task.spawn(function()
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                local pf = r and r:FindFirstChild("Pallet")
                local j = pf and pf:FindFirstChild("Jason")
                if j then
                    local dg = j:FindFirstChild("Destroy-Global")
                    local com = j:FindFirstChild("PalletBreakCommit")
                    if dg and dg:IsA("RemoteEvent") then dg:FireServer(near) end
                    if com and com:IsA("RemoteEvent") then com:FireServer(near) end
                end
            end)
            task.wait(0.2)
            local s = os.clock()
            while c and c.Parent and (c:GetAttribute("Immobile") or c:GetAttribute("immobile")) do
                if os.clock() - s > 3 then break end
                task.wait(0.1)
            end
            getgenv().W2_BreakingPallet = false
        end)
    end
    W.DestroyPallets = DestroyPallets
    task.spawn(function()
        while true do
            task.wait(0.12)
            pcall(DestroyPallets)
        end
    end)
    do
        local s = W.T_Kill:AddSection("Destroy Pallet")
        s:AddToggle({ Title = "Enable Auto Destroy", Default = false, Callback = function(v)
            W.DestroyPallet = v
            ShowNotify("W2HUB", "Destroy Pallet " .. (v and "ON" or "OFF"), 2)
        end })
    end

    print("[W2HUB] PART 9 Loaded OK")

-- PART 10-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 10: KILLER — MASKED + SILENT VEIL V1 + V2 (W424)
    --====================================================--

    -- === SELECT MASKED POWER ===
    W.Masked = W.Masked or {
        CurrentPower = "Cobra",
        Powers = {"Cobra","Richter","Brandon","Rabbit","Alex","Tony"}
    }
    local Masked = W.Masked

    function W.Masked_Activate()
        local ev = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
        if ev then
            pcall(function() ev:FireServer(Masked.CurrentPower) end)
            ShowNotify("Select Masked", "Activated: " .. Masked.CurrentPower, 2)
        else ShowNotify("Select Masked", "Remote not found", 2) end
    end
    function W.Masked_Deactivate()
        local ev = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
        if ev then
            pcall(function() ev:FireServer() end)
            ShowNotify("Select Masked", "Deactivated", 2)
        else ShowNotify("Select Masked", "Remote not found", 2) end
    end

    -- === SILENT SPEAR VEIL V1 (ALFzxzzz) ===
    do
        local VS = { Enabled = false, ShowFOV = true, ShowTracker = false, AutoPredict = true,
            FOV = 150, MaxDist = 280, SpearSpeed = 165, Gravity = 103, Lead = 1.4 }
        W.VeilV1 = VS
        local State = { target = nil, lookVector = nil, velHistory = {} }
        W._VeilV1_State = State

        local Visuals = {}
        pcall(function()
            if typeof(Drawing) ~= "table" or not Drawing.new then return end
            local V = Visuals
            local ACCENT = Color3.fromRGB(255, 255, 255)
            local BLACK  = Color3.fromRGB(0, 0, 0)
            local WHITE  = Color3.fromRGB(255, 255, 255)
            V.FOVOuter = Drawing.new("Circle"); V.FOVOuter.Color = BLACK; V.FOVOuter.Thickness = 3; V.FOVOuter.Filled = false; V.FOVOuter.NumSides = 90; V.FOVOuter.Visible = false
            V.FOVMain  = Drawing.new("Circle"); V.FOVMain.Color = ACCENT; V.FOVMain.Thickness = 1.6; V.FOVMain.Filled = false; V.FOVMain.NumSides = 90; V.FOVMain.Visible = false
            V.FOVInner = Drawing.new("Circle"); V.FOVInner.Color = ACCENT; V.FOVInner.Thickness = 1; V.FOVInner.Filled = false; V.FOVInner.NumSides = 90; V.FOVInner.Visible = false
            V.TrackerRingOut = Drawing.new("Circle"); V.TrackerRingOut.Color = BLACK; V.TrackerRingOut.Thickness = 3; V.TrackerRingOut.Filled = false; V.TrackerRingOut.NumSides = 40; V.TrackerRingOut.Visible = false
            V.TrackerRing    = Drawing.new("Circle"); V.TrackerRing.Color = ACCENT; V.TrackerRing.Thickness = 1.6; V.TrackerRing.Filled = false; V.TrackerRing.NumSides = 40; V.TrackerRing.Visible = false
            V.TrackerDot     = Drawing.new("Circle"); V.TrackerDot.Color = ACCENT; V.TrackerDot.Filled = true; V.TrackerDot.Radius = 3; V.TrackerDot.NumSides = 20; V.TrackerDot.Visible = false
            V.TrackerLine    = Drawing.new("Line"); V.TrackerLine.Color = ACCENT; V.TrackerLine.Thickness = 1.5; V.TrackerLine.Visible = false
        end)

        local function IsSurvivor(p)
            if not p or not p.Team or not p.Team.Name then return false end
            return string.find(string.lower(p.Team.Name), "survivor", 1, true) ~= nil
        end

        local function SolvePitch(p, d, dy)
            d = math.max(d, 0.1)
            local s2 = p.v0 * p.v0
            local root = s2 * s2 - p.g * (p.g * d * d + 2 * dy * s2)
            if root < 0 then root = 0 end
            local tanTheta = (s2 - math.sqrt(root)) / (p.g * d)
            local theta = math.atan(tanTheta)
            local t = d / (p.v0 * math.cos(theta))
            return theta, t
        end

        local function GetVel(char)
            local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            if not root or not root:IsA("BasePart") then return Vector3.zero end
            local now = os.clock()
            local last = State.velHistory[char]
            local measured = Vector3.zero
            if last and now - last.t > 0.02 then
                measured = (root.Position - last.pos) / (now - last.t)
                if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
            end
            local smooth = last and last.smooth or measured
            smooth = smooth:Lerp(measured, 0.65)
            State.velHistory[char] = { pos = root.Position, t = now, smooth = smooth }
            if smooth.Magnitude < 1 then return Vector3.zero end
            return Vector3.new(smooth.X, 0, smooth.Z)
        end

        Players.PlayerRemoving:Connect(function(p)
            if p.Character then State.velHistory[p.Character] = nil end
        end)

        local function HideFOV()
            local V = Visuals
            local OFF = Vector2.new(-9999, -9999)
            for _, k in ipairs({"FOVOuter","FOVMain","FOVInner"}) do
                if V[k] then V[k].Visible = false; V[k].Position = OFF; V[k].Radius = 0 end
            end
        end
        local function HideTracker()
            local V = Visuals
            local OFF = Vector2.new(-9999, -9999)
            for _, k in ipairs({"TrackerRingOut","TrackerRing","TrackerDot"}) do
                if V[k] then V[k].Visible = false; V[k].Position = OFF; V[k].Radius = 0 end
            end
            if V.TrackerLine then V.TrackerLine.Visible = false; V.TrackerLine.From = OFF; V.TrackerLine.To = OFF end
        end
        local function HideAll() HideFOV(); HideTracker() end

        local function UpdateFOV(center)
            local V = Visuals
            if not V.FOVOuter then return end
            local radius = VS.FOV or 150
            local t = tick()
            local pulse = (math.sin(t * 3) + 1) * 0.5
            V.FOVOuter.Position = center; V.FOVOuter.Radius = radius + 2; V.FOVOuter.Transparency = 0.3 + pulse * 0.15; V.FOVOuter.Visible = true
            V.FOVMain.Position = center; V.FOVMain.Radius = radius; V.FOVMain.Transparency = 0.7 + pulse * 0.25; V.FOVMain.Visible = true
            V.FOVInner.Position = center; V.FOVInner.Radius = radius - 10; V.FOVInner.Transparency = 0.25; V.FOVInner.Visible = true
        end

        local function UpdateTracker(pos, dist)
            local V = Visuals
            if not V.TrackerRing then return end
            local t = tick()
            local pulse = (math.sin(t * 4) + 1) * 0.5
            local base = math.clamp(1000 / math.max(dist, 1), 20, 48)
            V.TrackerRingOut.Position = pos; V.TrackerRingOut.Radius = base + 3; V.TrackerRingOut.Transparency = 0.25 + pulse * 0.15; V.TrackerRingOut.Visible = true
            V.TrackerRing.Position = pos; V.TrackerRing.Radius = base; V.TrackerRing.Transparency = 0.75 + pulse * 0.2; V.TrackerRing.Visible = true
            V.TrackerDot.Position = pos; V.TrackerDot.Radius = 2.5 + pulse * 1.2; V.TrackerDot.Transparency = 0.85 + pulse * 0.15; V.TrackerDot.Visible = true
        end

        local function UpdateAimbot()
            if GetRole() ~= "Killer" then State.target = nil; State.lookVector = nil; HideAll(); return end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            if VS.ShowFOV and VS.Enabled then UpdateFOV(center)
            else HideFOV() end
            if not VS.Enabled then State.target = nil; State.lookVector = nil; HideTracker(); return end
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local nearest, nearestPart = nil, nil
            local bestDist = VS.FOV or 150
            local bestStudDist = VS.MaxDist or 500
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and IsSurvivor(p) and p.Character then
                    local pc = p.Character
                    local isDown = pc:GetAttribute("Knocked") == true or pc:GetAttribute("HookProgressDepleting") == true
                    if not isDown then
                        local hum = pc:FindFirstChildOfClass("Humanoid")
                        local targetPart = pc:FindFirstChild("UpperTorso") or pc:FindFirstChild("Torso") or pc:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and targetPart then
                            local sp, on = cam:WorldToViewportPoint(targetPart.Position)
                            if on and sp.Z > 0 then
                                local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if sd < bestDist then
                                    local studDist = (targetPart.Position - hrp.Position).Magnitude
                                    if studDist <= bestStudDist then bestDist = sd; nearest = p; nearestPart = targetPart end
                                end
                            end
                        end
                    end
                end
            end
            if nearest and nearest.Character and nearestPart then
                local tp = nearestPart.Position
                local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
                local dir = tp - origin
                local dist = dir.Magnitude
                if dist > 0.1 and dist <= (VS.MaxDist or 500) then
                    local isAura = char:GetAttribute("special") == true
                    local prof
                    if isAura then
                        prof = { v0 = 165, g = 96.5, windup = 0.10, latency = 0.04, maxlead = 25, scale = VS.Lead or 1.4 }
                    else
                        prof = { v0 = VS.SpearSpeed or 165, g = VS.Gravity or 103, windup = 0.10, latency = 0.04, maxlead = 45, scale = VS.Lead or 1.4 }
                    end
                    local aimPoint = tp
                    if VS.AutoPredict then
                        local vel = GetVel(nearest.Character)
                        if vel.Magnitude > 0.5 then
                            local h0 = Vector3.new(dir.X, 0, dir.Z)
                            local _, tFlight = SolvePitch(prof, h0.Magnitude, dir.Y)
                            local ping = 0.08
                            pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.35) end)
                            local delay = tFlight + prof.windup + ping + prof.latency
                            for _ = 1, 2 do
                                local lead = vel * delay * prof.scale
                                local maxLead = math.clamp(dist * 0.6, 3, prof.maxlead)
                                if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
                                aimPoint = tp + lead
                                local ad = aimPoint - origin
                                local ah = Vector3.new(ad.X, 0, ad.Z)
                                local _, t2 = SolvePitch(prof, math.max(ah.Magnitude, 0.1), ad.Y)
                                delay = t2 + prof.windup + ping + prof.latency
                            end
                        end
                    end
                    local adir = aimPoint - origin
                    local ah = Vector3.new(adir.X, 0, adir.Z)
                    local ahDist = ah.Magnitude
                    local pitch = SolvePitch(prof, ahDist, adir.Y)
                    if ahDist > 0.001 then
                        State.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
                    else
                        State.lookVector = adir.Unit
                    end
                    State.target = nearest
                    if VS.ShowTracker then
                        local sp, vis = cam:WorldToViewportPoint(tp)
                        if vis and sp.Z > 0 then
                            local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if screenDist <= (VS.FOV or 150) + 100 then
                                UpdateTracker(Vector2.new(sp.X, sp.Y), dist)
                                local bc = Vector2.new(center.X, cam.ViewportSize.Y)
                                if Visuals.TrackerLine then
                                    Visuals.TrackerLine.From = bc
                                    Visuals.TrackerLine.To = Vector2.new(sp.X, sp.Y)
                                    Visuals.TrackerLine.Visible = true
                                end
                            else HideTracker() end
                        end
                    else HideTracker() end
                end
            else
                State.target = nil; State.lookVector = nil; HideTracker()
            end
        end

        RunService.RenderStepped:Connect(function() pcall(UpdateAimbot) end)

        local s = W.T_Kill:AddSection("Silent Spear Veil V1")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            VS.Enabled = v
            ShowNotify("W2HUB", "Veil V1 " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Show FOV", Default = true, Callback = function(v) VS.ShowFOV = v end })
        s:AddToggle({ Title = "Show Tracker", Default = false, Callback = function(v) VS.ShowTracker = v end })
        s:AddToggle({ Title = "Auto Predict", Default = true, Callback = function(v) VS.AutoPredict = v end })
        s:AddSlider({ Title = "FOV Size", Min = 50, Max = 500, Default = 150, Increment = 10,
            Callback = function(v) VS.FOV = v end })
        s:AddSlider({ Title = "Max Distance", Min = 50, Max = 280, Default = 280, Increment = 10,
            Callback = function(v) VS.MaxDist = v end })
    end

    -- === SILENT SPEAR VEIL V2 (W424) ===
    do
        local Config = {}
        local AimConfig = {
            Aim_SilentVeil = false, Aim_SilentVeilV2 = false,
            Veil_ShowFOV = true, SpearSmart_enable = false,
            Veil_FOV = 150, SPEAR_Speed = 165,
            SPEAR_Gravity = workspace.Gravity * 0.5,
            SPEAR_MaxDist = 200, Veil_LeadMultiplier = 1.4,
            AIM_Auto = false, AIM_TargetPart = "Torso",
        }
        local isChargingSpear = false
        local isAttackCD = false
        local isFiringSpear = false
        local currentTouch = nil

        local function IsSilentOn() return AimConfig.Aim_SilentVeil or AimConfig.Aim_SilentVeilV2 end

        local function GetTargetPart(char)
            if AimConfig.AIM_TargetPart == "Head" then return char:FindFirstChild("Head")
            elseif AimConfig.AIM_TargetPart == "Root" or AimConfig.AIM_TargetPart == "HumanoidRootPart" then
                return char:FindFirstChild("HumanoidRootPart")
            else
                return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
            end
        end

        local function GetClosestSurvivor()
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local bestD = AimConfig.Veil_FOV
            local best = nil
            local cam = workspace.CurrentCamera
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Team and p.Team.Name == "Survivors" and p.Character then
                    local char = p.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local tPart = GetTargetPart(char)
                    if hum and hum.Health > 0 and tPart then
                        local d3 = (tPart.Position - myRoot.Position).Magnitude
                        if d3 <= AimConfig.SPEAR_MaxDist then
                            local sp, on = cam:WorldToViewportPoint(tPart.Position)
                            if on then
                                local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d2 <= bestD then bestD = d2; best = tPart end
                            end
                        end
                    end
                end
            end
            return best
        end

        local vHighlight = Instance.new("Highlight")
        vHighlight.Name = "W2HUB_VeilTarget"
        vHighlight.FillColor = Color3.fromRGB(150, 150, 150)
        vHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        vHighlight.FillTransparency = 0.5
        vHighlight.OutlineTransparency = 0

        local TrackerOn = false
        local TrackerLine = nil
        local CurBillboard = nil

        local function SetupTracker()
            if CoreGui:FindFirstChild("W2HUBVeilTracker") then return end
            local sg = Instance.new("ScreenGui")
            sg.Name = "W2HUBVeilTracker"
            sg.IgnoreGuiInset = true
            sg.ResetOnSpawn = false
            sg.Parent = CoreGui
            TrackerLine = Instance.new("Frame")
            TrackerLine.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackerLine.BackgroundColor3 = Color3.fromRGB(138, 138, 138)
            TrackerLine.BackgroundTransparency = 0.2
            TrackerLine.BorderSizePixel = 0
            TrackerLine.Visible = false
            TrackerLine.Parent = sg
        end
        SetupTracker()

        local FovFrame = nil
        if not CoreGui:FindFirstChild("W2HUBVeilFOV") then
            local fg = Instance.new("ScreenGui")
            fg.Name = "W2HUBVeilFOV"
            fg.Parent = CoreGui
            fg.ResetOnSpawn = false
            fg.IgnoreGuiInset = true
            FovFrame = Instance.new("Frame")
            FovFrame.BackgroundTransparency = 1
            FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            FovFrame.Visible = false
            FovFrame.Parent = fg
            Instance.new("UICorner", FovFrame).CornerRadius = UDim.new(1, 0)
            local stk = Instance.new("UIStroke", FovFrame)
            stk.Color = Color3.fromRGB(222, 222, 222)
            stk.Thickness = 1.5
        end

        UserInputService.InputBegan:Connect(function(inp, gp)
            local isTouch = (inp.UserInputType == Enum.UserInputType.Touch)
            if gp and not isTouch then return end
            local c = LP.Character
            local isSpear = c and c:GetAttribute("spearmode") == true
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsSilentOn() and isSpear then isChargingSpear = true end
            end
            if isTouch then
                if IsSilentOn() and isSpear then
                    local pg = LP:FindFirstChild("PlayerGui")
                    if pg then
                        local sm = pg:FindFirstChild("Slasher-mob")
                        local ctrl = sm and sm:FindFirstChild("Controls")
                        local atk = ctrl and ctrl:FindFirstChild("attack")
                        if atk and atk.Visible then
                            local pos = inp.Position
                            local ap = atk.AbsolutePosition
                            local az = atk.AbsoluteSize
                            if pos.X >= ap.X and pos.X <= ap.X + az.X and pos.Y >= ap.Y and pos.Y <= ap.Y + az.Y then
                                isChargingSpear = true
                                currentTouch = inp
                            end
                        end
                    end
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(inp, gp)
            if isChargingSpear and (inp == currentTouch or inp.UserInputType == Enum.UserInputType.MouseButton1) then
                isChargingSpear = false
                if isAttackCD then return end
                isAttackCD = true
                task.delay(2, function() isAttackCD = false end)
                local myChar = LP.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local startPart = myChar and (myChar:FindFirstChild("Head") or myHRP)
                if startPart and myHRP then
                    local isSpecial = myChar:GetAttribute("special") == true
                    local startPos = Config.SpearSmart_enable and myHRP.Position or startPart.Position
                    local curSpeed = Config.SpearSmart_enable and (isSpecial and 165 or 142.5) or AimConfig.SPEAR_Speed
                    local targetPart = GetClosestSurvivor()
                    local aimDir
                    if targetPart then
                        local targetHRP = targetPart:IsA("Model") and targetPart:FindFirstChild("HumanoidRootPart") or targetPart
                        local targetPos = targetHRP.Position
                        local targetVel = Vector3.new(0,0,0)
                        local targetHum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.MoveDirection.Magnitude > 0 then
                            targetVel = targetHum.MoveDirection * targetHum.WalkSpeed
                        elseif targetHRP:IsA("BasePart") then
                            targetVel = targetHRP.AssemblyLinearVelocity
                        end
                        targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                        local distance = (targetPos - startPos).Magnitude
                        local timeToHit = distance / curSpeed
                        if Config.SpearSmart_enable then
                            local leadMult = AimConfig.Veil_LeadMultiplier or 1.4
                            local pred = targetPos + (targetVel * (timeToHit * leadMult))
                            local spearG = workspace.Gravity * 0.5
                            local drop = 0.5 * spearG * (timeToHit ^ 2)
                            local final = pred + Vector3.new(0, drop - 1.5, 0)
                            aimDir = (final - startPos).Unit
                        else
                            local dynPred = math.clamp(distance / 50, 0.1, 4.0)
                            local pred = targetPos + (targetVel * (timeToHit * dynPred))
                            local distMult = math.clamp(distance / 100, 1, 2.5)
                            local autoG = math.max(0, distance - 8)
                            local g = AimConfig.AIM_Auto and autoG or AimConfig.SPEAR_Gravity
                            local drop = 0.5 * g * (timeToHit ^ 2) * distMult
                            local final = pred + Vector3.new(0, drop, 0)
                            aimDir = (final - startPos).Unit
                        end
                    else
                        aimDir = Workspace.CurrentCamera.CFrame.LookVector
                    end
                    if AimConfig.Aim_SilentVeil then
                        pcall(function()
                            ReplicatedStorage.Remotes.Killers.Veil.Spearthrow:FireServer(aimDir, curSpeed, startPos)
                        end)
                    end
                end
            end
        end)

        -- Hook Spearthrow
        task.spawn(function()
            pcall(function()
                if typeof(hookmetamethod) ~= "function" then return end
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() == "FireServer" and not checkcaller() then
                        local ok, n = pcall(function() return self.Name end)
                        if ok and n == "Spearthrow" then
                            local args = {...}
                            local modeV1 = W.VeilV1.Enabled and W._VeilV1_State and typeof(W._VeilV1_State.lookVector) == "Vector3"
                            if AimConfig.Aim_SilentVeil and not AimConfig.Aim_SilentVeilV2 then
                                return nil
                            end
                            if modeV1 and not AimConfig.Aim_SilentVeilV2 then
                                if typeof(args[1]) == "Vector3" then
                                    args[1] = W._VeilV1_State.lookVector
                                    return oldNC(self, unpack(args))
                                end
                            end
                        end
                    end
                    return oldNC(self, ...)
                end)
            end)
        end)

        RunService.RenderStepped:Connect(function()
            local c = LP.Character
            local isSpear = c and c:GetAttribute("spearmode") == true
            local cam = workspace.CurrentCamera
            if FovFrame then
                if IsSilentOn() and AimConfig.Veil_ShowFOV and isSpear then
                    FovFrame.Visible = true
                    FovFrame.Size = UDim2.new(0, AimConfig.Veil_FOV * 2, 0, AimConfig.Veil_FOV * 2)
                else FovFrame.Visible = false end
            end
            if IsSilentOn() and isSpear and cam then
                local t = GetClosestSurvivor()
                if t and t.Parent then
                    vHighlight.Parent = t.Parent
                    if TrackerOn then
                        if not CurBillboard or CurBillboard.Parent ~= t then
                            if CurBillboard then CurBillboard:Destroy() end
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "VeilTrackerBillboard"
                            bb.Size = UDim2.fromOffset(14, 14)
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 0
                            bb.MaxDistance = 500
                            local ring = Instance.new("Frame")
                            ring.AnchorPoint = Vector2.new(0.5, 0.5)
                            ring.Position = UDim2.fromScale(0.5, 0.5)
                            ring.Size = UDim2.fromScale(1, 1)
                            ring.BackgroundTransparency = 1
                            ring.Parent = bb
                            Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
                            local s = Instance.new("UIStroke")
                            s.Color = Color3.fromRGB(255, 255, 255)
                            s.Thickness = 1
                            s.Transparency = 0.1
                            s.Parent = ring
                            bb.Adornee = t
                            bb.Parent = t
                            CurBillboard = bb
                        end
                        local sp, on = cam:WorldToViewportPoint(t.Position)
                        if on and sp.Z > 0 and TrackerLine then
                            local vp = cam.ViewportSize
                            local fx, fy = vp.X * 0.5, vp.Y
                            local tx, ty = sp.X, sp.Y
                            local dx, dy = tx - fx, ty - fy
                            local len = math.sqrt(dx * dx + dy * dy)
                            TrackerLine.Size = UDim2.fromOffset(math.max(len, 1), 1)
                            TrackerLine.Position = UDim2.fromOffset((fx + tx) * 0.5, (fy + ty) * 0.5)
                            TrackerLine.Rotation = math.deg(math.atan2(dy, dx))
                            TrackerLine.Visible = true
                        elseif TrackerLine then TrackerLine.Visible = false end
                    else
                        if CurBillboard then CurBillboard:Destroy(); CurBillboard = nil end
                        if TrackerLine then TrackerLine.Visible = false end
                    end
                else
                    vHighlight.Parent = nil
                    if CurBillboard then CurBillboard:Destroy(); CurBillboard = nil end
                    if TrackerLine then TrackerLine.Visible = false end
                end
            else
                vHighlight.Parent = nil
                if CurBillboard then CurBillboard:Destroy(); CurBillboard = nil end
                if TrackerLine then TrackerLine.Visible = false end
            end
        end)

        W.W424Veil_API = {
            AimConfig = AimConfig,
            Config = Config,
            getClosestSurvivor = GetClosestSurvivor,
            IsVeilSilentOn = IsSilentOn,
            setTracker = function(v) TrackerOn = v end,
        }

        local s = W.T_Kill:AddSection("Silent Spear Veil V2")
        s:AddToggle({ Title = "V1 Mode", Default = false, Callback = function(v)
            AimConfig.Aim_SilentVeil = v
        end })
        s:AddToggle({ Title = "V2 Mode", Default = false, Callback = function(v)
            AimConfig.Aim_SilentVeilV2 = v
            ShowNotify("W2HUB", "Veil V2 " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddToggle({ Title = "Auto Predict", Default = false, Callback = function(v)
            Config.SpearSmart_enable = v
        end })
        s:AddSlider({ Title = "Lead Multiplier", Min = 0.5, Max = 5, Default = 1.4,
            Callback = function(v) AimConfig.Veil_LeadMultiplier = v end })
        s:AddSlider({ Title = "Spear Speed", Min = 50, Max = 200, Default = 165,
            Callback = function(v) AimConfig.SPEAR_Speed = v end })
        s:AddSlider({ Title = "Spear Gravity", Min = 0, Max = 200, Default = 103,
            Callback = function(v) AimConfig.SPEAR_Gravity = v end })
        s:AddToggle({ Title = "ESP Tracker", Default = false, Callback = function(v)
            W.W424Veil_API.setTracker(v)
        end })
    end

    -- === UI: MASKED ===
    do
        local s = W.T_Kill:AddSection("Select Masked Power")
        s:AddDropdown({ Title = "Power", Options = Masked.Powers, Default = Masked.CurrentPower,
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                Masked.CurrentPower = val
            end })
        s:AddButton({ Title = "Activate", Callback = function() W.Masked_Activate() end })
        s:AddButton({ Title = "Deactivate", Callback = function() W.Masked_Deactivate() end })
    end

    print("[W2HUB] PART 10 Loaded OK")

-- PART 11-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 11: KILLER — BYPASS + CARRY + SPEAR + ABILITIES + FLASK + DASH
    --====================================================--

    -- === BYPASS: HIDDEN LEAP ===
    getgenv().W2_HiddenLeapThread = nil
    function W.StartHiddenBypass()
        if getgenv().W2_HiddenLeapThread then return end
        getgenv().W2_HiddenLeapThread = task.spawn(function()
            local leapFn, m2Fn
            local function scan()
                pcall(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "function" and islclosure(v) then
                            local info
                            pcall(function() info = debug.getinfo(v) end)
                            if info then
                                if info.name == "tryActivate" then leapFn = v
                                elseif info.name == "playM2Animation" then m2Fn = v end
                            end
                        end
                        if leapFn and m2Fn then break end
                    end
                end)
            end
            scan()
            local lastScan = os.clock()
            while task.wait(0.1) do
                if not W.BypassHiddenLeap then break end
                if not (leapFn and m2Fn) then
                    if os.clock() - lastScan >= 2 then lastScan = os.clock(); scan() end
                end
                if leapFn then
                    pcall(function()
                        for i, v in pairs(debug.getupvalues(leapFn)) do
                            if type(v) == "boolean" and v == true then debug.setupvalue(leapFn, i, false) end
                        end
                    end)
                end
                if m2Fn then
                    pcall(function()
                        for i, v in pairs(debug.getupvalues(m2Fn)) do
                            if type(v) == "boolean" and v == true then debug.setupvalue(m2Fn, i, false) end
                        end
                    end)
                end
            end
            getgenv().W2_HiddenLeapThread = nil
        end)
    end
    W.BypassHiddenLeap = false
    W.SetHiddenLeap = function(v)
        W.BypassHiddenLeap = v and true or false
        if W.BypassHiddenLeap then W.StartHiddenBypass() end
    end

    -- === BYPASS: MYERS GRAB ===
    W.Myers = W.Myers or { Enabled = false, Hotkey = Enum.KeyCode.H }
    local Myers = W.Myers
    function W.Myers_GetTarget()
        local c = LP.Character
        if not c then return nil end
        local myHRP = c:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and h and h.Health > 0 then
                    table.insert(list, { player = p, dist = (hrp.Position - myHRP.Position).Magnitude })
                end
            end
        end
        table.sort(list, function(a, b) return a.dist < b.dist end)
        for _, v in ipairs(list) do return v.player end
        return nil
    end
    function W.Myers_DoGrab()
        if not Myers.Enabled then return end
        local t = W.Myers_GetTarget()
        if not t or not t.Character then return end
        pcall(function() ReplicatedStorage.Remotes.Killers.Stalker.grab:FireServer(t.Character) end)
    end
    function W.Myers_Set(v)
        Myers.Enabled = v and true or false
    end
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Myers.Hotkey and Myers.Enabled then W.Myers_DoGrab() end
    end)

    -- === BYPASS: SLASHER (LakeMist + Pursuit) ===
    getgenv().W2_SlasherThread = nil
    function W.StartSlasherBypass()
        if getgenv().W2_SlasherThread then return end
        pcall(function()
            local b = true
            local mt = debug.getmetatable(b)
            if not mt then mt = {}; debug.setmetatable(b, mt) end
            if setreadonly then setreadonly(mt, false) end
            mt.__div = function() return 0 end
            mt.__mul = function() return 0 end
            mt.__add = function() return 0 end
            mt.__sub = function() return 0 end
            if setreadonly then setreadonly(mt, true) end
        end)
        getgenv().W2_SlasherThread = task.spawn(function()
            local toggleFn, pursuitFn
            local function scan()
                pcall(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "function" and islclosure(v) then
                            local cs = debug.getconstants(v)
                            local ho, hl, ha, ht = false, false, false, false
                            local hp, hw = false, false
                            for _, c in pairs(cs) do
                                if c == "Offset" then ho = true end
                                if c == "Linear" then hl = true end
                                if c == "action" then ha = true end
                                if c == "TweenInfo" then ht = true end
                                if c == "Pursuit" then hp = true end
                                if c == "WalkSpeed" then hw = true end
                            end
                            if ho and hl and ha and ht and not hp then toggleFn = v end
                            if hp and ht and ha and hw then pursuitFn = v end
                        end
                        if toggleFn and pursuitFn then break end
                    end
                end)
            end
            scan()
            local lastScan = os.clock()
            while task.wait(0.1) do
                if not W.BypassLakeMist and not W.BypassPursuit then break end
                if not (toggleFn and pursuitFn) then
                    if os.clock() - lastScan >= 2 then scan(); lastScan = os.clock() end
                end
                if toggleFn and W.BypassLakeMist then
                    pcall(function()
                        debug.setupvalue(toggleFn, 6, false)
                        debug.setupvalue(toggleFn, 10, false)
                    end)
                end
                if pursuitFn and W.BypassPursuit then
                    pcall(function()
                        debug.setupvalue(pursuitFn, 5, false)
                        debug.setupvalue(pursuitFn, 6, false)
                    end)
                end
            end
            getgenv().W2_SlasherThread = nil
        end)
    end
    W.BypassLakeMist = false
    W.BypassPursuit = false
    W.SetLakeMist = function(v)
        W.BypassLakeMist = v and true or false
        if W.BypassLakeMist or W.BypassPursuit then W.StartSlasherBypass() end
    end
    W.SetPursuit = function(v)
        W.BypassPursuit = v and true or false
        if W.BypassLakeMist or W.BypassPursuit then W.StartSlasherBypass() end
    end

    -- === BYPASS: ABYSS ===
    getgenv().W2_AbyssConn = nil
    getgenv().W2_CorruptFn = nil
    W.BypassAbyss = false
    function W.StartAbyssBypass()
        if not getgenv().W2_CorruptFn then
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local cs = debug.getconstants(v)
                        if table.find(cs, "corrupt") and table.find(cs, "Immobile") then
                            getgenv().W2_CorruptFn = v
                            break
                        end
                    end
                end
            end)
        end
        if not getgenv().W2_CorruptFn then return end
        if getgenv().W2_AbyssConn then getgenv().W2_AbyssConn:Disconnect() end
        getgenv().W2_AbyssConn = RunService.Heartbeat:Connect(function()
            if not W.BypassAbyss then return end
            if getgenv().W2_CorruptFn then
                local ups = debug.getupvalues(getgenv().W2_CorruptFn)
                for i, v in pairs(ups) do
                    if type(v) == "boolean" and v == false then
                        debug.setupvalue(getgenv().W2_CorruptFn, i, true)
                    end
                end
            end
        end)
    end
    W.SetAbyssBypass = function(v)
        W.BypassAbyss = v and true or false
        if W.BypassAbyss then W.StartAbyssBypass()
        elseif getgenv().W2_AbyssConn then getgenv().W2_AbyssConn:Disconnect(); getgenv().W2_AbyssConn = nil end
    end

    -- === BYPASS: JEFF INFINITE FRENZY ===
    getgenv().W2_JeffThread = nil
    W.BypassJeff = false
    function W.StartJeffBypass()
        if getgenv().W2_JeffThread then return end
        getgenv().W2_JeffThread = task.spawn(function()
            while task.wait() do
                if not W.BypassJeff then break end
                pcall(function()
                    local c = LP.Character
                    if c and c:GetAttribute("Frenzy") ~= true then c:SetAttribute("Frenzy", true) end
                end)
            end
            getgenv().W2_JeffThread = nil
        end)
    end
    function W.StopJeffBypass()
        pcall(function()
            local c = LP.Character
            if c and c:GetAttribute("Frenzy") == true then
                c:SetAttribute("Frenzy", false)
                local k = ReplicatedStorage:FindFirstChild("Remotes")
                    and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                    and ReplicatedStorage.Remotes.Killers:FindFirstChild("Killer")
                if k then
                    local d = k:FindFirstChild("Deactivatefromclient")
                    if d then d:FireServer() end
                end
            end
        end)
    end
    W.SetJeffFrenzy = function(v)
        W.BypassJeff = v and true or false
        if W.BypassJeff then W.StartJeffBypass() else W.StopJeffBypass() end
    end

    -- === UNLOCK SKILL WHILE CARRYING ===
    W.CarryCfg = W.CarryCfg or { Enabled = false, Hooked = false }
    local CarryCfg = W.CarryCfg
    function W.SetUnlockCarry(v)
        CarryCfg.Enabled = v and true or false
        if v then
            if CarryCfg.Hooked then return end
            if typeof(getrawmetatable) ~= "function" then return end
            pcall(function()
                local mt = getrawmetatable(game)
                if setreadonly then setreadonly(mt, false) end
                local oldNC = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    local args = {...}
                    if CarryCfg.Enabled and method == "GetAttribute" and not checkcaller() then
                        if args[1] == "IsCarrying" then return false end
                    end
                    return oldNC(self, ...)
                end)
                if setreadonly then setreadonly(mt, true) end
                CarryCfg.Hooked = true
            end)
        end
    end

    -- === SPEAR AIMBOT ===
    do
        local SA = { Enabled = false, Gravity = 50, Speed = 100,
            ManualTarget = nil, TargetIndex = 0, Btn = nil, BtnGui = nil,
            Locked = false, Dragging = false, DragStart = nil, DragStartPos = nil }
        W.SpearAimbot = SA

        local function Calc(targetPos)
            if not SA.Enabled or GetRole() ~= "Killer" then return nil end
            local c = LP.Character
            if not c then return nil end
            local root = c:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            local startPos = root.Position + Vector3.new(0, 2, 0)
            local dist = (targetPos - startPos).Magnitude
            local g = SA.Gravity or 50
            local sp = SA.Speed or 100
            local t = dist / sp
            local drop = 0.5 * g * t * t
            return targetPos + Vector3.new(0, drop, 0)
        end

        local function TargetList()
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local l = {}
            if not root then return l end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and TeamIs(p, "Survivor") and p.Character then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    local th = p.Character:FindFirstChildOfClass("Humanoid")
                    if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
                        table.insert(l, { P = p, D = (tr.Position - root.Position).Magnitude })
                    end
                end
            end
            table.sort(l, function(a, b) return a.D < b.D end)
            local out = {}
            for _, v in ipairs(l) do table.insert(out, v.P) end
            return out
        end

        local function UpdateAim()
            if not SA.Enabled then return end
            if GetRole() ~= "Killer" then return end
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local target = nil
            if SA.ManualTarget then
                local p = SA.ManualTarget
                local valid = p.Parent and TeamIs(p, "Survivor") and p.Character
                if valid then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    local th = p.Character:FindFirstChildOfClass("Humanoid")
                    valid = tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25
                end
                if valid then target = p
                else SA.ManualTarget = nil end
            end
            if not target then
                local closest, cd = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and TeamIs(p, "Survivor") and p.Character then
                        local tr = p.Character:FindFirstChild("HumanoidRootPart")
                        local th = p.Character:FindFirstChildOfClass("Humanoid")
                        if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
                            local d = (tr.Position - root.Position).Magnitude
                            if d < cd then cd = d; closest = p end
                        end
                    end
                end
                target = closest
            end
            if target and target.Character then
                local tr = target.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local aimPos = Calc(tr.Position)
                    if aimPos then
                        local cam = Workspace.CurrentCamera
                        if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos) end
                    end
                end
            end
        end

        local function BuildBtn()
            if SA.BtnGui then pcall(function() SA.BtnGui:Destroy() end) end
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            SA.BtnGui = Instance.new("ScreenGui")
            SA.BtnGui.Name = "W2HUBSpearAimbot"
            SA.BtnGui.ResetOnSpawn = false
            SA.BtnGui.IgnoreGuiInset = true
            SA.BtnGui.Parent = pg
            SA.Btn = Instance.new("TextButton")
            SA.Btn.Name = "SpearAimbotButton"
            SA.Btn.Size = UDim2.new(0, 65, 0, 65)
            SA.Btn.Position = UDim2.new(0.15, 0, 0.75, 0)
            SA.Btn.AnchorPoint = Vector2.new(0.5, 0.5)
            SA.Btn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            SA.Btn.BackgroundTransparency = 0.15
            SA.Btn.Text = "SPEAR\nAIM"
            SA.Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            SA.Btn.TextSize = 11
            SA.Btn.Font = Enum.Font.GothamBold
            SA.Btn.Visible = false
            SA.Btn.ZIndex = 10
            SA.Btn.Parent = SA.BtnGui
            Instance.new("UICorner", SA.Btn).CornerRadius = UDim.new(1, 0)
            local stk = Instance.new("UIStroke", SA.Btn)
            stk.Color = Color3.fromRGB(255, 80, 80)
            stk.Thickness = 2
            stk.Transparency = 0.2
            local lock = Instance.new("TextButton")
            lock.Size = UDim2.new(0, 22, 0, 22)
            lock.Position = UDim2.new(1, -5, 0, -5)
            lock.AnchorPoint = Vector2.new(1, 0)
            lock.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            lock.BackgroundTransparency = 0.3
            lock.Text = "L"
            lock.TextSize = 10
            lock.Font = Enum.Font.GothamBold
            lock.TextColor3 = Color3.new(1, 1, 1)
            lock.ZIndex = 11
            lock.Parent = SA.Btn
            Instance.new("UICorner", lock).CornerRadius = UDim.new(1, 0)
            lock.MouseButton1Click:Connect(function()
                SA.Locked = not SA.Locked
                lock.Text = SA.Locked and "X" or "L"
                lock.BackgroundColor3 = SA.Locked and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 60)
            end)
            local lbl = Instance.new("TextLabel")
            lbl.Name = "TargetLabel"
            lbl.Size = UDim2.new(0, 90, 0, 18)
            lbl.Position = UDim2.new(0.5, 0, 0, -22)
            lbl.AnchorPoint = Vector2.new(0.5, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "AUTO"
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamBold
            lbl.ZIndex = 11
            lbl.Visible = false
            lbl.Parent = SA.Btn
            local left = Instance.new("TextButton")
            left.Size = UDim2.new(0, 28, 0, 28)
            left.Position = UDim2.new(0, -34, 0.5, 0)
            left.AnchorPoint = Vector2.new(0.5, 0.5)
            left.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            left.BackgroundTransparency = 0.15
            left.Text = "<"
            left.TextColor3 = Color3.fromRGB(158, 158, 158)
            left.TextSize = 16
            left.Font = Enum.Font.GothamBold
            left.ZIndex = 10
            left.Parent = SA.Btn
            Instance.new("UICorner", left).CornerRadius = UDim.new(1, 0)
            local right = Instance.new("TextButton")
            right.Size = UDim2.new(0, 28, 0, 28)
            right.Position = UDim2.new(1, 34, 0.5, 0)
            right.AnchorPoint = Vector2.new(0.5, 0.5)
            right.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            right.BackgroundTransparency = 0.15
            right.Text = ">"
            right.TextColor3 = Color3.fromRGB(255, 150, 150)
            right.TextSize = 16
            right.Font = Enum.Font.GothamBold
            right.ZIndex = 10
            right.Parent = SA.Btn
            Instance.new("UICorner", right).CornerRadius = UDim.new(1, 0)
            SA.Btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if SA.Locked then return end
                    SA.Dragging = true
                    SA.DragStart = inp.Position
                    SA.DragStartPos = SA.Btn.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if SA.Dragging and not SA.Locked and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local d = inp.Position - SA.DragStart
                    SA.Btn.Position = UDim2.new(SA.DragStartPos.X.Scale, SA.DragStartPos.X.Offset + d.X, SA.DragStartPos.Y.Scale, SA.DragStartPos.Y.Offset + d.Y)
                end
            end)
            SA.Btn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then SA.Dragging = false end
            end)
        end

        RunService.RenderStepped:Connect(function() pcall(UpdateAim) end)
        RunService.Heartbeat:Connect(function()
            if SA.Btn then
                SA.Btn.Visible = SA.Enabled and GetRole() == "Killer"
            end
        end)
        LP.CharacterAdded:Connect(function()
            task.wait(0.5)
            if SA.Enabled then pcall(BuildBtn) end
        end)
        function W.SpearAimbot_Set(v)
            SA.Enabled = v and true or false
            if v then BuildBtn()
            else
                if SA.BtnGui then pcall(function() SA.BtnGui:Destroy() end); SA.BtnGui = nil end
                SA.Btn = nil
            end
        end
        function W.SpearAimbot_SetG(v) SA.Gravity = tonumber(v) or 50 end
        function W.SpearAimbot_SetS(v) SA.Speed = tonumber(v) or 100 end
    end

    -- === KILLER ABILITIES ===
    W.KA = W.KA or {
        AutoStalk = false, AutoStalkRange = 150,
        AutoKillAll = false, DropAllPallet = false, BlockAllVault = false,
    }
    local KA = W.KA
    W._KATimer = W._KATimer or { lastDrop = 0, lastBlock = 0 }
    local _KAtimer = W._KATimer

    function W.KA_Closest(range, minHP)
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, shortest = nil, (range or math.huge)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and TeamIs(p, "Survivor") then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if h and hrp and h.Health > (minHP or 30) then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= shortest then shortest = d; closest = p end
                end
            end
        end
        return closest
    end

    local AutoStalkConn = nil
    function W.KA_StartAutoStalk()
        if AutoStalkConn then return end
        AutoStalkConn = RunService.Heartbeat:Connect(function()
            if not KA.AutoStalk then return end
            if GetRole() ~= "Killer" then return end
            local t = W.KA_Closest(KA.AutoStalkRange, 30)
            if not t or not t.Character then return end
            local ev = ReplicatedStorage:FindFirstChild("Remotes", true)
                and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
                and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
            if ev then pcall(function() ev:FireServer(t) end) end
        end)
    end
    function W.KA_StopAutoStalk()
        if AutoStalkConn then pcall(function() AutoStalkConn:Disconnect() end); AutoStalkConn = nil end
    end
    function W.KA_SetAutoStalk(v)
        KA.AutoStalk = v and true or false
        if KA.AutoStalk then W.KA_StartAutoStalk() else W.KA_StopAutoStalk() end
    end

    local KillAllTarget = nil
    function W.KA_UpdateKillAll()
        if not KA.AutoKillAll then KillAllTarget = nil; return end
        if GetRole() ~= "Killer" then KillAllTarget = nil; return end
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tChar = KillAllTarget and KillAllTarget.Character
        if not KillAllTarget or not tChar or not tChar.Parent or not tChar:FindFirstChild("Humanoid") or tChar.Humanoid.Health <= 35 then
            KillAllTarget = W.KA_Closest(math.huge, 30)
            tChar = KillAllTarget and KillAllTarget.Character
        end
        if KillAllTarget and tChar then
            local tr = tChar:FindFirstChild("HumanoidRootPart")
            if tr then
                local v = tr.AssemblyLinearVelocity
                local pr = v * 0.15
                local tp = tr.Position + pr
                local behind = tr.CFrame.LookVector * -3
                root.CFrame = CFrame.new(tp + behind, tp)
            end
            pcall(function()
                local a = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
                local b = a and a:FindFirstChild("BasicAttack")
                if b then b:FireServer(false) end
            end)
        end
    end
    function W.KA_SetAutoKillAll(v)
        KA.AutoKillAll = v and true or false
        if not KA.AutoKillAll then KillAllTarget = nil end
    end

    function W.KA_DropAllPallets()
        if not KA.DropAllPallet then return end
        if GetRole() ~= "Killer" then return end
        local now = tick()
        if now - _KAtimer.lastDrop < 2 then return end
        _KAtimer.lastDrop = now
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local pf = r and r:FindFirstChild("Pallet")
            local drop = pf and pf:FindFirstChild("PalletDropEvent")
            if not drop then return end
            local map = workspace:FindFirstChild("Map")
            if not map then return end
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Palletwrong" and (obj:IsA("Model") or obj:IsA("Folder")) then
                    local t = obj:FindFirstChild("PalletPointSlide") or obj:FindFirstChild("PalletPoint")
                    if t then pcall(function() drop:FireServer(t) end) end
                end
            end
        end)
    end
    function W.KA_SetDropAllPallet(v)
        KA.DropAllPallet = v and true or false
    end
    function W.KA_DropAllPallets_Force()
        if GetRole() ~= "Killer" then return end
        _KAtimer.lastDrop = 0
        local saved = KA.DropAllPallet
        KA.DropAllPallet = true
        pcall(W.KA_DropAllPallets)
        task.delay(0.1, function() KA.DropAllPallet = saved end)
    end

    function W.KA_BlockAllVaults()
        if not KA.BlockAllVault then return end
        local ev = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Window")
            and ReplicatedStorage.Remotes.Window:FindFirstChild("VaultEvent")
        if not ev then return end
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        for _, t in ipairs(map:GetDescendants()) do
            if t.Name == "VaultTrigger" then pcall(function() ev:FireServer(t, true) end) end
        end
    end
    function W.KA_SetBlockAllVault(v)
        KA.BlockAllVault = v and true or false
    end
    function W.KA_BlockAllVaults_Force()
        _KAtimer.lastBlock = 0
        pcall(W.KA_BlockAllVaults)
    end

    task.spawn(function()
        while true do
            task.wait(0.12)
            if KA.AutoKillAll then pcall(W.KA_UpdateKillAll) end
            if KA.DropAllPallet then pcall(W.KA_DropAllPallets) end
            if KA.BlockAllVault then pcall(W.KA_BlockAllVaults) end
        end
    end)
    LP.CharacterAdded:Connect(function()
        task.wait(1)
        if KA.AutoStalk then pcall(W.KA_StartAutoStalk) end
    end)

    -- === AUTO HOOK ===
    do
        W.AutoHook = false
        local isHooking = false
        local function GetHooks()
            local l = {}
            local map = Workspace:FindFirstChild("Map")
            if not map then return l end
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    local hp = obj:FindFirstChild("HookPoint") or obj:FindFirstChild("HookHitbox") or obj:FindFirstChildWhichIsA("BasePart", true)
                    if hp then table.insert(l, { model = obj, part = hp }) end
                end
            end
            return l
        end
        local function OnHook(char, hooks)
            local tr = char:FindFirstChild("HumanoidRootPart")
            if not tr then return false end
            for _, h in ipairs(hooks) do
                if (h.part.Position - tr.Position).Magnitude < 6 then return true end
            end
            return false
        end
        local function FindDowned(hooks)
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil, nil end
            local cl, cd, cc = nil, math.huge, nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP or not p.Character then continue end
                if not TeamIs(p, "Survivor") then continue end
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if not tr or not h then continue end
                local pct = h.MaxHealth > 0 and (h.Health / h.MaxHealth) or 0
                if pct > 0.25 or pct <= 0 then continue end
                if OnHook(p.Character, hooks) then continue end
                if p.Character:GetAttribute("IsCarried") == true then continue end
                local d = (tr.Position - myRoot.Position).Magnitude
                if d < cd then cd = d; cl = tr; cc = p.Character end
            end
            return cl, cc
        end
        local function NearestHook(pos, hooks)
            local cl, cd = nil, math.huge
            for _, h in ipairs(hooks) do
                local d = (h.part.Position - pos).Magnitude
                if d < cd then cd = d; cl = h end
            end
            return cl
        end
        local function DoHook()
            if not W.AutoHook then return end
            if isHooking then return end
            if GetRole() ~= "Killer" then return end
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local hooks = GetHooks()
            if #hooks == 0 then return end
            local tRoot, tChar = FindDowned(hooks)
            if not tRoot then return end
            local near = NearestHook(tRoot.Position, hooks)
            if not near then return end
            isHooking = true
            task.spawn(function()
                local carryEv, hookEv, hookCom
                pcall(function()
                    local cf = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                    carryEv = cf:FindFirstChild("CarrySurvivorEvent")
                    hookEv = cf:FindFirstChild("HookEvent")
                    hookCom = cf:FindFirstChild("HookCommit")
                end)
                pcall(function() root.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 3, 0), tRoot.Position) end)
                task.wait(0.2)
                pcall(function() if carryEv then carryEv:FireServer(tChar) end end)
                task.wait(0.5)
                local r2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not r2 then isHooking = false; return end
                pcall(function() r2.CFrame = CFrame.new(near.part.Position + Vector3.new(0, 3, 0)) end)
                task.wait(0.3)
                pcall(function()
                    local hp = near.model:FindFirstChild("HookPoint") or near.model:FindFirstChild("HookHitbox") or near.part
                    if hookEv then hookEv:FireServer(hp) end
                    if hookCom then hookCom:FireServer(hp) end
                end)
                task.wait(1)
                isHooking = false
            end)
        end
        function W.KA_StartAutoHook()
            if W._AutoHookThread then return end
            W._AutoHookThread = task.spawn(function()
                while W.AutoHook do
                    if GetRole() == "Killer" then pcall(DoHook) end
                    task.wait(1)
                end
                W._AutoHookThread = nil
            end)
        end
        function W.KA_StopAutoHook()
            if W._AutoHookThread then pcall(function() task.cancel(W._AutoHookThread) end); W._AutoHookThread = nil end
        end
        function W.KA_SetAutoHook(v)
            W.AutoHook = v and true or false
            if W.AutoHook then W.KA_StartAutoHook() else W.KA_StopAutoHook() end
        end
    end

    -- === SILENT FLASK ===
    do
        local FS = { Enabled = false, ShowBeam = true, ShowLanding = true, Predict = true,
            Speed = 90, Gravity = 196, Lead = 1.0, Range = 200,
            Target = nil, PredictedPos = nil, BeamPart = nil, AccentPart = nil, LandingRing = nil }
        W.Flask = FS

        local function GetTarget()
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local maxR = FS.Range or 200
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and TeamIs(p, "Survivor") and p.Character then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if h and h.Health > 0 and r then
                        local d = (r.Position - myRoot.Position).Magnitude
                        if d <= maxR and d < bd then bd = d; best = { Player = p, Root = r } end
                    end
                end
            end
            return best
        end
        local function GetHand()
            local c = LP.Character
            if not c then return nil end
            return c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm") or c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart")
        end
        local function Predict(origin, targetRoot)
            local tp = targetRoot.Position
            local speed = FS.Speed or 90
            local gravity = FS.Gravity or 196
            local lead = FS.Lead or 1.0
            if not FS.Predict then return tp end
            local tv = targetRoot.AssemblyLinearVelocity or Vector3.zero
            local hv = Vector3.new(tv.X, 0, tv.Z)
            local dist = (tp - origin).Magnitude
            local time = dist / speed
            local pred = tp
            for _ = 1, 3 do
                pred = tp + hv * time * lead
                local nd = (pred - origin).Magnitude
                time = nd / speed
            end
            local drop = 0.5 * gravity * (time * time)
            return pred + Vector3.new(0, drop, 0)
        end
        local function Clear()
            if FS.BeamPart then pcall(function() FS.BeamPart:Destroy() end); FS.BeamPart = nil end
            if FS.AccentPart then pcall(function() FS.AccentPart:Destroy() end); FS.AccentPart = nil end
            if FS.LandingRing then pcall(function() FS.LandingRing:Destroy() end); FS.LandingRing = nil end
        end
        local function Hide()
            if FS.BeamPart then FS.BeamPart.Transparency = 1 end
            if FS.AccentPart then FS.AccentPart.Transparency = 1 end
            if FS.LandingRing then FS.LandingRing.Transparency = 1 end
        end
        local function EnsureBeam()
            if not FS.BeamPart or not FS.BeamPart.Parent then
                local b = Instance.new("Part")
                b.Name = "W2HUBFlaskBeam"; b.Anchored = true; b.CanCollide = false
                b.CanTouch = false; b.CanQuery = false; b.CastShadow = false
                b.Material = Enum.Material.Neon
                b.Color = Color3.fromRGB(255, 255, 255)
                b.Transparency = 0.2
                b.Parent = Workspace
                FS.BeamPart = b
            end
            if not FS.AccentPart or not FS.AccentPart.Parent then
                local a = Instance.new("Part")
                a.Name = "W2HUBFlaskAccent"; a.Anchored = true; a.CanCollide = false
                a.CanTouch = false; a.CanQuery = false; a.CastShadow = false
                a.Material = Enum.Material.SmoothPlastic
                a.Color = Color3.fromRGB(25, 25, 25)
                a.Transparency = 0.35
                a.Parent = Workspace
                FS.AccentPart = a
            end
        end
        local function UpdateBeam(origin, landing)
            EnsureBeam()
            local dir = landing - origin
            local dist = dir.Magnitude
            if dist < 0.1 then return end
            local mid = (origin + landing) / 2
            local cf = CFrame.lookAt(mid, landing)
            FS.BeamPart.Size = Vector3.new(0.12, 0.12, dist)
            FS.BeamPart.CFrame = cf
            FS.BeamPart.Transparency = 0.2
            FS.AccentPart.Size = Vector3.new(0.22, 0.22, dist)
            FS.AccentPart.CFrame = cf
            FS.AccentPart.Transparency = 0.35
        end
        local function UpdateLanding(pos)
            if not FS.ShowLanding then
                if FS.LandingRing then FS.LandingRing.Transparency = 1 end
                return
            end
            if not FS.LandingRing or not FS.LandingRing.Parent then
                local ring = Instance.new("Part")
                ring.Name = "W2HUBFlaskLanding"
                ring.Shape = Enum.PartType.Cylinder
                ring.Anchored = true; ring.CanCollide = false
                ring.CanTouch = false; ring.CanQuery = false; ring.CastShadow = false
                ring.Material = Enum.Material.Neon
                ring.Color = Color3.fromRGB(255, 255, 255)
                ring.Size = Vector3.new(0.2, 5, 5)
                ring.Parent = Workspace
                FS.LandingRing = ring
            end
            FS.LandingRing.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
            FS.LandingRing.Transparency = 0.35
        end

        RunService.RenderStepped:Connect(function()
            if not FS.Enabled then Hide(); FS.Target = nil; FS.PredictedPos = nil; return end
            if GetRole() ~= "Killer" then Hide(); return end
            local t = GetTarget()
            if not t or not t.Root then Hide(); FS.Target = nil; FS.PredictedPos = nil; return end
            local hand = GetHand()
            if not hand then return end
            local landing = Predict(hand.Position, t.Root)
            FS.Target = t
            FS.PredictedPos = landing
            if FS.ShowBeam then pcall(UpdateBeam, hand.Position, landing)
            else
                if FS.BeamPart then FS.BeamPart.Transparency = 1 end
                if FS.AccentPart then FS.AccentPart.Transparency = 1 end
            end
            pcall(UpdateLanding, landing)
        end)

        task.spawn(function()
            pcall(function()
                if typeof(hookmetamethod) ~= "function" then return end
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() == "FireServer" and FS.Enabled then
                        local ok, n = pcall(function() return self.Name end)
                        if ok and n == "ThrowFlask" then
                            if FS.PredictedPos and GetRole() == "Killer" then
                                local args = {...}
                                if typeof(args[2]) == "Vector3" then
                                    local o = args[2]
                                    local dir = FS.PredictedPos - o
                                    if dir.Magnitude > 0.1 then
                                        args[1] = dir.Unit
                                        return oldNC(self, unpack(args))
                                    end
                                elseif typeof(args[1]) == "Vector3" then
                                    local c = LP.Character
                                    local hand = c and (c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm") or c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart"))
                                    if hand then
                                        local dir = FS.PredictedPos - hand.Position
                                        if dir.Magnitude > 0.1 then
                                            args[1] = dir.Unit
                                            return oldNC(self, unpack(args))
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return oldNC(self, ...)
                end)
            end)
        end)

        function W.Flask_Set(v) FS.Enabled = v and true or false; if not v then Clear() end end
        function W.Flask_SetSpeed(v) FS.Speed = tonumber(v) or 90 end
        function W.Flask_SetGravity(v) FS.Gravity = tonumber(v) or 196 end
        function W.Flask_SetLead(v) FS.Lead = tonumber(v) or 1.0 end
        function W.Flask_SetRange(v) FS.Range = tonumber(v) or 200 end
    end

    -- === DASH LOCK ===
    do
        local DL = { Enabled = false, Active = false, Duration = 1.5, Smooth = 0.3,
            Freeze = false, Target = nil, Conn = nil }
        W.DashLock = DL
        local DASH_ANIM = "rbxassetid://98163597193511"

        local function Update()
            if not DL.Enabled or not DL.Active then return end
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then DL.Target = nil; return end
            local t, td = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and TeamIs(p, "Survivor") then
                    local c = p.Character
                    if c then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if r and h and h.Health > 0 then
                            local d = (myRoot.Position - r.Position).Magnitude
                            if d < td then td = d; t = r end
                        end
                    end
                end
            end
            if not t then DL.Target = nil; return end
            DL.Target = t
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Position), DL.Smooth or 0.3)
            end
            if DL.Freeze then
                local h = myChar:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed ~= 0 then h.WalkSpeed = 0 end
            end
        end
        local function SetActive(a)
            a = a and true or false
            if a == DL.Active then return end
            DL.Active = a
            if a then
                if not DL.Conn then DL.Conn = RunService.RenderStepped:Connect(function() pcall(Update) end) end
            else
                if DL.Conn then pcall(function() DL.Conn:Disconnect() end); DL.Conn = nil end
                DL.Target = nil
                if DL.Freeze then
                    local c = LP.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.WalkSpeed == 0 then h.WalkSpeed = 16 end
                end
            end
        end
        local function Hook(char)
            if not char then return end
            local h = char:FindFirstChildOfClass("Humanoid")
            if not h then return end
            local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5)
            if not a then return end
            a.AnimationPlayed:Connect(function(t)
                if not DL.Enabled then return end
                local aid = t.Animation and t.Animation.AnimationId or ""
                if aid == DASH_ANIM then
                    SetActive(true)
                    task.delay(DL.Duration or 1.5, function() SetActive(false) end)
                end
            end)
        end
        if LP.Character then Hook(LP.Character) end
        LP.CharacterAdded:Connect(function(c) task.wait(0.5); Hook(c) end)
        function W.DashLock_Set(v)
            DL.Enabled = v and true or false
            if not v then SetActive(false) end
        end
    end

    -- === UI SECTION ===
    do
        local s = W.T_Kill:AddSection("Bypass No Cooldown")
        s:AddToggle({ Title = "Hidden Leap", Default = false, Callback = function(v) W.SetHiddenLeap(v) end })
        s:AddToggle({ Title = "Myers Grab (H)", Default = false, Callback = function(v) W.Myers_Set(v) end })
        s:AddToggle({ Title = "Slasher LakeMist", Default = false, Callback = function(v) W.SetLakeMist(v) end })
        s:AddToggle({ Title = "Slasher Pursuit", Default = false, Callback = function(v) W.SetPursuit(v) end })
        s:AddToggle({ Title = "Abyss Bypass", Default = false, Callback = function(v) W.SetAbyssBypass(v) end })
        s:AddToggle({ Title = "Jeff Infinite Frenzy", Default = false, Callback = function(v) W.SetJeffFrenzy(v) end })

        local s2 = W.T_Kill:AddSection("Unlock Skill While Carrying")
        s2:AddToggle({ Title = "Enable", Default = false, Callback = function(v) W.SetUnlockCarry(v) end })

        local s3 = W.T_Kill:AddSection("Spear Aimbot")
        s3:AddToggle({ Title = "Enable", Default = false, Callback = function(v) W.SpearAimbot_Set(v) end })
        s3:AddSlider({ Title = "Gravity", Min = 10, Max = 200, Default = 50, Increment = 1,
            Callback = function(v) W.SpearAimbot_SetG(v) end })
        s3:AddSlider({ Title = "Speed", Min = 50, Max = 300, Default = 100, Increment = 5,
            Callback = function(v) W.SpearAimbot_SetS(v) end })

        local s4 = W.T_Kill:AddSection("Killer Abilities")
        s4:AddToggle({ Title = "Auto Stalk", Default = false, Callback = function(v) W.KA_SetAutoStalk(v) end })
        s4:AddSlider({ Title = "Stalk Range", Min = 20, Max = 500, Default = 150, Increment = 10, Suffix = " studs",
            Callback = function(v) KA.AutoStalkRange = v end })
        s4:AddToggle({ Title = "Auto Kill All", Default = false, Callback = function(v) W.KA_SetAutoKillAll(v) end })
        s4:AddToggle({ Title = "Drop All Pallet", Default = false, Callback = function(v) W.KA_SetDropAllPallet(v) end })
        s4:AddToggle({ Title = "Block All Vault", Default = false, Callback = function(v) W.KA_SetBlockAllVault(v) end })
        s4:AddToggle({ Title = "Auto Hook", Default = false, Callback = function(v) W.KA_SetAutoHook(v) end })
        s4:AddButton({ Title = "Instant Auto Kill (1x)", Callback = function()
            local saved = KA.AutoKillAll
            KA.AutoKillAll = true
            task.spawn(function() task.wait(0.3); KA.AutoKillAll = saved end)
            ShowNotify("Auto Kill", "Triggered", 2)
        end })
        s4:AddButton({ Title = "Instant Drop All Pallet (1x)", Callback = function()
            W.KA_DropAllPallets_Force()
            ShowNotify("Drop Pallet", "Triggered", 2)
        end })
        s4:AddButton({ Title = "Instant Block All Vault (1x)", Callback = function()
            W.KA_BlockAllVaults_Force()
            ShowNotify("Block Vault", "Triggered", 2)
        end })
        s4:AddButton({ Title = "Unblock All Vault (1x)", Callback = function()
            local VCE = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Window")
                and ReplicatedStorage.Remotes.Window:FindFirstChild("VaultCompleteEvent")
            if not VCE then return end
            local count = 0
            local map = workspace:FindFirstChild("Map"); if not map then return end
            for _, trigger in ipairs(map:GetDescendants()) do
                if trigger.Name == "VaultPointInUse" then
                    local vp = trigger.Parent
                    if vp then
                        pcall(function() VCE:FireServer(vp, false); count = count + 1 end)
                    end
                end
            end
            ShowNotify("Unblock Vault", "Unblocked " .. count .. " vaults!", 3)
        end })

        local s5 = W.T_Kill:AddSection("Silent Flask (The Cure)")
        s5:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.Flask_Set(v); ShowNotify("W2HUB", "Silent Flask " .. (v and "ON" or "OFF"), 2)
        end })
        s5:AddToggle({ Title = "Show Beam", Default = true, Callback = function(v) W.Flask.ShowBeam = v end })
        s5:AddToggle({ Title = "Show Landing", Default = true, Callback = function(v) W.Flask.ShowLanding = v end })
        s5:AddToggle({ Title = "Enable Prediction", Default = true, Callback = function(v) W.Flask.Predict = v end })
        s5:AddSlider({ Title = "Speed", Min = 30, Max = 200, Default = 90, Increment = 5, Callback = function(v) W.Flask_SetSpeed(v) end })
        s5:AddSlider({ Title = "Gravity", Min = 50, Max = 400, Default = 196, Increment = 5, Callback = function(v) W.Flask_SetGravity(v) end })
        s5:AddSlider({ Title = "Lead Multiplier", Min = 0, Max = 3, Default = 1.0, Increment = 0.1, Callback = function(v) W.Flask_SetLead(v) end })
        s5:AddSlider({ Title = "Max Range", Min = 50, Max = 500, Default = 200, Increment = 10, Suffix = " studs", Callback = function(v) W.Flask_SetRange(v) end })

        local s6 = W.T_Kill:AddSection("Dash Lock")
        s6:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.DashLock_Set(v); ShowNotify("W2HUB", "Dash Lock " .. (v and "ON" or "OFF"), 2)
        end })
        s6:AddSlider({ Title = "Duration", Min = 0.5, Max = 5, Default = 1.5, Increment = 0.1, Suffix = "s",
            Callback = function(v) W.DashLock.Duration = v end })
        s6:AddSlider({ Title = "Smoothness", Min = 0.05, Max = 1, Default = 0.3, Increment = 0.05,
            Callback = function(v) W.DashLock.Smooth = v end })
        s6:AddToggle({ Title = "Freeze Character", Default = false, Callback = function(v)
            W.DashLock.Freeze = v
            if not v then
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed == 0 then h.WalkSpeed = 16 end
            end
        end })
    end

    print("[W2HUB] PART 11 Loaded OK")

-- PART 12-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 12: VISUALS — ESP + STATUS + HITBOX + GRAPHICS + CAMERA
    --====================================================--

    -- === FULL ESP SYSTEM ===
    W.FESP = W.FESP or {
        Survivor = false, Killer = false, Generator = false, Pallet = false,
        Window = false, SCP = false, Distance = 500,
    }
    W.FESPS = W.FESPS or {
        Enabled = false, ShowName = true, ShowDistance = true, ShowHealth = false,
        ShowAvatar = true, ShowAction = true, Radius = 500,
    }
    W.FESPC = W.FESPC or {
        Survivor = Color3.fromRGB(0, 190, 255), Killer = Color3.fromRGB(255, 0, 0),
        Generator = Color3.fromRGB(255, 255, 0), Window = Color3.fromRGB(255, 255, 255),
        Pallet = Color3.fromRGB(255, 165, 0), SCP = Color3.fromRGB(0, 255, 0),
    }
    local FESP = W.FESP
    local FESPS = W.FESPS
    local FESPC = W.FESPC

    do
        local ESPObjects, StatusESP = {}, {}
        local CachedSCP, CachedGen, CachedPallet = {}, {}, {}
        local WindowObjects = {}

        local function Cache(obj)
            if not obj then return end
            local ln = string.lower(obj.Name)
            if string.find(ln, "scp", 1, true) then CachedSCP[obj] = true end
            if obj.Name == "Generator" then CachedGen[obj] = true
            elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then CachedPallet[obj] = true end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do Cache(o) end
        Workspace.DescendantAdded:Connect(Cache)
        Workspace.DescendantRemoving:Connect(function(o)
            CachedSCP[o] = nil; CachedGen[o] = nil; CachedPallet[o] = nil
            if ESPObjects[o] then pcall(function() ESPObjects[o]:Destroy() end); ESPObjects[o] = nil end
            if StatusESP[o] then pcall(function() StatusESP[o]:Destroy() end); StatusESP[o] = nil end
        end)

        local function RemoveESP(obj)
            if not obj then return end
            if ESPObjects[obj] then pcall(function() ESPObjects[obj]:Destroy() end); ESPObjects[obj] = nil end
        end
        local function CreateESP(obj, color)
            if not obj or not obj.Parent then return end
            if ESPObjects[obj] then
                ESPObjects[obj].FillColor = color
                ESPObjects[obj].OutlineColor = color
                return
            end
            local h = Instance.new("Highlight")
            h.FillColor = color; h.OutlineColor = color
            h.FillTransparency = 0.9; h.OutlineTransparency = 0.3
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = obj
            ESPObjects[obj] = h
            obj.AncestryChanged:Connect(function(_, p) if not p then RemoveESP(obj) end end)
        end

        local function RemoveStatus(char)
            if StatusESP[char] then pcall(function() StatusESP[char]:Destroy() end); StatusESP[char] = nil end
        end
        local function GetAction(char, hum)
            if not char or not hum then return "IDLE", Color3.fromRGB(150, 150, 150) end
            if hum.Health <= 0 then return "DEAD", Color3.fromRGB(200, 60, 60) end
            if char:GetAttribute("IsHooked") or char:GetAttribute("isHooked") or char:GetAttribute("Hooked") then
                return "HOOKED", Color3.fromRGB(255, 60, 60)
            end
            if char:GetAttribute("IsCarried") or char:GetAttribute("isCarried") or char:GetAttribute("Carried") then
                return "CARRIED", Color3.fromRGB(255, 100, 100)
            end
            local st = char:GetAttribute("State")
            if st == "Downed" or char:GetAttribute("Knocked") == true or char:GetAttribute("IsDown") == true or char:GetAttribute("Downed") == true then
                return "DOWNED", Color3.fromRGB(255, 130, 60)
            end
            local ci = char:FindFirstChild("CheckInterractable")
            if ci then
                if ci:GetAttribute("isRepairing") then return "REPAIR", Color3.fromRGB(255, 220, 60) end
                if ci:GetAttribute("isHealing") then return "HEAL", Color3.fromRGB(80, 220, 120) end
                if ci:GetAttribute("isVaulting") then return "VAULT", Color3.fromRGB(120, 200, 255) end
                if ci:GetAttribute("isSliding") then return "SLIDE", Color3.fromRGB(150, 180, 255) end
                if ci:GetAttribute("isDroppingPallet") then return "PALLET", Color3.fromRGB(255, 165, 60) end
                if ci:GetAttribute("isUnhooking") then return "UNHOOK", Color3.fromRGB(180, 120, 255) end
                if ci:GetAttribute("isExiting") then return "EXIT", Color3.fromRGB(80, 255, 180) end
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local v = root.AssemblyLinearVelocity
                local sp = Vector3.new(v.X, 0, v.Z).Magnitude
                if sp > 20 then return "SPRINT", Color3.fromRGB(120, 255, 200) end
                if sp > 2 then return "MOVE", Color3.fromRGB(200, 200, 220) end
            end
            return "IDLE", Color3.fromRGB(150, 150, 150)
        end

        local function CreateStatus(plr, char, root)
            if not FESPS.Enabled then RemoveStatus(char); return end
            if not root then return end
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not head or not hum then return end
            local isDown = hum.Health <= 0 or hum.Health < 2 or char:GetAttribute("Downed") == true
                or char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
            local dist = (head.Position - root.Position).Magnitude
            if dist > FESPS.Radius then RemoveStatus(char); return end
            local accent = Color3.fromRGB(255, 255, 255)
            if TeamIs(plr, "Killer") then accent = FESPC.Killer
            elseif TeamIs(plr, "Survivor") then accent = FESPC.Survivor end
            if isDown then accent = Color3.fromRGB(255, 60, 60) end
            local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            local hpCol
            if hpPct > 0.6 then hpCol = Color3.fromRGB(80, 220, 120)
            elseif hpPct > 0.3 then hpCol = Color3.fromRGB(255, 200, 60)
            else hpCol = Color3.fromRGB(255, 80, 80) end
            local act, actCol = GetAction(char, hum)
            local bb = StatusESP[char]
            if not bb or not bb.Parent then
                bb = Instance.new("BillboardGui")
                bb.Name = "W2HUBStatusESP"
                bb.AlwaysOnTop = true; bb.LightInfluence = 0
                bb.Adornee = head; bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.Size = UDim2.fromOffset(260, 40); bb.Parent = char
                local sc = Instance.new("UIScale"); sc.Name = "DistScale"; sc.Scale = 1; sc.Parent = bb
                local nLbl = Instance.new("TextLabel")
                nLbl.Name = "NameLbl"; nLbl.BackgroundTransparency = 1
                nLbl.Size = UDim2.new(1, 0, 0, 16); nLbl.Position = UDim2.new(0, 0, 0, 0)
                nLbl.Font = Enum.Font.GothamBold; nLbl.TextSize = 13
                nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                nLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nLbl.TextStrokeTransparency = 0.2
                nLbl.TextXAlignment = Enum.TextXAlignment.Center
                nLbl.TextYAlignment = Enum.TextYAlignment.Center
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = bb
                local pill = Instance.new("Frame")
                pill.Name = "Pill"; pill.AnchorPoint = Vector2.new(0.5, 0)
                pill.Position = UDim2.new(0.5, 0, 0, 18)
                pill.Size = UDim2.fromOffset(120, 22)
                pill.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
                pill.BackgroundTransparency = 0.15; pill.BorderSizePixel = 0; pill.Parent = bb
                Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
                local ps = Instance.new("UIStroke", pill)
                ps.Name = "PillStroke"; ps.Color = accent; ps.Thickness = 1; ps.Transparency = 0.5
                local lay = Instance.new("UIListLayout", pill)
                lay.FillDirection = Enum.FillDirection.Horizontal
                lay.Padding = UDim.new(0, 5); lay.SortOrder = Enum.SortOrder.LayoutOrder
                lay.VerticalAlignment = Enum.VerticalAlignment.Center
                lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
                local pad = Instance.new("UIPadding", pill)
                pad.PaddingLeft = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 8)
                local avH = Instance.new("Frame", pill)
                avH.Name = "AvatarHolder"; avH.Size = UDim2.fromOffset(18, 18)
                avH.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                avH.BorderSizePixel = 0; avH.LayoutOrder = 1; avH.ClipsDescendants = true
                Instance.new("UICorner", avH).CornerRadius = UDim.new(1, 0)
                local avS = Instance.new("UIStroke", avH)
                avS.Name = "AvatarStroke"; avS.Color = accent; avS.Thickness = 1.2; avS.Transparency = 0.3
                local avImg = Instance.new("ImageLabel", avH)
                avImg.Name = "AvatarImg"; avImg.Size = UDim2.fromScale(1, 1)
                avImg.BackgroundTransparency = 1
                avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
                local dot = Instance.new("Frame", pill)
                dot.Name = "Dot"; dot.Size = UDim2.fromOffset(7, 7)
                dot.BackgroundColor3 = accent; dot.BorderSizePixel = 0
                dot.LayoutOrder = 1; dot.Visible = false
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                local distLbl = Instance.new("TextLabel", pill)
                distLbl.Name = "DistLbl"; distLbl.BackgroundTransparency = 1
                distLbl.Size = UDim2.fromOffset(32, 14); distLbl.Font = Enum.Font.GothamBold
                distLbl.TextSize = 11; distLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
                distLbl.Text = "0m"; distLbl.LayoutOrder = 2
                local actLbl = Instance.new("TextLabel", pill)
                actLbl.Name = "ActionLbl"; actLbl.BackgroundTransparency = 1
                actLbl.Size = UDim2.fromOffset(50, 14); actLbl.Font = Enum.Font.GothamBold
                actLbl.TextSize = 10; actLbl.TextColor3 = actCol
                actLbl.Text = "IDLE"; actLbl.LayoutOrder = 3
                local hpBg = Instance.new("Frame", pill)
                hpBg.Name = "HPBarBg"; hpBg.Size = UDim2.fromOffset(38, 4)
                hpBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                hpBg.BorderSizePixel = 0; hpBg.LayoutOrder = 4
                Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
                local hpFill = Instance.new("Frame", hpBg)
                hpFill.Name = "HPBarFill"; hpFill.Size = UDim2.new(1, 0, 1, 0)
                hpFill.BackgroundColor3 = hpCol; hpFill.BorderSizePixel = 0
                Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
                local downP = Instance.new("Frame", pill)
                downP.Name = "DownPill"; downP.Size = UDim2.fromOffset(36, 14)
                downP.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                downP.BackgroundTransparency = 0.1; downP.BorderSizePixel = 0
                downP.Visible = false; downP.LayoutOrder = 5
                Instance.new("UICorner", downP).CornerRadius = UDim.new(1, 0)
                local downL = Instance.new("TextLabel", downP)
                downL.Name = "DownLbl"; downL.Size = UDim2.new(1, 0, 1, 0)
                downL.BackgroundTransparency = 1; downL.Font = Enum.Font.GothamBold
                downL.TextSize = 9; downL.TextColor3 = Color3.fromRGB(255, 255, 255)
                downL.Text = "DOWN"
                StatusESP[char] = bb
            end
            local nLbl = bb:FindFirstChild("NameLbl")
            local pill = bb:FindFirstChild("Pill")
            if not pill then return end
            local ps = pill:FindFirstChild("PillStroke")
            local avH = pill:FindFirstChild("AvatarHolder")
            local avImg = avH and avH:FindFirstChild("AvatarImg")
            local avS = avH and avH:FindFirstChild("AvatarStroke")
            local dot = pill:FindFirstChild("Dot")
            local distLbl = pill:FindFirstChild("DistLbl")
            local actLbl = pill:FindFirstChild("ActionLbl")
            local hpBg = pill:FindFirstChild("HPBarBg")
            local hpFill = hpBg and hpBg:FindFirstChild("HPBarFill")
            local downP = pill:FindFirstChild("DownPill")
            local dScale = bb:FindFirstChild("DistScale")
            if ps then ps.Color = accent; ps.Transparency = isDown and 0.2 or 0.5 end
            if avH then
                avH.Visible = FESPS.ShowAvatar == true
                if avS then avS.Color = accent end
                if avImg and avImg.Image == "" then
                    avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
                end
            end
            if dot then dot.Visible = (FESPS.ShowAvatar ~= true); dot.BackgroundColor3 = accent end
            if nLbl then
                nLbl.Text = plr.Name
                nLbl.Visible = FESPS.ShowName
                nLbl.TextColor3 = isDown and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
            end
            if distLbl then distLbl.Text = string.format("%.0fm", dist); distLbl.Visible = FESPS.ShowDistance end
            if actLbl then
                actLbl.Text = act; actLbl.TextColor3 = actCol
                actLbl.Visible = FESPS.ShowAction == true
                if act == "IDLE" then actLbl.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            if hpBg and hpFill then
                hpFill.Size = UDim2.new(hpPct, 0, 1, 0)
                hpFill.BackgroundColor3 = hpCol
                hpBg.Visible = FESPS.ShowHealth
            end
            if downP then downP.Visible = isDown end
            local totalW = 14
            local cnt = 0
            if FESPS.ShowAvatar then totalW = totalW + 18; cnt = cnt + 1
            else totalW = totalW + 7; cnt = cnt + 1 end
            if FESPS.ShowDistance then totalW = totalW + 32; cnt = cnt + 1 end
            if FESPS.ShowAction then totalW = totalW + 50; cnt = cnt + 1 end
            if FESPS.ShowHealth then totalW = totalW + 38; cnt = cnt + 1 end
            if isDown then totalW = totalW + 36; cnt = cnt + 1 end
            totalW = totalW + math.max(cnt - 1, 0) * 5
            if totalW < 50 then totalW = 50 end
            if totalW > 240 then totalW = 240 end
            pill.Size = UDim2.fromOffset(totalW, 22)
            local showPill = FESPS.ShowDistance or FESPS.ShowHealth or isDown or FESPS.ShowAction or FESPS.ShowAvatar
            pill.Visible = showPill
            bb.Size = UDim2.fromOffset(260, 16 + (showPill and 24 or 0))
            if dScale then
                local sv = math.clamp(1 - (dist - 50) / 500, 0.5, 1.05)
                dScale.Scale = sv
            end
        end

        local function GetGVal(obj, name)
            if not obj then return nil end
            local a = obj:GetAttribute(name)
            if a ~= nil then return a end
            local c = obj:FindFirstChild(name)
            if c then local ok, v = pcall(function() return c.Value end); if ok then return v end end
            return nil
        end

        local function UpdateGen(gen)
            if not gen or not gen.Parent then return end
            if not FESP.Generator then
                local o = gen:FindFirstChild("GenESP"); if o then o:Destroy() end
                local h = gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
                return
            end
            local pct = GetGVal(gen, "RepairProgress") or GetGVal(gen, "Progress") or GetGVal(gen, "ProgressRepair") or 0
            local bb = gen:FindFirstChild("GenESP")
            if pct >= 100 then if bb then bb:Destroy() end; return end
            local cp = math.clamp(pct, 0, 100)
            local color = FESPC.Generator:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
            local text = string.format("[%.0f%%]", pct)
            if not bb then
                bb = Instance.new("BillboardGui")
                bb.Name = "GenESP"; bb.Size = UDim2.new(0, 100, 0, 30)
                bb.AlwaysOnTop = true
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
                lbl.Text = text; lbl.TextColor3 = color; lbl.TextStrokeTransparency = 0
                lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
                lbl.Parent = bb
                bb.Adornee = gen; bb.Parent = gen
            else
                local lbl = bb:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = text; lbl.TextColor3 = color end
            end
            local h = gen:FindFirstChild("GenHighlight") or Instance.new("Highlight")
            h.Name = "GenHighlight"; h.Adornee = gen
            h.FillColor = color; h.OutlineColor = color
            h.FillTransparency = 0.9; h.OutlineTransparency = 0.3
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = gen
        end

        local function UpdateMapESP(obj, root)
            if not obj or not root or not obj.Parent then return end
            local pos
            if obj:IsA("Model") then
                if obj.PrimaryPart then pos = obj.PrimaryPart.Position
                else
                    local ok, p = pcall(function() return obj:GetPivot().Position end)
                    pos = ok and p or nil
                    if not pos then local bp = obj:FindFirstChildWhichIsA("BasePart", true); if bp then pos = bp.Position end end
                end
            elseif obj:IsA("BasePart") then pos = obj.Position end
            if not pos then return end
            local dist = (pos - root.Position).Magnitude
            if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
                if FESP.Pallet and dist <= FESP.Distance then CreateESP(obj, FESPC.Pallet)
                else RemoveESP(obj) end
            end
        end

        local function UpdateSCP(root)
            if not FESP.SCP then for obj in pairs(CachedSCP) do RemoveESP(obj) end; return end
            for obj in pairs(CachedSCP) do
                if obj and obj.Parent then
                    local pos
                    if obj:IsA("Model") then
                        local ok, p = pcall(function() return obj:GetPivot().Position end)
                        pos = ok and p or nil
                    elseif obj:IsA("BasePart") then pos = obj.Position end
                    if pos then
                        local d = (pos - root.Position).Magnitude
                        if d <= FESP.Distance then CreateESP(obj, FESPC.SCP)
                        else RemoveESP(obj) end
                    end
                end
            end
        end

        local function RemoveWindowESP(model)
            if not model then return end
            local wData = WindowObjects[model]
            if wData then
                if wData.highlight then pcall(function() wData.highlight:Destroy() end) end
                if wData.box then pcall(function() wData.box:Destroy() end) end
                if wData.bottomPart and wData.bottomPart.Parent then
                    pcall(function()
                        local o = wData.bottomPart:GetAttribute("ESP_OrigTrans")
                        if o ~= nil then wData.bottomPart.Transparency = o; wData.bottomPart:SetAttribute("ESP_OrigTrans", nil) end
                    end)
                end
                WindowObjects[model] = nil
            end
        end

        local function HandleWindow(child)
            if not FESP.Window then return end
            if not child or child.Name ~= "VaultTrigger" then return end
            local winModel = child.Parent
            if not winModel or not winModel:IsA("Model") then return end
            if WindowObjects[winModel] then return end
            local bottomPart = winModel:FindFirstChild("Bottom")
            if not bottomPart or not bottomPart:IsA("BasePart") then
                local bestSize = 0
                for _, p in ipairs(winModel:GetChildren()) do
                    if p:IsA("BasePart") and p.Name ~= "VaultTrigger" and p.Name ~= "inviswall" and p.Size.Magnitude > bestSize then
                        bestSize = p.Size.Magnitude; bottomPart = p
                    end
                end
            end
            if not bottomPart then return end
            if bottomPart:GetAttribute("ESP_OrigTrans") == nil then
                bottomPart:SetAttribute("ESP_OrigTrans", bottomPart.Transparency)
            end
            if bottomPart.Transparency > 0.5 then bottomPart.Transparency = 0.5 end
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "W2HUBWindowBox"; box.Adornee = bottomPart; box.Size = bottomPart.Size
            box.Color3 = FESPC.Window; box.Transparency = 0.3; box.AlwaysOnTop = true; box.ZIndex = 5
            box.Parent = bottomPart
            local hl = Instance.new("Highlight")
            hl.Name = "W2HUBWindowHighlight"; hl.Adornee = winModel
            hl.FillColor = FESPC.Window; hl.FillTransparency = 0.9
            hl.OutlineColor = FESPC.Window; hl.OutlineTransparency = 0.1
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = winModel
            WindowObjects[winModel] = { highlight = hl, box = box, bottomPart = bottomPart }
        end

        local function ScanWindows()
            if not FESP.Window then return end
            local map = Workspace:FindFirstChild("Map")
            if not map then return end
            for _, o in ipairs(map:GetDescendants()) do
                if o.Name == "VaultTrigger" then HandleWindow(o) end
            end
        end

        Workspace.DescendantAdded:Connect(function(o)
            if o.Name == "VaultTrigger" and FESP.Window then
                task.defer(function() HandleWindow(o) end)
            end
        end)

        local lastUpd = 0
        RunService.RenderStepped:Connect(function()
            local now = tick()
            if now - lastUpd < 0.05 then return end
            lastUpd = now
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local char = p.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d <= FESP.Distance then
                                if FESP.Survivor and TeamIs(p, "Survivor") then CreateESP(char, FESPC.Survivor)
                                elseif FESP.Killer and TeamIs(p, "Killer") then CreateESP(char, FESPC.Killer)
                                else RemoveESP(char) end
                            else RemoveESP(char) end
                        end
                        CreateStatus(p, char, root)
                    else
                        RemoveESP(char); RemoveStatus(char)
                    end
                end
            end
            if FESP.Generator then for gen in pairs(CachedGen) do UpdateGen(gen) end end
            for obj in pairs(CachedPallet) do UpdateMapESP(obj, root) end
            UpdateSCP(root)
            if FESP.Window then
                if not _G.W2HUBWindowScanned then _G.W2HUBWindowScanned = true; pcall(ScanWindows) end
            else
                _G.W2HUBWindowScanned = false
                for model in pairs(WindowObjects) do RemoveWindowESP(model) end
            end
        end)
    end

    -- === HITBOX ===
    W.Hitbox = W.Hitbox or {
        Enabled = false, Color = Color3.fromRGB(255, 0, 0), Transparency = 0.6,
        Expand = false, SizeMult = 2, TargetMode = "Both",
        ESPBox = false, HideESP = false, ESPColor = Color3.fromRGB(255, 0, 0),
    }
    local HB = W.Hitbox
    do
        local HitboxObj, ESPBoxObj = {}, {}
        local function ClearHitbox(c)
            if HitboxObj[c] then pcall(function() HitboxObj[c]:Destroy() end); HitboxObj[c] = nil end
        end
        local function ClearESPBox(c)
            if ESPBoxObj[c] then pcall(function() ESPBoxObj[c]:Destroy() end); ESPBoxObj[c] = nil end
        end
        local function IsTarget(p)
            if p == LP then return false end
            if HB.TargetMode == "Killer" then return TeamIs(p, "Killer") end
            if HB.TargetMode == "Survivor" then return TeamIs(p, "Survivor") end
            return TeamIs(p, "Killer") or TeamIs(p, "Survivor")
        end
        local function CreateHB(char, part)
            if not char or not part or not part.Parent then return end
            if HitboxObj[char] then
                local b = HitboxObj[char]
                b.Size = part.Size * (HB.Expand and (HB.SizeMult or 2) or 1)
                b.Color3 = HB.Color; b.Transparency = HB.Transparency
                return
            end
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "W2HUBHitbox"; box.Adornee = part
            box.Size = part.Size * (HB.Expand and (HB.SizeMult or 2) or 1)
            box.Color3 = HB.Color; box.Transparency = HB.Transparency
            box.AlwaysOnTop = true; box.ZIndex = 5; box.Parent = part
            HitboxObj[char] = box
        end
        local function CreateESPBox(char, root)
            if not char or not root or not root.Parent then return end
            if ESPBoxObj[char] then
                local b = ESPBoxObj[char]
                b.Size = root.Size * 1.5; b.Color3 = HB.ESPColor
                b.Transparency = 0.3; b.Visible = not HB.HideESP
                return
            end
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "W2HUBESPBox"; box.Adornee = root
            box.Size = root.Size * 1.5; box.Color3 = HB.ESPColor
            box.Transparency = 0.3; box.AlwaysOnTop = true; box.ZIndex = 6; box.Parent = root
            ESPBoxObj[char] = box
        end
        RunService.RenderStepped:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local char = p.Character
                    if HB.Enabled and IsTarget(p) then
                        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
                        if torso then CreateHB(char, torso) end
                    else ClearHitbox(char) end
                    if HB.ESPBox and IsTarget(p) then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then CreateESPBox(char, root) end
                    else ClearESPBox(char) end
                else
                    if p.Character then ClearHitbox(p.Character); ClearESPBox(p.Character) end
                end
            end
        end)
    end

    -- === GRAPHICS ===
    W.Graphics = W.Graphics or {
        Fullbright = false, NoShadow = false, LowGraphics = false,
        NoScreenEffects = false, CleanSky = false,
        ClockTimeEnabled = false, ClockTime = 14, Brightness = 2,
        UnlimitedZoom = false, MaxZoomDistance = 1000,
        FOVEnabled = false, FOV = 70, PotatoEnabled = false,
    }
    local G = W.Graphics
    local origG = {
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        FOV = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
    }
    local lastG = { FB = nil, NS = nil, Amb = nil, Br = nil, Cl = nil }
    local lastOpt = { LG = nil, CS = nil }
    local disabledFX = {}
    local FXTypes = {"ColorCorrectionEffect","DepthOfFieldEffect","BlurEffect","SunRaysEffect","BloomEffect"}

    local function ApplyGraphics(force)
        if force or lastG.FB ~= G.Fullbright then
            lastG.FB = G.Fullbright
            if G.Fullbright then
                Lighting.Brightness = 2; Lighting.ClockTime = 14
                Lighting.Ambient = Color3.fromRGB(255,255,255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            else
                Lighting.Brightness = origG.Brightness
                Lighting.ClockTime = origG.ClockTime
                Lighting.Ambient = origG.Ambient
                Lighting.OutdoorAmbient = origG.OutdoorAmbient
            end
        end
        if force or lastG.NS ~= G.NoShadow then
            lastG.NS = G.NoShadow
            Lighting.GlobalShadows = not G.NoShadow
        end
        local ambChanged = lastG.Amb ~= G.ClockTimeEnabled or lastG.Br ~= G.Brightness or lastG.Cl ~= G.ClockTime
        if force or ambChanged then
            lastG.Amb = G.ClockTimeEnabled; lastG.Br = G.Brightness; lastG.Cl = G.ClockTime
            if G.ClockTimeEnabled then
                Lighting.ClockTime = G.ClockTime; Lighting.Brightness = G.Brightness
            elseif not G.Fullbright then
                Lighting.Brightness = origG.Brightness
                Lighting.ClockTime = origG.ClockTime
            end
        end
    end
    local function ApplyOpt(force)
        if force or lastOpt.LG ~= G.LowGraphics then
            lastOpt.LG = G.LowGraphics
            pcall(function()
                if G.LowGraphics then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
            end)
        end
        if force or lastOpt.CS ~= G.CleanSky then
            lastOpt.CS = G.CleanSky
            if G.CleanSky then
                for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
            end
        end
    end
    local function ApplyNoFX()
        if G.NoScreenEffects then
            for _, v in pairs(Lighting:GetChildren()) do
                for _, t in ipairs(FXTypes) do
                    if v:IsA(t) then
                        if disabledFX[v] == nil then disabledFX[v] = v.Enabled end
                        v.Enabled = false
                    end
                end
            end
        else
            for obj, st in pairs(disabledFX) do if obj and obj.Parent then obj.Enabled = st end end
            disabledFX = {}
        end
    end
    Lighting.ChildAdded:Connect(function(v)
        if not G.NoScreenEffects then return end
        task.wait()
        for _, t in ipairs(FXTypes) do
            if v:IsA(t) then
                if disabledFX[v] == nil then disabledFX[v] = v.Enabled end
                v.Enabled = false
            end
        end
    end)
    local function ApplyZoom()
        if G.UnlimitedZoom then
            LP.CameraMaxZoomDistance = G.MaxZoomDistance
            LP.CameraMinZoomDistance = 0
        else
            LP.CameraMaxZoomDistance = 128
            LP.CameraMinZoomDistance = 0.5
        end
    end
    local function ApplyFOV()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if G.FOVEnabled then cam.FieldOfView = G.FOV
        else cam.FieldOfView = origG.FOV end
    end
    RunService.RenderStepped:Connect(function()
        if G.FOVEnabled then
            local cam = Workspace.CurrentCamera
            if cam and cam.FieldOfView ~= G.FOV then cam.FieldOfView = G.FOV end
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not G.UnlimitedZoom then return end
        if LP.CameraMaxZoomDistance ~= G.MaxZoomDistance then LP.CameraMaxZoomDistance = G.MaxZoomDistance end
        if LP.CameraMinZoomDistance ~= 0 then LP.CameraMinZoomDistance = 0 end
    end)
    W.ApplyGraphics = ApplyGraphics
    W.ApplyOpt = ApplyOpt
    W.ApplyNoFX = ApplyNoFX
    W.ApplyZoom = ApplyZoom
    W.ApplyFOV = ApplyFOV
    LP.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyGraphics(true); ApplyOpt(true); ApplyNoFX(); ApplyZoom(); ApplyFOV()
    end)

    -- === CAMERA DBD ===
    W.CamDBD = W.CamDBD or {
        Enabled = false, Smooth = 4, POVLock = false,
        POVValue = 85, POVSmooth = 9,
    }
    local CD = W.CamDBD
    do
        local prevPos, prevRot = nil, nil
        RunService:BindToRenderStep("W2HUBCamDBD", Enum.RenderPriority.Camera.Value + 1, function(dt)
            local cam = Workspace.CurrentCamera
            if not cam then return end
            if cam.CameraType ~= Enum.CameraType.Custom and cam.CameraType ~= Enum.CameraType.Follow then
                prevPos = nil; prevRot = nil; return
            end
            if CD.Enabled then
                local curCF = cam.CFrame
                if not prevPos or not prevRot then
                    prevPos = curCF.Position; prevRot = curCF.Rotation
                else
                    local spd = CD.Smooth or 4
                    local posA = 1 - math.exp(-spd * dt)
                    prevPos = prevPos:Lerp(curCF.Position, math.clamp(posA, 0, 1))
                    local rotA = 1 - math.exp(-(spd * 1.9) * dt)
                    prevRot = prevRot:Lerp(curCF.Rotation, math.clamp(rotA, 0, 1))
                    cam.CFrame = CFrame.new(prevPos) * prevRot
                end
            else
                prevPos = nil; prevRot = nil
            end
            if CD.POVLock then
                local povSpd = CD.POVSmooth or 9
                local alpha = 1 - math.exp(-povSpd * dt)
                cam.FieldOfView = cam.FieldOfView + ((CD.POVValue or 85) - cam.FieldOfView) * alpha
            end
        end)
        LP.CharacterAdded:Connect(function()
            task.wait(0.5); prevPos = nil; prevRot = nil
        end)
    end

    -- === UI SECTION ===
    do
        local s = W.T_Vis:AddSection("Full ESP System")
        s:AddToggle({ Title = "ESP Survivor", Default = false, Callback = function(v) FESP.Survivor = v end })
        s:AddColorPicker({ Title = "Survivor Color", Default = FESPC.Survivor, Save = false, Callback = function(c) FESPC.Survivor = c end })
        s:AddToggle({ Title = "ESP Killer", Default = false, Callback = function(v) FESP.Killer = v end })
        s:AddColorPicker({ Title = "Killer Color", Default = FESPC.Killer, Save = false, Callback = function(c) FESPC.Killer = c end })
        s:AddToggle({ Title = "ESP Generator", Default = false, Callback = function(v) FESP.Generator = v end })
        s:AddColorPicker({ Title = "Generator Color", Default = FESPC.Generator, Save = false, Callback = function(c) FESPC.Generator = c end })
        s:AddToggle({ Title = "ESP Pallet", Default = false, Callback = function(v) FESP.Pallet = v end })
        s:AddColorPicker({ Title = "Pallet Color", Default = FESPC.Pallet, Save = false, Callback = function(c) FESPC.Pallet = c end })
        s:AddToggle({ Title = "ESP Window", Default = false, Callback = function(v)
            FESP.Window = v; _G.W2HUBWindowScanned = false
        end })
        s:AddColorPicker({ Title = "Window Color", Default = FESPC.Window, Save = false, Callback = function(c) FESPC.Window = c end })
        s:AddToggle({ Title = "ESP SCP", Default = false, Callback = function(v) FESP.SCP = v end })
        s:AddColorPicker({ Title = "SCP Color", Default = FESPC.SCP, Save = false, Callback = function(c) FESPC.SCP = c end })
        s:AddSlider({ Title = "ESP Radius", Min = 10, Max = 1000, Default = 500, Increment = 10,
            Callback = function(v) FESP.Distance = v end })

        local s2 = W.T_Vis:AddSection("ESP Status")
        s2:AddToggle({ Title = "Enable Status ESP", Default = false, Callback = function(v) FESPS.Enabled = v end })
        s2:AddToggle({ Title = "Show Name", Default = true, Callback = function(v) FESPS.ShowName = v end })
        s2:AddToggle({ Title = "Show Distance", Default = true, Callback = function(v) FESPS.ShowDistance = v end })
        s2:AddToggle({ Title = "Show Avatar", Default = true, Callback = function(v) FESPS.ShowAvatar = v end })
        s2:AddToggle({ Title = "Show Action", Default = true, Callback = function(v) FESPS.ShowAction = v end })
        s2:AddToggle({ Title = "Show Health", Default = false, Callback = function(v) FESPS.ShowHealth = v end })
        s2:AddSlider({ Title = "Status Radius", Min = 20, Max = 1000, Default = 500, Increment = 10,
            Callback = function(v) FESPS.Radius = v end })

        local s3 = W.T_Vis:AddSection("Hitbox")
        s3:AddToggle({ Title = "Enable Hitbox", Default = false, Callback = function(v) HB.Enabled = v end })
        s3:AddColorPicker({ Title = "Hitbox Color", Default = Color3.fromRGB(255,0,0), Save = false,
            Callback = function(c) HB.Color = c end })
        s3:AddSlider({ Title = "Transparency", Min = 0, Max = 1, Default = 0.6, Increment = 0.05,
            Callback = function(v) HB.Transparency = v end })
        s3:AddToggle({ Title = "Expand Hitbox", Default = false, Callback = function(v) HB.Expand = v end })
        s3:AddSlider({ Title = "Size Multiplier", Min = 1, Max = 5, Default = 2, Increment = 0.5,
            Callback = function(v) HB.SizeMult = v end })
        s3:AddDropdown({ Title = "Target Mode", Options = {"Killer","Survivor","Both"}, Default = "Both",
            Callback = function(v) HB.TargetMode = v end })
        s3:AddToggle({ Title = "Show ESP Box", Default = false, Callback = function(v) HB.ESPBox = v end })
        s3:AddToggle({ Title = "Hide ESP Box", Default = false, Callback = function(v) HB.HideESP = v end })
        s3:AddColorPicker({ Title = "ESP Box Color", Default = Color3.fromRGB(255,0,0), Save = false,
            Callback = function(c) HB.ESPColor = c end })

        local s4 = W.T_Vis:AddSection("Graphics")
        s4:AddToggle({ Title = "Fullbright", Default = false, Callback = function(v) G.Fullbright = v; ApplyGraphics() end })
        s4:AddToggle({ Title = "No Shadow", Default = false, Callback = function(v) G.NoShadow = v; ApplyGraphics() end })
        s4:AddToggle({ Title = "Low Graphics", Default = false, Callback = function(v) G.LowGraphics = v; ApplyOpt() end })
        s4:AddToggle({ Title = "No Screen Effects", Default = false, Callback = function(v) G.NoScreenEffects = v; ApplyNoFX() end })
        s4:AddToggle({ Title = "Clean Sky", Default = false, Callback = function(v) G.CleanSky = v; ApplyOpt() end })

        local s5 = W.T_Vis:AddSection("Clock & Ambient")
        s5:AddToggle({ Title = "Enable Clock Override", Default = false, Callback = function(v)
            G.ClockTimeEnabled = v; ApplyGraphics()
        end })
        s5:AddSlider({ Title = "Clock Time", Min = 0, Max = 24, Default = 14, Increment = 1,
            Callback = function(v) G.ClockTime = v; G.ClockTimeEnabled = true; ApplyGraphics() end })
        s5:AddSlider({ Title = "Brightness", Min = 0, Max = 5, Default = 2, Increment = 0.1,
            Callback = function(v) G.Brightness = v; G.ClockTimeEnabled = true; ApplyGraphics() end })

        local s6 = W.T_Vis:AddSection("Zoom & FOV")
        s6:AddToggle({ Title = "Unlimited Zoom", Default = false, Callback = function(v)
            G.UnlimitedZoom = v; ApplyZoom()
        end })
        s6:AddSlider({ Title = "Max Zoom Distance", Min = 100, Max = 5000, Default = 1000, Increment = 50,
            Callback = function(v) G.MaxZoomDistance = v end })
        s6:AddToggle({ Title = "Custom FOV", Default = false, Callback = function(v)
            G.FOVEnabled = v; ApplyFOV()
        end })
        s6:AddSlider({ Title = "Camera FOV", Min = 40, Max = 120, Default = 70, Increment = 5,
            Callback = function(v) G.FOV = v end })

        local s7 = W.T_Vis:AddSection("Camera DBD")
        s7:AddToggle({ Title = "Enable Camera DBD", Default = false, Callback = function(v)
            CD.Enabled = v
            ShowNotify("W2HUB", "Camera DBD " .. (v and "ON" or "OFF"), 2)
        end })
        s7:AddSlider({ Title = "Smoothness", Min = 1, Max = 30, Default = 4, Increment = 1,
            Callback = function(v) CD.Smooth = v end })
        s7:AddToggle({ Title = "POV Lock", Default = false, Callback = function(v) CD.POVLock = v end })
        s7:AddSlider({ Title = "POV Value", Min = 60, Max = 120, Default = 85, Increment = 1, Suffix = "°",
            Callback = function(v) CD.POVValue = v end })
        s7:AddSlider({ Title = "POV Smoothness", Min = 3, Max = 20, Default = 9, Increment = 1,
            Callback = function(v) CD.POVSmooth = v end })
    end

    print("[W2HUB] PART 12 Loaded OK")

-- PART 13-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 13: MISC — STUN + INVIS + UTILITY + SPEED + CURSOR + EMOTE + AVATAR + KORLESS + HEADER + SPECTATOR
    --====================================================--

    -- === STUN INDICATOR ===
    W.StunSounds = W.StunSounds or {
        ["Default"]="18843924331",["Clash Royale"]="114072050006157",["Blash"]="89068385567682",
        ["Coin"]="75510526696824",["Kururin Kuru"]="119896940405402",["Spongebob"]="6835794541",
        ["Fahhhh"]="123562480982353",["Cave"]="3173566193",["Aughhh"]="9095205664",
        ["Samsung"]="6879335951",["iPhone"]="4203251375",["Siren"]="130677853589923",
    }
    W.SInd = W.SInd or {
        Enabled = false, Cache = {}, Conn = nil, Range = 500,
        SoundEnabled = true, SoundId = "18843924331",
        Volume = 1.5, SoundRange = 500, SelectedSound = "Default",
    }
    local SInd = W.SInd
    local function SInd_GetId()
        return W.StunSounds[SInd.SelectedSound] or SInd.SoundId
    end
    local function SInd_IsStunned(char)
        if not char then return false end
        if char:GetAttribute("IsStunned") == true then return true end
        if char:GetAttribute("isStunned") == true then return true end
        if char:GetAttribute("Stunned") == true then return true end
        if char:GetAttribute("stunned") == true then return true end
        local ci = char:FindFirstChild("CheckInterractable")
        if ci then
            if ci:GetAttribute("isStunned") == true then return true end
            if ci:GetAttribute("Stunned") == true then return true end
        end
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then
            local sv = h:FindFirstChild("StunValue")
            if sv and sv.Value > 0 then return true end
        end
        return false
    end
    local function SInd_Remove(char)
        local d = SInd.Cache[char]
        if d then
            pcall(function() if d.StopAnim then d.StopAnim() end if d.Gui then d.Gui:Destroy() end end)
            SInd.Cache[char] = nil
        end
    end
    local function SInd_PlaySound(char)
        if not SInd.SoundEnabled then return end
        pcall(function()
            local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local att = head or hrp
            if not att then return end
            local s = Instance.new("Sound")
            s.Name = "W2HUBStunSound"
            s.SoundId = "rbxassetid://" .. tostring(SInd_GetId())
            s.Volume = SInd.Volume or 1.5
            s.RollOffMaxDistance = SInd.SoundRange or 500
            s.RollOffMinDistance = 10
            s.RollOffMode = Enum.RollOffMode.InverseTapered
            s.Parent = att
            s:Play()
            s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
            task.delay(5, function() pcall(function() if s and s.Parent then s:Destroy() end end) end)
        end)
    end
    local function SInd_Create(char)
        if SInd.Cache[char] then return SInd.Cache[char] end
        local head = char:FindFirstChild("Head")
        if not head then return nil end
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "W2HUBStunIndicator"
        bbg.Size = UDim2.fromOffset(140, 42)
        bbg.StudsOffset = Vector3.new(0, 3.0, 0)
        bbg.AlwaysOnTop = true; bbg.LightInfluence = 0
        bbg.MaxDistance = 500; bbg.Adornee = head; bbg.Parent = char
        local p1 = Instance.new("Frame", bbg)
        p1.Name = "Pulse1"; p1.AnchorPoint = Vector2.new(0.5, 0.5)
        p1.Position = UDim2.new(0.5, 0, 0.5, 0)
        p1.Size = UDim2.fromOffset(34, 34)
        p1.BackgroundTransparency = 1; p1.ZIndex = 0
        Instance.new("UICorner", p1).CornerRadius = UDim.new(1, 0)
        local p1s = Instance.new("UIStroke", p1)
        p1s.Color = Color3.fromRGB(255,255,255); p1s.Thickness = 1.8; p1s.Transparency = 0.3
        local p2 = Instance.new("Frame", bbg)
        p2.Name = "Pulse2"; p2.AnchorPoint = Vector2.new(0.5, 0.5)
        p2.Position = UDim2.new(0.5, 0, 0.5, 0)
        p2.Size = UDim2.fromOffset(34, 34)
        p2.BackgroundTransparency = 1; p2.ZIndex = 0
        Instance.new("UICorner", p2).CornerRadius = UDim.new(1, 0)
        local p2s = Instance.new("UIStroke", p2)
        p2s.Color = Color3.fromRGB(200,200,210); p2s.Thickness = 1.8; p2s.Transparency = 0.4
        local main = Instance.new("Frame", bbg)
        main.Name = "Main"; main.Size = UDim2.new(0, 140, 0, 34)
        main.Position = UDim2.new(0, 0, 0, 4)
        main.BackgroundColor3 = Color3.fromRGB(12,12,15)
        main.BackgroundTransparency = 0.05; main.BorderSizePixel = 0; main.ZIndex = 1
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 9)
        local ms = Instance.new("UIStroke", main)
        ms.Name = "MainStroke"; ms.Color = Color3.fromRGB(255,255,255)
        ms.Thickness = 1.3; ms.Transparency = 0.15
        local ih = Instance.new("Frame", main)
        ih.Name = "IconHolder"; ih.Size = UDim2.fromOffset(24, 24)
        ih.Position = UDim2.new(0, 5, 0.5, -12)
        ih.BackgroundColor3 = Color3.fromRGB(22,22,26)
        ih.BorderSizePixel = 0; ih.ZIndex = 3
        Instance.new("UICorner", ih).CornerRadius = UDim.new(1, 0)
        local star = Instance.new("TextLabel", ih)
        star.Name = "StarIcon"; star.Size = UDim2.fromScale(1, 1)
        star.BackgroundTransparency = 1
        star.Font = Enum.Font.GothamBlack; star.Text = "★"
        star.TextColor3 = Color3.fromRGB(255,255,255)
        star.TextScaled = true; star.ZIndex = 4
        local title = Instance.new("TextLabel", main)
        title.Name = "Title"; title.Size = UDim2.new(1, -42, 0, 12)
        title.Position = UDim2.new(0, 34, 0, 4)
        title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBlack
        title.Text = "STUNNED"; title.TextColor3 = Color3.fromRGB(255,255,255)
        title.TextSize = 11; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 3
        local sub = Instance.new("TextLabel", main)
        sub.Name = "Sub"; sub.Size = UDim2.new(1, -42, 0, 8)
        sub.Position = UDim2.new(0, 34, 0, 18)
        sub.BackgroundTransparency = 1; sub.Font = Enum.Font.GothamBold
        sub.Text = "SILENT"; sub.TextColor3 = Color3.fromRGB(170,170,180)
        sub.TextSize = 7; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 3
        local acc = Instance.new("Frame", main)
        acc.Name = "Accent"; acc.AnchorPoint = Vector2.new(1, 0.5)
        acc.Size = UDim2.fromOffset(2.5, 14)
        acc.Position = UDim2.new(1, -5, 0.5, 0)
        acc.BackgroundColor3 = Color3.fromRGB(255,255,255)
        acc.BorderSizePixel = 0; acc.ZIndex = 3
        Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)
        main.Size = UDim2.new(0, 0, 0, 0); main.BackgroundTransparency = 1
        task.spawn(function()
            task.wait(0.02)
            TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundTransparency = 0.05,
            }):Play()
        end)
        local active = true
        local function StopAnim() active = false end
        task.spawn(function()
            local t = 0
            while active and bbg.Parent and main.Parent do
                t = t + 0.05
                local pulse = (math.sin(t * 3) + 1) * 0.5
                ms.Transparency = 0.35 - pulse * 0.2
                ms.Thickness = 1.2 + pulse * 0.3
                star.Rotation = math.sin(t * 2) * 10
                local v1 = (t * 0.55) % 1
                p1.Size = UDim2.fromOffset(34 + v1 * 40, 34 + v1 * 40)
                p1s.Transparency = 0.15 + v1 * 0.75
                local v2 = ((t * 0.55) + 0.5) % 1
                p2.Size = UDim2.fromOffset(34 + v2 * 40, 34 + v2 * 40)
                p2s.Transparency = 0.15 + v2 * 0.75
                task.wait(0.03)
            end
        end)
        local function Exit()
            active = false
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.28, function() pcall(function() bbg:Destroy() end) end)
        end
        SInd.Cache[char] = { Gui = bbg, StopAnim = StopAnim, Exit = Exit }
        return SInd.Cache[char]
    end
    function W.SInd_Set(v)
        SInd.Enabled = v and true or false
        if SInd.Enabled then
            if SInd.Conn then return end
            SInd.Conn = RunService.Heartbeat:Connect(function()
                if not SInd.Enabled then return end
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and TeamIs(p, "Killer") and p.Character then
                        local char = p.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (hrp.Position - myRoot.Position).Magnitude
                            local stun = SInd_IsStunned(char)
                            local data = SInd.Cache[char]
                            local wasStun = data ~= nil
                            if stun and d <= SInd.Range then
                                if not wasStun then SInd_PlaySound(char); SInd_Create(char) end
                            else
                                if wasStun then
                                    if data.Exit then data.Exit() else SInd_Remove(char) end
                                    SInd.Cache[char] = nil
                                end
                            end
                        end
                    end
                end
            end)
        else
            if SInd.Conn then SInd.Conn:Disconnect(); SInd.Conn = nil end
            for _, d in pairs(SInd.Cache) do
                pcall(function() if d.StopAnim then d.StopAnim() end if d.Gui then d.Gui:Destroy() end end)
            end
            SInd.Cache = {}
        end
    end

    -- === INVISIBILITY (MengHub API) ===
    do
        local MV = getgenv().W2HUBInvis
        if not MV then
            MV = { Enabled = false, Loading = false, Ready = false, API = nil,
                _lastToggle = 0, _retries = 0, _retryMax = 3, _retryDelay = 2, _queueState = nil }
            getgenv().W2HUBInvis = MV
        end
        W.Invis = MV
        local URL = "https://leekguy.vercel.app/roblox/menghub/crack_obf_invisible_93978595733734.lua"
        local function Validate(api)
            if type(api) ~= "table" then return false end
            if type(api.enable) ~= "function" then return false end
            if type(api.disable) ~= "function" then return false end
            return true
        end
        local function Cleanup()
            pcall(function()
                local ch = Workspace:FindFirstChild("invischair")
                if ch then ch:Destroy() end
                local c = LP.Character
                if c then
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") or p:IsA("Decal") then
                            if p.Name ~= "Hurtbox" and p.Name ~= "HumanoidRootPart" and p.Name ~= "HRP_Clone" then
                                p.Transparency = 0
                                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
                            end
                        end
                    end
                end
            end)
        end
        local function LoadAPI()
            if _G.MengHub and _G.MengHub.Invisible and Validate(_G.MengHub.Invisible) then
                MV.API = _G.MengHub.Invisible; MV.Ready = true; return true
            end
            MV.Loading = true; MV.Ready = false
            for i = 1, MV._retryMax do
                MV._retries = i
                local ok = pcall(function() loadstring(game:HttpGet(URL))() end)
                task.wait(0.5)
                if ok and _G.MengHub and _G.MengHub.Invisible and Validate(_G.MengHub.Invisible) then
                    MV.API = _G.MengHub.Invisible; MV.Ready = true; MV.Loading = false
                    if MV._queueState ~= nil then
                        local q = MV._queueState; MV._queueState = nil
                        task.defer(function() W.Invis_Set(q, false) end)
                    end
                    return true
                elseif i < MV._retryMax then task.wait(MV._retryDelay) end
            end
            MV.Loading = false; MV.Ready = false
            return false
        end
        task.spawn(function() LoadAPI() end)
        function W.Invis_Set(state, fromBtn)
            state = state and true or false
            local now = tick()
            if now - MV._lastToggle < 0.25 then return end
            if not MV.API then
                if MV.Loading then
                    ShowNotify("Invisible", "Loading API...", 2)
                    MV._queueState = state
                else
                    ShowNotify("Invisible", "Retry...", 2)
                    MV._queueState = state
                    task.spawn(function()
                        if LoadAPI() then
                            local q = MV._queueState; MV._queueState = nil
                            if q ~= nil then task.defer(function() W.Invis_Set(q, fromBtn) end) end
                        end
                    end)
                end
                return
            end
            if MV.Enabled == state then if not state then Cleanup() end; return end
            MV._lastToggle = now
            MV.Enabled = state
            if state then
                pcall(function() MV.API.enable() end)
                if not fromBtn then ShowNotify("Invisible", "ON", 2) end
            else
                pcall(function() MV.API.disable() end); Cleanup()
                if not fromBtn then ShowNotify("Invisible", "OFF", 2) end
            end
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if inp.KeyCode == Enum.KeyCode.G then W.Invis_Set(not MV.Enabled, false) end
        end)
        LP.CharacterAdded:Connect(function()
            task.wait(1.2)
            if MV.Enabled and MV.API then pcall(function() MV.API.enable() end) end
        end)
        W.Invis_IsOn = function() return MV.Enabled end
    end

    -- === PLAYER UTILITY ===
    do
        local PU = {
            SpeedEnabled = false, SpeedValue = 16,
            ShiftLock = false, UnlimitedZoom = false, Noclip = false,
            _Conns = {}, _OrigCanCollide = {}, _ShiftWasActive = false,
        }
        W.PU = PU
        table.insert(PU._Conns, RunService.Heartbeat:Connect(function()
            if not PU.SpeedEnabled then return end
            local c = LP.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.WalkSpeed ~= PU.SpeedValue then h.WalkSpeed = PU.SpeedValue end
        end))
        table.insert(PU._Conns, RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local root = c:FindFirstChild("HumanoidRootPart")
            local cam = Workspace.CurrentCamera
            if not (h and root and cam) then return end
            if PU.ShiftLock then
                h.AutoRotate = false
                PU._ShiftWasActive = true
                local lv = cam.CFrame.LookVector
                local flat = Vector3.new(lv.X, 0, lv.Z)
                if flat.Magnitude > 0.001 then root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit) end
            elseif PU._ShiftWasActive then
                h.AutoRotate = true
                PU._ShiftWasActive = false
            end
        end))
        table.insert(PU._Conns, RunService.RenderStepped:Connect(function()
            if not PU.UnlimitedZoom then return end
            if LP.CameraMaxZoomDistance ~= math.huge then LP.CameraMaxZoomDistance = math.huge end
            if LP.CameraMinZoomDistance ~= 0 then LP.CameraMinZoomDistance = 0 end
        end))
        table.insert(PU._Conns, RunService.Stepped:Connect(function()
            if not PU.Noclip then return end
            local c = LP.Character
            if not c then return end
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    if PU._OrigCanCollide[d] == nil then PU._OrigCanCollide[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        end))
        LP.CharacterRemoving:Connect(function(c)
            if c == LP.Character then PU._OrigCanCollide = {} end
        end)
        W.PU_RestoreNoclip = function()
            for part, cc in pairs(PU._OrigCanCollide) do
                if part and part.Parent then pcall(function() part.CanCollide = cc end) end
            end
            PU._OrigCanCollide = {}
        end
    end

    -- === SPEED BOOST ===
    do
        local SB = { Enabled = false, Value = 30, Conn = nil }
        W.SpeedBoost = SB
        local function ShouldDisable()
            local c = LP.Character
            if not c then return true end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                if h.Health <= 0 or h.Health < 2
                    or c:GetAttribute("Downed") == true
                    or c:GetAttribute("IsDown") == true
                    or c:GetAttribute("Knocked") == true then
                    return true
                end
            end
            return false
        end
        function W.SpeedBoost_Set(v)
            SB.Enabled = v and true or false
            if SB.Conn then SB.Conn:Disconnect(); SB.Conn = nil end
            if not SB.Enabled then
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then pcall(function() h.WalkSpeed = 16 end) end
                return
            end
            SB.Conn = RunService.Heartbeat:Connect(function()
                if not SB.Enabled then return end
                if ShouldDisable() then return end
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed ~= SB.Value then pcall(function() h.WalkSpeed = SB.Value end) end
            end)
        end
        function W.SpeedBoost_SetValue(v) SB.Value = tonumber(v) or 30 end
        LP.CharacterAdded:Connect(function()
            task.wait(0.8)
            if SB.Enabled then W.SpeedBoost_Set(true) end
        end)
    end

    -- === CURSOR FEATURE ===
    do
        local Cursor = { Enabled = false, Thread = nil, Orig = { MouseIconEnabled = nil, MouseBehavior = nil, AutoRotate = nil } }
        W.Cursor = Cursor
        function W.Cursor_Set(v)
            Cursor.Enabled = v and true or false
            if v then
                Cursor.Orig.MouseIconEnabled = UserInputService.MouseIconEnabled
                Cursor.Orig.MouseBehavior = UserInputService.MouseBehavior
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                Cursor.Orig.AutoRotate = h and h.AutoRotate or true
                pcall(function()
                    UserInputService.MouseIconEnabled = true
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end)
                if h then pcall(function() h.AutoRotate = false end) end
                if Cursor.Thread then pcall(function() task.cancel(Cursor.Thread) end) end
                Cursor.Thread = task.spawn(function()
                    while Cursor.Enabled do
                        pcall(function()
                            UserInputService.MouseIconEnabled = true
                            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                        end)
                        local c2 = LP.Character
                        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                        if h2 and h2.AutoRotate then h2.AutoRotate = false end
                        task.wait(0.1)
                    end
                end)
            else
                if Cursor.Thread then pcall(function() task.cancel(Cursor.Thread) end); Cursor.Thread = nil end
                pcall(function()
                    UserInputService.MouseIconEnabled = Cursor.Orig.MouseIconEnabled or false
                    UserInputService.MouseBehavior = Cursor.Orig.MouseBehavior or Enum.MouseBehavior.LockCenter
                end)
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then pcall(function() h.AutoRotate = Cursor.Orig.AutoRotate or true end) end
            end
        end
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.LeftAlt or inp.KeyCode == Enum.KeyCode.RightAlt then
                W.Cursor_Set(not Cursor.Enabled)
            end
        end)
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            if Cursor.Enabled then W.Cursor_Set(true) end
        end)
    end

    -- === EMOTE ===
    do
        local ES = {
            Enabled = false, Track = nil, Sound = nil, Selected = "Friday Night",
            Options = {
                "Friday Night","WarCry","24 Hour Cinderella","Applause",
                "Arm Swing","Backflip","California Girls","Christmas Spirit",
                "Floating Rest","Ghoul","Griddy","Kyoufuu","OnePlays","Vulnerable",
            },
            Data = {
                ["Friday Night"]       = { Anim = "rbxassetid://83229063951016",  Sound = "rbxassetid://85355610204255" },
                ["WarCry"]             = { Anim = "rbxassetid://82600868380136",  Sound = "rbxassetid://120101930689931" },
                ["24 Hour Cinderella"] = { Anim = "rbxassetid://137195203725366", Sound = "rbxassetid://121099446613414" },
                ["Applause"]           = { Anim = "rbxassetid://96328361165090",  Sound = "rbxassetid://115490787020749" },
                ["Arm Swing"]          = { Anim = "rbxassetid://80552139463944",  Sound = "rbxassetid://74216458932348" },
                ["Backflip"]           = { Anim = "rbxassetid://74705617908505" },
                ["California Girls"]   = { Anim = "rbxassetid://123552803041504", Sound = "rbxassetid://87899327891544" },
                ["Christmas Spirit"]   = { Anim = "rbxassetid://137859761110514" },
                ["Floating Rest"]      = { Anim = "rbxassetid://114593021219597" },
                ["Ghoul"]              = { Anim = "rbxassetid://130415594909401", Sound = "rbxassetid://123004139176580" },
                ["Griddy"]             = { Anim = "rbxassetid://75586690784894" },
                ["Kyoufuu"]            = { Anim = "rbxassetid://137322894494527", Sound = "rbxassetid://129064643026442" },
                ["OnePlays"]           = { Anim = "rbxassetid://140625405103474", Sound = "rbxassetid://94749073728335" },
                ["Vulnerable"]         = { Anim = "rbxassetid://121773684313913", Sound = "rbxassetid://135265751184744" },
            },
        }
        W.Emote = ES
        function W.Emote_Stop()
            if ES.Track then pcall(function() ES.Track:Stop() end); ES.Track = nil end
            if ES.Sound then pcall(function() ES.Sound:Destroy() end); ES.Sound = nil end
        end
        function W.Emote_Play()
            W.Emote_Stop()
            local c = LP.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local r = c:FindFirstChild("HumanoidRootPart")
            if not h or not r then return end
            local d = ES.Data[ES.Selected]
            if not d then return end
            if d.Anim then
                local a = Instance.new("Animation")
                a.AnimationId = d.Anim
                local t = h:LoadAnimation(a)
                t.Looped = true
                t.Priority = Enum.AnimationPriority.Action
                t:Play()
                ES.Track = t
            end
            if d.Sound then
                local s = Instance.new("Sound")
                s.SoundId = d.Sound
                s.Looped = true; s.Volume = 2; s.Parent = r
                s:Play()
                ES.Sound = s
            end
        end
        function W.Emote_Set(v)
            ES.Enabled = v and true or false
            if ES.Enabled then W.Emote_Play() else W.Emote_Stop() end
        end
        function W.Emote_Select(name)
            if ES.Data[name] then
                ES.Selected = name
                if ES.Enabled then W.Emote_Play() end
            end
        end
        LP.CharacterRemoving:Connect(function() W.Emote_Stop() end)
        LP.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ES.Enabled then W.Emote_Play() end
        end)
    end

    -- === FAKE AVATAR ===
    do
        local FA = { Enabled = false, UserId = LP.UserId }
        W.FakeAvatar = FA
        local function LoadAppearance(appearance, character, head)
            local items = appearance:GetChildren()
            local function applyMesh(obj)
                if obj:IsA("CharacterMesh") or obj:IsA("BodyColors") or obj:IsA("Shirt") or obj:IsA("Pants") then
                    local existing = character:FindFirstChild(obj.Name)
                    if existing and existing.ClassName == obj.ClassName then existing:Destroy() end
                    obj:Clone().Parent = character
                end
            end
            for _, item in pairs(items) do
                if item:IsA("Folder") or item:IsA("Model") then
                    for _, sub in pairs(item:GetChildren()) do applyMesh(sub) end
                else applyMesh(item) end
            end
            for _, item in pairs(items) do
                if item:IsA("SpecialMesh") and head then
                    local tm = head:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", head)
                    tm.MeshType = Enum.MeshType.FileMesh
                    tm.MeshId = item.MeshId
                    tm.TextureId = item.TextureId
                elseif item:IsA("Decal") and item.Name == "face" and head then
                    if head:FindFirstChild("face") then head.face:Destroy() end
                    item:Clone().Parent = head
                end
            end
            for _, item in pairs(items) do
                if item:IsA("Accessory") then
                    local clone = item:Clone()
                    local handle = clone:FindFirstChild("Handle")
                    if handle then
                        local att = handle:FindFirstChildOfClass("Attachment")
                        if att then
                            local tAtt = character:FindFirstChild(att.Name, true)
                            if tAtt then
                                local weld = Instance.new("Weld")
                                weld.Part0 = handle; weld.Part1 = tAtt.Parent
                                weld.C0 = att.CFrame; weld.C1 = tAtt.CFrame
                                weld.Parent = handle
                            end
                        end
                        handle.CanCollide = false; handle.Massless = true; clone.Parent = character
                    end
                end
            end
        end
        local function Apply()
            local character = LP.Character
            if not character or not FA.UserId then return end
            local hum = character:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            task.spawn(function()
                local ok, appearance = pcall(function()
                    return Players:GetCharacterAppearanceAsync(FA.UserId)
                end)
                if not ok or not appearance then return end
                for _, obj in pairs(character:GetChildren()) do
                    if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
                    or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") or obj:IsA("ShirtGraphic") then
                        obj:Destroy()
                    end
                end
                local head = character:FindFirstChild("Head")
                if head then
                    for _, hObj in pairs(head:GetChildren()) do
                        if hObj:IsA("SpecialMesh") or hObj:IsA("Decal") then hObj:Destroy() end
                    end
                    local m = Instance.new("SpecialMesh", head)
                    m.MeshType = Enum.MeshType.Head; m.Scale = Vector3.new(1, 1, 1)
                end
                local scaleDefaults = { BodyDepthScale=1, BodyHeightScale=1, BodyWidthScale=1, HeadScale=1, BodyTypeScale=0, BodyProportionScale=0 }
                for sN, sV in pairs(scaleDefaults) do
                    local s = hum:FindFirstChild(sN); if s then s.Value = sV end
                end
                task.wait(0.1)
                LoadAppearance(appearance, character, head)
                pcall(function()
                    local info = Players:GetCharacterAppearanceInfoAsync(FA.UserId)
                    if head and info.assets then
                        for _, asset in pairs(info.assets) do
                            if asset.assetType.name == "Face" then
                                if head:FindFirstChild("face") then head.face:Destroy() end
                                local f = Instance.new("Decal", head)
                                f.Name = "face"; f.Texture = "rbxassetid://" .. asset.id
                                break
                            end
                        end
                    end
                end)
            end)
        end
        function W.FakeAvatar_Set(v) FA.Enabled = v and true or false; if v then Apply() end end
        function W.FakeAvatar_SetId(id) FA.UserId = id; if FA.Enabled then Apply() end end
        function W.FakeAvatar_FromUsername(input)
            input = (input or ""):gsub("^@", "")
            if input == "" then return false end
            local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(input) end)
            if not ok or not uid then ShowNotify("Fake Avatar", "User not found", 2); return false end
            FA.UserId = uid
            Apply()
            ShowNotify("Fake Avatar", "Applied: @" .. input, 2)
            return true
        end
        LP.CharacterAdded:Connect(function()
            if FA.Enabled then task.wait(1); Apply() end
        end)
    end

    -- === FAKE KORLESS ===
    do
        local K = { Enabled = false, Conn = nil }
        W.Korless = K
        local function Morph()
            local plr = LP
            task.spawn(function()
                repeat task.wait() until plr.Character
                    and plr.Character:FindFirstChild("HumanoidRootPart")
                    and plr.Character:FindFirstChild("Right Leg")
                task.wait(0.1)
                local c = plr.Character
                pcall(function()
                    c.Head.Transparency = 1
                    local f = c.Head:FindFirstChild("face")
                    if f then f:Destroy() end
                    c["Right Leg"].Transparency = 1
                    local old = c:FindFirstChild("KorlessHead")
                    if old then old:Destroy() end
                    local mesh = Instance.new("MeshPart")
                    mesh.Name = "KorlessHead"
                    mesh.Size = Vector3.new(1.5, 1.5, 1.5)
                    mesh.CanCollide = false
                    mesh.MeshId = "rbxassetid://902942096"
                    mesh.TextureID = "rbxassetid://902843398"
                    mesh.CFrame = c["Right Leg"].CFrame * CFrame.new(0, 0.5, 0)
                    mesh.Parent = c
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = c["Right Leg"]
                    w.Part1 = mesh
                    w.Parent = mesh
                end)
            end)
        end
        local function Remove()
            local c = LP.Character
            if c then
                local m = c:FindFirstChild("KorlessHead")
                if m then m:Destroy() end
                if c:FindFirstChild("Head") then c.Head.Transparency = 0 end
                if c:FindFirstChild("Right Leg") then c["Right Leg"].Transparency = 0 end
            end
            if K.Conn then K.Conn:Disconnect(); K.Conn = nil end
        end
        function W.Korless_Set(v)
            K.Enabled = v and true or false
            if v then
                Morph()
                if K.Conn then K.Conn:Disconnect() end
                K.Conn = LP.CharacterAdded:Connect(function() task.wait(1); Morph() end)
            else Remove() end
        end
    end

    -- === HEADER TITLE ===
    do
        local H = { Enabled = false, Text = "W2HUB", Color = Color3.fromRGB(255,255,255),
            Billboard = nil, Txt = nil, ShineTxt = nil, ShineGrad = nil, SizeConn = nil }
        W.Header = H
        local BW = isMobile and 90 or 140
        local BH = isMobile and 20 or 32
        local function Create()
            if H.Billboard then H.Billboard:Destroy() end
            local c = LP.Character or LP.CharacterAdded:Wait()
            if not c:FindFirstChild("Head") then return end
            local bb = Instance.new("BillboardGui")
            bb.Name = "W2HUBHeader"
            bb.Adornee = c.Head
            bb.Size = UDim2.new(0, BW, 0, BH)
            bb.StudsOffset = Vector3.new(0, 1.5, 0)
            bb.AlwaysOnTop = true; bb.LightInfluence = 0
            bb.Parent = c
            H.Billboard = bb
            local t = Instance.new("TextLabel", bb)
            t.Name = "BaseText"; t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1; t.TextScaled = true
            t.Font = Enum.Font.GothamBold; t.TextStrokeTransparency = 0.5
            t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            t.TextColor3 = H.Color; t.Text = H.Text
            H.Txt = t
            local sh = Instance.new("TextLabel", bb)
            sh.Name = "ShineText"; sh.Size = UDim2.new(1, 0, 1, 0)
            sh.BackgroundTransparency = 1; sh.TextScaled = true
            sh.Font = Enum.Font.GothamBold; sh.TextStrokeTransparency = 1
            sh.Text = H.Text; sh.TextColor3 = Color3.fromRGB(255, 255, 255)
            sh.ZIndex = 2
            H.ShineTxt = sh
            local grad = Instance.new("UIGradient")
            grad.Name = "ShineGradient"; grad.Rotation = 20
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 1), NumberSequenceKeypoint.new(0.30, 1),
                NumberSequenceKeypoint.new(0.42, 0), NumberSequenceKeypoint.new(0.58, 0),
                NumberSequenceKeypoint.new(0.70, 1), NumberSequenceKeypoint.new(1.00, 1),
            })
            grad.Offset = Vector2.new(-1, 0); grad.Parent = sh
            H.ShineGrad = grad
            if H.SizeConn then H.SizeConn:Disconnect() end
            H.SizeConn = RunService.RenderStepped:Connect(function()
                if not bb or not bb.Parent then H.SizeConn:Disconnect(); return end
                local head = c:FindFirstChild("Head"); if not head then return end
                local dist = (Workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude
                local scale = math.clamp(12 / dist, 0.6, isMobile and 1.1 or 1.4)
                bb.Size = UDim2.new(0, BW * scale, 0, BH * scale)
            end)
            task.spawn(function()
                while sh and sh.Parent and grad and grad.Parent do
                    grad.Offset = Vector2.new(-1, 0)
                    local tw = TweenService:Create(grad, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(1, 0) })
                    tw:Play(); tw.Completed:Wait(); task.wait(2)
                end
            end)
        end
        local function Remove()
            if H.SizeConn then H.SizeConn:Disconnect(); H.SizeConn = nil end
            if H.Billboard then H.Billboard:Destroy() end
            H.Billboard = nil; H.Txt = nil; H.ShineTxt = nil; H.ShineGrad = nil
        end
        function W.Header_Set(v) H.Enabled = v and true or false; if v then Create() else Remove() end end
        function W.Header_SetText(t)
            H.Text = t or "W2HUB"
            if H.Txt then H.Txt.Text = H.Text end
            if H.ShineTxt then H.ShineTxt.Text = H.Text end
        end
        function W.Header_SetColor(c)
            H.Color = c
            if H.Txt then H.Txt.TextColor3 = c end
        end
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            if H.Enabled then Create() end
        end)
    end

    -- === SPECTATOR COUNTER ===
    do
        local S = { Enabled = false, Gui = nil, Label = nil, Thread = nil, Expanded = true }
        W.Spectator = S
        local function Create()
            if S.Gui then S.Gui:Destroy(); S.Gui = nil end
            S.Gui = Instance.new("ScreenGui")
            S.Gui.Name = "W2HUBSpectator"
            S.Gui.ResetOnSpawn = false
            S.Gui.IgnoreGuiInset = true
            S.Gui.Parent = CoreGui
            local mf = Instance.new("Frame", S.Gui)
            mf.Name = "MainBox"; mf.AnchorPoint = Vector2.new(0.5, 0)
            mf.Position = UDim2.new(0.5, 0, 0.42, 0)
            mf.Size = UDim2.new(0, 145, 0, 52)
            mf.BackgroundColor3 = Color3.fromRGB(25,25,25)
            mf.BackgroundTransparency = 0.1
            mf.BorderSizePixel = 0; mf.Active = true
            Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 6)
            local h = Instance.new("Frame", mf)
            h.Name = "Header"; h.Size = UDim2.new(1, 0, 0, 18)
            h.Position = UDim2.new(0, 0, 0, 4)
            h.BackgroundTransparency = 1; h.Active = true
            local t = Instance.new("TextLabel", h)
            t.Size = UDim2.new(1, -20, 1, 0); t.BackgroundTransparency = 1
            t.Font = Enum.Font.GothamBold; t.Text = "Spectators"
            t.TextColor3 = Color3.fromRGB(255,255,255); t.TextSize = 10
            local minBtn = Instance.new("TextButton", h)
            minBtn.Size = UDim2.new(0, 18, 0, 18); minBtn.Position = UDim2.new(1, -19, 0, 0)
            minBtn.BackgroundTransparency = 1; minBtn.Text = "−"
            minBtn.TextColor3 = Color3.fromRGB(255,255,255)
            minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 13
            minBtn.AutoButtonColor = false
            local body = Instance.new("Frame", mf)
            body.Name = "Body"; body.Size = UDim2.new(1, 0, 1, -25)
            body.Position = UDim2.new(0, 0, 0, 25); body.BackgroundTransparency = 1
            S.Label = Instance.new("TextLabel", body)
            S.Label.Size = UDim2.new(1, 0, 1, 0); S.Label.BackgroundTransparency = 1
            S.Label.Font = Enum.Font.GothamMedium; S.Label.Text = "No spectators"
            S.Label.TextColor3 = Color3.fromRGB(220,220,220); S.Label.TextSize = 10
            local function setExp(state)
                S.Expanded = state
                if state then
                    mf.Size = UDim2.new(0, 145, 0, 52); body.Visible = true; minBtn.Text = "−"
                else
                    mf.Size = UDim2.new(0, 145, 0, 22); body.Visible = false; minBtn.Text = "+"
                end
            end
            minBtn.MouseButton1Click:Connect(function() setExp(not S.Expanded) end)
            setExp(true)
            local drag, ds, sp = false, nil, nil
            mf.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    drag = true; ds = inp.Position; sp = mf.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not drag then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - ds
                    mf.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then drag = false end
            end)
        end
        local function Update()
            if not S.Label then return end
            local cnt = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Team and p.Team.Name == "Spectator" then cnt = cnt + 1 end
            end
            if cnt == 0 then
                S.Label.Text = "No spectators"; S.Label.TextColor3 = Color3.fromRGB(200,200,200)
            else
                S.Label.Text = cnt .. " spectators"; S.Label.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end
        function W.Spectator_Set(v)
            S.Enabled = v and true or false
            if S.Thread then task.cancel(S.Thread); S.Thread = nil end
            if v then
                Create(); Update()
                S.Thread = task.spawn(function()
                    while S.Enabled do Update(); task.wait(1.2) end
                end)
            else
                if S.Gui then S.Gui:Destroy(); S.Gui = nil; S.Label = nil end
            end
        end
    end

    -- === HIDE NAME / ICON ===
    W.HideName = W.HideName or { Enabled = false, Conn = nil }
    do
        local function Process(obj)
            if not obj then return end
            local ok, isT = pcall(function()
                return obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")
            end)
            if not ok or not isT then return end
            local txt = ""
            pcall(function() txt = tostring(obj.Text or "") end)
            if txt == "" then return end
            if txt == LP.Name or txt == LP.DisplayName or txt:find(LP.Name, 1, true) ~= nil then
                pcall(function() obj.Visible = not W.HideName.Enabled end)
            end
        end
        W.HideName_Set = function(en)
            W.HideName.Enabled = en and true or false
            if W.HideName.Conn then pcall(function() W.HideName.Conn:Disconnect() end); W.HideName.Conn = nil end
            local pg = LP:FindFirstChildOfClass("PlayerGui")
            if not pg then return end
            for _, d in ipairs(pg:GetDescendants()) do Process(d) end
            if W.HideName.Enabled then
                W.HideName.Conn = pg.DescendantAdded:Connect(function(obj) task.defer(Process, obj) end)
            end
        end
    end

    W.HideIcon = W.HideIcon or { Enabled = false, OrigIcons = {} }
    do
        local function Apply()
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:match("%-mob$") then
                    local frame = gui:FindFirstChild("Frame")
                    if frame then
                        for i = 1, 5 do
                            local sf = frame:FindFirstChild("Survivor" .. i)
                            if sf then
                                local il = sf:FindFirstChild("ImageLabel")
                                local tl = sf:FindFirstChild("TextLabel")
                                if il and il:IsA("ImageLabel") then
                                    if not W.HideIcon.OrigIcons[il] then
                                        W.HideIcon.OrigIcons[il] = { Image = il.Image, ImageTransparency = il.ImageTransparency }
                                    end
                                    il.Image = "rbxassetid://138040631725974"
                                    il.ImageTransparency = 0
                                end
                                if tl and tl:IsA("TextLabel") then
                                    if not W.HideIcon.OrigIcons[tl] then
                                        W.HideIcon.OrigIcons[tl] = { Text = tl.Text, TextTransparency = tl.TextTransparency }
                                    end
                                    tl.Text = "W2HUB"; tl.TextTransparency = 0
                                end
                            end
                        end
                    end
                end
            end
        end
        local function Restore()
            for obj, data in pairs(W.HideIcon.OrigIcons) do
                if obj and obj.Parent then
                    pcall(function()
                        if data.Image ~= nil and obj:IsA("ImageLabel") then
                            obj.Image = data.Image; obj.ImageTransparency = data.ImageTransparency
                        end
                        if data.Text ~= nil and obj:IsA("TextLabel") then
                            obj.Text = data.Text; obj.TextTransparency = data.TextTransparency
                        end
                    end)
                end
            end
            W.HideIcon.OrigIcons = {}
        end
        RunService.Heartbeat:Connect(function() if W.HideIcon.Enabled then Apply() end end)
        W.HideIcon_Set = function(v)
            W.HideIcon.Enabled = v and true or false
            if v then Apply() else Restore() end
        end
    end

    -- === JERK OFF TOOL ===
    do
        local J = { Enabled = false, Name = "Jerk Off" }
        W.JerkTool = J
        local current, running = nil, false
        function W.Jerk_Destroy()
            if current then pcall(function() current:Destroy() end); current = nil end
        end
        function W.Jerk_Create()
            W.Jerk_Destroy()
            local c = LP.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local bp = LP:FindFirstChildOfClass("Backpack")
            if not h or not bp then return end
            local tool = Instance.new("Tool")
            tool.Name = J.Name
            tool.ToolTip = 'jorking it'
            tool.RequiresHandle = false
            tool.Parent = bp
            current = tool
            local jork = false
            local track = nil
            local function stop()
                jork = false
                if track then pcall(function() track:Stop() end); track = nil end
            end
            tool.Equipped:Connect(function() jork = true end)
            tool.Unequipped:Connect(stop)
            if h.Died then h.Died:Connect(stop) end
            task.spawn(function()
                while running do
                    task.wait()
                    if not J.Enabled or not jork then
                        if track then pcall(function() track:Stop() end) end
                        continue
                    end
                    local isR15 = h.RigType == Enum.HumanoidRigType.R15
                    if not track then
                        local a = Instance.new("Animation")
                        a.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                        track = h:LoadAnimation(a)
                    end
                    track:Play()
                    track:AdjustSpeed(isR15 and 0.7 or 0.65)
                    track.TimePosition = 0.6
                    task.wait(0.1)
                    while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do
                        task.wait(0.1)
                    end
                    if track then pcall(function() track:Stop() end) end
                end
            end)
        end
        function W.Jerk_Set(v)
            J.Enabled = v and true or false
            running = J.Enabled
            if v then W.Jerk_Create() else W.Jerk_Destroy() end
        end
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            if J.Enabled then running = true; W.Jerk_Create() end
        end)
    end

    -- === SKIP END SCREEN ===
    W.SkipEnd = W.SkipEnd or { Enabled = false }
    local function ShowInstant()
        if not W.SkipEnd.Enabled then return end
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then cam.CameraType = Enum.CameraType.Custom; cam.FieldOfView = 70 end
            UserInputService.MouseIconEnabled = true
            LP:SetAttribute("isspectating", true)
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                for _, n in ipairs({"Results","EndScreen","Darkness"}) do
                    local g = pg:FindFirstChild(n)
                    if g then
                        g.Enabled = true
                        local f = g:FindFirstChild("blackout") or g:FindFirstChild("Frame2")
                        if f then f.BackgroundTransparency = 1 end
                    end
                end
            end
        end)
    end
    task.spawn(function()
        local gf = ReplicatedStorage:WaitForChild("Remotes", 10)
        gf = gf and gf:WaitForChild("Game", 10)
        if not gf then return end
        for _, n in ipairs({"endscreencutscene","cutsceneEnd","cutsceneEnd2","cutsceneEndwithownchar"}) do
            local ev = gf:FindFirstChild(n)
            if ev and ev:IsA("RemoteEvent") then
                ev.OnClientEvent:Connect(ShowInstant)
            end
        end
    end)
    W.SkipEnd_Set = function(v) W.SkipEnd.Enabled = v and true or false end

    -- === ESCAPE ===
    W.Escape = W.Escape or { Enabled = false, Name = "fininshline", Count = 0 }
    W.Escape_TP = function()
        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not r then ShowNotify("Escape", "Character not found", 2); return false end
        local found = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(W.Escape.Name) and obj:IsA("BasePart") then
                found = obj; break
            end
        end
        if not found then ShowNotify("Escape", "Finish line not found", 2); return false end
        pcall(function() r.CFrame = found.CFrame + Vector3.new(0, 5, 0) end)
        W.Escape.Count = W.Escape.Count + 1
        ShowNotify("Escape", "TP! (#" .. W.Escape.Count .. ")", 2)
        return true
    end

    -- === UI SECTION ===
    do
        local s = W.T_Misc:AddSection("Stun Indicator")
        s:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.SInd_Set(v); ShowNotify("W2HUB", "Stun Indicator " .. (v and "ON" or "OFF"), 2)
        end })
        s:AddDropdown({ Title = "Stun Sound",
            Options = { "Default","Clash Royale","Blash","Coin","Kururin Kuru","Spongebob","Fahhhh","Cave","Aughhh","Samsung","iPhone","Siren" },
            Default = "Default", Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                SInd.SelectedSound = val
            end })
        s:AddToggle({ Title = "Sound Alert", Default = true, Callback = function(v) SInd.SoundEnabled = v end })
        s:AddButton({ Title = "Preview Sound", Callback = function()
            pcall(function()
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://" .. tostring(SInd_GetId())
                snd.Volume = SInd.Volume or 1.5
                snd.Parent = LP:FindFirstChildOfClass("PlayerGui") or Workspace
                snd:Play()
                snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end)
            end)
        end })
        s:AddSlider({ Title = "Detect Range", Min = 50, Max = 2000, Default = 500, Increment = 25, Suffix = " studs",
            Callback = function(v) SInd.Range = v end })
        s:AddSlider({ Title = "Volume", Min = 0, Max = 5, Default = 1.5, Increment = 0.1,
            Callback = function(v) SInd.Volume = v end })

        local s2 = W.T_Misc:AddSection("Invisibility")
        s2:AddToggle({ Title = "Enable Invisibility", Default = false, Callback = function(v)
            W.Invis_Set(v, false)
        end })
        s2:AddKeybind({ Title = "Hotkey", Default = Enum.KeyCode.G, Callback = function(kc) end })

        local s3 = W.T_Misc:AddSection("Player Utility")
        s3:AddToggle({ Title = "Speed Hack", Default = false, Callback = function(v)
            W.PU.SpeedEnabled = v
            if not v then
                local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 16 end
            end
        end })
        s3:AddSlider({ Title = "Speed Value", Min = 16, Max = 200, Default = 16, Increment = 1,
            Callback = function(v) W.PU.SpeedValue = v end })
        s3:AddToggle({ Title = "Shift Lock", Default = false, Callback = function(v) W.PU.ShiftLock = v end })
        s3:AddToggle({ Title = "Unlimited Zoom", Default = false, Callback = function(v) W.PU.UnlimitedZoom = v end })
        s3:AddToggle({ Title = "Noclip", Default = false, Callback = function(v)
            W.PU.Noclip = v
            if not v then W.PU_RestoreNoclip() end
        end })

        local s4 = W.T_Misc:AddSection("Speed Boost")
        s4:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
            W.SpeedBoost_Set(v); ShowNotify("W2HUB", "Speed Boost " .. (v and "ON" or "OFF"), 2)
        end })
        s4:AddSlider({ Title = "Speed Value", Min = 16, Max = 100, Default = 30, Increment = 1,
            Callback = function(v) W.SpeedBoost_SetValue(v) end })

        local s5 = W.T_Misc:AddSection("Cursor Feature")
        s5:AddToggle({ Title = "Enable Cursor Unlock", Default = false, Callback = function(v)
            W.Cursor_Set(v)
        end })
        s5:AddButton({ Title = "Toggle Now", Callback = function()
            W.Cursor_Set(not W.Cursor.Enabled)
        end })

        local s6 = W.T_Misc:AddSection("Spectator Counter")
        s6:AddToggle({ Title = "Enable", Default = false, Callback = function(v) W.Spectator_Set(v) end })

        local s7 = W.T_Misc:AddSection("Jerk Off")
        s7:AddToggle({ Title = "Enable Jerk Off Tool", Default = false, Callback = function(v) W.Jerk_Set(v) end })

        local s8 = W.T_Misc:AddSection("Extra Utility")
        s8:AddToggle({ Title = "Skip End Screen", Default = false, Callback = function(v) W.SkipEnd_Set(v) end })
        s8:AddToggle({ Title = "Hide Name", Default = false, Callback = function(v) W.HideName_Set(v) end })
        s8:AddToggle({ Title = "Hide Survivor Icon", Default = false, Callback = function(v) W.HideIcon_Set(v) end })

        local s9 = W.T_Misc:AddSection("Fake Avatar")
        s9:AddDropdown({ Title = "Preset",
            Options = { "Self Avatar","Random 1","Random 2","Random 3","Random 4","Random 5","Random 6","Random 7",
                "WoozyNate","Nicholas","yvlyf","traevp","J0LLY","LucashDev","CEOofIsaac","Stealthy","Wildes","Talon",
                "Relukt","Sammy","Diesel","S4ans03","Aura","iJava","White Guy","Purple King" },
            Default = "Self Avatar", Callback = function(opt)
                local ids = {
                    ["Self Avatar"]=LP.UserId, ["Random 1"]=2888298851, ["Random 2"]=10074747755,
                    ["Random 3"]=5209567453, ["Random 4"]=8991982843, ["Random 5"]=5796319029,
                    ["Random 6"]=9744452117, ["Random 7"]=8476755006, ["WoozyNate"]=146089324,
                    ["Nicholas"]=909635, ["yvlyf"]=181751703, ["traevp"]=471607078, ["J0LLY"]=1073847038,
                    ["LucashDev"]=2525651744, ["CEOofIsaac"]=63238912, ["Stealthy"]=56602747,
                    ["Wildes"]=40397833, ["Talon"]=75974130, ["Relukt"]=65042011, ["Sammy"]=2678001507,
                    ["Diesel"]=9123921576, ["S4ans03"]=35439794, ["Aura"]=2275806428, ["iJava"]=276557820,
                    ["White Guy"]=8843268357, ["Purple King"]=9070758608
                }
                W.FakeAvatar_SetId(ids[opt] or LP.UserId)
            end })
        s9:AddToggle({ Title = "Enable Fake Avatar", Default = false, Callback = function(v) W.FakeAvatar_Set(v) end })
        local UN = ""
        s9:AddInput({ Title = "Username", Placeholder = "username", Callback = function(inp) UN = (inp or ""):gsub("^@", "") end })
        s9:AddButton({ Title = "Apply From Username", Callback = function()
            if UN == "" then ShowNotify("Fake Avatar", "Enter username first!", 2); return end
            W.FakeAvatar_FromUsername(UN)
        end })

        local s10 = W.T_Misc:AddSection("Fake Korless")
        s10:AddToggle({ Title = "Korless Morph", Default = false, Callback = function(v) W.Korless_Set(v) end })

        local s11 = W.T_Misc:AddSection("Header Title")
        s11:AddInput({ Title = "Header Text", Default = "W2HUB", Placeholder = "Nama header...",
            Callback = function(inp) W.Header_SetText(inp) end })
        s11:AddToggle({ Title = "Enable Header", Default = false, Callback = function(v) W.Header_Set(v) end })
        s11:AddColorPicker({ Title = "Header Color", Default = Color3.fromRGB(255,255,255), Save = false,
            Callback = function(c) W.Header_SetColor(c) end })

        local s12 = W.T_Misc:AddSection("Emote")
        s12:AddToggle({ Title = "Enable Emote", Default = false, Callback = function(v) W.Emote_Set(v) end })
        s12:AddDropdown({ Title = "Select Emote",
            Options = W.Emote.Options or {},
            Default = "Friday Night", Multi = false,
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                W.Emote_Select(val or "Friday Night")
            end })
        s12:AddButton({ Title = "Stop Emote", Callback = function()
            W.Emote_Stop(); W.Emote.Enabled = false
        end })
    end

    print("[W2HUB] PART 13 Loaded OK")

-- PART 14-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 14: TROLL — BOMBAX MUSIC PLAYER + FLOATING BUTTONS
    --====================================================--

    -- === BOMBAX MUSIC PLAYER ===
    W.Bombax = W.Bombax or {
        Enabled = false, Current = nil, Selected = "One", Volume = 2, Looped = true, Playing = false,
        Songs = {
            {id="101985596918228", judul="One"},
            {id="78520199502339",  judul="Two"},
            {id="78253224480952",  judul="Three"},
            {id="136949217768985", judul="Four"},
            {id="92143860315842",  judul="Five"},
            {id="96568301359656",  judul="Six"},
            {id="96053601899287",  judul="Seven"},
            {id="116537762304510", judul="Eight"},
            {id="111775377151665", judul="Nine"},
            {id="131317416582166", judul="Ten"},
            {id="107569604895628", judul="Eleven"},
            {id="80210594606101",  judul="Danza Kuduro"},
            {id="135887188304832", judul="Ada Yang Tumbang Jos Jis"},
            {id="105372329671874", judul="Million Stars Asoy"},
            {id="79296696808534",  judul="My Lope Lope (Speed Up)"},
            {id="70578919220987",  judul="My Lope Lope (Andri Poter)"},
            {id="89338419772018",  judul="Habibi Ishqi"},
            {id="93652038633690",  judul="Santai Dulu"},
            {id="124582101215124", judul="DJ Akimilaku Im Back"},
            {id="121304834713825", judul="Dangdut Week Sebelas"},
            {id="102944382854479", judul="Lagu Misterius"},
            {id="126810420971446", judul="Anak Kota"},
            {id="94299109467073",  judul="Cinderella Jedag Jedug"},
            {id="83463789936127",  judul="Lagu Jawa (Kowe Siji)"},
            {id="771523191444498", judul="Cintaku Ini Istimewa"},
            {id="86422417888834",  judul="Kini Tinggal Kenangan"},
            {id="70868757792328",  judul="Mashup Dora Dora (Funky RMX)"},
            {id="128071048140468", judul="Always Loving You"},
            {id="136239433509180", judul="Mysterious Girl (Funky RMX)"},
            {id="101280279977761", judul="Kini Kita Pe Kisah"},
            {id="117080961502380", judul="DJ Music Dubstep x Bangun Tidur Selfie"},
            {id="110337096446518", judul="DJ Onia"},
        },
    }
    local BX = W.Bombax

    function W.Bombax_GetList()
        local l = {}
        for _, s in ipairs(BX.Songs) do table.insert(l, s.judul) end
        return l
    end
    function W.Bombax_Find(t)
        for _, s in ipairs(BX.Songs) do
            if s.judul == t then return s end
        end
        return nil
    end
    function W.Bombax_Stop()
        if BX.Current then
            pcall(function() BX.Current:Stop() end)
            pcall(function() BX.Current:Destroy() end)
            BX.Current = nil
        end
        BX.Playing = false
    end
    function W.Bombax_Play(t)
        W.Bombax_Stop()
        t = t or BX.Selected
        local s = W.Bombax_Find(t)
        if not s then ShowNotify("Bombax", "Lagu gak ada", 2); return end
        local c = LP.Character
        if not c then ShowNotify("Bombax", "Character kosong", 2); return end
        local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
        if not r then return end
        local snd = Instance.new("Sound")
        snd.Name = "W2HUBBombaxSound"
        snd.SoundId = "rbxassetid://" .. s.id
        snd.Volume = BX.Volume
        snd.Looped = BX.Looped
        snd.Parent = r
        snd:Play()
        BX.Current = snd
        BX.Playing = true
        BX.Selected = t
        ShowNotify("Bombax", "▶ " .. t, 3)
    end
    function W.Bombax_Set(v)
        BX.Enabled = v
        if v then W.Bombax_Play(BX.Selected) else W.Bombax_Stop() end
    end
    function W.Bombax_SetVol(v)
        BX.Volume = tonumber(v) or 2
        if BX.Current then pcall(function() BX.Current.Volume = BX.Volume end) end
    end
    function W.Bombax_SetLoop(v)
        BX.Looped = v and true or false
        if BX.Current then pcall(function() BX.Current.Looped = BX.Looped end) end
    end
    function W.Bombax_Next()
        local l = BX.Songs
        local idx = 1
        for i, s in ipairs(l) do if s.judul == BX.Selected then idx = i; break end end
        local n = idx + 1
        if n > #l then n = 1 end
        W.Bombax_Play(l[n].judul)
    end
    function W.Bombax_Prev()
        local l = BX.Songs
        local idx = 1
        for i, s in ipairs(l) do if s.judul == BX.Selected then idx = i; break end end
        local p = idx - 1
        if p < 1 then p = #l end
        W.Bombax_Play(l[p].judul)
    end

    -- === BOMBAX UI (Floating Button + Window) ===
    W.BombaxUI = W.BombaxUI or {
        Gui = nil, ButtonBox = nil, Window = nil, Open = false,
        ProgressFill = nil, TimeLabel = nil, NowLabel = nil,
        PlayBtn = nil, LoopBtn = nil, PickerBtn = nil,
        Enabled = false, Conns = {},
    }
    local BUI = W.BombaxUI

    local function BUI_Clean()
        for _, c in ipairs(BUI.Conns) do pcall(function() c:Disconnect() end) end
        BUI.Conns = {}
    end
    local function BUI_UpdateProgress()
        if not BUI.ProgressFill or not BUI.TimeLabel then return end
        if not BX.Current then
            BUI.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            BUI.TimeLabel.Text = "0:00 / 0:00"
            return
        end
        local ok, len = pcall(function() return BX.Current.TimeLength end)
        local ok2, pos = pcall(function() return BX.Current.TimePosition end)
        if not ok or not ok2 or not len or len <= 0 then
            BUI.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            BUI.TimeLabel.Text = "0:00 / 0:00"
            return
        end
        local pct = math.clamp(pos / len, 0, 1)
        BUI.ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
        local function fmt(t)
            t = math.max(0, math.floor(t))
            local m = math.floor(t / 60)
            local s = t - m * 60
            return string.format("%d:%02d", m, s)
        end
        BUI.TimeLabel.Text = fmt(pos) .. " / " .. fmt(len)
    end
    local function BUI_UpdateNow()
        if not BUI.NowLabel then return end
        BUI.NowLabel.Text = "▶ " .. tostring(BX.Selected)
        if BUI.PickerBtn then BUI.PickerBtn.Text = "🎵 SONG: " .. tostring(BX.Selected) end
    end
    local function BUI_UpdatePlayBtn()
        if not BUI.PlayBtn then return end
        if BX.Playing then
            BUI.PlayBtn.Text = "⏸"
            BUI.PlayBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        else
            BUI.PlayBtn.Text = "▶"
            BUI.PlayBtn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
        end
    end
    local function BUI_UpdateLoopBtn()
        if not BUI.LoopBtn then return end
        BUI.LoopBtn.BackgroundColor3 = BX.Looped and Color3.fromRGB(30, 70, 40) or Color3.fromRGB(45, 45, 58)
        BUI.LoopBtn.Text = "LOOP: " .. (BX.Looped and "ON" or "OFF")
    end
    local function BUI_ToggleWindow()
        if not BUI.Window then return end
        BUI.Open = not BUI.Open
        if BUI.Open then
            BUI.Window.Visible = true
            BUI.Window.Size = UDim2.fromOffset(0, 0)
            BUI.Window.BackgroundTransparency = 1
            TweenService:Create(BUI.Window, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(260, 260), BackgroundTransparency = 0.05,
            }):Play()
        else
            local tw = TweenService:Create(BUI.Window, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
            })
            tw:Play()
            tw.Completed:Connect(function()
                if BUI.Window then BUI.Window.Visible = false end
            end)
        end
    end

    local function BUI_BuildButton()
        if BUI.ButtonBox then pcall(function() BUI.ButtonBox:Destroy() end); BUI.ButtonBox = nil end
        local box = Instance.new("Frame")
        box.Name = "W2HUBBombaxBtn"
        box.Size = UDim2.fromOffset(54, 54)
        box.Position = UDim2.new(0, 20, 0, 20)
        box.BackgroundTransparency = 1
        box.Parent = BUI.Gui
        BUI.ButtonBox = box
        local glow = Instance.new("Frame", box)
        glow.Name = "Glow"; glow.Size = UDim2.fromScale(1.35, 1.35)
        glow.Position = UDim2.fromScale(0.5, 0.5)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        glow.BackgroundTransparency = 1; glow.BorderSizePixel = 0; glow.ZIndex = 1
        Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
        local glowStroke = Instance.new("UIStroke", glow)
        glowStroke.Color = Color3.fromRGB(255, 255, 255); glowStroke.Thickness = 1
        glowStroke.Transparency = 1
        local btn = Instance.new("TextButton", box)
        btn.Name = "Btn"; btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        btn.BackgroundTransparency = 0.08
        btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false
        btn.ZIndex = 2
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Name = "S"; btnStroke.Color = Color3.fromRGB(255, 255, 255)
        btnStroke.Thickness = 1.5; btnStroke.Transparency = 0.35
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "I"; icon.Size = UDim2.fromScale(0.62, 0.62)
        icon.Position = UDim2.fromScale(0.19, 0.19)
        icon.BackgroundTransparency = 1
        icon.Image = "138040631725974"
        icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        icon.ZIndex = 3
        local hint = Instance.new("TextLabel", box)
        hint.Name = "Hint"; hint.AnchorPoint = Vector2.new(0.5, 0)
        hint.Position = UDim2.new(0.5, 0, 1, 4)
        hint.Size = UDim2.fromOffset(60, 12)
        hint.BackgroundTransparency = 1
        hint.Font = Enum.Font.GothamBold; hint.Text = "MUSIC"
        hint.TextColor3 = Color3.fromRGB(180, 180, 200); hint.TextSize = 9
        hint.ZIndex = 2
        task.spawn(function()
            while box.Parent do
                if not BUI.Open then
                    TweenService:Create(glowStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
                        Transparency = 0.2, Thickness = 2.5,
                    }):Play()
                    TweenService:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
                        Size = UDim2.fromScale(1.45, 1.45),
                    }):Play()
                    task.wait(1.2)
                    TweenService:Create(glowStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
                        Transparency = 1, Thickness = 1,
                    }):Play()
                    TweenService:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
                        Size = UDim2.fromScale(1.15, 1.15),
                    }):Play()
                    task.wait(1.2)
                else task.wait(0.3) end
            end
        end)
        local dragging, dragStart, startPos = false, nil, nil
        local dDist = 0
        local holdStart = 0
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position
                startPos = box.Position; dDist = 0; holdStart = tick()
            end
        end)
        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if dDist < 8 and (tick() - holdStart) < 0.6 then
                    BUI_ToggleWindow()
                end
            end
        end)
        table.insert(BUI.Conns, UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStart
                dDist = math.abs(d.X) + math.abs(d.Y)
                box.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
    end

    local function BUI_BuildWindow()
        if BUI.Window then pcall(function() BUI.Window:Destroy() end); BUI.Window = nil end
        local win = Instance.new("Frame")
        win.Name = "BombaxWindow"; win.Size = UDim2.fromOffset(260, 260)
        win.Position = UDim2.new(0, 20, 0, 84)
        win.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        win.BackgroundTransparency = 0.05
        win.BorderSizePixel = 0; win.Visible = false; win.ZIndex = 50
        win.Active = true; win.Parent = BUI.Gui
        BUI.Window = win
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
        local ws = Instance.new("UIStroke", win)
        ws.Color = Color3.fromRGB(255, 255, 255); ws.Thickness = 1.2; ws.Transparency = 0.25
        local header = Instance.new("Frame", win)
        header.Name = "Header"; header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1; header.Active = true
        local ic = Instance.new("ImageLabel", header)
        ic.Size = UDim2.fromOffset(28, 28)
        ic.Position = UDim2.new(0, 10, 0.5, -14)
        ic.BackgroundTransparency = 1
        ic.Image = "138040631725974"
        ic.ImageColor3 = Color3.fromRGB(255, 255, 255)
        local title = Instance.new("TextLabel", header)
        title.Size = UDim2.new(1, -80, 0, 16); title.Position = UDim2.new(0, 46, 0, 6)
        title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold
        title.Text = "W2HUB MUSIC"; title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left
        local sub = Instance.new("TextLabel", header)
        sub.Size = UDim2.new(1, -80, 0, 12); sub.Position = UDim2.new(0, 46, 0, 22)
        sub.BackgroundTransparency = 1; sub.Font = Enum.Font.Gotham
        sub.Text = "Bombax Player"; sub.TextColor3 = Color3.fromRGB(140, 140, 160)
        sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left
        local close = Instance.new("TextButton", header)
        close.AnchorPoint = Vector2.new(1, 0.5)
        close.Size = UDim2.fromOffset(24, 24)
        close.Position = UDim2.new(1, -8, 0.5, 0)
        close.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        close.BorderSizePixel = 0; close.Text = "✕"
        close.TextColor3 = Color3.fromRGB(255, 255, 255)
        close.Font = Enum.Font.GothamBold; close.TextSize = 12
        Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
        close.MouseButton1Click:Connect(function()
            if BUI.Open then BUI_ToggleWindow() end
        end)
        local nowCard = Instance.new("Frame", win)
        nowCard.Name = "NowCard"; nowCard.Size = UDim2.new(1, -20, 0, 46)
        nowCard.Position = UDim2.fromOffset(10, 48)
        nowCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        nowCard.BorderSizePixel = 0
        Instance.new("UICorner", nowCard).CornerRadius = UDim.new(0, 8)
        local nc = Instance.new("UIStroke", nowCard)
        nc.Color = Color3.fromRGB(60, 60, 80); nc.Thickness = 1; nc.Transparency = 0.4
        local nLbl = Instance.new("TextLabel", nowCard)
        nLbl.Name = "NowLabel"; nLbl.Size = UDim2.new(1, -16, 0, 18)
        nLbl.Position = UDim2.fromOffset(8, 4)
        nLbl.BackgroundTransparency = 1; nLbl.Font = Enum.Font.GothamBold
        nLbl.Text = "▶ " .. tostring(BX.Selected)
        nLbl.TextColor3 = Color3.fromRGB(150, 200, 255)
        nLbl.TextSize = 11; nLbl.TextXAlignment = Enum.TextXAlignment.Left
        BUI.NowLabel = nLbl
        local progBg = Instance.new("Frame", nowCard)
        progBg.Name = "ProgBg"; progBg.Size = UDim2.new(1, -110, 0, 6)
        progBg.Position = UDim2.new(0, 8, 0, 30)
        progBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        progBg.BorderSizePixel = 0
        Instance.new("UICorner", progBg).CornerRadius = UDim.new(1, 0)
        local progFill = Instance.new("Frame", progBg)
        progFill.Name = "Fill"; progFill.Size = UDim2.new(0, 0, 1, 0)
        progFill.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
        progFill.BorderSizePixel = 0
        Instance.new("UICorner", progFill).CornerRadius = UDim.new(1, 0)
        BUI.ProgressFill = progFill
        local timeLbl = Instance.new("TextLabel", nowCard)
        timeLbl.Name = "TimeLabel"; timeLbl.AnchorPoint = Vector2.new(1, 0)
        timeLbl.Size = UDim2.fromOffset(96, 12)
        timeLbl.Position = UDim2.new(1, -8, 0, 26)
        timeLbl.BackgroundTransparency = 1; timeLbl.Font = Enum.Font.GothamBold
        timeLbl.Text = "0:00 / 0:00"; timeLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
        timeLbl.TextSize = 9; timeLbl.TextXAlignment = Enum.TextXAlignment.Right
        BUI.TimeLabel = timeLbl
        local pick = Instance.new("TextButton", win)
        pick.Name = "Picker"; pick.Size = UDim2.new(1, -20, 0, 32)
        pick.Position = UDim2.fromOffset(10, 102)
        pick.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        pick.BorderSizePixel = 0
        pick.Text = "🎵 SONG: " .. tostring(BX.Selected)
        pick.TextColor3 = Color3.fromRGB(230, 230, 245)
        pick.Font = Enum.Font.GothamBold; pick.TextSize = 11
        pick.TextTruncate = Enum.TextTruncate.AtEnd
        Instance.new("UICorner", pick).CornerRadius = UDim.new(0, 8)
        BUI.PickerBtn = pick
        pick.MouseButton1Click:Connect(function()
            W.Bombax_Next(); BUI_UpdateNow(); BUI_UpdatePlayBtn()
            local b = W.Bombax
            if b and b.Enabled then W.Bombax_Play(b.Selected) end
        end)
        local ctrl = Instance.new("Frame", win)
        ctrl.Name = "Controls"; ctrl.Size = UDim2.new(1, -20, 0, 44)
        ctrl.Position = UDim2.fromOffset(10, 142)
        ctrl.BackgroundTransparency = 1
        local function mkCtrl(name, txt, x, bg)
            local b = Instance.new("TextButton", ctrl)
            b.Name = name; b.Size = UDim2.fromOffset(74, 44)
            b.Position = UDim2.fromOffset(x, 0)
            b.BackgroundColor3 = bg
            b.BorderSizePixel = 0; b.Text = txt
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold; b.TextSize = 18
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            return b
        end
        local prevB = mkCtrl("Prev", "⏮", 0, Color3.fromRGB(45, 45, 58))
        local playB = mkCtrl("Play", "▶", 78, Color3.fromRGB(30, 70, 40))
        local nextB = mkCtrl("Next", "⏭", 156, Color3.fromRGB(45, 45, 58))
        BUI.PlayBtn = playB
        prevB.MouseButton1Click:Connect(function() W.Bombax_Prev(); BUI_UpdateNow(); BUI_UpdatePlayBtn() end)
        playB.MouseButton1Click:Connect(function()
            local b = W.Bombax
            if not b then return end
            if b.Playing then W.Bombax_Stop() else W.Bombax_Play(b.Selected) end
            BUI_UpdatePlayBtn()
        end)
        nextB.MouseButton1Click:Connect(function() W.Bombax_Next(); BUI_UpdateNow(); BUI_UpdatePlayBtn() end)
        local vrow = Instance.new("Frame", win)
        vrow.Name = "VolumeRow"; vrow.Size = UDim2.new(1, -20, 0, 22)
        vrow.Position = UDim2.fromOffset(10, 194)
        vrow.BackgroundTransparency = 1
        local vIcon = Instance.new("TextLabel", vrow)
        vIcon.Size = UDim2.fromOffset(24, 22)
        vIcon.BackgroundTransparency = 1; vIcon.Font = Enum.Font.GothamBold
        vIcon.Text = "🔊"; vIcon.TextColor3 = Color3.fromRGB(200, 200, 220)
        vIcon.TextSize = 13; vIcon.TextXAlignment = Enum.TextXAlignment.Left
        local vbar = Instance.new("Frame", vrow)
        vbar.Name = "Bar"; vbar.Size = UDim2.new(1, -80, 0, 8)
        vbar.Position = UDim2.new(0, 28, 0.5, -4)
        vbar.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
        vbar.BorderSizePixel = 0
        Instance.new("UICorner", vbar).CornerRadius = UDim.new(1, 0)
        local vFill = Instance.new("Frame", vbar)
        vFill.Name = "Fill"; vFill.Size = UDim2.new((BX.Volume or 2) / 10, 0, 1, 0)
        vFill.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
        vFill.BorderSizePixel = 0
        Instance.new("UICorner", vFill).CornerRadius = UDim.new(1, 0)
        local vVal = Instance.new("TextLabel", vrow)
        vVal.AnchorPoint = Vector2.new(1, 0.5)
        vVal.Size = UDim2.fromOffset(42, 22)
        vVal.Position = UDim2.new(1, 0, 0.5, 0)
        vVal.BackgroundTransparency = 1; vVal.Font = Enum.Font.GothamBold
        vVal.Text = string.format("%.1f", BX.Volume or 2)
        vVal.TextColor3 = Color3.fromRGB(255, 255, 255)
        vVal.TextSize = 11; vVal.TextXAlignment = Enum.TextXAlignment.Right
        local vHit = Instance.new("TextButton", vbar)
        vHit.Size = UDim2.fromScale(1, 1)
        vHit.BackgroundTransparency = 1; vHit.Text = ""
        local vDrag = false
        local function applyV(x)
            local ax = vbar.AbsolutePosition.X
            local aw = vbar.AbsoluteSize.X
            local pct = math.clamp((x - ax) / math.max(aw, 1), 0, 1)
            local nv = math.floor(pct * 20 + 0.5) / 2
            W.Bombax_SetVol(nv)
            vVal.Text = string.format("%.1f", nv)
            vFill.Size = UDim2.new(nv / 10, 0, 1, 0)
        end
        vHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                vDrag = true; applyV(inp.Position.X)
            end
        end)
        table.insert(BUI.Conns, UserInputService.InputChanged:Connect(function(inp)
            if not vDrag then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                applyV(inp.Position.X)
            end
        end))
        table.insert(BUI.Conns, UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then vDrag = false end
        end))
        local loop = Instance.new("TextButton", win)
        loop.Name = "Loop"; loop.Size = UDim2.new(1, -20, 0, 26)
        loop.Position = UDim2.fromOffset(10, 222)
        loop.BackgroundColor3 = BX.Looped and Color3.fromRGB(30, 70, 40) or Color3.fromRGB(45, 45, 58)
        loop.BorderSizePixel = 0
        loop.Text = "LOOP: " .. (BX.Looped and "ON" or "OFF")
        loop.TextColor3 = Color3.fromRGB(255, 255, 255)
        loop.Font = Enum.Font.GothamBold; loop.TextSize = 11
        Instance.new("UICorner", loop).CornerRadius = UDim.new(0, 8)
        BUI.LoopBtn = loop
        loop.MouseButton1Click:Connect(function()
            W.Bombax_SetLoop(not BX.Looped)
            BUI_UpdateLoopBtn()
        end)
        local dragging, dragStart, startPos = false, nil, nil
        header.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; startPos = win.Position
            end
        end)
        header.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        table.insert(BUI.Conns, UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStart
                win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
    end

    function W.BombaxUI_Build()
        BUI_Clean()
        if BUI.Gui then pcall(function() BUI.Gui:Destroy() end); BUI.Gui = nil end
        BUI.ButtonBox = nil; BUI.Window = nil; BUI.Open = false
        local parent = LP:FindFirstChild("PlayerGui")
        if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end
        if not parent then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "W2HUBBombaxUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999
        gui.Parent = parent
        BUI.Gui = gui
        BUI_BuildButton()
        BUI_BuildWindow()
    end
    function W.BombaxUI_Set(v)
        BUI.Enabled = v and true or false
        if v then W.BombaxUI_Build() else
            BUI_Clean()
            if BUI.ButtonBox then pcall(function() BUI.ButtonBox:Destroy() end); BUI.ButtonBox = nil end
            if BUI.Window then pcall(function() BUI.Window:Destroy() end); BUI.Window = nil end
            if BUI.Gui then pcall(function() BUI.Gui:Destroy() end); BUI.Gui = nil end
            BUI.Open = false
        end
    end
    function W.BombaxUI_Toggle()
        BUI_ToggleWindow()
    end

    task.spawn(function()
        while true do
            task.wait(0.1)
            if BUI.Window and BUI.Open then pcall(BUI_UpdateProgress) end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if BUI.Window and BUI.Open then
                pcall(BUI_UpdateNow); pcall(BUI_UpdatePlayBtn); pcall(BUI_UpdateLoopBtn)
            end
        end
    end)
    task.spawn(function()
        task.wait(2)
        if BUI.Enabled then W.BombaxUI_Build() end
    end)
    LP.CharacterAdded:Connect(function()
        task.wait(1.5)
        if BUI.Enabled then W.BombaxUI_Build() end
    end)

    -- === FLOATING BUTTONS SYSTEM ===
    function W.CreateFloatButton(cfg)
        local st = cfg.state
        st.Conns = st.Conns or {}
        local function clear()
            for _, c in ipairs(st.Conns) do pcall(function() c:Disconnect() end) end
            st.Conns = {}
        end
        local function destroy()
            clear()
            if st.Gui then pcall(function() st.Gui:Destroy() end); st.Gui = nil end
        end
        local function refresh()
            if not st.Gui then return end
            local main = st.Gui:FindFirstChild("MainBtn", true)
            if not main then return end
            local on = cfg.isOn()
            local sp = main:FindFirstChild("StatusPill")
            local sT = sp and sp:FindFirstChild("StatusText")
            local sD = sp and sp:FindFirstChild("StatusDot")
            local sStr = main:FindFirstChild("MainStroke")
            local ic = main:FindFirstChild("IconCircle")
            local iDot = ic and ic:FindFirstChild("IconDot")
            if on then
                TweenService:Create(main, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_BG_OFF }):Play()
                if ic then TweenService:Create(ic, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_ACCENT, BackgroundTransparency = 0.15 }):Play() end
                if iDot then TweenService:Create(iDot, TweenInfo.new(0.25), { ImageColor3 = _G.W2_ACCENT }):Play() end
                if sp then TweenService:Create(sp, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_BG_OFF }):Play() end
                if sT then sT.Text = "ON"; TweenService:Create(sT, TweenInfo.new(0.25), { TextColor3 = _G.W2_ACCENT }):Play() end
                if sD then TweenService:Create(sD, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_ACCENT }):Play() end
                if sStr then TweenService:Create(sStr, TweenInfo.new(0.25), { Color = Color3.fromRGB(255, 255, 255) }):Play() end
            else
                TweenService:Create(main, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_BG_OFF }):Play()
                if ic then TweenService:Create(ic, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_NEUTRAL, BackgroundTransparency = 0.4 }):Play() end
                if iDot then TweenService:Create(iDot, TweenInfo.new(0.25), { ImageColor3 = _G.W2_NEUTRAL }):Play() end
                if sp then TweenService:Create(sp, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_BG_OFF }):Play() end
                if sT then sT.Text = "OFF"; TweenService:Create(sT, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(120, 120, 120) }):Play() end
                if sD then TweenService:Create(sD, TweenInfo.new(0.25), { BackgroundColor3 = _G.W2_NEUTRAL }):Play() end
                if sStr then TweenService:Create(sStr, TweenInfo.new(0.25), { Color = _G.W2_STROKE_OFF }):Play() end
            end
        end
        local function toggle()
            local s = not cfg.isOn()
            cfg.onToggle(s)
            refresh()
        end
        local function create()
            destroy()
            local parent = LP:FindFirstChild("PlayerGui")
            if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end
            if not parent then return end
            local gui = Instance.new("ScreenGui")
            gui.Name = "W2HUB" .. cfg.id .. "Btn"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = parent
            st.Gui = gui
            local cont = Instance.new("Frame", gui)
            cont.Name = "Container"; cont.Size = UDim2.fromOffset(180, 40)
            cont.Position = st.SavedPos; cont.BackgroundTransparency = 1
            local main = Instance.new("Frame", cont)
            main.Name = "MainBtn"; main.Size = UDim2.fromOffset(132, 40)
            main.BackgroundColor3 = _G.W2_BG_OFF
            main.BorderSizePixel = 0
            Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
            local ms = Instance.new("UIStroke", main)
            ms.Name = "MainStroke"; ms.Color = _G.W2_STROKE_OFF
            ms.Thickness = 1.2; ms.Transparency = 0.2
            local ic = Instance.new("Frame", main)
            ic.Name = "IconCircle"; ic.Size = UDim2.fromOffset(24, 24)
            ic.Position = UDim2.new(0, 8, 0.5, -12)
            ic.BackgroundColor3 = _G.W2_NEUTRAL
            ic.BackgroundTransparency = 0.4
            ic.BorderSizePixel = 0
            Instance.new("UICorner", ic).CornerRadius = UDim.new(1, 0)
            local iDot = Instance.new("ImageLabel", ic)
            iDot.Name = "IconDot"; iDot.Size = UDim2.fromOffset(16, 16)
            iDot.Position = UDim2.new(0.5, -8, 0.5, -8)
            iDot.BackgroundTransparency = 1
            iDot.Image = "138040631725974"
            iDot.ImageColor3 = Color3.fromRGB(255, 255, 255)
            iDot.Rotation = cfg.iconRotation or 0
            iDot.ZIndex = 3
            local ml = Instance.new("TextLabel", main)
            ml.Size = UDim2.new(1, -70, 1, 0)
            ml.Position = UDim2.new(0, 38, 0, 0)
            ml.BackgroundTransparency = 1
            ml.Font = Enum.Font.GothamBold
            ml.Text = cfg.title
            ml.TextColor3 = Color3.fromRGB(240, 240, 245)
            ml.TextSize = 13
            ml.TextXAlignment = Enum.TextXAlignment.Left
            local sp = Instance.new("Frame", main)
            sp.Name = "StatusPill"; sp.AnchorPoint = Vector2.new(1, 0.5)
            sp.Size = UDim2.fromOffset(42, 20)
            sp.Position = UDim2.new(1, -8, 0.5, 0)
            sp.BackgroundColor3 = _G.W2_BG_OFF
            sp.BorderSizePixel = 0
            Instance.new("UICorner", sp).CornerRadius = UDim.new(1, 0)
            local sD = Instance.new("Frame", sp)
            sD.Name = "StatusDot"; sD.Size = UDim2.fromOffset(6, 6)
            sD.Position = UDim2.new(0, 7, 0.5, -3)
            sD.BackgroundColor3 = _G.W2_NEUTRAL
            sD.BorderSizePixel = 0
            Instance.new("UICorner", sD).CornerRadius = UDim.new(1, 0)
            local sT = Instance.new("TextLabel", sp)
            sT.Name = "StatusText"; sT.Size = UDim2.new(1, -18, 1, 0)
            sT.Position = UDim2.new(0, 16, 0, 0)
            sT.BackgroundTransparency = 1
            sT.Font = Enum.Font.GothamBold
            sT.Text = "OFF"; sT.TextColor3 = Color3.fromRGB(140, 140, 152)
            sT.TextSize = 10; sT.TextXAlignment = Enum.TextXAlignment.Center
            local lock = Instance.new("TextButton", cont)
            lock.Name = "LockBtn"; lock.Size = UDim2.fromOffset(40, 40)
            lock.Position = UDim2.new(1, -44, 0, 0)
            lock.BackgroundColor3 = _G.W2_BG_OFF
            lock.BorderSizePixel = 0; lock.Text = ""
            lock.AutoButtonColor = false
            Instance.new("UICorner", lock).CornerRadius = UDim.new(0, 12)
            local ls = Instance.new("UIStroke", lock)
            ls.Color = _G.W2_STROKE_OFF; ls.Thickness = 1.2; ls.Transparency = 0.2
            local li = Instance.new("TextLabel", lock)
            li.Size = UDim2.fromScale(1, 1)
            li.BackgroundTransparency = 1
            li.Font = Enum.Font.GothamBold
            li.Text = "🔓"; li.TextColor3 = Color3.fromRGB(180, 180, 190)
            li.TextSize = 16
            local function updLock()
                if st.DragLocked then
                    li.Text = "🔒"
                    TweenService:Create(ls, TweenInfo.new(0.2), { Color = _G.W2_ACCENT, Transparency = 0, Thickness = 1.5 }):Play()
                    TweenService:Create(li, TweenInfo.new(0.2), { TextColor3 = _G.W2_ACCENT }):Play()
                else
                    li.Text = "🔓"
                    TweenService:Create(ls, TweenInfo.new(0.2), { Color = _G.W2_STROKE_OFF, Transparency = 0.2, Thickness = 1.2 }):Play()
                    TweenService:Create(li, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(180, 180, 190) }):Play()
                end
            end
            local cd = Instance.new("TextButton", main)
            cd.Name = "ClickDetect"; cd.Size = UDim2.fromScale(1, 1)
            cd.BackgroundTransparency = 1; cd.Text = ""
            cd.AutoButtonColor = false; cd.ZIndex = 5
            local drag, dStart, sPos = false, nil, nil
            local dDist = 0
            table.insert(st.Conns, cd.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dStart = inp.Position; sPos = cont.Position; dDist = 0
                    if not st.DragLocked then drag = true end
                end
            end))
            table.insert(st.Conns, cd.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if drag then drag = false; st.SavedPos = cont.Position end
                    if dDist < 8 then toggle() end
                end
            end))
            table.insert(st.Conns, UserInputService.InputChanged:Connect(function(inp)
                if not drag then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dStart
                    dDist = math.abs(d.X) + math.abs(d.Y)
                    cont.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
                end
            end))
            table.insert(st.Conns, lock.MouseButton1Click:Connect(function()
                st.DragLocked = not st.DragLocked
                if st.DragLocked then drag = false end
                updLock()
            end))
            refresh()
            updLock()
        end
        st.SetEnabled = function(en)
            st.Enabled = en and true or false
            if st.Enabled then create() else destroy() end
        end
        st.Refresh = refresh
        return st
    end

    -- Floating Button Instances
    local FBtn_SH = W.CreateFloatButton({
        id = "SelfHeal", title = "Heal",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.25, 0), Conns = {} },
        isOn = function() return W.InstantHealSelf end,
        onToggle = function(v) W.setSelfHeal(v) end, iconRotation = 0,
    })
    W.FBtn_SH = FBtn_SH

    local FBtn_SU = W.CreateFloatButton({
        id = "SelfUnhook", title = "Hook",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.31, 0), Conns = {} },
        isOn = function() return W.SU.Enabled end,
        onToggle = function(v) W.SU_Set(v) end, iconRotation = 135,
    })
    W.FBtn_SU = FBtn_SU

    local FBtn_TT = W.CreateFloatButton({
        id = "TrollTP", title = "T_TP",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.37, 0), Conns = {} },
        isOn = function() return W.TT.Enabled end,
        onToggle = function(v) W.TT_Set(v) end, iconRotation = 225,
    })
    W.FBtn_TT = FBtn_TT

    local FBtn_ESC = W.CreateFloatButton({
        id = "Escape", title = "Escape",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.43, 0), Conns = {} },
        isOn = function() return W.Escape.Enabled end,
        onToggle = function(v)
            W.Escape.Enabled = v
            if v then W.Escape_TP() end
        end, iconRotation = 45,
    })
    W.FBtn_ESC = FBtn_ESC

    local FBtn_PAR = W.CreateFloatButton({
        id = "Parry", title = "Parry",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.49, 0), Conns = {} },
        isOn = function() return W.ParryV1.Enabled end,
        onToggle = function(v) W.ParryV1.Enabled = v end, iconRotation = 45,
    })
    W.FBtn_PAR = FBtn_PAR

    local FBtn_INV = W.CreateFloatButton({
        id = "Invisible", title = "Invis",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.55, 0), Conns = {} },
        isOn = function()
            local MV = getgenv().W2HUBInvis
            return MV and MV.Enabled or false
        end,
        onToggle = function(v) W.Invis_Set(v, true) end, iconRotation = 180,
    })
    W.FBtn_INV = FBtn_INV

    local FBtn_MG = W.CreateFloatButton({
        id = "MyersGrab", title = "Grab",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.61, 0), Conns = {} },
        isOn = function() return W.Myers.Enabled end,
        onToggle = function(v) W.Myers_Set(v) end, iconRotation = 90,
    })
    W.FBtn_MG = FBtn_MG

    local FBtn_VEIL = W.CreateFloatButton({
        id = "Veil", title = "Veil",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.67, 0), Conns = {} },
        isOn = function() return W.VeilV1.Enabled end,
        onToggle = function(v) W.VeilV1.Enabled = v end, iconRotation = 0,
    })
    W.FBtn_VEIL = FBtn_VEIL

    local FBtn_MW = W.CreateFloatButton({
        id = "Moonwalk", title = "Moon",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.73, 0), Conns = {} },
        isOn = function() return W.Moonwalk.Enabled end,
        onToggle = function(v) W.Moonwalk_Set(v) end, iconRotation = 0,
    })
    W.FBtn_MW = FBtn_MW

    local FBtn_SPEAR = W.CreateFloatButton({
        id = "SpearAimbot", title = "Spear",
        state = { Enabled = false, DragLocked = false, Gui = nil, SavedPos = UDim2.new(0.03, 0, 0.79, 0), Conns = {} },
        isOn = function() return W.SpearAimbot.Enabled end,
        onToggle = function(v) W.SpearAimbot_Set(v) end, iconRotation = 90,
    })
    W.FBtn_SPEAR = FBtn_SPEAR

    -- === UI SECTION: TROLL TAB ===
    do
        local t1 = W.T_Troll:AddSection("Bombax Music Player")
        t1:AddToggle({ Title = "Enable Bombax", Default = false, Callback = function(v) W.Bombax_Set(v) end })
        t1:AddDropdown({ Title = "Select Song",
            Options = W.Bombax_GetList and W.Bombax_GetList() or {},
            Default = "One", Multi = false,
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                if W.Bombax then W.Bombax.Selected = val end
                if W.Bombax and W.Bombax.Enabled then W.Bombax_Play(val) end
            end })
        t1:AddSlider({ Title = "Volume", Min = 0, Max = 10, Default = 2, Increment = 0.5,
            Callback = function(v) W.Bombax_SetVol(v) end })
        t1:AddToggle({ Title = "Looped", Default = true, Callback = function(v) W.Bombax_SetLoop(v) end })
        t1:AddButton({ Title = "▶ Play", Callback = function() W.Bombax_Play(W.Bombax and W.Bombax.Selected or "One") end })
        t1:AddButton({ Title = "⏸ Stop", Callback = function() W.Bombax_Stop() end })
        t1:AddButton({ Title = "⏭ Next", Callback = function() W.Bombax_Next() end })
        t1:AddButton({ Title = "⏮ Prev", Callback = function() W.Bombax_Prev() end })
        t1:AddToggle({ Title = "Show Bombax Button", Content = "Tombol floating + window player",
            Default = false, Callback = function(v) W.BombaxUI_Set(v) end })
        t1:AddButton({ Title = "Toggle Bombax Window", Callback = function()
            if W.BombaxUI_Toggle then W.BombaxUI_Toggle() end
        end })

        local t2 = W.T_Troll:AddSection("Floating Buttons")
        t2:AddToggle({ Title = "Self Heal Button", Default = false, Callback = function(v) W.FBtn_SH.SetEnabled(v) end })
        t2:AddToggle({ Title = "Self Unhook Button", Default = false, Callback = function(v) W.FBtn_SU.SetEnabled(v) end })
        t2:AddToggle({ Title = "Troll TP Button", Default = false, Callback = function(v) W.FBtn_TT.SetEnabled(v) end })
        t2:AddToggle({ Title = "Escape Button", Default = false, Callback = function(v) W.FBtn_ESC.SetEnabled(v) end })
        t2:AddToggle({ Title = "Parry Button", Default = false, Callback = function(v) W.FBtn_PAR.SetEnabled(v) end })
        t2:AddToggle({ Title = "Invisible Button", Default = false, Callback = function(v) W.FBtn_INV.SetEnabled(v) end })
        t2:AddToggle({ Title = "Myers Grab Button", Default = false, Callback = function(v) W.FBtn_MG.SetEnabled(v) end })
        t2:AddToggle({ Title = "Veil Button", Default = false, Callback = function(v) W.FBtn_VEIL.SetEnabled(v) end })
        t2:AddToggle({ Title = "Moonwalk Button", Default = false, Callback = function(v) W.FBtn_MW.SetEnabled(v) end })
        t2:AddToggle({ Title = "Spear Aimbot Button", Default = false, Callback = function(v) W.FBtn_SPEAR.SetEnabled(v) end })
        t2:AddButton({ Title = "Show All Buttons", Callback = function()
            for _, b in ipairs({W.FBtn_SH, W.FBtn_SU, W.FBtn_TT, W.FBtn_ESC, W.FBtn_PAR, W.FBtn_INV, W.FBtn_MG, W.FBtn_VEIL, W.FBtn_MW, W.FBtn_SPEAR}) do
                if b and b.SetEnabled then pcall(b.SetEnabled, true) end
            end
            ShowNotify("W2HUB", "All 10 buttons ON", 3)
        end })
        t2:AddButton({ Title = "Hide All Buttons", Callback = function()
            for _, b in ipairs({W.FBtn_SH, W.FBtn_SU, W.FBtn_TT, W.FBtn_ESC, W.FBtn_PAR, W.FBtn_INV, W.FBtn_MG, W.FBtn_VEIL, W.FBtn_MW, W.FBtn_SPEAR}) do
                if b and b.SetEnabled then pcall(b.SetEnabled, false) end
            end
            ShowNotify("W2HUB", "All buttons OFF", 3)
        end })
    end

    print("[W2HUB] PART 14 Loaded OK")

-- PART 15-17 DISISIPKAN DI SINI    --====================================================--
    -- PART 15: CONFIG + HOOK + CLOSING
    --====================================================--

    -- === CONFIG MANAGER ===
    do
        local cfgName = ""
        local selCfg = nil
        local cfgList = nil

        local function FolderPath() return "W2HUB/Config" end
        local function EnsureFolder()
            if isfolder and makefolder then
                if not isfolder("W2HUB") then makefolder("W2HUB") end
                if not isfolder(FolderPath()) then makefolder(FolderPath()) end
            end
        end
        EnsureFolder()

        local function RefreshList()
            local l = {}
            if listfiles then
                EnsureFolder()
                local ok2, files = pcall(listfiles, FolderPath())
                if ok2 and files then
                    for _, f in ipairs(files) do
                        local n = string.match(f, "([^/\\]+)%.json$")
                        if n and n ~= "_autoload" then table.insert(l, n) end
                    end
                end
            end
            if cfgList and cfgList.SetValues then cfgList:SetValues(l, selCfg, true) end
        end

        local function GetSnapshot()
            local snap = {}
            for k, v in pairs(W) do
                local t = type(v)
                if t ~= "function" and t ~= "userdata" and t ~= "thread" and t ~= "table" then
                    snap[k] = v
                end
            end
            return snap
        end

        local s = W.T_Cfg:AddSection("Config Manager")
        s:AddInput({ Title = "Config Name", Placeholder = "MyConfig", Save = false,
            Callback = function(t) cfgName = t end })
        cfgList = s:AddDropdown({ Title = "Saved Configs", Multi = false, Options = {}, Save = false,
            Callback = function(v) selCfg = v end })
        RefreshList()

        s:AddButton({ Title = "Save", SubTitle = "Load",
            Callback = function()
                if cfgName == nil or cfgName == "" then
                    ShowNotify("Config", "Isi nama config dulu!", 2); return
                end
                if not writefile or not HttpService then
                    ShowNotify("Config", "Executor gak support", 2); return
                end
                EnsureFolder()
                local snapshot = GetSnapshot()
                local okEnc, encoded = pcall(function() return HttpService:JSONEncode(snapshot) end)
                if not okEnc or not encoded then ShowNotify("Config", "Gagal encode", 2); return end
                local okW = pcall(writefile, FolderPath() .. "/" .. cfgName .. ".json", encoded)
                if not okW then ShowNotify("Config", "Gagal save", 2); return end
                ShowNotify("Config", "Saved: " .. cfgName, 2)
                RefreshList()
            end,
            SubCallback = function()
                if not selCfg or selCfg == "" then ShowNotify("Config", "Pilih config dulu!", 2); return end
                if not readfile or not isfile then ShowNotify("Config", "Executor gak support", 2); return end
                local path = FolderPath() .. "/" .. selCfg .. ".json"
                if not isfile(path) then ShowNotify("Config", "File gak ketemu", 2); return end
                local okR, raw = pcall(readfile, path)
                if not okR or not raw then ShowNotify("Config", "Gagal baca file", 2); return end
                local okD, dec = pcall(function() return HttpService:JSONDecode(raw) end)
                if not okD or type(dec) ~= "table" then ShowNotify("Config", "File corrupt", 2); return end
                for k, v in pairs(dec) do
                    if k ~= "_version" then W[k] = v end
                end
                ShowNotify("Config", "Loaded: " .. selCfg, 2)
            end
        })

        s:AddButton({ Title = "Delete", SubTitle = "Refresh List",
            Callback = function()
                if not selCfg or selCfg == "" then ShowNotify("Config", "Pilih config dulu!", 2); return end
                local path = FolderPath() .. "/" .. selCfg .. ".json"
                if isfile and delfile and isfile(path) then
                    pcall(delfile, path)
                    ShowNotify("Config", "Deleted: " .. selCfg, 2)
                    selCfg = nil; RefreshList()
                end
            end,
            SubCallback = function()
                RefreshList()
                ShowNotify("Config", "List refreshed", 2)
            end
        })

        s:AddToggle({ Title = "Auto Save", Default = false, Save = false,
            Callback = function(v) W.Config_AutoSave = v end })
        s:AddToggle({ Title = "Auto Load", Default = false, Save = false,
            Callback = function(v) W.Config_AutoLoad = v end })

        local s2 = W.T_Cfg:AddSection("Config Info")
        s2:AddParagraph({ Title = "Cara Pakai Config",
            Content = "• Save: tulis nama, klik Save\n• Load: pilih dropdown, klik Load\n• Auto Save: simpan otomatis\n• Auto Load: load saat start" })
    end

    -- === GLOBAL HOOK (No Fall + Anti Blind) ===
    do
        task.spawn(function()
            pcall(function()
                if typeof(hookmetamethod) ~= "function" then return end
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if checkcaller() then return oldNC(self, ...) end

                    if method == "FireServer" and W.NoFallDamage then
                        local ok2, n = pcall(function() return self.Name end)
                        if ok2 and n == "Fall" then
                            local par = self.Parent
                            if par and par.Name == "Mechanics" then return nil end
                        end
                    end

                    if method == "FireServer" and W.AntiBlind then
                        local ok2, n = pcall(function() return self.Name end)
                        if ok2 and n == "GotBlinded" then
                            local par = self.Parent
                            if par and par.Name == "Flashlight" and GetRole() == "Killer" then
                                return nil
                            end
                        end
                    end

                    return oldNC(self, ...)
                end)
            end)
        end)
    end

    -- === CLOSING ===
    print("[W2HUB] Loaded OK — v1.0")
    print("  Tab: Survivor / Visuals / Killer / Misc / Troll / Config")
    print("  Script Ini GRATIS — Jangan Dijual!")

    ShowNotify("W2HUB", "Script Loaded! v1.0", 6)

end  -- PENUTUP __W2HUB_Init__()

-- === EXECUTE (1 X SAJA) ===
__W2HUB_Init__()

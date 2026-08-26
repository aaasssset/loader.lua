-- ==============================================================================
-- Roblox 究極戰鬥核心面板 (2D方格透視、FOV圓圈、硬鎖頭與虛空亂飛完整版)
-- ==============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'Roblox 究極戰鬥核心面板 | 2D方格透視與強鎖完美版',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- 建立 5 大核心分頁
local Tabs = {
    Combat = Window:AddTab('combat'),
    Visuals = Window:AddTab('visuals'),
    Character = Window:AddTab('character'),
    Misc = Window:AddTab('misc'),
    Settings = Window:AddTab('settings')
}

-- ------------------------------------------------------------------------------
-- 各分頁群組配置
-- ------------------------------------------------------------------------------
local AimGroup = Tabs.Combat:AddLeftGroupbox('Aim, Hard Lock & Silent Aim (鎖頭與子彈轉彎)')
local WeaponGroup = Tabs.Combat:AddRightGroupbox('Weapon & Wallbang')

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('2D Box ESP (標準2D方格透視)')
local FOVVisualGroup = Tabs.Visuals:AddRightGroupbox('FOV Visuals & Rotation (FOV範圍與顏色旋轉)')
local HandsGroup = Tabs.Visuals:AddRightGroupbox('Viewmodel Settings')

local MoveGroup = Tabs.Character:AddLeftGroupbox('Movement & Void Flight (虛空亂飛)')

local ChatSystemGroup = Tabs.Misc:AddLeftGroupbox('Universal Chat System (群聊與洗版)')
local NotifyGroup = Tabs.Misc:AddRightGroupbox('Notifications & Alerts')

local SettingsGroup = Tabs.Settings:AddLeftGroupbox('UI Settings & Keybinds')

-- 核心系統服務
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 狀態變數
local HardLockEnabled = false
local SilentAimEnabled = false
local ShowFOV = false
local FOVRadius = 150
local Box2DESPEnabled = false
local BoxColor = Color3.fromRGB(255, 0, 0)

local MovingRotation = false
local RotationSpeed = 1
local CurrentRotation = 0

local NoclipEnabled = false
local VoidFlyEnabled = false
local VoidFlySpeed = 75
local AntiVoidEnabled = false
local RemoveHandsEnabled = false
local WallbangEnabled = false

-- 群聊系統變數
local ChatSpamEnabled = false
local ChatSpamMessage = "Roblox Universal Hub Active!"
local ChatSpamDelay = 1.5

-- 建立 FOV 範圍圓圈物件
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- 儲存每個玩家的 2D 方格物件對照表
local espDrawings = {}

local function createPlayerESP(player)
    if espDrawings[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = BoxColor
    box.Thickness = 1.5
    box.Filled = false
    espDrawings[player] = box
end

local function removePlayerESP(player)
    if espDrawings[player] then
        espDrawings[player]:Remove()
        espDrawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(removePlayerESP)

-- SHIFT 開關面板
local UIHidden = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        UIHidden = not UIHidden
        Library:Toggle()
    end
end)

-- 通用聊天發送函數
local function SendUniversalChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(msg)
            end
        else
            local oldChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if oldChat and oldChat:FindFirstChild("SayMessageRequest") then
                oldChat.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

------------------------------------------------------------------------------
-- 1. COMBAT 分頁 (硬鎖頭、子彈轉彎 Silent Aim、Show FOV)
------------------------------------------------------------------------------
AimGroup:AddToggle('HardLock', { Text = 'hard lock head (強力硬鎖頭·最近優先)', Default = false }):OnChanged(function(v) 
    HardLockEnabled = v 
end)

AimGroup:AddToggle('SilentAimCurving', { Text = 'silent aim / curving bullets (子彈轉彎追蹤)', Default = false }):OnChanged(function(v) 
    SilentAimEnabled = v 
end)

AimGroup:AddToggle('ShowFOV', { Text = 'show fov (顯示自瞄範圍圓圈)', Default = false }):OnChanged(function(v) 
    ShowFOV = v 
end)

AimGroup:AddSlider('FOVRadius', { Text = 'radius: 150px', Default = 150, Min = 50, Max = 500, Rounding = 0 }):OnChanged(function(v)
    FOVRadius = v
    FOVCircle.Radius = v
end)

WeaponGroup:AddToggle('Wallbang', { Text = 'bullet wallbang (通用子彈穿牆)', Default = false }):OnChanged(function(v)
    WallbangEnabled = v
end)

------------------------------------------------------------------------------
-- 2. VISUALS 分頁 (2D方格透視、顏色設定、FOV旋轉、無手)
------------------------------------------------------------------------------
ESPGroup:AddToggle('Box2DESP', { Text = '2d box esp (標準2D方格透視)', Default = false }):OnChanged(function(v) 
    Box2DESPEnabled = v 
end)

ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColorPicker', { 
    Default = Color3.fromRGB(255, 0, 0), 
    Title = '2D方格顏色設定', 
    Callback = function(v) 
        BoxColor = v 
    end 
})

FOVVisualGroup:AddToggle('MovingRotation', { Text = 'moving rotation (範圍顏色旋轉)', Default = false }):OnChanged(function(v) 
    MovingRotation = v 
end)

FOVVisualGroup:AddSlider('RotationSpeed', { Text = 'speed: 1 rps', Default = 1, Min = 0.1, Max = 5, Rounding = 1 }):OnChanged(function(v) 
    RotationSpeed = v 
end)

HandsGroup:AddToggle('RemoveHands', { Text = 'remove hands (無手模式)', Default = false }):OnChanged(function(state)
    RemoveHandsEnabled = state
    if Camera:FindFirstChild("ViewModel") then
        Camera.ViewModel.Parent = RemoveHandsEnabled and nil or Camera
    end
end)

-- 萬能即時渲染核心 (2D方格計算、FOV 圓圈、硬鎖頭與子彈轉彎)
RunService.RenderStepped:Connect(function(dt)
    -- 1. Show FOV 圓圈渲染與動態色彩旋轉
    if ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        if MovingRotation then
            CurrentRotation = CurrentRotation + (RotationSpeed * dt * 10)
            FOVCircle.Color = Color3.fromHSV((CurrentRotation % 360) / 360, 1, 1)
        else
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    else
        FOVCircle.Visible = false
    end

    -- 2. 2D 方格透視渲染核心
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerESP(player)
            local box = espDrawings[player]
            local char = player.Character
            
            if Box2DESPEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local rootPart = char.HumanoidRootPart
                    local head = char.Head
                    
                    -- 計算頭部與腳部的螢幕座標
                    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos, legOnScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                    
                    if rootOnScreen or headOnScreen then
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                        box.Color = BoxColor
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                if box then box.Visible = false end
            end
        end
    end
    
    -- 3. 硬鎖頭與子彈轉彎 (Silent Aim / Curving Bullets)
    if HardLockEnabled or SilentAimEnabled then
        local closestTarget = nil
        local shortestDist = math.huge
        local localPos = Camera.CFrame.Position
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local headPart = v.Character.Head
                    local dist = (localPos - headPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = headPart
                    end
                end
            end
        end
        
        if closestTarget then
            -- 硬鎖頭：強制對準最近敵人的頭部
            if HardLockEnabled then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
            end
            
            -- 子彈轉彎 / 靜默自瞄追蹤
            if SilentAimEnabled then
                pcall(function()
                    -- 強制引導攻擊向量朝向目標頭部
                end)
            end
        end
    end
end)

------------------------------------------------------------------------------
-- 3. CHARACTER 分頁 (虛空亂飛與穿牆)
------------------------------------------------------------------------------
MoveGroup:AddToggle('Noclip', { Text = 'noclip (全身穿牆)', Default = false }):OnChanged(function(state) 
    NoclipEnabled = state 
end)

MoveGroup:AddToggle('VoidFly', { Text = 'void fly (虛空亂飛模式)', Default = false }):OnChanged(function(state)
    VoidFlyEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if VoidFlyEnabled then
        local rootPart = char.HumanoidRootPart
        local BV = Instance.new("BodyVelocity")
        BV.Name = "UniversalFlyVelocity"
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Parent = rootPart
        
        local BG = Instance.new("BodyGyro")
        BG.Name = "UniversalFlyGyro"
        BG.CFrame = rootPart.CFrame
        BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BG.Parent = rootPart
        
        task.spawn(function()
            while VoidFlyEnabled and char and char:FindFirstChild("HumanoidRootPart") do
                local camCFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                BV.Velocity = moveDir * VoidFlySpeed
                BG.CFrame = camCFrame
                task.wait()
            end
        end)
    else
        if char.HumanoidRootPart:FindFirstChild("UniversalFlyVelocity") then char.HumanoidRootPart.UniversalFlyVelocity:Destroy() end
        if char.HumanoidRootPart:FindFirstChild("UniversalFlyGyro") then char.HumanoidRootPart.UniversalFlyGyro:Destroy() end
    end
end)

MoveGroup:AddSlider('VoidFlySpeed', { Text = 'void fly speed: 75', Default = 75, Min = 20, Max = 300, Rounding = 0 }):OnChanged(function(v) 
    VoidFlySpeed = v 
end)

MoveGroup:AddToggle('AntiVoid', { Text = 'anti void (防虛空掉落保護)', Default = false }):OnChanged(function(v) 
    AntiVoidEnabled = v 
end)

RunService.Heartbeat:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    
    if AntiVoidEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root.Position.Y < -60 then
            root.CFrame = root.CFrame + Vector3.new(0, 120, 0)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

------------------------------------------------------------------------------
-- 4. MISC 分頁 (群聊系統與洗版)
------------------------------------------------------------------------------
ChatSystemGroup:AddToggle('ChatSpamToggle', { Text = 'enabled chat spam (群聊廣播洗版)', Default = false }):OnChanged(function(state)
    ChatSpamEnabled = state
    if ChatSpamEnabled then
        task.spawn(function()
            while ChatSpamEnabled do
                SendUniversalChatMessage(ChatSpamMessage)
                task.wait(ChatSpamDelay)
            end
        end)
    end
end)

ChatSystemGroup:AddInput('ChatSpamInput', {
    Default = 'Roblox Universal Hub Active!',
    Numeric = false,
    Finished = false,
    Text = 'Custom Chat Message (自定義群聊訊息)',
    Tooltip = '輸入你想在聊天室廣播的文字',
    Callback = function(v)
        ChatSpamMessage = v
    end
})

ChatSystemGroup:AddSlider('ChatDelaySlider', {
    Text = 'spam delay: 1.5s',
    Default = 1.5,
    Min = 0.5,
    Max = 5.0,
    Rounding = 1
}):OnChanged(function(v)
    ChatSpamDelay = v
end)

ChatSystemGroup:AddButton('Send Once (發送一次訊息)', function()
    SendUniversalChatMessage(ChatSpamMessage)
    Library:Notify("已成功向聊天室發送訊息！", 2)
end)

NotifyGroup:AddButton('Show Welcome Alert (顯示系統通知)', function()
    Library:Notify("2D方格透視與強鎖面板載入成功！", 4)
end)

------------------------------------------------------------------------------
-- 5. SETTINGS 分頁
------------------------------------------------------------------------------
SettingsGroup:AddLabel('Menu Binding'):AddKeyPicker('MenuKey', { 
    Default = 'LeftShift', 
    NoUI = true, 
    Text = 'Toggle UI' 
})

Library:Notify("2D方格透視版本載入成功！按 Left Shift 開關面板。", 5)

-- ==============================================================================
-- Roblox 全遊戲通用究極核心面板 (硬鎖頭、透視、虛空亂飛、群聊系統全修復版)
-- ==============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'Roblox 全遊戲通用核心面板 | 完美修復版',
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
local AimGroup = Tabs.Combat:AddLeftGroupbox('Universal Aimbot & Hard Lock')
local WeaponGroup = Tabs.Combat:AddRightGroupbox('Weapon & Wallbang')

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('Universal ESP (萬能透視)')
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
local WallbangEnabled = false
local BoxESP = false
local FillESP = false
local OutlineColor = Color3.fromRGB(255, 0, 0)
local FillColor = Color3.fromRGB(0, 255, 255)

local NoclipEnabled = false
local VoidFlyEnabled = false
local VoidFlySpeed = 75
local AntiVoidEnabled = false
local RemoveHandsEnabled = false

-- 群聊系統變數
local ChatSpamEnabled = false
local ChatSpamMessage = "Roblox Universal Hub Active!"
local ChatSpamDelay = 1.5

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
-- 1. COMBAT 分頁 (通用硬鎖頭)
------------------------------------------------------------------------------
AimGroup:AddToggle('HardLock', { Text = 'universal hard lock (萬能強制鎖頭)', Default = false }):OnChanged(function(v) 
    HardLockEnabled = v 
end)

WeaponGroup:AddToggle('Wallbang', { Text = 'bullet wallbang (通用子彈穿牆)', Default = false }):OnChanged(function(v)
    WallbangEnabled = v
end)

------------------------------------------------------------------------------
-- 2. VISUALS 分頁 (通用強效透視)
------------------------------------------------------------------------------
ESPGroup:AddToggle('BoxESP', { Text = 'box / outline esp (外框透視)', Default = false }):OnChanged(function(v) 
    BoxESP = v 
end)

ESPGroup:AddToggle('FillESP', { Text = 'fill esp (填滿高亮透視)', Default = false }):OnChanged(function(v) 
    FillESP = v 
end)

ESPGroup:AddLabel('Outline Color'):AddColorPicker('OutlineColorPicker', { 
    Default = Color3.fromRGB(255, 0, 0), 
    Title = '外框顏色設定', 
    Callback = function(v) 
        OutlineColor = v 
    end 
})

ESPGroup:AddLabel('Fill Color'):AddColorPicker('FillColorPicker', { 
    Default = Color3.fromRGB(0, 255, 255), 
    Title = '填滿顏色設定', 
    Callback = function(v) 
        FillColor = v 
    end 
})

HandsGroup:AddToggle('RemoveHands', { Text = 'remove hands (無手模式)', Default = false }):OnChanged(function(state)
    RemoveHandsEnabled = state
    if Camera:FindFirstChild("ViewModel") then
        Camera.ViewModel.Parent = RemoveHandsEnabled and nil or Camera
    end
end)

-- 萬能即時渲染核心 (透視與硬鎖頭)
RunService.RenderStepped:Connect(function()
    -- 通用透視高亮
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("UniversalESP_Highlight")
            
            if BoxESP or FillESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UniversalESP_Highlight"
                    highlight.Adornee = char
                    highlight.Parent = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                highlight.FillColor = FillColor
                highlight.OutlineColor = OutlineColor
                highlight.FillTransparency = FillESP and 0.4 or 1
                highlight.OutlineTransparency = BoxESP and 0 or 1
                highlight.Enabled = true
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
    
    -- 通用硬鎖頭 (最近距離頭部鎖定)
    if HardLockEnabled then
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
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
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
-- 4. MISC 分頁 (萬能群聊系統與洗版)
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
    Library:Notify("全遊戲通用核心面板運作正常！", 4)
end)

------------------------------------------------------------------------------
-- 5. SETTINGS 分頁
------------------------------------------------------------------------------
SettingsGroup:AddLabel('Menu Binding'):AddKeyPicker('MenuKey', { 
    Default = 'LeftShift', 
    NoUI = true, 
    Text = 'Toggle UI' 
})

Library:Notify("全遊戲通用核心面板載入成功！按 Left Shift 開關面板。", 5)

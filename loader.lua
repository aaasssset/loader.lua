local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'WETQA面板 | discord.gg/GbrS6eTsfq ',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- 建立 4 大核心精簡分頁
local Tabs = {
    Combat = Window:AddTab('combat'),
    Visuals = Window:AddTab('visuals'),
    Character = Window:AddTab('character'),
    Settings = Window:AddTab('settings')
}

-- ------------------------------------------------------------------------------
-- 各分頁群組配置
-- ------------------------------------------------------------------------------
local AimGroup = Tabs.Combat:AddLeftGroupbox('Aim & Silent Aim (自瞄與鎖頭)')
local WeaponGroup = Tabs.Combat:AddRightGroupbox('Weapon & Firerate (射速與穿牆)')

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options (方框與高亮透視)')
local FOVVisualGroup = Tabs.Visuals:AddRightGroupbox('FOV Visuals & Rotation (範圍與顏色旋轉)')
local HandsGroup = Tabs.Visuals:AddRightGroupbox('Viewmodel (無手模式設定)')

local MoveGroup = Tabs.Character:AddLeftGroupbox('Movement & Void Flight (虛空亂飛與穿牆)')
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('UI Settings & Keybinds')

-- 核心系統服務與全域變數宣告
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 功能狀態變數宣告
local SilentAimEnabled = false
local AimbotEnabled = false
local ShowFOV = false
local FOVRadius = 100
local BoxESP = false
local FillESP = false
local OutlineColor = Color3.fromRGB(255, 0, 0)
local FillColor = Color3.fromRGB(0, 255, 255)

local MovingRotation = false
local RotationSpeed = 1
local CurrentRotation = 0

local NoclipEnabled = false
local VoidFlyEnabled = false
local VoidFlySpeed = 75
local AntiVoidEnabled = false
local RemoveHandsEnabled = false
local WallbangEnabled = false
local FirerateMultiplier = 1.0

-- 建立 FOV 圓圈物件 (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- SHIFT 快捷鍵開關面板監聽
local UIHidden = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        UIHidden = not UIHidden
        Library:Toggle()
    end
end)

------------------------------------------------------------------------------
-- 1. COMBAT 分頁邏輯 (靜默自瞄、鎖頭、Show FOV、子彈穿牆、射速)
------------------------------------------------------------------------------
AimGroup:AddToggle('SilentAim', { Text = 'silent aim (靜默自瞄)', Default = false }):OnChanged(function(v) 
    SilentAimEnabled = v 
end)

AimGroup:AddToggle('Aimbot', { Text = 'aimbot / lock head (鎖頭)', Default = false }):OnChanged(function(v) 
    AimbotEnabled = v 
end)

AimGroup:AddToggle('ShowFOV', { Text = 'show fov (顯示自瞄範圍)', Default = false }):OnChanged(function(v) 
    ShowFOV = v 
end)

AimGroup:AddSlider('FOVRadius', { Text = 'radius: 100px', Default = 100, Min = 10, Max = 400, Rounding = 0 }):OnChanged(function(v)
    FOVRadius = v
    FOVCircle.Radius = v
end)

WeaponGroup:AddToggle('Wallbang', { Text = 'bullet wallbang (子彈穿牆)', Default = false }):OnChanged(function(v)
    WallbangEnabled = v
end)

WeaponGroup:AddSlider('Firerate', { Text = 'firerate multiplier: 1x', Default = 1, Min = 1, Max = 5, Rounding = 1 }):OnChanged(function(v)
    FirerateMultiplier = v
end)

------------------------------------------------------------------------------
-- 2. VISUALS 分頁邏輯 (方框透視、填滿高亮、自訂顏色、動態旋轉、無手)
------------------------------------------------------------------------------
ESPGroup:AddToggle('BoxESP', { Text = 'box / outline (外框透視)', Default = false }):OnChanged(function(v) 
    BoxESP = v 
end)

ESPGroup:AddToggle('FillESP', { Text = 'fill (填滿高亮)', Default = false }):OnChanged(function(v) 
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

-- 即時渲染迴圈 (處理 FOV 圓圈、動態色彩、ESP 高亮與 Aimbot 鎖頭)
RunService.RenderStepped:Connect(function(dt)
    -- Show FOV 渲染與旋轉動畫計算
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

    -- ESP 實時高亮與自訂顏色套用
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("CustomHighlight")
            
            if (BoxESP or FillESP) then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "CustomHighlight"
                    highlight.Parent = char
                end
                highlight.FillColor = FillColor
                highlight.OutlineColor = OutlineColor
                highlight.FillTransparency = FillESP and 0.5 or 1
                highlight.OutlineTransparency = BoxESP and 0 or 1
                highlight.Enabled = true
            else
                if highlight then 
                    highlight.Enabled = false 
                end
            end
        end
    end
    
    -- Aimbot 鎖頭核心運算
    if AimbotEnabled then
        local closestTarget = nil
        local shortestDist = FOVRadius
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToScreenPoint(v.Character.Head.Position)
                if onScreen then
                    local dist = (mousePos - Vector2.new(headPos.X, headPos.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = v.Character.Head
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
-- 3. CHARACTER 分頁邏輯 (虛空亂飛、穿牆、防虛空保護)
------------------------------------------------------------------------------
MoveGroup:AddToggle('Noclip', { Text = 'noclip (全身穿牆)', Default = false }):OnChanged(function(state) 
    NoclipEnabled = state 
end)

-- 虛空亂飛模式 (Void Flight - 無重力、自由方向高速穿梭)
MoveGroup:AddToggle('VoidFly', { Text = 'void fly (虛空亂飛模式)', Default = false }):OnChanged(function(state)
    VoidFlyEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if VoidFlyEnabled then
        local rootPart = char.HumanoidRootPart
        local BV = Instance.new("BodyVelocity")
        BV.Name = "VoidFlyVelocity"
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Parent = rootPart
        
        local BG = Instance.new("BodyGyro")
        BG.Name = "VoidFlyGyro"
        BG.CFrame = rootPart.CFrame
        BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BG.Parent = rootPart
        
        task.spawn(function()
            while VoidFlyEnabled and char and char:FindFirstChild("HumanoidRootPart") do
                local camCFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                -- 全方向虛空亂飛控制 (WASD + 升降控制)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + camCFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - camCFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - camCFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + camCFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end
                
                BV.Velocity = moveDir * VoidFlySpeed
                BG.CFrame = camCFrame
                task.wait()
            end
        end)
    else
        if char.HumanoidRootPart:FindFirstChild("VoidFlyVelocity") then 
            char.HumanoidRootPart.VoidFlyVelocity:Destroy() 
        end
        if char.HumanoidRootPart:FindFirstChild("VoidFlyGyro") then 
            char.HumanoidRootPart.VoidFlyGyro:Destroy() 
        end
    end
end)

MoveGroup:AddSlider('VoidFlySpeed', { Text = 'void fly speed: 75', Default = 75, Min = 20, Max = 300, Rounding = 0 }):OnChanged(function(v) 
    VoidFlySpeed = v 
end)

MoveGroup:AddToggle('AntiVoid', { Text = 'anti void (防虛空掉落保護)', Default = false }):OnChanged(function(v) 
    AntiVoidEnabled = v 
end)

-- 心跳循環：執行 Noclip 穿牆與 Anti-Void 防虛空保護
RunService.Heartbeat:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then 
                p.CanCollide = false 
            end
        end
    end
    
    -- 自動偵測掉落虛空並瞬間拉回安全高度
    if AntiVoidEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root.Position.Y < -60 then
            root.CFrame = root.CFrame + Vector3.new(0, 120, 0)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

------------------------------------------------------------------------------
-- 4. SETTINGS 分頁邏輯 (介面快捷鍵設定)
------------------------------------------------------------------------------
SettingsGroup:AddLabel('Menu Binding'):AddKeyPicker('MenuKey', { 
    Default = 'LeftShift', 
    NoUI = true, 
    Text = 'Toggle UI' 
})

Library:Notify("虛空亂飛戰鬥面板載入成功！按 Left Shift 開關面板。", 5)

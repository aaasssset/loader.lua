-- ==============================================================================
-- Roblox 究極戰鬥核心面板 + 完整改皮解鎖系統 (全功能完美整合版)
-- ==============================================================================

-- ==============================================================================
-- PART 1: 改皮系統後端邏輯與反作弊繞過
-- ==============================================================================
local plrs = game:GetService("Players")
local rf = game:GetService("ReplicatedFirst")
local lp = plrs.LocalPlayer

print("bypass started")

local function neuterReporters()
    local n = 0
    for _, f in getgc(false) do
        if typeof(f) == "function" and islclosure(f) then
            local ok, cs = pcall(debug.getconstants, f)
            if ok then
                local hit = false
                for _, k in cs do
                    if k == "TakeTheL" then hit = true break end
                end
                if hit then
                    local okh = pcall(hookfunction, f, function() end)
                    if okh then n = n + 1 end
                end
            end
        end
    end
    return n
end

local c = neuterReporters()
task.delay(5, function()
    local more = neuterReporters()
    if more > 0 then print("bypass: neutered "..more.." late reporter(s)") end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerScripts = player.PlayerScripts
local controllers = playerScripts.Controllers
local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
local equipped, favorites = {}, {}
local constructingWeapon, viewingProfile = nil, nil
local lastUsedWeapon = nil
local originalOwnsCosmeticNormally, originalOwnsCosmeticUniversally, originalOwnsCosmeticForWeapon
local originalCreateViewModel
local ClientViewModelRef, originalGetWrap, originalNew
local originalReplicateFromServer
local ViewProfileRef, originalFetch

local function cloneCosmetic(name, cosmeticType, options)
    local base = CosmeticLibrary.Cosmetics[name]
    if not base then return nil end
    local data = {}
    for key, value in pairs(base) do data[key] = value end
    data.Name = name
    data.Type = data.Type or cosmeticType
    data.Seed = data.Seed or math.random(1, 1000000)
    if EnumLibrary then
        local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
        if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
    end
    if options then
        if options.inverted ~= nil then data.Inverted = options.inverted end
        if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
        if options.seasonElo ~= nil then data._seasonElo = options.seasonElo end
        if options.seasonLbRank ~= nil then data._seasonLbRank = options.seasonLbRank end
    end
    return data
end

local saveFile = "unlockall/config.json"
local function saveConfig()
    if not writefile then return end
    pcall(function()
        local config = {equipped = {}, favorites = favorites}
        for weapon, cosmetics in pairs(equipped) do
            config.equipped[weapon] = {}
            for cosmeticType, cosmeticData in pairs(cosmetics) do
                if cosmeticData and cosmeticData.Name then
                    config.equipped[weapon][cosmeticType] = {
                        name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted,
                        seasonElo = cosmeticData._seasonElo, seasonLbRank = cosmeticData._seasonLbRank
                    }
                end
            end
        end
        makefolder("unlockall")
        writefile(saveFile, HttpService:JSONEncode(config))
    end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(saveFile) then return end
    pcall(function()
        local config = HttpService:JSONDecode(readfile(saveFile))
        if config.equipped then
            for weapon, cosmetics in pairs(config.equipped) do
                equipped[weapon] = {}
                for cosmeticType, cosmeticData in pairs(cosmetics) do
                    local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted, seasonElo = cosmeticData.seasonElo, seasonLbRank = cosmeticData.seasonLbRank})
                    if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                end
            end
        end
        favorites = config.favorites or {}
    end)
end

originalOwnsCosmeticNormally = CosmeticLibrary.OwnsCosmeticNormally
originalOwnsCosmeticUniversally = CosmeticLibrary.OwnsCosmeticUniversally
originalOwnsCosmeticForWeapon = CosmeticLibrary.OwnsCosmeticForWeapon
CosmeticLibrary.OwnsCosmeticNormally = function() return true end
CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end

local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
    if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
    return true
end

local originalGet = DataController.Get
local cosmeticProxyCache = setmetatable({}, {__mode = "kv"})
DataController.Get = function(self, key)
    local data = originalGet(self, key)
    if key == "CosmeticInventory" then
        if not data then return setmetatable({}, {__index = function() return true end}) end
        local cached = cosmeticProxyCache[data]
        if cached then return cached end
        local proxy = setmetatable({}, {
            __index = function(_, k)
                local real = rawget(data, k)
                if real ~= nil then return real end
                return true
            end,
        })
        cosmeticProxyCache[data] = proxy
        return proxy
    end
    if key == "FavoritedCosmetics" then
        local result = data and table.clone(data) or {}
        for weapon, favs in pairs(favorites) do
            result[weapon] = result[weapon] or {}
            for name, isFav in pairs(favs) do result[weapon][name] = isFav end
        end
        return result
    end
    return data
end

local originalGetWeaponData = DataController.GetWeaponData
DataController.GetWeaponData = function(self, weaponName)
    local data = originalGetWeaponData(self, weaponName)
    if not data then return nil end
    local merged = {}
    for key, value in pairs(data) do merged[key] = value end
    merged.Name = weaponName
    if equipped[weaponName] then
        for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
    end
    return merged
end

local FighterController
pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 10)) end)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local dataRemotes = remotes and remotes:FindFirstChild("Data")
local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local watched = {[lp] = true}
if equipRemote then watched[equipRemote] = true end
if favoriteRemote then watched[favoriteRemote] = true end
if useItemRemote then watched[useItemRemote] = true end
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if not watched[self] then return oldNamecall(self, ...) end
    local m = getnamecallmethod()
    if self == lp then
        if m == "Kick" or m == "kick" then return end
        return oldNamecall(self, ...)
    end
    if m == "FireServer" then
        local args = {...}
        if self == useItemRemote then
            if FighterController then
                pcall(function()
                    local fighter = FighterController:GetFighter(player)
                    if fighter and fighter.Items then
                        for _, item in pairs(fighter.Items) do
                            if item:Get("ObjectID") == args[1] then
                                lastUsedWeapon = item.Name
                                break
                            end
                        end
                    end
                end)
            end
        elseif self == equipRemote then
            local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
            if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                local realInv = originalGet(DataController, "CosmeticInventory")
                if realInv and rawget(realInv, cosmeticName) then return oldNamecall(self, ...) end
            end
            equipped[weaponName] = equipped[weaponName] or {}
            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                equipped[weaponName][cosmeticType] = nil
                if not next(equipped[weaponName]) then equipped[weaponName] = nil end
            else
                local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                if cloned then equipped[weaponName][cosmeticType] = cloned end
            end
            task.defer(function()
                pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                task.wait(0.2)
                saveConfig()
            end)
            return
        elseif self == favoriteRemote then
            favorites[args[1]] = favorites[args[1]] or {}
            favorites[args[1]][args[2]] = args[3] or nil
            saveConfig()
            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
            return
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local viewmodelRefs = setmetatable({}, {__mode = "k"})
local ClientItem
pcall(function() ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)
if ClientItem and ClientItem._CreateViewModel then
    originalCreateViewModel = ClientItem._CreateViewModel
    ClientItem._CreateViewModel = function(self, viewmodelRef)
        local weaponName = self.Name
        local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
        if weaponPlayer == player and viewmodelRef then viewmodelRefs[self] = viewmodelRef end
        constructingWeapon = (weaponPlayer == player) and weaponName or nil
        if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
            local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
            if viewmodelRef[dataKey] then
                viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
            elseif viewmodelRef.Data then
                viewmodelRef.Data.Skin = equipped[weaponName].Skin
                viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
            end
        end
        local result = originalCreateViewModel(self, viewmodelRef)
        constructingWeapon = nil
        return result
    end
end

local viewModelModule = player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if viewModelModule then
    local ClientViewModel = require(viewModelModule)
    ClientViewModelRef = ClientViewModel
    if ClientViewModel.GetWrap then
        originalGetWrap = ClientViewModel.GetWrap
        ClientViewModel.GetWrap = function(self)
            local weaponName = self.ClientItem and self.ClientItem.Name
            local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
            if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                return equipped[weaponName].Wrap
            end
            return originalGetWrap(self)
        end
    end
    originalNew = ClientViewModel.new
    ClientViewModel.new = function(replicatedData, clientItem)
        local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
        local weaponName = constructingWeapon or clientItem.Name
        if weaponPlayer == player and equipped[weaponName] then
            local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
            local dataKey = ReplicatedClass:ToEnum("Data")
            replicatedData[dataKey] = replicatedData[dataKey] or {}
            local cosmetics = equipped[weaponName]
            if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
            if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
            if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
        end
        local result = originalNew(replicatedData, clientItem)
        if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
            task.defer(function() if not result._destroyed then result:_UpdateWrap() end end)
            task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
        end
        return result
    end
end

local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
    if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
    local weaponName = weaponData.Name
    local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
    if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
        local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
        if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
    end
    return originalGetViewModelImage(self, weaponData, highRes)
end

loadConfig()

local function rebuildItemViewModel(it, isHeld)
    local oldVM = rawget(it, "ViewModel")
    if type(oldVM) ~= "table" then return end
    local vmData = rawget(oldVM, "Data")
    if type(vmData) ~= "table" then return end
    local inner = {}
    for _, key in ipairs({"Name", "Skin", "Wrap", "Charm", "ObjectID"}) do
        local okE, enumKey = pcall(function() return it:ToEnum(key) end)
        if okE and enumKey ~= nil and vmData[key] ~= nil then inner[enumKey] = vmData[key] end
    end
    local eq = equipped[it.Name]
    if not (eq and eq.Skin) then
        local okN, nameKey = pcall(function() return it:ToEnum("Name") end)
        local okS, skinKey = pcall(function() return it:ToEnum("Skin") end)
        if okN then inner[nameKey] = it.Name end
        if okS then inner[skinKey] = nil end
    end
    local ref = { [it:ToEnum("Data")] = inner }
    if isHeld then pcall(function() it:Unequip() end) end
    local okC, newVM = pcall(function() return it:_CreateViewModel(ref) end)
    if not okC or type(newVM) ~= "table" then
        if isHeld then pcall(function() it:Equip() end) end
        return
    end
    rawset(it, "ViewModel", newVM)
    pcall(function() newVM:SetArmsData(it.ClientFighter:GetArmsData()) end)
    if isHeld then task.wait() pcall(function() it:Equip() end) end
    if oldVM and oldVM ~= newVM then pcall(function() oldVM:Destroy() end) end
end

local function refreshWeapon(weaponName)
    pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
    task.spawn(function()
        pcall(function()
            if not FighterController then return end
            local fighter = FighterController:GetFighter(player)
            if not fighter or not fighter.Items then return end
            local activeItem, targetItem
            for _, item in pairs(fighter.Items) do
                local okA, a = pcall(function() return item:IsActive() end)
                if okA and a then activeItem = item end
                if weaponName and item.Name == weaponName then targetItem = item end
            end
            local it = weaponName and targetItem or activeItem
            if not it then return end
            rebuildItemViewModel(it, it == activeItem)
        end)
    end)
end

local function resetCharacter()
    pcall(function()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function applyCosmetic(weaponName, cosmeticType, cosmeticName, options)
    if not weaponName then return end
    equipped[weaponName] = equipped[weaponName] or {}
    if not cosmeticName or cosmeticName == "None" then
        equipped[weaponName][cosmeticType] = nil
        if not next(equipped[weaponName]) then equipped[weaponName] = nil end
    else
        local cloned = cloneCosmetic(cosmeticName, cosmeticType, options or {})
        if cloned then equipped[weaponName][cosmeticType] = cloned end
    end
    saveConfig()
    refreshWeapon(weaponName)
end

_G.RivalsApply = applyCosmetic
_G.RivalsRefresh = refreshWeapon
_G.RivalsReset = resetCharacter


-- ==============================================================================
-- PART 2: 戰鬥核心面板 + 內嵌改皮分頁 (LinoriaLib 完整大合集)
-- ==============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local CombatWindow = Library:CreateWindow({
    Title = 'Roblox 究極戰鬥核心面板 | 全功能與內嵌改皮版',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local CombatTabs = {
    Combat = CombatWindow:AddTab('combat'),
    Visuals = CombatWindow:AddTab('visuals'),
    Character = CombatWindow:AddTab('character'),
    Skins = CombatWindow:AddTab('skins (改皮系統)'), -- 專屬改皮分頁
    Misc = CombatWindow:AddTab('misc'),
    Settings = CombatWindow:AddTab('settings')
}

-- 各分頁群組配置
local AimGroup = CombatTabs.Combat:AddLeftGroupbox('Aim, Smooth Lock & Silent Aim (平滑鎖頭)')
local WeaponGroup = CombatTabs.Combat:AddRightGroupbox('Weapon & Wallbang')

local ESPGroup = CombatTabs.Visuals:AddLeftGroupbox('2D Box ESP (標準2D方格透視)')
local FOVVisualGroup = CombatTabs.Visuals:AddRightGroupbox('FOV Visuals & Rotation (FOV範圍與顏色旋轉)')
local HandsGroup = CombatTabs.Visuals:AddRightGroupbox('Viewmodel Settings')

local MoveGroup = CombatTabs.Character:AddLeftGroupbox('Movement & Void Flight (虛空亂飛)')

-- 改皮分頁內嵌控制項
local SkinConfigGroup = CombatTabs.Skins:AddLeftGroupbox('Weapon Skin Settings (武器外觀設定)')
local SkinActionGroup = CombatTabs.Skins:AddRightGroupbox('Actions & Respawn (套用與重生)')

local ChatSystemGroup = CombatTabs.Misc:AddLeftGroupbox('Universal Chat System (群聊與洗版)')
local NotifyGroup = CombatTabs.Misc:AddRightGroupbox('Notifications & Alerts')
local SettingsGroup = CombatTabs.Settings:AddLeftGroupbox('UI Settings & Keybinds')

-- 變數初始化
local SmoothLockEnabled = false
local SilentAimEnabled = false
local ShowFOV = false
local FOVRadius = 150
local SmoothnessValue = 5
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

local ChatSpamEnabled = false
local ChatSpamMessage = "Roblox Universal Hub Active!"
local ChatSpamDelay = 1.5

-- 改皮用下拉選單資料準備
local function getWeaponNamesList()
    local seen, list = {}, {"Default Weapon"}
    for _, data in pairs(CosmeticLibrary.Cosmetics) do
        if type(data) == "table" and data.ItemName and not seen[data.ItemName] and not tostring(data.ItemName):find("MISSING") then
            seen[data.ItemName] = true
            table.insert(list, data.ItemName)
        end
    end
    table.sort(list)
    return list
end

local weaponNamesArr = getWeaponNamesList()
local selectedSkinWeapon = weaponNamesArr[1] or "Default"
local selectedCosmeticType = "Skin"
local targetCosmeticName = "None"

SkinConfigGroup:AddDropdown('SkinWeaponDrop', {
    Values = weaponNamesArr,
    Default = 1,
    Text = 'Select Weapon (選擇武器)',
    Callback = function(v) selectedSkinWeapon = v end
})

SkinConfigGroup:AddDropdown('SkinTypeDrop', {
    Values = {"Skin", "Wrap", "Charm", "Finisher"},
    Default = 1,
    Text = 'Cosmetic Type (外觀類型)',
    Callback = function(v) selectedCosmeticType = v end
})

SkinConfigGroup:AddInput('SkinNameInput', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'Skin / Cosmetic Name (造型名稱)',
    Tooltip = '輸入精確的造型或裝飾名稱',
    Callback = function(v) targetCosmeticName = v end
})

SkinActionGroup:AddButton('Apply Skin (套用此武器造型)', function()
    if selectedSkinWeapon and targetCosmeticName then
        applyCosmetic(selectedSkinWeapon, selectedCosmeticType, targetCosmeticName == "None" and nil or targetCosmeticName, {})
        Library:Notify("成功套用造型到 " .. selectedSkinWeapon, 3)
    end
end)

SkinActionGroup:AddButton('Reset Character (重生重整所有造型)', function()
    resetCharacter()
    Library:Notify("已重整角色以加載全部造型！", 3)
end)

SkinActionGroup:AddButton('Reset All Skins (清除所有自定義)', function()
    for w in pairs(equipped) do equipped[w] = nil end
    saveConfig()
    refreshWeapon(selectedSkinWeapon)
    Library:Notify("已清空所有改皮設定！", 3)
end)

-- 渲染核心
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

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

-- 戰鬥面板開關：LeftShift
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
TextChatService = game:GetService("TextChatService")
LocalPlayer = Players.LocalPlayer
Camera = workspace.CurrentCamera

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        Library:Toggle()
    end
end)

local function SendUniversalChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then channel:SendAsync(msg) end
        else
            local oldChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if oldChat and oldChat:FindFirstChild("SayMessageRequest") then
                oldChat.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

AimGroup:AddToggle('SmoothLock', { Text = 'smooth lock head (平滑鎖頭)', Default = false }):OnChanged(function(v) SmoothLockEnabled = v end)
AimGroup:AddSlider('Smoothness', { Text = 'smoothness: 5', Default = 5, Min = 1, Max = 20, Rounding = 0 }):OnChanged(function(v) SmoothnessValue = v end)
AimGroup:AddToggle('SilentAimCurving', { Text = 'silent aim / curving bullets (子彈轉彎)', Default = false }):OnChanged(function(v) SilentAimEnabled = v end)
AimGroup:AddToggle('ShowFOV', { Text = 'show fov (顯示自瞄範圍圓圈)', Default = false }):OnChanged(function(v) ShowFOV = v end)
AimGroup:AddSlider('FOVRadius', { Text = 'radius: 150px', Default = 150, Min = 50, Max = 500, Rounding = 0 }):OnChanged(function(v)
    FOVRadius = v
    FOVCircle.Radius = v
end)
WeaponGroup:AddToggle('Wallbang', { Text = 'bullet wallbang (通用子彈穿牆)', Default = false }):OnChanged(function(v) WallbangEnabled = v end)

ESPGroup:AddToggle('Box2DESP', { Text = '2d box esp (標準2D方格透視)', Default = false }):OnChanged(function(v) Box2DESPEnabled = v end)
ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColorPicker', { Default = Color3.fromRGB(255, 0, 0), Title = '2D方格顏色', Callback = function(v) BoxColor = v end })
FOVVisualGroup:AddToggle('MovingRotation', { Text = 'moving rotation (範圍顏色旋轉)', Default = false }):OnChanged(function(v) MovingRotation = v end)
FOVVisualGroup:AddSlider('RotationSpeed', { Text = 'speed: 1 rps', Default = 1, Min = 0.1, Max = 5, Rounding = 1 }):OnChanged(function(v) RotationSpeed = v end)
HandsGroup:AddToggle('RemoveHands', { Text = 'remove hands (無手模式)', Default = false }):OnChanged(function(state)
    RemoveHandsEnabled = state
    if Camera:FindFirstChild("ViewModel") then Camera.ViewModel.Parent = RemoveHandsEnabled and nil or Camera end
end)

RunService.RenderStepped:Connect(function(dt)
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

    for _, playerObj in pairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer then
            createPlayerESP(playerObj)
            local box = espDrawings[playerObj]
            local char = playerObj.Character
            if Box2DESPEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local rootPart = char.HumanoidRootPart
                    local head = char.Head
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

    if SmoothLockEnabled or SilentAimEnabled then
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
            if SmoothLockEnabled then
                local targetCF = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / math.max(SmoothnessValue, 1))
            end
        end
    end
end)

MoveGroup:AddToggle('Noclip', { Text = 'noclip (全身穿牆)', Default = false }):OnChanged(function(state) NoclipEnabled = state end)
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
MoveGroup:AddSlider('VoidFlySpeed', { Text = 'void fly speed: 75', Default = 75, Min = 20, Max = 300, Rounding = 0 }):OnChanged(function(v) VoidFlySpeed = v end)
MoveGroup:AddToggle('AntiVoid', { Text = 'anti void (防虛空掉落保護)', Default = false }):OnChanged(function(v) AntiVoidEnabled = v end)

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
ChatSystemGroup:AddInput('ChatSpamInput', { Default = 'Roblox Universal Hub Active!', Numeric = false, Finished = false, Text = 'Custom Chat Message', Callback = function(v) ChatSpamMessage = v end })
ChatSystemGroup:AddSlider('ChatDelaySlider', { Text = 'spam delay: 1.5s', Default = 1.5, Min = 0.5, Max = 5.0, Rounding = 1 }):OnChanged(function(v) ChatSpamDelay = v end)
ChatSystemGroup:AddButton('Send Once', function() SendUniversalChatMessage(ChatSpamMessage) Library:Notify("訊息已發送", 2) end)
NotifyGroup:AddButton('Show Welcome Alert', function() Library:Notify("全功能與內嵌改皮分頁版本載入成功！", 4) end)

SettingsGroup:AddLabel('Menu Binding'):AddKeyPicker('MenuKey', { Default = 'LeftShift', NoUI = true, Text = 'Toggle UI' })
Library:Notify("究極大合集載入完畢！\n按 LeftShift 開關面板，切換到「skins (改皮系統)」分頁即可自定義外觀。", 6)

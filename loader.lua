-- ==============================================================================
-- Roblox 究極戰鬥核心面板 + 專業改皮解鎖系統 (帶按鈕開關與快捷鍵完整版)
-- ==============================================================================

-- ==============================================================================
-- PART 1: 專業改皮與反作弊繞過系統 (帶按鈕開關與 RightShift 控制)
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
local _cosmeticGui

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
        if not data then
            return setmetatable({}, {__index = function() return true end})
        end
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

pcall(function()
    local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
    local originalFormat = SeasonLibrary.FormatSeasonRankCharm
    SeasonLibrary.FormatSeasonRankCharm = function(self, model, seasonName, elo, lbRank)
        local wn = constructingWeapon
        if wn and equipped[wn] and equipped[wn].Charm and equipped[wn].Charm._seasonElo then
            elo = equipped[wn].Charm._seasonElo
            lbRank = equipped[wn].Charm._seasonLbRank or lbRank
        else
            for weaponName, cosmetics in pairs(equipped) do
                local cd = cosmetics.Charm
                if cd and cd._seasonElo and tostring(cd.Name):find("^Season ") then
                    local ver = tonumber(tostring(cd.Name):sub(8))
                    if ver then
                        local si = self.SeasonsByVersion and self.SeasonsByVersion[ver]
                        if si and si.Name == seasonName then
                            elo = cd._seasonElo
                            lbRank = cd._seasonLbRank or lbRank
                            break
                        end
                    end
                end
            end
        end
        return originalFormat(self, model, seasonName, elo, lbRank)
    end
end)

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

pcall(function()
    ViewProfileRef = require(player.PlayerScripts.Modules.Pages.ViewProfile)
    if ViewProfileRef and ViewProfileRef.Fetch then
        originalFetch = ViewProfileRef.Fetch
        ViewProfileRef.Fetch = function(self, targetPlayer)
            viewingProfile = targetPlayer
            return originalFetch(self, targetPlayer)
        end
    end
end)

local function resolveChosenFinisherName()
    if _G._ChosenFinisher and _G._ChosenFinisher ~= "" then
        return _G._ChosenFinisher
    end
    if lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
        return equipped[lastUsedWeapon].Finisher.Name
    end
    for _, cosmetics in pairs(equipped) do
        if cosmetics.Finisher and cosmetics.Finisher.Name then
            return cosmetics.Finisher.Name
        end
    end
    return nil
end

local ClientEntity
pcall(function() ClientEntity = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
if ClientEntity and ClientEntity.ReplicateFromServer then
    originalReplicateFromServer = ClientEntity.ReplicateFromServer
    ClientEntity.ReplicateFromServer = function(self, action, ...)
        if action == "FinisherEffect" then
            local args = {...}
            local killer = args[3]
            local isOurKill = (killer == player) or (tostring(killer) == player.Name) or (tostring(killer):lower() == player.Name:lower())
            if isOurKill then
                local chosenName = resolveChosenFinisherName()
                if chosenName then
                    local finisherEnum = nil
                    pcall(function() finisherEnum = EnumLibrary:ToEnum(chosenName) end)
                    if finisherEnum then
                        args[1] = finisherEnum
                        return originalReplicateFromServer(self, action, table.unpack(args, 1, select("#", ...)))
                    end
                end
            end
        end
        return originalReplicateFromServer(self, action, ...)
    end
end
loadConfig()
_G._ChosenFinisher = nil

local function updateHotbarIcon(weaponName)
    pcall(function()
        local eq = equipped[weaponName]
        local skin = eq and eq.Skin
        local img
        if skin and skin.Name and ItemLibrary.ViewModels then
            local info = ItemLibrary.ViewModels[skin.Name]
            if info then img = info.ImageHighResolution or info.Image end
        end
        if not img and ItemLibrary.ViewModels then
            local info = ItemLibrary.ViewModels[weaponName]
            if info then img = info.ImageHighResolution or info.Image end
        end
        if not img then return end
        local fi = player.PlayerGui.MainGui.MainFrame.FighterInterfaces:FindFirstChild(player.Name)
        local hotbar = fi and fi.BottomRight.Container:FindFirstChild("Hotbar")
        local cont = hotbar and hotbar:FindFirstChild("Container")
        local slot = cont and cont:FindFirstChild(weaponName)
        if slot then
            for _, d in ipairs(slot:GetDescendants()) do
                if d:IsA("ImageLabel") and d.Name == "Icon" then d.Image = img end
            end
        end
    end)
end

local function rebuildItemViewModel(it, isHeld)
    local oldVM = rawget(it, "ViewModel")
    if type(oldVM) ~= "table" then return end
    local vmData = rawget(oldVM, "Data")
    if type(vmData) ~= "table" then return end
    local inner = {}
    for _, key in ipairs({"Name", "Skin", "Wrap", "Charm", "ObjectID"}) do
        local okE, enumKey = pcall(function() return it:ToEnum(key) end)
        if okE and enumKey ~= nil and vmData[key] ~= nil then
            inner[enumKey] = vmData[key]
        end
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
    if isHeld then
        task.wait()
        pcall(function() it:Equip() end)
    end
    if oldVM and oldVM ~= newVM then pcall(function() oldVM:Destroy() end) end
    updateHotbarIcon(it.Name)
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
-- 專屬改皮懸浮開關按鈕 (畫面右側隨時可點擊開關改皮介面)
-- ==============================================================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "CosmeticToggleGui"
toggleGui.ResetOnSpawn = false
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() toggleGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not toggleGui.Parent then toggleGui.Parent = player:WaitForChild("PlayerGui") end

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 140, 0, 36)
floatBtn.Position = UDim2.new(1, -150, 0.4, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(22, 20, 34)
floatBtn.BorderSizePixel = 0
floatBtn.Text = "🎨 改皮介面開關"
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Font = Enum.Font.Code
floatBtn.TextSize = 13
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.Parent = toggleGui

local btnStroke = Instance.new("UIStroke", floatBtn)
btnStroke.Color = Color3.fromRGB(100, 65, 165)
btnStroke.Thickness = 1.5
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 建立改皮介面本體
task.spawn(function()
    local COSMETIC_TYPES = {"Skin", "Wrap", "Charm", "Finisher"}
    local function buildWeaponList()
        local items = ItemLibrary.Items or ItemLibrary
        local seen, list = {}, {}
        for _, data in pairs(CosmeticLibrary.Cosmetics) do
            if type(data) == "table" and data.ItemName and not seen[data.ItemName] and not tostring(data.ItemName):find("MISSING") then
                seen[data.ItemName] = true
                local img = "rbxassetid://0"
                local it = items[data.ItemName]
                if it and it.Image then img = it.Image end
                table.insert(list, {Name = data.ItemName, Image = img})
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        return list
    end

    local function getCosmetics(weaponName, cosmeticType)
        local res = {}
        for name, data in pairs(CosmeticLibrary.Cosmetics) do
            if type(data) == "table" and data.Type == cosmeticType then
                if data.ItemName == weaponName or data.ItemName == nil then
                    local n = tostring(name)
                    if not n:find("MISSING") then
                        table.insert(res, {Name = n, Image = data.Image or "rbxassetid://0"})
                    end
                end
            end
        end
        table.sort(res, function(a, b) return a.Name < b.Name end)
        return res
    end

    local LibraryUEL
    pcall(function()
        LibraryUEL = loadstring(game:HttpGet("https://raw.githubusercontent.com/engnyg/UELinoriaLib/main/Library.lua"))()
    end)
    LibraryUEL = LibraryUEL or {}

    local function themeColor(key, fallback)
        local v = LibraryUEL[key]
        if typeof(v) == "Color3" then return v end
        return fallback
    end
    local BG = themeColor("BackgroundColor", Color3.fromRGB(14, 13, 21))
    local PANEL = themeColor("MainColor", Color3.fromRGB(22, 20, 34))
    local OUTLINE = themeColor("OutlineColor", Color3.fromRGB(38, 35, 54))
    local ACCENT = themeColor("AccentColor", Color3.fromRGB(100, 65, 165))
    local TEXT = themeColor("FontColor", Color3.fromRGB(255, 255, 255))
    local CELL = OUTLINE
    local SELBG = Color3.fromRGB(38, 78, 44)
    local SELLINE = Color3.fromRGB(95, 200, 110)
    local UIFONT = (typeof(LibraryUEL.Font) == "EnumItem") and LibraryUEL.Font or Enum.Font.Code

    local function heldWeaponName()
        local name
        pcall(function()
            if not FighterController then return end
            local fighter = FighterController:GetFighter(player)
            if not fighter or not fighter.Items then return end
            for _, item in pairs(fighter.Items) do
                local ok, a = pcall(function() return item:IsActive() end)
                if ok and a then name = tostring(item.Name) break end
            end
        end)
        return name
    end

    local weaponList = buildWeaponList()
    local weaponNames = {}
    for _, w in ipairs(weaponList) do table.insert(weaponNames, w.Name) end

    local selectedWeapon = heldWeaponName() or weaponNames[1]
    local selectedType = "Skin"
    local lastCosmeticName = nil
    local manualWeaponSelect = false
    local lastHeldWeapon = heldWeaponName()
    local renderCosmetics

    local panel = Instance.new("ScreenGui")
    panel.Name = "CosmeticChangerPanel"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panel.IgnoreGuiInset = true
    panel.Enabled = false
    pcall(function() panel.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not panel.Parent then panel.Parent = player:WaitForChild("PlayerGui") end
    _cosmeticGui = panel

    local UIS = game:GetService("UserInputService")
    local RunSvc = game:GetService("RunService")
    local MOUSE_BIND = "CosmeticChangerMouseFree"
    local mouseBound = false
    local function setMouseFree(on)
        if on then
            if mouseBound then return end
            mouseBound = true
            pcall(function()
                RunSvc:BindToRenderStep(MOUSE_BIND, Enum.RenderPriority.Camera.Value + 1, function()
                    UIS.MouseBehavior = Enum.MouseBehavior.Default
                    UIS.MouseIconEnabled = true
                end)
            end)
        else
            if not mouseBound then return end
            mouseBound = false
            pcall(function() RunSvc:UnbindFromRenderStep(MOUSE_BIND) end)
        end
    end

    local function strokeOf(inst, color, thickness)
        local s = Instance.new("UIStroke", inst)
        s.Color = color or OUTLINE
        s.Thickness = thickness or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 540, 0, 744)
    main.Position = UDim2.new(0.5, -270, 0.5, -372)
    main.BackgroundColor3 = BG
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    strokeOf(main, ACCENT, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundColor3 = PANEL
    title.BorderSizePixel = 0
    title.Text = "Cosmetic Changer (點右側按鈕或按 RightShift 開關)"
    title.TextColor3 = TEXT
    title.Font = UIFONT
    title.TextSize = 13
    title.Parent = main
    strokeOf(title, OUTLINE, 1)

    local function makeLabel(text, y)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 16)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = TEXT
        l.TextTransparency = 0.35
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = UIFONT
        l.TextSize = 12
        l.Parent = main
        return l
    end

    local function makeSearch(y)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -20, 0, 24)
        box.Position = UDim2.new(0, 10, 0, y)
        box.BackgroundColor3 = PANEL
        box.BorderSizePixel = 0
        box.PlaceholderText = "search..."
        box.Text = ""
        box.TextColor3 = TEXT
        box.PlaceholderColor3 = Color3.fromRGB(120, 115, 140)
        box.Font = UIFONT
        box.TextSize = 13
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Parent = main
        strokeOf(box, OUTLINE, 1)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 8)
        return box
    end

    local function makeScroll(y, h, cell)
        cell = cell or 76
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, -20, 0, h)
        sf.Position = UDim2.new(0, 10, 0, y)
        sf.BackgroundColor3 = PANEL
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 4
        sf.ScrollBarImageColor3 = ACCENT
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Parent = main
        strokeOf(sf, OUTLINE, 1)
        local grid = Instance.new("UIGridLayout", sf)
        grid.CellSize = UDim2.new(0, cell, 0, cell)
        grid.CellPadding = UDim2.new(0, 8, 0, 8)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", sf)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 8)
        return sf
    end

    local function makeCell(parent, name, image, onClick, cosmeticType)
        local cell = Instance.new("TextButton")
        cell.Size = UDim2.new(0, 76, 0, 76)
        cell.BackgroundColor3 = CELL
        cell.BorderSizePixel = 0
        cell.Text = ""
        cell.AutoButtonColor = true
        cell.Parent = parent
        local st = strokeOf(cell, OUTLINE, 1)

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -4, 1, -16)
        img.Position = UDim2.new(0, 2, 0, 0)
        img.BackgroundTransparency = 1
        img.Image = image or ""
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = cell

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -4, 0, 16)
        nm.Position = UDim2.new(0, 2, 1, -17)
        nm.BackgroundTransparency = 1
        nm.Text = name
        nm.TextColor3 = TEXT
        nm.Font = UIFONT
        nm.TextSize = 11
        nm.TextWrapped = true
        nm.TextTruncate = Enum.TextTruncate.AtEnd
        nm.Parent = cell
        cell.MouseButton1Click:Connect(onClick)
        return cell, st
    end

    makeLabel("weapon filter", 34)
    local weaponSearch = makeSearch(52)
    local weaponScroll = makeScroll(82, 180)

    makeLabel("cosmetic filter", 270)
    local cosmeticSearch = makeSearch(288)
    local cosmeticScroll = makeScroll(318, 180)

    local typeBtn = Instance.new("TextButton")
    typeBtn.Size = UDim2.new(1, -20, 0, 26)
    typeBtn.Position = UDim2.new(0, 10, 0, 506)
    typeBtn.BackgroundColor3 = PANEL
    typeBtn.BorderSizePixel = 0
    typeBtn.Text = "  " .. selectedType
    typeBtn.TextXAlignment = Enum.TextXAlignment.Left
    typeBtn.TextColor3 = TEXT
    typeBtn.Font = UIFONT
    typeBtn.TextSize = 13
    typeBtn.Parent = main
    strokeOf(typeBtn, ACCENT, 1)

    local typeList = Instance.new("Frame")
    typeList.Size = UDim2.new(1, -20, 0, #COSMETIC_TYPES * 24)
    typeList.Position = UDim2.new(0, 10, 0, 532)
    typeList.BackgroundColor3 = PANEL
    typeList.BorderSizePixel = 0
    typeList.Visible = false
    typeList.ZIndex = 50
    typeList.Parent = main
    strokeOf(typeList, ACCENT, 1).ZIndex = 50
    local typeLayout = Instance.new("UIListLayout", typeList)

    for _, t in ipairs(COSMETIC_TYPES) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 24)
        opt.BackgroundColor3 = PANEL
        opt.BorderSizePixel = 0
        opt.Text = t
        opt.TextColor3 = TEXT
        opt.Font = UIFONT
        opt.TextSize = 13
        opt.ZIndex = 51
        opt.Parent = typeList
        opt.MouseButton1Click:Connect(function()
            selectedType = t
            typeBtn.Text = "  " .. t
            typeList.Visible = false
            renderCosmetics(cosmeticSearch.Text)
        end)
    end

    typeBtn.MouseButton1Click:Connect(function()
        typeList.Visible = not typeList.Visible
    end)

    local function styledBtn(text, xs, xo, ws, wo, y)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(ws, wo, 0, 26)
        b.Position = UDim2.new(xs, xo, 0, y)
        b.BackgroundColor3 = PANEL
        b.BorderSizePixel = 0
        b.Text = text
        b.TextColor3 = TEXT
        b.Font = UIFONT
        b.TextSize = 13
        b.Parent = main
        strokeOf(b, OUTLINE, 1)
        return b
    end

    local applyAllBtn = styledBtn("apply selected to all", 0, 10, 1, -20, 596)
    local applyNowBtn = styledBtn("APPLY NOW (reset character)", 0, 10, 1, -20, 628)
    applyNowBtn.TextColor3 = ACCENT

    local resetBtn = styledBtn("reset to defaults", 0, 10, 0.5, -14, 676)
    local closeBtn = styledBtn("close", 0.5, 4, 0.5, -14, 676)
    local unloadBtn = styledBtn("unload cosmetic panel", 0, 10, 1, -20, 708)

    local function weaponIcon(wname, default)
        local eq = equipped[wname]
        if eq and eq.Skin and eq.Skin.Name and ItemLibrary.ViewModels then
            local info = ItemLibrary.ViewModels[eq.Skin.Name]
            if info then return info.ImageHighResolution or info.Image or default end
        end
        return default
    end

    local weaponStrokes = {}
    local function applyWeaponHighlight(name)
        for n, s in pairs(weaponStrokes) do
            local c = s.Parent
            local on = (n == name)
            s.Color = on and SELLINE or OUTLINE
            s.Thickness = on and 2 or 1
            if c then c.BackgroundColor3 = on and SELBG or CELL end
        end
    end

    local function renderWeapons(filter)
        for _, c in ipairs(weaponScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        weaponStrokes = {}
        filter = (filter or ""):lower()
        for _, w in ipairs(weaponList) do
            if filter == "" or w.Name:lower():find(filter, 1, true) then
                local cell, st = makeCell(weaponScroll, w.Name, weaponIcon(w.Name, w.Image), function()
                    selectedWeapon = w.Name
                    manualWeaponSelect = true
                    applyWeaponHighlight(w.Name)
                    renderCosmetics(cosmeticSearch.Text)
                end)
                weaponStrokes[w.Name] = st
                if w.Name == selectedWeapon then
                    st.Color = SELLINE st.Thickness = 2
                    cell.BackgroundColor3 = SELBG
                end
            end
        end
    end

    renderCosmetics = function(filter)
        for _, c in ipairs(cosmeticScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        filter = (filter or ""):lower()
        makeCell(cosmeticScroll, "None", "", function()
            applyCosmetic(selectedWeapon, selectedType, nil)
            renderWeapons(weaponSearch.Text)
        end)
        local list = getCosmetics(selectedWeapon, selectedType)
        makeCell(cosmeticScroll, "Random", "", function()
            if #list > 0 then
                local pick = list[math.random(1, #list)]
                lastCosmeticName = pick.Name
                applyCosmetic(selectedWeapon, selectedType, pick.Name)
                renderWeapons(weaponSearch.Text)
                renderCosmetics(cosmeticSearch.Text)
            end
        end)
        local appliedName
        local eq = equipped[selectedWeapon]
        if eq and eq[selectedType] then appliedName = eq[selectedType].Name end
        for _, cz in ipairs(list) do
            if filter == "" or cz.Name:lower():find(filter, 1, true) then
                local cell, st = makeCell(cosmeticScroll, cz.Name, cz.Image, function()
                    lastCosmeticName = cz.Name
                    applyCosmetic(selectedWeapon, selectedType, cz.Name, {})
                    renderWeapons(weaponSearch.Text)
                    renderCosmetics(cosmeticSearch.Text)
                end, selectedType)
                if cz.Name == appliedName then
                    st.Color = SELLINE st.Thickness = 2
                    cell.BackgroundColor3 = SELBG
                end
            end
        end
    end

    applyAllBtn.MouseButton1Click:Connect(function()
        if not lastCosmeticName then return end
        for _, w in ipairs(weaponList) do
            local found = false
            for _, cz in ipairs(getCosmetics(w.Name, selectedType)) do
                if cz.Name == lastCosmeticName then found = true break end
            end
            if found then
                equipped[w.Name] = equipped[w.Name] or {}
                local cloned = cloneCosmetic(lastCosmeticName, selectedType, {})
                if cloned then equipped[w.Name][selectedType] = cloned end
            end
        end
        saveConfig()
        renderCosmetics(cosmeticSearch.Text)
    end)

    applyNowBtn.MouseButton1Click:Connect(function() resetCharacter() end)
    resetBtn.MouseButton1Click:Connect(function()
        for w in pairs(equipped) do equipped[w] = nil end
        saveConfig()
        if selectedWeapon then refreshWeapon(selectedWeapon) end
        renderCosmetics(cosmeticSearch.Text)
    end)
    
    local function togglePanel()
        panel.Enabled = not panel.Enabled
        setMouseFree(panel.Enabled)
    end

    closeBtn.MouseButton1Click:Connect(togglePanel)
    floatBtn.MouseButton1Click:Connect(togglePanel)

    unloadBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
        toggleGui:Destroy()
    end)

    weaponSearch:GetPropertyChangedSignal("Text"):Connect(function() renderWeapons(weaponSearch.Text) end)
    cosmeticSearch:GetPropertyChangedSignal("Text"):Connect(function() renderCosmetics(cosmeticSearch.Text) end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            togglePanel()
        end
    end)

    renderWeapons("")
    renderCosmetics("")
    print("[Cosmetic Changer] Loaded with Button & RightShift support.")
end)


-- ==============================================================================
-- PART 2: 戰鬥核心面板 (平滑鎖頭、2D透視、FOV範圍、虛空亂飛) (由 LeftShift 控制)
-- ==============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local CombatWindow = Library:CreateWindow({
    Title = 'WETQA面板 | discord.gg/GbrS6eTsfq',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local CombatTabs = {
    Combat = CombatWindow:AddTab('combat'),
    Visuals = CombatWindow:AddTab('visuals'),
    Character = CombatWindow:AddTab('character'),
    Misc = CombatWindow:AddTab('misc'),
    Settings = CombatWindow:AddTab('settings')
}

local AimGroup = CombatTabs.Combat:AddLeftGroupbox('Aim, Smooth Lock & Silent Aim (平滑鎖頭)')
local WeaponGroup = CombatTabs.Combat:AddRightGroupbox('Weapon & Wallbang')

local ESPGroup = CombatTabs.Visuals:AddLeftGroupbox('2D Box ESP (標準2D方格透視)')
local FOVVisualGroup = CombatTabs.Visuals:AddRightGroupbox('FOV Visuals & Rotation (FOV範圍與顏色旋轉)')
local HandsGroup = CombatTabs.Visuals:AddRightGroupbox('Viewmodel Settings')

local MoveGroup = CombatTabs.Character:AddLeftGroupbox('Movement & Void Flight (虛空亂飛)')
local ChatSystemGroup = CombatTabs.Misc:AddLeftGroupbox('Universal Chat System (群聊與洗版)')
local NotifyGroup = CombatTabs.Misc:AddRightGroupbox('Notifications & Alerts')
local SettingsGroup = CombatTabs.Settings:AddLeftGroupbox('UI Settings & Keybinds')

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
NotifyGroup:AddButton('Show Welcome Alert', function() Library:Notify("究極大合集載入成功！", 4) end)

SettingsGroup:AddLabel('Menu Binding'):AddKeyPicker('MenuKey', { Default = 'LeftShift', NoUI = true, Text = 'Toggle UI' })
Library:Notify("究極大合集載入完畢！\n• 戰鬥面板: 按 LeftShift 開關\n• 改皮介面: 按右側「🎨 改皮介面開關」按鈕或 RightShift", 6)

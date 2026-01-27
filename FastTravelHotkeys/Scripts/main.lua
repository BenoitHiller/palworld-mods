local UEHelpers = require("UEHelpers")
---@type UPalLocationManager
local LocationManager = CreateInvalidObject()
local keybindsRegistered = false

---@param left UPalLocationPoint
---@param right UPalLocationPoint
---@return boolean
local function comparePoints(left, right)
    local leftCoord = left:GetLocation()
    local rightCoord = right:GetLocation()
    -- Note: X is N/S Y is E/W
    if leftCoord.X == rightCoord.X then
        return leftCoord.Y < rightCoord.Y
    else
        return leftCoord.X > rightCoord.X
    end
end

---@return UPalLocationPoint[]
local function GetBaseLocations()
    local locationMap = LocationManager:GetLocationMap()
    local bases = {}

    for _, locationRef in pairs(locationMap) do
        ---@type UPalLocationBase
        local location = locationRef:get()
        local locationType = location:GetType()
        if locationType == 4 and location:IsShowInMap() then
            local point = location:LocationPoint()
            if point:IsEnableFastTravel() then
                bases[#bases + 1] = point
            end
        end
    end
    table.sort(bases, comparePoints)
    return bases
end

local function GoToBase(index)
    local bases = GetBaseLocations()
    local base = bases[index]
    if base ~= nil and base:IsValid() then
        base:InvokeFastTravel()
        return true
    end

    return false
end

local function BaseCallbackForIndex(index)
    return function()
        if not LocationManager:IsValid() then
            return
        end

        ---@type UWBP_Map_Base_C
        local mapUI = FindFirstOf("WBP_Map_Base_C")
        if mapUI ~= nil and mapUI:IsValid()
            and mapUI.bIsActive and mapUI["Can Fast Travel"] then
            if GoToBase(index) then
              mapUI:CloseMap()
            end
        end
    end
end

---@param PlayerController APlayerController
local function HandleModLogic(PlayerController)
    ---@type UPalUtility
    local PalUtility = StaticFindObject("/Script/Pal.Default__PalUtility")
    local worldContext = UEHelpers:GetWorldContextObject()

    LocationManager = PalUtility:GetLocationManager(worldContext)

    if not keybindsRegistered then
        for i = 1,9,1 do
            RegisterKeyBind(Key.ZERO + i, BaseCallbackForIndex(i))
        end
        RegisterKeyBind(Key.ZERO, BaseCallbackForIndex(10))

        keybindsRegistered = true
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", HandleModLogic)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local EnumList = require(ReplicatedStorage.Packages["enum-list"])
local DataStoreModule = require(ReplicatedStorage.Packages.suphisdatastoremodule)
local Concur = require(ReplicatedStorage.Packages.concur)


local PlayerDataService = Knit.CreateService{
    Name = "PlayerDataService",
    Client = {}
}
local DataHandlerEnumToModuleMap  = {}

local function onPlayerAdded(player)
    
end

local function onPlayerRemoved(player)
    
end

function PlayerDataService:KnitInit()
    Players.onPlayerAdded:Connect(onPlayerAdded)
    Players.onPlayerRemoved:Connect(onPlayerRemoved)
    for _, player in pairs(Players:GetPlayers()) do
        Concur.spawn(onPlayerAdded, player)
    end
    --#region Data Handlers Mapping
    local enumData = {}
    local e = {}
    for _, module : ModuleScript in script.DataHandlers:GetChildren() do
        local dataHandler = require(module)
        e[module.Name] = dataHandler
        table.insert(enumData, module.Name)
    end
    self.DataHandlers = EnumList.new("DataHandlers", enumData)
    local enumItems = self.DataHandlers:GetEnumItems()
    for _, enumItem in enumItems do
        DataHandlerEnumToModuleMap[enumItem] = e[enumItem.Name]
    end
    --#endregion
end

function PlayerDataService:KnitStart()
    
end

function PlayerDataService:BindDataHandlerToGetSignal(enumItem, signal)
    return DataHandlerEnumToModuleMap[enumItem]:BindToGetSignal(signal)
end

function PlayerDataService:BindDataHandlerToSetSignal(enumItem, signal)
    return DataHandlerEnumToModuleMap[enumItem]:BindToSetSignal(signal)
end

function PlayerDataService:BindToDataHandlerOnUpdateSignal(enumItem, callback)
    return DataHandlerEnumToModuleMap[enumItem]:BindFunctionToOnUpdate(callback)
end
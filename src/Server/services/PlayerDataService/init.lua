local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local EnumList = require(ReplicatedStorage.Packages["enum-list"])
local DataStoreModule = require(ReplicatedStorage.Packages.suphisdatastoremodule)
local Concur = require(ReplicatedStorage.Packages.concur)

local PlayerDataTemplate = require(script.PlayerDataTemplate)
local PlayerDataService = Knit.CreateService{
    Name = "PlayerDataService",
    Client = {}
}
local DataHandlerEnumToModuleMap  = {}

--#region DataStore Initializers and Destructors
local function StateChanged(state, dataStore)
    while dataStore.State == false do -- Keep trying to re-open if the state is closed
        if dataStore:Open(PlayerDataTemplate) ~= "Success" then 
            task.wait(6) 
        end
    end
end

local function onPlayerAdded(player)
    local dataStore = DataStoreModule.new("PlayerDataStore__", player.UserId)
    dataStore.StateChanged:Connect(StateChanged)
    StateChanged(dataStore.State, dataStore)
end

local function onPlayerRemoved(player)
    local dataStore = DataStoreModule.find("Player", player.UserId)
    if dataStore ~= nil then 
        dataStore:Destroy() -- If the player leaves datastore object is destroyed allowing the retry loop to stop
    end 
end
--#endregion

function PlayerDataService:KnitInit()
    --#region Player Events Binders
    Players.onPlayerAdded:Connect(onPlayerAdded)
    Players.onPlayerRemoved:Connect(onPlayerRemoved)
    for _, player in pairs(Players:GetPlayers()) do
        Concur.spawn(onPlayerAdded, player)
    end
    --#endregion
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
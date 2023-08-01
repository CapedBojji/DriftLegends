local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.knit)
local Concur = require(ReplicatedStorage.Packages.concur)
local Signal = require(ReplicatedStorage.Packages.signal)


local PlayerLoaderService = Knit.CreateService{
    Name = "PlayerLoaderService",
    Client = {}
}

-- Data Signals
local GetPetsDataSignal = Signal.new()
local SetPetsDataSignal = Signal.new()

local GetVehicleDataSignal = Signal.new()
local SetVehicleDataSignal = Signal.new()

local GetCurrentVehicleDataSignal = Signal.new()
local SetCurrentVehicleDataSignal = Signal.new()


local function onPlayerAdded(player)

end

local function onPlayerRemoved(player)

end
function PlayerLoaderService:KnitInit()

end

function PlayerLoaderService:KnitStart()
    -- Bind Signals to PlayerDataService
    -- TODO Add on update signals
    local PlayerDataService = Knit.GetService("PlayerDataService")
    PlayerDataService:BindDataHandlerToGetSignal(PlayerDataService.DataHandlers.Pets, GetPetsDataSignal)
    PlayerDataService:BindDataHandlerToSetSignal(PlayerDataService.DataHandlers.Pets, SetPetsDataSignal)

    PlayerDataService:BindDataHandlerToGetSignal(PlayerDataService.DataHandlers.Vehicle, GetVehicleDataSignal)
    PlayerDataService:BindDataHandlerToSetSignal(PlayerDataService.DataHandlers.Vehicle, SetVehicleDataSignal)

    PlayerDataService:BindDataHandlerToGetSignal(PlayerDataService.DataHandlers.CurrentVehicle, GetCurrentVehicleDataSignal)
    PlayerDataService:BindDataHandlerToSetSignal(PlayerDataService.DataHandlers.CurrentVehicle, SetCurrentVehicleDataSignal)

    -- Bind to Player Events
    Players.OnPlayerAdded:Connect(onPlayerAdded)
    Players.OnPlayerRemoved:Connect(onPlayerRemoved)
    for _, player in pairs(Players:GetPlayers()) do
        Concur.spawn(onPlayerAdded, player)
    end


end

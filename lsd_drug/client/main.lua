local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local PlayerData = {}
local HasAlreadyEnteredMarker, LastZone = false, nil
local CurrentAction, CurrentActionMsg
local CurrentActionData = {}
local rc = false
local treating = false
local selling = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local coords = GetEntityCoords(PlayerPedId())
        local isInMarker = false
        local currentZone
        for k, v in pairs(Config.Zones) do
            if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
                isInMarker = true
                currentZone = k
            end
        end
        if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
            HasAlreadyEnteredMarker = true
            LastZone = currentZone
            TriggerEvent('lsd_drug:hasEnteredMarker', currentZone)
        end
        if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('lsd_drug:hasExitedMarker')
        end
    end
end)

AddEventHandler('lsd_drug:hasEnteredMarker', function(zone)
    if zone == 'Recolte' then
        CurrentAction = 'recolte'
        CurrentActionMsg = _U('recolte')
        CurrentActionData = {}
        ESX.TriggerServerCallback('lsd_drug:inMarker', function(cb)
        end)
    elseif zone == 'Traitement' then
        CurrentAction = 'traitement'
        CurrentActionMsg = _U('traitement')
        CurrentActionData = {}
        ESX.TriggerServerCallback('lsd_drug:inMarker', function(cb)
        end)
    elseif zone == 'Vente' then
        CurrentAction = 'vente'
        CurrentActionMsg = _U('vente')
        CurrentActionData = {}
        ESX.TriggerServerCallback('lsd_drug:inMarker', function(cb)
        end)
    end
end)

AddEventHandler('lsd_drug:hasExitedMarker', function()
    if CurrentAction == 'recolte' then
        ESX.TriggerServerCallback('lsd_drug:outOfMarker', function(cb)
            if cb then
                rc = false
            end
        end)
    elseif CurrentAction == 'traitement' then
        ESX.TriggerServerCallback('lsd_drug:outOfMarker', function(cb)
            if cb then
                treating = false
            end
        end)
    elseif CurrentAction == 'vente' then
        ESX.TriggerServerCallback('lsd_drug:outOfMarker', function(cb)
            if cb then
                selling = false
            end
        end)
    end
    CurrentActionMsg = {}
    CurrentAction = nil
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

--[[-- Draw Marker
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        for _, v in pairs(Config.Zones) do
            if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, nil, nil, false)
            end
        end
    end
end)]]

-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if not selling and CurrentAction == 'vente' then
            ESX.ShowHelpNotification(CurrentActionMsg)
            if IsControlJustReleased(0, Keys['E']) then
                ESX.TriggerServerCallback('lsd_drug:startVente', function(back)
                    if back then
                        selling = true
                    else
                        selling = false
                    end
                end)
            end
        elseif not rc and CurrentAction == 'recolte' then
            ESX.ShowHelpNotification(CurrentActionMsg)
            if IsControlJustReleased(0, Keys['E']) then
                ESX.TriggerServerCallback('lsd_drug:startRecolte', function(back)
                    if back then
                        rc = true
                    else
                        rc = false
                    end
                end)
            end
        elseif not treating and CurrentAction == 'traitement' then
            ESX.ShowHelpNotification(CurrentActionMsg)
            if IsControlJustReleased(0, Keys['E']) then
                ESX.TriggerServerCallback('lsd_drug:startTraitement', function(back)
                    if back then
                        treating = true
                    else
                        treating = false
                    end
                end)
            end
        end
    end
end)

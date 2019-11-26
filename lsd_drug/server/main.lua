ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local isOutMarker = {}
local rcINProg, treatINProg, sellINProg = {}, {}, {}
--
--
--

AddEventHandler('lsd_drug:rc', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    while not isOutMarker[_source] do
        rcINProg[_source] = true
        Citizen.Wait(Config.Zones.Recolte.ItemTime)
        local Quantity = xPlayer.getInventoryItem(Config.Zones.Recolte.ItemRequires).count

        if not isOutMarker[_source] then
            if Quantity == Config.Zones.Recolte.ItemMax then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez plus de place dans votre inventaire.')
                rcINProg[_source] = false
                return
            else
                xPlayer.addInventoryItem(Config.Zones.Recolte.ItemDb_name, Config.Zones.Recolte.ItemAdd)
            end
        end
    end
    rcINProg[_source] = false
end)


AddEventHandler('lsd_drug:treat', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    while not isOutMarker[_source] do
        treatINProg[_source] = true
        Citizen.Wait(Config.Zones.Recolte.ItemTime)
        local QuantityErgot = xPlayer.getInventoryItem(Config.Zones.Recolte.ItemRequires).count
        local QuantityLSD = xPlayer.getInventoryItem(Config.Zones.Traitement.ItemRequires).count

        if not isOutMarker[_source] then
            if QuantityLSD >= 100 then
                TriggerClientEvent('esx:showNotification', _source, '~r~Votre inventaire est plein.')
                treatINProg[_source] = false
                return
            elseif QuantityErgot <= 0 then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez plus d\'ergot a traiter.')
                treatINProg[_source] = false
                return
            else
                xPlayer.addInventoryItem(Config.Zones.Traitement.ItemDb_name, Config.Zones.Traitement.ItemAdd)
                xPlayer.removeInventoryItem(Config.Zones.Recolte.ItemDb_name, Config.Zones.Recolte.ItemRemove)
            end
        end
    end
    treatINProg[_source] = false
end)


AddEventHandler('lsd_drug:sell', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    while not isOutMarker[_source] do
        sellINProg[_source] = true
        Citizen.Wait(Config.Zones.Vente.ItemTime)
        local Quantity = xPlayer.getInventoryItem(Config.Zones.Vente.ItemRequires).count

        if not isOutMarker[_source] then
            if Quantity < Config.Zones.Vente.ItemRemove then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez plus de ' .. Config.Zones.Vente.ItemRequires_name .. ' à vendre.')
                sellINProg[_source] = false
                return
            else
                local item = Config.Zones.Vente.ItemRequires

                xPlayer.addAccountMoney('black_money', Config.Zones.Vente.ItemPrice)
                xPlayer.removeInventoryItem(item, Config.Zones.Vente.ItemRemove)
            end
        end
    end
    sellINProg[_source] = false
end)


ESX.RegisterServerCallback('lsd_drug:startRecolte', function(source, cb)
    local _source = source
    local cops = 0
    local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops > 0 and not isOutMarker[_source] and not rcINProg[_source] then
        TriggerClientEvent('esx:showNotification', _source, '~g~Récolte ~w~en cours...')
        TriggerEvent('lsd_drug:rc', _source)
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', _source, 'Vous ne pouvez pas récolter pour le moment')
        cb(false)
    end
end)


ESX.RegisterServerCallback('lsd_drug:startTraitement', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local _source = source

    local cops = 0
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops > 0 and not isOutMarker[_source] and not treatINProg[_source] then
        TriggerClientEvent('esx:showNotification', _source, '~g~Traitement ~w~en cours...')
        TriggerEvent('lsd_drug:treat', _source)
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', _source, 'Vous ne pouvez pas traiter pour le moment')
        cb(false)
    end
end)

ESX.RegisterServerCallback('lsd_drug:startVente', function(source, cb)
    local _source = source
    local xPlayers = ESX.GetPlayers()
    local cops = 0

    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops > 1 and not isOutMarker[_source] and not sellINProg[_source] then
        TriggerClientEvent('esx:showNotification', _source, '~g~Vente ~w~en cours...')
        TriggerEvent('lsd_drug:sell', _source)
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', _source, 'Vous ne pouvez pas vendre pour le moment')
        cb(false)
    end
end)

ESX.RegisterServerCallback('lsd_drug:outOfMarker', function(source, cb)
    local _source = source
    isOutMarker[_source] = true
    cb(true)
end)

ESX.RegisterServerCallback('lsd_drug:inMarker', function(source, cb)
    local _source = source
    isOutMarker[_source] = false
    cb(true)
end)
RegisterNetEvent('qb-printer:client:UseDocument', function(ItemData)
    local DocumentUrl = ItemData.info.url ~= nil and ItemData.info.url or false
    exports['rpemotes']:EmoteCommandStart('clipboard',nil)
    SendNUIMessage({
        action = "open",
        url = DocumentUrl
    })
    SetNuiFocus(true, false)
end)

RegisterNetEvent('qb-printer:client:SpawnPrinter', function()
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local forward   = GetEntityForwardVector(playerPed)
    local x, y, z   = table.unpack(coords + forward * 1.0)

    local model = `prop_printer_01`
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(1)
    end
    local obj = CreateObject(model, x, y, z, true, false, true)
    PlaceObjectOnGroundProperly(obj)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(obj)
end)



CreateThread(function()
    for k,v in pairs(Config.PrinterLocations) do
        if v.spawn then
        SpawnPresetPrinter(v.location.x,v.location.y,v.location.z,v.heading,v.size)
     
        --print("Printer Spawned: " .. k)
        end
        exports['qb-target']:AddBoxZone(k, v.location, 1.0, 1.5, {
            name = k,
            heading = v.heading,
            minZ = v.location.z - 1,
            maxZ = v.location.z + 1,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'qb-printer:printer',
                    icon = "fa fa-print	",
                    label = Lang:t('info.use_printer'),
                }
            },
            distance = 1.5
        })
        --print("Printer Target: " .. k)
    end
end)


function SpawnPresetPrinter(x,y,z,heading,size)
    local model = `prop_printer_01`

    if size == 1 then 
        model =  `v_res_printer`
    elseif size == 2 then 
        model = `prop_printer_02`
    elseif size == 3 then
        model = `proper_printer_01`
    elseif size == 4 then
        model = `prop_copier_01`
    end

    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(1)
    end
    local obj = CreateObject(model, x, y, z, true, false, true)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)
    --SetModelAsNoLongerNeeded(model)
    --SetEntityAsMissionEntity(obj)
end
-- NUI

RegisterNUICallback('SaveDocument', function(data, cb)
    if data.url then
        TriggerServerEvent('qb-printer:server:SaveDocument', data.url, data.name)
    end
    cb('ok')
end)

RegisterNUICallback('CloseDocument', function(_, cb)
    SetNuiFocus(false, false)
    exports['rpemotes']:EmoteCancel()
    cb('ok')
end)

-- Command

RegisterCommand('useprinter', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local PrinterObject = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.5, `prop_printer_01`, false, false, false)
    if PrinterObject ~= 0 then
        SendNUIMessage({
            action = "start"
        })
        SetNuiFocus(true, true)
    end
end)
RegisterNetEvent('qb-printer:printer',function()
    SendNUIMessage({
        action = "start"
    })
    SetNuiFocus(true, true)
end)

if Config.UseTarget then
    --[[CreateThread(function()
        exports['qb-target']:AddTargetModel("prop_printer_01", {
            options = {
                {
                    event = 'qb-printer:printer',
                    type = 'client',
                    icon = "fa fa-print	",
                    label = Lang:t('info.use_printer'),
                },
            },
            distance = 1.5,
        })
    end)]]
end

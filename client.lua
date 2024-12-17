lib.locale()

RegisterNUICallback('createReport', function(data, cb)
    local category = data.category
    local message = data.message

    local success, responseMessage = lib.callback.await('d-reports:createReport', false, category, message)

    if success then
        cb({ ok = true })
    else
        cb({ ok = false, error = responseMessage or "Error while trying to send report." })
    end
end)


RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('reportsystem:updateReports')
AddEventHandler('reportsystem:updateReports', function(reportList)
    SendNUIMessage({
        action = 'updateReports',
        reports = reportList
    })
end)


RegisterCommand(Config.SendReportCommand, function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openPlayer" })
end)

RegisterNetEvent('d-reports:openAdminReport', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openAdmin" })
    local success, reports = lib.callback.await('d-reports:requestActiveReports', false)
    if success then
        TriggerEvent('reportsystem:updateReports', reports)
    else
        lib.notify({
            title = locale('title'),
            description = locale('no_reports'),
            type = 'success'
        })
    end
end)

RegisterNUICallback('gotoPlayer', function(data, cb)
    local playerId = data.playerId
    local success = lib.callback.await('d-reports:goto', false, playerId)
    if success then
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    local playerId = data.playerId
    local success = lib.callback.await('d-reports:bring', false, playerId)
    if success then
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNetEvent('d-reports:client:teleport')
AddEventHandler('d-reports:client:teleport', function(coords, targetPlayerId, playerName)
    local playerPed = PlayerPedId() 
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(playerPed) do
        Citizen.Wait(0)
    end
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
end)


RegisterNUICallback('closeReport', function(data, cb)
    local reportId = tonumber(data.reportId)

    if reportId then
        local success, message = lib.callback.await('d-reports:closeReport', false, reportId)

        if success then
            SetNuiFocus(false, false)
            cb({ success = true })
        else
            cb({ success = false, error = message or "Error occured." })
        end
    else
        cb({ success = false, error = "Invalid report id." })
    end
end)

RegisterNUICallback('takeReport', function(data, cb)
    local reportId = tonumber(data.reportId)

    if reportId then
        local success, message = lib.callback.await('d-reports:takeReport', false, reportId)

        if success then
            cb({ success = true })
        else
            cb({ success = false, error = message or "Error occured." })
        end
    else
        cb({ success = false, error = "Invalid report id." })
    end
end)


RegisterNetEvent('showAdvancedNotification')
AddEventHandler('showAdvancedNotification', function(title, message, type, duration)
    SendNUIMessage({
        type = 'showNotification',
        title = title,
        message = message,
        notificationType = type or 'info',
        duration = duration or 5000 
    })
end)
lib.locale ()

function isAdmin(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        for _, group in ipairs(Config.Groups) do
            if playerGroup == group then
                return true
            end
        end
    end

    return false
end


lib.callback.register('d-reports:createReport', function(source, category, message)
    local playerId = source

    if playerId and playerId > 0 then
        local playerName = GetPlayerName(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)

        if playerName and xPlayer then
            local insertId = MySQL.insert.await('INSERT INTO admin_reports (sender_name, category, message, player_id) VALUES (?, ?, ?, ?)', {
                playerName, category, message, playerId
            })

            if insertId then
                local logMessage = string.format(
                    "**Report created**\n**Player:** %s\n**Category:** %s\n**Message:** %s", 
                    playerName, category, message
                )
                SendToDiscord(
                    Config.Webhook, 
                    'Reports', 
                    logMessage, 
                    65280
                )
                NotifyAdmins()
                return true, locale('new_report')
            else
                return false, locale('report_sendind_error')
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = locale('title'),
                description = locale('no_player_found'),
                type = 'warning'
            })
            return false, locale('no_player_found')
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('source_error'),
            type = 'error'
        })
        return false, locale('source_error')
    end
end)


lib.callback.register('d-reports:requestActiveReports', function(source)
    local src = source
    local reports = MySQL.query.await('SELECT * FROM admin_reports')
    if reports and #reports > 0 then
        return true, reports
    else
        return false, locale('no_reports')
    end
end)

lib.callback.register('d-reports:takeReport', function(source, reportId)
    local src = source
    local adminName = GetPlayerName(src)
    local adminLicense = GetPlayerIdentifier(src, 0)

    reportId = tonumber(reportId)
    if not reportId then
        TriggerClientEvent('lib:notify', src, {
            title = locale('title'),
            description = locale('no_report'),
            type = "warning"
        })
        return false, locale('no_report')
    end
    local rowsChanged = MySQL.update.await('UPDATE admin_reports SET admin_name = ? WHERE id = ?', { adminName, reportId })

    if rowsChanged > 0 then
            local existingAdmin = MySQL.query.await('SELECT * FROM admin_resolved_reports WHERE admin_license = ?', { adminLicense })

            if existingAdmin and #existingAdmin > 0 then
                MySQL.update.await('UPDATE admin_resolved_reports SET resolved_reports = resolved_reports + 1 WHERE admin_license = ?', { adminLicense })
            else
                MySQL.insert.await('INSERT INTO admin_resolved_reports (admin_name, admin_license, resolved_reports) VALUES (?, ?, ?)', {
                    adminName, adminLicense, 1
                })
            end

            local logMessage = string.format("**Report Taken**\n**Admin:** %s\n**Report ID:** %d", adminName, reportId, adminLicense)
            SendToDiscord(Config.Webhook, 'Reports', logMessage, 65280) 


            TriggerClientEvent('ox_lib:notify', src, {
                title = locale('title'),
                description = locale('report_taken'),
                type = 'success'
            })
        local reports = MySQL.query.await('SELECT * FROM admin_reports')
        return true, locale('report_taken')
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('no_report'),
            type = 'warning'
        })
        return false, locale('no_report')
    end
end)

lib.callback.register('d-reports:closeReport', function(source, reportId)
    local src = source
    reportId = tonumber(reportId)
    if not reportId then
        return false, locale('no_report')
    end
    local rowsChanged = MySQL.update.await('DELETE FROM admin_reports WHERE id = ?', { reportId })
    if rowsChanged > 0 then 

        local logMessage = string.format("**Report Closed**\n**Report id:** %s\n**Closed By:** %s", reportId, GetPlayerName(src)) 
        SendToDiscord(Config.Webhook,'Reports',logMessage,65280)


        local reports = MySQL.query.await('SELECT * FROM admin_reports WHERE admin_name = "No admin"')
        TriggerClientEvent('reportsystem:updateReports', src, reports)
        return true, locale('report_concluded')
    else
        return false, locale('no_report')
    end
end)

lib.callback.register('d-reports:goto', function(source, playerId)
    playerId = tonumber(playerId)
    if not playerId or not GetPlayerName(playerId) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('title'),
            description = locale('no_player_found'),
            type = 'warning'
        })
        return false
    end
    local targetPed = GetPlayerPed(playerId)
    if not targetPed or not DoesEntityExist(targetPed) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('title'),
            description = locale('no_player_found'),
            type = 'warning'
        })
        return false
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
    local playerName = GetPlayerName(playerId)
    local adminName = GetPlayerName(source)
    TriggerClientEvent('d-reports:client:teleport', source, targetCoords)

    TriggerClientEvent('ox_lib:notify', source, {
        title = locale('title'),
        description = locale('goto_message', playerName),
        type = 'success'
    })
    TriggerClientEvent('ox_lib:notify', playerId, {
        title = locale('title'),
        description = locale('goto_message_player', adminName),
        type = 'success'
    })
    local logMessage = string.format("**Admin:** %s\n**Teleported To:** %s (ID: %d)", adminName, playerName, playerId)
    SendToDiscord(Config.Webhook, 'Admin Actions', logMessage, 65280)


    return true
end)

lib.callback.register('d-reports:bring', function(sourcePlayer, playerId)
    playerId = tonumber(playerId)
    if not playerId or not GetPlayerName(playerId) then
        TriggerClientEvent('ox_lib:notify', sourcePlayer, {
            title = locale('title'),
            description = locale('no_player_found'),
            type = 'warning'
        })
        return false
    end
    local targetPed = GetPlayerPed(playerId)
    if not targetPed or not DoesEntityExist(targetPed) then
        TriggerClientEvent('ox_lib:notify', sourcePlayer, {
            title = locale('title'),
            description = locale('no_player_found'),
            type = 'warning'
        })
        return false
    end

    local playerId = tonumber(playerId)
    local adminCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
    local adminName = GetPlayerName(sourcePlayer)
    local targetName = GetPlayerName(playerId)
    TriggerClientEvent('d-reports:client:teleport', playerId, adminCoords)
    TriggerClientEvent('ox_lib:notify', sourcePlayer, {
        title = locale('title'),
        description = locale('brought_message', targetName),
        type = 'success'
    })
    TriggerClientEvent('ox_lib:notify', playerId, {
        title = locale('title'),
        description = locale('brought_message_player', adminName),
        type = 'success'
    })
    local message = string.format("%s je doveo igrača %s (ID: %d) do sebe", adminName, targetName, playerId)
        
        local logMessage = string.format("**Bring Command**\n**Admin:** %s\n**Brought Player:** %s (ID: %d)", adminName, targetName, playerId)
        SendToDiscord(Config.Webhook, 'Admin Actions', logMessage, 65280)
    
    return true
end)

RegisterCommand(Config.AdminStatsCommand, function(source, args)
    local src = source
    local targetId = tonumber(args[1])

    if not isAdmin(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('not_authorized'),
            type = 'error'
        })
        return
    end

    if not targetId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('player_id_required'),
            type = 'warning'
        })
        return
    end

    local targetLicense = GetPlayerIdentifier(targetId, 0)

    if not targetLicense then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('no_player_found'),
            type = 'error'
        })
        return
    end

    MySQL.query('SELECT admin_name, resolved_reports FROM admin_resolved_reports WHERE admin_license = ?', { targetLicense }, function(results)
        if results and #results > 0 then
            local row = results[1]
            TriggerClientEvent('ox_lib:notify', src, {
                title = locale('title'),
                description = locale('resolved_reports', row.admin_name, row.resolved_reports),
                type = 'info',
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = locale('title'),
                description = locale('no_data_found'),
                type = 'warning'
            })
        end
    end)
end)

RegisterCommand(Config.OpenAdminReportsComamnd, function(source)
    local src = source

    if not isAdmin(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('not_authorized'),
            type = 'warning'
        })
        return
    end

    TriggerClientEvent('d-reports:openAdminReport', src)
end)

function NotifyAdmins()
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local playerGroup = xPlayer.getGroup()
        for _, group in ipairs(Config.Groups) do
            if playerGroup == group then
                    TriggerClientEvent('ox_lib:notify', playerId, {
                        title = locale('title'),
                        description = locale('notify_admin'),
                        type = 'info',
                    })
            end
        end
    end
end


function SendToDiscord(webhook, title, logMessage, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = logMessage,
            ["color"] = color, 
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S"), 
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Djonza reports", 
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end
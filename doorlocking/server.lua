local doorStates = {}
local doorOwners = {}

RegisterNetEvent('doorlock:updateState', function(doorModel, doorCoords, isLocked)
    local src = source
    local doorKey = string.format('%s_%.2f_%.2f_%.2f', doorModel, doorCoords.x, doorCoords.y, doorCoords.z)

    doorStates[doorKey] = {
        model = doorModel,
        coords = doorCoords,
        locked = isLocked
    }

    if isLocked then
        doorOwners[doorKey] = src
    else
        doorOwners[doorKey] = nil
    end

    TriggerClientEvent('doorlock:setState', -1, doorModel, doorCoords, isLocked)
end)

RegisterNetEvent('doorlock:tryUnlock', function(doorModel, doorCoords)
    local src = source
    local doorKey = string.format('%s_%.2f_%.2f_%.2f', doorModel, doorCoords.x, doorCoords.y, doorCoords.z)
    local owner = doorOwners[doorKey]

    if owner and owner ~= src then
        TriggerClientEvent('ox:showNotification', src, {
            description = 'You are not the owner of this lock. Try forcing it open.',
            type = 'error'
        })
        return
    end

    doorStates[doorKey] = {
        model = doorModel,
        coords = doorCoords,
        locked = false
    }
    doorOwners[doorKey] = nil
    TriggerClientEvent('doorlock:setState', -1, doorModel, doorCoords, false)
end)

RegisterNetEvent('doorlock:forceOpen', function(doorModel, doorCoords)
    local doorKey = string.format('%s_%.2f_%.2f_%.2f', doorModel, doorCoords.x, doorCoords.y, doorCoords.z)
    doorStates[doorKey] = {
        model = doorModel,
        coords = doorCoords,
        locked = false
    }
    doorOwners[doorKey] = nil
    TriggerClientEvent('doorlock:setState', -1, doorModel, doorCoords, false)
end)

AddEventHandler('playerConnecting', function()
    local src = source
    TriggerClientEvent('doorlock:initialize', src, doorStates)
end)

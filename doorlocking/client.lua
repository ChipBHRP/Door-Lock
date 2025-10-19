local isForcingDoor = false
local forceDoorTime = 15000
local doorCache = {}
local DOOR_RANGE = 50.0

if not Config then 
    print("^1[DOORLOCK] ERROR: Config table is not defined in the client's scope. Check resource manifest.^7") 
    Config = { DoorModels = {} }
end

function RotAnglesToVec(rotation)
    local z = math.rad(rotation.z)
    local x = math.rad(rotation.x)
    local num = math.abs(math.cos(x))
    return {x = -math.sin(z) * num, y = math.cos(z) * num, z = math.sin(x)} 
end

function GetDoorInFront()
    local playerPed = PlayerPedId()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local forwardVector = RotAnglesToVec(camRot)
    local distance = 3.0
    local rayEnd = {
        x = camCoords.x + (forwardVector.x * distance),
        y = camCoords.y + (forwardVector.y * distance),
        z = camCoords.z + (forwardVector.z * distance)
    }
    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, playerPed, 0)
    local _, hit, _, _, hitEntity = GetShapeTestResult(rayHandle)
    if hit and DoesEntityExist(hitEntity) and IsEntityAnObject(hitEntity) then
        local model = GetEntityModel(hitEntity)
        if Config.DoorModels[model] then
            return hitEntity, GetEntityCoords(hitEntity), model 
        end
    end
    return nil, nil, nil
end

local function GenerateDoorKey(modelHash, coords)
    return string.format('%s_%.2f_%.2f_%.2f', modelHash, coords.x, coords.y, coords.z)
end

local function SetDoorStateNative(modelHash, coords, isLocked)
    local door = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, modelHash, false, false, false)
    if not DoesEntityExist(door) then return end
    local entityCoords = GetEntityCoords(door)
    local doorKey = GenerateDoorKey(modelHash, entityCoords)
    if not doorCache[doorKey] then
        AddDoorToSystem(modelHash, entityCoords.x, entityCoords.y, entityCoords.z, false, false, false)
        doorCache[doorKey] = { model = modelHash, coords = entityCoords, locked = isLocked }
    end
    local state = isLocked and 1 or 0
    DoorSystemSetDoorState(modelHash, entityCoords.x, entityCoords.y, entityCoords.z, state, false, false)
    FreezeEntityPosition(door, isLocked)
    doorCache[doorKey].locked = isLocked
end

RegisterCommand('doorlock', function()
    local _, doorCoords, doorModel = GetDoorInFront()
    if doorModel then
        TriggerServerEvent('doorlock:updateState', doorModel, doorCoords, true)
        exports.ox_lib:notify({ description = 'Door locked.', type = 'success' })
    else
        exports.ox_lib:notify({ description = 'You are not looking at a lockable door.', type = 'error' })
    end
end, false)

RegisterCommand('doorunlock', function()
    local _, doorCoords, doorModel = GetDoorInFront()
    if doorModel then
        TriggerServerEvent('doorlock:tryUnlock', doorModel, doorCoords)
    else
        exports.ox_lib:notify({ description = 'You are not looking at a lockable door.', type = 'error' })
    end
end, false)

RegisterCommand('doorforce', function()
    if isForcingDoor then return end
    local _, doorCoords, doorModel = GetDoorInFront()
    if not doorCoords then
        exports.ox_lib:notify({ description = 'You are not looking at a lockable door.', type = 'error' })
        return
    end
    if doorModel == GetHashKey('v_ilev_bk_vaultdoor') or doorModel == -1653372102 then
        exports.ox_lib:notify({ description = 'This door is too reinforced for forced entry.', type = 'error' })
        return
    end
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed) then
        exports.ox_lib:notify({ description = 'You must be on foot to force a door.', type = 'error' })
        return
    end
    RequestAnimDict('missheistfbi3b_ig7')
    while not HasAnimDictLoaded('missheistfbi3b_ig7') do
        Wait(10)
    end
    TaskPlayAnim(playerPed, 'missheistfbi3b_ig7', 'lift_fibagent_loop', 8.0, -8.0, -1, 1, 0, false, false, false)
    isForcingDoor = true
    exports.ox_lib:notify({ description = 'Attempting to force door...', type = 'inform' })
    local soundTimer = GetGameTimer()
    local soundInterval = 750
    local maxSoundDistance = 30.0
    local initialCoords = GetEntityCoords(playerPed)
    local maxMoveDistance = 0.2
    local movementCancelled = false
    Citizen.CreateThread(function()
        while isForcingDoor and not movementCancelled do
            Citizen.Wait(5)
            local currentCoords = GetEntityCoords(playerPed)
            local distanceMoved = #(currentCoords - initialCoords)
            if distanceMoved > maxMoveDistance then
                movementCancelled = true
                ClearPedTasksImmediately(playerPed)
                exports.ox_lib:cancelProgress()
                exports.ox_lib:notify({ description = 'Forced entry failed: You moved!', type = 'error' })
                break
            end
            if GetGameTimer() - soundTimer > soundInterval then
                PlaySoundFromCoord(-1, "SAFE_OPEN", doorCoords.x, doorCoords.y, doorCoords.z, "DLC_HEIST_BIOLAB_PREP_SOUNDS", true, maxSoundDistance, false)
                soundTimer = GetGameTimer()
            end
        end
        if movementCancelled then
            isForcingDoor = false
        end
    end)
    local success = exports.ox_lib:progressCircle({
        duration = forceDoorTime,
        label = 'Bashing door open...',
        style = 'circle',
        colour = 'orange',
        canCancel = true,
        disableAllInput = true,
        position = 'front',
    })
    if success and not movementCancelled then
        TriggerServerEvent('doorlock:forceOpen', doorModel, doorCoords)
        exports.ox_lib:notify({ description = 'The door has been successfully forced open!', type = 'success' })
    elseif not movementCancelled then
        exports.ox_lib:notify({ description = 'Forced entry cancelled.', type = 'warning' })
    end
    ClearPedTasks(playerPed)
    isForcingDoor = false
end, false)

RegisterCommand('checkdoor', function()
    local playerPed = PlayerPedId()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local forwardVector = RotAnglesToVec(camRot)
    local distance = 5.0
    local rayEnd = {
        x = camCoords.x + (forwardVector.x * distance),
        y = camCoords.y + (forwardVector.y * distance),
        z = camCoords.z + (forwardVector.z * distance)
    }
    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, playerPed, 0)
    local _, hit, _, _, hitEntity = GetShapeTestResult(rayHandle)
    if hit and DoesEntityExist(hitEntity) and IsEntityAnObject(hitEntity) then
        local modelHash = GetEntityModel(hitEntity)
        local coords = GetEntityCoords(hitEntity)
        local modelName = GetDisplayNameFromVehicleModel(modelHash)
        local isInConfig = Config.DoorModels[modelHash] and "✅ IS in config" or "❌ NOT in config"
        exports.ox_lib:notify({
            title = 'Object Found',
            description = string.format('Name: %s<br>Hash: `%s`<br>%s<br>Coords: (%.2f, %.2f, %.2f)', 
                modelName, modelHash, isInConfig, coords.x, coords.y, coords.z),
            type = 'inform'
        })
    else
        exports.ox_lib:notify({ description = 'You are not looking at any object.', type = 'error' })
    end
end, false)

RegisterNetEvent('doorlock:setState', function(doorModel, doorCoords, isLocked)
    SetDoorStateNative(doorModel, doorCoords, isLocked)
end)

RegisterNetEvent('doorlock:initialize', function(allDoors)
    for _, door in pairs(allDoors) do
        local doorKey = GenerateDoorKey(door.model, door.coords)
        doorCache[doorKey] = { model = door.model, coords = door.coords, locked = door.locked }
        if #(GetEntityCoords(PlayerPedId()) - door.coords) < DOOR_RANGE then
            SetDoorStateNative(door.model, door.coords, door.locked)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        for doorKey, door in pairs(doorCache) do
            local distance = #(playerCoords - door.coords)
            if distance < DOOR_RANGE then
                SetDoorStateNative(door.model, door.coords, door.locked)
            end
        end
    end
end)

RegisterNetEvent('ox:showNotification', function(data)
    exports.ox_lib:notify(data)
end)

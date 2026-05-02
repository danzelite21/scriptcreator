local resourceName = GetCurrentResourceName()
local permissions = Config.Permission

local function getPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    if not identifiers or #identifiers == 0 then
        return nil
    end
    for _, id in ipairs(identifiers) do
        if string.find(id, 'steam:') or string.find(id, 'license:') or string.find(id, 'discord:') or string.find(id, 'xbl:') or string.find(id, 'live:') then
            return id
        end
    end
    return identifiers[1]
end

local function createTables()
    local tables = {
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_admins (
            identifier VARCHAR(100) PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_npcs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            model VARCHAR(64) NOT NULL,
            x DOUBLE NOT NULL,
            y DOUBLE NOT NULL,
            z DOUBLE NOT NULL,
            heading DOUBLE NOT NULL,
            scenario VARCHAR(128) DEFAULT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_blips (
            id INT AUTO_INCREMENT PRIMARY KEY,
            label VARCHAR(64) NOT NULL,
            sprite INT NOT NULL,
            color INT NOT NULL,
            scale DOUBLE NOT NULL,
            x DOUBLE NOT NULL,
            y DOUBLE NOT NULL,
            z DOUBLE NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_markers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            markerType INT NOT NULL,
            r INT NOT NULL,
            g INT NOT NULL,
            b INT NOT NULL,
            a INT NOT NULL,
            x DOUBLE NOT NULL,
            y DOUBLE NOT NULL,
            z DOUBLE NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            label VARCHAR(128) NOT NULL,
            weight DOUBLE NOT NULL DEFAULT 0.0,
            stackable TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_images (
            id INT AUTO_INCREMENT PRIMARY KEY,
            url TEXT NOT NULL,
            label VARCHAR(128) DEFAULT NULL,
            x DOUBLE DEFAULT 0.0,
            y DOUBLE DEFAULT 0.0,
            z DOUBLE DEFAULT 0.0,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_jobs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            label VARCHAR(128) NOT NULL,
            type VARCHAR(64) NOT NULL,
            defaultDuty TINYINT(1) NOT NULL DEFAULT 0,
            offDutyPay TINYINT(1) NOT NULL DEFAULT 0,
            webhook TEXT DEFAULT NULL,
            grades JSON DEFAULT NULL,
            actions JSON DEFAULT NULL,
            blips JSON DEFAULT NULL,
            bossMenu TINYINT(1) NOT NULL DEFAULT 0,
            collections JSON DEFAULT NULL,
            spawnerZones JSON DEFAULT NULL,
            crafting TINYINT(1) NOT NULL DEFAULT 0,
            garages JSON DEFAULT NULL,
            selling TINYINT(1) NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS scriptcreator_audit (
            id INT AUTO_INCREMENT PRIMARY KEY,
            action VARCHAR(128) NOT NULL,
            actor VARCHAR(64) NOT NULL,
            target VARCHAR(128) DEFAULT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    }

    for _, query in ipairs(tables) do
        MySQL.execute(query, {})
    end
end

local function logAudit(source, action, target)
    local actor = GetPlayerName(source) or 'Server'
    MySQL.execute('INSERT INTO scriptcreator_audit (`action`, actor, target, created_at) VALUES (?, ?, ?, ?)', {
        action,
        actor,
        target or '',
        os.date('%Y-%m-%d %H:%M:%S')
    })
end

local function isAdmin(source, callback)
    if source == 0 or source == nil then
        callback(false)
        return
    end

    if IsPlayerAceAllowed(source, permissions) then
        callback(true)
        return
    end

    local identifier = getPlayerIdentifier(source)
    if not identifier then
        callback(false)
        return
    end

    MySQL.scalar('SELECT 1 FROM scriptcreator_admins WHERE identifier = ? LIMIT 1', { identifier }, function(result)
        callback(result == 1)
    end)
end

local function sanitizeFloat(value)
    return tonumber(value) or 0.0
end

local function sendState(source)
    MySQL.query('SELECT * FROM scriptcreator_npcs', {}, function(npcs)
        MySQL.query('SELECT * FROM scriptcreator_blips', {}, function(blips)
            MySQL.query('SELECT * FROM scriptcreator_markers', {}, function(markers)
                MySQL.query('SELECT * FROM scriptcreator_items', {}, function(items)
                    MySQL.query('SELECT * FROM scriptcreator_images', {}, function(images)
                        MySQL.query('SELECT * FROM scriptcreator_jobs', {}, function(jobs)
                            MySQL.query('SELECT identifier, name FROM scriptcreator_admins', {}, function(admins)
                            MySQL.query('SELECT * FROM scriptcreator_audit ORDER BY created_at DESC LIMIT 40', {}, function(audit)
                                local payload = {
                                    npcs = npcs,
                                    blips = blips,
                                    markers = markers,
                                    items = items,
                                    images = images,
                                    jobs = jobs,
                                    admins = admins,
                                    audit = audit,
                                    stats = {
                                        npcs = #npcs,
                                        blips = #blips,
                                        markers = #markers,
                                        items = #items,
                                        images = #images,
                                        jobs = #jobs,
                                        admins = #admins,
                                        audit = #audit
                                    }
                                }
                                TriggerClientEvent('scriptcreator:stateUpdate', source, payload)
                            end)
                        end)
                    end)
                    end)
                end)
            end)
        end)
    end)
end

local function generateExportFile()
    MySQL.query('SELECT * FROM scriptcreator_npcs', {}, function(npcs)
        MySQL.query('SELECT * FROM scriptcreator_blips', {}, function(blips)
            MySQL.query('SELECT * FROM scriptcreator_markers', {}, function(markers)
                MySQL.query('SELECT * FROM scriptcreator_items', {}, function(items)
                    MySQL.query('SELECT * FROM scriptcreator_images', {}, function(images)
                        MySQL.query('SELECT * FROM scriptcreator_jobs', {}, function(jobs)
                            local lines = {}
                            table.insert(lines, '-- Generated by ScriptCreator')
                            table.insert(lines, 'return {')

                            local function formatTable(name, records, fields, jsonFields)
                                table.insert(lines, ('    %s = {'):format(name))
                                for _, record in ipairs(records) do
                                    local parts = {}
                                    for _, field in ipairs(fields) do
                                        local value = record[field]
                                        if jsonFields and jsonFields[field] then
                                            local decoded = json.decode(value or '[]')
                                            if type(decoded) == 'table' then
                                                value = '{' .. table.concat(decoded, ', ') .. '}' -- simple format
                                            else
                                                value = tostring(value)
                                            end
                                        elseif type(value) == 'string' then
                                            value = value:gsub('\n', '\\n'):gsub('"', '\\"')
                                            table.insert(parts, ('%s = %q'):format(field, value))
                                        else
                                            table.insert(parts, ('%s = %s'):format(field, tostring(value)))
                                        end
                                    end
                                    table.insert(lines, ('        { %s },'):format(table.concat(parts, ', ')))
                                end
                                table.insert(lines, '    },')
                            end

                            formatTable('npcs', npcs, { 'model', 'x', 'y', 'z', 'heading', 'scenario' })
                            formatTable('blips', blips, { 'label', 'sprite', 'color', 'scale', 'x', 'y', 'z' })
                            formatTable('markers', markers, { 'markerType', 'r', 'g', 'b', 'a', 'x', 'y', 'z' })
                            formatTable('items', items, { 'name', 'label', 'weight', 'stackable' })
                            formatTable('images', images, { 'url', 'label', 'x', 'y', 'z', 'active' })
                            formatTable('jobs', jobs, { 'name', 'label', 'type', 'defaultDuty', 'offDutyPay', 'webhook', 'grades', 'actions', 'blips', 'bossMenu', 'collections', 'spawnerZones', 'crafting', 'garages', 'selling' }, { grades = true, actions = true, blips = true, collections = true, spawnerZones = true, garages = true })

                            table.insert(lines, '}')
                            local content = table.concat(lines, '\n')
                            SaveResourceFile(resourceName, 'scriptcreator_export.lua', content, -1)
                        end)
                    end)
                end)
            end)
        end)
    end)
end

local actionHandlers = {
    load = function(source, payload)
        sendState(source)
    end,
    createNPC = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_npcs (model, x, y, z, heading, scenario, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            tostring(payload.model),
            sanitizeFloat(payload.x),
            sanitizeFloat(payload.y),
            sanitizeFloat(payload.z),
            sanitizeFloat(payload.heading),
            tostring(payload.scenario),
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create NPC', payload.model)
        sendState(source)
        generateExportFile()
    end,
    deleteNPC = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_npcs WHERE id = ?', { payload.id })
        logAudit(source, 'Delete NPC', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    createBlip = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_blips (label, sprite, color, scale, x, y, z, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            tostring(payload.label),
            tonumber(payload.sprite) or Config.DefaultBlip.sprite,
            tonumber(payload.color) or Config.DefaultBlip.color,
            tonumber(payload.scale) or Config.DefaultBlip.scale,
            sanitizeFloat(payload.x),
            sanitizeFloat(payload.y),
            sanitizeFloat(payload.z),
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create Blip', payload.label)
        sendState(source)
        generateExportFile()
    end,
    deleteBlip = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_blips WHERE id = ?', { payload.id })
        logAudit(source, 'Delete Blip', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    createMarker = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_markers (markerType, r, g, b, a, x, y, z, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            tonumber(payload.markerType) or 1,
            tonumber(payload.r) or 255,
            tonumber(payload.g) or 100,
            tonumber(payload.b) or 100,
            tonumber(payload.a) or 150,
            sanitizeFloat(payload.x),
            sanitizeFloat(payload.y),
            sanitizeFloat(payload.z),
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create Marker', tostring(payload.markerType))
        sendState(source)
        generateExportFile()
    end,
    deleteMarker = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_markers WHERE id = ?', { payload.id })
        logAudit(source, 'Delete Marker', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    createItem = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_items (name, label, weight, stackable, created_at) VALUES (?, ?, ?, ?, ?)', {
            tostring(payload.name),
            tostring(payload.label),
            sanitizeFloat(payload.weight),
            payload.stackable and 1 or 0,
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create Item', payload.name)
        sendState(source)
        generateExportFile()
    end,
    deleteItem = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_items WHERE id = ?', { payload.id })
        logAudit(source, 'Delete Item', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    createImage = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_images (url, label, x, y, z, active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            tostring(payload.url),
            tostring(payload.label),
            sanitizeFloat(payload.x),
            sanitizeFloat(payload.y),
            sanitizeFloat(payload.z),
            payload.active and 1 or 0,
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create Image', payload.url)
        sendState(source)
        generateExportFile()
    end,
    deleteImage = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_images WHERE id = ?', { payload.id })
        logAudit(source, 'Delete Image', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    createJob = function(source, payload)
        MySQL.execute('INSERT INTO scriptcreator_jobs (name, label, type, defaultDuty, offDutyPay, webhook, grades, actions, blips, bossMenu, collections, spawnerZones, crafting, garages, selling, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            tostring(payload.name),
            tostring(payload.label),
            tostring(payload.type),
            payload.defaultDuty and 1 or 0,
            payload.offDutyPay and 1 or 0,
            tostring(payload.webhook),
            json.encode(payload.grades or {}),
            json.encode(payload.actions or {}),
            json.encode(payload.blips or {}),
            payload.bossMenu and 1 or 0,
            json.encode(payload.collections or {}),
            json.encode(payload.spawnerZones or {}),
            payload.crafting and 1 or 0,
            json.encode(payload.garages or {}),
            payload.selling and 1 or 0,
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Create Job', payload.name)
        sendState(source)
        generateExportFile()
    end,
    deleteJob = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_jobs WHERE id = ?', { payload.id })
        logAudit(source, 'Delete Job', tostring(payload.id))
        sendState(source)
        generateExportFile()
    end,
    addAdmin = function(source, payload)
        local identifier = tostring(payload.identifier)
        local name = tostring(payload.name)
        MySQL.execute('INSERT INTO scriptcreator_admins (identifier, name, added_at) VALUES (?, ?, ?)', {
            identifier,
            name,
            os.date('%Y-%m-%d %H:%M:%S')
        })
        logAudit(source, 'Add Admin', name)
        sendState(source)
    end,
    removeAdmin = function(source, payload)
        MySQL.execute('DELETE FROM scriptcreator_admins WHERE identifier = ?', { tostring(payload.identifier) })
        logAudit(source, 'Remove Admin', tostring(payload.identifier))
        sendState(source)
    end,
    grantItem = function(source, payload)
        MySQL.query('SELECT name, label, weight FROM scriptcreator_items WHERE id = ? LIMIT 1', { payload.id }, function(result)
            if not result or not result[1] then
                TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'error', text = 'Item tidak ditemukan.' } })
                return
            end
            local item = result[1]
            exports.ox_inventory:AddItem(source, item.name, 1, { label = item.label, weight = item.weight })
            logAudit(source, 'Grant Item', item.name)
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'success', text = 'Item telah ditambahkan ke inventory.' } })
        end)
    end,
    export = function(source, payload)
        generateExportFile()
        TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'success', text = 'Export Lua telah dibuat.' } })
    end
}

RegisterServerEvent('scriptcreator:npcInteract')
AddEventHandler('scriptcreator:npcInteract', function(npcId)
    local source = source
    MySQL.query('SELECT model FROM scriptcreator_npcs WHERE id = ? LIMIT 1', { npcId }, function(result)
        if result and result[1] then
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'success', text = ('Interaksi NPC %s berhasil.'):format(result[1].model) } })
        else
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'error', text = 'NPC tidak ditemukan.' } })
        end
    end)
end)

RegisterServerEvent('scriptcreator:nuiAction')
AddEventHandler('scriptcreator:nuiAction', function(data)
    local source = source
    isAdmin(source, function(ok)
        if not ok then
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'error', text = 'Akses admin ditolak.' } })
            return
        end

        if not data or not data.action or not actionHandlers[data.action] then
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'error', text = 'Aksi tidak valid.' } })
            return
        end

        actionHandlers[data.action](source, data.payload or {})
    end)
end)

RegisterServerEvent('scriptcreator:requestState')
AddEventHandler('scriptcreator:requestState', function()
    local source = source
    isAdmin(source, function(ok)
        if not ok then
            TriggerClientEvent('scriptcreator:uiMessage', source, { action = 'toast', payload = { type = 'error', text = 'Akses admin ditolak.' } })
            return
        end
        sendState(source)
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == resourceName then
        createTables()
        generateExportFile()
    end
end)

RegisterCommand(Config.Command, function(source)
    if source == 0 then
        return
    end
    isAdmin(source, function(ok)
        if ok then
            TriggerClientEvent('scriptcreator:toggleMenu', source)
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^1ScriptCreator', 'Anda tidak memiliki izin admin.' }
            })
        end
    end)
end, false)

DonorShop = {__VERSION = "1.01"}
function GetDatabaseName()
    local dbconvar = GetConvar("mysql_connection_string", "Empty")
    if not dbconvar or dbconvar == "Empty" then
        error("Local dbconvar is empty.")
        return false
    else
        local strStart, strEnd = string.find(dbconvar, "database=")
        if not strStart or not strEnd then
            local oStart, oEnd = string.find(dbconvar, "mysql://")
            if not oStart or not oEnd then
                error("Incorrect mysql_connection_string.")
                return false
            else
                local hostStart, hostEnd = string.find(dbconvar, "@", oEnd)
                local dbStart, dbEnd = string.find(dbconvar, "/", hostEnd + 1)
                local eStart, eEnd = string.find(dbconvar, "?")
                local _end = (eEnd and eEnd - 1 or dbconvar:len())
                local dbName = string.sub(dbconvar, dbEnd + 1, _end)
                return dbName
            end
        else
            local dbStart, dbEnd = string.find(dbconvar, ";", strEnd)
            local dbName = string.sub(dbconvar, strEnd + 1, (dbEnd and dbEnd - 1 or dbconvar:len()))
            return dbName
        end
    end
end
local Donors = {}
MySQL.ready(
    function()
        local dbName = GetDatabaseName()
        if not dbName then
            error("Error connecting to database.")
            return
        end
        local dbTable = "donors"
        MySQL.Async.fetchAll(
            "SELECT * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=@dbName AND TABLE_NAME=@tabName",
            {["@dbName"] = dbName, ["@tabName"] = dbTable},
            function(retData)
                if retData and retData[1] then
                    DonorShop.sqlReady = true
                else
                    print(GetCurrentResourceName() .. " does not have required SQL tables.")
                end
            end
        )
    end
)
RegisterNetEvent("DonorShop:CheckPlate")
AddEventHandler(
    "DonorShop:CheckPlate",
    function(plate)
        local _source = source
        local sqlRet
        MySQL.Async.fetchAll(
            "SELECT 1 FROM owned_vehicles WHERE plate = @plate",
            {["@plate"] = plate},
            function(result)
                sqlRet = {valid = (result[1] == nil)}
            end
        )
        while not sqlRet do
            Wait(0)
        end
        TriggerClientEvent("DonorShop:CheckedPlate", _source, sqlRet.valid)
    end
)
LoginCheck = function()
    local _source = source
    while not DonorShop.sqlReady do
        Wait(0)
    end
    local xPlayerx = ESX.GetPlayerFromId(source)
    local identifier = xPlayerx.identifier

    -- GetIdentifier(_source, "steam")
    MySQL.Async.fetchAll(
        "SELECT * FROM donors WHERE identifier=@identifier",
        {["@identifier"] = identifier},
        function(data)
            local donorLevel, donorPoints
            if data and data[1] then
                donorLevel = data[1].donor_tier
                donorPoints = data[1].donor_points
            else
                donorLevel = 0
                donorPoints = 0
            end
            Donors[_source] = {level = donorLevel, count = donorPoints}
            TriggerClientEvent("DonorShop:GotStatus", _source, donorLevel, donorPoints)
        end
    )
end
DonorCheck = function(c, props)
    local _source = source
    local count = 0
    if Donors[_source] then
        count = Donors[_source].count
    end
    if count >= c then
        TakePoints(_source, c)
        BuyCar(_source, props)
        count = true
    else
        count = false
    end
    TriggerClientEvent("DonorShop:CheckedDonor", _source, count)
end
if not ControlCars then
    BuyCar = function(_source, props)
        while not DonorShop.sqlReady do
            Wait(0)
        end
    local xPlayerx = ESX.GetPlayerFromId(source)
    local identifier = xPlayerx.identifier
        -- GetIdentifier(_source, "steam")
        local plate = props.plate
        MySQL.Async.execute(
            "INSERT INTO owned_vehicles SET owner=@owner,plate=@plate,vehicle=@vehicle",
            {["@owner"] = identifier, ["@plate"] = plate, ["@vehicle"] = json.encode(props)}
        )
    end
end
TakePoints = function(source, points)
    while not DonorShop.sqlReady do
        Wait(0)
    end
    Donors[source].count = Donors[source].count - points
    local xPlayerx = ESX.GetPlayerFromId(source)
    local identifier = xPlayerx.identifier
    -- GetIdentifier(source, "steam")
    MySQL.Async.fetchAll(
        "UPDATE donors SET donor_points=@donor_points WHERE identifier=@identifier",
        {["@identifier"] = identifier, ["@donor_points"] = Donors[source].count}
    )
    TriggerClientEvent("DonorShop:GotStatus", source, Donors[source].level, Donors[source].count)
end
AddPoints = function(source, points)
    while not DonorShop.sqlReady do
        Wait(0)
    end
    local target = false
    if type(points) == "table" then
        target = (points[2] and tonumber(points[2]) or false)
        points = tonumber(points[1])
    end
    if target then
        source = target
    end
    if not Donors[source] then
        print(GetCurrentResourceName() .. " Error: " .. source .. " is not a donor.")
        return
    end
    Donors[source].count = (Donors[source].count or 0) + points
    local xPlayerx = ESX.GetPlayerFromId(source)
    local identifier = xPlayerx.identifier
    -- GetIdentifier(source, "steam")
    MySQL.Async.fetchAll(
        "UPDATE donors SET donor_points=@donor_points WHERE identifier=@identifier",
        {["@identifier"] = identifier, ["@donor_points"] = Donors[source].count}
    )
    TriggerClientEvent("DonorShop:GotStatus", source, Donors[source].level, Donors[source].count)
end
SetDonor = function(source, args)
    while not DonorShop.sqlReady do
        Wait(0)
    end
    local tier = math.max(1, math.min(#DonorTiers, tonumber(args[1])))
    local target = (args[2] and tonumber(args[2]) or false)
    if target then
        source = target
    end
    if not target and not tier then
        return
    end
    Donors[source] = (Donors[source] or {})
    Donors[source].level = tier

    local xPlayerx = ESX.GetPlayerFromId(source)
    local identifier = xPlayerx.identifier
    -- GetIdentifier(source, "steam")
    MySQL.Async.fetchAll(
        "SELECT * FROM donors WHERE identifier=@identifier",
        {["@identifier"] = identifier},
        function(data)
            if data and data[1] then
                MySQL.Async.fetchAll(
                    "UPDATE donors SET donor_tier=@donor_tier WHERE identifier=@identifier",
                    {["@identifier"] = identifier, ["@donor_tier"] = tier}
                )
            else
                MySQL.Async.execute(
                    "INSERT INTO donors SET donor_tier=@donor_tier, donor_points=@donor_points, identifier=@identifier",
                    {
                        ["@identifier"] = identifier,
                        ["@donor_tier"] = tier,
                        ["@donor_points"] = (Donors[source].points or 0)
                    }
                )
            end
        end
    )
    TriggerClientEvent("DonorShop:SetTier", source, tier)
end


GetIdentifier = function(source, identifier)
    for k, id in pairs(GetPlayerIdentifiers(source)) do
        if id:find(identifier) then
            return id
        end
    end
end

Event = function(e, h, n)
    if e then
        RegisterNetEvent(e)
    end
    AddEventHandler(e, h)
end
Event("DonorShop:DonorCheck", DonorCheck, 1)
Event("DonorShop:LoginCheck", LoginCheck, 1)
if not Config.UseConsoleCommand then
    TriggerEvent("es:addGroupCommand", "setdonor", "admin", SetDonor)
    TriggerEvent("es:addGroupCommand", "addpointsdonor", "admin", AddPoints)
    TriggerEvent(
        "es:addGroupCommand",
        "setdonorbyidentifier",
        "admin",
        function(source, args)
            while not DonorShop.sqlReady do
                Wait(0)
            end
            local tier = math.max(1, math.min(#DonorTiers, tonumber(args[1])))
            local target_identifier = (args[2] and args[2]:len() > 1 and args[2] or false)
            if not target_identifier then
                print(
                    string.format(
                        "[DonorShop] setdonorbyidentifier : invalid target identifier : %s",
                        target_identifier
                    )
                )
                return
            end
            local xPlayer = ESX.GetPlayerFromIdentifier(target_identifier)
            if not xPlayer then
                print(
                    string.format(
                        "[DonorShop] setdonorbyidentifier : invalid target identifier : %s",
                        target_identifier
                    )
                )
                return
            end
            if not tier then
                print(string.format("[DonorShop] setdonorbyidentifier : invalid target tier : %s", tier))
                return
            end
            Donors[xPlayer.source] = (Donors[xPlayer.source] or {})
            Donors[xPlayer.source].level = tier
            MySQL.Async.fetchAll(
                "SELECT * FROM donors WHERE identifier=@identifier",
                {["@identifier"] = identifier},
                function(data)
                    if data and data[1] then
                        MySQL.Async.fetchAll(
                            "UPDATE donors SET donor_tier=@donor_tier WHERE identifier=@identifier",
                            {["@identifier"] = identifier, ["@donor_tier"] = tier}
                        )
                    else
                        MySQL.Async.execute(
                            "INSERT INTO donors SET donor_tier=@donor_tier, donor_points=@donor_points, identifier=@identifier",
                            {
                                ["@identifier"] = identifier,
                                ["@donor_tier"] = tier,
                                ["@donor_points"] = (Donors[xPlayer.source].points or 0)
                            }
                        )
                    end
                end
            )
            TriggerClientEvent("DonorShop:SetTier", xPlayer.source, tier)
        end
    )
else
    RegisterCommand("setdonor", SetDonor, 1)
    RegisterCommand("addpointsdonor", AddPoints, 1)
end

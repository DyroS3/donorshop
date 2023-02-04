local mLibs       = exports["meta_libs"]
local Vector      = mLibs:Vector()
local donorRank   = 0
local donorChips  = 0

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
  local generatedPlate
  local doBreak = false

  while true do
    Citizen.Wait(2)
    math.randomseed(GetGameTimer())
    generatedPlate = string.upper(GetRandomLetter(3) .. ' ' .. GetRandomNumber(3))

    PlateRet = false
    TriggerServerEvent("DonorShop:CheckPlate",generatedPlate)
    while not PlateRet do Wait(0); end

    if PlateRet.valid then
      break
    end
  end

  return generatedPlate
end

function GetRandomNumber(length)
  Citizen.Wait(0)
  math.randomseed(GetGameTimer())
  if length > 0 then
    return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
  else
    return ''
  end
end

function GetRandomLetter(length)
  Citizen.Wait(0)
  math.randomseed(GetGameTimer())
  if length > 0 then
    return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
  else
    return ''
  end
end

RegisterNetEvent("DonorShop:CheckedPlate")
AddEventHandler("DonorShop:CheckedPlate", function(valid) print("Checked plate",valid) PlateRet = {valid = valid}; end)

Start = function()    
  Wait(1000)
  if Config.ShowBlip then
    local blip = Config.Blip
    shopBlip = mLibs:AddBlip(blip.posX,blip.posY,blip.posZ,blip.sprite,blip.color,blip.text,blip.scale,blip.display,blip.shortRange,blip.highDetail)
  end

  if Config.ShowMarker then
    local m1 = Config.OutsideMarker
    outsideMarker = mLibs:AddMarker(m1.type,m1.posX,m1.posY,m1.posZ,0.0,0.0,0.0,0.0,0.0,0.0,m1.scaleX,m1.scaleY,m1.scaleZ,m1.red,m1.green,m1.blue,m1.alpha,m1.bobUpAndDown,m1.faceCamera,2)
    local m2 = Config.InsideMarker
    insideMarker = mLibs:AddMarker(m2.type,m2.posX,m2.posY,m2.posZ,0.0,0.0,0.0,0.0,0.0,0.0,m2.scaleX,m2.scaleY,m2.scaleZ,m2.red,m2.green,m2.blue,m2.alpha,m2.bobUpAndDown,m2.faceCamera,2)
  end

  TriggerServerEvent('DonorShop:LoginCheck')
end

HelpNotification = function(msg)
  AddTextEntry('mLibsHelp', msg)
  BeginTextCommandDisplayHelp('mLibsHelp')
  EndTextCommandDisplayHelp(0, false, true, -1)
end

ShowNotification = function(msg)
  AddTextEntry('mLibsNotify', msg)
  SetNotificationTextEntry('mLibsNotify')
  DrawNotification(false, true)
end

GetKeyUp = function(key)
  return (IsControlJustPressed(0,key) or IsDisabledControlJustPressed(0,key))
end

Update = function()
  if not started then
    started = true
  else
    return
  end
  
  while true do
    local plyPed = GetPlayerPed(-1)
    local plyPos = GetEntityCoords(plyPed)
    local insideDist = vDist(plyPos,Config.InsideTeleport)
    local outsideDist = vDist(plyPos,Config.OutsideTeleport)
    if insideDist < outsideDist then
      if insideDist < 5.0 then
        HelpNotification("Press ~INPUT_PICKUP~ to leave the donor shop.")
        if GetKeyUp(38) then
          Wait(100)
          mLibs:TeleportPlayer(Config.OutsideSpawn)
          DespawnShop()
        end
      end

      if shopSpawned then
        local closest,closestDist = GetClosestVehicle()
        if closestDist < 20.0 then
          DrawSpotlight(closest)
          if closestDist < 5.0 then
            local data = SpawnedVehicles[closest]
            local model = GetEntityModel(data.vehicle.entId)
            local display = GetDisplayNameFromVehicleModel(model)
            local label = GetLabelText(display)

            HelpNotification("Press ~INPUT_PICKUP~ to buy the "..(label ~= "NULL" and label or display or model).." for "..data.price.." donor "..(data.price > 1 and "tokens" or "token"))
            if GetKeyUp(38) then
              Wait(0)
              donorCheck = false
              donorData  = false
              local props = mLibs:GetVehicleProps(data.vehicle.entId)
              local generatedPlate = GeneratePlate()
              props.plate = generatedPlate
              TriggerServerEvent('DonorShop:DonorCheck',data.price,props)
              while not donorCheck do Wait(0); end
              if (donorData) then
                SetVehicleNumberPlateText(data.vehicle.entId,props.plate)
                ShowNotification("~g~You purchased the "..(label ~= "NULL" and label or display or model).." for "..data.price.." donor "..(data.price > 1 and "tokens~s~" or "token~s~"))
                mLibs:TeleportPlayer(Config.OutsideSpawn)
                local vehicle = mLibs:Vehicle(model,Config.OutsideSpawn.x,Config.OutsideSpawn.y,Config.OutsideSpawn.z+0.5)
                mLibs:SetVehicleProps(vehicle.entId,props)
				
                TaskWarpPedIntoVehicle(plyPed,vehicle.entId,-1)
                SetVehicleEngineOn(vehicle.entId,true,true,false)

			   DespawnShop()
				
              else
                ShowNotification("~r~You can't afford that~s~")
              end
            end
          end
        end
      end
    else
      local inVeh = (IsPedInAnyVehicle(plyPed))
      if outsideDist < 5.0 and donorRank > 0 and not inVeh then
        HelpNotification("Press ~INPUT_PICKUP~ to enter the donor shop.")
        if GetKeyUp(38) then
          mLibs:TeleportPlayer(Config.InsideSpawn)
          SpawnShop()
        end
      end
    end
    Wait(0)
  end
end

CheckedDonor = function(hasEnough)
  donorData  = hasEnough
  donorCheck = true
end

GotStatus = function(status,points)
  donorRank  = status
  donorChips = points  
  Update()
end

SetTier = function(tier)
  donorRank = tier
end

DrawSpotlight = function(pos)
  local lightPos = vector3(pos.x,pos.y,pos.z + 5.0)
  local direction = pos - lightPos
  local normal = Vector.Normalize(direction)
  DrawSpotLight(lightPos.x,lightPos.y,lightPos.z, normal.x,normal.y,normal.z, 255,255,255, 100.0, 1.0, 0.0, 25.0, 1.0)
end

DespawnShop = function()
  if SpawnedVehicles then
    for k,v in pairs(SpawnedVehicles) do
      v.vehicle.delete()
    end
  end
  shopSpawned = false
end

GetClosestVehicle = function()
  local plyPos = GetEntityCoords(GetPlayerPed(-1))
  local closest,closestDist
  for pos,data in pairs(SpawnedVehicles) do
    local dist = Vdist(plyPos,pos)
    if not closestDist or dist < closestDist then
      closest = pos
      closestDist = dist
    end
  end
  if closest and closestDist then
    return closest,closestDist
  else
    return false,999999
  end
end

SpawnShop = function()
  local tier = DonorTiers[donorRank]
  if tier then
    SpawnedVehicles = SpawnVehicles(tier.vehicles)
    shopSpawned = true
  end
end

SpawnVehicles = function(playerVehicles)
  local pos = Config.InsideSpawn
  local spawnPositions = {}
  local spawnVehicles = {}
  for i=1,36,1 do spawnPositions[i] = pos + Vector.PointOnSphere(0.0, (i*(36 / math.min(36,#playerVehicles)))*10.0, 15.0); end
  for i=1,#playerVehicles,1 do
    if spawnPositions[i] then
      local spawn = spawnPositions[i]
      local model = playerVehicles[i].model
      local dirNorm = Vector.Normalize(pos - spawn)
      local heading = GetHeading(dirNorm) - 90.0
      local vehicle = mLibs:LocalVehicle(model,spawn,heading)
      spawnVehicles[spawnPositions[i]] = {vehicle = vehicle, price = playerVehicles[i].price}
      mLibs:ReleaseModel(model)
    end
  end
  return spawnVehicles
end

GetHeading = function(norm)
  local angle = math.atan2(norm.y,norm.x)
  local degrees = 180.0*angle/math.pi
  return (360.0+degrees)%360.0
end

vDist = function(v1,v2)  
  if not v1 or not v2 or not v1.x or not v2.x or not v1.z or not v2.z then return 0; end
  return math.sqrt( ((v1.x - v2.x)*(v1.x-v2.x)) + ((v1.y - v2.y)*(v1.y-v2.y)) + ((v1.z-v2.z)*(v1.z-v2.z)) ) 
end

RegisterNetEvent('DonorShop:CheckedDonor')
AddEventHandler('DonorShop:CheckedDonor',CheckedDonor)

RegisterNetEvent('DonorShop:GotStatus')
AddEventHandler('DonorShop:GotStatus',GotStatus)

RegisterNetEvent('DonorShop:SetTier')
AddEventHandler('DonorShop:SetTier',SetTier)

TriggerEvent('chat:addSuggestion','/setdonor','help text',{{ name="tier", help="配置赞助等级" },{ name="target", help="服务器ID (留空为自己)" }})
TriggerEvent('chat:addSuggestion','/addpointsdonor','help text',{{ name="points", help="配置赞助点数" },{ name="target", help="服务器ID (留空为自己)" }})

Citizen.CreateThread(Start)

RegisterCommand('mydonor', function(...)
  ShowNotification("赞助等级: "..tostring(donorRank).."\n赞助点数: "..tostring(donorChips))
end)
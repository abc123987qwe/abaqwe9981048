--[[Sensitive Part]]--
local PaX,PaY = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
local facing = Configuration.Player.Facing:lower() == "left" and 48 or 32
local isIsland = GetTile(199, 199)
local TileX, TileY = (isIsland and 199 or 99), (isIsland and 199 or 53)
local current = 1
local Rejoin = true
local CurrentWorld = GetWorld().name:upper()
local Limit = 0
local Pkt = SendPacket
local Slp = Sleep
local PktR = SendPacketRaw
local PktV = not SendVarian and SendVariantList or SendVariant
local ConsumeTime = -60 * 30
local ConvertDL = 60
local SuckBGem = 60
local WBL = "https://discord.com/api/webhooks/1358137211123535923/rRDAvDajk1DUEp7OyBdCYPjR9useekwau2bkvQbrTkjooUSWK38m_jSr1B-HczQiY-LF"
local StartTime = os and os.time() or 0

E = function(log) return LogToConsole("`0[`^" ..os.date("%H:%M:%S") .."`0][`#@Tomoka`0] `0** : "..log) end

L = function(vl) 
    local func = not SendVariant and SendVariantList or SendVariant
    return func({[0] = "OnTextOverlay", [1] = (vl ~= nil and vl or "")}) 
end

ER = function(inp)
E(inp)
L(inp)
end


WP = function(x)
  Pkt(3, "action|join_request\nname|" ..x)
end

AR = function(x, y)
  Pkt(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. x .. "|\ny|" .. y .. "|\nbuttonClicked|getRemote")
end

CH = function(num)
  Pkt(2, "action|dialog_return\ndialog_name|cheats\ncheck_antibounce|1\ncheck_gems|" ..(Configuration.Misc.TakeGems and 1 or 0) .."\ncheck_autofarm|" ..num .."\ncheck_bfg|" ..num)
end

TX = function(x)
  Pkt(2, "action|input\ntext|" ..x)
end

PN = function(x, y, z)
  PktR(false, { type = 3, x = x * 32, y = y * 32, px = x, py = y, value = z })
end

CS = function(x, y, z)
  PktR(false, { type = 0, x = y * 32, y = z * 32, state = x, xspeed = 300})
end

SB = function()
  Pkt(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgem_suckall")
  Slp(200)
end

FM = function()
  local Found = {}
  local count = 0
  for y = 0, TileY, 1 do
    for x = 0, TileX, 1 do
      if GetTile(x, y).fg == 5638 and GetTile(x, y).bg == Configuration.Magplants.BackgroundID then
        table.insert(Found, {x, y})
        count = count + 1
      end
    end
  end
  return Found
end

GR = function()
  local Magplant = FM()
  if #Magplant == 0 then
    ER("`4No Magplant Detected")
    return
  end
  CS(32, Magplant[#Magplant - current + 1][1], Magplant[#Magplant - current + 1][2])
  Slp(300)
  PN(Magplant[#Magplant - current +  1][1], Magplant[#Magplant - current + 1][2], 32)
  Slp(300)
  AR(Magplant[#Magplant - current + 1][1], Magplant[#Magplant - current + 1][2])
  Slp(300)
end

CI = function(num)
  for _, Inv in pairs(GetInventory()) do
    if Inv.id == num then
      return Inv.amount
    end
  end
  return 0
end

EC = function()
  if not Configuration.Misc.AutoConsume then
    return end
  local cT = os.time()
  if cT > ConsumeTime + (60 * 30) then
    ConsumeTime = cT
    ER("`9Consume Time")
    for _, Eat in pairs(Configuration.Misc.ConsumableID) do
      if CI(Eat) > 0 then
        for i = 1, Configuration.Misc.Attempt do
        PN(PaX, PaY, Eat)
        Slp(2000)
        end
      end
    end
  end
end

FTime = function(sec)
    days = math.floor(sec / 86400)
    hours = math.floor(sec % 86400 / 3600)
    minutes = math.floor(sec % 3600 / 60)
    seconds = math.floor(sec % 60)
    if days > 0 then
      return string.format("%sd %sh %sm %ss", days, hours, minutes, seconds)
    elseif hours > 0 then
      return string.format("%sh %sm %ss", hours, minutes, seconds)
    elseif minutes > 0 then
      return string.format("%sm %ss", minutes, seconds)
    elseif seconds >= 0 then
      return string.format("%ss", seconds)
    end
end

AS = function()
  if not Configuration.Misc.AutoSuck then
    return
  end
  
  local scBGems = os.time()
  
  if scBGems > SuckBGem + (Configuration.Delay.DelaySuck) then
    Pkt(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgem_suckall")
    Slp(200)
    SuckBGem = scBGems
  end
end

CD = function()
  if not Configuration.Misc.GemToDL then
    return
  end
  
  local cvTime = os.time()
  
  if cvTime > ConvertDL + (Configuration.Delay.DelayConvert) then
    Pkt(2, "action|dialog_return\ndialog_name|telephone\nnum|53785\nx|" .. (Configuration.Misc.TelephonePos.x - 1) .. "\ny|" .. (Configuration.Misc.TelephonePos.y - 1) .. "\nbuttonClicked|dlconvert")
    Slp(200)
    ConvertDL = cvTime
  end
end

CB = function()
  if CI(1796) > 100 then
    Pkt(2, "action|dialog_return\ndialog_name|telephone\nnum|53785\nx|" .. (Configuration.Misc.TelephonePos.x - 1) .. "\ny|" .. (Configuration.Misc.TelephonePos.y - 1) .. "\nbuttonClicked|bglconvert")
    ER("`cConverting `1DL `cto `eBGL")
    Slp(200)
  end
end

WBH = function()
        local playerName = GetLocal().name:match("[^`,%d]+")
    local PosiBre = "X: " .. (math.floor(PaX) + 1).. " Y: " .. (math.floor(PaY) +1)
    local TelePost = "X: " .. Configuration.Misc.TelephonePos.x .. " Y: " ..Configuration.Misc.TelephonePos.y
    local TotMag = #FM()
    local RemT = current
    local ConsTot = #Configuration.Misc.ConsumableID
    local Link = WBL
    local requestBody = [[
    {
      "content": "",
      "embeds": [
        {
          "title": "PNB V3 Status Update",
          "color": 65535,
          "fields": [
            {
              "name": "**<a:Crown:1358265366576496793> Username:**",
              "value": "*]] ..playerName.. [[*",
              "inline": true
            },
            {
              "name": "**<:Char:1358261991508283553> Break Position:**",
              "value": "*Locked Break Position: ]] ..PosiBre.. [[*",
              "inline": true
            },
            {
              "name": "**<:telep:1358652528413249597> Telephone Position:**",
              "value": "*Telephone Position Set: ]] ..TelePost.. [[*",
              "inline": true
            },
            {
              "name": "**<:MagPlants:1358262215135854672> Magplant Count:**",
              "value": "*Total Magplant: ]] ..TotMag.. [[*",
              "inline": true
            },
            {
              "name": "**<:MPRemote:1358658580135546947> Current Remote:**",
              "value": "*Taking Remote #]] ..RemT.. [[*",
              "inline": true
            },
            {
              "name": "**<:ArRoz:1358269158692749372> Consumable:**",
              "value": "*Consumable Counts: ]] ..ConsTot.. [[*",
              "inline": true
            },
            {
              "name": "**<a:emoji_40:1315182746498236456> Consumable Amount:**",
              "value": "*Arroz: ]] ..CI(4604).. [[\nClover: ]] ..CI(524).. [[\nSongpyeon: ]] ..CI(1056).. [[\nEgg Benedict: ]] ..CI(1474).. [[*",
              "inline": true
            },
            {
              "name": "**<:Globes:1358263944938000526> World:**",
              "value": "*Locked World: ]] ..CurrentWorld.. [[*",
              "inline": true
            },
            {
              "name": "**<:bijiel:1250517175421370459> Current Lock:**",
              "value": "*Diamond Lock: ]] ..CI(1796).. [[ <:DL:1358262393192579234>\nBlue Gem Lock: ]] ..CI(7188).. [[ <:bijiel:1250517175421370459>*",
              "inline": true
            },
            {
              "name": "**<a:EPTime:1243341200195321916> RunTime:**",
              "value": "*Time: ]] ..FTime(os.time() - StartTime)..[[*",
              "inline": true
            }
          ]
        }
      ]
    }
    ]]
    MakeRequest(Link, "POST", {["Content-Type"] = "application/json"}, requestBody)
end


for i = 1, 1 do
  TX("`cPremium PNB V3 `0by `#@Tomoka")
  Slp(1000)
 if Configuration.Misc.GemToDL then
  TX("`cCurrent `1DL`0: " .. CI(1796)) 
  Slp(2000)
  end
end


RN = function()
  CH(0)
  Slp(300)
  
  while true do
    Slp(100)   
    if (GetWorld() == nil or GetWorld().name~= CurrentWorld) then
      ER("`cWarping Back to`0: `2" ..CurrentWorld)
      WP(CurrentWorld)
      Slp(7000)
      Rejoin = true
    else
      if (Rejoin) then
        ER("`cTaking Remote `0#" .. current)
        Rejoin = false
        CH(0)
        Slp(300)
        GR()
        WBH()
        CS(facing, PaX, PaY)
        Slp(300)
        CH(1)
      else
        CS(facing, PaX, PaY)
        local tl = GetTile(PaX + (facing == 48 and -1 or 1), PaY)
        local tb = type(tl) == "table" and tl.fg or Configuration.Magplants.BlockID
        if (tb ~= Configuration.Magplants.BlockID) then
          Limit = Limit + 1
        else
          Limit = 0
        end
        
        if (Limit > 50) then
          ER("`0Magplant #" ..current.. " is `4Empty")
          current = current + 1
          if current > #FM() then
            current = 1
          end
          Limit = 0
          Rejoin = true
          Slp(1000)
        else
          if Configuration.Misc.GemToDL and Limit == 0 then
            if CI(1796) > 0 then
              CD()
              Slp(2000)
              CB()
            end
          end
        end
      end

      if Configuration.Misc.AutoSuck and Limit == 0 then
        AS() 
        Slp(500)
      end
      EC()
    end
  end
end

local success, error = pcall(RN)
  if not success then
    LogToConsole("`4Error`0:" .. error)
  end

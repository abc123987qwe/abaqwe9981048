
--[[Sensitive Part]]--

local Pkt = SendPacket
local PktR = SendPacketRaw
local PktV = SendVariantList
local LtcS = LogToConsole
local Slp = Sleep
local BposX = math.floor(GetLocal().pos.x / 32)
local BposY = math.floor(GetLocal().pos.y / 32)

E = function(log) return LtcS("`0[`^NierCommunity`0] ** : "..log) end

L = function(vl) 
    PktV({[0] = "OnTextOverlay", [1] = (vl ~= nil and vl or "")}) 
end

ER = function(inp)
E(inp)
L(inp)
end

Ingredients ={
  {3472, "Rice"},{4602, "Onion"}, {4588, "Chicken Meat"}, {962, "Tomato"}, {4568, "Salt"}, {4570, "Pepper"}
} 

IslandTile = GetTile(199, 199)

PT = function(x, y, z)
  PktR(false, {
    type = 3,
    value = z,
    px = x,
    py = y,
    x = x * 32,
    y = y * 32
  })
end

OV = function(x)
  PktV({
    [0] = "OnTextOverlay",
    [1] = x
  })
  LtcS(x)
end

PV = function(x, y ,z, a)
  Pkt(2,"action|dialog_return\ndialog_name|homeoven_edit\nx|" .. x .. "|\ny|" .. y .. "|\ncookthis|" .. z .. "|\nbuttonClicked|" .. a)
end

CI = function(x)
  for _, amnt in pairs(GetInventory()) do
    if amnt.id == x then
      return amnt.amount
    end
  end
  return 0 
end

IN = function(x)
  for _, name in pairs(Ingredients) do
    if name[2] == x then
      return name[1]
    end
  end
  return 0
end

CK = function()
  local r = {}
    local p = {GetLocal().pos.x // 32, GetLocal().pos.y // 32}
    local t = 1

    for x = p[1] - 4, p[1] + 4 do
        for y = p[2] - 4, p[2] + 4 do
            if x > -1 and y > -1 and ((IslandTile and 199 and 99) or (not IslandTile and 99 and 53)) then
                local tile = GetTile(x, y)
                if tile and tile.fg == Configuration.MainSettings.OvenID and not (t > Configuration.MainSettings.MaxOven) then
                    t = t + 1
                    table.insert(r, {x, y})
                end
            end
        end
    end

    return r
end

local st = CK()
local oven = {["count"] = Configuration.MainSettings.MaxOven, ["type"] = "low", ["time"] = 1}
local count = 0

P1 = function()
  for _, itm in pairs(st) do
    PV(itm[1], itm[2], IN("Rice"), "low")
    Slp(300)
  end
end

P2 = function()
  for _, itm in pairs(st) do
    PT(itm[1], itm[2], IN("Onion"))
    Slp(150)
    PT(itm[1], itm[2], IN("Chicken Meat"))
    Slp(150)
  end
end

P3 = function()
  for _, itm in pairs(st) do
    PT(itm[1], itm[2], IN("Tomato"))
    Slp(300)
  end
end

P4 = function()
  for _, itm in pairs(st) do
    PT(itm[1], itm[2], 18)
    Slp(300)
  end
end

P5 = function()
  for _, itm in pairs(st) do
    PT(itm[1], itm[2], IN("Salt"))
    Slp(300)
  end
end

P6 = function()
  for _, itm in pairs(st) do
    PT(itm[1], itm[2], IN("Pepper"))
    Slp(300)
  end
end

MN = function()
  OV("`cSection`0: `9Putting Rice")
  P1()
  OV("`cSection`0: `9Putting Salt")
  P5()
  Slp(((33700 - (oven.count * 300)) / oven.time) - (oven.count * 300))
  OV("`cSection`0: `9Putting Onion And Chicken Meat")
  P2()
  OV("`cSection`0: `9Putting Pepper `0[1/2]")
  P6()
  Slp(((36300 - (oven.count * 300)) / oven.time) - (oven.count * 300))
  OV("`cSection`0: `9Putting Tomato")
  P3()
  OV("`cSection`0: `9Putting Pepper `0[2/2]")
  P6()
  Slp(((30000 - (oven.count * 300)) / oven.time) - (oven.count * 300))
  OV("`cSection`0: `9Punch Oven")
  P4()
  count = count + 1
  Pkt(2, "action|input\ntext|`9Cooking Section is Done")
  Slp(1000)
  Pkt(2, "action|input\ntext|`9Please Wait a Moment")
end

BO = function()
  local mainObjects = {
    ["Rice"] = Configuration.MainSettings.MaxOven,
    ["Onion"] = Configuration.MainSettings.MaxOven,
    ["Pepper"] = Configuration.MainSettings.MaxOven,
    ["Chicken Meat"] = Configuration.MainSettings.MaxOven,
    ["Tomato"] = Configuration.MainSettings.MaxOven,
    ["Salt"] = Configuration.MainSettings.MaxOven,
    ["Pepper"] = Configuration.MainSettings.MaxOven * 2,
  }
  
  local missing = {}
  local needed = {}
  local hasAll = true
  
  for name, required in pairs(mainObjects) do
    local id = IN(name)
    if CI(id) < required then
      table.insert(missing, name)
      table.insert(needed, id)
      hasAll = false
    end
  end
  
  return hasAll, needed, missing
end

FP = function(x, y)
  local px = math.floor(GetLocal().pos.x / 32)
  local py = math.floor(GetLocal().pos.y / 32)
  ChangeValue("[C] Modfly", true)
  while math.abs(y - py) > 6 do
    py = py + (y - py > 0 and 6 or -6)
    FindPath(px, py)
    Slp(200)
  end
  
  while math.abs(x - px) > 6 do
    px = px + (x - px > 0 and 6 or -6)
    FindPath(px, py)
    Slp(200)
  end
  
  Slp(50)
  FindPath(x, y)
end

CL = function(id)
  local clSource = nil
  local minDist = math.huge
  local PsX, PsY = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
  for _, obj in pairs(GetObjectList()) do
    if obj.id == id then
      local distance = math.sqrt((obj.pos.x / 32 - PsX)^2 + (obj.pos.y / 32 - PsY)^2)
      if distance < minDist then
        minDist = distance
        clSource = obj
      end
    end
  end
  
  if clSource then
    FP(clSource.pos.x / 32, clSource.pos.y / 32)
    Slp(500)
    return true
  end
  return false
end

TI = function(needed, missing)
    OV("`1Taking`0: `9" .. table.concat(missing, "`0, `9"))
    for i, id in pairs(needed) do
      if CL(id) then
        OV("`2Collected `9" .. missing[i])
      else
        OV("`4Failed to Collect `9" .. missing[i])
      end
      Slp(1000)
    end
    OV("`2Returning To Cook Position")
    FP(BposX, BposY)
    Slp(1000)
end

DP = function()
  if CI(4604) >= 250 then
    OV("`cSection`0: `9Move To Drop Position")
    FP(Configuration.MiscSettings.DropPosition.x - 1, Configuration.MiscSettings.DropPosition.y - 1)
    Slp(1500)
    Pkt(2, "action|dialog_return\ndialog_name|drop\nitem_drop|4604|\nitem_count|250")
    Slp(1500)
    OV("`cSection`0: `2Returning To Cook Position")
    FP(BposX, BposY)
    Slp(1500)
  end
end

if Configuration.MainSettings.MaxOven > 50 then
  ER("`4The Max Oven is 50")
  E("`1Max Oven Is Only 50")
  E("`1Do Not Put Greater Than 50")
  E("`1Please Put The Correct Number of Max Oven")
else
    Pkt(2, "action|input\ntext|`9Cook Arroz `0[`^NierCommunity`0]")
    Slp(2000)
    
    repeat
  local hasIngr, needed, missing = BO()
  if not hasIngr then
    TI(needed, missing)
  end
  DP()
  if hasIngr then
    MN()
    Slp(5000)  -- 5-second cooldown before next loop (adjust as needed)
  end
until not Configuration.BooleanSettings.Loop
end

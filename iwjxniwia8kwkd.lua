local PkT = SendPacket 
local LtcS = LogToConsole
local PktV = SendVariantList
local Slp = Sleep

T = function(log) return LtcS(log) end
L = function(vl) return PktV({[0] = "OnTextOverlay", [1] = (vl ~= nil and vl or "")}) end

ER = function(inp)
 T(inp)
 L(inp)
end

local CanDrop = true
local CanBuy = true

WP = function(x)
  PkT(3, "action|join_request\nname|" ..x)
end

CI = function(id)
    for _, itm in pairs(GetInventory() or {}) do
        if itm.id == id then return itm.amount end
    end
    return 0
end

CG = function()
    local gems = GetPlayerItems().gems
    if gems < Configuration.MainSettings.PackPrice then
        return false
    end
    return true
end

DR = function(id)
  if (GetWorld() == nil or GetWorld().name ~= Worlds) then
    return
   else
    local amount = CI(id)
    if amount >= 200 then
        local itemIndex
        for i, dropId in ipairs(Configuration.ItemSettings.DropId) do
            if dropId == id then
                itemIndex = i
                break
            end
        end

        local tileX = Configuration.MainSettings.DropTile.x - ((itemIndex - 1) * 2)
        local baseY = Configuration.MainSettings.DropTile.y - 1
        local currentY = baseY

        while CI(id) >= amount do
            FindPath(tileX, currentY)
            Slp(500)

            PkT(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..id.."|\nitem_count|"..amount)
            Slp(300)

            if CI(id) < amount then
                T("`cDropped `0: "..GetItemInfo(id).name.." (`cAmount`0: "..amount..")")
                return true
            end

            currentY = currentY - 1
        end
        return false
    end
    return false
end
end

TR = function(id)
    local amount = CI(id)
    if amount > 200 then
        PkT(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..id.."|\nitem_count|"..amount)
        Slp(50)
        T("`cTrashed`0: "..GetItemInfo(id).name.." (`cAmount`0: "..amount..")")
        return true
    end
    return false
end

PkT(2, "action|input\ntext|`cAuto Buy Pack `0by `#@Tomoka")
Slp(2000)

while true do
 if (GetWorld() == nil or GetWorld().name ~= Worlds) then
   ER("`cWarping Back To `0" .. Worlds:upper())
   WP(Worlds)
   Slp(5000)
 else
  if CanBuy then
    if not CG() then
      ER("`4ERROR`0: Stopped The Script Due To Insufficient Gems!")
        return
    end

    PkT(2, "action|buy\nitem|"..Configuration.MainSettings.PackName)
    CanBuy = false
    Slp(Configuration.MainSettings.BuyDelay)
    
    local actions = {}

    for _, id in pairs(Configuration.ItemSettings.DropId) do
        if CI(id) >= 200 then
            table.insert(actions, {func=DR, id=id})
        end
    end
    
    if Configuration.MainSettings.Trash then
        for _, id in pairs(Configuration.ItemSettings.TrashId) do
            if CI(id) > 200 then
                table.insert(actions, {func=TR, id=id})
            end
        end
    end
    
    if #actions > 0 then
        for _, action in ipairs(actions) do
            if action.func then
                action.func(action.id)
                Slp(50)
            end
        end
    end
    
    CanBuy = true
  else
    Slp(50)
  end
end
end

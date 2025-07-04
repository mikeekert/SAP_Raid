local _, SAP = ...
local AceComm = LibStub("AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local del = ":"

local function buildMessage(event, ...)
    local message = string.format("%s%s%s(%s)", event, del, UnitInRaid("player") and "raid"..UnitInRaid("player") or UnitName("player"), "string")
    for _, arg in ipairs({...}) do
        local argType = type(arg)
        if argType == "table" then
            arg = LibSerialize:Serialize(arg)
            arg = LibDeflate:CompressDeflate(arg)
            arg = LibDeflate:EncodeForWoWAddonChannel(arg)
        elseif argType ~= "string" and argType ~= "number" and argType ~= "boolean" then
            arg, argType = "", "string"
        end
        message = string.format("%s%s%s(%s)", message, del, tostring(arg), argType)
    end
    return message
end

function SAP_API:Broadcast(event, channel, ...)
    local message = buildMessage(event, ...)
    if channel == "WHISPER" then
        AceComm:SendCommMessage("SAP_WA_MSG2", message, "RAID")
    else
        AceComm:SendCommMessage("SAP_WA_MSG", message, channel)
    end
end

function SAP:Broadcast(event, channel, ...)
    local message = buildMessage(event, ...)
    if channel == "WHISPER" then
        AceComm:SendCommMessage("SAP_WHISPER", message, "RAID")
    else
        AceComm:SendCommMessage("SAP_MSG", message, channel)
    end
end

local function ReceiveComm(text, chan, sender, whisper, internal)
    local argTable = {strsplit(del, text)}
    local event = table.remove(argTable, 1)
    if (UnitExists(sender) and (UnitInRaid(sender) or UnitInParty(sender))) or (chan == "GUILD" and allowedcomms and allowedcomms[event]) then
        if whisper then
            local target = argTable[2] and argTable[2]:match("^(.*)%(")
            if not (target and UnitIsUnit("player", target)) then return end
            table.remove(argTable, 2)
        end
        local formatted = {}
        local tonext
        for _, v in ipairs(argTable) do
            local val, typ = v:match("^(.*)%((%a+)%)$")
            if tonext and val then val = tonext..val end
            if typ == "number" then val = tonumber(val)
            elseif typ == "boolean" then val = val == "true"
            elseif typ == "table" then
                val = LibDeflate:DecodeForWoWAddonChannel(val)
                val = LibDeflate:DecompressDeflate(val)
                local ok, t = LibSerialize:Deserialize(val)
                val = ok and t or ""
            end
            if val ~= nil and typ then
                table.insert(formatted, val == "" and false or val)
                tonext = nil
            elseif not typ then
                tonext = (tonext or "")..v..del
            end
        end
        SAP:EventHandler(event, false, internal, unpack(formatted))
        WeakAuras.ScanEvents(event, unpack(formatted))
    end
end

AceComm:RegisterComm("SAPWA_MSG", function(_, text, chan, sender) ReceiveComm(text, chan, sender, false, false) end)
AceComm:RegisterComm("SAPWA_MSG2", function(_, text, chan, sender) ReceiveComm(text, chan, sender, true, false) end)
AceComm:RegisterComm("SAP_MSG", function(_, text, chan, sender) ReceiveComm(text, chan, sender, false, true) end)
AceComm:RegisterComm("SAP_WHISPER", function(_, text, chan, sender) ReceiveComm(text, chan, sender, true, true) end)
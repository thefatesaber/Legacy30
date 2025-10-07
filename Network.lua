-- Network communication system for Legacy30
local _, ns = ...
local L30 = ns.Core

local Serializer = LibStub("LibSerialize")
local Compressor = LibStub("LibDeflate")

-- Handle gear check messages
L30.Addon[ns.Protocol.GEAR_CHECK] = function(self, payload, senderName)
    local msgType = payload.type
    local expansion = payload.expansion
    
    if msgType == "REQUEST" then
        self:SendNetworkMessage(
            ns.Protocol.GEAR_CHECK,
            { type = self:GetValidationStatus(expansion) }
        )
    elseif msgType == "REQUEST_DETAILS" then
        self:SendNetworkMessage(
            ns.Protocol.GEAR_DETAILS,
            self:GetValidationDetails(expansion)
        )
    else
        self:ProcessValidationResponse(senderName, msgType)
    end
end

-- Handle detailed gear check responses
L30.Addon[ns.Protocol.GEAR_DETAILS] = function(_, payload, senderName)
    local ui = ns.ValidationUI
    ui:UpdatePlayerDetails(senderName, payload)
end

-- Handle creature kill sync
L30.Addon[ns.Protocol.CREATURE_SYNC] = function(self, creatureGUID)
    local timerFrame = ns.TimerUI
    timerFrame:IncrementCreatureCount(creatureGUID)
end

-- Handle timer start sync
L30.Addon[ns.Protocol.TIMER_START] = function(self, startTimestamp)
    self:AttemptTimerStart(startTimestamp)
end

-- Process incoming messages
function L30.Addon:OnCommReceived(channel, encodedPayload, _, senderName)
    local decodedData = Compressor:DecodeForWoWAddonChannel(encodedPayload)
    if not decodedData then
        self:ErrorMessage("Network decode error")
        return
    end
    
    local decompressedData = Compressor:DecompressDeflate(decodedData)
    if not decompressedData then
        self:ErrorMessage("Network decompression error")
        return
    end
    
    local success, payload = Serializer:Deserialize(decompressedData)
    if not success then
        self:ErrorMessage("Network deserialization error")
        return
    end
    
    if self[channel] then
        self[channel](self, payload, senderName)
    end
end

-- Send message to party
function L30:BroadcastMessage(channel, payload, whisperTarget)
    local serializedData = Serializer:Serialize(payload)
    local compressedData = Compressor:CompressDeflate(serializedData)
    local encodedData = Compressor:EncodeForWoWAddonChannel(compressedData)
    
    local destination = whisperTarget and "WHISPER" or "PARTY"
    
    self:SendCommMessage(
        channel,
        encodedData,
        destination,
        whisperTarget,
        "BULK"
    )
end
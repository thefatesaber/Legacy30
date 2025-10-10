-- ============================================================================
-- Encryption.lua
-- L30 RC4 EXPORT WITH BASE64
-- Pure Lua 5.1, WoW-safe, no external libraries
-- ============================================================================

local _, ns = ...
local L30 = ns.Core

-- Default dev key (only used if SavedVariables is empty on first load)
local DEFAULT_DEV_KEY = "L30-Dev-Key-2025"

-- ============================================================================
-- RC4 IMPLEMENTATION (KSA + PRGA, no drop)
-- ============================================================================

local function rc4_ksa(key)
    local S = {}
    for i = 0, 255 do
        S[i] = i
    end
    
    local j = 0
    local keyLen = #key
    
    for i = 0, 255 do
        j = (j + S[i] + key:byte((i % keyLen) + 1)) % 256
        S[i], S[j] = S[j], S[i]
    end
    
    return S
end

local function rc4_prga(S, data)
    local i, j = 0, 0
    local result = {}
    
    for k = 1, #data do
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        local K = S[(S[i] + S[j]) % 256]
        result[k] = string.char(bit.bxor(data:byte(k), K))
    end
    
    return table.concat(result)
end

local function rc4_encrypt(key, plaintext)
    local S = rc4_ksa(key)
    return rc4_prga(S, plaintext)
end

-- ============================================================================
-- BASE64 ENCODING (Standard with padding)
-- ============================================================================

local base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_encode(data)
    local result = {}
    
    for i = 1, #data, 3 do
        local b1, b2, b3 = data:byte(i, i + 2)
        b2 = b2 or 0
        b3 = b3 or 0
        
        local n = b1 * 65536 + b2 * 256 + b3
        
        local c1 = bit.rshift(n, 18)
        local c2 = bit.band(bit.rshift(n, 12), 63)
        local c3 = bit.band(bit.rshift(n, 6), 63)
        local c4 = bit.band(n, 63)
        
        result[#result + 1] = base64_chars:sub(c1 + 1, c1 + 1)
        result[#result + 1] = base64_chars:sub(c2 + 1, c2 + 1)
        result[#result + 1] = base64_chars:sub(c3 + 1, c3 + 1)
        result[#result + 1] = base64_chars:sub(c4 + 1, c4 + 1)
    end
    
    local encoded = table.concat(result)
    
    -- Add padding
    local padding = (3 - (#data % 3)) % 3
    if padding == 1 then
        encoded = encoded:sub(1, -2) .. "="
    elseif padding == 2 then
        encoded = encoded:sub(1, -3) .. "=="
    end
    
    return encoded
end

-- ============================================================================
-- NONCE GENERATION
-- ============================================================================

local function generate_nonce()
    -- WoW's random is already seeded, just use it directly
    local nonce = random(100000, 999999)
    return string.format("%06d", nonce)
end

-- ============================================================================
-- CANONICAL JSON SERIALIZATION
-- ============================================================================

local function escape_json_string(str)
    str = str:gsub('\\', '\\\\')
    str = str:gsub('"', '\\"')
    str = str:gsub('\n', '\\n')
    str = str:gsub('\r', '\\r')
    str = str:gsub('\t', '\\t')
    return str
end

local function serialize_value(val)
    local t = type(val)
    if t == "string" then
        return '"' .. escape_json_string(val) .. '"'
    elseif t == "number" then
        return tostring(val)
    elseif t == "boolean" then
        return tostring(val)
    elseif t == "nil" then
        return "null"
    elseif t == "table" then
        -- Check if it's an array
        local isArray = true
        local maxIndex = 0
        for k, v in pairs(val) do
            if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
                isArray = false
                break
            end
            maxIndex = math.max(maxIndex, k)
        end
        
        if isArray then
            local items = {}
            for i = 1, maxIndex do
                items[i] = serialize_value(val[i])
            end
            return "[" .. table.concat(items, ",") .. "]"
        else
            return "null" -- Objects handled separately for ordering
        end
    end
    return "null"
end

local function serialize_canonical_json(data)
    -- Build JSON with exact key order
    local parts = {}
    
    parts[#parts + 1] = '{"generatedAt":' .. serialize_value(data.generatedAt)
    parts[#parts + 1] = ',"dungeonName":' .. serialize_value(data.dungeonName)
    parts[#parts + 1] = ',"difficulty":' .. serialize_value(data.difficulty)
    parts[#parts + 1] = ',"startTime":' .. serialize_value(data.startTime)
    parts[#parts + 1] = ',"endTime":' .. serialize_value(data.endTime)
    parts[#parts + 1] = ',"durationSeconds":' .. serialize_value(data.durationSeconds)
    
    -- Players array
    parts[#parts + 1] = ',"players":['
    local playerParts = {}
    for i, player in ipairs(data.players or {}) do
        local p = '{"name":' .. serialize_value(player.name)
        p = p .. ',"itemLevel":' .. serialize_value(player.itemLevel)
        p = p .. ',"mobsKilled":' .. serialize_value(player.mobsKilled)
        p = p .. ',"deaths":' .. serialize_value(player.deaths)
        p = p .. '}'
        playerParts[i] = p
    end
    parts[#parts + 1] = table.concat(playerParts, ",")
    parts[#parts + 1] = ']'
    
    parts[#parts + 1] = ',"totalDeaths":' .. serialize_value(data.totalDeaths)
    parts[#parts + 1] = '}'
    
    return table.concat(parts)
end

-- ============================================================================
-- ENCRYPTION MODULE
-- ============================================================================

ns.Encryption = {}
local Encrypt = ns.Encryption

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function Encrypt:Initialize()
    -- Ensure SavedVariables table exists
    if not L30_ExportState then
        L30_ExportState = {}
    end
    
    -- Set default dev key if none exists
    if not L30_ExportState.baseKey or L30_ExportState.baseKey == "" then
        L30_ExportState.baseKey = DEFAULT_DEV_KEY
        L30:InfoMessage("Using default dev key. Set your own with /l30 key <your-key>")
    end
end

-- ============================================================================
-- KEY MANAGEMENT
-- ============================================================================

function Encrypt:SetKey(key)
    if not key or key == "" then
        return false, "Key cannot be empty"
    end
    
    L30_ExportState.baseKey = key
    return true
end

function Encrypt:GetKey()
    return L30_ExportState.baseKey
end

function Encrypt:HasKey()
    return L30_ExportState.baseKey and L30_ExportState.baseKey ~= ""
end

-- ============================================================================
-- EXPORT FUNCTION
-- ============================================================================

function Encrypt:ExportRun(runData)
    -- Check if key exists
    if not self:HasKey() then
        return nil, "No key. Use /l30 key <your-key>"
    end
    
    -- Generate nonce
    local nonce = generate_nonce()
    
    -- Build session key
    local sessionKey = L30_ExportState.baseKey .. "|" .. nonce
    
    -- Calculate total deaths
    local totalDeaths = 0
    for _, player in ipairs(runData.players or {}) do
        totalDeaths = totalDeaths + (player.deaths or 0)
    end
    
    -- Build canonical payload
    local payload = {
        generatedAt = date("!%Y-%m-%dT%H:%M:%SZ"),
        dungeonName = runData.dungeonName or "Unknown",
        difficulty = runData.difficulty or "Normal",
        startTime = runData.startTime or "",
        endTime = runData.endTime or "",
        durationSeconds = runData.durationSeconds or 0,
        players = runData.players or {},
        totalDeaths = totalDeaths
    }
    
    -- Serialize to canonical JSON
    local jsonText = serialize_canonical_json(payload)
    
    -- Encrypt with RC4
    local ciphertext = rc4_encrypt(sessionKey, jsonText)
    
    -- Encode to Base64
    local base64Cipher = base64_encode(ciphertext)
    
    -- Format output: L30R1.{nonce}.{base64Cipher}
    local exportString = string.format("L30R1.%s.%s", nonce, base64Cipher)
    
    return exportString
end
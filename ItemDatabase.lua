-- ItemDatabase.lua
-- Item database management for Legacy30
-- Tracks item information for speedrunning analysis

local ADDON_NAME, ns = ...
local ItemDB = {}
ns.ItemDB = ItemDB

-- Database structure
ItemDB.cache = {}
ItemDB.loaded = false
ItemDB.pending = {}

-- Initialize the item database
function ItemDB:Initialize()
    -- Set up saved variables
    if not Legacy30ItemDB then
        Legacy30ItemDB = {
            items = {},
            version = ns.Version,
            lastUpdate = time()
        }
    end
    
    self.data = Legacy30ItemDB
    self.loaded = true
    
    ns.Core:InfoMessage("Item database initialized with %d items", self:GetItemCount())
end

-- Get item count
function ItemDB:GetItemCount()
    if not self.data or not self.data.items then return 0 end
    
    local count = 0
    for _ in pairs(self.data.items) do
        count = count + 1
    end
    return count
end

-- Cache an item's information
function ItemDB:CacheItem(itemID, itemData)
    if not itemID then return false end
    
    self.cache[itemID] = {
        data = itemData,
        timestamp = time()
    }
    
    return true
end

-- Get item from cache or database
function ItemDB:GetItem(itemID)
    if not itemID then return nil end
    
    -- Check cache first
    if self.cache[itemID] then
        return self.cache[itemID].data
    end
    
    -- Check database
    if self.data and self.data.items and self.data.items[itemID] then
        local itemData = self.data.items[itemID]
        self:CacheItem(itemID, itemData)
        return itemData
    end
    
    return nil
end

-- Store item information
function ItemDB:StoreItem(itemID, itemData)
    if not itemID or not itemData then return false end
    
    if not self.data or not self.data.items then
        self.data = { items = {} }
    end
    
    self.data.items[itemID] = itemData
    self:CacheItem(itemID, itemData)
    
    return true
end

-- Extract item ID from item link
function ItemDB:GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    
    local itemID = tonumber(itemLink:match("item:(%d+)"))
    return itemID
end

-- Request item information from server
function ItemDB:RequestItemInfo(itemID, callback)
    if not itemID then return false end
    
    -- Check if we already have this item
    local cached = self:GetItem(itemID)
    if cached then
        if callback then callback(itemID, cached) end
        return true
    end
    
    -- Check if already pending
    if self.pending[itemID] then
        if callback then
            table.insert(self.pending[itemID].callbacks, callback)
        end
        return true
    end
    
    -- Create pending request
    self.pending[itemID] = {
        callbacks = callback and { callback } or {},
        timestamp = time()
    }
    
    -- Create item object to force server query
    local item = Item:CreateFromItemID(itemID)
    if not item then return false end
    
    item:ContinueOnItemLoad(function()
        self:OnItemLoaded(itemID)
    end)
    
    return true
end

-- Handle item loaded from server
function ItemDB:OnItemLoaded(itemID)
    if not self.pending[itemID] then return end
    
    -- Get item information
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, 
          itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, 
          sellPrice, classID, subclassID, bindType = C_Item.GetItemInfo(itemID)
    
    if itemName then
        local itemData = {
            name = itemName,
            link = itemLink,
            rarity = itemRarity,
            itemLevel = itemLevel,
            minLevel = itemMinLevel,
            type = itemType,
            subType = itemSubType,
            stackCount = itemStackCount,
            equipLoc = itemEquipLoc,
            icon = iconFileDataID,
            sellPrice = sellPrice,
            classID = classID,
            subclassID = subclassID,
            bindType = bindType,
            timestamp = time()
        }
        
        -- Store the item
        self:StoreItem(itemID, itemData)
        
        -- Execute callbacks
        local pending = self.pending[itemID]
        for _, callback in ipairs(pending.callbacks) do
            callback(itemID, itemData)
        end
    end
    
    -- Clear pending request
    self.pending[itemID] = nil
end

-- Batch request multiple items
function ItemDB:RequestItems(itemIDs, callback)
    if not itemIDs or type(itemIDs) ~= "table" then return false end
    
    local completed = 0
    local total = #itemIDs
    local results = {}
    
    for _, itemID in ipairs(itemIDs) do
        self:RequestItemInfo(itemID, function(id, data)
            completed = completed + 1
            results[id] = data
            
            if completed >= total and callback then
                callback(results)
            end
        end)
    end
    
    return true
end

-- Get items from equipment links
function ItemDB:ProcessEquipment(equipment)
    if not equipment or type(equipment) ~= "table" then return {} end
    
    local itemIDs = {}
    for slot, link in pairs(equipment) do
        if link then
            local itemID = self:GetItemIDFromLink(link)
            if itemID then
                table.insert(itemIDs, itemID)
            end
        end
    end
    
    return itemIDs
end

-- Analyze equipment for speedrunning
function ItemDB:AnalyzeEquipment(equipment)
    local analysis = {
        totalItems = 0,
        averageItemLevel = 0,
        itemLevels = {},
        sockets = 0,
        legendary = {},
        sets = {}
    }
    
    if not equipment then return analysis end
    
    local totalItemLevel = 0
    local itemCount = 0
    
    for slot, link in pairs(equipment) do
        if link then
            local itemID = self:GetItemIDFromLink(link)
            if itemID then
                local itemData = self:GetItem(itemID)
                if itemData then
                    analysis.totalItems = analysis.totalItems + 1
                    
                    if itemData.itemLevel then
                        totalItemLevel = totalItemLevel + itemData.itemLevel
                        itemCount = itemCount + 1
                        table.insert(analysis.itemLevels, itemData.itemLevel)
                    end
                    
                    -- Track legendary items
                    if itemData.rarity == 5 then -- Legendary
                        table.insert(analysis.legendary, itemID)
                    end
                end
            end
        end
    end
    
    if itemCount > 0 then
        analysis.averageItemLevel = totalItemLevel / itemCount
    end
    
    return analysis
end

-- Clear old cache entries
function ItemDB:ClearOldCache(maxAge)
    maxAge = maxAge or 3600 -- Default 1 hour
    local currentTime = time()
    local cleared = 0
    
    for itemID, cached in pairs(self.cache) do
        if currentTime - cached.timestamp > maxAge then
            self.cache[itemID] = nil
            cleared = cleared + 1
        end
    end
    
    if cleared > 0 then
        ns.Core:InfoMessage("Cleared %d old cache entries", cleared)
    end
end

-- Export item database
function ItemDB:Export()
    if not self.data or not self.data.items then return {} end
    return self.data.items
end

-- Import item database
function ItemDB:Import(items)
    if not items or type(items) ~= "table" then return false end
    
    local count = 0
    for itemID, itemData in pairs(items) do
        if self:StoreItem(itemID, itemData) then
            count = count + 1
        end
    end
    
    ns.Core:InfoMessage("Imported %d items", count)
    return true
end

-- Get database statistics
function ItemDB:GetStats()
    return {
        totalItems = self:GetItemCount(),
        cacheSize = self:GetCacheSize(),
        pendingRequests = self:GetPendingCount(),
        lastUpdate = self.data and self.data.lastUpdate or 0
    }
end

-- Get cache size
function ItemDB:GetCacheSize()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    return count
end

-- Get pending request count
function ItemDB:GetPendingCount()
    local count = 0
    for _ in pairs(self.pending) do
        count = count + 1
    end
    return count
end

-- Clear all cache
function ItemDB:ClearCache()
    self.cache = {}
    ns.Core:InfoMessage("Item cache cleared")
end

-- Reset database
function ItemDB:Reset()
    if Legacy30ItemDB then
        Legacy30ItemDB.items = {}
        Legacy30ItemDB.lastUpdate = time()
    end
    
    self.cache = {}
    self.pending = {}
    
    ns.Core:InfoMessage("Item database reset")
end
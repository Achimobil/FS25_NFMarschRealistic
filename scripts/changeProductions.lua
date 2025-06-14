ChangeProductionPoint = {};
ChangeProductionPoint.Debug = false;

---Print the text to the log. Example: ChangeProductionPoint.DebugText("Alter: %s", age)
-- @param string text the text to print formated
-- @param any ... format parameter
function ChangeProductionPoint.DebugText(text, ...)
    if not ChangeProductionPoint.Debug then return end
    print("ChangeProductionPointDebug: " .. string.format(text, ...));
end

function ChangeProductionPoint:onLoad(superFunc, savegame)
    local xmlFile = self.xmlFile;

    local skip = false;
    if string.find(xmlFile.filename, "Futterfabrik") or string.find(xmlFile.filename, "bga") then
        ChangeProductionPoint.DebugText("ChangeProductionPoint ignore xml: %s", xmlFile.filename);
        skip = true;
    end

    if (string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") or string.find(xmlFile.filename, "FS25_NFMarsch4fach")) and not skip then
        ChangeProductionPoint.DebugText("ChangeProductionPoint xmlFile: %s", xmlFile.filename);

        local rootName = xmlFile:getRootName();

        ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, rootName..".storeData.price", 5);

        xmlFile:iterate(rootName..".productionPoint.productions.production",function(_, key)
            ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, key.."#cyclesPerHour", 5);
            ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, key.."#costsPerActiveHour", 5);
        end)

        xmlFile:iterate(rootName..".productionPoint.storage.capacity",function(_, key)
            ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, key.."#capacity", 5);
        end)

--         DebugUtil.printTableRecursively(xmlFile,"_",0,1)

    end

    superFunc(self, savegame)
end

function ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, path, divisor)
    local oldValue = xmlFile:getValue(path);
    local newValue = oldValue / divisor;
    ChangeProductionPoint.DebugText("Change '%s' from %s to %s", path, oldValue, newValue);
    xmlFile:setValue(path, newValue);
end

PlaceableProductionPoint.onLoad = Utils.overwrittenFunction(PlaceableProductionPoint.onLoad, ChangeProductionPoint.onLoad)




StoreManagerExtension = {};
StoreManagerExtension.Debug = false;

---Print the text to the log. Example: StoreManagerExtension.DebugText("Alter: %s", age)
-- @param string text the text to print formated
-- @param any ... format parameter
function StoreManagerExtension.DebugText(text, ...)
    if not StoreManagerExtension.Debug then return end
    print("StoreManagerExtensionDebug: " .. string.format(text, ...));
end

function StoreManagerExtension:loadItem(superFunc, rawXMLFilename, baseDir, customEnvironment, isMod, isBundleItem, dlcTitle, extraContentId, ignoreAdd)

    local storeItem = superFunc(self, rawXMLFilename, baseDir, customEnvironment, isMod, isBundleItem, dlcTitle, extraContentId, ignoreAdd);

    if storeItem ~= nil and customEnvironment ~= nil then
        StoreManagerExtension.DebugText("StoreManagerExtension rawXMLFilename: %s, customEnvironment %s", rawXMLFilename, customEnvironment);
        if (string.find(customEnvironment, "FS25_Fed_Produktions_Pack") ~= nil or string.find(customEnvironment, "FS25_NFMarsch4fach") ~= nil) then

            -- nicht alles billiger machen. Paletten hier ausnehmen
            if string.find(rawXMLFilename:upper(), "PALETTEN") == nil then
                -- nur die BGA die vorplatziert sind, sind zu teuer, andere dürfen nicht billiger werden
                local isBga = string.find(rawXMLFilename, "bga") ~= nil;
                local isMapBga = isBga and string.find(rawXMLFilename, "NFMarsch/placeables/sellingStations") ~= nil;
                if isMapBga then
                    StoreManagerExtension.DebugText("Change Map BGA store item: %s", rawXMLFilename);
                    storeItem.price = storeItem.price / 10;
                    storeItem.dailyUpkeep = storeItem.dailyUpkeep / 5;
                elseif not isBga and storeItem.categoryName == "PRODUCTIONPOINTS" then
                    StoreManagerExtension.DebugText("Change Non BGA store item: %s", rawXMLFilename);
                    storeItem.price = storeItem.price / 5;
                    storeItem.dailyUpkeep = storeItem.dailyUpkeep / 5;
                end
--                 DebugUtil.printTableRecursively(storeItem,"_",0,1)
            end
        end

        -- Paletten hier ändern wenn sie in den Storemanager geladen werden.
        -- hierbei schema "vehicle" und pfad zur limitierun nutzen
        -- das ist notwendig für das auslagern über den production storage control mod
--         if (storeItem.xmlSchema.name == "vehicle") and string.find(storeItem.rawXMLFilename:upper(), "PALETTEN") ~= nil then
--             DebugUtil.printTableRecursively(storeItem.configurations,"_",0,2)
--         end
    end

    return storeItem;
end

StoreManager.loadItem = Utils.overwrittenFunction(StoreManager.loadItem, StoreManagerExtension.loadItem)









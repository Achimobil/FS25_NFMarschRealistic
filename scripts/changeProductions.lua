
ChangeProductionPoint = {}

function ChangeProductionPoint:onLoad(superFunc, savegame)
    local xmlFile = self.xmlFile;

    if (string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") or string.find(xmlFile.filename, "FS25_NFMarsch4fach")) and not string.find(xmlFile.filename, "bga") then

        Logging.devInfo("ChangeProductionPoint xmlFile: %s", xmlFile.filename);

        local rootName = xmlFile:getRootName();

--         ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, rootName..".storeData.dailyUpkeep", 5);
        ChangeProductionPoint.ChangeXmlValueByDivisor(xmlFile, rootName..".storeData.price", 5); -- geht nicht

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
    Logging.devInfo("Change '%s' from %s to %s", path, oldValue, newValue);
    xmlFile:setValue(path, newValue);
end

PlaceableProductionPoint.onLoad = Utils.overwrittenFunction(PlaceableProductionPoint.onLoad, ChangeProductionPoint.onLoad)




StoreManagerExtension = {}
function StoreManagerExtension:loadItem(superFunc, rawXMLFilename, baseDir, customEnvironment, isMod, isBundleItem, dlcTitle, extraContentId, ignoreAdd)

    local storeItem = superFunc(self, rawXMLFilename, baseDir, customEnvironment, isMod, isBundleItem, dlcTitle, extraContentId, ignoreAdd);

    if storeItem ~= nil and customEnvironment ~= nil then
        Logging.devInfo("StoreManagerExtension rawXMLFilename: %s, customEnvironment %s", rawXMLFilename, customEnvironment);
        if (string.find(customEnvironment, "FS25_Fed_Produktions_Pack") ~= nil or string.find(customEnvironment, "FS25_NFMarsch4fach") ~= nil) then

            -- nicht alles billiger machen. Paletten hier ausnehmen
            if string.find(rawXMLFilename:upper(), "PALETTEN") == nil then
                -- nur die BGA die vorplatziert sind, sind zu teuer, andere dürfen nicht billiger werden
                local isBga = string.find(rawXMLFilename, "bga") ~= nil;
                local isMapBga = isBga and string.find(rawXMLFilename, "NFMarsch/placeables/sellingStations") ~= nil;
                if isMapBga then
                    Logging.devInfo("Change Map BGA store item: %s", rawXMLFilename);
                    storeItem.price = storeItem.price / 10;
                    storeItem.dailyUpkeep = storeItem.dailyUpkeep / 5;
                elseif not isBga and storeItem.categoryName == "PRODUCTIONPOINTS" then
                    Logging.devInfo("Change Non BGA store item: %s", rawXMLFilename);
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









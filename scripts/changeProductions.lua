
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

        DebugUtil.printTableRecursively(xmlFile,"_",0,1)

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
        Logging.devInfo("ChangeProductionPoint rawXMLFilename: %s, customEnvironment %s", rawXMLFilename, customEnvironment);
        if (string.find(customEnvironment, "FS25_Fed_Produktions_Pack") or string.find(customEnvironment, "FS25_NFMarsch4fach")) and not string.find(rawXMLFilename, "bga") then
            storeItem.price = storeItem.price / 5;
            storeItem.dailyUpkeep = storeItem.dailyUpkeep / 5;
        end
    end

    return storeItem;
end

StoreManager.loadItem = Utils.overwrittenFunction(StoreManager.loadItem, StoreManagerExtension.loadItem)









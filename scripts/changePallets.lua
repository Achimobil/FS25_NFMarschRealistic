ChangePalletsExtension = {};
-- Logging.info("ChangePalletsExtension");


function ChangePalletsExtension:loadFinished(superFunc)
--     Logging.info("ChangePalletsExtension:loadFinished");

    local xmlFile = self.xmlFile;

--     filename = "FS25_Fed_Produktions_Pack/Paletten"
    Logging.devInfo("ChangePalletsExtension xmlFile: %s", xmlFile.filename);
    if (string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") ~= nil or string.find(xmlFile.filename, "FS25_NFMarsch4fach") ~= nil) and string.find(xmlFile.filename:upper(), "PALETTEN") ~= nil then
--         Logging.devInfo("ChangePalletsExtension xmlFile: " .. xmlFile.filename);

        local rootName = xmlFile:getRootName();

        xmlFile:iterate(rootName..".fillUnit.fillUnitConfigurations.fillUnitConfiguration",function(_, key)
            xmlFile:iterate(key..".fillUnits.fillUnit", function(_, fillUnitKey)
                local capacity = xmlFile:getValue(fillUnitKey.."#capacity");
                Logging.devInfo("ChangePalletsExtension capacity: " .. capacity);

                if capacity == 5000 then
                    Logging.devInfo("Change PalletsExtension xmlFile: " .. xmlFile.filename);
                    xmlFile:setValue(fillUnitKey.."#capacity", 1000);
                end
            end)
        end)
    end

    superFunc(self);
end

-- Vehicle.loadFinished = Utils.overwrittenFunction(Vehicle.loadFinished, ChangePalletsExtension.loadFinished)

-- überschreiben, da diese funktion bestimmt welche menge zum auslagern benutzt wir bei produktionen
function ChangePalletsExtension.getCapacityFromXml(xmlFile, superFunc)
    local capacity = superFunc(xmlFile);

    if (string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") ~= nil or string.find(xmlFile.filename, "FS25_NFMarsch4fach") ~= nil) and string.find(xmlFile.filename:upper(), "PALETTEN") ~= nil and capacity == 5000 then
        Logging.devInfo("ChangePalletsExtension.getCapacityFromXml change %s", xmlFile.filename);
        capacity = 1000;
    end

    return capacity
end

FillUnit.getCapacityFromXml = Utils.overwrittenFunction(FillUnit.getCapacityFromXml, ChangePalletsExtension.getCapacityFromXml)

function ChangePalletsExtension:loadFillUnitFromXML(superFunc, xmlFile, key, entry, index)
--     Logging.devInfo("ChangePalletsExtension.loadFillUnitFromXML %s, %s, %s, %s, %s", superFunc, xmlFile, key, entry, index);

    local result = superFunc(self, xmlFile, key, entry, index);

    if (string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") ~= nil or string.find(xmlFile.filename, "FS25_NFMarsch4fach") ~= nil) and string.find(xmlFile.filename:upper(), "PALETTEN") ~= nil and entry.capacity == 5000 then
        Logging.devInfo("ChangePalletsExtension.loadFillUnitFromXML change %s", xmlFile.filename);
--         DebugUtil.printTableRecursively(entry,"_",0,1)
        entry.capacity = 1000;
    end

    return result;
end

FillUnit.loadFillUnitFromXML = Utils.overwrittenFunction(FillUnit.loadFillUnitFromXML, ChangePalletsExtension.loadFillUnitFromXML)

-- für den Baumarkt beim Kaufen, da dort die Preise für 5000er paletten sind und die paletten anders geladen werden
NfmrPlaceablePalletBuyingStationExtension = {}

function NfmrPlaceablePalletBuyingStationExtension:onLoad(superFunc, savegame)
--     Logging.info("NfmrPlaceablePalletBuyingStationExtension.onLoad");
--     local spec = self.spec_palletBuyingStation
--     DebugUtil.printTableRecursively(spec.pallets,"_",0,1)

    local key = "placeable.palletBuyingStation"
    local i = 0
    while true do
        local fillTypeKey = string.format(key..".fillType(%d)", i)
        if not self.xmlFile:hasProperty(fillTypeKey) then
            break
        end

        local fillTypeStr = self.xmlFile:getValue(fillTypeKey.."#name")
        local fillType = g_fillTypeManager:getFillTypeByName(fillTypeStr)

        if fillType ~= nil then
--             local fillTypeIndex = fillType.index
            local palletFilename = fillType.palletFilename

            if (string.find(palletFilename, "FS25_Fed_Produktions_Pack") ~= nil or string.find(palletFilename, "FS25_NFMarsch4fach") ~= nil) then
--                 local storeItem = g_storeManager:getItemByXMLFilename(palletFilename)
--                 DebugUtil.printTableRecursively(storeItem.configurations,"_",0,2)
                local priceScale = self.xmlFile:getValue(fillTypeKey.."#priceScale", 1.0)
                self.xmlFile:setValue(fillTypeKey.."#priceScale", priceScale / 5)
            end
        end
        i = i + 1
    end

    return superFunc(self, savegame);
end

PlaceablePalletBuyingStation.onLoad = Utils.overwrittenFunction(PlaceablePalletBuyingStation.onLoad, NfmrPlaceablePalletBuyingStationExtension.onLoad)
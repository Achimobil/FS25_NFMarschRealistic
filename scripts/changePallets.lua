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
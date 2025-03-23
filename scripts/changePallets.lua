ChangePalletsExtension = {};
-- Logging.info("ChangePalletsExtension");


function ChangePalletsExtension:loadFinished(superFunc)
--     Logging.info("ChangePalletsExtension:loadFinished");

    local xmlFile = self.xmlFile;

--     filename = "FS25_Fed_Produktions_Pack/Paletten"
    if string.find(xmlFile.filename, "FS25_Fed_Produktions_Pack") and string.find(xmlFile.filename, "Paletten")  then
--         Logging.info("ChangePalletsExtension xmlFile: " .. xmlFile.filename);

        local rootName = xmlFile:getRootName();

        xmlFile:iterate(rootName..".fillUnit.fillUnitConfigurations.fillUnitConfiguration",function(_, key)
            xmlFile:iterate(key..".fillUnits.fillUnit", function(_, fillUnitKey)
                local capacity = xmlFile:getValue(fillUnitKey.."#capacity");
--                 Logging.info("ChangePalletsExtension capacity: " .. capacity);

                if capacity == 5000 then
                    xmlFile:setValue(fillUnitKey.."#capacity", 1000);
                end
            end)
        end)

--         local height = xmlFile:getValue("vehicle.base.size#height");
--         Logging.info("ChangePalletsExtension height: %s", height);
--         if height == nil then
--             xmlFile:setValue("vehicle.base.size#height", 0.9);
--         end
    end

    superFunc(self);
end

Vehicle.loadFinished = Utils.overwrittenFunction(Vehicle.loadFinished, ChangePalletsExtension.loadFinished)
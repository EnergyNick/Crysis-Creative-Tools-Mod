Script.ReloadScript("SCRIPTS/common.lua");

local function copyPresetTemplateDataToPreset(preset, template)
	for key, value in pairs(template) do
		-- Not service field or if in preset that field is override
		if key ~= "key" and key ~= "description" and not preset[key] then
			preset[key] = value
		end
	end
end

function TryFindAndApplyTemplateToPreset(preset, templates)
    if not preset.templateKey then
        return false
    end

    for _, template in pairs(templates) do
        if template.key == preset.templateKey then
			copyPresetTemplateDataToPreset(preset, template)
			return true
		end
    end

	return false
end

function CopyTableWithMetadata(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[CopyTableWithMetadata(k, s)] = CopyTableWithMetadata(v, s) end
    return res
end

function PrintTable(table)
	local toPrint = {}
	for key, value in pairs(table) do
		table.insert(toPrint, key)
		if count(toPrint) > 8 then
			local text = ""
			for i, value in pairs(toPrint) do
				text = text..value..", "
			end
			HUD.DrawStatusText(text)
			toPrint = {}
		end
	end
end

-------------------------------------------------------------------------------
-- Reference of tableManager argument:
-- {
-- 	table = {},
-- 	currentElementIndex = 1,
-- 	currentCategoryIndex = 1,
-- }

function GetCurrentCategory(tableManager)
	if tableManager.table then
		return tableManager.table[tableManager.currentCategoryIndex]
	end
	return nil
end

function ResetCategoryAndIndex(tableManager)
	tableManager.currentCategoryIndex = 1
	tableManager.currentElementIndex = 1
end

function GetElementInCategory(tableManager, index)
	local category = GetCurrentCategory(tableManager)
	if (category) then
		return category.categoryElements[index]
	end
	return nil
end

function GetCurrentElement(tableManager)
	return GetElementInCategory(tableManager, tableManager.currentElementIndex)
end

function GetCurrentElementOrReset(tableManager)
	local item = GetCurrentElement(tableManager)
	if not item then
		ResetCategoryAndIndex(tableManager)
		item = GetCurrentElement(tableManager)
	end
	return item
end

function IncrementElementIndexCycled(tableManager)
	local newIndex = tableManager.currentElementIndex + 1

	local category = GetCurrentCategory(tableManager)
	if not category then
		ResetCategoryAndIndex(tableManager)
		return 1
	end

	local currentCategoryCount = count(category.categoryElements)
	if (newIndex > currentCategoryCount) then
		newIndex = 1
	end
	tableManager.currentElementIndex = newIndex

	return newIndex
end

function IncrementCategoryIndexCycled(tableManager)
	local newIndex = tableManager.currentCategoryIndex + 1
	if (newIndex > count(tableManager.table)) then
		newIndex = 1
	end
	tableManager.currentElementIndex = 1
	tableManager.currentCategoryIndex = newIndex

	return newIndex
end

function TryFindElementAndSetByName(tableManager, elementName)
	for catInd, category in pairs(tableManager.table) do
		for i, value in pairs(category.categoryElements) do

			if value.name == elementName then
				tableManager.currentElementIndex = i
				tableManager.currentCategoryIndex = catInd
				return true
			end
		end
	end

	return false
end


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
	local printed = {}
	for key, v in pairs(table) do
		table.insert(printed, key)
		if count(printed) > 8 then
			local text = ""
			for i, val in pairs(printed) do
				text = text..val..", "
			end
			HUD.DrawStatusText(text)
			System.Log(text)
			printed = {}
		end
	end
end

local function countIndexElements(table)
	local count = 0;
	if (table) then
		for i,v in ipairs(table) do
			count = count+1;
		end
	end	
	return count;
end

-------------------------------------------------------------------------------
-- Reference of tableManager argument:
-- {
--	groups = {},
-- 	currentGroupIndex = 1,
-- 	currentCategoryIndex = 1,
-- 	currentElementIndex = 1,
-- }

function SwitchToNextGroupCycled(tableManager)
	if not tableManager.groups then
		return
	end

	local tableCount = countIndexElements(tableManager.groups)
	if tableCount == 1 then
		return
	end

	local newIndex = tableManager.currentGroupIndex + 1
	if newIndex > tableCount then
		newIndex = 1
	end

	ResetCategoryAndIndex(tableManager)
	tableManager.currentGroupIndex = newIndex
end

function GetCurrentGroup(tableManager)
	if not tableManager.groups then
		return nil
	end

	return tableManager.groups[tableManager.currentGroupIndex]
end

function GetCurrentCategory(tableManager)
	local group = GetCurrentGroup(tableManager)
	if group then
		return group[tableManager.currentCategoryIndex]
	end
	return nil
end

function GetElementInCategory(tableManager, index)
	local category = GetCurrentCategory(tableManager)
	if (category) then
		return category[index]
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

function ResetCategoryAndIndex(tableManager)
	tableManager.currentCategoryIndex = 1
	tableManager.currentElementIndex = 1
end

function IncrementElementIndexCycled(tableManager)
	local category = GetCurrentCategory(tableManager)
	if not category then
		ResetCategoryAndIndex(tableManager)
		return 1
	end

	local currentCategoryCount = countIndexElements(category)
	local newIndex = tableManager.currentElementIndex + 1
	if (newIndex > currentCategoryCount) then
		newIndex = 1
	end
	tableManager.currentElementIndex = newIndex

	return newIndex
end

function IncrementCategoryIndexCycled(tableManager)
	local newIndex = tableManager.currentCategoryIndex + 1
	if (newIndex > countIndexElements(GetCurrentGroup(tableManager))) then
		newIndex = 1
	end
	tableManager.currentElementIndex = 1
	tableManager.currentCategoryIndex = newIndex

	return newIndex
end

function TryFindElementAndSetByName(tableManager, elementName)
	local currentTable = GetCurrentGroup(tableManager)
	if not currentTable then
		return nil
	end
	for catInd, category in ipairs(currentTable) do
		for i, value in ipairs(category) do

			if value.name == elementName then
				tableManager.currentElementIndex = i
				tableManager.currentCategoryIndex = catInd
				return true
			end
		end
	end

	return false
end


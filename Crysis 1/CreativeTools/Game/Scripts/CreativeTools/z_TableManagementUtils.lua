-- Script.ReloadScript("SCRIPTS/common.lua");

-- function CopyTableWithMetadata(obj, seen)
-- 	HUD.DrawStatusText("Before")
--     if type(obj) ~= 'table' then return obj end
--     if seen and seen[obj] then return seen[obj] end
--     local s = seen or {}
--     local res = setmetatable({}, getmetatable(obj))
--     s[obj] = res
--     for k, v in pairs(obj) do res[CopyTableWithMetadata(k, s)] = CopyTableWithMetadata(v, s) end
--     return res
--   end

-- -------------------------------------------------------------------------------

-- TableManager =
-- {
-- 	table = {},
-- 	currentElementIndex = 1,
-- 	currentCategoryIndex = 1,
-- }

-- function TableManager:GetCurrentCategory()
-- 	return self.table[self.currentCategoryIndex]
-- end

-- function TableManager:ResetCategoryAndIndex()
-- 	self.currentCategoryIndex = 1
-- 	self.currentElementIndex = 1
-- end

-- function TableManager:GetElementInCategory(index)
-- 	local category = self:GetCurrentCategory()
-- 	if (category) then
-- 		return category.categoryElements[index]
-- 	end
-- 	return nil
-- end

-- function TableManager:GetCurrentElement()
-- 	return self:GetElementInCategory(self.currentElementIndex)
-- end

-- function TableManager:GetCurrentElementOrReset()
-- 	local item = self:GetCurrentElement()
-- 	if not item then
-- 		self:ResetCategoryAndIndex()
-- 		item = self:GetCurrentElement()
-- 	end
-- 	return item
-- end

-- function TableManager:IncrementElementIndexCycled()
-- 	local newIndex = self.currentElementIndex + 1

-- 	local category = self:GetCurrentCategory()
-- 	if not category then
-- 		self:ResetCategoryAndIndex()
-- 		return 1
-- 	end

-- 	local currentCategoryCount = count(category.categoryElements)
-- 	if (newIndex > currentCategoryCount) then
-- 		newIndex = 1
-- 	end
-- 	self.currentElementIndex = newIndex

-- 	return newIndex
-- end

-- function TableManager:IncrementCategoryIndexCycled()
-- 	local newIndex = self.currentCategoryIndex + 1
-- 	if (newIndex > count(self.table)) then
-- 		newIndex = 1
-- 	end
-- 	self.currentElementIndex = 1
-- 	self.currentCategoryIndex = newIndex

-- 	return newIndex
-- end

-- function TableManager:TryFindElementAndSetByName(elementName)
-- 	for catInd, category in pairs(self.table) do
-- 		for i, value in pairs(category.categoryElements) do

-- 			if value.name == elementName then
-- 				self.currentElementIndex = i
-- 				self.currentCategoryIndex = catInd
-- 				return true
-- 			end
-- 		end
-- 	end

-- 	return false
-- end


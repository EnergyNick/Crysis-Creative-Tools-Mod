Script.ReloadScript("Scripts/common.lua");

local function progressBarIteration(data)
	if data.isAbortCalled then
		HUD.SetProgressBar(false, -1, "")
		return
	end
	HUD.SetProgressBar(true, data.count, data.name)

	if data.count >= 100 then
		HUD.SetProgressBar(false, -1, "")
		data.onFinishAction()
	else
		data.count = data.count + (data.step)
		Script.SetTimer(data.delay, progressBarIteration, data)
	end
end


---Start progress bar
---@param stepDelayMs integer|nil Time of every step delay, default is 100 ms
---@param stepNumber integer|nil Count of progress added on every step, default is 5
---@param onFinishAction function Called after finishing action
---@return function CancelAction Func to cancel progress bar
function StarProgressBar(onScreenName, onFinishAction, stepDelayMs, stepNumber)
	local data =
	{
		name = onScreenName,
		onFinishAction = onFinishAction,
		step = stepNumber or 5,
		delay = stepDelayMs or 100,

		isAbortCalled = false,
		count = 0,
	}
	local function cancelFunc()
		data.isAbortCalled = true
	end

	Script.SetTimer(100, progressBarIteration, data)

	return cancelFunc
end
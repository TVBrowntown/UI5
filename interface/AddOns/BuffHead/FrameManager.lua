BuffHead.FrameManager = {};

local frameList = {};
local tableRemove = table.remove;
local tableInsert = table.insert;

function BuffHead.FrameManager.GetFrame()

	if (#frameList > 0) then
		local frame = tableRemove(frameList);
		return frame;
	end
	
	return nil;

end

function BuffHead.FrameManager.ReleaseFrame(frame)
	--d("release frame")
	--d(frame.m_Name)
	tableInsert(frameList, frame);

	--d("-release frame")
end

function BuffHead.FrameManager.GetFrameList()
	--d(frameList)
end

function BuffHead.FrameManager.ManualRelease(frameName)
	for index, content in pairs(FrameManager.m_Frames) do
		if (index:match(frameName)) then
			BuffHead.FrameManager.ReleaseFrame(content)
		end     
	end
end

function BuffHead.FrameManager.DestroyFrames()

	for index, frame in ipairs(frameList) do
		DestroyWindow(frame:GetName());
		FrameManager:Remove(frame:GetName());
	end
	
	frameList = {};

end
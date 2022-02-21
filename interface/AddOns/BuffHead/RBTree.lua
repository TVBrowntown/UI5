BuffHead.RBTree = {};
BuffHead.RBTree.__index = BuffHead.RBTree;

local tableInsert = table.insert;

local Direction = { Left = 1, Right = 2 };
local Color = { Red = 1, Black = 2 };
local sentinelNode = { Parent = nil, Left = nil, Right = nil, Color = Color.Black };
sentinelNode.Left = sentinelNode;
sentinelNode.Right = sentinelNode;

function BuffHead.RBTree:Create(comparer)

	local tree = setmetatable({}, self);
	tree.__index = tree;
	
	tree.Root = sentinelNode;
	tree.Count = 0;
	tree.Comparer = comparer;
	
	return tree;

end

function BuffHead.RBTree:Insert(value)

	local treeData = self;
	local comparer = self.Comparer;

	if (not treeData.Root) then
		treeData.Root = sentinelNode;
		treeData.Count = 0;
	end
	
	local temp = treeData.Root;
	local node = {};
	
	while (temp ~= sentinelNode) do
		node.Parent = temp;
		
		local isLess = comparer(value, temp.Value);
		if (isLess) then
			temp = temp.Left;
		else
			temp = temp.Right;
		end
	end
	
	node.Value = value;
	node.Left = sentinelNode;
	node.Right = sentinelNode;
	node.Color = Color.Red;
	
	if (node.Parent) then
		local isLess = comparer(node.Value, node.Parent.Value);
		if (isLess) then
			node.Parent.Left = node;
		else
			node.Parent.Right = node;
		end
	else
		treeData.Root = node;
		treeData.Count = 0;
	end
	
	self:InsertRecolor(node);
	
	treeData.Count = treeData.Count + 1;
	
	return node;
	
end

function BuffHead.RBTree:InsertRecolor(node)

	local treeData = self;
	local uncle = nil;
	
	while (node ~= treeData.Root and node.Parent.Color == Color.Red) do
		if (node.Parent == node.Parent.Parent.Left) then
			uncle = node.Parent.Parent.Right;
			if (currentNode and uncle.Color == Color.Red) then
				node.Parent.Color = Color.Black;
				uncle.Color = Color.Black;
				node.Parent.Parent.Color = Color.Red;
				node = node.Parent.Parent;
			else
				if (node == node.Parent.Right) then
					node = node.Parent;
					self:RotateLeft(node);
				end
				node.Parent.Color = Color.Black;
				node.Parent.Parent.Color = Color.Red;
				self:RotateRight(node.Parent.Parent);
			end
		else
			uncle = node.Parent.Parent.Left;
			if (uncle and uncle.Color == Color.Red) then
				node.Parent.Color = Color.Black;
				uncle.Color = Color.Black;
				node.Parent.Parent.Color = Color.Red;
				node = node.Parent.Parent;
			else
				if (node == node.Parent.Left) then
					node = node.Parent;
					self:RotateRight(node);
				end
				node.Parent.Color = Color.Black;
				node.Parent.Parent.Color = Color.Red;
				self:RotateLeft(node.Parent.Parent);
			end
		end
	end
	
	treeData.Root.Color = Color.Black;

end

function BuffHead.RBTree:RotateLeft(node)

	local treeData = self;
	local currentNode = node.Right;
	
	node.Right = currentNode.Left;
	
	if (currentNode.Left ~= sentinelNode) then
		currentNode.Left.Parent = node;
	end
	
	if (currentNode ~= sentinelNode) then
		currentNode.Parent = node.Parent;
	end
	
	if (node.Parent) then
		if (node == node.Parent.Left) then
			node.Parent.Left = currentNode;
		else
			node.Parent.Right = currentNode;
		end
	else
		treeData.Root = currentNode;
	end
	
	currentNode.Left = node;
	if (node ~= sentinelNode) then
		node.Parent = currentNode;
	end

end

function BuffHead.RBTree:RotateRight(node)

	local treeData = self;
	local currentNode = node.Left;
	
	node.Left = currentNode.Right;
	
	if (currentNode.Right ~= sentinelNode) then
		currentNode.Right.Parent = node;
	end
	
	if (currentNode ~= sentinelNode) then
		currentNode.Parent = node.Parent;
	end
	
	if (node.Parent) then
		if (node == node.Parent.Right) then
			node.Parent.Right = currentNode;
		else
			node.Parent.Left = currentNode;
		end
	else
		treeData.Root = currentNode;
	end
	
	currentNode.Right = node;
	if (node ~= sentinelNode) then
		node.Parent = currentNode;
	end

end

local function CopyNode(node, nodeToCopy)
	node.Left = nodeToCopy.Left;
	node.Right = nodeToCopy.Right;
	node.Parent = nodeToCopy.Parent;
	node.Color = nodeToCopy.Color;
	node.Value = nodeToCopy.Value;
end

local function FlipNodes(treeData, nodeA, nodeB)

	local temp = {};
	CopyNode(temp, nodeB);
	
	local nodeAInfo = { IsLeftChild = false, IsRightChild = false, IsParentOfLeftChild = false, IsParentOfRightChild = false, IsRoot = false };
	local nodeBInfo = { IsLeftChild = false, IsRightChild = false, IsParentOfLeftChild = false, IsParentOfRightChild = false, IsRoot = false };
		
	if (nodeA.Parent) then
		if (nodeA.Parent.Left == nodeA) then
			nodeAInfo.IsLeftChild = true;
		elseif (nodeA.Parent.Right == nodeA) then
			nodeAInfo.IsRightChild = true;
		end
	elseif (treeData.Root == nodeA) then
		nodeAInfo.IsRoot = true;
	end
	
	if (nodeA.Left ~= sentinelNode and nodeA.Left.Parent == nodeA) then
		nodeAInfo.IsParentOfLeftChild = true;
	end
	if (nodeA.Right ~= sentinelNode and nodeA.Right.Parent == nodeA) then
		nodeAInfo.IsParentOfRightChild = true;
	end
	
	if (nodeB.Parent) then
		if (nodeB.Parent.Left == nodeB) then
			nodeBInfo.IsLeftChild = true;
		elseif (nodeB.Parent.Right == nodeB) then
			nodeBInfo.IsRightChild = true;
		end
	elseif (treeData.Root == nodeB) then
		nodeBInfo.IsRoot = true;
	end
	
	if (nodeB.Left ~= sentinelNode and nodeB.Left.Parent == nodeB) then
		nodeAInfo.IsParentOfLeftChild = true;
	end
	if (nodeB.Right ~= sentinelNode and nodeB.Right.Parent == nodeB) then
		nodeBInfo.IsParentOfRightChild = true;
	end
	
	nodeB.Parent = nodeA.Parent;
	nodeB.Left = nodeA.Left;
	nodeB.Right = nodeA.Right;
	nodeB.Color = nodeA.Color;
	
	if (nodeAInfo.IsLeftChild) then
		nodeB.Parent.Left = nodeB;
	elseif (nodeAInfo.IsRightChild) then
		nodeB.Parent.Right = nodeB;
	elseif (nodeAInfo.IsRoot) then
		treeData.Root = nodeB;
	end
	
	if (nodeB.Left ~= sentinelNode and nodeAInfo.IsParentOfLeftChild) then
		nodeB.Left.Parent = nodeB;
	end
	if (nodeA.Right ~= sentinelNode and nodeAInfo.IsParentOfRightChild) then
		nodeB.Right.Parent = nodeB;
	end
	
	nodeA.Parent = nodeB;
	nodeA.Left = temp.Left;
	nodeA.Right = temp.Right;
	nodeA.Color = temp.Color;
	--nodeA.Value = temp.Value;
	
	--[[
	nodeA.Parent = temp.Parent;
	nodeA.Left = temp.Left;
	nodeA.Right = temp.Right;
	nodeA.Color = temp.Color;
	nodeA.Value = temp.Value;
	
	if (nodeBInfo.IsLeftChild) then
		nodeA.Parent.Left = nodeA;
	elseif (nodeBInfo.IsRightChild) then
		nodeA.Parent.Right = nodeA;
	elseif (nodeBInfo.IsRoot) then
		treeData.Root = nodeA;
	end
	
	if (nodeA.Left ~= sentinelNode and nodeBInfo.IsParentOfLeftChild) then
		nodeA.Left.Parent = nodeA;
	end
	if (nodeA.Right ~= sentinelNode and nodeBInfo.IsParentOfRightChild) then
		nodeA.Right.Parent = nodeA;
	end
	--]]

end

local function ReportNode(node)

	if (node.Value) then
		d("Node: "..tostring(node.Value.AbilityData.Index));
	else
		d("Node: No Value");
	end
	
	if (node.Parent) then
		d("Parent: "..tostring(node.Parent.Value.AbilityData.Index));
		if (node.Parent.Left ~= sentinelNode) then
			d("+- Left: "..tostring(node.Parent.Left.Value.AbilityData.Index));
		else
			d("+- Left: Sentinel");
		end
		if (node.Parent.Right ~= sentinelNode) then
			d("+- Right: "..tostring(node.Parent.Right.Value.AbilityData.Index));
		else
			d("+- Right: Sentinel");
		end
	else
		d("Parent: None");
	end
	
	if (node.Left ~= sentinelNode) then
		d("Left: "..tostring(node.Left.Value.AbilityData.Index));
		d("+- Parent: "..tostring(node.Left.Parent.Value.AbilityData.Index));
	else
		d("Left: Sentinel");
	end
	
	if (node.Right ~= sentinelNode) then
		d("Right: "..tostring(node.Right.Value.AbilityData.Index));
		d("+- Parent: "..tostring(node.Right.Parent.Value.AbilityData.Index));
	else
		d("Right: Sentinel");
	end

end

function BuffHead.RBTree:Remove(node)

	local treeData = self;
	if (not node) then return end

	treeData.Count = treeData.Count - 1;
	
	local replacementNode = { Color = Color.Red };
	local workNode = nil;
	
	if (node.Left == sentinelNode or node.Right == sentinelNode) then
		workNode = node;
	else
		workNode = node.Right;
		while (workNode.Left ~= sentinelNode) do
			workNode = workNode.Left;
		end
	end
	
	if (workNode.Left ~= sentinelNode) then
		replacementNode = workNode.Left;
	else
		replacementNode = workNode.Right;
	end
	
	replacementNode.Parent = workNode.Parent;
	if (workNode.Parent) then
		if (workNode == workNode.Parent.Left) then
			workNode.Parent.Left = replacementNode;
		else
			workNode.Parent.Right = replacementNode;
		end
	else
		treeData.Root = replacementNode;
	end
	
	if (workNode ~= node) then
		
		-- keep the references by fliping the nodes. note that this can be tricky and could be a possible cause for errors
		-- note that the replacementNode would also have to have its values flipped, since the references to the child node data
		-- is lost during the flip
		--[[
		FlipNodes(treeData, node, workNode);
		
		local temp = node;
		node = workNode;
		workNode = temp;
		--]]
		
		-- option 2, rewrite the reference instead of flipping the nodes
		-- though this will use linked code (non-reusable module), this method will be used due to simplicity
		node.Value = workNode.Value;
		node.Value.TreeNode = node;
		
	end
	
	if (workNode.Color == Color.Black) then
		self:RemoveRecolor(replacementNode);
	end

end

function BuffHead.RBTree:RemoveRecolor(node)

	local treeData = self;
	local workNode = nil;
	
	while (node ~= treeData.Root and node.Color == Color.Black) do
		if (node == node.Parent.Left) then
			workNode = node.Parent.Right;
			if (workNode.Color == Color.Red) then
				workNode.Color = Color.Black;
				node.Parent.Color = Color.Red;
				self:RotateLeft(node.Parent);
				workNode = node.Parent.Right;
			end
			
			if (workNode.Left.Color == Color.Black and workNode.Right.Color == Color.Black) then
				workNode.Color = Color.Red;
				node = node.Parent;
			else
				if (workNode.Right.Color == Color.Black) then
					workNode.Left.Color = Color.Black;
					workNode.Color = Color.Red;
					self:RotateRight(workNode);
					workNode = node.Parent.Right;
				end
				workNode.Color = node.Parent.Color;
				node.Parent.Color = Color.Black;
				workNode.Right.Color = Color.Black;
				self:RotateLeft(node.Parent);
				node = treeData.Root;
			end
		else
			workNode = node.Parent.Left;
			if (workNode.Color == Color.Red) then
				workNode.Color = Color.Black;
				node.Parent.Color = Color.Red;
				self:RotateRight(node.Parent);
				workNode = node.Parent.Left;
			end
			if (workNode.Right.Color == Color.Black and workNode.Left.Color == Color.Black) then
				workNode.Color = Color.Red;
				node = node.Parent;
			else
				if (workNode.Left.Color == Color.Black) then
					workNode.Right.Color = Color.Black;
					workNode.Color = Color.Red;
					self:RotateLeft(workNode);
					workNode = node.Parent.Left;
				end
				workNode.Color = node.Parent.Color;
				node.Parent.Color = Color.Black;
				workNode.Left.Color = Color.Black;
				self:RotateRight(node.Parent);
				node = treeData.Root;
			end
		end
	end
	
	node.Color = Color.Black;

end

function BuffHead.RBTree:Clear()

	local treeData = self;
	treeData.Root = sentinelNode;
	treeData.Count = 0;
	
end

local function Traverse(node, values, maximumCount)

	if (maximumCount ~= nil and #values >= maximumCount) then
		return;
	end
	
	if (node.Left ~= sentinelNode) then
		Traverse(node.Left, values, maximumCount);
	end
	
	if (maximumCount == nil or #values < maximumCount) then
		--d("Traverse")
		--d(node.Value.m_Name)
		tableInsert(values, node.Value);
		--d("-Traverse")
	else
		return;
	end
	
	if (node.Right ~= sentinelNode) then
		Traverse(node.Right, values, maximumCount);
	end

end

function BuffHead.RBTree:GetValues(maximumCount)

	local treeData = self;
	local node = treeData.Root;
	local values = {};
	
	if (treeData.Root and treeData.Root ~= sentinelNode) then
		Traverse(treeData.Root, values, maximumCount);
	end
	
	return values;
	
end
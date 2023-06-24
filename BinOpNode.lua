local Node = require(script.Parent.Node)
local NodeTypes = require(script.Parent.NodeTypes)

local BinOpNode = setmetatable({}, { __index = Node})
BinOpNode.__index = BinOpNode

function BinOpNode.new(left, op, right)
    local self = Node.new(NodeTypes.BinOpNode)
    setmetatable(self, BinOpNode)
    self.left = left
    self.op = op
    self.right = right
    return self
end

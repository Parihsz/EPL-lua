local NodeTypes = require(script.Parent.NodeTypes)

CondNode = {}
CondNode.__index = CondNode

function CondNode.new(left, op, right)
    local self = setmetatable({}, CondNode)
    self.left = left
    self.op = op
    self.right = right
    return self
end

function CondNode:GetNodeType()
  return NodeTypes.CondNode
end

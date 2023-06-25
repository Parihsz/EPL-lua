local NodeTypes = require(script.Parent.NodeTypes)

CondNode = {}
CondNode.__index = CondNode

setmetatable(CondNode, {
  __call = function (cls, left, op, right)
    local self = setmetatable({}, cls)
    self.left = left
    self.op = op
    self.right = right
    return self
  end,
})

function CondNode.new(left, op, right)
  return CondNode(left, op, right)
end

function CondNode:GetNodeType()
  return NodeTypes.CondNode
end

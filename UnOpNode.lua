local NodeTypes = require(script.Parent.NodeTypes)

local UnOpNode = {}
UnOpNode.__index = UnOpNode

function UnOpNode.new(node)
    local self = setmetatable({}, UnOpNode)
    self.type = NodeTypes.UnOpNode
    self.node = node
    return self
end

return UnOpNode

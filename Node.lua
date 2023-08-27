Node = {}
Node.__index = Node

function Node.new(nodeType, value)
    local self = setmetatable({}, Node)
    self.nodeType = nodeType
    self.value = value or 0
    return self
end

return Node

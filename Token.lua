local Token = {}
Token.__index = Token

function Token.new(tokenType, value)
    local self = setmetatable({}, Token)
    self.type = tokenType
    self.value = value or 0
    return self
end

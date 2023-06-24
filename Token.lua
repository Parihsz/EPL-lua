local Token = {}
Token.__index = Token

function Token.new(tokenType, value, optional)
    local self = setmetatable({}, Token)
    self.type = tokenType
    self.value = value or 0
    self.optional = optional or 0
    return self
end

return Token

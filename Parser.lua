local Node = require(script.Parent.Node)
local BinOpNode = require(script.Parent.BinOpNode)
local UnOpNode = require(script.Parent.UnOpNode)
local TokenTypes = require(script.Parent.TokenTypes)
local NodeTypes = require(script.Parent.NodeTypes)

local Parser = {}
Parser.__index = Parser

function Parser.new(tokens)
    assert(type(tokens) == "table", "Expected table for parameter 'tokens'")
    local self = setmetatable({}, Parser)
    self.tokens = tokens
    self.currentNum = 1
    self.currentToken = self.tokens[1]
    self.current_line = 1
    self.ast = {}
    return self
end

function Parser:Advance()
    local n1 = TokenTypes.NEWLINE
    self.currentNum += 1

    if self.currentNum <= #self.tokens and self.tokens[self.currentNum].type == n1 then
        self.currentNum += 1
        self.current_line += 1
        table.insert(self.ast, Node.new(NodeTypes.NewLineNode, 0))
    else
        self.currentToken = self.tokens[self.currentNum]
    end
end

function Parser:Parse()
   local expression = self:Expression()
   if self.currentToken ~= nil then
      error("SyntaxError on line " .. self.current_line .. ": Expected end of program.")
   end
   return expression
end

function Parser:Expression()
    local left = self:Term()

    while self.currentToken and (self.currentToken.type == TokenTypes.PLUS or self.currentToken.type == TokenTypes.MINUS) do
        local op = self.currentToken.type  
        self:Advance()
        left = BinOpNode.new(left, op, self:Term())
    end
end

function Parser:Term()
    local left = self:Factor()

    while self.currentToken and (self.currentToken.type == TokenTypes.MULTIPLY or self.currentToken.type == TokenTypes.DIVIDE) do
        local op = self.currentToken.type
        self:Advance()
        left = BinOpNode.new(left, op, self:Factor())
    end

    return left
end

function Parser:Factor()
    if self.currentToken then
        if self.currentToken.type == TokenTypes.NUMBER then
            local value = self.currentToken.value
            self:Advance()
            return Node.new(NodeTypes.NumberNode, value)
        elseif self.currentToken.type == TokenTypes.MINUS then
            self:Advance()
            return UnOpNode.new(self:Factor())
        elseif self.currentToken.type == TokenTypes.LPAREN then
            self:Advance()
            local expr = self:Expression()
            self:Check(TokenTypes.RPAREN)
            return expr
        else
            error("SyntaxError on line " .. self.current_line .. ": Expected Literal.")
        end
    else
        error("SyntaxError on line " .. self.current_line .. ": Expected Literal, got null.")
    end
end


return Parser
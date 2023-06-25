local Node = require(script.Parent.Node)
local BinOpNode = require(script.Parent.BinOpNode)
local UnOpNode = require(script.Parent.UnOpNode)
local TokenTypes = require(script.Parent.TokenTypes)
local NodeTypes = require(script.Parent.NodeTypes)
local Lexer = require(script.Parent.Lexer)
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

function Parser:expr()
    local left = self:term()
    local tokenTypes = {TokenTypes.PLUS, TokenTypes.MINUS}

    while self.currentToken ~= nil and self:tokenInTypes(self.currentToken.type, tokenTypes) do
        local op = self.currentToken.type
        self:Advance()
        left = BinOpNode.new(left, op, self:term())
    end

    return left
end

function Parser:cexpr()
    local left = self:expr()
    local valid = {TokenTypes.EEQ, TokenTypes.NQ, TokenTypes.LTE, TokenTypes.LT, TokenTypes.GT, TokenTypes.GTE}

    while self.currentToken ~= nil and self:tokenInTypes(self.currentToken.type, valid) do
        local op = self.currentToken.type
        self:Advance()
        left = BinOpNode.new(left, op, self:expr())
    end

    return left
end

function Parser:Expression()
    local left = self:cexpr()
    local KEYWORDS = Lexer.KEYWORDS
    local andval = KEYWORDS[1]
    local orval = KEYWORDS[2]

    while self.currentToken ~= nil and self.currentToken.type == TokenTypes.KEYWORD do
        local op = self.currentToken.value

        if op == andval then 
            op = TokenTypes.AND 
        elseif op == orval then 
            op = TokenTypes.OR 
        else
            error("InvalidSyntaxError on line " .. self.current_line .. ": Expected and / or.")
        end

        self:Advance()
        left = BinOpNode.new(left, op, self:cexpr())
    end

    return left
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
    local left = self:Atom()
    while self.currentToken ~= nil and self.currentToken.type == TokenTypes.POWER do
        self:Advance()
        left = BinOpNode.new(left, TokenTypes.POWER, self:Atom())
    end
    return left
end

function Parser:Atom()
    if self.currentToken then
        local tokenTypes = {
            TokenTypes.NUMBER,
            TokenTypes.BOOL,
            TokenTypes.NULL,
            TokenTypes.STRING
        }
        for _, tokenType in ipairs(tokenTypes) do
            if self.currentToken.type == tokenType then
                local nodeType = self:GetNodeFromToken(tokenType)
                local value = self.currentToken.value
                self:Advance()
                return Node.new(nodeType, value)
            end
        end

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
        elseif self.currentToken.type == TokenTypes.FSTRING then
            if #self.currentToken.optional == 0 then
                return Node.new(NodeTypes.StringNode, self.currentToken.value)
            end
            local fstr = self.currentToken.value
            local string = nil
            local keys = {}
            local idx = 0
            for key, _ in pairs(self.currentToken.optional) do
                table.insert(keys, key)
            end
            while idx < #self.currentToken.optional do
                local key = keys[idx + 1]
                local value = self.currentToken.optional[key]
                local tval = nil
                if idx + 1 >= #self.currentToken.optional then
                    tval = string.sub(fstr, tonumber(key) - idx)
                else
                    tval = string.sub(fstr, tonumber(key) - idx, tonumber(keys[idx + 2]) - idx - 1)
                end
                local expr = Parser.new(value):expression()
                local cstring = string or Node.new(NodeTypes.StringNode, string.sub(fstr, 1, tonumber(key)))
                string = BinOpNode.new(cstring, TokenTypes.PLUS, expr)
                string = BinOpNode.new(string, TokenTypes.PLUS, Node.new(NodeTypes.StringNode, tval))
                idx = idx + 1
                self:Advance()
            end
            return string
        elseif (self.currentToken.type == TokenTypes.MINUS) or (self.currentToken.type == TokenTypes.NEG) then
            self:Advance()
            return self:UnOpNode(self:Atom())
        else
            error("SyntaxError on line " .. self.current_line .. ": Expected Literal.")
        end
    else
        error("SyntaxError on line " .. self.current_line .. ": Expected Literal, got null.")
    end
end

function Parser:GetNodeFromToken(tokenType)
    if tokenType == TokenTypes.NUMBER then
        return NodeTypes.NumberNode
    elseif tokenType == TokenTypes.STRING then
        return NodeTypes.StringNode
    elseif tokenType == TokenTypes.BOOL then
        return NodeTypes.BooleanNode
    elseif tokenType == TokenTypes.NULL then
        return NodeTypes.NullNode
    else
        error('PARSER METHOD "GetNodeFromToken": Unable to cast TokenType to NodeType')
    end
end

function Parser:BCheck(tokenType)
    if self.currentToken ~= nil and self.currentToken.type == TokenTypes.NULL then
        self:Advance()
    end
    if self.currentToken == nil or self.currentToken.type ~= tokenType then
        return false
    end
    return true
end

function Parser:CheckNext(tokenType)
    local idx = 1
    local cond1 = self.currentNum + idx < #self.tokens
    local cond2 = false
    if self.tokens[self.currentNum + idx] == TokenTypes.NEWLINE then
        cond2 = true
    end
    while cond1 and cond2 do
        idx = idx + 1
        cond1 = self.tokens[self.currentNum + idx] ~= nil
        cond2 = false
        if self.tokens[self.currentNum + idx] ~= nil and self.tokens[self.currentNum + idx].type == tokenType then
            cond2 = true
        end
    end
    if cond1 and cond2 then
        return true
    end
end



return Parser

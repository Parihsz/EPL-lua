local Token = require(script.Parent.Token)
local TokenTypes = require(script.Parent.TokenTypes)

local Lexer = {}
Lexer.__index = Lexer

function Lexer.new(content)
    local self = setmetatable({}, Lexer)
    self.text = content
    self.currentNum = 0
    self.currentChar = self.text[self.currentNum]
    self.line = 1
    return self
end

function Lexer:Advance()
    self.currentNum += 1
    if self.currentNum <= #self.text then
        self.currentChar = self.text[self.currentNum]
    else
        self.currentChar = nil
    end
end

function Lexer:Lex()
    local tokens = {}
    while self.currentChar do
        if self.currentChar == '+' then
            table.insert(tokens, Token.new(TokenTypes.PLUS))
            self:Advance()
        elseif self.currentChar == '-' then
            table.insert(tokens, Token.new(TokenTypes.MINUS))
            self:Advance()
        elseif self.currentChar == '*' then
            table.insert(tokens, Token.new(TokenTypes.MULTIPLY))
            self:Advance()
        elseif self.currentChar == '/' then
            table.insert(tokens, Token.new(TokenTypes.DIVIDE))
            self:Advance()
        elseif self.currentChar == ' ' or self.currentChar == '\t' then
            self:Advance()
        elseif self.currentChar == '\n' then
            self.line += 1
            
            self:Advance()
        else
            error("InvalidCharacterError on line " .. self.line .. ": Unexpected Character " .. self.currentChar .. " appeared.")
        end
    end
    return tokens
end

function Lexer:LexNumber()
    local nstr = ""
    local dotcount = 0
    
    while self.currentChar and self.currentChar:match("%d") or self.currentChar == "." do
        if self.currentChar == "." then
            if dotcount == 1 then
                error("InvalidCharacterError on line " .. self.line .. ": Unexpected Character " .. self.currentChar .. " appeared.") 
            end
            dotcount += 1
        end
        nstr = nstr .. self.currentChar
        self:Advance()
    end

    if nstr:sub(-1) == "." then
        nstr = nstr:sub(1, -2)
    end

    return tonumber(nstr)
end


return Lexer
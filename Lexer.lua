local Token = require(script.Parent.Token)
local TokenTypes = require(script.Parent.TokenTypes)

local LETTERS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
local NUMBERS = '0123456789'
local SYMBOLS = '-!@#$%^&*()+]}|\\ \';[{:><,/?.~`'
local IDENTIFIER_LETTERS = LETTERS .. NUMBERS .. '_'
local STRING = IDENTIFIER_LETTERS .. SYMBOLS
local BOOL_VAL = {'true', 'false'}
local NULL_VAL = 'null'
local KEYWORDS = {}

local Lexer = {}
Lexer.__index = Lexer

function Lexer.new(content)
    local self = setmetatable({}, Lexer)
    self.text = content
    self.currentNum = 0
    self.currentChar = self.text:sub(self.currentNum, self.currentNum)
    self.line = 1
    return self
end

function Lexer:Advance()
    self.currentNum += 1
    if self.currentNum <= #self.text then
        self.currentChar = self.text:sub(self.currentNum, self.currentNum)
    else
        self.currentChar = nil
    end
end

function Lexer:Lex()
    local tokens = {}

    local actionMap = {
        ['+'] = function() 
            table.insert(tokens, Token.new(TokenTypes.PLUS)); 
            self:Advance(); 
        end,
        ['-'] = function() 
            table.insert(tokens, Token.new(TokenTypes.MINUS)); 
            self:Advance(); 
        end,
        ['*'] = function() 
            table.insert(tokens, Token.new(TokenTypes.MULTIPLY)); 
            self:Advance(); 
        end,
        ['/'] = function() 
            table.insert(tokens, Token.new(TokenTypes.DIVIDE)); 
            self:Advance(); 
        end,
        ['^'] = function() 
            table.insert(tokens, Token.new(TokenTypes.POWER)); 
            self:Advance(); 
        end,
        [' '] = function() 
            self:Advance(); 
        end,
        ['\t'] = function() 
            self:Advance(); 
        end,
        ['\n'] = function() 
            self.line += 1; 
            self:Advance(); 
        end,
        ['"'] = function()
            table.insert(tokens, Token.new(TokenTypes.STRING, self:LexString()))
            self:Advance()
        end
    }

    while self.currentChar do
        local action = actionMap[self.currentChar] or (self.currentChar:match("[%a]") and function() 
            table.insert(tokens, self:LexID()) 
        end)
        if action then
            action()
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

function Lexer:LexID()
    local identifier = ''
    while self.currentChar and self.currentChar:match("[%w]") do
        identifier = identifier .. self.currentChar
        self:Advance()
    end

    if identifier == NULL_VAL then
        return Token.new(TokenTypes.NULL, 0)
    elseif identifier == BOOL_VAL[1] then
        return Token.new(TokenTypes.BOOL, true)
    elseif identifier == BOOL_VAL[2] then
        return Token.new(TokenTypes.BOOL, false)
    elseif table.contains(KEYWORDS, identifier) then
        return Token.new(TokenTypes.KEYWORD, identifier)
    else
        return Token.new(TokenTypes.IDENTIFIER, identifier)
    end
end

function Lexer:LexString()
    local string = ''
    local modifiers = {}
    local is_f_string = false
    local idx = 0
    while self.currentChar ~= nil and STRING:find(self.currentChar, 1, true) do
        local increment = 1
        if self.currentChar == '\\' then
            self:Advance()
            if SYMBOLS:find(self.currentChar, 1, true) or self.currentChar == '"' then
                string = string .. self.currentChar
                self:Advance()
                increment = 2
            end
        elseif self.currentChar == '{' then
            self:Advance()
            local inputstream = ''
            while self.currentChar ~= nil and not (self.currentChar:find('{}', 1, true)) do
                inputstream = inputstream .. self.currentChar
                self:Advance()
            end
            idx = idx + 1
            is_f_string = true
            modifiers[tostring(idx - 1)] = Lexer.new(inputstream):Lex()
            self:Advance()
        else
            string = string .. self.currentChar
            idx = idx + 1
            self:Advance()
        end
        idx = idx + increment
    end
    local type = is_f_string and TokenTypes.FSTRING or TokenTypes.STRING
    return Token.new(type, string, modifiers)
end

return Lexer

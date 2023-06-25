local Node = require(script.Parent.Node)
local TokenTypes = require(script.Parent.TokenTypes)
local NodeTypes = require(script.Parent.NodeTypes)

local Interpreter = {}
Interpreter.__index = Interpreter

local function convert(val)
    if val.type == NodeTypes.NumberNode then
        return tonumber(val.value)
    elseif val.type == NodeTypes.StringNode then
        return tostring(val.value)
    elseif val.type == NodeTypes.BooleanNode then
        return val.value == true
    elseif val.type == NodeTypes.NullNode then
        return 'null'
    end
end


function Interpreter.new(ast: table)
    assert(type(ast) == "table", "Expected table, got " .. type(ast))
    local self = setmetatable({}, Interpreter)
    self.current_line = 1
    self.nodes = ast
    return self
end

Interpreter.Operations = {
    [TokenTypes.PLUS] = function(a, b) 
        return a + b 
    end,
    [TokenTypes.MINUS] = function(a, b) 
        return a - b 
    end,
    [TokenTypes.MULTIPLY] = function(a, b) 
        return a * b 
    end,
    [TokenTypes.DIVIDE] = function(a, b) 
        return a / b 
    end,
    [TokenTypes.POWER] = function(a, b)
        return a ^ b
    end
}

function Interpreter:Evaluate()
    print(self:VisitExpression(self.nodes).value)
end

function Interpreter:VisitExpression(expression: table)
    assert(type(expression) == "table", "Expected table, got " .. type(expression))
    if expression.type == NodeTypes.NumberNode then
        return expression
    elseif expression.type == NodeTypes.BinOpNode then
        return self:VisitBinOpNode(expression)
    elseif expression.type == NodeTypes.UnOpNode then
        return self:VisitUnOpNode(expression)
    elseif expression.type == NodeTypes.CondNode then
        return self:VisitCondNode(expression)
    end
end

function Interpreter:VisitBinOpNode(node: table)
    assert(type(node) == "table", "Expected table for parameter 'node'")
    local left = self:visitExpression(node.left)
    local op = node.op
    local right = self:visitExpression(node.right)
    local result = Node.new(NodeTypes.NumberNode, 0)

    if left.type == NodeTypes.StringNode or right.type == NodeTypes.StringNode then
        if op == TokenTypes.PLUS then
            if left.type == NodeTypes.NumberNode and string.sub(tostring(left.value), -2) == ".0" then
                left.value = string.sub(tostring(left.value), 1, -3)
            elseif right.type == NodeTypes.NumberNode and string.sub(tostring(right.value), -2) == ".0" then
                right.value = string.sub(tostring(right.value), 1, -3)
            end
            result.type = NodeTypes.StringNode
            result.value = tostring(left.value) .. tostring(right.value)
        end
    else
        if op == TokenTypes.PLUS then
            result.value = left.value + right.value
        elseif op == TokenTypes.MINUS then
            result.value = left.value - right.value
        elseif op == TokenTypes.MULTIPLY then
            result.value = left.value * right.value
        elseif op == TokenTypes.DIVIDE then
            if right.value == 0 then
                error("DivisionByZeroError on line " .. self.current_line)
            end
            result.value = left.value / right.value
        elseif op == TokenTypes.POWER then
            result.value = left.value ^ right.value
        end
    end

    return result
end

function Interpreter:VisitUnOpNode(node)
    local val = self:VisitExpression(node.node).value
    if val.type == NodeTypes.BooleanNode then
        return Node.new(NodeTypes.BooleanNode, not val.value)
    end
    return Node.new(NodeTypes.NumberNode, -val)
end

function Interpreter:VisitCondNode(node)
    local left = self:VisitExpression(node.left)
    local right = self:VisitExpression(node.right)
    local op = node.op
    local resultNode = Node.new(NodeTypes.BooleanNode, 0)

    local ops = {TokenTypes.AND, TokenTypes.OR}
    if not self:contains(ops, op) then
        left = convert(left)
        right = convert(right)

        if op == TokenTypes.EEQ then
            resultNode.value = left == right
        elseif op == TokenTypes.NQ then
            resultNode.value = left ~= right
        elseif op == TokenTypes.LT then
            resultNode.value = left < right
        elseif op == TokenTypes.LTE then
            resultNode.value = left <= right
        elseif op == TokenTypes.GT then
            resultNode.value = left > right
        elseif op == TokenTypes.GTE then
            resultNode.value = left >= right
        else
            error("InvalidConditionOperatorError: " .. op .. ", line " .. self.current_line)
        end
    else
        if left.type ~= NodeTypes.BooleanNode or right.type ~= NodeTypes.BooleanNode then
            error("InvalidConditionOperatorError: " .. op .. ", line " .. self.current_line)
        end
        left = left.value
        right = right.value

        if op == TokenTypes.AND then
            resultNode.value = left and right
        else
            resultNode.value = left or right
        end
    end
    return resultNode
end

return Interpreter

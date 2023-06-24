local Node = require(script.Parent.Node)
local TokenTypes = require(script.Parent.TokenTypes)
local NodeTypes = require(script.Parent.NodeTypes)

local Interpreter = {}
Interpreter.__index = Interpreter


function Interpreter.new(ast: table)
    assert(type(ast) == "table", "Expected table, got " .. type(ast))
    local self = setmetatable({}, Interpreter)
    self.current_line = 1
    self.nodes = ast
    return self
end

Interpreter.Operations = {
    [TokenTypes.PLUS] = function(a, b) 
        return a + b end,
    [TokenTypes.MINUS] = function(a, b) 
        return a - b end,
    [TokenTypes.MULTIPLY] = function(a, b) 
        return a * b end,
    [TokenTypes.DIVIDE] = function(a, b) 
        return a / b
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
    end
end

function Interpreter:VisitBinOpNode(node: table)
    assert(type(node) == "table", "Expected table for parameter 'node'")
    local left = self:VisitExpression(node.left)
    local op = node.op  
    local right = self:VisitExpression(node.right)
    local result = Node.new(NodeTypes.NumberNode, 0)
    
    if self.operations[op] then
        if op == TokenTypes.DIVIDE and right.value == 0 then
            error("DivisionByZeroError on line " .. self.current_line)
        end
        result.value = self.operations[op](left.value, right.value)
    else
        error("Unexpected operation type: " .. tostring(op))
    end
end

function Interpreter:VisitUnOpNode(node)
    local val = self:VisitExpression(node.node).value
    return Node.new(NodeTypes.NumberNode, -val)
end

return Interpreter
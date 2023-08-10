![R (9)](https://github.com/Parihsz/EPL/assets/65139606/539afae2-c848-4ee6-98bd-05e9e2db3aa7)

# EPL
The EPL project encompasses an interpreter, lexer, and parser implemented in Lua. EPL is a programming language designed for evaluating arithmetic expressions and handling conditional operations. The interpreter evaluates EPL code, the lexer tokenizes EPL scripts, and the parser builds an abstract syntax tree (AST) from the tokens.

# EPL Usage
```lua
local source_code = "3 + 5 * 2"
local Lexer = Lexer.new(source_code)
local Tokens = Lexer:Tokenize()
local Parser = Parser.new(Tokens)
local Ast = Parser:Parse()
local Interpreter = Interpreter.new(Ast)
Interpreter:Evaluate() -- Output will be 13
```

# Detailed Breakdown

## Lexer
The Lexer is responsible for converting the source code into a series of tokens.

Key Methods
```lua
Lexer.new(source_code) -- Initializes the lexer with the given source code.
Lexer:Tokenize() -- Processes the source code and returns a list of tokens.
```
## Parser
The Parser transforms the tokens into an Abstract Syntax Tree (AST).

Key Methods
```lua
Parser.new(tokens) -- Initializes the parser with the tokens.
Parser:Parse() -- Parses the tokens and returns an AST.
```
## Interpreter
The Interpreter evaluates the AST and performs the corresponding operations.

Key Methods
```lua
Interpreter.new(ast) -- Initializes the interpreter with the given AST.
Interpreter:Evaluate() -- Evaluates the AST, printing the result.
Interpreter:VisitExpression(expression) -- Processes the given expression node and returns the result.
Interpreter:VisitBinOpNode(node) -- Processes a binary operation node, performing the corresponding operation on its left and right children.
Interpreter:VisitUnOpNode(node) -- Processes a unary operation node, applying the operation to its child node.
Interpreter:VisitCondNode(node) -- Processes a conditional node, evaluating the corresponding logical operation.
```

Details on Operation Handling
Arithmetic Operations:

```lua
+: Addition
-: Subtraction
*: Multiplication
/: Division
^: Exponentiation
```

Logical Operations:
```lua
AND: Logical AND
OR: Logical OR
Other conditional operators include ==, ~=, <, <=, >, >=.
```


![R (9)](https://github.com/Parihsz/EPL/assets/65139606/539afae2-c848-4ee6-98bd-05e9e2db3aa7)

# EPL-Lua
Syntax

Basics
// Variables
```python
var1 = 45
var2 = 32

var_res = (var1 + var2)^2
```

// Strings
```python
name = "Michael"
age = 15

welcome = "Welcome, {name}! You are {age} years old and you are thus not allowed"
```

// Data Structures
```python
array = ["Stupard", "Michael"]
object = [
    name = array[1]
    age = 15
]

welcome = "Welcome, {object.name}! You're {object.age} years old!"
```

// Basic Logic
```python
option = null

male = true
welcome = null

if !male {
    welcome = "You are a woman"
} else if option == "nonbinary" {
    welcome = "You are nonbinary"
} else {
    welcome = "You are normal"
}
```
// Advanced Logic
```python
GENDERS = [
    male = 0
    female = 1
]

name = "Chloe"
age = 15
gender = GENDERS.female

if age < 18 and name != "Michael" and gender != GENDERS.female {
    log("Underaged!")
} else if name == "Michael" or gender == GENDERS.female {
    log("Underaged but granted!")
}
```

// While Loops
```python
while true {
    sleep(0.05)
    log("Hello World!")
}
This is a never ending loop which prints "Hello World!". (TIP: Press "CTRL+C" to exit the terminal if you run this command)
```

// For Loops [1]
```python
for index in 0, 100 {
    log(index)
    if index == 69 {break}
}
```
// For Loops [2]
```python
user = [
    name = "<Mic>"
    age = 15
]

for data in user {
    log("{data.key} -> {data.value}")
}
```

// Lambda Functions
```python
sqrt = (x) => x ^ (1 / 2)

log(sqrt(10))
```

// Functions
```python
base_user = [
    name = null
    age = null
    id = null
]

generate_unique_id = (user) => {
    first_bit = "{#(user.name)}:{user.age}"
    second_bit = random(1, (#(user.name) + tonumber(user.age))*10^6)

    id = "{first_bit}->{second_bit}"
    return id
}

base_user.name = "Michael"
base_user.age = 15

log(generate_unique_id(base_user))
```

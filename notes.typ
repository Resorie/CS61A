#import "@preview/ilm:1.4.2": *

#show: ilm.with(
    title: text(font: ("Fira Mono for Powerline", "LXGW Wenkai"))[CS61A 笔记],
    author: "Resory",
    abstract: "my personal notes of the course cs 61a",
    //raw-text: (custom-font: ("FiraCode Nerd Font", "Times", "LXGW Wenkai")),
    raw-text: (use-typst-defaults: true),
    figure-index: (enabled: true),
    table-index: (enabled: true),
    listing-index: (enabled: true),
    preface: [
        #text(size: 1.3em)[*Useful Links*]\
        #link("https://cs61a.org/")[CS61A 课程官网] \ #link(
            "https://www.learncs.site/docs/curriculum-resource/cs61a",
        )[LearnCS 的 CS61A 资源] \ #link(
            "https://csdiy.wiki/%E7%BC%96%E7%A8%8B%E5%85%A5%E9%97%A8/Python/CS61A/",
        )[csdiy.wiki 的 CS61A 页面] \ #link("https://composingprograms.netlify.app/")[SICP Python 版本翻译]
    ],
)

#set text(font: ("Times", "LXGW Wenkai"))
#set image(width: 80%)
#set raw(lang: "python", tab-size: 4)
#set heading(
    numbering: "1.",
    supplement: "Lecture ",
)

= Welcome <lec1>

blah, blah, blah.

= Functions <lec2>

教授比较喜欢说 evaluate 这个词。大致相当于 `eval()`，或许可以翻译成“求值”。

An environment is a collection of frames. \
这句话说的很好，很有启发。frame 意思相当于“作用域”。

`None` is _not displayed_ by the interpreter as the value of an expression. \
一个很好地解释 interpreter 行为的例子：
```python
>>> 'Hello, World!'
'Hello, World!'
>>> print('Hello, World!')
Hello, World!
>>> None
>>> print(None)
None
>>> print(print(1), print(2))
1
2
None None
```

= Control <lec3>

Every expression is evaluated in the context of an environment.

A name evaluates to the value bound to that name in the earliest frame of the current environment in which that name is found. \
对于变量的查找，是从 environment 这个许多 frame 的嵌套结构中，从内向外地递归性查找，并就近选用。\
一个例子：\
```python
def square(square):
    return square * square
```
main frame 中的 `square` 是个函数，而 `square()` 内部的 frame 中，`square` 是个形参，并会被 bind to 某个值。
#image("assets/pic1.png")

A call expression and the body of the function being called are evaluated in different environments.

`/` 对应 `operator.truediv()`，`//` 对应 `operator.floordiv()`。\
注意浮点数除法是不精确的，而整数除法和取模是精确的。

在 interpreter 中执行文件：```bash python -i filename.py```。

doc string：函数的 def statement 下方第一行。其中的形参一般用大写。 \
doc string 中应当给出函数功能的描述和使用例子。
```python
def divide_exact(n, d):
    """Return the quotient and remainder of dividing N by D.

    >>> q, r = divide_exact(2025, 10)
    >>> q
    202
    >>> r
    5
    """
    return n // d, n % d
```
可以通过 ```bash python -m doctest filename.py -v``` 来测试 doc string 中的例子。

A _statement_ is executed by the interpreter to perform an action. \
Compound statements:
- A header that determines a statement's type
- The header of the clause "controls" the suite that follows
- `def` statements are compound statements
#image("assets/pic2.png")
- A suite is a sequence of statements
- To "execute" a suite means to execute its sequence of statements, in order

Conditional statements:\
即条件句。
#image("assets/pic3.png")

Let's understand it more deeply by introducing our friend #text(size: 1.2em)[George Boole]. \
He's an important logician, so let's make him bigger. :D
- False values in Python: `False`, `0`, `0.0`, `''`, `[]`, `{}`, `set()`, and `None` (thx copilot)
- True values in Python: Anything else

Iteration means repeating things. \
`while` statement:
#image("assets/pic4.png")

我们可以用函数写出一个类似 `if` 的功能：\
```python
def if_(c, t, f):
    if c:
        return t
    else:
        return f
```
但事实上，这和真正的 `if` 语句*并不一样*。回忆函数求值的过程：这里的 `t` 和 `f` 都会被求值，而 `if` 语句只会求值其中一个分支。\
一个例子：
```python
def real_sqrt(x):
    """Return the real part of the square root of x."""
    if x >= 0:
        return sqrt(x)
    else:
        return 0

def real_sqrt_bad(x):
    """An incorrect version of real_sqrt."""
    return if_(x >= 0, sqrt(x), 0)

>>> real_sqrt(-4)
0
>>> real_sqrt_bad(-4)
Traceback (most recent call last):
    ...
ValueError: math domain error
```
Call expressions don't allow you to skip evaluating parts of the call expression. Instead, all the parts are always evaluated before the function is called.

The logical operators AND and OR exhibit a behavior called short-circuiting. \
#image("assets/pic5.png")
例如 `2 and 3 = 3`，`[] and 3 = []`。

= Higher-Order Functions <lec4>

What we'd like to do is to generalize patterns by defining functions that take arguments that give us back the specific instances of the patterns.

The common structure among functions maybe a computational process.
```python
"""Generalization."""

def sum_naturals(n):
    """Sums the first N natural numbers.

    >>> sum_naturals(5)
    15
    """
    total, k = 0, 1
    while k <= n:
        total, k = total + k, k + 1
    return total

def sum_cubes(n):
    """Sums the first N cubes.

    >>> sum_cubes(5)
    225
    """
    total, k = 0, 1
    while k <= n:
        total, k = total + pow(k, 3), k + 1
    return total
```
Maybe we can do better. Maybe we don't have to repeat ourselves.
```python
"""Generalization."""

def identity(k):
    return k

def cube(k):
    return pow(k, 3)

def summation(n, term):
    """Sums the first N terms of a sequence.

    >>> summation(5, cube)
    225
    """
    total, k = 0, 1
    while k <= n:
        total, k = total + term(k), k + 1
    return total

def sum_naturals(n):
    """Sums the first N natural numbers.

    >>> sum_naturals(5)
    15
    """
    return summation(n, identity)

def sum_cubes(n):
    """Sums the first N cubes.

    >>> sum_cubes(5)
    225
    """
    return summation(n, cube)
```
Ta-da.

Functions as return values:
```python
def make_adder(n):
    """Return a function that takes one argument K and returns K + N.

    >>> add_three = make_adder(3)
    >>> add_three(4)
    7
    """
    def adder(k):
        return k + n
    return adder
```
Locally defined functions: Functions defined _within other function bodies_ are *bound to names in a local frame*.
#image("assets/pic6.png")

*Functions are first-class:* Functions can be manipulated as values in python.

*Higher-order function:* A function that takes a function as an argument value or returns a function as a return value. \
Higher-order functions:
- Express general methods of computation
- Remove repetition from programs
- Separate concerns among functions

= Environments <lec5>

当运行自定义函数时，Python 会创建一个对应的 frame，并将该函数的形参绑定到实参上。

Environment Diagrams for Nested `def` Statemens:
#image("assets/pic7.png")
注意其中 `make_adder(3)` 的 frame 并不在调用后立刻被销毁（而是被保存在返回的函数 `adder` 的闭包中 by copilot），这是因为 `adder` 仍然需要访问其中的 `n`。当一个 frame 中的变量不再被引用后，这个 frame 才会被销毁。


= Function Example: Sounds <lec6>

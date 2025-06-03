# Environment used in my everyday Julia shell.


import AlgebraOfGraphics
const AOG = AlgebraOfGraphics
using CairoMakie
using Distributions
using KittyTerminalImages
using StatsBase


atreplinit() do repl
    pushKittyDisplay!()
end

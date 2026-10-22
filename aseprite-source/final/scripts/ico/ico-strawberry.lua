local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local berryR = GV.ramp("#d6322b", { shade = "#ae2a2a", deep = "#6b1b2c", gloss = "#ff9158" })
local leafR = GV.ramp("#58a03e", { shade = "#2e5a2c" })
local stemR = GV.ramp("#2e5a2c")

local berry = c:ellipse(31.5, 31, 17.5, 9)
berry:add(c:poly({ {14,31}, {50,31}, {44,42}, {36,51}, {28,51}, {20,42} }))

local crown = c:ellipse(31.5, 21, 8, 3)
crown:add(c:poly({ {21,19}, {29,22}, {14,28} }))
crown:add(c:poly({ {25,21}, {31,22}, {22,31} }))
crown:add(c:poly({ {29,21}, {35,21}, {32,30} }))
crown:add(c:poly({ {33,22}, {39,21}, {42,31} }))
crown:add(c:poly({ {35,22}, {43,19}, {50,28} }))

local stem = c:line({ {31,21}, {31,15}, {34,12} }, 3)

c:build{
  { "berry", berry, berryR },
  { "stem", stem, stemR, { flat = true } },
  { "crown", crown, leafR },
}

local S = { ".s.", "sss", ".s." }
local seeds = { {22,33}, {30,36}, {40,32}, {25,41}, {36,42}, {31,47} }
for _, p in ipairs(seeds) do c:paint(S, p[1], p[2], { s = "#ffc27a" }) end

local t = c:save(O .. "aseprite/ico/ico-strawberry.aseprite", O .. "png/ico/ico-strawberry.png")
print(GV.report(t))

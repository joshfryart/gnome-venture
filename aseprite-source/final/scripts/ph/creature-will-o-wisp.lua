local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- glow disc behind (flat, opaque)
local disc = c:ellipse(32, 36, 17, 17)

-- outer flame: rounded bottom + tapered body to a sharp, slightly curled tip
local outer = c:ellipse(32, 38, 11, 11)
outer:add(c:poly({ {21, 37}, {23, 30}, {27, 23}, {31, 17}, {33, 13}, {34, 11}, {35, 15}, {37, 22}, {40, 28}, {43, 34}, {44, 38} }))

-- inner flame: smaller cream teardrop
local inner = c:ellipse(32, 41.5, 6, 5.5)
inner:add(c:poly({ {26, 42}, {27, 37}, {30, 30}, {32, 25}, {33, 24}, {34, 29}, {36, 34}, {38, 39}, {39, 42} }))

local water = GV.ramp("#b8d8d2", { rim = "#8fcbd8", gloss = "#c8ecdc" })
c:build{
  { "disc",  disc,  GV.ramp("#d6efe6"), { flat = true, rim = false } },
  { "outer", outer, water, { gloss = { 26, 30 } } },
  { "inner", inner, "cream", { contact = false, gloss = false } },
}

-- face
c:eye(28, 38, true); c:eye(34, 38, true)
c:paint({ "u...u", ".uuu." }, 30, 44, { u = "#2a1a10" })

c:ground(32, 57, 12, 1.5)
local t = c:save(O .. "aseprite/ph/creature-will-o-wisp.aseprite", O .. "png/ph/creature-will-o-wisp.png")
print(GV.report(t))

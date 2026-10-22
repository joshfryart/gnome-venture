local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local steel = GV.ramp("#8b8f96")
local wood = GV.ramp("#b6814d")
local lh = c:line({ {33, 36}, {27, 46}, {24, 53} }, 6)
local rh = c:line({ {36, 36}, {42, 46}, {45, 53} }, 6)
local rb = c:poly({ {32, 37}, {39, 34}, {52, 9}, {48, 7} })
-- left blade snapped with a jagged end
local lb = c:poly({ {30, 34}, {37, 37}, {30, 21}, {28, 24}, {26, 20}, {24, 23} })
local tip = c:poly({ {9, 44}, {19, 37}, {21, 40}, {18, 41}, {19, 43} })
local p = c:build{
  { "lh", lh, wood },
  { "rh", rh, wood },
  { "rb", rb, steel },
  { "lb", lb, steel },
  { "rivet", c:ellipse(34.5, 35, 3), GV.ramp("#a5663a") },
  { "tip", tip, steel, { gloss = false } },
  { "chip", c:poly({ {48, 50}, {53, 48}, {52, 53} }), wood, { flat = true } },
}
-- handle crack
c:paint({ "x..", ".x.", "x..", ".xx", "..x" }, 42, 44, { x = "#2a1a10" })
-- blade edge bevel
for i = 0, 10 do c:px(38 + i, 32 - 2 * i, "#c9c5bc") end
local t = c:save(O .. "aseprite/ph/broken-pruning-shears.aseprite", O .. "png/ph/broken-pruning-shears.png")
print(GV.report(t))

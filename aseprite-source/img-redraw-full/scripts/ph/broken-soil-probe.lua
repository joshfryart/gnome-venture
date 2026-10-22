-- ph/broken-soil-probe
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#8c4a1a")
local tipR = GV.ramp("#d4a46a", { rim = "#f0d49a" })

-- rod with a chipped bottom-right corner (notch at the rod/tip join)
local rod = c:rrect(26, 6, 38, 46, 4)
rod:cut(c:poly({ {35, 41}, {40, 41}, {40, 48}, {33, 48} }))
-- tip spike, notched on its right shoulder
local tip = c:poly({ {28, 45}, {37, 45}, {36, 50}, {33, 58}, {32, 58}, {29, 50} })
tip:cut(c:poly({ {33, 45}, {37, 45}, {37, 49} }))

c:build{
  { "tip", tip, tipR, { gloss = { 30, 47 } } },
  { "rod", rod, wood },
}

-- depth bands
for _, y in ipairs({ 16, 24, 32 }) do
  local b = c:rect(26, y, 38, y + 1):clip(rod)
  c:fill(b, "#2a1a10")
  c:fill(c:rect(26, y + 2, 38, y + 2):clip(rod):clip(c:rect(27, 0, 34, 63)), wood.rim)
end

-- crack: dark zigzag with a lit lip on its left
local crackPts = { {30, 11}, {35, 21}, {29, 28}, {36, 37}, {32, 44} }
local lip = c:line(crackPts, 1):shift(-1, 0):clip(rod)
c:fill(lip, wood.gloss)
c:fill(c:line(crackPts, 1):clip(rod), "#2a1a10")
c:fill(c:line(crackPts, 1):shift(1, 0):clip(rod), "#4a2c1a")

-- loose chips
c:build{
  { "chipA", c:poly({ {44, 50}, {50, 51}, {48, 55}, {44, 54} }), wood, { flat = true } },
  { "chipB", c:poly({ {8, 38}, {13, 38}, {12, 41}, {9, 41} }), wood, { flat = true } },
}

c:ground(33, 58, 8, 1.5)
local t = c:save(O .. "aseprite/ph/broken-soil-probe.aseprite", O .. "png/ph/broken-soil-probe.png")
print(GV.report(t))

-- ph/elderberry : pyramid cluster of six dark berries under a stem and leaf
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local purple = GV.ramp("#4e3a8a")   -- dusk family, lifted purple
local dark = "dusk"                  -- near-black purple
local leaf = GV.ramp("#58a03e")      -- moss family

local leafM = c:poly({ {34,20}, {36,13}, {40,8}, {46,6}, {47,9}, {45,15}, {40,19} })
local stemM = c:line({ {32,10}, {32,24} }, 3):add(c:line({ {32,15}, {35,17} }, 2))

-- berry centres, back (top) to front (bottom)
local B = {
  { 32, 29, purple },
  { 25, 39, purple }, { 39, 39, dark },
  { 18, 49, dark }, { 32, 49, purple }, { 46, 49, dark },
}
local parts = {
  { "stem", stemM, "moss", { flat = true } },
  { "leaf", leafM, leaf, { gloss = false } },
}
for i, b in ipairs(B) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 7.5, 7.5), b[3] }
end
c:build(parts)

-- leaf midrib
c:line({ {37,17}, {44,9} }, 1)
c:fill(c:line({ {37,17}, {44,9} }, 1), leaf.shade)

-- tiny dried flower nub (calyx) on each berry, a dark star dot at lower-right
for i, b in ipairs(B) do
  c:px(b[1] + 2, b[2] + 2, "#291d4a")
end

local t = c:save(O .. "aseprite/ph/elderberry.aseprite", O .. "png/ph/elderberry.png")
print(GV.report(t))

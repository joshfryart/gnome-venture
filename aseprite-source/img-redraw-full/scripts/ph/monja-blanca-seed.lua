local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- gathered frill top: flared, two ruffle lobes
local frill = c:ellipse(25, 15, 6, 5):add(c:ellipse(39, 15, 6, 5))
frill:add(c:poly({ {21, 16}, {44, 16}, {38, 25}, {26, 25} }))
-- pear-shaped sack, widest low, flat base
local sack = c:ellipse(32, 42, 20, 13):add(c:ellipse(32, 31, 13, 9))
sack:cut(c:rect(0, 55, 63, 63))
local twine = c:rrect(22, 22, 42, 25, 1)

local p = c:build{
  { "frill", frill, GV.ramp("#d9a660") },
  { "sack",  sack,  GV.ramp("#c9a96e", { shade = "#b07a45" }) },
  { "twine", twine, GV.ramp("#9a6b3f"), { flat = true } },
}
-- weave marks on the sack sides
local wv = "#8a4f2a"
for _, r in ipairs({ { 36, 0 }, { 42, 1 }, { 48, 0 } }) do
  local y, o = r[1], r[2]
  for _, x in ipairs({ 15 + o, 46 - o }) do c:fill(c:rect(x, y, x + 1, y), wv) end
  for _, x in ipairs({ 17 + o, 48 - o }) do c:fill(c:rect(x, y + 3, x + 1, y + 3), wv) end
end
-- frill ruffle lines
c:fill(c:line({ { 26, 13 }, { 28, 21 } }, 1), "#b07a45")
c:fill(c:line({ { 38, 13 }, { 36, 21 } }, 1), "#b07a45")
c:fill(c:line({ { 32, 15 }, { 32, 21 } }, 1), "#b07a45")

-- patch
local patch = c:rrect(20, 31, 44, 51, 4)
c:part(patch, GV.ramp("#f4f0e0"), { pale = true })
c:fill(patch:copy():cut(c:rrect(22, 33, 42, 49, 3)), "#3f8fb0")
c:stitch(c:rrect(22, 33, 42, 49, 3))
-- blue seed emblem
c:part(c:ellipse(32, 42.5, 6, 5.5), GV.ramp("#3f8fb0"))
c:fill(c:rect(31, 34, 32, 37), "#2f5a2a")
c:fill(c:ellipse(35.5, 35.5, 2, 1.5), "#4a8a3e")

-- twine knot and loose ends (drawn last, on top)
c:part(c:rrect(29, 21, 34, 26, 1), GV.ramp("#9a6b3f"), { flat = true })
c:fill(c:line({ { 30, 27 }, { 27, 31 } }, 2), "#9a6b3f")
c:fill(c:line({ { 33, 27 }, { 36, 30 } }, 2), "#9a6b3f")

c:ground(32, 57, 17, 3)
local t = c:save(O .. "aseprite/ph/monja-blanca-seed.aseprite", O .. "png/ph/monja-blanca-seed.png")
print(GV.report(t))

local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- low heap: wide dome with a flat base, slightly peaked top
local pile = c:ellipse(31.5, 48, 24, 24):clip(c:rect(0, 0, 63, 47))
pile:cut(c:rect(0, 0, 63, 23))
pile:add(c:ellipse(31.5, 26, 6, 4):cut(c:rect(0, 30, 63, 63)))
c:build{ { "pile", pile, GV.ramp("#f1ece0"), { pale = true, gloss = { 21, 30 } } } }
-- curved ridge in the powder
local arc = {}
for i = 0, 18 do
  local t = i / 18
  local x = 14 + 36 * t
  local y = 43 - 36 * t * (1 - t)
  arc[#arc + 1] = { math.floor(x + 0.5), math.floor(y + 0.5) }
end
local ridge = c:line(arc, 2):clip(pile:shrink(2))
c:fill(ridge:shift(0, 1):clip(pile:shrink(2)), "#c9a96e")
c:fill(ridge, "#d6c9b6")
-- three sparkle specks
local function speck(x, y)
  c:paint({ "..o..", "..g..", "ogwgo", "..g..", "..o.." }, x - 2, y - 2, { w = "#ffffff", g = "#fff3c8", o = "#f5b860" })

end
speck(25, 35); speck(39, 31); speck(32, 41)

local t = c:save(O .. "aseprite/ph/gnat-dust.aseprite", O .. "png/ph/gnat-dust.png")
print(GV.report(t))

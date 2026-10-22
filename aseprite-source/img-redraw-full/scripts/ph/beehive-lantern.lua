local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local whole = c:rrect(14, 38, 50, 50, 6):add(c:rrect(18, 28, 46, 40, 6)):add(c:rrect(22, 19, 42, 30, 5)):add(c:ellipse(32, 18, 8, 6))
local stand = c:rect(13, 49, 51, 54):add(c:rect(17, 54, 22, 57)):add(c:rect(42, 54, 47, 57))
local p = c:build{
  { "stand",  stand, GV.ramp("#c4925f"), { gloss = false } },
  { "bottom", c:rrect(14, 38, 50, 50, 6), GV.ramp("#d8941a"), { light = whole, gloss = false } },
  { "middle", c:rrect(18, 28, 46, 40, 6), GV.ramp("#e8a317"), { light = whole, gloss = { 22, 31 } } },
  { "top",    c:rrect(22, 19, 42, 30, 5):add(c:ellipse(32, 18, 8, 6)), GV.ramp("#f0b42a"), { light = whole, gloss = { 27, 16 } } },
  { "knob",   c:rrect(30, 8, 34, 13, 1), GV.ramp("#b07a10"), { flat = true } },
}
-- straw grooves
local g = "#b07a10"
for _, row in ipairs({ { 44, p.bottom.m }, { 34, p.middle.m }, { 24, p.top.m } }) do
  local y, m = row[1], row[2]
  m:each(function(x, yy) if yy == y and m:has(x - 1, y) and m:has(x + 1, y) then c:px(x, y, g) end end)
end
-- entrance arch
c:part(c:rrect(27, 41, 37, 50, 4):cut(c:rect(0, 50, 63, 63)), "#44281c", { gloss = false, rim = false, flat = true })
-- side lamps
c:part(c:rrect(9, 30, 14, 36, 2), "gold", { gloss = { 10, 31 } })
c:part(c:rrect(50, 30, 55, 36, 2), "gold", { gloss = { 51, 31 } })
-- bees
for _, b in ipairs({ { 14, 22 }, { 51, 21 } }) do
  local x, y = b[1], b[2]
  c:part(c:ellipse(x, y, 2, 2), "#f08a24", { flat = true })
  c:px(x, y, "#2a1a10"); c:px(x - 1, y, "#2a1a10")
  c:px(x - 1, y - 3, "#f2e4c0"); c:px(x + 1, y - 3, "#f2e4c0")
end
c:seam({ { 15, 49 }, { 49, 49 } }, { free = true })
c:ground(31.5, 58, 20, 1.5)
local t = c:save(O .. "aseprite/ph/beehive-lantern.aseprite", O .. "png/ph/beehive-lantern.png")
print(GV.report(t))

local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- C-shaped loop handle on the right
local handle = c:ellipse(46, 37, 9, 8):cut(c:ellipse(46, 37, 6, 5)):cut(c:rect(0, 0, 44, 63))
-- pot-bellied bottle
local body = c:ellipse(31, 41, 16, 14):add(c:rrect(20, 25, 42, 32, 3))
-- liquid: top half with a wavy lower edge
local liq = c:rect(16, 26, 46, 37)
for x = 16, 46 do
  local k = (x // 4) % 3
  local y = (k == 0) and 38 or ((k == 1) and 39 or 38)
  for yy = 38, y do liq:set(x, yy) end
end
liq:clip(body:shrink(2))
local rim = c:rrect(18, 20, 44, 26, 2)

c:build{
  { "handle", handle, GV.ramp("#d6c9b6"), { gloss = false } },
  { "body",   body,   GV.ramp("#d6c9b6"), { gloss = { 21, 44 } } },
  { "liquid", liq,    "dusk",             { gloss = { 21, 29 } } },
  { "rim",    rim,    GV.ramp("#968f96"), { gloss = { 20, 23 } } },
}
-- cream gloss curl across the liquid
c:paint({ "cc.....", "..cc.cc", "....c.." }, 27, 31, { c = "#fffaf0" })
c:seam({ { 18, 24 }, { 44, 24 } })
local t = c:save(D .. "img-redraw-full/aseprite/ph/elderberry-cordial.aseprite", D .. "img-redraw-full/png/ph/elderberry-cordial.png")
print(GV.report(t))

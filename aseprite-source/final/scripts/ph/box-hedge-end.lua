local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "r" }
local G = GV.ramp("#58a03e")
local xs = { 66.5, 59.5, 52.5, 45.5, 38.5, 31.5 }
local list = {}
table.insert(list, { "body", c:rrect(24, 30, 63, 42, 5), G, { gloss = false } })
for i, x in ipairs(xs) do
  table.insert(list, { "p" .. i, c:ellipse(x, 30, 7, 7):cut(c:rect(0, 34, 63, 63)), G,
    { gloss = (i == #xs) and true or false, contact = false } })
end
local P = c:build(list)
local bm = P.body.m
c:fill(bm:copy():clip(c:rect(25, 37, 63, 40)), G.shade)
c:fill(bm:copy():clip(c:rect(25, 41, 63, 42)), G.deep)
-- broken top highlight, one dash per puff
for i, x in ipairs(xs) do
  local x0 = math.floor(x) - 3
  for dx = 0, 3 do
    if x0 + dx <= 63 then c:px(x0 + dx, 25, G.rim); c:px(x0 + dx, 26, G.rim) end
  end
end
c:ground(44, 43, 20, 1.5)
local t = c:save(O .. "aseprite/ph/box-hedge-end.aseprite", O .. "png/ph/box-hedge-end.png")
print(GV.report(t))

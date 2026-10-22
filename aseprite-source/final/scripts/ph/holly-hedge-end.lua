local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "r" }
local G = GV.ramp("#4f9a3a")
local Rd = GV.ramp("#d6322b")
-- holly: 5 wider spiky puffs, each with prickle points on the crown
local xs = { 68, 59, 50, 41, 32 }
local list = {}
table.insert(list, { "body", c:rrect(24, 30, 63, 42, 4), G, { gloss = false } })
for i, x in ipairs(xs) do
  local m = c:ellipse(x, 31, 8, 7):cut(c:rect(0, 35, 63, 63))
  -- prickles: three small points on the top edge
  m:add(c:poly({ {x - 7, 28}, {x - 4, 21}, {x - 3, 28} }))
  m:add(c:poly({ {x - 2, 25}, {x + 1, 21}, {x + 2, 25} }))
  m:add(c:poly({ {x + 3, 28}, {x + 5, 21}, {x + 7, 28} }))
  table.insert(list, { "p" .. i, m, G, { gloss = (i == #xs) and true or false, contact = false } })
end
local P = c:build(list)
c:fill(P.body.m:copy():clip(c:rect(25, 37, 63, 40)), G.shade)
c:fill(P.body.m:copy():clip(c:rect(25, 41, 63, 42)), G.deep)
-- berry pairs just above the middle
local function berry(x, y)
  c:paint({ ".r.", "rrr", ".rs" }, x, y, { r = Rd.base, s = Rd.shade })
  c:paint({ "rr", "rr" }, x, y + 1, { r = Rd.base })
  c:px(x, y + 1, Rd.gloss)
end
for _, bx in ipairs({ 30, 47, 56 }) do
  berry(bx, 31); berry(bx + 4, 30)
end
local t = c:save(O .. "aseprite/ph/holly-hedge-end.aseprite", O .. "png/ph/holly-hedge-end.png")
print(GV.report(t))

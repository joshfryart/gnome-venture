local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- shaft
c:part(c:line({ {15, 52}, {42, 16} }, 5), GV.ramp("#b6814d"))
-- butt cap
c:part(c:ellipse(14, 53, 3, 3), GV.ramp("#8a4f2a"))
-- star head
local pts, cx, cy = {}, 45.5, 15
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 10 or 4.6
  pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
end
local star = c:poly(pts)
c:part(star, "gold", { gloss = { 41, 12 } })
-- raindrops floating beside the shaft
local d1 = c:ellipse(21, 33, 2.5, 2.5):add(c:poly({ {19, 32}, {21, 27}, {23, 32} }))
c:part(d1, GV.ramp("#a9d6ea"), { gloss = false })
c:px(20, 32, "#c8ecdc")
local d2 = c:ellipse(28, 22.5, 2, 2):add(c:poly({ {26, 22}, {28, 18}, {30, 22} }))
c:part(d2, GV.ramp("#a9d6ea"), { gloss = false })
c:px(27, 22, "#c8ecdc")
c:ground(30, 57, 14, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/masterwork-rain-wand.aseprite", O .. "png/ph/masterwork-rain-wand.png")
print(GV.report(t))

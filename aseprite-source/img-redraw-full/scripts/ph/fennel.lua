local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- diagonal capsule stalk, lower-left to upper-right
local ax, ay, bx, by, r = 17, 44, 42, 24, 7
local dx, dy = bx - ax, by - ay
local L = math.sqrt(dx*dx + dy*dy)
local px, py = -dy / L * r, dx / L * r
local stalk = c:poly({ {ax+px, ay+py}, {bx+px, by+py}, {bx-px, by-py}, {ax-px, ay-py} })
stalk:add(c:ellipse(ax, ay, r, r)); stalk:add(c:ellipse(bx, by, r, r))
-- feathery frond tuft at the top end
local frond = c:ellipse(45, 21, 6, 5)
frond:add(c:ellipse(41, 15, 3, 3)); frond:add(c:ellipse(48, 13, 3, 3))
frond:add(c:ellipse(52, 18, 2.5, 3)); frond:add(c:ellipse(51, 25, 2.5, 2.5))
frond:add(c:ellipse(44.5, 13, 2, 2.5))
local p = c:build{
  { "stalk", stalk, "gold", { gloss = { 22, 37 } } },
  { "frond", frond, GV.ramp("#2f5a2a"), { gloss = false } },
}
-- rib lines along the shaft
local ux, uy = dx / L, dy / L
local function rib(off, t0, t1)
  local m = c:line({ {ax + ux*t0 + px/r*off, ay + uy*t0 + py/r*off}, {ax + ux*t1 + px/r*off, ay + uy*t1 + py/r*off} }, 1)
  m:clip(p.stalk.m); m:cut(frond)
  m:each(function(x, y) if c:get(x, y) ~= GV.R.gold.gloss and c:get(x, y) ~= GV.R.gold.dot then c:px(x, y, "#b8661a") end end)
end
rib(-3, 0, 22); rib(3, 2, 26)
-- frond tips lighter
c:paint({ "m.m", ".m." }, 40, 13, { m = "#4a8a3e" })
c:paint({ "m.m", ".m." }, 47, 11, { m = "#4a8a3e" })
c:paint({ "mm" }, 51, 16, { m = "#4a8a3e" })
-- thread ring around the shaft
c:seam({ { 34 - px*1.2, 30 - py*1.2 }, { 34 + px*1.2, 30 + py*1.2 } })
c:ground(31, 53, 15, 2)
local t = c:save(O .. "aseprite/ph/fennel.aseprite", O .. "png/ph/fennel.png")
print(GV.report(t))

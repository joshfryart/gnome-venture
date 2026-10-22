local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tilt -6 deg: shift top right->left by rotating corner points about (32,33)
local a = math.rad(-6)
local function R(x, y)
  local dx, dy = x - 32, y - 33
  return { 32 + dx * math.cos(a) - dy * math.sin(a), 33 + dx * math.sin(a) + dy * math.cos(a) }
end
local body = c:poly({ R(15, 11), R(49, 11), R(49, 55), R(15, 55) })
local flap = c:poly({ R(15, 11), R(49, 11), R(49, 15), R(32, 27), R(15, 15) })
local win = c:poly({ R(19, 30), R(45, 30), R(45, 50), R(19, 50) })
local p = c:build{
  { "body", body, GV.ramp("#f4e7c3"), { gloss = false } },
  { "flap", flap, GV.ramp("#e6d29c"), { gloss = false } },
  { "win", win, GV.ramp("#fff3c8", { shade = "#d9c58f", deep = "#c9a85a" }), { gloss = false, rim = false } },
}
-- flower picture
local fc = R(32, 38)
local cx, cy = math.floor(fc[1] + 0.5), math.floor(fc[2] + 0.5)
c:line({ { cx, cy + 4 }, { cx, cy + 11 } }, 2)
c:fill(c:line({ { cx, cy + 4 }, { cx, cy + 11 } }, 2), "#6a9a3a")
c:fill(c:ellipse(cx - 4, cy + 9, 3, 1.5), "#8fb06a")
c:fill(c:ellipse(cx + 5, cy + 8, 3, 1.5), "#8fb06a")
local petal = GV.ramp("#e46a9b")
local pm = c:mask()
for i = 0, 4 do
  local ang = -math.pi / 2 + i * 2 * math.pi / 5
  pm:add(c:ellipse(cx + 0.5 + math.cos(ang) * 4, cy + 0.5 + math.sin(ang) * 4, 2.6, 2.6))
end
c:part(pm, petal, { gloss = false, contact = false, contour = false, solid = false })
c:fill(c:ellipse(cx + 0.5, cy + 0.5, 2, 2), "#f5cf6a")
c:px(cx, cy, "#fff1c8")
c:px(cx - 3, cy - 4, "#f6b8cf")
-- leaf line / ground strip
local g1, g2 = R(22, 48), R(42, 48)
c:fill(c:line({ { math.floor(g1[1]), math.floor(g1[2]) }, { math.floor(g2[1]), math.floor(g2[2]) } }, 2), "#8fb06a")
-- seam along flap edge + button at the point
local s1, s2, s3 = R(18, 15.5), R(32, 25.5), R(46, 15.5)
c:seam({ s1, s2, s3 })
local bp = R(32, 27)
c:button(math.floor(bp[1]) - 2, math.floor(bp[2]) - 2)
-- gloss on the packet upper-left
local gp = R(17, 32)
local gx, gy = math.floor(gp[1]), math.floor(gp[2])
c:paint({ "g", "g", "g", "g", "g", ".", "d" }, gx, gy, { g = "#fff3c8", d = "#ffffff" })
local t = c:save(O .. "aseprite/flowers/packet.aseprite", O .. "png/flowers/packet.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local green = GV.ramp("#b0bc66")
local cream = GV.ramp("#f8eed2")
-- tunic
local tunic = c:ellipse(39.5, 100, 34, 22):cut(c:rect(0, 0, 79, 77))
-- head (wide flat toad head) + eye bumps
local head = c:ellipse(39.5, 59, 27, 18)
local bumpL = c:ellipse(25, 36, 9.5, 9.5)
local bumpR = c:ellipse(54, 36, 9.5, 9.5)
local p = c:build{
  { "back",  c:ellipse(39.5, 50, 36, 36), GV.ramp("#e6d2ae"), { gloss = false } },
  { "tunic", tunic, GV.ramp("#3f93b2") },
  { "head",  head, green, { light = head:copy():add(bumpL):add(bumpR) } },
  { "bumpL", bumpL, green, { gloss = false, contact = false } },
  { "bumpR", bumpR, green, { gloss = false, contact = false } },
  { "chin",  c:ellipse(39.5, 64, 16, 8), cream, { gloss = false } },
  { "whiteL", c:ellipse(25, 35.5, 6.5, 6), cream, { flat = true } },
  { "whiteR", c:ellipse(54, 35.5, 6.5, 6), cream, { flat = true } },
}
-- collar V
c:fill(c:poly({ {30, 78}, {50, 78}, {40, 88} }):clip(p.tunic.m), "#256a80")
c:seam({ {40, 88}, {40, 99} })
-- pupils 4x4 with glint
for _, x in ipairs({ 25, 52 }) do
  c:fill(c:rrect(x, 34, x + 3, 37, 1), "#2a1a10")
  c:fill(c:rect(x, 35, x + 3, 36), "#2a1a10")
  c:px(x + 1, 35, "#f8eed2")
end
-- warts (diamond-ish beans)
for _, w in ipairs({ { 18, 54 }, { 59, 55 }, { 26, 69 }, { 52, 69 }, { 39, 50 } }) do
  c:spot(c:ellipse(w[1] + 0.5, w[2] + 0.5, 1.5, 1.5), "#58a03e", "#7ab55c")
end
c:px(36, 56, "#4a2c1a"); c:px(37, 56, "#4a2c1a")
c:px(42, 56, "#4a2c1a"); c:px(43, 56, "#4a2c1a")
-- wide smile
c:fill(c:line({ { 23, 63 }, { 31, 67 }, { 39, 68 }, { 40, 68 }, { 48, 67 }, { 56, 63 } }, 2), "#2a1a10")
-- flower crown: vine + 7 blossoms across the forehead under the eye bumps
c:part(c:line({ { 15, 47 }, { 27, 45 }, { 39, 44 }, { 52, 45 }, { 64, 47 } }, 2), GV.ramp("#4a8a3e"), { flat = true, contact = false })
local cols = { "#d9667f", "#f5cf6a", "#f8eed2", "#c3b2ea", "#d9667f", "#f5cf6a", "#f8eed2" }
local xs = { 18, 25, 32, 39, 46, 53, 60 }
local ys = { 47, 44, 45, 43, 45, 44, 47 }
for i = 1, 7 do
  local x, y = xs[i], ys[i]
  local m = c:ellipse(x, y, 2.5, 2.5)
  c:part(m, GV.ramp(cols[i]), { flat = true, contact = false })
  c:px(x, y, "#e8a317")
end
local t = c:save(O .. "aseprite/ph/npc-marigold-puddleby.aseprite", O .. "png/ph/npc-marigold-puddleby.png")
print(GV.report(t))

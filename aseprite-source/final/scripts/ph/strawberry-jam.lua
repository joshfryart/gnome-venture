local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local jar = c:rrect(18, 19, 46, 52, 7)
local jam = c:rrect(20, 27, 44, 50, 5)
local label = c:rrect(22, 34, 42, 43, 2)
local lid = c:rrect(17, 11, 47, 19, 2)
lid:add(c:ellipse(22, 19.5, 5, 2.5)); lid:add(c:ellipse(32, 19.5, 5, 2.5)); lid:add(c:ellipse(42, 19.5, 5, 2.5))

c:build{
  { "jar",   jar,   GV.ramp("#a9d6ea"), { gloss = { 22, 25 } } },
  { "jam",   jam,   GV.ramp("#d6322b", { shade = "#ae2a2a" }), { gloss = false } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "lid",   lid,   "gold", { gloss = { 21, 13 } } },
}
-- seed specks on the jam, left and low
for _, s in ipairs({ { 23, 45 }, { 26, 48 }, { 30, 46 }, { 36, 48 }, { 24, 30 } }) do c:px(s[1], s[2], "#f5cf6a") end
-- label writing
c:paint({ "uuuu.uuu", "........", ".uuu.uuuu", "........", "uuu.uu" }, 27, 37, { u = "umber" })
-- seam under the scallops, button on the lid
c:seam({ { 19, 24 }, { 45, 24 } })
c:button(40, 13)

local t = c:save(O .. "aseprite/ph/strawberry-jam.aseprite", O .. "png/ph/strawberry-jam.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:rrect(14, 22, 51, 50, 8)
c:part(body, "skin")
local kn = { {19, 22}, {28, 20}, {37, 20}, {46, 22} }
for i, k in ipairs(kn) do
  c:part(c:ellipse(k[1], k[2], 5, 5):cut(c:rect(0, k[2] + 3, 63, 63)), "skin", { gloss = false, contact = false, light = body })
end
for _, x in ipairs({ 23, 32, 41 }) do
  c:fill(c:line({ { x, 21 }, { x, 31 } }, 2), "#b6814d")
end
local thumb = c:rrect(12, 32, 42, 46, 7)
c:part(thumb, "skin", { light = thumb })
c:fill(c:line({ { 46, 35 }, { 46, 43 } }, 2), "#b6814d")
local t = c:save(O .. "aseprite/ico/ico-fist.aseprite", O .. "png/ico/ico-fist.png")
print(GV.report(t))

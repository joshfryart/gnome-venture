local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
-- twisted top: a tilted pinched pill
local twist = c:line({ {30, 8}, {34, 16} }, 6):add(c:ellipse(31, 8, 3.5, 3))
c:build{
  { "twist", twist, paper },
  { "cone",  c:poly({ {16, 20}, {49, 20}, {33, 57}, {32, 57} }), paper },
  { "rim",   c:rrect(14, 16, 50, 22, 2), GV.ramp("#dcb06a"), { gloss = { 17, 17 } } },
  { "label", c:ellipse(32.5, 32, 6, 6.5), GV.ramp("#b0bc66"), { contact = false } },
}
-- fold lines on the twist
c:paint({ "f..", ".f.", "..f" }, 29, 9, { f = "#dcb06a" })
c:paint({ "f..", ".f.", "..f" }, 32, 12, { f = "#dcb06a" })
-- seam across the rim band
c:seam({ {16, 19}, {48, 19} })
-- sage leaf on the label
c:paint({
  "..g..",
  ".ggg.",
  "gglgg",
  "gglgg",
  ".ggg.",
  "..l..",
}, 30, 29, { g = "#58a03e", l = "#2f5a2a" })
-- seed dots near the tip
for _, p in ipairs({ { 28, 42 }, { 35, 42 }, { 31, 47 } }) do
  c:paint({ ".s.", "sss", ".s." }, p[1], p[2], { s = "#8c4a1a" })
end
local t = c:save(O .. "aseprite/ph/mexican-sage-seed.aseprite", O .. "png/ph/mexican-sage-seed.png")
print(GV.report(t))

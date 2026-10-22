local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- slumped pouch: wider at the bottom
local body = c:ellipse(31.5, 43, 18, 13)
body:add(c:ellipse(31.5, 47, 20, 9))
body:add(c:poly({{22,26},{42,26},{48,36},{16,36}}))
local ruffle = c:ellipse(26, 21, 5, 3.5):add(c:ellipse(37, 21, 5, 3.5)):add(c:ellipse(31.5, 19, 4, 3))
local puffm = c:ellipse(31.5, 12, 6.5, 6)
local leaf = c:poly({{38,11},{42,7},{46,8},{45,12},{41,14}})
local p = c:build{
  { "puff", puffm, GV.ramp("#b0bc66") },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
  { "ruffle", ruffle, GV.ramp("#f1ece0") },
  { "body", body, GV.ramp("#f1ece0"), { stitch = { side = "lit" } } },
  { "neck", c:rrect(24, 23, 39, 29, 2), GV.ramp("#dcb06a") },
  { "label", c:rrect(25, 38, 38, 48, 3), GV.ramp("#b0bc66") },
}
-- drawstring band and tails
c:seam({ {24, 27}, {39, 27} }, { on = 2, off = 1 })
c:limb({ {28, 30}, {26, 33}, {23, 36} })
c:limb({ {35, 30}, {37, 33}, {40, 36} })
c:fill(c:line({ {28, 30}, {26, 33}, {23, 36} }, 2), "#e8a317")
c:fill(c:line({ {35, 30}, {37, 33}, {40, 36} }, 2), "#e8a317")
c:px(23, 36, "#b8661a"); c:px(40, 36, "#b8661a")
c:button(30, 25)
-- seed dots on label
for _, x in ipairs({ 28, 31, 34 }) do c:paint({ "ss", "ss" }, x, 44, { s = "#8c4a1a" }) end
c:paint({ "k.k", ".k." }, 30, 40, { k = "#4a8a3e" })
local t = c:save(O .. "aseprite/ph/kapok-blossom-seed.aseprite", O .. "png/ph/kapok-blossom-seed.png")
print(GV.report(t))

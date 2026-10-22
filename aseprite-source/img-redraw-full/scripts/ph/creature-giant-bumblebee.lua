local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wings: wide horizontal ovals, slightly lifted at the outer tips
local wingL = c:ellipse(21.5, 29, 10, 6.5)
local wingR = c:ellipse(42.5, 29, 10, 6.5)
local abd = c:ellipse(32, 41.5, 11.5, 12)
-- stripes: sagging bands clipped to abdomen
local stripes = c:mask()
for _, y in ipairs({ 35, 41, 47 }) do
  stripes:add(c:line({ {19, y}, {26, y + 2}, {32, y + 2}, {38, y + 2}, {45, y} }, 3))
end
stripes:clip(abd:copy())
local sting = c:poly({ {30, 52}, {35, 52}, {32.5, 58} })
local head = c:ellipse(32, 25, 8, 8)
local muz = c:ellipse(32, 28.5, 4, 2.5)
local antL = c:line({ {29, 18}, {27, 16}, {25, 15} }, 2)
local antR = c:line({ {35, 18}, {37, 16}, {39, 15} }, 2)
local clubL = c:rrect(22, 12, 25, 15, 1)
local clubR = c:rrect(39, 12, 42, 15, 1)

local p = c:build{
  { "antL", antL, "dusk", { flat = true } },
  { "antR", antR, "dusk", { flat = true } },
  { "clubL", clubL, "dusk", { flat = true } },
  { "clubR", clubR, "dusk", { flat = true } },
  { "wingL", wingL, GV.ramp("#e6f1ec") },
  { "wingR", wingR, GV.ramp("#e6f1ec") },
  { "sting", sting, "dusk", { flat = true } },
  { "abd", abd, "gold", { stitch = { side = "lit" } } },
  { "stripes", stripes, "dusk", { gloss = false, light = abd, contact = false } },
  { "head", head, "gold" },
  { "muz", muz, GV.ramp("#f8eed2"), { gloss = false } },
}
-- wing veins
c:paint({ "v....", ".v...", "..vvv" }, 14, 27, { v = "#b9cfc6" })
c:paint({ "....v", "...v.", "vvv.." }, 45, 27, { v = "#b9cfc6" })
c:eye(26, 21, true); c:eye(35, 21, true)
c:paint({ "m...m", ".mmm." }, 30, 28, { m = "umber" })
local t = c:save(O .. "aseprite/ph/creature-giant-bumblebee.aseprite", O .. "png/ph/creature-giant-bumblebee.png")
print(GV.report(t))

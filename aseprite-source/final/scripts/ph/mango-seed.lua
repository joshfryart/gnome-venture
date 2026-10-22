local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local linen = GV.ramp("#e9c98a", { shade = "#b07a45", deep = "#8a4f2a" })
-- slumped sack: wide low belly, tapering shoulders up to the cinched neck
local body = c:ellipse(32, 41, 18, 11.5)
body:add(c:poly({ {26, 23}, {38, 23}, {46, 34}, {18, 34} }))
body = body:closed(3)
-- gathered frill above the cord, flaring out
local frill = c:poly({ {22, 15}, {42, 15}, {37, 23}, {27, 23} })
frill:add(c:ellipse(32, 15.5, 10, 2))
local sprout = c:rect(31, 9, 33, 16)
local leaf = c:ellipse(37, 10.5, 3, 2)
local cord = c:line({ {25, 22}, {39, 22} }, 2)
cord:add(c:line({ {28, 23}, {22, 29} }, 2)); cord:add(c:line({ {36, 23}, {42, 30} }, 2))
local knots = c:ellipse(21, 30, 1.5, 1.5):add(c:ellipse(43, 31, 1.5, 1.5))
local label = c:rrect(22, 32, 42, 47, 5)
local seed = c:ellipse(32, 39.5, 5.5, 6)
c:build{
  { "body", body, linen, { stitch = { side = "lit" } } },
  { "stem", sprout, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
  { "frill", frill, linen, { light = body } },
  { "cord", cord, "#a8582f", { flat = true } },
  { "knots", knots, "#a8582f", { flat = true } },
  { "label", label, "#f4f0e0" },
  { "seed", seed, GV.ramp("#e8a317", { shade = "#f08a24" }) },
}
-- frill folds
for _, x in ipairs({ 27, 32, 37 }) do
  for y = 17, 20 do if (y % 3) ~= 2 then c:px(x, y, "#b07a45") end end
end
-- count dots under the label
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 49, x + 1, 50), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/mango-seed.aseprite", O .. "png/ph/mango-seed.png")
print(GV.report(t))

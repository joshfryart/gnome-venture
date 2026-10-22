local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local orange = GV.ramp("#f08a24", { shade = "#e0501f" })
local ember  = GV.ramp("#e0501f")
local cream  = GV.ramp("#f1ece0")
local petal  = GV.ramp("#ffc27a")
local red    = "red"
local leaf   = GV.ramp("#58a03e")

-- pouch body, leaning right: bulge low-left, shoulder high-right
local body = c:ellipse(30.5, 42, 17, 11)
body:add(c:ellipse(35, 35, 12, 8))
-- gathered neck tilted right
local neck = c:poly({ {26, 30}, {40, 30}, {43, 18}, {32, 16} })
-- folded-over top flopping to the right
local fold = c:poly({ {29, 10}, {41, 11}, {50, 18}, {48, 23}, {40, 21}, {31, 18} })

local p = c:build{
  { "body", body, orange, { stitch = { side = "lit" } } },
  { "neck", neck, ember },
  { "fold", fold, ember, { gloss = { 33, 12 } } },
}
-- drawstring band with bow and tails
local band = c:line({ {25, 29}, {41, 28} }, 2)
c:part(band, cream, { flat = true })
c:part(c:ellipse(22.5, 28, 2.5, 2), cream, { flat = true })
c:part(c:ellipse(19, 30, 2.5, 2), cream, { flat = true })
c:part(c:line({ {21, 31}, {19, 37} }, 2), cream, { flat = true })
c:part(c:line({ {24, 31}, {24, 38} }, 2), cream, { flat = true })
-- leaf
c:part(c:poly({ {35, 32}, {41, 30}, {40, 34}, {36, 35} }), leaf, { flat = true })
-- five-petal flower
local fx, fy = 31, 42
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  c:part(c:ellipse(fx + math.cos(a) * 5, fy + math.sin(a) * 5, 3), petal, { gloss = false })
end
c:part(c:ellipse(fx, fy, 3), red, { gloss = false })
c:paint({ "s.s", ".s." }, fx - 1, fy - 1, { s = "#f5cf6a" })
-- back seam glimpse along the right side
c:seam({ {46, 32}, {47, 40}, {45, 47} })
c:ground(32, 54, 17, 2)
local t = c:save(O .. "aseprite/ph/red-hibiscus-seed.aseprite", O .. "png/ph/red-hibiscus-seed.png")
print(GV.report(t))

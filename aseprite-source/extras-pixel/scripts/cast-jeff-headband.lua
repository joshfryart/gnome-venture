-- Jeff headband (Expert tier host): red focus headband with tails flying, squinting hard at a tiny
-- piece pinched up by his face, tight determined mouth, sweat drop. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -3, 3
local body = K.jeffBody(c, dx, dy)
local armL = c:rrect(8, 39, 14, 45, 2); armL:add(c:ellipse(8.5, 42, 2, 3.5)); armL:cut(body:grow(1))
local armR = c:line({ {40, 42}, {47, 40}, {50, 36} }, 4); armR:cut(body:grow(1))
-- headband across the brow, following the slant of the top edge, knot + two tails on the right
local band = c:poly({ {12, 25}, {44, 22}, {44, 28}, {12, 31} })
band:clip(body:grow(1))
local knot = c:ellipse(45, 25, 2.5, 2.5)
local tails = c:poly({ {45, 23}, {54, 17}, {56, 20}, {47, 25} })
tails:add(c:poly({ {46, 26}, {56, 25}, {55, 29}, {46, 28} }))
local fist = c:ellipse(50, 33, 3.5, 3.5)
local drop = c:ascii({ "..d..", ".ddd.", ".ddd.", "ddddd", "ddddd", ".ddd." }, 15, 9)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "tails", tails, "red", { flat = true } },
  { "band", band, GV.ramp("#dd3a2a"), { gloss = { 15, 26 }, cres = 2, deep = 0 } },
  { "knot", knot, "red", { flat = true } },
  K.jeffArm("fist", fist),
  { "drop", drop, "water", { flat = true, contact = false } },
}
c:px(16, 12, "#eaf8e4")
c:seam({ {14, 30}, {42, 27} })                                            -- hem on the band
c:paint({ "u.u" }, 48, 31, { u = "umber" })
c:paint({ "g", "g" }, 56, 34, { g = "#f5cf6a" }); c:paint({ "gg" }, 52, 44, { g = "#f5cf6a" })
-- squint: heavy flat lids over narrowed eyes, both
c:paint({ "uuuuu", ".hhuu", "..uu." }, 20+dx, 32+dy-1, { u = "umber", h = "halo" })
c:paint({ "uuuuu", ".hhuu", "..uu." }, 36+dx, 31+dy-1, { u = "umber", h = "halo" })
K.jeffFace(c, dx, dy, "custom", { eyes = "none", mouth = "focus" })
K.save(c, "jeff-headband")

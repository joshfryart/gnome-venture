-- Badge entered: took-part rosette. Gold scalloped ring, Jeff's green jigsaw face in the middle, two red tails.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tailL = c:poly({ {22, 36}, {32, 36}, {28, 55}, {18, 53} }); tailL:cut(c:poly({ {21, 54}, {24, 49}, {27, 55} }))
local tailR = c:poly({ {31, 36}, {41, 36}, {45, 53}, {35, 55} }); tailR:cut(c:poly({ {36, 55}, {39, 49}, {42, 54} }))
local ring = c:ellipse(31.5, 26, 17, 17)
for i = 0, 11 do                                                  -- scallops
  local a = i * math.pi / 6
  ring:add(c:ellipse(31.5 + 16 * math.cos(a), 26 + 16 * math.sin(a), 3, 3))
end
-- Jeff's piece: block, knob up, tab right, notch bottom (same build as jeff-v2, scaled to the rosette)
local face = c:rrect(22, 19, 40, 35, 2)
face:add(c:ellipse(31.5, 16, 4.5, 4)); face:add(c:ellipse(42, 26.5, 3.5, 3.5))
face:cut(c:ellipse(31.5, 36, 4, 3))

c:build{
  { "tailL", tailL, "red", { gloss = false } },
  { "tailR", tailR, GV.ramp("#b8452f"), { gloss = false, contour = false } },
  { "ring",  ring,  "gold", { gloss = { 18, 15 } } },
  { "face",  face,  GV.ramp("#1fb86b"), { gloss = { 24, 21 } } },
}
c:fill(ring:shrink(4):cut(ring:shrink(5)):cut(face:grow(1)), "#d0862a")   -- inner groove
c:seam({ {25, 40}, {27, 51} }); c:seam({ {38, 40}, {36, 51} })
-- Jeff face, shrunk: wide small eyes, raised brow, big grin with a tooth row
c:eye(23, 23, true); c:eye(35, 22, true)
c:paint({ "uuu" }, 35, 20, { u = "umber" })
c:paint({ "u.......u", ".u.....u.", ".ucccccu.", "..uuuuu.." }, 27, 28, { u = "umber", c = "#f1ece0" })
K.save(c, "badge-entered")

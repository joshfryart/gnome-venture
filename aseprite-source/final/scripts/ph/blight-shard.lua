-- blight-shard : a jagged black shard that hums and points down.
-- One long splinter hanging tip-down, tilted a little, with a broken jagged crown on top,
-- a lit and a shaded face split by a ridge, a sickly green vein-sheen down the lit face,
-- and two small hum arcs either side. Dusk family (GV.R.dusk) for the black,
-- blight sheen borrowed from creature-blight-mother (#8f9c7a / #7a8a52).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dusk  = GV.R.dusk
local dark  = GV.ramp("#291d4a", { rim = "#3e2f66", gloss = "#54447f", dot = "#7b66b4" })
local sick  = "#8f9c7a"   -- blight sheen
local sickD = "#7a8a52"   -- blight sheen, darker

-- the shard: jagged broken top, long taper to a low point, a chip on the left flank
local shard = c:poly({
  {16, 15}, {21, 10}, {24, 14}, {29, 9}, {33, 12}, {38, 8}, {42, 13}, {46, 16},
  {44, 25}, {40, 36}, {35, 46}, {31, 55}, {29, 55},
  {26, 46}, {22, 40}, {24, 37}, {20, 28},
})
-- shaded right face, split from the lit face by a ridge from the top peak to the tip
local face = c:poly({ {34, 11}, {38, 8}, {42, 13}, {46, 16}, {44, 25}, {40, 36}, {35, 46}, {31, 55}, {30, 55} }):clip(shard)

local p = c:build{
  { "shard", shard, dusk, { gloss = { 22, 17 } } },
  { "face",  face,  dark, { light = shard, gloss = false, contour = false, contact = false } },
}

-- sickly sheen: a thin vein down the lit face, brightest near the top
local inner = shard:shrink(2):cut(face)
c:fill(c:line({ {29, 15}, {28, 24}, {29, 32}, {28, 40} }, 1):clip(inner), sickD)
c:fill(c:line({ {29, 16}, {28, 23} }, 1):clip(inner), sick)
-- a second faint glint on the shaded face
c:fill(c:line({ {39, 18}, {38, 25} }, 1):clip(face:shrink(2)), "#4a3a7a")

-- hum: two small arcs beside the shard (left "(" and right ")")
c:paint({ ".h", "h.", "h.", ".h" }, 10, 26, { h = sick })
c:paint({ "h.", ".h", ".h", "h." }, 51, 30, { h = sick })

local t = c:save(D .. "final/aseprite/ph/blight-shard.aseprite", PNG .. "blight-shard.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

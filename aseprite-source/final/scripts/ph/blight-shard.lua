-- blight-shard : a jagged black shard that hums and points down.
-- One long crystal splinter hanging tip-down with a broken, jagged crown on top. Three prism
-- faces (lit lavender bevel, dusk front, near-black right face), a sickly green vein-sheen down
-- the front face, and two small hum arcs either side. Dusk family (GV.R.dusk) for the black;
-- blight sheen borrowed from creature-blight-mother (#8f9c7a / #7a8a52).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dusk  = GV.R.dusk
local bevel = GV.ramp("#54447f", { rim = "#7b66b4", shade = "#3e2f66", deep = "#291d4a", bounce = "#4a3a7a" })
local dark  = GV.ramp("#231840", { rim = "#3e2f66", shade = "#1e1438", deep = "#1e1438", bounce = "#291d4a" })
local sick  = "#8f9c7a"   -- blight sheen
local sickD = "#7a8a52"   -- blight sheen, darker

-- the shard: jagged broken crown, straight flanks converging to a low point
local shard = c:poly({
  {18, 14}, {22, 8}, {26, 12}, {30, 5}, {34, 10}, {38, 6}, {42, 11}, {46, 9},
  {44, 22}, {39, 38}, {34, 57}, {32, 57},
  {26, 40}, {20, 25},
})
-- prism faces: lit bevel on the left, dark face on the right, ridges meet at the tip
local left  = c:poly({ {18, 14}, {22, 8}, {25, 11}, {26, 24}, {29, 40}, {33, 57}, {32, 57}, {26, 40}, {20, 25} }):clip(shard)
local right = c:poly({ {37, 7}, {38, 6}, {42, 11}, {46, 9}, {44, 22}, {39, 38}, {34, 57}, {33, 57}, {35, 38}, {37, 22} }):clip(shard)

c:build{
  { "shard", shard, dusk,  { gloss = false } },
  { "left",  left,  bevel, { light = shard, contour = false, contact = false, gloss = { 21, 13 } } },
  { "right", right, dark,  { light = shard, contour = false, contact = false, gloss = false } },
}

-- sickly sheen: a thin vein down the front face, brightest near the crown
local front = shard:shrink(2):cut(left:grow(1)):cut(right:grow(1))
c:fill(c:line({ {31, 12}, {30, 22}, {32, 31}, {31, 40} }, 1):clip(front), sickD)
c:fill(c:line({ {31, 13}, {30, 21} }, 1):clip(front), sick)
-- violet glint on the dark face
c:fill(c:line({ {41, 13}, {40, 20} }, 1):clip(right:shrink(1)), "#4a3a7a")

-- hum: one small arc each side of the shard, as if it vibrates
c:paint({ ".h", "h.", "h.", "h.", ".h" }, 11, 24, { h = sick })
c:paint({ "h.", ".h", ".h", ".h", "h." }, 50, 27, { h = sick })

local t = c:save(D .. "final/aseprite/ph/blight-shard.aseprite", PNG .. "blight-shard.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

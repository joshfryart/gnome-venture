-- blight-shard : a jagged black shard that hums and points down.
-- One long crystal splinter hanging tip-down with a broken, jagged crown on top. Three prism
-- faces (lit lavender bevel, dusk front, near-black right face), a sickly green vein-sheen down
-- the front face, and two small hum arcs either side. Dusk family (GV.R.dusk) for the black;
-- blight sheen borrowed from creature-blight-mother (#8f9c7a / #7a8a52).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bevel = GV.ramp("#54447f", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#7b66b4",
  shade = "#3e2f66", deep = "#291d4a", bounce = "#4a3a7a" })  -- lit left face (dusk legs tone)
local front = GV.ramp("#2e2252", { gloss = "#7b66b4", dot = "#a894dc", rim = "#4a3a7a",
  shade = "#231840", deep = "#1e1438", bounce = "#291d4a" })  -- near-black front face
local dark  = GV.ramp("#1e1438", { rim = "#291d4a", shade = "#1e1438", deep = "#1e1438", bounce = "#231840" })
local sick  = "#8f9c7a"   -- blight sheen
local sickD = "#7a8a52"   -- blight sheen, darker

-- the shard: a broken crown (tall left prong, middle prong, slanted right break),
-- straight flanks converging to a low point
local shard = c:poly({
  {18, 23}, {21, 6}, {27, 20}, {32, 9}, {37, 18}, {45, 11}, {46, 22},
  {34, 57}, {32, 57},
})
-- prism faces: each crown prong tops one face; ridges run from the notches to the tip
local left  = c:poly({ {10, 4}, {21, 4}, {27, 20}, {28, 33}, {31, 46}, {33, 60}, {10, 60} }):clip(shard)
local right = c:poly({ {37, 18}, {45, 8}, {55, 8}, {55, 60}, {34, 60}, {35, 46}, {37, 32} }):clip(shard)

c:build{
  { "shard", shard, front, { gloss = false } },
  { "left",  left,  bevel, { light = shard, contour = false, contact = false, gloss = { 21, 15 } } },
  { "right", right, dark,  { light = shard, contour = false, contact = false, gloss = false } },
}

-- sickly sheen: a thin vein down the front face, brightest near the crown
local mid = shard:shrink(2):cut(left:grow(1)):cut(right:grow(1))
c:fill(c:line({ {32, 14}, {31, 23}, {32, 32}, {31, 42} }, 1):clip(mid), sickD)
c:fill(c:line({ {32, 14}, {31, 22} }, 1):clip(mid), sick)
-- violet glint on the dark face
c:fill(c:line({ {42, 18}, {41, 25} }, 1):clip(right:shrink(1)), "#4a3a7a")

-- hum: one small arc each side of the shard, as if it vibrates
c:paint({ ".h", "h.", "h.", "h.", ".h" }, 10, 26, { h = sick })
c:paint({ "h.", ".h", ".h", ".h", "h." }, 52, 28, { h = sick })

local t = c:save(D .. "final/aseprite/ph/blight-shard.aseprite", PNG .. "blight-shard.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

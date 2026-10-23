-- kiln-key: a heavy clay key, glazed blue. Chunky upright key: fat round bow with
-- a big hole, thick shaft, blocky two-ward bit. Blue glaze runs down from the bow
-- and stops in drips, leaving the bare fired clay at the tip.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glaze = GV.ramp("#3a6fb8")          -- water family, pushed to cobalt glaze
local clay  = GV.ramp("#b0603a")          -- soil/brick family: bare fired terracotta

-- whole key silhouette (clay underneath)
local bow   = c:ellipse(27.5, 16.5, 12, 10)
local shaft = c:rrect(23, 25, 31, 56, 2)
local bit   = c:rrect(29, 42, 44, 56, 1)
bit:cut(c:rect(35, 47, 45, 51))              -- gap between the two wards
bit:cut(c:rect(41, 54, 45, 58))              -- small step on the lower ward
local key = bow:copy():add(shaft):add(bit)
local hole = c:ellipse(27.5, 15.5, 4.5, 4.5)
key:cut(hole)

-- glaze coat: everything above a drippy line
local coat = key:copy():cut(c:rect(0, 40, 63, 63))
coat:add(c:rrect(23, 38, 26, 47, 1):clip(key))   -- drip, left of shaft
coat:add(c:rrect(28, 38, 31, 51, 1):clip(key))   -- long drip
coat:add(c:rrect(34, 38, 38, 45, 1):clip(key))   -- drip on the upper ward
-- collar ring where bow meets shaft
local collar = c:rrect(20, 26, 34, 30, 2)

local p = c:build{
  { "clay",   key,    clay,  { light = key } },
  { "coat",   coat,   glaze, { light = key, gloss = { 18, 11 } } },
  { "collar", collar, glaze, { light = key, gloss = false } },
}
-- twine binding on the collar
c:seam({ { 21, 28 }, { 33, 28 } })

local t = c:save(D .. "final/aseprite/ph/kiln-key.aseprite", PNG .. "kiln-key.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

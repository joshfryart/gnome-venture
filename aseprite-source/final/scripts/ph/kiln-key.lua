-- kiln-key: a heavy clay key, glazed blue. Chunky upright key: fat round bow with
-- a thumb-pressed hole, thick shaft, blocky bit. Blue glaze runs down from the bow
-- and stops in drips, leaving the bare fired clay at the tip.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glaze = GV.ramp("#3a6fb8")          -- water family, pushed to cobalt glaze
local clay  = GV.ramp("#b0603a")          -- soil/brick family: bare fired terracotta

-- whole key silhouette (clay underneath)
local bow   = c:ellipse(28.5, 19.5, 13, 12)
local shaft = c:rrect(24, 28, 33, 56, 2)
local bit   = c:rrect(33, 40, 43, 46, 1)
bit:add(c:rrect(33, 49, 46, 55, 1))
local key = bow:copy():add(shaft):add(bit)
local hole = c:ellipse(28.5, 18.5, 4.5, 4.5)
key:cut(hole)

-- glaze coat: everything above a drippy line
local coat = key:copy():cut(c:rect(0, 44, 63, 63))
coat:add(c:rrect(24, 40, 27, 48, 1):clip(key))   -- drip, left
coat:add(c:rrect(30, 40, 33, 51, 1):clip(key))   -- long drip, right of shaft
coat:add(c:rrect(37, 40, 41, 47, 1):clip(key))   -- drip on the upper ward
-- collar ring where bow meets shaft
local collar = c:rrect(21, 29, 36, 33, 2)

local p = c:build{
  { "clay",   key,    clay,  { light = key } },
  { "coat",   coat,   glaze, { light = key, gloss = { 18, 12 }, contact = true } },
  { "collar", collar, glaze, { light = key, gloss = false } },
}
-- thumb-press dimples on the bow (glaze pooled darker)
c:spot(c:ellipse(19.5, 21, 1.5, 1.5), glaze.shade, glaze.base)
c:spot(c:ellipse(37.5, 21, 1.5, 1.5), glaze.shade, glaze.base)
c:spot(c:ellipse(28.5, 28.5 - 3, 1, 0.5), glaze.shade, glaze.base)
-- bit teeth notch lines on bare clay
c:fill(c:rect(43, 51, 43, 53), clay.deep)
-- twine wrap on the collar: a short seam with its button
c:seam({ { 22, 31 }, { 35, 31 } })

local t = c:save(D .. "final/aseprite/ph/kiln-key.aseprite", PNG .. "kiln-key.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

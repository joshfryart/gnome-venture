-- flood-boots-b-fine: Fine rank of the Flood Boots cut b "Sure Foot" (sewn gingham patch). Opus second pass, batch4b. 64x64.
-- Start: the finished cut-a Fine (art-2701-batch3/wear/opus3/flood-boots-fine.png: gold cuff bands, polished cuffs,
-- gold sole piping, pull-loop rivet, rain bead) with the cut-b patch grafted in from art-2701-opus/wear/flood-boots-b.png.
-- Fix: the cut-a strap and 9x7 buckle sat at rows 28-34, right where the patch is sewn. The strap is moved up to
-- rows 22-25 (just under the cuffs, across both boots) and the buckle is re-cut to 9x6 (rows 21-26), so one row of
-- green shaft separates it from the patch's top stitches. The old strap rows go back to the shared shaft texture
-- (taken from the cut-a Lined, which carries the same rim, gloss and bounce).
-- quirk kept: splash at the toe, dog-ear on the patch, rain bead on the front cuff.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local img, M = O.graft(O.OP3 .. "flood-boots-fine.png", O.V3 .. "/art-2701-opus/wear/flood-boots-b.png", O.PH .. "flood-boots.png")
local F = O.load(O.OP3 .. "flood-boots-fine.png")
local L = O.load(O.OP3 .. "flood-boots-lined.png")

-- 1. unpick the old strap and buckle (rows 28-34) back to plain shaft
for y = 28, 34 do for x = 13, 38 do
  if not O.inMask(M, x, y) then img:putPixel(x, y, L:getPixel(x, y)) end
end end
-- 2. strap + contact shadow, rows 30-34 of the cut-a Fine moved up to 22-26
for y = 30, 34 do for x = 13, 38 do
  if not (x >= 15 and x <= 23) then img:putPixel(x, y - 8, F:getPixel(x, y)) end
end end
-- 3. buckle re-cut to 9x6 (drop its middle row 31), rows 21-26
local rows = { 28, 29, 30, 32, 33, 34 }
for i, sy in ipairs(rows) do for x = 15, 23 do img:putPixel(x, 20 + i, F:getPixel(x, sy)) end end
O.save4(img, "flood-boots-b-fine")

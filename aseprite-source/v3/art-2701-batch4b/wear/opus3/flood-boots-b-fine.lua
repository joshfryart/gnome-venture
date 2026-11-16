-- flood-boots-b-fine: Fine rank, Flood Boots cut b (gingham patch with a dog-eared corner). Opus richness pass.
-- Base: ../opus2/flood-boots-b-fine.png (= finished cut-a Fine + the grafted cut-b patch; read only). Added:
--  * the strap now crosses the front boot only: its run over the back boot is unpicked back to the back shaft's
--    rubber (copied from the row under it), so it no longer reads as a second cuff band; a pale-gold sparkle on the lit corner of the front cuff is the gleam;
--  * the shared rubber crinkle, gloss streak and tread grain (_boots.lua).
-- The patch, its stitches and the dog-ear are untouched. No fleece.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local G = O.GOLD6
local img = O.load(O.OP2 .. "flood-boots-b-fine.png")
-- unpick the strap over the back boot (rows 22-25, x 29-38): copy the back shaft's row 27 into each strap row;
-- the ink seam between the boots (x 28) runs through again
for y = 22, 25 do
  for x = 29, 38 do local h = O.get(img, x, 27); if h then O.px(img, x, y, h) end end
  O.px(img, 28, y, O.INK)
end
loadfile(O.ME .. "_boots.lua")(O)(img, "fine")
O.sparkle(img, 14, 14, G.pale)
O.reink(img)
O.save4(img, "flood-boots-b-fine")

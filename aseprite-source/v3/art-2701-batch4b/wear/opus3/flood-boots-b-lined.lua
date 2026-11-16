-- flood-boots-b-lined: Lined rank, Flood Boots cut b (gingham patch with a dog-eared corner). Opus richness pass.
-- Base: ../opus2/flood-boots-b-lined.png (= finished cut-a Lined + the grafted cut-b patch; read only). Added via
-- _boots.lua (shared with the Fine): rubber crinkle rows, a long gloss streak and a pale glint on the front shaft,
-- tread grain on the soles; Lined only: a snail climbing the back boot's instep (quirk, reads at 32 px).
-- The patch, its stitches and the dog-ear are untouched. Fleece cuffs as before; no gold.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local img = O.load(O.OP2 .. "flood-boots-b-lined.png")
loadfile(O.ME .. "_boots.lua")(O)(img, "lined")
O.reink(img)
O.save4(img, "flood-boots-b-lined")

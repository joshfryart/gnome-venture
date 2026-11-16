-- trail-pack-b-lined: Lined rank, Trail Pack cut b (denim patch with a trail-blaze arrow). Opus richness pass.
-- Base: ../opus2/trail-pack-b-lined.png (= finished cut-a Lined + grafted cut-b patch; read only). Added via _pack.lua
-- (shared by both ranks): a leather-bound base in a hue-shifted leather ramp with a lit top edge and a cream
-- saddle stitch, and a leather compression strap with a small buckle on the left side pocket.
-- Lined: the side buckle is pewter (no gold beyond the base hardware).
-- The denim patch, its red stitches and the arrow are untouched.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local img = O.load(O.OP2 .. "trail-pack-b-lined.png")
loadfile(O.ME .. "_pack.lua")(O)(img, { "#e8e4e0", "#b8b0b0", "#8a8290", "#5e5866" })
O.reink(img)
O.save4(img, "trail-pack-b-lined")

-- trail-pack-b-fine: Fine rank, Trail Pack cut b (denim patch with a trail-blaze arrow). Opus richness pass.
-- Base: ../opus2/trail-pack-b-fine.png (= finished cut-a Fine + grafted cut-b patch; read only). Added via _pack.lua
-- (shared by both ranks): a leather-bound base in a hue-shifted leather ramp with a lit top edge and a cream
-- saddle stitch, and a leather compression strap with a small buckle on the left side pocket.
-- Fine: the side buckle is gold, with a pale-gold sparkle on the main buckle (gleam).
-- The denim patch, its red stitches and the arrow are untouched.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local img = O.load(O.OP2 .. "trail-pack-b-fine.png")
loadfile(O.ME .. "_pack.lua")(O)(img, { O.GOLD6.hi, O.GOLD6.base, O.GOLD6.shade, O.GOLD6.deep })
O.sparkle(img, 28, 44, O.GOLD6.pale)
O.reink(img)
O.save4(img, "trail-pack-b-fine")

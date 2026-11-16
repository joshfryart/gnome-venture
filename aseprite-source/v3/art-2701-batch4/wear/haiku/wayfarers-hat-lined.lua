-- wayfarers-hat-lined: Lined rank of the Wayfarer's Hat (cut a), Haiku first pass, batch4. 64x64.
-- Base: game ph/wayfarers-hat.png (plain cut a; the game's -lined icon is not used as the base).
-- Lined = cream sheepskin fleece showing at the brim's lower edge, where the lining turns out.
-- quirk kept from base: blue feather and the red band.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/wayfarers-hat.png")

-- fleece tufts along the brim's lower edge
H.fleece(img, 12, 40, 47)
H.fleece(img, 14, 36, 46)

H.save(img, "wayfarers-hat-lined")

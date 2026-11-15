-- yarn-scarf-lined: Lined rank of the Yarn Scarf, Haiku first pass, batch4. 64x64.
-- Base: game ph/yarn-scarf.png (plain cut a).
-- Lined = cream fleece at the openings: the two tail ends and the inner rim of the loop.
-- quirk kept from base: the two loose tails with fringe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/yarn-scarf.png")

-- fleece at the left tail end, right tail end
H.fleece(img, 14, 24, 55)
H.fleece(img, 37, 45, 55)
-- fleece on the inner rim of the loop
H.fleece(img, 29, 32, 15)

H.save(img, "yarn-scarf-lined")

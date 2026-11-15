-- travel-cloak-b-lined: Lined rank of the Travel Cloak cut-b (shoulder patch and bee kept). Haiku, batch4b. 64x64.
-- Base: art-2701-next8/opus3/travel-cloak-b.png (read only).
-- Lined = cream fleece around the collar (the neck opening), tufts dropping into the front V.
-- quirk kept: the orange leaf on the hem. Patch and bee untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-next8/opus3/travel-cloak-b.png")

H.fleece(img, 17, 47, 14)
H.fleece(img, 17, 47, 15)
for x = 17, 47 do if x % 3 == 0 then H.put(img, x, 16, H.FLEECE.shade) end end

H.save(img, "travel-cloak-b-lined")

-- wayfarers-hat-b-lined: Lined rank of the Wayfarer's Hat cut-b (crown patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-rest/opus3/wayfarers-hat-b.png (read only).
-- Lined = cream fleece tufts along the brim's lower edge, where the lining turns out.
-- quirk kept: blue feather and red band. Patch untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-rest/opus3/wayfarers-hat-b.png")

H.fleece(img, 10, 50, 46)
H.fleece(img, 10, 50, 47)
for x = 10, 50 do if x % 3 == 1 then H.put(img, x, 48, H.FLEECE.base) end end

H.save(img, "wayfarers-hat-b-lined")

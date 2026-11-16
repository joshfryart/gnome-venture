-- trail-pack-b-lined: Lined rank of the Trail Pack cut-b (blue patch and buckle kept). Haiku, batch4b. 64x64.
-- Base: art-2701-next8/opus3/trail-pack-b.png (read only).
-- Lined = cream fleece along the mouth of the pack body, where it meets the roll, with tufts over the edge.
-- quirk kept: lavender sprig on top of the roll. Patch and buckle untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-next8/opus3/trail-pack-b.png")

H.fleece(img, 17, 47, 24)
H.fleece(img, 17, 47, 25)
for x = 17, 47 do if x % 3 == 1 then H.put(img, x, 26, H.FLEECE.base) end end

H.save(img, "trail-pack-b-lined")

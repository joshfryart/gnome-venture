-- work-gloves-b-lined: Lined rank of the Work Gloves cut-b (ticking patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-opus/wear/work-gloves-b.png (read only).
-- Lined = cream fleece at both wrist openings (the bottom of each cuff), tufts over the edge.
-- quirk kept: the loose red stitch thread on the front cuff. Patch untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/work-gloves-b.png")

-- front glove wrist: three fleece rows, a tuft row under them
H.fleece(img, 17, 33, 52)
H.fleece(img, 17, 33, 53)
H.fleece(img, 17, 33, 54)
for x = 17, 33 do if x % 3 == 2 then H.put(img, x, 55, H.FLEECE.shade) end end
-- back glove wrist
H.fleece(img, 35, 46, 49)
H.fleece(img, 35, 46, 50)
H.fleece(img, 35, 46, 51)
for x = 35, 46 do if x % 3 == 0 then H.put(img, x, 52, H.FLEECE.base) end end

H.save(img, "work-gloves-b-lined")

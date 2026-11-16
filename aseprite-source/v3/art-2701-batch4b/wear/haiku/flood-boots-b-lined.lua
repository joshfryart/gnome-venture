-- flood-boots-b-lined: Lined rank of the Flood Boots cut-b (sewn gingham patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-opus/wear/flood-boots-b.png (read only).
-- Lined = cream fleece over the boot tops (both cuffs turned down), tufts hanging over the lower edge.
-- quirk kept: splash at the toe. Patch and dog-ear untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/flood-boots-b.png")

-- front cuff: three fleece rows, tufts hang below
for y = 12, 14 do H.fleece(img, 11, 30, y) end
for x = 11, 30 do if x % 3 == 0 then H.put(img, x, 15, H.FLEECE.base) end end
-- back cuff
for y = 8, 10 do H.fleece(img, 22, 40, y) end
for x = 22, 40 do if x % 3 == 1 then H.put(img, x, 11, H.FLEECE.base) end end

H.save(img, "flood-boots-b-lined")

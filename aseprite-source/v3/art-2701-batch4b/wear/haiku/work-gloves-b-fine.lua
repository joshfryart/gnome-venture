-- work-gloves-b-fine: Fine rank of the Work Gloves cut-b (ticking patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-opus/wear/work-gloves-b.png (read only).
-- Fine = the two cream stitch rows turned to gold thread, gold trim on both wrists, a gold snap on the back cuff.
-- quirk kept: the loose red stitch thread on the front cuff. Patch untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/work-gloves-b.png")
local G = H.GOLD

-- the cream stitch rows become gold thread
local CREAM = { ["#f2e2b8"] = G.base, ["#f4ead2"] = G.hi, ["#fff4d6"] = G.hi, ["#e4d6b8"] = G.base }
H.swap(img, 17, 46, 33, 48, CREAM)
H.swap(img, 34, 43, 47, 45, CREAM)
-- gold trim along each wrist opening
H.dashRow(img, 17, 33, 54, G.base, 2, 1)
H.dashRow(img, 35, 46, 51, G.base, 2, 1)
-- gold snap on the back cuff
H.put(img, 40, 47, G.hi); H.put(img, 41, 47, G.hi); H.put(img, 42, 47, G.base)
H.put(img, 40, 48, G.base); H.put(img, 41, 48, G.deep); H.put(img, 42, 48, G.base)
H.put(img, 40, 49, G.base); H.put(img, 41, 49, G.base); H.put(img, 42, 49, G.shade)
H.put(img, 40, 47, "#fff4d6")

H.save(img, "work-gloves-b-fine")

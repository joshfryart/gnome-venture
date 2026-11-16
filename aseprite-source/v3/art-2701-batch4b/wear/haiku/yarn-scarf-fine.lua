-- yarn-scarf-fine: Fine rank of the Yarn Scarf. Haiku, batch4b. 64x64.
-- Base: game ph/yarn-scarf.png (cut a, read only). NOTE: no yarn-scarf cut-b exists on disk, so this
-- Fine is built on the plain base and carries no stitched patch. Flagged in MANIFEST.md.
-- Fine = gold stitch across both tail ends, a gold bead at the loop crossing.
-- quirk kept: the loose tails with fringe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/yarn-scarf.png")
local G = H.GOLD

H.dashRow(img, 16, 24, 42, G.base, 2, 1)
H.dashRow(img, 39, 48, 42, G.base, 2, 1)
-- gold bead at the loop crossing
H.put(img, 27, 16, G.hi); H.put(img, 28, 16, G.base)
H.put(img, 27, 17, G.base); H.put(img, 28, 17, G.shade)

H.save(img, "yarn-scarf-fine")

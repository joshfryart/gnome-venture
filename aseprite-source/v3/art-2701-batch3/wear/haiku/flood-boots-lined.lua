-- flood-boots-lined: Lined rank of the Flood Boots (Haiku pass, batch3). 64x64.
-- Base: game ph/flood-boots.png (cut a silhouette; the -b patch is not carried over).
-- Lined = the turned-down cuff tops show a cream sheepskin fleece, and the mouth of the
-- right boot shows its fleece lining under the cuff.
-- quirk kept from base: blue water splash at the toe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/flood-boots.png")

-- left boot: the cuff rolls over, fleece on its top two rows
H.fleece(img, 12, 28, 12)
H.fleece(img, 12, 28, 13)
-- right boot: fleece on the top of the cuff
H.fleece(img, 23, 39, 8)
H.fleece(img, 23, 39, 9)
-- lining showing at the right boot mouth
H.fleece(img, 30, 38, 17)

H.save(img, "flood-boots-lined")

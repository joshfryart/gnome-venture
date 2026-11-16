-- trail-pack-lined: Lined rank of the Trail Pack (Haiku pass, batch3). 64x64.
-- Base: game ph/trail-pack.png. Lined = a cream fleece lining shows at the pack mouth
-- under the blanket roll and along the lower edge of the flap.
-- quirk kept from base: lavender sprig on the roll.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/trail-pack.png")

-- pack mouth lining, rolled out under the blanket roll
H.fleece(img, 17, 46, 24)
-- flap lower edge: fleece on the row above the seam, tufts on the row below it
H.fleece(img, 17, 46, 38)
for x = 17, 46 do
  if x % 3 == 0 then H.put(img, x, 39, H.FLEECE.hi) end
end

H.save(img, "trail-pack-lined")

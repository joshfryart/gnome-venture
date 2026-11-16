-- travel-cloak-lined: Lined rank of the Travel Cloak (Haiku pass, batch3). 64x64.
-- Base: Opus travel-cloak.png (finished art). Lined = the tan lining along the front V becomes
-- a cream fleece strip with tufts, and the hem rolls over into a curly fleece edge.
-- quirk kept from base: autumn leaf on the hem.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/travel-cloak.png")

-- front V edges: fleece strips, left column light, right column shaded
for y = 29, 55 do
  H.put(img, 27, y, (y % 2 == 0) and H.FLEECE.hi or H.FLEECE.base)
  H.put(img, 28, y, (y % 3 == 0) and H.FLEECE.base or H.FLEECE.shade)
  H.put(img, 34, y, (y % 2 == 0) and H.FLEECE.base or H.FLEECE.shade)
end

-- hem: the lowest body row of every column becomes fleece, with tufts one row up
local bot = H.bottoms(img, 4, 60)
for x, yb in pairs(bot) do
  H.put(img, x, yb, (x % 4 == 0) and H.FLEECE.hi or ((x % 4 == 2) and H.FLEECE.shade or H.FLEECE.base))
  if x % 4 == 0 then H.put(img, x, yb - 1, H.FLEECE.hi) end
end

H.save(img, "travel-cloak-lined")

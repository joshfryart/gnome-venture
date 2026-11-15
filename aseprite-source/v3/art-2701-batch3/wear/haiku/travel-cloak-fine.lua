-- travel-cloak-fine: Fine rank of the Travel Cloak (Haiku pass, batch3). 64x64.
-- Base: Opus travel-cloak.png. Fine = gold embroidery along the front V and a gold hem,
-- the wooden toggle is cast gold, a cream gleam on the left shoulder.
-- quirk kept from base: autumn leaf on the hem.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local G = H.GOLD
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/travel-cloak.png")

-- gold trim down the front V, with an embroidered dash line just outside it
for y = 29, 55 do
  H.put(img, 27, y, (y % 2 == 0) and G.hi or G.base)
  H.put(img, 34, y, (y % 2 == 0) and G.base or G.shade)
end
H.dashCol(img, 25, 30, 55, G.base, 2, 2)
H.dashCol(img, 36, 30, 55, G.shade, 2, 2)

-- gold hem: lowest body row gold, alternating base and shade
local bot = H.bottoms(img, 4, 60)
for x, yb in pairs(bot) do
  H.put(img, x, yb, (x % 3 == 0) and G.shade or G.base)
end

-- toggle bar in gold (hi on top, shade underneath)
for x = 28, 35 do
  H.put(img, x, 24, G.hi)
  H.put(img, x, 25, G.base)
  H.put(img, x, 26, G.shade)
end

-- cream gleam on the left shoulder
H.put(img, 17, 28, H.CREAM)
H.put(img, 18, 28, H.CREAM)

H.save(img, "travel-cloak-fine")

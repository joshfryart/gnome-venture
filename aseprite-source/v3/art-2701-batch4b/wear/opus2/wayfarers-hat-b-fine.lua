-- wayfarers-hat-b-fine: Fine rank of the Wayfarer's Hat cut b (sewn crown patch). Opus second pass, batch4b. 64x64.
-- Base: art-2701-rest/opus3/wayfarers-hat-b.png (read only).
-- Fine = a 2 px twisted gold cord piped round the whole front edge of the brim (outer ring gold base/hi twist,
-- inner ring gold shade), a cast gold buckle on the red band left of the feather, and the gleam: a cream glint on
-- the buckle and a pale-gold rim light on the crown's lit top.
-- The crown patch and its stitches, the band, and the blue feather are untouched apart from the buckle.
-- quirk kept: blue feather, red band, the patch's sleeping-mouse print.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local G = O.GOLD6
local img = O.load(O.V3 .. "/art-2701-rest/opus3/wayfarers-hat-b.png")
local BRIM = { ["#8a5239"] = 1, ["#a66a45"] = 1, ["#704033"] = 1, ["#c48a5a"] = 1, ["#552f2c"] = 1, ["#3a2026"] = 1 }
local function out(x, y) return not O.isBody(img, x, y) end
local ring1, ring2 = {}, {}
for y = 38, 63 do for x = 0, 63 do
  if O.isBody(img, x, y) and BRIM[O.get(img, x, y)] then
    local feather = (x >= 34 and x <= 46 and y <= 40)   -- the brim's back edge where the feather tucks in
    if not feather and (out(x + 1, y) or out(x - 1, y) or out(x, y + 1) or out(x, y - 1)) then ring1[#ring1 + 1] = { x, y } end
  end
end end
local r1 = {}
for _, p in ipairs(ring1) do r1[p[2] * 64 + p[1]] = true end
for y = 38, 63 do for x = 0, 63 do
  if O.isBody(img, x, y) and not r1[y * 64 + x] and BRIM[O.get(img, x, y)] then
    if r1[y * 64 + x + 1] or r1[y * 64 + x - 1] or r1[(y + 1) * 64 + x] or r1[(y - 1) * 64 + x] then ring2[#ring2 + 1] = { x, y } end
  end
end end
for _, p in ipairs(ring1) do
  local x, y = p[1], p[2]
  local c = ((x + y) % 3 == 0) and G.hi or G.base
  if y >= 49 then c = ((x + y) % 3 == 0) and G.base or G.shade end   -- underside of the curve, away from the light
  O.px(img, x, y, c)
end
for _, p in ipairs(ring2) do O.px(img, p[1], p[2], (p[2] >= 48) and G.deep or G.shade) end
-- buckle on the band (x 20-24, rows 32-37), red band through its openings
O.paint(img, 20, 32, {
  "Whbbs",
  "bDhDs",
  "bDbDs",
  "bDbDd",
  "bDbDd",
  "sdddU",
}, { W = "#fff4d6", h = G.hi, b = G.base, s = G.shade, d = G.deep, U = G.umber, D = "#5e1c33" })
-- pale-gold rim light on the crown top (lit upper left)
for _, p in ipairs({ { 24, 19 }, { 25, 19 }, { 21, 21 }, { 20, 22 }, { 19, 24 } }) do O.body(img, p[1], p[2], G.pale) end
O.save4(img, "wayfarers-hat-b-fine")

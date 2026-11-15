-- wayfarers-hat-b-lined: Lined rank of the Wayfarer's Hat cut b (sewn crown patch). Opus second pass, batch4b. 64x64.
-- Base: art-2701-rest/opus3/wayfarers-hat-b.png (read only).
-- Lined = the fleece lining rolls out over the front edge of the brim: a 2-3 px cream fleece rim along the whole
-- lower brim (from tip to tip, rows 39 down), lit along its top, shaded under, with flat-topped lumps hanging past
-- the old outline so the silhouette itself turns woolly (the same "fleece cuff" read as the boots and gloves).
-- The crown, the green patch with its gold stitches, the red band and the blue feather are untouched.
-- quirk kept: blue feather, red band, the patch's sleeping-mouse print.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local F = O.FLEECE
local img = O.load(O.V3 .. "/art-2701-rest/opus3/wayfarers-hat-b.png")
local BRIM = { ["#8a5239"] = 1, ["#a66a45"] = 1, ["#704033"] = 1, ["#c48a5a"] = 1, ["#552f2c"] = 1, ["#3a2026"] = 1 }
local function out(x, y) return not O.isBody(img, x, y) end
-- distance (4-steps) to the outside, up to 3
local function near(x, y, d)
  for dy = -d, d do for dx = -d, d do
    if math.abs(dx) + math.abs(dy) <= d and out(x + dx, y + dy) then return true end
  end end
  return false
end
local set = {}
for y = 39, 63 do for x = 0, 63 do
  if O.isBody(img, x, y) and BRIM[O.get(img, x, y)] then
    local d = (y >= 46) and 3 or 2
    if near(x, y, d) then set[y * 64 + x] = true end
  end
end end
-- lumps hanging below the bottom outline (every 6 px, 3 px wide)
for x = 9, 52 do
  if (x % 6) < 3 then
    local yb
    for y = 63, 0, -1 do if O.isBody(img, x, y) then yb = y break end end
    if yb and yb >= 44 then set[(yb + 1) * 64 + x] = true end
  end
end
O.wool(img, set, { ramp = F, shadeFrom = 46, yDark = 51 })
O.reink(img)
O.save4(img, "wayfarers-hat-b-lined")

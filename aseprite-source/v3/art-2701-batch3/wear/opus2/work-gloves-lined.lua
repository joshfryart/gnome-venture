-- work-gloves-lined: Lined rank of the Work Gloves (Opus second pass, batch3). 64x64.
-- Base: game ph/work-gloves.png (read only). Same tan leather pair, same stitched cuffs.
-- Lined = a thick curly sheepskin lining rolls out of each cuff mouth: a puffy cream band
-- with a wavy top where it meets the leather and tufts hanging below the cuff.
-- quirk kept from base: the cream stitch row across each cuff.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local img = O.load(O.PH .. "work-gloves.png")

-- back (right) glove first: band y47..52, x35..47, wavy top, tufts at y53
local back = {}
for x = 35, 47 do
  local top = ((x // 3) % 2 == 0) and 47 or 48
  O.rectSet(x, top, x, 52, back)
end
for _, x in ipairs({ 37, 38, 39, 42, 43, 44 }) do back[53 * 64 + x] = true end
O.wool(img, back, { shadeFrom = 43, phase = 2, yDark = 52 })
-- front (left) glove: band y50..55, x15..35, wavy top, tufts at y56
local front = {}
for x = 15, 35 do
  local top = ((x // 3) % 2 == 1) and 50 or 51
  if x == 15 or x == 35 then top = 51 end
  O.rectSet(x, top, x, 55, front)
end
for _, x in ipairs({ 17, 18, 19, 22, 23, 24, 27, 28, 29, 32, 33 }) do front[56 * 64 + x] = true end
-- clear what the front band covers of the back glove first, so the ink can re-form
for k in pairs(front) do O.px(img, k % 64, k // 64, "#f6e6c4") end
O.wool(img, front, { shadeFrom = 30, yLight = 51, yDark = 55 })
-- ink between the two lined cuffs where they touch
for y = 50, 55 do if O.isBody(img, 36, y) then O.px(img, 36, y, O.INK) end end
O.reink(img)
O.save(img, "work-gloves-lined")

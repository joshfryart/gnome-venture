-- trail-pack-lined: Lined rank of the Trail Pack (Opus second pass, batch3). 64x64.
-- Base: game ph/trail-pack.png (read only). Same oat canvas pack, roll, strap and buckle.
-- Lined = a fat curly fleece collar puffs out of the pack mouth under the blanket roll
-- (wider than the pack by 1 px each side), and the flap's hem is turned back to show
-- a fleece lining band with tufts, split by the leather strap.
-- quirk kept from base: lavender sprig on the roll.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local img = O.load(O.PH .. "trail-pack.png")
-- a brighter fleece than the shared ramp, so it lifts off the pale oat canvas
local FL = { hi = "#fff4d6", base = "#fcefd2", mid = "#f2dcb2", shade = "#dcbd8c", deep = "#b38a5c" }
local DK = "#6c5c4a"    -- canvas contact shadow under the fleece

-- 1. fleece collar at the mouth, y22..27, puffing 2 px past each side of the pack
local col = {}
for x = 15, 48 do O.rectSet(x, 23, x, 27, col) end
for _, x in ipairs({ 13, 14, 49, 50 }) do O.rectSet(x, 24, x, 27, col) end
for _, x in ipairs({ 13, 50 }) do col[24 * 64 + x] = nil end
for _, x in ipairs({ 16, 17, 18, 21, 22, 26, 27, 28, 31, 32, 36, 37, 38, 41, 42, 46, 47 }) do col[22 * 64 + x] = true end
for _, x in ipairs({ 16, 17, 21, 22, 23, 27, 28, 33, 34, 35, 39, 40, 44, 45, 46 }) do col[28 * 64 + x] = true end
O.wool(img, col, { ramp = FL, shadeFrom = 43, yLight = 24, yDark = 27, phase = 1 })
for x = 15, 48 do
  local y = col[28 * 64 + x] and 29 or 28
  if O.isBody(img, x, y) then O.px(img, x, y, DK) end
end

-- 2. fleece lining at the flap hem, y37..41 (strap x29..33 stays on top)
local hem = {}
for x = 18, 45 do
  if x < 29 or x > 33 then
    O.rectSet(x, 37, x, 40, hem)
    if (x // 2) % 2 == 0 then hem[41 * 64 + x] = true end
  end
end
O.wool(img, hem, { ramp = FL, shadeFrom = 40, yLight = 37, yDark = 40, phase = 2 })
for x = 18, 45 do
  if (x < 29 or x > 33) then
    local y = hem[41 * 64 + x] and 42 or 41
    local h = O.get(img, x, y)
    if h == "#ad9e7a" or h == "#8e7e62" or h == "#6c5c4a" or h == "#c9bb92" then O.px(img, x, y, DK) end
  end
end
-- the strap casts a 1 px shadow onto the fleece on its right
for y = 37, 40 do O.px(img, 34, y, "#d2b386") end
O.reink(img)
O.save(img, "trail-pack-lined")

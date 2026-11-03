-- ico-rain (final pass, Opus). A heavy rain cloud: four puffs over a flat, shadowed belly, cool slate 6-tone ramp
-- lit per pixel from a puff height field, crease lines where the front puffs sit on the back ones, a pale rim light
-- on the top. Below it three slanting glassy teardrops (6-tone blue, bright rim upper-left, pale core, one cream glint)
-- falling in a staggered line.
-- quirk: the last drop has just landed and thrown up a little splash crown on a puddle.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-rain")
local SLATE = { "#2f3352", "#484d74", "#666c96", "#8b92b8", "#b7bdd8", "#e2e6f4" }
local BLU   = { "#1d2c63", "#28509a", "#3478c8", "#55a2e6", "#92d0f6", "#d6f2ff" }

-- cloud
local bumps = { { 19, 22, 7 }, { 30, 15, 10 }, { 43, 19, 8 }, { 25, 24, 6, true }, { 40, 25, 6, true } }
local cm, cidx = A.cloud(c, bumps, 30, 11, 52, SLATE, { baseH = 8 })
-- rim light on the very top edge of the big puff (one row, upper-left arc)
cm:each(function(x, y)
  if not cm:has(x, y - 1) and x < 34 and x > 22 and (cidx[K(x, y)] or 0) >= 5 then c:put(x, y, SLATE[6]) end
end)
c:sparkle(26, 9)

-- raindrops: slanting teardrop (point up-right), sphere-lit round bottom
local function drop(bx, by, small)
  local r = small and 2 or 3
  local m = HP.ellipse(bx, by, r, r)
  local tipx, tipy = bx + 2, by - (small and 5 or 8)
  m:add(HP.poly{ { bx - r + 0.2, by - 0.4 }, { tipx + 0.5, tipy }, { tipx + 1.2, tipy + 0.6 }, { bx + r + 0.8, by + 0.2 } })
  local n = X.sphere(bx - 0.3, by - 1.2, r + 2, m)
  local idx = A.shade(c, m, n, BLU, { amb = 0.12, wrap = 0.3 })
  -- glass: bright rim on the upper-left edge, pale core, darker lower-right lip, one glint
  m:edge():each(function(x, y)
    if x <= bx - 1 and y <= by then c:put(x, y, BLU[5]) end
    if x >= bx + 1 and y >= by + 1 then c:put(x, y, BLU[2]) end
  end)
  c:put(floor(bx), floor(by), BLU[5]) c:put(floor(bx) + 1, floor(by), BLU[4])
  c:put(floor(bx) - 1, floor(by) - 1, A.CREAM)
  return m
end
drop(19, 41) drop(32, 44) drop(45, 41)
-- quirk: splash crown on a puddle under the right column
local px, py = 46, 52
local pud = HP.ellipse(px, py, 5, 1)
c:fillMask(pud, BLU[3])
for x = px - 4, px + 1 do c:put(x, py - 1, BLU[4]) end
c:put(px - 3, py - 1, BLU[5]) c:put(px + 3, py + 1, BLU[2]) c:put(px + 4, py, BLU[2])
-- crown: two flung droplets + rising prongs
c:put(px - 2, py - 2, BLU[4]) c:put(px - 3, py - 3, BLU[5])
c:put(px + 2, py - 2, BLU[3]) c:put(px + 3, py - 3, BLU[4])
c:put(px, py - 2, BLU[5]) c:put(px, py - 3, BLU[6])
c:put(px - 5, py - 5, BLU[5]) c:put(px + 5, py - 5, BLU[4])
A.save(c, "ico-rain")

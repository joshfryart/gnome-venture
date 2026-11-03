-- broken-masterwork-harvest-cart (aB12_0, Opus single pass). Side view two-wheeled cart: three tapered oak planks with
-- gilded corner brackets and rivets, one big spoked wheel (steel tyre, wood felloe, brass hub) under the middle, a long
-- slim pull shaft to the left with a brass cap, a prop leg at the back. Material: plank grain + grooves, pale end grain,
-- bevelled brass with a spec, AO where wheel, shaft and brackets meet the box.
-- broken: the top two planks are split clean through (gap) with a corner knocked out, one spoke is missing,
-- a splinter flies off. quirk: a little pumpkin rides along, curly tendril and all.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-masterwork-harvest-cart")

c:groundShadow(34, 54, 20, 1)
-- quirk first (box paints over its lower half)
local pm = c:ellipse(26, 20, 5, 3.5)
local pn = X.sphere(25.6, 19.6, 4.5, pm)
local pidx = A.tone(c, pm, pn, A.PUMP, { wrap = 0.2 })
for _, x in ipairs{ 23, 26, 29 } do for y = 17, 23 do if pm:has(x, y) and pidx[K(x, y)] then c:px(x, y, A.PUMP[math.max(1, pidx[K(x, y)] - 2)]) end end end
c:px(24, 18, A.PUMP[6]) c:px(25, 17, A.SPEC)
c:px(26, 15, A.LEAF[2]) c:px(26, 14, A.LEAF[3]) c:px(27, 13, A.LEAF[4])
c:px(28, 14, A.LEAF[5]) c:px(29, 13, A.LEAF[5]) c:px(29, 12, A.LEAF[4])
-- prop leg + shaft (behind box)
A.rod(c, 50, 36, 53, 51, 0.9, A.WOOD, { grain = 3 })
local sh = A.rod(c, 24, 34, 11, 42, 1.0, A.WOOD, { grain = 9 })
local cap = c:rect(10, 41, 12, 43)
A.lit(c, cap, A.GOLD, { R = 1 }) c:px(10, 41, A.GOLD[6])
-- box: three planks
local box = c:poly{ { 15, 22 }, { 55, 22 }, { 52, 38 }, { 18, 38 } }
local planks = {}
local ys = { { 22, 26 }, { 27, 32 }, { 33, 38 } }
for i, r in ipairs(ys) do
  local pl = box:copy():clip(c:rect(0, r[1], 63, r[2]))
  planks[i] = pl
  local idx = A.lit(c, pl, A.WOOD, { R = 2, wrap = 0.3 })
  -- grain streaks
  pl:each(function(x, y) local k = K(x, y) local t = idx[k]
    if t and t > 1 and y > r[1] and y < r[2] then
      local seg = math.floor((x + X.hash(y, i, 2) * 7) / 6)
      if X.hash(seg, y, i) > 0.64 then c:px(x, y, A.WOOD[t - 1]) end
    end end)
  -- groove under each plank
  for x = 0, 63 do if pl:has(x, r[2]) and i < 3 then c:px(x, r[2], A.WOOD[1]) end end
  -- knot
end
c:px(40, 29, A.WOOD[1]) c:px(41, 29, A.WOOD[2]) c:px(40, 30, A.WOOD[2])
-- pale end grain on the left end of each plank
for _, r in ipairs(ys) do for y = r[1], r[2] - 1 do for x = 0, 30 do if box:has(x, y) then c:px(x, y, A.WOOD[6]) if box:has(x + 1, y) then c:px(x + 1, y, A.WOOD[5]) end break end end end end
-- brass corner brackets + rivets
local function bracket(x0, y0, x1, y1)
  local m = c:rect(x0, y0, x1, y1):clip(box)
  A.lit(c, m, A.GOLD, { R = 1 })
  return m
end
bracket(17, 22, 20, 38) bracket(50, 22, 54, 38)
for _, y in ipairs{ 24, 30, 35 } do A.rivet(c, 18, y, A.GOLD) A.rivet(c, 51, y, A.GOLD) end
-- wheel
local wo = A.wheel(c, 36, 42, 11, { spokes = 8, felloe = true, miss = 2, hub = 2.5 })
-- AO on box above the wheel
box:each(function(x, y) if wo:has(x, y + 1) and not wo:has(x, y) then c:px(x, y, A.WOOD[1]) end end)
-- damage: split through the top two planks, corner knocked out
A.gap(c, { { 44, 21 }, { 43, 24 }, { 45, 27 }, { 43, 30 }, { 44, 32 } }, 1)
A.gap(c, { { 44, 21 }, { 44, 24 } }, 2)
A.erase(c, c:poly{ { 47, 20 }, { 51, 20 }, { 49, 24 } })
c:px(42, 24, A.WOOD[6]) c:px(44, 27, A.WOOD[6]) c:px(48, 23, A.WOOD[5])
-- flying splinter + chip of plank
local spl = c:line({ { 55, 13 }, { 59, 11 } }, 1) c:fillMask(spl, A.WOOD[5]) c:px(59, 11, A.WOOD[6]) c:px(55, 13, A.WOOD[3])
A.chip(c, { { 54, 16 }, { 57, 16 }, { 55, 19 } }, A.WOOD)
A.save(c)

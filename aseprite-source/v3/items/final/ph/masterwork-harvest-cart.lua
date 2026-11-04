-- masterwork-harvest-cart (aC22_4, Opus single pass). Side view, pulled to the left: a flared bed of three oak
-- planks with iron corner straps and brass-capped stakes, heaped with a ribbed pumpkin, red apples, a cabbage and
-- a wheat sheaf; one big spoked wheel (iron tyre, oak felloe, brass hub) under the back half; a long slim shaft with a
-- T-grip runs forward-down to the left. Material: plank grain + end-grain stakes, iron bevel, glossy fruit with
-- speculars and reflected light, leaf veins, AO where the heap sits in the bed.
-- quirk: one apple has rolled down onto the shaft.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = G.new("masterwork-harvest-cart")
c:groundShadow(34, 50, 22, 2)

-- shaft (behind the bed), T-grip at the left end
local sh, shn = G.rod(24, 34, 9, 42, 1.2)
local sidx, stok = G.shade(c, sh, shn, G.OAK, { amb = 0.12 })
local tg, tgn = G.rod(8, 38, 8, 46, 1.3)
local tgb = {}
local gi, gtok = G.shade(c, tg, tgn, G.WOOD, { amb = 0.12 })
tg:each(function(x, y) if y % 2 == 0 then c:put(x, y, G.WOOD[max(1, (gi[K(x, y)] or 3) - 1)], gtok) end end) -- cord wrap
-- iron ferrule where shaft meets grip
c:put(10, 41, G.IRON[5]) c:put(11, 41, G.IRON[3]) c:put(10, 42, G.IRON[3]) c:put(11, 42, G.IRON[2])

-- heap (painted before the bed so the bed front overlaps the bottom of the heap)
-- wheat sheaf at the back right
local wheat = HP.mask()
local stalkTok = { r = { name = "wheat" } }
local heads = { { 44, 8, -0.25 }, { 48, 7, 0.05 }, { 52, 9, 0.35 }, { 46, 10, -0.1 }, { 50, 11, 0.2 } }
for _, h in ipairs(heads) do
  G.pline(c, { { h[1], h[2] + 3 }, { 48 + (h[1] - 48) * 0.3, 23 } }, G.WHEAT[3], stalkTok)
end
for _, h in ipairs(heads) do
  local m, n = G.oval(h[1], h[2], 1.1, 2.6, h[3], 1.2)
  local idx, tok = G.shade(c, m, n, G.WHEAT, { amb = 0.15 })
  -- kernel notches
  m:each(function(x, y) if (y + x) % 2 == 0 and (idx[K(x, y)] or 3) > 2 then c:put(x, y, G.WHEAT[(idx[K(x, y)] or 3) - 1], tok) end end)
  c:put(floor(h[1] + h[3] * 4 + .5), h[2] - 3, G.WHEAT[4]) -- awn
end
-- cabbage at the front left
local cab, cabn = G.oval(22, 20, 5.5, 4.6, 0, 1)
local cB = {}
local cidx, ctok = G.shade(c, cab, cabn, G.LEAF, { bias = cB, amb = 0.15, wrap = 0.3 })
-- leaf veins radiating from lower right + outer leaf edges
for _, v in ipairs{ { { 24, 23 }, { 19, 17 } }, { { 24, 23 }, { 22, 16 } }, { { 24, 23 }, { 18, 21 } } } do
  G.pline(c, v, G.LEAF[6], ctok, cab)
end
G.pline(c, { { 25, 16 }, { 27, 19 } }, G.LEAF[2], ctok, cab)
-- pumpkin centre
local pm, pn = G.oval(35, 17, 7.5, 5.5, 0, 1)
local pB = {}
G.ao(pB, pm, cab, 1, -1)
local pidx, ptok = G.shade(c, pm, pn, G.ORANGE, { bias = pB, amb = 0.1, wrap = 0.25 })
-- ribs: dark grooves curving with the form
for _, rx in ipairs{ -4, 0, 4 } do
  for y = 12, 23 do
    local yy = (y - 17) / 5.5
    local x = floor(35 + rx * sqrt(max(0, 1 - yy * yy)) * 1.05 + .5)
    if pm:has(x, y) then local i = pidx[K(x, y)] or 3 c:put(x, y, G.ORANGE[max(1, i - 2)], ptok)
      if pm:has(x - 1, y) and i >= 4 then c:put(x - 1, y, G.ORANGE[min(6, i + 1)], ptok) end end
  end
end
c:put(31, 13, G.SPEC, ptok) c:put(32, 13, G.ORANGE[6], ptok)
-- stem
local st, stn = G.rod(35, 12, 37, 9, 0.9)
G.shade(c, st, stn, G.LEAF, { amb = 0.2 })
c:put(38, 9, G.LEAF[3])
-- apples
local function apple(ax, ay, r, tokname)
  local m, n = G.oval(ax, ay, r, r - 0.3, 0, 1)
  local idx, tok = G.shade(c, m, n, G.APPLE, { amb = 0.08, wrap = 0.25, name = tokname })
  local rim = X.rim(n)
  m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.75 then c:put(x, y, "#b04a6c", tok) end end)
  c:put(floor(ax - r * 0.4), floor(ay - r * 0.45), G.SPEC, tok)
  c:put(floor(ax + .5), floor(ay - r + .5), G.APPLE[1], tok)
  c:put(floor(ax + 1.5), floor(ay - r - 0.5), G.WOOD[2], tok)
  return m
end
apple(43, 20, 3.4)
apple(28, 22, 3.0)
apple(48, 19, 2.8)

-- bed: three planks, flared
local bed = c:poly{ { 16, 23 }, { 56, 23 }, { 53, 36 }, { 19, 36 } }
local bB = {}
local planks = { { 23, 27 }, { 28, 31 }, { 32, 36 } }
local bidx, btok = G.pillow(c, bed, 1.5, G.OAK, { bias = bB, amb = 0.18, wrap = 0.3, flat = 0.4, flatv = 0.6 })
-- plank seams (dark) with lit lip under, slight darkening per lower plank
for i, p in ipairs(planks) do
  for x = 15, 57 do
    if i > 1 and bed:has(x, p[1]) then c:put(x, p[1], G.OAK[2], btok) end
    if i > 1 and bed:has(x, p[1] + 1) and bed:has(x, p[1] + 2) then c:put(x, p[1] + 1, G.OAK[5], btok) end
  end
end
-- top edge: rim board lit, heap contact shadow just under it is the seam line itself
for x = 16, 56 do if bed:has(x, 23) then c:put(x, 23, G.OAK[6], btok) end if bed:has(x, 24) then c:put(x, 24, G.OAK[5], btok) end end
-- grain streaks
for _, g in ipairs{ { 22, 26, 6 }, { 38, 25, 5 }, { 27, 29, 7 }, { 45, 30, 6 }, { 24, 34, 5 }, { 40, 33, 4 } } do
  for i = 0, g[3] do local x, y = g[1] + i, g[2] if bed:has(x, y) then c:put(x, y, G.OAK[3], btok) end end
end
c:put(33, 26, G.OAK[2]) c:put(34, 26, G.OAK[3]) -- knot
-- stakes (end grain caps) at both ends
for _, sx in ipairs{ 18, 53 } do
  local sm, sn = G.rod(sx, 20, sx + (sx < 30 and 1 or -1), 36, 1.2)
  local si, stk = G.shade(c, sm, sn, G.WOOD, { amb = 0.15 })
  local cap = c:rect(sx - 1, 19, sx + 1, 20)
  c:fillMask(cap, G.BRASS[4]) c:put(sx - 1, 19, G.BRASS[6]) c:put(sx + 1, 20, G.BRASS[2]) c:put(sx, 19, G.BRASS[5])
end
-- iron corner straps with rivets
for _, s in ipairs{ { 20, 33, 23 }, { 48, 33, 51 } } do
  for x = s[1], s[3] do c:put(x, s[2], G.IRON[4]) c:put(x, s[2] + 1, G.IRON[2]) end
  c:put(s[1] + 1, s[2], G.IRON[6])
end

-- big spoked wheel under the back half
local wall = G.wheel(c, 40, 39, { R = 10, tw = 2, felloe = 1.4, spokes = 8, rot = 0.2, sw = 0.7, hub = 2.2,
  wood = G.WOOD, tyre = G.IRON, hubRamp = G.BRASS, spec = G.IRON[6] })
-- wheel tread flats where it meets the ground (contact)
c:put(40, 49, G.IRON[1]) c:put(41, 49, G.IRON[1])

-- quirk: an apple rolled down onto the shaft
apple(15, 36, 2.4, "loose")

G.save(c, "ph", "masterwork-harvest-cart")

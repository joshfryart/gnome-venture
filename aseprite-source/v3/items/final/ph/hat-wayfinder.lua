-- hat-wayfinder (aC11_2 final, Opus single pass). Ranger's travelling hat: slim felt cone that leans and folds over
-- to the right, brass bobble on the tip, thin oval brim seen a little from above, tooled leather band with a brass
-- compass badge. Felt: tube light in 6 greens, diagonal felt weave, two crease lines at the fold, AO where crown
-- meets band and band meets brim. Brim: own deeper green ramp, dark underside thickness, gold stitch round the hem.
-- Compass: brass bezel (bevel + spec), cream face, red/ink needle.
-- quirk: a tiny rolled map with a red tie is tucked into the band.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("hat-wayfinder")

local FELT  = { "#1d3d34", "#28583e", "#357548", "#4c9352", "#6fb15e", "#a3cf74" }
local BRIM  = { "#16302c", "#1f4636", "#2b5e40", "#3d7a48", "#5a9752", "#85b866" }
local LEATH = { "#3a2024", "#5a3128", "#7d4a30", "#9f6638", "#c0874a" }
local BRASS = { "#6a3f1c", "#a0661e", "#d39a2a", "#f5c94a", "#fff0a8" }
local MAP   = { "#a88a62", "#d8c08e", "#f4e4b8" }
local RED   = "#c9393a"
local ftok, btok, ltok, mtok, qtok = A.tok("felt"), A.tok("brim"), A.tok("band"), A.tok("brass"), A.tok("map")

-- brim: thin oval, top surface + 2 px underside thickness at the front
local BCX, BCY, BRX, BRY = 32, 47, 25, 6
local brimTop = HP.ellipse(BCX, BCY, BRX, BRY)
local brimUnder = brimTop:shift(0, 2):cut(brimTop)
local brimAll = brimTop:copy():add(brimUnder)
local bn = X.pillow(brimTop, 3, 0.6)
-- tilt the brim plane a little toward the light (seen from above)
for k, v in pairs(bn) do bn[k] = { A.norm(v[1] * 0.8, v[2] * 0.8 - 0.25, v[3]) } end
local bidx = A.shade(c, brimTop, bn, BRIM, { tok = btok, amb = 0.15, wrap = 0.3 })
brimUnder:each(function(x, y) c:put(x, y, (x < BCX - 14) and BRIM[2] or BRIM[1], btok) end)

-- crown: tube from the base centre up, leaning then folding right; flat-ish bottom on the band arc
local CP = { { 32, 46 }, { 31, 30 }, { 33, 18 }, { 45, 11 } }
local cm, cn, cT, cS = A.tube(CP, function(t)
  return 10.5 * (1 - t) ^ 0.95 + 1.2
end)
local function arc(x) local d = (x - BCX) / 11.8 return BCY - 1 + 3 * sqrt(max(0, 1 - d * d)) end
cm:each(function(x, y) if y > arc(x) or y < 7 then cm.s[K(x, y)] = nil end end)
local cbias = {}
cm:each(function(x, y) local k = K(x, y)
  -- felt weave: diagonal pattern on the mid tones
  if (x + 2 * y) % 5 == 0 then cbias[k] = -1 end
  -- AO just above the band
  if y > arc(x) - 7 and y <= arc(x) - 5 then cbias[k] = (cbias[k] or 0) - 1 end
end)
local cidx = A.shade(c, cm, cn, FELT, { bias = cbias, tok = ftok, amb = 0.08, wrap = 0.28 })
-- fold creases where the cone bends over (dark line + lit lip)
for _, cr in ipairs{ { 0.62, -0.4, 0.6 }, { 0.7, -0.1, 0.8 } } do
  cm:each(function(x, y) local k = K(x, y)
    local t, s = cT[k], cS[k]
    if s > cr[2] and s < cr[3] then
      local d = (t - cr[1]) * 40 + s * s * 2
      if abs(d) < 0.5 then c:put(x, y, FELT[2], ftok)
      elseif d > -1.6 and d <= -0.5 and (cidx[k] or 3) >= 3 then c:put(x, y, FELT[min(6, (cidx[k] or 3) + 1)], ftok) end
    end
  end)
end

-- band: rows arc-4 .. arc-1 across the crown, vertical-cylinder light, tooled notches
local band = HP.mask()
cm:each(function(x, y) if y > arc(x) - 5 then band:set(x, y) end end)
local bx0, _, bx1 = band:bbox()
band:each(function(x, y)
  local u = ((x + .5 - bx0) / (bx1 + 1 - bx0)) * 2 - 1
  local lit = 0.55 - 0.45 * u
  local i = floor(lit * 4.99) + 1
  if y >= arc(x) - 1 then i = i - 1 end              -- AO on the brim
  if not band:has(x, y - 1) then i = i + 1 end        -- top edge catches light
  if (x % 4 == 0) and y == floor(arc(x) - 3) then i = i - 1 end
  c:put(x, y, LEATH[max(1, min(5, i))], ltok)
end)
-- brim AO right under the crown base (front)
cm:each(function(x, y) if not cm:has(x, y + 1) and brimTop:has(x, y + 1) then
  local k = K(x, y + 1) c:put(x, y + 1, BRIM[max(1, (bidx[k] or 3) - 2)], btok) end end)

-- gold stitch along the front hem of the brim
local hem = {}
for x = BCX - 22, BCX + 22 do
  local d = (x - BCX) / (BRX - 2)
  if abs(d) < 1 then hem[#hem + 1] = { x, floor(BCY + (BRY - 2) * sqrt(1 - d * d) + .5) } end
end
for i, p in ipairs(hem) do if (i % 3) < 2 and not cm:has(p[1], p[2]) then c:put(p[1], p[2], "#e0a63a", btok) end end

-- compass badge on the band (left of centre, lit side)
local OX, OY = 27, 41
local bez = HP.ellipse(OX, OY, 3, 3)
bez:each(function(x, y)
  local dx, dy = x - OX, y - OY
  local i = (dx + dy < -1) and 5 or (dx + dy < 1) and 4 or (dx + dy < 3) and 3 or 2
  if not bez:has(x + 1, y) and not bez:has(x, y + 1) then i = 1 end
  c:put(x, y, BRASS[i], mtok)
end)
for _, p in ipairs{ {-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1} } do c:put(OX + p[1], OY + p[2], A.CREAM, mtok) end
c:put(OX + 1, OY - 1, RED, mtok) c:put(OX, OY, A.INK, mtok) c:put(OX - 1, OY + 1, "#5a4a58", mtok)
c:put(OX - 2, OY - 2, BRASS[5], mtok)

-- brass bobble on the tip
local tipx, tipy = 46, 11
local bob = HP.ellipse(tipx, tipy, 2, 2)
local bobn = X.sphere(tipx - 0.3, tipy - 0.3, 2, bob)
X.tone(c, bob, X.light(bobn, { amb = 0.1, wrap = 0.2 }), BRASS, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = mtok })
c:put(tipx - 1, tipy - 1, BRASS[5], mtok)

-- quirk: rolled map tucked into the band, right side, leaning out
local mapm = HP.mask()
for i = 0, 8 do local x, y = 38 + floor(i * 0.35 + .5), 44 - i mapm:set(x, y) mapm:set(x + 1, y) end
mapm:each(function(x, y)
  local lit = not mapm:has(x - 1, y)
  c:put(x, y, lit and MAP[3] or MAP[2], qtok)
end)
c:put(41, 36, MAP[1], qtok) c:put(42, 36, MAP[2], qtok)          -- rolled end (spiral)
c:put(39, 40, RED, qtok) c:put(40, 40, "#8e2430", qtok)           -- tie
-- band over the map's foot (tucked in)
band:each(function(x, y) if mapm:has(x, y) and y >= arc(x) - 2 then c:put(x, y, LEATH[3], ltok) end end)

A.save(c, "hat-wayfinder")

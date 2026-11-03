-- atlas-daisy-seed (ph, Opus single pass, aR3_0). Atlas daisy (Anacyclus) achenes: three flat obovate seeds, a
-- tan ribbed body inside a pale papery wing (lit wing rim, darker wing shadow, centre rib), lying on a sage leaf
-- scrap that runs uphill to the right (torn base on the left, V-fold light, midrib + veins, cool rim, AO and contact
-- shadow under each seed). A seedling grows from the left seed: short stem, two oval cotyledons and two silvery,
-- finely divided true leaves (pinnate, lobed leaflets) that show the mat-forming fern-leaf of the plant.
-- quirk: the seedling already holds up a fat little bud, white petals striped with the daisy's crimson undersides.
local NAME = "atlas-daisy-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SAGE  = { "#213f3a", "#2f5a48", "#447655", "#61935f", "#8bb274", "#bdd69a" }
local SILV  = { "#26453f", "#3d6554", "#5a8668", "#7fa67c", "#a9c69a", "#d6e8c2" }
local VEIN, COOL = "#d2e6aa", "#3d6878"
local SEED  = { "#4a2e24", "#6c4430", "#90603c", "#b5824e", "#d2a468", "#ecc990" }
local WING  = { "#a08c6c", "#c8b48e", "#e6d6b0", "#fbf0d2" }
local STEM  = { "#3d6a4e", "#6f9a68", "#a6c88e" }
local PET   = { "#7d1f3c", "#b8304a", "#e1e0e4", "#fff4ea" }
local CUTS  = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle (the long axis); wing on the whole rim
local seeds = { { 23, 45, 4.0, 2.8, -0.5 }, { 36, 42, 4.2, 2.9, 0.35 }, { 46, 35, 3.9, 2.7, -1.1 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap running uphill to the right ---------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(8, 50, 32, 50, 57, 32, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.4 * sin(pi * min(1, t * 0.7 + 0.3)) ^ 0.7)
end, { fold = 0.4 })
G.tear(lm, 12, 0, -1, 0.15, 1.5, 5)        -- torn base on the left
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, SAGE, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.63, 0.82 }, amb = 0.12, wrap = 0.28 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or SAGE[3], ltok) return end
  local ph = (t * len - abs(s) * 4.4) / 5.5
  local f = ph - floor(ph)
  if f < 0.13 and abs(s) > 0.16 and abs(s) < 0.75 and t > 0.12 then c:put(x, y, s < 0 and SAGE[6] or SAGE[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 then c:put(x, y, COOL, ltok) end
  if x <= 13 and not bias[k] then c:put(x, y, (y % 2 == 0) and SAGE[6] or VEIN, ltok) end end)  -- fibrous tear

-- seedling (from the left seed) ------------------------------------------------------------------------------------
local stok = { r = { name = "stem" } }
local SX, SY = 22, 43
local sp = { { SX, SY }, { 21, 39 }, { 23, 34 }, { 22, 30 } }
local stm, stn = G.tube(sp, function(t) return 0.95 end)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.35, 0.65 }, tok = stok })
-- bud stalk
local bp = { { 22, 30 }, { 22, 25 }, { 27, 21 }, { 28, 16 } }
for i = 0, 40 do local x, y = G.bez(bp, i / 40) c:put(floor(x + .5), floor(y + .5), STEM[3], stok)
  if i < 22 then c:put(floor(x + .5) + 1, floor(y + .5), STEM[1], stok) end end
-- cotyledons: smooth ovals
local function blade(ax, ay, cx, cy, bx, by, w, ramp, tok)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6)
  end, { fold = 0.3 })
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok) end end)
  return m
end
local ltk = { r = { name = "seedling" } }
blade(21, 31, 16, 30, 11, 26, 2.1, SAGE, ltk)
blade(23, 31, 28, 31, 33, 28, 2.0, SAGE, ltk)
-- true leaves: pinnately divided, lobed leaflets in silvery green
local function frond(p, pinnae)
  local pm = HP.mask()
  for _, q in ipairs(pinnae) do
    local t, side, L = q[1], q[2], q[3]
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.01))
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local ux, uy = G.rot(tx, ty, side * 0.9)
    -- slim leaflet with one lobe notch: 2 px wide tapering line
    local m = G.tube({ { x, y }, { x + ux * L * 0.35, y + uy * L * 0.35 }, { x + ux * L * 0.7, y + uy * L * 0.7 + 0.01 }, { x + ux * L, y + uy * L } },
      function(tt) return 0.95 - tt * 0.35 end, 40)
    pm:add(m)
  end
  local ex, ey = G.bez(p, 1)
  local x1, y1 = G.bez(p, 0.9)
  local ux, uy = ex - x1, ey - y1 local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  pm:add(G.rell(ex + ux * 0.5, ey + uy * 0.5, ux, uy, 2.0, 1.1))
  for i = 0, 40 do local x, y = G.bez(p, i / 40) pm:set(floor(x + .5), floor(y + .5)) end
  pm:cut(stm)
  G.toneN(c, pm, X.pillow(pm, 1.2), SILV, { tok = ltk, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.28 })
  for i = 0, 40 do local x, y = G.bez(p, i / 40) local xi, yi = floor(x + .5), floor(y + .5)
    if pm:has(xi, yi) then c:put(xi, yi, (i < 10) and STEM[2] or SILV[3], ltk) end end
  return pm
end
frond({ { 21, 30 }, { 18, 26 }, { 14, 22 }, { 11, 16 } },
  { { 0.28, 1, 4.6 }, { 0.36, -1, 4.2 }, { 0.52, 1, 4.0 }, { 0.6, -1, 3.6 }, { 0.75, 1, 3.0 }, { 0.82, -1, 2.6 } })
frond({ { 23, 30 }, { 27, 27 }, { 32, 25 }, { 37, 20 } },
  { { 0.28, -1, 4.4 }, { 0.36, 1, 4.2 }, { 0.52, -1, 3.8 }, { 0.6, 1, 3.6 }, { 0.75, -1, 2.8 }, { 0.82, 1, 2.6 } })

-- quirk: fat closed bud, white petals with crimson stripes, green sepal cup ----------------------------------------
local BXc, BYc = 28, 13
G.map(c, BXc - 3, BYc - 4, {
  "...w...",
  "..wRw..",
  ".WRwRw.",
  ".wRWRr.",
  ".rRwRr.",
  "..gGg..",
  "..sgs..",
}, { w = PET[3], W = PET[4], R = PET[2], r = PET[1], g = SILV[4], G = SILV[5], s = SILV[2] }, { r = { name = "bud" } })

-- seeds last: winged achenes ---------------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local wingm = s.m:edge()
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    local lit = (dx + dy) < 0
    if wingm:has(x, y) then
      c:put(x, y, lit and WING[4] or (((dx + dy) > 2.5) and WING[2] or WING[3]), tok)
    else
      local val, ii = v[k] or 0, 1
      for j, t in ipairs({ 0.3, 0.48, 0.64, 0.8, 0.93 }) do if val >= t then ii = j + 1 end end
      if abs(w) < 0.18 and abs(u) < 0.7 then ii = ii - 2 end                -- centre rib groove
      if w < -0.18 and w > -0.45 and abs(u) < 0.5 then ii = ii + 1 end      -- lit ridge beside it
      c:put(x, y, SEED[max(1, min(6, ii))], tok)
    end
  end)
  -- tiny pappus crown at the narrow end (two pale pixels)
  local tx, ty = floor(s[1] + ca * (s[3] + 1.3) + .5), floor(s[2] + sa * (s[3] + 1.3) + .5)
  if not s.m:has(tx, ty) then c:put(tx, ty, WING[3], tok) end
end
-- one specular on the middle seed's wing
c:put(34, 40, "#fff4d6")
G.save2(c, NAME)

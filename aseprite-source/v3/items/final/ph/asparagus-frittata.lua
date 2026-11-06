-- asparagus-frittata (ph, Opus single pass, aR3_0). One thick wedge of frittata in 3/4 view on a small cream
-- plate. Top face: golden egg, pillow-bevelled edges, caramel blotches, three asparagus tips laid radially (lit
-- cylinders with scaly purple-green buds, AO + contact shadow on the egg), herb flecks. Cut face toward the viewer:
-- paler custard crumb with air pockets (dark hole, lit lower lip), spear cross-sections (ring + pale core), browned
-- skin on top and a crust row at the bottom, crust cross-section at the back end. Plate: glazed rim bevel, sunken
-- well, darker lip, rim specular, contact shadow under the wedge, 2-tone ground shadow.
-- quirk: a single steam curl still rising off the back of the slice.
local NAME = "asparagus-frittata"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local EGG   = { "#6b381f", "#a35d2b", "#cf8b35", "#e9b245", "#f6d064", "#ffeea0" }
local CRUMB = { "#7d4b20", "#b27b2e", "#d9a443", "#efc553", "#fadf7c", "#fff3b8" }
local GREEN = { "#1d4632", "#2b6638", "#41873f", "#5fa544", "#8ac458", "#bfe386" }
local BUD   = { "#2a1f47", "#463069", "#65478a", "#8666a6", "#a98bc1", "#d4bfe2" }
local PL    = { "#4e4a6a", "#77748f", "#a6a2b8", "#cfcad6", "#ebe5df", "#fbf7ea" }
local CUTS  = { 0.2, 0.37, 0.53, 0.69, 0.86 }

-- plate ------------------------------------------------------------------------------------------------------
c:groundShadow(33, 54, 23, 1)
local PCX, PCY, PRX, PRY = 32, 45, 25, 8
local lip = c:ellipse(PCX, PCY + 2, PRX, PRY)
local top = c:ellipse(PCX, PCY, PRX, PRY)
local ptok = { r = { name = "plate" } }
lip:each(function(x, y) if not top:has(x, y) then
  c:put(x, y, (x < PCX - 12) and PL[3] or ((x < PCX + 10) and PL[2] or PL[1]), ptok) end end)
local well = c:ellipse(PCX + 0.5, PCY + 0.5, 18, 5)
local pn = X.pillow(top, 2.4)
-- the well is concave: flip its normals (lit lower-right inside, shaded upper-left inside)
local wn = X.pillow(well, 1.6)
for k, n in pairs(wn) do pn[k] = { -n[1] * 0.8, -n[2] * 0.8, n[3] } end
local pv = X.light(pn, { amb = 0.25, wrap = 0.3 })
X.tone(c, top, pv, PL, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, tok = ptok })
-- rim specular streak, upper-left
for _, q in ipairs{ { 14, 41 }, { 15, 40 }, { 16, 40 }, { 18, 39 } } do c:put(q[1], q[2], PL[6], ptok) end
-- glaze line just inside the rim (thin painted band)
c:ellipse(PCX, PCY, PRX - 2, PRY - 1.6):edge():each(function(x, y)
  if not well:has(x, y) and y > PCY then c:put(x, y, (x < PCX) and "#a9c3d2" or "#7f9ab4", ptok) end end)

-- wedge geometry: apex front-left, arc at the back, projected 3/4 (y squash 0.55) -----------------------------
local AX, AY, R, SQ, TH = 15, 42, 34, 0.62, 7
local t1, t2 = math.rad(-68), math.rad(-11)
local function P(r, th) return AX + r * cos(th), AY + r * sin(th) * SQ end
local poly = { { AX, AY } }
for i = 0, 24 do local th = t1 + (t2 - t1) * i / 24 local x, y = P(R, th) poly[#poly + 1] = { x, y } end
local topf = c:poly(poly)
local CXp, CYp = P(R, t2)
local side = c:poly{ { AX, AY }, { CXp, CYp }, { CXp, CYp + TH }, { AX, AY + TH } }
side:cut(topf)
local wedge = topf:copy():add(side)
-- contact shadow on the plate under the wedge
wedge:shift(1, 1):add(wedge:shift(2, 1)):each(function(x, y)
  if top:has(x, y) and not wedge:has(x, y) then c:put(x, y, PL[2], ptok) end end)

-- top face -----------------------------------------------------------------------------------------------------
local etok = { r = { name = "egg-top" } }
local tn = X.pillow(topf, 2.2)
-- gentle dome: tilt normals toward the apex-back diagonal
local tv = X.light(tn, { amb = 0.3, wrap = 0.3 })
local spears = {
  { 0.16, 8, 30 }, { 0.5, 19, 27 }, { 0.84, 7, 29 },     -- angle fraction, start r, end r
}
local smasks, sbias = {}, {}
for i, sp in ipairs(spears) do
  local th = t1 + (t2 - t1) * sp[1]
  local ax, ay = P(sp[2], th) local bx, by = P(sp[3], th)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t) if t > 0.9 then return 1.6 * (1 - (t - 0.9) / 0.1) + 0.3 end return 1.45 end)
  m:clip(topf:shrink(1))
  smasks[i] = { m = m, n = n, T = T, S = S, len = sqrt((bx - ax)^2 + (by - ay)^2) }
end
local tb = {}
for _, s in ipairs(smasks) do X.ao(tb, topf, s.m, 1, -1) G.cast(tb, topf, s.m, 1, 1, -1) end
local tidx = {}
topf:each(function(x, y) local k = K(x, y)
  local val, i = tv[k] or 0, 1
  for j, t in ipairs(CUTS) do if val >= t then i = j + 1 end end
  -- caramel blotches (browned under the grill)
  local h = X.hash(floor(x / 2), floor(y / 2), 3)
  if h > 0.78 then i = i - 1 end
  if X.hash(x, y, 9) > 0.93 then i = i - 1 end
  i = max(1, min(6, i + (tb[k] or 0)))
  tidx[k] = i
  c:put(x, y, EGG[i], etok)
end)
-- herb flecks (chives), cheese melts
for _, q in ipairs{ { 22, 35 }, { 27, 39 }, { 37, 36 }, { 31, 30 }, { 41, 39 }, { 25, 31 } } do
  if topf:has(q[1], q[2]) then c:put(q[1], q[2], GREEN[3], etok) c:put(q[1] + 1, q[2], GREEN[2], etok) end end
for _, q in ipairs{ { 30, 37 }, { 34, 33 }, { 21, 38 } } do if topf:has(q[1], q[2]) then c:put(q[1], q[2], EGG[6], etok) end end
-- asparagus pieces
for i, s in ipairs(smasks) do
  local stok = { r = { name = "spear" .. i } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  s.m:each(function(x, y) local k = K(x, y)
    local val, ii = v[k] or 0, 1
    for j, t in ipairs(CUTS) do if val >= t then ii = j + 1 end end
    local ramp = GREEN
    if s.T[k] > 0.8 then
      local row = (s.T[k] * s.len - abs(s.S[k]) * 1.5) / 2.1
      if row - floor(row) < 0.35 or abs(s.S[k]) > 0.55 then ramp = BUD end
    end
    -- a bract scale mid-shaft
    local dd = (s.T[k] - 0.45) * s.len + abs(s.S[k]) * 1.3
    if dd > -0.5 and dd < 0.5 then ii = ii - 2 end
    c:put(x, y, ramp[max(1, min(6, ii))], stok)
  end)
  -- glossy oil glint on each spear
  local th = t1 + (t2 - t1) * spears[i][1]
  local gx, gy = P(spears[i][2] + (spears[i][3] - spears[i][2]) * 0.3, th)
  if s.m:has(floor(gx), floor(gy) - 1) then c:put(floor(gx), floor(gy) - 1, GREEN[6], stok) end
end

-- cut face -----------------------------------------------------------------------------------------------------
local ctok = { r = { name = "egg-cut" } }
local x0, y0, x1, y1 = side:bbox()
side:each(function(x, y)
  local u = (x - AX) / (CXp - AX)
  local topy = AY + (CYp - AY) * u
  local dy = y - topy
  local i = (u < 0.25) and 5 or ((u < 0.7) and 4 or 3)
  if dy < 1 then i = 2 end                  -- browned skin under the top
  if dy >= TH - 0.5 then i = 1 end          -- bottom crust
  if dy >= TH - 1.5 and dy < TH - 0.5 then i = i - 1 end
  if u > 0.93 then i = max(1, i - 2) end    -- crust cross-section at the back end
  c:put(x, y, CRUMB[max(1, min(6, i))], ctok)
end)
-- skin row lit at the front edge (the top face lip overhangs a little)
-- air pockets: dark hole + lit lower lip
for _, q in ipairs{ { 20, 44, 2 }, { 27, 42, 1 }, { 35, 43, 2 }, { 42, 40, 1 }, { 30, 45, 1 }, { 17, 46, 1 }, { 39, 42, 1 } } do
  local x, y, w = q[1], q[2], q[3]
  for dx = 0, w - 1 do if side:has(x + dx, y) and side:has(x + dx, y + 1) then
    c:put(x + dx, y, CRUMB[2], ctok) c:put(x + dx, y + 1, CRUMB[6], ctok) end end
end
-- spear cross-sections on the cut face: 3x3 ring with pale core
for _, q in ipairs{ { 24, 43 }, { 37, 41 } } do
  local x, y = q[1], q[2]
  local ring = { { 0, -1, 3 }, { -1, 0, 4 }, { 1, 0, 2 }, { 0, 1, 2 }, { -1, -1, 4 }, { 1, -1, 3 }, { -1, 1, 3 }, { 1, 1, 1 } }
  local ok = true
  for _, r in ipairs(ring) do if not side:has(x + r[1], y + r[2]) then ok = false end end
  if ok then for _, r in ipairs(ring) do c:put(x + r[1], y + r[2], GREEN[r[3]], ctok) end c:put(x, y, GREEN[6], ctok) end
end
-- one bright specular: glossy egg sheen on the top face near the apex
c:put(20, 38, "#fffbe0", etok) c:put(21, 38, EGG[6], etok)

-- quirk: steam curl rising off the back of the slice ------------------------------------------------------------
local ST = { "#a9b2c8", "#cfd6e4", "#eef2f8" }
local sm, sn, STt, SS = G.tube({ { 39, 26 }, { 44, 21 }, { 34, 18 }, { 40, 11 } }, function(t) return 0.95 - t * 0.35 end)
local sttok = { r = { name = "steam" } }
sm:each(function(x, y) local k = K(x, y)
  c:put(x, y, (SS[k] < -0.2) and ST[3] or ((SS[k] > 0.35) and ST[1] or ST[2]), sttok) end)
G.save2(c, NAME)

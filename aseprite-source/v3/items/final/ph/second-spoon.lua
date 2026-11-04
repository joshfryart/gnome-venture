-- second-spoon (D15, final pass, Sonnet). Two spoons crossed like a cutlery badge: a long slim silver spoon (egg-shaped
-- concave bowl, rolled rim, flared paddle handle with a lit ridge) lying over a smaller gold "second" spoon with a
-- twisted-wire handle ending in a ball finial. Bowls are lit as concave dishes (inner wall facing the light is bright,
-- far wall dark, sky reflection low-right), handles as bevelled tubes with a specular streak, contact shadow where
-- the silver handle crosses the gold one.
-- quirk: the little second spoon is already serving: one green pea sits in its bowl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("second-spoon")

local SILV = { "#2c3050", "#4a5276", "#7580a6", "#a4b0ca", "#d2deef", "#f6faff" }
local GOLD = { "#552a1c", "#8a4620", "#bf6a22", "#e8962a", "#f8c446", "#fff0a2" }
local PEA = { "#17392f", "#235a3e", "#3a8648", "#5fae58", "#8ccf6e", "#c8eca6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local stok, gtok, ptok = { r = { name = "silver" } }, { r = { name = "gold" } }, { r = { name = "pea" } }

-- egg-shaped spoon bowl. (nx,ny) bowl-axis centre, axis angle `ang` pointing toward the handle (neck end).
local function bowl(cx, cy, ang, rx, ry)
  local ux, uy = cos(ang), sin(ang)           -- toward the neck
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, info = HP.mask(), {}
  local R = math.ceil(max(rx, ry)) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx + 0.0, y - cy + 0.0
    local u = (dx * ux + dy * uy) / (rx + 0.5)
    local v = (dx * px + dy * py)
    local w = (ry + 0.5) * sqrt(max(0, 1 - u * u)) * (1 - 0.2 * u)
    if w > 0.3 and abs(v) <= w and abs(u) <= 1 then
      m:set(x, y)
      info[K(x, y)] = { u = u, v = v / w, px = px, py = py, ux = ux, uy = uy }
    end
  end end
  return m, info
end

-- paint a bowl: rolled rim (convex) + concave inside
local function paintBowl(c, m, info, ramp, tok, bias)
  local n = {}
  local isRim = {}
  for k, f in pairs(info) do
    local r2 = f.u * f.u + f.v * f.v
    local nx, ny
    if r2 > 0.6 then   -- rim: convex roll, normal points outward
      local ox, oy = f.ux * f.u + f.px * f.v, f.uy * f.u + f.py * f.v
      local l = sqrt(ox * ox + oy * oy) + 1e-6
      n[k] = { ox / l * 0.75, oy / l * 0.75, 0.66 }
      isRim[k] = true
    else               -- inside wall: inverted normals (concave dish)
      local q = r2 / 0.6
      local ox, oy = f.ux * f.u + f.px * f.v, f.uy * f.u + f.py * f.v
      local z = sqrt(max(0.1, 1 - q * 0.95))
      n[k] = { -ox * 0.95, -oy * 0.95, z }
    end
  end
  local v = X.light(n, { amb = 0.08, wrap = 0.18 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, bias = bias, tok = tok })
  return idx, v, isRim
end

-- handle -----------------------------------------------------------------------------------------------------------
local function handle(pts, wfn)
  local m, n, T, S, sm = A.tube(pts, wfn)
  return m, n, T, S, sm
end
local sH = { { 23, 39 }, { 30, 30 }, { 39, 19 }, { 48, 8 } }
local gH = { { 41, 41 }, { 36, 33 }, { 28, 22 }, { 21, 11 } }
local swfn = function(t)
  if t > 0.965 then return t > 0.985 and -1 or 1.3 end
  return 1.15 + 0.45 * t + 1.5 * max(0, (t - 0.55) / 0.45) ^ 2.1
end
local gwfn = function(t) return (t > 0.985) and 0 or (1.25 + 0.2 * t) end

-- silver masks first (for the crossing shadow on the gold)
local sm_, sn_, ST, SS = handle(sH, swfn)
local sbm, sbi = bowl(16.5, 45.5, -0.87, 10, 6.6)
local silverAll = sm_:copy():add(sbm)

-- gold: handle (twisted wire), finial, bowl ---------------------------------------------------------------------------
local gm_, gn_, GT, GS = handle(gH, gwfn)
local gbias = {}
X.ao(gbias, gm_, silverAll, 1, -1)
G.cast(gbias, gm_, silverAll, 1, 1, -1)
local gidx = G.toneN(c, gm_, gn_, GOLD, { bias = gbias, tok = gtok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
local glen = 33
gm_:each(function(x, y) local k = K(x, y)
  local ph = (GT[k] * glen - GS[k] * 2.2) % 3.2
  local i = gidx[k] or 3
  if gbias[k] then return end
  if ph < 1.1 then c:put(x, y, GOLD[min(6, i + 1)], gtok) elseif ph > 2.2 then c:put(x, y, GOLD[max(1, i - 1)], gtok) end
end)
-- ball finial
local fx, fy = 21, 10
local fm = c:ellipse(fx, fy, 2.6, 2.6)
local fb = {}
X.ao(fb, fm, silverAll, 1, -1)
X.tone(c, fm, X.light(X.sphere(fx, fy, 2.6, fm), { amb = 0.06, wrap = 0.2 }), GOLD, { cuts = CUTS, tok = gtok, bias = fb })
c:put(fx - 1, fy - 1, GOLD[6], gtok)

local gbm, gbi = bowl(46.5, 46, -2.18 + pi * 0 , 6.8, 4.8)
local gbb = {}
X.ao(gbb, gbm, silverAll, 1, -1)
local gi, gv, gRim = paintBowl(c, gbm, gbi, GOLD, gtok, gbb)
-- bright lip along the lit rim, deep tone along the shade rim
gbm:each(function(x, y) local k = K(x, y)
  if gRim[k] and gv[k] > 0.8 then c:put(x, y, GOLD[6], gtok) end end)
-- pea in the bowl (quirk) + its shadow on the metal
local px0, py0 = 46, 46
local pm = c:ellipse(px0, py0, 2.2, 2.2)
pm:copy():shift(1, 1):cut(pm):each(function(x, y) if gbm:has(x, y) then c:put(x, y, GOLD[1], gtok) end end)
X.tone(c, pm, X.light(X.sphere(px0, py0, 2.2, pm), { amb = 0.05, wrap = 0.2 }), PEA, { cuts = CUTS, tok = ptok })
c:put(px0 - 1, py0 - 1, PEA[6], ptok) c:put(px0, py0 - 1, PEA[5], ptok)
-- neck joint: darker row where handle meets bowl
-- silver spoon -------------------------------------------------------------------------------------------------------
local sbias = {}
local sidx = G.toneN(c, sm_, sn_, SILV, { bias = sbias, tok = stok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
local slen = 42
sm_:each(function(x, y) local k = K(x, y)
  local i = sidx[k] or 3
  -- specular streak on the lit side of the handle, thin bright bevel line
  if SS[k] < -0.28 and SS[k] > -0.62 and ST[k] > 0.12 and ST[k] < 0.93 then c:put(x, y, SILV[min(6, i + 2)], stok) end
  -- engraved groove inside the paddle
  if ST[k] > 0.8 and ST[k] < 0.94 and abs(SS[k]) < 0.2 then c:put(x, y, SILV[2], stok) end
end)
-- tiny crest mark engraved on the paddle
c:put(44, 13, SILV[1], stok)
local sbb = {}
for k, _ in pairs(sbi) do end
-- shadow cast by the bowl neck onto the handle start
local si2, sv, sRim = paintBowl(c, sbm, sbi, SILV, stok, sbb)
sbm:each(function(x, y) local k = K(x, y)
  if sRim[k] and sv[k] > 0.82 then c:put(x, y, SILV[6], stok) end end)
-- sky reflection low-right inside the bowl
sbm:each(function(x, y) local k = K(x, y)
  local f = sbi[k]
  if not sRim[k] and f.v > 0.1 and f.u < 0.5 and sv[k] > 0.55 then c:put(x, y, SILV[min(6, (si2[k] or 4) + 1)], stok) end end)
-- dark far wall line (inner shadow where rim turns into dish, upper-left)
sbm:each(function(x, y) local k = K(x, y) local f = sbi[k]
  if not sRim[k] and sv[k] < 0.25 then c:put(x, y, SILV[1], stok) end end)
-- bright hot streak + sparkle
c:put(10, 41, SILV[6], stok) c:put(11, 40, SILV[6], stok)
c:sparkle(53, 22)
A.save(c, "second-spoon")

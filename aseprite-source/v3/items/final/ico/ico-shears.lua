-- ico-shears (final, Opus single pass). Garden shears open in an X: two slim tapering steel blades (flat cheek,
-- lit spine, ground bevel strip + bright honed edge on the inner cutting side, specular streak), steel shanks into
-- brass ferrules (groove ring), turned beech handles with grain lines and a pale rounded butt. The right arm lies on
-- top: contact shadow on the lower arm where it crosses; domed brass pivot bolt with a dark slot.
-- quirk: a loop of red garden twine is knotted round the left handle, its loose end dangling.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-shears")
local ST = { "#2e2c47", "#464766", "#686a88", "#9294ad", "#bec0d2", "#e6e8f2" }
local WD = { "#4a2a28", "#6e3f2e", "#935a36", "#b97a4a", "#d89c62", "#f0c286" }
local BR = { "#5e3418", "#8f5a1f", "#c48a26", "#e8b23a", "#ffd96a", "#fff0b0" }
local TW = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local stok, wtok, btok, ttok = A.tok("steel"), A.tok("wood"), A.tok("brass"), A.tok("twine")
local PX, PY = 32, 29

-- one arm = blade (pivot -> tip) + handle (pivot -> butt). side: +1 when the blade's inner edge is s>0
local function arm(tip, butt, inner)
  local bm, bn, BT, BS = X.cyl(PX, PY, tip[1], tip[2], function(t)
    if t < 0.12 then return 3.2 end
    return 3.5 * ((1 - t) / 0.88) ^ 0.8 + 0.6
  end)
  local hm, hn, HT, HS = X.cyl(PX, PY, butt[1], butt[2], function(t)
    if t < 0.2 then return 1.8 end                   -- steel shank
    if t < 0.3 then return 3.0 end                   -- ferrule
    local w = 2.4 + (t - 0.3) * 0.9
    if t > 0.9 then w = w * sqrt(max(0, 1 - ((t - 0.9) / 0.105) ^ 2)) + 0.3 end
    return w
  end)
  return { bm = bm, bn = bn, BT = BT, BS = BS, hm = hm, hn = hn, HT = HT, HS = HS, inner = inner }
end

local function paintHandle(a, bias)
  bias = bias or {}
  local wood, shank, fer = HP.mask(), HP.mask(), HP.mask()
  a.hm:each(function(x, y) local t = a.HT[K(x, y)]
    if t < 0.2 then shank:set(x, y) elseif t < 0.3 then fer:set(x, y) else wood:set(x, y) end end)
  -- grain: two long lines along the handle, broken here and there; AO just below the ferrule
  wood:each(function(x, y) local k = K(x, y) local s, t = a.HS[k], a.HT[k]
    local g = s * 2.4 + math.sin(t * 14) * 0.3
    if abs(g - floor(g + 0.5)) < 0.17 and X.hash(x, y, 3) > 0.2 and t < 0.92 then bias[k] = (bias[k] or 0) - 1 end
    if t < 0.34 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local wi = A.shade(c, wood, a.hn, WD, { amb = 0.06, wrap = 0.25, bias = bias, tok = wtok })
  -- pale butt end grain
  wood:each(function(x, y) local k = K(x, y)
    if a.HT[k] > 0.955 then A.step(c, wi, WD, x, y, 1, wtok) end end)
  local fb = {}
  fer:each(function(x, y) local k = K(x, y) local t = a.HT[k]
    if t > 0.24 and t < 0.26 then fb[k] = -2 end end)
  A.shade(c, fer, a.hn, BR, { amb = 0.1, wrap = 0.3, bias = fb, tok = btok })
  local sb = {}
  shank:each(function(x, y) sb[K(x, y)] = -1 end)
  A.shade(c, shank, a.hn, ST, { amb = 0.1, wrap = 0.3, bias = sb, tok = stok })
  return wood
end

local function paintBlade(a, bias)
  bias = bias or {}
  local n = {}
  for k, v in pairs(a.bn) do
    local s = a.BS[k] * a.inner
    -- flat cheek (slight turn), bevel strip tilts hard toward the light on the inner edge
    local f = s > 0.42 and 0.9 or 0.35
    n[k] = { A.norm(v[1] * f, v[2] * f, v[3]) }
  end
  local idx = A.shade(c, a.bm, n, ST, { amb = 0.1, wrap = 0.3, bias = bias, tok = stok, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  -- bevel shoulder line, honed edge, darker heel near the pivot
  a.bm:each(function(x, y) local k = K(x, y) local s, t = a.BS[k] * a.inner, a.BT[k]
    if s > 0.3 and s <= 0.48 and t > 0.12 then A.step(c, idx, ST, x, y, -1, stok) end
    if t < 0.1 then A.step(c, idx, ST, x, y, -1, stok) end
  end)
  a.bm:edge():each(function(x, y) local k = K(x, y)
    if a.BS[k] * a.inner > 0.5 and a.BT[k] > 0.14 and a.BT[k] < 0.96 then c:put(x, y, ST[6], stok) end end)
  return idx
end

local L = arm({ 12, 6 }, { 49, 55 }, 1)    -- blade upper-left, handle lower-right
local R = arm({ 52, 6 }, { 15, 55 }, -1)   -- blade upper-right, handle lower-left (on top)

-- lower arm (L) first, with contact shadow cast by the top arm
local topAll = R.bm:copy():add(R.hm)
local lb, lh = {}, {}
A.cast(lb, L.bm, topAll, 1, 1, -1)
A.cast(lh, L.hm, topAll, 1, 1, -1)
paintBlade(L, lb)
local lwood = paintHandle(L, lh)
paintBlade(R)
paintHandle(R)

-- specular streaks on the blade spines (lit side, mid blade) + one glint
local function streak(a, t0, t1, sOff)
  for i = 0, 10 do
    local t = t0 + (t1 - t0) * i / 10
    local tx, ty = a.tip[1] - PX, a.tip[2] - PY
    local l = sqrt(tx * tx + ty * ty) local ux, uy = tx / l, ty / l
    local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end
    local x, y = floor(PX + tx * t + px * sOff + .5), floor(PY + ty * t + py * sOff + .5)
    if a.bm:has(x, y) then c:put(x, y, ST[6], stok) end
  end
end
L.tip, R.tip = { 12, 6 }, { 52, 6 }
streak(L, 0.32, 0.55, -1.2)
streak(R, 0.32, 0.55, 1.2)
c:put(floor(PX + (12 - PX) * 0.38 + 0.77 * -1.2 + .5) - 1, floor(PY + (6 - PY) * 0.38 + -0.64 * -1.2 + .5), A.CREAM, stok)

-- pivot bolt: domed brass disc with a dark slot
local bolt = A.ellM(PX, PY, 2.6, 2.6)
local bb = {}
A.shade(c, bolt, X.sphere(PX, PY, 2.6, bolt), BR, { amb = 0.12, wrap = 0.3, bias = bb, tok = btok })
c:put(PX - 1, PY + 1, BR[1], btok) c:put(PX, PY, BR[1], btok) c:put(PX + 1, PY - 1, BR[2], btok)
c:put(PX - 1, PY - 2, BR[6], btok)
-- ring of shade on the blades just round the bolt
bolt:grow(1):cut(bolt):each(function(x, y)
  if (L.bm:has(x, y) or R.bm:has(x, y) or R.hm:has(x, y) or L.hm:has(x, y)) and (x > PX or y > PY) then
    c:put(x, y, ST[2], stok) end end)

-- quirk: red twine knotted round the left (lower-left) handle, loose end dangling
do
  local tx, ty = 15 - PX, 55 - PY
  local l = sqrt(tx * tx + ty * ty) local ux, uy = tx / l, ty / l
  R.hm:each(function(x, y) local k = K(x, y) local t = R.HT[k]
    local d = (t - 0.62) * l
    if d > -1.6 and d < 1.6 then
      local s = R.HS[k]
      local tw = ((x + y) % 3 == 0) and 1 or (s < -0.2 and 4 or (s > 0.45 and 2 or 3))
      if d > 1.0 or d < -1.0 then tw = max(1, tw - 1) end
      c:put(x, y, TW[tw], ttok)
    end
  end)
  -- knot nub on the outside + dangling tail (2 px twisted)
  local kx, ky = floor(PX + tx * 0.62 + 2.6 + .5), floor(PY + ty * 0.62 + 1.8 + .5)
  A.map(c, {
    "ab..",
    "bcb.",
    ".cb.",
    ".bc.",
    "..cb",
    "..bc",
    "...b",
  }, kx - 1, ky - 1, { a = TW[4], b = TW[3], c = TW[2] }, ttok)
end
A.save(c, "ico-shears")

-- _aC11_4.lua: private helpers for ph/heather-seed, heilala-seed, heliconia-seed, henna-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- light + tone a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

-- jagged tear across a blade: drop pixels with T beyond t0 + jitter (seeded); returns torn-edge mask
function A.tear(m, T, S, t0, amp, seed, slope, fromStart)
  local gone = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local s = S[k] or 0
    local j = (X.hash(floor(s * 5 + 7), 3, seed) - 0.5) * 2 * amp + s * (slope or 0)
    local t = T[k] or 0
    if (not fromStart and t > t0 + j) or (fromStart and t < t0 + j) then gone:set(x, y) end
  end)
  m:cut(gone)
  local e = HP.mask()
  gone:grow(1):each(function(x, y) if m:has(x, y) then e:set(x, y) end end)
  return e
end

-- line of pixels along a cubic bezier
function A.bline(c, p, hex, tok, t0, t1, n, clip)
  t0, t1, n = t0 or 0, t1 or 1, n or 40
  local m = HP.mask()
  for i = 0, n do local x, y = G.bez(p, t0 + (t1 - t0) * i / n)
    local xi, yi = floor(x + .5), floor(y + .5)
    if not clip or clip:has(xi, yi) then m:set(xi, yi) if hex then c:put(xi, yi, hex, tok) end end end
  return m
end

-- leaf scrap: blade + midrib + paired veins + cool reflected edge. o: veins(per px), vein angle, bias, cuts
function A.leaf(c, m, n, T, S, len, ramp, o)
  o = o or {}
  local tok = o.tok or A.tok("leaf")
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = tok, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
  local bias = o.bias or {}
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] and bias[k] < 0 then return end
    if abs(s) < 0.13 and t > (o.rib0 or 0.02) and t < (o.rib1 or 0.95) then c:put(x, y, s <= 0 and o.vein or ramp[5], tok) return end
    if o.per then
      local ph = (t * len - abs(s) * (o.sweep or 3.5)) / o.per + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > (o.vw or 0.86) and abs(s) > 0.17 and abs(s) < (o.vmax or 0.78) and t > 0.05 and t < 0.92 then
        c:put(x, y, ramp[max(1, min(#ramp, idx[k] + (s < 0 and 1 or -1)))], tok) end
    end
  end)
  if o.cool then m:edge():each(function(x, y) local k = K(x, y)
    if not (bias[k] and bias[k] < 0) and S[k] > 0.6 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, o.cool, tok) end end) end
  return idx, tok
end

-- small sprout leaf (blade) with a midrib; returns mask
function A.sprleaf(c, ax, ay, cx, cy, bx, by, w, ramp, tok, o)
  o = o or {}
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ (o.pow or 0.6))
  end, { fold = o.fold or 0.3 })
  if o.cut then m:cut(o.cut) end
  local idx = G.toneN(c, m, n, ramp, { tok = tok, cuts = A.CUTS, amb = 0.14, wrap = 0.3, bias = o.bias })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok) end end)
  if o.gloss then
    local sx, sy = G.specAt(m, n, 30)
    if sx then c:put(sx, sy, o.gloss, tok) end
  end
  return m, n, T, S
end

-- oval seed with lighting, spec + cool rim. returns mask, idx
function A.seed(c, s, ramp, tok, o)
  o = o or {}
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5] or 0, o.flat or 0.8)
  local vis = m:copy() if o.cut then vis:cut(o.cut) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, vis, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = tok })
  if o.rim then
    local r = X.rim(n)
    vis:each(function(x, y) local k = K(x, y) if r[k] > 0.62 and idx[k] <= 3 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, tok) end end)
  end
  if o.spec then
    local sx, sy = G.specAt(vis, n, o.power or 40)
    if sx then c:put(sx, sy, o.spec, tok) if o.spec2 then c:put(sx + 1, sy, o.spec2, tok) end end
  end
  return m, n, idx, vis
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

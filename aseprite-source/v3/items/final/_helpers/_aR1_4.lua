-- _aR1_4.lua: private helpers for ph/adzuki, adzuki-seed, african-tulip-tree-seed, african-violet-seed (final pass, Opus).
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

-- light + quantise a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

A.ovalM = G.oval   -- mask + normals only

-- glossy oval (bean / seed body): returns mask, normals, idx
function A.oval(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.9)
  if o.cut then m:cut(o.cut) end
  if o.clip then m:clip(o.clip) end
  local idx, v = A.shade(c, m, n, ramp, { bias = o.bias, tok = o.tok, amb = o.amb or 0.05, wrap = o.wrap or 0.2, cuts = o.cuts })
  return m, n, idx, v
end

-- cool reflected light on the lower-right rim of a mask (skipping pixels in `skip`)
function A.bounce(c, m, n, hex, thr, tok, skip)
  local r = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if r[k] and r[k] > (thr or 0.6) and not (skip and skip:has(x, y)) then c:put(x, y, hex, tok) end end)
end

-- torn edge: remove a jagged bite from mask m on pixels where f(x,y) (0..1 position along the tear) passes a hash test
function A.tear(m, T, t0, amp, seed)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local j = X.hash(floor(y / 2), floor(x / 2), seed or 3) * amp + X.hash(x, y, (seed or 3) + 1) * 0.012
    if T[k] < t0 + j then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m
end

-- pinnate venation on a blade: midrib (lit / shade halves) + swept laterals every `per` px
function A.veins(c, m, T, S, len, LEAF, VEIN, o)
  o = o or {}
  local per, sweep = o.per or 5.5, o.sweep or 3.0
  local t0, t1 = o.t0 or 0.0, o.t1 or 0.93
  m:each(function(x, y) local k = K(x, y)
    if o.skip and o.skip[k] then return end
    local s, t = S[k], T[k]
    if t < t0 or t > t1 then return end
    if abs(s) < (o.rib or 0.13) then c:put(x, y, s <= 0 and VEIN or LEAF[3], o.tok) return end
    local ph = (t * len - abs(s) * sweep) / per + (s > 0 and 0.5 or 0)
    local f = ph - floor(ph)
    if f < 0.16 and abs(s) > 0.2 and abs(s) < (o.reach or 0.72) then c:put(x, y, s < 0 and LEAF[o.hiV or 6] or LEAF[2], o.tok) end
  end)
end

-- straight 1px pixel line (Bresenham)
function A.ln(c, x0, y0, x1, y1, hex, tok)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local e = dx + dy
  while true do
    c:put(x0, y0, hex, tok)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * e
    if e2 >= dy then e = e + dy x0 = x0 + sx end
    if e2 <= dx then e = e + dx y0 = y0 + sy end
  end
end

-- ramp from 6 hex
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

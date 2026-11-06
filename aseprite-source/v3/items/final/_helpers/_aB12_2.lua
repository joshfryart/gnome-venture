-- _aB12_2.lua: private helpers for broken prospector pick, pruning shears, rock pick, seed drill (copy of _aB12_0 pattern).
-- Opus single pass. Wraps v3/lib/hp.lua + hpx.lua (read-only).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local A = { HP = HP, X = X, K = K, P = HP.P }

-- 6-tone ramps, dark -> light
A.GOLD  = { "#58261f", "#8f4a1f", "#c4691f", "#e8962a", "#f8c548", "#ffeaa2" }
A.WOOD  = { "#3e2125", "#5f3329", "#86492f", "#a96a40", "#cb8f58", "#ebbd86" }
A.STEEL = { "#2e2f4c", "#454866", "#62657f", "#8a8ca4", "#b5b5c6", "#e6e4ec" }
A.GLASS = { "#253a6a", "#2c5a8c", "#3a86b0", "#5fc4c8", "#9ae6dc", "#dcfcf2" }
A.LEATH = { "#3a1e2c", "#5e2a36", "#8a3a3c", "#b0533f", "#d27a52", "#efa978" }
A.PUMP  = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
A.LEAF  = { "#1d4a3c", "#2e7646", "#45954c", "#6ab455", "#9dd06c", "#c8ea8c" }
A.CLOUD = { "#7d8fc8", "#9fb4e0", "#c4d8f2", "#e4f2ff", "#f6fbff", "#fff4d6" }
A.SPEC = "#fff4d6"
A.CUTS = { 0.24, 0.42, 0.58, 0.73, 0.87 }

function A.new(name)
  A.name = name
  A.out = app.params.out or (DIR .. "/../ph/")
  return HP.canvas{ w = 64, h = 64, scale = 1, name = name }
end

function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
-- pillow-lit flat part with bevel R
function A.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 2, o.hs)
  local idx = A.tone(c, m, n, ramp, o)
  return idx, n
end
-- AO bias: pixels of m within r of any mask in list get amt
function A.ao(m, list, r, amt, bias)
  bias = bias or {}
  for _, o in ipairs(list) do X.ao(bias, m, o, r or 1, amt or -1) end
  return bias
end
-- straight rod A->B, half width hw (number or fn). o.grain (wood streaks), o.bias, o.twist (rope/leather wrap)
function A.rod(c, ax, ay, bx, by, hw, ramp, o)
  o = o or {}
  local wf = type(hw) == "function" and hw or function() return hw end
  local m, n, T, S = X.cyl(ax, ay, bx, by, wf)
  if o.cutm then m:cut(o.cutm) end
  local idx = A.tone(c, m, n, ramp, { bias = o.bias, amb = o.amb, wrap = o.wrap or 0.3 })
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if o.grain and i and i > 1 then
      local lane = floor((S[k] + 1) * 1.6)
      local seg = floor(T[k] * len / 5 + X.hash(lane, 3, o.grain) * 3)
      if X.hash(lane, seg, o.grain) > 0.62 then c:put(x, y, ramp[i - 1]) end
    end
    if o.twist then
      local p = (T[k] * len + S[k] * 1.6) / o.twist
      local f = p - floor(p)
      if f < 0.22 then c:put(x, y, ramp[max(1, (i or 3) - 2)])
      elseif f < 0.45 and (i or 3) >= 3 then c:put(x, y, ramp[min(6, i + 1)]) end
    end
  end)
  return m, idx, T, S, n
end
-- metal sheen streak: diagonal band across mask, bump lit tones
function A.streak(c, m, idx, ramp, a, w)
  m:each(function(x, y) local i = idx[K(x, y)]
    local d = x + y - a
    if i and d >= 0 and d < (w or 2) and i >= 3 then c:put(x, y, ramp[min(6, i + 1)]) end
  end)
end
function A.specAt(m, n)
  local sp = X.spec(n, 30)
  local best, bx, by
  m:each(function(x, y) local s = sp[K(x, y)] if s and (not best or s > best + 1e-6 or (abs(s - best) < 1e-6 and x + y < bx + by)) then best, bx, by = s, x, y end end)
  return bx, by
end
-- wheel: tire ring (steel), optional wood felloe, spokes, hub. o.miss = index of a missing spoke
function A.wheel(c, cx, cy, r, o)
  o = o or {}
  local nsp = o.spokes or 6
  local outer = c:ellipse(cx, cy, r, r)
  local tire = outer:copy():cut(c:ellipse(cx, cy, r - 2, r - 2))
  local fel = HP.mask()
  if o.felloe then fel = c:ellipse(cx, cy, r - 2, r - 2):cut(c:ellipse(cx, cy, r - 3.2, r - 3.2)) end
  -- spokes
  local spm = HP.mask()
  for i = 0, nsp - 1 do
    if i ~= o.miss then
      local a = (i + (o.rot or 0)) / nsp * 2 * math.pi
      local ex, ey = cx + math.cos(a) * (r - 1.5), cy + math.sin(a) * (r - 1.5)
      local lm = c:line({ { cx, cy }, { ex, ey } }, 1)
      lm:each(function(x, y)
        local lit = math.cos(a) * 0.55 + math.sin(a) * 0.7 -- spokes pointing lower-right are darker
        local t = (lit > 0.3) and 2 or (lit > -0.3 and 3 or 4)
        if not spm:has(x, y) then c:put(x, y, (o.spokeRamp or A.WOOD)[t + 1]) end
        spm:set(x, y)
      end)
      -- shade pixel beside spoke
    end
  end
  if o.felloe then A.lit(c, fel, A.WOOD, { R = 1, bias = A.ao(fel, { tire }, 1, -1) }) end
  local tidx, tn = A.lit(c, tire, A.STEEL, { R = 1.2, wrap = 0.35 })
  -- hub
  local hub = c:ellipse(cx, cy, o.hub or 2, o.hub or 2)
  local hn = X.sphere(cx - .4, cy - .4, (o.hub or 2), hub)
  A.tone(c, hub, hn, A.GOLD)
  c:put(floor(cx - 1), floor(cy - 1), A.GOLD[6])
  c:put(floor(cx), floor(cy), A.GOLD[1])
  local sx, sy = A.specAt(tire, tn) c:put(sx, sy, A.SPEC)
  return outer, tire, spm, hub
end
function A.erase(c, m) m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end) end
-- real gap along a jagged polyline (w px)
function A.gap(c, pts, w) local m = c:line(pts, w or 1) A.erase(c, m) return m end
-- flying chip: small lit polygon
function A.chip(c, pts, ramp)
  local m = c:poly(pts)
  local n = X.pillow(m, 1)
  A.tone(c, m, n, ramp, { amb = 0.2 })
  return m
end
function A.rivet(c, x, y, ramp) c:put(x, y, ramp[6]) c:put(x + 1, y + 1, ramp[1]) end

-- tapered curve: P(t)->x,y ; hw(t) half-width. returns mask, T (t of nearest sample), S (signed side -1..1, + = lower-right)
function A.taper(c, P, hw, steps)
  steps = steps or 80
  local pts = {}
  for i = 0, steps do local t = i / steps local x, y = P(t) pts[#pts + 1] = { x, y, hw(t), t } end
  local m, T, S = HP.mask(), {}, {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, q in ipairs(pts) do x0, y0, x1, y1 = min(x0, q[1] - q[3]), min(y0, q[2] - q[3]), max(x1, q[1] + q[3]), max(y1, q[2] + q[3]) end
  for y = floor(y0) - 1, floor(y1) + 1 do for x = floor(x0) - 1, floor(x1) + 1 do
    local best, bq
    for _, q in ipairs(pts) do local d = sqrt((x - q[1])^2 + (y - q[2])^2) - q[3]
      if not best or d < best then best, bq = d, q end end
    if best <= 0 then m:set(x, y) local k = K(x, y) T[k] = bq[4]
      local sx, sy = x - bq[1], y - bq[2] S[k] = (sx + sy) >= 0 and 1 or -1 end
  end end
  return m, T, S
end
function A.bez(ax, ay, bx, by, cx, cy)
  return function(t) local u = 1 - t return u*u*ax + 2*u*t*bx + t*t*cx, u*u*ay + 2*u*t*by + t*t*cy end
end
function A.shift(P, dx, dy) return function(t) local x, y = P(t) return x + dx, y + dy end end
function A.sub(P, a, b) return function(t) return P(a + (b - a) * t) end end
-- 1px bright bevel on mask pixels whose (dx,dy) neighbour is outside
function A.bevel(c, m, dx, dy, hex) m:each(function(x, y) if not m:has(x + dx, y + dy) then c:put(x, y, hex) end end) end

function A.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function A.save(c)
  A.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.out .. A.name .. ".aseprite", png = A.out .. A.name .. ".png", scale = 1 }
end
function A.load(src)
  local d = src:match("^@(.*)[/\\][^/\\]*$")
  return dofile(d .. "/../_helpers/_aB12_2.lua")
end
return A

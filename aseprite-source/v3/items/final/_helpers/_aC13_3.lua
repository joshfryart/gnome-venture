-- _aC13_3.lua: private helpers for ph/jute-mallow-seed, ph/kale, ph/kale-seed, ph/kalette (final pass, Opus). Copied from _aC13_0.
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.save(c, name)
  G.out = app.params.out or (DIR .. "/../ph/")
  G.save2(c, name)
end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.26 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end

-- tear a blade mask past t0 along a stepped jagged line; returns the set of torn-edge pixels
function A.tear(m, T, S, t0, jag, fromStart)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local b = floor((S[k] + 1) * 3.49) + 1
    local lim = t0 + (jag[b] or 0)
    if (not fromStart and T[k] > lim) or (fromStart and T[k] < lim) then cut[#cut + 1] = k end
  end)
  local cs = {}
  for _, k in ipairs(cut) do m.s[k] = nil cs[k] = true end
  local torn = HP.mask()
  m:edge():each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if cs[K(x + d[1], y + d[2])] then torn:set(x, y) end
    end
  end)
  return torn
end

-- full leaf paint: tones (bias = AO), midrib, angled side veins, cool rim on the shade side, pale torn tissue
-- o: ramp, vein (hex), cool (hex), per (vein spacing px), sweep, len, torn (mask), tissue (hex), tok, bias
function A.leaf(c, m, n, T, S, o)
  local R = o.ramp
  local tok = o.tok or { r = { name = "leaf" } }
  local bias = o.bias or {}
  local idx = A.shade(c, m, n, R, { bias = bias, tok = tok, amb = o.amb or 0.16, wrap = o.wrap or 0.3, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 } })
  local per, sweep, len = o.per or 5, o.sweep or 3, o.len or 30
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if (bias[k] or 0) < 0 then return end
    if o.midrib ~= false and abs(s) < 0.14 and t > (o.t0 or 0.03) and t < (o.t1 or 0.95) then
      c:put(x, y, s <= 0 and o.vein or R[3], tok) return end
    if o.veins ~= false then
      local ph = (t * len - abs(s) * sweep) / per + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.06 and t < 0.92 then
        c:put(x, y, s < 0 and R[min(#R, (idx[k] or 4) + 1)] or R[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  if o.cool then
    m:edge():each(function(x, y) local k = K(x, y)
      if (bias[k] or 0) >= 0 and S[k] > 0.6 and T[k] > 0.12 and T[k] < 0.88 then c:put(x, y, o.cool, tok) end end)
  end
  if o.torn then o.torn:each(function(x, y) if (bias[K(x, y)] or 0) >= 0 then c:put(x, y, o.tissue or "#d6eaa0", tok) end end) end
  return idx, tok
end

-- seed: oval with lambert tone, AO bias, one glint. returns idx
function A.seed(c, m, n, ramp, o)
  o = o or {}
  local tok = o.tok or { r = { name = o.name or "seed" } }
  local idx = A.shade(c, m, n, ramp, { bias = o.bias, tok = tok, amb = o.amb or 0.1, wrap = o.wrap or 0.2, cuts = o.cuts })
  if o.rim then
    local r = X.rim(n)
    m:each(function(x, y) local k = K(x, y) if r[k] > 0.62 and idx[k] <= 2 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, tok) end end)
  end
  if o.glint then
    local gx, gy = G.specAt(m, n, 40)
    if gx then c:put(gx, gy, o.glint, tok) if o.glint2 then c:put(gx + 1, gy, o.glint2, tok) end end
  end
  return idx, tok
end

-- paint a char map
function A.map(c, rows, x0, y0, pal, tok)
  for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
    if pal[ch] then c:put(x0 + i - 1, y0 + j - 1, pal[ch], tok) end end end
end

-- contact shadow: darken pixels of target (by tone idx) covered by caster shifted
function A.contact(c, idx, ramp, target, caster, dx, dy, amt, tok)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y)
      local i = max(1, (idx[k] or 3) - (amt or 2)) idx[k] = i c:put(x, y, ramp[i], tok) end end)
end
-- frill a blade margin: cut notches every `per` px (sides offset), depth grows with dfn(t); returns phase table F[k] (0 notch..1 lobe)
function A.frill(m, T, S, len, per, dfn, t0, t1)
  local cut, F = {}, {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local ph = t * len / per + (s > 0 and 0.5 or 0) + 0.25
    local f = abs((ph - floor(ph)) - 0.5) * 2
    F[k] = f
    local lim = 0.98 - (1 - f) ^ 2.2 * dfn(t)
    if t > (t0 or 0.05) and t < (t1 or 0.97) and abs(s) > lim then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return F
end
-- ruffle normals near the margin: tilt along the leaf with the frill phase (curly kale rolls)
function A.ruffle(n, T, S, len, per, amp, from, ux, uy)
  for k, nn in pairs(n) do local s, t = S[k], T[k]
    if s and abs(s) > from then
      local w = (abs(s) - from) / (1 - from)
      local ph = t * len / per + (s > 0 and 0.5 or 0)
      local a = math.sin(ph * 2 * math.pi) * amp * w
      n[k] = { norm(nn[1] + ux * a, nn[2] + uy * a, nn[3]) }
    end
  end
end
return A

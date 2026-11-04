-- _aC31_2.lua: private helpers for ph/orange-marmalade, orange-seed, orangelo, orangelo-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- ramps (dark -> light, 6 tones)
A.LEAF   = { "#13332f", "#1b4d37", "#28683c", "#3c8742", "#5ea84c", "#93cb63" }  -- glossy citrus leaf
A.LVEIN  = "#a9d878"
A.LCOOL  = "#3d6a70"
A.SEED   = { "#6a5240", "#957a5c", "#bfa47e", "#dcc79c", "#efe2bc", "#fff6dc" }  -- citrus pip, cream
A.SEEDY  = { "#6c5038", "#9a7a50", "#c6a46a", "#e2c88a", "#f4e2ac", "#fff4d0" }  -- orangelo pip, warmer
A.STEM   = { "#2f5a3c", "#4f8650", "#7cb262", "#b4dc8a" }
A.ORANGE = { "#5c1d2e", "#97302a", "#cd521f", "#ee7a1d", "#fba23a", "#ffcf78" }
A.OLO    = { "#5a2c34", "#9a4c2e", "#d27f2a", "#efa63a", "#fbc95a", "#fff0a4" }
A.WOOD   = { "#3a2622", "#5b3e2e", "#81603f", "#a8844f" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- citrus leaf: elliptic, pointed tip, glossy. returns mask, T, S, idx, len. o.tear(t,s)->true cuts pixel.
-- o.wing: winged petiole length fraction (grapefruit-type heart wing at the base)
function A.leaf(c, ax, ay, cx, cy, bx, by, w, o)
  o = o or {}
  local ramp = o.ramp or A.LEAF
  local wing = o.wing or 0
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if wing > 0 and t < wing then
      local u = t / wing
      if u < 0.25 then return 0.45 end
      return max(0.45, w * 0.6 * sin(pi * min(1, (u - 0.25) / 0.85)) ^ 0.8)
    end
    if wing > 0 and t < wing + 0.05 then return 0.45 end
    local t0 = wing > 0 and (wing + 0.05) or 0
    local u = (t - t0) / (1 - t0)
    return max(0.4, w * sin(pi * min(1, u * 0.96 + 0.04)) ^ 0.75 * (1 - 0.25 * u))
  end, { fold = o.fold or 0.32 })
  if o.tear then
    local cut = {}
    m:each(function(x, y) local k = K(x, y) if o.tear(T[k], S[k], x, y) then cut[#cut + 1] = k end end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  if o.cutm then m:cut(o.cutm) end
  local tok = o.tok or { r = { name = o.name or "leaf" } }
  local idx = A.shade(c, m, n, ramp, { bias = o.bias, tok = tok, cuts = o.cuts or { 0.24, 0.4, 0.56, 0.72, 0.87 }, amb = 0.1, wrap = 0.28 })
  local veins = o.veins ~= false
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if o.bias and o.bias[k] then return end
    if abs(s) < 0.13 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and A.LVEIN or ramp[2], tok) return end
    if veins and t > wing + 0.06 then
      local ph = (t * len - abs(s) * (o.sweep or 3.2)) / (o.per or 4.6)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.72 and t < 0.88 then
        c:put(x, y, ramp[max(1, min(6, idx[k] + (s < 0 and 1 or -1)))], tok)
      end
    end
  end)
  -- cool reflected edge on the shade side
  m:edge():each(function(x, y) local k = K(x, y)
    if not (o.bias and o.bias[k]) and S[k] > 0.62 and T[k] > 0.12 and T[k] < 0.86 then c:put(x, y, A.LCOOL, tok) end end)
  -- gloss: one bright specular on the lit half
  if o.spec ~= false then
    local best, bx_, by_
    m:each(function(x, y) local k = K(x, y)
      if S[k] < -0.3 and S[k] > -0.6 and T[k] > 0.3 and T[k] < 0.55 and not (o.bias and o.bias[k]) then
        local sc = -T[k] if not best or sc > best then best, bx_, by_ = sc, x, y end end end)
    if bx_ then c:put(bx_, by_, ramp[6], tok) end
  end
  return m, T, S, idx, len, tok
end

-- citrus pip: teardrop (pointed beak at the -u end), lengthwise wrinkles. returns mask
function A.pip(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local U, V = {}, {}
  local R = rx + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    if u >= -1 and u <= 1 then
      local hw = sqrt(max(0, 1 - u * u)) * (0.62 + 0.38 * ((u + 1) / 2) ^ 0.6)
      if abs(v) <= hw then m:set(x, y) U[K(x, y)] = u V[K(x, y)] = v / max(hw, 0.2) end
    end
  end end
  if o.cutm then m:cut(o.cutm) end
  local n = X.pillow(m, o.R or 2.2)
  local tok = o.tok or { r = { name = o.name or "pip" } }
  local idx = A.shade(c, m, n, ramp, { bias = o.bias, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
  -- wrinkle ridges along the length (seed coat), skip the beak
  m:each(function(x, y) local k = K(x, y)
    local u, v = U[k], V[k]
    if u > -0.55 and u < 0.85 and (abs(v - 0.05) < 0.14 or abs(v + 0.5) < 0.1 and u > -0.2) and not (o.bias and o.bias[k]) then
      c:put(x, y, ramp[max(1, idx[k] - 1)], tok)
    end
  end)
  return m, U, V, idx, tok
end

-- disc of hash noise "oil glands" / bloom on a toned part
function A.pits(c, m, idx, ramp, seed, rate, tok)
  m:each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, seed)
    local i = idx[k]
    if i and h < rate and i >= 2 then c:put(x, y, ramp[i - 1], tok)
    elseif i and h > 1 - rate * 0.6 and i >= 3 and i <= 5 then c:put(x, y, ramp[i + 1], tok) end
  end)
end

function A.save(c, name) G.save2(c, name) end
return A

-- _aB1r1_3.lua: private helpers for ph/chamomile-seed, ph/champak-seed, ph/chanterelle, ph/chayote (final, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or A.tok(o.name or "part") })
  return idx, v
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  if idx[k] then idx[k] = max(1, min(#ramp, idx[k] + d)) c:put(x, y, ramp[idx[k]], tok) end
end

function A.pline(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      c:put(x0, y0, hex, tok)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy x0 = x0 + sx end
      if e2 <= dx then err = err + dx y0 = y0 + sy end
    end
  end
end

-- torn leaf scrap along quadratic A-C-B. o: w (max half width), tear (0..1 where the scrap is torn off),
-- ramp (6 dark->light), vein, cool, torn (pale torn-tissue colour), casters (masks for AO + contact shadow),
-- veinPer (px between side veins), shape(t)->width factor (optional), glossy (bool: extra specular streak)
local ZIG = { 0, 2, -1, 3, 0, -2, 1, 3, -1, 2, 0 }
function A.scrap(c, p, o)
  local wmax = o.w
  local m, n, T, S, len = G.blade(p[1], p[2], p[3], p[4], p[5], p[6], function(t)
    if t > 0.985 then return -1 end
    local f = o.shape and o.shape(t) or sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6
    return max(0.5, wmax * f)
  end, { fold = o.fold or 0.35 })
  -- tear: jagged cut across the blade at o.tear (keeps the base end)
  local tearL = o.tear * len
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local i = floor((S[k] + 1) * 5) + 1
    if T[k] * len > tearL + ZIG[min(11, max(1, i))] then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  -- small bite/notch on the upper margin
  if o.notch then m:cut(c:ellipse(o.notch[1], o.notch[2], o.notch[3], o.notch[3])) end
  local bias = {}
  for _, cm in ipairs(o.casters or {}) do X.ao(bias, m, cm, 1, -1) G.cast(bias, m, cm, 1, 2, -1) end
  local tok = A.tok("leaf")
  local ramp = o.ramp
  local idx = G.toneN(c, m, n, ramp, { bias = bias, tok = tok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  local per = o.veinPer or 6
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and o.vein or ramp[3], tok) return end
    local ph = (t * len - abs(s) * (o.sweep or 4.5)) / per + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.05 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) end
  end)
  -- torn edge: pale exposed tissue on the tear line; cool reflected light on the shade-side margin
  local e = m:edge()
  e:each(function(x, y) local k = K(x, y)
    if T[k] * len > tearL - 3.5 then c:put(x, y, o.torn, tok)
    elseif not bias[k] and S[k] > 0.62 and T[k] > 0.06 then c:put(x, y, o.cool, tok) end
  end)
  if o.glossy then
    m:each(function(x, y) local k = K(x, y)
      if not bias[k] and S[k] < -0.3 and S[k] > -0.5 and T[k] > 0.2 and T[k] < 0.45 then c:put(x, y, ramp[6], tok) end end)
  end
  return m, T, S, len, tok
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

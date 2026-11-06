-- _aB20_0.lua: private helpers for chestnut-seed, chicha, chickpea, chickpea-seed (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.LCUTS = { 0.12, 0.27, 0.43, 0.6, 0.78 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- leaf blade (sprout leaf or torn scrap). o: w, pow, fold, teeth (period px), tear (t of ragged base cut),
-- casters (masks for AO + contact shadow), ramp (6), vein, cool, edge (torn-fibre colour), period (vein spacing), tok
function A.leaf(c, ax, ay, cx, cy, bx, by, o)
  local W, pw = o.w, o.pow or 0.6
  local torn = o.tear ~= nil
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    local u = torn and (0.3 + 0.7 * t) or min(1, t * 0.92 + 0.06)
    return max(0.5, W * sin(pi * min(1, u)) ^ pw)
  end, { fold = o.fold or 0.35 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if torn then
      local j = X.hash(floor((s + 1) * 3.2), 7, o.seed or 3)
      if t < o.tear + 0.09 * j then cut[#cut + 1] = k end
    end
    if o.teeth and t > 0.06 and t < 0.93 then
      local ph = (t * len / o.teeth) % 1
      if abs(s) > 0.72 + 0.26 * ph then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local bias = {}
  for _, cm in ipairs(o.casters or {}) do X.ao(bias, m, cm, 1, -1) G.cast(bias, m, cm, 1, 2, -1) end
  local R = o.ramp
  local tok = o.tok or { r = { name = o.name or "leaf" } }
  G.toneN(c, m, n, R, { bias = bias, tok = tok, cuts = o.cuts or A.LCUTS, amb = 0.18, wrap = 0.3 })
  local per = o.period or 4.5
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < 0.13 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and (o.vein or R[6]) or R[3], tok) return end
    local ph = (t * len - abs(s) * W * 0.9) / per + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if W >= 3 and f > 0.86 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.05 and t < 0.88 then
      c:put(x, y, s < 0 and R[5] or R[2], tok) end
  end)
  local e = m:edge()
  e:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    if torn and T[k] < o.tear + 0.11 then c:put(x, y, o.edge or R[6], tok)
    elseif o.cool and S[k] > 0.6 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, o.cool, tok) end
  end)
  return m, T, S, tok, len
end

-- chickpea: ram-head seed with a beak (dir ang), wrinkles. bias optional (AO). returns mask
function A.chickpea(c, cx, cy, r, ang, R, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r * 0.92)
  local bxp, byp = cx + cos(ang) * (r - 0.2), cy + sin(ang) * (r - 0.2)
  m:add(c:ellipse(floor(bxp + .5), floor(byp + .5), 1.2, 1.2))
  if o.clip then m:cut(o.clip) end
  local n = X.pillow(m, r * 0.95)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local bias = o.bias or {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local d = sqrt(dx*dx + dy*dy) / r
    local th = math.atan(dy, dx) - ang
    -- wrinkle grooves: swirl from the beak around the body, plus the beak cleft
    if d > 0.3 and d < 0.92 and abs(sin(2.5 * th + d * 2.4 + (o.ph or 0))) < 0.16 then bias[k] = (bias[k] or 0) - 1 end
    if abs(sin(th)) * d < 0.12 and cos(th) > 0 and d > 0.45 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local tok = { r = { name = o.name or ("cp" .. cx .. cy) } }
  X.tone(c, m, v, R, { cuts = A.CUTS6, bias = bias, tok = tok })
  -- matte: one 2x1 hi pop
  local sx, sy = G.specAt(m, n, 20)
  if sx then c:put(sx, sy, R[6], tok) if m:has(sx + 1, sy) then c:put(sx + 1, sy, R[6], tok) end end
  return m
end

-- small leaflet (pillow lit) along unit dir from (x,y)
function A.leaflet(x, y, ux, uy, L, wd)
  return G.rell(x + ux * L * 0.55, y + uy * L * 0.55, ux, uy, L * 0.6, wd)
end

-- glossy water bead (quirk dewdrops)
function A.dew(c, x, y)
  c:put(x, y, "#5fc4c8") c:put(x + 1, y, "#b6f0e0") c:put(x, y + 1, "#3a86b0") c:put(x + 1, y + 1, "#5fc4c8")
  c:put(x, y, A.CREAM)
end
return A

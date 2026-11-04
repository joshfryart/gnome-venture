-- _aB1r1_1.lua: private helpers for cauliflower-seed, ceibo-seed, celery, celery-seed (final pass, Opus aB1r1_1).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.save(c, name)
  local out = app.params.out or (DIR .. "/../ph/")
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

function A.map(c, x0, y0, rows, cmap, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cmap[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cmap[ch], tok) end end end
end

-- tear the t=0 end of a blade: jagged, uneven bite. returns mask of the fresh torn rim
function A.tear(m, T, S, len, depth, seed)
  local rim = HP.mask()
  local kill = {}
  m:each(function(x, y) local k = K(x, y)
    local d = T[k] * len
    local band = floor((S[k] + 1) * 4.5)
    local j = depth + ((band % 2 == 0) and 0 or 1.6) + X.hash(band, 3, seed or 1) * 1.8 + S[k] * 1.2
    if d < j then kill[#kill + 1] = k elseif d < j + 1.1 then rim:set(x, y) end
  end)
  for _, k in ipairs(kill) do m.s[k] = nil end
  rim:clip(m)
  return rim
end

-- paint a leaf scrap: ramp tone + midrib + pinnate veins + cool reflected edge + torn rim
-- o: bias, tok, per (vein spacing px), sweep, vein (lit vein), veinD (shade-side vein), cool, rim (mask) rimCol, cuts
function A.leaf(c, m, n, T, S, len, R, o)
  o = o or {}
  local tok = o.tok or { r = { name = "leaf" } }
  local bias = o.bias or {}
  G.toneN(c, m, n, R, { bias = bias, tok = tok, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  local per, sw = o.per or 6, o.sweep or 3.5
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] and bias[k] < 0 then return end
    if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and (o.vein or R[6]) or R[3], tok) return end
    local ph = (t * len - abs(s) * sw) / per + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.78 and t < 0.92 then c:put(x, y, s < 0 and (o.vein or R[6]) or (o.veinD or R[2]), tok) end
  end)
  if o.cool then
    m:edge():each(function(x, y) local k = K(x, y)
      if not (bias[k] and bias[k] < 0) and S[k] > 0.7 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, o.cool, tok) end end)
  end
  if o.rim then o.rim:each(function(x, y) c:put(x, y, o.rimCol or R[6], tok) end) end
  return tok
end

-- toothed leaflet mask along direction (ux,uy): length L, half width W, teeth count per side
function A.tooth(cx, cy, ux, uy, L, W, teeth, depth)
  local m = HP.mask()
  local R = math.ceil(L) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a = dx * ux + dy * uy          -- 0 .. L along
    local b = -dx * uy + dy * ux
    if a >= -0.5 and a <= L + 0.3 then
      local t = max(0, a) / L
      local w = W * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.65
      local ph = t * teeth
      local saw = 1 - (depth or 0.35) * (ph - floor(ph))
      if abs(b) <= w * saw + 0.2 then m:set(x, y) end
    end
  end end
  return m
end

-- small glossy sphere with spec; returns mask
function A.ball(c, cx, cy, r, R, tok, spec, bias)
  local m = HP.ellipse(cx, cy, r, r)
  local n = X.sphere(cx, cy, r, m)
  local v = X.light(n, { amb = 0.05, wrap = 0.2 })
  X.tone(c, m, v, R, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, tok = tok, bias = bias })
  if spec then local sx, sy = G.specAt(m, n, 30) c:put(sx, sy, spec, tok) end
  return m, n
end
return A

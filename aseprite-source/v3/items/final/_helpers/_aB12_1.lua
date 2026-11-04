-- _aB12_1.lua: private helpers for ph/broken-masterwork-secateurs, -stirrup-hoe, -wheel-hoe, broken-miner-s-lantern
-- (final pass, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
-- 6-tone ramps, dark -> light (cool-violet shade, warm-yellow light)
A.STEEL = { "#2e3150", "#484d6c", "#6c728e", "#959bb2", "#c3c7d6", "#eceef4" }
A.BRASS = { "#6a3820", "#9b5a23", "#c88229", "#e8ad3a", "#f8d268", "#fff0b0" }
A.WOOD  = { "#4a2a27", "#6d3d2c", "#93583a", "#b8794a", "#d59c63", "#efc890" }
A.RED   = { "#561c34", "#8a2838", "#bd3638", "#e2533c", "#fb8458", "#ffbf96" }
A.GLASS = { "#2a4a7a", "#3a7fae", "#58b7c4", "#8ad8d4", "#b8f0e2", "#e8fcf3" }
A.PINK  = { "#6e2a4a", "#a23e62", "#d06482", "#ec8c9c", "#ffb4bc", "#ffdcd8" }
A.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
local function line2bez(a, b)
  return { a, { a[1] + (b[1]-a[1])/3, a[2] + (b[2]-a[2])/3 }, { a[1] + 2*(b[1]-a[1])/3, a[2] + 2*(b[2]-a[2])/3 }, b }
end
A.line2bez = line2bez

-- geometry of a tube along a bezier (or 2-point line): {m,n,T,S,sm,len}
function A.geo(p, wfn)
  if #p == 2 then p = line2bez(p[1], p[2]) end
  local m, n, T, S, sm = G.tube(p, wfn)
  local len = 0
  for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
  return { m = m, n = n, T = T, S = S, sm = sm, len = len, p = p }
end
-- restrict a geo to T range (new geo sharing normals)
function A.sub(g, t0, t1)
  local m = HP.mask()
  g.m:each(function(x, y) local t = g.T[K(x, y)] if t >= t0 and t <= t1 then m:set(x, y) end end)
  return { m = m, n = g.n, T = g.T, S = g.S, sm = g.sm, len = g.len, p = g.p }
end
-- sample point on geo centre line at t, plus perpendicular (points lower-right)
function A.at(g, t)
  local s = g.sm[floor(t * (#g.sm - 1)) + 1]
  return s.x, s.y, s.px, s.py, s.w, s.tx, s.ty
end

-- tone mask m with normal field n. o: bias, ao={masks}, aor, amb, wrap, cuts, tok, name
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local bias = o.bias or {}
  for _, om in ipairs(o.ao or {}) do X.ao(bias, m, om, o.aor or 1, -1) end
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local tok = o.tok or A.tok(o.name or "part")
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = bias, tok = tok })
  return idx, tok, v
end
function A.paint(c, g, ramp, o) local idx, tok = A.tone(c, g.m, g.n, ramp, o) g.idx, g.tok, g.ramp = idx, tok, ramp return g end
-- pillow-lit flat part (bevel radius R)
function A.slab(c, m, R, ramp, o)
  local n = X.pillow(m, R or 2)
  local idx, tok = A.tone(c, m, n, ramp, o)
  return { m = m, n = n, idx = idx, tok = tok, ramp = ramp }
end
function A.ball(c, cx, cy, r, ramp, o)
  local m = HP.ellipse(cx, cy, r, r)
  local n = X.sphere(cx, cy, r, m)
  local idx, tok = A.tone(c, m, n, ramp, o)
  return { m = m, n = n, idx = idx, tok = tok, ramp = ramp }
end
-- specular streak: pixels of g with S in [s0,s1], T in [t0,t1] and current tone >= minIdx -> ramp[6] (or hex)
function A.streak(c, g, s0, s1, t0, t1, hex, minIdx)
  g.m:each(function(x, y) local k = K(x, y)
    local s, t = g.S[k], g.T[k]
    if s >= s0 and s <= s1 and t >= t0 and t <= t1 and (g.idx[k] or 0) >= (minIdx or 3) then
      c:put(x, y, hex or g.ramp[6], g.tok) end end)
end
-- wood grain: dashed darker lines running along the tube
function A.grain(c, g, seed, lines)
  lines = lines or { -0.35, 0.3 }
  g.m:each(function(x, y) local k = K(x, y)
    local s, t = g.S[k], g.T[k]
    for i, l in ipairs(lines) do
      if abs(s - l) < 0.2 then
        local seg = floor(t * g.len / 3 + i * 0.5)
        if X.hash(seg, i, seed) > 0.4 then
          local cur = g.idx[k] or 3
          c:put(x, y, g.ramp[max(1, cur - 1)], g.tok)
        end
      end
    end
  end)
end
-- ring band across a tube at arc position t (1 px), coloured from ramp by its own light
function A.band(c, g, t, ramp, tok, dark)
  local L = g.len
  g.m:each(function(x, y) local k = K(x, y)
    if abs((g.T[k] - t) * L) < 0.5 then
      local s = g.S[k]
      local i = s < -0.3 and 5 or (s < 0.35 and 4 or 2)
      if dark then i = max(1, i - 2) end
      c:put(x, y, ramp[i], tok or g.tok)
    end
  end)
end
function A.clear(c, m) m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then
  c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end) end
-- small fragment: polygon pts, pillow lit
function A.chip(c, pts, ramp)
  local m = HP.poly(pts)
  return A.slab(c, m, 1, ramp, { amb = 0.2 })
end
function A.map(c, rows, x0, y0, cmap, tok)
  for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
    if cmap[ch] then c:put(x0 + i - 1, y0 + j - 1, cmap[ch], tok or true) end end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  local mg = r.margin
  if mg.l < 5 or mg.r < 5 or mg.t < 5 or mg.b < 5 then error("margin < 5: " .. name) end
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A

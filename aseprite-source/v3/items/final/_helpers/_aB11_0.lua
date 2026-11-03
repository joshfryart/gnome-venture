-- _aB11_0.lua: private helpers for ph/broken-* chunk aB11_0 (Opus single pass). Read-only use of batch2/_b2g1.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.STEEL  = { "#3a3c56", "#55596f", "#767b92", "#9a9fb3", "#c3c7d6", "#eef0f6" }
A.GALV   = { "#384656", "#52667a", "#71879a", "#95aab8", "#bdd0da", "#ecf6f8" }
A.COPPER = { "#5a2018", "#8c3622", "#b9572e", "#da7a40", "#f2a463", "#ffd6a2" }
A.BRASS  = { "#6a3418", "#9a5220", "#cc7e2a", "#eeab3a", "#ffd15e", "#fff0b4" }
A.WOOD   = { "#41241f", "#633a29", "#8a5530", "#b0743e", "#cf9456", "#ecc08a" }
A.HICK   = { "#4e2e22", "#7a4a2e", "#a66c3c", "#c98e52", "#e2b070", "#f6d9a0" }
A.STRAW  = { "#5e3e22", "#8a6034", "#b48544", "#d3a557", "#ebc477", "#fbe3a8" }
A.LEATH  = { "#36201f", "#55302b", "#7a4535", "#9d5f43", "#be7d58", "#dca27a" }
A.SOIL   = { "#24161a", "#35201f", "#4a2c26", "#643c2c", "#80523a", "#a07050" }
A.PINK   = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
A.CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }

function A.start(name)
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  return c
end
-- light a mask from a normal field n with ramp; returns idx
function A.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end
-- pillow lit
function A.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 2, o.hs)
  return A.toneN(c, m, n, ramp, o), n
end
-- straight tapered cylinder A->B; returns m, n, T, S, idx
function A.rod(c, ax, ay, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = X.cyl(ax, ay, bx, by, type(wfn) == "number" and function() return wfn end or wfn)
  if o.clip then m:cut(o.clip) end
  local idx = A.toneN(c, m, n, ramp, o)
  return m, n, T, S, idx
end
-- bezier tube; returns m, n, T, S, samples, idx
function A.tubeL(c, p, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, sm = G.tube(p, wfn)
  local idx = A.toneN(c, m, n, ramp, o)
  return m, n, T, S, sm, idx
end
-- wood grain: dark dashed streaks along a tube (needs T,S); len = approx length px
function A.grain(c, m, T, S, len, ramp, seed, idx)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if s and t then
      local lane = floor((s + 1) * 2.2)
      local seg = floor(t * len / 4 + lane * 0.7)
      if X.hash(seg, lane, seed or 1) > 0.5 and abs(s) < 0.85 then
        local i = idx and idx[k] or 3
        c:px(x, y, ramp[max(1, i - 1)])
      end
    end
  end)
end
function A.erase(c, m) m:each(function(x, y) local k = y * c.w + x c.pix[k] = nil c.own[k] = nil end) end
function A.gap(c, pts, w) local m = c:line(pts, w or 1) A.erase(c, m) return m end
-- rotated frame mask: f(a,b) -> bool, origin ox,oy, axis (ax,ay); b axis = (-ay, ax)
function A.frame(ox, oy, ax, ay, f, R)
  local m, U, V = HP.mask(), {}, {}
  R = R or 24
  for y = floor(oy) - R, floor(oy) + R do for x = floor(ox) - R, floor(ox) + R do
    local dx, dy = x + 0.5 - ox, y + 0.5 - oy
    local a = dx * ax + dy * ay
    local b = -dx * ay + dy * ax
    if f(a, b) then m:set(x, y) U[K(x, y)] = a V[K(x, y)] = b end
  end end
  return m, U, V
end
function A.map(c, x0, y0, rows, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:px(x0 + xx - 1, y0 + yy - 1, pal[ch]) end end end
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A

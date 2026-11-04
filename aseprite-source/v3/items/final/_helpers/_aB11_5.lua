-- _aB11_5.lua: private helpers for ph/broken-hatchet, broken-hiking-staff, broken-hooked-forager-s-knife, broken-hori-hori
-- (Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local A = setmetatable({ HP = HP, X = X, K = K, G = G }, { __index = G })
A.OUT = app.params.out or (DIR .. "/../ph/")

-- 6-tone ramps, dark -> light
A.STEEL = { "#2c2c4c", "#4b4f70", "#707895", "#98a2b9", "#c4cddb", "#eef2f6" }
A.IRON  = { "#2a2638", "#47405a", "#665e7a", "#8a849c", "#b2aec0", "#dcdae4" }
A.BRASS = { "#4a2622", "#7c4127", "#b0672b", "#d99331", "#f3c14f", "#fff0a6" }
A.ASH   = { "#4c2a27", "#713f2d", "#985a39", "#bd7d4c", "#d9a266", "#f1c98e" }
A.OAK   = { "#45252a", "#6d3a2c", "#965534", "#bb7642", "#d99c5c", "#f2c584" }
A.BURL  = { "#3f2a2c", "#634032", "#87603d", "#ab8350", "#cba76c", "#ead095" }
A.CHERRY= { "#3c1c2a", "#5e2830", "#863a34", "#ac5440", "#cc7650", "#e8a274" }
A.LEATH = { "#3a1d2a", "#5a2a2e", "#7c3c30", "#a0553a", "#c27a4e", "#e0a872" }
A.EMBER = { "#5a1c34", "#8e2a3a", "#b52e3f", "#d63f3c", "#f06a4c", "#ff9a6e" }
A.MOSS  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.SOIL  = { "#2e1c22", "#46292a", "#5f3b30", "#7a4f3a", "#97684a", "#b5865e" }
A.PETAL = { "#6e2a4e", "#9a3c5c", "#c45a72", "#e07f8c", "#f5a7ae", "#ffd2cf" }
A.CORD  = { "#5e3a26", "#8a5a2e", "#b58238", "#d9a94a", "#f0cd72", "#fff0b4" }
A.CREAM = "#fff4d6"
A.INK = "#2b1c26"
A.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }

function A.new(name)
  A.name = name
  return HP, X, HP.canvas{ w = 64, h = 64, scale = 1, name = name }
end
function A.clampI(i) return max(1, min(6, i)) end
function A.erase(c, m)
  m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then
    c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end)
end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end
-- straight cubic for G.tube
function A.seg(ax, ay, bx, by)
  return { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
end
function A.blen(sm)
  local L = 0
  for i = 2, #sm do L = L + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
  return L
end
-- tube geometry only (mask may be trimmed by keep(t,s,x,y) before shading)
function A.tubeGeo(p, wfn, keep)
  local m, n, T, S, sm = G.tube(p, wfn)
  if keep then
    local cut = HP.mask()
    m:each(function(x, y) local k = K(x, y) if not keep(T[k], S[k], x, y) then cut:set(x, y) end end)
    m:cut(cut)
  end
  return m, n, T, S, sm
end
function A.bump(c, idx, ramp, x, y, d)
  local k = K(x, y)
  if idx[k] then local i = A.clampI(idx[k] + d) idx[k] = i c:put(x, y, ramp[i]) end
end
function A.set(c, idx, ramp, x, y, i)
  local k = K(x, y)
  if idx[k] then i = A.clampI(i) idx[k] = i c:put(x, y, ramp[i]) end
end
-- wavy wood grain lanes along a tube (darken one step), knots optional
function A.grain(c, m, T, S, idx, ramp, lanes, L, seed)
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    for i, ln in ipairs(lanes) do
      local off = ln + 0.13 * sin(t * L * 0.33 + i * 1.9)
      if abs(s - off) < 0.12 and X.hash(floor(t * L / 4), i, seed or 0) > 0.22 then
        A.bump(c, idx, ramp, x, y, -1) break end
    end
  end)
end
-- 1 px crack: dark line, with a lit lip pixel above-left of each crack pixel (only where idx exists)
function A.crack(c, pts, idx, ramp)
  local m = c:line(pts, 1)
  m:each(function(x, y) if idx[K(x, y)] then
    if not m:has(x - 1, y - 1) and idx[K(x - 1, y - 1)] then A.set(c, idx, ramp, x - 1, y - 1, idx[K(x - 1, y - 1)] + 1) end
  end end)
  m:each(function(x, y) if idx[K(x, y)] then A.set(c, idx, ramp, x, y, 1) end end)
  return m
end
-- flying chip: small pillow-lit polygon with a bright edge pixel
function A.chip(c, poly, ramp, o)
  local m = c:poly(poly)
  local n = X.pillow(m, 1.2)
  local idx = A.shade(c, m, n, ramp, { amb = 0.2 })
  return m, idx
end
function A.map(c, rows, x0, y0, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch]) end end end
end
function A.fin(c)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c)
  HP.assertClean(c)
  c:save{ aseprite = A.OUT .. A.name .. ".aseprite", png = A.OUT .. A.name .. ".png", scale = 1 }
  return r
end
return A

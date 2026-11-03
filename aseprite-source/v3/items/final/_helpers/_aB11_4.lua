-- _aB11_4.lua: private helpers for ph/broken-glowcap-lantern, broken-hand-fork, broken-harvest-sack, broken-harvest-trug
-- (Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local A = setmetatable({ HP = HP, X = X, K = K, G = G }, { __index = G })
A.OUT = app.params.out or (DIR .. "/../ph/")

-- 6-tone ramps, dark -> light
A.BRASS = { "#4a2622", "#7c4127", "#b0672b", "#d99331", "#f3c14f", "#fff0a6" }
A.STEEL = { "#2c2c4c", "#4b4f70", "#707895", "#98a2b9", "#c4cddb", "#eef2f6" }
A.ASH   = { "#4c2a27", "#713f2d", "#985a39", "#bd7d4c", "#d9a266", "#f1c98e" }
A.OAK   = { "#45252a", "#6d3a2c", "#965534", "#bb7642", "#d99c5c", "#f2c584" }
A.BURL  = { "#4d3129", "#76502f", "#9c7341", "#bf985a", "#dab977", "#f1d9a0" }
A.GLASS = { "#22426a", "#2e6a8c", "#4795aa", "#79c3c2", "#b2e8dc", "#e8fff6" }
A.GLOW  = { "#2a5236", "#3f8a3c", "#78c23c", "#b6e84a", "#e6ff86", "#fbffd6" }
A.GOLD  = { "#5e3020", "#8f4a1f", "#d98322", "#f5b82e", "#ffd76a", "#fff1b8" }
A.EMBER = { "#5a1c34", "#8e2a3a", "#b52e3f", "#d63f3c", "#f06a4c", "#ff9a6e" }
A.MOSS  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.ORNG  = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
A.PURP  = { "#3a2150", "#5c2f72", "#86449a", "#b36bbd", "#d9a3dc", "#f6dcf0" }
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
-- light normals and tone. returns idx table
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end
-- tube along a cubic bezier, lit. returns m, n, T, S, idx, samples
function A.tube(c, p, wfn, ramp, o)
  local m, n, T, S, sm = G.tube(p, wfn)
  local idx = A.shade(c, m, n, ramp, o)
  return m, n, T, S, idx, sm
end
function A.seg(ax, ay, bx, by)
  return { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
end
-- pillow-lit mask
function A.pillow(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2)
  return A.shade(c, m, n, ramp, o), n
end
-- vertical-cylinder normals between x0..x1 (tilt ty < 0 = faces up)
function A.vcylN(m, x0, x1, ty)
  local n = {}
  m:each(function(x, y)
    local t = max(-.95, min(.95, ((x - x0) / max(1, x1 - x0)) * 2 - 1))
    local nx, ny, nz = t, ty or 0, sqrt(max(0.05, 1 - t * t))
    local l = sqrt(nx*nx + ny*ny + nz*nz)
    n[K(x, y)] = { nx / l, ny / l, nz / l }
  end)
  return n
end
-- shift the tone of an already-painted pixel inside idx by d
function A.bump(c, idx, ramp, x, y, d)
  local k = K(x, y)
  if idx[k] then local i = A.clampI(idx[k] + d) idx[k] = i c:put(x, y, ramp[i]) end
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

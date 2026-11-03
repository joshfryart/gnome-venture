-- _aA10_3: helper for ico-strawberry, ico-strength, ico-sun, ico-sun-rain (Opus artist pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
-- 6-tone ramps, dark -> light
D.RED   = { "#5e1a34", "#8e2238", "#c42e36", "#e8493b", "#ff7258", "#ffa784" }
D.SEED  = { "#8f4a1f", "#d98322", "#f5c83e", "#ffef9e" }
D.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.SKIN  = { "#6e3530", "#a0574a", "#c98462", "#e6a47a", "#f6c69a", "#ffe4c2" }
D.CLOTH = { "#29305e", "#3a4a8a", "#4f68ad", "#6a8ccc", "#94b4e4" }
D.PLAST = { "#9a5a46", "#c98e6a", "#e8bd92", "#f8dcb4" }
D.SUN   = { "#9a3a1e", "#d0601c", "#ee8c1e", "#f8b62a", "#ffd84c", "#fff29e" }
D.RAY   = { "#8e2c22", "#c44a1e", "#e8721e", "#f8a028", "#ffc848" }
D.CLOUD = { "#3a4470", "#56649a", "#7c8cc0", "#a6b8e0", "#cfdcf4", "#eef4ff" }
D.RAIN  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.set(c, x, y, hex, tok) c:put(x, y, hex, tok or c.own[y * c.w + x]) end
function D.find(ramp, hex) for i, h in ipairs(ramp) do if h:lower() == (hex or ""):lower() then return i end end end
function D.shift(c, x, y, ramp, d)
  local i = D.find(ramp, c:get(x, y)) if i then c:put(x, y, ramp[max(1, min(#ramp, i + d))], c.own[y * c.w + x]) end
end
function D.poly(pts)
  local m = HP.mask()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0 = min(y0, p[2]) y1 = max(y1, p[2]) end
  for y = floor(y0) - 1, floor(y1) + 1 do
    local xs = {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= y) ~= (b[2] <= y) then xs[#xs + 1] = a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1]) end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), floor(xs[i + 1] - 0.5) do m:set(x, y) end
    end
  end
  return m
end
function D.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
-- normals from a height function h(x,y) over mask m
function D.hnorm(m, h)
  local n = {}
  m:each(function(x, y)
    local gx, gy = (h(x + 1, y) - h(x - 1, y)) / 2, (h(x, y + 1) - h(x, y - 1)) / 2
    local l = sqrt(gx*gx + gy*gy + 1)
    n[K(x, y)] = { -gx / l, -gy / l, 1 / l }
  end)
  return n
end
-- paint ramp from normals; returns idx
function D.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.3 })
  local cuts = o.cuts
  if not cuts then
    cuts = (#ramp == 6) and { 0.2, 0.36, 0.52, 0.68, 0.84 } or (#ramp == 5) and { 0.24, 0.42, 0.6, 0.8 } or { 0.3, 0.55, 0.8 }
  end
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
end
-- thick polyline mask (disc brush)
function D.stroke(pts, r)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local L = sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
    local N = max(1, math.ceil(L * 3))
    for j = 0, N do
      local t = j / N
      local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
      for yy = floor(y - r) - 1, floor(y + r) + 1 do for xx = floor(x - r) - 1, floor(x + r) + 1 do
        if (xx - x) ^ 2 + (yy - y) ^ 2 <= r * r + 0.05 then m:set(xx, yy) end end end
    end
  end
  return m
end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ico/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D

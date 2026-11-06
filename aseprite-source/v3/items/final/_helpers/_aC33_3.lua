-- _aC33_3: helper for ph/persimmon-jam, persimmon-seed, petunia-seed, piccalilli (Opus artist pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
D.CUT6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tok(name) return { r = { name = name } } end
function D.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
-- mask from row half-widths: hw(y) about centre cx (cx may be .5)
function D.rows(cx, y0, y1, hw)
  local m = HP.mask()
  for y = y0, y1 do local h = hw(y) if h and h > 0 then
    for x = math.ceil(cx - h), floor(cx + h) do m:set(x, y) end end end
  return m
end
-- vertical cylinder normals: x0..x1 span, optional top/bottom roll
function D.vcyl(m, x0, x1, ytop, ybot, roll)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x - x0) / (x1 - x0)) * 2 - 1))
    local ny = 0
    if ytop and y < ytop + (roll or 3) then ny = -(1 - (y - ytop) / (roll or 3)) * 0.6 end
    if ybot and y > ybot - (roll or 3) then ny = (1 - (ybot - y) / (roll or 3)) * 0.6 end
    local l = sqrt(t * t + ny * ny + (1 - t * t))
    n[K(x, y)] = { t / l, ny / l, sqrt(1 - t * t) / l }
  end)
  return n
end
function D.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.3 })
  local cuts = o.cuts or ((#ramp == 6) and D.CUT6 or (#ramp == 5) and { 0.24, 0.42, 0.6, 0.8 } or { 0.3, 0.55, 0.8 })
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
  return idx, v
end
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
-- 1px pixel line (Bresenham) through points
function D.line(c, pts, hex, tok, fn)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local e = dx + dy
    while true do
      local h = fn and fn(x0, y0) or hex
      if h then c:put(x0, y0, h, tok) end
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * e
      if e2 >= dy then e = e + dy x0 = x0 + sx end
      if e2 <= dx then e = e + dx y0 = y0 + sy end
    end
  end
end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D

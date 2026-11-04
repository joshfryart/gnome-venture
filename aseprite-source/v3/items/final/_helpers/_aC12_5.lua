-- _aC12_5.lua: private helpers for ph/hummus-jar, hyacinth-seed, hydrangea-seed, iced-tea-concentrate (final, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- vertical cylinder normals (axis vertical through cx, half width hw); tilt<0 faces slightly up
function A.vcyl(m, cx, hw, tilt, fy)
  local n = {}
  m:each(function(x, y)
    local sn = max(-0.97, min(0.97, (x + 0.5 - cx) / (hw + 0.5)))
    local ny = (tilt or -0.1) + (fy and fy(y) or 0)
    n[K(x, y)] = { norm(sn, ny, sqrt(1 - sn*sn)) }
  end)
  return n
end

-- 1px separation line: edge pixels of m that 4-touch `other`
function A.sep(c, m, other, hex, tok)
  m:each(function(x, y)
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      if other:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then c:put(x, y, hex, tok) return end
    end
  end)
end

function A.line(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      c:put(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5), hex, tok) end
  end
end

-- wavy-edged lanceolate leaf (horseradish / dock type) along quadratic bezier; petiole for t < pet
function A.wavyLeaf(c, a, cc, b, W, o)
  o = o or {}
  local pet = o.pet or 0.2
  local m, n, T, S, len = G.blade(a[1], a[2], cc[1], cc[2], b[1], b[2], function(t)
    if t > 0.985 then return -1 end
    if t < pet then return 0.55 end
    local u = (t - pet) / (1 - pet)
    local w = W * sin(pi * min(1, u * 0.9 + 0.1)) ^ 0.65
    return max(0.5, w + (o.wave or 0.7) * sin(t * (o.freq or 30)) * min(1, u * 4))
  end, { fold = o.fold or 0.42 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = A.shade(c, m, n, A.LEAF, { tok = tok, amb = 0.14, wrap = 0.28, bias = o.bias })
  local L = A.LEAF
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if t < pet then c:put(x, y, s <= 0 and "#8cc066" or "#5b9a52", tok) return end
    if abs(s) < 0.14 and t < 0.93 then c:put(x, y, s <= 0 and (o.vein or "#c2e48c") or L[3], tok) return end
    local ph = (t * len - abs(s) * 3.2) / (o.per or 4.2)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 and t < 0.9 then
      c:put(x, y, L[max(1, min(6, (idx[k] or 3) + (s < 0 and 1 or -1)))], tok) end
  end)
  -- cool reflected light on the shade-side margin
  m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.7 and T[k] > pet + 0.1 and T[k] < 0.85 and (idx[k] or 1) <= 3 then c:put(x, y, o.cool or "#3a6c72", tok) end end)
  return m, T, S, idx, tok
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or A.CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

function A.paint(c, rows, x0, y0, map, tok)
  for r, rowS in ipairs(rows) do for i = 1, #rowS do local ch = rowS:sub(i, i)
    if map[ch] then c:put(x0 + i - 1, y0 + r - 1, map[ch], tok) end end end
end

-- glossy round seed (sphere light, 6-tone, bright spec + glint); returns mask
function A.ball(c, cx, cy, rx, ry, ramp, tok, o)
  o = o or {}
  local m = HP.mask()
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local u, v = (x + 0.5 - cx) / (rx + 0.3), (y + 0.5 - cy) / (ry + 0.3)
    if u * u + v * v <= 1 then m:set(x, y) end end end
  if o.cut then m:cut(o.cut) end
  local n = {}
  m:each(function(x, y)
    local u, v = (x + 0.5 - cx) / (rx + 0.6), (y + 0.5 - cy) / (ry + 0.6)
    n[K(x, y)] = { norm(u, v, sqrt(max(0.05, 1 - u * u - v * v))) } end)
  local idx = A.shade(c, m, n, ramp, { tok = tok, amb = o.amb or 0.05, wrap = 0.2, bias = o.bias, cuts = o.cuts })
  return m, idx, n
end
return A

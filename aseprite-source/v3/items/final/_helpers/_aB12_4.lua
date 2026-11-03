-- _aB12_4.lua: private helpers for the aB12_4 tool set (broken-steel-spade, broken-stirrup-hoe, broken-tide-bucket,
-- broken-tide-pail-and-scoop). Read-only use of batch1/_h.lua (hp.lua + hpx.lua).
local HDIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(HDIR .. "/../../batch1/_h.lua")
local HP, X, K = H.HP, H.X, H.K
local floor, sqrt, max, min, abs, sin, cos = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos
local A = { HP = HP, X = X, K = K, H = H, INK = "#2b1c26", CREAM = "#fff4d6" }
A.out = app.params.out or (HDIR .. "/../ph/")

-- 6-tone ramps, dark -> light
A.STEEL = { "#2c3050", "#4a5072", "#707896", "#9aa3bb", "#c8cfdd", "#eef2f6" }
A.ASH   = { "#4a2a28", "#74422f", "#9a6038", "#bd8048", "#dba565", "#f2cb8c" }
A.OAK   = { "#3c2228", "#62372c", "#8a5133", "#ae6d3d", "#cd9152", "#e9ba7a" }
A.IRON  = { "#22243a", "#353950", "#4f546c", "#6c7188", "#9095a9", "#bcc0cd" }
A.BRASS = { "#5a3220", "#8f5424", "#c07f26", "#e3a836", "#f6cd5e", "#fff0a8" }
A.HEMP  = { "#55361f", "#83592d", "#aa7d3c", "#cba155", "#e4c379", "#f5e0a6" }
A.TIN   = { "#5a1834", "#8f283b", "#c13b39", "#e45a3b", "#f98a57", "#ffc08a" }
A.TEAL  = { "#1b3a5a", "#225c76", "#2c8794", "#43afaa", "#77d2c3", "#bdf0e2" }
A.SEA   = { "#1f3a6a", "#2a5a8e", "#3a86b0", "#5fc4c8", "#8fe0d8", "#c8f6ea" }
A.SAND  = { "#7a4e34", "#a87446", "#cf9d5c", "#e8bf78", "#f5d896", "#fff0c4" }
A.WORM  = { "#6a2440", "#9c3b58", "#c9587a", "#e57f95", "#f8a8b5", "#ffd2d6" }
A.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.STAR  = { "#6e2038", "#a83236", "#d8503a", "#f07a44", "#ffa860", "#ffd28e" }
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) A.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias })
  return idx, v
end
function A.pil(c, m, ramp, R, o) local n = X.pillow(m, R or 2) local idx, v = A.tone(c, m, n, ramp, o) return idx, n, v end
-- vertical-axis cylinder normals between x0..x1
function A.vn(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end
-- index of hex in ramp
function A.idx(ramp, hex) if not hex then return nil end for i, h in ipairs(ramp) do if h == hex:lower() then return i end end end
function A.dk(c, x, y, ramp, n)
  local i = A.idx(ramp, c:get(x, y)) if i then c:px(x, y, ramp[max(1, min(#ramp, i - (n or 1)))]) end
end
-- ambient occlusion: pixels of back within r px of front (not in front) get darker
function A.ao(c, back, front, ramp, r, n)
  local ring = front:copy()
  for i = 1, r or 1 do
    local g = ring:grow(1)
    g:copy():cut(ring):each(function(x, y) if back:has(x, y) and not front:has(x, y) then A.dk(c, x, y, ramp, n or 1) end end)
    ring = g
  end
end
-- straight rod (cylinder) with optional wood grain
function A.rod(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local wf = type(w) == "function" and w or function() return w end
  local m, n, T, S = X.cyl(ax, ay, bx, by, wf)
  local idx = A.tone(c, m, n, ramp, o)
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  if o.grain then
    m:each(function(x, y) local k = K(x, y)
      local lane = floor((S[k] + 1) * 2.2)
      local seg = floor(T[k] * len / 4 + lane * 0.5)
      if X.hash(seg, lane, o.seed or 3) > 0.55 and abs(S[k]) < 0.85 then A.dk(c, x, y, ramp, 1) end
    end)
  end
  return m, n, T, S
end
function A.erase(c, m) m:each(function(x, y) local i = y * c.w + x c.pix[i] = nil c.own[i] = nil end) end
function A.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end
  end
end
function A.poly(c, pts, hex, clip) for i = 1, #pts - 1 do A.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hex, clip) end end
-- mask of pixels along a polyline (1px)
function A.lmask(pts)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n m:set(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)) end
  end
  return m
end
function A.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier; returns mask, normals, T, S, length
function A.tube(p, wfn, N)
  N = N or 120
  local sm, len = {}, 0
  for i = 0, N do
    local t = i / N
    local x, y = A.bez(p, t)
    local x2, y2 = A.bez(p, min(1, t + 0.002)) local x1, y1 = A.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
    if i > 0 then len = len + sqrt((x - sm[i].x)^2 + (y - sm[i].y)^2) end
    sm[i + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do x0, y0, x1, y1 = min(x0, s.x), min(y0, s.y), max(x1, s.x), max(y1, s.y) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(y0) - 4, floor(y1) + 4 do for x = floor(x0) - 4, floor(x1) + 4 do
    local best, bs
    for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if not best or q < best then best, bs = q, s end end
    if sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y) local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) } T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, len
end
-- mask from a local-frame predicate f(a, b): a along u from origin, b across (perp, +b lower-right)
function A.frame(ox, oy, ux, uy, x0, y0, x1, y1, f)
  local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do
    local rx, ry = x - ox, y - oy
    if f(rx * ux + ry * uy, rx * px + ry * py) then m:set(x, y) end
  end end
  return m
end
-- flying chip: small pillow-lit polygon
function A.chip(c, pts, ramp) local m = c:poly(pts) A.pil(c, m, ramp, 1, { amb = 0.2 }) return m end
-- shift drawn pixels so the outlined bbox is centred
function A.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("%s: recentre dx %d dy %d outlined %dx%d", A.name, dx, dy, W, Hh))
end
function A.fin(c)
  A.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.out .. A.name .. ".aseprite", png = A.out .. A.name .. ".png", scale = 1 }
end
return A

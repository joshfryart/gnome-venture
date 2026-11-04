-- dC32 helper (first-draft chunk): thin layer over batch2/_b2.lua. Shared files are not edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new = B.new D.lit = B.lit D.ell = B.ell D.ln = B.ln D.polyline = B.polyline D.seam = B.seam
D.leaf = H.leaf D.disc = H.disc D.cyl = H.cyl D.sweep = H.sweep D.ramp = H.ramp
-- 6-tone ramps (dark -> light)
D.R = {
  peach = { "#6e2038", "#b8403e", "#e9692f", "#f9944a", "#ffbf72", "#ffe2a4" },
  blush = { "#6e2038", "#a8305a", "#d24c6a", "#ee7088", "#ff9fa6", "#ffd0c0" },
  leaf  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  pear  = { "#3a5a2a", "#5f8a32", "#8cb43c", "#b3d049", "#d4e46a", "#f0f4a0" },
  grape = { "#2a1f4a", "#43306f", "#60449a", "#7d5cb8", "#a083d4", "#c9b4ec" },
  brown = { "#3a2020", "#5e362c", "#86523a", "#a9703f", "#cc9558", "#ecc07e" },
  seedB = { "#201820", "#38283a", "#58404c", "#7a5c62", "#a08078", "#d0b8a8" },
  gold  = { "#8f4a1f", "#c06a22", "#e08f26", "#f5b82e", "#ffd45e", "#ffeea0" },
  cream = { "#8a7a8a", "#b4a4a0", "#d6c8b4", "#ebe0c8", "#f8efd8", "#fffaf0" },
  pea   = { "#2a5a30", "#3c7a3a", "#5a9a42", "#7cba4e", "#a4d868", "#d0f090" },
  glass = { "#4a7a9a", "#74a8c4", "#9cc8dc", "#bfe2ee", "#dcf4f8", "#f6fdff" },
}
D.INK2 = "#3a2430"
function D.fin(c)
  c = c or B.c
  c:finish{ outline = true }
  local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local dx = floor((c.w - 1 - x1 + x0) / 2) - x0
  local dy = floor((c.h - 1 - y1 + y0) / 2) - y0
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w, i // c.w local j = (y + dy) * c.w + x + dx pix[j] = v own[j] = c.own[i] end
  c.pix, c.own = pix, own
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = H.out .. H.name .. ".aseprite", png = H.out .. H.name .. ".png", scale = 1 }
end
-- little helpers
function D.spec(c, x, y, big) c:px(x, y, D.CREAM) if big then c:px(x + 1, y, D.CREAM) end end
-- lit ellipse (rotated); returns mask
function D.blob(c, cx, cy, rx, ry, ang, ramp, R)
  local m = B.ell(cx, cy, rx, ry, ang)
  H.lit(c, m, ramp, { R = R or min(rx, ry) })
  return m
end
-- seed/ellipse with a small 1px contact shadow (dark) on the lower-right on `under` mask
function D.seedAt(c, cx, cy, rx, ry, ang, ramp, under)
  local m = B.ell(cx, cy, rx, ry, ang)
  if under then m:shift(1, 1):each(function(x, y) if under:has(x, y) and not m:has(x, y) then c:px(x, y, "#183a30") end end) end
  H.lit(c, m, ramp, { R = min(rx, ry) + .5 })
  local bx, by = 1e9, 1e9
  m:each(function(x, y) if x + y < bx + by then bx, by = x, y end end)
  c:px(bx + 1, by + 1, "#fff4d6")
  return m
end
-- leaf scrap: ellipse tilted, midrib + side veins; returns mask
function D.scrap(c, cx, cy, rx, ry, ang, ramp, ribLen)
  ramp = ramp or D.R.leaf
  local m = B.ell(cx, cy, rx, ry, ang)
  H.lit(c, m, ramp, { R = 3, amb = .1 })
  local ca, sa = cos(ang), sin(ang)
  local L = rx - 1
  for u = -L, L, .5 do
    local x, y = floor(cx + u * ca + .5), floor(cy + u * sa + .5)
    if m:has(x, y) then c:px(x, y, ramp[6]) end
  end
  for u = -L + 3, L - 3, 3.5 do
    for s = -1, 1, 2 do
      for k = 1, floor(ry - 1) do
        local uu, vv = u + k * .8, s * k
        local x, y = floor(cx + uu * ca - vv * sa + .5), floor(cy + uu * sa + vv * ca + .5)
        if m:has(x, y) then c:px(x, y, s < 0 and ramp[5] or ramp[2]) end
      end
    end
  end
  return m
end
-- thin stem along a bezier (4 pts), 2 tones, width w (half)
function D.stemB(c, pts, w, ramp)
  local m, T = H.sweep(pts, function() return w end, 40)
  H.lit(c, m, ramp, { R = max(1, w), amb = .1 })
  return m
end
-- jar glass body with fill (fillTop y); glass above. returns body mask
function D.jar(c, x0, y0, x1, y1, r, fill, fillTop)
  local m = c:rrect(x0, y0, x1, y1, r)
  local gl = D.R.glass
  H.vcyl(c, m, gl, x0, x1)
  local f = m:copy():clip(c:rect(x0, fillTop, x1, y1))
  H.vcyl(c, f, fill, x0 - 1, x1 + 1, { amb = .12, wrap = .3 })
  -- fill meniscus
  for x = x0 + 1, x1 - 1 do c:px(x, fillTop, fill[5]) end
  -- glass rim highlight (left) and reflected edge (right)
  for y = y0 + 3, y1 - 3 do if m:has(x0, y) then c:px(x0, y, gl[5]) end if m:has(x1, y) then c:px(x1, y, gl[2]) end end
  c:px(x0 + 1, y0 + 3, D.CREAM) c:px(x0 + 1, y0 + 4, D.CREAM)
  return m
end
function D.label(c, x0, y0, x1, y1, ramp)
  ramp = ramp or D.R.cream
  local m = c:rect(x0, y0, x1, y1)
  H.lit(c, m, ramp, { R = 1, amb = .2, wrap = .4 })
  for x = x0, x1 do c:px(x, y1, ramp[2]) end
  for y = y0, y1 do c:px(x1, y, ramp[3]) end
  return m
end
function D.mapPaint(c, rows, x, y, map) c:paint(rows, x, y, map) end
return D

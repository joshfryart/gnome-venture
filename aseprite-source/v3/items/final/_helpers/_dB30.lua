-- _dB30: helper for the d-B30 chunk (ph/ember-shell .. feijoa). Layer over _dB24 -> batch2/_b2.lua; edits nothing shared.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dB24.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, pi, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.sqrt
function D.new(name) local c = B.new(name) D.c = c return c end
local function rp(dk, md, lt) return { dk, H.mix(dk, md, .5), md, H.mix(md, lt, .4), H.mix(md, lt, .75), lt } end
D.rp = rp
D.R.leaf = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
D.R.wood = { "#3b2229", "#5e3a2e", "#864c33", "#a8693f", "#cf9159", "#ecbd82" }
D.R.gold = { "#6e3a1f", "#a35f22", "#d98322", "#f5b82e", "#ffd060", "#ffeaa0" }
D.R.dark = { "#150f1c", "#21172a", "#32243a", "#473450", "#624d70", "#85709a" }
D.R.stone = { "#35384f", "#545774", "#74758c", "#9798aa", "#bcbccb", "#e2e0e6" }
D.R.sea = { "#2a4a7a", "#3a6a9a", "#3a86b0", "#5fc4c8", "#8fe0d8", "#b6f0e0" }
-- scatter flecks on a mask: list of hex, density 0..1
function D.fleck(m, hexes, dens, seed, big)
  local c = D.c
  m:each(function(x, y)
    if X.hash(x, y, seed or 3) < (dens or .1) then
      local h = hexes[1 + floor(X.hash(x, y, (seed or 3) + 7) * #hexes) % #hexes]
      c:px(x, y, h)
      if big and m:has(x + 1, y) then c:px(x + 1, y, h) end
    end
  end)
end
-- ellipse with ellipse cut-out look: plate = outer lit disc + inner well. returns outer, inner
function D.plate(cx, cy, rx, ry, ramp, wellramp)
  local c = D.c
  local o = B.ell(cx, cy, rx, ry, 0)
  H.lit(c, o, ramp or D.R.cream, { R = 2.2 })
  local i = B.ell(cx, cy - .5, rx - 3, ry - 1.5, 0)
  H.lit(c, i, wellramp or ramp or D.R.cream, { R = 2, bias = nil })
  return o, i
end
-- leaf ellipse with midrib
function D.leaf(cx, cy, rx, ry, ang, ramp, rib)
  local c = D.c
  local m = B.ell(cx, cy, rx, ry, ang)
  H.lit(c, m, ramp or D.R.leaf, { R = min(rx, ry) + .6 })
  local r = H.ramp(ramp or D.R.leaf)
  if rib ~= false then
    local ca, sa = cos(ang), sin(ang)
    B.ln(c, cx - ca * (rx - 1), cy - sa * (rx - 1), cx + ca * (rx - 1.5), cy + sa * (rx - 1.5), (type(rib) == "string") and rib or r[6], m)
  end
  return m
end
-- stem polyline: lt left/top, dk right/bottom (1px dark under 1px light)
function D.stem(pts, lt, dk)
  local c = D.c
  local sh = {}
  for i, p in ipairs(pts) do sh[i] = { p[1] + 1, p[2] } end
  B.polyline(c, sh, dk) B.polyline(c, pts, lt)
end
-- lit seed with contact shadow
function D.seed(cx, cy, rx, ry, ang, ramp, shadow, glint)
  return B.seed(D.c, cx, cy, rx, ry, ang, ramp, shadow or "#1f553f", glint)
end
-- leaf scrap blade (veined) for seed items
function D.scrap(ax, ay, bx, by, w, ramp, veins)
  return B.blade(D.c, ax, ay, bx, by, w, ramp or D.R.leaf, { veins = veins or { 8, 14, 20, 26, 32, 38 }, slant = 2 })
end
-- steam curl, 2-tone
function D.steam(x, y, h, dir)
  local c = D.c
  dir = dir or 1
  for i = 0, h do
    local xx = x + floor(sin(i * .9) * 1.6 + .5) * dir
    c:px(xx, y - i, i % 3 == 2 and "#e8e4f2" or "#cfc8e0")
    c:px(xx + 1, y - i, "#cfc8e0")
  end
end
-- shadow dark row under a mask's lower edge
function D.ao(m, hex)
  local c = D.c
  m:each(function(x, y) if not m:has(x, y + 1) then c:px(x, y, hex) end end)
end
function D.px(c, list) for _, p in ipairs(list) do c:px(p[1], p[2], p[3]) end end
return D

-- green-pea-soup (dC10 first draft): a stone tureen of pea soup, two ear handles, a cream swirl, floating peas, a mint sprig.
-- quirk: the steam curl is drawn as a tiny heart-ish loop.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('green-pea-soup')
c:groundShadow(32, 56, 20, 2.5)
local ST = H.ramp('stone')
-- handles
D.rrect(c, 6, 30, 14, 36, 2, 'stone', 1) D.rrect(c, 50, 30, 58, 36, 2, 'stone', 1)
-- bowl body (lower half ellipse)
local body = c:ellipse(32, 30, 22, 24):clip(c:rect(0, 30, 63, 60)):add(c:rect(10, 27, 54, 31))
D.cyl(c, body, 'stone', 10, 54)
for x = 12, 52, 4 do c:px(x, 40, ST[2]) c:px(x + 1, 46, ST[2]) end
-- rim
D.rrect(c, 9, 25, 55, 31, 3, 'stone', 2)
-- soup surface
local sm = c:ellipse(32, 27, 20, 3.4)
local G = { '#24544a', '#3f9150', '#5ea84c', '#7cc35a', '#9ed26c', '#c4e07a' }
B.lit(c, sm, G, 2)
-- cream swirl
for i = 0, 40 do local a = i / 40 * 5.5 local r = 1 + i * 0.28
  local x, y = floor(32 + cos(a) * r * 1.3 + .5), floor(27 + sin(a) * r * 0.22 + .5)
  if sm:has(x, y) then c:px(x, y, '#fff4d6') end end
-- peas
for _, p in ipairs{ {20,26},{44,28},{26,29},{40,25} } do c:px(p[1], p[2], '#c4e07a') c:px(p[1]+1, p[2], '#3f9150') end
-- mint sprig
D.leafE(c, 36, 23, 3, 1.8, -0.5, 'moss', 0) D.leafE(c, 40, 22, 3, 1.8, -0.9, 'moss', 0)
-- steam
for _, s in ipairs{ {26, 20}, {37, 19} } do D.steam(c, s[1], s[2], 9, D.CREAM) end
c:px(24, 11, D.CREAM) c:px(25, 10, D.CREAM) c:px(27, 10, D.CREAM) c:px(28, 11, D.CREAM)
D.fin()

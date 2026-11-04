-- sea-buckthorn-juice (Sonnet high, single pass). A slim long-necked glass bottle, cork stopper, twine tied round the
-- neck with a little berry sprig tucked under it, cloudy orange juice, a cream paper label with a berry print.
-- Material: glass = bright left rim, pale core, dark blue right wall, thick base, specular streaks; juice = 6-tone orange
-- lit as a vertical cylinder with a meniscus ellipse, pulp specks, bubbles and a rim-light column; cork 6-tone with pits;
-- twine twist; label paper bevel + curled corner.
-- quirk: the sprig tucked under the twine still carries a berry and two silvery leaves.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_4.lua")
local HP, X, K, H = G.HP, G.X, G.K, G.H
local floor, abs, max, min, sqrt, pi, sin, cos = math.floor, math.abs, math.max, math.min, math.sqrt, math.pi, math.sin, math.cos
local c = G.new2("sea-buckthorn-juice")
local GL = { "#3f6f8c", "#6aa4b8", "#9fd0d6", "#cdeee8", "#e8f9f0", "#fbfff4" }
local ORG = { "#7a2a1c", "#b8441a", "#e8691f", "#f68e22", "#ffb43c", "#ffdc8a" }
local CK = { "#4a2f22", "#6e4630", "#946440", "#b88458", "#d6a574", "#efc994" }
local PAP = { "#6e5a4c", "#9c8668", "#c8b690", "#e0d0a8", "#f1e6c8", "#fff4d6" }
local GOLD = { "#7a4a20", "#a8702c", "#d29a3c", "#f2c45a", "#ffe08c" }
local LF = { "#2f4a46", "#4b6a5f", "#6f8f7c", "#93b09b", "#b8cdb6", "#dde8d2" }
local BK = { "#3a2a2e", "#5a4238", "#85624a", "#b08a62" }
local CX = 32
c:groundShadow(33, 52.5, 12, 2)
-- silhouette half width per row
local Y0, Y1 = 14, 51
local function hw(y)
  if y <= 15 then return 4.4 end
  if y <= 21 then return 3.4 end
  if y <= 30 then local t = (y - 21) / 9 local s = t * t * (3 - 2 * t) return 3.4 + 6.2 * s end
  if y <= Y1 - 4 then return 9.6 end
  local r = 4 local dy = y - (Y1 - r)
  return 9.6 - r + sqrt(max(0, r * r - dy * dy))
end
local function rows(inset, ya, yb)
  local m = HP.mask()
  for y = ya, yb do
    local h = hw(y) - inset
    for x = floor(CX - h + .5), floor(CX + h - .5) do m:set(x, y) end
  end
  return m
end
local glass = rows(0, Y0, Y1)
local core = rows(2, Y0 + 1, Y1 - 3)
local LEVEL = 27
local liquid = rows(2, LEVEL, Y1 - 3)
-- glass wall: cylinder normals across x
local gn = {}
glass:each(function(x, y)
  local h = hw(y)
  local nx = G.clamp((x + .5 - CX) / (h + .3), -.97, .97)
  gn[K(x, y)] = { nx, 0, sqrt(1 - nx * nx) }
end)
G.toneN(c, glass, gn, GL, { amb = .15, wrap = .35 })
-- empty glass interior: pale core
core:each(function(x, y)
  local h = hw(y) - 2
  local nx = (x + .5 - CX) / h
  c:px(x, y, nx < -.55 and GL[5] or (nx > .6 and GL[3] or GL[4]))
end)
-- thick base
for y = Y1 - 2, Y1 do glass:each(function(x, yy) if yy == y then c:px(x, yy, y == Y1 and GL[2] or (abs(x + .5 - CX) < hw(y) - 3 and GL[3] or GL[2])) end end) end
-- rim bright on the left edge, dark on the right
glass:each(function(x, y)
  local h = hw(y)
  if x == floor(CX - h + .5) then c:px(x, y, GL[6]) end
  if x == floor(CX + h - .5) then c:px(x, y, GL[1]) end
end)

-- juice
local ln = {}
liquid:each(function(x, y)
  local h = hw(y) - 2
  local nx = G.clamp((x + .5 - CX) / (h + .5), -.97, .97)
  ln[K(x, y)] = { nx, -.1, sqrt(1 - nx * nx) }
end)
local bias = {}
liquid:each(function(x, y) if y >= Y1 - 5 then bias[K(x, y)] = -1 end if y >= Y1 - 4 and x < CX - 3 then bias[K(x, y)] = -1 end end)
local idx = G.toneN(c, liquid, ln, ORG, { amb = .12, wrap = .3, bias = bias })
liquid:each(function(x, y)
  local i = idx[K(x, y)] or 3
  local h = H(x, y, 4)
  if h > .93 then c:px(x, y, ORG[min(6, i + 1)]) elseif h < .05 then c:px(x, y, ORG[max(1, i - 1)]) end
end)
-- meniscus
local surf = c:ellipse(CX - .5, LEVEL, hw(LEVEL) - 2.4, 1.7)
surf:each(function(x, y) c:px(x, y, (y <= LEVEL - 1 or x < CX - 3) and ORG[6] or ORG[5]) end)
for x = floor(CX - hw(LEVEL) + 2.6), floor(CX + hw(LEVEL) - 3.6) do c:px(x, LEVEL + 2, ORG[4]) end
-- rim-light column on the right inside
liquid:each(function(x, y) local h = hw(y) - 2 if x == floor(CX + h - .5) and y > LEVEL + 3 and y < Y1 - 5 then c:px(x, y, ORG[3]) end end)
-- bubbles
for _, p in ipairs{ { 28, 31 }, { 37, 33 }, { 29, 46 }, { 39, 44 } } do c:px(p[1], p[2], ORG[6]) c:px(p[1] + 1, p[2], ORG[5]) c:px(p[1], p[2] + 1, ORG[5]) end

-- label
local LX0, LX1, LY0, LY1 = 26, 38, 38, 46
local lab = c:rect(LX0, LY0, LX1, LY1)
G.toneN(c, lab, (function() local n = {} lab:each(function(x, y) local nx = G.clamp((x - 32) / 7, -.9, .9) n[K(x, y)] = { nx * .5, 0, sqrt(1 - nx * nx * .25) } end) return n end)(), PAP, { amb = .1, wrap = .3 })
for x = LX0, LX1 do c:px(x, LY0, PAP[6]) c:px(x, LY1, PAP[2]) end
for y = LY0 + 1, LY1 - 1 do c:px(LX0, y, PAP[6]) c:px(LX1, y, PAP[2]) end
c:px(LX1 - 1, LY1, PAP[1]) c:px(LX1, LY1 - 1, PAP[1]) c:px(LX1, LY1, PAP[1]) c:px(LX1 - 1, LY1 - 1, PAP[2])  -- curled corner
local function pberry(x, y)
  for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 } } do c:px(x + d[1], y + d[2], ORG[3]) end
  c:px(x - 1, y, ORG[4]) c:px(x + 1, y + 1, ORG[2]) c:px(x, y + 1, ORG[2])
  c:px(x - 1, y - 1, "#fff2cf")
end
pberry(30, 43) pberry(34, 41) pberry(35, 44)
c:px(31, 40, LF[3]) c:px(32, 40, LF[4]) c:px(33, 40, LF[2]) c:px(33, 41, BK[2])

-- specular streaks on the glass over everything
for y = 33, 46 do c:px(23, y, y == 33 and GL[5] or "#fffbee") end
for _, p in ipairs{ { 24, 31 }, { 25, 29 }, { 26, 28 } } do c:px(p[1], p[2], "#fffbee") end
c:px(23, 32, GL[5])

-- twine
for x = 27, 37 do
  c:px(x, 18, (x % 3 == 0) and GOLD[2] or GOLD[4])
  c:px(x, 19, (x % 3 == 1) and GOLD[2] or GOLD[3])
end
c:px(38, 19, GOLD[3]) c:px(38, 20, GOLD[2]) c:px(39, 21, GOLD[3]) c:px(39, 22, GOLD[1]) c:px(37, 20, GOLD[2])

-- cork
local cork = c:rect(29, 10, 35, 14)
local cn = {}
cork:each(function(x, y) local nx = G.clamp((x - 32) / 4, -.9, .9) cn[K(x, y)] = { nx, 0, sqrt(1 - nx * nx) } end)
G.toneN(c, cork, cn, CK, { amb = .1, wrap = .3 })
cork:each(function(x, y) local h = H(x, y, 6)
  if h > .88 then c:px(x, y, CK[2]) elseif h < .1 then c:px(x, y, CK[5]) end end)
for x = 29, 35 do c:px(x, 14, CK[1]) end
local ctop = c:ellipse(32, 9.5, 3.5, 1.6)
ctop:each(function(x, y) c:px(x, y, (x < 32) and CK[6] or CK[5]) end)
c:px(31, 9, CK[3]) c:px(33, 10, CK[3])
c:px(34, 14, CK[1])

-- sprig tucked under the twine (quirk): stem to the upper-left, two leaves, a berry
local sm, sn = G.tube({ { 29, 18 }, { 26, 15 }, { 23, 11 }, { 20, 8 } }, function(t) return .85 end)
G.toneN(c, sm, sn, BK, { amb = .12, wrap = .3, cuts = { .3, .55, .8 } })
local function lf(ax, ay, bx, by, w)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t) if t > .97 then return -1 end return max(.55, w * sin(pi * min(1, t + .05)) ^ .7) end)
  G.toneN(c, m, n, LF, { amb = .12, wrap = .25, cuts = { .2, .38, .55, .7, .86 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < .22 and T[k] > .1 and T[k] < .9 then c:px(x, y, S[k] <= 0 and LF[6] or LF[3]) end end)
end
lf(26, 15, 16, 16, 1.7)
lf(24, 12, 18, 4, 1.6)
local bm, bn = G.oval(20.5, 8.5, 2.7, 2.9, 0, 1)
G.toneN(c, bm, bn, ORG, { amb = .08, wrap = .28 })
c:px(19, 7, "#fff2cf") c:px(20, 7, ORG[6]) c:px(22, 10, "#c4505e")
G.save2(c, "sea-buckthorn-juice")

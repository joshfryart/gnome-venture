-- scotch-quail-eggs (Sonnet high, single pass). Slim dark slate slab; behind, one whole crumb-coated bite-size egg,
-- in front-left one halved to show crust ring, speckled sausage, white and a glossy yolk; a raw speckled quail egg
-- waits at the front corner.
-- Material: per-pixel lit crumb spheres with ragged edges + toasted/bright crumbs, planar-lit meat with fat flecks,
-- sphere-lit yolk with specular, slate bevel + specks + hairline crack, contact shadows where eggs meet slab/each other.
-- quirk: the raw speckled quail egg is sneaking in at the corner of the slab.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_4.lua")
local HP, X, K, H = G.HP, G.X, G.K, G.H
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = G.new2("scotch-quail-eggs")
local SL = { "#23253a", "#363955", "#4a4d6b", "#5f6283", "#7d80a2", "#a6a8c4" }
local CR = { "#5c3418", "#8a5420", "#b9792c", "#d99a3a", "#efbd58", "#ffe08c" }
local SA = { "#4e2420", "#7a3a30", "#a05342", "#c06c52", "#d98a68", "#efae88" }
local WH = { "#8c88a8", "#b0acc4", "#d6d2dc", "#f0ece4", "#fffaf0", "#fffbee" }
local YO = { "#a8441a", "#d06a1c", "#ee8e22", "#ffb030", "#ffd058", "#fff0a0" }
local QE = { "#7a6247", "#a58a64", "#cdb88c", "#e6d6aa", "#f4ead0", "#fff6e0" }

-- slab
local top = c:rrect(9, 40, 57, 50, 2)
G.toneN(c, top, X.pillow(top, 2.5), SL, { amb = .1, wrap = .3 })
top:each(function(x, y) local h = H(x, y, 3) if h > .94 then c:px(x, y, SL[5]) elseif h < .05 then c:px(x, y, SL[3]) end end)
for _, p in ipairs{ { 13, 47 }, { 14, 46 }, { 15, 46 }, { 16, 45 }, { 17, 45 } } do c:px(p[1], p[2], SL[2]) end
local front = c:rect(9, 50, 57, 53)
for x = 9, 57 do
  c:px(x, 50, SL[3]) c:px(x, 51, SL[2]) c:px(x, 52, SL[2]) c:px(x, 53, SL[1])
end
for x = 10, 22 do c:px(x, 51, SL[3]) end
-- contact shadows on slab
c:fillMask(c:ellipse(26.5, 45, 13, 2.6), SL[1])
c:fillMask(c:ellipse(46.5, 44, 10.5, 2.2), SL[1])
c:fillMask(c:ellipse(53, 47, 4.5, 1.5), SL[1])

-- crumb ball with ragged edge
local function crumbBall(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local ring = m:grow(1):cut(m)
  local add, rem = HP.mask(), HP.mask()
  ring:each(function(x, y) if H(x, y, seed) > .8 then add:set(x, y) end end)
  m:edge():each(function(x, y) if H(x, y, seed + 5) < .1 then rem:set(x, y) end end)
  m:add(add):cut(rem)
  local n = G.ellN(m, cx, cy, rx, ry)
  local idx = G.toneN(c, m, n, CR, { amb = .07, wrap = .28 })
  m:each(function(x, y)
    local k = K(x, y)
    local h = H(x, y, seed + 9)
    local i = idx[k] or 3
    if h > .86 then c:px(x, y, CR[min(6, i + 1)])
    elseif h < .1 then c:px(x, y, CR[max(1, i - 1)]) end
    if H(x, y, seed + 21) > .975 then c:px(x, y, "#fff0c0") end
  end)
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > .86 and y > cy - 2 then c:px(x, y, "#c9694a") end end)
  c:px(floor(cx - rx * .5), floor(cy - ry * .55), "#fff0c0") c:px(floor(cx - rx * .5) + 1, floor(cy - ry * .55), "#fff0c0")
  return m
end
-- whole egg at back right
local whole = crumbBall(44.5, 34.5, 9, 9.6, 11)
-- halved egg, front left
local ccx, ccy, R = 24.5, 33.5, 11.5
local disc = c:ellipse(ccx, ccy, R, R)
G.touch(c, disc, whole, CR[1]) G.touch(c, disc:copy():grow(1), whole, CR[2])
G.toneN(c, disc, G.ellN(disc, ccx, ccy, R, R, 1.2), CR, { amb = .07, wrap = .28 })
disc:each(function(x, y)
  local dx, dy = x - ccx, y - ccy
  local d = sqrt(dx * dx + dy * dy)
  local p = (dx + dy) / R
  local h = H(x, y, 31)
  if d <= 9.9 and d > 6.9 then
    local i = 4
    if p < -.35 then i = 5 elseif p > .7 then i = 2 elseif p > .4 then i = 3 end
    if d > 9.1 then i = max(1, i - 1) end
    if h > .86 then i = min(6, i + 1) elseif h < .1 then i = max(1, i - 1) end
    c:px(x, y, SA[i])
    if H(x, y, 33) > .955 then c:px(x, y, "#f4c4aa") end
  elseif d <= 6.9 and d > 4.2 then
    local i = 4
    if p < -.4 then i = 5 elseif p > .6 then i = 2 elseif p > .2 then i = 3 end
    if d > 6.1 then i = max(1, i - 1) end
    c:px(x, y, WH[i])
  end
end)
-- sausage/white boundary: thin warm line
for a = 0, 63 do
  local an = a / 64 * 2 * math.pi
  c:px(floor(ccx + .5 + math.cos(an) * 6.5 - .5), floor(ccy + .5 + math.sin(an) * 6.5 - .5), "#e8d4c0")
end
-- yolk
local yolk = c:ellipse(ccx, ccy, 4.2, 4.2)
G.toneN(c, yolk, X.sphere(ccx - .5, ccy - .5, 4.2, yolk), YO, { amb = .06, wrap = .25 })
c:px(ccx - 2, ccy - 2, YO[6]) c:px(ccx - 1, ccy - 2, YO[6]) c:px(ccx - 2, ccy - 1, "#fff6c8")
c:px(ccx + 2, ccy + 2, "#c8481c")

-- raw speckled quail egg
local qx, qy = 51, 43
local qm = G.eggM(qx, qy, 3.5, 4.6, .12)
G.touch(c, qm, whole, CR[1])
G.toneN(c, qm, G.ellN(qm, qx, qy, 3.5, 4.6), QE, { amb = .08, wrap = .25 })
for _, p in ipairs{ { 0, 1 }, { 1, 2 }, { -1, 2 }, { 1, -1 }, { 0, 3 }, { 2, 1 }, { -2, 0 }, { -1, 3 } } do c:px(qx + p[1], qy + p[2], "#6a4a2a") end
for _, p in ipairs{ { 2, 3 }, { -2, 2 }, { 0, -2 } } do c:px(qx + p[1], qy + p[2], "#8a6238") end
c:px(qx + 1, qy + 3, "#6a4a2a") c:px(qx - 1, qy + 1, "#8a6238")
c:px(qx - 2, qy - 3, QE[6])
c:px(qx + 2, qy + 3, QE[2])
G.save2(c, "scotch-quail-eggs")

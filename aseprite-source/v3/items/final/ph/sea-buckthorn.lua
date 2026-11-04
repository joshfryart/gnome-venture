-- sea-buckthorn (Sonnet high, single pass). A slim woody twig arching diagonally, bare at the cut base, then packed
-- with glossy orange berries in staggered pairs; narrow silvery-green lanceolate leaves with midribs; a thorn tip.
-- Material: berries are lit ellipsoids on a 6-tone orange ramp (waxy specks, one specular, cool-rose reflected light,
-- dark stigma dot, contact lines where they touch), bark 4-tone with a lit side and nodes, leaves 6-tone silver-green
-- with lit/shade midrib and dark base where they join the twig.
-- quirk: a tiny green caterpillar inches up the bare base of the twig.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_4.lua")
local HP, X, K, H = G.HP, G.X, G.K, G.H
local floor, abs, max, min, sqrt, pi, sin, cos = math.floor, math.abs, math.max, math.min, math.sqrt, math.pi, math.sin, math.cos
local c = G.new2("sea-buckthorn")
local ORG = { "#7a2a1c", "#b8441a", "#e8691f", "#f68e22", "#ffb43c", "#ffdc8a" }
local LF = { "#2f4a46", "#4b6a5f", "#6f8f7c", "#93b09b", "#b8cdb6", "#dde8d2" }
local BK = { "#3a2a2e", "#5a4238", "#85624a", "#b08a62" }
local CAT = { "#3f7a3c", "#5aa046", "#80c25a", "#b4e07c" }
local P = { { 18, 49 }, { 14, 35 }, { 31, 29 }, { 47, 14 } }
local sm = {}
local function at(t)
  local x, y = G.bez(P, t)
  local x2, y2 = G.bez(P, min(1, t + .01)) local x1, y1 = G.bez(P, max(0, t - .01))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  return x, y, tx, ty, px, py
end
-- leaves (behind everything)
local ltok = { r = { name = "leaf" } }
local function leaf(ax, ay, ux, uy, L, w)
  local bx, by = ax + ux * L, ay + uy * L
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > .97 then return -1 end
    return max(.55, w * sin(pi * min(1, t * 1.0 + .05)) ^ .7)
  end)
  G.toneN(c, m, n, LF, { amb = .12, wrap = .25, cuts = { .2, .38, .55, .7, .86 }, tok = ltok })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < .22 and t > .1 and t < .9 then c:px(x, y, s <= 0 and LF[6] or LF[3]) end
    if t < .12 then c:px(x, y, LF[1]) end
  end)
  return m
end
local function dirRot(ux, uy, a) return ux * cos(a) - uy * sin(a), ux * sin(a) + uy * cos(a) end
local LEAVES = { { .38, 1 }, { .52, -1 }, { .66, 1 }, { .8, -1 }, { .9, 1 } }
for _, d in ipairs(LEAVES) do
  local x, y, tx, ty = at(d[1])
  local ux, uy = dirRot(tx, ty, d[2] * 1.05)
  leaf(x, y, ux, uy, 13, 2.1)
end
do local x, y, tx, ty = at(1) local ux, uy = dirRot(tx, ty, -.35) leaf(x - tx, y - ty, ux, uy, 12, 1.9) end

-- twig
local tm, tn, TT, TS = G.tube(P, function(t) return t > .96 and .6 or (1.25 - .35 * t) end)
G.toneN(c, tm, tn, BK, { amb = .12, wrap = .3, cuts = { .3, .55, .8 } })
tm:each(function(x, y) if H(x, y, 5) > .93 then c:px(x, y, BK[1]) end end)
-- thorns: tip + two small side thorns
local tx0, ty0 = at(1)
c:px(floor(tx0 + .5) + 1, floor(ty0 + .5) - 1, BK[1]) c:px(floor(tx0 + .5) + 1, floor(ty0 + .5) - 2, BK[2])
for _, tt in ipairs{ .6, .76 } do
  local x, y, _, _, px, py = at(tt)
  local sx, sy = floor(x - px * 2.4 + .5), floor(y - py * 2.4 + .5)
  c:px(sx, sy, BK[3]) c:px(sx - 1, sy - 1, BK[2])
end
-- cut end
do local x, y = at(0) x, y = floor(x + .5), floor(y + .5) c:px(x, y + 1, BK[4]) c:px(x + 1, y + 1, BK[3]) end

-- berries (tip -> base so lower ones overlap)
local berries = {}
for i = 0, 12 do
  local t = .3 + i * .05
  local side = (i % 2 == 0) and -1 or 1
  local ok = true
  for _, d in ipairs(LEAVES) do if d[2] * -1 == side and abs(d[1] - t) < .045 then ok = true end
    if d[2] == side and abs(d[1] - t) < .05 then ok = false end end
  if ok then berries[#berries + 1] = { t, side } end
end
berries[#berries + 1] = { .955, -1 }
table.sort(berries, function(a, b) return a[1] > b[1] end)
local union = HP.mask()
for i, b in ipairs(berries) do
  local x, y, tx, ty, px, py = at(min(b[1], 1))
  local r = 2.7 + H(i, 7, 2) * .5
  local off = 3.9
  local cx, cy = x + px * b[2] * off + tx * (H(i, 3, 9) - .5), y + py * b[2] * off + ty * (H(i, 3, 9) - .5)
  cx, cy = floor(cx + .5) + .5, floor(cy + .5) + .5
  local m, n = G.oval(cx, cy, r + .1, r + .35, math.atan(ty, tx) + pi / 2 + .0, 1.0)
  G.touch(c, m, union, ORG[1])
  local idx = G.toneN(c, m, n, ORG, { amb = .08, wrap = .28 })
  m:each(function(xx, yy) local h = H(xx, yy, 20 + i)
    local ii = idx[K(xx, yy)] or 3
    if h > .88 and ii >= 4 then c:px(xx, yy, ORG[min(6, ii + 1)]) end end)
  local rim = X.rim(n)
  m:edge():each(function(xx, yy) if rim[K(xx, yy)] > .88 and yy >= cy then c:px(xx, yy, "#c4505e") end end)
  local sx, sy = floor(cx - r * .45), floor(cy - r * .5)
  c:px(sx, sy, "#fff2cf") c:px(sx + 1, sy, ORG[6])
  c:px(floor(cx + px * b[2] * (r - .8) + .5), floor(cy + py * b[2] * (r - .8) + .5), "#5c2a20")
  union:add(m)
end

-- caterpillar (quirk) on the bare base
local function seg(t, r, k)
  local x, y = at(t)
  local cx, cy = floor(x - 2.6 + .5) + .5, floor(y - 1.2 + .5) + .5
  local m = c:ellipse(cx, cy, r, r)
  G.toneN(c, m, X.sphere(cx - .3, cy - .3, r, m), CAT, { amb = .1, wrap = .3 })
  return cx, cy
end
seg(.04, 1.1) seg(.105, 1.2) seg(.17, 1.2)
local hx, hy = seg(.235, 1.6)
c:px(hx + 1, hy - 1, "#2b1c26") c:px(hx - 1, hy - 3, "#2b1c26") c:px(hx + 1, hy - 3, "#2b1c26")
c:px(hx - 2, hy + 1, CAT[1]) c:px(hx + 1, hy + 1, CAT[2])
G.save2(c, "sea-buckthorn")

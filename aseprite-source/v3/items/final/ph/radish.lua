-- radish (final, Sonnet high). A slim French-breakfast radish standing upright: crimson-pink shoulder fading to a white
-- tapered tail with a fine wiry root tip and root hairs; three scalloped, bristly radish leaves on pink stalks fan up from a
-- sunken crown. Per-pixel cylinder light (6-tone red, 6-tone cool-violet white), waxy specular streak + glint, cool bounce,
-- fine skin creases near the crown, AO where stalks meet.
-- quirk: a pale earthworm is peeking out of a bored hole in the left shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("radish")
local RD = { "#5a1a40", "#9c2150", "#d03360", "#ee4f77", "#ff7fa0", "#ffb8ca" }
local WH = { "#5c587c", "#8884a8", "#b8b4d0", "#dedaea", "#f4f0f6", "#fffaf0" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local ST = { "#7c1d4c", "#b2325f", "#e2567f", "#ff96b2" }
local ltok = { r = { name = "leaf" } }

local function leaf(ax, ay, cx, cy, bx, by, W, per, ph0)
  local lm, ln, LT, LS, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.95 + 0.05)
    return max(0.5, W * sin(pi * u ^ 0.9) ^ 0.7)
  end, { fold = 0.4 })
  local cut = {}
  lm:each(function(x, y) local k = K(x, y)
    local t, s = LT[k], LS[k]
    local ph = t * len / per + (s > 0 and 0.5 or 0) + ph0
    local f = abs((ph - floor(ph)) - 0.5) * 2
    local lim = 0.97 - (1 - f) ^ 2.4 * (0.5 + 0.2 * t)
    if t > 0.1 and t < 0.95 and abs(s) > lim then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
  G.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
    if abs(s) < 0.15 and t > 0.02 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
    local ph = (t * len - abs(s) * 3.6) / per + (s > 0 and 0.5 or 0) + ph0
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  lm:edge():each(function(x, y) local k = K(x, y)
    if LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, "#3c7a74", ltok) end end)
  return lm
end
local function petiole(pts)
  local m, n = G.tube(pts, function(t) return 1.05 end)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), ST, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "stalk" } } })
  return m
end
local CX, CY = 33, 27
-- stalks then blades
local pL = A.path(CX - 1, CY, 24, 21, 0.8)
local pC = A.path(CX, CY, 34, 17, -0.6)
local pR = A.path(CX + 1, CY, 43, 21, -0.8)
petiole(pL) petiole(pC) petiole(pR)
leaf(24, 22, 17, 19, 11, 10, 4.5, 6.2, 0.25)
leaf(34, 18, 37, 12, 34, 5.5, 5.0, 6.0, 0.4)
leaf(43, 22, 50, 19, 55, 10, 4.5, 6.2, 0.55)

-- ===== root
local RP = { { 33, CY + 1 }, { 35, 37 }, { 31, 45.5 }, { 29.5, 55 } }
local rm, rn, RT, RS, samp = G.tube(RP, function(t)
  if t < 0.12 then return 4.4 + (t / 0.12) * 2.3 end
  return 6.7 * ((1 - t) / 0.88) ^ 0.78 + 0.45
end)
local v = X.light(rn, { amb = 0.07, wrap = 0.22 })
local rtok = { r = { name = "root" } }
local idx = X.tone(c, rm, v, RD, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 }, tok = rtok })
local function isWhite(x, y, k) return RT[k] > 0.6 + 0.06 * RS[k] + 0.035 * (X.hash(x, 0, 2) - 0.5) end
rm:each(function(x, y) local k = K(x, y)
  local tb = 0.6 + 0.06 * RS[k] + 0.035 * (X.hash(x, 0, 2) - 0.5)
  local i = idx[k]
  if RT[k] > tb then c:put(x, y, WH[i], rtok)
  elseif RT[k] > tb - 0.045 then c:put(x, y, RD[min(6, i + 1)], rtok) end
end)
-- crown AO + sunken ring
local crown = G.rell(CX, CY + 1.3, 1, 0, 5.3, 1.9)
crown:each(function(x, y) if rm:has(x, y) then c:put(x, y, (x < CX - 2) and RD[2] or RD[1], rtok) end end)
for _, q in ipairs{ { CX - 1, CY }, { CX, CY }, { CX + 1, CY } } do c:put(q[1], q[2], ST[1], rtok) end
-- skin creases near the crown: short dark dashes
for _, q in ipairs{ { 0.17, 0.2, 2 }, { 0.22, -0.4, 2 }, { 0.3, 0.45, 2 }, { 0.36, -0.2, 1 } } do
  local s = samp[floor(q[1] * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5)
  for d = 0, q[3] - 1 do if rm:has(x + d, y) then c:put(x + d, y, RD[max(1, (idx[K(x + d, y)] or 3) - 2)], rtok) end end
end
-- cool bounce on the lower-right edge
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and RS[k] > 0.7 and RT[k] > 0.14 and RT[k] < 0.9 then c:put(x, y, isWhite(x, y, k) and "#a9a2d8" or "#b0448c", rtok) end end)
-- waxy specular streak + glint on the lit shoulder
for _, q in ipairs{ { 0.17, -0.5 }, { 0.2, -0.52 }, { 0.23, -0.5 }, { 0.27, -0.46 }, { 0.31, -0.42 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), RD[6], rtok)
end
do local s = samp[floor(0.2 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.52 + .5), floor(s.y + s.py * s.w * -0.52 + .5), "#fffaf0", rtok) end
-- white-flesh sheen on the tail
for _, q in ipairs{ { 0.7, -0.45 }, { 0.74, -0.42 }, { 0.78, -0.38 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), "#ffffff" == nil and "" or WH[6], rtok)
end
-- wiry root tip hairs
for _, q in ipairs{ { 28, 49 }, { 27, 50 }, { 26, 50 }, { 33, 45 }, { 34, 46 }, { 29, 56 }, { 30, 57 } } do
  if not rm:has(q[1], q[2]) then c:put(q[1], q[2], WH[3], rtok) end
end

-- ===== quirk: earthworm out of a bored hole in the left shoulder
local hole = c:ellipse(28, 35, 1.3, 1.0)
hole:each(function(x, y) if rm:has(x, y) then c:put(x, y, RD[1], rtok) end end)
local wm = c:line({ { 27, 35 }, { 25, 35 }, { 23, 34 }, { 21, 32 }, { 20, 30 }, { 21, 28 } }, 2)
local wn = X.pillow(wm, 1.2)
local widx = X.tone(c, wm, X.light(wn, { amb = 0.1, wrap = 0.3 }), { "#7a3f4c", "#a8606a", "#d08a82", "#f0b8a8" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "worm" } } })
local bx0, by0, bx1, by1 = wm:bbox()
local w = 0
for _, q in ipairs{ { 25, 35 }, { 22, 33 }, { 20, 31 } } do
  for dy = -1, 1 do if wm:has(q[1], q[2] + dy) then c:put(q[1], q[2] + dy, "#8f5058") end end
end
c:put(21, 28, "#2b1c26")
-- the hole's dark rim over the worm base
c:put(28, 35, RD[1]) c:put(29, 35, RD[1])

A.save(c, "radish")

-- champak-seed (final, Opus aB1r1_3). A split woody champak capsule (bark brown, pale lenticels, bevelled lip,
-- dark cavity) cradling two glossy scarlet arils, on a diagonal torn scrap of glossy lanceolate champak leaf
-- (midrib, fine swept veins, specular streak, pale torn tissue, cool margin). A loose scarlet seed has germinated:
-- a slim stem with two long, pointed lanceolate leaves (the champak leaf shape).
-- quirk: one curled saffron champak petal has drifted onto the leaf.
local NAME = "champak-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)
local LEAF = { "#123a30", "#1c5038", "#296a3e", "#3c8844", "#5ea84e", "#94cc68" }
local RED = { "#5a1828", "#8c2230", "#c03a2e", "#e2582f", "#f68a4c", "#ffc08a" }
local WOOD = { "#3a2220", "#5a3426", "#7e4c30", "#a26a40", "#c48c58", "#e2b47e" }
local STEM = { "#3a6e44", "#5f9a52", "#8fc46a", "#c4e49a" }
local SAF = { "#a2481e", "#d8741e", "#f5a02e", "#ffd070" }

-- capsule (outer shell) + cavity
local cap, capn = A.oval(19, 47, 7.5, 4.6, -0.35, 0.8)
local cav = A.oval(18, 45.6, 5.2, 2.6, -0.35, 1)
local a1, a1n = A.oval(16, 45.4, 2.3, 1.9, 0, 0.8)
local a2, a2n = A.oval(21, 44.2, 2.3, 1.9, 0, 0.8)
local loose, loosen = A.oval(37, 43, 2.8, 2.2, -0.4, 0.8)
local sp = { { 37, 41 }, { 35, 34 }, { 31, 27 }, { 33, 19 } }
local sm, sn = A.tube(sp, function(t) return 1.0 + 0.2 * (1 - t) end)
local pet = HP.mask()
for _, q in ipairs{ { 46, 36 }, { 47, 36 }, { 48, 36 }, { 45, 37 }, { 46, 37 }, { 47, 37 }, { 48, 37 }, { 49, 37 }, { 49, 36 }, { 50, 35 }, { 45, 38 } } do pet:set(q[1], q[2]) end

A.scrap(c, { 6, 57, 26, 52, 59, 29 }, { w = 8.6, tear = 0.8, ramp = LEAF, vein = "#b6dc86", cool = "#346a74",
  torn = "#c4dc92", casters = { cap, loose, sm, pet }, veinPer = 4.2, sweep = 6, glossy = true,
  shape = function(t) return sin(pi * min(1, t * 0.75 + 0.18)) ^ 0.7 end })

-- quirk petal (curled: lit outer curl, shaded inner)
local ptok = A.tok("petal")
pet:each(function(x, y)
  local i = (y == 36 and 3) or (y == 37 and (x < 47 and 2 or 3)) or 1
  if x == 50 or y == 35 then i = 4 end
  c:put(x, y, SAF[i], ptok)
end)
c:put(47, 36, SAF[4], ptok)

-- stem
local stok = A.tok("stem")
sm:cut(loose)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- lanceolate leaves (long, pointed, glossy)
local function lance(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.8)
  end, { fold = 0.4 })
  m:cut(sm)
  local tok = A.tok("lance")
  A.shade(c, m, n, LEAF, { tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.06 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[2], tok) end
    if S[k] < -0.35 and S[k] > -0.6 and T[k] > 0.3 and T[k] < 0.5 then c:put(x, y, "#c8eb98", tok) end
  end)
  return m
end
lance(32, 22, 25, 15, 14, 14, 2.9)
lance(34, 24, 43, 21, 53, 15, 3.1)
for i = 0, 8 do local x, y = A.bez(sp, 1 - i / 40) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
c:put(33, 18, STEM[4], stok)

-- capsule shell: wood ramp, lenticels, bevelled lip, dark cavity with AO
local wtok = A.tok("capsule")
local widx = A.shade(c, cap, capn, WOOD, { tok = wtok, amb = 0.1, wrap = 0.25 })
cav:each(function(x, y)
  -- cavity: dark, lighter toward the lower-right inner wall (concave)
  local dx, dy = x - 18, y - 45.6
  local i = (dx + dy > 2) and 3 or 2
  if dx + dy < -3 then i = 1 end
  c:put(x, y, WOOD[i], wtok)
end)
-- lip: bright bevel on the lower rim of the cavity
cav:grow(1):cut(cav):each(function(x, y)
  if cap:has(x, y) and y > 45.6 - (x - 18) * 0.36 then c:put(x, y, WOOD[6], wtok) end end)
-- lenticels and grain dashes on the outer shell
for _, q in ipairs{ { 14, 50 }, { 19, 51 }, { 23, 49 }, { 25, 46 }, { 12, 48 } } do
  if cap:has(q[1], q[2]) and not cav:has(q[1], q[2]) then c:put(q[1], q[2], WOOD[5], wtok) c:put(q[1] + 1, q[2], WOOD[2], wtok) end
end
-- arils
local function aril(m, n, name, cx, cy)
  local tok = A.tok(name)
  A.shade(c, m, n, RED, { tok = tok, amb = 0.12, wrap = 0.3 })
  c:put(cx - 1, cy - 1, RED[6], tok)
  c:put(cx + 1, cy + 1, RED[2], tok)
end
aril(a1, a1n, "aril1", 16, 45)
a2:cut(a1)
aril(a2, a2n, "aril2", 21, 44)
-- loose sprouting seed
local ltok = A.tok("seed")
A.shade(c, loose, loosen, RED, { tok = ltok, amb = 0.12, wrap = 0.3 })
c:put(36, 42, RED[6], ltok) c:put(35, 42, "#ffe4c0", ltok)
c:put(38, 44, RED[2], ltok) c:put(39, 44, "#7a4a66", ltok) -- cool reflected light

A.save(c, NAME)

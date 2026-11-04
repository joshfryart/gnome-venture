-- pickled-kohlrabi (C34, Opus single pass). Barrel jar with a red-gingham cloth cap gathered over the mouth and tied
-- with a twisted twine band and bow; inside, a whole small purple kohlrabi bulb (stem stubs) and three half-moon slices
-- (purple skin edge, pale lime flesh with a faint ring) in clear pale brine.
-- Material: lathe glass with band highlights; cloth pillow-lit and checked (red / pink / cream sharing one light
-- ramp), fold lines in the skirt and a scalloped hem; twine with a diagonal twist; waxy bloom + spec on the bulb.
-- quirk: a kohlrabi leaf stalk has pushed straight up through the cloth.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local c = A.new("pickled-kohlrabi")

local PUR = { "#2a1640", "#4a2266", "#6c368e", "#9050b2", "#b682d0", "#dcb8ec" }
local FL = { "#5c7e44", "#93b46a", "#c2da94", "#dcecb8", "#eef6d8", "#fafdf0" }
local BRINE = { "#4f8296", "#8cbcb6", "#b8dccc", "#d4ecdc", "#e8f6ea", "#f6fcf4" }
local RED = { "#5a1428", "#962033", "#cc3036", "#ea5442", "#ff8a66", "#ffb894" }
local PNK = { "#8a4a5c", "#c06e78", "#e8988e", "#f6b8a8", "#ffd4c4", "#ffe8dc" }
local CRM = { "#9a8296", "#c8b8bc", "#e8dcd4", "#f6eee2", "#fff6ea", "#fffcf4" }
local TW = { "#6a4a2a", "#a87a44", "#d8b070", "#f2d8a0" }
local STEM = { "#2a5a3e", "#4e8e4c", "#82bc5e", "#b8dc84" }

c:groundShadow(32, 54, 14, 2)

-- barrel jar
local function hw(y)
  if y < 22 then return nil end
  if y <= 24 then return 9.5 end
  if y <= 28 then return 9.5 + (y - 24) * .8 end
  local t = (y - 28) / 24
  return 12.7 + sin(t * math.pi) * 1.3 - (y > 50 and (y - 50) * .9 or 0)
end
local J = A.jar(c, 32, 22, 53, hw, 30, BRINE)

local occ = HP.mask()
-- half-moon slices (back), flat face toward us with a 1px cut side
local function slice(cx, cy, r, ang, flip)
  local ux, uy = math.cos(ang), math.sin(ang)
  local m = HP.mask()
  for y = floor(cy - r - 1), floor(cy + r + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local a = dx * ux + dy * uy
    local b = -dx * uy + dy * ux
    if a * a + (b * 1.1) ^ 2 <= r * r and b * (flip or 1) <= .3 then m:set(x, y) end
  end end
  m:clip(J.inner)
  local n = X.pillow(m, 1.2, .5)
  local idx = A.piece(c, m, n, FL, occ, { amb = .2, wrap = .35 })
  -- skin band on the curved edge, ring inside
  m:each(function(x, y)
    local dx, dy = x + .5 - cx, y + .5 - cy
    local d = sqrt((dx * ux + dy * uy) ^ 2 + ((-dx * uy + dy * ux) * 1.1) ^ 2) / r
    local lit = (dx + dy) < 0
    if d > .8 then c:put(x, y, lit and PUR[4] or PUR[3])
    elseif d > .55 and d < .65 then c:put(x, y, FL[3]) end
  end)
  return m
end
slice(25.5, 45.5, 6, -.3, 1)
slice(39.5, 46.5, 6, .4, 1)
slice(35.5, 37.5, 5.5, 2.6, 1)

-- whole bulb with stem stubs (front, lower-left)
local bm = c:ellipse(28, 40, 7, 6.5)
for _, s in ipairs{ { 24, 33, 22, 29 }, { 28, 33, 29, 28 }, { 32, 34, 35, 30 } } do
  A.ln(c, s[1], s[2], s[3], s[4], STEM[2], J.inner) A.ln(c, s[1] + 1, s[2], s[3] + 1, s[4], STEM[3], J.inner)
  c:put(s[3], s[4], STEM[4])
end
local bn = X.sphere(27.5, 39.5, 7, bm)
bm:clip(J.inner)
local bi = A.piece(c, bm, bn, PUR, occ, { amb = .1, wrap = .25 })
-- waxy bloom: pale lilac haze on the lit upper half, stem scars, root tip
bm:each(function(x, y) if bi[K(x, y)] and bi[K(x, y)] == 4 and X.hash(x, y, 3) > .55 then c:put(x, y, PUR[5]) end end)
c:put(25, 37, A.SPEC) c:put(26, 37, PUR[6]) c:put(25, 38, PUR[6])
c:put(31, 37, PUR[2]) c:put(31, 38, PUR[3]) c:put(23, 42, PUR[2]) c:put(23, 43, PUR[3])
c:put(28, 46, PUR[1]) c:put(28, 47, PUR[2])
-- cool reflected light lower-right
bm:edge():each(function(x, y) if x > 30 and y > 41 then c:put(x, y, "#7a7ab8") end end)
-- peppercorns
for _, p in ipairs{ { 36, 49 }, { 21, 48 }, { 41, 41 } } do c:put(p[1], p[2], "#4a2a2a") c:put(p[1] + 1, p[2], "#2e1a24") c:put(p[1], p[2] - 1, "#8a5a4a") end

A.glass(c, J.body, J.inner, J.n, J.NX, { ys = 25 })
for x = 22, 42 do if J.body:has(x, 52) then c:put(x, 52, x < 30 and A.GLASS[5] or A.GLASS[3]) end end

-- quirk stalk (behind the cloth) up through the top
A.ln(c, 33, 13, 34, 9, STEM[3]) A.ln(c, 34, 13, 35, 10, STEM[2])
local lf = A.leaf(c, 35, 9, 1, -.45, 7, 2.2, A.LEAF, { R = 1.4 })
c:put(37, 8, A.LEAF[6])

-- cloth cap: gathered dome over the mouth + scalloped skirt over the shoulder
local cloth = HP.mask()
for y = 11, 31 do
  local w
  if y <= 18 then w = 6 + (y - 11) * 1.0 elseif y <= 22 then w = 13 elseif y <= 24 then w = 10.5
  else w = 11 + (y - 24) * .55 end
  local bot = 29 + ((y > 28) and 0 or 0)
  for x = floor(32 - w), floor(32 + w - 1) do
    -- scalloped hem: points every 4 px
    local hem = 29 + ((x % 4 == 1 or x % 4 == 2) and 2 or 0)
    if y <= hem then cloth:set(x, y) end
  end
end
local cn = X.pillow(cloth, 3, 1)
-- fold ridges in the skirt and pleats on the dome
for k, v in pairs(cn) do local x, y = k % 1024 - 256, k // 1024 - 256
  local f = sin((x - 32) * 1.1)
  if y >= 25 then cn[k] = { A.norm(v[1] + f * .45, v[2], v[3]) }
  elseif y <= 20 then cn[k] = { A.norm(v[1] + f * .25, v[2], v[3]) } end
end
local v = X.light(cn, { amb = .1, wrap = .3 })
local ci = X.tone(c, cloth, v, RED, { cuts = A.CUT6 })
cloth:each(function(x, y) local k = K(x, y) local i = ci[k] or 3
  local a, b = floor((x - 1) / 3) % 2, floor((y - 1) / 3) % 2
  local R = (a == 0 and b == 0) and RED or ((a == 1 and b == 1) and CRM or PNK)
  c:put(x, y, R[i])
end)
-- gather shadow under the band
for x = 18, 46 do if cloth:has(x, 25) then c:put(x, 25, RED[1]) end if cloth:has(x, 26) and x > 32 then c:put(x, 26, RED[2]) end end
-- twine band with twist
for x = 20, 44 do
  if cloth:has(x, 23) then c:put(x, 23, ((x) % 3 == 0) and TW[2] or (x < 30 and TW[4] or TW[3])) end
  if cloth:has(x, 24) then c:put(x, 24, ((x + 1) % 3 == 0) and TW[1] or TW[2]) end
end
-- bow on the right with hanging tails
for _, p in ipairs{ { 43, 22, TW[3] }, { 44, 21, TW[3] }, { 45, 22, TW[2] }, { 44, 23, TW[2] }, { 45, 24, TW[1] },
  { 42, 22, TW[4] }, { 43, 25, TW[2] }, { 43, 26, TW[3] }, { 44, 27, TW[2] }, { 46, 25, TW[2] }, { 46, 26, TW[1] }, { 47, 27, TW[2] } } do
  c:put(p[1], p[2], p[3])
end
c:put(25, 13, CRM[6])

A.fin(c, "pickled-kohlrabi")

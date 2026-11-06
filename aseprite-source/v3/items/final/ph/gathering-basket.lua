-- gathering-basket (final, Opus single pass). A slim, tapered wicker basket with a tall thin twisted handle. Body:
-- vertical stakes with over-under weavers (each weaver lit on top, dark where it dives under a stake), cylinder
-- light, a twisted rope rim, a darker foot band, dark inner mouth and AO under the rim. Gathered goods peek out:
-- a red spotted mushroom, two glossy blackberries and a veined leaf. Ground shadow (it stands).
-- quirk: one loose wicker strand has sprung out of the side and curls into the air.
local NAME = "gathering-basket"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local WICK = { "#4a2a22", "#74432c", "#9c6538", "#c28a4c", "#deb06a", "#f4d696" }
local STAKE = { "#3c2220", "#5e3828", "#7e5232", "#a2703e" }
local RED  = { "#5c1a30", "#8e2236", "#c23638", "#e2563e", "#f6825a", "#ffb48a" }
local CAPSPOT = "#fff1d8"
local MSTEM = { "#8a7a72", "#bcaea0", "#e2d6c2", "#f6eedc" }
local BERRY = { "#1e1430", "#34224e", "#4e3270", "#6e4c92", "#9c78bc", "#d2b8ea" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }

local CX, RY0 = 32, 30          -- rim centre y
c:groundShadow(CX, 51, 17, 2)

-- handle: thin twisted arch, ends tucked behind the rim
local htok = { r = { name = "handle" } }
local hm, hn, HT, HS, hidx = A.stem(c, { {17, 31}, {16, 6}, {48, 6}, {47, 31} }, function(t) return 1.45 end, WICK, { tok = htok, amb = 0.12 })
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  local ph = (t * 62 + s * 1.6) % 3
  if ph < 0.9 then c:put(x, y, WICK[max(1, (hidx[k] or 3) - 2)], htok) end
end)

-- inner mouth (dark), seen above the front rim
local mouth = c:ellipse(CX, RY0, 15, 3)
c:fillMask(mouth, WICK[1])
mouth:each(function(x, y) if y <= RY0 - 2 then c:px(x, y, WICK[2]) end end)

-- rim: twisted rope ring; back half behind the goods, front half over them
local rimO, rimI = c:ellipse(CX, RY0, 17.5, 4.2), c:ellipse(CX, RY0, 15.2, 2.6)
local rim = rimO:copy():cut(rimI):clip(c:rect(0, RY0 - 1, 63, 63))
local rimBack = rimO:copy():cut(rimI):clip(c:rect(0, 0, 63, RY0 - 2))
local rtok = { r = { name = "rim" } }
local function paintRim(part)
  part:each(function(x, y)
    local ph = (x - 2 * (y - RY0)) % 4
    local i = (ph == 0) and 2 or ((ph == 1) and 5 or 4)
    if y > RY0 + 2 then i = i - 1 end
    if x > CX + 10 then i = i - 1 end
    if y < RY0 - 2 then i = i - 1 end
    c:put(x, y, WICK[max(1, min(6, i))], rtok)
  end)
end
paintRim(rimBack)

-- contents --------------------------------------------------------------
-- leaf tucked at the back left
A.leaf(c, 24, 30, 20, 23, 14, 20, 3.0, LEAF, { fold = 0.45, vs = 2.6 })
-- mushroom: stem + domed red cap with cream spots
local mtok = { r = { name = "mush" } }
local ms = c:rect(34, 23, 36, 30)
local _, msn = X.cyl(35, 23, 35, 30, function() return 1.6 end, ms:copy())
A.shade(c, ms, msn, MSTEM, { cuts = { 0.3, 0.55, 0.8 }, tok = mtok })
local cap = c:ellipse(35, 22, 6.5, 4):clip(c:rect(20, 10, 50, 22))
cap:add(c:rect(29, 22, 41, 23))
local capn = A.body(cap, 34, 22, 6.5, 3, 0.7)
local cidx = A.shade(c, cap, capn, RED, { tok = mtok, amb = 0.08 })
for _, p in ipairs{ {32, 19}, {33, 19}, {37, 18}, {39, 21}, {35, 21}, {30, 21} } do c:px(p[1], p[2], CAPSPOT) end
c:px(38, 18, "#d8c6b0") c:px(36, 21, "#d8c6b0")
for x = 29, 41 do c:px(x, 23, RED[1]) end                -- gill shadow row under the cap
c:px(31, 18, RED[6]) c:px(32, 18, RED[6])
-- blackberries (drupelet bumps)
local function berry(bx, by)
  local m = c:ellipse(bx, by, 3, 3.2)
  local n = X.sphere(bx, by, 3.2, m)
  local tok = { r = { name = "berry" .. bx } }
  local idx = A.shade(c, m, n, BERRY, { tok = tok, amb = 0.08 })
  m:each(function(x, y) if (x + y * 2) % 3 == 0 then A.step(c, idx, BERRY, x, y, -1, tok) end end)
  c:px(bx - 1, by - 2, BERRY[6]) c:px(bx - 2, by - 1, BERRY[5])
  return m
end
berry(27, 27)
berry(43, 27)

-- body -----------------------------------------------------------------
local Y0, Y1 = RY0, 50
local function hw(y) local t = (y - Y0) / (Y1 - Y0) return 16.5 - 3.6 * t end
local body = HP.mask()
for y = Y0 + 1, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
-- rounded bottom corners
body:cut(c:rect(CX - 14, Y1, CX - 13, Y1)):cut(c:rect(CX + 12, Y1, CX + 13, Y1))
local bn = {}   -- cylinder across x (round body)
body:each(function(x, y) local h = hw(y) local s = max(-0.96, min(0.96, (x - CX + 0.5) / (h + 0.6)))
  bn[K(x, y)] = { s, 0.12, sqrt(1 - s * s) } end)
local bias = {}
for x = CX - 17, CX + 17 do bias[K(x, Y0 + 1)] = -2 bias[K(x, Y0 + 2)] = -1 end   -- AO under the rim
local btok = { r = { name = "body" } }
local bv = X.light(bn, { amb = 0.1, wrap = 0.3 })
local bidx = X.tone(c, body, bv, WICK, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, bias = bias, tok = btok })
-- weave: stakes every 4 px (follow the taper), weavers 3 rows tall, over-under
body:each(function(x, y) local k = K(x, y)
  if y >= Y1 - 2 then return end
  local h = hw(y)
  local q = (x - CX + 0.5) / h * 4.2            -- stake coordinate (narrows with the taper)
  local qi = floor(q + 0.5)
  local onStake = abs(q - qi) < 0.14
  local r = floor((y - Y0 - 1) / 3)
  local ry = (y - Y0 - 1) % 3
  local i = bidx[k]
  local over = (qi + r) % 2 == 0                 -- weaver passes over this stake
  if onStake and not over then
    c:put(x, y, STAKE[max(1, min(4, i - 2))], btok)      -- stake shows, weaver dives under
  else
    local d = (ry == 0) and 1 or ((ry == 2) and -1 or 0)
    local cell = q - floor(q)
    if not over and (abs(q - qi) < 0.4) then d = d - 1 end -- weaver near a stake it goes under: in shadow
    c:put(x, y, WICK[max(1, min(6, i + d))], btok)
  end
end)
-- foot band: two dark rows of rope
for y = Y1 - 1, Y1 do
  body:each(function(x, yy) if yy == y then local i = bidx[K(x, y)] or 3
    c:put(x, y, ((x + y) % 3 == 0) and STAKE[1] or STAKE[max(1, min(4, i - 2))], btok) end end)
end
-- cool reflected light on the right edge
body:edge():each(function(x, y) if x > CX + 8 and y > Y0 + 4 and y < Y1 - 2 then c:px(x, y, "#8a6a7a") end end)

paintRim(rim)

-- quirk: loose sprung strand on the right, curling up
local qm = A.stem(c, { {46, 38}, {52, 38}, {55, 33}, {51, 31} }, function(t) return 0.75 end, { WICK[2], WICK[4], WICK[5], WICK[6] }, { cut = body, cuts = { 0.3, 0.55, 0.8 } })
c:px(51, 31, WICK[5])

-- one specular on the rim + a sparkle on the berry
c:px(20, 29, WICK[6]) c:px(21, 29, WICK[6])
c:px(26, 25, "#fff4d6")

A.save(c, NAME)

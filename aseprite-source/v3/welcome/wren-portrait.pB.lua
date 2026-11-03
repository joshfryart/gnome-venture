-- wren-portrait PASS B (substantial polish over pass A). Hearth Pop v3, 72x72 portrait, bleeds off the bottom.
-- Wren Thimblewick: small round brown wren, head turned 3/4 left, long slim pointed amber beak breaking the
-- silhouette, pale eyebrow stripe + dark eye stripe (wren tells), cocked barred tail, barred folded wing,
-- leather satchel strap with a brass buckle.
-- B: beak re-cut column by column as a tapering cone (lit culmen, nostril, ink gape that stops short, pale gape corner,
-- lower mandible in shade); head/body light re-tuned (no muddy right half), reflected rim + AO under the chin;
-- smaller throat patch; crown streaks as short dashes; feather scallops on the breast; tail re-cut with a round
-- tip and bars that wrap; thimble re-lit as polished steel (2 px specular streak, dark side, reflected edge,
-- regular dimple rows, bright rolled rim) and seated lower on the crown; cat-ear crest tuft removed.
-- quirk: a dimpled steel sewing thimble worn as a hat, tipped a little to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "wren-portrait.pB"
local c = HP.canvas{ w = 72, h = 72, scale = 1, name = NAME }
local D4 = { {1,0},{-1,0},{0,1},{0,-1} }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(list, hex) for _, p in ipairs(list) do keep(p[1], p[2], hex) end end
local function tok(n) return { r = { name = n } } end
local function idxOf(ramp, hex) for i, h in ipairs(ramp) do if h:lower() == hex then return i end end end
local function darken(mask, ramp, n) mask:each(function(x, y) local i = idxOf(ramp, c:get(x, y) or "") if i then keep(x, y, ramp[math.max(1, i - n)]) end end) end

local FUR   = { "#4a2a26", "#6e3c2c", "#8f5434", "#b06e3e", "#cc8a50", "#e6ad72" }
local BUFF  = { "#b5814f", "#d4a46c", "#ebc58e", "#f7deb0" }
local BEAK  = { hi = "#ffd88a", base = "#eda640", shade = "#c46f2c", deep = "#7a3a24" }
local STEEL = { "#3f4260", "#5f6382", "#8a8ca6", "#b4b5c8", "#d8d8e4", "#f6f4fa" }
local LEATH = { "#4f2a24", "#7a4030", "#a05e3a", "#c4844e" }
local WINGR = { "#3e2422", "#5e3428", "#7d4a30", "#a5683c" }

---------------------------------------------------------------- tail (behind): cocked up and right, round tip, barred
local tail = c:poly{ {49,58},{52,42},{56,28},{59,19},{61,16},{64,15},{66,17},{66,22},{63,36},{60,50},{57,62} }
tail:add(c:ellipse(63, 17, 2.5, 2.5))
do
  local _, n = X.cyl(55, 60, 63, 16, function() return 4.5 end, tail)
  for k, v in pairs(X.pillow(tail, 2)) do if not n[k] then n[k] = v end end
  local v = X.light(n, { amb = 0.3, wrap = 0.35 })
  X.tone(c, tail, v, FUR, { tok = tok("tail"), cuts = { 0.16, 0.32, 0.5, 0.68, 0.88 } })
  for i = 0, 10 do
    local y = 21 + i * 4
    local bar = c:line({ {50, y + 4}, {70, y - 2} }, 1):clip(tail)
    darken(bar, FUR, 2)
    darken(bar:shift(0, 1):clip(tail):cut(bar), FUR, 0)
  end
end

---------------------------------------------------------------- body
local body = c:ellipse(37, 72, 24, 21)
local head = c:ellipse(34, 38, 17, 15)
do
  local n = X.sphere(33, 66, 25, body)
  local bias = {}
  X.ao(bias, body, head, 2, -1)
  X.tone(c, body, X.light(n, { amb = 0.3, wrap = 0.45 }), FUR, { tok = tok("body"), bias = bias, cuts = { 0.14, 0.3, 0.46, 0.64, 0.84 } })
end
-- folded wing on the right, barred with pale spots
local wing = c:poly{ {46,55},{55,57},{61,64},{60,72},{45,72},{43,63} }
do
  X.tone(c, wing, X.light(X.pillow(wing, 3), { amb = 0.35 }), WINGR, { tok = tok("wing") })
  for _, y in ipairs{ 60, 64, 68 } do
    local bar = c:line({ {44, y}, {61, y + 3} }, 1):clip(wing)
    bar:each(function(x, yy) keep(x, yy, ((x + yy) % 3 == 0) and WINGR[4] or "#d39a62") end)
  end
  wing:edge():each(function(x, y) if not wing:has(x - 1, y) and c.own[y * 72 + x - 1] then keep(x, y, WINGR[1]) end end)
end
-- chest buff, modest, with feather scallops
local chest = c:ellipse(30, 69, 9, 7)
X.tone(c, chest, X.light(X.sphere(28, 66, 10, chest), { amb = 0.35 }), BUFF, { tok = tok("chest") })
for _, s in ipairs{ {24,60},{30,61},{18,64},{36,64},{22,67},{28,66},{34,68},{16,69},{40,69},{25,70},{31,71} } do
  local x, y = s[1], s[2]
  local onChest = chest:has(x, y)
  local col = onChest and BUFF[2] or FUR[3]
  pts({ {x, y}, {x + 1, y + 1}, {x + 2, y} }, col)
end

---------------------------------------------------------------- satchel strap + buckle
local strap = c:line({ {51,51},{38,61},{25,72} }, 3):clip(body)
X.tone(c, strap, X.light(X.pillow(strap, 1), { amb = 0.35 }), LEATH, { tok = tok("strap") })
c:line({ {50,51},{37,61},{24,72} }, 1):clip(strap):each(function(x, y) keep(x, y, LEATH[4]) end)
local buckle = c:rect(34, 59, 39, 64)
c:part(buckle, "gold", { band = 1, pop = { x = 35, y = 59 } })
c:fillMask(c:rect(36, 61, 37, 62), LEATH[1])
c:px(38, 61, P.gold.deep)

---------------------------------------------------------------- head
do
  local n = X.sphere(30, 33, 18, head)
  X.tone(c, head, X.light(n, { amb = 0.32, wrap = 0.45 }), FUR, { tok = tok("head"), cuts = { 0.14, 0.3, 0.47, 0.64, 0.84 } })
  -- warm reflected light from the disc on the lower-right rim
  local r = X.rim(n)
  head:edge():each(function(x, y) local h = c:get(x, y) if r[K(x, y)] > 0.55 and (h == FUR[1]:lower() or h == FUR[2]:lower()) then keep(x, y, FUR[3]) end end)
end
-- small buff throat under the beak, cheek wash under the eye
local throat = c:ellipse(28, 48, 7, 3.5):add(c:ellipse(36, 44, 4, 2)):clip(head)
X.tone(c, throat, X.light(X.sphere(27, 45, 10, throat), { amb = 0.45 }), BUFF, { tok = tok("throat") })
-- crown streaks: short dashes following the skull
for _, s in ipairs{ {26,29},{31,27},{36,27},{41,28},{45,31},{29,31},{39,30} } do pts({ {s[1], s[2]}, {s[1] + 1, s[2]} }, FUR[3]) end
-- pale eyebrow stripes (supercilium) and dark eye stripe
pts({ {32,31},{33,30},{34,30},{35,30},{36,30},{37,30},{38,30},{39,31},{40,31},{41,31},{42,32},{43,32},{44,33},{45,33},{46,34} }, BUFF[4])
pts({ {33,31},{38,31},{43,33} }, BUFF[3])
pts({ {19,31},{20,30},{21,30},{22,30},{23,30},{24,31} }, BUFF[4])
pts({ {38,35},{39,35},{40,35},{41,36},{42,36},{43,36},{44,37},{45,37},{46,38} }, FUR[1])
pts({ {39,36},{42,37},{45,38} }, FUR[2])
-- ear-covert speckles on the cheek
pts({ {41,40},{44,41},{42,43} }, FUR[3])

---------------------------------------------------------------- beak: hand-cut tapering cone
local btok = { r = BEAK }
for x = 15, 31 do
  local t = (x - 15) / 16
  local top, bot = math.floor(42.4 - 4 * t + 0.5), math.floor(43 + 2 * t + 0.5)
  local gape = top + math.floor((bot - top) * 0.62 + 0.5)
  for y = top, bot do
    local col
    if x <= 16 then col = BEAK.shade
    elseif y == top then col = BEAK.hi
    elseif y == gape and x >= 22 and x <= 30 then col = (x >= 27) and "#5a2a24" or BEAK.deep
    elseif y < gape then col = BEAK.base
    else col = (y == bot and x > 18) and BEAK.deep or BEAK.shade end
    if x == 31 and y < gape then col = BEAK.shade end
    c:put(x, y, col, btok)
  end
end
c:put(27, 40, BEAK.deep, btok)                     -- nostril
c:put(31, 42, "#ffe9a8", btok)                    -- pale gape corner
c:px(29, 44, "#e9b07a") c:px(30, 44, "#e9b07a")   -- soft chin under the gape corner

---------------------------------------------------------------- eyes, cheek
c:eyeLocked(19, 33) c:eyeLocked(33, 33)
c:cheek(37, 41)

---------------------------------------------------------------- thimble hat
local cx, cy, a = 33, 27, math.rad(9)
local ca, sa = math.cos(a), math.sin(a)
local function loc(x, y) local dx, dy = x + .5 - cx, cy - (y + .5) return dx * ca - dy * sa, dx * sa + dy * ca end
local thim, rim = HP.mask(), HP.mask()
local U, V = {}, {}
local function hwOf(v) return v > 10 and 6.8 or (8.6 - 0.18 * v) end
for y = 8, 31 do for x = 18, 50 do
  local u, v = loc(x, y)
  local inBody = v >= 0 and v <= 10 and math.abs(u) <= hwOf(v)
  local inDome = v > 10 and (u / 6.8) ^ 2 + ((v - 10) / 3.2) ^ 2 <= 1
  local inRim = v >= -0.6 and v <= 2.8 and math.abs(u) <= 9.8
  if inBody or inDome or inRim then thim:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
  if inRim then rim:set(x, y) end
end end
local ttok = tok("thimble")
thim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  local t = u / (rim:has(x, y) and 9.8 or hwOf(v))
  local i
  if t < -0.82 then i = 4 elseif t < -0.45 then i = 6 elseif t < -0.25 then i = 5 elseif t < 0.25 then i = 4
  elseif t < 0.6 then i = 3 elseif t < 0.86 then i = 2 else i = 3 end
  if v > 11.2 then i = (t < 0.2) and 5 or 4 end              -- dome top catches the sky
  c:put(x, y, STEEL[i], ttok)
end)
rim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  local t = u / 9.8
  local i
  if v > 1.5 then i = (t < -0.3) and 6 or (t < 0.45 and 5 or 3) else i = (t < 0.3) and 3 or 2 end
  c:put(x, y, STEEL[i], ttok)
end)
thim:each(function(x, y) local v = V[K(x, y)] if v > 2.8 and v <= 3.9 and not rim:has(x, y) then c:put(x, y, STEEL[1], ttok) end end)
-- dimples: regular staggered rows of 1 px pits, kept off the silhouette edge and the specular streak
thim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  if rim:has(x, y) or v < 5 or v > 12 then return end
  local row = math.floor((v - 5) / 2.6 + 0.5)
  if math.abs(v - (5 + row * 2.6)) >= 0.5 then return end
  local off = (row % 2) * 1.6
  if math.abs(u - (math.floor((u - off) / 3.2 + 0.5) * 3.2 + off)) >= 0.5 then return end
  local t = u / hwOf(v)
  if math.abs(t) > 0.8 then return end
  c:put(x, y, (t < -0.2) and STEEL[3] or STEEL[2], ttok)
end)
-- contact shadow of the rim on the crown
thim:shift(1, 1):cut(thim):clip(head):each(function(x, y) keep(x, y, FUR[2]) end)

c:finish{ outline = true }
c:sparkle(23, 13)
---------------------------------------------------------------- backdrop disc: cream-gold, shade crescent, own darker outline
local DB, DS, DO, DD = "#f9df96", "#efc566", "#c99238", "#a8742c"
local disc = HP.ellipse(36, 37, 31.5, 31.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and DB or DS, "bg") end end)
local ring = disc:grow(1):cut(disc)
ring:each(function(x, y) if not c:get(x, y) then
  local dk = false
  for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == DS:lower() then dk = true end end
  c:put(x, y, dk and DD or DO, "bg") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

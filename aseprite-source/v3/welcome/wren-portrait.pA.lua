-- wren-portrait PASS A (form, composition, material, colour, quirk). Hearth Pop v3, 72x72 portrait, bleeds off the bottom.
-- Wren Thimblewick: small round brown wren, head turned 3/4 left so a long slim amber beak breaks the silhouette,
-- pale eyebrow stripe + dark eye stripe (wren tells), cocked barred tail behind, barred folded wing, satchel strap.
-- quirk: a dimpled steel sewing thimble worn as a hat, tipped a little to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "wren-portrait.pA"
local c = HP.canvas{ w = 72, h = 72, scale = 1, name = NAME }
local D4 = { {1,0},{-1,0},{0,1},{0,-1} }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(list, hex) for _, p in ipairs(list) do keep(p[1], p[2], hex) end end
local function recol(mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end) end

local FUR   = { "#4a2a26", "#6e3c2c", "#8f5434", "#b06e3e", "#cc8a50", "#e6ad72" }
local BUFF  = { "#b5814f", "#d4a46c", "#ebc58e", "#f7deb0" }
local BEAK  = { hi = "#ffd27a", base = "#eba23c", shade = "#c06a2a", deep = "#7a3a24" }
local STEEL = { "#3f4260", "#5f6382", "#8a8ca6", "#b4b5c8", "#d8d8e4", "#f4f2f8" }
local LEATH = { "#4f2a24", "#7a4030", "#a05e3a", "#c4844e" }
local function tok(n) return { r = { name = n } } end

---------------------------------------------------------------- tail (behind): cocked up and right, barred
local tail = c:poly{ {49,58},{52,42},{56,28},{59,19},{62,15},{66,16},{66,22},{63,36},{60,50},{57,62} }
do
  local _, n = X.cyl(55, 60, 63, 16, function() return 4.5 end, tail)
  local v = X.light(n, { amb = 0.25, wrap = 0.2 })
  X.tone(c, tail, v, FUR, { tok = tok("tail"), cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
  for i = 0, 9 do
    local y = 20 + i * 4
    c:line({ {50, y + 4}, {70, y - 2} }, 1):clip(tail):each(function(x, yy) keep(x, yy, FUR[1]) end)
  end
end

---------------------------------------------------------------- body
local body = c:ellipse(37, 72, 24, 21)
local bodyTok = tok("body")
do
  local n = X.sphere(33, 66, 25, body)
  X.tone(c, body, X.light(n, { amb = 0.2, wrap = 0.3 }), FUR, { tok = bodyTok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 } })
end
-- folded wing on the right, barred
local wing = c:poly{ {46,55},{55,57},{61,64},{60,72},{45,72},{43,63} }
do
  local W = { "#3e2422", "#5e3428", "#7d4a30", "#a5683c" }
  local n = X.pillow(wing, 3)
  X.tone(c, wing, X.light(n, { amb = 0.3 }), W, { tok = tok("wing") })
  for _, y in ipairs{ 60, 64, 68 } do
    c:line({ {44, y}, {61, y + 3} }, 1):clip(wing):each(function(x, yy) keep(x, yy, "#c58b56") end)
  end
end
-- chest buff (modest), streaked flanks
local chest = c:ellipse(31, 68, 10, 8)
X.tone(c, chest, X.light(X.sphere(29, 66, 11, chest), { amb = 0.3 }), BUFF, { tok = tok("chest") })

---------------------------------------------------------------- satchel strap + buckle
local strap = c:line({ {50,52},{38,61},{25,72} }, 3):clip(body)
X.tone(c, strap, X.light(X.pillow(strap, 1), { amb = 0.3 }), LEATH, { tok = tok("strap") })
c:part(c:rect(35, 60, 39, 64), "gold", { band = 1, pop = { x = 35, y = 60 } })
c:fillMask(c:rect(36, 61, 38, 63), LEATH[1])

---------------------------------------------------------------- head
local head = c:ellipse(34, 38, 17, 15)
do
  local n = X.sphere(31, 33, 18, head)
  X.tone(c, head, X.light(n, { amb = 0.2, wrap = 0.3 }), FUR, { tok = tok("head"), cuts = { 0.16, 0.32, 0.48, 0.66, 0.86 } })
end
-- buff cheek + throat under the beak
local throat = c:ellipse(29, 48, 9, 4):add(c:ellipse(37, 44, 6, 3))
throat:clip(head)
X.tone(c, throat, X.light(X.sphere(28, 44, 12, throat), { amb = 0.4 }), BUFF, { tok = tok("throat") })
-- crown streaks
for _, p in ipairs{ {28,27},{33,26},{38,27},{43,29},{25,30},{31,29},{36,29},{41,31},{46,32} } do keep(p[1], p[2], FUR[2]) end
-- pale eyebrow stripes (supercilium)
pts({ {32,31},{33,30},{34,30},{35,30},{36,30},{37,30},{38,30},{39,31},{40,31},{41,31},{42,32},{43,32},{44,33},{45,33} }, BUFF[4])
pts({ {19,31},{20,30},{21,30},{22,30},{23,30} }, BUFF[4])
-- dark eye stripe behind the near eye
pts({ {38,35},{39,35},{40,35},{41,36},{42,36},{43,36},{44,37},{45,37} }, FUR[1])

---------------------------------------------------------------- beak: long slim amber, lit ridge, ink gape, nostril
local upper = c:poly{ {31,37.5},{31,42},{14,42.6},{18,40.5},{24,38.5} }
local lower = c:poly{ {31,42},{30,45},{22,44},{14,42.6} }
local btok = { r = BEAK }
upper:each(function(x, y)
  local col = BEAK.base
  if not upper:has(x, y - 1) then col = BEAK.hi elseif not upper:has(x, y + 1) then col = BEAK.shade end
  c:put(x, y, col, btok)
end)
lower:each(function(x, y)
  local col = BEAK.shade
  if not lower:has(x, y + 1) then col = BEAK.deep end
  c:put(x, y, col, btok)
end)
for x = 16, 30 do if upper:has(x, 42) or lower:has(x, 42) then c:put(x, 42, P.ink, btok) end end
c:put(25, 39, BEAK.deep, btok) c:put(26, 39, BEAK.deep, btok)
c:put(31, 42, "#ffe9a8", btok) c:put(31, 43, "#ffe9a8", btok)  -- soft gape corner

---------------------------------------------------------------- eyes, cheek
c:eyeLocked(19, 33) c:eyeLocked(33, 33)
c:cheek(38, 41)

---------------------------------------------------------------- thimble hat
local cx, cy, a = 33, 26, math.rad(9)
local ca, sa = math.cos(a), math.sin(a)
local function loc(x, y) local dx, dy = x + .5 - cx, cy - (y + .5) return dx * ca - dy * sa, dx * sa + dy * ca end
local thim, rim = HP.mask(), HP.mask()
local U, V = {}, {}
for y = 8, 30 do for x = 18, 50 do
  local u, v = loc(x, y)
  local inBody = v >= 0 and v <= 10 and math.abs(u) <= 8.6 - 0.18 * v
  local inDome = v > 10 and (u / 6.8) ^ 2 + ((v - 10) / 3.2) ^ 2 <= 1
  local inRim = v >= -0.5 and v <= 3 and math.abs(u) <= 9.6
  if inBody or inDome or inRim then thim:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
  if inRim then rim:set(x, y) end
end end
local ttok = tok("thimble")
thim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  local hw = v > 10 and 6.8 or (8.6 - 0.18 * v)
  if rim:has(x, y) then hw = 9.6 end
  local t = u / hw
  local i
  if t < -0.8 then i = 4 elseif t < -0.5 then i = 6 elseif t < -0.3 then i = 5 elseif t < 0.3 then i = 4
  elseif t < 0.65 then i = 3 elseif t < 0.88 then i = 2 else i = 3 end
  if v > 10.5 then i = math.min(6, i + 1) end
  c:put(x, y, STEEL[i], ttok)
end)
-- rolled rim: bright top roll, dark bottom, deep groove above
rim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  local t = u / 9.6
  local i = (v > 1.6) and (t < 0.4 and 5 or 3) or (t < 0.3 and 3 or 2)
  c:put(x, y, STEEL[i], ttok)
end)
thim:each(function(x, y) local v = V[K(x, y)] if v > 3 and v <= 4.1 then c:put(x, y, STEEL[2], ttok) end end)
-- dimples: staggered grid, dark pit with a lit lower-right lip
thim:each(function(x, y)
  local u, v = U[K(x, y)], V[K(x, y)]
  local row = math.floor((v - 5) / 2.4 + 0.5)
  local vv = 5 + row * 2.4
  local off = (row % 2) * 1.5
  local uu = math.floor((u - off) / 3 + 0.5) * 3 + off
  if row >= 0 and v < 13 and math.abs(v - vv) < 0.5 and math.abs(u - uu) < 0.5 and not rim:has(x, y) then
    local hw = v > 10 and 6.8 or (8.6 - 0.18 * v)
    if math.abs(u) < hw - 1 then
      c:put(x, y, STEEL[2], ttok)
      if thim:has(x + 1, y + 1) and not rim:has(x + 1, y + 1) then c:put(x + 1, y + 1, STEEL[5], ttok) end
    end
  end
end)
-- crest tuft poking out from under the rim at the back
local tuft = c:poly{ {43,26},{48,20},{50,22},{47,28} }
tuft:cut(thim)
X.tone(c, tuft, X.light(X.pillow(tuft, 1), { amb = 0.3 }), FUR, { tok = tok("tuft") })

c:finish{ outline = true }
c:sparkle(23, 12)
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

-- cold-brew-coffee (Opus single pass). A slim swing-top glass bottle of cold brew: dark coffee with a cream layer
-- and a cream swirl sinking through it, two ice cubes floating at the fill line, a pale glass core above, thick
-- teal glass base, porcelain stopper with red gasket and wire bail, twine twisted round the neck with a kraft tag.
-- Glass cues: bright left rim, specular streak, cool reflected light on the right wall, condensation beads.
-- quirk: a single roasted coffee bean balanced on top of the stopper.
local NAME = "cold-brew-coffee"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local c = G.new2(NAME)

local GL  = { "#28465f", "#3b6f8a", "#5f9fb8", "#94cdda", "#c6ebee", "#eefaf4" }   -- glass wall
local CORE = { "#6fa6bb", "#98cbd8", "#c2e6ea", "#e2f6f2" }                         -- empty glass core
local COF = { "#1a0e12", "#2a1615", "#3d2119", "#55301e", "#734526", "#99632f" }
local CR  = { "#6e4a2e", "#9a7046", "#c49a68", "#e6c792", "#f8e6bc" }              -- cream
local ICE = { "#4f7f9e", "#86b9d0", "#bfe3ee", "#ecfaf8" }
local CER = { "#4e4c66", "#7f7d95", "#aeabbf", "#d3d0db", "#ece8e6", "#fbf5e6" }   -- porcelain
local MET = { "#3c3d55", "#6c6d86", "#a3a3b6", "#dcdbe4" }
local TW  = { "#7a4a22", "#b07a36", "#dcae5a" }
local TAG = { "#6e4a35", "#9c6e48", "#c3955f", "#dfbd86", "#f3dcaa" }
local BEAN = { "#2a1714", "#4a2a1c", "#6e4126", "#94603a", "#c08a55" }

c:groundShadow(31.5, 51.5, 11, 1.5)

-- bottle silhouette
local body = c:rrect(23, 26, 40, 50, 5)
local shoulder = c:ellipse(31.5, 26, 8.5, 7)
local neck = c:rect(28, 13, 35, 23)
local lip = c:rrect(27, 11, 36, 14, 1)
local bottle = body:copy():add(shoulder):add(neck):add(lip)
local n = G.rowN(bottle, function(y)
  if y >= 19 and y <= 27 then return -(27 - y) / 7 * 0.9 end
  if y >= 49 then return 0.5 end
  if y <= 14 then return -0.25 end
  return 0
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })

-- glass wall: whole bottle first
local gtok = { r = { name = "glass" } }
X.tone(c, bottle, v, GL, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, tok = gtok })

-- interior (1 px wall, 2 px base)
local inner = bottle:shrink(1)
inner:cut(c:rect(0, 49, 63, 63))
local ctok = { r = { name = "coffee" } }
local FILL = 28
local coffee, air = HP.mask(), HP.mask()
inner:each(function(x, y) if y >= FILL then coffee:set(x, y) elseif y >= 15 then air:set(x, y) end end)
-- empty glass core (pale), slightly darker under the lip
X.tone(c, air, v, CORE, { cuts = { 0.3, 0.55, 0.78 }, tok = gtok })
-- coffee body
X.tone(c, coffee, v, COF, { cuts = { 0.36, 0.52, 0.66, 0.8, 0.93 }, tok = ctok })
-- reflected cool light / backlit amber on the right inner column of the coffee
local rows = {}
coffee:each(function(x, y) rows[y] = max(rows[y] or -1, x) end)
for y, x in pairs(rows) do if y > FILL + 2 and y < 47 then c:put(x, y, (y % 5 == 0) and COF[5] or COF[4], ctok) end end
-- cream layer at the fill line (2 rows), lit left
coffee:each(function(x, y)
  if y <= FILL + 1 then
    local t = (x - 24) / 15
    local i = y == FILL and (t < 0.35 and 5 or t < 0.75 and 4 or 3) or (t < 0.3 and 3 or t < 0.75 and 2 or 1)
    c:put(x, y, CR[i], ctok)
  end
end)
-- cream swirl sinking: two tendrils
for y = FILL + 2, 44 do
  local x1 = floor(30.5 + 3.6 * sin(y * 0.42) + 0.5)
  local tone = y < 38 and 2 or 1
  if coffee:has(x1, y) then c:put(x1, y, CR[tone], ctok) end
  if y < 36 and coffee:has(x1 - 1, y) and y % 3 ~= 0 then c:put(x1 - 1, y, CR[tone + 1], ctok) end
  if y > 33 and y < 44 then
    local x2 = floor(35 - 2.2 * sin(y * 0.5) + 0.5)
    if coffee:has(x2, y) and y % 2 == 0 then c:put(x2, y, CR[1], ctok) end
  end
end

-- ice cubes floating at the fill line (part above, part sunk = tinted)
local function cube(pts, top)
  local m = c:poly(pts)
  m:clip(inner)
  local x0, y0, x1, y1 = m:bbox()
  m:each(function(x, y)
    local u, w = (x - x0) / max(1, x1 - x0), (y - y0) / max(1, y1 - y0)
    local i = (u + w < 0.7) and 4 or (u > 0.65 or w > 0.7) and 2 or 3
    if y >= FILL then i = (i >= 3) and 2 or 1 end
    if y == FILL - 1 then i = 4 end
    if not m:has(x + 1, y) or not m:has(x, y + 1) then i = 1 end
    c:put(x, y, ICE[i], gtok)
  end)
  c:put(x0 + 1, y0 + 1, P_cream or "#fff4d6", gtok)
  return m
end
local ice1 = cube({ { 25, 24 }, { 29, 23 }, { 31, 28 }, { 26, 30 } })
local ice2 = cube({ { 33, 25 }, { 37, 24 }, { 38, 29 }, { 34, 30 } })
-- ambient dark row under the cubes in the coffee
for _, m in ipairs{ ice1, ice2 } do
  m:shift(0, 1):each(function(x, y) if coffee:has(x, y) and not m:has(x, y) and y > FILL then c:put(x, y, COF[1], ctok) end end)
end

-- thick glass base: teal with a lit seam
for x = 24, 39 do c:put(x, 48, x < 30 and GL[5] or GL[4], gtok) end
-- specular streak on the left wall + shoulder glint
for y = 31, 44 do if y ~= 37 and y ~= 38 then c:put(25, y, GL[6], gtok) end end
c:put(25, 40, GL[5], gtok)
c:put(26, 22, GL[6], gtok) c:put(27, 21, GL[6], gtok)
c:put(29, 16, GL[6], gtok) c:put(29, 17, GL[5], gtok)
-- cool reflected light on the right wall
for y = 30, 46 do c:put(40, y, (y % 6 == 0) and GL[4] or GL[3], gtok) end
-- condensation beads: bright top pixel + darker bead below (cold glass)
for _, b in ipairs{ { 37, 33 }, { 34, 42 }, { 38, 45 }, { 28, 46 } } do
  c:put(b[1], b[2], GL[6], gtok) c:put(b[1], b[2] + 1, COF[1] == nil and GL[2] or "#4b7488", gtok)
end
-- a drip running down from one bead
c:put(37, 34, "#4b7488", gtok) c:put(37, 35, GL[5], gtok) c:put(37, 36, "#4b7488", gtok)

-- lip ring (bevel): lighter top row, dark under
for x = 27, 36 do c:put(x, 11, x < 31 and GL[6] or GL[5], gtok) c:put(x, 14, GL[2], gtok) end

-- porcelain stopper + red gasket
local ptok = { r = { name = "cap" } }
local cap = c:ellipse(31.5, 8, 4.5, 2.6)
cap:cut(c:rect(0, 11, 63, 63))
local cn = X.sphere(30.6, 7.2, 4.6, cap)
G.toneN(c, cap, cn, CER, { tok = ptok, amb = 0.15, wrap = 0.35 })
for x = 27, 36 do c:put(x, 10, x < 30 and "#e8493b" or x < 34 and "#c23a3c" or "#8a2a3d", ptok) end
-- wire bail: hinge pins on the cap, wires down to a ring round the neck
local mtok = { r = { name = "wire" } }
for _, s in ipairs{ { 26, 1 }, { 37, -1 } } do
  local x = s[1]
  for y = 8, 13 do c:put(x, y, s[2] > 0 and MET[3] or MET[2], mtok) end
  c:put(x + s[2], 15, s[2] > 0 and MET[3] or MET[2], mtok)
  c:put(x, 14, s[2] > 0 and MET[4] or MET[2], mtok)
end
for x = 28, 35 do c:put(x, 16, x < 31 and MET[4] or x < 34 and MET[3] or MET[2], mtok) end
c:put(26, 8, MET[4], mtok)

-- twine twisted twice round the neck (rows 19-20, 1 px proud)
local ttok = { r = { name = "twine" } }
for y = 19, 20 do for x = 27, 36 do
  local i = ((x + y) % 2 == 0) and 3 or 2
  if x >= 34 then i = i - 1 end
  c:put(x, y, TW[max(1, i)], ttok)
end end
-- string down to the tag
local strP = { { 37, 21 }, { 38, 22 }, { 39, 23 }, { 40, 24 } }
for i, p in ipairs(strP) do c:put(p[1], p[2], TW[(i % 2 == 0) and 2 or 3], ttok) end

-- kraft tag (in front of the bottle's right side)
local tagm = c:poly({ { 39, 25 }, { 46, 27 }, { 45, 37 }, { 37, 35 } })
-- contact shadow of the tag on the glass (lower-right offset)
tagm:shift(-1, 1):each(function(x, y) if bottle:has(x, y) and not tagm:has(x, y) then c:put(x, y, GL[1], gtok) end end)
local tg = X.pillow(tagm, 1.5)
local ktok = { r = { name = "tag" } }
X.tone(c, tagm, X.light(tg, { amb = 0.35, wrap = 0.4 }), TAG, { cuts = { 0.3, 0.5, 0.68, 0.84 }, tok = ktok })
-- eyelet and a little bean doodle
c:put(40, 27, TAG[1], ktok) c:put(41, 27, TAG[2], ktok)
for _, p in ipairs{ { 41, 30 }, { 42, 30 }, { 40, 31 }, { 43, 31 }, { 40, 32 }, { 43, 32 }, { 41, 33 }, { 42, 33 } } do c:put(p[1], p[2], BEAN[2], ktok) end
c:put(41, 31, BEAN[3], ktok) c:put(42, 32, BEAN[3], ktok)
-- torn-paper fibre: bottom-right corner nick
c:put(44, 36, TAG[2], ktok)

-- quirk: coffee bean balanced on the stopper
local btok = { r = { name = "bean" } }
local bm, bnn = G.oval(32.5, 3.6, 2.6, 1.7, -0.25, 0.8)
G.toneN(c, bm, bnn, BEAN, { tok = btok, amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.42, 0.62, 0.82 } })
-- centre crease (dark S line along the bean)
c:put(31, 4, BEAN[1], btok) c:put(32, 4, BEAN[1], btok) c:put(33, 3, BEAN[1], btok) c:put(34, 3, BEAN[2], btok)
c:put(31, 3, BEAN[5], btok)
-- AO on the cap under the bean
bm:shift(1, 1):each(function(x, y) if cap:has(x, y) and not bm:has(x, y) then c:put(x, y, CER[2], ptok) end end)

G.save2(c, NAME)

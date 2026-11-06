-- ico-person (Opus single pass, aA8_1). A friendly head-and-shoulders bust: oval face, auburn hair with a side part
-- swept to the right, slim neck, narrow rounded shoulders in a teal rib-knit jumper with a crew collar.
-- Material: per-pixel pillow light on face, hair and jumper (6-tone ramps each); hair strand lines fanning from the
-- part with a glossy sheen arc; knit ribs and a ribbed collar; ambient shade under the fringe, under the chin and where
-- the neck enters the collar. Face: 2x3 pill eyes with glints, brows, a rounded nose with a lit tip, dark underside
-- and nostril, petal cheeks and a small smile.
-- quirk: a stubby yellow pencil is tucked behind the right ear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.atan
local c = A.new("ico-person")

local SKIN = { "#6e3a34", "#a35e4a", "#cf8866", "#eaa87e", "#f6c79c", "#ffe3c4" }
local HAIR = { "#2a1620", "#4a2428", "#6e3a2e", "#94523a", "#b8704a", "#d6935e" }
local KNIT = { "#1f3a58", "#285c78", "#33809a", "#46a4b2", "#76c4c6", "#ace0da" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
local stok, htok, ktok = { r = { name = "skin" } }, { r = { name = "hair" } }, { r = { name = "knit" } }

-- jumper: narrow rounded shoulders
local body = c:ellipse(32, 57, 18, 16):clip(c:rect(0, 0, 63, 57))
local kn = X.pillow(body, 7)
local kb = {}
body:each(function(x, y) local k = K(x, y)
  -- rib knit: vertical ribs that bow out with the chest
  local xx = (x - 32) * (1 - 0.012 * (y - 40))
  if floor(xx + 64) % 3 == 0 and y > 43 then kb[k] = -1 end
end)
-- AO where the neck enters the collar
X.ao(kb, body, c:rect(28, 34, 36, 40), 2, -1)
A.litN(body, kn, KNIT, { cuts = CUTS, bias = kb, tok = ktok })
-- crew collar: ribbed band around the neck
local collarO = c:ellipse(32, 41, 7, 3.5)
local collarI = c:ellipse(32, 40, 4.5, 2)
local collar = collarO:copy():cut(collarI):clip(body)
local cn = X.pillow(collarO, 2)
collar:each(function(x, y) local k = K(x, y)
  local v = X.light({ [k] = cn[k] }, { amb = 0.1, wrap = 0.3 })[k]
  local t = v > 0.75 and 5 or v > 0.5 and 4 or 3
  if x % 2 == 0 then t = t - 1 end
  if not collarO:has(x, y + 1) then t = max(1, t - 1) end
  c:put(x, y, KNIT[t], ktok)
end)
-- neck (between collar and chin), in shade
local neck = c:rect(30, 33, 34, 40):cut(collar):cut(body:copy():cut(collarI))
neck:each(function(x, y) c:put(x, y, (y <= 37) and SKIN[2] or (x >= 33 and SKIN[3] or SKIN[4]), stok) end)

-- ears
for _, ex in ipairs{ 21.5, 42.5 } do
  local em = c:ellipse(ex, 26.5, 2, 2.5)
  A.litN(em, X.pillow(em, 1.5), SKIN, { cuts = CUTS, bias = (function() local b = {} em:each(function(x, y) b[K(x, y)] = -1 end) return b end)(), tok = stok })
  c:put(floor(ex + .5), 26, SKIN[2], stok) c:put(floor(ex + .5), 27, SKIN[2], stok)
end

-- face
local face = c:ellipse(32, 25.5, 10, 11)
local fn = X.pillow(face, 6)
local fb = {}
-- chin underside darker


-- hair mask: crown + side part swept right, locks down past the temples
local function fringe(x)
  if x <= 27 then return 17 + (27 - x) * 0.55 end         -- short left side
  return 17 + (x - 27) * 0.42                               -- swept to the right
end
local crown = c:ellipse(32, 21, 11.5, 10.5):cut(c:rect(31, 0, 33, 10))
local hair = A.fmask(18, 8, 46, 34, function(x, y)
  if not crown:has(x, y) and not (abs(x - 32) >= 9 and abs(x - 32) <= 11.6 and y <= 27 and y >= 18) then return false end
  if y < fringe(x) then return true end
  return abs(x - 32) >= 9.0 and y <= 25 + (x > 32 and 1 or 0)
end)
X.ao(fb, face, hair, 1, -1)
X.ao(fb, face, hair:shift(1, 1), 1, -1)
A.litN(face, fn, SKIN, { cuts = { 0.1, 0.24, 0.4, 0.58, 0.8 }, amb = 0.15, wrap = 0.35, bias = fb, tok = stok })
local hn = X.pillow(hair, 5)
local hv = X.light(hn, { amb = 0.08, wrap = 0.25 })
local hb = {}
local PX, PY = 27, 10   -- part
hair:each(function(x, y) local k = K(x, y)
  local a = atan(y - PY, x - PX)
  local d = sqrt((x - PX) ^ 2 + (y - PY) ^ 2)
  if (a * 7) % 1 < 0.13 and d > 3 and d < 13 then hb[k] = -1 end
  -- sheen arc
  local r = sqrt((x - 32) ^ 2 + (y - 22) ^ 2)
  if r > 7.5 and r < 9 and x < 34 and y < 18 then hb[k] = (hb[k] or 0) + 1 end
end)
A.paintV(hair, hv, HAIR, CUTS, hb, htok)
-- the part itself: a 1 px dark line into the crown
A.pts({ { 27, 11 }, { 27, 12 }, { 27, 13 } }, HAIR[2])
-- one lifted tip at the fringe swoop
c:put(40, 21, HAIR[4], htok)

-- face features
c:eyeSmall(27, 25) c:eyeSmall(36, 25)
A.pts({ { 26, 23 }, { 27, 22 }, { 28, 22 } }, HAIR[2])
A.pts({ { 36, 22 }, { 37, 22 }, { 38, 23 } }, HAIR[2])
c:cheek(24, 30) c:cheek(39, 30)
-- nose: rounded, warmer, lit tip, dark underside row and nostril shadow
A.bmp({ ".ab.", "abbc", "dddd" }, 30, 28, { a = "#f9b88e", b = "#e7956c", c = "#c97556", d = SKIN[2] })
c:put(31, 28, "#ffe0c0", stok)
c:put(30, 30, SKIN[1], stok)
-- smile
A.pts({ { 30, 33 }, { 31, 34 }, { 32, 34 }, { 33, 34 }, { 34, 33 } }, "#7a3438")
c:put(32, 35, SKIN[3], stok)

-- quirk: a stubby pencil tucked behind the right ear, point forward
A.bmp({
  ".....pp",
  "...yyyp",
  ".yyYyy.",
  "tyYyy..",
  "wt.....",
}, 39, 20, { p = "#f5809f", y = "#f5b82e", Y = "#ffe38a", t = "#e8b982", w = "#51302b" })
A.done()

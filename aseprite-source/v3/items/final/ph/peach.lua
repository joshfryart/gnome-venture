-- peach (aC32_3 final, Opus single pass). One ripe peach, slightly taller than wide with a soft heart-shaped top dip,
-- a curved suture crease down the front-left, mottled red blush over golden-orange skin (two 6-tone ramps, per-pixel
-- light), velvety fuzz specks on the lit shoulder, one soft specular, cool lavender bounce lower-right, AO in the stem
-- cup. Short woody stem with two slim lanceolate peach leaves (midrib, angled veins, finely toothed edge).
-- History: Sonnet draft replaced.
-- quirk: a tiny ladybird is walking along the right-hand leaf.
local NAME = "peach"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GOLD  = { "#7a3a2c", "#b5552c", "#de7a2e", "#f59f3c", "#ffc35e", "#ffe08e" }
local BLUSH = { "#5a1a34", "#8e2438", "#c2363e", "#e2543e", "#f57a50", "#ffa47a" }
local LEAF  = { "#173b38", "#22573f", "#2f7546", "#47944c", "#6cb356", "#a0d06e" }
local WOOD  = { "#3e2622", "#5e3a2a", "#86552f", "#ad7a46" }
local SPEC, BOUNCE, FUZZ = "#fff0d8", "#b48ab8", "#ffd2a0"

-- body: round, slightly taller than wide, shoulders lifted either side of the stem dip
local CX, CY = 31, 38
local body = HP.mask()
for y = CY - 17, CY + 16 do for x = CX - 17, CX + 17 do
  local dx, dy = (x - CX) / 15.6, (y - CY) / 15.9
  if dy < 0 then dx = dx * (1 - 0.06 * dy) end
  local q = dx*dx + dy*dy
  -- heart dip at the top centre
  local dip = (y < CY - 12) and (abs(x - CX - 0.5) < (CY - 12 - y) * 0.9 + 1.2) and (y <= CY - 14)
  if q <= 1 and not dip then body:set(x, y) end
end end
local n = A.body(body, CX - 1, CY, 16, 6, 0.55)
-- suture crease: curve from the stem dip down the front-left
local function sx(y) return CX - 1 - (y - (CY - 14)) * 0.18 - sin((y - (CY - 14)) / 30 * pi) * 3.2 end
local bias = {}
body:each(function(x, y)
  if y >= CY - 14 and y <= CY + 11 then
    local d = x - sx(y)
    local k = K(x, y)
    if d >= -0.5 and d < 0.5 then bias[k] = -2
    elseif d >= 0.5 and d < 1.5 then bias[k] = 1        -- lit lip on the right of the crease
    elseif d >= -1.5 and d < -0.5 then bias[k] = -1 end
  end
end)
-- AO in the stem cup
X.ao(bias, body, c:rect(CX - 2, CY - 19, CX + 3, CY - 16), 2, -1)
-- blush field: upper-left/sun side, mottled edge
local blush = HP.mask()
body:each(function(x, y)
  local f = (CX + 6 - x) * 0.07 + (CY + 6 - y) * 0.06 + (X.hash(floor(x / 2), floor(y / 2), 7) - 0.5) * 0.5
  f = f + 0.18 * sin(x * 0.7 + y * 0.35)
  if f > 0.55 then blush:set(x, y) end
end)
local gold = body:copy():cut(blush)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local gidx = X.tone(c, gold, v, GOLD, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = { r = { name = "peach" } } })
local bidx = X.tone(c, blush, v, BLUSH, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = { r = { name = "peach" } } })
-- red flecks just outside the blush (freckled transition)
gold:each(function(x, y) local k = K(x, y)
  if blush:grow(2):has(x, y) and X.hash(x, y, 3) > 0.72 then c:px(x, y, BLUSH[max(2, min(6, (gidx[k] or 3)))]) end end)
-- velvet fuzz: pale specks on the lit shoulder
body:shrink(2):each(function(x, y) if v[K(x, y)] > 0.62 and X.hash(x, y, 19) > 0.86 and not bias[K(x, y)] then c:px(x, y, FUZZ) end end)
-- cool bounce lower-right
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.66 and y > CY - 2 then c:px(x, y, BOUNCE) end end)
-- soft specular (matte skin: one 2x1 + a hi pixel)
c:px(21, 29, SPEC) c:px(22, 29, SPEC) c:px(21, 30, BLUSH[6]) c:px(23, 28, BLUSH[6])

-- stem
local sm = A.stem(c, { { CX + 0.5, CY - 14 }, { CX + 0.5, CY - 17 }, { CX + 1.5, CY - 19 }, { CX + 2.5, CY - 21 } },
  function(t) return 1.2 - 0.3 * t end, WOOD, { amb = 0.2, cuts = { 0.3, 0.55, 0.8 } })
-- leaves: slim lanceolate, toothed margin
local function pleaf(ax, ay, cx, cy, bx, by, w)
  local m, T, S, idx = A.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, { vs = 3.0, fold = 0.5, pw = 0.9, cut = body })
  -- teeth: notch the margin every 2-3 px
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] and T[k] > 0.15 and T[k] < 0.9 and abs(S[k]) > 0.6 and (x + y) % 3 == 0 then c:px(x, y, S[k] < 0 and LEAF[5] or LEAF[2]) end end)
  return m, T, S
end
local lr = pleaf(CX + 3, CY - 20, CX + 12, CY - 28, CX + 22, CY - 27, 3.6)
local ll = pleaf(CX + 1, CY - 20, CX - 5, CY - 27, CX - 14, CY - 29, 3.0)
-- quirk: ladybird on the right leaf (3x3 dome, ink head, black spot, glint)
local LBx, LBy = CX + 15, CY - 28
for _, p in ipairs{ {0,0,"#e8493b"},{1,0,"#ff7a52"},{2,0,"#e8493b"},{0,1,"#b52e3f"},{1,1,"#2b1c26"},{2,1,"#e8493b"},{1,2,"#b52e3f"},{0,2,"#8a2236"},{2,2,"#8a2236"} } do
  c:px(LBx + p[1], LBy + p[2], p[3]) end
c:px(LBx + 3, LBy + 1, "#2b1c26") c:px(LBx, LBy, "#ffb08a")
A.save(c, NAME)

-- shea-seed (D15, final pass, Sonnet). A torn scrap of shea leaf (long oblong blade, closely parallel veins, pale fibre along the
-- ragged tear, a bite out of the lower edge) lies on the diagonal. Three glossy brown shea nuts with a pale butter-coloured scar
-- sit on it, each with a contact shadow. A sprout rises from the scrap: slim reddish stem and two oblong young leaves with
-- parallel veins, a tiny folded bud at the tip.
-- quirk: the nut on the left has split a hairline and a pale curl of root is poking out and over the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("shea-seed")

local LEAF = { "#12332f", "#1b4d3a", "#276a42", "#388a48", "#58a852", "#8cc968" }
local YOUNG = { "#1d4a34", "#2b6a3e", "#43893f", "#68a846", "#92c458", "#c4e47e" }
local NUT = { "#2a1616", "#4a2622", "#6e3a2a", "#975433", "#bd7a46", "#e2b078" }
local SCAR = { "#8a6a46", "#b08a58", "#cfae78", "#e6cf9c", "#f6e6bc", "#fff6dc" }
local STEM = { "#4a2230", "#7a3a3a", "#a85a40", "#d48a58" }
local ltok, ntok, stok = { r = { name = "leaf" } }, { r = { name = "nut" } }, { r = { name = "stem" } }

-- leaf scrap ---------------------------------------------------------------------------------------------------------------
-- torn: a zigzag bite on the right end and a scoop out of the lower edge
local tear = c:poly{ { 48, 33 }, { 51, 38 }, { 48, 40 }, { 53, 44 }, { 50, 47 }, { 56, 48 }, { 64, 50 }, { 64, 30 } }
tear:add(c:ellipse(38, 54, 3.8, 2.8))
local lm, LT, LS, lidx = G.leaf(c, 6, 57, 25, 46, 57, 41, 9.2, LEAF, { vs = 2.8, pw = 0.5, cut = tear, tok = ltok })
-- stronger parallel veins and a pale midrib
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if abs(s) < 0.1 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and "#b4dc8c" or LEAF[2], ltok)
  elseif abs(s) > 0.2 and abs(s) < 0.9 and t > 0.1 and t < 0.9 then
    local d = (t * 56 - abs(s) * 6.5) % 3.4
    if d < 0.8 then c:put(x, y, s < 0 and LEAF[max(2, (lidx[k] or 3) - 2)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
  end end)
-- pale fibre along the tear: leaf pixels touching the cut
local tg = tear:grow(1)
lm:each(function(x, y) if tg:has(x, y) and not tear:has(x, y) then c:put(x, y, "#a8d88a", ltok) end end)
lm:each(function(x, y) if tear:has(x + 1, y + 1) and not tear:has(x, y) and X.hash(x, y, 4) > 0.5 then c:put(x, y, LEAF[5], ltok) end end)
-- little hanging fibres

-- nut with shadow + scar; ang tilts the long axis
local function nut(cx, cy, rx, ry, ang, scarSide)
  -- contact shadow on the leaf
  local sh = G.ell(cx + 1.2, cy + 1.6, rx + 0.4, ry + 0.3, ang)
  sh:each(function(x, y) if lm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
  local m = G.ell(cx, cy, rx, ry, ang)
  local ns = X.sphere(cx, cy, (rx + ry) / 2 + 0.6, m)
  local np = X.pillow(m, min(rx, ry) + 0.5)
  local n = {}
  for k, a in pairs(ns) do local b = np[k]
    n[k] = { A.norm(a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4) } end
  local idx = G.shade(c, m, n, NUT, { amb = 0.06, wrap = 0.24, tok = ntok })
  -- pale scar patch on the flank facing the viewer's lower side
  local ca, sa = cos(ang), sin(ang)
  local sx, sy = cx + (-sa * scarSide) * ry * 0.45 + ca * rx * 0.1, cy + (ca * scarSide) * ry * 0.45 + sa * rx * 0.1
  local sm = G.ell(sx, sy, rx * 0.5, ry * 0.42, ang):clip(m)
  sm:each(function(x, y)
    local dx, dy = (x - sx) / (rx * 0.5), (y - sy) / (ry * 0.45)
    local v = max(0, min(1, 0.72 - dx * 0.35 - dy * 0.4 - (dx * dx + dy * dy) * 0.25))
    c:put(x, y, SCAR[2 + floor(v * 3.99)], ntok) end)
  sm:edge():each(function(x, y) if x + y > sx + sy then c:put(x, y, SCAR[1], ntok) end end)
  -- specular streak + sparkle on the lit shoulder
  local gx, gy = floor(cx - rx * 0.45), floor(cy - ry * 0.55)
  c:px(gx, gy, NUT[6]) c:px(gx + 1, gy, NUT[6]) c:px(gx - 1, gy + 1, NUT[5])
  return m
end
local n1 = nut(15, 54, 5.6, 4.2, -0.25, 1)
local n2 = nut(29, 54, 5.4, 4.0, 0.3, 1)
local n3 = nut(44, 50, 5.4, 4.0, -0.1, 1)
c:px(12, 50, "#fff4d6")

-- quirk: hairline split on the left nut with a pale root curl escaping onto the leaf
for _, p in ipairs{ { 13, 55 }, { 14, 55 }, { 15, 56 } } do c:px(p[1], p[2], NUT[1]) end
for _, p in ipairs{ { 10, 56 }, { 9, 57 }, { 9, 58 }, { 10, 59 }, { 12, 59 }, { 13, 58 } } do c:px(p[1], p[2], "#f6e8c4") end
c:px(10, 56, "#fff6dc") c:px(9, 57, "#fff6dc") c:px(11, 57, "#c8b088") c:px(10, 58, "#c8b088") c:px(10, 57, "#c8b088")

-- sprout ------------------------------------------------------------------------------------------------------------------
local stem = { { 22, 49 }, { 21, 42 }, { 25, 35 }, { 24, 28 } }
c:px(23, 50, LEAF[1]) c:px(24, 49, LEAF[1]) c:px(21, 50, LEAF[1])
local sm, sn, ST, SS, sidx = G.stem(c, stem, function(t) return 1.45 - 0.35 * t end, STEM, { tok = stok, amb = 0.1, wrap = 0.3 })
G.leaf(c, 24, 31, 18, 22, 8, 20, 4.2, YOUNG, { vs = 2.4, pw = 0.6, tok = ltok })
G.leaf(c, 25, 30, 32, 23, 45, 22, 4.2, YOUNG, { vs = 2.4, pw = 0.6, tok = ltok })
G.leaf(c, 24, 31, 23, 26, 25, 21, 2.0, YOUNG, { vs = 3, pw = 0.8, tok = ltok })
local jn = c:ellipse(24.5, 32, 1.5, 1.5)
G.shade(c, jn, X.sphere(24, 31.5, 1.7, jn), STEM, { tok = stok })
c:px(23, 31, YOUNG[1]) c:px(26, 31, YOUNG[1]) c:px(24, 34, STEM[1]) c:px(25, 34, STEM[1])
c:px(35, 26, "#fff4d6")

A.save(c, "shea-seed")

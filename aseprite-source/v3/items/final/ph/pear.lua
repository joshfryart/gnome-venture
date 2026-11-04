-- pear (final pass, Opus, aC32_5). Slim, slightly leaning green-gold pear: narrow neck flowing into a round base (soft
-- union of two circles), per-pixel light (6-tone green-gold), a warm blush on the sun side, russet freckles (lenticels),
-- a russet cap at the stem end, waxy bloom specks, one specular + small neck glint, cool reflected light lower right,
-- dark calyx dimple at the base. Curved woody stem with a ring scar, one leaf with midrib and veins, AO where they meet.
-- quirk: a single dewdrop is sliding down the shade side of the pear.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, exp, log = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.exp, math.log
local c = A.new("pear")

local PEAR  = { "#2c4428", "#46682c", "#6e9232", "#9cba3c", "#c8d852", "#ecf094" }
local BLUSH = { "#4a2a26", "#7a3c2a", "#a85a30", "#c87c38", "#e0a24a", "#f4cc7c" }
local RUS   = { "#4a3420", "#6e4e2a", "#8e6a36", "#ac8644" }
local STEM  = { "#3a2420", "#5e3a2a", "#86583a", "#ae7e52" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPEC, BOUNCE = "#fffbe6", "#7fb6a4"

-- body: soft union of a small top circle and a large base circle; slight lean (top to the right)
local C1, R1, C2, R2 = 23, 6.0, 43, 11.6
local function cx(y) return 32 + (43 - y) * 0.09 end
local function hw(y)
  if y <= C1 then return sqrt(max(0, R1 * R1 - (y - C1) ^ 2)) end
  if y >= C2 then return sqrt(max(0, R2 * R2 - (y - C2) ^ 2)) end
  local s = (y - C1) / (C2 - C1)
  s = s * s * (3 - 2 * s)
  return R1 + (R2 - R1) * s ^ 1.15
end
local body = HP.mask()
for y = 16, 55 do local h, x0 = hw(y), cx(y)
  if h > 0.6 then for x = floor(x0 - h + 0.5), floor(x0 + h - 0.5) do body:set(x, y) end end end
local n = A.body(body, 31, 40, 14, 6, 0.55)
local bias = {}
-- AO under the stem foot
X.ao(bias, body, c:rect(32, 13, 35, 15), 2, -1)
-- blush region (sun side of the base), wavy edge
local blush = HP.mask()
body:each(function(x, y)
  local d = ((x - 26) / 7.5) ^ 2 + ((y - 39) / 9) ^ 2 + (X.hash(x, y, 3) - 0.5) * 0.35
  if d < 1 then blush:set(x, y) end
end)
local green = body:copy():cut(blush)
local tok = { r = { name = "pear" } }
local gi, v = A.shade(c, green, n, PEAR, { amb = 0.06, wrap = 0.22, bias = bias, tok = tok })
local bi = A.shade(c, blush, n, BLUSH, { amb = 0.06, wrap = 0.22, bias = bias, tok = tok })
local idx = {}
for k, i in pairs(gi) do idx[k] = i end
for k, i in pairs(bi) do idx[k] = i end
-- russet cap at the stem end + freckles
body:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if y < 19 + floor(X.hash(x, 0, 5) * 2) then c:put(x, y, RUS[max(1, min(4, i - 1))], tok)
  elseif i >= 3 and X.hash(x, y, 7) > 0.955 and y > 21 then c:put(x, y, blush:has(x, y) and BLUSH[2] or RUS[3], tok) end
end)
-- waxy bloom: pale specks on the lit interior
body:shrink(2):each(function(x, y) local k = K(x, y)
  if v[k] and v[k] > 0.62 and X.hash(x, y, 13) > 0.86 then c:put(x, y, blush:has(x, y) and BLUSH[6] or PEAR[6], tok) end
end)
-- cool reflected light, lower right edge
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.62 and y > 30 and y < 53 then c:put(x, y, BOUNCE, tok) end end)
-- calyx dimple at the base
for _, p in ipairs{ {31, 54, RUS[1]}, {32, 54, RUS[1]}, {30, 53, RUS[2]}, {33, 53, RUS[2]}, {31, 53, RUS[1]}, {32, 55, RUS[2]} } do
  if body:has(p[1], p[2]) then c:put(p[1], p[2], p[3], tok) end end
-- specular on the base + small glint on the neck
c:px(24, 36, SPEC) c:px(25, 36, SPEC) c:px(24, 37, BLUSH[6]) c:px(26, 35, BLUSH[6])
c:px(31, 20, PEAR[6]) c:px(31, 21, SPEC)

-- quirk: dewdrop on the shade side (glass: dark rim, pale core, bright glint)
local drop = { "....", ".ab.", "abcb", "bccb", "bccd", ".bd." }
A.map(c, drop, 38, 39, { a = "#e8f8ee", b = "#5f9a7e", c = "#b6e0c0", d = "#3a6a5a" })
c:px(39, 45, PEAR[1]) c:px(40, 45, PEAR[2])   -- tiny contact shade under the drop

-- stem: curved woody tube with a ring scar
local sm, sn = A.stem(c, { { 33, 17 }, { 33, 13 }, { 35, 10 }, { 37, 7 } }, function(t) return 1.15 - t * 0.35 end, STEM, { cut = body })
c:px(33, 13, STEM[1]) c:px(34, 13, STEM[2])
c:px(37, 7, STEM[4])
-- leaf off the stem, to the right
local lm = A.leaf(c, 35, 11, 43, 5, 52, 10, 3.6, LEAF, { cut = sm, vs = 3 })
-- AO on the leaf where it meets the stem
for _, p in ipairs{ {36, 11}, {36, 10}, {37, 11} } do if lm:has(p[1], p[2]) then c:px(p[1], p[2], LEAF[1]) end end
A.save(c, "pear")

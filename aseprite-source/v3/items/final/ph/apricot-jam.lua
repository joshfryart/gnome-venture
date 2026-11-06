-- apricot-jam (final, Opus). A slim, tall glass jar of glowing apricot jam under a knurled brass screw lid.
-- Glass: lathe normals, thick base, bright left streak and a pale core, cool rim light right, clear headspace above
-- the jam with a lit meniscus. Jam: 6-tone amber, translucent glow crescent on the shade side (light passing through),
-- pale apricot halves and two bubbles pressed to the glass. Lid: knurled ridges, bevelled top rim, specular streak,
-- AO row onto the neck. Kraft paper label band (wrapped, darker at the turn) with a little apricot doodle.
-- Ground shadow under the jar. quirk: a fat drip of jam has escaped the lid and runs down the shoulder.
local NAME = "apricot-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLASS = { "#2c4560", "#46708a", "#73a2b2", "#a6cdd0", "#d4ece6", "#f2fbf4" }
local JAM   = { "#561a26", "#8c2c22", "#c0501e", "#e3762a", "#f69c3a", "#ffc463" }
local HALF  = { "#d07a2c", "#f0a446", "#ffcb6e", "#ffe6a0" }
local LID   = { "#4e2c22", "#83502a", "#b98230", "#e0ac42", "#f6d474", "#fff0b4" }
local KRAFT = { "#6e4a30", "#9c7046", "#c49a64", "#e2c08a", "#f2d8a8" }
local LEAFC = { "#2f7548", "#6cb258" }
local CX = 31.5

c:groundShadow(31.5, 57, 13.5, 1.2)

-- jar profile (glass), lid profile
local function rJar(y)
  if y < 18 or y > 56 then return nil end
  local t = ({ [18] = 7.8, [19] = 7.8, [20] = 8.4, [21] = 9.4, [22] = 10.3, [23] = 10.9, [24] = 11.2,
               [54] = 11.0, [55] = 10.5, [56] = 9.4 })[y]
  return t or 11.4
end
local jm, jn, JS = A.lathe(CX, 18, 56, rJar)
local gtok, jtok = { r = { name = "glass" } }, { r = { name = "jam" } }
A.shade(c, jm, jn, GLASS, { amb = 0.28, wrap = 0.35, tok = gtok, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })

-- jam fill
local TOP = 27
local fm = HP.mask()
jm:each(function(x, y) if y >= TOP and y <= 53 and abs(x - CX) <= rJar(y) - 1 then fm:set(x, y) end end)
local fb = {}
fm:each(function(x, y) local k = K(x, y)
  local s = JS[k]
  if s > 0.35 and s < 0.82 and y > 31 and y < 52 then fb[k] = 1 end      -- glow crescent (light through the jam)
  if s < -0.78 then fb[k] = (fb[k] or 0) - 1 end
  if y >= 52 then fb[k] = (fb[k] or 0) - 1 end
end)
local fidx = A.shade(c, fm, jn, JAM, { amb = 0.1, wrap = 0.4, bias = fb, tok = jtok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
-- meniscus: lit top row, dark row just under it
for x = floor(CX - 11), floor(CX + 11) do
  if fm:has(x, TOP) then c:put(x, TOP, (x < CX + 4) and JAM[6] or JAM[5], jtok) end
  if fm:has(x, TOP + 1) then c:put(x, TOP + 1, JAM[3], jtok) end
end
-- apricot halves pressed to the glass (cut face toward us, pit hollow), bubbles
local function half(x, y)
  A.map(c, { ".bcb.", "bcddb", "bcaca", ".bbb." }, x, y, { a = HALF[1], b = HALF[2], c = HALF[3], d = HALF[4] }, jtok)
  c:put(x + 2, y + 4, JAM[1], jtok) c:put(x + 3, y + 4, JAM[2], jtok)    -- contact shadow under the half
end
half(23, 32) half(33, 33)
-- bubbles: ring + glint
for _, b in ipairs{ { 29, 31 }, { 39, 31 } } do
  c:put(b[1], b[2], JAM[6], jtok) c:put(b[1] + 1, b[2] + 1, JAM[3], jtok)
end
c:put(29, 36, JAM[6], jtok)

-- label band, wrapped round the jar (cylinder light), deckled lower edge
local L0, L1 = 38, 47
local lm = HP.mask()
jm:each(function(x, y)
  if y >= L0 and y <= L1 and abs(x - CX) <= rJar(y) - 0.5 then
    if not (y == L1 and (x % 3 == 0)) then lm:set(x, y) end
  end
end)
local lb = {}
lm:each(function(x, y) if y == L0 then lb[K(x, y)] = 1 end end)
local ltok = { r = { name = "label" } }
local lidx = A.shade(c, lm, jn, KRAFT, { amb = 0.2, wrap = 0.4, bias = lb, tok = ltok, cuts = { 0.2, 0.42, 0.62, 0.82 } })
-- paper fibre flecks
lm:shrink(1):each(function(x, y) if X.hash(x, y, 5) > 0.92 then c:put(x, y, KRAFT[max(1, lidx[K(x, y)] - 1)], ltok) end end)
-- doodle: a tiny apricot with a leaf, and a written line
A.map(c, {
  "...gl",
  ".oog.",
  "ohoox",
  "ooodx",
  ".dxx.",
}, 26, 40, { o = JAM[4], h = HALF[4], d = JAM[3], x = JAM[2], g = LEAFC[1], l = LEAFC[2] }, ltok)
A.ln(c, 32, 42, 37, 42, KRAFT[1], ltok)
A.ln(c, 32, 44, 35, 44, KRAFT[2], ltok)
-- jam shadow under the label lower edge
for x = 18, 46 do if fm:has(x, L1 + 1) and not lm:has(x, L1 + 1) then c:put(x, L1 + 1, JAM[1], jtok) end end

-- glass over everything: left streak, pale core streak, cool rim right, thick base, headspace
for y = 21, 51 do if not lm:has(21, y) then c:put(21, y, y < 27 and GLASS[6] or GLASS[5], gtok) end end
for y = 30, 36 do c:put(23, y, GLASS[5], gtok) end
jm:each(function(x, y) local k = K(x, y)
  if JS[k] > 0.88 and y > 22 and y < 53 and not lm:has(x, y) then c:put(x, y, "#5b6c8e", gtok) end
end)
for x = 22, 41 do c:put(x, 54, x < 29 and GLASS[5] or GLASS[3], gtok) end
for x = 24, 39 do c:put(x, 55, GLASS[2], gtok) end
for x = 24, 39 do if jm:has(x, 24) then c:put(x, 24, x < 30 and GLASS[5] or GLASS[4], gtok) end end
-- neck thread ridges under the lid
for x = 24, 39 do c:put(x, 20, (x < 30) and GLASS[4] or GLASS[2], gtok) end

-- lid: knurled brass screw cap
local function rLid(y) if y < 11 or y > 19 then return nil end return ({ [11] = 8.0, [12] = 8.9 })[y] or 9.2 end
local lidm, lidn, LS = A.lathe(CX, 11, 19, rLid, { slope = 1.2 })
local kb = {}
lidm:each(function(x, y) local k = K(x, y)
  if y >= 14 and y <= 18 and (x % 2 == 0) then kb[k] = -1 end     -- knurl ridges
  if y == 13 then kb[k] = -1 end                                   -- groove below the top bevel
  if y == 19 then kb[k] = -2 end
end)
local dtok = { r = { name = "lid" } }
A.shade(c, lidm, lidn, LID, { amb = 0.08, wrap = 0.28, bias = kb, tok = dtok })
for x = 24, 38 do if lidm:has(x, 11) then c:put(x, 11, x < 33 and LID[6] or LID[4], dtok) end end   -- top bevel edge
for y = 14, 18 do c:put(24, y, LID[6], dtok) end                                                   -- specular streak
c:put(25, 12, A.CREAM, dtok) c:put(26, 12, A.CREAM, dtok)                                          -- glint
-- AO on the glass right under the lid
for x = 22, 41 do if jm:has(x, 20) and not lidm:has(x, 20) then c:put(x, 20, GLASS[1], gtok) end end
for x = 22, 41 do if jm:has(x, 21) then c:put(x, 21, x < 26 and GLASS[3] or GLASS[2], gtok) end end

-- quirk: jam drip escaping from under the lid, down the shoulder glass
local drip = { { 38, 19, 2 }, { 38, 20, 2 }, { 38, 21, 2 }, { 38, 22, 2 }, { 38, 23, 2 } }
for _, d in ipairs(drip) do
  c:put(d[1], d[2], JAM[5], jtok) c:put(d[1] + 1, d[2], JAM[3], jtok)
end
A.map(c, { ".ab.", "acdb", "abbb", ".bb." }, 37, 24, { a = JAM[5], b = JAM[3], c = A.CREAM, d = JAM[6] }, jtok)
c:put(37, 19, JAM[4], jtok) c:put(40, 19, JAM[2], jtok)
for x = 38, 40 do if jm:has(x, 28) and x ~= 37 then c:put(x, 28, JAM[2], jtok) end end   -- drip contact shadow

A.save(c, NAME)

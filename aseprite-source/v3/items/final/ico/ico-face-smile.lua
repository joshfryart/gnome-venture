-- ico-face-smile (final, Opus). A full, centred sun-yellow face with a wide open "D" grin: a row of cream teeth, a dark
-- mouth and a rosy tongue; two tall bright oval eyes with cream glints, raised happy brows and petal cheeks.
-- Material: per-pixel sphere light snapped to a 6-tone yellow ramp, slight squash (cheeks lifted), specular streak +
-- cream glint upper-left, cool reflected light lower-right, AO inside the upper lip and under the cheeks; teeth 3-tone
-- enamel with a dark gum line, tongue 4-tone with a centre groove.
-- quirk: one front tooth is missing, leaving a gap in the grin.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-face-smile")
local YE = { "#7a3a3a", "#b8603a", "#e08d2e", "#f5b82e", "#ffd94e", "#fff09a" }
local INK, CREAM = A.INK, A.CREAM
local ftok = A.tok("face")
local CX, CY, RX, RY = 31.5, 32, 21, 20

local m = A.ell(CX, CY, RX, RY)
local n = {}
m:each(function(x, y)
  local nx, ny = (x - CX) / (RX + 0.5), (y - CY) / (RY + 0.5)
  local q = 1 - nx * nx - ny * ny
  n[K(x, y)] = { A.norm(nx, ny, sqrt(max(q, 0.02)) * 1.15) }
end)
local idx = A.shade(c, m, n, YE, { tok = ftok, amb = 0.1, wrap = 0.35, cuts = { 0.14, 0.32, 0.5, 0.68, 0.86 },
  tilt = { CX, CY, RX, 0.06 } })
local rim = X.rim(n)
m:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, "#c0707a", ftok) end end)
for _, p in ipairs{ { 18, 20 }, { 19, 19 }, { 20, 18 }, { 17, 21 }, { 16, 23 }, { 16, 22 }, { 21, 17 } } do c:put(p[1], p[2], YE[6], ftok) end
c:put(19, 20, CREAM, ftok) c:put(20, 19, CREAM, ftok) c:put(18, 21, CREAM, ftok)
local function ao(x, y, d) local k = K(x, y) if idx[k] then A.step(c, idx, YE, x, y, d or -1, ftok) end end

-- happy brows: arched, 2 px
local brows = { { { 19, 20 }, { 20, 19 }, { 21, 18 }, { 22, 18 }, { 23, 18 }, { 24, 19 } },
  { { 39, 19 }, { 40, 18 }, { 41, 18 }, { 42, 18 }, { 43, 19 }, { 44, 20 } } }
for _, b in ipairs(brows) do for _, p in ipairs(b) do c:put(p[1], p[2], INK, ftok) c:put(p[1], p[2] + 1, YE[2], ftok) end end
-- tall oval eyes (5x8) with a cream glint and a cool lower catchlight
local eye = {
  ".KKK.",
  "KccKK",
  "KccKK",
  "KKKKK",
  "KKKKK",
  "KKKKK",
  "KKsKK",
  ".KKK.",
}
A.map(c, eye, 20, 23, { K = INK, c = CREAM, s = "#5a459e" }, ftok)
A.map(c, eye, 39, 23, { K = INK, c = CREAM, s = "#5a459e" }, ftok)
-- AO under the eyes
for x = 21, 23 do ao(x, 31) end for x = 40, 42 do ao(x, 31) end
-- petal cheeks (lit pink top, deeper under)
local function cheek(x0)
  A.map(c, { ".pPPp.", "pPPPPp", ".dddd." }, x0, 32, { P = "#f5809f", p = "#ffa3b8", d = "#c94f84" }, ftok)
end
cheek(14) cheek(43)

-- open D grin
local mm = HP.mask()
local MX, MY, MW, MH = 31.5, 35, 12.5, 12
for y = MY, MY + MH do for x = floor(MX - MW) - 1, floor(MX + MW) + 1 do
  local u = (x - MX) / (MW + 0.4)
  local v = (y - MY) / (MH + 0.4)
  -- upper lip curves up at the corners, lower lip is a deep bowl
  local top = MY + 1.6 * (1 - u * u) - 0.2
  if y >= top and u * u + v * v <= 1 then mm:set(x, y) end
end end
local outer = mm:edge()
local INNER = { "#3d1426", "#5e1f30", "#7d2c3e" }
mm:each(function(x, y) c:put(x, y, INNER[2], ftok) end)
-- AO on the face just above the lip and a lit lower-lip rim below
mm:grow(1):cut(mm):each(function(x, y) if y <= MY + 3 then ao(x, y - 1, -1) else ao(x, y + 1, 1) end end)
-- teeth: a band under the upper lip, one front tooth missing
local teeth = HP.mask()
mm:each(function(x, y) if not mm:has(x, y - 1) or not mm:has(x, y - 2) or not mm:has(x, y - 3) then teeth:set(x, y) end end)
teeth:cut(outer)
local gap0 = 33
teeth:each(function(x, y)
  if x == gap0 or x == gap0 + 1 or x == gap0 + 2 then return end
  local top = not teeth:has(x, y - 1)
  local col = top and "#fff4d6" or "#efe0c0"
  if (x - 23) % 4 == 3 then col = "#c9b49a" end -- tooth seams
  if not teeth:has(x, y + 1) then col = "#cdbca2" end
  c:put(x, y, col, ftok)
end)
-- gum line under the missing tooth
for x = gap0, gap0 + 2 do for y = MY + 1, MY + 5 do if teeth:has(x, y) then c:put(x, y, INNER[1], ftok) end end end
c:put(gap0, MY + 3, "#b52e3f", ftok) c:put(gap0 + 1, MY + 3, "#b52e3f", ftok) c:put(gap0 + 2, MY + 3, "#b52e3f", ftok)
-- tongue in the lower bowl
local tm = A.ell(32, MY + MH - 1, 5.6, 3.2)
tm:clip(mm:shrink(1))
local TG = { "#9b2a4e", "#c94f6a", "#e87480", "#ff9ea0" }
local tn = {}
tm:each(function(x, y) local nx, ny = (x - 31) / 8, (y - (MY + MH - 3)) / 4
  tn[K(x, y)] = { A.norm(nx, ny, sqrt(max(1 - nx * nx - ny * ny, 0.05))) } end)
local tidx = A.shade(c, tm, tn, TG, { tok = ftok, amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.55, 0.8 } })
for y = MY + MH - 4, MY + MH - 1 do if tm:has(32, y) then c:put(32, y, TG[1], ftok) end end
-- inner mouth shadow at the back of the throat above the tongue
mm:each(function(x, y) if not tm:has(x, y) and not teeth:has(x, y) and tm:has(x, y + 1) then c:put(x, y, INNER[1], ftok) end end)
-- ink lip line around the whole mouth
outer:each(function(x, y) c:put(x, y, INK, ftok) end)
-- dimples at the corners
c:put(floor(MX - MW) - 1, MY - 1, YE[2], ftok) c:put(floor(MX + MW) + 2, MY - 1, YE[2], ftok)
A.save(c, "ico-face-smile")

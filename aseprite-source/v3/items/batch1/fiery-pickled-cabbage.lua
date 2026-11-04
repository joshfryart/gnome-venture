-- fiery-pickled-cabbage (pass B, final). Slim onggi crock: dark glossy brown glaze (sky-lit shoulder, long specular,
-- cool bounce lower right), rolled lip bead with AO beneath, finger-wiped wave band, bare clay foot under ragged glaze drips.
-- Fan of three napa leaves out of the mouth: thick white ribs, crinkled pale-green tops with veins, chili paste smeared
-- low on the leaves + sparse flakes. A glossy red chili hooked over the rim, calyx in the mouth.
-- History: fiery-pickled-cabbage.pA (pass A).
-- quirk: the chili is so hot its tip has caught a tiny flame.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("fiery-pickled-cabbage")
local K, floor, max, min, sqrt, sin = H.K, math.floor, math.max, math.min, math.sqrt, math.sin
local function put(x, y, h) c:put(x, y, h) end
local function idx(v, n) n = n or 6 return max(1, min(n, floor(v * (n - 0.01)) + 1)) end
local function nrm(x, y, z) local l = sqrt(x*x + y*y + z*z) return { x/l, y/l, z/l } end

local GLAZE = { "#1e1116", "#2e1a1c", "#45241f", "#613426", "#86502f", "#b27444" }
local SPEC  = { "#e9b07a", "#fff0d0" }
local BOUNCE = "#6c5470"
local CLAY  = { "#6b3a2a", "#94553a", "#bb7650", "#d99a6c" }
local LEAFG = { "#2c5638", "#43783f", "#669c47", "#8fbd56", "#b8d874", "#def0a2" }
local RIB   = { "#a99a78", "#cfc19a", "#e9ddb8", "#fbf3d8" }
local PASTE = { "#6e1a20", "#a82a28", "#d6422a", "#f2703a" }
local CHILI = { "#5a1224", "#8a1a28", "#bc262b", "#e2412e", "#ff6d48", "#ffb894" }
local FLAME = { "#e8493b", "#f59a2a", "#ffe07a", "#fff4d6" }

c:groundShadow(32, 58, 10, 2)
-- crock profile: rolled lip, short neck, high shoulder, tapering belly, narrow foot
local CX = 31.5
local function hw(y)
  if y <= 28 then return 7 end
  if y == 29 then return 5.5 end
  if y <= 36 then return 5.5 + 4.5 * sin((y - 29) / 7 * math.pi / 2) end
  if y >= 55 then return 7 end
  return 10 - 3.8 * ((y - 36) / 19) ^ 1.2
end
local crock = HP.mask()
for y = 26, 57 do local w = hw(y) for x = floor(CX - w + 0.5), floor(CX + w + 0.49) do crock:set(x, y) end end
local n = {}
crock:each(function(x, y)
  local w = hw(y)
  local nx = (x - CX) / (w + 0.5)
  local ny = (y <= 26) and -0.8 or (y < 29) and 0.1 or (-0.65 + (y - 30) / 27 * 1.1)
  n[K(x, y)] = nrm(nx, ny, sqrt(max(0.05, 1 - nx * nx)))
end)
local v = X.light(n, { amb = 0.04, wrap = 0.15 })
local GC = { 0.3, 0.5, 0.66, 0.8, 0.93 }
crock:each(function(x, y)
  local i = 1 for j, t in ipairs(GC) do if v[K(x, y)] >= t then i = j + 1 end end
  if y == 29 then i = 1 end                                   -- AO under the rolled lip
  if y == 30 then i = max(1, i - 1) end
  local wy = 45 + floor(1.5 * sin(x * 0.8) + 0.5)              -- finger-wiped wave
  if y == wy then i = min(6, i + 2) end
  put(x, y, GLAZE[i])
end)
-- bare clay foot under ragged glaze drips
local drip = { [24]=1, [27]=2, [28]=1, [31]=0, [33]=2, [36]=1, [37]=0, [39]=1 }
crock:each(function(x, y)
  local edge = 53 + (drip[x] or 0)
  if y > edge then
    local t = (x - CX) / hw(y)
    put(x, y, CLAY[t < -0.45 and 4 or t < 0.15 and 3 or t < 0.6 and 2 or 1])
  elseif y == edge and y >= 53 then put(x, y, GLAZE[1]) end    -- glaze bead along the drip edge
end)
-- gloss: long specular down the shoulder, sky glint on the lip, cool bounce lower right
for _, p in ipairs{ {27,31},{26,32},{25,33},{25,34},{24,35},{24,36},{24,37},{23,38},{23,39},{23,40} } do put(p[1], p[2], SPEC[1]) end
put(26, 31, SPEC[2]) put(25, 32, SPEC[2])
for _, p in ipairs{ {40,45},{40,46},{40,47},{39,48},{39,49},{38,50} } do put(p[1], p[2], BOUNCE) end

-- napa leaves: wedge widening to a crinkled top, white rib, paste smeared low
local function napa(ax, ay, bx, by, wmax, seed, back)
  local m, nn, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = 1.5 + (wmax - 1.5) * min(1, t * 1.25)
    if t > 0.82 then w = w * sqrt(max(0, 1 - (t - 0.82) / 0.18)) + 0.5 end
    return max(0.6, w)
  end)
  local lv = X.light(nn, { amb = 0.15, wrap = 0.3 })
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  -- crinkled edge: nibble alternate edge pixels in the upper half
  local cut = HP.mask()
  m:edge():each(function(x, y) if T[K(x, y)] > 0.45 and (x + y) % 3 == 0 then cut:set(x, y) end end)
  m:cut(cut)
  m:each(function(x, y)
    local k = K(x, y)
    local s, t, i = S[k], T[k], idx(lv[k])
    if back then i = max(1, i - 1) end
    local ribW = 0.42 * (1 - t * 0.8)
    local col
    if math.abs(s) < ribW and t < 0.8 then col = RIB[max(1, min(4, i - 2))]
    else
      col = LEAFG[i]
      local d = t * len - (math.abs(s) * 3)                     -- veins angled toward the tip
      if math.abs(s) > ribW + 0.12 and (floor(d) % 4 == 0) and t > 0.3 then col = LEAFG[max(1, i - 1)] end
      if t > 0.55 and math.abs(s) > 0.75 then col = LEAFG[min(6, i + 1)] end   -- crinkle catches light
    end
    -- chili paste: smeared low, thinning upward, plus sparse flakes
    local smear = t < 0.32 + 0.12 * sin(s * 5 + seed)
    if smear then col = PASTE[max(1, min(4, i - 2))] end
    if not smear and t < 0.7 and X.hash(x, y, seed) > 0.9 then col = PASTE[2] end
    put(x, y, col)
  end)
  return m
end
napa(32, 28, 32, 13, 4.2, 5, true)
napa(29, 28, 18, 11, 5.6, 3)
napa(35, 28, 46, 17, 4.6, 7)
-- rolled lip bead drawn over the leaf bases
for y = 26, 28 do for x = floor(CX - 7 + 0.5), floor(CX + 7 + 0.49) do
  local t = (x - CX) / 7.5
  local i = (y == 26) and (t < 0.2 and 6 or t < 0.7 and 4 or 3) or (y == 27) and (t < -0.4 and 5 or t < 0.5 and 4 or 2) or (t < 0 and 3 or 2)
  put(x, y, GLAZE[i])
end end
put(27, 26, SPEC[2]) put(28, 26, SPEC[1])
-- chili hooked over the rim, hanging down the right side
local cm = H.sweep({ {35,24},{41,20},{45,26},{45,37} }, function(t) return 1.9 - 1.2 * t end, 90)
local cn = X.pillow(cm, 1.8)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
cm:each(function(x, y) put(x, y, CHILI[idx(cv[K(x, y)])]) end)
for _, p in ipairs{ {39,21},{40,21},{42,22} } do put(p[1], p[2], CHILI[6]) end
put(40, 21, "#fff4d6")
for _, p in ipairs{ {44,30},{44,31},{44,32} } do put(p[1], p[2], CHILI[5]) end
c:paint({ "..ab", ".bb.", "cb.." }, 32, 21, { a = LEAFG[5], b = LEAFG[3], c = LEAFG[2] })   -- calyx + stem
-- quirk: tiny flame licking up from the chili tip
c:paint({
  "..a..",
  ".ab.a",
  ".abba",
  "abcba",
  "abdcb",
  ".bcb.",
}, 44, 35, { a = FLAME[1], b = FLAME[2], c = FLAME[3], d = FLAME[4] })
H.fin(c)

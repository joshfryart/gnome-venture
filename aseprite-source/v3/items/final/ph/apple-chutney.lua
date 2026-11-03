-- apple-chutney (final, Opus). A slim, tall glass preserving jar packed with chunky amber chutney: pale apple cubes,
-- dark raisins and mustard seeds pressed against the glass. Thick glass base, bright left-edge streak, cool rim light.
-- Red gingham cloth cap gathered under a twisted twine tie with a bow; scalloped cloth hem with fold lines.
-- quirk: a little kraft-paper tag with a red apple doodle dangles from the bow.
local NAME = "apple-chutney"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin
local c = A.new(NAME)

local GLASS = { "#2c4a5c", "#4a7486", "#79a6ae", "#a8cfcc", "#d2ece4", "#f2fbf2" }
local CHUT  = { "#3c1716", "#62241a", "#8a381e", "#b05624", "#cf7a32", "#e9a24c" }
local APL   = { "#a87a32", "#d4ae58", "#efd48a", "#fff0bc" }
local RAIS  = { "#2a1528", "#47233e", "#6a3a58" }
local SEEDC = { "#c48a1e", "#f0c040" }
local RED   = { "#561629", "#82202f", "#b42f36", "#d84a40", "#ef7058", "#ff9c7c" }
local MIDC  = { "#6a2030", "#9a2c36", "#c8463e", "#e46a52", "#f2907a", "#fcb49c" }
local CRM   = { "#86626a", "#b08c8a", "#d6b8a8", "#ecd6c0", "#f8e8d4", "#fff4e2" }
local TW    = { "#5e3f26", "#8c6438", "#bb8e56", "#e2bf84" }
local KRAFT = { "#7a5432", "#a87a4c", "#cca06a", "#e6c48c" }

local CX = 31.5
c:groundShadow(32, 57, 14, 1.5)

-- jar profile
local function rJar(y)
  if y < 19 or y > 56 then return nil end
  if y <= 22 then return ({ [19] = 9.0, [20] = 10.2, [21] = 10.9, [22] = 11.3 })[y] end
  if y >= 53 then return ({ [53] = 11.1, [54] = 10.7, [55] = 10.0, [56] = 8.8 })[y] end
  return 11.5
end
local jm, jn, JS = A.lathe(CX, 19, 56, rJar)
local gtok = { r = { name = "glass" } }
local ctok = { r = { name = "chutney" } }
-- glass shell first
local gidx = A.shade(c, jm, jn, GLASS, { amb = 0.25, wrap = 0.35, tok = gtok, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })

-- chutney fill: inside the wall, from the lumpy top line down to the glass base
local cm = HP.mask()
jm:each(function(x, y)
  local r = rJar(y)
  local top = 24 + ((x * 7) % 3 == 0 and 1 or 0) + (abs(x - 27) < 2 and -1 or 0)
  if y >= top and y <= 52 and abs(x - CX) <= r - 1 then cm:set(x, y) end
end)
local cn = {}
cm:each(function(x, y) local k = K(x, y) cn[k] = jn[k] end)
local cb = {}
-- ambient dark just under the shoulder glass and above the base
cm:each(function(x, y) if y <= 25 or y >= 51 then cb[K(x, y)] = -1 end end)
local cidx = A.shade(c, cm, cn, CHUT, { amb = 0.08, wrap = 0.3, tok = ctok, bias = cb })

-- texture: apple cubes, raisins, mustard seeds (deterministic scatter, kept off the glass edge)
local function inner(x, y, pad) local r = rJar(y) return r and abs(x - CX) <= r - 1 - pad and cm:has(x, y) end
local used = HP.mask()
local cubes = { {22,28},{29,27},{37,29},{25,34},{33,33},{40,36},{21,40},{29,39},{36,42},{24,46},{32,47},{39,48},{27,51} }
for _, p in ipairs(cubes) do
  local x, y = p[1], p[2]
  local s = A.X.hash(x, y, 3)
  if inner(x, y, 0) and inner(x + 1, y + 1, 0) then
    local l = cidx[K(x, y)] or 3
    local t = l >= 4 and 1 or 0
    c:put(x, y, APL[3 + t], ctok) c:put(x + 1, y, APL[2 + t], ctok)
    c:put(x, y + 1, APL[2 + t], ctok) c:put(x + 1, y + 1, APL[1 + t], ctok)
    if s > 0.5 and inner(x + 2, y, 0) then c:put(x + 2, y, APL[1], ctok) end
    c:put(x + 1, y + 2, CHUT[max(1, l - 2)], ctok)          -- contact under the cube
    used:set(x, y) used:set(x + 1, y) used:set(x, y + 1) used:set(x + 1, y + 1)
  end
end
local raisins = { {26,30},{35,31},{21,35},{38,39},{27,43},{34,45},{22,49},{37,51},{30,35} }
for _, p in ipairs(raisins) do
  local x, y = p[1], p[2]
  if inner(x, y, 0) and inner(x + 1, y, 0) then
    c:put(x, y, RAIS[2], ctok) c:put(x + 1, y, RAIS[1], ctok)
    if (cidx[K(x, y)] or 3) >= 4 then c:put(x, y, RAIS[3], ctok) end
  end
end
for _, p in ipairs{ {24,31},{31,30},{39,33},{27,37},{35,38},{23,43},{31,44},{38,45},{29,49},{35,50} } do
  if inner(p[1], p[2], 0) and not used:has(p[1], p[2]) then c:put(p[1], p[2], (cidx[K(p[1], p[2])] or 3) >= 4 and SEEDC[2] or SEEDC[1], ctok) end
end

-- glass on top: cool reflected rim (right), bright streak (left), base thickness, shoulder ring
cm:each(function(x, y) local k = K(x, y)
  if JS[k] > 0.86 and y > 27 and y < 50 then c:put(x, y, "#5a6f86", ctok) end
end)
for y = 26, 49 do if y ~= 37 and y ~= 38 then c:put(23, y, y < 31 and GLASS[6] or GLASS[5], gtok) end end
for y = 40, 46 do c:put(25, y, GLASS[4], gtok) end
for x = 23, 40 do c:put(x, 53, x < 30 and GLASS[5] or GLASS[3], gtok) end
for x = 25, 38 do c:put(x, 55, GLASS[2], gtok) end
c:put(22, 21, GLASS[6], gtok) c:put(23, 21, GLASS[6], gtok)       -- the glint

-- cloth cap: dome over the lid + gathered skirt with a scalloped hem
local cap = HP.mask()
local function rCap(y)
  if y < 7 or y > 22 then return nil end
  local t = ({ [7] = 5.0, [8] = 8.0, [9] = 9.8, [10] = 10.9, [11] = 11.5, [12] = 11.8, [13] = 11.8, [14] = 11.2,
               [15] = 10.3, [16] = 9.7, [17] = 9.7, [18] = 10.6, [19] = 11.6, [20] = 12.4, [21] = 13.0, [22] = 13.4 })[y]
  return t
end
local capm, capn, CS = A.lathe(CX, 7, 22, rCap, { slope = 0.8 })
-- scallops: lift the hem between points
capm:each(function(x, y)
  local ph = (x - 18) % 5
  if (y == 22 and ph ~= 2) or (y == 21 and (ph == 0 or ph == 4)) then capm.s[K(x, y)] = nil end
end)
local cbias = {}
capm:each(function(x, y) local k = K(x, y)
  -- fold lines on the skirt (darker gathers below the tie)
  if y >= 18 then
    local f = (x + floor((y - 18) * 0.5)) % 5
    if f == 0 then cbias[k] = -1 end
  end
  if y >= 16 and y <= 17 then cbias[k] = -1 end
end)
local cv = X.light(capn, { amb = 0.1, wrap = 0.3 })
local captok = { r = { name = "cloth" } }
capm:each(function(x, y) local k = K(x, y)
  local v = cv[k] or 0
  local i = 1
  for j, t in ipairs{ 0.22, 0.4, 0.56, 0.72, 0.9 } do if v >= t then i = j + 1 end end
  i = max(1, min(6, i + (cbias[k] or 0)))
  -- gingham: 2 px bands following the drape (skirt bands bend outward)
  local gx = floor((x - CX + 0.5 + (y >= 18 and (x - CX) * (y - 18) * 0.04 or 0)) / 2) % 2
  local gy = floor((y - (y >= 18 and 0 or 1)) / 2) % 2
  local ramp = (gx == 1 and gy == 1) and RED or ((gx == 1 or gy == 1) and MIDC or CRM)
  if gx == 1 and gy == 1 then i = min(6, i) end
  c:put(x, y, ramp[i], captok)
end)
-- under-hem ambient shadow on the glass
for x = 19, 44 do if jm:has(x, 22) and not capm:has(x, 22) then c:put(x, 22, GLASS[1], gtok) end
  if jm:has(x, 23) and not capm:has(x, 23) then c:put(x, 23, GLASS[2], gtok) end end
c:put(25, 9, CRM[6], captok) c:put(26, 9, CRM[6], captok)           -- cloth pop

-- twine tie: twisted band (alternating diagonal tones) + bow knot front-right
local ttok = { r = { name = "twine" } }
for x = 21, 42 do for y = 16, 17 do
  if capm:has(x, y) then
    local lit = x < 30 and 1 or 0
    local tw = (x + y) % 3
    c:put(x, y, TW[min(4, (tw == 0 and 1 or (tw == 1 and 2 or 3)) + lit)], ttok)
  end
end end
A.map(c, {
  ".abb.bba.",
  "abccbccba",
  ".abbdbba.",
  "...bab...",
}, 32, 14, { a = TW[1], b = TW[2], c = TW[4], d = TW[3] }, ttok)
-- dangling ends + tag string
A.ln(c, 35, 18, 35, 23, TW[2], ttok)
A.ln(c, 37, 18, 38, 21, TW[3], ttok)
c:put(38, 22, TW[2], ttok)

-- quirk: kraft tag with a red apple doodle
local ktok = { r = { name = "tag" } }
A.map(c, {
  "..kkk..",
  ".kkokk.",
  "kllllld",
  "kllaald",
  "klaaa1d",
  "klaa11d",
  "kll11ld",
  "klllldd",
  "ddddddd",
}, 32, 23, { k = KRAFT[2], l = KRAFT[4], d = KRAFT[1], o = TW[1], a = RED[4], ["1"] = RED[2] }, ktok)
c:put(35, 26, "#5e8a3c", ktok)                                     -- doodle leaf
c:put(33, 28, RED[6], ktok)
-- cast shadow of the tag on the jar
for y = 24, 32 do if jm:has(39, y) then c:put(39, y, CHUT[1], ctok) end end

A.save(c, NAME)

-- tide-pail-and-scoop pass A (Opus). Slim tapered coral enamel pail with a rolled cream rim, two pressed ridge rings,
-- seawater inside, a thin wire bail with a turned wooden grip; a steel hand scoop on a wooden handle leans on the right.
-- quirk: a strand of kelp hangs over the rim and drips.
local NAME = "tide-pail-and-scoop.pA"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, sqrt = math.floor, math.abs, math.sin, math.sqrt

local CORAL = { "#6e2038", "#9e2c3e", "#c8423f", "#e8604a", "#f88a66", "#ffbe94" }
local CREAM = { "#8a6a6a", "#c2a49a", "#e6d2bc", "#fff4d6" }
local WATER = { "#1e3560", "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local KELP  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(31, 58, 21, 1.5)

local CX, TOP, BOT = 27, 26, 55
local function halfw(y) return 14 - (y - TOP) * 3 / (BOT - TOP) end

-- bail wire (behind the rim) + wooden grip
local arc = {}
for i = 0, 20 do local a = i / 20 arc[#arc + 1] = { CX - 14 + 28 * a, 28 - 17 * sin(a * math.pi) } end
c:line(arc, 1):each(function(x, y) c:px(x, y, (x < CX - 4 and y < 22) and STEEL[5] or STEEL[3]) end)
local grip = c:rrect(CX - 4, 9, CX + 4, 12, 1)
local gb = {}
grip:each(function(x, y) gb[K(x, y)] = ((x - CX) % 3 == 0) and -1 or 0 end)
H.lit(c, grip, WOOD, { R = 1.5, bias = gb })

-- pail body
local body = HP.mask()
for y = TOP, BOT do
  local hw = halfw(y)
  for x = floor(CX - hw + 0.5), floor(CX + hw - 0.5) do body:set(x, y) end
end
body:add(c:ellipse(CX - 0.5, BOT, halfw(BOT) - 0.5, 2))
local bias = {}
body:each(function(x, y)
  local b = 0
  if y == 33 or y == 47 then b = 1 end                                 -- pressed ridges: lit top
  if y == 34 or y == 48 then b = -2 end                                -- and their shadow
  if y == TOP + 2 then b = -2 end                                      -- AO under rolled rim
  bias[K(x, y)] = b
end)
H.vcyl(c, body, CORAL, CX - 14, CX + 14, { amb = 0.08, wrap = 0.3, bias = bias })
-- painted cream wave band
for x = CX - 13, CX + 13 do
  local y = 40 + floor(1.2 * sin(x * 0.7) + 0.5)
  if body:has(x, y) then c:px(x, y, x < CX + 6 and CREAM[4] or CREAM[3]) end
  if body:has(x, y + 1) then c:px(x, y + 1, x < CX + 6 and CREAM[3] or CREAM[2]) end
end
-- rivet ears
for _, ex in ipairs{ CX - 13, CX + 12 } do c:px(ex, 29, STEEL[5]) c:px(ex + 1, 29, STEEL[3]) c:px(ex, 30, STEEL[2]) c:px(ex + 1, 30, STEEL[1]) end
-- specular on the enamel
c:px(CX - 9, 36, CREAM[4]) c:px(CX - 9, 37, CREAM[4]) c:px(CX - 9, 38, CORAL[6])

-- rolled rim + water
local rim = c:ellipse(CX - 0.5, TOP, 14.5, 3.5)
local inner = c:ellipse(CX - 0.5, TOP, 12.5, 2)
rim:cut(inner)
rim:each(function(x, y)
  local i = (y < TOP) and 3 or 4
  if x > CX + 7 then i = i - 1 end
  if y > TOP + 1 and x > CX + 2 then i = 2 end
  c:px(x, y, CREAM[math.max(1, i)])
end)
inner:each(function(x, y)
  local i = 2
  if y == TOP - 2 then i = 1 elseif y >= TOP then i = 3 end
  if y == TOP and x > CX - 6 and x < CX + 2 then i = 4 end
  c:px(x, y, WATER[i])
end)
c:px(CX - 7, TOP + 1, WATER[5]) c:px(CX - 6, TOP + 1, WATER[5])

-- scoop: wooden handle + steel blade
local hm, hT, hS = H.cyl(c, 55, 10, 50, 36, function(t) return t < 0.06 and 2.1 or 1.5 end, WOOD, { amb = 0.15 })
hm:each(function(x, y) local s, t = hS[K(x, y)], hT[K(x, y)] if s and abs(s + 0.1 - 0.15 * sin(t * 20)) < 0.17 and (t * 30) % 5 > 1 then c:px(x, y, WOOD[3]) end end)
local blade = c:poly{ {46, 36}, {54, 36}, {57, 44}, {57, 51}, {54, 56}, {48, 56}, {44, 51}, {44, 43} }
local bn = X.pillow(blade, 2)
local bv = X.light(bn, { amb = 0.15, wrap = 0.2 })
local bb = {}
local hollow = c:poly{ {47, 39}, {53, 39}, {55, 45}, {55, 50}, {53, 53}, {49, 53}, {46, 50}, {46, 44} }
hollow:each(function(x, y) bb[K(x, y)] = (x + y < 92) and -3 or 1 end)   -- concave: lit side reversed
X.tone(c, blade, bv, STEEL, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = bb })
for x = 46, 54 do c:px(x, 36, STEEL[6]) end                                -- top lip
c:px(52, 41, STEEL[6]) c:px(53, 42, STEEL[6]) c:px(53, 43, "#f5f6fa")       -- specular inside the bowl
for x = 47, 53 do c:px(x, 37, STEEL[1]) end                                -- AO where the socket meets
-- contact shadow of scoop on pail
for y = 38, 54 do if body:has(43, y) and not blade:has(43, y) then c:px(43, y, CORAL[1]) end end

-- quirk: kelp strand over the front rim + a drip
local kelp = H.sweep({ {20, 25}, {17, 28}, {19, 33}, {16, 38} }, function(t) return 1.4 - 0.6 * t end)
kelp:each(function(x, y) c:px(x, y, (x < 18) and KELP[3] or KELP[2]) end)
c:px(19, 26, KELP[4]) c:px(18, 31, KELP[1])
c:px(16, 41, WATER[4]) c:px(16, 42, WATER[3])

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }

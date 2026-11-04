-- tide-pail-and-scoop (pass B, final; Opus). Slim tapered coral enamel pail: rolled cream rim (lit top, shaded
-- underside), visible back wall above the seawater (ripple + glint), two pressed ridge rings, painted cream wave
-- band, enamel specular streak, rivet ears and a thin wire bail with a turned wooden grip. A galvanised hand scoop
-- leans against the rim: wooden handle (grain, pale end grain), concave bowl lit in reverse with a bright lip,
-- contact shadow on the pail. History: tide-pail-and-scoop.pA (pass A), Sonnet draft overwritten.
-- quirk: a strand of kelp with a float bladder hangs over the rim and drips.
local NAME = "tide-pail-and-scoop"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, sqrt, max, min = math.floor, math.abs, math.sin, math.sqrt, math.max, math.min

local CORAL = { "#6e2038", "#9e2c3e", "#c8423f", "#e8604a", "#f88a66", "#ffbe94" }
local CREAM = { "#9a7470", "#c9aa9a", "#ead6bc", "#fff4d6" }
local WATER = { "#1e3560", "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local KELP  = { "#24544a", "#3a7d4f", "#6aaa52", "#a6d06a", "#d2ea8e" }

c:groundShadow(31, 58, 20, 1)

local CX, TOP, BOT = 27.5, 27, 55
local function halfw(y) return 12.5 - (y - TOP) * 2.5 / (BOT - TOP) end

-- bail wire (behind the rim) + wooden grip
local arc = {}
for i = 0, 24 do local a = i / 24 arc[#arc + 1] = { CX - 12 + 24 * a, 30 - 18 * sin(a * math.pi) } end
c:line(arc, 1):each(function(x, y) c:px(x, y, (x < CX - 3 and y < 24) and STEEL[5] or (x > CX + 4 and STEEL[2] or STEEL[3])) end)
local grip = c:rrect(CX - 4.5, 10, CX + 3.5, 13, 1)
local gb = {}
grip:each(function(x, y) gb[K(x, y)] = ((x - 23) % 3 == 0) and -1 or 0 end)
H.lit(c, grip, WOOD, { R = 1.5, bias = gb })
c:px(24, 10, WOOD[6])

-- pail body
local body = HP.mask()
for y = TOP, BOT do
  local hw = halfw(y)
  for x = math.ceil(CX - hw), floor(CX + hw) do body:set(x, y) end
end
body:add(c:ellipse(CX, BOT, halfw(BOT), 1.5))
local bias = {}
body:each(function(x, y)
  local b = 0
  if y == 33 or y == 49 then b = 1 end
  if y == 34 or y == 50 then b = -2 end
  if y == TOP + 3 then b = -2 end                                      -- AO under the rolled rim
  if y >= BOT then b = b - 1 end
  bias[K(x, y)] = b
end)
H.vcyl(c, body, CORAL, CX - 13, CX + 13, { amb = 0.08, wrap = 0.3, bias = bias })
-- painted wave band
for x = CX - 13, CX + 13 do
  local xi = floor(x)
  local y = 41 + floor(1.3 * sin(xi * 0.75) + 0.5)
  local lit = xi < CX + 5
  if body:has(xi, y) then c:px(xi, y, lit and CREAM[4] or CREAM[2]) end
  if body:has(xi, y + 1) then c:px(xi, y + 1, lit and CREAM[3] or CREAM[1]) end
end
-- enamel specular streak (left of centre) + one tiny chip on the shade side
for y = 36, 46 do if y ~= 40 and y ~= 41 and y ~= 42 then c:px(20, y, (y < 39) and CREAM[4] or CORAL[6]) end end
c:px(21, 37, CORAL[6])
c:px(36, 45, CORAL[1]) c:px(36, 44, CREAM[2])
-- rivet ears
c:px(16, 31, STEEL[6]) c:px(16, 32, STEEL[3]) c:px(38, 31, STEEL[4]) c:px(38, 32, STEEL[1])

-- rolled rim + back wall + water
local rimO = c:ellipse(CX, TOP, 13.5, 3.5)
local rimI = c:ellipse(CX, TOP, 11.5, 2)
local rim = rimO:copy():cut(rimI)
rim:each(function(x, y)
  local i
  if y < TOP then i = 3 elseif y == TOP or y == TOP + 1 then i = 4 else i = 2 end
  if x > CX + 6 and i > 1 then i = i - 1 end
  if y == TOP + 3 or (y == TOP + 2 and not rim:has(x, y + 1)) then i = 1 end
  c:px(x, y, CREAM[i])
end)
rimI:each(function(x, y)
  if y <= TOP - 2 then c:px(x, y, (x < CX) and CORAL[2] or CORAL[1])      -- back inner wall in shadow
  else
    local i = 3
    if y == TOP + 1 then i = 2 elseif y == TOP - 1 then i = 2 end
    if (y == TOP and (x == 19 or x == 20 or x == 31 or x == 32)) then i = 4 end   -- ripple
    c:px(x, y, WATER[i])
  end
end)
c:px(23, TOP, WATER[5]) c:px(24, TOP, WATER[5])

-- scoop: handle leaning on the rim, concave steel bowl on the ground
local hm, hT, hS = H.cyl(c, 42, 21, 49, 41, function(t) return 1.5 end, WOOD, { amb = 0.15 })
hm:each(function(x, y) local s, t = hS[K(x, y)], hT[K(x, y)]
  if s and abs(s - 0.15 * sin(t * 18)) < 0.18 and (t * 28) % 6 > 1.5 then c:px(x, y, WOOD[3]) end end)
c:px(41, 20, WOOD[6]) c:px(42, 20, WOOD[5]) c:px(41, 21, WOOD[5])          -- pale end grain
local bm, bn, bT, bS = X.cyl(48.5, 38, 52.5, 57, function(t)
  if t > 0.98 then return -1 end
  return max(1.5, 6.2 * sin(math.pi * (0.2 + 0.8 * t)) ^ 0.55)
end)
local bv = X.light(bn, { amb = 0.15, wrap = 0.25 })
local bb = {}
bm:each(function(x, y)
  local s, t = bS[K(x, y)], bT[K(x, y)]
  if abs(s) < 0.62 and t > 0.12 and t < 0.86 then bb[K(x, y)] = (s < 0) and -3 or 1 end   -- concave bowl: reversed
end)
X.tone(c, bm, bv, STEEL, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = bb })
bm:each(function(x, y)                                                       -- bright lip round the hollow
  local s, t = bS[K(x, y)], bT[K(x, y)]
  if t > 0.1 and t < 0.88 and abs(s) >= 0.62 and abs(s) < 0.86 and s < 0 then c:px(x, y, STEEL[6]) end
end)
c:px(53, 45, "#f5f6fa") c:px(53, 46, STEEL[6]) c:px(52, 52, STEEL[5])     -- specular on the far wall
for _, p in ipairs{ {48, 38}, {49, 38}, {48, 39} } do if bm:has(p[1], p[2]) then c:px(p[1], p[2], STEEL[1]) end end   -- socket AO
-- contact shadows of the scoop on the pail
for y = 30, 55 do for x = 38, 41 do
  if body:has(x, y) and (bm:has(x + 1, y) or bm:has(x + 2, y - 1)) and not bm:has(x, y) then c:px(x, y, CORAL[1]) end
end end
c:px(40, 23, CREAM[1]) c:px(40, 24, CREAM[1])

-- quirk: kelp strand over the front rim (wavy frond, light midrib, a float bladder) + a drip
local kelp, kT = H.sweep({ {21, 26}, {17, 29}, {20, 34}, {16, 41} }, function(t) return 1.6 - 0.7 * t end, 80)
kelp:each(function(x, y)
  local i = 3
  if not kelp:has(x - 1, y) then i = 4 end
  if not kelp:has(x + 1, y) then i = 2 end
  c:px(x, y, KELP[i])
end)
local bl = c:ellipse(18.5, 32, 1.5, 1.5)
bl:each(function(x, y) c:px(x, y, (x < 19 and y < 32) and KELP[5] or KELP[3]) end)
c:px(19, 33, KELP[1]) c:px(21, 27, KELP[1]) c:px(20, 27, KELP[1])
c:px(16, 44, WATER[5]) c:px(16, 45, WATER[3])

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }

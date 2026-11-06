-- elderberry-cordial (final pass, Opus single pass). A tall slim swing-top bottle of deep violet cordial: square
-- shoulders easing into a narrow neck, a cream ceramic stopper on a red rubber seal held by a wire bail, twine
-- wound round the neck and a paper label with a hand-drawn elderberry sprig.
-- Material: liquid lit as a filled glass cylinder (6 tones: dark walls, glowing magenta core lower-right where light
-- passes through), pale clear glass in the headspace, a long specular streak on the left wall plus one cream glint,
-- bright right rim, thick dark base with a punt glint. Ceramic: bevel + specular. Wire: 2-tone bright edge.
-- Twine: alternating twist with a tied tail. Label: cylinder-lit paper with a dark top/bottom edge.
-- quirk: a single drip of cordial runs down the neck from the lip.
local NAME = "elderberry-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB2r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)

local LIQ   = { "#1c0d2c", "#36184e", "#552672", "#7a3592", "#a752b4", "#d68fd6" }
local GLASS = { "#4e5a7e", "#7f93b0", "#b4cad8", "#e2f0ee" }
local CER   = { "#8a7e86", "#bfb6b4", "#e6ddd0", "#fbf4e6" }
local RUB   = { "#6e2038", "#b52e3f" }
local WIRE  = { "#5c5e78", "#aaa9b8", "#e2e0e6" }
local TWN   = { "#8f4a1f", "#c48a3a", "#e8bf6a" }
local PAP   = { "#9a8670", "#c9b490", "#e8d8b2", "#fbf0d4" }
local SPEC  = "#fff4e4"
local tokG, tokL, tokC = { r = { name = "glass" } }, { r = { name = "label" } }, { r = { name = "cap" } }

local CX = 31.5
c:groundShadow(31.5, 55, 12, 2)
local function hw(y)
  if y <= 13 then return 4.3 end                                   -- lip ring
  if y <= 17 then return 3.3 end                                   -- neck
  if y <= 25 then return 3.3 + 5.9 * sin((y - 17) / 8 * pi / 2) end -- shoulder
  if y <= 51 then return 9.2 end
  return 9.2 - (y - 51) * 0.9                                      -- rounded heel
end
local glass = HP.mask()
local S = {}
for y = 12, 53 do local w = hw(y) for x = 20, 43 do
  if abs(x - CX) <= w then glass:set(x, y) S[K(x, y)] = (x - CX) / (w + 0.5) end end end
local LEVEL = 21
glass:each(function(x, y)
  local k, s = K(x, y), S[K(x, y)]
  if y <= 13 then                                                   -- lip: thick glass ring
    local i = (s < -0.4) and 4 or ((s > 0.5) and 1 or (y == 12 and 3 or 2))
    c:put(x, y, GLASS[i], tokG)
  elseif y < LEVEL then                                             -- empty clear glass: dark walls, pale core
    local a = abs(s)
    local i = (a > 0.8) and 1 or ((a > 0.5) and 2 or 3)
    if s < -0.45 and s > -0.8 then i = 4 end
    c:put(x, y, GLASS[i], tokG)
  else                                                              -- cordial
    local a = abs(s)
    local v = 0.62 * (1 - a * a) + 0.28 * max(0, s) + 0.18 * (y - 30) / 22
    if y == LEVEL then v = 0.95 end                                 -- meniscus line catches light
    local i = max(1, min(6, floor(v * 5.2) + 1))
    if a > 0.86 then i = (s > 0) and 5 or 2 end                     -- bright right rim, dark left wall
    if y >= 52 then i = 1 end                                       -- thick dark base
    c:put(x, y, LIQ[i], tokG)
  end
end)
c:put(36, 52, LIQ[5], tokG) c:put(37, 52, LIQ[4], tokG)           -- punt glint
-- specular streak down the left wall + one glint on the shoulder
for y = 27, 48 do c:put(25, y, (y < 31) and LIQ[6] or LIQ[5], tokG) end
for y = 24, 26 do c:put(26, y, LIQ[6], tokG) end
c:put(27, 22, SPEC, tokG) c:put(26, 23, SPEC, tokG)

-- paper label wrapped round the body
for y = 33, 44 do for x = 23, 40 do if glass:has(x, y) then
  local s = S[K(x, y)]
  local i = (s < -0.55) and 3 or ((s < 0.35) and 4 or ((s < 0.75) and 3 or 2))
  if y == 33 or y == 44 then i = max(1, i - 2) end
  c:put(x, y, PAP[i], tokL)
end end end
-- label art: tiny elderberry sprig + ink rule
A.map(c, {
  "....g.",
  "...g..",
  ".b.g..",
  "bBbBb.",
  ".bBb..",
  "..b...",
}, 29, 35, { b = LIQ[3], B = LIQ[2], g = "#45954c" }, tokL)
for x = 27, 36 do c:put(x, 42, PAP[2], tokL) end

-- twine round the neck (twist) + tied tail
for y = 15, 16 do for x = 27, 36 do if glass:has(x, y) then
  c:put(x, y, TWN[((x + y) % 2 == 0) and 3 or 2], tokC) end end end
c:put(27, 15, TWN[1], tokC) c:put(36, 16, TWN[1], tokC)
A.map(c, { "a.", "ab", ".b", ".a", "b." }, 25, 16, { a = TWN[2], b = TWN[1] }, tokC)

-- swing-top: red seal, ceramic stopper, wire bail + lever
for x = 28, 35 do c:put(x, 11, (x < 31) and RUB[2] or RUB[1], tokC) end
A.map(c, {
  "..bccb..",
  ".bdccbb.",
  "bdhcccba",
  "bccccbaa",
}, 28, 7, { h = SPEC, d = CER[4], c = CER[3], b = CER[2], a = CER[1] }, tokC)
for _, p in ipairs{ { 27, 9 }, { 27, 10 }, { 26, 11 }, { 26, 12 }, { 26, 13 }, { 26, 14 } } do c:put(p[1], p[2], WIRE[3], tokC) end
for _, p in ipairs{ { 36, 9 }, { 36, 10 }, { 37, 11 }, { 37, 12 }, { 37, 13 }, { 37, 14 } } do c:put(p[1], p[2], WIRE[2], tokC) end
for _, p in ipairs{ { 38, 13 }, { 39, 12 }, { 40, 11 }, { 40, 10 } } do c:put(p[1], p[2], WIRE[1], tokC) end   -- lever
c:put(39, 13, WIRE[2], tokC)

-- quirk: a drip of cordial running down the neck from the lip
for y = 14, 19 do c:put(29, y, LIQ[4], tokG) end
c:put(29, 14, LIQ[5], tokG)
c:put(28, 19, LIQ[3], tokG) c:put(29, 20, LIQ[3], tokG) c:put(28, 20, LIQ[2], tokG)
c:put(29, 18, LIQ[6], tokG)
A.save(c, NAME)

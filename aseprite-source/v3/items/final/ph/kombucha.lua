-- kombucha (run3, Opus single pass). A tall, slim swing-top glass bottle of amber kombucha: glass shoulder and neck
-- (bright rim, pale core, vertical streak), cylinder-lit tea with a floating cream SCOBY layer and a stringy tendril,
-- fizz bubbles up the shade side, twisted jute twine round the neck with a little kraft tag, porcelain stopper with a
-- red rubber gasket on a steel wire bail. Ground shadow (it stands).
-- quirk: the fizz has popped the stopper half open; three bubbles escape from the mouth.
local NAME = "kombucha"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new5(NAME)
local GLASS = { "#2f5a74", "#4f86a0", "#7fb6c4", "#acd8da", "#d2efe8", "#effbf4" }
local TEA   = { "#5a2416", "#87391a", "#b45a1f", "#d9822a", "#f0a83c", "#fbd06c" }
local SCOBY = { "#9c8058", "#c4a676", "#e2cc9c", "#f6e8c4" }
local PORC  = { "#8f8aa0", "#bdb8c8", "#e2dfe6", "#fbf8f2" }
local WIRE  = { "#444663", "#74758c", "#c9c8d6" }
local JUTE  = { "#6a4424", "#9a6a36", "#c69852", "#e8c47e" }
local KRAFT = { "#8a6040", "#b8875a", "#d8b07c", "#f0d4a0" }
local CX = 32

local function hw(y)
  if y < 13 then return nil end
  if y <= 14 then return 4.6 end                     -- lip
  if y <= 19 then return 3.6 end                     -- neck
  if y <= 28 then local t = (y - 19) / 9 return 3.6 + 6.2 * (1 - cos(t * pi)) / 2 end   -- shoulder
  if y <= 50 then return 9.8 end
  if y <= 52 then return 9.8 - (y - 50) * 1.2 end
  return nil
end
c:groundShadow(CX, 54, 13, 2)
local body = HP.mask()
for y = 13, 52 do local w = hw(y) for x = floor(CX - w), floor(CX + w + 0.999) - 1 do
  if abs(x + 0.5 - CX) <= w then body:set(x, y) end end end
local x0, x1 = CX - 10, CX + 10
-- glass everywhere first (vertical-cylinder normals per row width)
local function cyln(m)
  local n = {}
  m:each(function(x, y) local w = hw(y) or 4 local t = max(-.95, min(.95, (x + 0.5 - CX) / (w + 0.3)))
    local ny = (y >= 20 and y <= 28) and -0.35 or 0
    n[K(x, y)] = { G.norm(t, ny, sqrt(1 - t * t)) } end)
  return n
end
local gn = cyln(body)
local gtok = { r = { name = "glass" } }
local gi = G.toneN(c, body, gn, GLASS, { tok = gtok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, amb = 0.2, wrap = 0.4 })
-- tea inside (1px glass wall), level in the shoulder
local tea = body:copy():shrink(1)
tea:each(function(x, y) if y < 25 then tea.s[K(x, y)] = nil end end)
local ttok = { r = { name = "tea" } }
local tn = cyln(tea)
local ti = G.toneN(c, tea, tn, TEA, { tok = ttok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.35 })
-- darker at the bottom (depth), brighter glow just under the surface on the lit side
tea:each(function(x, y) local k = K(x, y)
  if y >= 48 then c:put(x, y, TEA[max(1, ti[k] - 1)], ttok) end end)
-- SCOBY layer floating on top + tendril
local sc = HP.mask()
for y = 25, 27 do tea:each(function(x, yy) if yy == y then sc:set(x, y) end end) end
G.fillIdx(c, sc, SCOBY, function(x, y)
  local t = (x + 0.5 - CX) / 9
  local i = (y == 25) and 4 or (y == 26 and 3 or 2)
  if t > 0.55 then i = i - 1 end
  if t < -0.5 and y == 25 then i = 4 end
  return i
end, ttok)
c:px(CX - 5, 26, SCOBY[4]) c:px(CX + 3, 27, SCOBY[1])
-- tendril hanging down, wavy
for i, q in ipairs{ { 34, 28 }, { 35, 29 }, { 35, 30 }, { 34, 31 }, { 34, 32 }, { 35, 33 }, { 35, 34 }, { 34, 35 } } do
  c:put(q[1], q[2], i < 5 and SCOBY[2] or SCOBY[1], ttok) end
c:put(29, 28, SCOBY[1], ttok) c:put(29, 29, SCOBY[1], ttok)
-- surface meniscus: thin bright line at the glass where the tea meets air
c:put(CX - 9, 25, TEA[6], ttok) c:put(CX + 8, 25, TEA[3], ttok)
-- glass streaks over the tea: lit-side vertical highlight, pale rim on the shade side (glass: bright rim, pale core)
for y = 29, 47 do c:put(26, y, y % 9 == 0 and TEA[6] or "#ffe9b0", gtok) end
for y = 31, 43 do c:put(27, y, (y > 33 and y < 41) and "#fbd88a" or TEA[5], gtok) end
for y = 30, 48 do c:put(40, y, GLASS[3], gtok) end
for y = 16, 22 do c:put(30, y, GLASS[6], gtok) end
c:put(31, 17, GLASS[6], gtok)
c:put(25, 24, GLASS[6], gtok) c:put(26, 23, GLASS[6], gtok)
-- fizz bubbles: shade side, rising (ring: dark lower-right, bright upper-left pixel)
for _, b in ipairs{ { 37, 46 }, { 38, 42 }, { 36, 40 }, { 38, 36 }, { 37, 32 }, { 33, 44 }, { 30, 38 } } do
  c:put(b[1], b[2], TEA[6], ttok) c:put(b[1] + 1, b[2] + 1, TEA[3], ttok) end
-- base: thick glass punt shadow
for x = CX - 8, CX + 7 do c:put(x, 51, x < CX - 2 and GLASS[3] or GLASS[2], gtok) end

-- jute twine round the neck (twisted: alternating light/dark pairs), knot and tail to a tag
local jtok = { r = { name = "jute" } }
for x = CX - 5, CX + 4 do
  local t = (x + 0.5 - CX) / 5
  local base = t < -0.4 and 3 or (t < 0.4 and 3 or 2)
  c:put(x, 19, JUTE[((x % 2 == 0) and base + 1 or base - 1)], jtok)
  c:put(x, 20, JUTE[((x % 2 == 1) and base or base - 1)], jtok)
end
-- tail + tag on the right shoulder
local tail = { { 37, 21 }, { 38, 22 }, { 39, 23 }, { 40, 24 } }
for i, q in ipairs(tail) do c:put(q[1], q[2], JUTE[i % 2 == 0 and 2 or 3], jtok) end
local tag = c:poly{ { 39, 25 }, { 45, 24 }, { 47, 31 }, { 41, 32 } }
local ktok = { r = { name = "tag" } }
G.fillIdx(c, tag, KRAFT, function(x, y)
  local d = (x - 39) + (y - 25)
  return d < 3 and 4 or (d < 8 and 3 or (d < 11 and 2 or 1))
end, ktok)
c:put(41, 26, KRAFT[1], ktok)                                  -- punched hole
G.ln(c, 42, 28, 44, 28, KRAFT[2], tag) G.ln(c, 42, 30, 45, 30, KRAFT[2], tag)
-- AO on the glass under the tag
tag:shift(1, 1):each(function(x, y) if body:has(x, y) and not tag:has(x, y) then c:px(x, y, GLASS[1]) end end)

-- lip ring highlight
c:put(CX - 4, 13, GLASS[6], gtok) c:put(CX - 3, 13, GLASS[6], gtok) c:put(CX + 3, 14, GLASS[2], gtok)
-- open mouth: dark tea seen from above
for x = CX - 2, CX + 1 do c:put(x, 13, TEA[2], ttok) end

-- wire bail: two thin wires from the neck pivot up to the lifted stopper
local wtok = { r = { name = "wire" } }
G.ln(c, CX + 4, 17, CX + 7, 12, WIRE[2]) G.ln(c, CX + 5, 17, CX + 8, 12, WIRE[1])
c:put(CX + 4, 17, WIRE[3], wtok) c:put(CX - 5, 17, WIRE[2], wtok) c:put(CX - 5, 16, WIRE[3], wtok)
-- stopper: porcelain dome tipped up to the right, red gasket underneath
local st = G.oval(CX + 7, 9.5, 3.6, 2.4, 0.5, 1)
local sn = {}
local spm, spn = G.oval(CX + 7, 9.5, 3.6, 2.4, 0.5, 0.9)
G.toneN(c, spm, spn, PORC, { tok = { r = { name = "porc" } }, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
for _, q in ipairs{ { CX + 4, 10 }, { CX + 5, 11 }, { CX + 6, 12 }, { CX + 7, 12 } } do
  if not spm:has(q[1], q[2]) then c:px(q[1], q[2], "#c9402f") else c:px(q[1], q[2], "#e8493b") end end
local px, py = G.specAt(spm, spn, 40) if px then c:px(px, py, "#fff4d6") end
-- quirk: escaping bubbles above the mouth
c:px(CX - 1, 10, "#fbd06c") c:px(CX - 2, 9, "#fff4d6")
c:px(CX - 3, 6, "#fbd06c") c:px(CX - 4, 5, "#fff4d6") c:px(CX - 2, 6, "#d9822a")
G.save2(c, NAME)

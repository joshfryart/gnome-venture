-- kimchi (final, Opus single pass). A small onggi crock (tall, slim-shouldered, glossy brown glaze with a
-- finger-swiped grass motif, rolled lip, an unglazed terracotta foot where the glaze ends in drips) heaped with
-- napa-cabbage kimchi: red pepper-paste coated leaves, pale ribbed stem chunks, yellow-green frilled leaf tips,
-- chili flakes and sesame specks; AO where the heap meets the lip; a pair of wooden chopsticks stuck in the heap.
-- Ground shadow under the crock.
-- quirk: one fermentation bubble floats up off the heap.
local NAME = "kimchi"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLAZE = { "#24120f", "#3e2017", "#5f321f", "#84492b", "#ad6a3e", "#d8975e" }
local CLAY  = { "#6a3a2a", "#94553a", "#bd7a52", "#dca274" }
local PASTE = { "#5a1424", "#8c1e2a", "#bc2f2e", "#e04d34", "#f6773e", "#ffa45c" }
local STEMC = { "#b08a52", "#d6b878", "#efdca2", "#fbf0c8" }
local NAPA  = { "#3f6a2e", "#6a9a3a", "#a2c64c", "#d2e47a" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#d9a46a", "#f0cc94" }
local SPEC  = "#fff2dc"
local CX = 32

c:groundShadow(CX, 57, 13, 2)

-- ---------------------------------------------------------------- crock
local Y0, Y1 = 33, 56
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  -- narrow neck, shoulder at t~0.25, gentle taper to a narrow foot
  if t < 0.25 then return 9.2 + 3.0 * sin(t / 0.25 * pi / 2) end
  return 7.4 + 4.8 * cos((t - 0.25) / 0.75 * pi / 2) ^ 0.8
end
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
local nb = {}
body:each(function(x, y)
  local h = hw(y)
  local s = max(-0.96, min(0.96, (x - CX + 0.5) / (h + 0.4)))
  local dy = (hw(y + 1) - hw(y - 1)) * -0.5      -- vertical slope of the profile
  nb[K(x, y)] = { A.norm(s, dy * 0.6 + (y < Y0 + 3 and -0.25 or 0), sqrt(1 - s * s)) }
end)
local foot = HP.mask()
body:each(function(x, y)
  local drip = (X.hash(x, 0, 3) > 0.7) and 1 or 0
  if y >= Y1 - 2 + drip then foot:set(x, y) end end)
local glaze = body:copy():cut(foot)
local gtok, ftok = { r = { name = "glaze" } }, { r = { name = "foot" } }
local gb = {}
local gidx, gv = A.shade(c, glaze, nb, GLAZE, { amb = 0.03, wrap = 0.2, bias = gb, tok = gtok, cuts = { 0.3, 0.48, 0.64, 0.8, 0.93 } })
A.shade(c, foot, nb, CLAY, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.78 }, tok = ftok })
-- glaze drip lip: darkest glaze row just above the foot
glaze:each(function(x, y) if foot:has(x, y + 1) then c:put(x, y, GLAZE[max(1, gidx[K(x, y)] - 1)], gtok) end end)
-- finger-swiped grass motif (paler glaze strokes) on the front of the belly
local strokes = {
  { { 27, 51 }, { 26, 47 }, { 27, 43 }, { 29, 40 } },
  { { 30, 51 }, { 31, 46 }, { 33, 42 }, { 36, 40 } },
  { { 33, 51 }, { 35, 48 }, { 38, 46 }, { 40, 45 } },
}
for _, s in ipairs(strokes) do
  for i = 0, 24 do local x, y = A.bez(s, i / 24) x, y = floor(x + .5), floor(y + .5)
    if glaze:has(x, y) then local k = K(x, y) c:put(x, y, GLAZE[min(6, (gidx[k] or 3) + 2)], gtok) end end
end
-- vertical specular streak upper-left + cool bounce lower-right
for y = Y0 + 4, Y0 + 11 do c:put(CX - 8, y, y < Y0 + 7 and SPEC or GLAZE[6], gtok) end
c:put(CX - 7, Y0 + 5, GLAZE[6], gtok)
local rim = X.rim(nb)
glaze:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and y > Y0 + 6 and y < Y1 - 4 then c:put(x, y, "#5a4a6e", gtok) end end)

-- ---------------------------------------------------------------- chopsticks (behind the heap, in front of the back lip)
local wtok = { r = { name = "wood" } }
local function stick(ax, ay, bx, by)
  local m, n = X.cyl(ax, ay, bx, by, function(t) return 1.0 - t * 0.35 end)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  local idx = X.tone(c, m, v, WOOD, { cuts = { 0.28, 0.48, 0.68, 0.86 }, tok = wtok })
  return m
end
local st1 = stick(38, 28, 50, 9)
local st2 = stick(36, 28, 45, 8)
-- pale end grain at the top ends
c:put(50, 9, WOOD[5], wtok) c:put(45, 8, WOOD[5], wtok)

-- ---------------------------------------------------------------- lip (rolled rim) back half
local lip = HP.mask()
for x = CX - 10, CX + 9 do for y = Y0 - 2, Y0 do lip:set(x, y) end end
lip:cut(c:rect(CX - 10, Y0 - 2, CX - 10, Y0 - 2)):cut(c:rect(CX + 9, Y0 - 2, CX + 9, Y0 - 2))
local nl = {}
lip:each(function(x, y) local s = max(-0.95, min(0.95, (x - CX + 0.5) / 10.5)) local vy = (y - (Y0 - 1)) / 1.6
  nl[K(x, y)] = { A.norm(s, vy, sqrt(max(0.05, 1 - s * s))) } end)

-- ---------------------------------------------------------------- kimchi heap
local heap = HP.mask()
heap:add(c:ellipse(CX - 1, Y0 - 3, 9, 7))
heap:add(c:ellipse(CX - 5, Y0 - 9, 5, 4))
heap:add(c:ellipse(CX + 4, Y0 - 8, 5, 4))
heap:add(c:ellipse(CX - 1, Y0 - 13, 4, 3))
heap:cut(c:rect(0, Y0 - 1, 63, 63))
local hn = X.pillow(heap, 4)
local hbias = {}
X.ao(hbias, heap, lip, 2, -1)
X.ao(hbias, heap, st1:copy():add(st2), 1, -1)
local ptok = { r = { name = "paste" } }
local hidx = A.shade(c, heap, hn, PASTE, { amb = 0.08, wrap = 0.3, bias = hbias, tok = ptok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- pale ribbed napa stem chunks peeking through the paste (curved slabs)
local chunks = {
  { 25, 24, 30, 22, 1 }, { 33, 27, 38, 26, 1 }, { 28, 18, 32, 17, 1 }, { 36, 21, 39, 19, 1 },
}
local stok = { r = { name = "stem" } }
for _, ch in ipairs(chunks) do
  local m = c:line({ { ch[1], ch[2] }, { ch[3], ch[4] } }, 2):clip(heap)
  m:each(function(x, y) local top = not m:has(x, y - 1)
    local i = top and 4 or 2
    if (x + y) % 3 == 0 and not top then i = 1 end   -- rib grooves
    if x < ch[1] + 1 and top then i = 3 end
    c:put(x, y, STEMC[i], stok) end)
end
-- frilled yellow-green leaf tips poking out of the top
local ntok = { r = { name = "napa" } }
local frills = { { 26, 17, 3 }, { 27, 16, 4 }, { 28, 15, 3 }, { 29, 16, 2 }, { 31, 13, 4 }, { 32, 12, 3 }, { 33, 13, 2 },
  { 37, 19, 3 }, { 38, 18, 4 }, { 39, 19, 2 }, { 23, 25, 3 }, { 22, 24, 4 }, { 23, 23, 2 } }
for _, q in ipairs(frills) do c:put(q[1], q[2], NAPA[q[3]], ntok) end
-- chili flakes + sesame
heap:copy():shrink(1):each(function(x, y) local h = X.hash(x, y, 13)
  if c:get(x, y) and c:get(x, y) == PASTE[(hidx[K(x, y)] or 1)] then
    if h > 0.93 then c:put(x, y, PASTE[1], ptok) elseif h < 0.035 then c:put(x, y, STEMC[4], ptok) end end end)
-- glossy paste specular
c:put(CX - 5, Y0 - 12, SPEC, ptok) c:put(CX - 4, Y0 - 12, PASTE[6], ptok)

-- lip in front of heap
local lidx = A.shade(c, lip, nl, GLAZE, { amb = 0.08, wrap = 0.3, tok = gtok })
for x = CX - 8, CX + 7 do c:put(x, Y0 + 1, GLAZE[1], gtok) end   -- AO under the rolled lip
c:put(CX - 7, Y0 - 2, SPEC, gtok) c:put(CX - 6, Y0 - 2, GLAZE[6], gtok)

-- quirk: fermentation bubble
for _, q in ipairs{ { 22, 15, "#fff4d6" }, { 23, 14, "#e4dcc8" }, { 21, 14, "#e4dcc8" }, { 22, 13, "#c9c0b8" } } do
  c:put(q[1], q[2], q[3], { r = { name = "bubble" } }) end
c:put(22, 14, "#f8c8a0", { r = { name = "bubble" } })

A.save(c, NAME)

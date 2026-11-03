-- ico-arrow-down (final pass, Opus single pass). Bold icon: a hand-cut wooden sign arrow pointing down, painted
-- sea blue. Slim 11 px shaft, broad head with slightly hollowed (concave) barbs. Per-pixel bevelled light
-- (6-tone blue, cool shade side lower-right, bright lit edge upper-left), worn paint chips on the edges showing the
-- wood beneath (grain + paler end grain at the square-cut top), a nail head with a dark eye, AO where the head
-- meets the shaft. Rope cue: a twisted twine lashing round the shaft.
-- quirk: the twine's loose end has come undone and dangles off to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA0_3.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-arrow-down")
local BLUE = { "#22345e", "#2c5488", "#3a7cb4", "#4fa6d2", "#7ccce0", "#c0f0ec" }
local WOOD = { "#4a2a26", "#7a4a32", "#a8703e", "#d09a5c", "#ecc488" }
local TW   = { "#7a4a22", "#b8782c", "#e0a844", "#ffd878" }
local btok, wtok = { r = { name = "paint" } }, { r = { name = "wood" } }

-- silhouette: shaft + head (concave barbs, blunt 3 px tip)
local shaft = c:rect(27, 6, 37, 33)
local head = c:poly{ { 9, 35 }, { 26, 30 }, { 38, 30 }, { 55, 35 }, { 34, 57 }, { 30, 57 } }
local m = shaft:copy():add(head)
local np, d = X.pillow(m, 2.5)
-- carved ridge down the middle: left plane faces upper-left (lit), right plane faces right (shade)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local p = np[k]
  local tx = x <= 32 and -0.42 or 0.5
  local ty = x <= 32 and -0.12 or 0.1
  n[k] = { T.norm(p[1] * 1.3 + tx, p[2] * 1.3 + ty, p[3]) }
end)
local bias = {}
-- AO in the inner corners where head meets shaft
m:each(function(x, y) local k = K(x, y)
  if not shaft:has(x, y) and y <= 33 and (x == 26 or x == 25 or x == 38 or x == 39) then bias[k] = -1 end
  if not shaft:has(x, y) and y <= 32 and (x == 26 or x == 38) then bias[k] = -2 end
end)
local idx = T.shade(c, m, n, BLUE, { amb = 0.05, wrap = 0.2, bias = bias, tok = btok, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 } })
-- ridge: one bright line on the lit side of the crest
m:each(function(x, y) if x == 32 and d[K(x, y)] > 1 then c:put(x, y, BLUE[6], btok) c:put(x + 1, y, BLUE[3], btok) end end)
-- crisp lit edge on the upper-left facing borders
m:each(function(x, y) local k = K(x, y)
  local p = np[k]
  if d[k] and d[k] < 1 and p[1] < -0.3 and p[2] < 0.5 and x < 32 then c:put(x, y, BLUE[5], btok) end
  if d[k] and d[k] < 1 and p[2] < -0.3 and x < 32 then c:put(x, y, BLUE[5], btok) end
end)
-- wood grain ghosting through the paint: two long broken lines on each plane
for _, gx in ipairs{ 29, 35 } do for y = 9, 52 do
  if m:has(gx, y) and d[K(gx, y)] > 1.5 and X.hash(gx, y // 3, 5) > 0.35 then T.step(c, idx, BLUE, gx, y, -1, btok) end end end
for _, g in ipairs{ { 18, 36, 25, 46 }, { 46, 36, 39, 46 } } do
  local nn = max(abs(g[3] - g[1]), abs(g[4] - g[2]))
  for i = 0, nn do local x, y = floor(g[1] + (g[3] - g[1]) * i / nn + .5), floor(g[2] + (g[4] - g[2]) * i / nn + .5)
    if i % 5 ~= 4 then T.step(c, idx, BLUE, x, y, -1, btok) end end
end
-- worn chips: paint flaked off at the edges, wood shows (lit / shade wood + dark rim)
local function chip(rows, x0, y0)
  T.map(c, rows, x0, y0, { w = WOOD[4], v = WOOD[3], u = WOOD[2], g = WOOD[5], b = BLUE[2] }, wtok)
end
-- square-cut top: end grain (pale) with growth rings
T.map(c, {
  "gggggwwwwww",
  "wvgggwwvwww",
}, 27, 6, { g = WOOD[5], w = WOOD[4], v = WOOD[3] }, wtok)
c:put(27, 8, WOOD[3], wtok) c:put(37, 8, WOOD[2], wtok) c:put(37, 7, WOOD[3], wtok)
chip({ "gw", "wv", ".u" }, 10, 34)
chip({ "ww.", "vu" }, 52, 34)
chip({ "ww", "vu" }, 31, 55)
chip({ "w", "v", "u" }, 37, 22)
-- nail through the shaft: bright rim, dark eye
T.map(c, { ".ss.", "shDs", "sDDd", ".dd." }, 30, 37, { s = "#e2e0e6", h = "#ffffee", D = "#444663", d = "#74758c" }, { r = { name = "nail" } })
-- rust tear under the nail
c:put(32, 41, "#8f4a1f") c:put(32, 42, BLUE[2])

-- twine lashing: 4 wraps on the shaft (twist: diagonal lit strands), wraps overlap the edges by 1 px
local ttok = { r = { name = "twine" } }
for y = 13, 21 do
  local r = (y - 13) % 3
  for x = 26, 38 do
    local tone
    if r == 2 then tone = 1 else
      local q = (x + r * 2 + (y // 3)) % 3
      tone = q == 0 and 4 or (q == 1 and 3 or 2)
    end
    if (x == 26 or x == 38) and tone > 1 then tone = tone - 1 end
    if x > 33 and tone > 2 then tone = tone - 1 end
    if not (r == 2 and (x == 26 or x == 38)) then c:put(x, y, TW[tone], ttok) end
  end
end
-- quirk: the twine's loose end has come undone and dangles off to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA0_3.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-arrow-down")
local BLUE = { "#22345e", "#2c5488", "#3a7cb4", "#4fa6d2", "#7ccce0", "#c0f0ec" }
local WOOD = { "#4a2a26", "#7a4a32", "#a8703e", "#d09a5c", "#ecc488" }
local TW   = { "#7a4a22", "#b8782c", "#e0a844", "#ffd878" }
local btok, wtok = { r = { name = "paint" } }, { r = { name = "wood" } }

-- silhouette: shaft + head (concave barbs, blunt 3 px tip)
local shaft = c:rect(27, 6, 37, 33)
local head = c:poly{ { 9, 35 }, { 26, 30 }, { 38, 30 }, { 55, 35 }, { 34, 57 }, { 30, 57 } }
local m = shaft:copy():add(head)
local np, d = X.pillow(m, 2.5)
-- carved ridge down the middle: left plane faces upper-left (lit), right plane faces right (shade)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local p = np[k]
  local tx = x <= 32 and -0.42 or 0.5
  local ty = x <= 32 and -0.12 or 0.1
  n[k] = { T.norm(p[1] * 1.3 + tx, p[2] * 1.3 + ty, p[3]) }
end)
local bias = {}
-- AO in the inner corners where head meets shaft
m:each(function(x, y) local k = K(x, y)
  if not shaft:has(x, y) and y <= 33 and (x == 26 or x == 25 or x == 38 or x == 39) then bias[k] = -1 end
  if not shaft:has(x, y) and y <= 32 and (x == 26 or x == 38) then bias[k] = -2 end
end)
local idx = T.shade(c, m, n, BLUE, { amb = 0.05, wrap = 0.2, bias = bias, tok = btok, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 } })
-- ridge: one bright line on the lit side of the crest
m:each(function(x, y) if x == 32 and d[K(x, y)] > 1 then c:put(x, y, BLUE[6], btok) c:put(x + 1, y, BLUE[3], btok) end end)
-- crisp lit edge on the upper-left facing borders
m:each(function(x, y) local k = K(x, y)
  local p = np[k]
  if d[k] and d[k] < 1 and p[1] < -0.3 and p[2] < 0.5 and x < 32 then c:put(x, y, BLUE[5], btok) end
  if d[k] and d[k] < 1 and p[2] < -0.3 and x < 32 then c:put(x, y, BLUE[5], btok) end
end)
-- wood grain ghosting through the paint: two long broken lines on each plane
for _, gx in ipairs{ 29, 35 } do for y = 9, 52 do
  if m:has(gx, y) and d[K(gx, y)] > 1.5 and X.hash(gx, y // 3, 5) > 0.35 then T.step(c, idx, BLUE, gx, y, -1, btok) end end end
for _, g in ipairs{ { 18, 36, 25, 46 }, { 46, 36, 39, 46 } } do
  local nn = max(abs(g[3] - g[1]), abs(g[4] - g[2]))
  for i = 0, nn do local x, y = floor(g[1] + (g[3] - g[1]) * i / nn + .5), floor(g[2] + (g[4] - g[2]) * i / nn + .5)
    if i % 5 ~= 4 then T.step(c, idx, BLUE, x, y, -1, btok) end end
end
-- worn chips: paint flaked off at the edges, wood shows (lit / shade wood + dark rim)
local function chip(rows, x0, y0)
  T.map(c, rows, x0, y0, { w = WOOD[4], v = WOOD[3], u = WOOD[2], g = WOOD[5], b = BLUE[2] }, wtok)
end
-- square-cut top: end grain (pale) with growth rings
T.map(c, {
  "gggggwwwwww",
  "wvgggwwvwww",
}, 27, 6, { g = WOOD[5], w = WOOD[4], v = WOOD[3] }, wtok)
c:put(27, 8, WOOD[3], wtok) c:put(37, 8, WOOD[2], wtok) c:put(37, 7, WOOD[3], wtok)
chip({ "gw", "wv", ".u" }, 10, 34)
chip({ "ww.", "vu" }, 52, 34)
chip({ "ww", "vu" }, 31, 55)
chip({ "w", "v", "u" }, 37, 22)
-- nail through the shaft: bright rim, dark eye
T.map(c, { ".ss.", "shDs", "sDDd", ".dd." }, 30, 37, { s = "#e2e0e6", h = "#ffffee", D = "#444663", d = "#74758c" }, { r = { name = "nail" } })
-- rust tear under the nail
c:put(32, 41, "#8f4a1f") c:put(32, 42, BLUE[2])

-- twine lashing: 4 wraps on the shaft (twist: diagonal lit strands), wraps overlap the edges by 1 px
local ttok = { r = { name = "twine" } }
for y = 13, 20 do
  for x = 26, 38 do
    local s = (x + y * 2) % 4
    local edge = (x == 26 or x == 38)
    local tone = s == 0 and 4 or (s == 1 and 3 or (s == 2 and 2 or 1))
    if edge then tone = max(1, tone - 1) end
    if x > 34 then tone = max(1, tone - 1) end
    if y == 20 then tone = 1 end
    c:put(x, y, TW[tone], ttok)
  end
end
-- quirk: the loose end has come undone and dangles off to the right in a lazy curl
local loose = { { 39, 16 }, { 40, 17 }, { 41, 18 }, { 42, 19 }, { 42, 20 }, { 43, 21 }, { 43, 22 }, { 43, 23 }, { 44, 24 }, { 45, 24 }, { 46, 23 } }
for i, p in ipairs(loose) do
  c:put(p[1], p[2], i % 2 == 0 and TW[2] or TW[3], ttok)
  c:put(p[1] + 1, p[2], TW[1], ttok)
  if i <= 7 then c:put(p[1], p[2] + 1, TW[2], ttok) end
end
-- frayed tip
c:put(47, 22, TW[3], ttok) c:put(47, 24, TW[3], ttok)
-- cream glint on the lit bevel at the top-left of the head
c:put(14, 35, T.CREAM, btok)
T.save(c, "ico-arrow-down", "ico")

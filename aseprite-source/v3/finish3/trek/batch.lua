-- trek tiles v3 (finish3). One parameterised script: --script-param name=<trek-name>|all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../../lib/hp.lua")
local GX = dofile(d .. "/../../gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs, pi = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs, math.pi
local INK = "#2b1c26"
local mix = GX.mix

---------------------------------------------------------------- helpers
local function H(x, y, s)
  local n = (x * 374761393 + y * 668265263 + s * 2147483647) & 0xffffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65536
end
local function pn(x, y, sc, s, W, Hh)   -- periodic value noise (period W x Hh, cell sc divides both)
  W = W or 42; Hh = Hh or W
  local nx, ny = W // sc, Hh // sc
  local gx, gy = x / sc, y / sc
  local x0, y0 = floor(gx), floor(gy)
  local fx, fy = gx - x0, gy - y0
  fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
  local function h(i, j) return H(i % nx, j % ny, s) end
  local a, b, c, e = h(x0, y0), h(x0 + 1, y0), h(x0, y0 + 1), h(x0 + 1, y0 + 1)
  return a + (b - a) * fx + (c - a) * fy + (a - b - c + e) * fx * fy
end
local function newT(w, h, wrap)
  local T = { w = w, h = h, wrap = wrap, c = HP.canvas{ w = w, h = h, scale = 1, name = "t" } }
  function T.p(x, y, col)
    x = floor(x); y = floor(y)
    if wrap then x = x % w; y = y % h end
    T.c:put(x, y, col)
  end
  function T.g(x, y) x = floor(x); y = floor(y); if wrap then x = x % w; y = y % h end return T.c:get(x, y) end
  return T
end
local function fillAll(T, f) for y = 0, T.h - 1 do for x = 0, T.w - 1 do local col = f(x, y); if col then T.p(x, y, col) end end end end
local function ground(T, o)   -- patchy periodic ground: o.b base, o.dk dark, o.lt light
  local s = o.seed or 1
  fillAll(T, function(x, y)
    local v = pn(x, y, 7, s) * .55 + pn(x, y, 3, s + 5) * .45
    local col = o.b
    if v < (o.td or .33) then col = o.dk elseif v > (o.tl or .7) then col = o.lt end
    local r = H(x, y, s + 9)
    if r < (o.sd or .02) then col = o.dk2 or o.dk elseif r > 1 - (o.sl or .02) then col = o.lt2 or o.lt end
    return col
  end)
end
-- blob mask: rough ellipse
local function blob(cx, cy, rx, ry, seed, rough)
  local m = HP.mask()
  rough = rough or .18
  for y = floor(cy - ry - 2), math.ceil(cy + ry + 2) do for x = floor(cx - rx - 2), math.ceil(cx + rx + 2) do
    local dx, dy = (x + .5 - cx) / rx, (y + .5 - cy) / ry
    local a = math.atan(dy, dx)
    local k = 1 + rough * (H(floor((a + pi) * 2.2), 7, seed) - .5) * 2
    if dx * dx + dy * dy <= k * k then m:set(x, y) end
  end end
  return m
end
-- lit(T, mask, ramp{hi,base,shade}, o{rim,rimTL,shadow,l1,l2})
local function lit(T, m, R, o)
  o = o or {}
  local x0, y0, x1, y1 = m:bbox()
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local rad = max(x1 - x0, y1 - y0) / 2 + .5
  if o.shadow then m:each(function(x, y) if not m:has(x + 1, y + 1) then T.p(x + 1, y + 1, o.shadow) end end) end
  m:each(function(x, y)
    local up, lf, dn, rt = not m:has(x, y - 1), not m:has(x - 1, y), not m:has(x, y + 1), not m:has(x + 1, y)
    local col
    if o.rim ~= false and (up or lf or dn or rt) then
      if (dn or rt) then col = o.rim or INK else col = o.rimTL or R.shade end
    else
      local l = -((x - cx) * .6 + (y - cy) * .8) / rad
      col = l > (o.l1 or .42) and R.hi or (l > (o.l2 or -.25) and R.base or R.shade)
    end
    T.p(x, y, col)
  end)
end
local function pebble(T, cx, cy, rx, ry, R, sh, seed, o)
  o = o or {}; o.shadow = sh
  lit(T, blob(cx, cy, rx, ry, seed or 3, .12), R, o)
end
local function bmp(T, x0, y0, rows, map)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i); local col = map[ch]
    if col then T.p(x0 + i - 1, y0 + j - 1, col) end
  end end
end
local function seg(T, x0, y0, x1, y1, col, th)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for s = 0, n do
    local x, y = floor(x0 + (x1 - x0) * s / n + .5), floor(y0 + (y1 - y0) * s / n + .5)
    T.p(x, y, col); if th and th > 1 then T.p(x + 1, y, col) end
  end
end
local function walk(T, x, y, n, dx, dy, col, seed, o)   -- jagged crack
  o = o or {}
  for i = 1, n do
    T.p(x, y, col)
    if o.edge then T.p(x + 1, y + 1, o.edge) end
    local r = H(i, floor(x), seed)
    if r < .35 then x = x + dx elseif r < .7 then y = y + dy else x = x + dx; y = y + dy end
    if H(i, 3, seed + 2) < (o.turn or .2) then dx, dy = dy * (H(i, 5, seed) < .5 and 1 or -1), dx * (H(i, 7, seed) < .5 and 1 or -1) end
    if dx == 0 and dy == 0 then dx = 1 end
  end
  return x, y
end
local function path(T, pts, R, th)   -- thick lit root/twig through points
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    local flat = abs(b[1] - a[1]) >= abs(b[2] - a[2])
    for s = 0, n do
      local x, y = floor(a[1] + (b[1] - a[1]) * s / n + .5), floor(a[2] + (b[2] - a[2]) * s / n + .5)
      if flat then
        T.p(x, y + 1, R.shade); T.p(x, y, R.base); if th >= 3 then T.p(x, y - 1, R.hi) end
        if th >= 4 then T.p(x, y + 2, R.deep or R.shade) end
        if th >= 3 then T.p(x, y + 2, R.deep or INK) elseif th == 2 then T.p(x, y + 2, R.deep or INK) end
      else
        T.p(x + 1, y, R.shade); T.p(x, y, R.base); if th >= 3 then T.p(x - 1, y, R.hi) end
        if th >= 3 then T.p(x + 2, y, R.deep or INK) elseif th == 2 then T.p(x + 2, y, R.deep or INK) end
      end
    end
  end
end
local function tuft(T, x, y, G, h)
  h = h or 5
  local bl = { { -2, h - 2, -1 }, { 0, h, 0 }, { 2, h - 2, 1 }, { -1, h - 3, 0 }, { 1, h - 1, 0 } }
  for _, b in ipairs(bl) do
    for k = 0, b[2] - 1 do
      local xx = x + b[1] + ((k >= b[2] - 2) and b[3] or 0)
      T.p(xx, y - k, k == b[2] - 1 and G.hi or (k < 1 and G.shade or G.base))
    end
  end
end
local function sparkle(T, x, y, col, big)
  T.p(x, y, col); T.p(x - 1, y, col); T.p(x + 1, y, col); T.p(x, y - 1, col); T.p(x, y + 1, col)
  if big then T.p(x, y - 2, col); T.p(x, y + 2, col) end
end
local function pit(T, cx, cy, rx, ry, seed, deep, lip, rimc)   -- dug hole, lip lit on lower-right
  local m = blob(cx, cy, rx, ry, seed, .15)
  m:each(function(x, y)
    if not m:has(x + 1, y + 1) then T.p(x + 1, y + 1, lip) end
  end)
  m:each(function(x, y)
    local c = deep
    if not m:has(x - 1, y) or not m:has(x, y - 1) then c = rimc end
    T.p(x, y, c)
  end)
end

---------------------------------------------------------------- palettes
local O = { b = "#9a6b3f", dk = "#8b5a31", dk2 = "#7a4a1f", lt = "#a87a4a", lt2 = "#c9a96e", deep = "#4a2c1a", pale = "#d9ba7c" }
local U = { b = "#8a5a30", dk = "#7a4c28", dk2 = "#5c3520", lt = "#96643a", lt2 = "#b88850", deep = "#33221a" }
local MUD = { b = "#7a4a1f", dk = "#6a3f1a", dk2 = "#5c3520", lt = "#87531f", lt2 = "#9a6b3f", deep = "#3d2a1c" }
local STONE_O = { hi = "#d9d3c8", base = "#a8a9ac", shade = "#7e8190" }
local GRN = { hi = "#a4b86a", base = "#4f9a45", shade = "#2f5a2a" }
local PEB = { hi = "#e6cf98", base = "#c9a96e", shade = "#9a7a48" }
local PEBU = { hi = "#b88850", base = "#8b5a31", shade = "#6e4426" }
local WOOD = { hi = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#4a2c1a" }
local GOLD = { hi = "#fff1c8", base = "#f5cf6a", shade = "#e8a317", deep = "#b8661a" }

---------------------------------------------------------------- tile recipes
local R = {}
R["floor-o-1"] = function(T)
  ground(T, O); T.seed = 1
  pebble(T, 10, 12, 3.5, 2.5, PEB, "#7a4a1f", 3); pebble(T, 16, 15, 2, 1.5, PEB, "#7a4a1f", 4)
  pebble(T, 31, 8, 2, 1.5, STONE_O, "#7a4a1f", 5); pebble(T, 24, 32, 3, 2, PEB, "#7a4a1f", 6)
  tuft(T, 33, 24, GRN, 4); tuft(T, 8, 33, GRN, 3)
  for _, p in ipairs{ { 20, 6 }, { 38, 36 }, { 5, 24 }, { 27, 19 } } do T.p(p[1], p[2], "#4a2c1a"); T.p(p[1] + 1, p[2], "#4a2c1a") end
end
R["floor-o-2"] = function(T)
  ground(T, O, 2); ground(T, { b = O.b, dk = O.dk, dk2 = O.dk2, lt = O.lt, lt2 = O.lt2, seed = 2 })
  for _, s in ipairs{ { 6, 7, 6 }, { 26, 6, 7 }, { 15, 28, 8 }, { 32, 24, 5 }, { 3, 36, 5 } } do
    for i = 0, s[3] - 1 do T.p(s[1] + i, s[2], O.pale); T.p(s[1] + i, s[2] + 1, "#c9a96e") end
    T.p(s[1], s[2] + 1, O.deep)
  end
  path(T, { { 10, 20 }, { 16, 22 }, { 22, 20 }, { 26, 17 } }, WOOD, 2)
  path(T, { { 17, 22 }, { 19, 27 } }, WOOD, 2)
  for _, p in ipairs{ { 8, 17 }, { 34, 33 }, { 36, 14 } } do T.p(p[1], p[2], "#3d2a1c"); T.p(p[1] + 1, p[2] + 1, "#3d2a1c") end
end
R["floor-o-3"] = function(T)
  ground(T, O)
  tuft(T, 31, 16, GRN, 6); tuft(T, 36, 20, GRN, 5); tuft(T, 9, 31, GRN, 4); tuft(T, 15, 9, GRN, 4); tuft(T, 26, 37, GRN, 4)
  local clv = { ".g.g.", "ggggg", ".ggg.", "..s.." }
  bmp(T, 7, 12, { ".h.h.", "hbhbh", ".bbb.", "..s.." }, { h = "#7ab55c", b = "#4a8a3e", s = "#2f5a2a" })
  bmp(T, 20, 24, { ".h.h.", "hbhbh", ".bbb.", "..s.." }, { h = "#7ab55c", b = "#4a8a3e", s = "#2f5a2a" })
  pebble(T, 36, 36, 2, 1.5, PEB, "#7a4a1f", 8)
  for _, p in ipairs{ { 4, 5 }, { 24, 12 }, { 38, 6 } } do T.p(p[1], p[2], "#4a2c1a") end
end
R["floor-u-1"] = function(T)
  ground(T, U)
  pebble(T, 10, 12, 4.5, 3.5, PEBU, "#4a2c1a", 3, { rim = INK })
  pebble(T, 30, 29, 4, 3, PEBU, "#4a2c1a", 4, { rim = INK })
  pebble(T, 22, 8, 1.5, 1, PEBU, "#4a2c1a", 5); pebble(T, 8, 33, 2, 1.5, PEBU, "#4a2c1a", 6)
  for _, p in ipairs{ { 20, 20 }, { 36, 10 }, { 4, 24 }, { 28, 38 } } do T.p(p[1], p[2], "#33221a"); T.p(p[1] + 1, p[2], "#5c3520") end
end
R["floor-u-2"] = function(T)
  ground(T, U, 2); ground(T, { b = U.b, dk = U.dk, dk2 = U.dk2, lt = U.lt, lt2 = U.lt2, seed = 4 })
  walk(T, 4, 10, 16, 1, 0, "#33221a", 11, { edge = "#96643a", turn = .12 })
  walk(T, 22, 30, 12, 1, 1, "#33221a", 12, { edge = "#96643a", turn = .2 })
  pebble(T, 32, 14, 2.5, 2, PEBU, "#4a2c1a", 5); pebble(T, 12, 30, 2, 1.5, PEBU, "#4a2c1a", 6)
  bmp(T, 33, 4, { ".b.", "bhb", ".b." }, { b = "#6ac0d8", h = "#c8ecdc" })   -- drip puddle
  bmp(T, 33, 4, { "...", ".h.", "..." }, { h = "#a9d6ea" })
  for _, p in ipairs{ { 18, 18 }, { 38, 34 }, { 6, 38 } } do T.p(p[1], p[2], "#33221a") end
end
R["floor-u-3"] = function(T)
  ground(T, U, 3)
  for y = 0, 41 do for x = 0, 41 do
    local v = pn(x, y, 14, 21)
    if v > .62 then T.p(x, y, v > .72 and "#4a4632" or "#5a5438") end
  end end
  bmp(T, 12, 22, { "..hh..", ".hbbh.", "hbbbbh", "..ss.." }, { h = "#ff8a5c", b = "#e8493b", s = "#e8d2a0" })   -- tiny toadstool
  bmp(T, 21, 30, { "ss", "ss" }, { s = "#e8d2a0" })
  pebble(T, 34, 10, 2.5, 2, PEBU, "#4a2c1a", 5); pebble(T, 6, 8, 2, 1.5, PEBU, "#4a2c1a", 6)
  for _, p in ipairs{ { 8, 18 }, { 30, 24 }, { 28, 38 }, { 38, 20 } } do T.p(p[1], p[2], "#33221a"); T.p(p[1] + 1, p[2] + 1, "#33221a") end
end

local function mudBase(T, s) ground(T, MUD, s)
  for y = 0, 41 do for x = 0, 41 do
    local v = pn(x, y, 6, s + 20)
    if v > .74 and H(x, y, s) > .45 then T.p(x, y, "#8b5a31") end
  end end
end
R["mud-o-1"] = function(T) mudBase(T, 1)
  pit(T, 12, 14, 5, 3.5, 1, "#3d2a1c", "#9a6b3f", "#5c3520"); pit(T, 30, 30, 4, 3, 2, "#3d2a1c", "#9a6b3f", "#5c3520")
  for _, s in ipairs{ { 24, 10, 7 }, { 6, 30, 6 } } do for i = 0, s[3] do T.p(s[1] + i, s[2], "#9a6b3f"); T.p(s[1] + i + 1, s[2] + 1, "#5c3520") end end
  T.p(36, 8, "#3d2a1c"); T.p(20, 22, "#3d2a1c")
end
R["mud-o-2"] = function(T) mudBase(T, 2)
  pit(T, 10, 12, 4, 3, 3, "#3d2a1c", "#9a6b3f", "#5c3520"); pit(T, 30, 13, 4.5, 3, 4, "#3d2a1c", "#9a6b3f", "#5c3520")
  pit(T, 20, 33, 3, 2, 5, "#3d2a1c", "#9a6b3f", "#5c3520")
  path(T, { { 6, 26 }, { 14, 30 }, { 24, 25 } }, { hi = "#c9a96e", base = "#9a6b3f", shade = "#5c3520", deep = "#3d2a1c" }, 2)
  T.p(37, 33, "#3d2a1c"); T.p(36, 24, "#3d2a1c")
end
R["mud-u"] = function(T) mudBase(T, 3)
  pit(T, 21, 18, 6, 4.5, 6, "#3d2a1c", "#9a6b3f", "#5c3520")
  bmp(T, 20, 17, { "bh", "bb" }, { b = "#6ac0d8", h = "#a9d6ea" })
  pit(T, 8, 33, 3, 2, 7, "#3d2a1c", "#9a6b3f", "#5c3520"); pit(T, 34, 8, 3, 2.5, 8, "#3d2a1c", "#9a6b3f", "#5c3520")
  T.p(31, 30, "#a9d6ea"); T.p(31, 31, "#6ac0d8"); T.p(5, 10, "#a9d6ea")
end

local SAGE = { b = "#7d8a62", dk = "#6f7c55", dk2 = "#5a6845", lt = "#8e9a70", lt2 = "#a4b86a" }
local RT = { hi = "#c9a96e", base = "#9a6b3f", shade = "#7a4a1f", deep = "#4a2c1a" }
R["roots-o-1"] = function(T) ground(T, SAGE, 1)
  path(T, { { 3, 33 }, { 12, 28 }, { 22, 22 }, { 31, 15 }, { 39, 10 } }, RT, 4)
  path(T, { { 21, 23 }, { 24, 30 } }, RT, 2)
  tuft(T, 8, 14, GRN, 4); tuft(T, 33, 36, GRN, 4); T.p(16, 26, "#4f9a45"); T.p(26, 20, "#4f9a45"); T.p(30, 14, "#7ab55c")
  for _, p in ipairs{ { 6, 6 }, { 28, 6 }, { 38, 28 } } do T.p(p[1], p[2], "#3a4530") end
end
R["roots-o-2"] = function(T) ground(T, SAGE, 2)
  path(T, { { 6, 6 }, { 15, 16 }, { 23, 26 }, { 33, 36 } }, RT, 3)
  path(T, { { 36, 8 }, { 28, 16 }, { 20, 22 }, { 15, 16 } }, RT, 3)
  pebble(T, 31, 28, 3, 2.2, STONE_O, "#5a6845", 7)
  bmp(T, 18, 20, { ".h.", "hbh" }, { h = "#7ab55c", b = "#4f9a45" })
  tuft(T, 8, 34, GRN, 4); T.p(36, 18, "#3a4530"); T.p(6, 20, "#3a4530")
end
R["roots-u"] = function(T) ground(T, { b = "#4a4632", dk = "#403d2c", dk2 = "#38352a", lt = "#555038", lt2 = "#5e5840" }, 3)
  local T2 = { hi = "#e6cf98", base = "#c9a96e", shade = "#9a6b3f", deep = "#4a2c1a" }
  path(T, { { 21, 4 }, { 21, 14 }, { 20, 22 } }, T2, 3)
  path(T, { { 20, 22 }, { 12, 26 }, { 6, 33 } }, T2, 2); path(T, { { 20, 22 }, { 29, 27 }, { 36, 33 } }, T2, 2)
  path(T, { { 21, 12 }, { 29, 9 }, { 36, 10 } }, T2, 2); path(T, { { 21, 14 }, { 13, 11 }, { 7, 12 } }, T2, 2)
  path(T, { { 20, 22 }, { 21, 33 }, { 20, 39 } }, T2, 2)
  bmp(T, 4, 29, { "h.h", ".b." }, { h = "#a4b86a", b = "#4f9a45" }); bmp(T, 36, 29, { "h.h", ".b." }, { h = "#a4b86a", b = "#4f9a45" })
  T.p(8, 6, "#38352a"); T.p(34, 4, "#38352a"); T.p(3, 18, "#38352a")
end

R["clay-loose"] = function(T) ground(T, { b = "#7a4a1f", dk = "#6e4220", dk2 = "#5c3520", lt = "#8b5a31", lt2 = "#9a6b3f", sd = .015, sl = .02 }, 1)
  walk(T, 8, 4, 18, 0, 1, "#3d2a1c", 5, { edge = "#8b5a31", turn = .25 })
  walk(T, 20, 3, 20, 0, 1, "#3d2a1c", 6, { edge = "#8b5a31", turn = .28 })
  walk(T, 14, 22, 10, -1, 1, "#3d2a1c", 7, { edge = "#8b5a31", turn = .3 })
  pebble(T, 31, 16, 2.5, 2, PEB, "#4a2c1a", 8); pebble(T, 9, 33, 2.5, 2, PEB, "#4a2c1a", 9); pebble(T, 36, 34, 1.5, 1.2, PEB, "#4a2c1a", 4)
end
R["clay-wet"] = function(T)
  fillAll(T, function(x, y)
    local ph = y + floor(2 * sin(2 * pi * x / 14 + 1) + .5)
    local m = ph % 7
    if m == 0 then return "#c0662c" elseif m == 1 or m == 2 then return "#a85a28" elseif m == 6 then return "#6a3820" else return "#944c1f" end
  end)
  pebble(T, 12, 14, 3.5, 3, PEB, "#6a3820", 3); pebble(T, 30, 29, 3.5, 3, PEB, "#6a3820", 4)
  for _, p in ipairs{ { 26, 6 }, { 6, 32 }, { 38, 20 } } do T.p(p[1], p[2], "#e0883c"); T.p(p[1] + 1, p[2], "#c0662c") end
end
R["drained"] = function(T) ground(T, { b = "#7a4a1f", dk = "#6e4220", dk2 = "#5c3520", lt = "#8b5a31", lt2 = "#9a6b3f" }, 4)
  local m = blob(21, 21, 14, 11, 9, .16)
  m:each(function(x, y) T.p(x, y, "#5c3520") end)
  m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then T.p(x, y, "#3d2a1c") end end)
  local w = blob(21, 22, 6, 4, 3, .2)
  w:each(function(x, y) T.p(x, y, "#25637d") end)
  w:shrink(1):each(function(x, y) T.p(x, y, "#3f8fb0") end)
  T.p(19, 20, "#a9d6ea"); T.p(20, 20, "#a9d6ea"); T.p(23, 23, "#6ac0d8")
  for _, p in ipairs{ { 4, 6 }, { 36, 34 }, { 38, 8 } } do T.p(p[1], p[2], "#4a2c1a") end
  pebble(T, 7, 33, 2, 1.5, PEB, "#4a2c1a", 5)
end

local CH = { b = "#143645", dk = "#10303f", dk2 = "#0e2433", lt = "#18405a", lt2 = "#24556b", sd = .015, sl = .015 }
R["chasm-1"] = function(T) ground(T, CH, 1)
  local m = blob(21, 20, 10, 7, 5, .2)
  m:each(function(x, y) T.p(x + 1, y + 2, "#24556b") end)
  m:each(function(x, y) T.p(x, y, "#091623") end)
  m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then T.p(x, y, "#0e2433") end end)
  seg(T, 8, 33, 14, 35, "#2d6479"); seg(T, 14, 35, 22, 35, "#2d6479"); seg(T, 28, 6, 34, 8, "#24556b"); seg(T, 3, 10, 7, 11, "#24556b")
  T.p(33, 33, "#2d6479"); T.p(34, 33, "#2d6479")
end
R["chasm-2"] = function(T) ground(T, CH, 2)
  for _, l in ipairs{ { 4, 8, 22 }, { 12, 14, 24 }, { 6, 22, 16 } } do
    for i = 0, l[3] - 1 do T.p(l[1] + i, l[2], "#0e2433"); T.p(l[1] + i, l[2] + 1, "#24556b") end
  end
  for i = 0, 11 do T.p(16 + i, 33, "#091623"); T.p(16 + i, 34, "#091623"); T.p(16 + i, 35, "#0e2433") end
  T.p(36, 12, "#33221a"); T.p(37, 12, "#5c3520"); seg(T, 26, 26, 34, 28, "#2d6479")
end

local BL = { b = "#4e3a8a", dk = "#463480", dk2 = "#3e2f66", lt = "#5a449a", lt2 = "#7a5cc0", sd = .02, sl = .01 }
local BLU = { b = "#3e2f66", dk = "#372a5a", dk2 = "#291d4a", lt = "#4a3878", lt2 = "#4e3a8a", sd = .02, sl = .01 }
local function spore(T, x, y) T.p(x, y, "#a894dc"); T.p(x + 1, y, "#7a5cc0"); T.p(x, y + 1, "#7a5cc0"); T.p(x + 1, y + 1, "#4a3878") end
R["blight-o-1"] = function(T) ground(T, BL, 1)
  walk(T, 10, 4, 10, 1, 1, "#291d4a", 3, { turn = .3 }); walk(T, 26, 16, 12, -1, 1, "#291d4a", 4, { turn = .3 })
  pebble(T, 9, 28, 3, 2.5, { hi = "#a894dc", base = "#7a5cc0", shade = "#463480" }, "#291d4a", 3)
  pebble(T, 31, 12, 2.5, 2, { hi = "#a894dc", base = "#7a5cc0", shade = "#463480" }, "#291d4a", 4)
  spore(T, 24, 32); spore(T, 18, 14); spore(T, 36, 28); T.p(4, 17, "#a894dc")
end
R["blight-o-2"] = function(T) ground(T, BL, 2)
  local P2 = { hi = "#a894dc", base = "#7a5cc0", shade = "#463480", deep = "#291d4a" }
  path(T, { { 21, 34 }, { 21, 26 }, { 22, 18 } }, P2, 3)
  pebble(T, 22, 14, 4.5, 4, P2, "#291d4a", 5)
  bmp(T, 21, 13, { "h", " " }, { h = "#d8c8f4" })
  path(T, { { 21, 28 }, { 14, 24 } }, P2, 2); path(T, { { 22, 25 }, { 29, 22 } }, P2, 2)
  walk(T, 6, 8, 8, 1, 1, "#291d4a", 6, { turn = .3 })
  spore(T, 8, 30); spore(T, 33, 32); spore(T, 4, 20); spore(T, 36, 8)
end
R["blight-u"] = function(T) ground(T, BLU, 3)
  local P2 = { hi = "#a894dc", base = "#7a5cc0", shade = "#463480", deep = "#291d4a" }
  for _, e in ipairs{ { 8, 8 }, { 34, 8 }, { 8, 34 }, { 34, 34 } } do path(T, { { 21, 21 }, { e[1], e[2] } }, P2, 2) end
  pebble(T, 21, 21, 4.5, 4, P2, "#291d4a", 5)
  bmp(T, 20, 19, { "hh", "h." }, { h = "#d8c8f4" })
  for _, e in ipairs{ { 8, 8 }, { 34, 8 }, { 8, 34 }, { 34, 34 } } do spore(T, e[1] - 1, e[2] - 1) end
  T.p(21, 5, "#7a5cc0"); T.p(4, 21, "#7a5cc0"); T.p(37, 22, "#7a5cc0")
end

local function crystal(T, cx, top, cy, bot, hw)
  local m = HP.mask()
  for y = top, bot do
    local w = (y <= cy) and hw * (y - top + 1) / (cy - top + 1) or hw * (bot - y + 1) / (bot - cy + 1)
    for x = floor(cx - w + .5), floor(cx + w - .5) do m:set(x, y) end
  end
  m:each(function(x, y)
    local edge = not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1))
    local u = (x - cx + .5) / hw
    local col
    if y < cy then col = u < -.3 and "#fff1c8" or (u < .25 and "#f5cf6a" or "#e8a317")
    else col = u < -.3 and "#f5cf6a" or (u < .25 and "#e8a317" or "#d98322") end
    if y == cy or (y == cy + 1 and false) then col = "#fff1c8" end
    if abs(u) < .06 and y > top + 1 and y < bot - 1 then col = (y < cy) and "#ffe38a" or "#d98322" end
    if edge then col = INK end
    T.p(x, y, col)
  end)
  T.p(floor(cx - hw * .45), top + floor((cy - top) * .55), "#ffffff" == "" and INK or "#fff4d6")
end
R["crystal-o"] = function(T) ground(T, O, 1)
  local oc = blob(21, 21, 17, 17, 4, .08)
  oc:each(function(x, y) T.p(x, y, "#a87a4a") end)
  oc:shrink(3):each(function(x, y) T.p(x, y, "#c9a96e") end)
  oc:shrink(6):each(function(x, y) T.p(x, y, "#d9ba7c") end)
  local sh = blob(21, 36, 8, 2, 3, .1); sh:each(function(x, y) T.p(x, y, "#7a4a1f") end)
  crystal(T, 21, 5, 19, 35, 8)
  sparkle(T, 7, 8, "#fff4d6"); sparkle(T, 35, 10, "#fff4d6"); sparkle(T, 34, 31, "#fff4d6"); sparkle(T, 8, 30, "#fff4d6")
end
R["crystal-u"] = function(T) ground(T, U, 1)
  local mound = blob(21, 33, 14, 5, 3, .12); mound:each(function(x, y) T.p(x, y, "#5c3520") end)
  mound:shrink(2):each(function(x, y) T.p(x, y, "#6e4426") end)
  crystal(T, 21, 4, 18, 34, 8)
  crystal(T, 8, 20, 27, 35, 3); crystal(T, 34, 22, 28, 35, 3)
  sparkle(T, 6, 8, "#fff4d6"); sparkle(T, 36, 8, "#fff4d6"); sparkle(T, 36, 20, "#ffe38a")
end

---------------------------------------------------------------- strips / planks (transposable)
local function oriented(T, vertical, w, h)   -- returns put(a,b) with a along long axis, b across
  return function(a, b, col) if vertical then T.p(b, a, col) else T.p(a, b, col) end end
end
local function plank(T, vertical, a0, a1, b0, b1, o)   -- long axis a0..a1, across b0..b1
  local P = oriented(T, vertical)
  o = o or {}
  for b = b0, b1 do for a = a0, a1 do
    local col = "#d9a660"
    local eA, eB = (a == a0 or a == a1), (b == b0 or b == b1)
    if eA or eB then col = INK
    elseif b == b0 + 1 or a == a0 + 1 then col = "#ecc58a"
    elseif b == b1 - 1 or a == a1 - 1 then col = "#a8582f"
    elseif b >= b1 - 3 and b > b0 + 3 then col = "#b07a45" end
    if col == "#d9a660" and H(a, b, o.s or 1) > .94 then col = "#c58c52" end
    P(a, b, col)
  end end
  for _, k in ipairs(o.nails or {}) do P(k, (b0 + b1) // 2, "#f5cf6a"); P(k, (b0 + b1) // 2 + 1, "#8a4f2a") end
  for _, k in ipairs(o.knots or {}) do P(k[1], k[2], "#8a4f2a"); P(k[1] + 1, k[2], "#8a4f2a"); P(k[1], k[2] + 1, "#8a4f2a") end
  for _, g in ipairs(o.grain or {}) do for a = g[2], g[3] do P(a, g[1], "#c58c52") end end
end
R["bridge-h"] = function(T)
  plank(T, true, 2, 38, 1, 11, { s = 1, nails = { 4, 36 }, knots = { { 20, 5 } }, grain = { { 4, 8, 17 }, { 8, 22, 30 } } })
  plank(T, true, 2, 38, 15, 26, { s = 2, nails = { 4, 36 }, knots = { { 12, 21 } }, grain = { { 18, 6, 14 }, { 22, 20, 33 } } })
  plank(T, true, 2, 38, 29, 40, { s = 3, nails = { 4, 36 }, knots = { { 28, 33 } }, grain = { { 32, 10, 20 }, { 36, 4, 12 } } })
end
R["bridge-v"] = function(T)
  plank(T, false, 1, 40, 2, 12, { s = 1, nails = { 4, 37 }, knots = { { 24, 6 } }, grain = { { 5, 8, 18 }, { 9, 22, 32 } } })
  plank(T, false, 1, 40, 15, 26, { s = 2, nails = { 4, 37 }, knots = { { 10, 20 } }, grain = { { 18, 6, 14 }, { 22, 20, 33 } } })
  plank(T, false, 1, 40, 29, 39, { s = 3, nails = { 4, 37 }, knots = { { 30, 33 } }, grain = { { 32, 12, 22 }, { 36, 4, 12 } } })
end
local function rail(T, vertical, lightFirst, s)
  local P = oriented(T, vertical)
  local rows = lightFirst and { "#74462a", "#d9a660", "#b07a45", INK } or { INK, "#8a4f2a", "#d9a660", "#74462a" }
  if vertical and not lightFirst then rows = { "#74462a", "#d9a660", "#b07a45", INK } end
  for a = 0, 41 do for b = 0, 3 do P(a, b, rows[b + 1]) end end
  for _, k in ipairs{ 6 + s, 27 - s } do P(k, 1, "#f5cf6a"); P(k, 2, "#8a4f2a"); P(k + 1, 2, "#8a4f2a") end
  for a = 0, 41 do if H(a, 1, s) > .9 then P(a, 2, "#8a4f2a") end end
  for _, k in ipairs{ 15 + s, 34 } do P(k, 0, INK); P(k, 1, "#74462a") end
end
R["rail-n"] = function(T) rail(T, false, true, 0) end
R["rail-s"] = function(T) rail(T, false, true, 3) end
R["rail-e"] = function(T) rail(T, true, true, 1) end
R["rail-w"] = function(T) rail(T, true, true, 4) end
local function cap(T, vertical, flip, s)   -- hedge cap 42x5 (or 5x42), gold berries on outer row
  local P = oriented(T, vertical)
  for a = 6, 35 do
    local ends = (a == 6 or a == 35)
    for b = 0, 4 do
      local bb = flip and (4 - b) or b
      local skip = ends and (b == 0 or b == 4)
      if not skip then
        local col = "#4a8a3e"
        if b == 0 then col = (H(a, 2, s) > .5) and INK or "#2f5a2a"
          if (a + s) % 6 == 0 then col = "#f5cf6a" end
        elseif b == 1 then col = "#4f9a45"; if (a + s) % 7 == 1 then col = "#a4b86a" end
        elseif b == 3 then col = "#2f5a2a"
        elseif b == 4 then col = INK end
        if ends and col == INK then col = "#2f5a2a" end
        if b == 2 and (a + s) % 9 == 3 then col = "#7ab55c" end
        P(a, bb, col)
      end
    end
  end
end
R["wallcap-n"] = function(T) cap(T, false, false, 0) end
R["wallcap-s"] = function(T) cap(T, false, true, 2) end
R["wallcap-w"] = function(T) cap(T, true, false, 1) end
R["wallcap-e"] = function(T) cap(T, true, true, 3) end

local function arc(T, x, y, n, c1, c2)
  for i = 0, n - 1 do
    local yy = y + floor(1.5 * sin(i / (n - 1) * pi * 1.5 + 3.5) + .5)
    T.p(x + i, yy, c1); T.p(x + i, yy + 1, c2)
  end
end
R["ripple-high"] = function(T)
  arc(T, 6, 12, 12, "#c8ecdc", "#a9d6ea"); arc(T, 20, 20, 14, "#c8ecdc", "#a9d6ea"); arc(T, 9, 28, 10, "#c8ecdc", "#a9d6ea")
  T.p(34, 9, "#a9d6ea"); T.p(3, 36, "#a9d6ea"); T.p(36, 34, "#c8ecdc")
end
R["ripple-pool"] = function(T)
  arc(T, 24, 9, 9, "#c8ecdc", "#a9d6ea"); arc(T, 8, 25, 12, "#c8ecdc", "#a9d6ea")
  T.p(33, 31, "#c8ecdc"); T.p(34, 31, "#c8ecdc"); T.p(4, 8, "#a9d6ea")
end

local function wallBrick(T, x, y, o)    -- periodic 42 brick; returns colour
  local ch = { 10, 11, 10, 11 }
  local yy, r, acc = y % 42, 1, 0
  for i = 1, 4 do if yy < acc + ch[i] then r = i; break end acc = acc + ch[i] end
  local ly, hgt = yy - acc, ch[r]
  local off = (r % 2 == 0) and 7 or 0
  local xx = (x + off) % 42
  local bx, lx = xx // 14, xx % 14
  if lx == 13 or ly == hgt - 1 then return o.mortar end
  local col = o.base
  local t = H(bx, r, o.seed)
  if t > .66 then col = o.alt elseif t < .2 then col = o.alt2 end
  if ly == 0 or lx == 0 then col = o.hi elseif ly == hgt - 2 or lx == 12 then col = o.shade end
  if H(x, y, o.seed + 5) > .97 then col = o.shade end
  return col
end
local STO = { mortar = "#4a4d66", base = "#8f92a2", alt = "#9a9cac", alt2 = "#84879a", hi = "#b9bac6", shade = "#6a6f84", seed = 3 }
local STD = { mortar = "#2c2d44", base = "#555a70", alt = "#5f647a", alt2 = "#4b5066", hi = "#6c7288", shade = "#3c4058", seed = 5 }
local function sandWave(x, y, o)
  local ph = y + floor(2 * sin(2 * pi * x / 14 + o.ph) + .5)
  local m = ph % 6
  if m == 0 then return o.dk elseif m == 5 then return o.hi end
  local r = H(x, y, o.seed)
  if r > .985 then return o.dk elseif r < .012 then return o.hi end
  return o.b
end
local SAND = { b = "#c9a96e", dk = "#b08a55", hi = "#e6cf98", ph = 0.5, seed = 2 }
local DEEPU = { b = "#9a6b3f", dk = "#7a4a1f", hi = "#b08350", ph = 2.0, seed = 4 }

R["wall-o-deep"] = function(T)
  fillAll(T, function(x, y) return wallBrick(T, x, y, STD) end)
  for _, p in ipairs{ { 7, 4 }, { 28, 15 }, { 14, 26 }, { 33, 36 } } do
    for _, q in ipairs{ { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 } } do T.p(p[1] + q[1], p[2] + q[2], "#6c7288") end
  end
  T.p(14, 35, "#2f5a2a"); T.p(15, 35, "#2f5a2a"); T.p(15, 34, "#4a8a3e")
end
R["wall-u-deep"] = function(T)
  fillAll(T, function(x, y) return sandWave(x, y, DEEPU) end)
  for _, p in ipairs{ { 8, 9 }, { 30, 20 }, { 16, 33 }, { 37, 5 } } do
    T.p(p[1], p[2], "#c9a96e"); T.p(p[1] + 1, p[2], "#c9a96e"); T.p(p[1], p[2] + 1, "#6e4426"); T.p(p[1] + 1, p[2] + 1, "#6e4426")
  end
end

---------------------------------------------------------------- autotile sheets 84x126
local function inRegion(rg, x, y)
  if rg == 0 then
    if x < 3 or x > 38 or y < 3 or y > 38 then return false end
    local prof = { 5, 3, 2, 1, 1 }
    local ly, lx = y - 3, x - 3
    local dy = min(ly, 35 - ly); local dx = min(lx, 35 - lx)
    if dy < 5 and dx < prof[dy + 1] then return false end
    if dx < 5 and dy < prof[dx + 1] then return false end
    return true
  elseif rg == 1 then
    local lx, ly = (x - 42) % 42, y % 42
    return not ((lx < 3 or lx > 38) and (ly < 3 or ly > 38))
  else
    if x < 3 or x > 80 or y < 45 or y > 122 then return false end
    local prof = { 5, 3, 2, 1, 1 }
    local ly, lx = y - 45, x - 3
    local dy = min(ly, 77 - ly); local dx = min(lx, 77 - lx)
    if dy < 5 and dx < prof[dy + 1] then return false end
    if dx < 5 and dy < prof[dx + 1] then return false end
    return true
  end
end
local function sheet(bg, style)
  local T = newT(84, 126, false)
  fillAll(T, function() return bg end)
  for y = 0, 125 do for x = 0, 83 do
    local rg = (y >= 42) and 2 or ((x >= 42) and 1 or 0)
    if inRegion(rg, x, y) then
      local best, vx, vy = 99, 0, 0
      for dy = -3, 3 do for dx = -3, 3 do
        local dm = abs(dx) + abs(dy)
        if dm > 0 and dm <= 3 and not inRegion(rg, x + dx, y + dy) then
          if dm < best then best, vx, vy = dm, dx, dy elseif dm == best then vx, vy = vx + dx, vy + dy end
        end
      end end
      local depth = best - 1
      local litside = (vx + vy) < 0
      T.p(x, y, style(x, y, depth <= 3 and depth or 9, litside))
    end
  end end
  return T
end
R["wall-o-auto"] = function()
  return sheet("#9a6b3f", function(x, y, dp, lit)
    if dp == 0 then return INK end
    if dp == 1 then return lit and "#d9dae2" or "#4a4d66" end
    local col = wallBrick(nil, x, y, STO)
    if H(x // 6, y // 6, 31) > .985 and (x % 6 < 3 and y % 6 < 3) then col = (x % 6 == 0 or y % 6 == 0) and "#7ab55c" or "#4a8a3e" end
    if H(x // 7, y // 7, 77) > .99 and (x % 7 < 2 and y % 7 < 2) then col = (x % 7 == 0) and "#ff8a5c" or "#e8493b" end
    return col
  end)
end
R["wall-u-auto"] = function()
  return sheet("#8a5a30", function(x, y, dp, lit)
    if dp == 0 then return INK end
    if dp == 1 then return lit and "#f2e2b0" or "#8a5a30" end
    local col = sandWave(x, y, SAND)
    if H(x // 6, y // 6, 41) > .992 and (x % 6 < 2 and y % 6 < 2) then col = "#e8493b" end
    return col
  end)
end
R["water-auto"] = function()
  local dash = {}
  for ty = 0, 2 do for tx = 0, 1 do
    for i = 1, 4 do
      local x = tx * 42 + floor(H(tx * 3 + i, ty, 8) * 30) + 4
      local y = ty * 42 + floor(H(tx * 3 + i, ty + 9, 8) * 34) + 4
      dash[#dash + 1] = { x, y, 3 + floor(H(i, tx + ty, 6) * 4) }
    end
  end end
  local T = sheet("#7a4a1f", function(x, y, dp, lit)
    if dp == 0 then return "#4a2c1a" end
    if dp == 1 then return lit and "#25637d" or "#8fd0e0" end
    local v = pn(x % 42, y % 42, 7, 4) * .6 + pn(x % 42, y % 42, 3, 9) * .4
    if v > .68 then return "#4a9cbd" elseif v < .26 then return "#37819f" end
    return "#3f8fb0"
  end)
  for _, ds in ipairs(dash) do
    for i = 0, ds[3] - 1 do
      local x, y = ds[1] + i, ds[2]
      local rg = (y >= 42) and 2 or ((x >= 42) and 1 or 0)
      local ok = true
      for dy = -2, 2 do for dx = -2, 2 do if not inRegion(rg, x + dx, y + dy) then ok = false end end end
      if ok then T.p(x, y, "#a9d6ea"); if i == 0 then T.p(x, y + 1, "#25637d") end end
    end
  end
  return T
end

---------------------------------------------------------------- sprites
local function disc(T, cx, cy, f)   -- f(x,y,r,a) -> colour or nil
  for y = floor(cy - 20), floor(cy + 20) do for x = floor(cx - 20), floor(cx + 20) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local col = f(x, y, sqrt(dx * dx + dy * dy), math.atan(dy, dx), dx, dy)
    if col then T.p(x, y, col) end
  end end
end
local function ring(T, cx, cy, R0, ramp, shape)
  disc(T, cx, cy, function(x, y, r, a, dx, dy)
    local rr = shape and shape(a, R0) or R0
    if r > rr then return nil end
    if r > rr - 1 then return INK end
    local l = -(dx * .6 + dy * .8) / rr
    if r > rr - 2.2 then return l > .2 and ramp.hi or ramp.shade end
    return nil
  end)
end
R["token-gold"] = function(T)
  disc(T, 17, 17, function(x, y, r, a, dx, dy)
    if r > 16 then return nil end
    if r > 15 then return INK end
    if r > 12 then
      local l = -(dx * .6 + dy * .8) / 16
      if r > 14 then return l > .1 and "#ffe38a" or "#d0862a" end
      return l > .1 and "#f5cf6a" or "#e8a317"
    end
    if r > 11 then return "#b8661a" end
    local l = -(dx * .6 + dy * .8) / 11
    return l > .75 and "#fffaf0" or "#f4f0e0"
  end)
  T.p(8, 6, "#fff4d6"); T.p(7, 7, "#fff4d6")
  for i = 0, 5 do T.p(22 + i, 29 - i // 2, "#d0862a") end
end
R["token-ember"] = function(T)
  local function shp(a, R0) return R0 + 1.6 * (cos(4 * a) ^ 4) end
  disc(T, 17, 17, function(x, y, r, a, dx, dy)
    local rr = shp(a, 15)
    if r > rr then return nil end
    if r > rr - 1 then return INK end
    if r > 12 then
      local l = -(dx * .6 + dy * .8) / 16
      if r > rr - 2.2 then return l > .1 and "#ff8a5c" or "#8c2438" end
      return l > .1 and "#e8493b" or "#b52e3f"
    end
    if r > 11 then return "#8c2438" end
    local l = -(dx * .6 + dy * .8) / 11
    return l > .75 and "#fffaf0" or "#f4f0e0"
  end)
  for _, p in ipairs{ { 16, 2 }, { 32, 16 }, { 16, 31 }, { 1, 16 } } do T.p(p[1], p[2], "#f5cf6a"); T.p(p[1] + 1, p[2] + 1, "#e8a317") end
  T.p(9, 7, "#ffc4a0"); T.p(8, 8, "#ffc4a0")
end
R["bang"] = function(T)
  disc(T, 12, 12, function(x, y, r, a, dx, dy)
    if r > 11 then return nil end
    if r > 10 then return INK end
    local l = -(dx * .6 + dy * .8) / 11
    if r > 8.6 then return l > .15 and "#ff9158" or "#ae2a2a" end
    return l > .35 and "#ee5a3a" or "#dd3a2a"
  end)
  for y = 5, 13 do for x = 11, 13 do T.p(x, y, "#f4f0e0") end end
  T.p(11, 5, "#dd3a2a"); T.p(13, 5, "#dd3a2a")
  for y = 5, 13 do T.p(14, y, "#cfc3a2") end
  for x = 11, 13 do for y = 16, 18 do T.p(x, y, "#f4f0e0") end end
  for x = 11, 14 do T.p(x, 19, "#cfc3a2") end
  T.p(14, 16, "#cfc3a2"); T.p(14, 17, "#cfc3a2"); T.p(14, 18, "#cfc3a2")
  T.p(7, 5, "#ffc4a0"); T.p(6, 6, "#ffc4a0")
end
R["flag"] = function(T)
  -- pennant
  local m = HP.mask()
  for x = 7, 18 do
    local w = (18 - x) * .46 + .2
    local yc = 6 + floor(1.2 * sin((x - 7) / 3))
    for y = floor(yc - w), floor(yc + w) do m:set(x, y) end
  end
  m:each(function(x, y)
    local edge = not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1))
    local up = not m:has(x, y - 1)
    T.p(x, y, edge and INK or (up and "#ff9158" or ((not m:has(x, y + 2)) and "#ae2a2a" or "#dd3a2a")))
  end)
  for y = 2, 16 do T.p(5, y, INK); T.p(6, y, "#d9a660"); T.p(7, y, "#8a4f2a"); T.p(8, y, INK) end
  for x = 7, 8 do T.p(x, 2, INK) end
  T.p(6, 1, INK); T.p(5, 1, INK); T.p(6, 2, "#f5cf6a")
  -- stone base
  local b = blob(6.5, 17, 5, 2, 3, .1)
  lit(T, b, { hi = "#e2e0e6", base = "#aaa9b8", shade = "#74758c" })
end
local FOOT = { { ".bbb.b.", "bbbbb..", "bbbbb.b", "bbbbb..", ".bcc.b." } }
local function foot(T, vertical)
  local rows = FOOT[1]
  local function print_(ox, oy)
    for j = 1, 5 do for i = 1, 7 do
      local ch = rows[j]:sub(i, i)
      if ch ~= "." then
        local col = ch == "b" and "#f5cf6a" or "#e8a317"
        if j == 1 and i == 2 then col = "#fff1c8" end
        if vertical then T.p(ox + (j - 1), oy + (7 - i), col) else T.p(ox + i - 1, oy + j - 1, col) end
      end
    end end
  end
  if vertical then print_(0, 0); print_(7, 5) else print_(0, 0); print_(5, 7) end
end
R["foot-h"] = function(T) foot(T, false) end
R["foot-v"] = function(T) foot(T, true) end
R["me"] = function(T)
  local cx, cy = 19, 18
  local sh = blob(19, 37, 11, 2.4, 3, .1); sh:each(function(x, y) T.p(x, y, "#4a2c1a") end)
  disc(T, cx, cy, function(x, y, r, a, dx, dy)
    if r > 18 then return nil end
    if r > 17 then return INK end
    local l = -(dx * .6 + dy * .8) / 18
    if r > 14.6 then return l > .3 and "#ffe38a" or (l > -.2 and "#f5b82e" or "#d98322") end
    if r > 13.6 then return "#8f4a1f" end
    return "#fff4d6"
  end)
  local function inner(x, y) local dx, dy = x + .5 - cx, y + .5 - cy; return dx * dx + dy * dy <= 13.4 * 13.4 end
  local function P2(x, y, col) if inner(x, y) then T.p(x, y, col) end end
  -- beard
  for y = 19, 31 do
    local w = 8 - (y - 19) * .55
    for x = floor(cx - w), floor(cx + w - 1) do
      local edge = (x <= floor(cx - w) or x >= floor(cx + w - 1) or y == 31)
      P2(x, y, edge and "#8a7f98" or ((x < cx - 2) and "#ffffff" == "" and "" or (x < cx - 3 and "#f4f0e0" or "#e2e0e6")))
    end
  end
  -- face
  for y = 15, 22 do for x = 13, 25 do
    local dx, dy = (x - 19) / 6.5, (y - 18.5) / 4.2
    if dx * dx + dy * dy <= 1 then P2(x, y, (y > 20) and "#e8a47e" or "#f4b894") end
  end end
  P2(15, 18, INK); P2(15, 19, INK); P2(22, 18, INK); P2(22, 19, INK)
  for y = 19, 22 do for x = 18, 21 do P2(x, y, (x == 18 or y == 19) and "#ffc4a0" or "#f5809f") end end
  P2(13, 20, "#f5809f"); P2(25, 20, "#f5809f")
  -- hat
  for y = 4, 16 do
    local t = (y - 4) / 12
    local x0, x1 = floor(cx + 4 - 12 * t - 1 + (t > .95 and 0 or 0)), floor(cx + 4 + 6 * t)
    if y == 4 then x0, x1 = 22, 24 end
    for x = x0, x1 + (y >= 15 and 4 or 0) do
      local xa = (y >= 15) and (x0 - 3) or x0
      local edge = (x == x0 or x == x1 or y == 4 or y == 16)
      local col = edge and INK or (x < cx - 2 + 7 * (1 - t) - 6 and "#ff8a5c" or (x > x1 - 3 and "#b52e3f" or "#e8493b"))
      if y >= 15 then col = (y == 16) and INK or "#b52e3f" end
      P2(x, y, col)
    end
  end
  P2(24, 3, "#f5cf6a"); P2(23, 4, "#f5cf6a"); P2(24, 4, "#f5cf6a")
end

---------------------------------------------------------------- driver
local SIZES = {}
for _, n in ipairs{ "bang" } do SIZES[n] = { 24, 24, false } end
for _, n in ipairs{ "flag" } do SIZES[n] = { 20, 20, false } end
for _, n in ipairs{ "foot-h", "foot-v" } do SIZES[n] = { 12, 12, false } end
SIZES["me"] = { 38, 40, false }
for _, n in ipairs{ "token-ember", "token-gold" } do SIZES[n] = { 34, 34, false } end
for _, n in ipairs{ "rail-n", "rail-s", "wallcap-n", "wallcap-s" } do SIZES[n] = { 42, n:find("rail") and 4 or 5, false } end
for _, n in ipairs{ "rail-e", "rail-w", "wallcap-e", "wallcap-w" } do SIZES[n] = { n:find("rail") and 4 or 5, 42, false } end
for _, n in ipairs{ "ripple-high", "ripple-pool", "bridge-h", "bridge-v" } do SIZES[n] = { 42, 42, false } end

local ORDER = {}
for k in pairs(R) do ORDER[#ORDER + 1] = k end
table.sort(ORDER)

local function build(n)
  local T
  if n:find("auto") then T = R[n]()
  else
    local s = SIZES[n] or { 42, 42, true }
    T = newT(s[1], s[2], s[3]); R[n](T)
  end
  local out = d .. "/out/trek-" .. n .. ".png"
  T.c:save{ png = out, scale = 1 }
end
local want = app.params.name or "all"
for _, n in ipairs(ORDER) do if want == "all" or want == n then build(n) end end

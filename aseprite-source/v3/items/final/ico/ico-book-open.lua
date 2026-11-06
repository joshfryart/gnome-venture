-- ico-book-open (final pass, Opus). An open book lying flat, seen from the front and a little above.
-- Structure: two curved page spreads rising from a deep gutter and drooping at the outer edges, a stack of page edges
-- under each spread, brown leather cover peeking out below and at the sides, a teal ribbon down the gutter.
-- Material: per-pixel light from the page curvature (left page turns away near the gutter, right page faces the light),
-- AO in the gutter, text lines following the page curve, layered page edges, leather bevel on the cover, satin ribbon.
-- quirk: someone doodled a tiny red gnome hat in the right-hand margin.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new("ico-book-open")
local PG, HD, GO = R.page, R.hide, R.gold
local SEA = { "#1c3a52", "#24546a", "#2e7a86", "#45a0a0", "#72c4bc", "#b6ecdc" }
local TXT, TXT2 = "#8e7a8e", "#b39c9e"
local GX = 32       -- gutter column
local W = 21        -- page width from the gutter

local function rise(d) return sin(min(d / 12, 1) * pi / 2) end
local function droop(d) return max(0, (d - 14) / 9) ^ 2 end
local function yT(d) return 21 - 7 * rise(d) + 2.6 * droop(d) end
local function yB(d) return 46 - 4 * rise(d) + 1.8 * droop(d) end
local function z(d) return 6 * rise(d) - 2.6 * droop(d) end

-- cover (under everything): spread wider and lower than the pages
local cover = HP.mask()
for x = GX - W - 3, GX + W + 3 do
  local d = min(abs(x - GX), W)
  local t0 = floor(yT(d) + 2.5)
  local b1 = floor(yB(d) + 6.5)
  for y = t0, b1 do cover:set(x, y) end
end
local cidx = A.face(c, cover, HD, { R = 1.6, base = { 0, -0.1, 1 }, grain = 0.05, seed = 9,
  nfn = function(x, y, n) return n[1] + (x - GX) / 90, n[2], n[3] end })

-- page-edge stacks below each spread (and down the outer side)
for x = GX - W, GX + W do
  local d = abs(x - GX)
  local b = floor(yB(d) + 0.5)
  for i = 1, 3 do
    local col = (i % 2 == 1) and PG[3] or PG[4]
    if i == 3 then col = PG[2] end
    if d < 2 then col = PG[1] end
    c:put(x, b + i, col)
  end
end
for _, sx in ipairs{ -1, 1 } do
  local x = GX + sx * (W + 1)
  for y = floor(yT(W) + 2.5), floor(yB(W) + 3.5) do c:put(x, y, (y % 2 == 0) and PG[3] or PG[2]) end
end

-- page surfaces
local pg = HP.mask()
for x = GX - W, GX + W do
  local d = abs(x - GX)
  for y = floor(yT(d) + 0.5), floor(yB(d) + 0.5) do pg:set(x, y) end
end
local n = {}
pg:each(function(x, y)
  local d = abs(x - GX)
  local dz = (z(d + 0.5) - z(max(0, d - 0.5)))      -- height change per px away from the gutter
  local sgn = (x < GX) and -1 or 1
  local nx = -dz * sgn * 1.1
  local v = (y - yT(d)) / max(1, yB(d) - yT(d))
  n[K(x, y)] = { A.norm(nx, -0.15 + v * 0.25, 1) }
end)
local bias = {}
pg:each(function(x, y)
  local d = abs(x - GX)
  local k = K(x, y)
  if d == 0 then bias[k] = -4 elseif d == 1 then bias[k] = -2 elseif d == 2 then bias[k] = -1 end
  if y == floor(yT(d) + 0.5) and d > 2 then bias[k] = (bias[k] or 0) + 1 end
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local pidx = X.tone(c, pg, v, PG, { cuts = { 0.2, 0.34, 0.46, 0.58, 0.72 }, bias = bias })

-- text lines following the page curve
local function textRow(x0, x1, off, seed)
  for x = x0, x1 do
    local d = abs(x - GX)
    local y = floor(yT(d) + off + 0.5)
    local h = X.hash(x, floor(off), seed)
    if h > 0.16 and pg:has(x, y) then
      local i = pidx[K(x, y)] or 4
      c:put(x, y, i >= 5 and TXT2 or TXT)
    end
  end
end
for r, off in ipairs{ 4, 7, 10, 13, 16, 19 } do
  textRow(GX - W + 4, GX - 4 - (r == 6 and 8 or 0), off, 3)
end
-- right page: two lines above the doodle, short lines beside it, two below
textRow(GX + 4, GX + W - 4, 4, 4)
textRow(GX + 4, GX + W - 4, 7, 4)
textRow(GX + 4, GX + 10, 10, 4)
textRow(GX + 4, GX + 10, 13, 4)
textRow(GX + 4, GX + W - 4, 16, 4)
textRow(GX + 4, GX + W - 10, 19, 4)
-- drop cap on the left page
do local x, y = GX - W + 4, floor(yT(W - 4) + 3.5)
  for yy = 0, 2 do for xx = 0, 1 do c:put(x + xx, y + yy, "#c94f6a") end end
  c:put(x, y, "#e8708a") end

-- quirk: tiny red gnome-hat doodle (hand-inked) in the right margin
do
  local d0 = 13
  local bx, by = GX + d0, floor(yT(d0) + 9.5)
  A.map(c, {
    "..r...",
    "..rr..",
    ".rRr..",
    ".rRRr.",
    "rRRRRr",
    "kkkkkk",
    "..cc..",
  }, bx, by, { r = "#c4363e", R = "#e8584a", k = "#7a4a4e", c = "#c49a5e" })
end

-- ribbon down the gutter, hanging out under the cover
for y = floor(yT(1) + 0.5), floor(yB(0) + 9.5) do
  local tail = y > yB(0) + 4
  for dx = 0, 2 do
    local x = GX + 1 + dx
    local col = ({ SEA[5], SEA[4], SEA[2] })[dx + 1]
    if (x + y) % 3 == 0 then col = SEA[max(1, ({ 5, 4, 2 })[dx + 1] - 1)] end
    if y == floor(yB(0) + 9.5) and dx == 1 then col = nil end   -- notched end
    if col then c:put(x - (tail and 1 or 0), y, col) end
  end
  -- ribbon shadow on the page
  if not tail and pg:has(GX + 4, y) then A.step(c, pidx, PG, GX + 4, y, -2) end
end
c:put(GX + 1, floor(yT(1) + 2.5), SEA[6])

A.save(c, "ico-book-open")

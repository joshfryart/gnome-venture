-- ico-path (final, Opus). A square chunk of turf with a winding dirt path of flagstones running from the front edge
-- to the back, and a slim wooden finger-post standing on the grass.
-- Material: grass top = bevelled pillow, blade ticks (lit tip over a dark root), tufts overhanging the path;
-- path = sunken dirt (shadowed under the grass lip, lit on the far bank) with grit; flagstones = bevelled stone with
-- a crack; soil front face = layered strata, a pebble and a root; post = wood grain, end grain, nail, AO at its foot.
-- quirk: a snail is halfway across the path.
local A = dofile("/home/user/gnome-venture/aseprite-source/v3/items/final/_helpers/_aA7_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-path")
local GR  = { "#1c4a3e", "#24644a", "#35844e", "#58a852", "#86c85e", "#bde27c" }
local SO  = { "#2e1c22", "#46282a", "#64382e", "#864c33", "#a86a42", "#c88a58" }
local DI  = { "#6a4432", "#9c6a40", "#c8955c", "#e4bc80", "#f4d8a2", "#fcecc4" }
local ST  = { "#3a3c58", "#5a5c78", "#7e8098", "#a4a6ba", "#c8cad8", "#e8e8f0" }
local WD  = { "#3e2420", "#5e3628", "#864c33", "#b07448", "#d09a62", "#ecc28a" }

local TOPY0, TOPY1, X0, X1 = 12, 48, 8, 55
-- soil front face (drawn first; the turf top overlaps its top row)
local stok = A.tok("soil")
local front = c:rrect(X0, TOPY1 - 3, X1, TOPY1 + 6, 3):cut(c:rect(X0, TOPY1 - 3, X1, TOPY1 - 1))
front:each(function(x, y)
  local d = y - TOPY1
  local i = (d <= 1) and 4 or (d <= 4) and 3 or 2
  if x > X1 - 5 then i = i - 1 end
  if x < X0 + 4 and d <= 3 then i = i + 1 end
  -- strata: a wavy darker seam
  if y == TOPY1 + 3 + ((x // 5) % 2) then i = i - 1 end
  c:put(x, y, SO[max(1, min(6, i))], stok)
end)
-- pebble in the soil + a dangling root
A.map(c, { ".ab", "abc", ".cc" }, 12, TOPY1 + 2, { a = ST[5], b = ST[4], c = ST[2] }, stok)
c:put(41, TOPY1 + 2, WD[5], stok) c:put(42, TOPY1 + 3, WD[5], stok) c:put(42, TOPY1 + 4, WD[4], stok) c:put(43, TOPY1 + 5, WD[4], stok)

-- turf top
local gtok = A.tok("grass")
local top = c:rrect(X0, TOPY0, X1, TOPY1, 5)
-- path (bezier ribbon, widening toward the viewer)
local P = { { 27, TOPY1 + 7 }, { 0, 36 }, { 60, 30 }, { 30, TOPY0 - 1 } }
local pm, pn, PT, PS = A.tube(P, function(t) return 6.2 - 3.2 * t end)
local pathTop = pm:copy():clip(top)
local gidx = A.pil(c, top, 3, GR, { tok = gtok, cuts = { 0.12, 0.3, 0.5, 0.72, 0.92 } })
-- blade ticks: lit tip over a darker root pixel
top:each(function(x, y)
  if not pathTop:has(x, y) and X.hash(x, y, 7) > 0.87 and top:has(x, y + 1) and y > TOPY0 + 1 then
    A.step(c, gidx, GR, x, y, 1, gtok) A.step(c, gidx, GR, x, y + 1, -1, gtok)
  end
end)
-- path where it cuts through the front face
local ptok = A.tok("path")
local pathFront = pm:copy():clip(front)
pathFront:each(function(x, y) c:put(x, y, y > TOPY1 + 1 and DI[2] or DI[3], ptok) end)
-- sunken dirt: shadowed under the left/upper bank, lit on the lower-right bank
local didx = {}
pathTop:each(function(x, y) local k = K(x, y)
  local s = PS[k]
  local i = 4
  if s < -0.55 then i = 2 elseif s < -0.2 then i = 3 elseif s > 0.6 then i = 5 end
  if X.hash(x, y, 11) > 0.88 then i = i - 1 elseif X.hash(x, y, 13) > 0.93 then i = i + 1 end
  i = max(1, min(6, i))
  didx[k] = i c:put(x, y, DI[i], ptok)
end)
-- AO: grass darkens where it rolls down into the path
A.near(top, pathTop, 1):each(function(x, y) A.step(c, gidx, GR, x, y, -2, gtok) end)
-- grass tufts overhanging the path edges
for _, q in ipairs{ { 0.18, -1 }, { 0.34, 1 }, { 0.52, -1 }, { 0.7, 1 }, { 0.86, -1 } } do
  local bx, by = A.bez(P, q[1])
  local bx2, by2 = A.bez(P, q[1] + 0.01)
  local tx, ty = bx2 - bx, by2 - by local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  local w = 6.2 - 3.2 * q[1]
  local ex, ey = floor(bx + px * (w - 0.6) * q[2] + .5), floor(by + py * (w - 0.6) * q[2] + .5)
  if top:has(ex, ey) then
    c:put(ex, ey, GR[q[2] < 0 and 4 or 5], gtok) c:put(ex, ey - 1, GR[q[2] < 0 and 3 or 4], gtok)
  end
end
-- flagstones in the dirt
local fs = A.tok("stone")
for i, q in ipairs{ { 0.08, 0.2, 3.6, 2.2 }, { 0.42, 0.3, 3.0, 2.0 }, { 0.62, -0.2, 2.8, 1.8 }, { 0.84, 0, 2.2, 1.5 } } do
  local bx, by = A.bez(P, q[1])
  local m, n, idx = A.ovl(c, bx + q[2] * 3, by, q[3], q[4], 0.2 * i, ST, { tok = A.tok("fs" .. i), clip = top, cuts = { 0.12, 0.3, 0.5, 0.7, 0.9 } })
  -- contact shadow on the dirt below/right of each stone
  m:shift(1, 1):cut(m):each(function(x, y) if pathTop:has(x, y) then c:put(x, y, DI[1], ptok) end end)
  if i == 1 then -- a crack across the big front stone
    local x0, y0 = m:bbox()
    c:put(x0 + 3, y0 + 1, ST[2], fs) c:put(x0 + 4, y0 + 2, ST[2], fs) c:put(x0 + 4, y0 + 3, ST[2], fs)
  end
end

-- finger-post on the grass, right
local wt = A.tok("post")
local px0, py0, py1 = 48, 13, 31
-- AO at its foot
c:ellipse(px0 + 2, py1 + 1, 3, 1):each(function(x, y) if top:has(x, y) and not pathTop:has(x, y) then c:put(x, y, GR[1], gtok) end end)
for y = py0, py1 do
  c:put(px0, y, WD[5], wt) c:put(px0 + 1, y, WD[4], wt) c:put(px0 + 2, y, WD[2], wt)
  if y % 5 == 2 then c:put(px0 + 1, y, WD[3], wt) end -- grain
end
c:put(px0, py0, WD[6], wt) c:put(px0 + 1, py0, WD[5], wt) -- pale end grain
-- board pointing right (arrow), sticks past the turf
local board = c:poly{ { 41, 15 }, { 55, 15 }, { 58.5, 18.5 }, { 55, 22 }, { 41, 22 } }
board:each(function(x, y)
  local i = 4
  if y == 15 then i = 6 elseif y == 16 then i = 5 elseif y >= 21 then i = 2 elseif y == 20 then i = 3 end
  if (y == 18 and (x % 7) < 4) or (y == 19 and (x % 7) >= 4) then i = i - 1 end -- grain streaks
  c:put(x, y, WD[max(1, min(6, i))], wt)
end)
c:put(41, 15, WD[6], wt) c:put(41, 16, WD[6], wt) -- end grain
c:put(49, 18, A.INK, wt) c:put(50, 17, ST[5], wt)                -- nail with glint
-- shadow the post casts under the board
c:put(px0, 23, WD[3], wt) c:put(px0 + 1, 23, WD[2], wt)

-- quirk: a snail halfway across the path
local sx, sy = A.bez(P, 0.25)
sx, sy = floor(sx) - 2, floor(sy) - 3
A.map(c, {
  "..aab..",
  ".abcbd.",
  ".bcedd.",
  "ffbddd.",
  "gfffffh",
}, sx, sy, { a = "#ffc4d8", b = "#f5809f", c = "#c94f84", d = "#7d2c5e", e = "#ffe38a", f = "#e2d8c0", g = "#2b1c26", h = "#a89a88" }, A.tok("snail"))
c:put(sx, sy + 2, "#e2d8c0") c:put(sx, sy + 1, "#2b1c26") -- eye stalk
A.save(c, "ico-path")

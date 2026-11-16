-- Crown Points (pl-gwk-4), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
-- Thornblade, uncommon, Lair of the Grey Wolf King. "Four little golden points from the king's old crown."
-- Haiku weakness fixed: a whole flat crown (five points, not four) read as any king's crown, not a piece of an old
-- one. Now a broken-off segment of the crown: a curved gold band seen in perspective with jagged snapped ends,
-- exactly four points each tipped with a gold ball, engraved dot rows and two set gems; old, worn gold with deep
-- shadow inside the curve.
-- quirk: it is old: the fourth point is bent over sideways. closer-look: one gem socket on the band is empty.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-4-yard", 64)

local GOLD = { "#5a2e14", "#91501e", "#c9802a", "#eeb240", "#fbd870", "#fff2b8" }
local RUBY = { "#5a1028", "#a8203a", "#e8485a", "#ff9a9a" }
local SAPH = { "#14285a", "#2a4ea8", "#4a8ae8", "#a8d0ff" }

c:groundShadow(32, 54, 23, 2)
local function ybot(x) local u = (x - 32) / 25 return 46 + math.floor(4 * math.sqrt(math.max(0, 1 - u * u)) + .5) end
-- four points; each a faceted spike (lit left facet, shaded right facet); the fourth bent over to the right
local tips = {}
local pts = { 14, 25, 37, 48 }
for k, bx in ipairs(pts) do
  local yb = ybot(bx) - 14
  local m, tx, ty
  if k < 4 then
    tx, ty = bx, yb - 16
    m = c:poly{ { bx - 4.5, yb + 2 }, { bx + 4.5, yb + 2 }, { tx + .5, ty } }
  else
    tx, ty = bx + 10, yb - 9
    m = c:poly{ { bx - 4.5, yb + 2 }, { bx + 4.5, yb + 2 }, { bx + 3.5, yb - 4 }, { tx + 1, ty + 1 }, { tx, ty - 1 }, { bx - 2.5, yb - 7 } }
  end
  local I, T = O.shade(c, m, GOLD, { R = 2, amb = .3, wrap = .45, rim = true, sep = GOLD[1] })
  O.tex(c, I, T, GOLD, function(x, y, i)
    if k < 4 then
      if x == bx and y < yb then return 1 end
      if x > bx then return -1 end
    else
      if y - (yb - 6) > (x - bx) * .4 + 2 then return -1 end
    end
  end)
  tips[k] = { tx, ty }
end
-- the band: front of a ring, jagged snapped ends
local band = HP.mask()
for x = 9, 55 do
  local yb = ybot(x)
  for y = yb - 14, yb do band:set(x, y) end
end
band:cut(c:poly{ { 8, 30 }, { 11, 30 }, { 10, 36 }, { 12, 40 }, { 9, 45 }, { 11, 50 }, { 8, 52 } })
band:cut(c:poly{ { 56, 30 }, { 53, 30 }, { 54, 35 }, { 52, 39 }, { 54, 44 }, { 52, 49 }, { 56, 52 } })
local bn = {}
band:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 32) / 26))
  local yy = (y - (ybot(x) - 7)) / 10
  local l = math.sqrt(sx * sx + yy * yy + .6)
  bn[K(x, y)] = { sx / l, yy / l, math.sqrt(.6) / l }
end)
local bI, bT = O.shadeN(c, band, bn, GOLD, { amb = .28, wrap = .45, rim = true, bounce = "#8a6ab0", bmax = 3, sep = GOLD[1] })
-- engraved dot rows along the top and bottom of the band, worn scratches
O.tex(c, bI, bT, GOLD, function(x, y, i)
  local yb = ybot(x)
  if (y == yb - 12 or y == yb - 2) and x % 3 == 0 then return -2 end
  if y == yb - 13 and i <= 5 then return 1 end
  if O.H(x, y, 21) > .95 and i >= 3 then return -1 end
end)
-- ball tips
for _, t in ipairs(tips) do
  O.shade(c, c:ellipse(t[1], t[2] - 1, 2, 2), GOLD, { sphere = { t[1] - 1, t[2] - 2, 3 }, amb = .35, wrap = .5, sep = GOLD[2] })
end
-- gems: ruby left, sapphire right, empty socket centre-right
local function gem(cx, cy, R)
  O.flat(c, c:ellipse(cx, cy, 2, 2), R[2], "gem")
  O.dots(c, { { cx - 1, cy - 1 }, { cx, cy - 1 } }, R[3]) O.dot(c, cx - 1, cy - 1, R[4])
  O.dots(c, { { cx + 1, cy + 1 }, { cx, cy + 2 }, { cx + 2, cy } }, R[1])
end
gem(14, ybot(14) - 7, RUBY)
gem(50, ybot(50) - 7, SAPH)
-- empty socket (dark pit with a lit lower lip)
O.flat(c, c:ellipse(44, ybot(44) - 7, 1.5, 1.5), GOLD[1], "socket")
O.dots(c, { { 43, ybot(44) - 5 }, { 44, ybot(44) - 5 }, { 45, ybot(44) - 6 } }, GOLD[5])

-- face in the middle of the band
local fy = ybot(32) - 12
c:eyeLocked(23, fy)
c:eyeLocked(36, fy)
c:cheek(21, fy + 7) c:cheek(41, fy + 7)
O.dots(c, { { 29, fy + 7 }, { 30, fy + 8 }, { 31, fy + 8 }, { 32, fy + 8 }, { 33, fy + 8 }, { 34, fy + 7 } }, P.ink)

O.shift(c, 0, 3)
O.done(c, "pl-gwk-4-yard", function(c)
  c:sparkle(6, 14)
  c:sparkle(58, 20)
end)

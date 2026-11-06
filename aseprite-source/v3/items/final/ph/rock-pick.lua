-- rock-pick (Opus-style single pass by Sonnet high). Slim diagonal miner's pick: long ash handle rising to the upper right
-- with grain, pale end grain on a flared knob, a stitched-look leather grip wrap and a hammered-iron socket collar; a
-- curved double-pointed steel head (bright bevel along the lit edge, blue-violet shade, specular streak, rivet).
-- quirk: a little grey pebble is jammed on the lower point of the pick.
local NAME = "rock-pick"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }

local WOOD  = { "#3b2428", "#5c3a2d", "#85553a", "#ad7a4c", "#d3a468", "#f0cf93" }
local LEATH = { "#34202a", "#552e34", "#7b4635", "#a2684a", "#c88d63" }
local STEEL = { "#2f3254", "#4b5079", "#6f78a0", "#98a4c4", "#c4d0e6", "#f2f6ff" }
local IRON  = { "#2a2640", "#433f60", "#5f5a7e", "#827ca0", "#a8a2c2" }
local STONE = { "#4b4a64", "#6d6c84", "#908fa4", "#b4b3c4", "#d6d5e0" }
local wtok, ltok, stok, itok, ptok = {r={name="wood"}}, {r={name="leather"}}, {r={name="steel"}}, {r={name="iron"}}, {r={name="pebble"}}

-- handle: bezier from the knob (lower left) to the head crown (upper right)
local hp = { {11, 57}, {19, 45}, {28, 31}, {37, 21} }
local hm, hn, HT, HS = G.tube(hp, function(t) return 1.75 + 0.75 * max(0, 1 - t * 9) + 0.2 * sin(t * 5) end)
-- head: arc through the crown, perpendicular to the handle
local cx, cy = G.bez(hp, 1)
local dx, dy = G.bez(hp, 1.0)  -- (unused placeholder)
local ex, ey = G.bez(hp, 0.995)
local tx, ty = cx - ex, cy - ey local tl = sqrt(tx*tx + ty*ty) tx, ty = tx / tl, ty / tl   -- handle direction (up-right)
local px, py = -ty, tx                                                                      -- perpendicular (down-right-ish)
local A = 22
local B = 7
local p0 = { cx - px * A, cy - py * A }
local p3 = { cx + px * A, cy + py * A }
local p1 = { p0[1] + tx * B + px * 6, p0[2] + ty * B + py * 6 }
local p2 = { p3[1] + tx * B - px * 6, p3[2] + ty * B - py * 6 }
do -- slide the arc back so its crown sits on the handle top
  local mx, my = G.bez({ p0, p1, p2, p3 }, 0.5)
  for _, p in ipairs{ p0, p1, p2, p3 } do p[1] = p[1] + (cx - mx) p[2] = p[2] + (cy - my) end
end
local head = { p0, p1, p2, p3 }
local sm, sn, ST, SS = G.tube(head, function(t)
  local u = 1 - abs(2 * t - 1)           -- 0 at the points, 1 at the centre
  return 0.25 + 3.0 * u ^ 0.7 + 0.8 * max(0, u - 0.8) * 5
end)

-- AO on the handle where the collar and the head sit
local collarC = { { 31.5, 30.5 }, { 33, 28 }, { 34.5, 25.5 }, { 36, 23 } }
local cm, cn = G.tube({ {31, 32.5}, {32.3, 30}, {34.3, 26.5}, {36.3, 22.8} }, function(t) return 2.5 end)
local hbias = {}
X.ao(hbias, hm, cm, 2, -1)
G.cast(hbias, hm, sm, 1, 2, -1)
G.cast(hbias, hm, cm, 1, 1, -1)

-- wood
hm:cut(sm)
local len = 58
G.toneN(c, hm, hn, WOOD, { bias = hbias, tok = wtok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.14, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if hbias[k] and hbias[k] < 0 then return end
  -- grain: thin dark streaks running along the shaft
  local g = abs(sin(s * 5.1 + 0.9)) < 0.1 and X.hash(floor(t * 26), floor(s * 3 + 3), 7) > 0.35
  if g and t > 0.34 then c:put(x, y, s < 0 and WOOD[3] or WOOD[2], wtok) end
end)
-- leather grip wrap (diagonal bands, lit upper edge, stitched seam at the top)
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if t > 0.17 and t < 0.43 then
    local ph = (t * len + s * 2.4) % 4
    local lit = s < -0.3
    local i = ph < 1 and 4 or (ph < 3 and 3 or 2)
    if s > 0.45 then i = i - 1 end
    if lit and ph < 1 then i = 5 end
    if ph >= 3.4 then i = 1 end
    c:put(x, y, LEATH[max(1, min(5, i))], ltok)
  end
end)
-- end grain on the knob: pale cap with rings
do
  local kx, ky = G.bez(hp, 0)
  local cap = G.oval(kx + 0.3, ky + 0.8, 2.9, 2.1, -1.1, 0.8)
  cap:each(function(x, y)
    local d = sqrt(((x - kx - 0.3)) ^ 2 + ((y - ky - 0.8)) ^ 2)
    c:put(x, y, d < 0.9 and WOOD[3] or (d < 1.9 and WOOD[6] or WOOD[5]), wtok)
  end)
  c:put(floor(kx), floor(ky + 1), WOOD[4], wtok)
end

-- iron socket collar: band with a ridge, rivet, bevel
cm:cut(sm)
G.toneN(c, cm, cn, IRON, { tok = itok, cuts = { 0.2, 0.38, 0.55, 0.72 }, amb = 0.1, wrap = 0.3 })
-- collar cross ridges
local cT = {}
cm:each(function(x, y)
  local k = K(x, y)
  local along = (x - 31) * 0.45 + (y - 32.5) * -0.89   -- distance along the handle direction
  local a = floor(along * -1 + 0.5)
  if a == 1 or a == 7 then c:put(x, y, IRON[1], itok) end
  if a == 3 or a == 5 then c:put(x, y, (x + y) % 2 == 0 and IRON[4] or IRON[3], itok) end
end)
c:put(32, 28, IRON[5], itok) c:put(33, 28, IRON[2], itok)   -- rivet

-- steel head
local sb = {}
local steelIdx = G.toneN(c, sm, sn, STEEL, { bias = sb, tok = stok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1, wrap = 0.35 })
sm:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  -- forged bevel: bright strip along the lit (outer) edge, dark fuller groove inside
  if s < -0.55 and t > 0.06 and t < 0.94 then c:put(x, y, STEEL[5], stok) end
  if s > -0.2 and s < 0.1 and t > 0.12 and t < 0.88 then c:put(x, y, STEEL[3], stok) end
  if s > 0.62 and t > 0.05 and t < 0.95 then c:put(x, y, STEEL[1], stok) end
  if s > 0.35 and s <= 0.62 and abs(ST[k] - 0.5) < 0.18 then c:put(x, y, STEEL[2], stok) end
end)
-- hammered dents + crown specular
do local x, y = G.bez(head, 0.3) x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, STEEL[6], stok) c:put(x + 1, y - 1, STEEL[6], stok) c:put(x - 1, y + 1, STEEL[5], stok)
  local x2, y2 = G.bez(head, 0.68) c:put(floor(x2), floor(y2), STEEL[2], stok) end
-- cool bounce light along the lower point
sm:edge():each(function(x, y) local k = K(x, y)
  if SS[k] and SS[k] > 0.7 and ST[k] > 0.62 and ST[k] < 0.96 then c:put(x, y, "#7f95c9", stok) end end)

-- quirk pebble stuck on the lower point
local pxx, pyy = G.bez(head, 0.87)
local pm, pn = G.oval(pxx - 0.5, pyy + 2.2, 2.5, 2.1, 0.5, 0.9)
G.toneN(c, pm, pn, STONE, { tok = ptok, cuts = { 0.2, 0.38, 0.55, 0.74 }, amb = 0.1, wrap = 0.3 })
c:put(floor(pxx - 1.5), floor(pyy + 1.2), STONE[5], ptok) c:put(floor(pxx + 1), floor(pyy + 4), STONE[1], ptok)

G.save(c, NAME)

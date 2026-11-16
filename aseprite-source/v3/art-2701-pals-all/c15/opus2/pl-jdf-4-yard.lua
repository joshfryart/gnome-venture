-- Jadewing Quartet (pl-jdf-4), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Thornblade, uncommon, Lair of the Jade Dragon-fly. "Four little wing bits that all want to go first."
-- A round jade dragonfly chick: big head with the face, a short thorax, a segmented tail with gold rings curling
-- down to a little thorn-blade tip (thornblade). Its four glassy wings (net veins, a gold pterostigma spot at
-- each tip) are all crowded onto the SAME side, fanned forward like a hand of cards, each pushing past the next.
-- Haiku weakness fixed: four plain sky blades in a static X on a stick; now veined wings with a clear pose.
-- quirk: the four wings all lean to the front at once, jostling (the front one has nudged ahead, ticks behind).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-jdf-4-yard", 64)

local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }
local WING = { "#2e5c78", "#4c8aa6", "#7ab8c8", "#a6dcd8", "#cdf0e6", "#eefcf2" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(28, 56, 15, 2)

-- tail: segmented, curling down and back to a little thorn tip
local tail, tn, tT = O.tube({ { 22, 38 }, { 20, 47 }, { 12, 52 }, { 8, 45 } }, function(t) return 3.6 - t * 2.2 end)
local tI, tTok = O.shadeN(c, tail, tn, JADE, { amb = .3, wrap = .4, rim = true, bounce = "#3a6a8a", bmax = 2 })
O.tex(c, tI, tTok, JADE, function(x, y, i)
  local t = tT[K(x, y)] or 0
  if (t * 9) % 1 < .16 then return -2 end
end)
-- gold rings on two segments
tail:each(function(x, y)
  local t = tT[K(x, y)] or 0
  if (t > .25 and t < .3) or (t > .47 and t < .52) or (t > .69 and t < .74) then
    c.pix[y * c.w + x] = (tI[K(x, y)] or 3) >= 3 and GOLD[3] or GOLD[2]
  end
end)
-- thorn tip
O.shade(c, c:poly{ { 6, 44 }, { 10, 44 }, { 7, 38 } }, GOLD, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = GOLD[1] })

-- four wings, all fanned to the front-right side; back first
local wings = {
  { { 33, 26 }, { 38, 15 }, { 44, 10 }, { 48, 7 } },
  { { 34, 28 }, { 42, 21 }, { 49, 17 }, { 55, 15 } },
  { { 34, 31 }, { 43, 29 }, { 50, 28 }, { 56, 27 } },
  { { 33, 34 }, { 41, 37 }, { 48, 40 }, { 54, 43 } },
}
for wi, wp in ipairs(wings) do
  local m, n, T, S = O.tube(wp, function(t) return 1.2 + 2.6 * math.sin(math.pi * math.min(1, t * .95 + .08)) end)
  local I, Tk = O.shadeN(c, m, n, WING, { amb = .45, wrap = .5, sep = WING[1], rim = true })
  O.tex(c, I, Tk, WING, function(x, y, i)
    local t, s = T[K(x, y)] or 0, S[K(x, y)] or 0
    if math.abs(s) < .22 and t > .05 then return -2 end                -- leading vein
    if t > .15 and t < .85 and (t * 7 + s * .7) % 1 < .14 then return -1 end -- cross veins
  end)
  -- pterostigma near the tip
  local sx, sy = O.bez(wp, .86)
  O.mark(c, { { math.floor(sx), math.floor(sy) }, { math.floor(sx) + 1, math.floor(sy) } }, GOLD[3])
  -- glassy glint on the leading edge
  local gx, gy = O.bez(wp, .4)
  O.mark(c, { { math.floor(gx), math.floor(gy) - 1 } }, WING[6])
end

-- thorax under the head, where the wings join
O.shade(c, c:ellipse(30, 35, 6, 5), JADE, { sphere = { 27, 32, 8 }, amb = .25, wrap = .35, sep = JADE[2] })
-- little legs tucked under
for _, lp in ipairs({ { { 26, 39 }, { 25, 42 }, { 24, 44 }, { 23, 47 } }, { { 32, 39 }, { 33, 43 }, { 34, 46 }, { 35, 49 } } }) do
  local lm, ln = O.tube(lp, function() return 1.1 end)
  O.shadeN(c, lm, ln, JADE, { amb = .3, wrap = .4, sep = JADE[1] })
end
-- head with the face
local hI, hT = O.shade(c, c:ellipse(24, 25, 11, 10), JADE, { sphere = { 20, 20, 15 }, amb = .25, wrap = .4, rim = true, bounce = "#3a6a8a", bmax = 2, sep = JADE[2] })
-- fine speckle on the crown
O.tex(c, hI, hT, JADE, function(x, y, i) if y < 21 and H(x, y, 4) > .86 and i >= 3 then return 1 end end)
-- two antenna nubs
O.shade(c, c:rect(17, 13, 18, 15), JADE, { R = 1, amb = .4, cuts = { .2, .4, .6, .8, .95 }, sep = JADE[2] })
O.shade(c, c:rect(28, 13, 29, 15), JADE, { R = 1, amb = .4, cuts = { .2, .4, .6, .8, .95 }, sep = JADE[2] })

c:eyeLocked(17, 22)
c:eyeLocked(26, 22)
c:cheek(15, 28) c:cheek(31, 28)
-- determined little grin
O.mark(c, { { 22, 30 }, { 23, 31 }, { 24, 31 }, { 25, 31 }, { 26, 30 } }, P.ink)

O.done(c, "pl-jdf-4-yard", function(c)
  -- hurry ticks behind the head (they all want to go first)
  for _, p in ipairs({ { 7, 22 }, { 8, 22 }, { 9, 22 }, { 6, 26 }, { 7, 26 }, { 8, 26 }, { 9, 26 }, { 7, 30 }, { 8, 30 } }) do c:put(p[1], p[2], P.ink) end
end)

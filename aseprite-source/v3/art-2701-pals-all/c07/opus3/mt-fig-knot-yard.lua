-- Fig Knot (mt-fig-knot), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3 (opus2's head was a plain ball): the head is now a knot of roots, a knobbly lumpy silhouette with two
-- grained root coils wrapping the cheeks and framing a smoother face patch, bark fissures, and thin aerial roots
-- dangling from the sides (strangler fig). Stone gets lichen, a crack and thicker moss; leaves get side veins; the
-- fig gets speckles. Closer look: a tiny fig wasp on the fig.
-- Monsoontangle, uncommon, thornblade. "Wraps itself round the temple and never lets go of a secret."
-- A strangler fig: a round knot of twisted pale-bark root for a head (spiral grain), two lobed fig leaves on
-- top and a ripe dusk fig hanging off one side; two thick roots come down from the head, wrap round a carved
-- mossy temple stone and cross in front of it, then splay into root feet on the ground.
-- Haiku fixes: it no longer reads as a walnut. The temple stone gives the "wraps round the temple" story, the
-- roots are tubes that visibly wrap and cross, leaves are true lobed fig leaves, the fig hangs on a stalk.
-- quirk: the secret, a tiny rolled scroll with a red seal, pinned where the roots cross.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-fig-knot-yard", 64)

local BARK = { "#3e2a2a", "#5e4036", "#82604a", "#a8846a", "#c8a888", "#e2c8a8" }
local STN  = { "#3a3e48", "#565c64", "#7a7e80", "#9c9e98", "#bcbcb0", "#dcdac8" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local LEAF = { "#1f4a3a", "#2f6a40", "#4a8c44", "#6aac4e", "#94cc62", "#c0e488" }
local FIG  = { "#2a1e44", "#45306e", "#6a4a9e", "#8a6fd0", "#b49ae6", "#dccaf6" }
local PAPR = { "#c8a878", "#e8d4a8", "#fff4d6" }

c:groundShadow(32, 58, 21, 2.5)

-- temple stone block (carved, seamed, mossy top)
local stone = c:rect(17, 33, 46, 55)
local sb = {}
stone:each(function(x, y)
  if y == 44 or (y < 44 and x == 31) or (y > 44 and (x == 24 or x == 39)) then sb[K(x, y)] = -2 end -- block seams
  if H(x, y, 21) > .9 then sb[K(x, y)] = (sb[K(x, y)] or 0) - 1 end
end)
O.shade(c, stone, STN, { R = 3, amb = .3, wrap = .45, bias = sb, sep = STN[1], rim = true, bounce = "#5a6a8a", bmax = 2 })
-- carved spiral on the lower blocks
O.dots(c, { { 20, 48 }, { 21, 47 }, { 22, 48 }, { 22, 49 }, { 21, 50 }, { 20, 50 }, { 19, 49 }, { 19, 47 }, { 20, 46 } }, STN[2])
O.dots(c, { { 43, 48 }, { 42, 47 }, { 41, 48 }, { 41, 49 }, { 42, 50 }, { 43, 50 }, { 44, 49 }, { 44, 47 }, { 43, 46 } }, STN[2])
-- moss on the stone top edges
O.dots(c, { { 17, 33 }, { 18, 33 }, { 19, 33 }, { 18, 34 }, { 44, 33 }, { 45, 33 }, { 46, 33 }, { 46, 34 } }, MOSS[3])
O.dots(c, { { 17, 34 }, { 19, 34 }, { 45, 34 } }, MOSS[2])
O.dots(c, { { 16, 35 }, { 17, 35 }, { 17, 36 }, { 46, 35 }, { 47, 35 }, { 46, 36 }, { 30, 33 }, { 31, 33 }, { 33, 33 } }, MOSS[3]) -- moss creeping down
O.dots(c, { { 30, 34 }, { 31, 34 }, { 32, 33 } }, MOSS[4])
-- lichen rosettes
for _, l in ipairs({ { 26, 38 }, { 41, 41 }, { 21, 53 }, { 36, 52 } }) do O.dot(c, l[1], l[2], "#c8c87a") O.dot(c, l[1] + 1, l[2], "#a8ac62") end
-- a crack across the upper left block
O.dots(c, { { 19, 37 }, { 20, 38 }, { 21, 38 }, { 22, 39 }, { 22, 40 }, { 23, 41 } }, STN[1])
O.dots(c, { { 20, 37 }, { 21, 37 }, { 23, 40 } }, STN[5])

-- the fig hanging on a stalk (right), behind the leaf
O.dots(c, { { 47, 21 }, { 48, 22 }, { 49, 23 }, { 49, 24 } }, BARK[2])
local fig = c:ellipse(50, 29, 3.5, 4) fig:add(c:ellipse(50, 25.5, 1.5, 1.5))
O.shade(c, fig, FIG, { sphere = { 48, 26, 7 }, amb = .3, sep = FIG[1], rim = true })
O.dots(c, { { 49, 33 }, { 50, 33 } }, FIG[1])
O.dots(c, { { 51, 28 }, { 49, 31 }, { 52, 31 } }, FIG[5]) -- speckles
-- closer look: a tiny fig wasp on the fig
O.dots(c, { { 53, 27 }, { 54, 27 } }, "#2b1c26") O.dot(c, 54, 26, "#f5b82e") O.dot(c, 53, 26, "#d8eef8")

-- head: twisted root knot
local head = c:ellipse(32, 21, 13, 11)
for _, q in ipairs({ { 20, 16, 3, 3.5 }, { 44, 16, 3, 3.5 }, { 23, 30, 4, 2.5 }, { 41, 30, 4, 2.5 }, { 27, 11, 3.5, 2.5 }, { 38, 11, 3.5, 2.5 } }) do
  head:add(c:ellipse(q[1], q[2], q[3], q[4])) -- knobbly root lumps
end
local hb = {}
head:each(function(x, y)
  local a = math.atan(y - 21, x - 32)
  local r = math.sqrt((x - 32)^2 + (y - 21)^2)
  if math.abs(math.sin(a * 2 + r * .55)) < .24 and r > 5 then hb[K(x, y)] = -1 end -- spiral twist grain
end)
local hI, hT = O.shade(c, head, BARK, { sphere = { 27, 15, 17 }, amb = .3, wrap = .45, bias = hb, sep = BARK[1], rim = true, bounce = "#6a6a9a", bmax = 2 })
-- bark fissures (short dark vertical cracks) outside the face
O.tex(c, hI, hT, BARK, function(x, y, i)
  if (x - 32)^2 / 64 + (y - 22)^2 / 42 < 1 then return end
  if H(x, y // 3, 17) > .8 and i >= 2 then return -1 end
end)
-- thin aerial roots dangling from the sides of the head
for _, a in ipairs({ { 19, 22, 18, 38 }, { 45, 22, 46, 37 }, { 21, 31, 22, 39 } }) do
  for y = a[2], a[4] do
    local x = math.floor(a[1] + (a[3] - a[1]) * (y - a[2]) / (a[4] - a[2]) + .5)
    O.dot(c, x, y, (y % 4 == 0) and BARK[4] or BARK[3])
  end
  O.dot(c, a[3], a[4], BARK[6])
end
-- two root coils wrapping the cheeks, framing the face
local function coil(p, w)
  local m, n, T = O.tube(p, w)
  local gb = {} m:each(function(x, y) if math.floor((T[K(x, y)] or 0) * 14) % 3 == 0 then gb[K(x, y)] = -1 end end)
  local i, t = O.shadeN(c, m, n, BARK, { amb = .3, wrap = .45, bias = gb, sep = BARK[1], rim = true, bounce = "#6a6a9a", bmax = 2 })
  O.tex(c, i, t, BARK, function(x, y, k) if H(x, y, 23) > .88 and k <= 4 then return 1 end end)
end
coil({ { 25, 10 }, { 17, 13 }, { 17, 27 }, { 27, 32 } }, function(t) return 1.9 - math.abs(t - .5) * 1.2 end)
coil({ { 39, 10 }, { 47, 13 }, { 47, 27 }, { 37, 32 } }, function(t) return 1.9 - math.abs(t - .5) * 1.2 end)

-- two roots wrap down round the stone and cross in front
local function root(p, w)
  local m, n, T = O.tube(p, w)
  local gb = {} m:each(function(x, y) if math.floor((T[K(x, y)] or 0) * 18) % 3 == 0 then gb[K(x, y)] = -1 end end)
  O.shadeN(c, m, n, BARK, { amb = .3, wrap = .45, bias = gb, sep = BARK[1], rim = true, bounce = "#6a6a9a", bmax = 2 })
end
root({ { 21, 27 }, { 12, 36 }, { 22, 50 }, { 44, 53 } }, function(t) return 2.6 - t * .6 end)  -- left root, across the bottom
root({ { 43, 27 }, { 52, 38 }, { 40, 46 }, { 18, 40 } }, function(t) return 2.6 - t * .8 end)  -- right root, across the middle
-- root feet on the ground
root({ { 20, 51 }, { 17, 54 }, { 14, 56 }, { 10, 57 } }, function(t) return 2 - t * 1.2 end)
root({ { 44, 52 }, { 47, 55 }, { 51, 57 }, { 55, 57 } }, function(t) return 2 - t * 1.2 end)

-- fig leaves on top (lobed, with midribs)
local FL = { { 0, 0 }, { -3, -1 }, { -6, -3 }, { -5, -5 }, { -2, -5 }, { -4, -8 }, { -1, -10 }, { 0, -9 }, { 1, -10 }, { 4, -8 }, { 2, -5 }, { 5, -5 }, { 6, -3 }, { 3, -1 } }
local function leaf(cx, cy, d)
  local a = d * .55
  local ca, sa = math.cos(a), math.sin(a)
  local pts = {}
  for _, p in ipairs(FL) do pts[#pts+1] = { cx + p[1] * ca - p[2] * sa, cy + p[1] * sa + p[2] * ca } end
  local m = c:poly(pts)
  O.shade(c, m, LEAF, { R = 2, amb = .32, wrap = .45, sep = LEAF[1], rim = true })
  for t = 1, 8 do -- midrib
    local px, py = cx - (-t) * sa, cy + (-t) * ca
    O.mark(c, { { math.floor(px + .5), math.floor(py + .5) } }, LEAF[2])
    if t == 3 or t == 6 then -- side veins
      for _, sd in ipairs({ -1, 1 }) do
        for u = 1, 2 do
          local vx, vy = px + sd * u * ca - u * .6 * sa * 0, py + sd * u * sa - u * .6
          O.mark(c, { { math.floor(vx + .5), math.floor(vy + .5) } }, LEAF[3])
        end
      end
    end
  end
end
leaf(27, 12, -1)
leaf(37, 12, 1)
O.dots(c, { { 31, 11 }, { 32, 10 }, { 33, 11 } }, BARK[3]) -- twig nub between them

-- root strands knotted over the crown (an X tied over the head)
local function strand(p) local m, n = O.tube(p, function() return 1.3 end) O.shadeN(c, m, n, BARK, { amb = .3, wrap = .45, sep = BARK[1], rim = true }) end
strand({ { 20, 21 }, { 22, 13 }, { 30, 10 }, { 40, 15 } })
strand({ { 44, 21 }, { 42, 13 }, { 34, 10 }, { 24, 15 } })

-- face on the knot
c:eyeLocked(25, 18)
c:eyeLocked(35, 18)
c:cheek(22, 25) c:cheek(41, 25)
-- tight-lipped little smile (keeping the secret)
O.dots(c, { { 29, 26 }, { 30, 27 }, { 31, 27 }, { 32, 27 }, { 33, 27 }, { 34, 26 } }, "#3e1620")

-- quirk: the secret scroll pinned where the roots cross
local sc = c:rect(28, 45, 36, 47)
O.shade(c, sc, PAPR, { R = 1, amb = .4, cuts = { .35, .7 }, sep = BARK[1] })
O.dots(c, { { 28, 45 }, { 28, 46 }, { 28, 47 }, { 36, 45 }, { 36, 46 }, { 36, 47 } }, PAPR[1]) -- rolled ends
O.flat(c, c:rect(32, 45, 33, 47), "#b52e3f", "seal") O.dot(c, 32, 45, "#e8493b")

O.done(c, "mt-fig-knot-yard")

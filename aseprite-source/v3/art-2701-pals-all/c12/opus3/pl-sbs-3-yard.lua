-- Buttress Tangle (pl-sbs-3), yard sprite 64x64. Opus richness pass (c12/opus3), built on c12/opus2.
-- Rootwarden, common, Hollow of the Silverback Spider. "A knot of silk tucked in the buttress roots, guarding a
-- good hiding spot."
-- Haiku was a yellow ball between two brown cones (read as a sun on hills, the roots and the hollow did not
-- read). Now two flared buttress roots sweep down from a trunk foot into an arch (bark grain along each root,
-- moss on the lit shoulders) over a dark hollow. Tucked in the hollow's mouth sits the tangle: a big warm cream
-- ball of loosely wound silk with crossing strands, two thread arms stretched out to the
-- roots like a little gate rope.
-- quirk: it is guarding a good hiding spot: an acorn stash peeks out of the dark behind it.
-- closer look: a tiny red mushroom with cream spots at the foot of the right root.
-- richness (opus3): plum-to-tan hue-shifted bark, a hollow that deepens toward the back with a faint lit
-- mouth edge, pale lichen flecks, cross-hatched cap scales and a shine on each acorn, a loose thread end with
-- a glossy sticky bead hanging off the ball, glossy strand sheen between the grooves.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-sbs-3-yard", 64)

local BARK = { "#2c1a28", "#4a2a30", "#6e4034", "#985e3e", "#bf8656", "#dcae78" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SILK = { "#5a4440", "#8a6e5e", "#b8a08a", "#dccab0", "#f0e4cc", "#fbf5e6" }
local NUT  = { "#3a2420", "#5e3a26", "#8a5a30", "#b98040", "#dca85a", "#f0cc84" }
local CAP  = { "#3a2a24", "#5a4030", "#7e5c40", "#a07a56", "#c49c72", "#e0c094" }

c:groundShadow(32, 57, 27, 2)

-- the dark hollow first (behind everything): the hiding spot under the root arch
local hollow = c:ellipse(32, 38, 19, 25)
hollow:cut(c:rect(0, 56, 63, 63))
O.flat(c, hollow, "#2a1a24", "hollow")
-- depth: the back of the hollow is darkest, the mouth near the roots a touch warmer, a few root hairs
hollow:each(function(x, y)
  local d = ((x - 32) / 19) ^ 2 + ((y - 38) / 25) ^ 2
  if d > .55 then c:put(x, y, "#3a2430", { r = { name = "hollow" } }) end
  if y > 46 and (y + x) % 5 == 0 then c:put(x, y, "#3a2430", { r = { name = "hollow" } }) end
end)
for _, p in ipairs({ { 29, 14 }, { 29, 15 }, { 30, 16 }, { 36, 14 }, { 36, 15 }, { 35, 17 } }) do c:put(p[1], p[2], "#4a3036", { r = { name = "hollow" } }) end

-- two flared buttress roots meeting in a trunk foot at the top: an arch over the hollow
local roots = HP.mask()
local rootIdx = {}
local function root(pts)
  local m, n, T = O.tube(pts, function(t) return 4 + 2.3 * t end)
  return m, n, T
end
local lm, ln, lT = root({ { 30, 6 }, { 17, 12 }, { 11, 30 }, { 10, 55 } })
local rm, rn, rT = root({ { 34, 6 }, { 47, 12 }, { 53, 30 }, { 54, 55 } })
lm:cut(c:rect(0, 56, 63, 63)) rm:cut(c:rect(0, 56, 63, 63))
local trunk = c:ellipse(32, 6, 10, 5) trunk:cut(c:rect(0, 0, 63, 2))
local kI, kT = O.shade(c, trunk, BARK, { R = 3, amb = .22, wrap = .4, rim = true })
local lI, lTk = O.shadeN(c, lm, ln, BARK, { amb = .22, wrap = .4, rim = true, bounce = "#5a4a6e", bmax = 2 })
local rI, rTk = O.shadeN(c, rm, rn, BARK, { amb = .22, wrap = .4, rim = true, bounce = "#5a4a6e", bmax = 2, sep = BARK[1] })
-- bark grain: fissures running along each root
for _, R in ipairs({ { lI, lTk, lT, 1 }, { rI, rTk, rT, 2 } }) do
  O.tex(c, R[1], R[2], BARK, function(x, y, i)
    local t = R[3][K(x, y)] or 0
    local u = (R[4] == 1 and (x + t * 30) or (-x + t * 30)) + math.sin(y * .5) * .7
    if u % 4 < 1 then return -1 end
    if u % 4 > 3.3 and i >= 3 then return 1 end
  end)
end
O.tex(c, kI, kT, BARK, function(x, y, i) if x % 4 == 0 then return -1 end end)
-- moss on the lit outer shoulders of the roots
for _, p in ipairs({ { 13, 16 }, { 12, 18 }, { 11, 20 }, { 10, 22 }, { 9, 24 }, { 15, 14 }, { 17, 13 }, { 46, 10 }, { 48, 11 }, { 50, 13 } }) do
  O.mark(c, { p, { p[1] + 1, p[2] } }, MOSS[3]) O.mark(c, { { p[1] + 1, p[2] + 1 }, { p[1] + 2, p[2] + 1 } }, MOSS[2])
end
O.mark(c, { { 13, 15 }, { 48, 9 } }, MOSS[4])
-- pale lichen flecks low on the roots
O.mark(c, { { 7, 44 }, { 8, 45 }, { 9, 49 }, { 56, 41 }, { 55, 46 }, { 57, 47 } }, "#a8b494")

-- quirk: the acorn stash peeking out of the hollow
local function acorn(x, y, flip)
  local nut = c:ellipse(x, y + 2, 2.5, 3)
  O.shade(c, nut, NUT, { sphere = { x - 1, y, 4 }, amb = .3, wrap = .4, sep = NUT[1] })
  O.mark(c, { { x - 1, y + 1 } }, NUT[6]) -- shine
  local cap = c:ellipse(x, y - 1, 3, 1.6)
  local I, T = O.shade(c, cap, CAP, { sphere = { x - 1, y - 2, 4 }, amb = .3, wrap = .4, sep = CAP[1] })
  O.tex(c, I, T, CAP, function(px, py, i) if (px + py) % 2 == 0 and i >= 3 then return -1 end end) -- cap scales
  O.dot(c, x + (flip and -1 or 1), y - 3, CAP[2])
end
acorn(22, 30, true) acorn(27, 27) acorn(42, 31)

-- the tangle: a warm cream ball of loosely wound silk
local ball = c:ellipse(32, 44, 13, 11)
local bI, bT = O.shade(c, ball, SILK, { sphere = { 26, 37, 19 }, amb = .3, wrap = .45, rim = true, bounce = "#8a7aa8", bmax = 2 })
-- crossing wound strands: two families of diagonal grooves, clear of the face
O.tex(c, bI, bT, SILK, function(x, y, i)
  if y >= 41 and y <= 51 and x >= 23 and x <= 41 then return 0 end
  local a = (x + y * 1.4) % 6
  local b = (x - y * .9 + 60) % 7
  if a < 1 or b < 1 then return i >= 4 and -2 or -1 end
  if a > 4.6 and a < 5.4 and i >= 3 and i <= 5 then return 1 end -- glossy strand sheen
end)
-- loose thread end trailing off the ball, with a sticky bead
local le, lne = O.tube({ { 38, 54 }, { 41, 56 }, { 44, 55 }, { 45, 57 } }, function() return .7 end)
O.shadeN(c, le, lne, SILK, { amb = .35, wrap = .45 })
-- gate-rope arms stretched out to both roots, guarding the hollow
local arm, an = O.tube({ { 44, 42 }, { 47, 39 }, { 49, 38 }, { 52, 40 } }, function() return .9 end)
O.shadeN(c, arm, an, SILK, { amb = .35, wrap = .45 })
local arm2, an2 = O.tube({ { 20, 42 }, { 17, 39 }, { 15, 38 }, { 12, 40 } }, function() return .9 end)
O.shadeN(c, arm2, an2, SILK, { amb = .35, wrap = .45 })

-- closer look: a tiny mushroom on the right root
O.flat(c, c:rect(58, 52, 58, 54), "#f0e4cc")
O.shade(c, c:ellipse(58, 51, 2, 1.4), { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }, { sphere = { 57, 50, 3 }, amb = .3 })
O.mark(c, { { 57, 50 }, { 59, 51 } }, "#f0e4cc") -- spots

-- face: watchful guard (steady brows), small firm smile
c:cheek(24, 48) c:cheek(38, 48)
O.dots(c, { { 30, 49 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, P.ink)

O.done(c, "pl-sbs-3-yard", function(c)
  c:eyeLocked(25, 42)
  c:eyeLocked(34, 42)
  for i = 0, 3 do c:put(25 + i, 40, P.ink) c:put(35 + i, 40, P.ink) end
  c:put(46, 58, "#c4dcef") c:put(46, 59, "#7aa0c8") -- sticky bead on the thread end
end)

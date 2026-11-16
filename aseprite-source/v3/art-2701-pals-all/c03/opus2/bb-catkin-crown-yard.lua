-- Catkin Crown (bb-catkin-crown), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus2), built on the
-- Haiku first pass. Uncommon, rootwarden, Birchbramble. "Wears a crown of catkins and sneezes gold when pleased."
-- A round moss-tufted body wearing a band of twisted birch twig (white bark, dark lenticel dashes, two birch leaves);
-- five soft catkins spring from the band and droop outward like a fountain, beaded so they read as catkins
-- (the first pass drew straight gold prongs). quirk: a pleased little sneeze, a puff of gold pollen off to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-catkin-crown-yard", 64)

local MOSS = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070", "#cfe896" }
local CAT  = { "#4e3e1a", "#7a6a1e", "#a8962a", "#cdb83a", "#e6d660", "#f6ee9e" }
local BIR  = { "#4a3a44", "#8a7f8e", "#c6c0c8", "#ebe6e3" }
local LEAF = { "#2a5a32", "#4a8a3a", "#7cbc4a", "#b4e070" }
local GOLD = { "#8a5a14", "#c8901e", "#f0c040", "#fbe68a" }

c:groundShadow(30, 58, 17, 2.5)
for _, fx in ipairs({ 23, 37 }) do O.shade(c, c:ellipse(fx, 55, 4, 2), MOSS, { R = 1, amb = .25, sep = MOSS[1] }) end

-- body
local body = c:ellipse(30, 41, 16, 13)
local bI, bT = O.shade(c, body, MOSS, { sphere = { 26, 36, 18 }, amb = .2, wrap = .4, sep = MOSS[1], rim = true, bounce = "#4a7a8a", bmax = 2 })
O.tex(c, bI, bT, MOSS, function(x, y, i) -- moss tufts: lit tips and dark roots
  local h = H(x, y, 7)
  local face = x > 19 and x < 42 and y > 34 and y < 48
  if not face and h > .88 and i <= 5 then return 1 end
  if not face and h < .07 and i >= 2 then return -1 end
end)

-- catkins: soft beaded tassels springing up and drooping outward
local function catkin(p, r)
  -- a chain of small overlapping beads along a curve: lumpy, fuzzy silhouette
  local m = HP.mask()
  local beads = {}
  for k = 0, 7 do
    local t = k / 7
    local x, y = O.bez(p, t)
    local rr = r * (1 - .3 * t)
    beads[#beads+1] = { x, y, rr }
    m:add(c:ellipse(x, y, rr, rr))
  end
  local idx, tok = O.shade(c, m, CAT, { R = 2, amb = .3, wrap = .4, sep = CAT[1] })
  O.tex(c, idx, tok, CAT, function(x, y, i) -- seam between beads, lit fuzz dots
    local best, bk = 1e9, 0
    for k, b in ipairs(beads) do local d = (x - b[1])^2 + (y - b[2])^2 if d < best then best, bk = d, k end end
    if bk % 2 == 0 and i >= 3 and i <= 5 then return -1 end
    if H(x, y, 5) > .85 and i <= 5 then return 1 end
  end)
end
catkin({ { 30, 23 }, { 30, 17 }, { 31, 12 }, { 34, 9 } }, 2.6)
catkin({ { 23, 24 }, { 21, 19 }, { 18, 15 }, { 15, 15 } }, 2.5)
catkin({ { 37, 24 }, { 40, 19 }, { 43, 15 }, { 46, 16 } }, 2.5)
catkin({ { 17, 27 }, { 13, 24 }, { 10, 22 }, { 8, 25 } }, 2.3)
catkin({ { 43, 27 }, { 47, 24 }, { 50, 22 }, { 52, 25 } }, 2.3)

-- twisted birch-twig band
local band = c:poly{ { 14, 31 }, { 20, 27 }, { 30, 25.5 }, { 40, 27 }, { 46, 31 }, { 46, 33 }, { 40, 30 }, { 30, 28.5 }, { 20, 30 }, { 14, 34 } }
local wI, wT = O.shade(c, band, BIR, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BIR[1] })
O.mark(c, { { 17, 31 }, { 22, 28 }, { 27, 27 }, { 33, 27 }, { 38, 28 }, { 43, 31 } }, BIR[1]) -- lenticels
O.mark(c, { { 18, 31 }, { 34, 27 } }, BIR[1])
-- two birch leaves on the band
for _, L in ipairs({ { 14, 33, -1 } }) do
  local lf = c:poly{ { L[1], L[2] }, { L[1] + 3 * L[3], L[2] - 3 }, { L[1] + 7 * L[3], L[2] - 2 }, { L[1] + 4 * L[3], L[2] + 1 } }
  O.shade(c, lf, LEAF, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = LEAF[1] })
  O.mark(c, { { L[1] + 2 * L[3], L[2] - 1 }, { L[1] + 3 * L[3], L[2] - 1 }, { L[1] + 4 * L[3], L[2] - 2 }, { L[1] + 5 * L[3], L[2] - 2 } }, LEAF[2])
end

-- face
c:eyeLocked(22, 37) c:eyeLocked(34, 37)
c:cheek(19, 43) c:cheek(40, 43)
O.dots(c, { { 27, 45 }, { 28, 46 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 45 } }, P.ink)
O.dots(c, { { 29, 47 }, { 30, 47 } }, "#e05a6a")

-- quirk: a pleased gold sneeze, three pollen puffs blowing out to the right
O.shade(c, O.unionCircles{ { 49.5, 46, 1.5, 1.5 } }, GOLD, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.shade(c, O.unionCircles{ { 54.5, 42, 2.4, 2.2 } }, GOLD, { R = 2, amb = .4, cuts = { .3, .55, .8 } })
O.shade(c, O.unionCircles{ { 59.5, 37.5, 1.6, 1.6 } }, GOLD, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.done(c, "bb-catkin-crown-yard", function(c)
  for _, d in ipairs({ { 53, 47 }, { 59, 44 }, { 51, 39 }, { 56, 35 } }) do c:put(d[1], d[2], GOLD[3]) end
  c:sparkle(60, 42)
end)

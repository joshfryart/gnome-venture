-- Catkin Crown (bb-catkin-crown), perch sprite 36x36. Opus second pass, hand-built at this size.
-- Round moss body, a birch-bark band and three bold beaded catkins (centre one upright, two splayed),
-- pill eyes and a smile. quirk: two gold pollen puffs from a pleased sneeze.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-catkin-crown-perch", 36)

local MOSS = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070", "#cfe896" }
local CAT  = { "#4e3e1a", "#7a6a1e", "#a8962a", "#cdb83a", "#e6d660", "#f6ee9e" }
local BIR  = { "#4a3a44", "#8a7f8e", "#c6c0c8", "#ebe6e3" }
local GOLD = { "#8a5a14", "#c8901e", "#f0c040", "#fbe68a" }

c:groundShadow(16, 32, 10, 1.5)
for _, fx in ipairs({ 12, 20 }) do O.shade(c, c:ellipse(fx, 31, 2.5, 1.2), MOSS, { R = 1, amb = .25, sep = MOSS[1] }) end
local body = c:ellipse(16, 23, 9, 7.5)
local bI, bT = O.shade(c, body, MOSS, { sphere = { 13, 20, 11 }, amb = .2, wrap = .4, sep = MOSS[1], rim = true, bounce = "#4a7a8a", bmax = 2 })
O.tex(c, bI, bT, MOSS, function(x, y, i)
  local face = x > 10 and x < 23 and y > 19 and y < 28
  if not face and H(x, y, 7) > .86 and i <= 5 then return 1 end
end)

local function catkin(p, r)
  local m, beads = HP.mask(), {}
  for k = 0, 4 do
    local t = k / 4
    local x, y = O.bez(p, t)
    beads[#beads+1] = { x, y }
    m:add(c:ellipse(x, y, r * (1 - .3 * t), r * (1 - .3 * t)))
  end
  local idx, tok = O.shade(c, m, CAT, { R = 1, amb = .3, wrap = .4, sep = CAT[1] })
  O.tex(c, idx, tok, CAT, function(x, y, i)
    local best, bk = 1e9, 0
    for k, b in ipairs(beads) do local d = (x - b[1])^2 + (y - b[2])^2 if d < best then best, bk = d, k end end
    if bk % 2 == 0 and i >= 3 and i <= 5 then return -1 end
  end)
end
catkin({ { 16, 13 }, { 16, 9 }, { 17, 6 }, { 19, 4.5 } }, 1.9)
catkin({ { 11, 14 }, { 9, 11 }, { 7, 9 }, { 5, 10 } }, 1.8)
catkin({ { 21, 14 }, { 23, 11 }, { 25, 9 }, { 27, 10 } }, 1.8)

local band = c:poly{ { 8, 17 }, { 12, 14.5 }, { 16, 14 }, { 20, 14.5 }, { 24, 17 }, { 24, 18 }, { 20, 16 }, { 16, 15.5 }, { 12, 16 }, { 8, 19 } }
O.shade(c, band, BIR, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BIR[1] })
O.mark(c, { { 10, 17 }, { 14, 15 }, { 18, 15 }, { 22, 16 } }, BIR[1])

c:eyeSmall(12, 20) c:eyeSmall(19, 20)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 22, 24, "#f5809f")
O.dots(c, { { 14, 25 }, { 15, 26 }, { 16, 26 }, { 17, 26 }, { 18, 25 } }, P.ink)

-- quirk: gold sneeze puffs
O.shade(c, O.unionCircles{ { 27, 25, 1.2, 1.2 } }, GOLD, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.shade(c, O.unionCircles{ { 31.5, 19.5, 1.7, 1.6 } }, GOLD, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.done(c, "bb-catkin-crown-perch", function(c)
  c:put(28, 21, GOLD[3]) c:put(34, 23, GOLD[3])
end)

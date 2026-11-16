-- Octo Ogle (cs-octo-ogle), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, wayfinder. "Ogles every shiny thing in the lagoon and then stares some more."
-- A violet octopus: tall domed mantle with darker spots, big locked eyes, an awed "o" mouth, tapering tentacles
-- that curl at the tips with pale suckers on their undersides.
-- Fixes: stiff stick legs replaced by curling, tapering tentacles with suckers; the trinket is now a clear gold
-- ring with a teal gem held up in a curled tip at eye height, so the stare has a target.
-- quirk: the gold ring it is ogling, with a twinkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-octo-ogle-yard", 64)

local OCT  = { "#2e1f52", "#4c3384", "#6e4fb4", "#9473d6", "#b99cec", "#dccaff" }
local SUCK = "#f2c4e0"
local TEN  = { "#2e1f52", "#4c3384", "#6e4fb4", "#8a68cc", "#a988e2" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }
local BNC = "#3a6a9a"

c:groundShadow(31, 58, 19, 2.5)

local function tentacle(p, w0, curl, suckSide)
  local m, n, T, S = O.tube(p, function(t) return w0 * (1 - t * .6) end)
  -- curled tip: a small loop at the end
  local ex, ey = p[4][1], p[4][2]
  local I, Tk = O.shadeN(c, m, n, TEN, { amb = .2, wrap = .3, sep = OCT[1], bounce = BNC, bmax = 1 })
  -- suckers: pale dots along one side, every 3rd sample
  local list = {}
  for i = 2, 9 do
    local t = i / 11
    local x, y = O.bez(p, t)
    local x2, y2 = O.bez(p, t + .01)
    local tx, ty = x2 - x, y2 - y
    local l = math.sqrt(tx * tx + ty * ty) if l == 0 then l = 1 end
    local nx, ny = -ty / l * suckSide, tx / l * suckSide
    local w = w0 * (1 - t * .6) - .6
    local sx, sy = math.floor(x + nx * w + .5), math.floor(y + ny * w + .5)
    if m:has(sx, sy) and i % 2 == 0 then list[#list+1] = { sx, sy } end
  end
  O.mark(c, list, SUCK)
end

-- back tentacles first
tentacle({ { 23, 35 }, { 12, 40 }, { 4, 55 }, { 10, 53 } }, 3.2, 0, -1)
tentacle({ { 40, 36 }, { 50, 41 }, { 57, 54 }, { 52, 52 } }, 3.2, 0, 1)
tentacle({ { 27, 38 }, { 21, 45 }, { 14, 57 }, { 19, 56 } }, 3, 0, -1)
tentacle({ { 36, 38 }, { 41, 46 }, { 48, 57 }, { 43, 56 } }, 3, 0, 1)
tentacle({ { 30, 39 }, { 29, 47 }, { 24, 58 }, { 28, 56 } }, 2.8, 0, -1)
tentacle({ { 33, 39 }, { 35, 47 }, { 39, 58 }, { 35, 57 } }, 2.8, 0, 1)

-- mantle + head in one shape
local head = c:ellipse(31, 22, 13, 13)
head:add(c:ellipse(31, 32, 13.5, 7))
local hI, hT = O.shade(c, head, OCT, { sphere = { 28, 18, 20 }, amb = .3, wrap = .35, sep = OCT[1], rim = true, bounce = BNC, bmax = 2 })
-- mantle spots
O.tex(c, hI, hT, OCT, function(x, y, i)
  if y < 22 and O.H(x, y, 5) > .93 and i >= 3 then return -1 end
end)
for _, s in ipairs({ { 22, 13 }, { 36, 10 }, { 40, 17 }, { 27, 8 } }) do
  O.mark(c, { { s[1], s[2] }, { s[1] + 1, s[2] }, { s[1], s[2] + 1 } }, OCT[3])
end
-- brow crease between mantle and face
O.mark(c, { { 21, 23 }, { 22, 22 }, { 23, 22 }, { 39, 22 }, { 40, 22 }, { 41, 23 } }, OCT[3])

-- raised tentacle holding the ring, in front of the body
do
  local p = { { 40, 37 }, { 50, 41 }, { 56, 31 }, { 52, 22 } }
  local m, n = O.tube(p, function(t) return 2.6 * (1 - t * .5) end)
  O.shadeN(c, m, n, OCT, { amb = .3, sep = OCT[1] })
  O.mark(c, { { 47, 39 }, { 52, 36 }, { 53, 31 }, { 53, 27 } }, SUCK)
  -- curl wrapped round the ring shank
  O.shade(c, c:ellipse(51.5, 22, 2, 1.5), OCT, { R = 1, amb = .35, sep = OCT[1] })
end
-- the gold ring
do
  local ring = c:ellipse(52, 15, 4.5, 4.5)
  ring:cut(c:ellipse(52, 15, 2.2, 2.2))
  O.shade(c, ring, GOLD, { sphere = { 50, 12, 6 }, amb = .25, wrap = .4, sep = GOLD[1] })
  -- teal gem on top
  local gem = c:ellipse(52, 10, 2, 1.5)
  O.shade(c, gem, { "#173f4f", "#1f6a72", "#2f9a94", "#4fc4b0", "#8ae6c8", "#c8f7e2" }, { R = 1, amb = .4, sep = GOLD[1] })
  O.dot(c, 51, 9, "#e4fff4")
end

-- face
c:eyeLocked(22, 25)
c:eyeLocked(35, 25)
c:cheek(19, 32) c:cheek(42, 32)
-- awed "o" mouth
O.dots(c, { { 30, 32 }, { 31, 32 }, { 29, 33 }, { 32, 33 }, { 29, 34 }, { 32, 34 }, { 30, 35 }, { 31, 35 } }, P.ink)
O.dots(c, { { 30, 33 }, { 31, 33 } }, "#7d2c5e")
O.dots(c, { { 30, 34 }, { 31, 34 } }, "#c94f84")

O.shift(c, 0, -1)
O.done(c, "cs-octo-ogle-yard", function(c)
  -- twinkle off the ring
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do c:put(58 + d[1], 9 + d[2], "#fff4d6") end
  c:put(57, 15, "#ffe38a")
end)

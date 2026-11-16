-- Octo Ogle (cs-octo-ogle), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, wayfinder. "Ogles every shiny thing in the lagoon and then stares some more."
-- A violet octopus: tall domed mantle with darker spots, big locked eyes, an awed "o" mouth, tapering tentacles
-- that curl at the tips with pale suckers on their undersides.
-- Fixes: stiff stick legs replaced by curling, tapering tentacles with suckers; the trinket is now a clear gold
-- ring with a teal gem held up in a curled tip at eye height, so the stare has a target.
-- Richness: hue-shifted ramps (indigo shadows, warm lilac lights), mottled chromatophore skin with pale specks,
-- rim light on the dome and tentacles, a pinker underside with ringed suckers, a
-- faceted gem and a shaded inner band on the ring.
-- quirk: the gold ring it is ogling, with a twinkle.
-- closer look: its stash of other shiny things (a pearl) tucked under the curl of its back tentacle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-octo-ogle-yard", 64)

local OCT  = { "#281c4e", "#44307e", "#6648ae", "#8c6ad2", "#b494e8", "#e2cef8" }
local SUCK = "#f6c8dc"
local SUCKD = "#b06aa8"
local TEN  = { "#281c4e", "#44307e", "#6648ae", "#8466c8", "#a888e0", "#ccb0f2" }
local UND  = { "#3e2458", "#6a3a86", "#9a5aa8", "#c07cc0", "#dca0d4", "#f0c8e4" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }
local BNC = "#3a6a9a"

c:groundShadow(31, 58, 19, 2.5)

local function tentacle(p, w0, curl, suckSide)
  local m, n, T, S = O.tube(p, function(t) return w0 * (1 - t * .6) end)
  local I, Tk = O.shadeN(c, m, n, TEN, { amb = .2, wrap = .3, sep = OCT[1], rim = true, bounce = BNC, bmax = 1 })
  -- pinker underside strip on the sucker side
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local sv = S[k]
    if sv and sv * suckSide > .45 and c.own[y * c.w + x] == Tk then c.pix[y * c.w + x] = UND[math.min(6, i)] end
  end
  -- mottled skin: soft darker blotches + a few pale specks
  O.tex(c, I, Tk, TEN, function(x, y, i)
    local h = O.H(x // 2, y // 2, 7)
    if h > .86 and i >= 3 and i <= 5 then return -1 end
    if O.H(x, y, 13) > .96 and i >= 3 then return 1 end
  end)
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
  local dl = {}
  for _, q in ipairs(list) do dl[#dl+1] = { q[1] + (suckSide > 0 and 1 or 1), q[2] + 1 } end
  local keep = {}
  for _, q in ipairs(dl) do if m:has(q[1], q[2]) then keep[#keep+1] = q end end
  O.mark(c, keep, SUCKD)
end

-- closer look: the stash under the back tentacles (a pearl under the left curl)
O.shade(c, c:ellipse(9, 57, 2.5, 2.5), { "#8a7894", "#bca8c0", "#e2d0d8", "#f6e8e6", "#fff4e8" }, { sphere = { 8, 56, 3 }, amb = .4, wrap = .4, cuts = { .25, .45, .7, .88 } })

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
-- mottled chromatophores on the mantle: soft 2x2 blotches, pale specks in the light
O.tex(c, hI, hT, OCT, function(x, y, i)
  if y < 23 and O.H(x // 2, y // 2, 5) > .84 and i >= 3 and i <= 5 then return -1 end
  if y < 21 and O.H(x, y, 17) > .955 and i >= 4 then return 1 end
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
  O.shadeN(c, m, n, OCT, { amb = .3, sep = OCT[1], rim = true })
  O.mark(c, { { 47, 39 }, { 52, 36 }, { 53, 31 }, { 53, 27 } }, SUCK)
  O.mark(c, { { 47, 40 }, { 53, 36 }, { 54, 31 }, { 54, 27 } }, SUCKD)
  -- curl wrapped round the ring shank
  O.shade(c, c:ellipse(51.5, 22, 2, 1.5), OCT, { R = 1, amb = .35, sep = OCT[1] })
end
-- the gold ring
do
  local ring = c:ellipse(52, 15, 4, 4)
  ring:cut(c:ellipse(52, 15, 2.5, 2.5))
  O.shade(c, ring, GOLD, { sphere = { 50, 12, 6 }, amb = .42, wrap = .4, sep = GOLD[1], rim = true })
  -- inner band of the hoop in shade (upper-left inside faces away from the light)
  O.mark(c, { { 50, 13 }, { 51, 12 }, { 50, 14 } }, GOLD[2])
  O.mark(c, { { 54, 17 }, { 53, 18 } }, GOLD[5])
  -- teal gem on top
  local gem = c:ellipse(52, 10, 2, 1.5)
  O.shade(c, gem, { "#173f4f", "#1f6a72", "#2f9a94", "#4fc4b0", "#8ae6c8", "#c8f7e2" }, { R = 1, amb = .4, sep = GOLD[1] })
  O.dot(c, 51, 9, "#e4fff4") O.dot(c, 52, 9, "#8ae6c8") O.dot(c, 53, 11, "#1f6a72")
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

-- Chilli Chime (sp-chilli-chime), yard sprite 64x64. Opus second pass (art-2701-pals-all/c06/opus2), built on the Haiku pass.
-- Common, brewroot. "Hangs chilli garlands that tinkle whenever the wind comes through."
-- A round moss-green pal with a tall wooden peg on its head (knob: peg). Two chilli garlands run from the
-- peg top down to either side like a festival pole, so the silhouette is a tent over a round body.
-- Fixes vs Haiku: chillis are real curved, tapering pods with green caps (not red bars), the garland is
-- clear of the head, bells are proper gold bells with a clapper, the body has a 6-tone ramp with rim light.
-- quirk: the wind is coming through: every chilli swings to the right, a wind curl blows in from the left,
-- and the end bells ring (sound ticks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-chilli-chime-yard", 64)

local MOSS = { "#24423a", "#33664a", "#4a8c4c", "#6cb256", "#9ad06a", "#cdea98" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local CHIL = { "#4a1020", "#7a1626", "#b01e2c", "#d8303a", "#f05a58", "#ff9e92" }
local STEM = { "#2c5a3a", "#5ea24c", "#a7d873" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local TWN  = "#8a6040"
local BNC  = "#4c6a8a"

c:groundShadow(32, 57, 17, 2.5)

-- feet
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 54, 4.5, 2.5), MOSS, { R = 2, amb = .2, wrap = .3, bounce = BNC, bmax = 2 })
end
-- body
local body = c:ellipse(32, 42, 16, 12.5)
local bI, bT = O.shade(c, body, MOSS, { sphere = { 26, 36, 19 }, amb = .26, wrap = .35, sep = MOSS[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, MOSS, function(x, y, i) -- soft moss flecks
  local h = H(x, y, 11)
  if h > .97 and i >= 4 then return -1 end
  if h < .03 and i >= 3 and i <= 5 then return 1 end
end)

-- the peg: a wooden pole on its head with a round cap
local pole = c:rect(31, 8, 33, 31)
local pb = {} pole:each(function(x, y) if x == 32 and y % 4 == 1 then pb[K(x, y)] = -1 end end)
O.shade(c, pole, WOOD, { R = 1, amb = .25, wrap = .4, bias = pb, sep = MOSS[2] })
O.shade(c, c:ellipse(32, 7, 2.5, 2), WOOD, { sphere = { 31, 6, 3 }, amb = .3, wrap = .4 })
O.mark(c, { { 30, 30 }, { 34, 30 }, { 31, 31 }, { 33, 31 } }, MOSS[2]) -- socket shadow where the peg goes in

-- garlands: twine from the peg top sagging down to each side
local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local G = {
  { { 31, 10 }, { 18, 22 }, { 8, 31 } },
  { { 33, 10 }, { 46, 22 }, { 56, 31 } },
}
for _, g in ipairs(G) do
  local seen = {}
  for i = 0, 80 do
    local x, y = bz(g[1], g[2], g[3], i / 80)
    x, y = math.floor(x + .5), math.floor(y + .5)
    if not seen[K(x, y)] then seen[K(x, y)] = true O.dot(c, x, y, TWN) end
  end
end

-- chillis hanging from the twine, all swung right by the wind
local function chilli(ax, ay, len, seed)
  local p = { { ax, ay + 1 }, { ax + 1, ay + len * .55 }, { ax + 1, ay + len }, { ax + 4, ay + len - 1 } }
  local m, n = O.tube(p, function(t) return t < .12 and 1.2 or (1.6 - 1.4 * t) end)
  local I, T = O.shadeN(c, m, n, CHIL, { amb = .22, wrap = .4, sep = CHIL[1] })
  -- cap + curled stalk
  O.dot(c, ax - 1, ay, STEM[2]) O.dot(c, ax, ay, STEM[3]) O.dot(c, ax + 1, ay, STEM[1])
  O.dot(c, ax, ay - 1, STEM[1])
  -- waxy streak
  O.mark(c, { { ax, ay + 2 }, { ax, ay + 3 } }, CHIL[6])
end
-- left strand (twine runs (31,10)->(8,31))
for _, t in ipairs({ .28, .55, .82 }) do
  local x, y = bz(G[1][1], G[1][2], G[1][3], t)
  chilli(math.floor(x + .5), math.floor(y + .5) + 1, 9, t)
end
for _, t in ipairs({ .28, .55, .82 }) do
  local x, y = bz(G[2][1], G[2][2], G[2][3], t)
  chilli(math.floor(x + .5), math.floor(y + .5) + 1, 9, t)
end

-- gold bells on the garland ends
local function bell(bx, by)
  local m = c:poly{ { bx - 1, by }, { bx + 1, by }, { bx + 3, by + 4 }, { bx - 3, by + 4 } }
  m:add(c:rect(bx - 1, by - 1, bx + 1, by))
  O.shade(c, m, GOLD, { sphere = { bx - 1, by, 4 }, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
  O.dot(c, bx, by + 5, GOLD[1]) -- clapper
  O.dot(c, bx - 1, by + 1, GOLD[5])
end
bell(7, 32) bell(57, 32)

-- face
c:eyeLocked(23, 37)
c:eyeLocked(36, 37)
O.dots(c, { { 30, 45 }, { 31, 46 }, { 32, 46 }, { 33, 45 } }, P.ink)
c:cheek(20, 44) c:cheek(42, 44)
-- tiny arms tucked at the sides
O.dots(c, { { 16, 46 }, { 17, 47 } }, MOSS[4]) O.dots(c, { { 47, 46 }, { 46, 47 } }, MOSS[2])

O.done(c, "sp-chilli-chime-yard", function(c)
  -- the wind coming through (curl, un-outlined) and the bells ringing (ticks)
  for _, p in ipairs({ { 2, 18 }, { 3, 17 }, { 4, 17 }, { 5, 17 }, { 6, 18 }, { 6, 19 }, { 5, 20 }, { 4, 20 }, { 7, 21 }, { 8, 21 }, { 9, 21 }, { 10, 21 }, { 1, 23 }, { 2, 23 }, { 3, 23 }, { 4, 23 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], "#a8c8d8") end
  end
  for _, p in ipairs({ { 61, 33 }, { 62, 32 }, { 61, 37 }, { 62, 37 }, { 2, 36 }, { 1, 35 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], GOLD[4]) end
  end
end)

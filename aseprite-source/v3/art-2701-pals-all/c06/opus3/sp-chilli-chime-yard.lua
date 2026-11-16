-- Chilli Chime (sp-chilli-chime), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Common, brewroot. "Hangs chilli garlands that tinkle whenever the wind comes through."
-- A round moss pal with a tall wooden peg on its head (knob: peg). Two twisted-twine chilli garlands run from
-- the peg cap down to gold bells on either side: a tent over a round body.
-- Richness: moss tufts (lit crowns + dark crevices) over the whole body, bark grain and a knot on the peg,
-- two-tone twisted twine, glossy chillis with a waxy streak, a ridge line and a curled stalk, bells with a
-- lit lip and a dark mouth, toe lines on the feet.
-- quirk: the wind is coming through: every chilli swings right, a wind curl blows in from the left and the
-- end bells ring. Closer look: one chilli on the right garland is still green (not ripe yet).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-chilli-chime-yard", 64)

local MOSS = { "#203a36", "#2e5c46", "#44844a", "#66aa52", "#94cc66", "#cce894" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local CHIL = { "#4a1020", "#7a1626", "#b01e2c", "#d8303a", "#f05a58", "#ff9e92" }
local GRNC = { "#1f3b2e", "#2c6a3a", "#4a9a48", "#6eb04c", "#a2d06a", "#d4ec9a" }
local STEM = { "#2c5a3a", "#5ea24c", "#a7d873" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local TWN  = { "#6a4630", "#a47a52" }
local BNC  = "#4c6a8a"

c:groundShadow(32, 57, 17, 2.5)

-- feet with two toe lines
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 54, 4.5, 2.5), MOSS, { R = 2, amb = .2, wrap = .3, bounce = BNC, bmax = 2 })
  O.mark(c, { { fx - 1, 55 }, { fx + 1, 55 } }, MOSS[2])
end
-- body: moss ball
local body = c:ellipse(32, 42, 16, 12.5)
local bI, bT = O.shade(c, body, MOSS, { sphere = { 26, 36, 19 }, amb = .26, wrap = .35, sep = MOSS[1], rim = true, bounce = BNC, bmax = 2 })
-- moss tufts: small clumps on a 4x3 jittered grid, lit crown on the upper-left of each, dark crevice
-- below-right; kept off the face oval so the eyes and smile stay clean
local function onFace(x, y) return ((x - 31.5) / 11)^2 + ((y - 41) / 6.5)^2 < 1 end
local tuft = {}
for gy = 0, 21 do for gx = 0, 16 do
  local h1, h2 = H(gx, gy, 3), H(gx, gy, 4)
  local x, y = gx * 4 + math.floor(h1 * 3), gy * 3 + math.floor(h2 * 2)
  if h1 + h2 > .45 then
    tuft[K(x, y)] = 1 tuft[K(x + 1, y)] = 1          -- lit crown of a tuft
    tuft[K(x - 1, y + 1)] = -1 tuft[K(x + 2, y + 1)] = -1 -- crevice either side below it
  end
end end
O.tex(c, bI, bT, MOSS, function(x, y, i)
  if onFace(x, y) then return 0 end
  local d = tuft[K(x, y)]
  if d == 1 and i >= 2 and i <= 5 then return 1 end
  if d == -1 and i >= 2 then return -1 end
end)
-- a few bright moss spore heads catching the light on the upper-left
O.mark(c, { { 21, 32 }, { 24, 30 }, { 18, 36 }, { 28, 30 } }, MOSS[6])

-- the peg: a wooden pole with bark grain, a knot and a round cap
local pole = c:rect(31, 8, 33, 31)
local pI, pT = O.shade(c, pole, WOOD, { R = 1, amb = .25, wrap = .4, sep = MOSS[2], rim = true })
O.tex(c, pI, pT, WOOD, function(x, y, i)
  if x == 32 and (y % 5 == 1 or y % 5 == 2) then return -1 end -- grain streaks
  if x == 31 and y % 7 == 4 then return 1 end
end)
O.mark(c, { { 33, 22 } }, WOOD[1]) O.mark(c, { { 32, 22 }, { 33, 21 } }, WOOD[2]) -- knot
O.shade(c, c:ellipse(32, 7, 2.5, 2), WOOD, { sphere = { 31, 6, 3 }, amb = .3, wrap = .4 })
O.mark(c, { { 32, 8 }, { 33, 8 } }, WOOD[2]) -- cap shadow on the pole
O.mark(c, { { 30, 30 }, { 34, 30 }, { 31, 31 }, { 33, 31 } }, MOSS[1]) -- socket shadow where the peg goes in

-- garlands: twisted twine from the peg cap sagging down to each side
local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local G = {
  { { 31, 9 }, { 18, 22 }, { 8, 31 } },
  { { 33, 9 }, { 46, 22 }, { 56, 31 } },
}
for _, g in ipairs(G) do
  local seen, n = {}, 0
  for i = 0, 80 do
    local x, y = bz(g[1], g[2], g[3], i / 80)
    x, y = math.floor(x + .5), math.floor(y + .5)
    if not seen[K(x, y)] then seen[K(x, y)] = true n = n + 1 O.dot(c, x, y, TWN[(n % 3 == 0) and 2 or 1]) end
  end
end

-- chillis hanging from the twine, all swung right by the wind
local function chilli(ax, ay, len, R)
  local p = { { ax, ay + 1 }, { ax + 1, ay + len * .55 }, { ax + 1, ay + len }, { ax + 4, ay + len - 1 } }
  local m, n, T, S = O.tube(p, function(t) return t < .12 and 1.3 or (1.8 - 1.5 * t) end)
  local I, Tk = O.shadeN(c, m, n, R, { amb = .22, wrap = .4, sep = R[1] })
  -- ridge line down the shaded flank
  O.tex(c, I, Tk, R, function(x, y, i) local s = S[K(x, y)] if s and s > .35 and s < .75 and i >= 3 then return -1 end end)
  -- calyx + curled stalk
  O.dot(c, ax - 1, ay, STEM[2]) O.dot(c, ax, ay, STEM[3]) O.dot(c, ax + 1, ay, STEM[1])
  O.dot(c, ax, ay - 1, STEM[1])
  -- waxy streak
  O.mark(c, { { ax, ay + 2 }, { ax, ay + 3 } }, R[6]) O.mark(c, { { ax, ay + 4 } }, R[5])
end
local i = 0
for gi = 1, 2 do
  for _, t in ipairs({ .28, .55, .82 }) do
    i = i + 1
    local x, y = bz(G[gi][1], G[gi][2], G[gi][3], t)
    -- closer look: the middle chilli on the right garland is not ripe yet
    chilli(math.floor(x + .5), math.floor(y + .5) + 1, 9, (gi == 2 and t == .55) and GRNC or CHIL)
  end
end

-- gold bells on the garland ends: lit lip, dark mouth, clapper
local function bell(bx, by)
  local m = c:poly{ { bx - 1, by }, { bx + 1, by }, { bx + 3, by + 4 }, { bx - 3, by + 4 } }
  m:add(c:rect(bx - 1, by - 1, bx + 1, by))
  O.shade(c, m, GOLD, { sphere = { bx - 1, by, 4 }, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
  O.mark(c, { { bx - 2, by + 3 }, { bx - 1, by + 3 } }, GOLD[4])      -- lip catches the light
  O.mark(c, { { bx - 1, by + 4 }, { bx, by + 4 }, { bx + 1, by + 4 } }, GOLD[1]) -- dark mouth
  O.dot(c, bx, by + 5, GOLD[2]) -- clapper swinging out
  O.mark(c, { { bx - 1, by } }, GOLD[5])
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

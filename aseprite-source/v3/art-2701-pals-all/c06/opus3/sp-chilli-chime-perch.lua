-- Chilli Chime (sp-chilli-chime), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: round moss pal, wooden peg, one twine garland to each side
-- with two hooked chillis and a gold bell at the end. Face: c:eyeSmall pills, smile, cheeks.
-- Fixes the opus2 weakness (2-3 px chillis read as red drops): each chilli is now a hand-placed 3 px wide pod,
-- 7 px long, with a green calyx and stalk, a waxy streak and a hooked tip, inked where it crosses the body.
-- Richness: moss tuft texture, bark grain on the peg, bells with a dark mouth.
-- quirk: the wind swings every chilli to the right and the bells ring (ticks, un-outlined).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-chilli-chime-perch", 36)

local MOSS = { "#203a36", "#2e5c46", "#44844a", "#66aa52", "#94cc66", "#cce894" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local CHIL = { "#4a1020", "#7a1626", "#b01e2c", "#d8303a", "#f05a58", "#ff9e92" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local TWN  = "#8a6040"
local BNC  = "#4c6a8a"

c:groundShadow(18, 33, 10, 1)
local body = c:ellipse(18, 25, 9.5, 7.5)
local bI, bT = O.shade(c, body, MOSS, { sphere = { 14, 21, 11 }, amb = .26, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, MOSS, function(x, y, i)
  if y >= 22 and y <= 29 and x >= 11 and x <= 25 then return 0 end -- keep the face clean
  if (x + (y // 2) % 2 * 2) % 4 == 0 and y % 2 == 0 and i >= 3 and i <= 5 then return 1 end
  if (x + (y // 2) % 2 * 2) % 4 == 2 and y % 2 == 1 and i >= 2 then return -1 end
end)
for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 32, 2.5, 1), MOSS, { R = 1, amb = .25, bounce = BNC, bmax = 2, sep = MOSS[1] }) end
local pI, pT = O.shade(c, c:rect(17, 7, 18, 17), WOOD, { R = 1, amb = .3, wrap = .4, sep = MOSS[1] })
O.tex(c, pI, pT, WOOD, function(x, y, i) if x == 18 and y % 3 == 0 then return -1 end end)
O.shade(c, c:ellipse(17.5, 6, 2, 1.5), WOOD, { sphere = { 17, 5, 2 }, amb = .3 })

local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local G = { { { 16, 7 }, { 9, 10 }, { 3, 16 } }, { { 19, 7 }, { 26, 10 }, { 32, 16 } } }
for _, g in ipairs(G) do
  for i = 0, 40 do local x, y = bz(g[1], g[2], g[3], i / 40) O.dot(c, math.floor(x + .5), math.floor(y + .5), TWN) end
end
-- bold chilli pod (swung right by the wind): s stalk, g calyx, w waxy, l lit, b base, d shade
local POD = {
  ".s..",
  "ggg.",
  "wbd.",
  "lbd.",
  "lbbd",
  ".bbd",
  "..bd",
  "...d",
}
local map = { s = "#2c5a3a", g = "#5ea24c", w = CHIL[6], l = CHIL[5], b = CHIL[4], d = CHIL[2] }
local function chilli(ax, ay)
  local m = O.pat(c, ax - 1, ay, POD, map, "chilli")
  O.inkAround(c, m)
end
chilli(10, 10) chilli(5, 14)
chilli(23, 10) chilli(28, 14)
for _, bx in ipairs({ 3, 32 }) do
  local m = c:poly{ { bx - 1, 16 }, { bx + 1, 16 }, { bx + 2, 19 }, { bx - 2, 19 } }
  O.shade(c, m, GOLD, { sphere = { bx - 1, 17, 3 }, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 } })
  O.mark(c, { { bx - 1, 19 }, { bx, 19 }, { bx + 1, 19 } }, GOLD[1])
  O.mark(c, { { bx - 1, 16 } }, GOLD[5])
end

c:eyeSmall(13, 23) c:eyeSmall(21, 23)
O.dots(c, { { 16, 27 }, { 17, 28 }, { 18, 28 }, { 19, 27 } }, P.ink)
c:cheek(10, 27) c:cheek(24, 27)

O.shift(c, 0, -1)
O.done(c, "sp-chilli-chime-perch", function(c)
  for _, p in ipairs({ { 0, 15 }, { 1, 14 }, { 35, 15 }, { 34, 14 }, { 35, 19 }, { 0, 19 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], GOLD[4]) end
  end
end)

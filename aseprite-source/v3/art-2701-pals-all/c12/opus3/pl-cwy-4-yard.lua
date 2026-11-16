-- Spine Spark (pl-cwy-4), yard sprite 64x64. Opus richness pass (c12/opus3), built on c12/opus2.
-- Thornblade, uncommon, Forge of the Cinder Wyrm. "Four little spikes that pop like sparklers when stepped on."
-- Haiku was a red blob with yellow horns (read as a devil, and too close to the red Scorch Sliver). Now a round
-- body of quenched forge steel (cool blue with a cold sheen) on two stubby feet, with four tapered spikes
-- carrying real temper colours from the root out: steel blue, violet, bronze, straw gold, so they read as
-- forged and hot at the tips. Three hammer dimples on the body (closer look).
-- quirk: it has just been stepped on: the upper-right spike is popping in a big sparkler burst, the other tips
-- fizz with small gold sparks.
-- richness (opus3): indigo-to-ice hue-shifted steel, mottled forge scale low right, polish streaks, a raised
-- forged ridge and a dark collar on every spike, split toes. closer look: more hammer dimples and a tiny flame
-- maker's stamp low on its belly (the wyrm's forge mark).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-4-yard", 64)

local STEEL  = { "#221f46", "#33386a", "#4b5a96", "#6c86c0", "#9fc0e4", "#d8eef8" }
local VIOLET = { "#2e1f48", "#4a2d6a", "#6e4290", "#9566b4", "#bb92d2", "#dcc4ea" }
local BRONZE = { "#4a2a24", "#74402a", "#a4602e", "#cc8a3c", "#e8b45a", "#f8da8c" }
local STRAW  = { "#6a4022", "#a0682a", "#d39a32", "#f2c248", "#ffe07a", "#fff3b8" }

c:groundShadow(30, 56, 15, 2)

-- feet first (behind the body)
for _, f in ipairs({ { 23, 51 }, { 35, 51 } }) do
  O.shade(c, c:ellipse(f[1], f[2], 4, 2.5), STEEL, { sphere = { f[1] - 2, f[2] - 2, 5 }, amb = .2, wrap = .3 })
  O.mark(c, { { f[1] - 1, f[2] + 2 }, { f[1] + 1, f[2] + 2 } }, STEEL[1]) -- split toes
end

-- four spikes: base at the body, tip outward (each a tapered tube)
local spikes = {
  { { 21, 25 }, { 17, 19 }, { 14, 15 }, { 11, 11 } },   -- upper left
  { { 38, 24 }, { 42, 18 }, { 44, 15 }, { 47, 10 } },   -- upper right (the popping one)
  { { 15, 38 }, { 11, 38 }, { 8, 37 }, { 5, 35 } },     -- left
  { { 45, 38 }, { 49, 38 }, { 52, 37 }, { 55, 35 } },   -- right
}
local tips = {}
for _, s in ipairs(spikes) do
  local m, n, T, S = O.tube(s, function(t) return 3.2 * (1 - t) + .4 end)
  local I, Tk = O.shadeN(c, m, n, STEEL, { amb = .25, wrap = .35 })
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local t = T[k] or 0
    local R = t < .3 and STEEL or t < .52 and VIOLET or t < .74 and BRONZE or STRAW
    local j = i
    if math.abs(S[k] or 1) < .3 and t > .12 and t < .9 then j = math.min(6, i + 1) end -- forged ridge
    if t > .16 and t < .23 then j = math.max(1, i - 2) end -- collar
    if c.own[y * c.w + x] == Tk then c.pix[y * c.w + x] = R[j]:lower() end
  end
  tips[#tips + 1] = s[4]
end

-- the body: a quenched steel ball
local body = c:ellipse(30, 36, 16, 15)
local bI, bT = O.shade(c, body, STEEL, { sphere = { 24, 29, 22 }, amb = .2, wrap = .4, rim = true, bounce = "#6a5aa0", bmax = 2, sep = STEEL[2] })
-- cold sheen: a broad lit band upper left, and hammer dimples (dark pit + lit lower lip)
O.mark(c, { { 20, 27 }, { 21, 26 }, { 22, 25 }, { 23, 25 }, { 19, 29 }, { 18, 31 } }, STEEL[6])
-- forge scale: mottled dark flecks gathering low right; fine polish streaks upper left
O.tex(c, bI, bT, STEEL, function(x, y, i)
  if y >= 31 and y <= 45 and x >= 20 and x <= 41 then return 0 end -- face stays clean
  local lr = (x - 30) + (y - 36)
  if lr > 6 and H(x, y, 21) > .7 and i <= 4 then return -1 end
  if lr < -10 and (x + 2 * y) % 7 == 0 and i >= 3 and i <= 5 then return 1 end
end)
for _, d in ipairs({ { 39, 29 }, { 42, 42 }, { 34, 47 }, { 17, 37 }, { 44, 35 }, { 24, 48 } }) do
  local i = bI[K(d[1], d[2])] or 3
  O.mark(c, { { d[1], d[2] } }, STEEL[math.max(1, i - 1)])
  O.mark(c, { { d[1] + 1, d[2] + 1 } }, STEEL[math.min(6, i + 1)])
end

-- closer look: tiny flame maker's stamp on the belly (pressed in: dark, lit lower lip)
O.mark(c, { { 38, 46 }, { 37, 47 }, { 38, 47 }, { 39, 47 }, { 37, 48 }, { 39, 48 } }, STEEL[1])
O.mark(c, { { 38, 49 }, { 37, 49 }, { 39, 49 } }, STEEL[4])

-- face
c:cheek(20, 41) c:cheek(38, 41)
O.dots(c, { { 28, 41 }, { 29, 41 }, { 30, 41 }, { 27, 42 }, { 31, 42 }, { 27, 43 }, { 31, 43 }, { 28, 44 }, { 29, 44 }, { 30, 44 } }, P.ink)
O.dots(c, { { 28, 42 }, { 29, 42 }, { 30, 42 }, { 28, 43 }, { 29, 43 }, { 30, 43 } }, "#a8384a")
O.dots(c, { { 29, 43 }, { 30, 43 } }, "#e86a6a")

O.done(c, "pl-cwy-4-yard", function(c)
  c:eyeLocked(22, 33)
  c:eyeLocked(33, 33)
  -- sparkler burst on the upper-right tip: 8 rays, gold body, cream ends, with gaps
  local tx, ty = 47, 10
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } }) do
    for r = 2, 6 do
      if r ~= 4 then
        local x, y = tx + d[1] * r, ty + d[2] * r
        if (d[1] == 0 or d[2] == 0) or r <= 5 then c:put(x, y, r >= 5 and P.cream or (r == 2 and STRAW[5] or P.gold.base)) end
      end
    end
  end
  c:put(tx, ty, P.cream)
  -- small fizz on the other tips
  for _, s in ipairs({ { 11, 11, -1, -1 }, { 5, 35, -1, -1 }, { 55, 35, 1, -1 } }) do
    c:put(s[1] + s[3] * 2, s[2] + s[4] * 2, P.gold.base)
    c:put(s[1] + s[3] * 2, s[2], STRAW[5])
    c:put(s[1], s[2] + s[4] * 2, STRAW[5])
  end
  c:sparkle(57, 22)
  c:put(52, 26, P.gold.base)
end)

-- Scorch Sliver (pl-cwy-3), yard sprite 64x64. Opus richness pass (c12/opus3), built on c12/opus2.
-- Rootwarden, common, Forge of the Cinder Wyrm. "A sharp red sliver that still smells faintly of smoke."
-- A slim, leaning shard of wyrm scale: three hard facets (wide lit front, narrow dark right flank, small
-- bevel low left) meeting at a bright ridge, so it reads as a cut sliver and not a leaf or pepper (haiku).
-- The lower third is scorched to soot-dark with a few warm char flecks; the face sits on the clean front.
-- quirk: a slow curl of smoke still rising off its point (cool grey puffs growing as they curl left).
-- closer look: a single hot crack glowing low on the char; a chip knocked out of its left edge; embers drifting up.
-- richness: heat-tempered orange band above the soot, conchoidal ripples on the flank, scale striations + glints.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-3-yard", 64)

local RED   = { "#43132e", "#7a1c34", "#b02a40", "#dc4436", "#ff7448", "#ffb879" }
local SMOKE = { "#4f4a63", "#6f6a85", "#958fa8", "#bcb6c9", "#ddd8e3" }

local function facet(m, nx, ny, nz, o)
  local n = {}
  local l = math.sqrt(nx * nx + ny * ny + nz * nz)
  local bb = { m:bbox() }
  m:each(function(x, y)
    local t = (y - 12) / 44 -- slight cooling toward the base
    n[K(x, y)] = { nx / l + t * .15, ny / l + t * .25, nz / l }
  end)
  return O.shadeN(c, m, n, RED, o)
end

c:groundShadow(31, 58, 13, 2)

-- the shard: tip top right, broken blunt base
local front = c:poly{ { 38, 12 }, { 37, 56 }, { 27, 56 }, { 23, 49 }, { 22, 37 }, { 26, 24 } }
local flank = c:poly{ { 38, 12 }, { 43, 26 }, { 44, 39 }, { 42, 51 }, { 39, 56 }, { 37, 56 } }
local bevel = c:poly{ { 22, 42 }, { 23, 49 }, { 27, 56 }, { 21, 56 }, { 19, 49 } }
front:cut(c:poly{ { 23, 27 }, { 27, 29 }, { 23, 32 } })
flank:cut(front)
bevel:cut(front)
local fI, fT = facet(front, -.05, -.12, 1, { amb = .12, wrap = .25, rim = true })
local kI, kT = facet(flank, .75, .1, .65, { amb = .2, wrap = .2, bounce = "#7a4a7e", bmax = 2 })
local bI, bT = facet(bevel, -.9, -.2, .4, { amb = .2, wrap = .3 })

-- grain: scale striations running down the front (one tone lower) and a few hot glints, skipping the face
O.tex(c, fI, fT, RED, function(x, y, i)
  if y >= 32 and y <= 45 and x <= 35 then return 0 end
  if (x * 3 + y) % 9 == 0 and H(x, y, 3) > .3 and i >= 3 then return -1 end
  if (x * 3 + y) % 9 == 1 and H(x, y, 5) > .75 and i >= 4 and y < 32 then return 1 end
end)
-- conchoidal ripples on the dark flank (it was split off a bigger scale): arcs one tone down, lit lip one up
O.tex(c, kI, kT, RED, function(x, y, i)
  local r = math.sqrt((x - 46) ^ 2 + (y - 18) ^ 2)
  local w = r % 5.5
  if w < 1 then return -1 end
  if w < 2 and i <= 4 then return 1 end
end)
-- bevel: soot creeping up it in streaks
O.tex(c, bI, bT, RED, function(x, y, i) if (x + y) % 3 == 0 then return -1 end end)
-- bright ridge where front meets flank, hot pop near the tip
for y = 15, 48 do if y % 9 ~= 4 then O.mark(c, { { 37, y } }, y < 28 and RED[6] or RED[5]) end end
O.mark(c, { { 35, 17 }, { 35, 18 }, { 34, 20 }, { 33, 23 } }, RED[6])
-- chip notch: its inner face catches light
O.mark(c, { { 24, 29 }, { 25, 29 }, { 26, 30 } }, RED[2])
O.mark(c, { { 24, 28 }, { 25, 28 } }, RED[6])

-- scorch: the base is charred soot, ragged upper edge, warm char flecks
local CHAR = { "#2e1d29", "#3c2530", "#4d2e36", "#633a3c" }
local function scorch(I, T, sh)
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    local edge = 49 + math.floor(math.sin(x * .9) * 1.5 + H(x, 0, 7) * 2)
    if c.own[p] == T and y >= edge then
      local t = math.min(4, math.max(1, i - 1 + sh))
      if y == edge and H(x, y, 9) > .5 then t = math.min(4, t + 1) end
      c.pix[p] = CHAR[t]
      if H(x, y, 11) > .95 and y > edge + 1 then c.pix[p] = "#7e3f3a" end
    end
  end
end
-- just above the soot the scale is heat-tempered: a warm orange band fading up
local function temper(I, T)
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    local edge = 49 + math.floor(math.sin(x * .9) * 1.5 + H(x, 0, 7) * 2)
    if c.own[p] == T and (y == edge - 1 or (y == edge - 2 and H(x, y, 4) > .45)) then
      c.pix[p] = (y == edge - 1) and "#ff8a3c" or "#f0602e"
    end
  end
end
temper(fI, fT) temper(kI, kT) temper(bI, bT)
scorch(fI, fT, 0) scorch(kI, kT, -1) scorch(bI, bT, 0)
-- closer look: one hot crack in the char
O.mark(c, { { 29, 55 }, { 30, 54 }, { 31, 54 }, { 32, 53 }, { 33, 52 } }, "#ff8a3c")
O.mark(c, { { 31, 53 } }, "#ffc070")
O.mark(c, { { 30, 55 }, { 33, 53 }, { 28, 55 }, { 34, 52 } }, "#c4402e")

-- face on the clean front
c:cheek(24, 41) c:cheek(34, 41)
O.dots(c, { { 28, 42 }, { 29, 43 }, { 30, 43 }, { 31, 42 } }, P.ink)
O.dot(c, 29, 44, RED[2]) O.dot(c, 30, 44, RED[2])

-- quirk: smoke curling off the point
for i, q in ipairs({ { 36, 9, 1.3 }, { 32.5, 6.5, 1.8 }, { 27.5, 5, 2.4 }, { 23, 8, 1.9 } }) do
  local m = c:ellipse(q[1], q[2], q[3], q[3])
  local I, T = O.shade(c, m, SMOKE, { sphere = { q[1] - 1, q[2] - 1.5, q[3] + 1.5 }, amb = .45, wrap = .5, cuts = { .3, .5, .68, .84 }, sep = SMOKE[2] })
  if i == 4 then O.tex(c, I, T, SMOKE, function() return -1 end) end
  if i == 3 then O.mark(c, { { 27, 6 }, { 28, 6 }, { 29, 5 } }, SMOKE[2]) end -- the curl's inner fold
end

O.done(c, "pl-cwy-3-yard", function(c)
  c:eyeLocked(24, 35)
  c:eyeLocked(31, 35)
  -- the curl thins to a wisp (un-outlined)
  for _, p in ipairs({ { 20, 10 }, { 19, 11 }, { 19, 12 }, { 20, 13 } }) do c:put(p[1], p[2], SMOKE[3]) end
  -- two embers drifting up with the smoke
  c:put(41, 8, "#ff8a3c") c:put(44, 4, "#ffc070")
end)

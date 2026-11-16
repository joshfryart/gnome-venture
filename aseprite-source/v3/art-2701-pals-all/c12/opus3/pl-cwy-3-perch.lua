-- Scorch Sliver (pl-cwy-3), perch sprite 36x36. Opus richness pass (c12/opus3), hand-built at this size.
-- Leaning red shard: lit front facet, narrow dark flank, bright ridge; soot-dark scorched base.
-- Face: 2x3 pills on the wide front with cheeks and a small open smile.
-- quirk: two small smoke puffs curling off the point. richness: heat band above the soot, flank ripple, ember.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-3-perch", 36)

local RED   = { "#43132e", "#7a1c34", "#b02a40", "#dc4436", "#ff7448", "#ffb879" }
local SMOKE = { "#4f4a63", "#6f6a85", "#958fa8", "#bcb6c9", "#ddd8e3" }
local CHAR  = { "#2e1d29", "#3c2530", "#4d2e36", "#633a3c" }

local function facet(m, nx, ny, nz, o)
  local n = {}
  local l = math.sqrt(nx * nx + ny * ny + nz * nz)
  m:each(function(x, y) local t = (y - 8) / 24 n[K(x, y)] = { nx / l + t * .15, ny / l + t * .25, nz / l } end)
  return O.shadeN(c, m, n, RED, o)
end

c:groundShadow(17, 32, 8, 1)
local front = c:poly{ { 22, 4 }, { 21, 31 }, { 14, 31 }, { 11, 26 }, { 11, 19 }, { 15, 11 } }
local flank = c:poly{ { 22, 4 }, { 25, 14 }, { 25, 24 }, { 23, 31 }, { 21, 31 } }
flank:cut(front)
local fI, fT = facet(front, -.05, -.12, 1, { amb = .12, wrap = .25, rim = true })
local kI, kT = facet(flank, .75, .1, .65, { amb = .2, wrap = .2, bounce = "#7a4a7e", bmax = 2 })
for y = 7, 26 do if y % 6 ~= 3 then O.mark(c, { { 21, y } }, y < 15 and RED[6] or RED[5]) end end
for _, L in ipairs({ { fI, fT, 0 }, { kI, kT, -1 } }) do
  for k, i in pairs(L[1]) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    local edge = 27 + math.floor(math.sin(x * 1.1) + .5)
    if c.own[p] == L[2] and y >= edge then c.pix[p] = CHAR[math.min(4, math.max(1, i - 1 + L[3]))]
    elseif c.own[p] == L[2] and y == edge - 1 then c.pix[p] = "#ff8a3c" end -- heat-tempered band
  end
end
O.mark(c, { { 16, 30 }, { 17, 29 } }, "#ff8a3c")
-- conchoidal ripple on the flank, one lit glint on the front
O.tex(c, kI, kT, RED, function(x, y, i) if math.sqrt((x - 27) ^ 2 + (y - 9) ^ 2) % 5 < 1 then return -1 end end)
O.mark(c, { { 18, 10 }, { 17, 12 } }, RED[6])

O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 23 } }, P.ink)
O.dot(c, 12, 22, P.petal.base) O.dot(c, 21, 22, P.petal.base)

for i, q in ipairs({ { 17.5, 4.5, 1.3 }, { 13.5, 3.5, 1.7 }, { 10, 5.5, 1.2 } }) do
  local I, T = O.shade(c, c:ellipse(q[1], q[2], q[3], q[3]), SMOKE, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1.5 }, amb = .45, wrap = .5, cuts = { .3, .5, .68, .84 }, sep = SMOKE[2] })
  if i == 3 then O.tex(c, I, T, SMOKE, function() return -1 end) end
end

O.done(c, "pl-cwy-3-perch", function(c)
  c:eyeSmall(13, 18)
  c:eyeSmall(19, 18)
  c:put(24, 3, "#ffc070") -- an ember drifting up
end)

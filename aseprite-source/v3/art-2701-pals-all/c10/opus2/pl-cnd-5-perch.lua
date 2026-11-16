-- Nest Wobble (pl-cnd-5), perch sprite 36x36. Opus second pass (c10/opus2), hand-built at this size.
-- A woven twig bowl tipped to the right on a puffy cloud, its right side hanging past the cloud edge, a pale
-- speckled egg inside, two stray twigs, a pink bloom tucked in. Pill eyes on a smooth patch of the woven front.
-- quirk: the wobble, with a sway arc either side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-5-perch", 36)

local TWIG = { "#3a2220", "#5e3828", "#865234", "#ae7444", "#d09a5c", "#ecc488" }
local SKY  = { "#6a84b8", "#8eaad4", "#b9d2ec", "#dcecf8", "#f2f8fc" }
local EGG  = { "#7a92a8", "#a8c0d0", "#cde0e8", "#eaf4f2", "#f8fcf8" }
local PET  = { "#c94f84", "#f5809f", "#ffc4d8" }

local cloud = O.unionCircles{ { 6, 30, 4, 3 }, { 12, 27, 6, 5 }, { 21, 28, 5, 4 }, { 15, 31, 12, 2.5 } }
cloud:cut(c:rect(0, 34, 35, 35))
O.shade(c, cloud, SKY, { sphere = { 10, 22, 16 }, amb = .4, wrap = .55, cuts = { .25, .45, .7, .88 }, rim = true, bounce = "#9a8ad0", bmax = 2 })

local CX, CY, A = 19, 14, math.rad(9)
local ca, sa = math.cos(A), math.sin(A)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
local function M(f)
  local m = HP.mask()
  for y = 0, 35 do for x = 0, 35 do local u, v = loc(x, y) if f(u, v) then m:set(x, y) end end end
  return m
end
local RV = -5
local rimBack = M(function(u, v) return (u / 11.5) ^ 2 + ((v - RV) / 3) ^ 2 <= 1 and v < RV end)
O.shade(c, rimBack, TWIG, { R = 1, amb = .3, wrap = .45 })
local hollow = M(function(u, v) return (u / 9) ^ 2 + ((v - RV) / 1.6) ^ 2 <= 1 end)
O.flat(c, hollow, TWIG[1], "hollow")
local egg = M(function(u, v) return ((u - 2) / 3.5) ^ 2 + ((v - RV + 2) / 4) ^ 2 <= 1 and v < RV + 1 end)
local eI, eT = O.shade(c, egg, EGG, { sphere = { 19, 9, 6 }, amb = .35, wrap = .5, cuts = { .25, .45, .7, .88 }, sep = TWIG[1] })
O.mark(c, { { 21, 9 } }, EGG[2])
local bowl = M(function(u, v) return v >= RV and (u / 12.5) ^ 2 + ((v - RV) / 13.5) ^ 2 <= 1 and v <= 9 end)
bowl:add(M(function(u, v) return (u / 11.5) ^ 2 + ((v - RV) / 3) ^ 2 <= 1 and v >= RV end))
bowl:cut(hollow)
local bI, bT = O.shade(c, bowl, TWIG, { sphere = { 15, 12, 15 }, amb = .3, wrap = .45, rim = true, bounce = "#6a6aa0", bmax = 2, sep = TWIG[1] })
for k, i in pairs(bI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == bT then
    local u, v = loc(x, y)
    local s = u * ((math.floor(u / 4) % 2 == 0) and .6 or -.6) + v
    if math.floor(s) % 3 == 0 and not (math.abs(u) < 7 and v > -2 and v < 5) then c.pix[p] = TWIG[math.max(1, i - 1)]:lower() end
  end
end
M(function(u, v) return (u / 7.5) ^ 2 + ((v - 3) / 3.5) ^ 2 <= 1 end):each(function(x, y)
  if bowl:has(x, y) then c.pix[y * c.w + x] = TWIG[math.max(4, math.min(5, (bI[K(x, y)] or 4) + 1))]:lower() end
end)
for _, tw in ipairs({ { { 9, 10 }, { 6, 7 } }, { { 27, 11 }, { 30, 6 } } }) do
  local m = c:line(tw, 1) m:cut(bowl) m:cut(rimBack)
  O.flat(c, m, TWIG[4], "twig")
end
local function at(u, v) return math.floor(CX + u * ca - v * sa + .5), math.floor(CY + u * sa + v * ca + .5) end
local ex1, ey1 = at(-4, 1) c:eyeSmall(ex1 - 1, ey1 - 1)
local ex2, ey2 = at(4, 1) c:eyeSmall(ex2 - 1, ey2 - 1)
local mx, my = at(0, 5)
O.dots(c, { { mx - 1, my }, { mx, my + 1 }, { mx + 1, my } }, P.ink)
local qx, qy = at(-8, 4) O.dot(c, qx, qy, "#f5809f")
local wx, wy = at(7, 4) O.dot(c, wx, wy, "#f5809f")
local bloom = O.unionCircles{ { 9, 16, 1, 1 }, { 11, 16, 1, 1 }, { 10, 15, 1, 1 }, { 10, 17, 1, 1 } }
O.shade(c, bloom, PET, { R = 1, amb = .4, wrap = .5, cuts = { .4, .8 }, sep = TWIG[1], nopop = true })
O.dot(c, 10, 16, "#f5b82e")

O.done(c, "pl-cnd-5-perch", function(c)
  for _, p in ipairs({ { 4, 12 }, { 3, 13 }, { 3, 14 }, { 3, 15 }, { 4, 16 }, { 33, 17 }, { 34, 18 }, { 34, 19 }, { 34, 20 }, { 33, 21 } }) do c:put(p[1], p[2], P.ink) end
end)

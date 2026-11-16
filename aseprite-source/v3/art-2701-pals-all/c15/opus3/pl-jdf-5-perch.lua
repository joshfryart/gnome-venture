-- Lantern Eye Pair (pl-jdf-5), perch sprite 36x36. Opus richness pass (c15/opus3), hand-built at this size.
-- Round orange paper lantern lit from inside (bright core, hoop lines), thin jade caps, ember tassel, hanging
-- from a bamboo crook; 2x3 pill eyes in the bright core, glow rays and a warm light pool under it.
-- richness: bamboo nodes and one leaf on the crook (rim lit, cool bounce), gold studs on the caps, a gold knot bead
-- on the tassel.
-- quirk: a tiny jade dragonfly zips past, the lantern flares on that side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-5-perch", 36)

local GLOW = { "#7a2a1e", "#b8461e", "#e8701e", "#ff9a2e", "#ffc95a", "#fff0a8" }
local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }
local BAMB = { "#2a4a2e", "#3f6a36", "#5f8f3e", "#8ab454", "#b8d878", "#e4f2b0" }
local CORD = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(6, 32, 3, 0)
local pm, pn, pT = O.tube({ { 6, 31 }, { 5, 18 }, { 5, 5 }, { 14, 5 } }, function() return 1 end)
O.shadeN(c, pm, pn, BAMB, { amb = .3, wrap = .4, rim = true, bounce = "#4a6a8a", bmax = 3 })
pm:each(function(x, y) if ((pT[K(x, y)] or 0) * 4) % 1 < .05 then c.pix[y * c.w + x] = BAMB[2] end end)
local lm, ln = O.tube({ { 6, 14 }, { 8, 12 }, { 10, 12 }, { 12, 14 } }, function(t) return .3 + 1 * math.sin(math.pi * t) end)
O.shadeN(c, lm, ln, BAMB, { amb = .35, wrap = .45, rim = true, sep = BAMB[1] })
O.flat(c, c:rect(14, 5, 18, 5), CORD[2], "cord") O.flat(c, c:rect(18, 6, 18, 8), CORD[2], "cord")
O.flat(c, c:rect(18, 26, 18, 27), CORD[2], "cord")
local tI, tT = O.shade(c, c:poly{ { 17, 28 }, { 20, 28 }, { 21, 31 }, { 16, 31 } }, CORD, { R = 1, amb = .3, cuts = { .3, .55, .8 } })

local CX, CY, RX, RY = 19, 17, 9, 7
local tok = { r = { name = "paper" } }
c:ellipse(CX, CY, RX, RY):each(function(x, y)
  local dx, dy = (x + .5 - CX) / RX, (y + .5 - CY) / RY
  local r = math.sqrt(dx * dx * .8 + dy * dy)
  local v = 1.05 - r + (-dx * .1 - dy * .08)
  if dx > .3 and dy < -.1 then v = v + .1 end
  local i = v > .6 and 6 or v > .42 and 5 or v > .24 and 4 or v > .08 and 3 or 2
  if math.abs(dy - .6) < .09 or math.abs(dy + .6) < .09 then i = math.max(2, i - 1) end
  c:put(x, y, GLOW[i], tok)
end)
O.shade(c, c:rect(14, 9, 24, 10), JADE, { R = 1, amb = .3, cuts = { .2, .4, .6, .8, .95 }, rim = true, sep = JADE[1] })
O.shade(c, c:rect(15, 24, 23, 25), JADE, { R = 1, amb = .3, cuts = { .2, .4, .6, .8, .95 }, sep = JADE[1] })

O.dots(c, { { 14, 9 }, { 24, 9 } }, "#f5b82e")
O.dot(c, 18, 27, "#f5b82e")
c:eyeSmall(15, 15)
c:eyeSmall(21, 15)
O.dot(c, 13, 19, P.petal.base) O.dot(c, 25, 19, P.petal.base)
O.mark(c, { { 18, 19 }, { 19, 20 }, { 20, 19 } }, P.ink)

-- the dragonfly
O.flat(c, c:rect(27, 5, 31, 5), JADE[3], "fly") O.flat(c, c:rect(30, 4, 31, 6), JADE[4], "flyh")
O.flat(c, c:rect(27, 3, 28, 4), "#cdf0e6", "w") O.flat(c, c:rect(27, 6, 28, 7), "#a6dcd8", "w")

O.done(c, "pl-jdf-5-perch", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  for _, p in ipairs({ { 8, 17 }, { 9, 17 }, { 30, 17 }, { 31, 17 }, { 28, 10 }, { 29, 9 }, { 10, 11 }, { 28, 24 }, { 10, 24 } }) do put(p[1], p[2], "#ffe38a") end
  for y = 30, 33 do for x = 11, 27 do
    local dx, dy = (x + .5 - 19) / 8, (y + .5 - 31.5) / 1.6
    local d = dx * dx + dy * dy
    if d <= 1 then put(x, y, d < .35 and "#ffd25a" or "#e8a03a") end
  end end
  for _, p in ipairs({ { 22, 5 }, { 23, 5 } }) do put(p[1], p[2], P.ink) end
end)

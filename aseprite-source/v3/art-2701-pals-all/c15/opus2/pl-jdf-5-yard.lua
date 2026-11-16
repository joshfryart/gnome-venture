-- Lantern Eye Pair (pl-jdf-5), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Rootwarden, uncommon, Lair of the Jade Dragon-fly. "A pair of orange eyes that glow whenever the dragonfly flies."
-- A round paper lantern lit from inside: orange paper with bamboo ribs, the glow brightest in the core and
-- falling off to the rims, jade caps top and bottom, a bent jade handle and a short ember tassel. The face sits
-- in the bright core.
-- Haiku weakness fixed: a flat purple box with no halo (glow only from sparkles); now the light comes from inside,
-- with short glow rays around it and a warm light pool on the ground instead of a grey shadow.
-- quirk: a tiny jade dragonfly zips past the top, and the lantern flares on that side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-5-yard", 64)

local GLOW = { "#7a2a1e", "#b8461e", "#e8701e", "#ff9a2e", "#ffc95a", "#fff0a8" }
local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }
local CORD = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

local CX, CY, RX, RY = 34, 30, 14, 11
local BAMB = { "#2a4a2e", "#3f6a36", "#5f8f3e", "#8ab454", "#b8d878", "#e4f2b0" }
c:groundShadow(13, 58, 5, 1)
-- bamboo crook it hangs from: a pole up the left side bending over to a hook
local pm, pn, pT = O.tube({ { 13, 57 }, { 12, 30 }, { 12, 7 }, { 27, 7 } }, function() return 1.6 end)
local pI, pTok = O.shadeN(c, pm, pn, BAMB, { amb = .3, wrap = .4, rim = true, bounce = "#4a6a8a", bmax = 2 })
pm:each(function(x, y) local t = pT[K(x, y)] or 0 if (t * 6) % 1 < .04 then c.pix[y * c.w + x] = BAMB[2] end end) -- nodes
O.shade(c, c:rect(27, 7, 28, 10), BAMB, { R = 1, amb = .35, cuts = { .2, .4, .6, .8, .95 }, sep = BAMB[1] })
O.flat(c, c:rect(32, 11, 32, 15), CORD[2], "cord") O.flat(c, c:rect(29, 10, 32, 10), CORD[2], "cord")
-- tassel
O.flat(c, c:rect(33, 45, 34, 47), CORD[2], "cord")
local tas = c:poly{ { 31, 48 }, { 36, 48 }, { 38, 53 }, { 29, 53 } }
local tI, tT = O.shade(c, tas, CORD, { R = 2, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
O.tex(c, tI, tT, CORD, function(x, y, i) if y > 49 and x % 2 == 0 then return -1 end end)

-- paper body: lit from within, horizontal wire hoops
local body = c:ellipse(CX, CY, RX, RY)
local tok = { r = { name = "paper" } }
body:each(function(x, y)
  local dx, dy = (x + .5 - CX) / RX, (y + .5 - CY) / RY
  local r = math.sqrt(dx * dx * .8 + dy * dy)
  local v = 1.05 - r + (-dx * .1 - dy * .08)
  if dx > .3 and dy < -.1 then v = v + .1 end -- flares on the side the dragonfly passes
  local i = v > .62 and 6 or v > .44 and 5 or v > .26 and 4 or v > .1 and 3 or 2
  -- hoops: rows at fixed latitudes, one tone down
  for _, h in ipairs({ -.62, -.3, .3, .62 }) do
    if math.abs(dy - h) < .045 + .5 / RY then i = math.max(2, i - 1) break end
  end
  c:put(x, y, GLOW[i], tok)
end)
-- caps (dark lacquer jade, thin)
O.shade(c, c:rrect(26, 16, 42, 18, 1), JADE, { R = 2, amb = .3, wrap = .4, rim = true, sep = JADE[1] })
O.shade(c, c:rrect(27, 42, 41, 44, 1), JADE, { R = 2, amb = .3, wrap = .4, sep = JADE[1] })
O.mark(c, { { 28, 17 }, { 29, 17 }, { 32, 17 }, { 33, 17 }, { 36, 17 }, { 37, 17 } }, JADE[6])
O.dots(c, { { 34, 19 }, { 34, 41 } }, "#f5b82e")

-- face in the bright core
c:eyeLocked(27, 26)
c:eyeLocked(36, 26)
c:cheek(25, 32) c:cheek(41, 32)
O.mark(c, { { 32, 33 }, { 33, 34 }, { 34, 34 }, { 35, 33 } }, P.ink)
O.mark(c, { { 33, 35 }, { 34, 35 } }, "#c94f84")

-- tiny jade dragonfly zipping past the upper right: two wing pairs, a long tail
O.flat(c, c:rect(44, 9, 52, 9), JADE[3], "fly")
O.flat(c, c:rect(51, 8, 53, 10), JADE[4], "flyhead") O.dot(c, 52, 8, JADE[6])
for _, w in ipairs({ { 47, 6, 48, 8 }, { 49, 6, 50, 8 }, { 47, 10, 48, 12 }, { 49, 10, 50, 12 } }) do
  O.flat(c, c:rect(w[1], w[2], w[3], w[4]), "#cdf0e6", "w")
end
O.dots(c, { { 47, 6 }, { 49, 6 } }, "#eefcf2") O.dots(c, { { 48, 12 }, { 50, 12 } }, "#7ab8c8")

O.done(c, "pl-jdf-5-yard", function(c)
  -- glow rays round the lantern (stronger on the dragonfly side)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  for _, r in ipairs({
    { 17, 30, -1, 0, 2 }, { 20, 21, -1, -1, 3 }, { 34, 13, 0, -1, 0 }, { 20, 40, -1, 1, 2 }, { 51, 30, 1, 0, 3 },
    { 49, 20, 1, -1, 3 }, { 48, 40, 1, 1, 2 },
  }) do
    for s = 0, r[5] - 1 do put(r[1] + r[3] * s, r[2] + r[4] * s, s == 0 and "#ffe38a" or "#f5b82e") end
  end
  -- warm light pool on the ground
  for y = 54, 59 do for x = 18, 50 do
    local dx, dy = (x + .5 - 34) / 13, (y + .5 - 57) / 2.6
    local d = dx * dx + dy * dy
    if d <= 1 then put(x, y, d < .35 and "#ffd25a" or "#e8a03a") end
  end end
  -- speed dashes behind the dragonfly
  for _, p in ipairs({ { 39, 9 }, { 40, 9 }, { 41, 9 }, { 36, 9 } }) do put(p[1], p[2], P.ink) end
end)

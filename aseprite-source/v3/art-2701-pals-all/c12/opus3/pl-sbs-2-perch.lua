-- Web Snag (pl-sbs-2), perch sprite 36x36. Opus richness pass (c12/opus3), hand-built at this size.
-- Round silk knot hanging under a twig on three pale radial threads with two rungs; one thicker loose thread
-- runs out like an arm and hooks. Face: 2x3 pills, cheeks, smile.
-- quirk: a little red gnome hat hanging on the hook, held out to hand back. richness: wound-thread lines on the
-- knot, a gold hat band, bark ridges, two-tone glinting threads.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-2-perch", 36)

local SILK = { "#3c3f70", "#566a98", "#86a0c6", "#b2cae4", "#d6e8f4", "#eef8fb" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }
local HAT  = { "#5a1838", "#8a2040", "#b82a44", "#dc3c46", "#f26a5e", "#ff9c86" }

local tw, tn = O.tube({ { 3, 6 }, { 12, 3 }, { 22, 3 }, { 32, 6 } }, function(t) return 1.5 - .5 * t end)
local wI, wT = O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
O.tex(c, wI, wT, BARK, function(x, y, i) if (x * 2 + y) % 5 == 0 and i >= 3 then return -1 end end)
local hk, hn = O.tube({ { 19, 21 }, { 25, 26 }, { 29, 21 }, { 26, 19 } }, function() return .8 end)
O.shadeN(c, hk, hn, SILK, { amb = .35, wrap = .45 })
local cone = c:poly{ { 25, 22 }, { 27, 23 }, { 31, 31 }, { 21, 31 } }
cone:add(O.tube({ { 25, 24 }, { 25, 20 }, { 28, 18 }, { 30, 21 } }, function(t) return 1.5 * (1 - t) + .5 end)) -- floppy tip over the hook
cone:add(c:ellipse(26, 31, 5.5, 1.2))
O.shade(c, cone, HAT, { R = 3, amb = .2, wrap = .4, rim = true })
O.mark(c, { { 25, 25 }, { 25, 26 } }, HAT[2])
O.mark(c, { { 22, 30 }, { 23, 30 }, { 24, 30 }, { 25, 30 }, { 26, 30 }, { 27, 30 }, { 28, 30 }, { 29, 30 } }, "#f5b82e") -- gold band
local knot = c:ellipse(14, 18, 7, 6.5)
local kI, kT = O.shade(c, knot, SILK, { sphere = { 11, 15, 10 }, amb = .3, wrap = .45, rim = true, bounce = "#6a7ab8", bmax = 2 })
O.tex(c, kI, kT, SILK, function(x, y, i)
  if y >= 16 and y <= 23 and x >= 9 and x <= 20 then return 0 end
  if math.floor((x - 14) * .7 - (y - 18) * 1.1 + 40) % 3 == 0 then return -1 end
end)
O.dot(c, 8, 21, P.petal.base) O.dot(c, 19, 21, P.petal.base)
O.dots(c, { { 13, 22 }, { 14, 23 }, { 15, 22 } }, P.ink)

O.done(c, "pl-sbs-2-perch", function(c)
  c:eyeSmall(10, 17)
  c:eyeSmall(16, 17)
  local T = "#e4eef8"
  for _, L in ipairs({ { { 9, 12 }, { 6, 7 } }, { { 14, 11 }, { 15, 6 } }, { { 19, 13 }, { 25, 7 } } }) do
    local a, b = L[1], L[2]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
    for s = 0, n do
      local x, y = math.floor(a[1] + (b[1] - a[1]) * s / n + .5), math.floor(a[2] + (b[2] - a[2]) * s / n + .5)
      if not c:get(x, y) then c:put(x, y, (x + y) % 4 == 0 and "#a8c4e2" or T) end
    end
  end
  for x = 8, 21 do if not c:get(x, 9) and x ~= 13 then c:put(x, 9, T) end end
end)

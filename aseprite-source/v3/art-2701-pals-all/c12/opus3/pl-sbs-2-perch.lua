-- Web Snag (pl-sbs-2), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Round silk knot hanging under a twig on three pale radial threads with two rungs; one thicker loose thread
-- runs out like an arm and hooks. Face: 2x3 pills, cheeks, smile.
-- quirk: a little red gnome hat hanging on the hook, held out to hand back.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-2-perch", 36)

local SILK = { "#3a4a6e", "#5a6e96", "#8aa0c2", "#b4c8e0", "#d8e6f2", "#eef6fb" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }
local HAT  = { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }

local tw, tn = O.tube({ { 3, 6 }, { 12, 3 }, { 22, 3 }, { 32, 6 } }, function(t) return 1.5 - .5 * t end)
O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
local hk, hn = O.tube({ { 19, 21 }, { 25, 26 }, { 29, 21 }, { 26, 19 } }, function() return .8 end)
O.shadeN(c, hk, hn, SILK, { amb = .35, wrap = .45 })
local cone = c:poly{ { 26, 20 }, { 31, 31 }, { 21, 31 } }
cone:add(c:ellipse(26, 31, 5.5, 1.2))
O.shade(c, cone, HAT, { R = 3, amb = .2, wrap = .4, rim = true })
O.mark(c, { { 25, 25 }, { 25, 26 } }, HAT[2])
local knot = c:ellipse(14, 18, 7, 6.5)
local kI, kT = O.shade(c, knot, SILK, { sphere = { 11, 15, 10 }, amb = .3, wrap = .45, rim = true, bounce = "#6a7ab8", bmax = 2 })
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
      if not c:get(x, y) then c:put(x, y, T) end
    end
  end
  for x = 8, 21 do if not c:get(x, 9) and x ~= 13 then c:put(x, 9, T) end end
end)

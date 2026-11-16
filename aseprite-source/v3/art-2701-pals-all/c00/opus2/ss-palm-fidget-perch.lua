-- Palm Fidget (ss-palm-fidget), perch sprite 36x36. Opus second pass (c00/opus2), hand-built at this size.
-- Hairy coconut with three bold palm fronds (4-5 px blades slit into leaflets, so they no longer go thin at this
-- size), 2x3 pill eyes, coir flecks.
-- quirk: one foot lifted mid-tap with two tap ticks; a breeze swoosh behind.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-palm-fidget-perch", 36)

local NUT  = { "#2e1c1e", "#4e2e26", "#74472f", "#9a6640", "#bf8a58", "#dcae7a" }
local FROND = { "#1f4438", "#2a6a42", "#3f9150", "#62b257", "#9ccf6a", "#d0eb96" }
local FOOT = { "#4e2e26", "#74472f", "#9a6640", "#bf8a58" }

local function frond(p, w, slits)
  local wf = function(t) return w * math.sin(math.pi * (.15 + .85 * t)) ^ .6 * (1 - .3 * t) + .5 end
  local m, n = O.tube(p, wf)
  for _, t0 in ipairs(slits) do
    local x0, y0 = O.bez(p, t0)
    local x1, y1 = O.bez(p, math.min(1, t0 + .1))
    local xa, ya = O.bez(p, math.min(1, t0 + .11))
    local tx, ty = xa - x1, ya - y1
    local l = math.sqrt(tx * tx + ty * ty) if l == 0 then l = 1 end
    tx, ty = tx / l, ty / l
    for _, sd in ipairs({ -1, 1 }) do
      local px, py = -ty * sd, tx * sd
      local e = wf(t0 + .1) + 1
      m:cut(c:line({ { math.floor(x0 + px * 1.2 + .5), math.floor(y0 + py * 1.2 + .5) }, { math.floor(x1 + px * e + .5), math.floor(y1 + py * e + .5) } }, 1))
    end
  end
  O.shadeN(c, m, n, FROND, { amb = .2, wrap = .4, rim = true })
end

c:groundShadow(17, 32, 9, 1)
frond({ { 16, 15 }, { 13, 11 }, { 7, 10 }, { 3, 14 } }, 3, { .35, .65 })
frond({ { 18, 15 }, { 23, 10 }, { 29, 9 }, { 32, 15 } }, 3, { .35, .65 })
frond({ { 17, 15 }, { 15, 7 }, { 21, 2 }, { 28, 4 } }, 3.4, { .3, .55, .8 })
O.shade(c, c:ellipse(13, 30, 2.5, 1.5), FOOT, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
local nut = c:ellipse(17, 22, 8.5, 8)
local nI, nT = O.shade(c, nut, NUT, { sphere = { 14, 18, 11 }, amb = .22, wrap = .4, rim = true, bounce = "#7a5a72", bmax = 2 })
O.mark(c, { { 11, 17 }, { 23, 18 }, { 12, 26 }, { 22, 27 }, { 20, 16 }, { 9, 22 } }, NUT[2])
O.shade(c, c:ellipse(23, 29, 2.5, 1.5), FOOT, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = NUT[1] })

c:eyeSmall(13, 20)
c:eyeSmall(19, 20)
O.dot(c, 11, 24, P.petal.base) O.dot(c, 22, 24, P.petal.base)
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 25 } }, P.ink)

O.shift(c, 0, 0)
O.done(c, "ss-palm-fidget-perch", function(c)
  for _, p in ipairs({ { 21, 33 }, { 26, 33 } }) do c:put(p[1], p[2], P.ink) end
  for _, p in ipairs({ { 1, 22 }, { 2, 22 }, { 3, 22 }, { 4, 21 } }) do c:put(p[1], p[2], "#8bc4ea") end
end)

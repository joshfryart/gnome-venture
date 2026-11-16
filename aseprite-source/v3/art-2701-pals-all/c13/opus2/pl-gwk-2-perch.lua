-- Pawprint Cuff (pl-gwk-2), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- A short wide ring of packed snow seen a little from above: dark open middle, lumpy fluffed rims, cool shading.
-- 2x3 pill eyes on the left of the front.
-- quirk: one perfect pawprint pressed into the right of the front (heel pad and four toes as dents).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-2-perch", 36)

local SNOW = { "#3c4670", "#5b6e9c", "#8aa0c8", "#b8cbe4", "#dce7f4", "#f3f7fc" }
local HOLE = { "#262642", "#363a5e", "#4a5480" }

c:groundShadow(18, 32, 15, 1.5)
local body = c:rect(4, 13, 31, 26)
body:add(c:ellipse(17.5, 26, 13.5, 4))
body:add(c:ellipse(17.5, 13, 13.5, 4.5))
for _, b in ipairs({ { 5, 16 }, { 4, 21 }, { 30, 17 }, { 31, 22 }, { 8, 29 }, { 14, 31 }, { 21, 31 }, { 27, 29 } }) do
  body:add(c:ellipse(b[1], b[2], 1.5, 1.5))
end
local bn = {}
body:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 17.5) / 14.5))
  bn[K(x, y)] = { sx, (y < 13) and -.4 or 0, math.sqrt(1 - sx * sx) }
end)
local bI, bT = O.shadeN(c, body, bn, SNOW, { amb = .3, wrap = .5, rim = true, bounce = "#9a8ac8", bmax = 3 })
c:ellipse(17.5, 12.5, 9.5, 3):each(function(x, y)
  local col = (y <= 11) and SNOW[2] or ((y <= 12) and HOLE[3] or HOLE[1])
  c:put(x, y, col, { r = { name = "hole" } })
end)
for _, b in ipairs({ { 7, 10 }, { 13, 8 }, { 20, 8 }, { 27, 10 } }) do
  O.shade(c, c:ellipse(b[1], b[2], 1.5, 1.2), SNOW, { sphere = { b[1] - 1, b[2] - 1, 2.5 }, amb = .5, wrap = .5, cuts = { .1, .25, .45, .65, .8 } })
end
local function press(m)
  m:each(function(x, y)
    local tl = not m:has(x - 1, y) or not m:has(x, y - 1)
    c.pix[y * 36 + x] = tl and SNOW[1] or SNOW[2]
  end)
  m:each(function(x, y)
    for _, d in ipairs({ { 1, 0 }, { 0, 1 } }) do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) and c.own[ny * 36 + nx] == bT then c.pix[ny * 36 + nx] = SNOW[6] end
    end
  end)
end
press(c:ellipse(24, 23, 2.5, 2))
press(c:rect(20, 19, 20, 20)) press(c:rect(22, 17, 23, 18)) press(c:rect(25, 17, 26, 18)) press(c:rect(28, 19, 28, 20))

c:eyeSmall(9, 18)
c:eyeSmall(15, 18)
O.dot(c, 7, 22, P.petal.base) O.dot(c, 18, 22, P.petal.base)
O.dots(c, { { 11, 23 }, { 12, 24 }, { 13, 23 } }, P.ink)

O.done(c, "pl-gwk-2-perch", function(c) c:sparkle(33, 6) end)

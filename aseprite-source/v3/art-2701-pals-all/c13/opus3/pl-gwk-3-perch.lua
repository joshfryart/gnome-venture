-- Moonpale Mantle (pl-gwk-3), perch sprite 36x36. Opus richness pass (c13/opus3), hand-built at this size.
-- opus3: no longer a sheet ghost: the fur collar is wider than the cloth (shoulder cape), the cloth swings right,
-- the left front edge is turned back to an indigo lining strip with a gold trim line, no hem border at this size,
-- fur clumps instead of stripes.
-- Grey wolf-fur collar with a gold clasp over pale lilac cloth in soft folds, hem torn on a slant, indigo lining
-- at the ripped corner. 2x3 pill eyes on the upper cloth.
-- quirk: a full moon at the top right and a one-pixel moon-glow halo on the moon-facing side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-3-perch", 36)

local CLOTH = { "#3c2e58", "#5c4c80", "#8474a8", "#a99ec8", "#cec8e4", "#eceaf6" }
local LINE  = { "#1c1636", "#2c2656", "#443c80", "#5c56a0" }
local FUR   = { "#2a2632", "#45404e", "#676070", "#8d8794", "#b4aeb6", "#dcd6d2" }
local GOLD  = { "#6a3e1a", "#a8662a", "#e0a03a", "#f8d468", "#fff0b0" }
local MOON  = { "#8a86a8", "#c2c4dc", "#e6eaf4", "#fbfcfe" }
local GLOW  = "#c8f0ee"

c:groundShadow(16, 33, 11, 1)
local cloth = c:poly{ { 8, 10 }, { 25, 10 }, { 30, 24 }, { 28, 26 }, { 27, 28 }, { 24, 27 }, { 22, 30 }, { 18, 31 }, { 11, 32 }, { 6, 31 }, { 6, 22 } }
local cn = {}
cloth:each(function(x, y)
  local f = math.sin((x - 16) * .8) * math.min(1, (y - 9) / 8) * 1.1
  local sx = math.max(-.95, math.min(.95, (x - 16) / 14 + f))
  cn[K(x, y)] = { sx, -.1, math.sqrt(math.max(.02, 1 - sx * sx)) }
end)
O.shadeN(c, cloth, cn, CLOTH, { amb = .24, wrap = .5, rim = true, bounce = "#7a9ac8", bmax = 3 })
O.shade(c, c:poly{ { 23, 20 }, { 30, 24 }, { 28, 26 }, { 27, 28 }, { 24, 27 } }, LINE, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = LINE[1] })
-- turned-back front edge: indigo lining strip with a gold trim line
O.shade(c, c:poly{ { 8, 11 }, { 9, 11 }, { 8, 22 }, { 8, 31 }, { 6, 31 }, { 6, 22 } }, LINE, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = LINE[1] })
for y = 12, 30 do O.dot(c, (y < 22) and 10 or 9, y, (y % 3 == 0) and GOLD[4] or GOLD[3]) end
local collar = c:ellipse(16.5, 9, 13.5, 3.5)
for k = 0, 6 do collar:add(c:poly{ { 4 + k * 4, 11 }, { 7 + k * 4, 11 }, { 5 + k * 4, 14 + (k % 2) } }) end
collar:add(c:ellipse(9, 6, 2, 1.5)) collar:add(c:ellipse(17, 5, 2.5, 1.5)) collar:add(c:ellipse(24, 6, 2, 1.5))
local fI, fT = O.shade(c, collar, FUR, { sphere = { 12, 5, 12 }, amb = .3, wrap = .45, rim = true, sep = FUR[1] })
O.tex(c, fI, fT, FUR, function(x, y, i) if y >= 12 then return -1 end if O.H(x, (y + x % 2) // 2, 2) > .65 then return -1 end end)
O.flat(c, c:rect(15, 10, 17, 12), GOLD[3], "clasp") O.dot(c, 16, 11, MOON[3]) O.dot(c, 15, 10, GOLD[5])

c:eyeSmall(11, 16)
c:eyeSmall(18, 16)
O.dot(c, 9, 20, P.petal.base) O.dot(c, 21, 20, P.petal.base)
O.dots(c, { { 14, 21 }, { 15, 22 }, { 16, 22 }, { 17, 21 } }, P.ink)

O.shade(c, c:ellipse(30.5, 3.5, 2.5, 2.5), MOON, { sphere = { 29.5, 2.5, 3.5 }, amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
O.done(c, "pl-gwk-3-perch", function(c)
  local add = {}
  for y = 1, 34 do for x = 17, 34 do
    if not c:get(x, y) and y < 28 then
      for _, d in ipairs({ { -1, 0 }, { 0, 1 } }) do
        local q = c:get(x + d[1], y + d[2])
        if q == P.ink:lower() and c:get(x + d[1] * 2, y + d[2] * 2) and y > 8 then add[#add+1] = { x, y } break end
      end
    end
  end end
  for _, p in ipairs(add) do c:put(p[1], p[2], GLOW) end
  c:put(33, 14, GLOW)
end)

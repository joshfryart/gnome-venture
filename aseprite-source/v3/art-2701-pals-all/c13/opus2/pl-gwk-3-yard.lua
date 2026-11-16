-- Moonpale Mantle (pl-gwk-3), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
-- Seedkeeper, common, Lair of the Grey Wolf King. "A pale scrap of mantle that only glows under the full moon."
-- Haiku weakness fixed: a saturated purple banner (not pale) with a porthole moon on its belly read as a sign or
-- a ghost. Now a real scrap of a king's mantle: a shaggy grey wolf-fur collar with a gold clasp on top, pale
-- pearl-lilac cloth hanging in soft vertical folds, a torn ragged hem, and one corner flipped up to show the deep
-- indigo lining. Pale and cool, clearly cloth, and nothing like the snow cuff's ring shape.
-- quirk: under the full moon it glows: a full moon at the top right and a one-pixel moon-glow halo outside the
-- ink on the moon-facing side, with glow motes. closer-look: the king's gold crescent badge stitched on the lower left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-3-yard", 64)

local CLOTH = { "#3e3058", "#5e4e80", "#8676a8", "#ab9ec8", "#d0c6e2", "#eee8f6" }
local LINE  = { "#1c1636", "#2c2656", "#443c80", "#5c56a0" }
local FUR   = { "#2c2832", "#46414e", "#686270", "#8e8896", "#b6b0bc", "#d8d4dc" }
local GOLD  = { "#6a3e1a", "#a8662a", "#e0a03a", "#f8d468", "#fff0b0" }
local MOON  = { "#8a86a8", "#c2c4dc", "#e6eaf4", "#fbfcfe" }
local GLOW  = "#c8f0ee"

c:groundShadow(30, 59, 20, 2)
-- cloth: widening drape with a torn hem
-- torn on a slant: long on the left, ripped short on the right (a scrap, not a sheet)
local hem = { { 13, 18 }, { 47, 18 }, { 54, 43 }, { 51, 46 }, { 48, 44 }, { 45, 49 }, { 41, 47 }, { 37, 52 }, { 33, 50 },
              { 29, 54 }, { 25, 52 }, { 20, 57 }, { 15, 54 }, { 11, 56 }, { 7, 51 } }
local cloth = c:poly(hem)
local cn = {}
cloth:each(function(x, y)
  -- folds: ripples that widen downwards, on a gentle cylinder
  local f = math.sin((x - 30) * (.55 - y * .004)) * math.min(1, (y - 16) / 14) * 1.15
  local sx = math.max(-.95, math.min(.95, (x - 30) / 26 + f))
  cn[K(x, y)] = { sx, -.1, math.sqrt(math.max(.02, 1 - sx * sx)) }
end)
local clI, clT = O.shadeN(c, cloth, cn, CLOTH, { amb = .22, wrap = .5, rim = true, bounce = "#7a9ac8", bmax = 3 })
-- weave: faint cross threads on the lit cloth
O.tex(c, clI, clT, CLOTH, function(x, y, i) if (x + y * 2) % 9 == 0 and i >= 4 and not (x >= 20 and x <= 42 and y >= 25 and y <= 38) then return -1 end end)
-- the flipped corner: indigo lining folded up at the bottom right
local corner = c:poly{ { 42, 38 }, { 54, 43 }, { 51, 46 }, { 48, 44 }, { 45, 49 } }
local coI, coT = O.shade(c, corner, LINE, { R = 2, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = LINE[1] })
O.dots(c, { { 43, 39 }, { 45, 40 }, { 47, 41 }, { 49, 42 } }, CLOTH[5])
-- fur collar: shaggy grey wolf fur
local collar = c:ellipse(30, 16, 20, 6.5)
for k = 0, 9 do collar:add(c:poly{ { 11 + k * 4, 19 }, { 16 + k * 4, 19 }, { 13 + k * 4 + (k % 2), 26 + (k % 3) * 2 } }) end
for _, b in ipairs({ { 12, 12 }, { 20, 10 }, { 30, 9 }, { 40, 10 }, { 48, 12 } }) do collar:add(c:ellipse(b[1], b[2], 3, 2.5)) end
local fI, fT = O.shade(c, collar, FUR, { sphere = { 24, 9, 22 }, amb = .3, wrap = .45, rim = true, sep = FUR[1] })
O.tex(c, fI, fT, FUR, function(x, y, i)
  -- fur strands: short diagonal ticks
  if y >= 23 then return -1 end
  local s = (x + (y // 3)) % 3
  if s == 0 then return -1 end
  if s == 1 and y < 14 and i <= 5 then return 1 end
end)
-- gold clasp with a moonstone
O.shade(c, c:ellipse(30, 19, 3.5, 3.5), GOLD, { sphere = { 29, 18, 4.5 }, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })
O.flat(c, c:rect(29, 18, 31, 20), MOON[2], "stone") O.dot(c, 29, 18, MOON[4]) O.dot(c, 31, 20, MOON[1])
-- the king's crescent badge stitched in gold on the lower left of the cloth
for _, p in ipairs({ { 15, 44 }, { 14, 45 }, { 14, 46 }, { 14, 47 }, { 15, 48 }, { 16, 49 }, { 18, 49 }, { 17, 46 }, { 16, 47 } }) do O.dot(c, p[1], p[2], GOLD[3]) end
O.dots(c, { { 15, 45 }, { 15, 46 } }, GOLD[4])

-- face on the upper cloth
c:eyeLocked(22, 28)
c:eyeLocked(33, 28)
c:cheek(20, 35) c:cheek(38, 35)
O.dots(c, { { 27, 36 }, { 28, 37 }, { 29, 37 }, { 30, 37 }, { 31, 36 } }, P.ink)

-- full moon, top right
local mI, mT = O.shade(c, c:ellipse(55, 7, 4.5, 4.5), MOON, { sphere = { 53, 5, 6.5 }, amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
O.dots(c, { { 56, 8 }, { 57, 9 }, { 54, 9 } }, MOON[2])

O.done(c, "pl-gwk-3-yard", function(c)
  -- moon-glow halo: one pixel outside the ink on the upper-right of the mantle (facing the moon)
  local add = {}
  for y = 1, 62 do for x = 1, 62 do
    if not c:get(x, y) and x + (40 - y) > 40 and x > 30 and y < 50 then
      for _, d in ipairs({ { -1, 0 }, { 0, 1 }, { -1, 1 } }) do
        local q = c:get(x + d[1], y + d[2])
        if q == P.ink:lower() and c:get(x + d[1] * 2, y + d[2] * 2) then add[#add+1] = { x, y } break end
      end
    end
  end end
  for _, p in ipairs(add) do c:put(p[1], p[2], GLOW) end
  for _, p in ipairs({ { 58, 22 }, { 61, 30 }, { 57, 38 }, { 46, 3 } }) do c:put(p[1], p[2], GLOW) end
  c:sparkle(5, 30)
end)

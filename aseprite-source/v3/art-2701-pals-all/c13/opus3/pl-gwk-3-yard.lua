-- Moonpale Mantle (pl-gwk-3), yard sprite 64x64. Opus richness pass (c13/opus3), built on c13/opus2.
-- Seedkeeper, common, Lair of the Grey Wolf King. "A pale scrap of mantle that only glows under the full moon."
-- opus2 weakness fixed: it read a bit like a sheet ghost (round fur top over a symmetric drape with a wavy hem).
-- Now it reads as a garment: the shaggy wolf-fur collar is the widest part (a shoulder cape, with tufts and long
-- guard hairs), the cloth swings out to the right in diagonal folds, the left front edge is turned back to show a
-- deep indigo lining strip edged with a gold trim line, the intact hem carries an embroidered gold border, and the
-- torn corner on the right frays into loose threads. Hue-shifted ramps (pearl-lilac cloth with cool moonlit tops,
-- silver-wolf fur with warm tips), gold clasp with a moonstone and a little chain across the collar.
-- quirk: under the full moon it glows: a moon at the top right, a one-pixel moon-glow halo outside the ink on the
-- moon-facing side, moon-cyan sheen on the lit folds, glow motes. closer-look: the king's gold crescent badge
-- stitched on the cloth, and a single wolf hair caught on the hem.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-3-yard", 64)

local CLOTH = { "#3c2e58", "#5c4c80", "#8474a8", "#a99ec8", "#cec8e4", "#eceaf6" }
local LINE  = { "#1a1434", "#2a2454", "#40387c", "#585298" }
local FUR   = { "#2a2632", "#45404e", "#676070", "#8d8794", "#b4aeb6", "#dcd6d2" }
local GOLD  = { "#6a3a1e", "#a8642a", "#e09e3a", "#f6d066", "#fcecb0" }
local MOON  = { "#8a86a8", "#c2c4dc", "#e6eaf4", "#f8faf6" }
local GLOW  = "#c8f0ee"

c:groundShadow(31, 59, 20, 2)
-- cloth: narrower at the collar, swinging out to the right; hem intact on the left, torn on the right
local hem = { { 15, 18 }, { 45, 18 }, { 52, 34 }, { 57, 44 }, { 54, 45 }, { 55, 48 }, { 51, 47 }, { 49, 51 }, { 46, 48 },
              { 42, 53 }, { 38, 53 }, { 30, 55 }, { 20, 56 }, { 11, 55 }, { 10, 40 } }
local cloth = c:poly(hem)
local cn = {}
cloth:each(function(x, y)
  -- diagonal folds: ripples tilted with the swing, deepening downwards
  local f = math.sin((x - 30 - (y - 18) * .35) * .5) * math.min(1, (y - 16) / 12) * 1.1
  local sx = math.max(-.95, math.min(.95, (x - 32) / 26 + f))
  cn[K(x, y)] = { sx, -.1, math.sqrt(math.max(.02, 1 - sx * sx)) }
end)
local clI, clT = O.shadeN(c, cloth, cn, CLOTH, { amb = .22, wrap = .5, rim = true, bounce = "#7a9ac8", bmax = 3 })
O.tex(c, clI, clT, CLOTH, function(x, y, i)
  if x >= 18 and x <= 42 and y >= 25 and y <= 38 then return 0 end
  -- fine twill weave on the cloth
  if (x + y * 2) % 7 == 0 and i >= 4 then return -1 end
end)
-- moonlit sheen: the brightest fold tops on the moon side pick up moon-cyan
clI2 = clI
for k, i in pairs(clI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if i >= 5 and x > 36 and c.own[y * 64 + x] == clT and (x + y) % 3 ~= 0 then c.pix[y * 64 + x] = "#d8eef0" end
end
-- the turned-back front edge: indigo lining strip down the left, gold trim line on its inner edge
local lap = c:poly{ { 15, 19 }, { 18, 19 }, { 15, 40 }, { 14, 55 }, { 11, 55 }, { 10, 40 } }
O.shade(c, lap, LINE, { R = 1, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = LINE[1] })
for y = 20, 54 do
  local xl = math.floor(18 - (y - 19) * (3 / 21) + .5)
  if y > 40 then xl = 15 - math.floor((y - 40) / 15 + .5) end
  xl = xl + 1
  if cloth:has(xl, y) then O.dot(c, xl, y, (y % 3 == 0) and GOLD[4] or GOLD[3]) end
end
-- embroidered gold border along the intact hem (left half), a dot every other pixel
for x = 16, 37 do
  local y
  for yy = 57, 40, -1 do if cloth:has(x, yy) then y = yy break end end
  if y then
    O.dot(c, x, y - 2, (x % 2 == 0) and GOLD[3] or GOLD[2])
    if x % 4 == 0 then O.dot(c, x, y - 3, GOLD[4]) end
  end
end
-- the torn corner: indigo lining flipped up, loose threads dangling
local corner = c:poly{ { 47, 38 }, { 57, 44 }, { 54, 45 }, { 55, 48 }, { 51, 47 }, { 49, 51 } }
O.shade(c, corner, LINE, { R = 2, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = LINE[1] })
O.dots(c, { { 48, 39 }, { 50, 40 }, { 52, 41 }, { 54, 42 } }, CLOTH[5])
O.dots(c, { { 44, 49 }, { 44, 50 }, { 45, 51 }, { 40, 54 }, { 40, 55 } }, CLOTH[4])
-- fur collar: wider than the cloth (a shoulder cape), shaggy, with tufts and long guard hairs
local collar = c:ellipse(31, 15, 24, 6.5)
for k = 0, 11 do collar:add(c:poly{ { 9 + k * 4, 18 }, { 14 + k * 4, 18 }, { 11 + k * 4 + (k % 2), 24 + (k % 3) * 2 } }) end
for _, b in ipairs({ { 10, 13 }, { 18, 10 }, { 27, 9 }, { 36, 9 }, { 45, 10 }, { 52, 13 } }) do collar:add(c:ellipse(b[1], b[2], 3, 2.5)) end
collar:add(c:poly{ { 6, 14 }, { 9, 12 }, { 8, 19 } }) collar:add(c:poly{ { 56, 12 }, { 58, 15 }, { 54, 18 } })
local fI, fT = O.shade(c, collar, FUR, { sphere = { 27, 7, 27 }, amb = .36, wrap = .5, rim = true, sep = FUR[1] })
O.tex(c, fI, fT, FUR, function(x, y, i)
  if y >= 22 then return -1 end
  -- fur strands: diagonal clumps, warm pale tips on the lit side
  local h = O.H(x, (y + x % 2) // 3, 2)
  if h > .62 then return -1 end
  if h < .18 and y < 16 and i <= 5 then return 1 end
end)
-- a little gold chain across the collar to the clasp
for _, q in ipairs({ { 20, 18 }, { 22, 19 }, { 24, 19 }, { 26, 20 }, { 35, 20 }, { 37, 19 }, { 39, 19 }, { 41, 18 } }) do O.dot(c, q[1], q[2], GOLD[3]) end
O.dots(c, { { 21, 18 }, { 23, 19 }, { 25, 20 }, { 36, 20 }, { 38, 19 }, { 40, 18 } }, GOLD[2])
-- gold clasp with a moonstone
O.shade(c, c:ellipse(31, 20, 3.5, 3.5), GOLD, { sphere = { 30, 19, 4.5 }, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })
O.flat(c, c:rect(30, 19, 32, 21), MOON[2], "stone") O.dot(c, 30, 19, MOON[4]) O.dot(c, 32, 21, "#7ab8c8")
-- the king's crescent badge stitched in gold, lower left of the cloth
for _, p in ipairs({ { 21, 44 }, { 20, 45 }, { 20, 46 }, { 20, 47 }, { 21, 48 }, { 22, 49 }, { 24, 49 }, { 23, 46 }, { 22, 47 } }) do O.dot(c, p[1], p[2], GOLD[3]) end
O.dots(c, { { 21, 45 }, { 21, 46 } }, GOLD[4])
-- a single grey wolf hair caught on the hem
O.dots(c, { { 31, 51 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, FUR[3])

-- face on the upper cloth
c:eyeLocked(23, 28)
c:eyeLocked(34, 28)
c:cheek(21, 35) c:cheek(39, 35)
O.dots(c, { { 28, 36 }, { 29, 37 }, { 30, 37 }, { 31, 37 }, { 32, 36 } }, P.ink)

-- full moon, top right, with a few soft maria
local mI, mT = O.shade(c, c:ellipse(56, 6, 4.5, 4.5), MOON, { sphere = { 54, 4, 6.5 }, amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
O.dots(c, { { 57, 7 }, { 58, 8 }, { 55, 8 } }, MOON[2])

O.done(c, "pl-gwk-3-yard", function(c)
  -- moon-glow halo: one pixel outside the ink on the upper-right of the mantle (facing the moon)
  local add = {}
  for y = 1, 62 do for x = 1, 62 do
    if not c:get(x, y) and x + (40 - y) > 40 and x > 30 and y < 50 then
      for _, d in ipairs({ { -1, 0 }, { 0, 1 }, { -1, 1 } }) do
        local q = c:get(x + d[1], y + d[2])
        if q == P.ink:lower() and c:get(x + d[1] * 2, y + d[2] * 2) and not (x > 49 and y < 13) then add[#add+1] = { x, y } break end
      end
    end
  end end
  for _, p in ipairs(add) do c:put(p[1], p[2], GLOW) end
  for _, p in ipairs({ { 61, 22 }, { 62, 31 }, { 60, 38 }, { 47, 3 } }) do c:put(p[1], p[2], GLOW) end
  c:sparkle(4, 30)
end)

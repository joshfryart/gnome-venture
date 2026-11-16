-- Karst Yawn (pl-dlz-5), yard sprite 64x64. Opus second pass (c11/opus2), built on c11/haiku.
-- Rootwarden, uncommon, Dragonlizard Den. "A scrap of the dark den mouth that yawns whenever the lizard does."
-- haiku drew a grey bottle with a hole: flat grey, no stone read. Now a lumpy limestone boulder (layered strata,
-- ochre mineral streaks, moss and a fern on top, a root dangling down its side) on stubby stone feet; its whole
-- front is the den mouth, stretched in a huge yawn with stalactite and stalagmite teeth.
-- quirk: the yawn itself; closer look: a tiny sleepy bat hanging upside down from the roof of the mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-5-yard", 64)

local LIME = { "#3a2e44", "#5a4c62", "#7e7084", "#a496a2", "#c8bcbc", "#e8dece" }
local OCHR = { "#8a5a34", "#b8844a", "#d8aa66" }
local CAVE = { "#1e1426", "#2c1c34", "#3e2a44" }
local MOSS = { "#2a4428", "#3e6a30", "#5e963c", "#94c458" }
local ROOT = { "#4a2e26", "#7a5038", "#a87a52" }
local BAT  = { "#6a4a6a", "#9a6e8a", "#c8a0b0" }

c:groundShadow(32, 58, 21, 2.5)

-- stubby stone feet
for _, fx in ipairs({ 21, 43 }) do
  O.shade(c, c:ellipse(fx, 54, 5, 3), LIME, { sphere = { fx - 2, 52, 6 }, amb = .25, wrap = .4, sep = LIME[1] })
end
-- boulder: lumpy outline (main mass + bumps)
local rock = c:ellipse(32, 36, 20, 17)
rock:add(c:ellipse(22, 22, 8, 6)) rock:add(c:ellipse(41, 21, 9, 7)) rock:add(c:ellipse(32, 47, 19, 7))
rock:cut(c:rect(0, 54, 63, 63))
local rI, rT = O.shade(c, rock, LIME, { sphere = { 24, 22, 30 }, amb = .32, wrap = .42, rim = true, bounce = "#5a6a9a", bmax = 2, sep = LIME[1] })
-- strata lines and pits
O.tex(c, rI, rT, LIME, function(x, y, i)
  local wob = math.floor(math.sin(x * .35) * 1.2)
  if (y + wob) % 6 == 0 then return -1 end
  if (y + wob) % 6 == 1 and i >= 3 and x % 4 == 0 then return 1 end
  if H(x, y, 7) > .93 then return -1 end
end)
-- ochre mineral streaks running down
for _, s in ipairs({ { 14, 30, 6 }, { 49, 28, 8 }, { 46, 40, 5 } }) do
  for j = 0, s[3] do O.mark(c, { { s[1] + (j // 3), s[2] + j } }, OCHR[j % 2 + 1]) end
end

-- the den mouth, mid-yawn
local mouth = c:ellipse(32, 40, 10, 10)
mouth:add(c:ellipse(32, 44, 11, 6))
O.flat(c, mouth, CAVE[1], "mouth")
-- lip of the mouth: one lighter ring of stone
mouth:edge():each(function(x, y) c.pix[y * c.w + x] = (y < 40 and LIME[2] or CAVE[3]) end)
-- inner depth: a lighter throat band at the bottom
O.flat(c, c:ellipse(32, 47, 6, 2), CAVE[2], "throat")
-- stalactites from the roof, stalagmites from the floor
for _, t in ipairs({ { 24, 34, 4 }, { 29, 31, 6 }, { 35, 31, 5 }, { 40, 34, 4 } }) do
  O.shade(c, c:poly{ { t[1] - 1, t[2] }, { t[1] + 2, t[2] }, { t[1] + 1, t[2] + t[3] } }, LIME, { R = 1, amb = .45, wrap = .5, cuts = { .1, .2, .3, .5, .75 } })
end
for _, t in ipairs({ { 25, 50, 4 }, { 38, 50, 4 } }) do
  O.shade(c, c:poly{ { t[1] - 1, t[2] }, { t[1] + 2, t[2] }, { t[1] + 1, t[2] - t[3] } }, LIME, { R = 1, amb = .45, wrap = .5, cuts = { .1, .2, .3, .5, .75 } })
end
-- tiny bat hanging from the roof, asleep (wings wrapped, ears down)
O.flat(c, c:rect(31, 37, 33, 41), BAT[2], "bat")
O.dots(c, { { 30, 38 }, { 30, 39 }, { 30, 40 }, { 34, 38 }, { 34, 39 }, { 34, 40 } }, BAT[1])
O.dots(c, { { 31, 37 }, { 32, 38 }, { 31, 39 } }, BAT[3])
O.dots(c, { { 31, 42 }, { 33, 42 } }, BAT[1]) -- ears (it hangs upside down)
O.dots(c, { { 31, 36 }, { 33, 36 } }, LIME[4]) -- feet gripping the roof
O.dots(c, { { 32, 40 } }, CAVE[1]) -- closed eye

-- moss cap and a little fern on the top bump
local moss = HP.mask()
for x = 15, 50 do
  local top
  for y = 0, 63 do if rock:has(x, y) then top = y break end end
  if top then moss:add(c:rect(x, top, x, top + 1 + math.floor(H(x, 1, 5) * 2))) end
end
moss:cut(c:rect(0, 0, 25, 63)) -- just the right bump
local mI, mT = O.shade(c, moss, MOSS, { R = 1, amb = .35, wrap = .45, cuts = { .25, .5, .78 } })
-- one fern frond arching over to the right, leaflets along it
local fr, fn, FT = O.tube({ { 40, 15 }, { 40, 7 }, { 48, 4 }, { 52, 9 } }, function(t) return 1 end)
O.shadeN(c, fr, fn, MOSS, { amb = .4, wrap = .45, cuts = { .25, .5, .78 } })
for k = 1, 6 do
  local t = k / 7
  local x, y = O.bez({ { 40, 15 }, { 40, 7 }, { 48, 4 }, { 52, 9 } }, t)
  x, y = math.floor(x + .5), math.floor(y + .5)
  local len = 3 - math.floor(t * 2)
  for j = 1, len do O.dot(c, x - j, y - j + (t > .5 and 2 * j or 0), MOSS[3]) O.dot(c, x + j, y - j + (t > .5 and 0 or j), MOSS[4]) end
end

-- a root dangling down the left side
local root, rn = O.tube({ { 15, 26 }, { 11, 32 }, { 12, 40 }, { 9, 45 } }, function(t) return 1.1 - .3 * t end)
O.shadeN(c, root, rn, ROOT, { amb = .3, wrap = .45, cuts = { .3, .65 } })

-- face: eyes above the mouth, sleepy cheeks
c:eyeLocked(21, 21)
c:eyeLocked(38, 21)
c:cheek(17, 28) c:cheek(45, 28)

O.done(c, "pl-dlz-5-yard", function(c)
  -- yawn breath puffs
  for _, p in ipairs({ { 55, 38 }, { 56, 37 }, { 57, 38 }, { 58, 35 }, { 59, 34 } }) do c:put(p[1], p[2], LIME[5]) end
end)

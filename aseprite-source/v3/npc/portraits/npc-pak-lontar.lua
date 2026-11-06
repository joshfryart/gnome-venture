-- npc-pak-lontar portrait (npc2 P1_27) species: water buffalo
-- Elder kerbau: sweeping bone horns, flat-topped songkok, broad soft muzzle with white walrus moustache and brows,
-- blue batik shirt; companion: ginger kitten peeking from his woven lontar basket. 80x100, teal disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pak-lontar"
local HIDE = { hi = "#a88c80", base = "#806660", shade = "#5c4656", deep = "#413044" }
local MUZ = { hi = "#f2d6bc", base = "#d6ac94", shade = "#ae8278", deep = "#7a5460" }
local HORN = { hi = "#f6e8c6", base = "#d8c09a", shade = "#a8907e", deep = "#6f5e6a" }
local PECI = { hi = "#625a8e", base = "#433c6c", shade = "#322c56", deep = "#262046" }
local SHIRT = { hi = "#7aaee0", base = "#4a7abc", shade = "#38559a", deep = "#2c3a6e" }
local HAIR = { hi = "#fbf1de", base = "#e6d8c4", shade = "#bcaab0", deep = "#8a7a8e" }
local BASK = { hi = "#f4cc76", base = "#d49c4a", shade = "#a86c3a", deep = "#7a4636" }
local CAT = { hi = "#f8b860", base = "#e2802e", shade = "#b8562e", deep = "#7e3a34" }
local GOLDR = { hi = "#ffe08a", base = "#f0b43c", shade = "#c47e2a", deep = "#8a4e26" }
local DISC = { hi = "#c4ece4", base = "#9fd6cc", shade = "#74b4b0", deep = "#4f8a92" }
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:copy():grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
c:part(c:rect(32, 62, 47, 72), HIDE, { band = 2, nopop = true })
local sh = c:ellipse(39.5, 103, 37, 33):clip(c:rect(0, 0, 79, 99))
c:part(sh, SHIRT, { band = 3, pop = { x = 12, y = 90 } })
for y = 74, 99, 5 do for x = 4 + ((y // 5) % 2) * 4, 76, 8 do
  local ok = true
  for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do if not sh:has(x + d[1], y + d[2]) then ok = false end end
  if ok then for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do c:put(x + d[1], y + d[2], GOLDR.shade) end c:put(x, y, GOLDR.hi) end
end end
c:part(c:poly{ { 32, 69 }, { 47, 69 }, { 39.5, 78 } }, HIDE, { band = 1, nopop = true })
-- horns, ears, head
for _, s in ipairs{ -1, 1 } do
  local function X(x) return math.floor(39.5 + s * (39.5 - x) + 0.5 * (s - 1) * -0) end
  c:part(c:line({ { X(24), 42 }, { X(14), 40 }, { X(8), 34 }, { X(7), 27 } }, 5), HORN, { band = 2, nopop = true })
  c:part(c:line({ { X(7), 28 }, { X(9), 20 } }, 3), HORN, { band = 1, nopop = true })
  for _, q in ipairs{ { 13, 38 }, { 13, 42 }, { 9, 32 }, { 6, 30 } } do c:put(X(q[1]), q[2], HORN.shade) end
  c:part(c:ellipse(X(16) + 0.5, 50, 4.5, 2.5), HIDE, { band = 1, nopop = true })
  c:put(X(16), 50, MUZ.shade) c:put(X(15), 50, MUZ.shade)
end
c:put(12, 37, HORN.hi) c:put(7, 26, HORN.hi) c:put(8, 22, HORN.hi)
c:part(c:ellipse(39.5, 50, 20, 15.5), HIDE, { band = 3, pop = { x = 26, y = 41 } })
c:part(c:ellipse(39.5, 59, 12, 7), MUZ, { band = 2, pop = { x = 31, y = 55 } })
c:put(39, 53, MUZ.hi) c:put(40, 53, MUZ.hi) c:put(39, 54, MUZ.hi)
for _, q in ipairs{ { 34, 57 }, { 35, 57 }, { 34, 58 }, { 44, 57 }, { 45, 57 }, { 45, 58 } } do c:put(q[1], q[2], MUZ.deep) end
local mu = c:ellipse(33, 62.5, 5.5, 1.5) mu:add(c:ellipse(46, 62.5, 5.5, 1.5))
mu:add(c:rect(26, 60, 27, 61)) mu:add(c:rect(52, 60, 53, 61))
c:part(mu, HAIR, { band = 1, pop = { x = 30, y = 61 } })
for x = 37, 42 do c:put(x, 65, MUZ.deep) end
c:part(c:ellipse(30, 42.5, 3.5, 1), HAIR, { band = 1, nopop = true })
c:part(c:ellipse(49, 42.5, 3.5, 1), HAIR, { band = 1, nopop = true })
c:eyeLocked(28, 46) c:eyeLocked(47, 46)
c:cheek(23, 56) c:cheek(55, 56)
-- songkok
c:part(c:rrect(24, 25, 55, 38, 2), PECI, { band = 2, pop = { x = 27, y = 26 } })
for x = 25, 54 do c:put(x, 29, PECI.deep) end
for x = 26, 53, 2 do c:put(x, 36, GOLDR.base) end
-- kitten + basket
local ck = c:ellipse(39.5, 84, 7, 5.5)
ck:add(c:poly{ { 33, 81 }, { 34, 74 }, { 38, 79 } }) ck:add(c:poly{ { 41, 79 }, { 45, 74 }, { 46, 81 } })
c:part(ck, CAT, { band = 2, pop = { x = 34, y = 80 } })
c:put(35, 78, "#e88a9a") c:put(44, 78, "#e88a9a")
for _, q in ipairs{ { 39, 79 }, { 40, 79 }, { 39, 80 }, { 37, 80 }, { 42, 80 } } do c:put(q[1], q[2], CAT.shade) end
for _, ex in ipairs{ 35, 43 } do c:put(ex, 84, P.cream) c:put(ex + 1, 84, P.ink) c:put(ex, 85, P.ink) c:put(ex + 1, 85, P.ink) end
c:put(39, 86, "#e88a9a") c:put(40, 86, "#e88a9a")
for x = 37, 42 do c:put(x, 87, CAT.hi) end
local bowl = c:ellipse(39.5, 92, 21, 9):clip(c:rect(0, 89, 79, 99))
c:part(bowl, BASK, { band = 2, nopop = true })
bowl:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 and c:get(x, y) == BASK.base then c:put(x, y, BASK.shade) end end)
c:part(c:ellipse(39.5, 89, 21, 2.5), BASK, { band = 1, pop = { x = 22, y = 87 } })
c:part(c:ellipse(19, 90, 4, 3), HIDE, { band = 1, pop = { x = 17, y = 89 } })
c:part(c:ellipse(60, 90, 4, 3), HIDE, { band = 1, nopop = true })
c:finish{ outline = true }
backdrop(c, DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

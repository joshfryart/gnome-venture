-- npc-bracken-spurwing portrait (npc2 P1_2) species: ground beetle
-- Same design as the sprite: glossy brown beetle, purple bandana + knot tails, clubbed antennae,
-- clypeus-plate nose, horn mandibles, red vest over elytra shoulders, four arms; holds a bracken fiddlehead.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-bracken-spurwing"
local SH = { hi = "#d39a5e", base = "#9a5f36", shade = "#64394a", deep = "#3d2438" }
local CLY = { hi = "#e8b47a", base = "#b97a44", shade = "#7a4a44", deep = "#4a2c3a" }
local MAND = { hi = "#f2d29a", base = "#c9955a", shade = "#8a5a48", deep = "#5a3644" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local VEST, BAND, FERN = P.ember, P.dusk, P.moss
local NO = { band = 1, nopop = true, inner = false }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- bracken frond behind everything on the right
local fern = c:line({ { 64, 99 }, { 64, 60 }, { 65, 40 }, { 63, 31 } }, 2)
for y = 92, 40, -7 do local x = (y > 60) and 64 or 64.5
  fern:add(c:line({ { x, y }, { x - 5, y + 3 } }, 2)) fern:add(c:line({ { x + 1, y - 3 }, { x + 6, y } }, 2)) end
fern:add(c:ellipse(60, 28, 3.5, 3.5))
c:part(fern, FERN, { band = 2, inner = false, pop = { x = 58, y = 26 } })
c:put(60, 28, FERN.deep) c:put(61, 28, FERN.deep) c:put(61, 29, FERN.shade) c:put(59, 29, FERN.shade)
-- elytra shoulders + thorax
local shell = c:ellipse(39.5, 102, 33, 26):clip(c:rect(0, 74, 79, 99))
c:part(shell, SH, { band = 2, inner = false, pop = { x = 12, y = 88 } })
local thor = c:ellipse(39.5, 70, 11, 6)
c:part(thor, SH, { band = 1, inner = false, nopop = true }) under(thor, SH.deep)
-- vest
local vest = c:poly{ { 17, 100 }, { 19, 84 }, { 29, 77 }, { 50, 77 }, { 60, 84 }, { 62, 100 } }
c:part(vest, VEST, { band = 2, inner = false, pop = { x = 21, y = 85 } })
c:part(c:poly{ { 31, 76 }, { 48, 76 }, { 39.5, 88 } }, CR, NO)
c:line({ { 31, 77 }, { 39, 88 } }, 1):add(c:line({ { 48, 77 }, { 40, 88 } }, 1)):each(function(x, y) c:put(x, y, VEST.deep) end)
for y = 89, 99 do c:put(39, y, VEST.deep) c:put(40, y, VEST.shade) end
c:button(43, 92) c:button(43, 98)
-- four arms: lower pair at the hips, upper-left on chest, upper-right gripping the frond
for _, a in ipairs{ { 18, 93, 3, 2.5 }, { 61, 93, 3, 2.5 }, { 25, 83, 2.5, 2 } } do
  local m = c:ellipse(a[1], a[2], a[3], a[4]) c:part(m, SH, NO) under(m, SH.deep) end
local arm = c:line({ { 57, 84 }, { 61, 78 } }, 3) c:part(arm, SH, NO)
local hand = c:ellipse(63.5, 75.5, 2.5, 2.5) c:part(hand, SH, { band = 1, inner = false, pop = { x = 62, y = 74 } }) under(hand, SH.deep)
-- antennae
local an = c:line({ { 32, 32 }, { 28, 21 }, { 22, 14 } }, 2):add(c:line({ { 46, 32 }, { 50, 21 }, { 56, 14 } }, 2))
c:part(an, SH, NO)
for _, t in ipairs{ { 20.5, 12 }, { 58.5, 12 } } do
  c:part(c:ellipse(t[1], t[2], 2.5, 2), SH, { band = 1, inner = false, pop = { x = math.floor(t[1]) - 1, y = 11 } }) end
-- head
local head = c:ellipse(39.5, 47, 20, 17)
c:part(head, SH, { band = 3, inner = false, nopop = true }) under(head, SH.deep)
for _, q in ipairs{ { 29, 34 }, { 30, 33 }, { 31, 33 }, { 32, 32 }, { 33, 32 }, { 34, 32 } } do c:put(q[1], q[2], SH.hi) end
c:put(32, 32, P.cream) c:put(33, 32, P.cream)
-- bandana
local band = HP.mask()
head:each(function(x, y) local t = 33 + math.floor(5 * (1 - ((x - 39.5) / 20) ^ 2) + 0.5)
  if y >= t and y <= t + 3 then band:set(x, y) end end)
c:part(band, BAND, NO)
band:each(function(x, y) if not band:has(x, y - 1) and x < 42 then c:put(x, y, BAND.hi) end end)
local tails = c:poly{ { 58, 35 }, { 69, 40 }, { 67, 45 } }:add(c:poly{ { 58, 38 }, { 65, 47 }, { 61, 49 } })
c:part(tails, BAND, NO) under(tails, BAND.deep)
c:put(66, 41, BAND.shade) c:put(63, 45, BAND.shade)
c:part(c:ellipse(58, 37, 3, 2.5), BAND, { band = 1, inner = false, pop = { x = 56, y = 35 } })
-- face
c:eyeLocked(28, 44) c:eyeLocked(47, 44)
for _, x in ipairs{ 28, 47 } do for i = 1, 3 do c:put(x + i, 42, SH.deep) end end
local cly = c:rrect(34, 51, 45, 55, 2)
c:part(cly, CLY, { band = 1, inner = false, pop = { x = 36, y = 51 } }) under(cly, CLY.deep)
c:put(37, 52, P.cream)
for _, q in ipairs{ { 35, 57 }, { 36, 58 }, { 37, 58 }, { 38, 58 }, { 39, 58 }, { 40, 58 }, { 41, 58 }, { 42, 58 }, { 43, 58 }, { 44, 57 } } do c:put(q[1], q[2], P.ink) end
c:put(38, 59, P.petal.base) c:put(39, 59, P.petal.base) c:put(40, 59, P.petal.base) c:put(41, 59, P.petal.base)
local md = c:line({ { 31, 59 }, { 30, 63 }, { 33, 66 } }, 3):add(c:line({ { 47, 59 }, { 48, 63 }, { 45, 66 } }, 3))
c:part(md, MAND, NO) c:put(31, 60, MAND.hi) c:put(48, 60, MAND.hi)
c:paint({ "PPP", "PPP" }, 23, 51, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 51, { P = "petal.base" })
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

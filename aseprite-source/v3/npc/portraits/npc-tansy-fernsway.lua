-- npc-tansy-fernsway portrait (npc2 P1_35) species: star-nosed mole
-- 80x100 head+shoulders, bleeds off bottom. Same design as the sprite: rose beret with darned patch, moss knit shawl,
-- cream blouse, pink star nose, pink digging paw holding a fern frond. Backdrop: gold disc.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-tansy-fernsway"
local FUR = { hi = "#b98a66", base = "#8a6450", shade = "#5f4555", deep = "#3c2c40" }
local MUZ = { hi = "#f3dcbc", base = "#d9b38f", shade = "#a87f7c", deep = "#6e4f5e" }
local PAW = { hi = "#ffd0dc", base = "#f0a0b4", shade = "#c06c8c", deep = "#7d3c5e" }
local BER = { hi = "#f08aa0", base = "#d0506e", shade = "#9a3460", deep = "#5e2048" }
local CR  = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shoulders: fur, blouse V, knit shawl
local body = c:ellipse(39.5, 104, 33, 29):clip(c:rect(0, 0, 79, 99))
c:part(body, FUR, { band = 3, pop = { x = 14, y = 88 } })
c:part(c:poly{ { 29, 74 }, { 50, 74 }, { 39.5, 93 } }:clip(body), CR, { band = 2, nopop = true })
local sh = c:poly{ { 5, 99 }, { 8, 87 }, { 18, 78 }, { 30, 75 }, { 39.5, 92 }, { 49, 75 }, { 61, 78 }, { 71, 87 }, { 74, 99 } }:clip(body)
c:part(sh, P.moss, { band = 3, pop = { x = 16, y = 80 } })
sh:each(function(x, y) if y % 3 == 0 and x % 2 == 0 and c:get(x, y) == P.moss.base then c:put(x, y, P.moss.shade) end end)
c:button(39, 80)
-- head
local head = c:ellipse(39.5, 50, 20, 17)
for _, a in ipairs{ 150, 165, 180, 0, 15, 30 } do local r = math.rad(a)
  head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 50 + math.sin(r) * 16.5, 1.8, 1.8)) end
c:part(head, FUR, { band = 3, pop = { x = 25, y = 42 } })
for _, s in ipairs{ { 23, 46, 24, 44 }, { 27, 43, 28, 41 }, { 21, 52, 22, 50 }, { 55, 55, 56, 53 }, { 53, 60, 54, 58 } } do
  c:fillMask(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(head), s[1] < 40 and FUR.hi or FUR.shade) end
c:part(c:ellipse(39.5, 59, 10, 7.5), MUZ, { band = 2, nopop = true, inner = false })
-- beret
local ber = c:ellipse(37, 35, 22, 5.5)
ber:add(c:ellipse(35, 31, 18, 6.5))
c:part(ber, BER, { band = 2, pop = { x = 23, y = 28 } })
under(ber, BER.deep)
for x = 16, 58 do for y = 36, 41 do if ber:has(x, y) and not ber:has(x, y + 2) and c:get(x, y) ~= BER.deep then c:put(x, y, BER.shade) break end end end
c:part(c:ellipse(34, 23, 2.5, 2):add(c:rect(34, 23, 35, 26)), BER, { band = 1, pop = { x = 33, y = 22 } })
c:part(c:rrect(45, 28, 50, 32, 1), BER, { band = 1, nopop = true, inner = false })
for _, q in ipairs{ { 45, 28 }, { 47, 28 }, { 49, 28 }, { 50, 30 }, { 50, 32 }, { 46, 32 }, { 48, 32 } } do c:put(q[1], q[2], P.gold.base) end
-- face
c:eyeLocked(28, 44) c:eyeLocked(47, 44)
for x = 28, 31 do c:put(x, 42, FUR.deep) end for x = 48, 51 do c:put(x, 42, FUR.deep) end
local nose = c:ellipse(39.5, 56, 2.5, 2)
for k = 0, 10 do local a = math.rad(k * 360 / 11 - 90)
  nose:add(HP.ellipse(39.5 + math.cos(a) * 6.5, 56 + math.sin(a) * 5.2, 1.2, 1.2)) end
c:part(nose, P.petal, { band = 1, pop = { x = 36, y = 52 } })
c:put(38, 56, P.petal.deep) c:put(41, 56, P.petal.deep)
c:paint({ "i....i", ".iiii." }, 37, 63, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 58, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 58, { P = "petal.base" })
-- fern frond held in a pink digging paw
local pts = { { 18, 90 }, { 14, 74 }, { 11, 58 }, { 13, 40 } }
local leaf = HP.mask()
for i = 1, 3 do local a, z = pts[i], pts[i + 1]
  for t = 0, 4 do
    local x, y = a[1] + (z[1] - a[1]) * t / 5, a[2] + (z[2] - a[2]) * t / 5
    local k = (i - 1) * 5 + t
    local L = math.max(2, 7 - k // 3)
    local side = (k % 2 == 0) and -1 or 1
    if k >= 2 then leaf:add(c:line({ { x, y }, { x + side * L, y - 2 - L // 3 } }, 2)) end
  end
end
leaf:add(HP.ellipse(13, 39, 1.8, 2.5))
c:part(leaf, P.moss, { band = 1, pop = { x = 12, y = 37 }, inner = false })
c:fillMask(c:line(pts, 1), P.moss.deep)
local paw = c:ellipse(18, 89, 5, 4)
c:part(paw, PAW, { band = 2, pop = { x = 15, y = 87 } })
for _, q in ipairs{ { 14, 86 }, { 17, 85 }, { 20, 85 }, { 22, 86 } } do c:put(q[1], q[2], CR.base) end
c:finish{ outline = true }
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

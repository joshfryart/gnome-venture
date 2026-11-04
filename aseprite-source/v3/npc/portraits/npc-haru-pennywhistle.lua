-- npc-haru-pennywhistle portrait (npc2 P1_13) species: green bush-cricket
-- 80x100 head and shoulders: green cricket in a wide pink woven kasa hat, pale face shield with a button
-- clypeus nose and little mandibles, sea-blue tunic with cream collar, hind-leg knees behind the shoulders.
-- Prop in frame: tin pennywhistle with gold mouthpiece. Backdrop: sea disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-haru-pennywhistle"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function dot(x, y, h) c:put(x, y, h, c.own[y * c.w + x]) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- hind-leg knees rising behind the shoulders
for _, s in ipairs{ -1, 1 } do
  c:part(c:poly{ { 39.5 + s * 19, 99 }, { 39.5 + s * 30, 70 }, { 39.5 + s * 34, 73 }, { 39.5 + s * 30, 99 } }, "moss", { band = 2, nopop = true })
end
-- tunic shoulders
local body = c:ellipse(39.5, 104, 30, 30):clip(c:rect(0, 70, 79, 99))
c:part(body, "sea", { band = 3, pop = { 18, 82 } })
c:part(c:poly{ { 31, 69 }, { 48, 69 }, { 39.5, 80 } }, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
c:button(39, 84) c:button(39, 92)
for _, q in ipairs{ { 22, 88 }, { 26, 94 }, { 54, 86 }, { 50, 96 } } do dot(q[1], q[2], P.sea.shade) dot(q[1], q[2] + 1, P.sea.shade) end
-- head
local head = c:ellipse(39.5, 53, 20, 16)
c:part(head, "moss", { band = 3, pop = { 24, 46 } })
-- face shield + clypeus nose + mandibles
local shield = c:rrect(34, 53, 45, 63, 4)
c:part(shield, { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }, { band = 1, pop = { 35, 54 } })
c:part(c:rrect(37, 54, 42, 57, 1), "wood", { band = 1, pop = { 38, 54 } })
c:paint({ "i......i", ".iiiiii.", "..DppD..", "...ii..." }, 36, 59, { i = "ink", D = "wood.deep", p = "petal.base" })
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
c:paint({ "PPP", "PPP" }, 23, 55, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 55, { P = "petal.base" })
dot(23, 55, P.petal.hi) dot(54, 55, P.petal.hi)
-- kasa hat: wide woven cone with band and gold knob
local hm = c:ellipse(39.5, 39, 28, 4.5)
hm:add(c:poly{ { 12, 39 }, { 67, 39 }, { 39.5, 16 } })
c:part(hm, "petal", { band = 2, pop = { 33, 24 } })
for _, ex in ipairs{ 16, 24, 32, 47, 55, 63 } do
  c:line({ { 39.5, 18 }, { ex, 40 } }, 1):clip(hm):each(function(x, y) if y > 21 then dot(x, y, P.petal.shade) end end)
end
for x = 12, 67 do for y = 34, 44 do if hm:has(x, y) and not hm:has(x, y + 1) then dot(x, y - 1, P.petal.deep) end end end
for x = 18, 61 do local y = 35 if hm:has(x, y) then dot(x, y, (x % 4 == 0) and P.gold.base or P.petal.deep) end end
c:part(c:ellipse(39.5, 16, 2, 2), "gold", { band = 1, pop = { 38, 15 } })
-- pennywhistle (prop) and hand
local fl = c:line({ { 47, 99 }, { 70, 70 } }, 3)
c:part(fl, "stone", { band = 1, pop = { 60, 81 } })
c:part(c:line({ { 68, 72 }, { 71, 68 } }, 3), "gold", { band = 1, pop = { 69, 69 } })
for _, q in ipairs{ { 53, 91 }, { 56, 87 }, { 59, 83 }, { 62, 80 } } do dot(q[1], q[2], P.ink) end
c:part(c:ellipse(51, 93, 3.5, 3), "moss", { band = 1, pop = { 49, 92 } })
c:finish{ outline = true }
-- long sweeping antennae from under the brim
c:fillMask(c:line({ { 11, 38 }, { 7, 27 }, { 8, 16 }, { 13, 8 } }, 1), P.ink)
c:fillMask(c:line({ { 68, 38 }, { 72, 27 }, { 71, 15 }, { 66, 6 } }, 1), P.ink)
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

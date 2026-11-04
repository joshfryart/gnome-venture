-- folk-bumblebee PASS 1 (form). Hearth Pop v3, 80x100 stop-folk species portrait (neutral outfit).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-bumblebee.p1"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end
local FUR = { hi = P.dusk.shade, base = P.dusk.deep, shade = P.ink, deep = P.ink }
local function overlay(mask, r, baseOf)
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end

-- wings behind the shoulders
c:part(c:ellipse(15, 66, 8, 12), "sky", { band = 2 })
c:part(c:ellipse(65, 66, 8, 12), "sky", { band = 2 })
c:fillMask(c:line({ {19,74},{13,60} }, 1), P.sky.shade) c:fillMask(c:line({ {61,74},{67,60} }, 1), P.sky.shade)
-- fuzzy striped body
local body = c:poly{ {4,100},{7,86},{16,76},{30,70},{50,70},{64,76},{73,86},{76,100} }
c:part(body, "gold", { band = 3 })
overlay(c:rect(0, 80, 79, 84):clip(body), FUR, P.gold)
overlay(c:rect(0, 92, 79, 96):clip(body), FUR, P.gold)
-- apron (neutral cream) with straps and a pocket
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.shade }
c:part(c:poly{ {27,100},{28,79},{52,79},{53,100} }, CR, { nopop = true })
c:part(c:rect(28, 70, 31, 79), CR, { nopop = true, band = 1 }) c:part(c:rect(49, 70, 52, 79), CR, { nopop = true, band = 1 })
c:part(c:rect(35, 87, 45, 94), CR, { nopop = true, band = 1 })

-- antennae (club tips drawn now, stalks after outline)
c:part(c:ellipse(25, 11, 2.5, 2.5), FUR, { band = 1 })
c:paint({ ".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }, 51, 6, { X = "petal.base" })
c:px(52, 7, P.petal.hi)
-- head: round, fuzzy dark cap
local head = c:ellipse(39.5, 46, 21, 19)
for _, b in ipairs{ {24,32},{31,28},{39,27},{47,28},{54,32} } do head:add(c:ellipse(b[1], b[2], 3, 3)) end
c:part(head, "gold")
local cap = head:copy():clip(c:ellipse(39.5, 30, 30, 9))
c:part(cap, FUR, { band = 1 })
c:eyeLocked(30, 44) c:eyeLocked(45, 44)
c:cheek(27, 52) c:cheek(52, 52)
for _, p in ipairs{ {38,54},{39,55},{40,55},{41,55},{42,54} } do c:px(p[1], p[2], P.gold.deep) end

c:finish{ outline = true }
c:fillMask(c:line({ {32,30},{28,20},{26,13} }, 1), P.ink)
c:fillMask(c:line({ {47,30},{51,20},{54,12} }, 1), P.ink)
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ png = out .. NAME .. ".png", scale = 1 }

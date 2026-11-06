-- npc-abuela-quilla PASS 1 (form). Hearth Pop v3, 80x100 portrait.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-abuela-quilla.p1"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }

local function overlay(mask, r, baseOf) -- pattern on a part: keeps that part's shade band
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end

-- poncho
local pon = c:poly{ {1,100},{5,86},{14,76},{28,69},{40,71},{52,69},{66,76},{75,86},{79,100} }
c:part(pon, "ember", { band = 3 })
overlay(c:rect(0, 81, 79, 82):clip(pon), P.gold, P.ember)
local zz = HP.mask()
for x = 0, 79 do local t = x % 6; local d = t < 3 and t or 6 - t; zz:set(x, 85 + d) end
overlay(zz:clip(pon), { base = P.cream, shade = P.stone.hi }, P.ember)
overlay(c:rect(0, 91, 79, 92):clip(pon), P.sea, P.ember)
overlay(c:rect(0, 96, 79, 96):clip(pon), P.gold, P.ember)
-- neck + collar
c:part(c:rect(34, 58, 45, 70), "skinB", { nopop = true })
c:part(c:ellipse(39.5, 70, 9, 2), "gold", { band = 1 })

-- braids (in front of the poncho)
local function braid(pts)
  local m = c:line(pts, 6)
  c:part(m, "stone", { band = 2 })
  local x0, y0, x1, y1 = m:bbox()
  for y = y0 + 3, y1 - 2, 4 do
    for i = 0, 2 do
      for x = x0, x1 do if m:has(x, y) and not m:has(x - 1, y) then c:px(x + i + 1, y + i - 1, P.stone.shade) break end end
    end
  end
  return m
end
braid{ {21,48},{20,60},{19,74} }
braid{ {58,48},{59,60},{60,74} }
-- ribbons + tufts
for _, bx in ipairs{ 19, 60 } do
  c:part(c:rect(bx - 3, 76, bx + 2, 78), "sea", { band = 1, nopop = true })
  c:part(c:poly{ {bx-2,79},{bx+2,79},{bx+3,84},{bx-3,84} }, "stone", { band = 1, nopop = true })
end

-- head
local head = c:ellipse(39.5, 44, 20, 18)
c:part(head, "skinB")
-- hair (grey, centre part) under hat
local hair = head:copy():clip(c:rect(0, 0, 79, 37)):add(c:poly{ {19,34},{26,34},{24,52},{19,52} }):add(c:poly{ {53,34},{60,34},{60,52},{55,52} }):clip(head:copy():add(c:rect(18,34,61,52)))
c:part(hair, "stone", { band = 2 })
c:fillMask(c:line({ {39,32},{39,36} }, 1), P.stone.shade)
-- face
c:eyeLocked(30, 43) c:eyeLocked(45, 43)
c:fillMask(c:rect(30, 40, 33, 40), P.stone.shade) c:fillMask(c:rect(46, 40, 49, 40), P.stone.shade)
c:cheek(28, 50) c:cheek(51, 50)
c:px(41, 48, P.skinB.shade) c:px(40, 49, P.skinB.shade) c:px(41, 49, P.skinB.shade)
for _, p in ipairs{ {36,52},{37,53},{38,54},{39,54},{40,54},{41,54},{42,54},{43,53},{44,52} } do c:px(p[1], p[2], P.skinB.deep) end

-- hat
c:part(c:poly{ {28,30},{29,15},{33,11},{46,11},{50,15},{51,30} }, "wood")
c:part(c:ellipse(39.5, 30, 27, 3), "wood", { band = 2 })
overlay(c:rect(28, 23, 51, 26), P.ember, P.wood)
c:stitch{ {29, 24}, {50, 24} }
-- feather
c:part(c:poly{ {49,24},{53,15},{59,6},{62,3},{61,9},{56,18},{52,25} }, "gold", { band = 1 })
c:fillMask(c:line({ {51,24},{55,16},{60,7} }, 1), P.gold.shade)

-- cat peeking out of the poncho (quirk: matching tiny hat)
c:part(c:poly{ {33,80},{34,72},{39,77} }, "gold", { band = 1, nopop = true })
c:part(c:poly{ {47,77},{52,72},{53,80} }, "gold", { band = 1, nopop = true })
local cat = c:ellipse(43, 84, 11, 8)
c:part(cat, "gold")
c:px(42, 78, P.gold.shade) c:px(44, 78, P.gold.shade) c:px(43, 79, P.gold.shade)
c:eyeSmall(37, 83) c:eyeSmall(47, 83)
c:px(42, 86, P.petal.base) c:px(43, 86, P.petal.base)
c:px(41, 88, P.ink) c:px(42, 87, P.ink) c:px(43, 87, P.ink) c:px(44, 88, P.ink)
c:part(c:ellipse(36, 93, 3, 2), "gold", { band = 1, nopop = true })
c:part(c:ellipse(50, 93, 3, 2), "gold", { band = 1, nopop = true })
-- cat hat
c:part(c:rect(39, 71, 47, 75), "wood", { band = 1 })
overlay(c:rect(39, 74, 47, 74), P.ember, P.wood)
c:part(c:rect(36, 76, 50, 77), "wood", { band = 1, nopop = true })

c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ png = out .. NAME .. ".png", scale = 1 }

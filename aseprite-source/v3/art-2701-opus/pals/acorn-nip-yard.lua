-- Acorn Nip (mw-acorn-nip), yard sprite 64x64. Opus pass, art-2701-opus.
-- Seedkeeper, common. An acorn-bodied squirrel kit: golden nut body with faint shell stripes,
-- latticed cap pulled down like a beanie, tufted ears through the cap, big bushy rust tail.
-- quirk: a spare baby acorn forgotten in the cap, wedged beside the stalk.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("acorn-nip-yard", 64)

local NUT  = { "#5c3322", "#8e532e", "#bd7a3c", "#dc9d4f", "#f0c06e", "#fae0a0" }
local CAP  = { "#3a2630", "#573a35", "#77553c", "#967046", "#b48e58", "#d1af76" }
local FUR  = { "#5e2626", "#923a2a", "#c45a30", "#e27d3c", "#f2a35e", "#fbca8c" }
local CRM  = { "#c08a66", "#d9a982", "#ecc7a0", "#f7e0bd", "#fdeccc" }

c:groundShadow(31, 58, 18, 3)

-- bushy tail behind, from the lower back up into a curl over the right shoulder
local tm, tn, tT = O.tube({ { 40, 53 }, { 58, 52 }, { 60, 25 }, { 46, 14 } },
  function(t) return 3.8 + 4.2 * math.sin(math.pi * math.min(1, t * 1.15)) end)
-- tufted outer edge: notch the rim every few px
local edge = tm:edge()
edge:each(function(x, y) if (x * 3 + y * 5) % 9 == 0 and x > 47 then tm.s[K(x, y)] = nil end end)
O.shadeN(c, tm, tn, FUR, { amb = .2, wrap = .4 })
-- combed fur strokes (3px, darker), hand placed along the tail
for _, s in ipairs({ { {52,48},{53,47},{54,46} }, { {55,40},{56,39},{56,38} }, { {54,31},{55,30},{55,29} },
                     { {50,22},{51,21},{52,21} }, { {48,44},{49,43},{50,42} }, { {50,34},{51,33},{51,32} } }) do
  O.mark(c, s, FUR[2])
end
O.mark(c, { {47,26},{48,25},{46,30},{47,29} }, FUR[6])
-- curl tip pale
O.dots(c, { {44,13},{45,12},{46,12},{43,14} }, FUR[6])

-- ears (behind the cap)
local earL = c:poly{ {16,29}, {14,15}, {17,16}, {24,25} }
local earR = c:poly{ {46,29}, {48,15}, {45,16}, {38,25} }
O.shade(c, earL, FUR, { R = 2 })
O.shade(c, earR, FUR, { R = 2 })
O.dots(c, { {16,19},{16,20},{17,21},{17,22},{18,23} }, "#c94f84") -- inner ear
O.dots(c, { {46,19},{46,20},{45,21},{45,22},{44,23} }, "#b5425f")
O.dots(c, { {14,14},{15,13},{48,14},{47,13} }, FUR[5]) -- tufts

-- nut body
local body = c:ellipse(31, 44, 14, 13)
local nb = {}
body:each(function(x, y) -- faint longitudinal shell stripes (material cue)
  local dx = x - 31
  for _, s in ipairs({ -9, -4, 4, 9 }) do
    local sx = s * math.sqrt(math.max(0, 1 - ((y - 44) / 13) ^ 2))
    if math.abs(dx - sx) < .5 and y > 38 then nb[K(x, y)] = -1 end
  end
end)
O.shade(c, body, NUT, { sphere = { 29, 41, 15 }, bias = nb, amb = .15, wrap = .3, sep = NUT[1] })

-- cream muzzle + belly
local muz = c:ellipse(31, 45, 6, 3.5)
O.shade(c, muz, CRM, { R = 2, amb = .45 })
local belly = c:ellipse(31, 52, 6, 3)
belly:cut(c:rect(0, 56, 63, 63))
O.shade(c, belly, CRM, { R = 2, amb = .4 })

-- cap: dome pulled low, diamond lattice of scales, scalloped brim
local cap = c:ellipse(31, 31, 18, 10)
cap:cut(c:rect(0, 35, 63, 63))
for x = 13, 49 do if x % 3 == 0 then cap:cut(c:rect(x, 34, x, 34)) end end -- brim scallops
local cb = {}
cap:each(function(x, y)
  if (x + y) % 5 == 0 or (x - y) % 5 == 0 then cb[K(x, y)] = -1 end
  if y == 33 or y == 34 then cb[K(x, y)] = (cb[K(x, y)] or 0) - 1 end
end)
O.shade(c, cap, CAP, { R = 5, bias = cb, amb = .2, wrap = .35 })
-- stalk
local sm, sn = O.tube({ { 31, 22 }, { 31, 18 }, { 33, 16 }, { 36, 16 } }, function(t) return 1.1 end)
O.shadeN(c, sm, sn, CAP, { amb = .3 })

-- quirk: forgotten baby acorn tucked into the cap
local ba = c:ellipse(22, 21.5, 2, 2.5)
O.shade(c, ba, NUT, { sphere = { 21, 20, 3 }, amb = .3, sep = NUT[2] })
local bc = c:ellipse(22, 19, 3, 1)
O.shade(c, bc, CAP, { R = 1, amb = .4 })
O.dot(c, 22, 17, CAP[2])

-- paws clasped over the belly
for _, cx in ipairs({ 26, 36 }) do
  local pw = c:ellipse(cx, 50, 2.5, 2)
  O.shade(c, pw, FUR, { R = 1, amb = .35, sep = FUR[2] })
end
-- feet
for _, cx in ipairs({ 24, 38 }) do
  local ft = c:ellipse(cx, 57, 4, 1.5)
  O.shade(c, ft, FUR, { R = 1, amb = .3, sep = FUR[1] })
end

-- face
c:eyeLocked(22, 37)
c:eyeLocked(36, 37)
c:cheek(19, 43) c:cheek(42, 43)
-- nose: ink button with cream glint
O.dots(c, { {30,42},{31,42},{32,42},{31,43} }, P.ink)
O.dot(c, 30, 42, P.cream)
-- mouth with a nibbling tooth
O.dots(c, { {29,45},{30,46},{31,45},{32,46},{33,45} }, "#6e2c2a")
O.dot(c, 31, 46, P.cream)
O.dot(c, 31, 47, "#d9a982")

O.shift(c, -2, 0)
O.done(c, "acorn-nip-yard")

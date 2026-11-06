-- harissa (final, Opus aC11_0). A slim, tall glass jar of brick-red chilli paste with a knurled tin screw lid and a
-- kraft paper label wrapped round the middle (a little hand-drawn chilli on it). Material: per-pixel cylinder light on
-- the paste (6-tone red, cool-violet shade side), oily specks and pale seeds in the paste, glass cues (empty headspace
-- with a pale core, bright left rim streak, thick lighter glass base), tin lid with bevel, ridges and a specular, AO
-- where lid meets neck and under the label. Ground shadow (it stands).
-- quirk: a fat drip of harissa has escaped the lid and is sliding down the shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor = math.max, math.min, math.floor
local c = A.new("harissa")
local RED  = { "#4e1426", "#7a1d2a", "#a82a2a", "#cf3f2c", "#ea6a3c", "#ffa36a" }
local TIN  = { "#3b3c55", "#5d6078", "#868aa0", "#adb0c2", "#d4d6e0", "#f1f1f6" }
local KRAFT = { "#6b4129", "#93623b", "#b9864f", "#d6a768", "#ecc98a", "#fbe5b0" }
local GLASS = { "#4f5f7a", "#7fa0b4", "#b7d6dc", "#e3f3ee" }
local tP, tL, tB = A.tok("paste"), A.tok("lid"), A.tok("label")

c:groundShadow(32, 55, 14, 2)

-- jar body: slim tall cylinder with rounded shoulder and base
local X0, X1 = 21, 42
local jar = c:rrect(X0, 20, X1, 54, 5)
jar:add(c:rect(25, 16, 38, 21))                       -- neck
local nC = A.vcylN(jar, X0, X1)
-- shoulder dome: tilt normals up on the top rows
jar:each(function(x, y) local k = K(x, y)
  if y <= 24 then local t = (25 - y) / 6 local p = nC[k] nC[k] = { A.norm(p[1], p[2] - t * 0.8, p[3]) } end
  if y >= 51 then local t = (y - 50) / 5 local p = nC[k] nC[k] = { A.norm(p[1], p[2] + t * 0.7, p[3]) } end
end)
-- paste fills to y 24; above is empty glass (headspace)
local paste = jar:copy():clip(c:rect(0, 24, 63, 51))
local bias = {}
local idx = A.shade(c, paste, nC, RED, { tok = tP, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- headspace + neck: empty glass, pale core and tinted edges
local head = jar:copy():clip(c:rect(0, 16, 63, 23))
head:each(function(x, y)
  local e = (x <= 22 or x >= 41 or (y <= 21 and (x == 25 or x == 38)))
  local col = GLASS[3]
  if x >= 37 or (y <= 21 and x >= 36) then col = GLASS[2] end
  if e then col = GLASS[2] end
  if x == 23 or (y <= 21 and x == 26) then col = GLASS[4] end
  c:put(x, y, col, tP)
end)
-- paste surface: wavy top line with a lit lip
for x = X0, X1 do
  local y = 24 + ((x % 5 == 0) and 1 or 0)
  if jar:has(x, y) then c:put(x, y, x < 32 and RED[5] or RED[4], tP) end
  if y == 25 and jar:has(x, 24) then c:put(x, 24, GLASS[3], tP) end
end
-- thick glass base: two lighter rows, cool tint
for x = X0, X1 do for y = 52, 54 do if jar:has(x, y) then
  local col = (y == 52) and RED[2] or ((x < 30) and GLASS[2] or GLASS[1])
  if y == 53 and x >= 24 and x <= 28 then col = GLASS[3] end
  c:put(x, y, col, tP)
end end end
-- paste texture: chilli seeds (pale) and oily dark flecks
paste:each(function(x, y)
  if y > 26 and y < 51 and x > X0 and x < X1 then
    local h = X.hash(x, y, 7)
    local cur = idx[K(x, y)] or 3
    if h < 0.06 then c:put(x, y, RED[max(1, cur - 2)], tP)
    elseif h > 0.965 and cur >= 3 then c:put(x, y, "#f7c766", tP) end
  end
end)
-- glass: bright vertical rim streak on the lit side, and a cool reflected line on the shade side
for y = 26, 50 do
  if y < 31 or y > 45 then c:put(23, y, GLASS[4], tP) end
  if y % 6 ~= 0 then c:put(41, y, "#c46a7c", tP) end
end
c:put(24, 27, A.CREAM, tP) c:put(24, 28, A.CREAM, tP)

-- kraft label wrapped round the jar (cylinder light, flatter), torn top edge
local lab = HP.mask()
for x = X0, X1 do
  local top = 31 + ((x * 7) % 3 == 0 and 1 or 0)
  for y = top, 45 do if jar:has(x, y) then lab:set(x, y) end end
end
local nL = A.vcylN(lab, X0, X1)
local lbias = {}
lab:each(function(x, y) if y == 45 then lbias[K(x, y)] = -1 end end)
local lidx = A.shade(c, lab, nL, KRAFT, { tok = tB, bias = lbias, amb = 0.15, wrap = 0.35 })
-- AO under the label on the paste
for x = X0, X1 do if paste:has(x, 46) then c:put(x, 46, RED[1], tP) end end
-- paper fibre flecks
lab:each(function(x, y) if X.hash(x, y, 3) < 0.07 and y > 32 and y < 44 then
  c:put(x, y, KRAFT[max(1, (lidx[K(x, y)] or 3) - 1)], tB) end end)
-- hand-drawn chilli on the label (ink stroke + red fill + green stalk)
A.map(c, {
  "......gg..",
  ".....gG...",
  "...rRRr...",
  ".rRRRr....",
  "rRRrr.....",
  ".rr.......",
}, 26, 35, { r = "#a82a2a", R = "#e8493b", g = "#3f9150", G = "#7cc35a" }, tB)
-- two ink lines of 'writing'
for x = 27, 37 do if x % 3 ~= 0 then c:put(x, 42, KRAFT[2], tB) end end
for x = 29, 35 do if x % 4 ~= 1 then c:put(x, 43, KRAFT[2], tB) end end

-- tin screw lid: slightly wider than the neck, rounded top bevel, vertical knurl ridges
local lid = c:rrect(22, 9, 41, 16, 2)
local nT = A.vcylN(lid, 22, 41)
lid:each(function(x, y) local k = K(x, y) if y <= 10 then local p = nT[k] nT[k] = { A.norm(p[1], p[2] - 0.9, p[3]) } end end)
local tbias = {}
lid:each(function(x, y) local k = K(x, y)
  if y >= 12 and y <= 15 and x % 2 == 1 then tbias[k] = -1 end   -- knurl grooves
  if y == 16 then tbias[k] = -2 end
end)
A.shade(c, lid, nT, TIN, { tok = tL, bias = tbias, amb = 0.1, wrap = 0.3 })
-- top lip highlight + specular
for x = 25, 33 do c:put(x, 10, TIN[6], tL) end
c:put(25, 12, TIN[6], tL) c:put(25, 13, TIN[6], tL)
c:put(27, 9, A.CREAM, tL)
-- AO: neck shadow under the lid
for x = 25, 38 do c:put(x, 17, GLASS[1], tP) end

-- quirk: a fat drip escaping the lid, running down over the shoulder
local drip = HP.mask()
for _, p in ipairs{ {36,15},{37,15},{36,16},{37,16},{37,17},{37,18},{38,18},{37,19},{38,19},{38,20},{37,20},{38,21},{39,21},{38,22},{39,22},{38,23},{39,23} } do drip:set(p[1], p[2]) end
drip:each(function(x, y) c:put(x, y, (x == 37 and y < 22) and RED[5] or RED[3], tP) end)
c:put(39, 23, RED[2], tP) c:put(38, 23, RED[3], tP) c:put(36, 15, RED[6], tP)
c:put(38, 19, RED[6], tP)

A.save(c, "harissa")

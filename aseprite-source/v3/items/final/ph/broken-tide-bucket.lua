-- broken-tide-bucket (aB12_4, Opus single pass). Staved oak tide bucket, gently tapered: pale end-grain rim, seawater
-- inside with a foam line, curved staves with grain, two iron hoops with rivets, lugs with a twisted hemp rope handle
-- and knots. broken: one stave split from the base up past the lower hoop (jagged gap, hoop cut), seawater dripping
-- out, a stave splinter flying. quirk: a little orange starfish clinging to the front.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, abs, max, min, sin, cos, pi = math.floor, math.sqrt, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new("broken-tide-bucket")
local O, I, R, SEA = A.OAK, A.IRON, A.HEMP, A.SEA
local CX = 32
c:groundShadow(CX, 52, 17, 2)

-- rope handle (behind the lugs)
local rm, rn, RT, RS, rl = A.tube({ { 17, 17 }, { 18, 2 }, { 46, 2 }, { 47, 17 } }, function() return 1.3 end)
A.tone(c, rm, rn, R, { amb = 0.15 })
rm:each(function(x, y) local k = K(x, y) if (RT[k] * rl + RS[k] * 1.6) % 3 < 1 then A.dk(c, x, y, R, 2) end end)

-- body: tapered, curved bottom
local top, bot = 21, 49
local function hw(y) return 16.5 - (y - top) * (3.5 / (bot - top)) end
local body = HP.mask()
for y = top, bot + 3 do
  local w = hw(min(y, bot))
  for x = floor(CX - w + .5), floor(CX + w - .5) do
    local dx = (x + 0.5 - CX) / w
    local ycurve = bot + 2.5 * sqrt(max(0, 1 - dx * dx))
    if y <= ycurve then body:set(x, y) end
  end
end
-- lugs (two taller staves with rope holes)
local lugL = c:rrect(15, 13, 18, 22, 1)
local lugR = c:rrect(46, 13, 49, 22, 1)
local lugs = lugL:copy():add(lugR)
local bn = A.vn(body, CX - 16.5, CX + 16.5)
A.tone(c, body, bn, O, { amb = 0.1, wrap = 0.3 })
A.pil(c, lugs, O, 1.2)
c:px(16, 15, O[1]) c:px(47, 15, O[1]) c:px(16, 14, O[5]) c:px(47, 14, O[4])
-- staves: boundaries follow the cylinder, plus grain streaks
local function staveX(th, y) return CX + hw(y) * sin(th) end
for i = -3, 3 do
  local th = i * 0.42
  for y = top + 3, bot + 2 do
    local x = floor(staveX(th, y) + .5)
    if body:has(x, y) then A.dk(c, x, y, O, 2) end
  end
end
body:each(function(x, y)
  if y > top + 3 and X.hash(x, floor(y / 3), 9) > 0.8 then A.dk(c, x, y, O, 1) end
end)
-- rim: pale end grain ellipse with the water inside
local rimO = c:ellipse(CX, top, 16, 3)
local rimI = c:ellipse(CX, top + 0.3, 14, 2)
local rim = rimO:copy():cut(rimI)
rim:each(function(x, y) c:px(x, y, y < top and O[4] or O[6]) end)
for i = -3, 3 do local x = floor(CX + 15 * sin(i * 0.42) + .5) if rim:has(x, top + 3) then c:px(x, top + 3, O[4]) end end
-- inside: dark back wall, then seawater
rimI:each(function(x, y)
  if y <= top - 1 then c:px(x, y, O[2]) else
    local t = (x - CX) / 14
    c:px(x, y, t < -0.3 and SEA[5] or (t < 0.4 and SEA[4] or SEA[3]))
  end
end)
for x = CX - 11, CX - 6 do c:px(x, top, A.SEA[6]) end
c:px(CX + 3, top + 1, SEA[6]) c:px(CX + 4, top + 1, SEA[6])
-- AO under the rim
for x = CX - 15, CX + 15 do local y = top + 4 if body:has(x, y) and not rimO:has(x, y) then A.dk(c, x, y, O, 1) end end

-- iron hoops (curved bands, 2 px, 1 px proud of the staves)
local hoopM = HP.mask()
for _, hy in ipairs{ 27, 44 } do
  local w = hw(hy) + 1
  for x = floor(CX - w + .5), floor(CX + w - .5) do
    local dx = (x + 0.5 - CX) / w
    local yc = floor(hy + 2.2 * sqrt(max(0, 1 - dx * dx)) + .5)
    hoopM:set(x, yc) hoopM:set(x, yc + 1)
  end
end
local hn = A.vn(hoopM, CX - 17.5, CX + 17.5)
A.tone(c, hoopM, hn, I, { amb = 0.12 })
hoopM:each(function(x, y) if not hoopM:has(x, y - 1) and (x - CX) < 6 then c:px(x, y, I[min(6, (A.idx(I, c:get(x, y)) or 3) + 1)]) end end)
A.ao(c, body, hoopM, O, 1)
for _, rv in ipairs{ { CX - 10, 29 }, { CX + 2, 30 }, { CX - 10, 46 }, { CX + 2, 47 } } do
  c:px(rv[1], rv[2], I[6]) c:px(rv[1] + 1, rv[2], I[2])
end
-- specular on the lit staves
for y = 31, 40 do c:px(CX - 11, y, O[6]) end
c:px(CX - 11, 32, A.CREAM)

-- damage: split stave from the base up past the lower hoop
local gx = CX + 7
local split = A.lmask{ { gx, bot + 3 }, { gx + 1, 48 }, { gx, 45 }, { gx + 1, 42 }, { gx, 39 }, { gx + 1, 36 } }
local gap = split:copy():add(A.lmask{ { gx + 1, bot + 3 }, { gx + 2, 48 }, { gx + 1, 45 }, { gx + 2, 43 } })
A.erase(c, gap)
-- crack continues as a hairline above the gap
A.poly(c, { { gx + 1, 35 }, { gx + 1, 33 } }, A.INK)
c:px(gx - 1, 40, O[6]) c:px(gx - 1, 46, O[6])
-- water leaking from the split
c:px(gx + 4, bot + 1, SEA[4]) c:px(gx + 4, bot + 2, SEA[3]) c:px(gx + 4, bot, SEA[6])
-- splinter flying right
A.chip(c, { { 52, 40 }, { 55, 37 }, { 56, 38 }, { 53, 42 } }, O)
c:px(54, 38, O[6])

-- quirk: starfish on the lower-left front
local st = HP.mask()
local sx, sy = CX - 6, 37
for y = sy - 4, sy + 4 do for x = sx - 4, sx + 4 do
  local dx, dy = x - sx, y - sy
  local r = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx) + pi / 2
  local arm = 1.3 + 2.9 * max(0, cos(2.5 * a)) ^ 2
  if r <= max(1.6, arm) then st:set(x, y) end
end end
A.pil(c, st, A.STAR, 1.4, { amb = 0.15 })
c:px(sx, sy, A.STAR[2]) c:px(sx - 1, sy - 2, A.STAR[6]) c:px(sx + 2, sy - 1, A.STAR[5])
A.ao(c, body, st, O, 1)
A.fin(c)

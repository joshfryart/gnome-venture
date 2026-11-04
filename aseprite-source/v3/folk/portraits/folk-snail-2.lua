-- folk-snail-2 portrait (folk F2_6) variant: 2
-- wandering trader snail: pink banded shell carrying a strapped pack and bedroll, blue cap, red striped scarf, brass lantern. 80x100 head and shoulders, eyes on the stalk tips.
local NAME = "folk-snail-2"
local BODYR = nil

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK, CREAM = P.ink, P.cream
local function R(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
local function part(c, m, r, band) c:part(m, r, { band = band or 2, nopop = true }) return m end
local function under(c, m, r) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, r.deep, r) end end) end
local function texture(c, m, r)
  m:each(function(x, y) if y % 3 == 0 and (x * 5 + y) % 7 == 0 and c:get(x, y) == r.base then c:put(x, y, r.shade, r) end end)
end
local function spiral(c, m, cx, cy, Rr, turns, sy, hex, owner, w, start)
  local inn = m:shrink(1)
  for i = 0, 700 do
    local t = i / 700
    local th = start + t * turns * 2 * math.pi
    local r = Rr * (1 - t) + 0.6
    local x = math.floor(cx + math.cos(th) * r + 0.5)
    local y = math.floor(cy + math.sin(th) * r * sy + 0.5)
    if inn:has(x, y) then c:put(x, y, hex, owner) end
    if w == 2 and inn:has(x, y + 1) then c:put(x, y + 1, hex, owner) end
  end
end
local STL = R("#e6e2d6", "#a8acb8", "#6e7088", "#474660")
local WD = R("#d08e4c", "#9c6038", "#6a3e34", "#432a34")

local SK = R("#dacad2", "#aa98aa", "#7c6a8a", "#4e4060")
local SH = R("#fde8c6", "#efbe9c", "#c2827a", "#7a4a5e")
local BAND = "#5c3249"
local RD = R("#ff9c6c", "#d84c3c", "#9c3042", "#5e1e3a")
local LT = R("#dca26a", "#aa6a40", "#76443e", "#48283a")
local CP = R("#8cc8e2", "#4c88b2", "#345c8a", "#283a5e")
local BR = R("#ffe08c", "#e2a83c", "#aa6c36", "#6a3e34")
local GL = R("#fff2b2", "#ffd46c", "#e2983c", "#9c5c36")
local BL = R("#e8e0a8", "#b8b47a", "#86826c", "#5a5262")
local ARM = SK
local BG = R("#b6d6ea", "#92b6d6", "#7090ba", "#566c9a")

local function shellP(c)
  local sh = c:ellipse(60, 67, 16, 15)
  part(c, sh, SH, 4)
  spiral(c, sh, 62, 68, 14.5, 2.3, 0.95, BAND, SH, 2, 3.4)
  c:put(47, 60, SH.hi, SH) c:put(48, 58, SH.hi, SH)
  local pk = c:rrect(52, 38, 75, 58, 3)
  part(c, pk, LT, 3) under(c, pk, LT)
  local fl = c:rrect(52, 38, 75, 44, 3) part(c, fl, LT, 1)
  for x = 52, 75 do if fl:has(x, 44) then c:put(x, 44, LT.deep, LT) end end
  part(c, c:rect(62, 44, 65, 47), BR, 1)
  local roll = c:ellipse(63.5, 35, 12, 4)
  part(c, roll, BL, 2)
  for _, x in ipairs{ 57, 58, 69, 70 } do for y = 30, 40 do if roll:has(x, y) then c:put(x, y, RD.base, RD) end end end
end
local function clothesP(c)
  part(c, c:line({ {27,70},{24,99} }, 3), LT, 1)
  part(c, c:line({ {52,70},{55,99} }, 3), LT, 1)
  part(c, c:rect(23, 84, 27, 87), BR, 1)
  local sc = c:rrect(17, 64, 62, 72, 3)
  part(c, sc, RD, 3)
  for x = 19, 60, 5 do for y = 66, 69 do if c:get(x, y) == RD.base then c:put(x, y, RD.hi, RD) end end end
  local tl = c:poly{ {43,70},{50,70},{52,92},{44,92} }
  part(c, tl, RD, 2)
  for x = 44, 52, 2 do c:put(x, 92, RD.deep, RD) end
  for _, y in ipairs{ 76, 77, 84, 85 } do for x = 43, 52 do if tl:has(x, y) and c:get(x, y) ~= RD.shade then c:put(x, y, RD.hi, RD) end end end
  part(c, c:ellipse(46.5, 71, 4, 3), RD, 1)
end
local function hatP(c)
  local cap = c:ellipse(39.5, 41, 11, 6)
  cap:add(c:rect(29, 41, 50, 45))
  part(c, cap, CP, 3)
  local pk = c:ellipse(35, 46, 13, 2.5) part(c, pk, CP, 1) under(c, pk, CP)
  part(c, c:ellipse(39.5, 35, 2, 1.5), RD, 1)
  for _, q in ipairs{ {32,38},{33,37},{34,36},{32,39} } do c:put(q[1], q[2], CP.hi, CP) end
end
local function propP(c)
  part(c, c:line({ {62,70},{68,77} }, 1), BR, 1)
  part(c, c:rrect(62, 77, 73, 79, 1), BR, 1)
  local g = c:rrect(62, 80, 73, 91, 2)
  part(c, g, GL, 2)
  for y = 83, 88 do c:put(67, y, GL.hi, GL) c:put(68, y, GL.hi, GL) end
  c:put(64, 81, CREAM, GL) c:put(64, 82, CREAM, GL)
  for x = 62, 73 do c:put(x, 85, BR.shade, BR) end
  part(c, c:rrect(61, 92, 74, 94, 1), BR, 1)
  part(c, c:ellipse(63, 74, 3.5, 3), SK, 1)
end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 31, 31)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
shellP(c)
local body = c:ellipse(39.5, 102, 27, 32):clip(c:rect(0, 64, 79, 99))
part(c, body, BODYR or SK, 3) texture(c, body, BODYR or SK)
clothesP(c)
local head = c:ellipse(39.5, 53, 20.5, 15.5)
part(c, head, SK, 4) texture(c, head, SK)
for _, s in ipairs{ -1, 1 } do local t = c:line({ {39.5 + s * 8, 61}, {39.5 + s * 11, 66} }, 3) part(c, t, SK, 1) end
local mz = c:ellipse(39.5, 60, 7.5, 4)
mz:each(function(x, y) c:put(x, y, mz:has(x + 1, y + 1) and SK.hi or SK.base, SK) end)
c:put(36, 57, CREAM, "m")
for _, q in ipairs{ {34,61},{35,62},{36,63},{37,63},{38,63},{39,63},{40,63},{41,63},{42,63},{43,62},{44,61} } do c:put(q[1], q[2], INK, "m") end
for x = 37, 42 do c:put(x, 62, "#7a2e48", "m") end
c:put(39, 62, "#e0727e", "m") c:put(40, 62, "#e0727e", "m")
c:cheek(24, 59) c:cheek(52, 59)
hatP(c)
local st = c:line({ {33,44},{30,32},{28,22} }, 4)
st:add(c:line({ {46,44},{49,32},{51,22} }, 4))
part(c, st, SK, 1)
for _, e in ipairs{ 27.5, 51.5 } do
  local bl = c:ellipse(e, 17.5, 5, 5) part(c, bl, SK, 2)
  c:put(math.floor(e) - 3, 14, SK.hi, SK) c:put(math.floor(e) - 2, 13, SK.hi, SK)
end
c:eyeLocked(25, 15) c:eyeLocked(49, 15)
propP(c)
c:finish{ outline = true }
backdrop(BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

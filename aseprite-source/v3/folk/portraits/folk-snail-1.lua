-- folk-snail-1 portrait (folk F2_6) variant: 1
-- garden snail: amber globe shell with a seedling sprouting from it, straw hat pierced by the eye stalks, green check neckerchief, trowel. 80x100 head and shoulders, eyes on the stalk tips.
local NAME = "folk-snail-1"
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

local SK = R("#d2cb94", "#a09e6e", "#726c60", "#4a4256")
local SH = R("#f6c86e", "#d48e3e", "#9e5c3c", "#5e3446")
local ST = R("#f6de8e", "#dab65c", "#a8824a", "#6e5040")
local GR = R("#a2d870", "#5ca24c", "#3c6e4e", "#2e4448")
local ARM = SK
local BG = R("#cfe3a0", "#a8c87c", "#7e9e64", "#5c7a54")

local function shellP(c)
  local sh = c:ellipse(62, 66, 16, 16)
  part(c, sh, SH, 4)
  spiral(c, sh, 64, 66, 15, 2.7, 1, SH.deep, SH, 2, 3.6)
  for _, q in ipairs{ {50,56},{51,54},{52,53},{50,57},{54,52} } do c:put(q[1], q[2], SH.hi, SH) end
  part(c, c:rect(65, 43, 66, 51), GR, 1)
  part(c, c:ellipse(61, 42, 4, 2), GR, 1)
  part(c, c:ellipse(70, 40, 4, 2), GR, 1)
  c:put(59, 41, GR.hi, GR) c:put(68, 39, GR.hi, GR)
end
local function clothesP(c)
  local nk = c:poly{ {17,68},{62,68},{42,90},{37,90} }
  part(c, nk, GR, 3)
  for y = 70, 86, 3 do for x = 20, 60, 4 do if nk:has(x, y) and c:get(x, y) == GR.base then c:put(x, y, GR.hi, GR) c:put(x + 1, y, GR.hi, GR) end end end
  part(c, c:ellipse(39.5, 69, 4, 3), GR, 1)
end
local function hatP(c)
  local brim = c:ellipse(39.5, 41, 25, 5.5)
  part(c, brim, ST, 3) under(c, brim, ST)
  local cr = c:rrect(33, 28, 46, 40, 5)
  part(c, cr, ST, 3)
  for x = 33, 46 do c:put(x, 37, GR.base, GR) c:put(x, 38, GR.shade, GR) end
  brim:add(cr):each(function(x, y) if (x + y * 2) % 4 == 0 and c:get(x, y) == ST.base then c:put(x, y, ST.shade, ST) end end)
  for _, q in ipairs{ {35,30},{36,29},{35,31},{18,39},{19,38} } do c:put(q[1], q[2], ST.hi, ST) end
end
local function propP(c)
  part(c, c:line({ {14,97},{17,84} }, 3), WD, 1)
  local bl = c:poly{ {11,84},{24,84},{20,66},{17,66} }
  part(c, bl, STL, 2)
  for y = 70, 82, 3 do c:put(16, y, STL.hi, STL) end
  part(c, c:ellipse(18, 88, 4, 3.5), SK, 1)
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

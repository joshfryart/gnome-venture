-- folk-snail-3 portrait (folk F2_6) variant: 3
-- cook snail: flat chestnut ramshorn shell, teal smock with cream apron, mustard polka kerchief, copper ladle with a soup drip. 80x100 head and shoulders, eyes on the stalk tips.
local NAME = "folk-snail-3"
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

local SK = R("#f6d0a2", "#dca272", "#a8705e", "#6e4458")
local SH = R("#d88c74", "#9e504e", "#6e3448", "#452238")
local STRIPE = "#f0c690"
local AP = R("#fbf0d4", "#ecdab2", "#bca690", "#7e6a72")
local TL = R("#8cdcc2", "#3caa90", "#2c7878", "#234a58")
local MU = R("#ffd86c", "#e2aa3c", "#a8743e", "#6a4440")
local CU = R("#ffc28c", "#d87c4c", "#9c4c40", "#5e2e36")
local SOUP = R("#d6e07a", "#9cb444", "#6c8040", "#46523e")
local ARM = TL
local BODYR = TL
local BG = R("#f2b6a8", "#e09a94", "#bc7880", "#925c72")

local function shellP(c)
  local sh = c:ellipse(58, 69, 19, 11.5)
  part(c, sh, SH, 4)
  spiral(c, sh, 60, 69, 17.5, 3, 0.6, SH.deep, SH, 1, 3.2)
  spiral(c, sh, 60, 69, 16, 2.7, 0.6, STRIPE, SH, 1, 3.2)
  c:put(41, 65, SH.hi, SH) c:put(42, 63, SH.hi, SH) c:put(44, 61, SH.hi, SH)
end
local function clothesP(c)
  local col = c:rrect(22, 65, 57, 72, 3) part(c, col, TL, 2)
  local ap = c:rrect(28, 76, 51, 99, 4) part(c, ap, AP, 3)
  part(c, c:line({ {29,77},{31,69} }, 2), AP, 1) part(c, c:line({ {50,77},{48,69} }, 2), AP, 1)
  local pkt = c:rrect(33, 86, 46, 94, 2)
  pkt:edge():each(function(x, y) c:put(x, y, AP.shade, AP) end)
  part(c, c:rect(36, 82, 37, 87), WD, 1) part(c, c:ellipse(36.5, 81, 2, 1.5), WD, 1)
  for _, f in ipairs{ {31,80,31,98}, {47,85,48,98} } do for y = f[2], f[4] do if c:get(f[1], y) == AP.base then c:put(f[1], y, AP.shade, AP) end end end
end
local function hatP(c)
  local hd = c:ellipse(39.5, 53, 21.5, 16.5):clip(c:rect(0, 0, 79, 46))
  part(c, hd, MU, 3) under(c, hd, MU)
  for _, q in ipairs{ {28,41},{34,39},{40,38},{46,40},{31,45},{37,43},{43,44},{49,44},{24,45},{53,42} } do
    if hd:has(q[1], q[2]) then c:put(q[1], q[2], AP.hi, AP) c:put(q[1] + 1, q[2], AP.hi, AP) end end
  part(c, c:ellipse(60.5, 45, 3, 3), MU, 1)
  part(c, c:poly{ {61,44},{68,38},{70,46} }, MU, 2)
  part(c, c:poly{ {61,46},{67,53},{61,54} }, MU, 2)
end
local function propP(c)
  part(c, c:line({ {16,98},{14,76},{12,60} }, 3), CU, 1)
  local bw = c:ellipse(12, 55, 7, 5) part(c, bw, CU, 2)
  local so = c:ellipse(12, 54, 5, 3) part(c, so, SOUP, 1)
  c:put(10, 53, SOUP.hi, SOUP) c:put(11, 52, SOUP.hi, SOUP)
  part(c, c:rect(5, 61, 5, 62), SOUP, 1)
  part(c, c:ellipse(15.5, 86, 4, 4), SK, 1)
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

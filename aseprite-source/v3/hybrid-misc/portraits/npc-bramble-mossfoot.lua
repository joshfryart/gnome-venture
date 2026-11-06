local NAME="npc-bramble-mossfoot"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function clamp(t) return math.max(1, math.min(5, t)) end
local function hairPaint(mask, ramp, cx, cy, N, tok)
  mask:each(function(x, y)
    local dx, dy = x + .5 - cx, y + .5 - cy
    local s = math.floor(math.atan(dy, dx) * N / math.pi)
    local t = 3 + math.floor((dx + dy) / 12 + .5)
    if s % 2 == 0 then t = t - 1 end
    if dy > 12 then t = t + 1 end
    c:put(x, y, ramp[clamp(t)], tok)
  end)
end
local function nose(x, y, C)
  c:paint({ ".hh.", "hnnn", "nnnn", "dssd" }, x, y, { h = C.h, n = C.n, d = C.d, s = C.s })
end
local OL = { "#e8dc8a", "#c2ad52", "#8a8240", "#5a6338", "#3c4430" }
local MS = { "#d8ee98", "#a4d46c", "#7cc35a", "#3f9150", "#24544a" }
local tokH, tokM = { r = OL }, { r = MS }
local CL = { hi = "#7cc35a", base = "#3f9150", shade = "#24544a", deep = "#1d3f3f" }
-- cloak with moss tufts
local body = c:ellipse(39.5, 106, 35, 36):clip(c:rect(0, 68, 79, 99))
for _, b in ipairs{ {11,86,3},{15,82,2.5},{20,79,2.5},{68,86,3},{64,82,2.5},{59,79,2.5} } do body:add(HP.ellipse(b[1], b[2], b[3], b[3])) end
c:part(body, CL, { band = 3, pop = { x = 16, y = 84 } })
body:each(function(x, y) local h = (x * 7 + y * 13) % 11 if h == 0 and c:get(x, y) == CL.base then keep(x, y, "#5aa854") elseif h == 5 and c:get(x, y) == CL.shade then keep(x, y, CL.deep) end end)
for _, p in ipairs{ {11,84},{15,80},{20,77},{68,84},{64,80},{59,77} } do for dx = -1, 1 do if c:get(p[1] + dx, p[2]) then keep(p[1] + dx, p[2], MS[2]) end end end
c:line({ {39,76},{39,99} }, 1):clip(body):each(function(x, y) keep(x, y, CL.deep) end)
-- satchel strap
local strap = c:line({ {16,73},{58,99} }, 3):clip(body)
c:part(strap, P.wood, { band = 2, nopop = true })
c:stitch{ {19,73},{56,97} }
for _, y in ipairs{ 91, 96 } do c:part(c:ellipse(33, y, 1.5, 1.5), P.wood, { band = 1, nopop = true }) end
-- neck, scarf
c:part(c:ellipse(39.5, 64, 7, 5), P.skinA, { band = 3, nopop = true })
local tail = c:line({ {49,72},{55,92} }, 6)
tail:add(c:line({ {50,72},{56,92} }, 6))
c:part(tail, P.ember, { band = 2, pop = { x = 50, y = 76 } })
for _, y in ipairs{ 80, 86, 92 } do c:line({ {46,y},{60,y + 1} }, 1):clip(tail):each(function(x, yy) keep(x, yy, P.gold.base) end) end
for x = 51, 58, 2 do c:put(x, 93, P.ember.shade) end
local ring = c:ellipse(39.5, 70, 18, 5.5)
c:part(ring, P.ember, { band = 2, pop = { x = 26, y = 68 } })
for _, f in ipairs{ { {28,70},{31,74} }, { {36,72},{37,75} }, { {44,71},{46,75} } } do c:line(f, 1):clip(ring):each(function(x, y) keep(x, y, P.ember.shade) end) end
-- head
local hcx, hcy = 39.5, 47
local head = c:ellipse(hcx, hcy, 20, 18.5)
c:part(head, P.skinA, { band = 3, pop = { x = 27, y = 41 } })
-- spikes
local function spike(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy) dx, dy = dx / L, dy / L
  local px, py = -dy, dx
  if -px - py < 0 then px, py = -px, -py end
  c:poly{ {bx + px * w, by + py * w}, {bx - px * w, by - py * w}, {tx, ty} }:each(function(x, y)
    local ax, ay = x + .5 - bx, y + .5 - by
    local u, v = (ax * dx + ay * dy) / L, ax * px + ay * py
    local t = 3
    if v > w * .35 then t = 2 elseif v < -w * .35 then t = 4 end
    if v > w * .35 and u > .45 then t = 1 end
    if u < .2 then t = t + 1 end
    c:put(x, y, OL[clamp(t)], tokH)
  end)
end
local i = 0
for a = 195, 345, 10 do
  if not (a > 252 and a < 288) then
    i = i + 1
    local r, L = math.rad(a), (i % 2 == 0) and 7 or 11
    spike(hcx + math.cos(r) * 19, hcy + math.sin(r) * 17.5, hcx + math.cos(r + .06) * (20 + L), hcy + math.sin(r + .06) * (18.5 + L), 3.4)
  end
end
local face = c:ellipse(39.5, 51, 15.5, 14.5)
local hm = head:copy():cut(face):clip(c:rect(0, 0, 79, 54))
local up = hm:copy():clip(c:rect(0, 0, 79, 44))
for _, t in ipairs{ { {29,36},{34,36},{31,42} }, { {35,36},{41,36},{38,42} }, { {42,36},{47,36},{44,41} }, { {48,36},{53,37},{51,41} } } do
  local m = c:poly(t) m:each(function(x, y) up:set(x, y) end)
end
hairPaint(up, OL, 39.5, 36, 9, tokH)
hairPaint(hm:copy():clip(c:rect(0, 45, 79, 99)), MS, 39.5, 30, 14, tokM)
-- face
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
nose(38, 49, { h = "#ffc9a0", n = "#e8a07a", d = "#b86a54", s = "#7a4036" })
c:cheek(27, 51) c:cheek(51, 51)
for _, p in ipairs{ {33,52},{35,53},{44,53},{46,52} } do c:put(p[1], p[2], P.skinA.shade) end
c:paint({ "i....i", ".iDDi.", ".iPPi.", "..ii.." }, 37, 54, { i = "ink", D = "ember.deep", P = "petal.base" })
-- quirk: mushroom sprouting from the hair
c:part(c:rrect(38, 22, 41, 29, 1), { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
local cap = c:ellipse(40, 21, 7, 5):clip(c:rect(0, 0, 79, 23))
c:part(cap, P.ember, { band = 2, pop = { x = 36, y = 17 } })
c:line({ {34,23},{46,23} }, 1):clip(cap:copy():add(c:rect(33,23,47,23))):each(function(x, y) c:put(x, y, P.ember.deep) end)
for _, p in ipairs{ {36,18},{40,16},{43,19},{38,21} } do c:put(p[1], p[2], P.cream) end
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

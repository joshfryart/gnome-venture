local NAME="npc-abuela-quilla"
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
local HAIR = { "#f3f1fa", "#e2e0e6", "#aaa9b8", "#74758c", "#5a5b78" }
local tokH = { r = HAIR }
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
-- shawl
local body = c:ellipse(39.5, 106, 35, 36):clip(c:rect(0, 68, 79, 99))
c:part(body, P.dusk, { band = 2, pop = { x = 18, y = 80 } })
for y = 80, 98, 6 do for x = 8 + ((y // 6) % 2) * 5, 72, 10 do
  if body:has(x, y) and body:has(x + 1, y + 1) and x < 48 then keep(x, y, P.petal.base) keep(x - 1, y, P.petal.shade) keep(x + 1, y, P.petal.shade) keep(x, y - 1, P.petal.hi) keep(x, y + 1, P.petal.shade) end
end end
for _, f in ipairs{ { {13,80},{16,90},{14,99} }, { {22,86},{24,93},{22,99} }, { {66,79},{64,88} }, { {58,92},{57,99} } } do
  c:line(f, 1):clip(body):each(function(x, y) keep(x, y, P.dusk.deep) end)
  c:line({ {f[1][1]-1,f[1][2]},{f[2][1]-1,f[2][2]},{f[3] and f[3][1]-1 or f[2][1]-1,f[3] and f[3][2] or f[2][2]} }, 1):clip(body):each(function(x, y) if c:get(x, y) == P.dusk.base then keep(x, y, P.dusk.hi) end end)
end
local blouse = c:poly{ {27,70},{39.5,85},{52,70} }
c:part(blouse, CR, { nopop = true, band = 2 })
c:line({ {33,73},{39,81} }, 1):clip(blouse):each(function(x, y) keep(x, y, P.stone.hi) end)
c:part(c:ellipse(39.5, 65, 8, 6):clip(c:rect(0, 0, 79, 71)), P.skinB, { band = 3, nopop = true })
local trim = c:line({ {19,70},{39.5,87},{60,70} }, 2):clip(body)
c:part(trim, P.gold, { band = 1, nopop = true, inner = false })
c:stitch{ {22,73},{39,86},{57,73} }
-- cat companion on the right shoulder
local cb = c:ellipse(60, 106, 10, 15):clip(c:rect(0, 92, 79, 99))
c:part(cb, P.ember, { band = 2, pop = { x = 55, y = 95 } })
for _, p in ipairs{ {55,93},{57,95},{59,93},{63,94},{65,96},{52,96} } do c:line({ {p[1],p[2]},{p[1],p[2]+2} }, 1):clip(cb):each(function(x, y) keep(x, y, P.ember.shade) end) end
local ch = c:ellipse(60, 87, 8, 6.5)
ch:add(c:poly{ {52,85},{53,77},{59,82} }) ch:add(c:poly{ {68,85},{67,77},{61,82} })
c:part(ch, P.ember, { band = 3, pop = { x = 55, y = 84 } })
for _, p in ipairs{ {60,81},{58,82},{62,82} } do keep(p[1], p[2], P.ember.deep) keep(p[1], p[2]+1, P.ember.shade) end
for _, p in ipairs{ {54,79},{54,80},{66,79},{66,80} } do keep(p[1], p[2], P.petal.base) end
for _, ex in ipairs{ 55, 63 } do
  c:fillMask(c:rect(ex, 85, ex + 1, 86), P.gold.base) keep(ex, 85, P.gold.hi) c:put(ex, 86, P.ink) c:put(ex + (ex == 55 and 0 or 1), 85, P.ink)
end
c:put(59, 88, P.petal.base) c:put(60, 88, P.petal.shade)
for _, p in ipairs{ {58,89},{59,90},{60,90},{61,89} } do c:put(p[1], p[2], P.ember.deep) end
for _, p in ipairs{ {54,89},{53,88},{66,89},{67,88} } do c:put(p[1], p[2], P.cream) end
-- head
local hcx, hcy = 39.5, 47
local head = c:ellipse(hcx, hcy, 20, 18.5)
c:part(head, P.skinB, { band = 3, pop = { x = 27, y = 41 } })
local face = c:ellipse(39.5, 51, 15.5, 14.5)
local hm = head:copy():cut(face):clip(c:rect(0, 0, 79, 56))
hm:add(c:poly{ {26,40},{30,38},{27,50} }) hm:add(c:poly{ {53,40},{49,38},{52,50} })
hairPaint(hm, HAIR, 39.5, 30, 9, tokH)
-- parting line
for y = 30, 36 do c:put(39 + (y > 33 and 0 or 0), y, HAIR[4], tokH) end
-- bun with needle
local bun = c:ellipse(39.5, 22, 9, 7)
hairPaint(bun, HAIR, 39.5, 22, 7, tokH)
c:line({ {32,24},{47,19} }, 1):clip(bun):each(function(x, y) c:put(x, y, HAIR[4], tokH) end)
c:fillMask(c:line({ {30,17},{50,28} }, 1), P.wood.base)
c:line({ {30,17},{49,27} }, 1):each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, P.wood.hi) end end)
c:part(c:ellipse(30, 16, 2, 2), P.petal, { band = 1, pop = { x = 29, y = 15 } })
-- face
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
for _, p in ipairs{ {28,45},{27,47},{28,49},{51,45},{52,47},{51,49} } do c:put(p[1], p[2], P.skinB.shade) end
for _, x in ipairs{ 31, 33, 46, 48 } do c:put(x, 43, HAIR[3]) end
nose(38, 49, { h = "#f0b07a", n = "#d98a5a", d = "#a85a40", s = "#6a3030" })
c:cheek(28, 52) c:cheek(50, 52)
for _, p in ipairs{ {35,54},{36,55},{37,56},{38,56},{39,56},{40,56},{41,56},{42,56},{43,55},{44,54} } do c:put(p[1], p[2], P.skinB.deep) end
for _, p in ipairs{ {34,53},{45,53},{33,57},{46,57} } do c:put(p[1], p[2], P.skinB.shade) end
c:finish{ outline = true }
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

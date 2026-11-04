-- peach-jam (aC32_3 final, Opus single pass). A slim, tall glass jar (rounded shoulders, narrow neck) of glossy amber
-- peach jam with soft fruit pieces suspended in it; glass shown by a bright cool rim, a pale core streak and a clear
-- headspace band; pink-and-cream gingham cloth cap (6-tone per-pixel light on both check colours, fold lines in the
-- skirt) tied with twisted gold twine and a small bow; cream paper label with a tiny peach. Ground shadow.
-- History: Sonnet draft replaced.
-- quirk: one sticky drip of jam has run down the outside of the glass from under the cloth.
local NAME = "peach-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local JAM   = { "#5a1a2a", "#94283a", "#c84630", "#ea6e2e", "#fb9a40", "#ffc678" }
local GLASS = { "#4a6a8a", "#7aa6c0", "#b4dcea", "#e4f6fa" }
local PINK  = { "#6e2350", "#a63a6c", "#d65a86", "#f07ea0", "#ffa6c0", "#ffcadb" }
local CRM   = { "#8a7a8e", "#b8a8b2", "#dccfcc", "#f2e8dc", "#fff4e2", "#fffaf0" }
local TWINE = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PAPER = { "#a89478", "#d8c6a2", "#f2e6c6", "#fff4d6" }
local PEACH = { "#8e2438", "#d84a34", "#f88a3c", "#ffc070" }

c:groundShadow(32, 56, 13, 2)
-- jar body: slim, rounded shoulders, narrow neck
local CX = 31.5
local function hw(y)
  if y < 24 then return 7.5 end                     -- neck
  if y < 29 then return 7.5 + (y - 24) * 0.75 end   -- shoulder flare
  if y > 52 then return 11 - (y - 52) * 1.2 end     -- rounded base
  return 11
end
local jar = HP.mask()
for y = 21, 55 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do jar:set(x, y) end end
-- jam fill (glass headspace above y 30)
local jam = jar:copy():clip(c:rect(0, 30, 63, 63)):shrink(1)
local glass = jar:copy():cut(jam)
local n = A.body(jar, CX, 40, 12, 5, 0.3)
-- cylinder-ish normal: override horizontally
local nc = {}
jar:each(function(x, y) local s = max(-0.97, min(0.97, (x - CX) / 11.6)) local bn = n[K(x, y)]
  nc[K(x, y)] = { A.norm(s, bn[2] * 0.6, sqrt(1 - s*s)) } end)
local jtok = { r = { name = "jam" } }
local jb = {}
X.ao(jb, jam, c:rect(0, 0, 63, 30), 1, -1)
local jidx, jv = A.shade(c, jam, nc, JAM, { amb = 0.12, wrap = 0.35, bias = jb, tok = jtok })
-- fruit pieces suspended: lighter soft chunks with a dark underside
for _, p in ipairs{ {25, 35}, {35, 38}, {28, 50}, {37, 49}, {24, 44}, {38, 33} } do
  if jam:has(p[1], p[2]) and jam:has(p[1] + 1, p[2] + 1) then
    A.step(c, jidx, JAM, p[1], p[2], 2, jtok) A.step(c, jidx, JAM, p[1] + 1, p[2], 1, jtok)
    A.step(c, jidx, JAM, p[1], p[2] + 1, -1, jtok) A.step(c, jidx, JAM, p[1] + 1, p[2] + 1, -1, jtok)
  end
end
-- glass: headspace + walls; bright cool rim, pale core
local gtok = { r = { name = "glass" } }
glass:each(function(x, y) local s = (x - CX) / 11
  local i = (s < -0.6) and 4 or (s < 0.2) and 3 or (s < 0.7) and 2 or 1
  if y >= 30 then i = (s < 0) and 3 or 1 end
  c:put(x, y, GLASS[i], gtok) end)
-- meniscus line
for x = floor(CX - 9.5), floor(CX + 9.5) do if jam:has(x, 31) then c:put(x, 30, JAM[6], jtok) end end
-- pale core streak (left) and bright rim
for y = 33, 51 do c:put(23, y, GLASS[3], gtok) if y > 35 and y < 46 then c:put(24, y, JAM[6], jtok) end end
c:put(23, 34, GLASS[4], gtok) c:put(23, 35, "#ffffee", gtok)
-- base: thick glass heel
for x = floor(CX - 8), floor(CX + 8) do if jar:has(x, 55) then c:put(x, 55, (x < CX) and GLASS[2] or GLASS[1], gtok) end end
-- label
local lab = c:rrect(25, 38, 38, 47, 1)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) local i = (x < 27 and 4) or (x > 36 and 2) or 3 if y == 47 then i = 2 end c:put(x, y, PAPER[i], ltok) end)
-- label peach + leaf
local pm = c:ellipse(31.5, 43, 2.4, 2.4)
A.shade(c, pm, X.sphere(31.5, 43, 2.4, pm), PEACH, { amb = 0.15, cuts = { 0.3, 0.55, 0.8 }, tok = ltok })
c:put(32, 40, "#47944c", ltok) c:put(33, 39, "#6cb356", ltok) c:put(30, 43, PEACH[4], ltok)
-- handwritten line
for _, x in ipairs{ 27, 28, 30, 34, 35, 36 } do c:put(x, 46, PAPER[1], ltok) end

-- cloth cap: dome over the neck plus a scalloped, folded skirt
local cap = HP.mask():add(c:rrect(20, 13, 43, 23, 5))
for i = 0, 4 do cap:add(c:ellipse(21.5 + i * 5, 25, 2.6, 2.4)) end
cap:cut(c:rect(0, 28, 63, 63))
local cn = X.pillow(cap, 4)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
local cb = {}
cap:each(function(x, y) local k = K(x, y)
  -- skirt folds: vertical dark lines between scallops
  if y > 21 and (x - 19) % 5 == 0 then cb[k] = -1 end
  if y == 21 then cb[k] = (cb[k] or 0) - 1 end              -- AO under the twine
end)
local ptok = { r = { name = "cloth" } }
local pinkm, crm = HP.mask(), HP.mask()
cap:each(function(x, y) if (floor((x - 20) / 3) + floor((y - 13) / 3)) % 2 == 0 then pinkm:set(x, y) else crm:set(x, y) end end)
X.tone(c, pinkm, cv, PINK, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, bias = cb, tok = ptok })
X.tone(c, crm, cv, CRM, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, bias = cb, tok = ptok })
-- weave: faint diagonal on cream checks
crm:each(function(x, y) if (x + y) % 4 == 0 and cv[K(x, y)] > 0.4 then c:put(x, y, CRM[3], ptok) end end)
-- twine: twisted gold band with bow
local ttok = { r = { name = "twine" } }
for x = 20, 43 do if cap:has(x, 20) then c:put(x, 20, ((x % 2 == 0) and TWINE[3] or TWINE[2]), ttok) c:put(x, 21, TWINE[1], ttok) end end
local bow = { {27,18,3},{28,17,4},{29,18,3},{28,19,2},{29,19,2},{30,20,2},{31,20,4},{32,20,2},{33,19,2},{34,19,2},{34,17,4},{35,18,3},{33,18,3},
  {30,22,3},{30,23,2},{29,24,3},{33,22,3},{33,23,2},{34,24,3} }
for _, p in ipairs(bow) do c:put(p[1], p[2], TWINE[p[3]], ttok) end
c:put(28, 18, TWINE[1], ttok) c:put(34, 18, TWINE[1], ttok)
-- quirk: jam drip down the glass from under the cloth (right side)
local dtok = { r = { name = "drip" } }
for y = 28, 34 do c:put(40, y, (y < 33) and JAM[4] or JAM[3], dtok) end
c:put(39, 28, JAM[5], dtok) c:put(40, 35, JAM[3], dtok) c:put(41, 35, JAM[2], dtok) c:put(40, 36, JAM[2], dtok) c:put(40, 29, JAM[6], dtok)
A.save(c, NAME)

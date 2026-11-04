-- koi-pond (final pass, Opus single pass). A small oval garden pond in 3/4 view: a ring of individual beveled rim
-- stones (pillow-lit each, alternating cool and warm grey ramps, dark mortar cracks, a darker front face, moss tufts),
-- deep teal water with the back rim's cast shadow, pale sky streaks and depth, a red-and-white kohaku koi gliding
-- left, a lily pad with a pink bud, and two slim cattails standing behind the back rim. 2-tone ground shadow.
-- quirk: a golden koi has popped its round "o" mouth up through the surface, ringed by ripples, begging for crumbs.
local NAME = "koi-pond"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local ST1 = { "#363650", "#4f526c", "#6c708c", "#8e92a8", "#b4b6c6", "#dadbe4" }
local ST2 = { "#40363e", "#5c4e58", "#7c6c76", "#9e8e96", "#c2b4b8", "#e4dad8" }
local MORTAR = "#2e2a3c"
local MOSS = { "#2c5a3a", "#4a8a44", "#7cba58", "#b0d878" }
local WAT = { "#183050", "#20496a", "#2a6486", "#36809e", "#58a2b6", "#9cd4d4" }
local KOI_W = { "#9a92a0", "#c8c2c4", "#ece6dc", "#fff4d6" }
local KOI_R = { "#a8361e", "#d8562a", "#f47e3a", "#ffaa62" }
local GOLD = { "#8a5a1a", "#c88a24", "#efb83a", "#ffe08a" }
local PAD = { "#24543a", "#3a7a44", "#5ea052", "#94c46a" }
local CAT = { "#3a2418", "#5e3a24", "#84562e", "#a8784a" }
local STEM = { "#2e5a34", "#4a8040", "#78ac58", "#a8d07a" }

-- ground shadow
c:groundShadow(32, 55, 24, 2)

-- cattails behind the back rim
local ctok = { r = { name = "cattail" } }
local function cattail(x0, y0, x1, y1, hx, hy)
  local m, n = A.tube({ { x0, y0 }, { x0 + (x1 - x0) * 0.3, y0 - 6 }, { x1, y1 + 6 }, { x1, y1 } }, function() return 0.7 end)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = ctok })
  local hm, hn = X.cyl(hx, hy, hx + (x1 - x0) * 0.12, hy + 6, function(t) return t < 0.12 and 0.9 or (t > 0.88 and 0.9 or 1.6) end)
  X.tone(c, hm, X.light(hn, { amb = 0.08, wrap = 0.25 }), CAT, { cuts = { 0.25, 0.5, 0.75 }, tok = ctok })
  c:put(hx, hy - 1, STEM[2], ctok) c:put(hx, hy - 2, STEM[3], ctok)
end
cattail(13, 34, 11, 21, 11, 15)
cattail(17, 33, 18, 24, 18, 19)
-- a slim blade leaf curling out to the left
local bm, bn, BT, BS = A.blade(15, 33, 9, 26, 6, 22, function(t) if t > 0.98 then return -1 end return max(0.4, 1.1 * (1 - t)) end, { fold = 0.2 })
A.toneN(c, bm, bn, STEM, { tok = ctok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15 })

-- rim: top surface ring + front face, cut into stones by angle
local CX, CY = 32, 40
local top = HP.ellipse(CX, CY, 25, 11.5)
local face = HP.ellipse(CX, CY + 3, 25, 11.5):cut(top)
face:each(function(x, y) if y < CY then face.s[K(x, y)] = nil end end)
local water = HP.ellipse(CX, CY - 1, 19.5, 7.6)
local rim = top:copy():add(face):cut(water)
local NS = 17
local sid = {}
rim:each(function(x, y)
  local a = atan((y - CY) / 11.5, (x - CX) / 25)
  local f = (a + pi) / (2 * pi) * NS + (X.hash(x // 3, y // 3, 4) - 0.5) * 0.25
  sid[K(x, y)] = floor(f) % NS
end)
local stones = {}
rim:each(function(x, y) local i = sid[K(x, y)] stones[i] = stones[i] or HP.mask() stones[i]:set(x, y) end)
local stok = { r = { name = "rim" } }
local wbias = {}
for i = 0, NS - 1 do local m = stones[i] if m then
  local core = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local cut = false
    for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do local q = K(x + d[1], y + d[2]) if sid[q] and sid[q] ~= i then cut = true end end
    if not cut then core:set(x, y) end end)
  local n = X.pillow(core, 2.2)
  local b = {}
  core:each(function(x, y) if face:has(x, y) then b[K(x, y)] = -2 end end)
  local R = (i % 2 == 0) and ST1 or ST2
  local idx = A.shade(c, core, n, R, { bias = b, tok = stok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- grain: a pale fleck and a dark pit per stone
  local cnt = 0
  core:each(function(x, y) local k = K(x, y) cnt = cnt + 1
    if (idx[k] or 1) >= 4 and X.hash(x, y, i) > 0.93 then c:put(x, y, R[6], stok) end
    if (idx[k] or 1) == 3 and X.hash(x, y, i + 9) > 0.94 then c:put(x, y, R[2], stok) end end)
  m:each(function(x, y) if not core:has(x, y) then c:put(x, y, MORTAR, stok) end end)
end end
-- moss tufts on two stones (front-left and right)
for _, q in ipairs{ { 14, 46 }, { 15, 46 }, { 13, 47 }, { 16, 47 }, { 14, 47 }, { 50, 44 }, { 51, 44 }, { 52, 45 }, { 51, 45 } } do
  c:put(q[1], q[2], MOSS[((q[1] + q[2]) % 3) + 1], stok) end
c:put(14, 45, MOSS[4], stok) c:put(51, 43, MOSS[4], stok)

-- water: cast shadow along the back inner edge, depth, sky streaks
local wtok = { r = { name = "water" } }
water:each(function(x, y)
  local d = 0 while water:has(x, y - d - 1) do d = d + 1 end   -- rows below the back edge
  local i = 3
  if d < 1 then i = 1 elseif d < 3 then i = 2 end
  if y >= CY + 3 then i = 4 end
  local e = (x - CX) / 19.5
  if abs(e) > 0.86 and i > 2 then i = i - 1 end
  c:put(x, y, WAT[i], wtok)
end)
for _, s in ipairs{ { 20, 36, 4 }, { 27, 44, 6 }, { 44, 41, 3 }, { 37, 35, 3 } } do
  for x = s[1], s[1] + s[3] - 1 do if water:has(x, s[2]) then c:put(x, s[2], WAT[5], wtok) end end
end
c:put(28, 44, WAT[6], wtok) c:put(29, 44, WAT[6], wtok)

-- lily pad + bud (right side)
local ptok = { r = { name = "pad" } }
local pm = HP.ellipse(45, 36, 4.2, 1.8)
pm:each(function(x, y) if x > 45 and x < 49 and abs(y - 35.4 - (x - 45) * 0.15) < 0.6 then pm.s[K(x, y)] = nil end end)
pm:each(function(x, y) local i = (y < 36) and 3 or 2 if x < 43 and y <= 36 then i = 4 end if y > 36 then i = 1 end c:put(x, y, PAD[i], ptok) end)
for _, q in ipairs{ { 44, 34, "#f5809f" }, { 45, 34, "#ffc4d8" }, { 44, 33, "#ffc4d8" }, { 43, 34, "#c94f84" }, { 44, 35, "#c94f84" } } do c:put(q[1], q[2], q[3], ptok) end

-- kohaku koi gliding left (seen through the surface)
local ktok = { r = { name = "koi" } }
local km, kn = A.oval(23, 39, 5.2, 1.7, 0.12, 0.7)
local kidx = A.shade(c, km, kn, KOI_W, { tok = ktok, amb = 0.25, wrap = 0.3, cuts = { 0.3, 0.6, 0.88 } })
km:each(function(x, y) local k = K(x, y)
  if (x <= 21 and x >= 18) or (x >= 24 and x <= 26 and y <= 39) then c:put(x, y, KOI_R[min(4, (kidx[k] or 2) + 1)], ktok) end end)
c:put(19, 38, "#2b1c26", ktok)
-- tail fan
for _, q in ipairs{ { 29, 39, 2 }, { 30, 38, 3 }, { 30, 40, 2 }, { 31, 38, 3 }, { 31, 41, 1 }, { 30, 39, 2 } } do c:put(q[1], q[2], KOI_W[q[3]], ktok) end
c:put(22, 41, KOI_W[2], ktok) c:put(24, 37, KOI_R[2], ktok)

-- quirk: golden koi mouth up through the surface, ripple rings
local GX, GY = 38, 42
for _, r in ipairs{ { 6, 2.2 } } do
  for a = 0, 63 do local t = a / 64 * 2 * pi
    local x, y = floor(GX + cos(t) * r[1] + .5), floor(GY + 0.5 + sin(t) * r[2] + .5)
    if water:has(x, y) and (a % 8) < 6 then c:put(x, y, WAT[6], wtok) end end
end
local gm = HP.ellipse(GX, GY, 2.2, 1.8)
local gn = X.sphere(GX - 0.3, GY - 0.5, 2.4, gm)
A.shade(c, gm, gn, GOLD, { tok = ktok, amb = 0.1, wrap = 0.25, cuts = { 0.3, 0.55, 0.8 } })
-- the round open mouth on top + two eyes on the sides
c:put(GX, GY - 1, "#2b1c26", ktok) c:put(GX - 1, GY - 1, GOLD[2], ktok) c:put(GX + 1, GY - 1, GOLD[2], ktok)
c:put(GX, GY - 2, GOLD[3], ktok) c:put(GX - 1, GY - 2, GOLD[4], ktok)
c:put(GX - 2, GY, "#2b1c26", ktok) c:put(GX + 2, GY, "#2b1c26", ktok)
c:put(GX - 1, GY + 1, GOLD[4], ktok)

A.save(c, NAME)

-- buckwheat-kasha (final, Opus aB13_2 single pass). A shallow cobalt-glazed bowl heaped with toasted buckwheat
-- kasha: every groat a small faceted grain (lit corner + dark seam), dome-lit as one mound; a cream glazed rim lip,
-- glaze specular streak, cream wave band, unglazed clay foot; a slim birch spoon stuck in the heap (grain lines,
-- paler end) with AO where it enters; 2-tone ground shadow.
-- quirk: the butter pat on top is melting and one golden drip runs over the rim.
local NAME = "buckwheat-kasha"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLAZE = { "#1c2150", "#283a7c", "#3456a6", "#4a78c8", "#74a2e0", "#b4d6f4" }
local LIP   = { "#7e7aa0", "#b0aac0", "#d8d0d2", "#efe6d8", "#fff4e2" }
local KASHA = { "#3a2020", "#5a3024", "#7c4628", "#a06232", "#c4864a", "#e2ae72" }
local WOOD  = { "#51302b", "#7a4c33", "#a8764a", "#cfa070", "#ead0a0", "#f8e8c4" }
local BUT   = { "#c98a1e", "#efbc34", "#ffe066", "#fff4b8" }
local CLAY  = { "#4a2e2a", "#6e4434", "#8f5c42", "#b07a56", "#cc9c74", "#e6c29c" }
local CX, RY0, RX, RRY = 31.5, 33, 20, 4.5     -- rim ellipse

c:groundShadow(32, 52, 15, 2)

-- foot ring
local foot = c:rect(24, 48, 39, 50)
A.vcyl(c, foot, CLAY, 24, 39)
-- bowl body: below rim, half-width tapering to the foot
local BOT = 48
local function hw(y) local t = (y - RY0) / (BOT - RY0) return RX * (1 - t ^ 2.2) ^ 0.55 + (1 - t) * 0 + t * 7 * 0 end
local body, bn = HP.mask(), {}
for y = RY0, BOT do local h = max(7.5, hw(y))
  for x = floor(CX - h + 0.5), floor(CX + h + 0.5) - 1 do body:set(x, y)
    local nx = max(-0.95, min(0.95, (x + 0.5 - CX) / h))
    local ny = 0.15 + 0.55 * (y - RY0) / (BOT - RY0)
    bn[K(x, y)] = { A.norm(nx, ny, sqrt(max(0.05, 1 - nx * nx))) }
  end end
local rimE = c:ellipse(CX, RY0, RX, RRY)
body:cut(rimE)
local gidx = A.shade(c, body, bn, GLAZE, { amb = 0.08, wrap = 0.25, tok = { r = { name = "glaze" } } })
-- cream wave band
for x = floor(CX - RX) + 3, floor(CX + RX) - 3 do
  local y = 40 + ((x // 3) % 2)
  if body:has(x, y) then c:put(x, y, (gidx[K(x, y)] or 3) >= 3 and LIP[4] or LIP[2], { r = { name = "glaze" } }) end
end
-- glaze specular streak + cool bounce
for _, p in ipairs{ { 17, 36 }, { 18, 37 }, { 18, 38 }, { 19, 39 } } do c:px(p[1], p[2], GLAZE[6]) end
c:px(17, 37, "#e8f4ff")
body:edge():each(function(x, y) if x > CX + 6 and y > 38 and y < 46 then c:px(x, y, "#5a6ec0") end end)

-- rim lip (front half of the ring), drawn after body
local inner = c:ellipse(CX, RY0 - 0.5, RX - 1.5, RRY - 1.2)
local lip = rimE:copy():cut(inner)
lip:each(function(x, y)
  local front = y >= RY0
  local i = front and ((x < CX) and 5 or 3) or 2
  if front and y >= RY0 + RRY - 0.5 then i = i - 1 end
  c:put(x, y, LIP[max(1, i)], { r = { name = "lip" } })
end)

-- kasha mound: dome above the opening, front edge hidden by the lip
local mound = c:ellipse(CX, 30, 17.5, 9):add(inner)
local flip = HP.mask() lip:each(function(x, y) if y >= RY0 then flip:set(x, y) end end)
mound:cut(flip)
local keep = HP.mask()
mound:each(function(x, y) if y <= RY0 + 1 then keep:set(x, y) end end)
mound = keep
local mn = X.sphere(CX - 1, 32, 18, mound)
local mv = X.light(mn, { amb = 0.08, wrap = 0.25 })
local bias = {}
X.ao(bias, mound, flip, 1, -1)
-- grains: staggered 3x2 cells; seam pixel dark, lit corner bright
mound:each(function(x, y) local k = K(x, y)
  local row = y
  local cx = (x + (row % 2) * 2) % 4
  if cx == 3 then bias[k] = (bias[k] or 0) - 1
  elseif cx == 0 and X.hash(x, y, 7) > 0.45 then bias[k] = (bias[k] or 0) + 1 end
  if X.hash(x, y, 3) > 0.93 then bias[k] = (bias[k] or 0) - 1 end
end)
local kidx = X.tone(c, mound, mv, KASHA, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = { r = { name = "kasha" } } })
-- loose groats on the crest (bumpy silhouette)
for _, p in ipairs{ { 20, 23 }, { 25, 20 }, { 36, 20 }, { 42, 23 }, { 46, 26 } } do
  c:put(p[1], p[2], KASHA[4], { r = { name = "kasha" } }) c:put(p[1] + 1, p[2], KASHA[3], { r = { name = "kasha" } }) end

-- spoon: slim birch handle from heap up-right, AO at entry
local spoonTok = { r = { name = "spoon" } }
local sm, _, ST, SS = A.stem(c, { { 39, 27 }, { 43, 21 }, { 48, 15 }, { 52, 9 } }, function(t) return 1.5 - t * 0.2 end, WOOD, { tok = spoonTok })
sm:each(function(x, y) local k = K(x, y)
  if abs(SS[k]) < 0.2 and ST[k] > 0.25 and (floor(ST[k] * 30) % 4 == 0) then c:put(x, y, WOOD[3], spoonTok) end -- grain
  if ST[k] > 0.94 then c:put(x, y, WOOD[6], spoonTok) end                                                         -- pale end grain
end)
for _, p in ipairs{ { 37, 28 }, { 38, 29 }, { 40, 29 }, { 41, 28 }, { 36, 27 } } do if mound:has(p[1], p[2]) then c:px(p[1], p[2], KASHA[1]) end end

-- quirk: butter pat (rhombus) melting, drip over the front rim
local butter = c:poly{ { 26, 24 }, { 32, 22 }, { 36, 25 }, { 30, 27 } }
butter:each(function(x, y)
  local i = (y <= 23 or x < 29) and 4 or 3
  if y >= 26 or x >= 35 then i = 2 end
  c:put(x, y, BUT[i], { r = { name = "butter" } })
end)
c:px(29, 23, "#fffbe8") c:px(30, 23, "#fffbe8")
-- melt pool + drip
for _, p in ipairs{ { 29, 28, 3 }, { 30, 28, 2 }, { 31, 28, 3 }, { 30, 29, 2 }, { 30, 30, 3 }, { 30, 31, 2 }, { 30, 32, 3 }, { 30, 33, 2 }, { 30, 34, 3 }, { 30, 35, 2 }, { 30, 36, 1 } } do
  c:put(p[1], p[2], BUT[p[3]], { r = { name = "butter" } }) end
c:px(31, 34, BUT[1])

A.save(c, NAME)

-- feast-summer-table (B30, Opus single pass). A picnic spread on the grass: a gingham blanket in perspective
-- (cream / pink / red weave checks, one soft diagonal wrinkle, front hem thickness) with its front-right corner
-- flipped up to show the plain underside. On it: a half-moon watermelon slice standing on its rind (striped rind,
-- pale band, seeds), a tall glass of lemonade (bright rim, pale core, ice cube, lemon wheel, striped straw) and
-- a pair of glossy cherries. Ambient/contact shadow on the cloth under everything.
-- quirk: somebody already took a bite out of the watermelon.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = G.new("feast-summer-table")
local CR = { "#c9a98f", "#efdcbc", "#fff4d6" }   -- dark, base, lit
local PK = { "#c4646a", "#ef8f88", "#ffb6a6" }
local RD = { "#8e2238", "#c8343e", "#e8493b" }
local RIND = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local FLESH = { "#7d1e3a", "#b02a40", "#dc3c48", "#f05a5a", "#ff8a7a", "#ffc0aa" }
local LEM = { "#9a6a1e", "#c8922a", "#e8b83c", "#f6d460", "#fde88e", "#fff6c8" }
local CHE = { "#4a0e24", "#7a1630", "#b0223a", "#d83a44", "#f2705e", "#ffb08a" }
local INK2 = "#3a1a26"
local CREAM = "#fff4d6"

-- blanket quad
local TLx, TRx, BLx, BRx, Y0, Y1 = 13, 52, 7, 57, 31, 49
local function xl(y) return TLx + (BLx - TLx) * (y - Y0) / (Y1 - Y0) end
local function xr(y) return TRx + (BRx - TRx) * (y - Y0) / (Y1 - Y0) end
-- fold line for the flipped corner: A on the bottom edge, B on the right edge
local Ax, Ay, Bx, By = 45, Y1, xr(41), 41
local function side(x, y) return (Bx - Ax) * (y - Ay) - (By - Ay) * (x - Ax) end
local sBR = side(BRx, Y1)
local cloth = HP.mask()
for y = Y0, Y1 do for x = floor(xl(y)), math.ceil(xr(y)) do
  if x + .5 >= xl(y) and x + .5 <= xr(y) + 0.5 and not (side(x + .5, y + .5) * sBR > 0) then cloth:set(x, y) end
end end
local hem = cloth:shift(0, 1):cut(cloth)
local function cls(x, y)
  local v = (y + .5 - Y0) / (Y1 - Y0)
  local u = (x + .5 - xl(y)) / (xr(y) - xl(y))
  local a = floor(u * 12) % 2 == 1
  local b = floor((v ^ 0.85) * 5) % 2 == 1
  if a and b then return RD elseif a or b then return PK else return CR end
end
local tone = {}
cloth:each(function(x, y)
  local t = 2
  -- soft diagonal wrinkle: lit ridge, shaded far side
  local d = (x - 22) - (y - 31) * 0.55
  if d > -1.5 and d <= 0 then t = 3 elseif d > 0 and d <= 1.5 then t = 1 end
  if y == Y0 then t = 1 end
  tone[K(x, y)] = t
  c:put(x, y, cls(x, y)[t], { r = { name = "cloth" } })
end)
hem:each(function(x, y) c:put(x, y, cls(x, y - 1)[1]) end)
local function shadeCloth(m)
  m:each(function(x, y) if cloth:has(x, y) then c:put(x, y, cls(x, y)[1], c.own[y * c.w + x]) end end)
end
-- flipped corner (underside shows: plain cream, faint check ghost)
local function refl(px, py)
  local dx, dy = Bx - Ax, By - Ay
  local l2 = dx * dx + dy * dy
  local t = ((px - Ax) * dx + (py - Ay) * dy) / l2
  local fx, fy = Ax + t * dx, Ay + t * dy
  return 2 * fx - px, 2 * fy - py
end
local rx, ry = refl(BRx, Y1)
local flap = HP.poly{ { Ax, Ay + 0.5 }, { Bx + 0.5, By }, { rx, ry } }
shadeCloth(flap:copy():shift(-1, 1))
local FL = { "#d9b9a0", "#f2dcc4", "#fff1dc" }
flap:each(function(x, y)
  local d = abs(side(x + .5, y + .5)) / sqrt((Bx - Ax) ^ 2 + (By - Ay) ^ 2)
  local col = FL[2]
  if d < 1.2 then col = FL[3] elseif x > rx - 3 then col = FL[1] end
  c:put(x, y, col, { r = { name = "flap" } })
end)

-- watermelon half-moon standing on its rind (with a back face for thickness)
local MX, MY, MR = 20, 38, 10.5
local function slice(ox, oy)
  local m = HP.mask()
  for y = MY + oy, MY + oy + 11 do for x = MX + ox - 12, MX + ox + 12 do
    local dx, dy = x + .5 - (MX + ox + .5), y + .5 - (MY + oy)
    if dy >= 0 and dx * dx + dy * dy <= MR * MR then m:set(x, y) end
  end end
  return m
end
local back = slice(2, -1)
local front = slice(0, 0)
local bite = HP.ellipse(25, 38, 2.4, 2.2):add(HP.ellipse(28.5, 38, 2, 1.8))
front:cut(bite) back:cut(bite:shift(2, -1))
shadeCloth(front:copy():add(back):shift(1, 1):grow(1))
back:copy():cut(front):each(function(x, y)
  local dx, dy = x + .5 - (MX + 2.5), y + .5 - (MY - 1)
  local r = sqrt(dx * dx + dy * dy)
  if dy < 1.2 then c:put(x, y, FLESH[3]) else c:put(x, y, r > MR - 1.6 and RIND[1] or RIND[2]) end
end)
front:each(function(x, y)
  local dx, dy = x + .5 - (MX + .5), y + .5 - MY
  local r = sqrt(dx * dx + dy * dy)
  local ang = atan(dy, dx)
  local col
  if r > MR - 1.7 then
    local stripe = floor(ang * 7) % 2 == 0
    local i = stripe and 2 or 4
    if dx > 4 then i = i - 1 end
    if dx < -5 and dy < 6 then i = i + 1 end
    col = RIND[max(1, i)]
  elseif r > MR - 2.7 then col = dx < -3 and "#e8f6c4" or "#c8e6a0"
  else
    local i = 4
    if dy < 1 then i = 5 end
    if r > MR - 3.7 then i = 3 end
    if dx > 4 and dy > 3 then i = 3 end
    col = FLESH[i]
  end
  c:put(x, y, col, { r = { name = "melon" } })
end)
-- fresh bite edge
bite:grow(1):cut(bite):each(function(x, y) if front:has(x, y) then c:put(x, y, FLESH[6]) end end)
-- seeds
for _, p in ipairs{ { 15, 41 }, { 19, 43 }, { 23, 42 }, { 12, 39 }, { 20, 40 } } do
  c:put(p[1], p[2], INK2) c:put(p[1], p[2] + 1, "#5a2a2a") end
c:put(14, 39, FLESH[6]) c:put(15, 39, CREAM)

-- cherries (front centre)
local function cherry(cx, cy)
  local m = HP.ellipse(cx, cy, 2.2, 2.2)
  shadeCloth(HP.ellipse(cx + 1, cy + 2, 2.5, 1.2):cut(m))
  G.shade(c, m, X.sphere(cx - .4, cy - .4, 2.2, m), CHE, { amb = 0.08 })
  c:put(cx - 1, cy - 1, CREAM)
  return m
end
cherry(34, 45) cherry(39, 46)
for _, p in ipairs{ { 34, 42 }, { 35, 41 }, { 36, 40 }, { 37, 39 }, { 38, 40 }, { 38, 41 }, { 39, 42 }, { 39, 43 } } do c:put(p[1], p[2], "#3f7a3a") end
c:put(36, 39, "#3f7a3a") c:put(37, 38, "#5ea64a") c:put(38, 38, "#86c45e") c:put(39, 37, "#5ea64a")

-- lemonade glass
local gx0, gx1, gy0, gy1 = 41, 48, 17, 40
local glass = HP.rect(gx0, gy0, gx1, gy1 - 1):add(HP.ellipse((gx0 + gx1) / 2, gy1 - 1, 4, 1))
shadeCloth(HP.ellipse((gx0 + gx1) / 2 + 2, gy1 + 1, 5, 1.2):cut(glass))
local LIQ = 22
local gn = G.vcylN(glass, gx0, gx1)
local gv = X.light(gn, { amb = 0.1, wrap = 0.3 })
glass:each(function(x, y)
  local k = K(x, y)
  local i = 1
  for j, tt in ipairs(G.CUTS) do if gv[k] >= tt then i = j + 1 end end
  local col
  if y >= gy1 - 2 then col = (x == gx0 + 1) and "#f4fbff" or (x >= gx1 - 1 and "#7fa6c0" or "#b6dbe6")
  elseif y < LIQ then col = (x == gx0 or x == gx0 + 1) and "#f4fbff" or (x >= gx1 - 1 and "#9cc0d6" or "#dff2f6")
  else col = LEM[i] end
  if x == gx0 + 1 and y >= LIQ and y < gy1 - 2 then col = LEM[6] end
  if x == gx0 and y >= LIQ then col = "#f4fbff" end
  if x == gx1 and y >= LIQ then col = "#c8922a" end
  c:put(x, y, col, { r = { name = "glass" } })
end)
for x = gx0, gx1 do c:put(x, LIQ, (x < gx0 + 4) and LEM[6] or LEM[5]) end
for x = gx0, gx1 do c:put(x, gy0, (x < gx1 - 1) and "#f4fbff" or "#b6dbe6") end
-- bubbles + ice cube
c:put(45, 33, LEM[6]) c:put(44, 29, LEM[6]) c:put(46, 36, LEM[6])
for y = 23, 25 do for x = 44, 46 do c:put(x, y, (x == 44 or y == 23) and "#f4fbff" or "#cfeef2") end end
-- lemon wheel on the rim (left)
local lw = HP.ellipse(40, 18, 2.6, 2.6)
lw:each(function(x, y)
  local r = sqrt((x - 40) ^ 2 + (y - 18) ^ 2)
  c:put(x, y, r > 2.2 and LEM[3] or (r > 1.6 and LEM[6] or ((x + y) % 2 == 0 and LEM[4] or LEM[5])), { r = { name = "lemon" } })
end)
c:put(40, 18, LEM[6])
-- striped straw
local sx, sy = 46, 21
for i = 0, 9 do
  local x, y = sx + floor(i * 0.45 + .5), sy - i
  local col = (i // 2) % 2 == 0 and "#e8493b" or CREAM
  c:put(x, y, col, { r = { name = "straw" } })
  c:put(x + 1, y, (i // 2) % 2 == 0 and "#b52e3f" or "#e8d8c0", { r = { name = "straw" } })
end

G.save(c, "feast-summer-table")

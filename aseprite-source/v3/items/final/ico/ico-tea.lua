-- ico-tea (final, Opus). A slim-walled glazed teacup in 3/4 view on its saucer: sea-blue glaze body with a cream
-- porcelain rim band and a gold line, a looped handle, amber tea inside, one bold steam curl.
-- Material: per-pixel lit vertical bowl (6-tone glaze, cool-violet shade), glossy specular streak + glint, cool
-- reflected light on the right edge, bevelled lit rim, flat tea surface with a dark back edge (ambient under the far
-- wall) and a bright window reflection; dished saucer (well, sloped rim, rolled lip) with a contact shadow under the
-- foot; ambient dark where the handle meets the body.
-- quirk: a single tea stalk floats upright in the tea (folklore: a visitor is coming).
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_1.lua")
local HP, X, K = R.HP, R.X, R.K
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
local c = R.new("ico-tea")
local CER  = { "#4b3a5c", "#7d6b93", "#b3a7c4", "#ddd6e0", "#f4ecdc", "#fff8e4" }
local GLZ  = { "#21305e", "#2a5590", "#357fb2", "#4fabcc", "#80d0d6", "#c2efe4" }
local TEA  = { "#4a1d1a", "#7a321f", "#a8521f", "#cf7a2a", "#eaa44a", "#ffd47e" }
local GOLD = { "#8f4a1f", "#b8661f", "#d98322", "#f5b82e", "#ffd45a", "#ffe9a0" }
local STEAM = { "#9fb2d6", "#c9d6ea", "#e6eef4", "#f8f6ec" }
local CX = 30

c:groundShadow(CX + 1, 55, 23, 2)
-- saucer: dished (flat well, inward-sloped rim, rolled lip)
local sau = c:ellipse(CX, 51, 22, 4.5)
local sn = {}
sau:each(function(x, y)
  local dx, dy = (x - CX) / 22.5, (y - 51) / 5
  local r = sqrt(dx*dx + dy*dy)
  local nx, ny, nz
  if r < 0.55 then nx, ny, nz = 0, -0.1, 1
  elseif r < 0.86 then nx, ny, nz = R.norm(-dx * 0.7, -dy * 0.9, 1)
  else nx, ny, nz = R.norm(dx * 0.9, dy * 1.4, 0.55) end
  sn[K(x, y)] = { nx, ny, nz }
end)
local sbias = {}
local stok
local sidx
sidx, _, stok = R.shade(c, sau, sn, CER, { amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })

-- handle (torus loop on the right), painted before the body so the body overlaps the joins
local HX, HY, RO, RI = CX + 17, 37, 7.2, 3.4
local hm, hn, hb = HP.mask(), {}, {}
for y = HY - 9, HY + 9 do for x = HX - 9, HX + 9 do
  local dx, dy = x - HX, y - HY
  local d = sqrt(dx*dx + dy*dy)
  if d <= RO and d >= RI and x >= CX + 12 then
    hm:set(x, y)
    local rc, w = (RO + RI) / 2, (RO - RI) / 2 + 0.4
    local s = max(-0.95, min(0.95, (d - rc) / w))
    local ux, uy = dx / max(d, 0.01), dy / max(d, 0.01)
    hn[K(x, y)] = { R.norm(ux * s, uy * s, sqrt(1 - s*s)) }
  end
end end

-- cup body: bowl that narrows to the foot
local TOP, BOT = 29, 46
local function hw(y) local t = (y - TOP) / (BOT - TOP) return 15.6 - 5.4 * t ^ 2.1 end
local body, bn, BT = HP.mask(), {}, {}
for y = TOP, BOT + 1 do
  local w = y <= BOT and hw(y) or hw(BOT) - 1.5
  for x = floor(CX - w + .5), floor(CX + w + .5) do
    body:set(x, y)
    local t = (min(y, BOT) - TOP) / (BOT - TOP)
    local s = max(-0.96, min(0.96, (x - CX) / (w + 0.5)))
    bn[K(x, y)] = { R.norm(s, 0.15 + 0.55 * t ^ 1.6, sqrt(1 - s*s)) }
    BT[K(x, y)] = { t, s }
  end
end
-- foot ring
local foot = c:rect(CX - 8, BOT + 1, CX + 8, BOT + 3)
foot:cut(body)
local fn = {}
foot:each(function(x, y) local s = (x - CX) / 9 fn[K(x, y)] = { R.norm(s, 0.2, sqrt(1 - s*s)) } end)
-- contact shadow on the saucer around the foot
for x = CX - 11, CX + 12 do for y = BOT + 2, BOT + 5 do
  if sau:has(x, y) and not foot:has(x, y) and abs(x - CX - 1) <= 11 - (y - BOT - 2) then R.step(c, sidx, CER, x, y, -2, stok) end
end end
R.shade(c, foot, fn, CER, { amb = 0.05, wrap = 0.2, bias = {} })

-- handle tone (AO near the body)
local hbias = {}
X.ao(hbias, hm, body, 2, -1)
local hidx, _, htok = R.shade(c, hm, hn, GLZ, { amb = 0.1, wrap = 0.3, bias = hbias })
-- body tone
local bbias = {}
local bidx, _, btok = R.shade(c, body, bn, GLZ, { amb = 0.08, wrap = 0.28 })
local BAND0, BAND1 = TOP, TOP + 4
-- cream porcelain band at the top + gold line, same lighting
local v = X.light(bn, { amb = 0.18, wrap = 0.3 })
body:each(function(x, y)
  local k = K(x, y)
  if y <= BAND1 then
    local i = 1 local val = v[k]
    for j, t in ipairs(R.CUTS) do if val >= t then i = j + 1 end end
    c:put(x, y, CER[max(2, i)], btok)
  elseif y == BAND1 + 1 then
    local i = 1 local val = v[k]
    for j, t in ipairs(R.CUTS) do if val >= t then i = j + 1 end end
    c:put(x, y, GOLD[max(2, i)], btok)
  end
end)
-- specular streak + glint on the glaze (left of centre), cool bounce on the right edge
for y = BAND1 + 3, BOT - 4 do
  local w = hw(y) local x = floor(CX - w * 0.52 + .5)
  c:put(x, y, GLZ[6], btok)
  if y <= BAND1 + 6 then c:put(x + 1, y, GLZ[6], btok) end
end
c:put(floor(CX - hw(BAND1 + 3) * 0.52 + .5), BAND1 + 3, R.CREAM, btok)
for y = BAND1 + 3, BOT - 1 do
  local x = floor(CX + hw(y) + .5) - 1
  if bidx[K(x, y)] and bidx[K(x, y)] <= 2 then c:put(x, y, GLZ[3], btok) end
end
-- darker underside row where the bowl turns to the foot
for x = CX - 11, CX + 11 do if body:has(x, BOT + 1) then c:put(x, BOT + 1, GLZ[1], btok) end end

-- rim and opening (ellipse sitting on the top row)
local OY = TOP - 0.5
local rimO = c:ellipse(CX, OY, 15.6, 4)
local rimI = c:ellipse(CX, OY + 0.4, 14, 3)
local ring = rimO:copy():cut(rimI)
local rtok = { r = { name = "rim" } }
ring:each(function(x, y)
  local hiSide = (y < OY) or (x < CX - 9)
  local col = CER[5]
  if y < OY then col = (x < CX + 6) and CER[6] or CER[5] else col = (x < CX) and CER[5] or CER[4] end
  c:put(x, y, col, rtok)
end)
-- inner far wall (shaded) and tea surface
local tokI = { r = { name = "inner" } }
rimI:each(function(x, y) c:put(x, y, y < OY - 0.5 and CER[3] or CER[2], tokI) end)
local tea = c:ellipse(CX, OY + 1.2, 12.6, 2.2)
tea:clip(rimI)
local ttok = { r = { name = "tea" } }
tea:each(function(x, y)
  local col = TEA[4]
  if not tea:has(x, y - 1) then col = TEA[2] end                 -- dark back edge (shadow of the far wall)
  if not tea:has(x, y + 1) and x > CX + 3 then col = TEA[3] end
  c:put(x, y, col, ttok)
end)
-- window reflection on the tea
for x = CX - 9, CX - 5 do if tea:has(x, floor(OY + 1)) then c:put(x, floor(OY + 1), TEA[6], ttok) end end
c:put(CX - 4, floor(OY + 1), TEA[5], ttok)
c:put(CX + 4, floor(OY + 2), TEA[5], ttok) c:put(CX + 5, floor(OY + 2), TEA[5], ttok)

-- quirk: an upright tea stalk floating in the tea (2 px wide, ripple ring at its foot)
local SX, SY = CX + 7, floor(OY) - 3
local STK = { "#3e5a2a", "#6f8a3a", "#a8b85a" }
for y = SY, SY + 3 do c:put(SX, y, STK[3]) c:put(SX + 1, y, STK[2]) end
c:put(SX, SY - 1, STK[2]) c:put(SX + 1, SY + 3, STK[1])
c:put(SX - 1, SY + 4, TEA[6]) c:put(SX + 2, SY + 4, TEA[5])

-- steam: one bold S curl rising from the tea
local stTok = { r = { name = "steam" } }
local Y0, Y1 = floor(OY) - 3, floor(OY) - 23
for y = Y0, Y1, -1 do
  local f = (Y0 - y) / (Y0 - Y1)
  local xc = CX - 2 + 5 * math.sin(f * 2 * math.pi * 1.15 + 0.3) * (0.55 + 0.45 * f)
  local w = f > 0.85 and 1 or 2
  for x = floor(xc - w / 2 + .5), floor(xc - w / 2 + .5) + w do
    if not rimO:has(x, y) then
      local rel = x - floor(xc - w / 2 + .5)
      local col = rel == 0 and STEAM[4] or (rel == w and STEAM[2] or STEAM[3])
      if f < 0.12 then col = rel == 0 and STEAM[3] or STEAM[1] end
      c:put(x, y, col, stTok)
    end
  end
end
R.save(c, "ico-tea")

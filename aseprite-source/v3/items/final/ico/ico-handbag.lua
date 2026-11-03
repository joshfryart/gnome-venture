-- ico-handbag (final, Opus). A slim, upright leather handbag: a tapered body (narrow top, wider base, rounded foot),
-- a rose flap with a curved point over the front, a gold turn-lock clasp at its tip, and a tall arched bamboo handle
-- held by two small gold rings.
-- Material: leather = pillow-bevel per-pixel light on 6-tone ramps (pink body, rose flap) with fine pore grain, a
-- gold saddle stitch along the flap edge, a contact shadow under the flap and AO at the top seam. Bamboo = per-pixel
-- tube light on a 6-tone ramp with raised node rings (dark groove + lit lip). Metal = bright bevel, dark slot, glint.
-- quirk: a little daisy has been tucked in under the flap and pokes out on the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.atan, math.pi
local c = A.new("ico-handbag")
local BODY = { "#4e1840", "#82285a", "#b83f74", "#e0629a", "#f590b6", "#ffc0d6" }
local FLAP = { "#4e1430", "#80203a", "#b42f44", "#de4a4c", "#f47660", "#ffa486" }
local BAM  = { "#4a2a24", "#7a4630", "#ae7444", "#d29e5e", "#e9c37e", "#f8e1a8" }
local GOLD = { "#6e3a1a", "#a8601e", "#d99022", "#f5bc2e", "#ffde6a", "#fff4c0" }
local CR = "#fff4d6"
local btok, ftok, htok, gtok, dtok = A.tok("body"), A.tok("flap"), A.tok("bamboo"), A.tok("gold"), A.tok("daisy")

local CX = 32
local TOP, BOT = 28, 53
local function hw(y) return 12.5 + (y - TOP) * 0.17 end

-- handle: tall arch (ellipse ring) from the top of the body, painted first so the body covers its feet
local HX, HY, HRX, HRY, HT = CX, TOP + 1, 10, 17, 1.6
local hm = HP.mask()
local hs = {}
for y = HY - HRY - 3, HY do for x = HX - HRX - 3, HX + HRX + 3 do
  local dx, dy = (x - HX) / HRX, (y - HY) / HRY
  local r = sqrt(dx * dx + dy * dy)
  local rr = (HRX + HRY) / 2
  local s = (r - 1) * rr / HT
  if abs(s) <= 1.0 then hm:set(x, y) hs[K(x, y)] = { s, dx / max(r, 1e-3), dy / max(r, 1e-3) } end
end end
-- trim a lone 1-2 px nub on the crown of the arch
do local _, y0 = hm:bbox() local cnt = 0
  for x = 0, 63 do if hm:has(x, y0) then cnt = cnt + 1 end end
  if cnt < 3 then for x = 0, 63 do if hm:has(x, y0) then hm.s[K(x, y0)] = nil end end end end
local hn = {}
hm:each(function(x, y) local q = hs[K(x, y)]
  local s = max(-0.95, min(0.95, q[1]))
  hn[K(x, y)] = { A.norm(q[2] * s, q[3] * s, sqrt(1 - s * s)) } end)
local hidx = A.shade(c, hm, hn, BAM, { tok = htok, amb = 0.08, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- bamboo nodes: raised rings across the tube every ~0.42 rad
for _, ang in ipairs{ -2.55, -2.0, -1.45, -0.95, -0.45 } do
  local ux, uy = cos(ang), sin(ang)
  hm:each(function(x, y)
    local dx, dy = (x - HX) / HRX, (y - HY) / HRY
    local a = atan(dy, dx)
    local d = (a - ang) * 14
    if d > -0.5 and d < 0.5 then A.step(c, hidx, BAM, x, y, -2, htok)
    elseif d >= 0.5 and d < 1.5 then A.step(c, hidx, BAM, x, y, 2, htok) end
  end)
end

-- quirk: daisy tucked under the flap on the right (stem first, flap covers its foot)
local stem = A.seg(42, 33, 47, 21):add(A.seg(43, 33, 48, 21))
stem:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and "#4f8a3e" or "#2f6438", dtok) end)
local leaf = A.pred(45, 24, 52, 29, function(x, y) local u = x - 45 return u >= 1 and abs(y - (27 - u * 0.35)) <= 1.3 - abs(u - 3.2) * 0.3 end)
leaf:each(function(x, y) c:put(x, y, y <= 27 - (x - 45) * 0.35 and "#8cc35a" or "#4f8a3e", dtok) end)
local DX, DY = 48, 18
local petals = A.ell(DX, DY, 3.6, 3.6)
petals:each(function(x, y)
  local a = atan(y - DY, x - DX)
  local r = sqrt((x - DX) ^ 2 + (y - DY) ^ 2)
  local f = ((a / (2 * pi / 8)) % 1)
  if r > 2.6 and (f < 0.22 or f > 0.78) then return end
  local col = CR
  if (x - DX) + (y - DY) > 0.5 then col = "#e6d6e6" end
  if (x - DX) + (y - DY) > 2.5 then col = "#b8a6c8" end
  c:put(x, y, col, dtok) end)
for _, p in ipairs{ { 0, 0, GOLD[4] }, { -1, 0, GOLD[5] }, { 0, -1, GOLD[5] }, { -1, -1, GOLD[6] }, { 1, 0, GOLD[3] }, { 0, 1, GOLD[3] }, { 1, 1, GOLD[2] }, { -1, 1, GOLD[4] }, { 1, -1, GOLD[4] } } do
  c:put(DX + p[1], DY + p[2], p[3], dtok) end

-- body
local bm = A.pred(0, TOP, 63, BOT, function(x, y)
  local w = hw(y)
  if abs(x - CX + 0.5) > w then return false end
  -- rounded foot corners (r 3) and softer top corners (r 2)
  local ex = abs(x - CX + 0.5) - (w - 3)
  if y > BOT - 3 and ex > 0 then local ey = y - (BOT - 3) return ex * ex + ey * ey <= 10 end
  if y < TOP + 2 and ex > 1 then local ey = (TOP + 2) - y ex = ex - 1 return ex * ex + ey * ey <= 5 end
  return true
end)
local bnb = X.pillow(bm, 4, 1)
local bn = {}
bm:each(function(x, y) local k = K(x, y) local q = bnb[k]
  local s = (x - CX + 0.5) / (hw(y) + 1) -- gentle barrel across the width
  bn[k] = { A.norm(q[1] + s * 0.35, q[2] + 0.08, q[3]) } end)
local bidx = A.shade(c, bm, bn, BODY, { tok = btok, amb = 0.06, cuts = { 0.2, 0.38, 0.56, 0.73, 0.89 } })
-- top seam AO (the opening) + darker gusset line on the right side
for x = 0, 63 do if bm:has(x, TOP) then A.step(c, bidx, BODY, x, TOP, -1, btok) end end

-- flap: same width as the body top, curved point at the centre
local function flapBot(x) local t = abs(x - CX + 0.5) / 15 return 39.5 + 5.5 * (1 - t * t) end
local fm = A.pred(0, TOP - 1, 63, 50, function(x, y)
  local w = hw(y) + 0.6
  if abs(x - CX + 0.5) > w then return false end
  if y > flapBot(x) then return false end
  local ex = abs(x - CX + 0.5) - (w - 2)
  if y < TOP + 1 and ex > 0 then return false end
  return true
end)
-- contact shadow of the flap on the body (2 rows)
fm:shift(0, 1):add(fm:shift(1, 2)):each(function(x, y) if bm:has(x, y) and not fm:has(x, y) then A.step(c, bidx, BODY, x, y, -2, btok) end end)
fm:shift(1, 3):each(function(x, y) if bm:has(x, y) and not fm:has(x, y) and not fm:has(x, y - 2) then A.step(c, bidx, BODY, x, y, -1, btok) end end)
local fnb = X.pillow(fm, 3, 1)
local fn = {}
fm:each(function(x, y) local k = K(x, y) local q = fnb[k]
  local s = (x - CX + 0.5) / 16
  fn[k] = { A.norm(q[1] + s * 0.3, q[2] - 0.05, q[3]) } end)
local fidx = A.shade(c, fm, fn, FLAP, { tok = ftok, amb = 0.06, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 } })
-- fold line along the top of the flap (where it rolls over the opening): lit lip then dark row
for x = 0, 63 do
  if fm:has(x, TOP) then A.step(c, fidx, FLAP, x, TOP, 1, ftok) end
  if fm:has(x, TOP + 1) then A.step(c, fidx, FLAP, x, TOP + 1, -1, ftok) end
end
-- leather pores
bm:each(function(x, y) if not fm:has(x, y) and X.hash(x, y, 11) > 0.955 and (bidx[K(x, y)] or 0) >= 3 then A.step(c, bidx, BODY, x, y, -1, btok) end end)
fm:each(function(x, y) if y > TOP + 2 and X.hash(x, y, 5) > 0.96 and (fidx[K(x, y)] or 0) >= 3 then A.step(c, fidx, FLAP, x, y, -1, ftok) end end)

-- saddle stitch: gold dashes 2 on 1 off, 2 px inside the flap's lower edge
local sp = {}
for x = CX - 12, CX + 11 do
  local y = floor(flapBot(x) - 2 + 0.5)
  if fm:has(x, y) and fm:has(x, y + 1) then sp[#sp + 1] = { x, y } end
end
for i, p in ipairs(sp) do if (i - 1) % 3 < 2 then c:put(p[1], p[2], (i % 6 < 3) and GOLD[5] or GOLD[4], gtok) end end

-- turn-lock clasp at the flap tip
local KX, KY = CX - 1, floor(flapBot(CX)) - 1
local km = A.pred(KX - 2, KY - 2, KX + 3, KY + 3, function(x, y)
  local ex, ey = abs(x - KX - 0.5), abs(y - KY - 0.5)
  return not (ex > 2 and ey > 2)
end)
-- AO ring under the clasp
km:shift(1, 1):each(function(x, y) if not km:has(x, y) then
  if fm:has(x, y) then A.step(c, fidx, FLAP, x, y, -2, ftok) elseif bm:has(x, y) then A.step(c, bidx, BODY, x, y, -2, btok) end end end)
local kn = X.pillow(km, 2, 1)
local kidx = A.shade(c, km, kn, GOLD, { tok = gtok, amb = 0.1, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
-- dark slot (turn piece) across the middle, bright bevel above
for x = KX - 1, KX + 2 do c:put(x, KY + 1, GOLD[1], gtok) end
c:put(KX - 1, KY - 1, GOLD[6], gtok) c:put(KX, KY - 2, CR, gtok)

-- gold rings holding the handle at the top of the body
for _, rx in ipairs{ HX - HRX - 1, HX + HRX - 1 } do
  local rm = A.pred(rx, TOP - 3, rx + 2, TOP, function(x, y) return true end)
  local rn = X.pillow(rm, 1.5, 1)
  A.shade(c, rm, rn, GOLD, { tok = gtok, amb = 0.1, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
  c:put(rx + 1, TOP - 2, GOLD[1], gtok)
  c:put(rx, TOP - 3, GOLD[6], gtok)
end
-- glint on the left flap shoulder
c:put(CX - 10, TOP + 3, FLAP[6], ftok) c:put(CX - 9, TOP + 3, FLAP[6], ftok)
A.save(c, "ico-handbag")

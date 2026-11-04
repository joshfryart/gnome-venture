-- mamey (final, Opus single pass). Mamey sapote: a slim russet torpedo lying on the diagonal (sandpaper skin:
-- speckled pale scurf + dark pits, stalk nub at the top end, calyx scar at the bottom) with a halved fruit in front:
-- 2 px rind lip, salmon flesh lit as a shallow dish, a big glossy chestnut seed with a pale matte hilum stripe,
-- a darker flesh ring round the seed cavity, AO + contact shadow where the half rests on the whole fruit.
-- quirk: a gnome-sized bite scooped out of the cut half's lower end, tooth ridges showing.
local NAME = "mamey"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, cos, sin = math.floor, math.abs, math.max, math.min, math.sqrt, math.cos, math.sin
local c = A.new(NAME)

local SKIN = { "#3a1f25", "#58302a", "#7a4632", "#9c6640", "#bd8a58", "#dcb07c" }
local SCURF = "#e8c896"
local FLESH = { "#9a2f2e", "#c4483a", "#e2663f", "#f68a50", "#ffac6a", "#ffd09a" }
local SEED = { "#211217", "#3e1f1e", "#653424", "#8f4f2c", "#b9733e", "#e8b07a" }
local HIL = { "#a8865e", "#c9a97c", "#e6cfa2" }
local COOL = "#6f6a8a"

-- whole fruit: slim spindle on the diagonal (lower-left to upper-right)
local ANG = -0.72
local ca, sa = cos(ANG), sin(ANG)
local WX, WY, WRX, WRY = 27, 30, 19, 9.5
local wm, wn = A.oval(WX, WY, WRX, WRY, ANG, 1)
-- taper both ends a little (spindle, not egg)
local tap = {}
wm:each(function(x, y) local dx, dy = x - WX, y - WY
  local u = (dx * ca + dy * sa) / WRX local v = (-dx * sa + dy * ca) / WRY
  if abs(u) > 0.62 and abs(v) > 1 - (abs(u) - 0.62) * 1.25 then tap[#tap + 1] = K(x, y) end
end)
for _, k in ipairs(tap) do wm.s[k] = nil end

-- cut half: lies in front, lower right. body = rind cup, face = cut surface
local HX, HY, HRX, HRY, HANG = 39, 42, 11.5, 8, -0.5
local hb = A.oval(HX + 1.2, HY + 1.6, HRX, HRY, HANG, 1)
local hf, hfn = A.oval(HX, HY, HRX, HRY, HANG, 2.6)
-- bite (quirk): two overlapping scoops at the lower-right end of the half
local bite = HP.mask()
for _, b in ipairs{ { 49.2, 44.6, 2.7 }, { 47.6, 48.0, 2.5 } } do
  for y = floor(b[2] - 4), floor(b[2] + 4) do for x = floor(b[1] - 4), floor(b[1] + 4) do
    if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] * b[3] then bite:set(x, y) end end end
end
hb:cut(bite) hf:cut(bite)
local hbody = hb:copy():cut(hf)

-- whole fruit tone, shaded where the half sits on it
local wvis = wm:copy():cut(hb):cut(hf)
local wb = {}
X.ao(wb, wvis, hb:copy():add(hf), 2, -1)
A.cast(wb, wvis, hb:copy():add(hf), -1, -2, 0)
local wtok = { r = { name = "skin" } }
local widx = A.shade(c, wvis, wn, SKIN, { amb = 0.08, wrap = 0.3, bias = wb, tok = wtok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- cool reflected light along the lower-right rim
local rim = X.rim(wn)
wvis:edge():each(function(x, y) local k = K(x, y)
  if (rim[k] or 0) > 0.55 and (widx[k] or 3) <= 3 and not wb[k] then c:put(x, y, COOL, wtok) end end)
-- sandpaper skin: pale scurf flecks on the lit side, dark pits on the shade side
wvis:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7) local i = widx[k] or 3
  if wb[k] then return end
  if h < 0.09 and i >= 3 then c:put(x, y, i >= 5 and SCURF or SKIN[min(6, i + 1)], wtok)
  elseif h > 0.92 and i >= 2 then c:put(x, y, SKIN[i - 1], wtok) end
end)
-- specular (matte fruit: one small soft glint)
c:put(18, 24, SKIN[6], wtok) c:put(19, 24, SCURF, wtok) c:put(20, 23, SKIN[6], wtok)
-- stalk nub at the upper-right tip, calyx scar at the lower-left tip
do local tx, ty = WX + ca * (WRX - 0.5), WY + sa * (WRX - 0.5)
  local stok = { r = { name = "stalk" } }
  local px = { { 0, 0, 2 }, { 1, -1, 3 }, { 2, -1, 4 }, { 2, -2, 5 }, { 3, -2, 3 }, { 1, 0, 1 }, { 3, -3, 4 }, { 2, -3, 2 } }
  for _, q in ipairs(px) do c:put(floor(tx + q[1] + 0.5), floor(ty + q[2] + 0.5), SKIN[q[3]], stok) end
  local bx, by = floor(WX - ca * (WRX - 2.5) + 0.5), floor(WY - sa * (WRX - 2.5) + 0.5)
  c:put(bx, by, SKIN[1], wtok) c:put(bx - 1, by, SKIN[2], wtok) c:put(bx, by + 1, SKIN[2], wtok) c:put(bx + 1, by - 1, SKIN[4], wtok)
end

-- half: rind cup (shade side only shows)
local htok = { r = { name = "rind" } }
local hbn = X.pillow(hb, 3)
local hbi = A.shade(c, hbody, hbn, SKIN, { amb = 0.05, wrap = 0.2, tok = htok, cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 } })
hbody:each(function(x, y) local k = K(x, y) if X.hash(x, y, 3) < 0.12 and (hbi[k] or 2) > 1 then c:put(x, y, SKIN[hbi[k] - 1], htok) end end)

-- face: flesh lit as a shallow dish (rim brighter top-left, centre a touch deeper), rind line round it
local ftok = { r = { name = "flesh" } }
local SX, SY, SRX, SRY = HX - 1.5, HY - 0.6, 5.6, 3.4
local sm, sn = A.oval(SX, SY, SRX, SRY, HANG, 1.1)
local fb = {}
X.ao(fb, hf, sm, 1, -1)
local fidx = A.shade(c, hf, hfn, FLESH, { amb = 0.35, wrap = 0.5, bias = fb, tok = ftok, cuts = { 0.3, 0.46, 0.6, 0.72, 0.84 } })
-- fibrous flesh: faint radial streaks
hf:each(function(x, y) local k = K(x, y)
  local a = math.atan(y - SY, x - SX)
  if (floor(a * 6 + 0.5) % 3 == 0) and X.hash(x, y, 11) < 0.35 and not fb[k] then c:put(x, y, FLESH[max(1, (fidx[k] or 4) - 1)], ftok) end
end)
-- rind line: 1 px brown ring on the face edge (thicker on the lower-right where we see the wall)
hf:edge():each(function(x, y)
  if bite:grow(1):has(x, y) then return end
  local dx, dy = x - HX, y - HY
  c:put(x, y, (dx + dy > 2) and SKIN[2] or SKIN[3], ftok) end)
-- bite edge: bright wet flesh with tooth ridges
bite:grow(1):each(function(x, y) if hf:has(x, y) then
  c:put(x, y, ((x + y) % 3 == 0) and FLESH[3] or FLESH[6], ftok) end end)
hb:edge():each(function(x, y) if bite:grow(1):has(x, y) and not hf:has(x, y) then c:put(x, y, FLESH[2], htok) end end)

-- seed: glossy chestnut, pale matte hilum stripe along its lower flank
local stok = { r = { name = "seed" } }
local sidx = A.shade(c, sm, sn, SEED, { amb = 0.05, wrap = 0.15, tok = stok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 } })
local hca, hsa = cos(HANG), sin(HANG)
sm:each(function(x, y) local dx, dy = x - SX, y - SY
  local u = (dx * hca + dy * hsa) / (SRX + 0.45) local v = (-dx * hsa + dy * hca) / (SRY + 0.45)
  if v > 0.42 and v < 0.85 and abs(u) < 0.78 then c:put(x, y, HIL[(u < -0.2) and 3 or ((u < 0.35) and 2 or 1)], stok) end
end)
-- glossy glint (2x1 + a cream point)
local gx, gy = A.specAt(sm, sn, 30)
c:put(gx, gy, A.CREAM, stok) c:put(gx + 1, gy, SEED[6], stok) c:put(gx, gy + 1, SEED[6], stok)
-- flesh glint (wet cut surface)
c:put(HX - 7, HY - 3, FLESH[6], ftok) c:put(HX - 6, HY - 4, A.CREAM, ftok)

A.save(c, NAME)

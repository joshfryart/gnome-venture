-- durian (ph, Opus single pass). Upright oval durian, a touch taller than wide, slightly tilted; thick woody stalk
-- with a flared collar on top. Husk: dense hex lattice of 4-faced pyramid thorns lit per pixel (facets catch the
-- light upper-left, fall dark lower-right), thorn tips on the silhouette, two shallow seam grooves (the locules),
-- cool reflected light on the lower-right rim, AO under the collar. Stalk: 6-tone wood with grain and a pale cut end.
-- quirk: the ripe husk has split along one seam and a lobe of custard-yellow flesh is bulging out.
local NAME = "durian"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local HUSK = { "#2f2a33", "#4b4a2e", "#6d7230", "#93993a", "#bcc04e", "#e2e08c" }
local WOOD = { "#3a2226", "#5a3328", "#7c4d32", "#a06c42", "#c4935e", "#e2bd88" }
local FLESH = { "#8a5424", "#c4862e", "#e8b43e", "#f8d66a", "#ffeca6", "#fff6d6" }
local COOL = "#4f6e74"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

-- body
local CX, CY, RX, RY, ANG = 31, 37, 13.6, 16.6, -0.16
local bm, bn = G.oval(CX, CY, RX, RY, ANG, 1.0)
local ca, sa = cos(ANG), sin(ANG)
local function uv(x, y) local dx, dy = x - CX, y - CY return (dx * ca + dy * sa) / (RX + .45), (-dx * sa + dy * ca) / (RY + .45) end

-- split seam (quirk) location: lens along a meridian, lower right
local SX, SY = 38, 45
local split = G.rell(SX, SY, 0.42, 0.91, 6.2, 2.9)

-- rim thorns (outline follows them)
local thorn = HP.mask()
local tn = {}
local NT = 22
for i = 0, NT - 1 do
  local a = (i + 0.5) / NT * 2 * pi
  local ex, ey = cos(a), sin(a)
  -- skip the top where the stalk sits, and near the split
  local px = CX + (ex * (RX + .2)) * ca - (ey * (RY + .2)) * sa
  local py = CY + (ex * (RX + .2)) * sa + (ey * (RY + .2)) * ca
  local onx, ony = norm((ex / RX) * ca - (ey / RY) * sa, (ex / RX) * sa + (ey / RY) * ca, 0)
  local top = ony < -0.86
  if not top then
    local tx, ty = -ony, onx
    local tip = { px + onx * 3.1, py + ony * 3.1 }
    local poly = HP.poly{ { floor(px - tx * 2.1 - onx + .5), floor(py - ty * 2.1 - ony + .5) },
      { floor(tip[1] + .5), floor(tip[2] + .5) },
      { floor(px + tx * 2.1 - onx + .5), floor(py + ty * 2.1 - ony + .5) } }
    poly:each(function(x, y)
      if not bm:has(x, y) and not thorn:has(x, y) then
        thorn:set(x, y)
        local side = (x - px) * tx + (y - py) * ty
        local f = side < 0 and -0.55 or 0.55
        tn[K(x, y)] = { norm(onx * 0.75 + tx * f, ony * 0.75 + ty * f, 0.45) }
      end
    end)
  end
end

-- husk lattice: 4-faced pyramid thorns on a hex grid
local SP, RH = 5, 4.33
local tips = {}
local hn = {}
local function nearest(x, y)
  local best, bx, by = 1e9
  local j0 = floor((y - 2) / RH)
  for j = j0 - 1, j0 + 2 do
    local off = (j % 2) * SP / 2
    local i0 = floor((x - 1 - off) / SP)
    for i = i0 - 1, i0 + 2 do
      local gx, gy = 1 + off + i * SP, 2 + j * RH
      local q = (x - gx)^2 + (y - gy)^2
      if q < best then best, bx, by = q, gx, gy end
    end
  end
  return x - bx, y - by
end
bm:each(function(x, y)
  local k = K(x, y)
  local b = bn[k]
  local dx, dy = nearest(x, y)
  local fx, fy = 0, 0
  if abs(dx) < 0.6 and abs(dy) < 0.6 then tips[k] = true
  elseif abs(dx) > abs(dy) then fx = dx > 0 and 1 or -1 else fy = dy > 0 and 1 or -1 end
  local s = 0.85 * (0.35 + 0.65 * b[3])
  hn[k] = { norm(b[1] + fx * s, b[2] + fy * s, b[3]) }
end)
local all = bm:copy():add(thorn)
for k, v in pairs(tn) do hn[k] = v end
local bias = {}
-- split: no thorns, flesh sits there
-- stalk masks first for AO
local sp = { { 31, 22 }, { 31, 17 }, { 33, 13 }, { 35, 9 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 2.3 - t * 0.4 end)
local collar = G.rell(31, 21.4, 1, 0, 4.4, 2.2)
local cn = X.sphere(31, 20.6, 4.4, collar)
X.ao(bias, all, collar, 2, -1)
local v = X.light(hn, { amb = 0.05, wrap = 0.2 })
local htok = { r = { name = "husk" } }
local idx = X.tone(c, all, v, HUSK, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, bias = bias, tok = htok })
-- thorn tips: a pale point on the lit half, a dark point on the shade side
for k in pairs(tips) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local i = idx[k] or 3
  c:put(x, y, HUSK[min(6, i + 1)], htok)
end
-- seam grooves (locules): meridians, dark groove + lit lip on the left
local function meridian(phi, y0, y1)
  for y = y0, y1 do
    local vv = (y - CY) / (RY + .45)
    local w = sqrt(max(0, 1 - vv * vv))
    local x = floor(CX + RX * sin(phi) * w + sa * (y - CY) * 0 + .5 - (y - CY) * sa)
    if bm:has(x, y) and not split:has(x, y) then
      c:put(x, y, HUSK[max(1, (idx[K(x, y)] or 3) - 2)], htok)
      if bm:has(x - 1, y) and (idx[K(x - 1, y)] or 1) < 5 then c:put(x - 1, y, HUSK[min(6, (idx[K(x - 1, y)] or 3) + 1)], htok) end
    end
  end
end
meridian(-0.32, 24, 50)
meridian(0.62, 25, 49)
-- cool reflected light on the lower-right body edge
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  local u, vv = uv(x, y)
  if (rim[k] or 0) > 0.7 and u > 0.35 and vv > 0.35 then c:put(x, y, COOL, htok) end end)
for k, nn in pairs(tn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local u, vv = uv(x, y)
  if u > 0.5 and vv > 0.5 and (idx[k] or 1) <= 1 then c:put(x, y, COOL, htok) end
end
-- one glint on a lit thorn, upper left
c:put(22, 27, "#fff4d6", htok) c:put(23, 27, HUSK[6], htok)

-- quirk: split seam with a bulging lobe of custard flesh
local stok = { r = { name = "flesh" } }
split:clip(bm)
local lip = split:grow(1):clip(bm):cut(split)
lip:each(function(x, y) c:put(x, y, HUSK[1], htok) end)
-- lit husk lip on the lower-right side of the opening (the husk edge facing the light)
split:grow(2):clip(bm):cut(split:grow(1)):each(function(x, y)
  local dx, dy = x - SX, y - SY if dx + dy > 2 then c:put(x, y, HUSK[5], htok) end end)
local fm, fn = G.oval(SX - 0.4, SY - 0.3, 5.4, 2.4, 1.15, 0.8)
fm:clip(split)
G.toneN(c, fm, fn, FLESH, { tok = stok, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.3 })
c:put(SX - 2, SY - 3, FLESH[6], stok) c:put(SX - 2, SY - 2, FLESH[6], stok) c:put(SX - 1, SY - 4, FLESH[5], stok)

-- stalk: collar then stem
local ctok = { r = { name = "collar" } }
X.tone(c, collar, X.light(cn, { amb = 0.08, wrap = 0.25 }), WOOD, { cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 }, tok = ctok })
-- collar underside dark row
collar:each(function(x, y) if not collar:has(x, y + 1) then c:put(x, y, WOOD[2], ctok) end end)
sm:cut(collar:shift(0, 1))
local wtok = { r = { name = "stalk" } }
local sbias = {}
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.08, wrap = 0.25 }), WOOD, { cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 }, tok = wtok, bias = sbias })
-- grain: broken dark streaks along the stalk
sm:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  if abs(s - 0.25) < 0.18 and (floor(t * 9) % 3 ~= 0) then c:put(x, y, WOOD[max(1, sidx[k] - 1)], wtok) end
  if abs(s + 0.45) < 0.15 and t > 0.2 and t < 0.8 then c:put(x, y, WOOD[min(6, sidx[k] + 1)], wtok) end
end)
-- pale end grain at the cut tip
local ex, ey = G.bez(sp, 1)
local cut = G.rell(ex + 0.3, ey - 0.2, 0.6, -0.8, 1.9, 1.3)
local etok = { r = { name = "endgrain" } }
cut:each(function(x, y) c:put(x, y, WOOD[6], etok) end)
c:put(floor(ex + .8), floor(ey + .3), WOOD[4], etok)
-- AO where stalk meets collar
for x = 29, 33 do if sm:has(x, 18) then c:put(x, 18, WOOD[2], wtok) end end
G.save2(c, NAME)

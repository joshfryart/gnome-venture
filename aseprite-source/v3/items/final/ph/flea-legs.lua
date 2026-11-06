-- flea-legs (final, Opus aB32_0). Two flea hind legs bundled side by side like a tiny bouquet: broad coxa plate, bulging
-- femur, slim tibia with a comb of dark spines on the back edge, beaded 4-segment tarsus and a double hooked claw.
-- Glossy chitin: 6-tone per-pixel light, cream specular streak on each femur, joint rings, AO where the front leg
-- covers the back one and where the thread cinches.
-- quirk: the bundle is tied with a twisted red thread finished in a neat little bow.
local NAME = "flea-legs"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local CH = { "#24101a", "#46182a", "#6e2830", "#9a3e34", "#c46640", "#ee9c64" }
local CHB = { "#1e0e18", "#3a1626", "#5a222c", "#7e3430", "#a4523a", "#cc8052" }   -- back leg, a step cooler/darker
local TH = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

local function leg(ox, oy, R, front, cover)
  local all = HP.mask()
  local tok = { r = { name = front and "legF" or "legB" } }
  local function put(m, n, o)
    m:cut(all) if cover then m:cut(cover) end
    local idx = A.shade(c, m, n, R, { amb = 0.08, wrap = 0.25, tok = tok, bias = o and o.bias })
    all:add(m) return m, idx
  end
  -- tarsus beads + claw (drawn first, smallest at the top)
  local tx0, ty0, tx1, ty1 = 43 + ox, 24 + oy, 48 + ox, 12 + oy
  for i = 0, 3 do local t = i / 3.6
    local x, y = tx0 + (tx1 - tx0) * t, ty0 + (ty1 - ty0) * t
    local bm, bn = A.oval(x, y, 1.6 - i * 0.12, 1.1, -1.17, 0.9)
    put(bm, bn)
  end
  local claw = HP.mask():set(tx1, ty1 - 1):set(tx1 - 1, ty1 - 2):set(tx1 - 2, ty1 - 2):set(tx1 + 1, ty1 - 2):set(tx1 + 1, ty1 - 3)
  claw:cut(all) if cover then claw:cut(cover) end
  claw:each(function(x, y) c:put(x, y, (x < tx1) and R[3] or R[2], tok) end) all:add(claw)
  -- tibia + spines on the back (lower) edge
  local tm, tn, TT, TS = A.tube({ { 27 + ox, 31 + oy }, { 32 + ox, 28 + oy }, { 38 + ox, 26 + oy }, { 43 + ox, 24 + oy } }, function(t) return 1.5 - t * 0.4 end)
  tm, _ = put(tm, tn)
  for i = 1, 4 do local t = i / 5
    local x, y = A.bez({ { 27 + ox, 31 + oy }, { 32 + ox, 28 + oy }, { 38 + ox, 26 + oy }, { 43 + ox, 24 + oy } }, t)
    local sx, sy = floor(x + 1.2 + .5), floor(y + 2.4 + .5)
    if not all:has(sx, sy) and not (cover and cover:has(sx, sy)) then c:put(sx, sy, R[1], tok) all:set(sx, sy) end
  end
  -- knee joint
  local km, kn = A.oval(27 + ox, 31 + oy, 2.0, 2.0, 0, 1)
  put(km, kn)
  -- femur (bulging) with specular streak
  local fp = { { 14 + ox, 47 + oy }, { 17 + ox, 42 + oy }, { 22 + ox, 36 + oy }, { 26 + ox, 32 + oy } }
  local fm, fn, FT, FS = A.tube(fp, function(t) return 2.0 + 1.3 * sin(pi * min(1, t * 1.05)) end)
  local fidx
  fm, fidx = put(fm, fn)
  fm:each(function(x, y) local k = K(x, y)
    if FS[k] and FS[k] < -0.35 and FS[k] > -0.75 and FT[k] > 0.3 and FT[k] < 0.62 then c:put(x, y, front and A.CREAM or R[6], tok) end
    if FT[k] and FT[k] > 0.94 then c:put(x, y, R[2], tok) end            -- joint ring under the knee
  end)
  -- coxa plate
  local cm, cn = A.oval(12 + ox, 50 + oy, 4.4, 3.0, -0.75, 0.7)
  local cidx
  cm, cidx = put(cm, cn)
  cm:each(function(x, y) if (x - 12 - ox) + (y - 50 - oy) * 0.9 > 1.8 and (x - 12 - ox) + (y - 50 - oy) * 0.9 < 3.2 then A.step(c, cidx, R, x, y, -1, tok) end end)
  -- ring between coxa and femur
  return all
end

local front = HP.mask()
-- build the front leg mask first (draw into a scratch canvas) to know what covers the back leg
do
  local keep = c
  c = A.new("scratch")
  front = leg(0, 0, CH, true)
  c = keep
end
local back = leg(6, 4, CHB, false, front)
-- AO: back leg pixels next to the front leg drop a step
front:grow(1):cut(front):each(function(x, y) if back:has(x, y) then
  local h = c:get(x, y) for i = 2, 6 do if h == CHB[i] then c:put(x, y, CHB[i - 1], { r = { name = "legB" } }) end end end end)
leg(0, 0, CH, true)

-- twisted thread band around both femurs, ending in a bow
local ttok = { r = { name = "thread" } }
local band = HP.line({ { 17, 36 }, { 29, 46 } }, 2)
local bandAll = band:copy()
band:each(function(x, y)
  local i = ((x + y * 2) % 3 == 0) and 1 or (((x + y) % 3 == 1) and 3 or 2)
  if (x - 17) * 0.63 - (y - 36) * 0.77 < -0.3 then i = min(4, i + 1) end
  c:put(x, y, TH[i], ttok)
end)
-- AO on the femurs either side of the cinch
band:grow(1):cut(band):each(function(x, y) local h = c:get(x, y)
  for i = 2, 6 do if h == CH[i] then c:put(x, y, CH[i - 1], { r = { name = "legF" } }) end if h == CHB[i] then c:put(x, y, CHB[i - 1], { r = { name = "legB" } }) end end end)
-- bow: two loops + two tails at the lower-right end
local loopA = HP.ellipse(33, 45, 2.6, 1.7):cut(HP.ellipse(33, 45, 1.2, 0.4))
local loopB = HP.ellipse(29, 50, 1.6, 2.4):cut(HP.ellipse(29, 50, 0.4, 1.0))
local tails = HP.line({ { 30, 47 }, { 34, 50 }, { 36, 50 } }, 1):add(HP.line({ { 29, 47 }, { 26, 52 } }, 1))
for _, m in ipairs{ loopA, loopB, tails } do
  m:each(function(x, y) if not band:has(x, y) then
    local up = not m:has(x, y - 1)
    c:put(x, y, up and TH[4] or (not m:has(x, y + 1) and TH[1] or TH[2 + ((x + y) % 2)]), ttok) end end)
end
for _, p in ipairs{ {30, 46}, {29, 46}, {30, 47} } do c:put(p[1], p[2], TH[2], ttok) end   -- knot
c:put(29, 46, TH[4], ttok)

A.save(c, NAME)

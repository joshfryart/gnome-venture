-- ico-bow (final pass, Opus). A recurve hunting bow drawn at full draw on the diagonal, arrow pointing up-right.
-- Structure: two slim laminated limbs that taper to curled recurve tips, a red cloth-wrapped grip with an arrow
-- shelf, a taut pale string pulled into a V at the nock, an arrow with a steel broadhead and red fletching.
-- Material: per-pixel cylinder light on the limbs with wood grain and a pale belly lamination, spiral twist on
-- the grip wrap, bevel + bright edge + specular on the steel head, vane lines on the feathers, AO where the
-- arrow crosses the grip.
-- quirk: one of the three feathers is a mismatched blue jay feather.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-bow")
local OK, LE, IR, RB, FE, WO = R.oak, R.leather, R.iron, R.ribbon, R.feather, R.wool

local CX, CY = 32, 32
local function P(u, v) return { CX + (u + v) * 0.7071, CY + (v - u) * 0.7071 } end
local function rnd(p) return floor(p[1] + 0.5), floor(p[2] + 0.5) end

-- limbs (two bezier tubes from the grip to the tips)
local limbs = {}
for _, sg in ipairs{ -1, 1 } do
  local p = { P(9, 0), P(9, sg * 11), P(-7, sg * 18), P(-3, sg * 24.5) }
  local m, n, T, S = A.tube(p, function(t) return 2.4 - t * 1.2 end, 200)
  limbs[#limbs + 1] = { m = m, n = n, T = T, S = S }
end
-- recurve tip nocks (small dark knobs)
local tips = { P(-2.6, -24.5), P(-2.6, 24.5) }

for _, L in ipairs(limbs) do
  local bias = {}
  L.m:each(function(x, y)
    local k = K(x, y)
    local h = X.hash(floor(L.T[k] * 60), floor((L.S[k] + 1) * 2), 5)
    if h < 0.18 then bias[k] = -1 end                -- grain streaks along the limb
  end)
  L.idx = A.shadeN(c, L.m, L.n, OK, { bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  -- pale belly lamination on the string side (towards -u): the S side facing the string
  L.m:each(function(x, y)
    local k = K(x, y)
    local t = L.T[k]
    if t > 0.25 and t < 0.92 then
      -- the string side is the side nearer to the string line u = -3
      local u = ((x - CX) - (y - CY)) * 0.7071
      local ux, uy = x + 0.7071, y - 0.7071
      if not L.m:has(floor(x - 0.7071 + 0.5), floor(y + 0.7071 + 0.5)) then
        A.setI(c, L.idx, OK, x, y, (L.idx[k] or 3) >= 4 and 6 or 4)
      end
    end
  end)
end
for _, t in ipairs(tips) do
  local x, y = rnd(t)
  c:put(x, y, OK[2]) c:put(x + 1, y, OK[1]) c:put(x, y + 1, OK[1]) c:put(x - 1, y, OK[3]) c:put(x, y - 1, OK[3])
end

-- string: tip -> nock -> tip (pale, 1px, twisted)
local nock = P(-10, 0)
local nx, ny = rnd(nock)
local strM = HP.mask()
for _, t in ipairs(tips) do
  local x, y = rnd(t)
  strM:add(A.seg(x, y, nx, ny))
end
local j = 0
strM:each(function(x, y)
  local lit = ((x + y) % 3 ~= 0)
  if not c:get(x, y) then c:put(x, y, lit and WO[5] or WO[3]) end
end)

-- arrow shaft (3px), from the nock to the head
local tail, headB = P(-11, 0), P(19, 0)
local sm, sn = select(1, X.cyl(tail[1], tail[2], headB[1], headB[2], function() return 1.1 end))
local _, snn = X.cyl(tail[1], tail[2], headB[1], headB[2], function() return 1.1 end, sm)
local isf = A.shadeN(c, sm, snn, R.kraft, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })

-- grip: red cloth wrap, over the limbs' joint, under the arrow (arrow crosses after)
local gm, gn, gT, gS = X.cyl(P(9, -5)[1], P(9, -5)[2], P(9, 5)[1], P(9, 5)[2], function() return 2.8 end)
local gb = {}
gm:each(function(x, y) local k = K(x, y)
  if floor(gT[k] * 10 + gS[k] * 1.6) % 2 == 0 then gb[k] = -1 end end)   -- spiral twist of the wrap
local ig = A.shadeN(c, gm, gn, RB, { bias = gb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- repaint arrow over the grip, with AO on the grip either side
sm:each(function(x, y) if gm:has(x, y) then c:put(x, y, R.kraft[isf[K(x, y)] or 3]) end end)
sm:grow(1):cut(sm):each(function(x, y) if gm:has(x, y) then A.step(c, ig, RB, x, y, -2) end end)
-- string passes over the arrow at the nock: nock notch
c:put(nx, ny, RB[2])

-- broadhead (steel): a diamond in front of the shaft
local h0, h1 = P(17.5, 0), P(26.5, 0)
local hw = function(u) return u < 3 and (u / 3) * 3.4 or 3.4 * (1 - (u - 3) / 6) end
local head = HP.mask()
local hn = {}
for y = 0, 63 do for x = 0, 63 do
  local u = ((x - CX) - (y - CY)) * 0.7071 - 17.5
  local v = ((x - CX) + (y - CY)) * 0.7071
  if u >= 0 and u <= 9 then
    local w = hw(u)
    if abs(v) <= w + 0.2 then
      head:set(x, y)
      -- two bevelled facets: v<0 faces upper-left (lit), v>0 faces lower-right
      local s = v < 0 and -0.6 or 0.6
      local ex = abs(v) > w - 1.2 and 1.6 or 1      -- bevel near the edge
      hn[K(x, y)] = { A.norm(0.7071 * s * ex, 0.7071 * s * ex, 0.75) }
    end
  end
end end
local ih = A.shadeN(c, head, hn, IR, { cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
-- central ridge + bright edge + spec
head:each(function(x, y)
  local v = ((x - CX) + (y - CY)) * 0.7071
  if abs(v) < 0.5 then A.setI(c, ih, IR, x, y, 5) end
end)
head:edge():each(function(x, y)
  local v = ((x - CX) + (y - CY)) * 0.7071
  if v < -0.5 then A.setI(c, ih, IR, x, y, 6) end
end)
-- binding where head meets shaft
do local b = P(17, 0) local x, y = rnd(b)
  c:put(x, y, RB[3]) c:put(x - 1, y, RB[4]) c:put(x, y + 1, RB[2]) c:put(x - 1, y - 1, RB[5]) c:put(x + 1, y + 1, RB[2]) end
do local sp = P(20.5, -0.9) local x, y = rnd(sp) c:put(x, y, A.CREAM) end

-- fletching: three feathers near the tail (two red, one blue: quirk)
local function feather(side, ramp)
  local m, n = HP.mask(), {}
  for y = 0, 63 do for x = 0, 63 do
    local u = ((x - CX) - (y - CY)) * 0.7071
    local v = ((x - CX) + (y - CY)) * 0.7071 * side
    if u >= -10 and u <= -2 then
      local w = 1.0 + (u + 10) * 0.42
      if u > -4.5 then w = 1.0 + (-2 - u) * 1.3 end
      if v >= 1.3 and v <= 1.3 + w then
        m:set(x, y)
        n[K(x, y)] = { A.norm(-0.4 * side * 0.7, -0.4 * side * 0.7 * -1 + 0.0, 0.9) }
      end
    end
  end end
  local idx = A.shadeN(c, m, n, ramp, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  -- vane lines (diagonal barbs)
  m:each(function(x, y)
    local u = ((x - CX) - (y - CY)) * 0.7071
    local v = ((x - CX) + (y - CY)) * 0.7071 * side
    if floor(u + v * 0.8 + 20) % 3 == 0 then A.step(c, idx, ramp, x, y, -1) end
    if v < 2.2 then A.step(c, idx, ramp, x, y, 1) end
  end)
  return m
end
feather(-1, RB)          -- upper-left feather (red)
local fB = feather(1, FE)           -- lower-right feather (blue jay)
-- the third feather faces us along the shaft: a thin red stripe over the shaft
sm:each(function(x, y)
  local u = ((x - CX) - (y - CY)) * 0.7071
  local v = ((x - CX) + (y - CY)) * 0.7071
  if u >= -9.5 and u <= -2.5 and abs(v) < 0.6 then c:put(x, y, (floor(u) % 2 == 0) and RB[5] or RB[4]) end
end)
-- jay stripe on the blue feather
for _, uu in ipairs{ -8, -5 } do
  for vv = 1.5, 4.5, 0.5 do local p = P(uu, vv) local x, y = rnd(p)
    if fB:has(x, y) then c:put(x, y, FE[1]) end end
end
-- nock end of the shaft
do local x, y = rnd(P(-11.5, 0)) c:put(x, y, OK[2]) end

A.save(c, "ico-bow")

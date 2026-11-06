-- river-clay (final, artist aD12_4). A wet brick of grey-brown river clay in 3/4 view, just cut in two by a wire cheese-cutter:
-- the upper half sits one pixel proud, a dark slit with the thin steel wire (bright top pixel) runs across the front and
-- slants along the right face to two slim wooden toggles. Material: wavy silt striations (dark seams, pale sand lens), grit,
-- two pressed-in pebbles, two thumb dents with lit lower lips on the glossy top, a deeper thumbprint on the front, wet specular,
-- lit top edge, dark right edge, AO at the foot.
-- quirk: a tiny river snail (cream spiral shell, two eye stalks) is crawling across the top of the brick.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("river-clay")

local CL    = { "#3a3444", "#58505a", "#7a6c6c", "#9c8a80", "#bda898", "#dccab8" }
local STONE = { "#35364f", "#4f5170", "#74758c", "#9795a8", "#bdbacb", "#e2e0e6" }
local WOOD  = { "#3a2220", "#51302b", "#7a4630", "#a46a40", "#cc9460", "#e8b982" }
local CRM   = { "#8a6a58", "#b58d70", "#dcb590", "#f2d4a8", "#fbe7c4", "#fff4d6" }
local SB    = { "#6e5a64", "#9a8480", "#c4aea0", "#e0cdbc" }
local CUTS  = { 0.26, 0.44, 0.6, 0.75, 0.88 }
local SL = 0.875

c:groundShadow(30, 57, 24, 2.5)

-- masks -------------------------------------------------------------------
local function front(xl, xr, y0, y1) return A.rows(y0, y1, function(y) return xl, xr end) end
local function right(x0, yt, yb)
  local m = HP.mask()
  for i = 0, 8 do for y = floor(yt - SL * i + .5), floor(yb - SL * i + .5) do m:set(x0 + i, y) end end
  return m
end
local uF = front(16, 43, 23, 38)
uF:cut(c:rect(16, 23, 16, 23)):cut(c:rect(43, 23, 43, 23))
local uT = A.rows(16, 22, function(y) local s = (23 - y) * 8 / 7 return 16 + s, 44 + s end)
uT:cut(c:rect(0, 16, 24, 16)):cut(c:rect(52, 16, 63, 16))
local uR = right(44, 23, 38)
local lF = front(15, 42, 41, 56):add(c:rect(14, 54, 14, 56)):cut(c:rect(15, 56, 15, 56)):cut(c:rect(42, 56, 42, 56))
local lR = right(43, 41, 56)
lR:cut(c:rect(51, 47, 51, 47)):cut(c:rect(51, 46, 51, 46))
local up = HP.mask():add(uT):add(uF):add(uR)
local lo = HP.mask():add(lF):add(lR)

-- face painter ---------------------------------------------------------------
local function paint(m, vf, bias)
  local v = {}
  m:each(function(x, y) v[K(x, y)] = vf(x, y) + (X.hash(x, y, 3) - 0.5) * 0.07 end)
  return X.tone(c, m, v, CL, { cuts = CUTS, bias = bias })
end
-- striation lines -> bias
local function seams(bias, m, ys, slant, x0)
  for _, l in ipairs(ys) do
    m:each(function(x, y)
      local yy = l[1] + floor(1.3 * sin(x * 0.28 + l[1] * 1.7) + 0.5) - (slant and floor(SL * (x - x0) + .5) or 0)
      if y == yy then bias[K(x, y)] = (bias[K(x, y)] or 0) + l[2] end
    end)
  end
end
local function grit(bias, m, seed)
  m:each(function(x, y) local h = X.hash(x, y, seed) if h > 0.93 then bias[K(x, y)] = (bias[K(x, y)] or 0) + 1 elseif h < 0.05 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end)
end

-- upper block
local bT, bF, bR = {}, {}, {}
grit(bT, uT, 11) grit(bF, uF, 12) grit(bR, uR, 13)
seams(bF, uF, { {26,-1}, {29,1}, {33,-1}, {36,1} }, false)
uF:each(function(x, y) if y >= 30 and y <= 31 and x >= 20 and x <= 33 then bF[K(x, y)] = (bF[K(x, y)] or 0) + 1 end
  if y == 23 then bF[K(x, y)] = (bF[K(x, y)] or 0) + 1 end
  if x == 43 then bF[K(x, y)] = (bF[K(x, y)] or 0) - 1 end
  if y == 38 then bF[K(x, y)] = (bF[K(x, y)] or 0) - 1 end end)
seams(bR, uR, { {26,-1}, {29,1}, {33,-1}, {36,1} }, true, 44)
uT:each(function(x, y) if y == 22 then bT[K(x, y)] = (bT[K(x, y)] or 0) - 1 end if x - (16 + (23 - y) * 8 / 7) < 1.2 then bT[K(x, y)] = (bT[K(x, y)] or 0) + 1 end end)
paint(uT, function(x, y) return 0.84 - 0.10 * (x - 20) / 30 end, bT)
paint(uF, function(x, y) return 0.64 - 0.12 * (x - 16) / 28 - 0.02 * (y - 23) / 15 end, bF)
paint(uR, function(x, y) return 0.30 end, bR)

-- lower block
local cF, cR = {}, {}
grit(cF, lF, 21) grit(cR, lR, 22)
seams(cF, lF, { {44,-1}, {47,1}, {51,-1}, {54,1} }, false)
seams(cR, lR, { {44,-1}, {47,1}, {51,-1}, {54,1} }, true, 43)
lF:each(function(x, y)
  if y == 41 then cF[K(x, y)] = (cF[K(x, y)] or 0) + 2 end             -- lit cut lip
  if y >= 55 then cF[K(x, y)] = (cF[K(x, y)] or 0) - 1 end            -- AO at the foot
  if x == 42 then cF[K(x, y)] = (cF[K(x, y)] or 0) - 1 end end)
lR:each(function(x, y) if y >= 55 - floor(SL * (x - 43) + .5) + 0 and y >= 54 - floor(SL * (x - 43)) then cR[K(x, y)] = (cR[K(x, y)] or 0) - 1 end end)
local fi = paint(lF, function(x, y) return 0.61 - 0.12 * (x - 15) / 28 - 0.04 * (y - 41) / 15 end, cF)
paint(lR, function(x, y) return 0.28 end, cR)

-- slit + wire ----------------------------------------------------------------
for x = 15, 52 do
  local yb, yt = nil, nil
  for y = 15, 60 do
    if up:has(x, y) then yb = y end
    if not yt and lo:has(x, y) then yt = y end
  end
  if yb and yt and yt - yb >= 2 then
    for y = yb + 1, yt - 1 do c:px(x, y, CL[1]) end
    c:px(x, yt - 1, STONE[3])                                          -- wire
    if x % 3 == 0 then c:px(x, yt - 1, STONE[5]) end
    if x % 7 == 2 then c:px(x, yt - 1, STONE[6]) end
  end
end
-- wire tails to the toggles
for x = 11, 14 do c:px(x, 40, STONE[3]) end c:px(12, 40, STONE[5])
local wy = floor(40 - SL * 9 + .5)
for x = 53, 55 do c:px(x, wy, STONE[3]) end c:px(54, wy, STONE[5])

-- thumb dents ----------------------------------------------------------------
local function dent(cx, cy, rx, ry, ang, m)
  local d = A.ell(cx, cy, rx, ry, ang):clip(m)
  d:each(function(x, y)
    local b = (X.tone and 0)
    local base = c:get(x, y)
    local top = not d:has(x - 1, y - 1) or not d:has(x, y - 1)
    local low = not d:has(x + 1, y + 1) or not d:has(x, y + 1)
    local hex = CL[2]
    if top then hex = CL[1] elseif low then hex = CL[5] end
    c:px(x, y, hex)
  end)
end
dent(24.5, 20, 3.4, 1.4, 0, uT)
dent(30.5, 18, 3.0, 1.2, 0, uT)
do -- thumbprint on the front, fingerprint ridges inside
  local d = A.ell(27, 47.5, 3.6, 2.6, -0.2):clip(lF)
  d:each(function(x, y)
    local top = not d:has(x - 1, y - 1) or not d:has(x, y - 1)
    local low = not d:has(x + 1, y + 1) or not d:has(x, y + 1)
    c:px(x, y, top and CL[1] or (low and CL[5] or CL[2]))
    if not top and not low and (y % 2 == 0) then c:px(x, y, CL[3]) end
  end)
end
-- pressed-in pebbles
local function pebble(cx, cy, rx, ry, ang)
  local m = A.ell(cx, cy, rx, ry, ang)
  m:shift(1, 1):each(function(x, y) if (up:has(x, y) or lo:has(x, y)) and not m:has(x, y) then c:px(x, y, CL[1]) end end)
  A.pill(c, m, STONE, 1.4, {})
  c:px(floor(cx - 0.8), floor(cy - 0.8), STONE[6])
end
pebble(36.5, 47.5, 2.4, 1.7, 0.2)
pebble(21.5, 30, 1.9, 1.4, -0.3)
-- wet specular on the top and a pale sheen streak on the front
for _, p in ipairs{ {21,19},{22,19},{21,18},{28,17} } do if uT:has(p[1], p[2]) then c:px(p[1], p[2], "#f4ead8") end end
for _, p in ipairs{ {18,26},{18,27},{19,28} } do if uF:has(p[1], p[2]) then c:px(p[1], p[2], CL[6]) end end
c:px(40, 30, CL[5]) c:px(40, 31, CL[5])

-- toggles ---------------------------------------------------------------------
local function toggle(x, y0, y1)
  local m, n, T, S = X.cyl(x, y0, x, y1, function(t) return 1.45 end)
  local idx = G.toneN(c, m, n, WOOD, { amb = 0.12, wrap = 0.3 })
  m:each(function(px, py) local k = K(px, py)
    if abs(S[k] - 0.1) < 0.18 and T[k] > 0.1 and T[k] < 0.9 then c:px(px, py, WOOD[max(1, (idx[k] or 3) - 1)]) end
    if T[k] < 0.12 or T[k] > 0.9 then c:px(px, py, WOOD[max(1, (idx[k] or 3) - 1)]) end end)
  return m
end
toggle(10, 34, 46)
toggle(56, 27, 39)
c:px(10, 40, WOOD[1]) c:px(56, wy, WOOD[1])

-- quirk: river snail crawling on the top ------------------------------------
do
  local body = HP.mask()
  for x = 35, 42 do body:set(x, 21) body:set(x, 20) end
  body:set(34, 20) body:set(34, 19) body:set(35, 19) body:set(41, 22)
  body:cut(c:rect(42, 20, 42, 20))
  body:each(function(x, y) c:px(x, y, (y == 21 or (x == 34 and y == 20)) and SB[2] or SB[3]) end)
  c:px(34, 19, SB[4]) c:px(35, 19, SB[3])
  -- eye stalks
  c:px(34, 18, SB[3]) c:px(36, 18, SB[3]) c:px(34, 17, "#2b1c26") c:px(36, 17, "#2b1c26")
  -- shell
  local sh = A.ell(40, 18, 3.0, 2.9, 0)
  sh:shift(1, 1):each(function(x, y) if uT:has(x, y) and not sh:has(x, y) then c:px(x, y, CL[1]) end end)
  local sn = X.sphere(39.4, 17.5, 3.0, sh)
  G.toneN(c, sh, sn, CRM, { amb = 0.12, wrap = 0.3 })
  for _, o in ipairs{ {1,-2},{2,-1},{2,0},{1,1},{0,1},{-1,0},{0,-1} } do c:px(40 + o[1], 18 + o[2], CRM[2]) end
  c:px(38, 16, CRM[6])
end

A.save(c, "river-clay")

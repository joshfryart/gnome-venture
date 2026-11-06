-- ico-strawberry (Opus artist pass): an upright, slightly leaning strawberry, tall heart-cone with round shoulders
-- tapering to a soft point; a star calyx of five slim sepals and a short bent stalk.
-- Material: berry lit per pixel from a height field (round cross-sections), 6-tone glossy red, cool-violet shade
-- side, waxy specular glint + bloom streak on the lit shoulder, cool reflected light along the lower-right edge.
-- Seeds sit in dark dimples (shade pixel below-right) as gold 1x2 achenes with a lit tip, toned down in the shade.
-- Sepals: 6-tone leaf blades with a pale midrib, a dark row where they lap each other, and a cast shadow on the
-- berry below them. Stalk: 3 px lit cylinder with a dark collar. quirk: a curly runner tendril springs off the stalk.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = D.new("ico-strawberry")
local R, LF = D.RED, D.LEAF
local btok, ltok, stok = { r = { name = "berry" } }, { r = { name = "leaf" } }, { r = { name = "stalk" } }

-- berry: half-width per row, centre leans a touch to the right as it goes down
local Y0, YM, YT = 17, 27, 55
local function hw(y)
  if y < Y0 then return -1 end
  if y <= YM then local q = (YM - y) / (YM - Y0 + 0.6) return 13.2 * sqrt(max(0, 1 - q * q)) end
  local t = (y - YM) / (YT - YM)
  if t > 1 then return -1 end
  return 13.2 * (1 - t ^ 1.25) ^ 0.85 + 0.6 * (1 - t)
end
local function cx(y) return 32 + (y - YM) * 0.07 end
-- heart dip at the top centre
local bm = HP.mask()
for y = Y0, YT do
  local w = hw(y)
  if w > 0 then for x = floor(cx(y) - w + 0.5), floor(cx(y) + w - 0.5) do
    local dip = (y <= Y0 + 1) and abs(x - 32) < 3
    if not dip then bm:set(x, y) end
  end end
end
local function h(x, y)
  local w = hw(y)
  if w <= 0 then return 0 end
  local d = (x - cx(y)) / (w + 0.5)
  if abs(d) >= 1 then return 0 end
  return w * 1.1 * sqrt(1 - d * d)
end
local bn = D.hnorm(bm, h)
local bias = {}
-- sepal masks (built first so they can shade the berry)
local CX0, CY0 = 32, 19
local sepals = { -- tip x, y, half width
  { 13, 25, 2.6 }, { 51, 26, 2.6 }, { 20, 14.5, 2.4 }, { 45, 14, 2.4 }, { 33, 30, 2.8 },
}
local smasks = {}
local sall = HP.mask()
for i, s in ipairs(sepals) do
  local m, n, T, S = X.cyl(CX0, CY0, s[1], s[2], function(t)
    if t > 0.985 then return -1 end
    return max(0.6, s[3] * sin(pi * min(1, 0.22 + t * 0.8)) ^ 0.8)
  end)
  smasks[i] = { m = m, n = n, T = T, S = S, s = s }
  sall:add(m)
end
local hub = D.ell(32, 19, 3.2, 2.0)
sall:add(hub)
G.cast(bias, bm, sall, 1, 2, -1)
G.cast(bias, bm, sall, 2, 3, -1)
local bidx = D.tone(c, bm, bn, R, { amb = 0.08, wrap = 0.3, bias = bias, tok = btok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })

-- cool reflected light on the lower-right rim
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and y > 30 and y < 52 then c:put(x, y, "#a8466e", btok) end end)

-- seeds: diagonal lattice, 1x2 achene in a dimple
for row = 0, 8 do
  for col = -4, 4 do
    local y = 24 + row * 4
    local x = floor(cx(y) + col * 5 + (row % 2) * 2.5 + 0.5)
    local w = hw(y)
    if w > 0 and bm:has(x, y) and bm:has(x, y + 1) and abs(x - cx(y)) < w * 0.8 and not sall:grow(1):has(x, y) then
      local k = K(x, y)
      local i = bidx[k] or 3
      -- dimple: darker pixel right and below
      D.shift(c, x + 1, y + 1, R, -2) D.shift(c, x + 1, y, R, -1)
      if i >= 4 then
        c:put(x, y, D.SEED[4], btok) c:put(x, y + 1, D.SEED[3], btok)
      elseif i >= 3 then
        c:put(x, y, D.SEED[3], btok) c:put(x, y + 1, D.SEED[2], btok)
      else
        c:put(x, y, D.SEED[2], btok) c:put(x, y + 1, D.SEED[1], btok)
      end
    end
  end
end
-- waxy bloom streak + specular glint on the lit shoulder
for _, p in ipairs{ { 22, 25 }, { 21, 26 }, { 21, 27 }, { 20, 28 }, { 20, 29 } } do c:put(p[1], p[2], R[6], btok) end
c:put(23, 24, R[6], btok) c:put(24, 24, R[5], btok)
c:put(22, 26, D.CREAM, btok) c:put(23, 25, D.CREAM, btok)
c:put(22, 34, R[5], btok) c:put(22, 35, R[5], btok)

-- sepals, back to front: dark row where a front sepal laps an earlier one; pale midrib
local order = { 3, 4, 1, 2, 5 }
local done = HP.mask()
for _, i in ipairs(order) do
  local sm = smasks[i]
  local idx = D.tone(c, sm.m, sm.n, LF, { amb = 0.14, wrap = 0.3, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  sm.m:each(function(x, y) local k = K(x, y)
    local s, t = sm.S[k], sm.T[k]
    if abs(s) < 0.22 and t > 0.18 and t < 0.85 then c:put(x, y, s <= 0 and LF[6] or LF[4], ltok) end
  end)
  sm.m:edge():each(function(x, y)
    if done:has(x - 1, y) or done:has(x + 1, y) or done:has(x, y - 1) or done:has(x, y + 1) then
      if not done:has(x, y) then end
    end
  end)
  -- pixels of earlier sepals bordering this one get darkened (contact shadow)
  local ring = sm.m:grow(1):cut(sm.m)
  ring:each(function(x, y) if done:has(x, y) then D.shift(c, x, y, LF, -2) end end)
  done:add(sm.m)
end
-- hub where the sepals join, dark centre where the stalk sinks in
hub:each(function(x, y) local d = ((x - 32) / 3.2) ^ 2 + ((y - 19) / 2.0) ^ 2
  c:put(x, y, d < 0.3 and LF[3] or (y < 19 and LF[4] or LF[3]), ltok) end)

-- stalk: bent 3 px cylinder from the hub up and slightly right
local sp = { { 32, 19 }, { 32, 13 }, { 34, 9 }, { 36, 6 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return t < 0.92 and 1.55 or 1.2 end)
local STK = { "#24544a", "#2e7646", "#4f9a4e", "#7cc35a", "#a6d873" }
D.tone(c, sm, sn, STK, { amb = 0.12, wrap = 0.3, tok = stok })
sm:each(function(x, y) local k = K(x, y) if ST[k] < 0.12 then c:put(x, y, STK[1], stok) end end)
-- cut end of the stalk: pale ring
c:put(36, 5, "#c4e07a", stok)

-- quirk: a curly runner tendril springing off the stalk to the left (hand-placed 1 px curl)
for i, p in ipairs{ {31,12},{30,11},{29,11},{28,10},{27,9},{26,9},{25,9},{24,10},{23,11},{23,12},{24,13},{25,13},{26,12} } do
  c:put(p[1], p[2], i < 6 and STK[3] or STK[4], stok)
end
c:put(26, 8, STK[5], stok)
D.save(c, "ico-strawberry")

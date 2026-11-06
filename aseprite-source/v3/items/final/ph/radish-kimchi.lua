-- radish-kimchi (final, Sonnet high). A slim indigo-glazed stoneware onggi jar (lathe-lit, 6-tone celadon-blue glaze with a
-- cream dotted band, speckles, lip bevel) heaped with glossy chilli-red kkakdugi cubes: chilli flecks, white flesh showing at cut
-- corners, sesame, spring-onion rings. Cubes sit behind the front lip, shadowed where they meet it.
-- quirk: a bead of red brine has run down the jar's neck and hangs from the shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("radish-kimchi")
local KR = { "#52132c", "#8a1d2c", "#c02a2a", "#e24a2c", "#f87a3c", "#ffb878" }
local J = { "#14283c", "#1f4560", "#2a6480", "#3a88a0", "#62b2b8", "#a8e0d0" }
local CREAM = "#f4e6c8"
local CX = 31.5
c:groundShadow(CX, 57, 14, 2)

-- ===== cubes (behind the lip), painted back to front
local cubes = {
  { 28, 8, 8, 8 },
  { 22, 13, 8, 8 }, { 31, 13, 8, 8 }, { 38, 15, 7, 8 },
  { 19, 20, 8, 9 }, { 26, 19, 8, 10 }, { 34, 20, 8, 9 }, { 41, 21, 6, 8 },
}
local drawn = HP.mask()
local ctok = { r = { name = "cube" } }
for i, q in ipairs(cubes) do
  local x0, y0, w, h = q[1], q[2], q[3], q[4]
  local m = c:rrect(x0, y0, x0 + w - 1, y0 + h - 1, 1.2)
  for _, p in ipairs{ { x0, y0 }, { x0 + w - 1, y0 }, { x0, y0 + h - 1 }, { x0 + w - 1, y0 + h - 1 } } do
    if X.hash(p[1], p[2], 41 + i) < 0.45 then m.s[K(p[1], p[2])] = nil end
  end
  -- box faces: lit top plane, front face, shaded right side + underside
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local t = 3
    if y <= y0 + 1 then t = 5 elseif y == y0 + 2 then t = 4 end
    if y == y0 then t = 6 end
    if x == x0 and y > y0 + 1 then t = 4 end
    if x >= x0 + w - 2 and y > y0 + 1 then t = 2 end
    if y >= y0 + h - 1 then t = 2 end
    local hh = X.hash(x, y, 50 + i)
    if hh < 0.1 then t = t - 1 elseif hh > 0.94 then t = t + 1 end
    idx[k] = max(1, min(6, t))
    c:put(x, y, KR[idx[k]], ctok)
  end)
  -- pale flesh at the cut corner on two cubes
  if i == 2 or i == 6 or i == 7 then
    local x0, y0 = q[1] + 1, q[2] + 1
    for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 } } do
      if m:has(x0 + p[1], y0 + p[2]) then c:put(x0 + p[1], y0 + p[2], (p[1] + p[2] >= 2) and "#ffc9b8" or "#fff0e2", ctok) end
    end
    if m:has(x0 + 2, y0 + 1) then c:put(x0 + 2, y0 + 1, KR[5], ctok) end
  end
  -- glossy specular on every cube
  do local sx, sy = q[1] + 2, q[2] + 1
    if m:has(sx, sy) and m:has(sx + 1, sy) and not (i == 2 or i == 6 or i == 7) then c:put(sx, sy, "#ffe2b8", ctok) c:put(sx + 1, sy, "#ffe2b8", ctok) end end
  -- 1px deep line along the edges that touch earlier cubes
  A.touch(m, drawn):each(function(x, y) if m:has(x, y) then c:put(x, y, KR[1], ctok) end end)
  drawn:add(m)
end
-- sesame + spring onion rings
for _, p in ipairs{ { 24, 15 }, { 36, 22 }, { 29, 25 } } do c:put(p[1], p[2], CREAM) c:put(p[1] + 1, p[2], "#d4b88c") end
for _, p in ipairs{ { 32, 11, 1 }, { 22, 24, 0 }, { 42, 19, 0 } } do
  c:put(p[1], p[2], "#9dd06c") c:put(p[1] + 1, p[2], "#6ab455") c:put(p[1] + 2, p[2], "#6ab455")
  c:put(p[1], p[2] + 1, "#2e7646") c:put(p[1] + 1, p[2] + 1, "#2e7646")
end

-- ===== jar (lathe)
local J0 = 27
local function hw(y)
  if y < J0 then return nil end
  if y <= J0 + 2 then return 11.6 end
  if y <= J0 + 5 then return 9.6 end
  if y <= J0 + 16 then return 9.6 + 3.4 * sin((y - J0 - 5) / 11 * pi / 2) end
  if y <= J0 + 21 then return 13.0 end
  if y <= J0 + 28 then return 13.0 - (y - J0 - 21) * 0.45 end
  return nil
end
local jm, jn, JU = A.lathe(CX, J0, J0 + 28, hw)
local jb = {}
-- AO under the lip, and where cubes sit just above
for x = 18, 46 do if jm:has(x, J0 + 3) then jb[K(x, J0 + 3)] = -1 end if jm:has(x, J0 + 4) then jb[K(x, J0 + 4)] = -1 end end
-- lit top row of the lip + bevel
for x = 18, 46 do if jm:has(x, J0) then jb[K(x, J0)] = 1 end if jm:has(x, J0 + 2) then jb[K(x, J0 + 2)] = -1 end end
-- glaze speckle
jm:each(function(x, y) local h = X.hash(x, y, 90) local k = K(x, y)
  if h < 0.025 then jb[k] = (jb[k] or 0) + 1 elseif h > 0.985 then jb[k] = (jb[k] or 0) - 1 end end)
local jidx = A.shade(c, jm, jn, J, { bias = jb, amb = 0.1, wrap = 0.2, cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 } })
-- cream dotted band on the shoulder + belly (dashes follow the curve a little)
local function band(y, off)
  for x = 17, 47 do if jm:has(x, y) then
    local dx = abs(x - CX)
    if (x + off) % 3 ~= 0 and dx < (hw(y) or 0) - 0.5 then
      local base = jidx[K(x, y)] or 3
      c:put(x, y, base >= 4 and CREAM or "#b8a78a")
    end
  end end
end
band(J0 + 12, 0) band(J0 + 22, 1)
-- belly specular streak (lit left)
for y = J0 + 8, J0 + 18 do for x = 18, 30 do
  if jm:has(x, y) and JU[K(x, y)] < -0.55 and JU[K(x, y)] > -0.72 and y % 6 ~= 0 then c:put(x, y, J[6]) end end end
-- cool bounce on the lower-right silhouette
jm:edge():each(function(x, y) if x > CX + 6 and y > J0 + 12 and not jm:has(x + 1, y) then c:put(x, y, "#6f9aa8") end end)
-- dark seam between the lip and the cubes
for x = 18, 46 do if jm:has(x, J0) then c:put(x, J0, X.hash(x, 0, 1) < 0.5 and J[5] or J[6]) end end

-- ===== quirk: red brine bead running down the neck
local dm = c:line({ { 38, J0 + 2 }, { 38, J0 + 9 } }, 2)
dm:add(c:ellipse(38.5, J0 + 11, 1.6, 1.8))
dm:each(function(x, y) if jm:has(x, y) or y > J0 + 8 then c:put(x, y, (x == 38) and KR[3] or KR[2]) end end)
c:put(38, J0 + 4, KR[5]) c:put(38, J0 + 5, KR[4]) c:put(38, J0 + 9, KR[5]) c:put(38, J0 + 10, "#ffe2b8")
c:put(39, J0 + 12, KR[1]) c:put(38, J0 + 12, KR[2])

A.save(c, "radish-kimchi")

-- broken-gathering-basket (aB11_3, Opus single pass). Round-shouldered wicker gathering basket, slim arched handle
-- with a spiral cane wrap, braided (twisted) rim over a dark interior. Body: vertical-cylinder light per pixel plus a
-- per-cell weave bump (weavers pass over and under the stakes, lit top row, dark lower row, dark stake gaps).
-- broken: the handle has snapped on the right (gap with frayed cane ends), and a hole is punched through the lower
-- right wall with sprung weaver ends; a loose bit of cane flies off. Ground shadow, AO under the rim.
-- quirk: a small red-capped mushroom peeks over the rim from inside.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local Wk = A.WICKER
local floor, abs, max, min, sqrt, atan, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.atan, math.pi
local c = A.new("broken-gathering-basket")
local CX, RY, Y1 = 32, 31, 54

c:groundShadow(CX, Y1 + 1, 15, 2)

-- handle arc (behind the body), centred on the rim
local hm, hn, hA, hS = HP.mask(), {}, {}, {}
local HR, HW = 16.2, 1.6
for y = 8, RY do for x = 10, 54 do
  local dx, dy = x - CX, y - RY
  local r = sqrt(dx * dx + dy * dy)
  if abs(r - HR) <= HW then
    local a = atan(-dy, dx)                  -- 0 right .. pi left
    local gap = a > 0.62 and a < 0.8
    if not gap then
      hm:set(x, y)
      local s = (r - HR) / (HW + 0.5)
      local k = K(x, y)
      hn[k] = { dx / r * s, dy / r * s, sqrt(max(0.05, 1 - s * s)) }
      hA[k], hS[k] = a, s
    end
  end
end end
local hi = A.tone(c, hm, hn, Wk, { tok = { r = { name = "handle" } } })
-- spiral cane wrap
hm:each(function(x, y) local k = K(x, y)
  local q = (hA[k] * HR + hS[k] * 2.2) / 2.6
  if q - floor(q) < 0.33 then c:put(x, y, Wk[max(1, hi[k] - 1)]) end end)
-- frayed ends at the snap
c:paint({ "a..", ".ab", "..a" }, 44, 18, { a = Wk[5], b = Wk[3] })
c:paint({ "b.a", "ab." }, 42, 15, { a = Wk[6], b = Wk[4] })

-- body: rows taper toward a rounded foot
local body = HP.mask()
for y = RY, Y1 do
  local hw = 19.5 - (y - RY) * 4.5 / (Y1 - RY)
  if y > Y1 - 3 then hw = hw - ({ 0.8, 1.8, 3.6 })[y - (Y1 - 3)] end
  for x = floor(CX - hw + .5), floor(CX + hw - .5) do body:set(x, y) end
end
local bn, bias, cellv = {}, {}, {}
body:each(function(x, y)
  local k = K(x, y)
  local hw = 19.5 - (y - RY) * 4.5 / (Y1 - RY)
  local s = max(-0.97, min(0.97, (x - CX + 0.5) / (hw + 0.6)))
  local ny = (y - RY) / (Y1 - RY) * 0.35 + 0.05
  bn[k] = { s, ny, sqrt(max(0.05, 1 - s * s)) }
  -- weave cell
  local row = (y - RY - 3) // 3
  local off = (row % 2) * 2
  local cx = (x + off) % 4
  local cy = (y - RY - 3) % 3
  local b = 0
  if cy == 0 then b = 1 elseif cy == 2 then b = -1 end
  if cx == 0 then b = -1 end
  if cx == 0 and cy == 2 then b = -2 end
  bias[k] = b
end)
-- AO under the rim
body:each(function(x, y) if y <= RY + 4 then local k = K(x, y) bias[k] = (bias[k] or 0) - (y <= RY + 3 and 2 or 1) end end)
local bi = A.tone(c, body, bn, Wk, { bias = bias, tok = { r = { name = "body" } } })
-- base band: two plain rows of tight weave just above the foot
body:each(function(x, y) if y >= Y1 - 3 then local k = K(x, y)
  c:put(x, y, Wk[max(1, min(6, bi[k] - bias[k] + ((x + y) % 3 == 0 and -1 or 0)))]) end end)

-- interior (dark), rim ring with a twisted braid
local outer = c:ellipse(CX, RY, 21, 4.5)
local inner = c:ellipse(CX, RY - 0.5, 17, 2.5)
c:fillMask(inner, Wk[1])
inner:each(function(x, y) if y <= RY - 2 then c:put(x, y, "#46261f") end end)
-- quirk: mushroom from inside (stem clipped by the front rim)
local ring = outer:copy():cut(inner)
-- rim ring
local rn = X.pillow(ring, 1.8)
local ri = A.tone(c, ring, rn, Wk, { tok = { r = { name = "rim" } } })
ring:each(function(x, y) local k = K(x, y)
  if (x * 1 + (y - RY) * 2) % 4 < 1 then c:put(x, y, Wk[max(1, ri[k] - 2)])
  elseif (x + (y - RY) * 2) % 4 == 1 and ri[k] >= 3 then c:put(x, y, Wk[min(6, ri[k] + 1)]) end end)
-- mushroom sits inside, in front of the back rim, its stem foot hidden in the dark interior
c:paint({ "..hhh..", ".hHrrr.", "hHrrrrd", "rrdddd.", "..csk..", "..csk..", "..csk..", "..ksk.." }, 22, 23,
  { h = "#ff9a72", H = "#fff4d6", r = "#e8493b", d = "#a82e3f", c = "#fff1cf", s = "#e9d6b4", k = "#b7a08a" })
-- broken: hole in the lower-right wall, sprung weaver ends
local hole = c:poly{ { 38, 43 }, { 42, 41 }, { 46, 43 }, { 46, 47 }, { 43, 50 }, { 39, 49 }, { 37, 46 } }
c:fillMask(hole, "#2e1a1c")
hole:each(function(x, y) if not hole:has(x, y - 1) then c:put(x, y, "#4a2a26") end end)
for _, p in ipairs{ { 39, 44, 5 }, { 40, 45, 3 }, { 45, 45, 5 }, { 44, 46, 3 }, { 41, 48, 4 }, { 42, 42, 6 } } do c:put(p[1], p[2], Wk[p[3]]) end
-- sprung end poking out of the wall + flying bit of cane
c:put(47, 42, Wk[5]) c:put(48, 41, Wk[4])
c:paint({ "..a", ".ab", "ab." }, 51, 44, { a = Wk[5], b = Wk[3] })
-- one glint on the rim
c:put(16, 30, A.SPEC)
A.save(c)

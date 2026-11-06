-- harvest-trug (final, Opus aC11_0). A Sussex garden trug: long shallow boat-shaped hull of overlapping thin willow
-- boards, a pale split-chestnut rim with copper nails, two little feet, and a slim bent-wood handle arching high over
-- the middle; three red apples and a leaf sit inside. Material: per-pixel hull light (cylinder along the length),
-- board laps (dark under-edge + lit top lip) with wood grain, end-grain pale on the rim ends, copper nail glints,
-- handle as a lit tube with grain, glossy apples (bloom + one specular + cool bounce), AO in the hull mouth.
-- quirk: a tiny snail is crawling over the top of the handle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt = math.max, math.min, math.floor, math.abs, math.sqrt
local c = A.new("harvest-trug")
local WIL = { "#4a2a24", "#6e4030", "#955c3c", "#b97d4e", "#d6a066", "#efc88c" }
local CHE = { "#5a3b2c", "#86603e", "#b08a5a", "#d2b17c", "#ecd4a0", "#fbecc4" }
local APL = { "#5a1530", "#8e2236", "#c4303a", "#e64c3e", "#ff7d5a", "#ffb48a" }
local COP = "#e88a4a"
local tH, tB, tR, tA = A.tok("handle"), A.tok("hull"), A.tok("rim"), A.tok("apple")

c:groundShadow(32, 52, 20, 2)

-- handle: slim bent-wood arch (painted first; rim and hull overlap its feet)
local hm, hn, HT, HS = A.tube({ {15,38},{14,8},{50,8},{49,38} }, function(t) return 1.6 end)
local hidx = A.shade(c, hm, hn, CHE, { tok = tH, amb = 0.1, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  if HS[k] and abs(HS[k]) < 0.25 and floor(HT[k] * 40) % 5 == 0 then c:put(x, y, CHE[max(1, (hidx[k] or 3) - 1)], tH) end
end)

-- inner back wall (seen through the mouth): dark boards
local mouth = c:ellipse(32, 34, 22, 4)
mouth:each(function(x, y)
  local col = WIL[1]
  if y <= 32 then col = ((y + floor(x / 9)) % 2 == 0) and WIL[2] or WIL[3] end
  if y == 31 then col = WIL[3] end
  c:put(x, y, col, tB)
end)

-- apples (sit in the hull, tops above the rim)
local apples = { { 25, 30, 4 }, { 33, 29, 4.5 }, { 41, 31, 3.5 } }
for i, a in ipairs(apples) do
  local m = c:ellipse(a[1], a[2], a[3], a[3] - 0.5)
  local n = X.sphere(a[1] - 0.6, a[2] - 0.8, a[3], m)
  local idx = A.shade(c, m, n, APL, { tok = { r = { name = "apple" .. i } }, amb = 0.08 })
  -- waxy bloom: a few paler pixels on the upper body
  m:each(function(x, y) if X.hash(x, y, i) < 0.08 and (idx[K(x, y)] or 1) >= 3 and (idx[K(x, y)] or 1) <= 4 then c:put(x, y, APL[5]) end end)
  -- cool bounce on lower right edge
  m:edge():each(function(x, y) if x > a[1] and y > a[2] then c:put(x, y, "#a8466e") end end)
  -- stem dimple + stem
  c:put(floor(a[1]), floor(a[2] - a[3] + 1), APL[1])
  c:put(floor(a[1]) + 1, floor(a[2] - a[3]), "#6e4030")
  c:put(floor(a[1]) + 1, floor(a[2] - a[3]) - 1, "#955c3c")
  -- specular
  c:put(floor(a[1] - a[3] * 0.45), floor(a[2] - a[3] * 0.45), A.CREAM)
end
-- one leaf on the middle apple stem
A.map(c, {
  "..lLL",
  ".lLMh",
  "dlM..",
}, 35, 21, { l = "#3f9150", L = "#7cc35a", M = "#c4e07a", h = "#c4e07a", d = "#24544a" }, A.tok("leaf"))

-- hull: shallow boat curve below the rim
local hull = HP.mask()
for x = 10, 54 do
  local u = (x - 32) / 22.5
  local bot = 34 + floor(14 * sqrt(max(0, 1 - u * u)) ^ 0.9 + .5)
  local top = 34 + floor(3.5 * sqrt(max(0, 1 - u * u)) + .5)
  for y = top, bot do hull:set(x, y) end
end
-- normals: round across the depth (y) and around the ends (x)
local hn2 = {}
hull:each(function(x, y)
  local u = (x - 32) / 25
  local depth = 34 + 14 * sqrt(max(0, 1 - u * u)) ^ 0.9
  local top = 34 + 3.5 * sqrt(max(0, 1 - u * u))
  local s = (y - top) / max(1, depth - top)            -- 0 top .. 1 keel
  hn2[K(x, y)] = { A.norm(u * 0.8, (s - 0.35) * 1.3, 1) }
end)
local bias = {}
-- board laps every 3 rows following the hull curve
hull:each(function(x, y)
  local u = (x - 32) / 25
  local top = 34 + 3.5 * sqrt(max(0, 1 - u * u))
  local r = (y - top) % 3.4
  local k = K(x, y)
  if r < 1 then bias[k] = -2 elseif r < 2 then bias[k] = 1 end
end)
local idx = A.shade(c, hull, hn2, WIL, { tok = tB, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- grain flecks along boards
hull:each(function(x, y) local k = K(x, y) if X.hash(x, y, 11) < 0.07 and (bias[k] or 0) == 0 then
  c:put(x, y, WIL[max(1, (idx[k] or 3) - 1)], tB) end end)
-- feet battens
for _, fx in ipairs{ 22, 40 } do
  for x = fx, fx + 3 do c:put(x, 49, WIL[2], tB) c:put(x, 50, WIL[1], tB) end
  c:put(fx, 49, WIL[4], tB)
end

-- rim: split chestnut band riding over the hull mouth (front arc), pale end grain at each end
local rim = HP.mask()
for x = 9, 55 do
  local u = (x - 32) / 23
  local yy = 34 + 3.6 * sqrt(max(0, 1 - u * u))
  for d = 0, 1 do rim:set(x, floor(yy + .5) + d) end
end
rim:add(c:rect(8, 33, 10, 35)):add(c:rect(54, 33, 56, 35))
rim:each(function(x, y)
  local u = (x - 32) / 23
  local yy = floor(34 + 3.6 * sqrt(max(0, 1 - u * u)) + .5)
  local col = (y == yy) and CHE[5] or CHE[3]
  if x < 20 and y == yy then col = CHE[6] end
  if x > 46 and y ~= yy then col = CHE[2] end
  c:put(x, y, col, tR)
end)
-- end grain caps
c:put(8, 33, CHE[6], tR) c:put(9, 33, CHE[5], tR) c:put(8, 34, CHE[4], tR) c:put(8, 35, CHE[3], tR)
c:put(56, 33, CHE[4], tR) c:put(56, 34, CHE[2], tR) c:put(56, 35, CHE[1], tR)
-- handle feet over the rim (riveted)
for _, hx in ipairs{ 14, 49 } do
  for y = 35, 40 do c:put(hx, y, CHE[4], tH) c:put(hx + 1, y, CHE[3], tH) c:put(hx + 2, y, CHE[2], tH) end
  c:put(hx + 1, 38, COP, tH)
end
-- copper nails along the rim
for x = 20, 46, 6 do
  local u = (x - 32) / 23
  local yy = floor(34 + 3.6 * sqrt(max(0, 1 - u * u)) + .5)
  c:put(x, yy + 1, COP, tR)
end
-- AO in the mouth just behind the rim
for x = 10, 54 do local u = (x - 32) / 23 local yy = floor(34 + 3.6 * sqrt(max(0, 1 - u * u)) + .5)
  if mouth:has(x, yy - 1) and not (c:get(x, yy - 1) or ""):match("^#[ef]") then
    local cur = c:get(x, yy - 1)
    if cur == WIL[2] or cur == WIL[3] then c:put(x, yy - 1, WIL[1], tB) end
  end
end

-- quirk: a tiny snail climbing the right leg of the handle
A.map(c, {
  "..sSs..",
  ".sShSs.",
  ".sSsSsb",
  "bbbbbbb",
}, 37, 12, { s = "#c98a5a", S = "#e8b982", h = "#fff1cf", b = "#b9aaa0" }, A.tok("snail"))
c:put(37, 11, "#b9aaa0") c:put(37, 10, "#2b1c26")
for x = 38, 44 do if not hm:has(x, 16) and not hm:has(x, 15) then c:put(x, 16, "#b9aaa0", A.tok("snail")) end end

A.save(c, "harvest-trug")

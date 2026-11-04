-- feast-isles-ackee-pot (final, Opus single pass). A slim cast-iron "dutchie" pot (straight sides, rounded base, two
-- ear handles) heaped with ackee and saltfish: soft butter-yellow lobes, cream fish flakes, red pepper and scallion bits.
-- A wooden spoon leans out to the right; a split red ackee pod sits on the left rim showing its cream aril and black seed.
-- Material: per-pixel cylinder light on iron (cool violet ramp), bevelled lip with a bright edge, vertical specular streak,
-- cool bounce lower-right; dark interior AO under the heap; lobes lit one by one with a darker seam where they meet;
-- spoon wood grain and pale end grain; glossy seed. quirk: one black ackee seed has rolled off onto the ground.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local norm = A.norm
local c = A.new("feast-isles-ackee-pot")

local IRON = { "#17121f", "#272035", "#3a3150", "#53486c", "#74688f", "#a094b8" }
local ACK  = { "#6e4a1c", "#a8741f", "#d8a42c", "#f0c94a", "#fbe17a", "#fff4bc" }
local WOOD = { "#3e2020", "#6a3a26", "#94582f", "#ba7c40", "#d8a25a", "#f0c98a" }
local POD  = { "#45121f", "#781b27", "#ad2a2b", "#d84932", "#f27a46", "#ffb47e" }
local SEED = { "#0f0b14", "#1c1522", "#2b2333", "#3d3349", "#5a4e6a", "#8c80a0" }
local FISH = { "#cdbda4", "#efe4cf" }
local SPEC = "#fff4d6"
local cx, ly = 32, 30

-- ground shadow
c:groundShadow(cx, 51, 19, 3)

-- ear handles (behind the body)
local function earM(hx, side)
  return A.pmask(hx - 4, 31, hx + 4, 39, function(x, y)
    local d = sqrt((x - hx)^2 + ((y - 35) * 1.15)^2)
    return d <= 3.4 and d >= 1.4 and (x - hx) * side >= -0.5
  end)
end
for _, e in ipairs({ { 14, -1 }, { 50, 1 } }) do
  local m = earM(e[1], e[2])
  local n = {}
  m:each(function(x, y) local dx, dy = x - e[1], (y - 35) * 1.15 local d = sqrt(dx*dx + dy*dy) local s = (d - 2.4) n[K(x, y)] = { norm(dx / d * s, dy / d * s, 1) } end)
  A.shade(c, m, n, IRON, { amb = 0.08, wrap = 0.2 })
end

-- body: straight sides, rounded base
local function half(y)
  if y < 44 then return 17.5 - ((y - 37) / 7)^2 * 0.6 end
  local q = 1 - ((y - 44) / 7.5)^2
  return q > 0 and 17.5 * sqrt(q) or -1
end
local body = A.pmask(cx - 19, ly, cx + 19, 52, function(x, y) local h = half(y) return h > 0 and abs(x - cx + 0.5) <= h end)
local bb = {}
body:each(function(x, y) if y <= ly + 1 then bb[K(x, y)] = -1 end end)
local bidx, bn = A.vcyl(c, body, IRON, cx - 18, cx + 17, { amb = 0.08, wrap = 0.25, bias = bb,
  ny = function(x, y) return y > 44 and (y - 44) / 7.5 * 1.1 or -0.1 end })
-- cool bounce lower-right, specular streak upper-left, a cast seam
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > 38 then c:put(x, y, "#5c5a86") end end)
for y = 34, 43 do c:put(cx - 11, y, y < 37 and SPEC or IRON[6]) end
for y = 35, 41 do c:put(cx - 10, y, IRON[5]) end
for x = cx - 14, cx + 13 do local y = 45 + floor(((x - cx) / 17)^2 * 2) if body:has(x, y) then c:put(x, y, IRON[max(1, (bidx[K(x, y)] or 3) - 1)]) end end

-- lip: thick bevelled ring
local lo = A.emask(cx - 0.5, ly, 18.5, 5.5)
local li = A.emask(cx - 0.5, ly + 0.4, 15.5, 4)
local lip = lo:copy():cut(li)
local lnorm = {}
lip:each(function(x, y) local u, v = (x - cx + 0.5) / 18.5, (y - ly) / 5.5 local rr = sqrt(u*u + v*v) local s = (rr - 0.9) / 0.12
  lnorm[K(x, y)] = { norm(u / rr * s, v / rr * s * 0.8, 1) } end)
-- interior: dark iron (deep under the heap)
li:each(function(x, y) c:put(x, y, y < ly - 1 and IRON[2] or IRON[1]) end)
local lidx = A.shade(c, lip, lnorm, IRON, { amb = 0.12, wrap = 0.3 })
lip:each(function(x, y) local u = (x - cx) / 18.5 if (lidx[K(x, y)] or 0) >= 5 and y < ly - 2 and u < -0.15 then c:put(x, y, IRON[6]) end end)
c:put(cx - 9, ly - 5, SPEC) c:put(cx - 8, ly - 5, SPEC)

-- spoon (handle leaning right, bowl buried in the heap)
local sm, sn, ST, SS = A.stem(c, { { cx + 4, ly - 1 }, { cx + 9, ly - 8 }, { cx + 14, ly - 14 }, { cx + 18, ly - 20 } },
  function(t) return t > 0.92 and 1.9 or 1.5 end, WOOD, { amb = 0.12 })
sm:each(function(x, y) local k = K(x, y)
  if abs(SS[k] - 0.25) < 0.2 and floor(ST[k] * 30) % 4 ~= 0 then c:put(x, y, WOOD[2]) end
  if ST[k] > 0.97 then c:put(x, y, WOOD[6]) end end)

-- ackee heap: lobes, back to front
local lobes = {
  { 24, 26, 3.6, 2.6, 0.3 }, { 31, 24, 3.8, 2.7, -0.2 }, { 38, 25.5, 3.4, 2.5, 0.4 },
  { 20, 29, 3.2, 2.3, -0.3 }, { 27, 28.5, 3.6, 2.5, 0.1 }, { 34, 28, 3.6, 2.6, -0.4 }, { 41, 29, 3.2, 2.3, 0.2 },
  { 23.5, 31, 3.2, 2.0, 0.0 }, { 30.5, 31.2, 3.4, 2.0, 0.2 }, { 37.5, 31, 3.2, 2.0, -0.2 },
}
local frontLip = HP.mask()
lip:each(function(x, y) if y > ly + 1 then frontLip:set(x, y) end end)
local heap = HP.mask()
for i, L in ipairs(lobes) do
  local m, n = A.oval(L[1], L[2], L[3], L[4], L[5], 0.8)
  m:cut(frontLip)
  local bias = {}
  A.contact(bias, m, heap, 0, 0, 0)
  local idx = A.shade(c, m, n, ACK, { amb = 0.12, wrap = 0.3, bias = bias })
  -- seam where this lobe lies over earlier lobes
  m:edge():each(function(x, y)
    if heap:has(x, y + 1) or heap:has(x + 1, y) or heap:has(x - 1, y) then c:put(x, y, ACK[2]) end end)
  -- waxy sheen
  local bx, by = A.specAt(m, n, 30)
  if bx and i % 2 == 1 then c:put(bx, by, ACK[6]) end
  heap:add(m)
end
-- saltfish flakes, pepper and scallion
local flakes = { { 28, 26, 1 }, { 35, 24, 1 }, { 22, 30, 1 }, { 33, 30, 1 }, { 39, 28, 1 }, { 26, 31, 0 } }
for _, f in ipairs(flakes) do c:put(f[1], f[2], FISH[2]) c:put(f[1] + 1, f[2], FISH[1]) if f[3] == 1 then c:put(f[1], f[2] + 1, FISH[1]) end end
for _, p in ipairs({ { 30, 27 }, { 37, 30 }, { 24, 28 }, { 41, 27 } }) do c:put(p[1], p[2], "#e2412f") end
for _, p in ipairs({ { 33, 26 }, { 27, 30 }, { 36, 27 }, { 21, 28 } }) do c:put(p[1], p[2], "#5fae4c") end
-- interior shadow line where the heap meets the front lip
frontLip:each(function(x, y) if heap:has(x, y - 1) and y == floor(ly + 0.4 + 4 * sqrt(max(0, 1 - ((x - cx + 0.5) / 15.5)^2))) + 1 then c:put(x, y, IRON[3]) end end)

-- split ackee pod on the left rim
local function lit(m, n, ramp, b) return A.shade(c, m, n, ramp, { amb = 0.1, wrap = 0.3, bias = b }) end
local pm, pn = A.oval(12, 27, 3.6, 4.8, 0.15, 0.9)
lit(pm, pn, POD)
for _, v in ipairs({ { 8.6, 22.6, -0.7 }, { 15.6, 22.8, 0.7 } }) do
  local m, n = A.oval(v[1], v[2], 1.6, 3.4, v[3], 0.8)
  lit(m, n, POD)
end
local am, an = A.oval(12, 22.8, 2.6, 2.0, 0, 0.9)
lit(am, an, { "#b0864a", "#d4ad6c", "#ead09a", "#f6e4b8", "#fff2d4", "#fff8e6" })
local sdm, sdn = A.oval(12, 19.6, 2.2, 2.2, 0, 1)
lit(sdm, sdn, SEED)
c:put(11, 18, SPEC)
for y = 25, 30 do c:put(14, y, POD[2]) end -- valve suture
c:put(12, 32, "#4a6a2e") c:put(13, 32, "#33502a")

-- quirk: a black seed rolled off onto the ground
local qm, qn = A.oval(54, 50, 2.0, 1.8, 0, 1)
lit(qm, qn, SEED)
c:put(53, 49, SPEC)
c:put(52, 48, "#f6e4b8") c:put(53, 48, "#fff2d4")
A.save(c, "feast-isles-ackee-pot")

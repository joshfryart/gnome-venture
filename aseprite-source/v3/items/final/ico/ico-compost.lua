-- ico-compost (final, Opus). Slatted wooden compost bin seen from the front: two square posts with pale end grain,
-- three planks with dark gaps showing the rich soil inside, and a crumbly heap rising out of the top topped with
-- scraps: a banana peel, a cracked eggshell half and a veined lettuce leaf.
-- Material: planks = per-row bevel (lit top edge, dark under-edge) with grain streaks, a knot and nail heads; posts =
-- vertical cylinder light with end grain rings; heap = dome light with crumb speckle; scraps get contact shadows;
-- AO under each plank in the gaps and beside the posts; 2-tone ground shadow.
-- quirk: a pink earthworm loops out of the lower gap to have a look around.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-compost")
local SOIL = { "#1e1216", "#33201e", "#4c3026", "#68432e", "#86593a", "#a87650" }
local WD = { "#3e2422", "#5e3628", "#864c33", "#b07040", "#d49a5e", "#f0c890" }
local PO = { "#33222a", "#53372f", "#78523a", "#9e744a", "#c49c68", "#e6c892" }
local APL = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local FL = { "#c9a878", "#ecd8a8", "#fff1c8" }
local LF = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local EG = { "#9e8a7a", "#cdbba4", "#ece0c8", "#fff4d6" }
local WRM = { "#8a3a52", "#c95f7e", "#f08aa4", "#ffc4d8" }
local X0, X1 = 11, 52           -- bin extent
local PW = 4                    -- post width
local BOARDS = { { 32, 37 }, { 40, 45 }, { 48, 53 } }
local stok, wtok, ptok = A.tok("soil"), A.tok("plank"), A.tok("post")

c:groundShadow(31.5, 56, 22, 1.5)

-- soil behind the planks (seen through the gaps)
local inside = HP.rect(X0 + PW, 32, X1 - PW, 53)
inside:each(function(x, y)
  local t = 2
  for _, b in ipairs(BOARDS) do if y == b[2] + 1 then t = 1 end end
  if X.hash(x, y, 3) > 0.86 then t = t + 1 end
  c:put(x, y, SOIL[t], stok)
end)

-- heap: dome rising out of the top
local heap = A.ell(31.5, 33, 18.5, 14)
heap:cut(HP.rect(0, 34, 63, 63))
heap:cut(HP.rect(0, 0, X0 + 2, 63)):cut(HP.rect(X1 - 2, 0, 63, 63))
local nH = X.sphere(30.5, 34, 18, heap)
for k, n in pairs(nH) do nH[k] = { n[1] * 1.0, n[2] * 1.25, n[3] } end
local biasH = {}
local idxH = A.shade(c, heap, nH, SOIL, { tok = stok, bias = biasH, amb = 0.08, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- crumb speckle: lit crumbs and dark pores
heap:each(function(x, y)
  local h = X.hash(x, y, 11)
  if h > 0.88 then A.step(c, idxH, SOIL, x, y, 1, stok) if heap:has(x + 1, y + 1) then A.step(c, idxH, SOIL, x + 1, y + 1, -2, stok) end
  elseif h < 0.07 then A.step(c, idxH, SOIL, x, y, -1, stok) end
end)
-- a twig poking out of the heap
for i = 0, 4 do c:put(40 + i, 22 - floor(i * 0.6), i < 2 and WD[3] or WD[5], A.tok("twig")) end

-- scraps (each casts a 1 px contact shadow on the heap, lower-right)
local function contact(m)
  m:copy():shift(1, 1):each(function(x, y) if heap:has(x, y) and not m:has(x, y) then c:put(x, y, SOIL[1], stok) end end)
end
-- lettuce leaf lying across the top (veined)
local lm, ln, LT, LS = A.tube({ { 24, 23 }, { 28, 18 }, { 34, 17 }, { 38, 20 } }, function(t) return 3.4 * sin(pi * min(1, t * 1.05)) ^ 0.7 + 0.2 end)
contact(lm)
local lv = A.val(ln, { amb = 0.15, wrap = 0.3 })
local ltok = A.tok("leaf")
lm:each(function(x, y) local k = K(x, y) local v = lv[k]
  local i = v > 0.8 and 4 or v > 0.55 and 3 or v > 0.3 and 2 or 1
  c:put(x, y, LF[i], ltok) end)
-- midrib + veins
for i = 0, 40 do local t = 0.08 + i / 40 * 0.84 local x, y = A.bez({ { 24, 23 }, { 28, 18 }, { 34, 17 }, { 38, 20 } }, t)
  c:put(floor(x + .5), floor(y + .5), LF[4], ltok) end
for _, v in ipairs{ { 27, 22 }, { 31, 21 }, { 35, 20 } } do c:put(v[1], v[2], LF[2], ltok) c:put(v[1] + 1, v[2] - 1, LF[2], ltok) end
-- banana peel (left): three splayed flaps, the left one drooping over the rim, a brown stem nub
local BAN = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local btk = A.tok("peel")
local flaps = {
  { { 20, 25 }, { 16, 24 }, { 13, 26 }, { 12, 31 } },
  { { 20, 25 }, { 19, 21 }, { 17, 18 }, { 15, 17 } },
  { { 20, 25 }, { 23, 22 }, { 25, 22 }, { 26, 26 } },
}
local peel = HP.mask()
local parts = {}
for _, f in ipairs(flaps) do
  local m, n, T = A.tube(f, function(t) return 1.9 - 0.7 * t end)
  parts[#parts + 1] = { m = m, n = n, T = T }
  peel:add(m)
end
contact(peel)
for fi, p in ipairs(parts) do
  local v = A.val(p.n, { amb = 0.12, wrap = 0.3 })
  p.m:each(function(x, y) local k = K(x, y) local t = v[k]
    local i = t > 0.8 and 4 or t > 0.55 and 3 or t > 0.3 and 2 or 1
    if p.T[k] > 0.9 then i = 1 end            -- bruised brown tips
    c:put(x, y, BAN[i], btk) end)
end
-- pale inner flesh side on the middle flap, stem nub, one glint
c:put(18, 21, "#fff1c8", btk) c:put(18, 22, "#fff1c8", btk)
c:put(20, 25, BAN[1], btk) c:put(21, 25, BAN[1], btk) c:put(20, 26, "#5a3220", btk) c:put(21, 26, "#5a3220", btk)
c:put(24, 22, A.CREAM, btk)
-- eggshell half (right): cup with a jagged rim, inside shadowed
local egg = A.ell(43, 27, 4.6, 3.8)
egg:cut(HP.rect(0, 0, 63, 24))
for x = 38, 48 do if x % 2 == 0 then egg:set(x, 24) end end
contact(egg)
local nEg = X.sphere(42.5, 26, 5, egg)
local ev = A.val(nEg, { amb = 0.12 })
local etok = A.tok("egg")
egg:each(function(x, y) local v = ev[K(x, y)]
  c:put(x, y, v > 0.8 and EG[4] or v > 0.55 and EG[3] or v > 0.3 and EG[2] or EG[1], etok) end)
-- inner hollow (darker cream crescent along the top)
for x = 40, 46 do c:put(x, 25, EG[2], etok) end
for x = 41, 45 do c:put(x, 26, EG[1], etok) end
c:put(40, 27, EG[4], etok)

-- planks
for bi, b in ipairs(BOARDS) do
  local m = HP.rect(X0, b[1], X1, b[2])
  local n = {}
  m:each(function(x, y)
    local ny = (y == b[1]) and -0.75 or (y == b[2]) and 0.8 or (y == b[2] - 1) and 0.3 or 0
    n[K(x, y)] = { 0, ny, sqrt(1 - ny * ny) }
  end)
  local bias = {}
  -- AO: shadow cast by the left post to its right, and the heap/soil above the top plank
  m:each(function(x, y) if x >= X0 + PW and x <= X0 + PW + 1 and y > b[1] then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, WD, { tok = wtok, bias = bias, amb = 0.1, wrap = 0.3, tilt = { 31.5, 42, 24, 0.18 },
    cuts = { 0.2, 0.36, 0.52, 0.68, 0.9 } })
  -- grain streaks
  for y = b[1] + 1, b[2] - 2 do
    local x = X0 + PW
    while x < X1 - PW do
      local h = X.hash(x, y, bi * 7)
      if h > 0.62 then
        local L = 3 + floor(h * 8)
        for xx = x, min(X1 - PW, x + L) do A.step(c, idx, WD, xx, y, -1, wtok) end
        x = x + L + 3
      else x = x + 2 end
    end
  end
  -- nail heads near each post
  for _, nx in ipairs{ X0 + PW + 1, X1 - PW - 1 } do
    c:put(nx, b[1] + 2, "#3a3046", wtok) c:put(nx, b[1] + 1, "#9a98a8", wtok)
  end
end
-- knot in the middle plank
c:put(33, 42, WD[2], wtok) c:put(34, 42, WD[1], wtok) c:put(35, 42, WD[2], wtok) c:put(34, 43, WD[2], wtok)
c:put(32, 41, WD[2], wtok) c:put(36, 43, WD[2], wtok)

-- posts: vertical cylinders with end grain tops
for pi_, px0 in ipairs{ X0, X1 - PW + 1 } do
  local m = HP.rect(px0, 28, px0 + PW - 1, 55)
  local n = {}
  m:each(function(x, y) local u = ((x - px0) / (PW - 1)) * 1.6 - 0.8 n[K(x, y)] = { u, 0, sqrt(1 - u * u) } end)
  local idx = A.shade(c, m, n, PO, { tok = ptok, amb = 0.08, wrap = 0.2, tilt = { 31.5, 42, 26, 0.12 } })
  -- end grain: pale square top with a ring
  for x = px0, px0 + PW - 1 do c:put(x, 28, PO[6], ptok) c:put(x, 29, PO[5], ptok) end
  c:put(px0 + 1, 29, PO[4], ptok) c:put(px0 + 2, 28, PO[5], ptok)
  -- AO under the top plank... and a vertical crack line
  for y = 33, 50, 1 do if X.hash(px0, y, 5) > 0.45 then c:put(px0 + 1, y, PO[2], ptok) end end
  -- contact where planks meet the post (posts sit in front of plank ends)
end

-- quirk: earthworm looping out of the lower gap
local wtok2 = A.tok("worm")
local wp = { { 37, 46.5 }, { 38, 41.5 }, { 43, 41 }, { 44.5, 45.5 } }
local wm, wn = A.tube(wp, function(t) return 1.5 end)
wm:copy():shift(1, 1):each(function(x, y) if not wm:has(x, y) and c:get(x, y) then c:put(x, y, WD[1], wtok) end end)
local wv = A.val(wn, { amb = 0.15, wrap = 0.3 })
wm:each(function(x, y) local v = wv[K(x, y)]
  c:put(x, y, v > 0.78 and WRM[4] or v > 0.5 and WRM[3] or v > 0.25 and WRM[2] or WRM[1], wtok2) end)
-- segment rings
for _, t in ipairs{ 0.25, 0.5, 0.75 } do local x, y = A.bez(wp, t) c:put(floor(x + .5), floor(y + .5), WRM[2], wtok2) end
-- clitellum band and a glint on the head
do local x, y = A.bez(wp, 0.38) c:put(floor(x + .5), floor(y + .5), "#d0687a", wtok2) end
do local x, y = A.bez(wp, 0.96) c:put(floor(x + .5) - 1, floor(y + .5), A.CREAM, wtok2) end
A.save(c, "ico-compost")

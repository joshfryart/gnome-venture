-- gnat-dust (final pass, Opus). A small burlap drawstring pouch, its mouth ruffled open on a dome of shimmering
-- lilac gnat dust, with a spilled heap of the same dust beside it. Burlap: pillow light, diagonal weave, ruffle folds,
-- a twisted gold drawstring with a bow and a dangling end. Dust: soft mound light plus iridescent single-pixel glints.
-- Ambient shading where the heap meets the pouch, ground shadow under both.
-- quirk: a single gnat hovers over the heap, still looking for the rest of itself.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("gnat-dust")
local SACK = { "#4a2c2c", "#6e4432", "#94603a", "#b8804a", "#d6a46a", "#ecca94" }
local DUST = { "#3e3658", "#5e5480", "#867ca6", "#ada4c6", "#d2cade", "#efe8f2" }
local CORD = { "#6e3a24", "#a8642a", "#d89a36", "#f5c454", "#ffe48e" }
local GLINT = { "#9fe8e0", "#ffd88a", "#ffc0d8" }
local tK, tD, tC = { r = { name = "sack" } }, { r = { name = "dust" } }, { r = { name = "cord" } }

c:groundShadow(33, 53, 18, 2)

-- pouch body: slim pear, pinched at the neck
local body = c:ellipse(26, 41, 9, 11)
body:add(c:ellipse(26, 33, 6, 5))
body:cut(c:rect(10, 53, 50, 60))
local bn = X.pillow(body, 5)
local bb = {}
local bi = A.shade(c, body, bn, SACK, { tok = tK, bias = bb })
-- weave: diagonal twill, one step darker every third diagonal, cross threads lighter
body:each(function(x, y) local k = K(x, y) local i = bi[k]
  if (x + y) % 3 == 0 and (x - y) % 2 == 0 then A.step(c, bi, SACK, x, y, -1, tK)
  elseif (x - y) % 4 == 0 and i < 5 and X.hash(x, y, 3) > 0.5 then A.step(c, bi, SACK, x, y, 1, tK) end end)
-- belly fold
for _, p in ipairs{ { 29, 40 }, { 30, 41 }, { 31, 43 }, { 31, 44 } } do A.step(c, bi, SACK, p[1], p[2], -2, tK) end
for _, p in ipairs{ { 28, 40 }, { 29, 42 }, { 30, 44 } } do A.step(c, bi, SACK, p[1], p[2], 1, tK) end

-- neck cinch (dark row) and ruffled mouth
for x = 20, 32 do if body:has(x, 29) then c:put(x, 29, SACK[1], tK) end end
local ruff = c:poly{ { 18, 23 }, { 21, 25 }, { 24, 22 }, { 27, 25 }, { 30, 22 }, { 33, 25 }, { 35, 23 }, { 33, 28 }, { 20, 28 } }
local rn = X.pillow(ruff, 2)
ruff:each(function(x, y) local k = K(x, y) local a = rn[k] rn[k] = { A.norm(a[1] + math.sin(x * 1.1) * 0.6, a[2], a[3]) } end)
local ri = A.shade(c, ruff, rn, SACK, { tok = tK })
-- dust dome in the mouth
local dome = c:ellipse(26.5, 22, 6, 3):cut(c:rect(10, 24, 50, 40))
A.shade(c, dome, X.sphere(25.5, 23, 6, dome), DUST, { tok = tD })
-- inner lip shadow under the dome
for x = 21, 32 do if ruff:has(x, 24) or ruff:has(x, 23) then c:put(x, 24, SACK[1], tK) end end
for x = 21, 32 do if ruff:has(x, 25) and (x % 3 ~= 0) then A.step(c, ri, SACK, x, 25, -1, tK) end end

-- drawstring: twisted gold cord around the neck, bow, dangling end
A.cord(c, { { 17, 30 }, { 22, 31.5 }, { 30, 31.5 }, { 35, 29.5 } }, 0.9, CORD, { tok = tC, per = 2.2 })
local bowL = c:ellipse(37, 27, 2, 1.5) local bowR = c:ellipse(38, 31, 1.5, 2)
for _, m in ipairs{ bowL, bowR } do
  local inner = m:shrink(1)
  A.shade(c, m, X.pillow(m, 1.5), CORD, { tok = tC })
  inner:each(function(x, y) c:put(x, y, CORD[1], tC) end)
end
local bk = c:rect(35, 29, 36, 30)
A.shade(c, bk, X.sphere(35.3, 29.3, 1.5, bk), CORD, { tok = tC })
A.cord(c, { { 35, 31 }, { 35, 35 }, { 37, 38 }, { 36, 42 } }, 0.7, CORD, { tok = tC })
c:put(36, 43, CORD[4], tC) c:put(35, 43, CORD[2], tC) -- frayed tip
c:put(37, 27, CORD[1], tC)

-- spilled heap beside the pouch
local heap = c:ellipse(43, 52, 9, 5):cut(c:rect(30, 53, 56, 60))
heap:add(c:ellipse(41, 50, 4, 3))
heap:cut(c:rect(30, 53, 56, 60))
local hn = X.pillow(heap, 4, 0.8)
local hb = {}
-- AO where the heap leans on the pouch
heap:each(function(x, y) if x <= 36 then hb[K(x, y)] = -1 end end)
local hi = A.shade(c, heap, hn, DUST, { tok = tD, bias = hb })
-- powder texture: soft ridges + iridescent glints (glints on dust are allowed: glittering material)
heap:each(function(x, y) local h = X.hash(x, y, 11) local i = hi[K(x, y)]
  if h < 0.1 and i and i > 2 then A.step(c, hi, DUST, x, y, -1, tD)
  elseif h > 0.94 and i and i >= 3 then c:put(x, y, GLINT[1 + floor(X.hash(y, x, 5) * 3)], tD) end end)
dome:each(function(x, y) if X.hash(x, y, 13) > 0.9 then c:put(x, y, GLINT[1 + floor(X.hash(y, x, 9) * 3)], tD) end end)
-- a few motes rolling off the heap edge
c:put(53, 52, DUST[4], tD) c:put(51, 50, DUST[5], tD)
c:put(39, 47, A.CREAM, tD) c:put(40, 47, DUST[6], tD)

-- quirk: a gnat hovering above the heap
local gn = {
  "w.w",
  ".k.",
}
local GC = { w = "#c8e0ec", k = "#3a2a3a" }
for yy, row in ipairs(gn) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if GC[ch] then c:put(44 + xx, 36 + yy, GC[ch]) end end end
c:put(47, 38, "#3a2a3a")

A.save(c, "gnat-dust")

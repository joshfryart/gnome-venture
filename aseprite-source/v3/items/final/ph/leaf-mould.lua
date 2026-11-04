-- leaf-mould (final, Opus single pass). A slim hessian sack (crosshatch weave, rolled-down rim with AO under it, a
-- twine tie, cool bounce on the shade side) heaped with dark crumbly leaf mould: lit crumbs, rusty leaf flecks and one
-- pale lacy skeleton leaf standing up out of the heap. Ground shadow.
-- quirk: a little grey woodlouse is climbing the side of the sack.
local NAME = "leaf-mould"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SACK = { "#4a2e22", "#6e4a30", "#93673f", "#b5874f", "#d3a866", "#ecca8a" }
local MOULD = { "#1a110f", "#2a1c17", "#3e2a1e", "#563b26", "#714f30", "#8c6a40" }
local RUST = { "#7a2e1e", "#b0502a", "#d9803a" }
local SKEL = { "#8a6a44", "#c9a670", "#efd9a6" }
local LOUSE = { "#3c3c52", "#5f6078", "#8a8ca2", "#b9bccb" }
local TWINE = { "#7a5a2a", "#b38a44", "#e2c27a" }
local COOL = "#5a6c8a"

c:groundShadow(32, 57, 18, 2)

-- sack body: tapers in toward the neck, bulges at the base
local body = HP.mask()
for y = 27, 56 do
  local f = (y - 27) / 29
  local hw = 13 + 3.2 * sin(pi * min(1, f * 0.85 + 0.1)) - (y > 54 and (y - 54) * 1.5 or 0)
  for x = floor(32 - hw), floor(32 + hw - 0.01) do body:set(x, y) end
end
-- rolled rim: a fat band wider than the neck
local rim = HP.mask()
for y = 23, 28 do
  local hw = 15.5 - ((y == 23 or y == 28) and 1 or 0)
  for x = floor(32 - hw), floor(32 + hw - 0.01) do rim:set(x, y) end
end
body:cut(rim)
-- heap of mould above the rim
local heap = HP.mask()
heap:add(A.rell(32, 23, 1, 0, 13.5, 7.5)):add(A.rell(25, 22, 1, 0, 6, 5)):add(A.rell(37, 19, 1, 0, 6.5, 5.5))
heap:cut(rim):cut(body)
local hb = {}
for y = 23, 24 do for x = 10, 54 do local k = K(x, y) if heap:has(x, y) then hb[k] = -1 end end end

-- body shading: cylinder-ish across, weave pattern
local bias = {}
X.ao(bias, body, rim, 2, -1)
local bn = A.body(body, 27, 38, 18, 6, 0.45)
local btok = { r = { name = "sack" } }
local bidx = A.shade(c, body, bn, SACK, { bias = bias, tok = btok, amb = 0.12, wrap = 0.25 })
body:each(function(x, y) local k = K(x, y)
  local i = bidx[k]
  -- crosshatch weave: warp columns and weft rows, offset
  if (x % 3 == 0 and y % 2 == 0) or (y % 3 == 1 and x % 2 == 1) then i = i - 1 end
  if (x + y) % 6 == 0 and i >= 4 then i = i + 1 end
  i = max(1, min(6, i))
  c:put(x, y, SACK[i], btok)
end)
body:edge():each(function(x, y)
  if x > 40 and y > 34 and y < 54 then c:put(x, y, COOL, btok) end end)
-- seam with stitch down the right front
local stitch = {}
for y = 31, 53 do local x = floor(43 + 1.5 * sin((y - 31) / 22 * pi) + 0.5) stitch[#stitch + 1] = { x, y } end
c:stitch{ { 43, 31 }, { 44, 42 }, { 43, 53 } }

-- rim: rolled cloth, lit on top, dark crease under
local rtok = { r = { name = "rim" } }
local rn = {}
rim:each(function(x, y) local fy = (y - 25.5) / 3.5 local fx = (x - 32) / 17
  rn[K(x, y)] = { A.norm(fx * 0.6, fy, sqrt(max(0.05, 1 - fy * fy))) } end)
local rb = {}
X.ao(rb, rim, heap, 1, -1)
local ridx = A.shade(c, rim, rn, SACK, { bias = rb, tok = rtok, amb = 0.1, wrap = 0.25 })
rim:each(function(x, y) if (x * 2 + y) % 5 == 0 then A.step(c, ridx, SACK, x, y, -1, rtok) end end)
-- rim folds
for _, fx in ipairs{ 22, 31, 41 } do for y = 24, 27 do A.step(c, ridx, SACK, fx, y, -2, rtok) end end
-- twine tie hanging off the rim on the left
local ttok = { r = { name = "twine" } }
local tw = { { 18, 27 }, { 18, 28 }, { 17, 29 }, { 17, 30 }, { 16, 31 }, { 16, 32 }, { 15, 33 }, { 15, 34 } }
for i, p in ipairs(tw) do c:put(p[1], p[2], TWINE[(i % 2 == 0) and 3 or 2], ttok) c:put(p[1] - 1, p[2], TWINE[1], ttok) end
c:put(14, 35, TWINE[2], ttok) c:put(15, 35, TWINE[1], ttok) c:put(14, 36, TWINE[3], ttok)

-- heap: crumbly mould
local htok = { r = { name = "heap" } }
local hn = X.pillow(heap, 4)
local hidx = A.shade(c, heap, hn, MOULD, { bias = hb, tok = htok, amb = 0.1, wrap = 0.3 })
heap:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if h < 0.18 then A.step(c, hidx, MOULD, x, y, -1, htok)
  elseif h > 0.86 then A.step(c, hidx, MOULD, x, y, 1, htok) end
end)
-- crumbs on the lit side (2px lumps) and rusty leaf flecks
for _, p in ipairs{ { 24, 18 }, { 30, 16 }, { 35, 15 }, { 21, 21 }, { 40, 18 } } do
  if heap:has(p[1], p[2]) then c:put(p[1], p[2], MOULD[6], htok) c:put(p[1] + 1, p[2] + 1, MOULD[3], htok) end end
for _, p in ipairs{ { 27, 21, 2 }, { 33, 20, 3 }, { 42, 21, 1 }, { 23, 20, 2 }, { 38, 15, 2 }, { 29, 18, 1 } } do
  if heap:has(p[1], p[2]) then c:put(p[1], p[2], RUST[p[3]], htok) c:put(p[1] + 1, p[2], RUST[max(1, p[3] - 1)], htok) end end

-- skeleton leaf standing up out of the heap: lacy outline, midrib, veins, holes show mould
local stok = { r = { name = "skeleton" } }
local sk, skn, ST, SS = A.blade(27, 20, 22, 14, 22, 9, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 3.6 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.7)
end, { fold = 0.3 })
local skAO = HP.mask()
sk:each(function(x, y) local k = K(x, y)
  local s, t = SS[k], ST[k]
  local onEdge = abs(s) > 0.72
  local mid = abs(s) < 0.2
  local vein = (t * 9 + abs(s) * 2.2) % 1.6 < 0.55
  if onEdge or mid or vein then
    c:put(x, y, SKEL[(s < 0) and 3 or (mid and 3 or 2)], stok)
    if s > 0.4 then c:put(x, y, SKEL[1], stok) end
  else
    -- see-through lace: mould behind, darkened
    c:put(x, y, MOULD[2], stok)
  end
end)
c:put(28, 21, SKEL[1], stok) c:put(28, 22, SKEL[1], stok)  -- petiole into the heap

-- quirk: woodlouse on the sack (segmented grey oval with legs)
local wtok = { r = { name = "louse" } }
local wl = A.rell(22.5, 44, 0.45, -0.89, 3.6, 2.0)
local wln = X.sphere(22.5, 44, 3.4, wl)
local widx = A.shade(c, wl, wln, LOUSE, { tok = wtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.12, wrap = 0.3 })
wl:each(function(x, y) local u = (x - 22.5) * 0.45 + (y - 44) * -0.89
  if floor(u * 1.4 + 10) % 2 == 0 then A.step(c, widx, LOUSE, x, y, -1, wtok) end end)
c:put(24, 40, LOUSE[1], wtok) c:put(25, 39, LOUSE[2], wtok)            -- antennae
c:put(20, 43, LOUSE[1], wtok) c:put(19, 45, LOUSE[1], wtok) c:put(25, 46, LOUSE[1], wtok) c:put(24, 47, LOUSE[1], wtok)
local gx, gy = A.specAt(wl, wln, 30) if gx then c:put(gx, gy, "#fff4d6", wtok) end

A.save(c, NAME)

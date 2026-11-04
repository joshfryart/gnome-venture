-- sago (final, Sonnet high single pass). A footed turned-wood bowl (slim stem and flat base) heaped in a pyramid of
-- 21 glossy pearl-white sago grains (cool lilac shade, a few with a pink blush, one specular each, AO where they
-- touch). Bowl: lit cup with concentric turning rings, bright front lip, dark inside. A maple spoon leans on the heap.
-- quirk: one pearl has rolled off the table by the foot and leaves two motion ticks behind it.
local NAME = "sago"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local WOOD  = { "#3a2020", "#51302b", "#7a4a33", "#a06a40", "#c48d58", "#e4b57c" }
local MAPLE = { "#6a3f2c", "#8f5a3a", "#b8804e", "#d6a468", "#ecc690", "#f8e2b4" }
local PEARL = { "#6c5a86", "#9783aa", "#c2afc8", "#e6d6d8", "#f7ead6", "#fff8e8" }
local BLUSH = { "#7a4f7a", "#a8708f", "#d598a6", "#efbdb6", "#fadcc6", "#fff0da" }
local SPEC  = "#fffdf2"
local CX = 31.5

c:groundShadow(32, 58, 17, 2)

-- foot: slim stem + flat base
local wtok = { r = { name = "wood" } }
local stem = HP.mask()
for y = 51, 56 do for x = 28, 35 do stem:set(x, y) end end
local base = c:ellipse(31.5, 57, 10, 2.2)
stem:add(base)
local sn = X.pillow(stem, 2.2)
local sidx = G.toneN(c, stem, sn, WOOD, { tok = wtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.08, wrap = 0.3 })
stem:each(function(x, y) if y >= 53 and y <= 55 and x >= 28 and x <= 35 and (x == 29 or x == 32) then c:put(x, y, WOOD[max(1, (sidx[K(x, y)] or 3) - 1)], wtok) end end)
for x = 24, 39 do if base:has(x, 56) and not stem:has(x, 55) then c:put(x, 56, WOOD[5], wtok) end end

-- bowl body (cup): rows 40..52, narrowing to the foot
local body = HP.mask()
for y = 40, 52 do
  local q = 1 - ((y - 40) / 12.6) ^ 2
  local h = 21 * sqrt(max(0, q))
  for x = 0, 63 do if abs(x - CX) <= h then body:set(x, y) end end
end
local bn = X.sphere(CX, 38, 21, body)
local bb = {}
-- ambient: row under the front lip, and the foot join
body:each(function(x, y) if y >= 46 and y <= 47 then bb[K(x, y)] = -1 end if y >= 51 then bb[K(x, y)] = -1 end end)
local bi = G.toneN(c, body, bn, WOOD, { tok = wtok, bias = bb, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 }, amb = 0.08, wrap = 0.3 })
body:each(function(x, y) local k = K(x, y)
  local t = ((x - CX) / 21) ^ 2 + ((y - 40) / 12.6) ^ 2
  local f = (t * 4.2) % 1
  if f < 0.14 and y >= 47 then c:put(x, y, WOOD[max(1, (bi[k] or 3) - 1)], wtok)
  elseif f > 0.86 and (bi[k] or 3) >= 3 and X.hash(x, y, 2) > 0.3 then c:put(x, y, WOOD[min(6, (bi[k] or 3) + 1)], wtok) end
end)
-- specular streak on the upper-left of the cup
for _, p in ipairs{ { 17, 47 }, { 18, 48 }, { 19, 49 }, { 18, 47 } } do if body:has(p[1], p[2]) then c:put(p[1], p[2], WOOD[6], wtok) end end

-- rim ring (lit wood), interior dark
local outer = c:ellipse(31.5, 41, 21, 4.5)
local inner = c:ellipse(31.5, 40, 19, 3)
local ring = outer:copy():cut(inner)
local function ringPaint(front)
  ring:each(function(x, y)
    if (y >= 41) == front then
      local t = max(-0.97, min(0.97, (x - CX) / 22))
      local nx, ny = t * 0.95, -0.3
      local nz = sqrt(max(0.05, 1 - nx * nx - ny * ny))
      local v = X.light({ [1] = { nx, ny, nz } }, { amb = 0.1, wrap = 0.3 })[1]
      local i = 1 + (v >= 0.2 and 1 or 0) + (v >= 0.36 and 1 or 0) + (v >= 0.52 and 1 or 0) + (v >= 0.68 and 1 or 0) + (v >= 0.84 and 1 or 0)
      if front and y >= 44 then i = max(1, i - 1) end                         -- underside of the lip
      c:put(x, y, WOOD[i], wtok)
    end
  end)
end
inner:each(function(x, y) c:put(x, y, x < CX and WOOD[2] or WOOD[1], wtok) end)
ringPaint(false)

-- pearl heap: top row first, front rows over them
local heap = HP.mask()
local ptok = { r = { name = "pearl" } }
for row = 0, 5 do
  local cy = 21 + 4 * row
  for i = 0, row do
    local cx = 32 + floor((i - row / 2) * 5 + (row % 2 == 0 and 0.4 or 0.1) + 0.5)
    local jy = X.hash(cx, cy, 4) < 0.28 and 1 or 0
    local py = cy + jy
    local m = G.disc(cx, py, 2.4)
    local bias = {}
    m:each(function(x, y) if heap:has(x, y - 1) and not heap:has(x, y) then bias[K(x, y)] = -1 end
      if (heap:has(x - 1, y) or heap:has(x, y - 1)) and not heap:has(x, y) and (x - cx) + (y - py) > 1 then bias[K(x, y)] = -1 end end)
    local ramp = X.hash(cx, py, 17) < 0.26 and BLUSH or PEARL
    local _, idx = G.sph(c, cx, py, 2.4, ramp, { mask = m, bias = bias, tok = ptok })
    -- bottom-right pixel of every pearl sits in cool shade; one specular
    c:put(cx - 1, py - 1, SPEC, ptok)
    if X.hash(cx, py, 6) > 0.5 then c:put(cx, py - 1, ramp[5], ptok) end
    -- soft ink-free separation: darkest tone where this pearl overlaps an earlier one
    m:each(function(x, y) if heap:has(x, y) then end end)
    heap:add(m)
  end
end

-- spoon leaning on the right slope of the heap
local sp = { x0 = 42, y0 = 31, x1 = 54, y1 = 9 }
local hm, hn, HT, HS = X.cyl(sp.x0, sp.y0, sp.x1, sp.y1, function(t) return 1.45 - 0.3 * t end)
local stk = { r = { name = "spoon" } }
local hidx = G.toneN(c, hm, hn, MAPLE, { tok = stk, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  if (floor(HT[k] * 40) % 7 == 3) and abs(HS[k]) < 0.8 then c:put(x, y, MAPLE[max(1, (hidx[k] or 3) - 1)], stk) end end)
local ux, uy = (sp.x1 - sp.x0), (sp.y1 - sp.y0)
local ul = sqrt(ux * ux + uy * uy) ux, uy = ux / ul, uy / ul
local head = G.rell(sp.x0 - ux * 1.5, sp.y0 - uy * 1.5, ux, uy, 5.2, 3.7)
local hdn = X.pillow(head, 2.2)
local hdi = G.toneN(c, head, hdn, MAPLE, { tok = stk, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
-- scooped inside of the spoon: darker bowl with a lit lower-right lip
local scoop = head:shrink(1)
scoop:each(function(x, y) c:put(x, y, ((x + y) > (sp.x0 + sp.y0 - 3)) and MAPLE[3] or MAPLE[2], stk) end)
scoop:each(function(x, y) if not scoop:has(x - 1, y - 1) then c:put(x, y, MAPLE[1], stk) end end)
head:edge():each(function(x, y) if x + y > sp.x0 + sp.y0 - 3 then c:put(x, y, MAPLE[5], stk) end end)
-- shadow of the head on the heap
head:shift(-1, 1):each(function(x, y) if heap:has(x, y) and not head:has(x, y) then c:put(x, y, PEARL[2], ptok) end end)
c:put(sp.x0 - 5, sp.y0 - 4, MAPLE[6], stk)

ringPaint(true)

-- quirk: a runaway pearl at the foot, with two motion ticks
local rm = G.sph(c, 54, 54, 2.4, PEARL, { tok = ptok })
c:put(53, 53, SPEC, ptok)
c:put(54, 57, "#74758c") c:put(55, 57, "#74758c") c:put(53, 57, "#aaa9b8")
c:put(49, 52, "#aaa9b8") c:put(48, 52, "#aaa9b8") c:put(50, 55, "#aaa9b8") c:put(49, 55, "#aaa9b8")

G.save2(c, NAME)

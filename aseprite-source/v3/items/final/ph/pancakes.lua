-- pancakes (final, aC31_5, Opus single pass; replaces the Sonnet draft). A slim stack of three fluffy pancakes in
-- 3/4 view on a small cool ceramic plate. Each pancake is a real disc: browned domed top face (6-tone, lacy bubble
-- pits, pale rounded lip) over a pale crumb side band (cylinder light, speckled crumb, darker crust row underneath).
-- A melting butter pat sits on top in a glossy amber syrup pool; two syrup runs drip down the sides with beads and
-- speculars. AO where each pancake sits on the one below, contact shadow on the plate, plate rim bevel + glint.
-- quirk: one blueberry has rolled off the stack and sits alone on the plate rim.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local norm = G.norm
local c = G.new2("pancakes")

local TOPR  = { "#5e2a1c", "#87401f", "#ad5d26", "#cc7e33", "#e3a04a", "#f2c36e" }   -- browned top
local SIDE  = { "#8a5a3a", "#b9874e", "#dbac62", "#efc97a", "#f9e09a", "#fff2c4" }   -- pale crumb side
local SYR   = { "#4a1a10", "#7a2e12", "#a84a14", "#cf6c1c", "#ec9632", "#ffcf72" }
local BUT   = { "#b88a2a", "#dcae3c", "#f0cc56", "#fbe27c", "#fff0a8", "#fffbe0" }
local PLATE = { "#4c5a82", "#6b7ea8", "#90a4c8", "#b5c8e2", "#d6e4f2", "#f2f8fc" }
local BERRY = { "#1c1838", "#2e2a5e", "#463f88", "#5e5aaa", "#8486c8", "#b8bce6" }

c:groundShadow(32, 53, 22, 2)

-- plate: shallow ellipse dish with a raised rim and a sunken well
local PX, PY = 32, 46
local plate = c:ellipse(PX, PY, 23, 6)
local well = c:ellipse(PX, PY - 0.5, 17, 3.6)
local pn = {}
plate:each(function(x, y)
  local u, v = (x - PX) / 23.5, (y - PY) / 6.5
  local r = sqrt(u * u + v * v)
  local nx, ny, nz
  if well:has(x, y) then nx, ny, nz = -u * 0.25, -v * 0.25 - 0.55, 0.8      -- well floor, faces up
  elseif r > 0.86 then nx, ny, nz = u * 0.9, v * 0.9 + 0.3, 0.4             -- outer rim rolls away
  else nx, ny, nz = -u * 0.6, -v * 0.6 - 0.5, 0.6 end                         -- inner slope up to the rim
  pn[K(x, y)] = { norm(nx, ny, nz) }
end)
-- the plate's front lip thickness (a band under the ellipse)
local lip = HP.mask()
for x = PX - 22, PX + 22 do local u = (x - PX) / 23.5 local yb = PY + 6.5 * sqrt(max(0, 1 - u * u))
  for y = floor(yb), floor(yb + 1.2) do if not plate:has(x, y) then lip:set(x, y) pn[K(x, y)] = { norm(u * 0.5, 0.75, 0.4) } end end end
local pm = plate:copy():add(lip)
local pbias = {}
local ptok = { r = { name = "plate" } }

-- pancakes: discs (cx, top-face centre y, rx, ry, side thickness)
local cakes = { { 31, 37, 15, 3.6, 5 }, { 33, 31, 14.5, 3.6, 5 }, { 31.5, 25, 14, 3.5, 5 } }
local function discMasks(d)
  local cx, cy, rx, ry, th = d[1], d[2], d[3], d[4], d[5]
  local top = c:ellipse(cx, cy, rx, ry)
  local side = HP.mask()
  for x = floor(cx - rx), floor(cx + rx + 1) do
    local u = (x - cx) / (rx + 0.5)
    if abs(u) <= 1 then
      local yb = cy + (ry + 0.5) * sqrt(1 - u * u)
      for y = floor(cy), floor(yb + th - 0.5) do if not top:has(x, y) then side:set(x, y) end end
    end
  end
  return top, side
end
for _, d in ipairs(cakes) do d.top, d.side = discMasks(d) d.all = d.top:copy():add(d.side) end
-- contact shadow of the stack on the plate
X.ao(pbias, pm, cakes[1].all, 2, -1)
G.cast(pbias, pm, cakes[1].all, 2, 2, -1)
pm:cut(cakes[1].all)
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.1, wrap = 0.3 }), PLATE, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = pbias, tok = ptok })
-- rim highlight arc (upper-left) + one glint
plate:edge():each(function(x, y) if y < PY - 2 and x < PX + 6 and not cakes[1].all:has(x, y) then c:put(x, y, PLATE[6], ptok) end end)
c:put(PX - 18, PY + 2, "#fbfdff", ptok)

local function paintCake(i)
  local d = cakes[i]
  local cx, cy, rx, ry, th = d[1], d[2], d[3], d[4], d[5]
  local tok = { r = { name = "cake" .. i } }
  local above = cakes[i + 1] and cakes[i + 1].all or HP.mask()
  -- side band: cylinder across x, rounded at the top lip and the crust underneath
  local sn, sb = {}, {}
  d.side:each(function(x, y)
    local u = max(-0.95, min(0.95, (x - cx) / (rx + 0.6)))
    local yb = cy + (ry + 0.5) * sqrt(max(0, 1 - u * u))
    local f = (y - yb) / th                      -- ~0 at the lip, ~1 at the bottom
    local vy = f < 0.2 and -0.5 or (f > 0.75 and 0.7 or 0.1)
    sn[K(x, y)] = { norm(u, vy, sqrt(1 - u * u) + 0.15) }
    if f > 0.8 then sb[K(x, y)] = -1 end         -- crust row
  end)
  X.ao(sb, d.side, above, 1, -2)
  local sv = d.side:copy():cut(above)
  local sid = X.tone(c, sv, X.light(sn, { amb = 0.1, wrap = 0.35 }), SIDE, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, bias = sb, tok = tok })
  -- crumb speckle
  sv:each(function(x, y) local k = K(x, y) if X.hash(x, y, i) > 0.86 and (sid[k] or 1) > 2 then c:put(x, y, SIDE[sid[k] - 1], tok) end end)
  -- top face: shallow dome, browned, pale rounded lip at the front
  local tn = X.pillow(d.top, 2.2, 0.6)
  for k, n in pairs(tn) do tn[k] = { norm(n[1], n[2] - 0.35, n[3]) } end
  local tb = {}
  X.ao(tb, d.top, above, 1, -2)
  G.cast(tb, d.top, above, 1, 1, -1)
  local tv = d.top:copy():cut(above)
  local tid = X.tone(c, tv, X.light(tn, { amb = 0.1, wrap = 0.3 }), TOPR, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = tb, tok = tok })
  -- pale rounded lip where top meets side (front half), browner at the back edge
  d.top:edge():each(function(x, y) if tv:has(x, y) and y > cy and not tb[K(x, y)] then c:put(x, y, SIDE[4], tok) end end)
  -- lacy bubble pits on the browned face
  tv:shrink(1):each(function(x, y) if X.hash(x, y, 7 + i) > 0.93 and not tb[K(x, y)] then
    c:put(x, y, TOPR[max(1, (tid[K(x, y)] or 3) - 2)], tok) end end)
  return tid
end
for i = 1, 3 do paintCake(i) end

-- syrup pool on the top pancake (glossy, irregular), with two drips down the sides
local t3 = cakes[3]
local pool = c:ellipse(31, 24.6, 9.5, 2.3):add(c:ellipse(37, 25.4, 5, 2)):add(c:ellipse(25, 25.2, 4, 1.8))
pool:clip(t3.top:shrink(1))
local drips = {
  { 22, 26, 33 },   -- x, start y, end y (runs over the top side onto the middle cake)
  { 40, 27, 32 },
  { 34, 28, 31 },
}
local syr = pool:copy()
for _, dr in ipairs(drips) do for y = dr[2], dr[3] do syr:set(dr[1], y) if y < dr[3] - 1 then syr:set(dr[1] + 1, y) end end
  syr:set(dr[1], dr[3] + 1) syr:set(dr[1] + 1, dr[3]) end
local syn = X.pillow(syr, 1.6, 1.2)
local stok = { r = { name = "syrup" } }
X.tone(c, syr, X.light(syn, { amb = 0.1, wrap = 0.2 }), SYR, { cuts = { 0.18, 0.34, 0.5, 0.64, 0.8 }, tok = stok })
-- drip beads: darker core + bright point
for _, dr in ipairs(drips) do c:put(dr[1], dr[3] + 1, SYR[3], stok) c:put(dr[1], dr[3], SYR[6], stok) c:put(dr[1] + 1, dr[2] + 1, SYR[2], stok) end
-- glossy streak on the pool
for x = 26, 29 do c:put(x, 23, SYR[6], stok) end c:put(27, 23, "#fff3d0", stok)

-- melting butter pat (small bevelled block, slumped corner, molten rim)
local bt = { r = { name = "butter" } }
G.map(c, {
  "..ehhhhe.",
  ".ehHHHhhe",
  "ehhHhhhbs",
  "ebbbbbbss",
  "mbbbbbssm",
  ".mmbbssm.",
}, 27, 17, { h = BUT[5], H = BUT[6], e = BUT[4], b = BUT[3], s = BUT[2], m = SYR[5] }, bt)
c:put(34, 19, BUT[1], bt) c:put(28, 22, SYR[4], bt)

-- quirk: a lone blueberry rolled off onto the plate rim (bloom, star crown)
local bm = c:ellipse(51, 47, 2.4, 2.4)
local bk = {} X.ao(bk, bm, HP.mask(), 1, 0)
G.toneN(c, bm, X.sphere(51, 47, 2.6, bm), BERRY, { tok = { r = { name = "berry" } }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
c:put(51, 46, BERRY[1]) c:put(52, 46, BERRY[2]) c:put(50, 46, BERRY[5]) c:put(49, 47, BERRY[6])
c:put(51, 50, PLATE[2], ptok) c:put(52, 50, PLATE[2], ptok)

G.save2(c, "pancakes")

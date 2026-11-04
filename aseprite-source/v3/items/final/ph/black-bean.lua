-- black-bean (final, Opus aR20_2). A little heap of glossy black kidney beans (violet-black 6-tone sphere light,
-- a hard cream specular each, cool reflected rim, a white hilum eye with a dark slit on the inner curve) in front of
-- a dry, split pod half that has twisted into a helix (papery tan, light/dark twist bands, a fibrous stalk).
-- AO where beans touch, contact shadows on the pod.
-- quirk: one bean balances on top of the others, hilum up like a sleepy eye.
local NAME = "black-bean"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)
local BK = { "#130d18", "#211727", "#33253c", "#4a3a58", "#6a5a80", "#9e8cb8" }
local POD = { "#5a3a26", "#86603a", "#ae8550", "#cfa96a", "#e8cc90", "#f8eac0" }
local COOL, HIL, HILD = "#3e4a6c", "#f0eadc", "#b8aca0"

-- dry pod half, twisted into a helix, arching behind the beans
local pp = { { 9, 40 }, { 15, 20 }, { 40, 17 }, { 56, 32 } }
local pm, pn, PT, PS = A.tube(pp, function(t)
  if t > 0.96 then return 0.6 end
  return 1.2 + 1.6 * sin(pi * min(1, t * 1.05)) ^ 0.4
end)
local ptok = { r = { name = "pod" } }
local pb = {}
-- twist: a band every ~6 px along, sliding across the width (helix), dark edge on the turned-away side
pm:each(function(x, y) local k = K(x, y)
  local ph = PT[k] * 70 / 6.5 + PS[k] * 0.45
  local f = ph - floor(ph)
  if f < 0.18 then pb[k] = -2 elseif f < 0.32 then pb[k] = -1 elseif f > 0.55 and f < 0.75 then pb[k] = 1 end
end)

-- beans: cx, cy, rx, ry, angle (indent faces +v side)
local beans = {
  { 16, 46, 5.6, 3.7, 0.25 }, { 30, 48, 5.8, 3.8, -0.1 }, { 44, 46, 5.6, 3.7, -0.35 },
  { 24, 39, 5.4, 3.6, 0.15, top = true },
}
for _, b in ipairs(beans) do
  local m, n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.75)
  -- kidney indent on the lower long side (inner curve)
  local ca, sa = cos(b[5]), sin(b[5])
  local ix, iy = b[1] - sa * (b[4] + 1.6), b[2] + ca * (b[4] + 1.6)
  if not b.top then m:cut(A.rell(ix, iy, ca, sa, 2.6, 1.5)) end
  b.m, b.n = m, n
end
local bmAll = HP.mask() for _, b in ipairs(beans) do bmAll:add(b.m) end
pm:cut(bmAll)
X.ao(pb, pm, bmAll, 1, -1)
A.cast(pb, pm, bmAll, 1, 2, -1)
local pidx = A.tone(c, pm, pn, POD, { tok = ptok, bias = pb, amb = 0.12, wrap = 0.35 })
-- inner papery lining seam (pale) along the lit edge, fibrous stalk at the base
pm:each(function(x, y) local k = K(x, y) if PS[k] < -0.6 and (pb[k] or 0) >= 0 then c:put(x, y, POD[6], ptok) end end)
local stk = { r = { name = "stalk" } }
for _, q in ipairs{ { 8, 41, 2 }, { 7, 42, 1 }, { 6, 43, 2 }, { 7, 43, 1 }, { 5, 44, 1 } } do c:put(q[1], q[2], POD[q[3]], stk) end

-- beans, back to front (the balancing bean last)
for i, b in ipairs(beans) do
  local tok = { r = { name = "bean" .. i } }
  local vis = b.m:copy()
  local bb = {}
  for j = i + 1, #beans do X.ao(bb, b.m, beans[j].m, 1, -1) A.cast(bb, b.m, beans[j].m, 1, 1, -1) end
  local idx = A.tone(c, vis, b.n, BK, { tok = tok, bias = bb, amb = 0.02, wrap = 0.15, cuts = { 0.3, 0.52, 0.7, 0.84, 0.94 } })
  -- cool reflected light on the lower-right rim
  local rim = X.rim(b.n)
  vis:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and not bb[k] then c:put(x, y, COOL, tok) end end)
  -- specular: hard cream glint + lilac halo
  local sx, sy = floor(b[1] - b[3] * 0.4 + .5), floor(b[2] - b[4] * 0.45 + .5)
  c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, BK[6], tok) c:put(sx, sy + 1, BK[5], tok)
  -- hilum: little white eye on the inner curve with a dark slit
  local ca, sa = cos(b[5]), sin(b[5])
  local hv = b.top and -(b[4] - 1.2) or (b[4] - 2.3)
  local hx, hy = b[1] - sa * hv, b[2] + ca * hv
  local hm = A.rell(hx + 0.5, hy, ca, sa, b.top and 2.2 or 1.8, 0.8)
  hm:clip(vis)
  hm:each(function(x, y) c:put(x, y, HIL, tok) end)
  local hl = b.top and 1 or 0
  for u = -1, 1 do local x, y = floor(hx + u * ca + 0.5 + 0.5), floor(hy + u * sa + .5)
    if hm:has(x, y + hl) then c:put(x, y + hl, b.top and BK[2] or HILD, tok) end end
end
A.fin(c, NAME)

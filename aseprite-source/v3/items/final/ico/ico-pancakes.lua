-- ico-pancakes (final, Opus). Four slim pancakes stacked on a glazed plate, seen a little from above.
-- Material: each pancake side has a browned crust lip top and bottom over pale crumb (cylinder light across x),
-- a lacy pored golden top, deep AO where each sits on the one below; amber syrup pool + three drips (glossy,
-- specular streaks); a melting butter pat with a soft puddle; ceramic plate with a blue glaze rim and a well.
-- quirk: one runaway blueberry has rolled to the edge of the plate.
local A = dofile("/home/user/gnome-venture/aseprite-source/v3/items/final/_helpers/_aA7_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-pancakes")
local PL    = { "#464a78", "#6c75a2", "#97a1c8", "#c0c9e4", "#e0e7f4", "#f4f7fd" }
local GLAZE = { "#2a4a7a", "#3a86b0", "#5fc4c8" }
local CRUM  = { "#a06e4a", "#c8935e", "#e2b67a", "#f2d49a", "#fbe6b8", "#fff2d2" }
local CRUST = { "#4e2828", "#7a3c28", "#a8582a", "#cc7832", "#e89a46", "#f6bd6a" }
local SY    = { "#3a1214", "#621e16", "#8a3018", "#b44c1e", "#dc7c30", "#ffc66a" }
local BU    = { "#a87a2a", "#d2a638", "#eec852", "#fbe07a", "#fff0a8", "#fffbe2" }
local BB    = { "#1e1a44", "#2e2a6a", "#433f98", "#5d5cc0", "#8f8edc", "#c4c6f0" }

c:groundShadow(33, 58, 20, 1)
-- plate
local ptok = A.tok("plate")
local pm = c:ellipse(32, 52, 24, 5)
local pidx = A.pil(c, pm, 2.5, PL, { tok = ptok, tilt = { 0, -0.25 } })
local well = c:ellipse(32, 51, 18, 3)
well:each(function(x, y) local i = pidx[K(x, y)] or 4 local j = (x > 40) and 3 or 4 pidx[K(x, y)] = j c:put(x, y, PL[j], ptok) end)
-- well lip: dark top edge, lit lower edge
well:edge():each(function(x, y) if y < 51 then c:put(x, y, PL[3], ptok) elseif x < 40 then c:put(x, y, PL[6], ptok) end end)
-- glaze ring on the rim (dashed blue band just outside the well, front half)
local ring = c:ellipse(32, 52, 22, 4):cut(c:ellipse(32, 51, 20, 3.5))
ring:each(function(x, y) if y >= 53 and (x % 4) ~= 0 then c:put(x, y, x > 42 and GLAZE[1] or GLAZE[2], ptok) end end)

-- pancakes, bottom to top
local stack = {}
local function puck(cx, yt, rx, ry, h, wob)
  local m = HP.mask()
  for t = 0, h do m:add(c:ellipse(cx, yt + t, rx, ry)) end
  local top = c:ellipse(cx, yt, rx, ry)
  local tokp = A.tok("cake")
  -- side
  m:each(function(x, y)
    if top:has(x, y) then return end
    local dx = (x - cx) / (rx + .5)
    local te = yt + ry * sqrt(max(0, 1 - dx * dx)) -- front edge of the top face at x
    local d = y - te                              -- 0..h below it
    local nx = max(-0.97, min(0.97, dx))
    local v = X.light({ [1] = { nx, 0.2, sqrt(1 - nx * nx) } }, { amb = 0.08, wrap = 0.25 })[1]
    local i = 1 for j, t in ipairs(A.CUT6) do if v >= t then i = j + 1 end end
    local wv = (wob and ((x * 7) % 5 == 0)) and 1 or 0
    if d < 1.2 then c:put(x, y, CRUST[min(6, i)], tokp)
    elseif d > h - 1.2 + wv then c:put(x, y, CRUST[max(1, i - 2)], tokp)
    else c:put(x, y, CRUM[max(1, min(6, i + (d < 2.4 and 1 or 0)))], tokp) end
  end)
  -- top face (golden, a little lit toward the upper-left) with lace pores
  local n = X.pillow(top, 2.2)
  for k, v in pairs(n) do n[k] = { A.norm(v[1], v[2] - 0.4, v[3]) } end
  local idx = A.shade(c, top, n, CRUST, { tok = tokp, cuts = { 0.08, 0.2, 0.34, 0.52, 0.8 } })
  top:each(function(x, y) if X.hash(x, y, 3) > 0.86 and idx[K(x, y)] and idx[K(x, y)] >= 4 then A.step(c, idx, CRUST, x, y, -1, tokp) end end)
  stack[#stack + 1] = { m = m, top = top, cx = cx, yt = yt, rx = rx, ry = ry, idx = idx, tok = tokp }
  return m
end
local below
for i, p in ipairs{ { 32, 43, 16, 3.5 }, { 31, 38, 15, 3.5 }, { 33, 33, 16, 3.5 }, { 32, 28, 15, 3.5 } } do
  local m = puck(p[1], p[2], p[3], p[4], 4, i % 2 == 0)
  -- AO on whatever lies just under this pancake's bottom rim
  if below then
    local sh = m:shift(0, 1):cut(m)
    sh:each(function(x, y) if below:has(x, y) then local col = c:get(x, y)
      c:put(x, y, CRUST[1], stack[i - 1].tok) end end)
  else
    local sh = m:shift(1, 1):cut(m)
    sh:each(function(x, y) if pm:has(x, y) then c:put(x, y, PL[2], ptok) end end)
  end
  below = m
end
-- syrup pool on the top pancake + drips over the front edge
local T = stack[4]
local stok = A.tok("syrup")
local pool = c:ellipse(T.cx + 1, T.yt + 0.5, 12, 2.5):add(c:ellipse(T.cx - 5, T.yt + 1, 6, 2))
local dripsX = { { 22, 6 }, { 33, 11 }, { 41, 4 } }
local dm = HP.mask()
for _, d in ipairs(dripsX) do
  local x0 = d[1]
  local dx = (x0 + 1 - T.cx) / (T.rx + .5)
  local ys = floor(T.yt + T.ry * sqrt(1 - dx * dx))
  dm:add(c:rect(x0, ys - 1, x0 + 2, ys + d[2])):add(c:ellipse(x0 + 1, ys + d[2] + 1, 1.5, 1.5))
end
local sall = pool:copy():add(dm)
local sn = {}
pool:each(function(x, y) sn[K(x, y)] = true end)
local pn = X.pillow(pool, 1.6)
for k, v in pairs(pn) do pn[k] = { A.norm(v[1], v[2] - 0.5, v[3]) } end
local sidx = A.shade(c, pool, pn, SY, { tok = stok, cuts = { 0.15, 0.38, 0.62, 0.84, 0.97 } })
dm:each(function(x, y) if not pool:has(x, y) then
  -- vertical cylinder across each drip
  local best = 99 local rel
  for _, d in ipairs(dripsX) do local r = x - (d[1] + 1) if abs(r) < abs(best) then best = r end end
  local i = best < 0 and 5 or best == 0 and 4 or 2
  c:put(x, y, SY[i], stok) sidx[K(x, y)] = i
end end)
-- syrup specular streaks
c:put(T.cx - 4, T.yt - 1, SY[6], stok) c:put(T.cx - 3, T.yt - 1, A.CREAM, stok) c:put(T.cx - 2, T.yt - 1, SY[6], stok)
c:put(33, T.yt + 6, SY[6], stok) c:put(33, T.yt + 7, SY[6], stok)
-- butter pat with melt puddle
local btok = A.tok("butter")
local pud = c:ellipse(T.cx - 1, T.yt - 0.5, 5, 1.4)
pud:each(function(x, y) c:put(x, y, (y > T.yt) and BU[3] or BU[4], btok) end)
local bx, by = T.cx - 4, T.yt - 5
local btop = c:poly{ { bx + 1, by }, { bx + 8, by }, { bx + 7, by + 2 }, { bx, by + 2 } }
local bfront = c:rect(bx, by + 2, bx + 6, by + 4)
btop:each(function(x, y) c:put(x, y, y == by and BU[6] or BU[5], btok) end)
bfront:each(function(x, y) c:put(x, y, x >= bx + 5 and BU[2] or (y == by + 4 and BU[2] or BU[3]), btok) end)
c:put(bx + 2, by + 1, A.CREAM, btok) c:put(bx + 3, by + 1, A.CREAM, btok)
-- a melting corner slumps
c:put(bx + 7, by + 3, BU[2], btok) c:put(bx + 7, by + 4, BU[3], btok) c:put(bx + 8, by + 4, BU[4], btok)
-- quirk: runaway blueberry on the plate rim
local btk = A.tok("berry")
local bm, bn, bidx = A.ovl(c, 50, 52, 3, 2.8, 0, BB, { tok = btk })
c:put(50, 50, BB[1], btk) c:put(51, 50, BB[2], btk) -- crown dimple
c:put(48, 51, BB[6], btk) c:put(49, 53, BB[5], btk) -- bloom
c:put(48, 55, PL[2], ptok) c:put(52, 55, PL[2], ptok) -- contact shadow
A.save(c, "ico-pancakes")

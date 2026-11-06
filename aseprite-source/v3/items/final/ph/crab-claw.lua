-- crab-claw (final, Opus single pass). One cooked crab claw on the diagonal: a slim carpus stub at the lower left
-- (cream cut end with pink meat), an oval palm (propodus) with raised tubercles and a pale lit ridge, and two
-- slender curved fingers (the fixed pollex and the movable dactyl) that open in a gap and close at dark,
-- glossy tips. Ivory teeth along both inner edges, AO at the wrist joint and the finger roots, a cool reflected
-- edge on the shade side, a hard shell specular on the palm.
-- quirk: a tiny barnacle has settled on the palm, its plates pale and its little mouth shut.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "crab-claw"
local c = A.new(NAME)
local SHELL = { "#5a1a32", "#8e2636", "#c23c34", "#e2603a", "#f58a4e", "#ffbf80" }
local TIP = { "#21161e", "#38222a", "#54303a", "#7a4a50" }
local TOOTH = { "#c8a890", "#f0dcc0", "#fff4dc" }
local COOL = "#7a4a7a"
local MEAT = { "#d07a7a", "#f0a8a0", "#fbe2cc" }

-- fingers
local function finger(pts, w0, name, inner)
  local m, n, T, S = A.tube(pts, function(t) return max(0.45, w0 * (1 - t) ^ 0.7 + 0.25) end)
  return { m = m, n = n, T = T, S = S, pts = pts, inner = inner, tok = { r = { name = name } } }
end
local dac = finger({ { 34, 27 }, { 37, 17 }, { 45, 9 }, { 54, 10 } }, 2.9, "dactyl", 1)
local pol = finger({ { 38, 32 }, { 46, 29 }, { 53, 23 }, { 55, 14 } }, 3.2, "pollex", -1)
-- palm
local pm, pn = A.oval(27, 37, 12.5, 7.5, -0.72, 0.85)
-- carpus stub
local cm, cn, CT = A.tube({ { 18, 45 }, { 14, 48 }, { 11, 51 }, { 9, 55 } }, function(t) return 3.6 - t * 0.4 end)
cm:cut(pm)
dac.m:cut(pm) pol.m:cut(pm) dac.m:cut(pol.m)

-- carpus
local ctok = { r = { name = "carpus" } }
local cb = {} X.ao(cb, cm, pm, 2, -1)
local ci = A.shade(c, cm, cn, SHELL, { tok = ctok, bias = cb, amb = 0.1, wrap = 0.3 })
-- cut end: cream rim and meat
cm:each(function(x, y) local k = K(x, y)
  if CT[k] > 0.9 then c:put(x, y, MEAT[3], ctok) end
  if CT[k] > 0.95 then c:put(x, y, ((x + y) % 2 == 0) and MEAT[2] or MEAT[1], ctok) end
end)

-- fingers
for _, f in ipairs{ pol, dac } do
  local fb = {} X.ao(fb, f.m, pm, 1, -1)
  if f == dac then X.ao(fb, f.m, pol.m, 1, -1) end
  local idx = A.shade(c, f.m, f.n, SHELL, { tok = f.tok, bias = fb, amb = 0.1, wrap = 0.3 })
  f.m:each(function(x, y) local k = K(x, y)
    local t, s = f.T[k], f.S[k]
    if t > 0.72 then
      local i = idx[k] - 2 if t > 0.86 then i = i - 1 end
      c:put(x, y, TIP[max(1, min(4, i))], f.tok)
    elseif s < -0.6 and t > 0.1 and idx[k] >= 4 then c:put(x, y, SHELL[min(6, idx[k] + 1)], f.tok)
    elseif s > 0.8 and idx[k] <= 3 then c:put(x, y, COOL, f.tok) end
  end)
  -- teeth on the inner edge
  for i = 2, 15 do
    local t = 0.12 + i * 0.04
    if t > 0.74 then break end
    local s = f.pts
    local x, y = A.bez(s, t)
    local x2, y2 = A.bez(s, t + 0.01)
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
    local w = 3.0 * (1 - t) ^ 0.7 + 0.25 + 1.0
    local qx, qy = floor(x + px * w * f.inner + 0.5), floor(y + py * w * f.inner + 0.5)
    if i % 2 == 0 and not f.m:has(qx, qy) and not pm:has(qx, qy) and not dac.m:has(qx, qy) and not pol.m:has(qx, qy) then
      c:put(qx, qy, TOOTH[(i % 4 == 0) and 3 or 2], f.tok)
    end
  end
  -- tip glint
  local gx, gy = A.bez(f.pts, 0.8)
  c:put(floor(gx - 0.5), floor(gy - 0.5), TIP[4], f.tok)
end

-- palm
local ptok = { r = { name = "palm" } }
local pb = {}
local pidx = A.shade(c, pm, pn, SHELL, { tok = ptok, bias = pb, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- tubercles: lit bump + shade pixel to the lower right
for _, q in ipairs{ { 20, 40 }, { 24, 36 }, { 28, 33 }, { 31, 30 }, { 22, 44 }, { 27, 41 }, { 32, 37 }, { 18, 37 } } do
  local x, y = q[1], q[2]
  local k = K(x, y)
  if pm:has(x, y) and pm:has(x + 1, y + 1) then
    local i = pidx[k]
    c:put(x, y, SHELL[min(6, i + 1)], ptok) c:put(x + 1, y + 1, SHELL[max(1, i - 1)], ptok)
  end
end
-- lit ridge along the upper edge of the palm
pm:edge():each(function(x, y) local k = K(x, y)
  local dx, dy = x - 27, y - 37
  if dx * 0.67 + dy * 0.74 < -5 and dx * 0.74 - dy * 0.67 < 8 and pidx[k] >= 4 then c:put(x, y, SHELL[6], ptok) end
  if dx * 0.67 + dy * 0.74 > 4 and pidx[k] <= 3 then c:put(x, y, COOL, ptok) end
end)
-- seam where the palm meets the fingers (AO arc)
for _, q in ipairs{ { 34, 30 }, { 35, 31 }, { 36, 31 }, { 36, 32 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], SHELL[2], ptok) end end
-- specular
c:put(21, 33, "#fff0d0", ptok) c:put(22, 33, "#fff0d0", ptok) c:put(22, 32, "#ffd8a8", ptok)

-- quirk: barnacle
do
  local btok = { r = { name = "barnacle" } }
  local bx, by = 25, 40
  local bm = A.rell(bx, by, 1, 0, 2.3, 2.0)
  bm:each(function(x, y) c:put(x, y, (x < bx and y <= by) and "#ece6e0" or ((x > bx or y > by) and "#9a96a8" or "#c8c4cc"), btok) end)
  c:put(bx, by, "#2b1c26", btok) c:put(bx + 1, by, "#4a3e52", btok)
  c:put(bx - 1, by - 2, "#fff6e8", btok)
  -- contact shadow on the shell
  for _, q in ipairs{ { bx + 3, by }, { bx + 2, by + 2 }, { bx + 3, by + 1 }, { bx, by + 3 }, { bx + 1, by + 3 } } do
    if pm:has(q[1], q[2]) and not bm:has(q[1], q[2]) then c:put(q[1], q[2], SHELL[2], ptok) end end
end

A.save(c, NAME)

-- marsh-pearl (final, Opus single pass). A freshwater swan-mussel opened like a book at its hinge: the back valve shows
-- its domed olive-brown outside with concentric growth rings around the umbo; the front valve is a nacre bowl (concave
-- light, pink and mint lustre bands, dark periostracum lip with ring lines) cradling one round marsh pearl (6-tone
-- ramp, cream specular, pink lustre crescent, cool reflected rim, AO + contact shadow in the nacre).
-- quirk: a sprig of duckweed (two round fronds and a trailing rootlet) clings to the back valve.
local NAME = "marsh-pearl"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aC22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SHELL = { "#1c1a18", "#2c2a1e", "#413e26", "#59552f", "#77713c", "#9a9250" }
local LIP = { "#231d1c", "#3a2e24", "#54432e", "#6e5a38" }
local NAC = { "#5f6286", "#8487a8", "#aaaac4", "#cdc8da", "#e8e0e4", "#fbf3ec" }
local PINK, MINT = "#e9cbd8", "#c6e4d8"
local PRL = { "#77708e", "#9e98b2", "#c4bed0", "#dfd8e0", "#f1eae6", "#fdf7ee" }
local DUCK = { "#25502e", "#3f7a38", "#68a548", "#a2d066" }

local function ell(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / (rx + .45), (-dx * sa + dy * ca) / (ry + .45)
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
-- mussel outline: ellipse made egg-shaped (blunt at the hinge end, longer posterior)
local function mussel(cx, cy, rx, ry, ang, blunt)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local R = rx + 3
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / (rx + .45), (-dx * sa + dy * ca) / (ry + .45)
    local w = 1 - blunt * (u < 0 and u * u * 0.6 or 0)
    if u * u + (v / w) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- back valve (domed outside), hinge at lower left
local BX, BY, BA = 30, 24, -0.32
local bm = mussel(BX, BY, 21, 8.5, BA, 0.5)
local bn = {}
do local ca, sa = cos(BA), sin(BA)
  bm:each(function(x, y) local dx, dy = x - BX, y - BY
    local u, v = (dx * ca + dy * sa) / 22, (-dx * sa + dy * ca) / 9.5
    local wx, wy = u * ca - v * sa, u * sa + v * ca
    bn[K(x, y)] = { A.norm(wx * 1.1, wy * 1.6, sqrt(max(1 - u * u - v * v, 0.03))) }
  end) end
-- front valve (bowl), same hinge
local FX, FY, FA = 31, 38, 0.06
local fm = mussel(FX, FY, 21, 10, FA, 0.5)
local inner = mussel(FX + 0.5, FY - 1.2, 19, 8.3, FA, 0.5)
inner:clip(fm)
local lip = fm:copy():cut(inner)

-- pearl
local PX, PY, PR = 32, 35, 6.6
local pm = c:ellipse(PX, PY, PR, PR)
local pn = X.sphere(PX - 0.3, PY - 0.3, PR, pm)

-- back valve paint (front valve overlaps its lower edge)
local btok = { r = { name = "backvalve" } }
local bb = {}
A.shadow(bb, bm, fm, 0, -1)
local bvis = bm:copy():cut(fm)
local bidx = X.tone(c, bvis, X.light(bn, { amb = 0.1, wrap = 0.3 }), SHELL, { cuts = A.CUTS6, bias = bb, tok = btok })
-- growth rings around the umbo (near hinge)
local UX, UY = 14, 30
bvis:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - UX) ^ 2 * 0.55 + (y - UY) ^ 2 * 1.4)
  if d > 4 and floor(d) % 4 == 0 then c:put(x, y, SHELL[max(1, bidx[k] - 2)], btok) end
  if d < 3.2 then c:put(x, y, SHELL[min(6, bidx[k] + 1)], btok) end            -- worn pale umbo
end)
do local bx, by = A.specAt(bvis, bn, 30) c:put(bx, by, SHELL[6], btok) c:put(bx + 1, by, "#c8c070", btok) end

-- front valve: nacre bowl (concave: lit from inside on the lower right)
local ntok = { r = { name = "nacre" } }
local nn = {}
do local ca, sa = cos(FA), sin(FA)
  inner:each(function(x, y) local dx, dy = x - FX, y - FY + 1.2
    local u, v = (dx * ca + dy * sa) / 20, (-dx * sa + dy * ca) / 9.5
    local wx, wy = u * ca - v * sa, u * sa + v * ca
    nn[K(x, y)] = { A.norm(-wx * 1.2, -wy * 1.6, sqrt(max(1 - u * u - v * v, 0.05)) + 0.3) }
  end) end
local nb = {}
X.ao(nb, inner, pm, 2, -1)
A.cast(nb, inner, pm, 1, 2, -1)
X.ao(nb, inner, lip, 1, -1)
local nidx = X.tone(c, inner, X.light(nn, { amb = 0.2, wrap = 0.35 }), NAC, { cuts = { 0.15, 0.3, 0.45, 0.6, 0.78 }, bias = nb, tok = ntok })
-- lustre bands: pink and mint contour lines through the nacre
inner:each(function(x, y) local k = K(x, y)
  if nb[k] then return end
  local d = sqrt(((x - FX) / 19) ^ 2 + ((y - FY + 1.2) / 8.3) ^ 2)
  if abs(d - 0.62) < 0.05 then c:put(x, y, PINK, ntok) elseif abs(d - 0.8) < 0.045 and x > FX - 6 then c:put(x, y, MINT, ntok) end
end)
-- lip: dark periostracum rim with ring lines, paler top edge (thickness)
local ltok = { r = { name = "lip" } }
lip:each(function(x, y)
  local i = 2
  if not lip:has(x, y + 1) then i = 1 end
  if inner:has(x, y + 1) or inner:has(x + 1, y) then i = 4 end
  if i == 2 and (x * 2 + y) % 5 == 0 then i = 3 end
  if x > FX + 8 and i == 2 then i = 1 end
  c:put(x, y, LIP[i], ltok)
end)
-- hinge ligament knot
for _, q in ipairs{ { 10, 33, 1 }, { 11, 33, 2 }, { 10, 34, 2 }, { 11, 34, 3 } } do c:put(q[1], q[2], LIP[q[3]], ltok) end

-- pearl
local ptok = { r = { name = "pearl" } }
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.12, wrap = 0.3 }), PRL, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, tok = ptok })
local rim = X.rim(pn)
pm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - PX, y - PY
  local r = sqrt(dx * dx + dy * dy)
  if rim[k] > 0.62 and r > PR - 1.6 then c:put(x, y, MINT, ptok)                        -- cool reflected rim
  elseif r > PR - 3.2 and r < PR - 2.2 and dx + dy > 1 and dx - dy > -4 then c:put(x, y, PINK, ptok) end   -- lustre crescent
end)
do local sx, sy = A.specAt(pm, pn, 60) c:put(sx, sy, A.CREAM, ptok) c:put(sx + 1, sy, PRL[6], ptok) c:put(sx, sy + 1, PRL[6], ptok) end

-- quirk: duckweed sprig on the back valve
do local dtok = { r = { name = "duckweed" } }
  for _, f in ipairs{ { 40, 17, 2.2 }, { 44, 18, 1.8 } } do
    local m = c:ellipse(f[1], f[2], f[3], f[3] - 0.4)
    local n = X.sphere(f[1], f[2], f[3], m)
    X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), DUCK, { cuts = { 0.3, 0.55, 0.8 }, tok = dtok })
    c:put(f[1] + 1, f[2] + 1, DUCK[1], dtok)
  end
  -- rootlet trailing down over the valve
  for _, q in ipairs{ { 42, 20 }, { 42, 21 }, { 43, 22 }, { 43, 23 } } do c:put(q[1], q[2], "#cfd8a8", dtok) end
end

A.save(c, NAME)

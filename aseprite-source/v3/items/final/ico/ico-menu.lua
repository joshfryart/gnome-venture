-- ico-menu (final pass, Opus single pass). Bold icon: the "three bars" menu glyph built from three slim wooden dowels
-- stacked with air between them. Each dowel: per-pixel cylinder light (6-tone wood, cool-violet underside), a rounded
-- right end, a pale end-grain disc on the left with growth rings and a dark pith, wavy grain lines along the length,
-- one knot on the middle dowel that the grain bends round, one specular on the top dowel.
-- quirk: a tiny red toadstool has sprouted on the top dowel (dark AO row where its stalk meets the wood).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, sqrt, max, min, abs = math.floor, math.sin, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-menu")
local WD = { "#3a2028", "#5e3229", "#874e30", "#ad713e", "#cf9858", "#ecc282" }
local END = { "#9a6a42", "#c49260", "#e0b47e", "#f2d29e" }
local norm = A.norm
local X0, X1, R = 11, 52, 4
local rows = { 19, 32, 45 }
for bi, cy in ipairs(rows) do
  local tok = { r = { name = "dowel" .. bi } }
  local m, n = HP.mask(), {}
  for y = cy - R, cy + R do for x = X0 - 2, X1 do
    local dy = (y - cy) / (R + 0.5)
    local inside, nx = true, 0
    if x < X0 + 2 then
      local ex = (x - (X0 + 2)) / 3.3
      inside = ex * ex + dy * dy <= 1.0
    end
    if x > X1 - R then
      local ex = (x - (X1 - R)) / (R + 0.5)
      inside = ex * ex + dy * dy <= 1.0
      nx = ex
    end
    if inside then
      m:set(x, y)
      local nz = sqrt(max(0.03, 1 - dy * dy - nx * nx))
      n[K(x, y)] = { norm(nx, dy, nz) }
    end
  end end
  local bias = {}
  local idx = A.shade(c, m, n, WD, { tok = tok, amb = 0.04, wrap = 0.12, bias = bias, cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 } })
  -- knot on the middle dowel
  local KX, KY = 34, cy + 1
  local function knotd(x, y) return sqrt(((x - KX) / 2.6)^2 + ((y - KY) / 1.6)^2) end
  -- grain lines: wavy, broken, bending round the knot
  local lines = { { -2, 0.3 }, { 1.5, 2.2 } }
  m:each(function(x, y)
    local k = K(x, y)
    if x < X0 + 6 then return end
    for li, L in ipairs(lines) do
      local gy = cy + L[1] + 0.7 * sin(x * 0.22 + L[2] + bi)
      if bi == 2 then local d = knotd(x, gy) if d < 2.4 then gy = gy + (gy >= KY and 1 or -1) * (2.4 - d) end end
      if abs(y - gy) < 0.5 and X.hash(x // 4, li, bi) > 0.12 then A.step(c, idx, WD, x, y, -1, tok) end
    end
  end)
  if bi == 2 then
    m:each(function(x, y) local d = knotd(x, y)
      if d < 0.6 then c:put(x, y, WD[2], tok) elseif d < 1.1 then c:put(x, y, WD[3], tok)
      elseif d < 1.7 then A.step(c, idx, WD, x, y, 1, tok) end end)
  end
  -- end grain disc on the left (paler), rings + pith, dark ring where it meets the bark
  local ecx = X0 + 2
  for y = cy - R, cy + R do for x = X0 - 2, X0 + 6 do
    local d = sqrt(((x - ecx) / 3.3)^2 + ((y - cy) / (R + 0.45))^2)
    if d <= 1 then
      local col
      if d > 0.76 then col = (x > ecx) and WD[2] or END[1]
      elseif abs(d - 0.48) < 0.12 then col = END[2]
      elseif d < 0.2 then col = WD[3]
      else col = (y < cy and x <= ecx) and END[4] or END[3] end
      c:put(x, y, col, tok)
    end
  end end
  -- specular streak on the top dowel
  if bi == 1 then
    for x = 20, 25 do c:put(x, cy - 3, WD[6], tok) end
    c:put(21, cy - 3, A.CREAM, tok)
  end
  -- cool bounce under each dowel
  for x = X0 + 3, X1 - 4 do if X.hash(x // 2, bi, 9) > 0.55 then c:put(x, cy + R, "#5a3a4e", tok) end end
end
-- quirk: toadstool on the top dowel
local TX, TY = 41, rows[1] - R
local mtok = { r = { name = "toad" } }
A.map(c, {
  "..rRRr..",
  ".hRcRRr.",
  "hRRRRcRd",
  "dRrRRRrd",
  "...sS...",
  "...sS...",
}, TX - 4, TY - 6, { h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038", c = "#fff4d6", s = "#f4e6c6", S = "#c9b08c" }, mtok)
c:put(TX - 1, TY, WD[1]) c:put(TX, TY, WD[1]) c:put(TX - 2, TY, WD[2]) c:put(TX + 1, TY, WD[2])
A.save(c, "ico-menu")

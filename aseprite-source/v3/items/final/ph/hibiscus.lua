-- hibiscus (aC11_5, Opus single pass). An open hibiscus seen face-on: five ruffled, overlapping petals with radiating
-- veins and a deep crimson eye, the long pale staminal column sweeping out to the upper-right with gold anthers and a
-- five-pad red stigma tip, and one serrated leaf tucked behind at the lower-left.
-- Material: per-petal domed light (6-tone coral-red), throat AO, darker separation line + contact shadow where petals
-- overlap, tube-lit column, leaf midrib and veins.
-- quirk: a tiny green caterpillar has munched a notch in the lower-right petal and is still sitting in it.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, sqrt, atan, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.sqrt, math.atan, math.max, math.min
local c = G.new2("hibiscus")
local PR = { "#561032", "#8a183e", "#ba2848", "#e2455a", "#f7747a", "#ffaca0" }
local EYE = { "#3a0820", "#5c0c2c", "#7e1238" }
local LF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local CX, CY = 30, 32

-- leaf behind, lower-left, serrated
local lm = G.leaf(c, CX - 6, CY + 6, 7, 56, 5.2, LF, { 6, 11, 16, 21 })
local lT = {}
lm:edge():each(function(x, y) if (x + 2 * y) % 4 == 0 and (x - CX) ^ 2 + (y - CY) ^ 2 > 200 then c.pix[y * 64 + x] = nil c.own[y * 64 + x] = nil end end)

-- petals
local petals = {}
local base = -pi / 2 + 0.25
local order = { 3, 4, 5, 1, 2 }
local done = HP.mask()
for oi, i in ipairs(order) do
  local a = base + (i - 1) * 2 * pi / 5
  local dx, dy = cos(a), sin(a)
  local pcx, pcy = CX + dx * 10, CY + dy * 10
  local m = HP.mask()
  for y = CY - 24, CY + 24 do for x = CX - 24, CX + 24 do
    local rx, ry = x - pcx, y - pcy
    local u, v = rx * dx + ry * dy, -rx * dy + ry * dx
    local ra, rb = 10.6, 9.0
    local q = (u / ra) ^ 2 + (v / rb) ^ 2
    local lim = 1
    if u > -2 then lim = 1 - 0.13 * (0.5 + 0.5 * sin(atan(v, u) * 7 + i)) end
    local fu, fv = x - CX, y - CY
    local uu = fu * dx + fv * dy
    if q <= lim or (uu >= 0 and uu < 6 and abs(-fu * dy + fv * dx) < 2.5 + uu * 0.6) then m:set(x, y) end
  end end
  if i == 2 then m:cut(G.rell(pcx + dx * 8.5 + 2, pcy + dy * 8.5 + 2, 1, 0, 2.2, 2.2)) end
  -- light: domed petal, concave throat
  local n = X.pillow(m, 3.5)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
    if r < 8 then bias[k] = -1 end end)
  -- contact shadow onto petals already drawn (cast down-right)
  local idx = X.tone(c, m, v, PR, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = bias })
  -- veins radiating from the centre
  local L = 0
  m:each(function(x, y) local k = K(x, y)
    local fu, fv = x - CX, y - CY
    local uu, vv = fu * dx + fv * dy, -fu * dy + fv * dx
    if uu > 7 and uu < 17 then
      local ang = atan(vv, uu)
      for _, va in ipairs{ -0.5, -0.22, 0.05, 0.3, 0.56 } do
        if abs(ang - va) * uu < 0.5 then c:put(x, y, PR[max(1, idx[k] - 1)]) end
      end
    end
  end)
  -- separation: earlier petals touching this one get a dark line + 1px cast shadow
  G.seam(c, done, m, PR[1])
  m:shift(1, 1):each(function(x, y) if done:has(x, y) and not m:has(x, y) and not m:grow(1):has(x, y) then c:put(x, y, PR[2]) end end)
  done:add(m)
  petals[i] = m
end
-- eye: deep crimson centre with streaks
done:each(function(x, y)
  local r = sqrt((x - CX + 0.5) ^ 2 + (y - CY + 0.5) ^ 2)
  local a = atan(y - CY, x - CX)
  local streak = (sin(a * 10) > 0.55) and 2.2 or 0
  if r < 3.2 then c:put(x, y, EYE[1]) elseif r < 5 then c:put(x, y, EYE[2]) elseif r < 5.8 + streak then c:put(x, y, EYE[3]) end
end)
-- staminal column: tube from centre to upper-right
local CL = { "#7a2c48", "#b45a74", "#e48ca0", "#f8bcc4", "#ffe0e0" }
local cp = { { CX, CY - 1 }, { 38, 26 }, { 45, 19 }, { 51, 11 } }
local cm, cn = G.tube(cp, function(t) return 1.15 - t * 0.3 end)
X.tone(c, cm, X.light(cn, { amb = 0.12, wrap = 0.3 }), CL, { cuts = { 0.25, 0.5, 0.7, 0.88 } })
c:put(CX, CY - 1, EYE[1]) c:put(CX + 1, CY - 1, EYE[1])
-- gold anthers on short filaments along the outer third
local AN = { "#a85a1c", "#f0b02c", "#ffe48a" }
for i, t in ipairs{ 0.58, 0.64, 0.7, 0.76, 0.82 } do
  local x, y = G.bez(cp, t)
  local side = (i % 2 == 0) and 1 or -1
  local ax, ay = floor(x + 0.7 * side * 2 + .5), floor(y + 0.7 * side * 2 + .5)
  if side < 0 then ax, ay = floor(x - 1.6 + .5), floor(y - 1.6 + .5) else ax, ay = floor(x + 1.6 + .5), floor(y + 1.6 + .5) end
  c:put(ax, ay, AN[2]) c:put(ax + (side < 0 and -1 or 1), ay, side < 0 and AN[3] or AN[1])
end
-- stigma: five red pads at the tip
G.stamp(c, 50, 7, { ".r.r", "rRrR", ".dRd" }, { r = "#ff6a6a", R = "#d0203a", d = "#8a1430" })
-- quirk: caterpillar in the notch of petal 2
do
  local a = base + 1 * 2 * pi / 5
  local nx, ny = floor(CX + cos(a) * 18.5 + 2 + .5), floor(CY + sin(a) * 18.5 + 2 + .5)
  G.stamp(c, nx - 2, ny - 2, { ".hg.", "hGgG", "gGdg" }, { h = "#c4e07a", g = "#7cc35a", G = "#3f9150", d = "#24544a" })
  c:put(nx - 2, ny - 2, "#2b1c26")
end
-- one waxy glint on the top-left petal
c:put(CX - 10, CY - 12, "#fff4d6") c:put(CX - 9, CY - 12, PR[6])
G.save2(c, "hibiscus")

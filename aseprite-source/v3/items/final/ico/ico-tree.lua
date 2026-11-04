-- ico-tree (final, Opus). Slim broadleaf tree: a gently S-curved trunk with flared roots forking into two
-- branches, under a crown of three leaf masses (back top, front left, front right) built from lumpy leaf clumps.
-- Material: per-pixel light from a clump height field (each clump its own dome on the crown dome, 6-tone leaf),
-- scalloped leafy rim, lit leaf flecks on the sunny side, dark seams where masses overlap; bark with vertical
-- fissures, a knot, AO under the crown and a cast shadow on the trunk; ground shadow.
-- quirk: one leaf has already turned orange and is drifting down.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = R.new("ico-tree")
local LEAF = { "#173f36", "#215a40", "#2e7846", "#47984c", "#6cb656", "#a2d470" }
local BARK = { "#3a2228", "#58322a", "#7a4a32", "#9c6640", "#bc8656", "#d8aa78" }
local lt, bt = { r = { name = "leaf" } }, { r = { name = "bark" } }

c:groundShadow(32, 57, 11, 1.5)

---------------------------------------------------------------- trunk + branches
local tm, tn, TT, TS = R.tube({ { 32, 56 }, { 30, 50 }, { 34, 44 }, { 32, 36 } }, function(t) return 2.7 - t * 0.8 end)
-- root flares
local roots = c:poly{ { 25, 57 }, { 29, 52 }, { 31, 54 }, { 30, 57 } }:add(c:poly{ { 39, 57 }, { 34, 52 }, { 33, 54 }, { 34, 57 } })
local bl, bln, BLT, BLS = R.tube({ { 31, 41 }, { 27, 37 }, { 24, 34 }, { 20, 31 } }, function(t) return 1.7 - t * 0.5 end)
local br, brn, BRT, BRS = R.tube({ { 33, 40 }, { 37, 36 }, { 40, 33 }, { 45, 30 } }, function(t) return 1.7 - t * 0.5 end)
local wood = tm:copy():add(roots):add(bl):add(br)
local wn = {}
for _, src in ipairs{ bln, brn, tn } do for k, v in pairs(src) do wn[k] = v end end
local rp = X.pillow(roots, 1.5) for k, v in pairs(rp) do if not wn[k] then wn[k] = v end end
local wb = {}
local widx = R.shade(c, wood, wn, BARK, { amb = 0.08, wrap = 0.25, tok = bt, bias = wb })
-- bark fissures: broken vertical dark lines on the trunk
tm:each(function(x, y) local k = K(x, y) local s = TS[k]
  if (abs(s - 0.25) < 0.16 or abs(s + 0.45) < 0.14) and X.hash(x, y, 5) > 0.22 then R.step(c, widx, BARK, x, y, -2, bt)
  elseif abs(s + 0.1) < 0.12 and TT[k] < 0.5 and X.hash(x, y, 9) > 0.6 then R.step(c, widx, BARK, x, y, 1, bt) end end)
-- knot with a lit lower lip
c:put(31, 47, BARK[1], bt) c:put(32, 47, BARK[1], bt) c:put(31, 48, BARK[2], bt) c:put(32, 48, BARK[5], bt)

---------------------------------------------------------------- crown
-- masses: { centre x, y, radius, clumps {dx, dy, r} }
local masses = {
  { 32, 18, 11.5, { { -5, -4, 5.2 }, { 3, -6, 5.4 }, { 7, 1, 5 }, { -6, 3, 5 }, { 1, 2, 5.6 }, { -1, -8, 3.6 } } },
  { 20, 27, 8.6, { { -2, -2, 4.6 }, { 3, 1, 4.6 }, { -3, 3, 4.2 }, { 2, -4, 3.6 } } },
  { 44, 26, 8.6, { { 2, -2, 4.6 }, { -3, 1, 4.6 }, { 3, 3, 4.2 }, { -1, -4, 3.6 } } },
}
local painted = HP.mask()
local all = HP.mask()
for mi, M in ipairs(masses) do
  local cx, cy, Rr = M[1], M[2], M[3]
  local m, hgt, nn = HP.mask(), {}, {}
  for y = floor(cy - Rr - 4), floor(cy + Rr + 4) do for x = floor(cx - Rr - 4), floor(cx + Rr + 4) do
    local best, bn
    for _, b in ipairs(M[4]) do
      local bx, by, r = cx + b[1], cy + b[2], b[3]
      local dx, dy = x + 0.5 - bx - 0.5, y + 0.5 - by - 0.5
      local q = r * r - dx * dx - dy * dy
      if q >= 0 then
        local base = sqrt(max(0, Rr * Rr - (bx - cx) ^ 2 - (by - cy) ^ 2)) * 0.45
        local h = sqrt(q) + base
        if not best or h > best then best, bn = h, { dx / r, dy / r, sqrt(q) / r } end
      end
    end
    if best then
      m:set(x, y)
      local gx, gy = (x - cx) / (Rr + 1), (y - cy) / (Rr + 1)
      local gz = sqrt(max(0.05, 1 - gx * gx - gy * gy))
      nn[K(x, y)] = { R.norm(bn[1] * 0.55 + gx * 0.45, bn[2] * 0.55 + gy * 0.45, bn[3] * 0.55 + gz * 0.45) }
    end
  end end
  -- seams + AO where a front mass overlaps what is behind it, and dark underside
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if y > cy + Rr * 0.55 then bias[k] = -1 end
  end)
  local idx = R.shade(c, m, nn, LEAF, { amb = 0.1, wrap = 0.3, tok = lt, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- leafy flecks on the lit side: small 1-2 px brighter leaves; dark gaps on the shade side
  m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 13 + mi)
    local i = idx[k]
    if i >= 4 and h > 0.86 then R.step(c, idx, LEAF, x, y, 1, lt) if i >= 5 then R.step(c, idx, LEAF, x - 1, y + 1, 0, lt) end
    elseif i <= 3 and h > 0.9 then R.step(c, idx, LEAF, x, y, -1, lt) end end)
  -- this mass sits in front of earlier ones: seam line on the earlier mass, AO ring
  if mi > 1 then
    m:grow(1):cut(m):each(function(x, y) if painted:has(x, y) then c:put(x, y, LEAF[1], lt) end end)
    m:grow(2):cut(m:grow(1)):each(function(x, y) if painted:has(x, y) and not m:has(x, y) then
      local col = c:get(x, y) if col then c:put(x, y, LEAF[2], lt) end end end)
  end
  painted:add(m) all:add(m)
end
-- cast shadow of the crown on the trunk/branches
all:shift(1, 2):each(function(x, y) if wood:has(x, y) and not all:has(x, y) then R.step(c, widx, BARK, x, y, -2, bt) end end)
-- dark row where the branches disappear into the crown
wood:each(function(x, y) if not all:has(x, y) and (all:has(x, y - 1) or all:has(x - 1, y) or all:has(x + 1, y)) then
  c:put(x, y, BARK[1], bt) end end)
-- single pop on the top mass
c:put(25, 10, LEAF[6], lt) c:put(26, 10, LEAF[6], lt) c:put(25, 11, LEAF[6], lt)

---------------------------------------------------------------- quirk: orange leaf drifting down
local OL = { d = "#8f3a22", s = "#c95a24", b = "#f08a2a", h = "#ffc060", m = "#a84424" }
R.map(c, {
  "..h.",
  ".hbb",
  "hbms",
  "bms.",
  "sd..",
  "d...",
}, 50, 41, OL, { r = { name = "oleaf" } })

R.save(c, "ico-tree")

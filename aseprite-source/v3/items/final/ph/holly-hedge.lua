-- holly-hedge (final, Opus single pass). A trimmed holly hedge block, wider than tall: the body is a Voronoi tiling
-- of glossy, cupped holly leaves (each leaf lit by its own tilted normal over the whole-hedge pillow form, pale midrib,
-- dark gaps between leaves, glossy specular flecks), with spiny leaf tips breaking the outline along the top and
-- sides. Clusters of round red berries (4 px, glint, contact shadow on the leaves), AO under the hedge, three short
-- woody stems and a 2-tone ground shadow.
-- quirk: a lost blue knitted mitten hangs snagged on a spine at the top right.
local NAME = "holly-hedge"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#0f2a26", "#173f32", "#1f5a3c", "#2d7845", "#4c9a4f", "#86c467" }
local SPEC = "#dff5c4"
local BARK = { "#2e1b1f", "#4a2c28", "#6c4130", "#8f5a3a" }
local ltok, btok, rtok, mtok = { r = { name = "leaf" } }, { r = { name = "bark" } }, { r = { name = "berry" } }, { r = { name = "mitten" } }

c:groundShadow(32, 54, 23, 1.5)
-- stems under the hedge
for _, sx in ipairs{ 19, 32, 45 } do
  local m, n = A.tube({ { sx, 48 }, { sx, 50 }, { sx + 0.3, 51 }, { sx + 0.5, 53 } }, function(t) return 1.1 end)
  A.shade(c, m, n, BARK, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = btok })
  c:put(sx, 49, BARK[1], btok)
end

-- leaf centres: staggered grid with jitter, each with its own angle and tilt
local base = c:rrect(11, 24, 53, 49, 4)
local leaves = {}
local row = 0
for y = 24, 50, 3.6 do
  row = row + 1
  for x = 10 + (row % 2) * 2.6, 55, 5.2 do
    local i = #leaves + 1
    local a = (X.hash(i, row, 3) - 0.5) * 2.4 + (row % 2) * 0.5
    leaves[i] = { x = x + (X.hash(i, row, 1) - 0.5) * 1.6, y = y + (X.hash(i, row, 2) - 0.5) * 1.2,
      ux = cos(a), uy = sin(a), tx = (X.hash(i, row, 4) - 0.5) * 0.7, ty = (X.hash(i, row, 5) - 0.5) * 0.6 }
  end
end
-- spiny silhouette: tips and side spines of edge leaves poke out of the trimmed block
local hedge = base:copy()
local grow2 = base:grow(2)
local bedge = base:edge()
for _, L in ipairs(leaves) do
  local cx, cy = floor(L.x + 0.5), floor(L.y + 0.5)
  if base:has(cx, cy) and cy < 46 then
    local near = false
    for dy = -2, 2 do for dx = -2, 2 do if not base:has(cx + dx, cy + dy) then near = true end end end
    if near then
      for _, p in ipairs{ { 4.6, 0 }, { -4.6, 0 }, { 1.8, 3.0 }, { 1.8, -3.0 }, { -1.8, 3.0 }, { -1.8, -3.0 } } do
        local px = L.x + L.ux * p[1] - L.uy * p[2]
        local py = L.y + L.uy * p[1] + L.ux * p[2]
        local xi, yi = floor(px + 0.5), floor(py + 0.5)
        if yi < 47 and not base:has(xi, yi) and grow2:has(xi, yi) then
          hedge:set(xi, yi)
          local mx, my = floor(L.x + (px - L.x) * 0.72 + 0.5), floor(L.y + (py - L.y) * 0.72 + 0.5)
          if not base:has(mx, my) and not base:grow(1):has(mx, my) == false then hedge:set(mx, my) end
        end
      end
    end
  end
end

local gn = X.pillow(hedge, 6)
local nrm, bias, own, LU, LV = {}, {}, {}, {}, {}
hedge:each(function(x, y) local k = K(x, y)
  local d1, d2, b1 = 1e9, 1e9, nil
  for i, L in ipairs(leaves) do
    local dx, dy = x + 0.5 - L.x, y + 0.5 - L.y
    if abs(dx) < 8 and abs(dy) < 8 then
      local u, v = dx * L.ux + dy * L.uy, -dx * L.uy + dy * L.ux
      local d = sqrt((u / 3.3) ^ 2 + (v / 2.0) ^ 2)
      if d < d1 then d2 = d1 d1, b1 = d, i elseif d < d2 then d2 = d end
    end
  end
  local L = leaves[b1]
  own[k] = b1
  local dx, dy = x + 0.5 - L.x, y + 0.5 - L.y
  local u, v = dx * L.ux + dy * L.uy, -dx * L.uy + dy * L.ux
  LU[k], LV[k] = u, v
  local g = gn[k]
  -- cupped leaf: halves tilt away from the midrib
  local px, py = -L.uy * v * 0.22, L.ux * v * 0.22
  nrm[k] = { A.norm(g[1] + L.tx + px, g[2] + L.ty + py, g[3]) }
  if d2 - d1 < 0.2 then bias[k] = -2 end
end)
-- AO: bottom of the hedge and under the overhang
hedge:each(function(x, y) if y >= 47 then local k = K(x, y) bias[k] = (bias[k] or 0) - (y >= 49 and 2 or 1) end end)
local idx, val = A.shade(c, hedge, nrm, LEAF, { amb = 0.08, wrap = 0.22, bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.65, 0.8 } })
hedge:each(function(x, y) local k = K(x, y)
  if (bias[k] or 0) <= -2 then return end
  local u, v = LU[k], LV[k]
  -- pale midrib
  if abs(v) < 0.45 and abs(u) < 2.6 and idx[k] < 6 then c:put(x, y, LEAF[min(6, idx[k] + 1)], ltok)
  -- glossy flecks on the lit half of well-lit leaves
  elseif val[k] > 0.8 and v < -0.4 and v > -1.6 and abs(u) < 1.4 and X.hash(own[k], 1, 9) > 0.45 then c:put(x, y, SPEC, ltok) end
end)

-- berries: 4 px round, glint, contact shadow lower-right
local RB = { d = "#5c0f22", s = "#9a1a2c", b = "#d42a35", h = "#ff6a5a", g = "#fff0d8" }
local BER = { ".hb.", "hgbs", "bbsd", ".sd." }
local function berry(x0, y0)
  for _, p in ipairs{ { 4, 2 }, { 4, 3 }, { 3, 4 }, { 2, 4 } } do
    local x, y = x0 + p[1], y0 + p[2]
    if hedge:has(x, y) and not (c.own[y * 64 + x] == rtok) then c:put(x, y, LEAF[1], ltok) end
  end
  for r, rowS in ipairs(BER) do for i = 1, 4 do local ch = rowS:sub(i, i)
    if RB[ch] then c:put(x0 + i - 1, y0 + r - 1, RB[ch], rtok) end end end
end
for _, cl in ipairs{ { 14, 28 }, { 33, 27 }, { 22, 38 }, { 42, 37 } } do
  berry(cl[1], cl[2]) berry(cl[1] + 5, cl[2] + 1) berry(cl[1] + 2, cl[2] + 5)
end

-- quirk: knitted mitten snagged on a top spine
local MIT = { C = "#fff0d0", c = "#d9c6aa", h = "#a6d6ff", t = "#5a9be6", B = "#4a86d8", k = "#2f5aa8", s = "#33609f", d = "#233c72" }
local rows = {
  "..CcCc.",
  "..cCcC.",
  ".thBBBs",
  "thhBkBs",
  "thBkBBs",
  ".hBBkBs",
  ".hBBBBd",
  "..sBBd.",
  "...sd..",
}
for r, rowS in ipairs(rows) do for i = 1, #rowS do local ch = rowS:sub(i, i)
  if MIT[ch] then c:put(43 + i - 1, 18 + r - 1, MIT[ch], mtok) end end end
-- shadow the mitten casts on the hedge
for _, p in ipairs{ { 50, 22 }, { 50, 23 }, { 50, 24 }, { 50, 25 }, { 49, 26 }, { 48, 27 } } do
  if hedge:has(p[1], p[2]) and c.own[p[2] * 64 + p[1]] == ltok then c:put(p[1], p[2], LEAF[1], ltok) end end
A.save(c, NAME)

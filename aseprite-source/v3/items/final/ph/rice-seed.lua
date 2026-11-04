-- rice-seed (final draft D12, Sonnet). Three plump golden rice grains (husk ridges, pointed tip with a fine awn) lying on
-- a long narrow paddy-grass leaf scrap; the right grain has sprouted two thin grass blades. quirk: the left grain's husk
-- has split at the tip showing the pale kernel inside.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rice-seed")
local LEAF = D.R.leaf
D.blade(c, 4, 54, 60, 47, 5, LEAF, { veins = { 6, 12, 18, 24, 30, 36, 42, 48 }, slant = 0.7,
  prof = function(t) return 0.5 + 0.5 * sin(pi * min(1, t * 1.02 + 0.04)) ^ 0.6 end })
local function grain(cx, cy, ang, split)
  c:fillMask(B.ell(cx + 1, cy + 1.3, 6.4, 3.4, ang), "#1f553f")
  local m = B.ell(cx, cy, 6.2, 3.2, ang)
  local idx = B.lit(c, m, D.R.gold, 3)
  -- husk ridges along the grain
  local ca, sa = cos(ang), sin(ang)
  for u = -5, 4, 1 do for _, v in ipairs{ -1.1, 1.0 } do
    local x, y = floor(cx + u * ca - v * sa + .5), floor(cy + u * sa + v * ca + .5)
    if m:has(x, y) then c:px(x, y, D.R.gold[max(1, (idx[K(x, y)] or 3) - 1)]) end end end
  c:px(floor(cx - 2.4 * ca), floor(cy - 2.4 * sa - 1.2), "#fff4d6")
  -- awn
  D.ln(c, floor(cx + 6.4 * ca), floor(cy + 6.4 * sa), floor(cx + 9 * ca), floor(cy + 9 * sa - 1), D.R.gold[3])
  if split then
    local tx, ty = floor(cx + 4.4 * ca), floor(cy + 4.4 * sa)
    c:fillMask(c:rect(tx - 1, ty - 1, tx + 1, ty + 1), "#fff4d6") c:px(tx + 1, ty + 1, "#dcb590") c:px(tx - 1, ty, "#8f4a1f")
  end
  return m
end
grain(15, 47, -0.12, true) grain(28, 48, 0.05, false)
-- sprouting grain with blades
B.blade(c, 44, 45, 38, 21, 1.5, LEAF, { norib = true }) B.blade(c, 45, 45, 54, 24, 1.4, LEAF, { norib = true })
B.blade(c, 44, 45, 45, 13, 1.2, LEAF, { norib = true })
grain(44, 49, 0.1, false)
-- little white roots under the sprouting grain
for _, q in ipairs{ {41,52},{40,54},{39,55} } do c:px(q[1], q[2], "#e2f2bc") end c:px(47, 53, "#e2f2bc") c:px(48, 54, "#e2f2bc")
D.fin()

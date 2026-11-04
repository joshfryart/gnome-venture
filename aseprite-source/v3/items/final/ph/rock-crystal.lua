-- rock-crystal (final draft D12, Sonnet). A cluster of three hexagonal quartz prisms with pointed faceted tips, pale
-- icy-blue and glassy, rising from a little dusky purple rock base. quirk: a tiny rainbow flare is caught inside the
-- tallest crystal.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-crystal")
D.shadow(c, 32, 58, 22, 2.5)
local base = c:poly{ {8,56},{12,48},{20,46},{30,50},{40,46},{50,47},{56,56} }
D.lit(c, base, { "#2a2050", "#35295f", "#5a459e", "#7a62bc", "#a88ae0", "#c9b2f0" }, 3, {})
local GL = D.R.glass
local function prism(pts, x0, x1, tipy, toptip)
  local m = c:poly(pts)
  m:each(function(x, y)
    local f = (x - x0) / (x1 - x0)
    local i
    if f < 0.3 then i = 5 elseif f < 0.62 then i = 4 else i = 2 end
    if y < tipy then
      local mid = (x0 + x1) / 2
      if (x < mid) then i = (f < 0.3) and 5 or 4 else i = 2 end
      if abs(x - mid) < 0.8 then i = 6 end
    end
    c:px(x, y, GL[i])
  end)
  -- facet edge lines
  m:each(function(x, y) local f = (x - x0) / (x1 - x0)
    if y >= tipy and (abs(f - 0.3) < 0.07 or abs(f - 0.62) < 0.07) then c:px(x, y, GL[6]) end end)
  for y = tipy, tipy + 1 do for x = x0, x1 do if m:has(x, y) and y == tipy then c:px(x, y, GL[3]) end end end
  return m
end
-- left, right, then tall centre
local mL = prism({ {10,52},{10,34},{16,24},{22,34},{22,52} }, 10, 22, 34)
local mR = prism({ {39,52},{40,36},{47,27},{53,37},{53,52} }, 40, 53, 37)
local mC = prism({ {23,54},{23,24},{30,9},{37,24},{37,54} }, 23, 37, 24)
-- deep lines where prisms meet
for y = 36, 53 do c:px(23, y, GL[1]) end
-- inner glow
for y = 30, 50 do c:px(27, y, GL[6]) end c:px(27, 29, GL[6])
-- rainbow flare
local RB = { "#ff8aa8", "#ffd060", "#a8f0b0", "#7ad8ff" }
for i, col in ipairs(RB) do c:px(25 + i, 40 - i * 2 + 2, col) end
c:px(30, 33, "#fff4d6") c:px(31, 33, "#fff4d6")
-- tip glints
c:px(30, 12, "#fff4d6") c:px(15, 28, "#fff4d6")
D.fin()

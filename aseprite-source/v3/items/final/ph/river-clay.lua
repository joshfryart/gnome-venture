-- river-clay (final draft D12, Sonnet). A wet grey-brown lump of river clay on a flat river stone, three thumb dents, a
-- rolled coil lying across the front and a wet shine. quirk: a small pebble is pressed into one thumb dent.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("river-clay")
D.shadow(c, 32, 57, 26, 2.5)
local stone = c:ellipse(32, 52, 25, 5)
D.lit(c, stone, D.R.stone, 2.5, {})
local CL = { "#4a3a3c", "#6e5a58", "#947c72", "#b89e8c", "#d6bea8", "#ecdcc6" }
local lump = c:poly{ {9,50},{10,36},{18,24},{30,18},{44,22},{54,34},{56,48},{50,51} }
D.lit(c, lump, CL, 7, { wrap = 0.3 })
-- thumb dents
for _, q in ipairs{ {22,34},{34,28},{44,38} } do
  local d = B.ell(q[1], q[2], 3.4, 2.6, -0.3)
  c:fillMask(d, CL[2])
  for _, p in ipairs{ {-2,1},{-1,2},{0,2},{1,2},{2,1} } do c:px(q[1] + p[1], q[2] + p[2], CL[5]) end
  c:px(q[1], q[2] - 1, CL[1]) c:px(q[1] - 1, q[2] - 1, CL[1])
end
-- pebble in a dent
local pb = B.ell(35, 29, 1.6, 1.3, 0) B.lit(c, pb, D.R.stone, 1.2)
-- coil across front
local cm, T = D.sw(c, { {14,47},{24,41},{40,50},{52,44} }, function(t) return 2.6 end, CL, 2.2)
cm:each(function(x, y) local t = T[K(x, y)] or 0 if floor(t * 12) % 3 == 0 then c:px(x, y, CL[2]) end end)
-- wet shine
c:px(18, 28, "#fff4d6") c:px(19, 28, "#fff4d6") c:px(17, 29, "#fff4d6")
c:px(26, 22, "#ecdcc6") c:px(48, 36, "#ecdcc6")
-- drip of water
c:px(12, 53, "#8bc4ea") c:px(12, 54, "#5f9ad0")
D.fin()

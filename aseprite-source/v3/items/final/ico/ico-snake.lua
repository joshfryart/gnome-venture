-- ico-snake first draft. green S-coil snake with diamond blotches and forked tongue. quirk: a red bow tie at the neck
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local floor, sin, pi = math.floor, math.sin, math.pi
local c = D.new("ico-snake")
local pts = {}
local N = 90
for i = 0, N do
  local t = i / N
  pts[#pts + 1] = { 32 + 17 * sin(t * pi * 2.4 + 0.2), 56 - t * 44, t }
end
local body = D.swept(c, pts, function(t) return 2.2 + math.min(t * 5, 1) * 1.8 - t * 0.6 end)
D.lit(c, body, D.GRN, 3.5)
for i = 8, N - 14, 9 do
  local q = pts[i]
  D.lit(c, c:ellipse(floor(q[1] + .5), floor(q[2] + .5), 1.5, 1.5), { "#1f5a44", "#1f5a44", "#2f8450", "#e6cf5a", "#f0e07a", "#f8f0a0" }, 1)
end
-- head
local hq = pts[#pts]
local hx, hy = floor(hq[1] + .5), floor(hq[2] + .5)
D.lit(c, D.ell(hx, hy - 1, 6, 5), D.GRN, 3)
c:eyeSmall(hx - 3, hy - 4)
D.pts(c, { {hx + 2, hy - 3} }, "#2b1c26")
-- tongue
D.polyline(c, { {hx, hy - 6}, {hx, hy - 9} }, "#d4403a")
D.pts(c, { {hx - 1, hy - 10}, {hx + 1, hy - 10} }, "#d4403a")
-- bow tie
local nq = pts[N - 8]
local nx, ny = floor(nq[1] + .5), floor(nq[2] + .5)
D.lit(c, c:poly{ {nx - 6, ny - 3}, {nx, ny}, {nx - 6, ny + 3} }, D.RED, 1)
D.lit(c, c:poly{ {nx + 6, ny - 3}, {nx, ny}, {nx + 6, ny + 3} }, D.RED, 1)
D.R(c, nx - 1, ny - 1, nx + 1, ny + 1, "#a82c3c")
D.fin()

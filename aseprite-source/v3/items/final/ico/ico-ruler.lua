-- ico-ruler first draft. slanted brass-edged ruler with tick marks. quirk: a red string tassel through a hole in the end
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local floor, sqrt = math.floor, math.sqrt
local c = D.new("ico-ruler")
local A, B = { 9, 42 }, { 52, 8 }
local L = sqrt((B[1]-A[1])^2 + (B[2]-A[2])^2)
local ux, uy = (B[1]-A[1]) / L, (B[2]-A[2]) / L
local nx, ny = -uy, ux
local bar = D.mk(0, 0, 63, 63, function(x, y)
  local dx, dy = x - A[1], y - A[2]
  local t, s = dx*ux + dy*uy, dx*nx + dy*ny
  return t >= 0 and t <= L and s >= -6 and s <= 6
end)
D.lit(c, bar, D.YEL, 3.5)
for t = 5, L - 3, 4 do
  local len = (floor(t / 4) % 2 == 0) and 5 or 3
  for k = 0, len - 1 do
    c:px(floor(A[1] + ux*t - nx*(5 - k) + .5), floor(A[2] + uy*t - ny*(5 - k) + .5), "#8f4a1f")
  end
end
-- hole + tassel
local hx, hy = floor(A[1] + ux*4 + 1), floor(A[2] + uy*4 + 1)
D.R(c, hx - 1, hy, hx + 1, hy + 2, "#2b1c26")
D.polyline(c, { {hx, hy + 2}, {hx - 4, hy + 8}, {hx - 3, hy + 12} }, "#d4403a")
D.polyline(c, { {hx - 1, hy + 2}, {hx - 5, hy + 8}, {hx - 4, hy + 12} }, "#a82c3c")
D.R(c, hx - 5, hy + 12, hx - 2, hy + 14, "#ee6a50")
D.fin()

local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shale-chip (D15 first draft). A flat slab of layered blue-grey shale, thin bands tilting across it, one corner freshly chipped away with the flake lying beside it.
-- quirk: a tiny fern fossil is pressed into the face.
local c = D.new("shale-chip")
c:groundShadow(32, 55, 22, 3)
local m = c:poly{ { 8, 42 }, { 13, 27 }, { 28, 19 }, { 42, 19 }, { 47, 27 }, { 54, 36 }, { 50, 47 }, { 34, 53 }, { 15, 51 } }
m:cut(c:poly{ { 42, 18 }, { 50, 22 }, { 47, 28 }, { 41, 24 } })
local L = { "#8c8ea4", "#74758c", "#a4a6b8", "#6a6c88", "#8f88ad", "#7c7f9a" }
m:each(function(x, y)
  local k = floor((y + x * 0.18) / 3) % #L + 1
  c:px(x, y, L[k])
end)
local inner = m:shrink(1)
m:each(function(x, y)
  if not inner:has(x, y) then
    if x + y > 78 or y > 48 then c:px(x, y, R.stone[1]) else c:px(x, y, R.stone[6]) end
  end
end)
-- fern fossil
D.ln(c, 20, 42, 36, 31, R.stone[2], m)
for i = 0, 5 do
  local x, y = 22 + i * 2.6, 41 - i * 1.8
  D.ln(c, floor(x), floor(y), floor(x) + 2, floor(y) - 4, R.stone[2], m)
  D.ln(c, floor(x), floor(y), floor(x) + 4, floor(y) + 2, R.stone[2], m)
end
-- fresh chip edge
D.polyline(c, { { 42, 19 }, { 41, 24 }, { 47, 28 } }, R.stone[6], m)
-- flake
local f = c:poly{ { 51, 50 }, { 56, 46 }, { 59, 52 }, { 54, 55 } }
D.lit(c, f, R.stone, 2)
D.fin()

-- trip (tag: Trip). A tripwire: two driven stakes with a taut twisted rope pulled between them across a grassy path,
-- a little gold bell tied mid-span. Quirk: the bell has been silenced by a stuffed acorn-cap clapper.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("trip")
-- ground strip
local g = c:ellipse(32, 56, 28, 4)
S.fill(c, g, R.moss, { lx = 0.2, ly = 1, bias = function() return -1 end })
for _, p in ipairs{ { 10, 54 }, { 22, 56 }, { 42, 55 }, { 52, 54 } } do c:fillMask(c:line({ { p[1], p[2] }, { p[1] + 1, p[2] - 3 } }, 1), R.moss[5]) end
local function stake(x0, x1)
  local m = c:poly{ { x0, 10 }, { x1, 10 }, { x1 + 1, 50 }, { (x0 + x1) / 2 + 1, 56 }, { x0 - 1, 50 } }
  S.fill(c, m, R.wood, { lx = 1, ly = 0.15 })
  c:fillMask(c:rect(x0, 10, x1, 11), R.wood[5])           -- cut top
  for y = 20, 46, 7 do c:px(x0 + 1, y, R.wood[2]) c:px(x0 + 2, y + 1, R.wood[2]) end -- grain
  return m
end
stake(7, 14) stake(49, 56)
-- rope winds around stakes
for _, x in ipairs{ 7, 49 } do for k = 0, 2 do c:fillMask(c:rect(x - 1, 33 + k * 3, x + 8, 33 + k * 3), (k % 2 == 0) and R.amber[5] or R.amber[3]) end end
-- rope (sagging), twisted
local pts = { { 13, 36 }, { 22, 40 }, { 32, 42 }, { 42, 40 }, { 50, 36 } }
local rope = c:line(pts, 3)
S.fill(c, rope, R.amber, { lx = 0.1, ly = 1 })
rope:each(function(x, y) if (x + y // 1) % 4 == 0 then c:px(x, y, R.amber[2]) elseif (x + y) % 4 == 2 then c:px(x, y, R.amber[6]) end end)
-- bell
local bell = c:poly{ { 29, 45 }, { 35, 45 }, { 37, 52 }, { 27, 52 } }
S.fill(c, bell, R.gold, { lx = 1, ly = 0.4 })
c:fillMask(c:rect(31, 43, 33, 44), R.steel[3]) -- loop
c:fillMask(c:ellipse(32, 53, 2, 1), R.wood[4]) c:px(31, 52, R.wood[5]) -- acorn cap clapper
c:fillMask(c:rect(28, 52, 36, 52), R.gold[2])
c:px(30, 47, R.gold[6]) c:px(30, 48, R.gold[6])
c:sparkle(32, 28)
S.save(c, "trip")

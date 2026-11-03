local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- acorn-cap: oak cupule seen from the side, scaly rows, rough rim, stubby stalk. quirk: an oak seedling pokes out of the stalk nub.
local c = D.new("acorn-cap")
c:groundShadow(32, 55, 16, 2)
local cap = c:ellipse(32, 38, 17, 14):clip(c:rect(0, 0, 63, 46))
cap:add(c:rect(15, 38, 49, 46):clip(c:ellipse(32, 30, 17, 17)))
D.lit(c:ellipse(32, 38, 17, 15):clip(c:rect(0,0,63,47)), D.BRN, 6)
-- scales: rows of arcs
local rows = {{27,5},{32,6},{37,6},{42,7}}
for ri, r in ipairs(rows) do
  local y = r[1]
  for x = 16, 48 do
    local off = (ri % 2) * 3
    local k = (x + off) % 6
    if cap:has(x, y) or c:ellipse(32,38,17,15):has(x,y) then
      if k == 0 then c:px(x, y, "#51302b") c:px(x, y+1, "#51302b") end
      if k == 1 or k == 2 then c:px(x, y-1, "#c98a54") end
    end
  end
end
-- stalk nub + seedling
D.lit(c:rect(29, 18, 35, 24), D.BRN, 2)
D.stem(32, 18, 32, 10, "#86b86c")
D.lf(27, 10, 4, 1.6, -0.3, D.LEAF2) D.lf(37, 8, 4, 1.6, 0.4, D.LEAF2)
-- rim chips
for _, x in ipairs{19, 25, 33, 41, 46} do c:px(x, 47, "#51302b") end
D.fin()

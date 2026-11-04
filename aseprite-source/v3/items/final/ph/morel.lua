-- morel: honeycomb-capped mushroom on a pale slim stem. quirk: a tiny ladybird crawls on the cap.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local floor = math.floor
local H, HP, B, X = D.H, D.HP, D.B, D.X
local c = D.new("morel")
local CAP = D.R("#e6c488", "#b88a4a", "#85582f", "#4c2f22")
local STEM = D.R("#fff4d6", "#ead9b6", "#c0aa8c", "#8a7360")
c:groundShadow(32, 57, 11, 2)
local stem = c:rrect(26, 34, 38, 56, 4)
H.vcyl(c, stem, STEM, 26, 38)
for i = 0, 5 do c:px(28 + (i * 3) % 8, 38 + i * 3, "#c0aa8c") end
local base = c:ellipse(32, 55, 7, 2)
B.lit(c, base, STEM, 2)
local cap = c:ellipse(32, 21, 12, 17):cut(c:rect(0, 36, 63, 63))
cap:add(c:ellipse(32, 34, 13, 3))
B.lit(c, cap, CAP, 9, { hs = 1 })
local k = 0
for row = 0, 5 do
  local y = 11 + row * 4.6
  for col = -3, 3 do
    local x = 32 + col * 4.8 + (row % 2) * 2.4
    local p = c:ellipse(floor(x), floor(y), 1.2, 1.6)
    if cap:shrink(1):has(floor(x), floor(y)) and cap:shrink(1):has(floor(x)+1, floor(y)+2) then
      c:fillMask(p, "#4c2f22")
      c:px(floor(x) - 1, floor(y) + 2, "#e6c488")
      c:px(floor(x), floor(y) + 2, "#e6c488")
      c:px(floor(x), floor(y) - 1, "#2b1c26")
    end
  end
end
c:px(26, 12, "#fff4d6") c:px(27, 12, "#fff4d6")
-- ladybird
local lb = c:ellipse(37, 14, 2, 1.5)
c:fillMask(lb, "#e8493b") c:px(37, 13, "#2b1c26") c:px(37, 15, "#2b1c26") c:px(35, 14, "#2b1c26") c:px(38, 14, "#fff4d6")
D.fin()

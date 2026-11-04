-- stone-path (lean W2_28)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-path" }
local GREY = { "#3a3650", "#59546e", "#7a7490", "#9c96ae", "#bdb8c8", "#dcd8e2" }
local TAN = { "#4a3a3a", "#6e5a52", "#917a6a", "#b49a84", "#d2b9a0", "#ecd8bf" }
local MAUVE = { "#43284a", "#654068", "#885c88", "#a87ca4", "#c79cc0", "#e4c0dc" }
local MOSS = { "#1f3d2c", "#2f5a35", "#47803f", "#6aa24a", "#94c45c" }
c:groundShadow(32, 52, 22, 4)
local S = {
  {33,15,6,4,GREY},{45,17,5,4,TAN},
  {22,24,6,5,TAN},{36,25,7,5,MAUVE},{50,28,5,5,GREY},
  {14,34,6,5,GREY},{28,35,7,5,MAUVE},{43,37,6,5,TAN},
  {11,45,6,5,MAUVE},{23,46,7,5,TAN},{37,48,6,4,GREY},{50,45,5,4,MAUVE},
}
for i, s in ipairs(S) do
  local m = c:ellipse(s[1], s[2], s[3], s[4])
  c:fillMask(m:copy():grow(1), "#2e2236")
  local n = X.pillow(m, s[4] + 1.5)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), s[5], { 0.2, 0.38, 0.55, 0.7, 0.86 })
  m:each(function(x, y) if X.hash(x, y, i) > 0.9 and X.light(n, {amb=0.1,wrap=0.25})[K(x,y)] > 0.45 then c:px(x, y, s[5][2]) end end)
  c:px(s[1] - s[3] // 2, s[2] - s[4] // 2, s[5][6])
end
local function moss(x, y, pts) for _, p in ipairs(pts) do c:px(x + p[1], y + p[2], MOSS[p[3]]) end end
moss(29, 30, { {0,0,2},{1,0,3},{0,-1,3},{1,-1,4},{-1,0,2} })
moss(18, 40, { {0,0,2},{1,0,3},{0,1,2},{1,-1,4} })
moss(46, 32, { {0,0,2},{1,0,3},{1,-1,4},{2,0,2} })
moss(30, 44, { {0,0,2},{1,0,3},{0,-1,4} })
-- quirk: one tiny yellow flower in a gap
c:px(40, 31, "#fff0b0") c:px(39, 31, "#f2c030") c:px(41, 31, "#f2c030") c:px(40, 30, "#f2c030") c:px(40, 32, "#f2c030")
c:px(40, 31, "#c0701e")
G.fin(c, "stone-path")

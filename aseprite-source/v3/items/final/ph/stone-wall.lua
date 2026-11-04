-- stone-wall (lean W2_28)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-wall" }
local GREY = { "#3a3650", "#59546e", "#7a7490", "#9c96ae", "#bdb8c8", "#dcd8e2" }
local TAN = { "#4a3a3a", "#6e5a52", "#917a6a", "#b49a84", "#d2b9a0", "#ecd8bf" }
local MAUVE = { "#43284a", "#654068", "#885c88", "#a87ca4", "#c79cc0", "#e4c0dc" }
local MOSS = { "#1f3d2c", "#2f5a35", "#47803f", "#6aa24a", "#94c45c" }
local RAMPS = { GREY, TAN, MAUVE }
c:groundShadow(32, 53, 25, 3)
c:fillMask(c:rect(9, 17, 53, 51), "#4a3d4d")
local rows = {
  { 16, 24, { 10, 8, 11, 9, 7 }, 3 },
  { 25, 31, { 7, 11, 9, 10, 8 }, 1 },
  { 32, 38, { 11, 8, 10, 7, 9 }, 1 },
  { 39, 45, { 8, 10, 9, 11, 7 }, 1 },
  { 46, 51, { 10, 9, 8, 11, 7 }, 1 },
}
local k = 0
for ri, r in ipairs(rows) do
  local x = 9
  for _, w in ipairs(r[3]) do
    k = k + 1
    local m = (r[4] > 1) and c:rrect(x, r[1], x + w - 2, r[2], r[4]) or c:rect(x, r[1], x + w - 2, r[2] - 1)
    local ramp = RAMPS[(k * 7 + ri) % 3 + 1]
    local n = X.pillow(m, 3.5)
    local v = X.light(n, { amb = 0.15, wrap = 0.3 })
    G.tone(c, m, v, ramp, { 0.18, 0.36, 0.54, 0.7, 0.86 })
    m:each(function(px, py) if X.hash(px, py, k) > 0.92 then c:px(px, py, ramp[2]) end end)
    c:px(x + 1, r[1] + 1, ramp[6])
    x = x + w
  end
end
-- crack in one brick
for _, p in ipairs{ {30,33},{31,34},{31,35},{32,36} } do c:px(p[1], p[2], "#2e2236") end
-- moss creeping up bottom-left and on cap
local function moss(x, y, pts) for _, p in ipairs(pts) do c:px(x + p[1], y + p[2], MOSS[p[3]]) end end
moss(10, 50, { {0,0,2},{1,0,3},{2,0,2},{0,-1,3},{1,-1,4},{0,-2,2},{3,0,3},{4,0,2} })
moss(42, 24, { {0,0,2},{1,0,3},{2,0,2},{1,-1,4},{0,1,2} })
moss(47, 51, { {0,0,2},{1,0,3},{2,0,2},{1,-1,4} })
-- quirk: a little daisy growing on the cap
c:px(21, 15, MOSS[3]) c:px(21, 14, MOSS[3]) c:px(21, 13, MOSS[4])
for _, p in ipairs{ {20,12},{22,12},{21,11},{21,13} } do c:px(p[1], p[2], "#f4ecf0") end
c:px(21, 12, "#f2b020")
G.fin(c, "stone-wall")

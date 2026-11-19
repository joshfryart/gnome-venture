local NAME = "stone-wall-end"
-- stone-wall-end (redraw): chunky drystone wall end, 3/4 view. Few BIG stones (3 courses), lighter mortar, stepped rough
-- end face in shade, mossy capstones, grass at the foot. quirk: tiny yellow flower in the cap.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local RAMPS = {
  { "#3a3a4c", "#58586e", "#7a7a92", "#9c9cb2", "#bcbccc", "#dcdce6" },
  { "#4a3a34", "#6e564a", "#927866", "#b69a82", "#d2b89e", "#ecd8be" },
  { "#34404e", "#4e6074", "#6e8498", "#90a6b8", "#b4c6d2", "#d6e2ea" },
}
local MORT = "#3a3048"
local GREEN = { "#163a35", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local function tok(n) return { r = { name = n } } end
c:groundShadow(33, 56, 24, 3)
local FX0, FX1, FY0, FY1 = 10, 38, 26, 53
local DX, DY = 10, -5
local front = c:rect(FX0, FY0, FX1, FY1)
local side = c:poly{ {FX1 + 1, FY0 + DY}, {FX1 + DX, FY0 + DY - 1}, {FX1 + DX, FY1 + DY}, {FX1 + 1, FY1} }
local top = c:poly{ {FX0, FY0 - 1}, {FX0 + DX, FY0 + DY - 4}, {FX1 + DX, FY0 + DY - 4}, {FX1 + 1, FY0 - 1} }
c:fillMask(front, MORT) c:fillMask(side, "#2a2236") c:fillMask(top, MORT)
-- explicit big stones: {x0,y0,x1,y1,ramp}
local function stone(region, x0, y0, x1, y1, ri, shade, id)
  local m = c:rrect(x0, y0, x1, y1, 3):clip(region)
  local ramp = RAMPS[ri]
  G.toneN(c, m, X.pillow(m, 4), ramp, { tok = tok("s" .. id), cuts = CUTS, amb = 0.1 + shade, wrap = 0.2 })
  m:shrink(1):each(function(px, py) if X.hash(px, py, id) > 0.93 then c:put(px, py, ramp[2], tok("s" .. id)) end end)
  -- top-left chip highlight
  c:put(x0 + 2, y0 + 1, ramp[6], tok("s" .. id)) c:put(x0 + 3, y0 + 1, ramp[5], tok("s" .. id))
end
-- front: 3 courses (9,9,9 rows), staggered
local rows = {
  {26, { {10,19,1}, {21,38,2} }},
  {35, { {10,26,3}, {28,38,1} }},
  {44, { {10,14,2}, {16,29,1}, {31,38,3} }},
}
local id = 0
for _, r in ipairs(rows) do for _, s in ipairs(r[2]) do id = id + 1 stone(front, s[1], r[1] + 1, s[2], r[1] + 8, s[3], 0, id) end end
-- end face (darker, stepped)
local srows = { {21, { {39,48,2} }}, {30, { {39,44,1}, {45,50,3} }}, {39, { {39,50,1} }} }
for _, r in ipairs(srows) do for _, s in ipairs(r[2]) do id = id + 1 stone(side, s[1], r[1] + 1, s[2], r[1] + 8, s[3], -0.14, id) end end
-- capstones
stone(top, 10, 20, 27, 25, 2, 0.2, 90) stone(top, 29, 17, 47, 24, 1, 0.2, 91)
-- moss on cap and joints
top:each(function(x, y) if X.hash(x, y, 77) > 0.8 and (x * 3 + y) % 5 < 3 then c:put(x, y, GREEN[2 + floor(X.hash(y, x, 3) * 3)], tok("moss")) end end)
for _, p in ipairs{ {13,35},{14,36},{20,44},{27,43},{36,35},{37,36},{40,40},{16,52},{15,53} } do c:put(p[1], p[2], GREEN[3], tok("moss")) end
-- grass tufts
for _, g in ipairs{ {12,53}, {26,54}, {37,53}, {49,49} } do
  for dy = 0, 2 do c:put(g[1] + (dy == 2 and -1 or 0), g[2] - dy, GREEN[2 + dy % 3], tok("grass")) end
  c:put(g[1] + 1, g[2] - 1, GREEN[4], tok("grass")) c:put(g[1] - 2, g[2] - 1, GREEN[3], tok("grass"))
end
-- quirk flower
for _, p in ipairs{ {22,18,"#ffd24e"}, {21,18,"#fff09a"}, {23,18,"#fff09a"}, {22,17,"#fff09a"}, {22,19,"#f2b52a"} } do c:put(p[1], p[2], p[3], tok("flower")) end
c:put(22, 18, "#e8742a", tok("flower"))
G.save(c, NAME)

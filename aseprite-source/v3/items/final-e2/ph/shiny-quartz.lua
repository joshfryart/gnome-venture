-- shiny-quartz (lean E2_07)
local NAME = "shiny-quartz"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: a tiny rainbow inclusion (pink/mint/gold) trapped in the big crystal
c:groundShadow(32, 55, 21, 3)
local rock = c:ellipse(32, 52, 21, 5):add(c:ellipse(20, 53, 9, 4)):add(c:ellipse(44, 53, 8, 4))
shade(c, rock, { "#241c3a", "#352a52", "#4a3d6c", "#615486", "#7b6ea0", "#9a8dba" }, 4, "rock")
local function face(pts, col, name) local m = c:poly(pts) c:fillMask(m, col, { r = { name = name } }) return m end
-- small left crystal
face({{11,52},{11,40},{14,31},{18,40},{18,52}}, "#cfe6fb", "sl")
face({{14,31},{18,40},{18,52},{15,52},{14,40}}, "#8fb0e6", "sl2")
face({{11,40},{14,31},{14,40}}, "#f4fbff", "sl3")
-- small right crystal
face({{43,52},{43,38},{47,25},{51,38},{51,52}}, "#a9d0f5", "sr")
face({{47,25},{51,38},{51,52},{47,52}}, "#6f8fcf", "sr2")
face({{43,38},{47,25},{46,38}}, "#e6f4ff", "sr3")
-- main prism
face({{22,52},{22,27},{28,27},{28,52}}, "#e6f4ff", "L")
face({{28,52},{28,27},{35,27},{35,52}}, "#a9d0f5", "M")
face({{35,52},{35,27},{41,27},{41,52}}, "#6f8fcf", "R")
face({{22,27},{28,27},{31,8}}, "#f4fbff", "T1")
face({{28,27},{35,27},{31,8}}, "#cfe6fb", "T2")
face({{35,27},{41,27},{31,8}}, "#8fb0e6", "T3")
-- facet edges
local function ln(pts, col) c:line(pts, 1):each(function(x, y) c:put(x, y, col, { r = { name = "ed" } }) end) end
ln({{28,28},{28,50}}, "#f4fbff") ln({{35,28},{35,50}}, "#4a5ca8") ln({{28,27},{31,10}}, "#f4fbff") ln({{35,27},{31,10}}, "#6f8fcf")
-- deep base shade and reflection streak
for x = 22, 41 do c:put(x, 51, "#4a5ca8") c:put(x, 50, x < 28 and "#8fb0e6" or "#5a6cb8") end
for y = 31, 43 do c:put(30, y, "#e6f4ff") end
c:put(30, 45, "#e6f4ff") c:put(23, 29, "#f4fbff") c:put(23, 30, "#f4fbff")
-- rainbow inclusion
c:put(32, 37, "#f08ec0") c:put(33, 38, "#ffd873") c:put(32, 39, "#8ee8c0") c:put(31, 38, "#b8a0f0")
c:sparkle(25, 17)
G.save(c, NAME)

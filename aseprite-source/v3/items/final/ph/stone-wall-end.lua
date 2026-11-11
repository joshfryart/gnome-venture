local NAME = "stone-wall-end"
-- stone-wall-end: end of a drystone wall seen 3/4: front face, stepped rough end face (darker), capstone top with moss,
-- mixed grey / warm / blue stones with mortar gaps, grass tufts at the base. quirk: a tiny yellow flower in the cap.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local RAMPS = {
  { "#3a3a4c", "#58586e", "#7a7a92", "#9c9cb2", "#bcbccc", "#dcdce6" },   -- cool grey
  { "#4a3a34", "#6e564a", "#927866", "#b69a82", "#d2b89e", "#ecd8be" },   -- warm tan
  { "#34404e", "#4e6074", "#6e8498", "#90a6b8", "#b4c6d2", "#d6e2ea" },   -- blue slate
}
local MORT = "#2a2230"
local GREEN = { "#163a35", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
c:groundShadow(34, 57, 26, 3)
local FX0, FX1, FY0, FY1 = 10, 41, 25, 54       -- front face
local DX, DY = 11, -5                           -- end face depth offset (to the right and up)
local tok = function(n) return { r = { name = n } } end
-- regions
local front = c:rect(FX0, FY0, FX1, FY1)
local side = c:poly{ {FX1 + 1, FY0 + DY}, {FX1 + DX, FY0 + DY - 1}, {FX1 + DX, FY1 + DY}, {FX1 + 1, FY1} }
local top = c:poly{ {FX0, FY0 - 1}, {FX0 + DX, FY0 + DY - 4}, {FX1 + DX, FY0 + DY - 4}, {FX1 + 1, FY0 - 1} }
c:fillMask(front, MORT) c:fillMask(side, "#1e1824") c:fillMask(top, MORT)
local function stones(region, x0, y0, x1, y1, rows, wlo, whi, seed, shift, rr)
  local y = y0
  for r, h in ipairs(rows) do
    local x = x0 - ((r * 5 + seed) % 7)
    local i = 0
    while x < x1 do
      i = i + 1
      local w = wlo + floor(X.hash(x, y, seed + i) * (whi - wlo + 1))
      local sx0, sx1 = max(x + 1, x0), min(x + w - 1, x1)
      local m = c:rrect(sx0, y + 1, sx1, y + h - 1, rr or 2):clip(region)
      if m:count() > 3 then
        local ri = 1 + floor(X.hash(x, y, seed + 40) * 3)
        local ramp = RAMPS[ri]
        local n = X.pillow(m, 3)
        local idx = G.toneN(c, m, n, ramp, { tok = tok("st" .. seed .. r .. i), cuts = CUTS, amb = 0.1 + shift, wrap = 0.2 })
        -- chips/speckle
        m:shrink(1):each(function(px, py) if X.hash(px, py, seed + 9) > 0.9 then c:put(px, py, ramp[2 + floor(X.hash(py, px, 5) * 2)], tok("st" .. seed .. r .. i)) end end)
      end
      x = x + w
    end
    y = y + h
  end
end
stones(front, FX0, FY0, FX1, FY1, { 7, 6, 8, 7, 7 }, 7, 12, 1, 0.0, 2)
stones(side, FX1 + 1, FY0 + DY - 1, FX1 + DX, FY1 + DY, { 7, 6, 8, 7, 7 }, 4, 8, 2, -0.12, 2)
stones(top, FX0, FY0 + DY - 4, FX1 + DX, FY0 - 1, { 6 }, 7, 11, 3, 0.18, 2)
-- moss on cap and mortar lines, AO under the cap lip
top:each(function(x, y) if X.hash(x, y, 77) > 0.76 and (x * 3 + y) % 5 < 3 then c:put(x, y, GREEN[2 + floor(X.hash(y, x, 3) * 3)], tok("moss")) end end)
for _, p in ipairs{ {13,31},{14,32},{20,40},{27,46},{36,32},{37,33},{16,50},{15,51} } do c:put(p[1], p[2], GREEN[3], tok("moss")) end
for x = FX0, FX1 do c:put(x, FY0, MORT, tok("ao")) end
-- grass tufts at the base
for _, g in ipairs{ {13,54}, {24,55}, {38,54}, {50,49} } do
  for dy = 0, 2 do c:put(g[1] + (dy == 2 and -1 or 0), g[2] - dy, GREEN[2 + dy % 3], tok("grass")) end
  c:put(g[1] + 1, g[2] - 1, GREEN[4], tok("grass")) c:put(g[1] - 2, g[2] - 1, GREEN[3], tok("grass"))
end
-- quirk: tiny flower on the cap
for _, p in ipairs{ {26,22,"#ffd24e"}, {25,22,"#fff09a"}, {27,22,"#fff09a"}, {26,21,"#fff09a"}, {26,23,"#f2b52a"} } do c:put(p[1], p[2], p[3], tok("flower")) end
c:put(26, 22, "#e8742a", tok("flower"))
G.save(c, NAME)

-- shiny-quartz (lean W2_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "shiny-quartz" }
local floor, abs = math.floor, math.abs
local ICE = { "#4b4d94", "#6f82c6", "#9cb9e4", "#c4def5", "#e3f3fc", "#f8fdff" }
local ROCK = { "#3a2f4a", "#51446a", "#6d5f88", "#8b7ea6" }
local EDGE = "#2b1c26"
c:groundShadow(32, 56, 20, 2)
-- matrix rock lump
local rock = c:ellipse(32, 53, 19, 4)
rock:each(function(x, y)
  local i = (y <= 51) and 4 or (y <= 53 and 3 or (y <= 55 and 2 or 1))
  if X.hash(x, y, 3) > 0.86 then i = math.min(4, i + 1) end
  c:put(x, y, ROCK[i], { r = { name = "rock" } })
end)
-- faceted prism: columns L (lit), M, R (shade) + tip faces
local function crystal(cx, by, w, h, lean, tipH, shift)
  local bl, sy = cx - w / 2, by - h
  local f = { 0, 0.34, 0.7, 1 }
  local cols = { 4 + shift, 3 + shift, 1 + shift }
  local tipc = { 5, 4, 2 }
  local tx, ty = floor(cx + lean + 0.5), sy - tipH
  for i = 1, 3 do
    local xa, xb = floor(bl + f[i] * w + 0.5), floor(bl + f[i + 1] * w + 0.5) - 1
    local m = c:poly{ { xa, by }, { xb, by }, { xb + lean, sy }, { xa + lean, sy } }
    c:fillMask(m, ICE[math.max(1, math.min(6, cols[i]))])
    local t = c:poly{ { xa + lean, sy }, { xb + lean, sy }, { tx, ty } }
    c:fillMask(t, ICE[math.max(1, math.min(6, tipc[i] + (shift > 0 and 0 or -1)))])
  end
  -- ridge highlight between L and M, shoulder line, dark base rim
  local rx = floor(bl + f[2] * w + 0.5)
  c:fillMask(c:line({ { rx, by - 1 }, { rx + lean, sy } }, 1), ICE[6])
  c:fillMask(c:line({ { floor(bl + 0.5) + lean, sy }, { floor(bl + w + 0.5) - 1 + lean, sy } }, 1), ICE[3])
  c:fillMask(c:line({ { floor(bl + 0.5), by }, { floor(bl + w + 0.5) - 1, by } }, 1), ICE[1])
  return tx, ty, sy
end
crystal(19, 52, 7, 10, -3, 5, 0)
crystal(45, 53, 9, 15, 3, 6, 0)
local tx, ty, sy = crystal(30, 52, 14, 26, 2, 9, 1)
crystal(38, 55, 5, 5, 0, 3, 0)
-- quirk: phantom inner crystal ghost in the big prism
for _, p in ipairs{ {28, 45}, {29, 44}, {30, 43}, {31, 44}, {32, 45}, {28, 46}, {32, 46} } do c:px(p[1], p[2], ICE[5]) end
c:px(30, 42, ICE[2]) c:px(30, 44, "#e8b8e8") c:px(30, 45, "#d890d0")
-- glints
c:px(26, 30, ICE[6]) c:px(26, 31, ICE[6]) c:px(27, 25, ICE[6])
c:sparkle(22, 33)
c:px(44, 41, ICE[6]) c:px(17, 44, ICE[6])
G.fin(c, "shiny-quartz")

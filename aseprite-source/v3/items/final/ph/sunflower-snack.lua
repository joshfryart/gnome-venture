-- sunflower-snack (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sunflower-snack" }
local BOWL = { "#4a4a78", "#6a72a4", "#94a2c6", "#bccadc", "#dde6ec", "#f6f8f4" }
local SEED = { "#6b4520", "#946030", "#bd8444", "#dca65e", "#f0c880", "#fbe6b0" }
local SHELL = { "#26242c", "#3c3a46", "#585566", "#7a7888", "#a7a4b0", "#d7d4d6" }
c:groundShadow(30, 57, 19, 2)
-- foot + bowl
shade(c, c:rrect(22, 52, 38, 55, 1), BOWL, 2, { r = { name = "foot" } })
local bowl = c:ellipse(30, 34, 19, 18):cut(c:rect(0, 0, 63, 33))
shade(c, bowl, BOWL, 14, { r = { name = "bowl" } })
shade(c, c:rrect(10, 31, 50, 36, 2), BOWL, 3, { r = { name = "rim" } })
-- band of sunflower dots
for x = 18, 42, 4 do
  c:px(x, 44, "#f6c529") c:px(x + 1, 44, "#d98a1a") c:px(x, 43, "#ffe270") c:px(x + 1, 43, "#f6c529")
end
-- mound of kernels
local dome = c:ellipse(30, 31, 16, 12):cut(c:rect(0, 32, 63, 63))
c:fillMask(dome, SEED[1])
local n = X.pillow(dome, 9)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local row = 0
for y = 21, 32, 3 do
  for x = 15 + (row % 2) * 2, 46, 4 do
    local cx, cy = x + floor(X.hash(x, y, 3) * 2), y + floor(X.hash(x, y, 5) * 2)
    if dome:has(cx - 1, cy) and dome:has(cx + 1, cy + 1) then
      local l = v[K(cx, cy)] or 0.5
      local i = max(2, min(6, 2 + floor(l * 5)))
      c:px(cx - 1, cy, SEED[i]) c:px(cx, cy, SEED[min(6, i + 1)]) c:px(cx + 1, cy, SEED[i])
      c:px(cx, cy + 1, SEED[max(1, i - 1)]) c:px(cx + 1, cy + 1, SEED[max(1, i - 1)])
    end
  end
  row = row + 1
end
c:px(24, 23, "#fff6f2") c:px(25, 23, "#fff6f2")
-- quirk: two striped shells + a petal at the foot
local s1, sn1 = G.oval(48, 54, 5, 2.4, -0.45, 1)
shade(c, s1, SHELL, 3, { r = { name = "shell" } })
for i = -3, 3 do c:px(floor(48 + i * 0.9), floor(54 + i * -0.4), SHELL[6]) end
local s2, sn2 = G.oval(53, 50, 4, 2, 0.5, 1)
shade(c, s2, SHELL, 3, { r = { name = "shell2" } })
for i = -2, 2 do c:px(floor(53 + i * 0.9), floor(50 + i * 0.4), SHELL[5]) end
G.save(c, "sunflower-snack")

-- snake-skin (lean W2_19)
-- Shed snake skin in a loose S: papery pale green, diamond scale pattern, empty eye socket (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snake-skin" }
local SK = { "#5f7f6c", "#86a98a", "#aecb9f", "#cfe2b8", "#e6f2cf", "#f8fbe6" }
local DK = "#35503f"
local function body(pts, wfn)
  local m, n, T, S = G.tube(pts, wfn)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, SK)
  m:each(function(x, y) local k = K(x, y)
    local a, b = (x + y) % 5, (x - y) % 5
    if a == 0 and b == 0 then c:px(x, y, SK[2]) elseif a == 2 and b == 2 then c:px(x, y, SK[5]) end
    if abs(S[k]) > 0.8 and S[k] > 0 then c:px(x, y, SK[1]) end
  end)
  return m
end
local A = body({ {17,22}, {30,8}, {56,12}, {50,32} }, function(t) return 4.6 end)
local B = body({ {50,32}, {48,54}, {22,38}, {10,52} }, function(t) return 4.6 * (1 - t)^0.7 + 0.6 end)
-- head
local h = G.rell(14, 23, 1, 0.25, 8, 5)
G.tone(c, h, X.light(X.pillow(h, 5), { amb = 0.12, wrap = 0.25 }), SK)
h:each(function(x, y) if (x + y) % 5 == 0 and (x - y) % 5 == 0 then c:px(x, y, SK[2]) end end)
-- empty eye socket + nostril
c:fillMask(c:rect(14, 20, 15, 21), DK) c:px(14, 20, SK[6]) c:px(8, 24, SK[1])
-- mouth seam
G.line(c, { {7, 26}, {12, 28}, {17, 27} }, SK[1])
G.fin(c, "snake-skin")

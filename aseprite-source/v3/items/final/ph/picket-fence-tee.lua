-- picket-fence-tee (lean E2_05)
local NAME = "picket-fence-tee"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local BL = { "#1f3f8a", "#2f63c4", "#4f8ee8", "#8fc4ff" }
c:groundShadow(31, 57, 27, 3)
-- rails behind
for _, y in ipairs{ 24, 40 } do
  RC(4, y, 27, y + 2, D[3]) RC(4, y + 2, 27, y + 2, D[1]) RC(4, y, 27, y, D[4])
  RC(35, y, 58, y + 2, D[3]) RC(35, y + 2, 58, y + 2, D[1]) RC(35, y, 58, y, D[4])
end
local function picket(x, y0, y1, w, k)
  for y = y0, y1 do
    local x0, x1 = x, x + w - 1
    local r = y - y0
    if r == 0 then x0, x1 = x + 2, x + w - 3 elseif r == 1 then x0, x1 = x + 1, x + w - 2 end
    for xx = x0, x1 do
      local col = (xx == x) and W[6] or (xx == x + 1) and W[5] or (xx == x + w - 1) and W[2] or (xx == x + w - 2) and W[3] or W[4]
      if y >= y1 - 1 then col = (xx >= x + w - 2) and W[1] or W[2] end
      P(xx, y, col)
    end
  end
  -- weathered grain + nail
  for y = y0 + 5, y1 - 3 do if X.hash(x, y, k) > 0.86 then P(x + 1 + floor(X.hash(y, x, k) * (w - 2)), y, W[3]) end end
  P(x + 2, y0 + 6, W[2]) P(x + 2, y1 - 6, W[2])
end
for i, x in ipairs{ 4, 10, 16, 22 } do picket(x, (i == 3) and 22 or 18, 52, 5, i) end
for i, x in ipairs{ 36, 42, 48, 54 } do picket(x, (i == 2) and 21 or 18, 52, 5, 10 + i) end
-- post
local post = c:rect(28, 14, 34, 55)
dome(post, D, 2.5, "post", { amb = 0.15, wrap = 0.3 })
for y = 16, 54 do if X.hash(31, y, 5) > 0.7 then P(29 + floor(X.hash(y, 3, 5) * 4), y, D[2]) end end
RC(28, 52, 34, 55, D[1]) RC(28, 52, 29, 52, D[2])
-- cap
local cap = c:poly{ { 26, 14 }, { 31, 8 }, { 36, 14 } }
dome(cap, D, 3, "cap", { amb = 0.2, wrap = 0.3 })
RC(26, 14, 36, 15, D[4]) RC(27, 15, 36, 15, D[2]) P(26, 14, D[6])
-- front stub pickets (third arm toward viewer) + rail
RC(24, 46, 40, 48, D[3]) RC(24, 48, 40, 48, D[1]) RC(24, 46, 40, 46, D[4])
picket(23, 32, 58, 5, 21) picket(36, 32, 58, 5, 22)
RC(23, 44, 40, 46, D[3]) RC(23, 46, 40, 46, D[1]) RC(23, 44, 40, 44, D[4])
picket(23, 32, 58, 5, 21) picket(36, 32, 58, 5, 22)
RC(28, 50, 35, 50, D[2])
-- bluebird quirk on the cap
for _, p in ipairs{ {30,6,2},{31,6,3},{32,6,2},{29,7,2},{30,7,3},{31,7,3},{32,7,2},{33,7,2},{29,8,1},{30,8,2},{31,8,2},{32,8,1},{27,8,2},{28,8,1} } do P(p[1], p[2], BL[p[3]]) end
P(33, 5, BL[3]) P(34, 5, BL[3]) P(34, 6, BL[2]) P(35, 6, "#f2b84a") P(33, 6, "#fbf3d0") P(34, 5, "#101018") P(31, 6, BL[4]) P(30, 5, BL[4])
P(30, 9, "#b8742c") P(32, 9, "#b8742c")
G.save(c, NAME)

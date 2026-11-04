-- starfruit (lean D2o_12)
-- Whole ribbed carambola leaning on a cut star slice (with a bite taken out of one point).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "starfruit" }
local YEL = { "#a8531c", "#d6821f", "#f0a820", "#f8c93a", "#fde06a", "#fff3a8" }
local GRN = { "#3d6a2c", "#5e8f2e", "#8cb336", "#b5cf48", "#d6e262", "#eef5a0" }
c:groundShadow(34, 55, 22, 2)
local CX = 21
local body = HP.mask()
for y = 11, 53 do
  local t = (y - 11) / 42
  local h = 11 * sin(pi * (0.07 + 0.86 * t)) ^ 0.55
  local cx = CX + (0.5 - t) * 3
  for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do body:set(x, y) end
end
local n = X.pillow(body, 10)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
local top = body:copy():cut(c:rect(0, 18, 63, 63))
local bot = body:copy():cut(c:rect(0, 0, 63, 47))
local mid = body:copy():cut(top):cut(bot)
G.tone(c, mid, v, YEL) G.tone(c, top, v, GRN) G.tone(c, bot, v, GRN)
for _, u in ipairs{ -0.62, 0, 0.62 } do
  for y = 15, 49 do
    local t = (y - 11) / 42
    local h = 11 * sin(pi * (0.07 + 0.86 * t)) ^ 0.55
    local x = floor(CX + (0.5 - t) * 3 + u * h * 0.9 + 0.5)
    if body:has(x, y) then
      c:px(x, y, (y < 19 or y > 45) and GRN[5] or YEL[5])
      if body:has(x + 1, y) and u < 0.5 then c:px(x + 1, y, (y < 19 or y > 45) and GRN[2] or YEL[2]) end
    end
  end
end
c:px(15, 22, "#fffbe0") c:px(15, 23, "#fffbe0") c:px(16, 21, YEL[6])
-- stem + leaf
G.line(c, { {22, 11}, {22, 8}, {24, 6} }, "#5a3a22") c:px(23, 8, "#8a5a32")
c:fillMask(c:poly{ {24, 7}, {28, 5}, {30, 7}, {26, 8} }, "#5e8f2e") c:px(27, 6, "#b5cf48")
-- star slice
local CXs, CYs = 45, 42
local pts, core = {}, {}
for i = 0, 9 do
  local a = -pi / 2 + i * pi / 5
  local r = (i % 2 == 0) and 12.5 or 6.4
  pts[#pts + 1] = { floor(CXs + r * cos(a) + 0.5), floor(CYs + r * sin(a) + 0.5) }
  local r2 = (i % 2 == 0) and 8 or 3.6
  core[#core + 1] = { floor(CXs + r2 * cos(a) + 0.5), floor(CYs + r2 * sin(a) + 0.5) }
end
local slice = c:poly(pts):cut(c:ellipse(45, 29, 3, 2.4))
solid(c, slice, YEL, 5, 0.25)
slice:copy():shrink(1):each(function(x, y) end)
c:fillMask(c:poly(core), "#fff3c0")
for i = 0, 9, 2 do local a = -pi / 2 + i * pi / 5 G.line(c, { {CXs, CYs}, {floor(CXs + 7 * cos(a) + 0.5), floor(CYs + 7 * sin(a) + 0.5)} }, "#f0b038") end
c:px(CXs, CYs, "#d6821f")
c:px(42, 37, "#6b3a1c") c:px(43, 37, "#6b3a1c") c:px(48, 45, "#6b3a1c") c:px(49, 45, "#6b3a1c") c:px(39, 47, "#6b3a1c")
c:px(41, 33, "#fffbe0") c:px(42, 33, "#fff3a8")
G.fin(c, "starfruit")

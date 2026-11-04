-- wild-rice-hotdish (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-rice-hotdish" }
-- 3/4 view of a lugged casserole: rim ellipse, golden crusted wild-rice filling studded with dark grains and mushroom bits, spoon, steam. quirk: spoon left standing in it.
local POT = { "#5a3320", "#7d4a2c", "#a2693a", "#c98a4c", "#e5ad6a", "#f6cf92" }
local FILL = { "#3a2616", "#5a3a20", "#7e5530", "#a67a42", "#cfa45c", "#efd08a" }
c:groundShadow(32, 53, 20, 3)
-- body
local body = c:rrect(14, 32, 49, 51, 6)
local bn = shade(c, body, POT, 9, { amb = 0.12, wrap = 0.25 })
-- lugs
for _, L in ipairs{ {10, 39}, {50, 39} } do
  local m = c:rrect(L[1], L[2], L[1] + 4, L[2] + 5, 2) shade(c, m, POT, 3, { amb = 0.2 })
end
-- band decoration
c:fillMask(c:rect(17, 44, 46, 44), POT[2]) c:fillMask(c:rect(17, 45, 46, 45), POT[5])
for x = 19, 45, 4 do c:px(x, 47, POT[2]) c:px(x + 1, 47, POT[2]) end
-- rim and filling
local rim = c:ellipse(32, 33, 19, 8)
shade(c, rim, POT, 8, { amb = 0.35, wrap = 0.3 })
local fm = c:ellipse(32, 33, 16, 6)
local n, v = shade(c, fm, FILL, 6, { amb = 0.2, wrap = 0.3 })
fm:each(function(x, y)
  local h = X.hash(x, y, 8)
  if h > 0.86 then c:px(x, y, "#2e1c14") c:px(x + 1, y, "#4a3022") end
  if h < 0.06 then c:px(x, y, "#e2d4b4") c:px(x + 1, y, "#e2d4b4") end
end)
c:px(24, 31, FILL[6]) c:px(25, 31, FILL[6])
-- spoon (quirk)
local sp = G.tube({ {41, 31}, {43, 24}, {45, 17}, {46, 11} }, function(t) return 1.2 end)
shade(c, sp, { "#6a6f86", "#9aa0b6", "#c6cbdc", "#eef0fa" }, 2, { amb = 0.2 })
c:fillMask(c:ellipse(46, 10, 2, 3), "#c6cbdc") c:px(45, 9, "#eef0fa")
-- steam
for _, s in ipairs{ {22, 8}, {30, 6} } do
  local m = G.tube({ {s[1], s[2] + 14}, {s[1] + 2, s[2] + 10}, {s[1] - 2, s[2] + 5}, {s[1], s[2]} }, function(t) return 0.9 end)
  m:each(function(x, y) c:px(x, y, "#e6e0ee") end)
end
G.fin(c, "wild-rice-hotdish")

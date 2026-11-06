-- tomato-passata (lean D3o_5)
-- A tall slim glass bottle with a long neck and sloped shoulders, deep red passata inside, cork stopper,
-- twine around the neck and a cream tomato label.
-- quirk: a basil leaf is tucked under the twine.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tomato-passata" }
local sin, cos, pi, sqrt, abs, floor = math.sin, math.cos, math.pi, math.sqrt, math.abs, math.floor
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local GL = { "#4a6a8e", "#7a9cbc", "#a8c8de", "#cce2ee", "#e6f4f8", "#fffff6" }
local RD = { "#3c0c20", "#661430", "#9c2234", "#c83a3a", "#e45c46", "#f98c64" }
local CR = { "#a09088", "#d4c4b0", "#efe4cc", "#fff8e4" }
local CK = { "#6a4630", "#94683c", "#b98a52", "#d8aa6c" }
c:groundShadow(32, 55, 13, 2)
local function hw(y)
  if y <= 12 then return 5 end
  if y <= 22 then return 4 end
  if y <= 33 then local t = (y - 22) / 11 return 4 + 9 * (0.5 - 0.5 * cos(t * pi)) end
  if y <= 53 then return 13 end
  return 13 - (y - 52) * 1.9
end
local bottle = HP.mask()
for y = 10, 56 do for x = 17, 47 do if abs(x - 31.5) <= hw(y) then bottle:set(x, y) end end end
sh(bottle, GL, 13, 0.2, 0.4)
-- passata
local liq = HP.mask()
for y = 27, 55 do for x = 17, 47 do
  if abs(x - 31.5) <= hw(y) - 2 and not (y > 55) then liq:set(x, y) end
end end
local ln, lv = sh(liq, RD, 12, 0.06, 0.28)
liq:each(function(x, y) if X.hash(x, y, 2) > 0.94 and lv[K(x, y)] > 0.4 then c:px(x, y, RD[5]) end end)
-- meniscus
for x = 24, 39 do if liq:has(x, 27) then c:px(x, 27, RD[6]) end end
for x = 22, 41 do if liq:has(x, 28) and x % 2 == 0 then c:px(x, 28, RD[5]) end end
-- glass highlights
for y = 35, 52 do c:px(21, y, GL[6]) end
c:px(21, 53, GL[4]) c:px(22, 34, GL[5]) c:px(22, 35, GL[5])
for y = 14, 21 do c:px(29, y, GL[6]) end
for y = 38, 50 do c:px(42, y, "#e8708a") end
-- lip and cork
c:fillMask(c:rect(25, 10, 38, 12), GL[3]) c:fillMask(c:rect(25, 12, 38, 12), GL[1]) c:fillMask(c:rect(25, 10, 38, 10), GL[5])
local cork = c:rrect(27, 5, 36, 11, 1)
local kn, kv = sh(cork, CK, 4, 0.15, 0.3)
c:px(29, 7, CK[1]) c:px(33, 8, CK[1]) c:px(31, 6, CK[4]) c:px(34, 8, CK[1])
-- label
c:fillMask(c:rect(23, 37, 41, 50), CR[3])
c:fillMask(c:rect(23, 50, 41, 50), CR[1]) c:fillMask(c:rect(41, 37, 41, 50), CR[2]) c:fillMask(c:rect(23, 37, 41, 37), CR[4])
c:fillMask(c:ellipse(32, 44, 4, 3.5), "#d03a40") c:px(30, 42, "#f26a48") c:px(31, 42, "#f26a48") c:px(34, 46, "#7a1a38") c:px(33, 46, "#7a1a38")
c:px(31, 40, "#4b9650") c:px(32, 40, "#32764b") c:px(33, 40, "#4b9650") c:px(32, 41, "#32764b")
for x = 25, 29 do c:px(x, 48, CR[1]) end for x = 35, 39 do c:px(x, 39, CR[1]) end
-- twine around neck
for x = 27, 36 do c:px(x, 16, (x % 2 == 0) and "#8a6a40" or "#c9a566") c:px(x, 17, (x % 2 == 1) and "#6a4e30" or "#a8884e") end
-- basil leaf (quirk)
local lm, ln2 = G.tube({ {35, 17}, {37, 15}, {40, 14}, {42, 15} }, function(t) return 0.6 + 2.2 * sin(pi * t) ^ 0.7 end)
G.tone(c, lm, X.light(ln2, { amb = 0.12, wrap = 0.3 }), { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" })
c:px(36, 17, "#9ccd6c") c:px(38, 15, "#9ccd6c") c:px(39, 15, "#9ccd6c")
G.fin(c, "tomato-passata")

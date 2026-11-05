-- mossy-shell (lean E2_03)
local NAME = "mossy-shell"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local T = { r = { name = "d" } }
local function body(m, ramp, R, name, amb)
  local n = X.pillow(m, R)
  local idx = X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = name } } })
  return n, idx
end
local function draw(lm, hex, within) lm:each(function(x, y) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end) end
local function dot(x, y, hex, within) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end
c:groundShadow(32, 56, 20, 2)
local R = { "#5c4050", "#8c6874", "#bc928c", "#dcb8a2", "#f0d6b8", "#fcecd2" }
local m = c:ellipse(31, 33, 21, 20)
-- aperture lip bulging lower right
local lip = c:ellipse(46, 46, 9, 7)
m:add(lip)
body(m, R, 20, "shell")
-- spiral whorl
local cx, cy = 30, 31
local pts = {}
for i = 0, 70 do
  local th = i * 0.17
  local r = 1.5 + th * 1.55
  pts[#pts + 1] = { cx + cos(th + 2.4) * r, cy + sin(th + 2.4) * r }
end
local sp = c:line(pts, 1)
sp:each(function(x, y) if m:has(x, y) then c:put(x, y, R[2], T) end end)
sp:shift(1, 1):each(function(x, y) if m:has(x, y) and not sp:has(x, y) then c:put(x, y, R[6], T) end end)
sp:shift(-1, -1):each(function(x, y) if m:has(x, y) and not sp:has(x, y) then c:put(x, y, R[1], T) end end)
-- dark opening
local mo = c:ellipse(47, 47, 6, 4)
body(mo, { "#1a0e18", "#2e1426", "#4a2034", "#6a2e44", "#8a4058", "#b05c72" }, 5, "mouth", 0.0)
for x = 41, 53 do dot(x, 43, R[6], m) end
-- moss clump upper left, fuzzy past the edge
local MS = { "#1c3a24", "#2c5a30", "#437c38", "#68a043", "#98c855", "#c8e47a" }
local mm = c:ellipse(22, 20, 11, 8)
mm:add(c:ellipse(31, 15, 7, 5)) mm:add(c:ellipse(14, 28, 5, 6))
local fuzz = HP.mask()
mm:grow(1):each(function(x, y) if not mm:has(x, y) and X.hash(x, y, 9) > 0.55 then fuzz:set(x, y) end end)
mm:add(fuzz)
body(mm, MS, 8, "moss", 0.05)
mm:each(function(x, y) if X.hash(x, y, 3) > 0.8 then c:put(x, y, MS[6], T) end if X.hash(x, y, 8) > 0.88 then c:put(x, y, MS[2], T) end end)
-- quirk: tiny red mushroom growing from the moss
dot(30, 12, "#e8dcc0") dot(30, 11, "#e8dcc0") dot(30, 10, "#d8c8a4")
local cap2 = c:ellipse(30, 9, 3, 2)
body(cap2, { "#6a1424", "#a02034", "#d03a40", "#ec6050", "#f89478", "#ffe0c8" }, 3, "cap")
dot(29, 8, "#fff4e0") dot(32, 9, "#fff4e0")
G.save(c, NAME)

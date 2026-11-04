-- spiral-shell (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spiral-shell" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local SH  = { "#8a5a46", "#b98466", "#dfaa86", "#f2cfa6", "#fbe6c4", "#fff4de" }
local STR = { "#4a2418", "#6e3a22", "#9a5a34", "#c07f4a", "#dba46a", "#f0c78e" }
local PNK = { "#f0a8b0", "#d8788a", "#a8485a", "#6b2a3c", "#3a1520" }
local W = { {32,12,3,3}, {32,18,5.5,4.5}, {31,26,8.5,6}, {31,35,11.5,7.5}, {30,45,15,10} }
local body
for i, w in ipairs(W) do
  local m = c:ellipse(w[1], w[2], w[3], w[4])
  local v, idx = shade(m, SH, w[4] + 2)
  m:each(function(x, y)
    if floor((x + y * 0.6) / 3) % 3 == 0 then c:px(x, y, STR[idx[K(x, y)] or 3]) end
  end)
  m:each(function(x, y) if not m:has(x, y - 1) then c:px(x, y, STR[1]) end end)
  body = m
end
-- aperture
local ap = c:ellipse(38, 47, 6, 5):clip(body)
local lip = c:ellipse(38, 47, 7, 6):clip(body)
c:fillMask(lip, "#f7c9b4")
shade(ap, PNK, 5)
c:px(34, 44, "#fff4de") c:px(35, 43, "#fff4de")
c:px(24, 36, SH[6]) c:px(25, 36, SH[6]) c:px(24, 37, SH[5])
-- pearl (quirk)
c:fillMask(c:ellipse(50, 53, 2, 2), "#e2daf0")
c:px(49, 52, "#fbfcff") c:px(51, 54, "#9a8cc0")
G.fin(c, "spiral-shell")

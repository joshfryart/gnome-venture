-- stage-tuber-1 (lean D2o_10)
-- First tuber sprout: a lumpy potato-like tuber with eye dimples breaks the soil; a vine rises and spirals at the tip, with heart-shaped leaves. Quirk: spiral tendril tip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tuber-1" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local LEAFD = { "#14303a", "#1d4640", "#295f3f", "#3d7b44", "#5a9a4c", "#86b85a" }
local LEAFY = { "#2a5236", "#3f7a42", "#5f9c48", "#86bb52", "#b0d462", "#d8ee90" }
local WOOD  = { "#2f1c24", "#4b2c2c", "#6d4330", "#8f5e3c", "#b5814c", "#d9a96a" }
local RED   = { "#4a1030", "#7a1634", "#a82233", "#d03a30", "#ee6a40", "#ffa070" }
local ORANGE= { "#7a2a1e", "#b0431c", "#dc6a1c", "#f39a24", "#ffc54a", "#fff0a0" }
local SOIL  = { "#2a1822", "#432733", "#5f3a38", "#7f5440", "#a2704c", "#c49565" }
local TUBER = { "#4a2a2c", "#6e4338", "#935c44", "#b7805a", "#d6a874", "#efce98" }
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local tok = { r = { name = "part" } }
local function shade(m, ramp, R, amb, bias)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias, tok)
  return n
end
local function blob(cx, cy, rx, ry, ramp) local m = c:ellipse(cx, cy, rx, ry) shade(m, ramp, min(rx, ry) + 1) return m end
local function bez(p, t) local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2] end
local function limb(pts, fn, ramp)
  local m, n = G.tube(pts, fn)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, CUTS, nil, tok)
  return m
end
local function leaf(ax, ay, bx, by, wmax, ramp, heart)
  ramp = ramp or LEAF
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = wmax * sin(pi * (0.05 + 0.95 * t)) ^ 0.7 * (heart and (1.25 - 0.6 * t) or (1 - 0.2 * t))
    return max(0.5, w)
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ramp, CUTS, nil, tok)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.2 and t < 0.92 and t > 0.05 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], tok)
    elseif t > 0.25 then
      for _, vt in ipairs{ 0.4, 0.58, 0.76 } do
        local d = (t - vt) * len - abs(s) * 1.8
        if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.8 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
      end
    end
  end)
  return m
end
local function soil(cx, cy, rx, ry)
  c:groundShadow(cx + 2, cy + ry - 1, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, ry + 1)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), SOIL, CUTS, nil, tok)
  for i = 1, 14 do
    local x, y = cx - rx + 3 + floor(X.hash(i, 3, 7) * (2 * rx - 6)), cy - ry + 1 + floor(X.hash(i, 5, 9) * (2 * ry - 2))
    if m:has(x, y) then c:px(x, y, X.hash(i, 1, 2) > 0.5 and SOIL[6] or SOIL[1]) end
  end
  return m
end
local function texture(m, ramp, seed)
  m:each(function(x, y) local h = X.hash(x, y, seed)
    if h > 0.93 then c:px(x, y, ramp[6]) elseif h < 0.05 then c:px(x, y, ramp[1]) end end)
end

soil(32, 53, 21, 5)
blob(22, 51, 9, 4, TUBER)
c:fillMask(c:ellipse(18,51,1,1), TUBER[1]) c:fillMask(c:ellipse(25,50,1,1), TUBER[1]) c:px(18,50,TUBER[6]) c:px(25,49,TUBER[6])
c:px(15,49,TUBER[6]) c:px(21,47,TUBER[5]) c:px(23,53,TUBER[2]) c:px(29,52,TUBER[2])
limb({ {38,53},{34,40},{44,34},{40,24} }, function(t) return 1.4 - 0.3*t end, LEAFY)
limb({ {40,24},{36,19},{41,13},{46,16} }, function(t) return 1.1 - 0.5*t end, LEAFY)
c:px(46,16,LEAFY[2]) c:px(45,17,LEAFY[5])
leaf(36,43,22,38,5,LEAF,true) leaf(42,32,56,28,5,LEAFD,true) leaf(39,22,28,17,4.2,LEAF,true)
leaf(22,47,17,42,2.2,LEAFY,true)
c:sparkle(50, 12)

G.fin(c, "stage-tuber-1")

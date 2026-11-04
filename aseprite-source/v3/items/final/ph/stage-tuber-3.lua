-- stage-tuber-3 (lean D2o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tuber-3" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local SOIL = { "#2e1f26", "#4a2e2c", "#6b4332", "#8c5a3a", "#ad7646", "#cf9a5c" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local TUB  = { "#5a3a2e", "#7e5638", "#a67a48", "#c99d62", "#e3be80", "#f3dba0" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "soil" } }
local function soil(cx, cy, rx, ry, furrows)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, ry + 2)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), SOIL, nil, nil, stok)
  m:each(function(x, y)
    local h = X.hash(x, y, 3)
    if h > 0.94 then c:put(x, y, SOIL[2], stok) elseif h < 0.05 then c:put(x, y, SOIL[5], stok) end
  end)
  if furrows then for i = 1, furrows do
    local yy = cy - ry + 3 + i * 2.6
    for x = cx - rx + 4, cx + rx - 4 do local y = floor(yy + 0.5 + 0.6 * sin((x - cx) * 0.25 + i))
      if m:has(x, y) then c:put(x, y, SOIL[2], stok) if m:has(x, y - 1) then c:put(x, y - 1, SOIL[5], stok) end end end
  end end
  return m
end
local function leaf(p, wmax, o)
  o = o or {}
  local m, n, T, S = G.tube(p, function(t)
    if t > 0.99 then return -1 end
    local s = max(0, sin(pi * t))
    local b = wmax * s ^ (o.pw or 0.7)
    if o.serr then b = b + 0.5 * sin(t * 40) * s end
    if t < 0.22 then b = min(b, 0.7 + t * 2) end
    return max(0.6, b)
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), LEAF, nil, nil, ltok)
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.18 and t > 0.12 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
    if o.vein and abs(s) > 0.3 and abs(s) < 0.8 and t > 0.3 and t < 0.9 and (floor((t * 40) - abs(s) * 6) % 5 == 0) then c:put(x, y, s <= 0 and LEAF[5] or LEAF[2], ltok) end
    if o.yellow and t > o.yellow then c:put(x, y, s <= 0 and "#e6d36a" or "#b9a23e", ltok) end
  end)
  return m, T
end
local function tuber(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  G.tone(c, m, X.light(X.pillow(m, ry + 1), { amb = 0.1, wrap = 0.25 }), TUB, nil, nil, { r = { name = "tuber" } })
  m:each(function(x, y) if X.hash(x, y, 8) > 0.9 then c:put(x, y, TUB[2]) end end)
  c:put(floor(cx + rx * 0.2), floor(cy), TUB[1]) c:put(floor(cx - rx * 0.4), floor(cy + 1), TUB[1])
  c:put(floor(cx - rx * 0.5), floor(cy - ry * 0.5), TUB[6])
  return m
end

soil(32, 52, 22, 8, 2)
leaf({ {32,47},{22,43},{14,36},{10,26} }, 4.2, {vein=true})
leaf({ {32,47},{42,43},{50,36},{54,27} }, 4.2, {vein=true})
leaf({ {32,47},{26,40},{22,30},{21,18} }, 4.2, {vein=true})
leaf({ {32,47},{38,40},{43,30},{44,19} }, 4.2, {vein=true})
leaf({ {32,47},{31,36},{33,24},{32,10} }, 4.6, {vein=true})
local sm = G.tube({ {34,47},{36,42},{39,38},{38,33} }, function(t) return 0.8 end)
c:fillMask(sm, LEAF[4])
c:fillMask(c:ellipse(38, 31, 2.6, 2.2), "#c9a8e6")
c:put(38, 31, "#f2c84a") c:put(36, 30, "#f0e4fa") c:put(40, 32, "#8e6cb8")
G.fin(c, "stage-tuber-3")

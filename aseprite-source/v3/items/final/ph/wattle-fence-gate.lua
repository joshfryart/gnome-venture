-- wattle-fence-gate (lean D3o_10)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local c
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local W    = { "#3a2220", "#5e3a2a", "#855034", "#a86c3e", "#cf9150", "#efc275" }
local R    = { "#4f3324", "#7a4f2c", "#a3733a", "#c9964a", "#e5bb62", "#f8dc8e" }
local CORD = { "#5a4a30", "#8a7448", "#b79f64", "#dcc98c" }
local IRON = { "#2a2a38", "#454659", "#6f7185", "#a3a5b8" }
local SOIL = { "#2e1f24", "#4a3030", "#6b4a3a", "#8c6648", "#ad8658" }
local GRS  = { "#2c5a3c", "#437a45", "#6aa352", "#9bcb6e" }
local function hs(x, y, s) return X.hash(x, y, s) end
local function cl(i) return max(1, min(6, i)) end
local function colIdx(k, w) return cl(floor(6 - ((k + 0.5) / w) * 4.2)) end
local function stakeV(x0, y0, y1, w, ramp, tip, seed)
  for y = y0, y1 do
    local d, ins = y - y0, 0
    if tip == "point" then ins = min(max(0, floor(w / 2) - d), floor((w - 1) / 2))
    elseif tip == "round" and d == 0 then ins = 1 end
    for k = ins, w - 1 - ins do
      local i, h = colIdx(k, w), hs(x0 + k, y, seed or 3)
      if h > 0.86 and k > 0 and k < w - 1 then i = cl(i - 1) end
      if h < 0.05 and k < w - 1 then i = cl(i + 1) end
      c:px(x0 + k, y, ramp[i])
    end
  end
  c:px(x0 + (w > 4 and 1 or 0), y0 + 2, ramp[6])
end
local function rodH(x0, x1, yc, t, ramp, seed)
  for r = 0, t - 1 do for x = x0, x1 do
    if not ((x == x0 or x == x1) and (r == 0 or r == t - 1)) then
      local i, h = colIdx(r, t), hs(x, yc + r, seed or 5)
      if h > 0.88 and r > 0 and r < t - 1 then i = cl(i - 1) end
      if h < 0.06 and r == 0 then i = cl(i + 1) end
      c:px(x, yc + r, ramp[i])
    end
  end end
end
local function weaveBack(rows, t, xL, xR, ramp, seed) for ri, yc in ipairs(rows) do rodH(xL, xR, yc, t, ramp, seed + ri) end end
local function weaveFront(stakes, sw, rows, t, ramp, seed)
  for ri, yc in ipairs(rows) do for i, sx in ipairs(stakes) do
    if (i + ri) % 2 == 0 then
      for x = sx, sx + sw - 1 do c:px(x, yc + t, W[1]) end
      rodH(sx - 1, sx + sw, yc, t, ramp, seed + ri)
    else
      for r = 1, t - 1 do c:px(sx + sw, yc + r, ramp[2]) end
    end
  end end
end
local function lash(x0, x1, y0, h)
  for y = y0, y0 + h - 1 do for x = x0, x1 do
    local i = (y == y0) and 4 or (y == y0 + h - 1 and 1 or 3)
    if (x + y) % 3 == 0 and i > 1 and i < 4 then i = 2 end
    c:px(x, y, CORD[i])
  end end
end
local function soil(x0, x1, y0, h, seed)
  for r = 0, h - 1 do
    local ins = max(0, (h - 1 - r) * 0 + (r == 0 and 3 or (r == 1 and 1 or 0)))
    for x = x0 + ins, x1 - ins do
      local i = (r == 0) and 4 or (r == 1 and 3 or 2)
      local q = hs(x, y0 + r, seed)
      if q > 0.85 then i = i + 1 elseif q < 0.12 then i = i - 1 end
      c:px(x, y0 + r, SOIL[max(1, min(5, i))])
    end
  end
  for x = x0 + 3, x1 - 3 do
    local q = hs(x, y0, seed + 9)
    if q > 0.8 then c:px(x, y0 - 1, GRS[2 + floor(q * 10) % 2]) if q > 0.92 then c:px(x, y0 - 2, GRS[3]) end end
  end
end
local function ball(cx, cy, r, ramp)
  for y = floor(cy - r) - 1, floor(cy + r) + 1 do for x = floor(cx - r) - 1, floor(cx + r) + 1 do
    local dx, dy = x - cx, y - cy
    if dx * dx + dy * dy <= r * r then
      local d = sqrt((x - (cx - r * 0.4)) ^ 2 + (y - (cy - r * 0.4)) ^ 2)
      c:px(x, y, ramp[cl(floor(6.2 - d / (r * 1.6) * 4.4))])
    end
  end end
end
local function band(x0, y0, x1, y1, horiz, kind, xskip)
  local w = (horiz and (y1 - y0) or (x1 - x0)) + 1
  for y = y0, y1 do for x = x0, x1 do
    if not (xskip and xskip(x, y)) then
      local v = horiz and (y - y0) or (x - x0)
      local u = horiz and (x - x0) or (y - y0)
      local idx
      if kind == "chev" then
        local ph = (u + floor(abs(v - (w - 1) / 2) + 0.5)) % 8
        idx = ph < 5 and (ph == 1 and 5 or 4) or 2
      else
        local cell = floor(u / 6)
        idx = ((floor(v / 3) + cell) % 2 == 0) and 4 or 3
        if v % 3 == 2 then idx = idx - 2 end
        if u % 6 == 0 then idx = 2 end
      end
      if v < 2 then idx = idx + 1 elseif v >= w - 3 then idx = idx - 1 end
      if v == 0 then idx = 5 elseif v == w - 1 then idx = 1 end
      if hs(x, y, 8) > 0.93 then idx = idx - 1 end
      c:px(x, y, R[cl(idx)])
    end
  end end
end
local NAME = "wattle-fence-gate"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 55, 22, 3)
local sx = {}
for i = 0, 5 do sx[#sx + 1] = 18 + 5 * i end
local rows = { 31, 37 }
weaveBack(rows, 3, 17, 46, R, 11)
for i, x in ipairs(sx) do stakeV(x, 19, 52, 3, W, "point", 40 + i) end
weaveFront(sx, 3, rows, 3, R, 22)
rodH(16, 47, 24, 4, W, 61) rodH(16, 47, 44, 4, W, 62)
-- diagonal brace
local br = c:line({ {19, 42}, {44, 27} }, 3)
br:each(function(x, y)
  local i = 3
  if not br:has(x, y - 1) then i = 5 elseif not br:has(x, y + 1) then i = 2 end
  c:px(x, y, W[i])
end)
-- posts with ball finials
stakeV(8, 13, 54, 8, W, "flat", 71) stakeV(48, 13, 54, 8, W, "flat", 72)
ball(11.5, 10, 3.5, W) ball(51.5, 10, 3.5, W)
lash(8, 15, 18, 3) lash(48, 55, 18, 3)
-- iron hinge straps (left) and hasp + brass bell (right)
for _, y0 in ipairs{ 25, 45 } do
  for x = 13, 25 do c:px(x, y0, IRON[4 - (x % 5 == 0 and 1 or 0)]) c:px(x, y0 + 1, IRON[3]) c:px(x, y0 + 2, IRON[1]) end
  c:px(15, y0 + 1, IRON[4]) c:px(22, y0 + 1, IRON[4]) c:px(13, y0, IRON[2])
end
for x = 44, 51 do c:px(x, 33, IRON[4]) c:px(x, 34, IRON[3]) c:px(x, 35, IRON[1]) end
c:px(46, 34, IRON[4]) c:px(49, 34, IRON[4])
c:px(45, 36, IRON[3]) c:px(46, 36, IRON[4]) c:px(47, 36, IRON[3]) c:px(44, 37, IRON[3]) c:px(48, 37, IRON[2]) c:px(45, 38, IRON[2]) c:px(47, 38, IRON[2])
c:px(46, 39, "#fde08a") c:px(45, 40, "#e9ad2b") c:px(46, 40, "#fde08a") c:px(47, 40, "#b8741f") c:px(44, 41, "#b8741f") c:px(45, 41, "#e9ad2b") c:px(46, 41, "#e9ad2b") c:px(47, 41, "#b8741f") c:px(48, 41, "#7a4a1e") c:px(46, 42, "#7a4a1e")
soil(7, 57, 51, 4, 13)
G.fin(c, NAME)

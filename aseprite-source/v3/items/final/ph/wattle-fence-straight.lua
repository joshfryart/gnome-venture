-- wattle-fence-straight (lean D3o_10)
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
local NAME = "wattle-fence-straight"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 53, 24, 3)
local sx, rows = {}, { 30, 40 }
for i = 0, 6 do sx[#sx + 1] = 8 + floor(7.5 * i) end
weaveBack(rows, 4, 7, 56, R, 40)
for i, x in ipairs(sx) do stakeV(x, (i % 2 == 0) and 22 or 24, 52, 4, W, "round", 20 + i) end
weaveFront(sx, 4, rows, 4, R, 50)
-- top rail laid across the stake tops, lashed at each stake
rodH(6, 57, 21, 4, W, 60)
for _, x in ipairs(sx) do lash(x, x + 3, 20, 6) end
soil(6, 57, 50, 4, 7)
-- quirk: little red toadstool between the stakes
c:px(28, 49, "#e9dcc0") c:px(29, 49, "#cdbf9e") c:px(28, 48, "#e9dcc0") c:px(29, 48, "#cdbf9e") c:px(28, 47, "#e9dcc0") c:px(29, 47, "#cdbf9e")
c:px(28, 45, "#e0605a") c:px(29, 45, "#b13a46") c:px(27, 46, "#b13a46") c:px(28, 46, "#e0605a") c:px(29, 46, "#b13a46") c:px(30, 46, "#7a2332")
c:px(28, 45, "#f6a58e")
G.fin(c, NAME)

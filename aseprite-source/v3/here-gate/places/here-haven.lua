-- here-haven: Haven gate view, HERO SCALE redo (cosy roadside haven: hearth lodge + campfire, supply wagon, wild trail).
-- Hearth Pop v3, 480x270 native, golden-hour calm day, one-point perspective to ~(240,112).
-- Layout contract (here-haven.layout.json, unchanged): fire [6,60,176,242], shop [330,130,444,212], wild [360,66,466,128].
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-haven" }
local INK = "#2b1c26"
local floor_, sin, cos, abs, max, min = math.floor, math.sin, math.cos, math.abs, math.max, math.min
local VX, VY = 240, 112

-- ground tracking: any normal paint clears the "bare ground" flag
local gnd = {}
local cput = c.put
c.put = function(self, x, y, hex, o) gnd[y * W + x] = nil; return cput(self, x, y, hex, o) end
local function inb(x, y) return x >= 0 and y >= 0 and x < W and y < H end
local function put(x, y, col) if inb(x, y) then c:put(x, y, col) end end
local function gput(x, y, col) if inb(x, y) then cput(c, x, y, col); gnd[y * W + x] = true end end
local function h(x, y, s)
  local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return v - floor_(v)
end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function PL(p) return c:poly(p) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function bb(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y)
    if x < x0 then x0 = x end; if y < y0 then y0 = y end
    if x > x1 then x1 = x end; if y > y1 then y1 = y end
  end)
  return x0, y0, x1, y1
end
-- ramp = {deep, shade, base, hi, light}; light from upper-left
local function obj(m, ramp, tex, o)
  o = o or {}
  local x0, y0, x1, y1 = bb(m)
  local w, hh = max(1, x1 - x0), max(1, y1 - y0)
  local cut = o.cut or 0.74
  m:each(function(x, y)
    local t = (x - x0) / w * 0.6 + (y - y0) / hh * 0.4
    local i = o.base or 3
    if t > cut then i = i - 1 end
    if o.lit and t < 0.18 then i = i + 1 end
    if tex then i = i + (tex(x, y, x - x0, y - y0) or 0) end
    if i < 1 then i = 1 end
    if i > #ramp then i = #ramp end
    put(x, y, ramp[i])
  end)
  if o.rim then c:rim(m, o.rim) end
  if not o.noedge then c:edgeIn(m, ramp[1]) end
end
local function stoneTex(bw, bh, seed)
  return function(x, y, lx, ly)
    local row = floor_(ly / bh)
    local xx = lx + (row % 2) * floor_(bw / 2)
    if ly % bh == 0 or xx % bw == 0 then return -2 end
    local v = h(floor_(xx / bw), row, seed or 1)
    if (ly % bh == 1 or xx % bw == 1) and v > 0.3 then return 1 end
    if v > 0.75 then return 1 elseif v < 0.25 then return -1 end
    return 0
  end
end
local function plankV(pw, seed)
  return function(x, y, lx, ly)
    if lx % pw == 0 then return -2 end
    if lx % pw == 1 then return 1 end
    if h(lx, floor_(ly / 4), seed or 2) > 0.88 then return -1 end
    return 0
  end
end
local function plankH(ph, seed)
  return function(x, y, lx, ly)
    if ly % ph == 0 then return -2 end
    if ly % ph == 1 then return 1 end
    if h(floor_(lx / 5), ly, seed or 3) > 0.86 then return -1 end
    return 0
  end
end
local function toward(x, y, t) return floor_(x + (VX - x) * t + 0.5), floor_(y + (VY - y) * t + 0.5) end

-- palettes (warm light, cool violet shade)
local STONE = { "#4a3f52", "#6c5f70", "#8f8288", "#b3a49e", "#d6c6b4" }
local TIMB  = { "#3e2619", "#5f3a24", "#7e5232", "#a06d42", "#c99258" }
local LOG   = { "#4a2c22", "#6e4630", "#8e603e", "#b07e50", "#d0a068" }
local ROOF  = { "#4a2028", "#73312e", "#9a4a34", "#c06a42", "#de9258" }
local ROOFS = { "#3a1e2c", "#552838", "#6e3438", "#8a4640", "#a25a48" } -- side plane, in shade
local PLAST = { "#8a7468", "#b49c84", "#e0c89e", "#f0dcb2", "#fbecc8" }
local TEAL  = { "#1f3f4e", "#2c5c68", "#3f7f88", "#5ea3a6", "#86c4bf" }
local CANV  = { "#8a7a6e", "#b4a28a", "#dccaa6", "#efe0bc", "#fbf0d4" }
local IRON  = { "#2e2a36", "#4a4554", "#6a6474", "#908a98", "#c0bac4" }

------------------------------------------------------------------ SKY: golden hour, calm
c:stripes(0, 111, { "#8fb3cf", "#a3c0d0", "#b8cbcc", "#cfd2be", "#e3d6aa", "#efd198", "#f5c886", "#f6bb7a" },
  { 16, 15, 14, 13, 13, 12, 12, 17 })
-- dithered band seams
for y = 1, 110 do
  local a, b = c:get(0, y - 1), c:get(0, y)
  if a ~= b then for x = 0, W - 1 do if (x + y) % 2 == 0 then put(x, y, a) end end end
end
-- low sun, upper left of the scene (key light)
for y = 40, 84 do for x = 166, 214 do
  local d = ((x - 190) ^ 2 + (y - 62) ^ 2) ^ 0.5
  if d <= 9 then put(x, y, d < 6 and "#fff3cc" or "#fde6a8")
  elseif d <= 15 and (x + y) % 2 == 0 then put(x, y, "#f9dc9c")
  elseif d <= 22 and (x + y) % 4 == 0 then put(x, y, "#f6d496") end
end end
local function cloud(x, y, w, top, mid, under)
  local m = c:cloud(x, y, w, top, under)
  m:each(function(px, py) if py > y - floor_(w * 0.12) and py < y and (px + py) % 2 == 0 then put(px, py, mid) end end)
end
cloud(104, 46, 54, "#fbe8c8", "#eccab4", "#c8a2b4")
cloud(286, 34, 70, "#fbe4c2", "#eec6ae", "#c49cb2")
cloud(250, 64, 34, "#f8dcb8", "#e8c0a8", "#bc98ae")
cloud(384, 52, 46, "#fbe2be", "#ecc4aa", "#c49cb0")
-- a far flight line? no animals. thin high streaks instead
for x = 220, 270 do if h(x, 1, 3) > 0.3 then put(x, 22 + floor_((x - 220) / 18), "#c6d4d8") end end
for x = 330, 370 do if h(x, 2, 3) > 0.35 then put(x, 74, "#f9dcb0") end end

------------------------------------------------------------------ far mountains, hills, distant trees (cool, light)
local function mY(x) return 78 + 9 * sin(x / 37) + 6 * sin(x / 13 + 1) - 10 * math.exp(-((x - 330) / 40) ^ 2) end
c:terrain(mY, "#9e94b8", 111)
for x = 1, W - 1 do
  local y, yp = floor_(mY(x) + 0.5), floor_(mY(x - 1) + 0.5)
  if yp >= y then put(x, y, "#d8c8d4"); put(x, y + 1, "#c4b4cc"); if h(x, 3, 4) > 0.5 then put(x, y + 2, "#c4b4cc") end
  else put(x, y, "#b4aac8") end
end
for y = 70, 111 do for x = 0, W - 1 do if c:get(x, y) == "#9e94b8" and (x + y) % 2 == 0 and h(x, y, 5) > 0.8 then put(x, y, "#8e84aa") end end end
local function hY(x) return 96 + 4 * sin(x / 26 + 2) + 3 * sin(x / 9) end
c:terrain(hY, "#8ea08e", 111)
for x = 0, W - 1 do put(x, floor_(hY(x) + 0.5), "#b0bc9a") end
-- distant tree line (blue-green silhouettes, varied crowns)
for i = 0, 70 do
  local tx = i * 7 + floor_(h(i, 1, 6) * 5)
  local ty = floor_(hY(tx) + 0.5)
  if h(i, 2, 6) > 0.45 then
    local th = 6 + floor_(h(i, 3, 6) * 8)
    for k = 0, th do
      local hw = floor_(k * 0.35)
      for xx = -hw, hw do put(tx + xx, ty - th + k, xx < 0 and "#748c7c" or "#647a70") end
    end
  else
    local r = 3 + floor_(h(i, 4, 6) * 3)
    E(tx, ty - r, r + 1, r):each(function(x, y) put(x, y, (x - tx) + (y - ty + r) < 0 and "#7c947a" or "#687e6e") end)
  end
end
-- far windmill near the vanishing point (focal, small)
do
  local tw = PL{ { 206, 110 }, { 209, 86 }, { 215, 86 }, { 218, 110 } }
  c:rim(tw, "#6a6078"); tw:each(function(x, y) put(x, y, x < 212 and "#d8c8bc" or "#b0a4a8") end)
  c:fillMask(PL{ { 205, 87 }, { 212, 80 }, { 219, 87 } }, "#9a5a4a"); put(211, 81, "#c07a5a")
  c:fillMask(R(211, 102, 213, 110), "#7a5a5a"); put(210, 92, "#8a7a88")
  local hub = { 212, 88 }
  for _, a in ipairs({ 0.4, 0.4 + 1.5708, 0.4 + 3.1416, 0.4 + 4.712 }) do
    for t = 2, 14 do
      local x, y = floor_(hub[1] + cos(a) * t + 0.5), floor_(hub[2] + sin(a) * t + 0.5)
      put(x, y, "#7a6a70")
      if t > 4 then local px, py = floor_(x - sin(a) * 2 + 0.5), floor_(y + cos(a) * 2 + 0.5); put(px, py, "#e8dccc") end
    end
  end
  put(212, 88, "#4a3a44")
end

------------------------------------------------------------------ ground
local GR = { { 112, "#8a9f6a" }, { 117, "#86a056" }, { 130, "#82a04a" }, { 160, "#7b9843" }, { 200, "#74903e" }, { 240, "#6c873a" } }
for y = 112, H - 1 do
  local col = GR[1][2]
  for _, g in ipairs(GR) do if y >= g[1] then col = g[2] end end
  for x = 0, W - 1 do
    local cc = col
    local r = h(x, y, 11)
    if r > 0.95 and y > 118 then cc = "#9eb45a" elseif r < 0.04 and y > 118 then cc = "#5f7a36" end
    gput(x, y, cc)
  end
end
-- grass tufts
for i = 1, 170 do
  local tx, ty = floor_(h(i, 3, 12) * 470) + 5, floor_(h(i, 4, 12) * 150) + 118
  local s = ty > 200 and 3 or 2
  gput(tx, ty, "#566e32"); gput(tx - 1, ty - s + 1, "#a6bc5e"); gput(tx + 1, ty - s, "#a6bc5e"); gput(tx, ty - 1, "#86a04a")
end

------------------------------------------------------------------ side trail to the wild (behind main path)
do
  local trail = PL{ { 250, 114 }, { 330, 114 }, { 406, 118 }, { 420, 122 }, { 410, 127 }, { 330, 124 }, { 258, 126 } }
  trail:each(function(x, y) local v = h(x, y, 13); gput(x, y, v > 0.86 and "#c8a272" or (v < 0.14 and "#8e6c4c" or "#b08a60")) end)
  for x = 254, 418 do if h(x, 1, 14) > 0.6 then gput(x, 114 + floor_((x - 250) / 40), "#9a7a56") end end
end

------------------------------------------------------------------ main flagstone path (one-point perspective)
local function xl(y) return 150 + 78 * (269 - y) / 157 end
local function xr(y) return 360 - 108 * (269 - y) / 157 end
do
  local K = 1785
  local SC = { "#c4a682", "#ceb08a", "#b89a78", "#d8bc94", "#c2a888" }
  for y = 112, H - 1 do
    local a, b = xl(y), xr(y)
    local z, z2 = K / (y - 100), K / (y + 1 - 100)
    local row = floor_(z)
    local rowH = (y - 100) ^ 2 / K
    for x = floor_(a), floor_(b) do
      local cols = 6
      local cu = (x - a) / (b - a) * cols + (row % 2) * 0.5
      local col = floor_(cu)
      local cu2 = (x + 1 - a) / (b - a) * cols + (row % 2) * 0.5
      local cc = SC[1 + floor_(h(col, row, 14) * 5)]
      local jointH = rowH >= 3 and floor_(z2) ~= row
      local jointV = rowH >= 3 and floor_(cu2) ~= col
      if x == floor_(a) or x == floor_(b) then cc = "#6e5446"
      elseif jointH or jointV then cc = "#86685a"
      elseif rowH < 3 then
        local v = h(x, y, 15); cc = v > 0.8 and "#dcc29c" or (v < 0.2 and "#a8886e" or "#c4a682")
      else
        local zt = K / (y - 1 - 100)
        local leftJ = floor_((x - 1 - a) / (b - a) * cols + (row % 2) * 0.5) ~= col
        if floor_(zt) ~= row or leftJ then cc = "#ead2aa" end
        if h(x, y, 16) > 0.94 then cc = "#a4866c" end
      end
      put(x, y, cc)
    end
  end
  for y = 116, H - 1, 3 do
    for _, ex in ipairs({ floor_(xl(y)), floor_(xr(y)) }) do
      if h(ex, y, 17) > 0.45 then put(ex, y, "#86a04a"); put(ex, y - 1, "#a6bc5e") end
    end
  end
end

------------------------------------------------------------------ mid ground: woodshed with stacked logs (between road and trail)
do
  c:fillMask(R(276, 121, 326, 123), "#5f7a3a")
  local back = R(280, 102, 322, 121)
  c:rim(back, INK); obj(back, { "#3a2620", "#4e3428", "#64443a", "#7a5644", "#8e6a50" }, plankV(7, 18))
  for r = 0, 2 do
    for k = 0, 7 do
      local lx, ly = 283 + k * 5 + (r % 2) * 2, 106 + r * 5
      if lx + 3 <= 319 then
        R(lx, ly, lx + 3, ly + 3):each(function(x, y)
          local col = (x == lx or y == ly + 3) and "#8a6040" or "#e0b880"
          if x == lx + 1 and y == ly + 1 then col = "#b88a5a" end
          put(x, y, col)
        end)
      end
    end
  end
  local roof = PL{ { 276, 102 }, { 284, 96 }, { 320, 96 }, { 327, 102 } }
  c:rim(roof, INK); obj(roof, ROOF, function(x, y, lx) return lx % 4 == 0 and -1 or 0 end, { lit = true })
  -- chopping block + axe
  local blk = R(330, 114, 338, 122); c:rim(blk, INK); obj(blk, LOG, plankV(3, 20)); c:fillMask(R(330, 114, 338, 115), "#e0b880")
  c:fillMask(c:line({ { 333, 113 }, { 336, 105 } }, 1), "#8e603e")
  c:fillMask(PL{ { 335, 104 }, { 340, 103 }, { 340, 107 }, { 336, 107 } }, "#8a8f9a"); put(339, 104, "#c9ccd4")
end

------------------------------------------------------------------ WILD: forest edge with a trail opening (right, mid)
do
  -- dark wood mass
  local wood = HP.mask()
  for x = 344, 467 do
    local top = floor_(84 + 6 * sin(x / 7) + 4 * sin(x / 3.3 + 1) - 10 * math.exp(-((x - 420) / 22) ^ 2))
    for y = top, 124 do wood:set(x, y) end
  end
  wood:each(function(x, y)
    local v = h(floor_(x / 3), floor_(y / 3), 21)
    local col = "#36583e"
    if v > 0.62 then col = "#466c46" elseif v < 0.2 then col = "#2a4634" end
    if y > 112 then col = (x + y) % 2 == 0 and "#2a4634" or "#36583e" end
    put(x, y, col)
  end)
  -- canopy top light (warm rim)
  for x = 344, 467 do
    for y = 60, 124 do if wood:has(x, y) then put(x, y, "#8aa65a"); if h(x, 2, 22) > 0.4 then put(x, y + 1, "#6e9050") end; break end end
  end
  -- the trail opening: a dark green tunnel with sun dapples, trail running in
  local hole = E(414, 104, 14, 16):clip(R(380, 80, 450, 124)):add(R(399, 104, 429, 124))
  c:rim(hole, "#24382c")
  hole:each(function(x, y)
    local col = y < 98 and "#14241c" or "#1a2e24"
    if h(floor_(x / 4), floor_(y / 3), 23) > 0.75 then col = "#24382c" end
    put(x, y, col)
  end)
  hole:grow(2):cut(hole):each(function(x, y) if y < 120 and wood:has(x, y) and (x + y) % 2 == 0 then put(x, y, x < 414 and "#a6c060" or "#6e9050") end end)
  local tr = PL{ { 412, 104 }, { 416, 104 }, { 424, 124 }, { 404, 124 } }
  tr:each(function(x, y) put(x, y, y < 108 and "#7a5c40" or (h(x, y, 24) > 0.8 and "#c8a272" or "#9a7650")) end)
  for i = 1, 10 do local dx, dy = 400 + floor_(h(i, 5, 25) * 28), 92 + floor_(h(i, 6, 25) * 30); if hole:has(dx, dy) then put(dx, dy, "#e8d488"); put(dx + 1, dy, "#c8c070") end end
  -- hero pine (left of opening)
  local function pine(px, by, ht, wd, seed)
    local m = HP.mask()
    for tier = 0, 3 do
      local ty = by - ht + floor_(tier * ht / 4.4)
      local hw = floor_(wd * (0.4 + tier * 0.22))
      m:add(PL{ { px, ty }, { px + hw, ty + floor_(ht * 0.34) }, { px - hw, ty + floor_(ht * 0.34) } })
    end
    c:rim(m, INK)
    local x0, y0, x1, y1 = bb(m)
    m:each(function(x, y)
      local col = "#2f5a44"
      if x < px - 1 then col = "#4a7a52" end
      if x < px - 3 and (x + y) % 2 == 0 then col = "#6e9a5a" end
      if x > px + 2 then col = "#244a3c" end
      if h(x, y, seed) > 0.9 then col = "#1e3c34" end
      put(x, y, col)
    end)
    local tk = R(px - 1, y1 + 1, px + 1, by + 6); c:rim(tk, INK); obj(tk, TIMB, nil, { noedge = true })
  end
  pine(384, 108, 54, 15, 26)
  pine(462, 108, 46, 11, 27)
  -- broadleaf oak (right of opening), different crown
  local trunk = PL{ { 440, 124 }, { 442, 98 }, { 446, 98 }, { 449, 124 } }
  c:rim(trunk, INK); obj(trunk, TIMB, function(x, y, lx, ly) return (ly % 6 == 0 and lx == 2) and -2 or 0 end, { lit = true })
  local crown = E(446, 84, 16, 13):add(E(434, 90, 9, 7)):add(E(457, 90, 8, 7))
  c:rim(crown, INK)
  crown:each(function(x, y)
    local l = (x - 446) / 16 + (y - 84) / 13
    local col = l < -0.55 and "#a6c060" or (l < 0.1 and "#74a04e" or "#4e7a40")
    if h(floor_(x / 2), floor_(y / 2), 28) > 0.8 then col = "#3a6236" end
    if l < -0.4 and h(x, y, 29) > 0.85 then col = "#d0d878" end
    put(x, y, col)
  end)
  -- signpost: arrow pointing into the trail with a pine icon
  local post = R(364, 94, 367, 127); c:rim(post, INK); obj(post, TIMB, nil, { lit = true })
  local arrow = PL{ { 354, 92 }, { 386, 92 }, { 394, 99 }, { 386, 106 }, { 354, 106 } }
  c:rim(arrow, INK); obj(arrow, { "#5f3a1c", "#8a5428", "#b07a46", "#d6a464", "#ecc488" }, plankH(7, 25), { lit = true })
  c:fillMask(PL{ { 372, 94 }, { 378, 104 }, { 366, 104 } }, "#3f6a44"); put(371, 97, "#6e9a5a"); put(372, 104, "#5f3a24")
  c:fillMask(PL{ { 383, 96 }, { 388, 99 }, { 383, 102 } }, "#5f3a1c")
  for x = 357, 362 do put(x, 99, "#5f3a1c") end
  -- ferns at the forest foot
  for _, fx in ipairs({ 352, 372, 396, 432, 456 }) do
    for k = -3, 3 do for t = 1, 5 - abs(k) do put(fx + k * floor_((t + 1) / 2), 126 - t, (t % 2 == 0) and "#86a85a" or "#4f7a44") end end
  end
end

------------------------------------------------------------------ SHOP: big supply wagon (right, near)
do
  -- ground shadow (falls lower right)
  for y = 206, 216 do for x = 334, 452 do
    local d = ((x - 396) / 58) ^ 2 + ((y - 210) / 6) ^ 2
    if d < 1 and ((x + y) % 2 == 0 or d < 0.6) then gput(x, y, "#4e6a30"); gnd[y * W + x] = nil end
  end end
  -- shafts resting on the ground (front, left)
  local shafts = c:line({ { 346, 184 }, { 330, 208 } }, 3):add(c:line({ { 354, 186 }, { 340, 210 } }, 3))
  c:rim(shafts, INK); obj(shafts, TIMB, nil, { noedge = true })
  -- canvas cover (hoops)
  local cover = E(388, 160, 46, 28):clip(R(340, 132, 436, 170)):add(R(342, 160, 434, 170))
  c:rim(cover, INK)
  obj(cover, CANV, function(x, y, lx, ly)
    local rib = (x - 344) % 15
    if rib == 0 then return -2 end
    if rib == 1 then return 1 end
    if rib == 13 and (x + y) % 2 == 0 then return -1 end
    return 0
  end, { lit = true, cut = 0.7 })
  -- rolled-up side flap: open window with shelves of goods
  local win = R(358, 157, 418, 170)
  c:rim(win, "#5a4a3e")
  c:fillMask(win, "#3a2a28")
  for y = 157, 170 do for x = 358, 418 do if (x + y) % 2 == 0 and y < 160 then put(x, y, "#2e2024") end end end
  c:fillMask(R(358, 164, 418, 164), "#a06d42"); c:fillMask(R(358, 165, 418, 165), "#5f3a24")
  -- top shelf: jars, bottles, rope coil
  for k = 0, 3 do
    local jx = 360 + k * 8
    local j = R(jx, 158, jx + 5, 163); c:rim(j, INK)
    obj(j, k % 2 == 0 and { "#2a5470", "#3f7aa0", "#6fa8c8", "#a8d4e4" } or { "#6a3a20", "#a05a2a", "#d08a40", "#f0b860" }, nil, { lit = true })
    put(jx + 1, 159, "#eaf4f4")
  end
  E(399, 160, 4, 3):each(function(x, y) put(x, y, (x + y) % 2 == 0 and "#d8c6a6" or "#a88f78") end); put(399, 160, "#5a4a3e")
  local lamp = R(408, 157, 413, 163); c:rim(lamp, INK); c:fillMask(lamp, "#f2c75c"); c:fillMask(R(409, 158, 410, 161), "#fff0a8")
  -- lower shelf: sacks, loaves, cheese wheel
  local sack = PL{ { 360, 170 }, { 359, 166 }, { 362, 164 }, { 366, 164 }, { 369, 166 }, { 368, 170 } }
  c:rim(sack, INK); obj(sack, { "#7a6248", "#a68a64", "#cdb38a", "#e6d4ae" }, nil, { lit = true })
  for k = 0, 2 do local l = E(377 + k * 7, 167, 3, 2); c:rim(l, INK); obj(l, { "#7a4a20", "#b8742e", "#dca050", "#f0c070" }, nil, { lit = true }) end
  local ch = E(404, 167, 6, 3); c:rim(ch, INK); obj(ch, { "#a07020", "#d0a030", "#f0cc50", "#fbe68a" }, nil, { lit = true }); put(406, 167, "#a07020")
  -- rolled canvas above the window with two ties
  local roll = R(356, 152, 420, 155); c:rim(roll, INK)
  roll:each(function(x, y) put(x, y, y == 152 and "#fbf0d4" or (y == 155 and "#a8967e" or ((x % 6 == 0) and "#c8b694" or "#e6d6b2"))) end)
  for _, tx in ipairs({ 366, 410 }) do c:fillMask(R(tx, 151, tx + 1, 157), "#c0473f"); put(tx, 158, "#8a3a30") end
  -- striped valance (shop read)
  local val = R(348, 143, 428, 147)
  c:rim(val, INK)
  val:each(function(x, y) local s = floor_((x - 348) / 8) % 2; put(x, y, s == 0 and (y == 143 and "#e8704e" or "#c8442e") or (y == 143 and "#fff4dc" or "#f0e0c0")) end)
  for x = 348, 428 do
    local t = (x - 348) % 8; local d = t < 4 and t or 7 - t; d = floor_(d / 2)
    local s = floor_((x - 348) / 8) % 2
    for k = 1, d do put(x, 147 + k, s == 0 and "#a8382a" or "#d8c6a6") end
    put(x, 148 + d, INK)
  end
  -- wagon body (teal planks), trim
  local body = R(338, 170, 438, 196)
  c:rim(body, INK); obj(body, TEAL, plankH(6, 27), { lit = true })
  c:fillMask(R(338, 170, 438, 172), "#a06d42"); c:fillMask(R(338, 170, 438, 170), "#d6a464"); c:fillMask(R(338, 173, 438, 173), "#5f3a24")
  for _, px in ipairs({ 338, 388, 436 }) do obj(R(px, 174, px + 2, 196), TIMB, nil, { lit = true, noedge = true }) end
  -- painted flowers on the side (quirk)
  for _, f in ipairs({ { 346, 186 }, { 430, 184 } }) do
    put(f[1], f[2], "#f4d24a"); put(f[1] - 1, f[2], "#e86a8a"); put(f[1] + 1, f[2], "#e86a8a"); put(f[1], f[2] - 1, "#e86a8a"); put(f[1], f[2] + 1, "#e86a8a")
    put(f[1] + 2, f[2] + 2, "#5e8f56"); put(f[1] - 2, f[2] + 2, "#5e8f56")
  end
  -- shop sign board on the body: pack icon on cream
  local sb = R(366, 175, 384, 193); c:rim(sb, INK); obj(sb, { "#a68a64", "#d8c6a6", "#efe0c0", "#fff4dc" }, nil, { lit = true })
  c:paint({
    "...oooo...",
    "..o....o..",
    ".oooooooo.",
    "obbbbbbbbo",
    "obyybbbbbo",
    "obbbbbbbbo",
    "obggggggbo",
    "obgbbbbgbo",
    "obggggggbo",
    "obbbbbbbbo",
    ".oooooooo.",
  }, 370, 178, { o = "#4a2c1e", b = "#b06a3a", y = "#e8b860", g = "#7a4426" })
  -- coin sign on right panel
  local coin = E(412, 184, 7, 7); c:rim(coin, INK); obj(coin, { "#8a5a10", "#c08a20", "#e8b830", "#f8dc70", "#fff0b0" }, nil, { lit = true })
  c:fillMask(R(411, 180, 412, 188), "#9a6a14"); put(410, 181, "#9a6a14"); put(413, 187, "#9a6a14")
  -- big spoked wheels
  local function wheel(cx, cy, r)
    local rim_ = E(cx, cy, r, r):cut(E(cx, cy, r - 3, r - 3))
    c:rim(rim_, INK)
    rim_:each(function(x, y)
      local l = (x - cx) + (y - cy)
      local col = l < -r * 0.5 and "#b07e50" or (l > r * 0.5 and "#5f3a24" or "#8e603e")
      if (x - cx) ^ 2 + (y - cy) ^ 2 >= (r - 0.6) ^ 2 then col = l < 0 and "#908a98" or "#4a4554" end
      put(x, y, col)
    end)
    for k = 0, 7 do
      local a = k * 0.7854 + 0.2
      for t = 3, r - 3 do put(floor_(cx + cos(a) * t + 0.5), floor_(cy + sin(a) * t + 0.5), k < 4 and "#a06d42" or "#7e5232") end
    end
    local hub = E(cx, cy, 3, 3); c:rim(hub, INK); obj(hub, IRON, nil, { lit = true })
  end
  wheel(356, 199, 13)
  wheel(420, 199, 13)
  -- hanging lantern on a hook at the front hoop
  c:fillMask(R(341, 150, 341, 156), "#3a2a22")
  local hl = R(338, 157, 344, 165); c:rim(hl, INK); c:fillMask(hl, "#f2c75c"); c:fillMask(R(339, 158, 340, 162), "#fff0a8"); c:fillMask(R(338, 156, 344, 156), "#4a3a3a")
  -- pots and a pan dangling from the valance
  for _, p in ipairs({}) do
    c:fillMask(R(p[1], p[2], p[1], p[2] + 3), "#3a2a22")
    local pot = E(p[1], p[2] + 6, p[3], 3); c:rim(pot, INK); obj(pot, IRON, nil, { lit = true })
  end
  -- side goods: barrel, crate stack, sacks (beside, outside the cart)
  local br = R(446, 190, 462, 211); c:rim(br, INK)
  obj(br, LOG, plankV(4, 71), { lit = true })
  for _, yy in ipairs({ 194, 206 }) do c:fillMask(R(446, yy, 462, yy), "#6a6474") end
  c:fillMask(R(447, 190, 461, 191), "#d0a068")
  local cr = R(444, 176, 460, 189); c:rim(cr, INK)
  obj(cr, { "#5f3a1c", "#8a5428", "#b5824a", "#d4a46a", "#ecc488" }, function(x, y, lx, ly) if lx == 8 or ly == 6 then return -1 end return 0 end, { lit = true })
  c:fillMask(R(447, 172, 455, 175), "#d9482b"); put(448, 172, "#f08a6a"); put(452, 171, "#5e8f56") -- apples on top
end

------------------------------------------------------------------ FIRE: hearth lodge (left, hero) + big campfire
-- lodge cast shadow on ground (lower right)
for y = 178, 212 do
  local x0 = 162 + floor_((y - 178) * 0.1)
  local x1 = 162 + floor_((212 - y) * 0.55) + 8
  for x = x0, x1 do if (x + y) % 2 == 0 and gnd[y * W + x] then gput(x, y, "#5a7434") end end
end
local SIDE = { "#2e2030", "#3e2a34", "#503638", "#62443e", "#745444" }
do
  -- side wall receding toward VP (in shade)
  local sw = PL{ { 132, 116 }, { 163, 116 }, { 163, 180 }, { 132, 206 } }
  c:rim(sw, INK)
  sw:each(function(x, y)
    local t = (x - 132) / 31
    local top = 116 + 0 * t
    local slot = floor_((y - 116 - (y - 116) * t * 0.0) / 7)
    local yy = y - floor_((x - 132) * (26 / 31) * ((y - 116) / 90))
    local col = (yy % 7 == 0) and SIDE[1] or ((yy % 7 == 1) and SIDE[4] or SIDE[3])
    if h(x, floor_(yy / 7), 30) > 0.9 then col = SIDE[2] end
    put(x, y, col)
  end)
  -- side window with warm glow
  local sw2 = PL{ { 142, 140 }, { 154, 138 }, { 154, 156 }, { 142, 160 } }
  c:rim(sw2, INK); c:fillMask(sw2, "#e8a048")
  for y = 140, 158 do put(148, y, "#5f3a24") end
  for x = 142, 154 do put(x, 149 - floor_((x - 142) / 6), "#5f3a24") end
  put(144, 143, "#ffe08a"); put(145, 143, "#ffe08a"); put(144, 144, "#ffe08a")
  -- side plinth
  local sp = PL{ { 132, 202 }, { 163, 176 }, { 163, 182 }, { 133, 210 } }
  c:rim(sp, INK); obj(sp, { "#3a3044", "#4a3f52", "#5c5064", "#6c5f70" }, function(x, y) return h(floor_(x / 5), floor_(y / 3), 31) > 0.6 and -1 or 0 end)
  -- side roof plane (in shade), receding
  local sr = PL{ { 75, 52 }, { 122, 68 }, { 176, 121 }, { 150, 126 } }
  c:rim(sr, INK)
  sr:each(function(x, y)
    -- shingle rows run parallel to the eave
    local d = (y - 52) - (x - 75) * 0.32
    local row = floor_(d / 5)
    local col = ROOFS[3]
    if floor_(d) % 5 == 0 then col = ROOFS[1] elseif floor_(d) % 5 == 1 then col = ROOFS[4] end
    if (x + row * 3) % 8 == 0 then col = ROOFS[2] end
    if h(x, row, 32) > 0.93 then col = "#4e6a44" end
    put(x, y, col)
  end)
  -- warm rim along the ridge
  for t = 0, 47 do local x, y = 75 + t, 52 + floor_(t * 16 / 47); put(x, y, "#c06a42") end
end
do
  -- front gable wall: lower log storey + half-timbered plaster gable
  local lower = R(18, 150, 132, 206)
  obj(lower, LOG, function(x, y, lx, ly)
    if ly % 7 == 0 then return -2 end
    if ly % 7 == 1 then return 1 end
    if ly % 7 == 6 then return -1 end
    if h(floor_(lx / 6), floor_(ly / 7), 33) > 0.9 and lx % 6 == 2 then return -1 end
    return 0
  end, { lit = true, noedge = true })
  -- log ends sticking out at the corners
  for y = 150, 204, 7 do
    for _, ex in ipairs({ 14, 129 }) do
      local le = E(ex + 3, y + 3, 3, 3); c:rim(le, INK); le:each(function(x, yy) put(x, yy, ((x - ex - 3) ^ 2 + (yy - y - 3) ^ 2 <= 1) and "#b07e50" or "#e0b880") end)
    end
  end
  local gable = PL{ { 18, 124 }, { 75, 68 }, { 132, 124 } }:add(R(18, 124, 132, 149))
  obj(gable, PLAST, function(x, y, lx, ly) local v = h(floor_(x / 3), floor_(y / 2), 34); return v > 0.88 and -1 or (v < 0.06 and 1 or 0) end, { lit = true, noedge = true, cut = 0.8 })
  -- timber frame on the gable
  local beams = R(18, 145, 132, 149)
  for _, sx in ipairs({ 40, 72, 106 }) do beams:add(R(sx, max(124, floor_(124 - (sx < 75 and (sx - 18) or (132 - sx - 4)) + 0)), sx + 3, 145)) end
  beams = R(18, 145, 132, 149):add(R(72, 76, 77, 145)):add(R(40, 102, 43, 145)):add(R(107, 102, 110, 145))
  beams:add(c:line({ { 43, 144 }, { 66, 124 } }, 3)):add(c:line({ { 107, 144 }, { 84, 124 } }, 3))
  beams:add(R(24, 124, 126, 126))
  obj(beams, TIMB, plankV(5, 35), { lit = true, noedge = true })
  -- round loft window with a warm glow and a bunk ladder silhouette
  local rw = E(75, 108, 11, 11)
  local rwi = E(75, 108, 8, 8)
  c:rim(rw, INK); obj(rw, TIMB, nil, { lit = true })
  rwi:each(function(x, y) put(x, y, y < 104 and "#f8d27a" or "#e8a048") end)
  for y = 100, 116 do put(75, y, "#5f3a24") end
  for x = 67, 83 do put(x, 108, "#5f3a24") end
  put(70, 103, "#fff0b8"); put(71, 103, "#fff0b8"); put(70, 104, "#fff0b8")
  -- moon & flame sign hanging under the gable (Hearth & Bunks)
  c:fillMask(R(62, 127, 62, 131), "#3a2a22"); c:fillMask(R(88, 127, 88, 131), "#3a2a22")
  local sg = R(56, 132, 94, 146); c:rim(sg, INK); obj(sg, { "#1e2850", "#283466", "#34427c", "#46589a" }, nil, { lit = true })
  c:paint({
    "..yyy.......f..",
    ".yy........fof.",
    "yy........foof.",
    "yy........foyf.",
    "yy.........ff..",
    ".yy.....bbbbbbb",
    "..yyy...b.....b",
  }, 62, 135, { y = "#f4d24a", f = "#d9482b", o = "#f08a2c", b = "#e0c89e" })
  put(76, 136, "#fbe9c6"); put(80, 139, "#d9c3d8")
  -- door: arched, open, warm interior with a bunk and quilt
  local door = R(62, 170, 88, 204):add(E(75, 170, 13, 10):clip(R(62, 158, 88, 170)))
  local frame = door:grow(2)
  c:rim(frame, INK); obj(frame, TIMB, nil, { lit = true })
  door:each(function(x, y)
    local col = "#c87838"
    if y < 176 then col = "#e8a048" end
    if y < 166 then col = "#f4c060" end
    if x > 82 then col = "#a85a30" end
    put(x, y, col)
  end)
  -- bunk inside the door
  c:fillMask(R(64, 180, 86, 183), "#7e5232"); c:fillMask(R(64, 192, 86, 195), "#7e5232")
  c:fillMask(R(64, 176, 86, 179), "#c0473f"); for x = 64, 86, 4 do c:fillMask(R(x, 176, x + 1, 177), "#e0b04a") end
  c:fillMask(R(64, 188, 86, 191), "#3f8f8a"); for x = 66, 86, 4 do c:fillMask(R(x, 188, x + 1, 189), "#e6d3a8") end
  c:fillMask(R(65, 174, 70, 176), "#f4e6c8"); c:fillMask(R(65, 186, 70, 188), "#f4e6c8")
  c:fillMask(R(84, 172, 85, 204), "#5f3a24")
  c:fillMask(R(62, 200, 88, 204), "#8e5030")
  -- windows with shutters and window boxes, bunks inside
  local function window(x0, q1, q2)
    local w = R(x0, 160, x0 + 24, 184)
    c:rim(w:grow(1), INK); c:fillMask(w:grow(1):cut(w), "#7e5232")
    w:each(function(x, y) put(x, y, y < 168 and "#f0b858" or "#d88a40") end)
    -- quilt + pillow on a bunk inside
    c:fillMask(R(x0, 174, x0 + 24, 180), q1); for x = x0, x0 + 24, 6 do c:fillMask(R(x, 174, x + 2, 176), q2) end
    c:fillMask(R(x0 + 2, 171, x0 + 8, 173), "#f4e6c8"); c:fillMask(R(x0, 181, x0 + 24, 184), "#7e5232")
    -- mullions
    for y = 160, 184 do put(x0 + 12, y, "#5f3a24") end
    for x = x0, x0 + 24 do put(x, 170, "#5f3a24") end
    put(x0 + 3, 162, "#fff0b8"); put(x0 + 4, 162, "#fff0b8"); put(x0 + 3, 163, "#fff0b8")
    -- shutters
    for _, sx in ipairs({ x0 - 9, x0 + 26 }) do
      local s = R(sx, 159, sx + 7, 185); c:rim(s, INK)
      obj(s, { "#24484a", "#2e6260", "#3e7e74", "#5e9e8a", "#86bca0" }, function(x, y, lx) return lx % 4 == 0 and -1 or 0 end, { lit = true })
      put(sx + 3, 166, "#2b1c26"); put(sx + 3, 178, "#2b1c26")
    end
    -- window box with flowers
    local bx = R(x0 - 2, 186, x0 + 26, 191); c:rim(bx, INK); obj(bx, TIMB, plankH(3, 36), { lit = true })
    for k = 0, 9 do
      local fx = x0 - 1 + k * 3
      put(fx, 185, "#4f7a44"); put(fx + 1, 184, "#6a9a52")
      put(fx, 183, k % 3 == 0 and "#f4d24a" or (k % 3 == 1 and "#e86a8a" or "#d9482b"))
    end
  end
  window(29, "#c0473f", "#e0b04a")
  window(97, "#3f8f8a", "#e6d3a8")
  -- front stone plinth / step
  local pl = R(12, 205, 134, 213); c:rim(pl, INK); obj(pl, STONE, stoneTex(11, 4, 37), { lit = true })
  local step = R(58, 202, 92, 206); c:rim(step, INK); obj(step, STONE, stoneTex(9, 5, 38), { lit = true })
  -- front roof (gable band, warm shingles)
  local outer = PL{ { 0, 130 }, { 75, 50 }, { 150, 130 } }
  local inner = PL{ { 14, 128 }, { 75, 64 }, { 136, 128 } }
  local roof = outer:copy():cut(inner)
  c:rim(roof, INK)
  roof:each(function(x, y)
    local left = x < 75
    -- shingle courses parallel to each slope
    local d = left and (y - 50 + (x - 75) * 1.07) or (y - 50 - (x - 75) * 1.07)
    local row = floor_(d / 5)
    local col = left and ROOF[3] or ROOF[2]
    if floor_(d) % 5 == 0 then col = ROOF[1]
    elseif floor_(d) % 5 == 1 then col = left and ROOF[5] or ROOF[3] end
    if (y + row * 3) % 7 == 0 and floor_(d) % 5 > 1 then col = left and ROOF[2] or ROOF[1] end
    if left and floor_(d) % 5 == 2 and h(x, row, 39) > 0.6 then col = ROOF[4] end
    put(x, y, col)
  end)
  -- ridge cap + bargeboard trim
  for t = 0, 75 do
    local y = 50 + floor_(t * 80 / 75)
    put(75 - t, y, "#e0a868"); put(75 + t, y, "#a25a48")
  end
  c:fillMask(R(73, 47, 77, 51), "#7e5232"); put(73, 47, "#c99258")
  -- moss tufts on the shingles (north/shade side) + a few on the left
  for i = 1, 26 do
    local x, y = 76 + floor_(h(i, 1, 40) * 70), 60 + floor_(h(i, 2, 40) * 66)
    if roof:has(x, y) and roof:has(x + 1, y) then put(x, y, "#5f7a48"); put(x + 1, y, "#7f9a58"); put(x, y + 1, "#4a6440") end
  end
  for i = 1, 8 do
    local x, y = 10 + floor_(h(i, 3, 40) * 60), 70 + floor_(h(i, 4, 40) * 56)
    if roof:has(x, y) then put(x, y, "#7f9a58"); put(x + 1, y, "#5f7a48") end
  end
  -- stone chimney on the left slope with calm smoke
  local ch = PL{ { 24, 62 }, { 40, 62 }, { 40, 92 }, { 24, 108 } }
  c:rim(ch, INK); obj(ch, STONE, stoneTex(6, 4, 41), { lit = true })
  local capm = R(22, 58, 42, 62); c:rim(capm, INK); obj(capm, STONE, nil, { lit = true, base = 4 })
  c:fillMask(R(26, 57, 38, 57), "#3a3044")
  for i, p in ipairs({ { 32, 50, 5, 4 }, { 28, 41, 6, 4 }, { 33, 31, 7, 5 }, { 27, 21, 6, 4 } }) do
    E(p[1], p[2], p[3], p[4]):each(function(x, y)
      local l = (x - p[1]) + (y - p[2])
      if h(x, y, 42 + i) > 0.12 * i then put(x, y, l < 0 and "#f4ece2" or "#d4c8d0") end
    end)
  end
  -- gnome-hat weathervane on the ridge (quirk)
  c:fillMask(R(75, 36, 75, 47), "#4a3a3a")
  local hat = PL{ { 70, 44 }, { 75, 30 }, { 81, 44 } }
  c:rim(hat, INK); obj(hat, { "#6a1e22", "#9a2c2c", "#c0473f", "#e0705a" }, nil, { lit = true })
  c:fillMask(R(69, 44, 82, 45), "#8a5a34")
  -- warm rim on the left logs and lit corner
  for y = 150, 204 do if (y % 7) ~= 0 then put(18, y, "#d0a068") end end
end

-- props in front of the lodge: log bench with blankets, boots, bedroll, bucket, woodpile
local function gshadow(x0, x1, y) for x = x0, x1 do if gnd[y * W + x] then gput(x, y, "#526c30") end; if x % 2 == 0 and gnd[(y + 1) * W + x] then gput(x, y + 1, "#5f7a36") end end end
do
  -- woodpile against the side wall
  gshadow(134, 168, 206)
  for r = 0, 3 do
    for k = 0, 4 - floor_(r / 2) do
      local lx, ly = 136 + k * 6 + (r % 2) * 3, 199 - r * 6 - floor_(k * 0.8)
      local le = E(lx + 2, ly + 2, 3, 3)
      c:rim(le, INK)
      le:each(function(x, y) local d = (x - lx - 2) ^ 2 + (y - ly - 2) ^ 2; put(x, y, d <= 1 and "#b07e50" or (d <= 4 and "#e0b880" or "#c89a64")) end)
    end
  end
  -- log bench with folded blankets and a mug (left)
  gshadow(20, 74, 236)
  local bench = R(20, 224, 72, 233); c:rim(bench, INK)
  obj(bench, LOG, function(x, y, lx, ly) if ly == 2 and h(lx, 1, 43) > 0.6 then return -1 end return 0 end, { lit = true })
  c:fillMask(R(20, 224, 72, 225), "#d0a068")
  local le = E(72, 228, 3, 5); c:rim(le, INK); le:each(function(x, y) put(x, y, ((x - 72) ^ 2 + (y - 228) ^ 2 <= 2) and "#b07e50" or "#e0b880") end)
  for _, b in ipairs({ { 26, 219, 42, 223, "#c0473f", "#8a3a30" }, { 27, 215, 41, 219, "#3f8f8a", "#2c6a66" }, { 28, 211, 40, 215, "#e0b04a", "#b88a30" } }) do
    local m = R(b[1], b[2], b[3], b[4]); c:rim(m, INK)
    obj(m, { b[6], b[6], b[5], "#efe0c0" }, function(x, y, lx, ly) if ly == 0 then return 1 end if lx % 4 == 0 and ly > 1 then return -1 end return 0 end)
  end
  local mug = R(54, 218, 59, 223); c:rim(mug, INK); obj(mug, { "#3a5a66", "#4a7a8a", "#6a9aaa", "#9ac0cc" }, nil, { lit = true }); put(60, 220, "#4a7a8a")
  for y = 212, 216, 2 do put(56 + (y % 4 == 0 and 1 or 0), y, "#e8e0e8") end
  -- bedroll tied with cord by the door
  gshadow(90, 112, 222)
  local bed = R(92, 213, 112, 221); c:rim(bed, INK)
  obj(bed, { "#3a3a60", "#4e4e82", "#6a68a0", "#8a88bc" }, function(x, y, lx) if lx % 5 == 0 then return -1 end return 0 end, { lit = true })
  E(92, 217, 2, 4):each(function(x, y) put(x, y, "#e6d3a8") end); put(92, 217, "#c9b48e")
  c:fillMask(R(98, 213, 99, 221), "#c0473f"); c:fillMask(R(106, 213, 107, 221), "#c0473f")
  -- boots by the step
  for k = 0, 1 do
    local bx = 40 + k * 8
    local bt = R(bx, 196, bx + 3, 204):add(R(bx, 202, bx + 6, 205)); c:rim(bt, INK)
    obj(bt, { "#3a2a2a", "#5a3a2e", "#7a4e36", "#9a6a4a" }, nil, { lit = true })
    c:fillMask(R(bx, 196, bx + 3, 197), "#e6d3a8")
  end
end

-- big campfire (the hero read): stone ring, logs, tall layered flames, pot on a crane
do
  local FX, FY = 136, 226
  -- warm glow on the ground around the fire
  for y = 206, 246 do for x = 86, 190 do
    local d = ((x - FX) / 54) ^ 2 + ((y - FY) / 20) ^ 2
    if d < 1 and gnd[y * W + x] and (x + y) % 2 == 0 and h(x, y, 44) > d * 0.7 then gput(x, y, d < 0.45 and "#b8a448" or "#9aa042") end
  end end
  -- warm glow on the shaded side wall and plinth
  for y = 150, 206 do for x = 133, 162 do
    local cur = c:get(x, y)
    if (cur == SIDE[3] or cur == SIDE[4]) and (x + y) % 2 == 0 and y > 196 - (x - 132) * 0.5 then put(x, y, "#8a5a40") end
  end end
  -- pit + ember bed
  local pit = E(FX, FY + 1, 22, 6)
  c:fillMask(pit, "#3a2424")
  for x = FX - 18, FX + 18 do if h(x, 1, 45) > 0.45 then put(x, FY + 2 + floor_(h(x, 2, 45) * 3), h(x, 3, 45) > 0.5 and "#f08a2c" or "#c0402a") end end
  -- ring stones, back row then front row
  local function stone(sx, sy, rw, rh, seed)
    local m = E(sx, sy, rw, rh); c:rim(m, INK)
    m:each(function(x, y)
      local l = (x - sx) / rw + (y - sy) / rh
      local col = l < -0.6 and STONE[5] or (l < 0.2 and STONE[4] or (l < 0.8 and STONE[3] or STONE[2]))
      if h(x, y, seed) > 0.92 then col = STONE[2] end
      put(x, y, col)
    end)
    if h(sx, sy, seed) > 0.5 then put(sx - 1, sy - rh + 1, "#6e8a4a") end
  end
  for k = 0, 6 do local a = 3.1416 + k * 3.1416 / 6; stone(floor_(FX + cos(a) * 24), floor_(FY + sin(a) * 7), 4, 3, 46 + k) end
  -- crossed logs
  local l1 = c:line({ { FX - 16, FY + 3 }, { FX + 12, FY - 4 } }, 4)
  local l2 = c:line({ { FX - 12, FY - 4 }, { FX + 16, FY + 3 } }, 4)
  c:rim(l1:copy():add(l2), INK); obj(l2, LOG, nil, { lit = true }); obj(l1, LOG, nil, { lit = true })
  for _, p in ipairs({ { FX - 16, FY + 3 }, { FX + 16, FY + 3 } }) do E(p[1], p[2], 2, 2):each(function(x, y) put(x, y, "#e0b880") end) end
  -- flames: big, layered, ink-edged
  local function tongue(cx, top, bot, hw, lean)
    return PL{ { cx + lean, top }, { cx + floor_(hw * 0.55) + floor_(lean / 2), top + floor_((bot - top) * 0.42) },
      { cx + hw, bot - floor_((bot - top) * 0.12) }, { cx + floor_(hw * 0.7), bot }, { cx - floor_(hw * 0.7), bot },
      { cx - hw, bot - floor_((bot - top) * 0.12) }, { cx - floor_(hw * 0.6) + floor_(lean / 2), top + floor_((bot - top) * 0.48) } }
  end
  local outerF = tongue(FX, 174, FY, 19, -2):add(tongue(FX - 11, 190, FY, 10, -4)):add(tongue(FX + 12, 186, FY, 10, 3)):add(tongue(FX + 4, 180, FY - 6, 7, 5))
  c:rim(outerF, INK)
  c:fillMask(outerF, "#d9482b")
  local midF = tongue(FX, 182, FY - 1, 14, -2):add(tongue(FX - 10, 196, FY - 1, 7, -3)):add(tongue(FX + 11, 193, FY - 1, 7, 2))
  c:fillMask(midF, "#f08a2c")
  local inF = tongue(FX, 192, FY - 2, 9, -1):add(tongue(FX + 7, 200, FY - 2, 4, 2))
  c:fillMask(inF, "#ffc94a")
  c:fillMask(tongue(FX - 1, 202, FY - 3, 5, 0), "#fff1b0")
  -- dark flicker licks inside the outer flame for shape
  for _, p in ipairs({ { FX - 6, 196 }, { FX + 8, 194 }, { FX - 13, 206 } }) do put(p[1], p[2], "#b83424"); put(p[1], p[2] + 1, "#b83424") end
  -- sparks
  for i = 1, 12 do
    local sx, sy = FX - 14 + floor_(h(i, 9, 47) * 30), 148 + floor_(h(i, 10, 47) * 26)
    put(sx, sy, i % 3 == 0 and "#fff1b0" or (i % 3 == 1 and "#ffc94a" or "#f08a2c"))
  end
  -- iron crane with a hanging kettle (left of the fire, over the edge)
  local post = R(FX - 30, 182, FX - 28, FY + 6); c:rim(post, INK); obj(post, IRON, nil, { lit = true, noedge = true })
  local arm = R(FX - 30, 180, FX - 8, 182); c:rim(arm, INK); c:fillMask(arm, "#4a4554"); c:fillMask(R(FX - 30, 180, FX - 8, 180), "#908a98")
  c:fillMask(R(FX - 10, 183, FX - 10, 190), "#3a3440")
  local kettle = PL{ { FX - 17, 194 }, { FX - 3, 194 }, { FX - 1, 199 }, { FX - 3, 205 }, { FX - 17, 205 }, { FX - 19, 199 } }
  c:rim(kettle, INK); obj(kettle, { "#2e2a36", "#4a4554", "#6a6474", "#908a98", "#c0bac4" }, nil, { lit = true })
  c:fillMask(c:line({ { FX - 17, 193 }, { FX - 10, 189 }, { FX - 3, 193 } }, 1), "#3a3440")
  c:fillMask(c:line({ { FX - 20, 198 }, { FX - 24, 193 } }, 1), "#4a4554")
  put(FX - 15, 196, "#e0dce8"); put(FX - 14, 196, "#c0bac4")
  -- steam puff from the spout
  E(FX - 26, 188, 3, 2):each(function(x, y) put(x, y, (x + y) % 2 == 0 and "#f0eaf0" or "#d4ccd8") end)
  E(FX - 29, 182, 2, 2):each(function(x, y) put(x, y, "#e4dce6") end)
  -- toasting stick with a marshmallow (quirk)
  c:fillMask(c:line({ { FX + 34, FY + 12 }, { FX + 18, FY - 8 } }, 1), "#8e603e")
  c:fillMask(R(FX + 16, FY - 12, FX + 19, FY - 9), "#f4e6c8"); put(FX + 16, FY - 9, "#c08040")
  -- stump seat right of the fire, with a water bucket
  gshadow(160, 180, 241)
  local stp = R(162, 230, 176, 240); c:rim(stp, INK); obj(stp, LOG, plankV(4, 48), { lit = true })
  E(169, 230, 7, 2):each(function(x, y) put(x, y, ((x - 169) ^ 2 / 9 + (y - 230) ^ 2 <= 1) and "#c89a64" or "#e0b880") end)
  local bk = R(146, 236, 156, 245); c:rim(bk, INK); obj(bk, LOG, plankV(3, 49), { lit = true })
  c:fillMask(R(146, 238, 156, 238), "#6a6474"); c:fillMask(R(146, 243, 156, 243), "#6a6474"); c:fillMask(R(147, 236, 155, 236), "#6a9ab0")
  c:fillMask(c:line({ { 146, 236 }, { 151, 231 }, { 156, 236 } }, 1), "#4a4554")
end

-- clothesline from the lodge corner to a pole, with socks and a shirt (quirk)
do
  c:fillMask(R(184, 120, 185, 168), "#7e5232"); put(184, 120, "#c99258"); c:fillMask(R(182, 168, 187, 169), "#5a7434")
  for x = 163, 184 do put(x, 128 + floor_(sin((x - 163) / 21 * 3.1416) * 3), "#e6d6b2") end
  c:paint({ "rrr", "www", "rrr", "rrr", "rrrr", ".rrr" }, 167, 130, { r = "#c0473f", w = "#efe0c0" })
  c:paint({ "bbbbbbb", "bbbbbbb", ".bbbbb.", ".bbybb.", ".bbbbb.", ".bbbbb." }, 174, 131, { b = "#4e7ab0", y = "#f4d24a" })
  for y = 131, 136 do put(180, y, "#3a5a8a") end
end

------------------------------------------------------------------ ground life: mottling, worn paths, flowers, pebbles
local STANDS = { { 200, 252 }, { 292, 252 }, { 352, 242 }, { 250, 205 }, { 250, 152 }, { 198, 188 } }
local function guarded(x, y)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 17 and abs(y - s[2]) <= 17 then return true end end
  return x >= 376 and y >= 226
end
local function gp(x, y, col)
  if x < 11 or x > 468 or y < 113 or y >= H or guarded(x, y) then return false end
  if gnd[y * W + x] then gput(x, y, col) return true end
  return false
end
local patches = { { 60, 255, 40, 12, "d" }, { 220, 140, 16, 8, "l" }, { 310, 140, 40, 9, "l" }, { 440, 145, 24, 10, "d" },
  { 300, 225, 26, 12, "l" }, { 420, 220, 34, 8, "l" }, { 120, 262, 50, 7, "d" }, { 340, 262, 34, 8, "d" }, { 20, 240, 14, 20, "d" },
  { 200, 120, 30, 5, "d" }, { 455, 240, 22, 20, "l" } }
for _, p in ipairs(patches) do
  for y = p[2] - p[4], p[2] + p[4] do for x = p[1] - p[3], p[1] + p[3] do
    local d = ((x - p[1]) / p[3]) ^ 2 + ((y - p[2]) / p[4]) ^ 2
    if d < 1 then
      local ch = (x + y) % 2 == 0 and (h(x, y, 50) > d * 0.9) or (h(x, y, 51) > 0.8 + d * 0.2 and d < 0.5)
      if ch then gp(x, y, p[5] == "d" and "#62803a" or "#9ab452") end
    end
  end end
end
local function wear(x0, y0, x1, y1, n)
  for i = 0, n do
    local t = i / n
    local x = floor_(x0 + (x1 - x0) * t + (h(i, 1, 52) - 0.5) * 7)
    local y = floor_(y0 + (y1 - y0) * t + (h(i, 2, 52) - 0.5) * 3)
    gp(x, y, "#a48a5a"); if h(i, 3, 52) > 0.5 then gp(x + 1, y, "#b89c68") end
    if h(i, 4, 52) > 0.6 then gp(x, y + 1, "#7e6a46") end
  end
end
wear(176, 226, 120, 236, 34); wear(332, 214, 372, 222, 18); wear(150, 214, 182, 208, 12)
for i = 1, 60 do
  local x, y = floor_(h(i, 5, 53) * 450) + 12, floor_(h(i, 6, 53) * 150) + 118
  if gp(x, y, "#a8a29c") then gp(x + 1, y, "#cfc6b8"); gp(x, y + 1, "#6e6870") end
end
local function daisy(x, y) gp(x - 1, y, "#fbf0dc"); gp(x + 1, y, "#fbf0dc"); gp(x, y - 1, "#fbf0dc"); gp(x, y + 1, "#fbf0dc"); gp(x, y, "#f4c24a") end
local function poppy(x, y) gp(x, y, "#d9482b"); gp(x + 1, y, "#e8644a"); gp(x, y + 1, "#4f7a44") end
local function bell(x, y) gp(x, y, "#8a7ac8"); gp(x, y - 1, "#a898e0"); gp(x, y + 1, "#4f7a44"); gp(x + 1, y + 1, "#6a9a52") end
local clumps = { { 60, 262, 1 }, { 22, 214, 2 }, { 210, 128, 3 }, { 320, 135, 1 }, { 455, 135, 2 }, { 100, 250, 3 }, { 245, 262, 1 },
  { 430, 222, 3 }, { 188, 160, 2 }, { 310, 240, 3 }, { 16, 256, 2 }, { 282, 214, 1 }, { 328, 172, 2 }, { 178, 128, 1 } }
for _, cl in ipairs(clumps) do
  for k = 1, 5 do
    local x, y = cl[1] + floor_((h(k, cl[1], 54) - 0.5) * 18), cl[2] + floor_((h(k, cl[2], 54) - 0.5) * 8)
    if cl[3] == 1 then daisy(x, y) elseif cl[3] == 2 then poppy(x, y) else bell(x, y) end
  end
end
for i = 1, 30 do
  local x, y = floor_(h(i, 7, 55) * 450) + 12, floor_(h(i, 8, 55) * 150) + 118
  local col = i % 3 == 0 and "#c8842a" or (i % 3 == 1 and "#e0aa3a" or "#9a6a2a")
  gp(x, y, col); gp(x + 1, y + 1, col)
end

------------------------------------------------------------------ mid trees by the road (birch right of lodge, sapling left of wagon)
local function mk(x, y, col)
  if not inb(x, y) or guarded(x, y) then return end
  if c:get(x, y) ~= INK then put(x, y, col) end
end
local function crown(cx, cy, rx, ry, lo, mid, hi, seed)
  local m = HP.mask()
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
    if d < 1 and h(x, y, seed) > d * 0.5 then m:set(x, y) end
  end end
  c:rim(m, INK)
  m:each(function(x, y)
    local l = (x - cx) / rx + (y - cy) / ry
    local col = l < -0.5 and hi or (l > 0.45 and lo or mid)
    if (x + y) % 2 == 0 and h(x, y, seed + 1) > 0.85 then col = lo end
    mk(x, y, col)
  end)
end
-- birch (pale bark, yellow-green leaves) at the left verge behind the clothesline
do
  local tk = R(196, 104, 199, 132); c:rim(tk, INK)
  tk:each(function(x, y) put(x, y, x == 196 and "#f0e6d4" or (x == 199 and "#9a948a" or "#d8cfbe")) end)
  for y = 108, 130, 5 do put(197, y, "#3a2a2a"); put(198, y + 1, "#3a2a2a") end
  for x = 195, 202 do if gnd[133 * W + x] then gput(x, 133, "#5a7434") end end
  crown(198, 96, 11, 13, "#7a8a2e", "#a8b844", "#d4d870", 85)
  crown(191, 104, 6, 6, "#7a8a2e", "#a8b844", "#d4d870", 86)
end
-- berry bush near the wagon shafts
do
  local bx, by, r = 322, 196, 8
  local m = HP.mask()
  for yy = -r, 0 do for xx = -r - 3, r + 3 do if (xx / (r + 3)) ^ 2 + (yy / r) ^ 2 <= 1 then m:set(bx + xx, by + yy) end end end
  c:rim(m, INK)
  m:each(function(x, y) local xx, yy = x - bx, y - by; put(x, y, (xx + yy < -r * 0.6) and "#7aa65a" or ((xx - yy > r) and "#2f5a3c" or "#4f7a44")) end)
  for i = 1, 7 do put(bx - r + floor_(h(i, bx, 84) * r * 2), by - 1 - floor_(h(i, by, 84) * (r - 2)), i % 2 == 0 and "#6a3aa0" or "#d9482b") end
end

------------------------------------------------------------------ gate frame: timber posts, beam, braces, lanterns, bunting
do
  local lpost, rpost = R(0, 0, 10, H - 1), R(469, 0, W - 1, H - 1)
  c:rim(lpost, INK, R(0, 0, W - 1, H - 1)); c:rim(rpost, INK)
  obj(lpost, TIMB, plankV(5, 60), { lit = true })
  obj(rpost, TIMB, plankV(5, 61), { base = 2 })
  local beam = R(0, 0, W - 1, 10)
  c:rim(beam, INK)
  obj(beam, TIMB, plankH(5, 62), { lit = true })
  for x = 0, W - 1 do if h(x, 1, 63) > 0.86 then put(x, 4, "#3e2619") end end
  for _, b in ipairs({ { 11, 11, 32, 32 }, { 468, 11, 447, 32 } }) do
    local m = c:line({ { b[1], b[4] }, { b[3], b[2] } }, 4)
    c:rim(m, INK); obj(m, TIMB, nil, { lit = true })
  end
  -- ivy on the left post (north side moss + leaves)
  for y = 40, 260, 3 do
    if h(y, 1, 64) > 0.45 then put(9, y, "#4f7a44"); put(10, y + 1, "#6a9a52"); put(8, y + 1, "#3b5e3a") end
  end
  -- bunting across the top (pennants), sagging
  local cols = { "#c0473f", "#e0b04a", "#3f8f8a", "#f4e6c8", "#7a6aa8" }
  for _, s in ipairs({ { 36, 228, 12, 9 }, { 252, 444, 12, 9 } }) do
    local x0, x1, y0, sag = s[1], s[2], s[3], s[4]
    for x = x0, x1 do
      local t = (x - x0) / (x1 - x0)
      local y = y0 + floor_(sin(t * 3.1416) * sag)
      put(x, y, "#5f3a24")
      if (x - x0) % 12 == 4 then
        local col = cols[1 + ((x - x0) // 12) % 5]
        local f = PL{ { x - 3, y + 1 }, { x + 3, y + 1 }, { x, y + 8 } }
        c:fillMask(f, col); put(x - 3, y + 1, INK); put(x + 3, y + 1, INK); put(x, y + 8, INK)
        put(x - 2, y + 2, col == "#f4e6c8" and "#fff4dc" or "#f4e6c8")
      end
    end
  end
  -- lanterns
  local function lantern(lx, ly)
    for y = 11, ly - 1, 2 do put(lx, y, "#3a2a22") end
    local capm = PL{ { lx - 3, ly }, { lx + 3, ly }, { lx + 6, ly + 4 }, { lx - 6, ly + 4 } }
    c:rim(capm, INK); c:fillMask(capm, "#4a3a3a"); put(lx - 2, ly + 1, "#7a6a6a")
    local g = R(lx - 5, ly + 5, lx + 5, ly + 17)
    c:rim(g, INK); c:fillMask(g, "#f2c75c"); c:fillMask(R(lx - 3, ly + 7, lx - 1, ly + 13), "#fff0a8")
    c:fillMask(R(lx, ly + 5, lx, ly + 17), "#3a2a22"); c:fillMask(R(lx + 3, ly + 8, lx + 4, ly + 16), "#d9a441")
    c:fillMask(R(lx - 6, ly + 18, lx + 6, ly + 19), "#4a3a3a")
  end
  lantern(150, 22); lantern(424, 22)
  -- corner pine boughs
  local function bough(x0, y0, dir, len)
    for k = 0, len do
      local bx, by = x0 + dir * k, y0 + floor_(k * 0.3)
      put(bx, by, "#4a3a2a")
      if k % 2 == 0 then
        for n = 1, 5 do
          put(bx - dir * floor_(n * 0.4), by + n, n < 3 and "#5a8a5a" or "#2f5a44")
          put(bx + dir * floor_(n * 0.6), by + n, "#3b6a4c")
        end
      end
    end
  end
  bough(11, 10, 1, 20); bough(468, 10, -1, 44)
end

------------------------------------------------------------------ foreground planting (bottom-left; stand zones and compass corner untouched)
do
  local function fern(x, y, n)
    for k = -n, n do
      local len = n + 3 - abs(k)
      for t = 1, len do
        local px, py = x + k * floor_(t / 2) + (k > 0 and 1 or (k < 0 and -1 or 0)) * floor_(t / 3), y - t - floor_(abs(k) * t / 4)
        mk(px, py, (t % 3 == 0) and "#9ab45a" or ((k <= 0) and "#5a8a48" or "#3a643c"))
      end
    end
  end
  local function lav(x, y, hgt)
    for t = 0, hgt do mk(x, y - t, "#4f7a44") end
    for t = 0, 3 do mk(x - 1 + (t % 2) * 2, y - hgt - t, "#8a7ac8"); mk(x, y - hgt - t, t == 3 and "#c0b0f0" or "#6a5aa8") end
  end
  local function tall(x, y)
    for k = 0, 4 do for t = 0, 5 - abs(2 - k) do mk(x + k * 2 + (k - 2) * floor_(t / 3), y - 2 - t, t % 2 == 0 and "#b0c060" or "#7e9a44") end end
  end
  fern(20, 268, 6); fern(54, 266, 5); fern(112, 268, 5); fern(150, 266, 4)
  lav(34, 269, 13); lav(38, 267, 10); lav(42, 269, 12); lav(80, 268, 11); lav(84, 266, 14); lav(128, 268, 12); lav(132, 269, 15)
  tall(92, 269); tall(160, 262); tall(14, 246); tall(318, 268); tall(456, 222)
  fern(326, 268, 3)
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. "here-haven.aseprite", png = OUT .. "here-haven.png", scale = 1 }
print("ok here-haven")

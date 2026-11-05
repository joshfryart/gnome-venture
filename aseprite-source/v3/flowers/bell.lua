-- bell (flowers P2_F1)
local out = app.params["out"] or "./"
local W, H = 64, 64
local OUTL = {58,58,60}
local INKC = {0x2b,0x1c,0x26}
local RAMP = { {96,96,98}, {126,126,128}, {154,154,156}, {182,182,184}, {206,206,204} }
local function hexc(h) return {tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16)} end
local function px(c) if type(c) == "string" then c = hexc(c) end return app.pixelColor.rgba(c[1], c[2], c[3], 255) end
local function ramp(v)
  local i = math.floor(v * 5.6 - 0.6) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return RAMP[i]
end
local function put(im, x, y, c) if x >= 0 and y >= 0 and x < W and y < H then im:putPixel(x, y, px(c)) end end
local function build(f)
  local im = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local c = f(x, y)
    if c then im:putPixel(x, y, px(c)) end
  end end
  return im
end
local function outline(im, c)
  local o = px(c)
  local mk = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    if app.pixelColor.rgbaA(im:getPixel(x, y)) == 0 then
      for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 0 and ny >= 0 and nx < W and ny < H and app.pixelColor.rgbaA(im:getPixel(nx, ny)) > 0 then mk[#mk+1] = {x, y} break end
      end
    end
  end end
  for _, p in ipairs(mk) do im:putPixel(p[1], p[2], o) end
end
local function finish(name, petals, centre, centreOutline)
  outline(petals, OUTL)
  if centreOutline then outline(centre, INKC) end
  local full = Image(W, H, ColorMode.RGB)
  local T = {217, 119, 58}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local p = petals:getPixel(x, y)
    if app.pixelColor.rgbaA(p) > 0 then
      local r = math.min(255, math.floor(app.pixelColor.rgbaR(p) * T[1] / 255 * 1.25 + 0.5))
      local g = math.min(255, math.floor(app.pixelColor.rgbaG(p) * T[2] / 255 * 1.25 + 0.5))
      local b = math.min(255, math.floor(app.pixelColor.rgbaB(p) * T[3] / 255 * 1.25 + 0.5))
      full:putPixel(x, y, app.pixelColor.rgba(r, g, b, 255))
    end
    local c = centre:getPixel(x, y)
    if app.pixelColor.rgbaA(c) > 0 then full:putPixel(x, y, c) end
  end end
  local function save(img, n)
    local s = Sprite(W, H, ColorMode.RGB)
    s.cels[1].image:drawImage(img, Point(0, 0))
    s:saveCopyAs(out .. n .. ".png")
    s:close()
  end
  save(petals, name .. "-petals"); save(centre, name .. "-centre"); save(full, name)
  local s = Sprite(W, H, ColorMode.RGB)
  s.layers[1].name = "petals"
  s.cels[1].image:drawImage(petals, Point(0, 0))
  local l2 = s:newLayer(); l2.name = "centre"
  s:newCel(l2, 1, centre, Point(0, 0))
  s:saveAs(out .. name .. ".aseprite")
end
local function mkBell(cx, y0, y1, R0, flare, nl, depth)
  local function hw(y)
    local t = (math.min(y, y1) - y0) / (y1 - y0)
    if t < 0 then t = 0 end
    local h = 2.5 + (R0 - 2.5) * (1 - (1 - t) ^ 2.4)
    if t > 0.74 then h = h + flare * ((t - 0.74) / 0.26) ^ 2 end
    return h
  end
  local RIM = R0 + flare
  return function(x, y)
    local px_ = x + 0.5 - cx
    if y < y0 then return nil end
    local h = hw(y)
    if math.abs(px_) > h then return nil end
    local frac = ((px_ + RIM) / (2 * RIM)) * nl
    local f = frac % 1
    local yb = y1 + depth * (1 - math.abs(f * 2 - 1))
    if y > yb then return nil end
    local t = (math.min(y, y1) - y0) / (y1 - y0)
    local nx = px_ / h
    local val = 0.60 + 0.30 * (-nx) * 0.9 + 0.10 * (1 - t) - 0.05 * t
    if y > y1 - 0.5 then val = 0.80 - 0.18 * math.abs(nx) end         -- flared lip catches light
    if y > y1 - 3.5 and y <= y1 - 0.5 and math.abs(nx) < 0.82 then val = 0.30 end -- dark mouth
    if (f < 0.09 or f > 0.93) and t > 0.35 and y <= y1 - 0.5 then val = val - 0.2 end -- petal seams
    if y > y1 - 0.5 and (f < 0.1 or f > 0.92) then val = 0.40 end
    if y < y0 + 1.5 then val = val + 0.08 end
    return ramp(val)
  end
end
local big = mkBell(24, 14, 40, 10, 4, 5, 4)
local small = mkBell(48, 28, 42, 6, 2.5, 5, 3)
local petals = build(function(x, y) return small(x, y) or big(x, y) end)
-- draw big over small where overlapping: big first in composite
petals = build(function(x, y) return big(x, y) or small(x, y) end)

local centre = Image(W, H, ColorMode.RGB)
local G1, G2, G3 = "#2f6b2e", "#3f8a3a", "#5aa84a"
-- arching stem from big bell to small bell
local function bez(t)
  local p0, p1, p2, p3 = {24, 15}, {24, 3}, {48, 3}, {48, 29}
  local m = 1 - t
  return m*m*m*p0[1] + 3*m*m*t*p1[1] + 3*m*t*t*p2[1] + t*t*t*p3[1],
         m*m*m*p0[2] + 3*m*m*t*p1[2] + 3*m*t*t*p2[2] + t*t*t*p3[2]
end
for i = 0, 120 do
  local x, y = bez(i / 120)
  local ix, iy = math.floor(x), math.floor(y)
  put(centre, ix + 1, iy + 1, G1); put(centre, ix, iy + 1, G1); put(centre, ix + 1, iy, G1)
end
for i = 0, 120 do
  local x, y = bez(i / 120)
  local ix, iy = math.floor(x), math.floor(y)
  put(centre, ix, iy, G2)
end
for i = 0, 120 do
  local x, y = bez(i / 120)
  local ix, iy = math.floor(x), math.floor(y)
  put(centre, ix - 1, iy - 1, G3)
end
-- repaint mid pass over light to keep 2px stem with light edge only upper-left
for i = 0, 120 do
  local x, y = bez(i / 120)
  put(centre, math.floor(x), math.floor(y), G2)
end
-- calyx caps
local function calyx(cx, y, rx)
  for dy = 0, 2 do for dx = -rx, rx - 1 do
    local c = G2
    if dy == 0 then c = G3 elseif dy == 2 or dx >= rx - 2 then c = G1 end
    if dx * dx / (rx * rx) + (dy - 0.5) ^ 2 / 6 <= 1.1 then put(centre, cx + dx, y + dy, c) end
  end end
end
calyx(24, 13, 4); calyx(48, 27, 3)
-- clappers (gold beads on thin filament)
local function clapper(cx, ytop, ybead, rr)
  for y = ytop, ybead do put(centre, cx, y, "#e0b040") end
  for dy = -rr, rr do for dx = -rr, rr do
    if dx * dx + dy * dy <= rr * rr + 0.6 then
      local c = "#f0c850"
      if dx + dy > 0 then c = "#c89030" elseif dx + dy < -1 then c = "#fbe89a" end
      put(centre, cx + dx, ybead + dy, c)
    end
  end end
end
clapper(24, 36, 48, 2)
clapper(48, 38, 45, 1)
finish("bell", petals, centre, true)

-- poppy (flowers P2_F2)
local out = app.params["out"] or "./"
local W, H = 64, 64
local OUTL = {58,58,60}
local RAMP = { {96,96,98}, {126,126,128}, {154,154,156}, {182,182,184}, {206,206,204} }
local function rgba(c) return app.pixelColor.rgba(c[1], c[2], c[3], 255) end
local function hexc(h) return {tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16)} end
local function ramp(v)
  local i = math.floor(v * 5.6 - 0.6) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return RAMP[i]
end
local val, mask = {}, {}
for y = -1, H do val[y] = {}; mask[y] = {} end
-- add a shape: inside(x,y) -> nil | v (0..1 shade); edges get inner outline tone
local function addShape(inside, cx, cy, rad, edgeTone)
  local m = {}
  for y = 0, H - 1 do m[y] = {} end
  for y = 0, H - 1 do for x = 0, W - 1 do
    if inside(x + 0.5, y + 0.5) then m[y][x] = true end
  end end
  for y = 0, H - 1 do for x = 0, W - 1 do
    if m[y][x] then
      local dx, dy = x + 0.5 - cx, y + 0.5 - cy
      local lit = -(dx * 0.7 + dy * 0.7) / rad
      local v = 0.6 + 0.24 * lit
      local isEdge = false
      for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        if not (m[y + d[2]] and m[y + d[2]][x + d[1]]) then isEdge = true end
      end
      if isEdge then v = (lit > 0.05) and 0.40 or 0.18 end
      val[y][x] = v; mask[y][x] = true
    end
  end end
  return m
end
local function put(x, y, v) if x >= 0 and x < W and y >= 0 and y < H then val[y][x] = v; mask[y][x] = true end end
local function finishPetals()
  local img = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do
    if mask[y][x] then img:putPixel(x, y, rgba(ramp(val[y][x]))) end
  end end
  local o = rgba(OUTL)
  for y = 0, H - 1 do for x = 0, W - 1 do
    if not mask[y][x] then
      for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        if mask[y + d[2]] and mask[y + d[2]][x + d[1]] then img:putPixel(x, y, o) break end
      end
    end
  end end
  return img
end
local function newCentre() return Image(W, H, ColorMode.RGB) end
local function cp(img, x, y, h) if x >= 0 and x < W and y >= 0 and y < H then img:putPixel(x, y, rgba(hexc(h))) end end
local function disc(img, cx, cy, r, fn)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local d = math.sqrt(dx * dx + dy * dy)
    if d <= r then local h = fn(dx, dy, d); if h then cp(img, x, y, h) end end
  end end
end
local function saveAll(NAME, petals, centre)
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
  save(petals, NAME .. "-petals"); save(centre, NAME .. "-centre"); save(full, NAME)
  local s = Sprite(W, H, ColorMode.RGB)
  s.layers[1].name = "petals"
  s.cels[1].image:drawImage(petals, Point(0, 0))
  local l2 = s:newLayer(); l2.name = "centre"
  s:newCel(l2, 1, centre, Point(0, 0))
  s:saveAs(out .. NAME .. ".aseprite")
end
-- rotated ellipse-ish petal; shapeFn(t,v) -> half width factor at t in 0..1 along u
local function petal(cx, cy, ang, u0, u1, hw, shp)
  local ca, sa = math.cos(ang), math.sin(ang)
  return function(px, py)
    local dx, dy = px - cx, py - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if u < u0 or u > u1 then return false end
    local t = (u - u0) / (u1 - u0)
    return math.abs(v) <= hw * shp(t, v, u)
  end
end
local CX, CY = 32, 32
local NAME = "poppy"
-- crinkled paper-thin petals: edge radius wobbles
local function crinkle(seed) return function(t, v, u)
  local base = math.sin(math.pi * (0.02 + 0.98 * t)) ^ 0.5
  local w = 1 + 0.09 * math.sin(v * 1.35 + seed) + 0.06 * math.sin(v * 2.9 + seed * 2)
  if t > 0.8 then base = base * (1 + 0.1 * math.sin(v * 2.2 + seed)) end
  return base * w
end end
local angs = { -45, 45, 135, 225 }
local lens = { 28, 27, 27, 24 }  -- quirk: lower-left petal is the short, crumpled one
local order = { 1, 3, 2, 4 }
for k, i in ipairs(order) do
  local a = math.rad(angs[i])
  local hw = (i == 4) and 11.5 or 12.5
  local midu = lens[i] * 0.55
  addShape(petal(CX, CY, a, 0, lens[i], hw, crinkle(i * 1.7)), CX + math.cos(a) * midu, CY + math.sin(a) * midu, 13)
end
-- fold crease lines on petals (lighter ridge lines radiating)
for _, i in ipairs{1, 2, 3} do
  local a = math.rad(angs[i] + (i == 2 and 14 or -12))
  for u = 8, 22 do
    local x, y = math.floor(CX + math.cos(a) * u), math.floor(CY + math.sin(a) * u)
    if mask[y] and mask[y][x] and val[y][x] > 0.45 then val[y][x] = val[y][x] - 0.2 end
  end
end
local petals = finishPetals()
local centre = newCentre()
-- ovary disc with ridged star top, dark ring of stamens
disc(centre, CX, CY, 9.2, function(dx, dy, d)
  if d > 8.3 then
    local a = math.atan(dy, dx)
    if d <= 9.2 and (math.floor((a + math.pi) / (2 * math.pi) * 18 + 0.5) % 2 == 0) then return "#3a1a3e" end
    return nil
  end
  return false
end)
disc(centre, CX, CY, 8.4, function(dx, dy, d)
  if d > 6.2 then
    local a = math.atan(dy, dx)
    local k = math.floor((a + math.pi) / (2 * math.pi) * 18 + 0.5)
    return (k % 2 == 0) and "#2a1530" or "#4a2650"
  end
  return false
end)
disc(centre, CX, CY, 6.2, function(dx, dy, d)
  local l = -(dx * 0.7 + dy * 0.7) / 6.2
  local r5 = {"#3d5a2a", "#5b8038", "#7fa347", "#a5c565", "#c8dd90"}
  local i = math.floor((0.5 + 0.35 * l - 0.1 * (d / 6.2) ^ 2) * 5.5) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  -- ridge spokes
  local a = math.atan(dy, dx)
  if d > 1.6 and math.floor((a + math.pi) / (2 * math.pi) * 8 + 0.5) % 1 == 0 and math.abs(math.sin(a * 4)) < 0.16 then i = math.max(1, i - 2) end
  return r5[i]
end)
cp(centre, CX - 2, CY - 3, "#e4f0b0"); cp(centre, CX - 3, CY - 2, "#e4f0b0")
saveAll(NAME, petals, centre)

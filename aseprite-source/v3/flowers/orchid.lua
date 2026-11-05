-- orchid (flowers P2_F2)
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
local CX, CY = 32, 33
local NAME = "orchid"
local function rad(d) return math.rad(d) end
local function dome(t) return math.sin(math.pi * (0.06 + 0.94 * t)) ^ 0.5 end
-- lower sepals (behind), angled down-left and down-right; quirk: right one shorter
addShape(petal(CX, CY, rad(125), 3, 24, 5.0, function(t) return dome(t) end), CX - 9, CY + 12, 8)
addShape(petal(CX, CY, rad(55), 3, 21, 5.0, function(t) return dome(t) end), CX + 8, CY + 11, 8)
-- dorsal sepal on top
addShape(petal(CX, CY, rad(-90), 2, 24, 5.4, function(t) return dome(t) end), CX, CY - 12, 9)
-- big round wing petals left and right, slightly raised
addShape(petal(CX, CY, rad(-12), 2, 28, 10.5, function(t) return math.sin(math.pi * (0.04 + 0.96 * t)) ^ 0.62 end), CX + 15, CY - 3, 11)
addShape(petal(CX, CY, rad(192), 2, 28, 10.5, function(t) return math.sin(math.pi * (0.04 + 0.96 * t)) ^ 0.62 end), CX - 15, CY - 2, 11)
-- lip: trilobed tongue pointing down with a curly tendril quirk
addShape(petal(CX, CY + 1, rad(90), 0, 17, 5.2, function(t) return (t < 0.45) and (0.55 + t) or (1.0 - (t - 0.45) * 0.6) * (0.5 + 0.5 * math.sin(math.pi * (1 - t) * 1.0)) end), CX, CY + 9, 8)
-- tendrils off lip tip
for i = 0, 5 do put(CX + 1 + math.floor(i * 0.6), CY + 18 + i, 0.5) end
put(CX + 4, CY + 23, 0.62); put(CX + 5, CY + 22, 0.6); put(CX + 5, CY + 21, 0.58)
for i = 0, 4 do put(CX - 2 - math.floor(i * 0.5), CY + 18 + i, 0.5) end
local petals = finishPetals()
local centre = newCentre()
-- column: pale hood with yellow anther cap and magenta freckles on the lip
disc(centre, CX, CY - 1, 3.6, function(dx, dy, d)
  local l = -(dx * 0.6 + dy * 0.8) / 3.6
  local r5 = {"#c9a64a", "#e4c85e", "#f4e08a", "#fbf0b8", "#fff8d8"}
  local i = math.floor((0.55 + 0.35 * l) * 5.5) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return r5[i]
end)
cp(centre, CX - 2, CY - 3, "#fff8d8")
cp(centre, CX - 1, CY - 3, "#fff8d8")
for _, p in ipairs{{-3,4},{3,4},{-2,6},{2,6},{0,5},{-3,8},{3,8},{0,8},{-1,11},{1,11}} do cp(centre, CX + p[1], CY + p[2], "#7a1f4a") end
cp(centre, CX, CY + 1, "#8a6a22"); cp(centre, CX + 1, CY + 1, "#8a6a22")
saveAll(NAME, petals, centre)

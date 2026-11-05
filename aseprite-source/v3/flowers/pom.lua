-- pom (flowers P2_F2)
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
local NAME = "pom"
-- pompom: spiralling rings of tight round florets, outer first
local rings = { {r=19.5, n=11, s=5.4, off=0}, {r=14.5, n=9, s=4.8, off=0.5}, {r=10, n=7, s=4.2, off=0.2}, {r=5.8, n=5, s=3.6, off=0.7} }
for ri, R in ipairs(rings) do
  for i = 0, R.n - 1 do
    local a = (i + R.off) / R.n * math.pi * 2 - 0.9
    local px, py = CX + math.cos(a) * R.r, CY + math.sin(a) * R.r
    local sx = R.s * (1.0 + 0.08 * ((i * 7 + ri) % 3 - 1))
    -- cup-shaped floret: wider rounded tip, tucked base toward centre
    addShape(petal(px, py, a, -sx * 0.9, sx * 1.15, sx * 0.95, function(t) return math.sin(math.pi * (0.1 + 0.9 * t)) ^ 0.6 end), px, py, sx)
  end
end
-- quirk: one rogue floret poking out upper right
local qa = -0.75
local qx, qy = CX + math.cos(qa) * 23.5, CY + math.sin(qa) * 23.5
addShape(petal(qx, qy, qa, -3, 4.2, 3.2, function(t) return math.sin(math.pi * (0.1 + 0.9 * t)) ^ 0.6 end), qx, qy, 4)
local petals = finishPetals()
local centre = newCentre()
disc(centre, CX, CY, 3.3, function(dx, dy, d)
  local l = -(dx * 0.7 + dy * 0.7) / 3.3
  local ramp5 = {"#4f5a14", "#7d8a1e", "#a9b02c", "#d3c648", "#f1e68a"}
  local i = math.floor((0.5 + 0.4 * l - 0.15 * (d / 3.3) ^ 2) * 5.5) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return ramp5[i]
end)
cp(centre, 30, 30, "#f6efb0")
cp(centre, 33, 33, "#4f5a14")
saveAll(NAME, petals, centre)

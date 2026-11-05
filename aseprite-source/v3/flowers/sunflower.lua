-- sunflower (flowers P2_F1)
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
local CX, CY = 32, 32
local petals_def = {}
for i = 0, 15 do
  if i ~= 6 then petals_def[#petals_def+1] = {ang = i * 22.5 - 90, len = 27, hw = 3.0, layer = 1} end -- quirk: one outer petal missing
end
for i = 0, 15 do
  petals_def[#petals_def+1] = {ang = i * 22.5 - 78.75, len = 21.5, hw = 2.8, layer = 2}
end
local function petalAt(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local best, bd
  for _, p in ipairs(petals_def) do
    local a = math.rad(p.ang)
    local ca, sa = math.cos(a), math.sin(a)
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if u >= 5 and u <= p.len then
      local t = (u - 5) / (p.len - 5)
      local w = p.hw * math.min(1, (1 - t) / 0.42) ^ 0.8
      if t < 0.25 then w = math.max(w, 2.0 + t * 3) end
      if math.abs(v) <= w then
        local s = math.abs(v) / math.max(w, 0.1) - p.layer * 10
        if not best or s < best then best = s; bd = {p = p, t = t, v = v, a = a, w = w} end
      end
    end
  end
  if not bd then return nil end
  local nx, ny = -math.sin(bd.a), math.cos(bd.a)
  if bd.v < 0 then nx, ny = -nx, -ny end
  local lit = nx * -0.7 + ny * -0.7
  local val = 0.60 + 0.26 * lit * math.min(1, math.abs(bd.v) / 1.3 + 0.25) + 0.16 * bd.t
  if bd.p.layer == 2 then val = val + 0.07 else val = val - 0.05 end
  if bd.p.layer == 2 and bd.t < 0.3 then val = val - 0.14 end
  if math.abs(bd.v) < 0.5 and bd.t > 0.1 and bd.t < 0.7 then val = val - 0.18 end
  if bd.t > 0.88 then val = val + 0.08 end
  return ramp(val)
end
local petals = build(petalAt)

local RC = {"#4a2a14", "#6b3a1a", "#8a4e22", "#a8662c", "#c98a3c"}
local ring = {"#b8761e", "#e0a02a", "#f4c040"}
local centre = Image(W, H, ColorMode.RGB)
local R = 9.2
for y = 0, H - 1 do for x = 0, W - 1 do
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local r = math.sqrt(dx * dx + dy * dy)
  if r <= R then
    local l = (-dx * 0.6 - dy * 0.8) / R
    local val = 0.46 + 0.36 * l - 0.12 * (r / R) ^ 2
    local i = math.floor(val * 5.5) + 1
    if i < 1 then i = 1 elseif i > 5 then i = 5 end
    local c = RC[i]
    if r > 7.4 then c = ring[(l > 0.2) and 3 or ((l > -0.35) and 2 or 1)] end
    put(centre, x, y, c)
  end
end end
-- fibonacci seed pits
for n = 1, 40 do
  local r = 1.15 * math.sqrt(n)
  local a = n * 2.39996
  local sx = math.floor(CX + r * math.cos(a))
  local sy = math.floor(CY + r * math.sin(a))
  if r < 6.9 then
    put(centre, sx, sy, "#3a2010")
    put(centre, sx - 1, sy - 1, "#b87c36")
  end
end
put(centre, 28, 28, "#f8d678"); put(centre, 29, 28, "#f8d678"); put(centre, 28, 29, "#f8d678")
finish("sunflower", petals, centre, true)

-- daisy (flowers P2pilot)
local out = app.params["out"] or "./"
local W, H = 64, 64
local CX, CY = 32, 32
local N = 12
local OUTL = {58,58,60}
local RAMP = { {96,96,98}, {126,126,128}, {154,154,156}, {182,182,184}, {206,206,204} } -- neutral greys, light base
local INK = Color{r=0x2b,g=0x1c,b=0x26}

local function petalAt(px, py)
  -- returns best (score, shade) for pixel centre, or nil
  local best, bu, bv, bi
  local dx, dy = px + 0.5 - CX, py + 0.5 - CY
  for i = 0, N - 1 do
    local a = math.rad(i * 30 - 90)
    local ca, sa = math.cos(a), math.sin(a)
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    local len, hw = 26.5, 3.3
    if i == 5 then len = 24 end                       -- quirk: one stubby petal
    if i == 2 then v = v - 0.09 * (u - 5) * (u - 5) / 4 end  -- quirk: one petal bent (curls)
    if u >= 4 and u <= len then
      local t = (u - 4) / (len - 4)
      local w = hw * (1 - (2 * t - 1) ^ 2) ^ 0.55
      if t < 0.3 then w = math.max(w, 1.4 + t * 6) end
      if t > 0.85 then w = w * 0.9 end
      if math.abs(v) <= w then
        local s = math.abs(v) / math.max(w, 0.1)
        if not best or s < best then best, bu, bv, bi = s, t, v, i end
      end
    end
  end
  if not best then return nil end
  local a = math.rad(bi * 30 - 90)
  -- light from upper-left: normal of the petal side
  local nx, ny = -math.sin(a), math.cos(a)
  if bv < 0 then nx, ny = -nx, -ny end
  local lit = (nx * -0.7 + ny * -0.7)  -- -1..1
  local val = 0.62 + 0.28 * lit * math.min(1, math.abs(bv) / 1.6 + 0.2) + 0.22 * bu - 0.18 * (1 - bu) ^ 2
  if math.abs(bv) < 0.5 and bu < 0.75 and bu > 0.12 then val = val - 0.2 end -- midrib groove
  if bu > 0.9 then val = val + 0.08 end
  return val
end

local function ramp(v)
  local i = math.floor(v * 5.6 - 0.6) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return RAMP[i]
end

local mask = {}
for y = 0, H - 1 do mask[y] = {} end
local petals = Image(W, H, ColorMode.RGB)
for y = 0, H - 1 do for x = 0, W - 1 do
  local v = petalAt(x, y)
  if v then
    mask[y][x] = true
    local c = ramp(v)
    petals:putPixel(x, y, app.pixelColor.rgba(c[1], c[2], c[3], 255))
  end
end end
local o = app.pixelColor.rgba(OUTL[1], OUTL[2], OUTL[3], 255)
for y = 0, H - 1 do for x = 0, W - 1 do
  if not mask[y][x] then
    for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
      local m = mask[y + d[2]]
      if m and m[x + d[1]] then petals:putPixel(x, y, o) break end
    end
  end
end end

-- centre: domed disc, orange-gold, one spec, seed dots, dark ring
local RC = {"#6e3a14","#a8591a","#d98a1c","#f0ae2a","#f8cf5a"}
local centre = Image(W, H, ColorMode.RGB)
local function hexpx(h) local c = Color{r=tonumber(h:sub(2,3),16),g=tonumber(h:sub(4,5),16),b=tonumber(h:sub(6,7),16)}; return app.pixelColor.rgba(c.red,c.green,c.blue,255) end
local inkpx = app.pixelColor.rgba(0x2b,0x1c,0x26,255)
for y = 0, H - 1 do for x = 0, W - 1 do
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local r = math.sqrt(dx * dx + dy * dy)
  if r <= 6.4 then
    local l = (-dx * 0.6 - dy * 0.8) / 6.4 -- upper-left lit
    local val = 0.5 + 0.38 * l - 0.15 * (r / 6.4) ^ 2
    local i = math.floor(val * 5.5) + 1
    if i < 1 then i = 1 elseif i > 5 then i = 5 end
    if ((x * 7 + y * 13) % 5 == 0) and r > 2 and r < 5.5 and i > 1 then i = i - 1 end -- floret pits
    centre:putPixel(x, y, hexpx(RC[i]))
  elseif r <= 7.5 then
    centre:putPixel(x, y, inkpx)
  end
end end
centre:putPixel(29, 29, hexpx("#fbe89a"))
centre:putPixel(30, 29, hexpx("#fbe89a"))
centre:putPixel(29, 30, hexpx("#fbe89a"))

-- full preview: petals * tint(255,244,200)*1.25 then centre
local full = Image(W, H, ColorMode.RGB)
local T = {255, 244, 200}
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

local function save(img, name)
  local s = Sprite(W, H, ColorMode.RGB)
  s.cels[1].image:drawImage(img, Point(0, 0))
  s:saveCopyAs(out .. name .. ".png")
  s:close()
end
save(petals, "daisy-petals")
save(centre, "daisy-centre")
save(full, "daisy")

local s = Sprite(W, H, ColorMode.RGB)
s.layers[1].name = "petals"
s.cels[1].image:drawImage(petals, Point(0, 0))
local l2 = s:newLayer(); l2.name = "centre"
s:newCel(l2, 1, centre, Point(0, 0))
s:saveAs(out .. "daisy.aseprite")

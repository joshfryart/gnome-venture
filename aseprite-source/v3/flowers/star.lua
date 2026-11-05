-- star (flowers P2_F1)
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
local N = 5
local function petalAt(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local best, bd
  for i = 0, N - 1 do
    local a = math.rad(i * 72 - 90)
    local ca, sa = math.cos(a), math.sin(a)
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    local len = 27.5
    if u >= 1 and u <= len then
      local t = u / len
      local w
      if t < 0.36 then w = 3.0 + (6.4 - 3.0) * (t / 0.36) else w = 6.4 * ((1 - t) / 0.64) ^ 0.95 end
      if math.abs(v) <= w then
        local s = math.abs(v) / math.max(w, 0.1)
        if not best or s < best then best = s; bd = {t = t, v = v, w = w} end
      end
    end
  end
  if not bd then return nil end
  -- folded petal: one half bright, the other in shade (pinwheel)
  local val
  if bd.v < 0 then val = 0.82 - 0.10 * bd.t - 0.06 * math.abs(bd.v) / bd.w
  else val = 0.52 + 0.08 * bd.t - 0.04 * math.abs(bd.v) / bd.w end
  if math.abs(bd.v) < 0.55 and bd.t > 0.12 and bd.t < 0.9 then val = 0.34 end -- crease
  if bd.t < 0.2 then val = val - 0.14 end
  return ramp(val)
end
local petals = build(petalAt)

local centre = Image(W, H, ColorMode.RGB)
-- stamens
local function stamen(ang, len, ar)
  local a = math.rad(ang)
  local ca, sa = math.cos(a), math.sin(a)
  for r = 3, len do
    put(centre, math.floor(CX + r * ca), math.floor(CY + r * sa), "#f3e2a0")
  end
  local ex, ey = math.floor(CX + len * ca), math.floor(CY + len * sa)
  for dy = -ar, ar do for dx = -ar, ar do
    if dx * dx + dy * dy <= ar * ar + 0.8 then
      local c = "#c4472a"
      if dx + dy < 0 then c = "#e87a3c" elseif dx + dy > 0 then c = "#8a2a1a" end
      put(centre, ex + dx, ey + dy, c)
    end
  end end
end
for i = 0, 4 do
  local ln, ar = 10, 1
  if i == 3 then ln, ar = 15, 2 end -- quirk: one long stamen with a big anther
  stamen(i * 72 - 54, ln, ar)
end
-- domed pistil disc
local PC = {"#a8591a", "#d98a1c", "#f0ae2a", "#f8cf5a"}
for y = 0, H - 1 do for x = 0, W - 1 do
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local r = math.sqrt(dx * dx + dy * dy)
  if r <= 4.6 then
    local l = (-dx * 0.6 - dy * 0.8) / 4.6
    local val = 0.5 + 0.4 * l - 0.12 * (r / 4.6) ^ 2
    local i = math.floor(val * 4.4) + 1
    if i < 1 then i = 1 elseif i > 4 then i = 4 end
    put(centre, x, y, PC[i])
  end
end end
put(centre, 30, 30, "#fbe89a"); put(centre, 31, 30, "#fbe89a"); put(centre, 30, 31, "#fbe89a")
finish("star", petals, centre, true)

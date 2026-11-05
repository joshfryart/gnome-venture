-- rose (flowers P2_F0)
local out = app.params["out"] or "./"
local W, H = 64, 64
local RAMP = { {96,96,98}, {126,126,128}, {154,154,156}, {182,182,184}, {206,206,204} }
local OUTL = {58,58,60}
local function rgba(c) return app.pixelColor.rgba(c[1], c[2], c[3], 255) end
local function hex(h) return app.pixelColor.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
local petals = Image(W, H, ColorMode.RGB)
local centre = Image(W, H, ColorMode.RGB)
local function ramp(v)
  local i = math.floor(v * 5.6 - 0.6) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return RAMP[i]
end
local function hash(x, y, s) local n = math.sin(x * 127.1 + y * 311.7 + s * 74.7) * 43758.5453; return n - math.floor(n) end
-- a layer is a table key->val; blade adds a petal along a quadratic bezier spine
local function newLayer() return {} end
local function blade(L, P0, P1, P2, wm, opt)
  opt = opt or {}
  local wfn = opt.wfn or function(t) return math.sqrt(math.max(0, math.sin(math.pi * t ^ 0.75))) end
  local tmp = {}
  for k = 0, 250 do
    local t = k / 250; local mt = 1 - t
    local x = mt*mt*P0[1] + 2*mt*t*P1[1] + t*t*P2[1]
    local y = mt*mt*P0[2] + 2*mt*t*P1[2] + t*t*P2[2]
    local dx = 2*mt*(P1[1]-P0[1]) + 2*t*(P2[1]-P1[1])
    local dy = 2*mt*(P1[2]-P0[2]) + 2*t*(P2[2]-P1[2])
    local d = math.sqrt(dx*dx + dy*dy); if d < 1e-6 then d = 1 end
    local nx, ny = -dy / d, dx / d
    local w = wfn(t) * wm
    for j = -25, 25 do
      local si = j / 25
      local px, py = math.floor(x + nx * si * w), math.floor(y + ny * si * w)
      local key = py * 100 + px
      if not tmp[key] or math.abs(si) < tmp[key].a then tmp[key] = { a = math.abs(si), t = t, s = si, nx = nx, ny = ny, w = w, px = px, py = py } end
    end
  end
  for key, r in pairs(tmp) do
    local sg = r.s >= 0 and 1 or -1
    local lit = (r.nx * sg) * -0.7 + (r.ny * sg) * -0.7
    local val = 0.64 + 0.26 * lit * math.min(1, r.a * 1.4 + 0.15) + 0.14 * r.t - 0.14 * (1 - r.t) ^ 2
    if opt.mid and r.a * r.w < 0.6 and r.t > 0.1 and r.t < 0.8 then val = val - 0.2 end
    if opt.adj then val = val + opt.adj(r.t, r.s, r.w, r.px, r.py) end
    L[key] = val
  end
end
local function commit(L)
  local keys = {}
  for key, v in pairs(L) do
    local px, py = key % 100, math.floor(key / 100)
    if px >= 0 and px < W and py >= 0 and py < H then
      local c = ramp(v); petals:putPixel(px, py, rgba(c)); keys[#keys + 1] = {px, py}
    end
  end
  local o = rgba(OUTL)
  for _, p in ipairs(keys) do
    for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
      local nx, ny = p[1] + d[1], p[2] + d[2]
      if nx >= 0 and nx < W and ny >= 0 and ny < H and L[ny * 100 + nx] == nil then petals:putPixel(nx, ny, o) end
    end
  end
end
local function cput(x, y, h) if x >= 0 and x < W and y >= 0 and y < H then centre:putPixel(x, y, hex(h)) end end
local function cring()
  local ink = app.pixelColor.rgba(0x2b, 0x1c, 0x26, 255)
  local add = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    if app.pixelColor.rgbaA(centre:getPixel(x, y)) == 0 then
      for _, d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 0 and nx < W and ny >= 0 and ny < H and app.pixelColor.rgbaA(centre:getPixel(nx, ny)) > 0 then add[#add + 1] = {x, y} break end
      end
    end
  end end
  for _, p in ipairs(add) do centre:putPixel(p[1], p[2], ink) end
end
local function finish(name)
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
    s:saveCopyAs(out .. n .. ".png"); s:close()
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
local function pol(a, d) local r = math.rad(a); return { CX + math.cos(r) * d, CY + math.sin(r) * d } end
local function ring(n, off, d0, d1, wm, curl, opt)
  for i = 0, n - 1 do
    local a = off + i * 360 / n
    local p0, p2 = pol(a, d0), pol(a, d1)
    local p1 = pol(a + curl, (d0 + d1) / 2)
    local L = newLayer()
    blade(L, p0, p1, p2, wm, opt and opt(i))
    commit(L)
  end
end
-- outer five, scalloped; petal 1 has a curled-back pale lip (quirk)
ring(5, -90, 3, 27, 10.5, 0, function(i)
  if i == 1 then return { adj = function(t, s, w) if t > 0.8 then return 0.3 end return 0 end } end
  return { adj = function(t, s, w) if t > 0.9 then return 0.06 end return 0 end }
end)
-- middle five, offset
ring(5, -54, 2, 17, 6.8, 12, nil)
-- inner cupped bud
ring(4, -70, 0, 10, 4.6, 18, nil)
-- centre: golden swirl core
for y = 0, H - 1 do for x = 0, W - 1 do
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local r = math.sqrt(dx*dx + dy*dy)
  if r <= 3.6 then
    local th = math.atan(dy, dx) / (2 * math.pi)
    local ph = (r * 0.9 - th) % 1
    local lit = (-dx * 0.7 - dy * 0.7) / 3.6
    local h = "#d49a40"
    if ph < 0.42 then h = "#7a3b1c" elseif lit > 0.3 then h = "#f0c868" end
    cput(x, y, h)
  end
end end
cput(30, 30, "#fbe6a0")
cring()
finish("rose")

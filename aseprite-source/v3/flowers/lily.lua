-- lily (flowers P2_F0)
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
local lw = function(t) return math.sin(math.pi * (t ^ 0.8)) ^ 0.7 end
local function tepal(a, len, wm, bend, tipLit, seed)
  local L = newLayer()
  blade(L, pol(a, 2), pol(a + bend, len * 0.55), pol(a + bend * 0.2, len), wm, { mid = true, wfn = lw,
    adj = function(t, s, w, px, py)
      local d = 0
      if tipLit and t > 0.72 then d = d + 0.24 end
      if t > 0.18 and t < 0.6 and math.abs(s) < 0.8 and hash(px, py, seed) > 0.9 and ((px + py) % 2 == 0) then d = d - 0.5 end
      return d
    end })
  commit(L)
end
-- outer three then inner three on top; first inner tepal curls its tip (quirk)
for i = 0, 2 do tepal(-90 + i * 120, 26, 6.2, 5, false, i) end
for i = 0, 2 do tepal(-30 + i * 120, 24, 5.6, -6, i == 0, 5 + i) end
-- centre: six stamens + longer pistil
local function line(x0, y0, x1, y1, h)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for k = 0, n do cput(math.floor(x0 + (x1 - x0) * k / n + 0.5), math.floor(y0 + (y1 - y0) * k / n + 0.5), h) end
end
for i = 0, 5 do
  local a = math.rad(-90 + i * 60 + 18)
  local ex, ey = CX + math.cos(a) * 8, CY + math.sin(a) * 8
  line(CX, CY, ex, ey, "#e0d49a")
  local ax, ay = math.floor(ex + 0.5), math.floor(ey + 0.5)
  for dy = -1, 1 do for dx = -1, 1 do if math.abs(dx) + math.abs(dy) < 3 then cput(ax + dx, ay + dy, (dx == -1 or dy == -1) and "#b0522a" or "#7a2e1c") end end end
  cput(ax - 1, ay - 1, "#e69a5a")
end
for dy = -1, 1 do for dx = -1, 1 do cput(CX + dx, CY + dy, (dx < 0 and dy < 0) and "#d8e68c" or "#9fc45a") end end
cput(31, 31, "#f2f8c0")
cring()
finish("lily")

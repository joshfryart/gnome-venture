-- tulip (flowers P2_F0)
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
local function pet(P0, P1, P2, wm, opt) local L = newLayer(); blade(L, P0, P1, P2, wm, opt); commit(L) end
local tipRound = function(t) return math.sqrt(math.max(0, math.sin(math.pi * t ^ 0.7))) end
-- back petals
pet({32,48}, {32,30}, {32,9}, 7, { mid = true })
pet({30,50}, {13,36}, {18,9}, 8, { mid = true })
pet({34,50}, {51,38}, {45,11}, 8, { mid = true })
-- stamens would sit here visually; drawn in the centre layer
-- front centre petal with a pale flame streak (quirk) and a small tip notch
pet({32,57}, {31,40}, {32,25}, 9, { wfn = function(t) return math.sqrt(math.max(0, math.sin(math.pi * t ^ 0.55))) end,
  adj = function(t, s, w) if math.abs(s * w) < 1.1 and t > 0.3 and t < 0.88 then return 0.2 end return 0 end })
pet({31,55}, {11,43}, {20,16}, 9.5, { adj = function(t, s, w) if math.abs(s) < 0.1 and t > 0.15 and t < 0.8 then return -0.16 end return 0 end })
pet({33,55}, {53,43}, {44,17}, 9.5, { adj = function(t, s, w) if math.abs(s) < 0.1 and t > 0.15 and t < 0.8 then return -0.16 end return 0 end })
-- centre: pistil and two anthers peeking over the front petal
for y = 14, 25 do cput(31, y, "#9fc45a"); cput(32, y, "#c8de82") end
for _, p in ipairs{{30,13},{31,12},{32,12},{33,13}} do cput(p[1], p[2], "#9fc45a") end
cput(32, 13, "#e6f2b0")
for y = 17, 25 do cput(27, y, "#e8d08a"); cput(37, y, "#e8d08a") end
for y = 12, 17 do for x = 26, 28 do cput(x, y, (x == 26) and "#6a3a52" or "#4a2a3a") end end
for y = 12, 17 do for x = 36, 38 do cput(x, y, (x == 36) and "#6a3a52" or "#4a2a3a") end end
cput(26, 12, "#9a6a82")
cput(36, 12, "#9a6a82")
cring()
finish("tulip")

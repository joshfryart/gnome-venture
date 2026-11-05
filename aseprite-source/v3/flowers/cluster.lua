-- cluster (flowers P2_F3)
local out = app.params["out"] or "./"
local W, H = 64, 64
local OUTL = {58,58,60}
local RAMP = { {96,96,98}, {126,126,128}, {154,154,156}, {182,182,184}, {206,206,204} }
local rgba = app.pixelColor.rgba
local ID, VAL = {}, {}
for y = 0, H - 1 do ID[y] = {}; VAL[y] = {} end
local nid = 0
-- paint an oriented ellipse petal; dx,dy = axis direction; shape pow for pointiness
local function ell(cx, cy, rx, ry, dx, dy, opt)
  opt = opt or {}
  nid = nid + 1
  local l = math.sqrt(dx * dx + dy * dy); dx, dy = dx / l, dy / l
  local R = math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    if x >= 0 and x < W and y >= 0 and y < H then
      local px, py = x + 0.5 - cx, y + 0.5 - cy
      local u = px * dx + py * dy
      local v = -px * dy + py * dx
      local uu = u / rx
      if opt.point and uu > 0 then v = v / (1 - 0.55 * uu) end
      local d = math.sqrt(uu * uu + (v / ry) ^ 2)
      if d <= 1 then
        local ex, ey = px / R, py / R
        local lit = -(ex * 0.7 + ey * 0.7)
        local val = 0.6 + 0.34 * lit - 0.2 * d * d + (opt.bias or 0)
        if opt.groove and math.abs(v) < 0.7 and uu > -0.3 and uu < 0.8 then val = val - 0.14 end
        if d > 0.86 and lit < -0.1 then val = val - 0.08 end
        ID[y][x] = nid; VAL[y][x] = val
      end
    end
  end end
end
local function ramp(v)
  local i = math.floor(v * 5.6 - 0.6) + 1
  if i < 1 then i = 1 elseif i > 5 then i = 5 end
  return RAMP[i]
end
local function build()
  local petals = Image(W, H, ColorMode.RGB)
  local mask = {}
  for y = 0, H - 1 do mask[y] = {} end
  local D4 = {{1,0},{-1,0},{0,1},{0,-1}}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local id = ID[y][x]
    if id then
      mask[y][x] = true
      local c = ramp(VAL[y][x])
      for _, d in ipairs(D4) do
        local r = ID[y + d[2]]
        local n = r and r[x + d[1]]
        if n and n > id then c = RAMP[1] break end
      end
      petals:putPixel(x, y, rgba(c[1], c[2], c[3], 255))
    end
  end end
  local o = rgba(OUTL[1], OUTL[2], OUTL[3], 255)
  for y = 0, H - 1 do for x = 0, W - 1 do
    if not mask[y][x] then
      for _, d in ipairs(D4) do
        local m = mask[y + d[2]]
        if m and m[x + d[1]] == true then petals:putPixel(x, y, o) mask[y][x] = "o" break end
      end
    end
  end end
  return petals, mask
end
local function hexpx(h) return rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
local function finish(name, petals, centre)
  local full = Image(W, H, ColorMode.RGB)
  local T = {217, 119, 58}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local p = petals:getPixel(x, y)
    if app.pixelColor.rgbaA(p) > 0 then
      local function t(ch, k) return math.min(255, math.floor(ch * k / 255 * 1.25 + 0.5)) end
      full:putPixel(x, y, rgba(t(app.pixelColor.rgbaR(p), T[1]), t(app.pixelColor.rgbaG(p), T[2]), t(app.pixelColor.rgbaB(p), T[3]), 255))
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
local function hash(i) return (math.sin(i * 12.9898) * 43758.5453) % 1 end
local florets = {}
for k = 0, 5 do
  local a = math.rad(30 + k * 60)
  florets[#florets + 1] = {32 + 15.5 * math.cos(a), 32 + 15.5 * math.sin(a)}
end
table.sort(florets, function(p, q) return p[2] < q[2] end)
florets[#florets + 1] = {32, 32}
local centres = {}
for i, f in ipairs(florets) do
  local rot = hash(i) * math.pi / 2
  local rx, ry = 5.6, 4.6
  local missing = (i == 3) and 2 or -1 -- quirk: one floret lost a petal
  for p = 0, 3 do
    if p ~= missing then
      local a = rot + p * math.pi / 2
      local dx, dy = math.cos(a), math.sin(a)
      ell(f[1] + dx * 4.4, f[2] + dy * 4.4, rx, ry, dx, dy, {bias = (i == 7) and 0.06 or 0})
    end
  end
  centres[#centres + 1] = {f[1], f[2], missing >= 0, rot}
end
local petals, mask = build()
local centre = Image(W, H, ColorMode.RGB)
for _, c in ipairs(centres) do
  local x, y = math.floor(c[1] - 0.5), math.floor(c[2] - 0.5)
  for dy = 0, 2 do for dx = 0, 2 do
    local col = "#c6c840"
    if dx == 0 and dy == 0 then col = "#f0ec8a"
    elseif dx == 2 or dy == 2 then col = "#8a9a2a" end
    if not (dx == 0 and dy == 2) and not (dx == 2 and dy == 0) then centre:putPixel(x + dx, y + dy, hexpx(col)) end
  end end
  if c[3] then -- green sepal peeking where the petal is missing
    local a = c[4] + 2 * math.pi / 2
    local sx, sy = math.floor(c[1] + math.cos(a) * 4.5), math.floor(c[2] + math.sin(a) * 4.5)
    for _, o in ipairs{{0,0,"#5ea044"},{1,0,"#3a7030"},{0,1,"#3a7030"},{1,1,"#2f5a2a"}} do
      centre:putPixel(sx + o[1], sy + o[2], hexpx(o[3]))
    end
  end
end
finish("cluster", petals, centre)

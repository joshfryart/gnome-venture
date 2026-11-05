-- spike (flowers P2_F3)
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
-- floret stack: florets get smaller toward the tip; lower ones overlap upper ones
local SX = 32
local ys = {}
for k = 0, 8 do ys[#ys + 1] = 50 - k * 4.9 end
local fl = {}
-- tip buds (curl right: quirk)
ell(35.8, 9.6, 1.9, 1.9, 1, 0)
ell(33.6, 11.2, 2.3, 2.1, 1, 0)
ell(31.6, 13.2, 2.6, 2.3, 1, 0)
for k = #ys, 1, -1 do
  local y = ys[k]
  local s = 1 - (k - 1) * 0.085
  local rx, ry = 6.6 * s, 3.1 * s
  local off = 0.55 * rx
  local up = (k % 2 == 0) and 0.55 or 0.35
  if k <= 7 then
    ell(SX - off, y - 0.8, rx, ry, -1, -up, {point = true, groove = true})
    ell(SX + off, y - 0.8, rx, ry, 1, -up, {point = true, groove = true})
  end
  fl[#fl + 1] = {y, s}
end
-- quirk: one lone petal drooping from a lower floret
ell(SX - 6, 44.5, 2.2, 4.4, 0.35, 1, {point = true})
local petals, mask = build()

local centre = Image(W, H, ColorMode.RGB)
local STEM = {"#2f5a2a", "#3f7a34", "#5ea044"}
-- stem only where no petal covers
for y = 6, 59 do for x = SX - 2, SX + 1 do
  if not mask[y][x] then
    local i = (x == SX - 2) and 1 or ((x == SX - 1) and 3 or 2)
    if x == SX + 1 then i = 1 end
    centre:putPixel(x, y, hexpx(STEM[i]))
  end
end end
-- stem is 2px (SX-1,SX); outline ring for stem pixels outside petal outline
local inkp = rgba(0x2b, 0x1c, 0x26, 255)
for y = 0, H - 1 do for x = 0, W - 1 do centre:putPixel(x, y, centre:getPixel(x, y)) end end
local sm = {}
for y = 0, H - 1 do sm[y] = {} end
for y = 6, 59 do for x = SX - 1, SX do if not mask[y][x] then sm[y][x] = true end end end
for y = 0, H - 1 do for x = 0, W - 1 do centre:putPixel(x, y, rgba(0,0,0,0)) end end
for y = 6, 59 do for x = SX - 1, SX do
  if sm[y][x] then centre:putPixel(x, y, hexpx(x == SX - 1 and "#5ea044" or "#3a7030")) end
end end
for y = 5, 60 do for x = SX - 2, SX + 1 do
  if not sm[y][x] and not mask[y][x] then
    local n = (sm[y][x-1]) or (sm[y][x+1]) or (sm[y-1] and sm[y-1][x]) or (sm[y+1] and sm[y+1][x])
    if n then centre:putPixel(x, y, inkp) end
  end
end end
-- keel/stamen dots on each floret
for _, f in ipairs(fl) do
  local y, s = f[1], f[2]
  if s > 0.5 then
    local yy = math.floor(y - 1)
    centre:putPixel(SX - 1, yy, hexpx("#f4e27a"))
    centre:putPixel(SX, yy, hexpx("#d9a52a"))
    centre:putPixel(SX - 1, yy + 1, hexpx("#d9a52a"))
    centre:putPixel(SX, yy + 1, hexpx("#8a5a1c"))
  end
end
-- bud tip hint
centre:putPixel(35, 9, hexpx("#d9a52a"))
centre:putPixel(33, 11, hexpx("#d9a52a"))
finish("spike", petals, centre)

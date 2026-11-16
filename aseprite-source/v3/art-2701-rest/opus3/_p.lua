-- _p.lua: copy of art-2701-opus/wear/_o.lua (sewn-patch painter + icon I/O) for the opus2 patch icons. Reads game/assets/img/ph read-only.
-- Reads base art from game/assets/img (read-only). Pixel tables: key y*W+x -> "#rrggbb".
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = {}
O.DIR = DIR
O.OUT = app.params.out or (DIR .. "/")
O.GN = DIR .. "/../../../../game/assets/img/gnome25/"
O.PH = DIR .. "/../../../../game/assets/img/ph/"
O.INK = "#2b1c26"
O.W, O.H, O.N = 64, 80, 8
local W, H = 64, 80
O.BODY = { "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
-- frame tables (= gnome-dir.lua / gnome-wear.py): idle 1-2, walk 3-8
O.F = { { bob=0, ly=0, ry=0, arm=0 }, { bob=1, ly=0, ry=0, arm=0 },
  { bob=0, ly=0, ry=-1, arm=-2 }, { bob=-1, ly=0, ry=-2, arm=-1 }, { bob=0, ly=0, ry=-3, arm=0 },
  { bob=0, ly=-1, ry=0, arm=2 }, { bob=-1, ly=-2, ry=0, arm=1 }, { bob=0, ly=-3, ry=0, arm=0 } }
O.SWAY = { 0, 0, 0, -1, -1, 0, 1, 1 }   -- cloth lags the body one frame
local pc = app.pixelColor
local cache = {}
function O.img(path)
  if not cache[path] then cache[path] = Image{ fromFile = path } end
  return cache[path]
end
function O.layer(view, name) return O.img(O.GN .. view .. "-" .. name .. ".png") end
-- mask (set of keys) of the named base layers in frame f (0-based)
function O.mask(view, names, f)
  local m = {}
  for _, n in ipairs(names) do
    local im = O.layer(view, n)
    for y = 0, H - 1 do for x = 0, W - 1 do
      if pc.rgbaA(im:getPixel(f * W + x, y)) > 0 then m[y * W + x] = true end
    end end
  end
  return m
end
function O.K(x, y) return y * W + x end
-- char map painter: rows of chars, map char -> hex; '.' or ' ' skipped
function O.paint(px, rows, x0, y0, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      local col = map[ch]
      if col then px[(y0 + j - 1) * W + x0 + i - 1] = col end
    end
  end
end
-- 1px ink ring where the layer meets empty space (not over the gnome); ink_over = base pixels to hide
function O.finish(px, body, ink_over, w, h)
  w, h = w or W, h or H
  local ring = {}
  for k in pairs(px) do
    local x, y = k % w, k // w
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      local nx, ny = x + d[1], y + d[2]
      local nk = ny * w + nx
      if nx >= 0 and nx < w and ny >= 0 and ny < h and not px[nk] and not (body and body[nk]) then ring[nk] = true end
    end
  end
  for k in pairs(ring) do px[k] = O.INK end
  if ink_over then for k in pairs(ink_over) do if not px[k] then px[k] = O.INK end end end
  return px
end
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
O.rgba = rgba
function O.hexAt(im, x, y)
  local v = im:getPixel(x, y)
  if pc.rgbaA(v) == 0 then return nil end
  return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
end
local function check(img)
  local semi, bw = 0, 0
  for it in img:pixels() do
    local v = it()
    local a = pc.rgbaA(v)
    if a > 0 and a < 255 then semi = semi + 1 end
    if a == 255 then
      local r, g, b = pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)
      if (r == 0 and g == 0 and b == 0) or (r == 255 and g == 255 and b == 255) then bw = bw + 1 end
    end
  end
  assert(semi == 0 and bw == 0, "unclean: semi=" .. semi .. " bw=" .. bw)
end
-- save a strip: frames = list of px tables (64x80 each) -> <name>.aseprite (one 512x80 cel) + <name>.png
function O.saveStrip(name, frames)
  local img = Image(W * #frames, H, ColorMode.RGB)
  img:clear()
  for f, px in ipairs(frames) do
    for k, hx in pairs(px) do
      local x, y = k % W, k // W
      if x >= 0 and x < W and y >= 0 and y < H then img:drawPixel((f - 1) * W + x, y, rgba(hx)) end
    end
  end
  check(img)
  local spr = Sprite(W * #frames, H, ColorMode.RGB)
  spr.layers[1].name = name
  spr.cels[1].image = img
  spr:saveAs(O.OUT .. name .. ".aseprite")
  spr:saveCopyAs(O.OUT .. name .. ".png")
  print("saved " .. name)
end
-- icon: start from a game PNG (ph/<base>.png) as a px table (64 wide)
function O.loadIcon(base)
  local im = O.img(O.PH .. base .. ".png")
  local px = {}
  for y = 0, im.height - 1 do for x = 0, im.width - 1 do
    local h = O.hexAt(im, x, y)
    if h then px[y * 64 + x] = h end
  end end
  return px, im.width, im.height
end
function O.saveIcon(name, px, w, h)
  local img = Image(w, h, ColorMode.RGB)
  img:clear()
  for k, hx in pairs(px) do img:drawPixel(k % w, k // w, rgba(hx)) end
  check(img)
  local HP = dofile(DIR .. "/../../lib/hp.lua")
  HP.report(img) HP.assertClean(img)
  local spr = Sprite(w, h, ColorMode.RGB)
  spr.layers[1].name = name
  spr.cels[1].image = img
  spr:saveAs(O.OUT .. name .. ".aseprite")
  spr:saveCopyAs(O.OUT .. name .. ".png")
  print("saved " .. name)
end
-- sewn cloth patch on a 64-wide icon px table.
-- o = { x0,y0,x1,y1, cloth = function(i,j,zone) -> hex (zone 1 lit, 2 mid, 3 shade), edge = {lit,mid,shade} hems,
--       edgeFn = optional function(i,j,zone) for the hem instead of edge, thread = hex, shadow = function(hex) -> darker hex of the base under it, skip = set of "i,j" corner cells left off }
function O.patch(px, o)
  local w = o.x1 - o.x0 + 1
  local function zone(i) if i < w * 0.3 then return 1 elseif i > w * 0.72 then return 3 end return 2 end
  local cells = {}
  for y = o.y0, o.y1 do for x = o.x0, o.x1 do
    local i, j = x - o.x0, y - o.y0
    if not (o.skip and o.skip[i .. "," .. j]) then cells[y * 64 + x] = { i, j } end
  end end
  -- contact shadow on the base, 1 px below and right of the patch
  for k, q in pairs(cells) do
    for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 } } do
      local nk = k + d[1] + d[2] * 64
      if not cells[nk] and px[nk] and px[nk] ~= O.INK then px[nk] = o.shadow(px[nk]) end
    end
  end
  for k, q in pairs(cells) do
    local i, j = q[1], q[2]
    local edge = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if not cells[k + d[1] + d[2] * 64] then edge = true end
    end
    px[k] = edge and (o.edgeFn and o.edgeFn(i, j, zone(i)) or o.edge[zone(i)]) or o.cloth(i, j, zone(i))
  end
  -- whip stitches: thread ticks on the base just outside the hem, every other pixel (top, left, bottom, right)
  local ticks = {}
  for k, q in pairs(cells) do
    local i, j = q[1], q[2]
    local x, y = k % 64, k // 64
    if (i + j) % 2 == 0 then
      for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
        local nk = k + d[1] + d[2] * 64
        if not cells[nk] and px[nk] and px[nk] ~= O.INK and not (o.noStitch and o.noStitch(x + d[1], y + d[2])) then ticks[nk] = true end
      end
    end
  end
  for k in pairs(ticks) do px[k] = o.thread end
  return cells
end
return O

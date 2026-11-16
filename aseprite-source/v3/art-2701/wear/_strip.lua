-- _strip.lua: shared helpers to redraw one 512x80 gnome25 wearable layer (8 frames of 64x80) in Aseprite Lua.
-- Reads the base rig layers from game/assets/img/gnome25 (read-only) so the wearable lines up with the body frame by frame.
-- Same rules as gnome-wear.py: 1 px ink where the wearable meets empty space / ground shadow, none where it meets the gnome.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = {}
S.OUT = app.params.out or (DIR .. "/")
S.GN = DIR .. "/../../../../game/assets/img/gnome25/"
S.INK = "#2b1c26"
local W, H, N = 64, 80, 8
S.W, S.H, S.N = W, H, N
S.BODY = { "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
-- frame tables copied from gnome-wear.py (= gnome-dir.lua)
S.FB = { { bob=0, ly=0, ry=-1, arm=-2 }, { bob=-1, ly=0, ry=-2, arm=-1 }, { bob=0, ly=0, ry=-3, arm=0 },
         { bob=0, ly=-1, ry=0, arm=2 }, { bob=-1, ly=-2, ry=0, arm=1 }, { bob=0, ly=-3, ry=0, arm=0 } }
S.FRAMES = { { bob=0 }, { bob=1 } }
for _, p in ipairs(S.FB) do S.FRAMES[#S.FRAMES + 1] = p end

local cache = {}
function S.img(view, name)
  local k = view .. "-" .. name
  if not cache[k] then cache[k] = Image{ fromFile = S.GN .. k .. ".png" } end
  return cache[k]
end
local pc = app.pixelColor
function S.alpha(view, name, f, x, y)
  return pc.rgbaA(S.img(view, name):getPixel(f * W + x, y)) > 0
end
function S.hex(view, name, f, x, y)
  local v = S.img(view, name):getPixel(f * W + x, y)
  if pc.rgbaA(v) == 0 then return nil end
  return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
end
function S.mask(view, names, f)
  local m = {}
  for _, n in ipairs(names) do
    for y = 0, H - 1 do for x = 0, W - 1 do if S.alpha(view, n, f, x, y) then m[y * W + x] = true end end end
  end
  return m
end
-- px: table key y*64+x -> hex. Adds the ink ring (not over the body); ink_over: base pixels the layer must hide.
function S.finish(px, body, ink_over)
  local ring = {}
  for k in pairs(px) do
    local x, y = k % W, k // W
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      local nx, ny = x + d[1], y + d[2]
      local nk = ny * W + nx
      if nx >= 0 and nx < W and ny >= 0 and ny < H and not px[nk] and not body[nk] then ring[nk] = true end
    end
  end
  for k in pairs(ring) do px[k] = S.INK end
  if ink_over then for k in pairs(ink_over) do if not px[k] then px[k] = S.INK end end end
  return px
end
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
function S.save(name, frames, note)
  local img = Image(W * N, H, ColorMode.RGB)
  img:clear()
  local nb, tot = 0, 0
  for f, px in ipairs(frames) do
    for k, hx in pairs(px) do
      local x, y = k % W, k // W
      if x >= 0 and x < W and y >= 0 and y < H then img:drawPixel((f - 1) * W + x, y, rgba(hx)) tot = tot + 1 end
    end
  end
  local spr = Sprite(W * N, H, ColorMode.RGB)
  spr.layers[1].name = name
  spr.cels[1].image = img
  spr:saveAs(S.OUT .. name .. ".aseprite")
  spr:saveCopyAs(S.OUT .. name .. ".png")
  print("saved " .. name .. " px=" .. tot)
end
return S

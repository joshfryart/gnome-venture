-- flowers/spike head (Stitched Toy, tintable). Petals neutral grey (tinted at runtime), centre fixed gold.
-- Outputs: spike.png (full), spike-petals.png, spike-centre.png, spike.aseprite (layers petals + centre).
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, close = 0, margin = 0 }

-- neutral grey ramp (no hue); pale=true keeps the lightest umber tone off the lit edge
local GREY = { base = "#d2d2d2", rim = "#e8e8e8", gloss = "#f5f5f5", dot = "#fbfbfb",
               shade = "#a6a6a6", deep = "#7e7e7e", bounce = "#b4b4b4", pale = true }
local CORE = { base = "#9a9a9a", rim = "#b0b0b0", gloss = "#c4c4c4", dot = "#cccccc",
               shade = "#828282", deep = "#686868", bounce = "#8c8c8c", pale = false }

-- SVG (64 box) -> grid: x 1:1, y squeezed 0.88 so the spike sits inside the frame with its outline
local SY, OY = 0.88, 4.0
local function toSvg(x, y) return x + 0.5, (y + 0.5 - OY) / SY + 0.3 end
local function toPx(xs, ys) return xs - 0.5, OY + (ys - 0.3) * SY - 0.5 end

-- rotated ellipse (SVG ellipse cx,cy,rx,ry rotated by deg about px,py), tested in SVG space
local function floret(cx, cy, rx, ry, deg, px, py)
  deg = deg or 0
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  if px then -- centre after rotating about (px,py)
    local dx, dy = cx - px, cy - py
    cx, cy = px + dx*ca - dy*sa, py + dx*sa + dy*ca
  end
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local xs, ys = toSvg(x, y)
    local dx, dy = xs - cx, ys - cy
    local u, v = dx*ca + dy*sa, -dx*sa + dy*ca
    if (u/rx)^2 + (v/ry)^2 <= 1 then m:set(x, y) end
  end end
  return m, cx, cy
end

-- florets in SVG paint order (lower rows first, upper rows overlap them)
local F = {
  {19.5,55,5.4,4.3,-22,19.5,55}, {44.5,55,5.4,4.3,22,44.5,55}, {32,56.5,5.2,4.2,0,nil,nil,"c"},
  {22.01,51.2,5.3,4.3,-22,22.0125,49.8}, {41.99,51.2,5.3,4.3,22,41.9875,49.8},
  {21,44.6,5.2,4.3,-22,21,44.6}, {43,44.6,5.2,4.3,22,43,44.6}, {32,46.1,5,4.2,0,nil,nil,"c"},
  {23.29,40.8,5.1,4.3,-22,23.2875,39.4}, {40.71,40.8,5.1,4.3,22,40.7125,39.4},
  {22.5,34.2,5,4.3,-22,22.5,34.2}, {41.5,34.2,5,4.3,22,41.5,34.2}, {32,35.7,4.8,4.2,0,nil,nil,"c"},
  {24.56,30.4,4.9,4.3,-22,24.5625,29}, {39.44,30.4,4.9,4.3,22,39.4375,29},
  {24,23.8,4.8,4.3,-22,24,23.8}, {40,23.8,4.8,4.3,22,40,23.8}, {32,25.3,4.6,4.2,0,nil,nil,"c"},
  {25.84,20,4.7,4.3,-22,25.8375,18.6}, {38.16,20,4.7,4.3,22,38.1625,18.6},
  {25.5,13.4,4.6,4.3,-22,25.5,13.4}, {38.5,13.4,4.6,4.3,22,38.5,13.4}, {32,14.9,4.4,4.2,0,nil,nil,"c"},
  {27.11,9.6,4.5,4.3,-22,27.1125,8.2}, {36.89,9.6,4.5,4.3,22,36.8875,8.2},
  {32,4.5,3,4.2,0,nil,nil,"t"},
}

-- tapered spike body behind the florets so gaps read as deep petal, not holes
local core = c:poly({ {29,4}, {35,4}, {44,57}, {20,57} })
local all = c:mask()
local ms = {}
for i, f in ipairs(F) do ms[i] = { floret(f[1], f[2], f[3], f[4], f[5], f[6], f[7]) } all:add(ms[i][1]) end
core:clip(all:shrink(1))
c:part(core, CORE, { gloss = false, rim = false, bounce = false, light = all, contact = false })

local centres = {}
for i, f in ipairs(F) do
  local m, cx, cy = ms[i][1], ms[i][2], ms[i][3]
  c:part(m, GREY, { light = all:grow(1), cres = 4 })
  if f[8] == "c" then centres[#centres+1] = { toPx(cx, cy) } end
end

-- petals-only image
local petals = c:image()

-- fixed-colour centre: a gold stamen knot (plus) with an ember heart in each middle floret,
-- and a 1 px stitch tick on the top bud
local GOLD, GOLDS, EMBER, EMBERD = "#f5cf6a", "#e8a317", "#e0501f", "#ae2a2a"
local cen = {}
local function put(x, y, h) cen[#cen+1] = { x, y, h } end
for _, p in ipairs(centres) do
  local x, y = math.floor(p[1] + 0.5), math.floor(p[2] + 1.5)
  put(x, y-1, GOLD); put(x-1, y, GOLD); put(x, y, EMBER); put(x+1, y, GOLDS); put(x, y+1, GOLDS)
end
do local tx, ty = toPx(32, 3.2) tx, ty = math.floor(tx + 0.5), math.floor(ty + 0.5)
  put(tx, ty, GOLD); put(tx, ty+1, GOLDS) end

local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
local centreImg = Image(64, 64, ColorMode.RGB); centreImg:clear(pc.rgba(0,0,0,0))
local full = petals:clone()
for _, q in ipairs(cen) do centreImg:putPixel(q[1], q[2], rgba(q[3])); full:putPixel(q[1], q[2], rgba(q[3])) end

local function savePng(img, path)
  local s = Sprite(64, 64, ColorMode.RGB); s.cels[1].image = img; s:saveCopyAs(path); s:close()
end
pcall(function() app.fs.makeAllDirectories(OUT .. "png") end)
pcall(function() app.fs.makeAllDirectories(OUT .. "aseprite") end)
savePng(full, OUT .. "png/spike.png")
savePng(petals, OUT .. "png/spike-petals.png")
savePng(centreImg, OUT .. "png/spike-centre.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"; spr.cels[1].image = petals
local L2 = spr:newLayer(); L2.name = "centre"
spr:newCel(L2, spr.frames[1], centreImg, Point(0, 0))
spr:saveAs(OUT .. "aseprite/spike.aseprite"); spr:close()
print(GV.report(GV.check(full)))

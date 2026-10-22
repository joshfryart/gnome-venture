-- poppy flower HEAD, Stitched Toy, tintable: petals neutral grey (tinted at runtime), centre fixed warm.
-- Outputs poppy.png (full), poppy-petals.png, poppy-centre.png, poppy.aseprite (layers petals + centre).
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }

-- neutral grey ramps (no hue). front = top pair, back = lower pair (SVG darkens them 14%)
local FRONT = { gloss="#f6f6f6", dot="#fcfcfc", rim="#ebebeb", base="#d8d8d8", bounce="#b4b4b4", shade="#a6a6a6", deep="#7a7a7a" }
local BACK  = { gloss="#dedede", dot="#ececec", rim="#cdcdcd", base="#bababa", bounce="#989898", shade="#8a8a8a", deep="#616161" }

-- ruffled round petal: circle with two small 1 px bites on its outer rim (poppy crinkle)
local function petal(cx, cy, r, bites)
  local m = c:ellipse(cx, cy, r)
  for _, b in ipairs(bites) do m:cut(c:ellipse(b[1], b[2], 1)) end
  return m
end
local bl = petal(22, 41, 14.5, { {8, 47}, {17, 55} })
local br = petal(41, 41, 14.5, { {55, 47}, {46, 55} })
local tl = petal(22, 22, 14.5, { {8, 16}, {17, 8} })
local tr = petal(41, 22, 14.5, { {46, 8}, {55, 16} })
c:build{
  { "bl", bl, BACK,  { gloss = false, pale = true } },
  { "br", br, BACK,  { gloss = false, pale = true } },
  { "tl", tl, FRONT, { gloss = { 13, 12 }, pale = true } },
  { "tr", tr, FRONT, { gloss = { 34, 11 }, pale = true } },
}

-- crinkle creases as stitched dashes (2 on / 1 off) in a darker grey: reads after any tint
local function dash(pts, hex, onlyOn)
  local n, seen = 0, {}
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local s = math.max(math.abs(x1-x0), math.abs(y1-y0))
    for t = 0, s do
      local x, y = math.floor(x0 + (x1-x0)*t/s + 0.5), math.floor(y0 + (y1-y0)*t/s + 0.5)
      local k = c:key(x, y)
      if not seen[k] then
        seen[k] = true
        if n % 3 < 2 and onlyOn:has(x, y) and not c.gl.s[k] then c:px(x, y, hex) end
        n = n + 1
      end
    end
  end
end
local tlv = tl:copy():cut(tr)
dash({ {19, 12}, {21, 17}, {21, 22}, {20, 26} }, "#9c9c9c", tlv)
dash({ {44, 12}, {42, 17}, {42, 22}, {43, 26} }, "#9c9c9c", tr)
local blv = bl:copy():cut(tl):cut(tr)
local brv = br:copy():cut(tl):cut(tr):cut(bl)
dash({ {15, 40}, {20, 39}, {23, 42}, {24, 48} }, "#7e7e7e", blv)
dash({ {48, 40}, {43, 39}, {40, 42}, {39, 48} }, "#7e7e7e", brv)

-- snapshot petal pixels before the fixed centre goes on top
local petalPix = {}
for k, v in pairs(c.pix) do petalPix[k] = v end
local centreKeys = {}
local function mark() for k, v in pairs(c.pix) do if petalPix[k] ~= v then centreKeys[k] = true end end end

-- fixed centre: dark ember-wine blotch ring, 12 stamens with gold anthers, gold seed pod with stitched rays
local WINE = { gloss="#dd3a2a", dot="#f2793a", rim="#ae2a2a", base="#6b1b2c", bounce="#5e2a3a", shade="#4e1626", deep="#35161f" }
local blot = c:ellipse(31.5, 31.5, 6.5)
c:part(blot, WINE, { gloss = false, contact = false })
for i = 0, 11 do
  local a = (i + 0.5) * math.pi / 6
  local ca, sa = math.cos(a), math.sin(a)
  local fx, fy = 31.5 + ca * 7.5, 31.5 + sa * 7.5
  c:px(math.floor(fx + 0.5), math.floor(fy + 0.5), "#35161f")                 -- filament
  local ax, ay = math.floor(31.5 + ca * 9.5), math.floor(31.5 + sa * 9.5)
  c:paint({ "ab", "bd" }, ax, ay, { a = "#f5cf6a", b = "#e8a317", d = "#b8661a" }) -- 2x2 anther, lit upper-left
end
local pod = c:ellipse(31.5, 31.5, 3.5)
c:part(pod, "gold", { flat = true, contact = false, contour = "#35161f" })
-- pod crown: stigma knob + 4 stitched rays (2 on / 1 off from the knob), gloss dot upper-left
c:paint({
  ".r.ss...",
  "........",
  "s..kk..s",
  "s..kk..s",
  "........",
  "...ss...",
}, 28, 29, { r = "#fff1c8", s = "#b8661a", k = "#7a3a14" })
mark()

-- finish (outline, no halo) and split into layers
c:finish()
local function img(filter)
  local im = Image(64, 64, ColorMode.RGB)
  im:clear(app.pixelColor.rgba(0, 0, 0, 0))
  for k, h in pairs(c.pix) do
    local x, y = c:xy(k)
    local v = filter(k, h)
    if v and c:inside(x, y) then
      local r, g, b = tonumber(v:sub(2,3),16), tonumber(v:sub(4,5),16), tonumber(v:sub(6,7),16)
      im:putPixel(x, y, app.pixelColor.rgba(r, g, b, 255))
    end
  end
  return im
end
local full   = img(function(k, h) return h end)
local petals = img(function(k, h) if centreKeys[k] then return petalPix[k] end return h end)
local centre = img(function(k, h) if centreKeys[k] then return h end end)

local function savePng(im, p) local s = Sprite(64, 64, ColorMode.RGB) s.cels[1].image = im s:saveCopyAs(p) s:close() end
pcall(function() app.fs.makeAllDirectories(O .. "png") end)
pcall(function() app.fs.makeAllDirectories(O .. "aseprite") end)
savePng(full,   O .. "png/poppy.png")
savePng(petals, O .. "png/poppy-petals.png")
savePng(centre, O .. "png/poppy-centre.png")
local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"; spr.cels[1].image = petals
local L2 = spr:newLayer(); L2.name = "centre"
spr:newCel(L2, spr.frames[1], centre, Point(0, 0))
spr:saveAs(O .. "aseprite/poppy.aseprite"); spr:close()
print("full   " .. GV.report(GV.check(full)))
print("petals " .. GV.report(GV.check(petals)))
print("centre " .. GV.report(GV.check(centre)))

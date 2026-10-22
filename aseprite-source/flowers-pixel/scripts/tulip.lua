-- Gnome Venture flower head: tulip (Stitched Toy). Petals neutral grey (runtime tint), centre fixed gold/ember.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }

-- neutral grey ramps (no hue) so a multiply tint takes any colour
local front = { base="#c9c9c9", gloss="#f2f2f2", dot="#fafafa", rim="#e0e0e0", shade="#9b9b9b", deep="#6f6f6f", bounce="#ababab", pale=false }
local back  = { base="#a3a3a3", gloss="#d6d6d6", dot="#e6e6e6", rim="#bdbdbd", shade="#7c7c7c", deep="#585858", bounce="#8a8a8a", pale=false }
local ember = { base="#e0501f", gloss="#ffc27a", dot="#ffc27a", rim="#f08a24", shade="#ae2a2a", deep="#6b1b2c", bounce="#b8452f", pale=false }

local DY = 4
local function path(p0, segs)
  local pts = { { p0[1], p0[2] + DY } }
  local x, y = p0[1], p0[2]
  for _, s in ipairs(segs) do
    for i = 1, 12 do
      local t = i / 12; local u = 1 - t
      local px = u*u*u*x + 3*u*u*t*s[1] + 3*u*t*t*s[3] + t*t*t*s[5]
      local py = u*u*u*y + 3*u*u*t*s[2] + 3*u*t*t*s[4] + t*t*t*s[6]
      pts[#pts+1] = { px, py + DY }
    end
    x, y = s[5], s[6]
  end
  return pts
end

local backM = c:poly(path({22,49}, {
  {11,40, 11,21, 17,7}, {23,15, 28,24, 32,29}, {36,24, 41,15, 47,7},
  {53,21, 53,40, 42,49}, {37,53, 27,53, 22,49} }))
local frontM = c:poly(path({32,6}, {
  {41,17, 47,32, 41,46}, {39,51, 25,51, 23,46}, {17,32, 23,17, 32,6} }))
-- round off the pointed tips so they stay at least 2 px wide
backM:add(c:rect(16, 11, 17, 13)); backM:add(c:rect(46, 11, 47, 13))
frontM:add(c:rect(31, 10, 32, 12))

-- stamens peeking out of the cup between the outer tips and the front petal (fixed ember, gold pollen)
local anL = c:ellipse(24, 18.5, 1.5, 1.5)
local anR = c:ellipse(40, 18.5, 1.5, 1.5)

local p = c:build{
  { "back",  backM,  back,  { cres = 5, gloss = false } },
  { "anL",   anL,    ember, { flat = true, contact = false } },
  { "anR",   anR,    ember, { flat = true, contact = false } },
  { "front", frontM, front, { cres = 5, gloss = { 26, 24 } } },
}

-- felt edge stitch on the back cup in light grey (reads after tint), lit side only, skips gloss
do
  local s1, s2 = backM:copy(), backM:shrink(1)
  s1 = backM:shrink(1); s2 = backM:shrink(2)
  s1:each(function(x, y)
    if not s2:has(x, y) and not frontM:has(x, y) and (x + y) % 3 == 0 and x < 30 then
      local col = c:get(x, y)
      if col == back.base or col == back.rim then c:px(x, y, "#d2d2d2") end
    end
  end)
end

-- pollen glints on the anthers
c:px(23, 18, "#f5cf6a"); c:px(39, 18, "#f5cf6a")
-- midrib seam down the front petal: thread gold, 2 on / 1 off (fixed colour group)
c:seam({ {32, 15}, {32, 19}, {33, 26}, {33, 34}, {32, 43} })
-- gold button where the head meets the stem
c:button(31, 50)

local img = c:image()
local t = GV.check(img)
print("full " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0)

-- split: fixed-colour pixels (gold, ember, holes) go to the centre layer, the rest to the petals layer
local pc = app.pixelColor
local fixed = {}
for _, h in ipairs({ "#f5cf6a", "#e8a317", "#8a4a1c", ember.base, ember.rim, ember.shade, ember.deep, ember.bounce, ember.gloss }) do
  fixed[tonumber(h:sub(2), 16)] = true
end
local petals = Image(64, 64, ColorMode.RGB); petals:clear(pc.rgba(0,0,0,0))
local centre = Image(64, 64, ColorMode.RGB); centre:clear(pc.rgba(0,0,0,0))
for it in img:pixels() do
  local v = it()
  if pc.rgbaA(v) > 0 then
    local key = pc.rgbaR(v)*65536 + pc.rgbaG(v)*256 + pc.rgbaB(v)
    if fixed[key] then centre:putPixel(it.x, it.y, v) else petals:putPixel(it.x, it.y, v) end
  end
end

local function savePng(im, path)
  local s = Sprite(64, 64, ColorMode.RGB); s.cels[1].image = im; s:saveCopyAs(path); s:close()
end
pcall(function() app.fs.makeAllDirectories(OUT .. "png") end)
pcall(function() app.fs.makeAllDirectories(OUT .. "aseprite") end)
savePng(img, OUT .. "png/tulip.png")
savePng(petals, OUT .. "png/tulip-petals.png")
savePng(centre, OUT .. "png/tulip-centre.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"; spr.cels[1].image = petals
local lc = spr:newLayer(); lc.name = "centre"
spr:newCel(lc, spr.frames[1], centre, Point(0, 0))
spr:saveAs(OUT .. "aseprite/tulip.aseprite"); spr:close()
print("petals " .. GV.report(GV.check(petals)))
print("centre " .. GV.report(GV.check(centre)))

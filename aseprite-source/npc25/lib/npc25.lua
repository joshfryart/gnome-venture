-- npc25 helpers for Aseprite Lua. Layout: one 512x80 RGBA image per view (8 frames of 64x80 side by side),
-- same as game/assets/img/gnome25/*.png. Hard pixels only (alpha 0 or 255).
local N = {W = 64, H = 80, FRAMES = 8, OUTLINE = "#2b1c26"}

function N.hex(s, a)
  s = s:gsub("#", "")
  return app.pixelColor.rgba(tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16), a or 255)
end

-- ramp {hi,base,shade,deep} (hex strings) -> table of rgba ints
function N.ramp(r)
  return {hi = N.hex(r[1]), base = N.hex(r[2]), shade = N.hex(r[3]), deep = N.hex(r[4])}
end

function N.px(img, x, y, c)
  if x >= 0 and y >= 0 and x < img.width and y < img.height then img:putPixel(x, y, c) end
end
function N.rect(img, x, y, w, h, c)
  for j = 0, h - 1 do for i = 0, w - 1 do N.px(img, x + i, y + j, c) end end
end
-- filled ellipse inside box x,y,w,h
function N.ellipse(img, x, y, w, h, c)
  local cx, cy, rx, ry = x + (w - 1) / 2, y + (h - 1) / 2, w / 2, h / 2
  for j = 0, h - 1 do for i = 0, w - 1 do
    local dx, dy = (x + i - cx) / rx, (y + j - cy) / ry
    if dx * dx + dy * dy <= 1 then N.px(img, x + i, y + j, c) end
  end end
end

-- 1 px outline (4-neighbour) on transparent pixels touching opaque ones
function N.outline(img, color)
  color = color or N.hex(N.OUTLINE)
  local add = {}
  for y = 0, img.height - 1 do for x = 0, img.width - 1 do
    if app.pixelColor.rgbaA(img:getPixel(x, y)) == 0 then
      for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 0 and ny >= 0 and nx < img.width and ny < img.height
           and app.pixelColor.rgbaA(img:getPixel(nx, ny)) ~= 0 then add[#add + 1] = {x, y}; break end
      end
    end
  end end
  for _, p in ipairs(add) do img:putPixel(p[1], p[2], color) end
end

-- offsets for frame f (1..8) from species tables -> {body, head, footL, footR, armL, armR}
function N.offsets(sp, f)
  local t = f <= 2 and sp.idle[f] or sp.walk[f - 2]
  return {body = t[1], head = t[2] or t[1], footL = t[3], footR = t[4], armL = t[5], armR = t[6]}
end

-- set the sprite palette from a list of hex strings
function N.set_palette(spr, hexes)
  local pal = Palette(#hexes)
  for i, h in ipairs(hexes) do
    local c = N.hex(h)
    pal:setColor(i - 1, Color{r = app.pixelColor.rgbaR(c), g = app.pixelColor.rgbaG(c), b = app.pixelColor.rgbaB(c)})
  end
  spr:setPalette(pal)
end

-- build sprite 512x80 with one layer per view; draws every frame via species.draw_figure(img64x80, view, frame, species)
-- then saves <outdir>/<name>-<view>.png each and <outdir>/<name>.aseprite
function N.build(species, outdir, views)
  local spr = Sprite(N.W * N.FRAMES, N.H, ColorMode.RGBA)
  N.set_palette(spr, species.palette_list)
  local first = true
  for _, view in ipairs(views) do
    local layer = first and spr.layers[1] or spr:newLayer()
    first = false
    layer.name = view
    local strip = Image(N.W * N.FRAMES, N.H, ColorMode.RGBA)
    for f = 1, N.FRAMES do
      local fi = Image(N.W, N.H, ColorMode.RGBA)
      species.draw_figure(fi, view, f, species)
      strip:drawImage(fi, Point((f - 1) * N.W, 0))
    end
    spr:newCel(layer, 1, strip, Point(0, 0))
    strip:saveAs(string.format("%s/%s-%s.png", outdir, species.name, view))
  end
  spr:saveAs(string.format("%s/%s.aseprite", outdir, species.name))
  return spr
end

return N

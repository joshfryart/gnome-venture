-- extras/icon master (64x64): app icon. Same concept as the original icon-*.png:
-- red gnome hat over a cream beard with a round salmon nose, on a green badge with a light-green ring.
-- Full-bleed square: cream (#f2e4c0, the halo cream) fills the corners for the opaque apple-touch icon;
-- the transparent icons (512/192) leave the corners empty, like the originals.
-- Writes: aseprite/icon-64.aseprite (master, opaque), png/icon-512.png (8x), png/icon-192.png (3x),
--         png/apple-touch-icon.png (180x180 opaque, 2x centred on cream).
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local BG = "#f2e4c0"

local function draw(withBg)
  local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
  if withBg then c:fill(c:rect(0, 0, 63, 63), BG) end
  -- badge: felt disc (leaf green, the original's deep green) with its own 3-tone outline at the frame
  local disc = c:ellipse(31.5, 31.5, 29.5)
  c:part(disc, "leaf", { cres = 4, gloss = false })
  -- light-green ring (moss), shaded with the disc's light
  local ring = c:ellipse(31.5, 31.5, 26.5):cut(c:ellipse(31.5, 31.5, 24.5))
  c:part(ring, "moss", { outline = false, contour = false, contact = false, gloss = false,
                         light = c:ellipse(31.5, 31.5, 26.5), cres = 3, bounce = false })
  -- gold edge stitch just inside the ring: the badge is a sewn felt patch
  local inner = c:ellipse(31.5, 31.5, 24.5)
  inner:shrink(1):edge():each(function(x, y)
    if (x + y) % 3 == 0 then c:px(x, y, (x + y > 70) and GV.C.goldS or GV.C.gold) end
  end)

  -- gnome
  local hat   = c:poly({ {31, 8}, {33, 8}, {48, 41}, {16, 41} })
  local beard = c:rrect(13, 40, 50, 47, 3):add(c:ellipse(31.5, 46, 12.5, 9):cut(c:rect(0, 0, 63, 44)))
  local nose  = c:ellipse(31.5, 42.5, 5)
  local all = hat:copy():add(beard):add(nose)
  c:outline(all)
  c:part(beard, "cream", { outline = false, gloss = { 16, 42 } })
  c:part(hat,   "red",   { outline = false, cres = 6 })
  c:part(nose,  GV.ramp("#e9a08c"), { outline = false, gloss = { 28, 39 } })
  -- seam down the hat (the original's two-tone split) with a button at its head
  c:seam({ {31, 17}, {31, 39} })
  c:button(30, 12)
  return c
end

local function scaled(src, s, W, H, ox, oy, fill)
  local img = Image(W, H, ColorMode.RGB)
  img:clear(fill or app.pixelColor.rgba(0, 0, 0, 0))
  for y = 0, src.height - 1 do for x = 0, src.width - 1 do
    local v = src:getPixel(x, y)
    if app.pixelColor.rgbaA(v) > 0 then
      for j = 0, s - 1 do for i = 0, s - 1 do img:putPixel(ox + x*s + i, oy + y*s + j, v) end end
    end
  end end
  return img
end
local function write(img, path, opaque)
  local spr = Sprite(img.width, img.height, ColorMode.RGB)
  spr.cels[1].image = img
  if opaque then app.command.BackgroundFromLayer() end -- opaque RGB PNG, like the original apple-touch-icon
  spr:saveCopyAs(path)
  spr:close()
  local t = GV.check(img)
  print(path:match("[^/]+$") .. ": " .. GV.report(t))
end

local opaque = draw(true)
print("master: " .. GV.report(opaque:save(O .. "aseprite/icon-64.aseprite", nil)))
local clear = draw(false):image()
write(scaled(clear, 8, 512, 512, 0, 0), O .. "png/icon-512.png")
write(scaled(clear, 3, 192, 192, 0, 0), O .. "png/icon-192.png")
local r, g, b = 0xf2, 0xe4, 0xc0
write(scaled(opaque:image(), 2, 180, 180, 26, 26, app.pixelColor.rgba(r, g, b, 255)), O .. "png/apple-touch-icon.png", true)

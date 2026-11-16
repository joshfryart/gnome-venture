-- _hb.lua: helpers for the batch4 wear icons (Hearth Pop, 64x64). Copy of the batch3 helper so batch4 stands alone.
-- Each rank icon starts from a finished base PNG (read only) and hand-places
-- pixels on top: fleece tufts for Lined, gold trim and stitching for Fine.
-- Paint only on body pixels (opaque and not ink), so the 1 px ink outline survives.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local H = { HP = HP, DIR = DIR, OUT = (app.params and app.params.out) or (DIR .. "/") }

local INK = app.pixelColor.rgba(0x2b, 0x1c, 0x26, 255)
H.FLEECE = { hi = "#fff4d6", base = "#f0dcb0", shade = "#d1b07e", deep = "#a0774f" }
H.GOLD = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
H.CREAM = "#fff4d6"

local function rgb(hex)
  return app.pixelColor.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255)
end
H.rgb = rgb

function H.load(path) return Image { fromFile = path } end

local function body(img, x, y)
  if x < 0 or y < 0 or x > 63 or y > 63 then return false end
  local v = img:getPixel(x, y)
  return app.pixelColor.rgbaA(v) > 0 and v ~= INK
end
H.body = body

-- paint one body pixel
function H.put(img, x, y, hex)
  if body(img, x, y) then img:putPixel(x, y, rgb(hex)) end
end

-- horizontal run: curly wool, tones cycle by x
function H.fleece(img, x0, x1, y, ramp)
  ramp = ramp or H.FLEECE
  local cyc = { ramp.hi, ramp.base, ramp.base, ramp.shade }
  for x = x0, x1 do H.put(img, x, y, cyc[(x % 4) + 1]) end
end

-- vertical run: tones cycle by y
function H.fleeceV(img, x, y0, y1, ramp)
  ramp = ramp or H.FLEECE
  local cyc = { ramp.hi, ramp.base, ramp.base, ramp.shade }
  for y = y0, y1 do H.put(img, x, y, cyc[(y % 4) + 1]) end
end

-- dashed stitch along a row: `on` px painted, `off` px skipped
function H.dashRow(img, x0, x1, y, hex, on, off)
  on = on or 2; off = off or 1
  for x = x0, x1 do if (x - x0) % (on + off) < on then H.put(img, x, y, hex) end end
end

-- dashed stitch along a column
function H.dashCol(img, x, y0, y1, hex, on, off)
  on = on or 2; off = off or 1
  for y = y0, y1 do if (y - y0) % (on + off) < on then H.put(img, x, y, hex) end end
end

-- a solid run of pixels
function H.hline(img, x0, x1, y, hex) for x = x0, x1 do H.put(img, x, y, hex) end end
function H.vline(img, x, y0, y1, hex) for y = y0, y1 do H.put(img, x, y, hex) end end

-- lowest body pixel per column in [x0, x1]
function H.bottoms(img, x0, x1)
  local t = {}
  for x = x0, x1 do
    for y = 63, 0, -1 do
      if body(img, x, y) then t[x] = y break end
    end
  end
  return t
end

function H.save(img, name)
  local r = HP.report(img, true)
  HP.assertClean(img)
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveAs(H.OUT .. name .. ".aseprite")
  spr:saveCopyAs(H.OUT .. name .. ".png")
  spr:close()
  print(string.format("%s: distinct=%s semi=%s blackWhite=%s", name, tostring(r.distinct), tostring(r.semi), tostring(r.blackWhite)))
end

return H

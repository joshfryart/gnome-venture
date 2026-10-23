-- Aseprite 1.3 Lua API subset used by gvlib, backed by the Python host in aseshim.py (P = host table).
function ASESHIM_INSTALL(P)
  local Image_mt = {}
  Image_mt.__index = function(t, k)
    if k == "width" then return P.width(rawget(t, "h")) elseif k == "height" then return P.height(rawget(t, "h")) end
    return Image_mt[k]
  end
  function Image_mt.clear(self, c) P.clear(self.h, c) end
  function Image_mt.putPixel(self, x, y, c) P.put(self.h, x, y, c) end
  function Image_mt.getPixel(self, x, y) return P.get(self.h, x, y) end
  function Image_mt.pixels(self)
    local w, h, i = P.width(self.h), P.height(self.h), -1
    local it = setmetatable({}, { __call = function(s) return P.get(self.h, s.x, s.y) end })
    return function()
      i = i + 1
      if i >= w * h then return nil end
      it.x = i % w; it.y = i // w
      return it
    end
  end
  function Image(w, h, mode) return setmetatable({ h = P.new_image(w, h) }, Image_mt) end
  ColorMode = { RGB = 1, GRAY = 2, INDEXED = 3 }
  local Sprite_mt = {}
  Sprite_mt.__index = Sprite_mt
  function Sprite(w, h, mode)
    local s = setmetatable({ width = w, height = h, cels = { {} } }, Sprite_mt)
    s.cels[1].image = Image(w, h, mode)
    return s
  end
  function Sprite_mt.saveAs(self, p) P.save_ase(self.cels[1].image.h, p) end
  function Sprite_mt.saveCopyAs(self, p) P.save_png(self.cels[1].image.h, p) end
  function Sprite_mt.close(self) end
  app = { pixelColor = {
      rgba = function(r, g, b, a) return (a << 24) | (b << 16) | (g << 8) | r end,
      rgbaR = function(v) return v & 255 end, rgbaG = function(v) return (v >> 8) & 255 end,
      rgbaB = function(v) return (v >> 16) & 255 end, rgbaA = function(v) return (v >> 24) & 255 end },
    fs = { makeAllDirectories = function(p) P.mkdirs(p) end,
           filePath = function(p) return (tostring(p):gsub("\\", "/"):match("^(.*)/[^/]*$")) or "" end } }
  local real_dofile = dofile
  function dofile(p) return real_dofile(P.fix(p)) end
end

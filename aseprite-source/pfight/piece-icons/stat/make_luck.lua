-- Luck piece icons: builds one layered .aseprite per icon from a pixel spec and
-- exports the game PNG from that same sprite (so source and PNG never drift).
-- Called by make_luck.py:  AppRun -b --script-param spec=<txt> --script-param dest=<.aseprite>
--                                   --script-param png=<png> --script make_luck.lua
-- spec format: first line "S"; then one line per pixel "layer x y rrggbb"
-- layers (bottom -> top): halo (cream rim, 32 px only), ink (1 px outline + ink detail), art
local f = assert(io.open(app.params.spec, "r"))
local S = tonumber(f:read("*l"))
local spr = Sprite(S, S, ColorMode.RGB)
local order = { "halo", "ink", "art" }
local layers = {}
local base = spr.layers[1]
base.name = order[1]
layers[order[1]] = base
for i = 2, #order do
  local l = spr:newLayer()
  l.name = order[i]
  layers[order[i]] = l
end
local imgs = {}
for _, n in ipairs(order) do imgs[n] = Image(S, S, ColorMode.RGB) end
for line in f:lines() do
  local ln, x, y, hex = line:match("^(%a+) (%d+) (%d+) (%x%x%x%x%x%x)$")
  if ln then
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    imgs[ln]:drawPixel(tonumber(x), tonumber(y), app.pixelColor.rgba(r, g, b, 255))
  end
end
f:close()
for _, n in ipairs(order) do spr:newCel(layers[n], spr.frames[1], imgs[n], Point(0, 0)) end
spr:saveAs(app.params.dest)
spr:saveCopyAs(app.params.png)
spr:close()

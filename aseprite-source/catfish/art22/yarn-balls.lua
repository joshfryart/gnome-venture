-- yarn-balls.lua : Cat Fish art22, coloured yarn balls (rose, mint, violet, gold) for the rolling-yarn room bit.
-- Run: AppRun -b --script yarn-balls.lua     Writes art22/out/cf-yarn-<n>-<colour>.png + .aseprite (n = 1..4).
-- Source frames: game/assets/img/catfish/cf-yarn-<n>.png (blue-grey felt, read only). This is a palette swap,
-- not a filter: the four felt tones of the grey ball (thread highlight, base, shade/thread line, deep contact
-- shading) are each mapped to one tone of a hue-shifted ramp built here; the umber outline and the 1 px #000000
-- border are kept, so every frame keeps its pixel structure exactly (same alpha, same tone index per pixel).
-- Ramp recipe (addenda): light = hue toward warm yellow (45 deg) and lighter; shade/deep = hue toward a cool
-- violet target and darker. The violet ball shades toward indigo (its own hue is already the violet target).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local SRC = here .. "/../../../game/assets/img/catfish/"
local OUT = here .. "/out/"
local abs, min, max = math.abs, math.min, math.max

local function toward(h, t, a)
  local d = ((t - h + 540) % 360) - 180
  if abs(d) <= a then return t end
  return h + (d > 0 and a or -a)
end

-- base = the .cfcol-* mid colour; sh = cool target hue for shade/deep; lk = light lift; ls = light saturation;
-- ss = shade/deep saturation (polish 1: rose shade was a hot magenta, eased so the felt steps stay soft like the grey)
local BALLS = {
  { "rose",   "#e8799b", sh = 290, lk = 0.45, ls = 1.00, ss = 0.82 },
  { "mint",   "#5fc9a0", sh = 205, lk = 0.45, ls = 0.95, ss = 1.00 },
  { "violet", "#9a6fd0", sh = 240, lk = 0.42, ls = 1.00, ss = 0.95 },
  { "gold",   "#e0a526", sh = 330, lk = 0.50, ls = 1.00, ss = 1.00 },
}

local function ramp(b)
  local h, s, l = GV.hsl(b[2])
  return {
    light = GV.fromHsl(toward(h, 45, 14), min(1, s * b.ls), l + (1 - l) * b.lk),
    base  = b[2],
    shade = GV.fromHsl(toward(h, b.sh, 10), min(1, s * 1.02 * b.ss), l * 0.80),
    deep  = GV.fromHsl(toward(h, b.sh, 24), min(1, s * 1.05 * b.ss), l * 0.60),
  }
end

-- grey source tones (exact) -> ramp key
local GREY = { ["b9cfd9"] = "light", ["8eaabf"] = "base", ["6f8aa8"] = "shade", ["56708f"] = "deep" }
local KEEP = { ["000000"] = true, ["74462a"] = true, ["4a2c1a"] = true, ["2a1a10"] = true }

local pc = app.pixelColor
local function hex(v) return string.format("%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
local function val(h) h = h:gsub("#", "") return pc.rgba(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16), 255) end

for _, b in ipairs(BALLS) do
  local r = ramp(b)
  print(b[1], r.light, r.base, r.shade, r.deep)
  for n = 1, 4 do
    local src = Image{ fromFile = SRC .. "cf-yarn-" .. n .. ".png" }
    assert(src.width == 16 and src.height == 16, "unexpected source size")
    local spr = Sprite(16, 16, ColorMode.RGB)
    local img = Image(16, 16, ColorMode.RGB)
    for y = 0, 15 do for x = 0, 15 do
      local v = src:getPixel(x, y)
      local a = pc.rgbaA(v)
      if a == 0 then img:drawPixel(x, y, pc.rgba(0, 0, 0, 0))
      else
        assert(a == 255, "semi-transparent source pixel")
        local k = hex(v)
        if GREY[k] then img:drawPixel(x, y, val(r[GREY[k]]))
        elseif KEEP[k] then img:drawPixel(x, y, v)
        else error("unmapped source colour #" .. k .. " in frame " .. n) end
      end
    end end
    spr.cels[1].image = img
    local name = OUT .. "cf-yarn-" .. n .. "-" .. b[1]
    spr:saveCopyAs(name .. ".aseprite")
    spr:saveCopyAs(name .. ".png")
    spr:close()
  end
end

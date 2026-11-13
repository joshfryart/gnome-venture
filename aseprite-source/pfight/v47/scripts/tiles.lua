-- tiles.lua : tile-<size>-<type> (body, rim, light, shade, stitch, glyph; no plate/number/pips)
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua")
local G = dofile(D .. "glyphs.lua")
local OUT = D .. "../"
local T = {}

function T.stitchLayer(c, col)
  local s = L.cv(c.W, c.H)
  local n = c.stitchIn
  local function pat(i, len) local j = i; if i >= len / 2 then j = len - 1 - i end; return (j % 3) < 2 end
  local lx, ly = c.BW - 2 * n, c.BH - 2 * n
  for i = 0, lx - 1 do
    if pat(i, lx) then s:set(c.T + n + i, c.T + n, col); s:set(c.T + n + i, c.T + c.BH - 1 - n, col) end
  end
  for i = 0, ly - 1 do
    if pat(i, ly) then s:set(c.T + n, c.T + n + i, col); s:set(c.T + c.BW - 1 - n, c.T + n + i, col) end
  end
  return s
end

function T.layers(c, tname)
  local P = L.TYPES[tname]
  local base, light, shade, stitch, glyph, rim = L.cv(c.W, c.H), L.cv(c.W, c.H), L.cv(c.W, c.H), nil, nil, L.cv(c.W, c.H)
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do
    if L.inBody(c, x, y) then
      if L.isRim(c, x, y) then rim:set(c.T + x, c.T + y, L.INK)
      else
        base:set(c.T + x, c.T + y, P.base)
        if y == 1 then light:set(c.T + x, c.T + y, P.light) end
        if y == c.BH - 2 then shade:set(c.T + x, c.T + y, P.shade) end
        if c.name == "hand" and (y == 2 and x > 1 and x < c.BW - 2) then light:set(c.T + x, c.T + y, P.light) end
        if c.name == "hand" and (y == c.BH - 3 and x > 1 and x < c.BW - 2) then shade:set(c.T + x, c.T + y, P.shade) end
      end
    end
  end end
  stitch = T.stitchLayer(c, P.light)
  local gl = G.make(c, tname)
  glyph = L.cv(c.W, c.H)
  local gx, gy = (c.BW - gl.w) // 2, (c.BH - gl.h) // 2
  glyph:blit(gl, c.T + gx, c.T + gy)
  return { base = base, shade = shade, light = light, stitch = stitch, glyph = glyph, rim = rim }, { gx = gx, gy = gy, gw = gl.w, gh = gl.h }
end

function T.build(c, tname)
  local ly, info = T.layers(c, tname)
  L.save(OUT .. c.name .. "/tile-" .. c.name .. "-" .. tname, c.W, c.H, {
    { name = "base", cv = ly.base }, { name = "shade", cv = ly.shade }, { name = "light", cv = ly.light },
    { name = "stitch", cv = ly.stitch }, { name = "glyph", cv = ly.glyph }, { name = "rim", cv = ly.rim } })
  L.savelayer(OUT .. "scripts/layers/glyph-" .. c.name .. "-" .. tname, ly.glyph)
  local x0, y0, x1, y1 = ly.glyph:bbox()
  print(("glyph %s %-6s bbox body-coords x %d..%d y %d..%d  centre %.1f,%.1f (body centre %.1f,%.1f)"):format(c.name, tname, x0 - c.T, x1 - c.T, y0 - c.T, y1 - c.T, (x0 + x1) / 2 - c.T, (y0 + y1) / 2 - c.T, (c.BW - 1) / 2, (c.BH - 1) / 2))
end
return T

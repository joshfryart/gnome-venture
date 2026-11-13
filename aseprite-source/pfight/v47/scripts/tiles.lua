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
  local lx, ly = c.BW - 2 * n - 4, c.BH - 2 * n - 4
  for i = 0, lx - 1 do
    if pat(i, lx) then s:set(c.T + n + 2 + i, c.T + n, col); s:set(c.T + n + 2 + i, c.T + c.BH - 1 - n, col) end
  end
  for i = 0, ly - 1 do
    if pat(i, ly) then s:set(c.T + n, c.T + n + 2 + i, col); s:set(c.T + c.BW - 1 - n, c.T + n + 2 + i, col) end
  end
  for _, p in ipairs({ { n + 1, n + 1 }, { c.BW - 2 - n, n + 1 }, { n + 1, c.BH - 2 - n }, { c.BW - 2 - n, c.BH - 2 - n } }) do s:set(c.T + p[1], c.T + p[2], col) end  -- tiny corner stitches
  return s
end

function T.layers(c, tname)
  local P = L.TYPES[tname]
  local function new() return L.cv(c.W, c.H) end
  local base, grain, light, shade, rim = new(), new(), new(), new(), new()
  local stitch = T.stitchLayer(c, P.light)
  local n = c.stitchIn
  local nb, ng = 0, 0
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do
    if L.inBody(c, x, y) then
      local X, Y = c.T + x, c.T + y
      if L.isRim(c, x, y) then rim:set(X, Y, P.rim)
      else
        nb = nb + 1
        base:set(X, Y, P.base)
        local lit = c.name == "hand" and 2 or 1   -- rim-light / shade band thickness
        local edge = math.min(x, y, c.BW - 1 - x, c.BH - 1 - y)
        if y <= lit and y <= x and x < c.BW - 2 then light:set(X, Y, (y == 1 and x >= c.R - 1 and x <= c.R + 1 + lit) and P.hi or P.light)
        elseif x <= lit and x < y then light:set(X, Y, P.light)
        elseif y >= c.BH - 1 - lit and c.BH - 1 - y <= c.BW - 1 - x then shade:set(X, Y, (c.BH - 1 - y == lit and x > c.BW - 4 - lit) and P.deep or P.shade)
        elseif x >= c.BW - 1 - lit then shade:set(X, Y, P.shade) end
        -- sparse felt grain: never near rim bands, stitch, glyph, plate, badges, pips
        if edge > lit + 1 and math.abs(edge - n) > 1 and not L.reserved(c, x, y, 1) and not stitch:get(X, Y) then
          local h = ((x * 73856093) ~ (y * 19349663) ~ (x * y * 83492791)) % 1000
          local thr = c.name == "hand" and 70 or 85
          if h < thr then ng = ng + 1; grain:set(X, Y, (h % 2 == 0) and P.dotL or P.dotD) end
        end
      end
    end
  end end
  local gl = G.make(c, tname)
  local glyph = new()
  local gx, gy = (c.BW - gl.w) // 2, (c.BH - gl.h) // 2
  glyph:blit(gl, c.T + gx, c.T + gy)
  return { base = base, grain = grain, shade = shade, light = light, stitch = stitch, glyph = glyph, rim = rim }, { gx = gx, gy = gy, gw = gl.w, gh = gl.h, grain = ng / nb }
end

function T.build(c, tname)
  local ly, info = T.layers(c, tname)
  L.save(OUT .. c.name .. "/tile-" .. c.name .. "-" .. tname, c.W, c.H, {
    { name = "base", cv = ly.base }, { name = "grain", cv = ly.grain }, { name = "shade", cv = ly.shade }, { name = "light", cv = ly.light },
    { name = "stitch", cv = ly.stitch }, { name = "glyph", cv = ly.glyph }, { name = "rim", cv = ly.rim } })
  L.savelayer(OUT .. "scripts/layers/grain-" .. c.name .. "-" .. tname, ly.grain)
  print(("grain %s %-6s %.1f%% of body pixels"):format(c.name, tname, info.grain * 100))
  L.savelayer(OUT .. "scripts/layers/glyph-" .. c.name .. "-" .. tname, ly.glyph)
  local x0, y0, x1, y1 = ly.glyph:bbox()
  print(("glyph %s %-6s bbox body-coords x %d..%d y %d..%d  centre %.1f,%.1f (body centre %.1f,%.1f)"):format(c.name, tname, x0 - c.T, x1 - c.T, y0 - c.T, y1 - c.T, (x0 + x1) / 2 - c.T, (y0 + y1) / 2 - c.T, (c.BW - 1) / 2, (c.BH - 1) / 2))
end
return T

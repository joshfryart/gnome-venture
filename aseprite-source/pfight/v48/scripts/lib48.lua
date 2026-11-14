-- lib48.lua : the v48 beauty pass. Geometry, sockets and the hard-pixel raster are v47's (lib47.lua, untouched): the piece edge is identical.
-- New here: the ramps of the three owners (mine by type, creature, environment by kind) and a small shape raster for the glyphs
-- (shapes in design units, 4 x 4 samples per pixel, a pixel is set when half of it is covered: hard pixels, no blends).
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "../../v47/scripts/lib47.lua")
L.OUT = D .. "../"
L.BONE, L.BONESH = 0xf6e2c0, 0xc9a27a
L.CREAMHI = 0xfffbe8
L.WOOD, L.WOODSH = 0xb97a4a, 0x864c33
-- the creature's pieces: one ember-to-plum ramp for every type (the glyph says the type)
L.FOE = { hi = 0xe0705a, light = 0xc4504a, base = 0x9c2f3c, shade = 0x6e2038, deep = 0x4a1a30, rim = 0x2a1016, tooth = 0xf6e2c0, toothsh = 0xc9a27a }
-- the environment's pieces: pale parchment for every kind, the dashed stitch and the glyph carry the kind's colour
L.ENV = { hi = 0xfffbe8, light = 0xf7edd2, base = 0xe6d6b4, shade = 0xc2a983, deep = 0x9c8262, rim = 0x3a2a20 }
L.KINDS = {   -- hi / base / shade / deep (Hearth Pop ramps)
  sun     = { hi = 0xffe38a, base = 0xf5b82e, shade = 0xd98322, deep = 0x8f4a1f },
  bramble = { hi = 0xc4e07a, base = 0x7cc35a, shade = 0x3f9150, deep = 0x24544a },
  rain    = { hi = 0xb6f0e0, base = 0x5fc4c8, shade = 0x3a86b0, deep = 0x2a4a7a },
  wind    = { hi = 0xc9d6ea, base = 0x9fb2d3, shade = 0x6f84ad, deep = 0x46557d },
  mud     = { hi = 0xe8b982, base = 0xb97a4a, shade = 0x864c33, deep = 0x51302b },
  thorn   = { hi = 0xff8a5c, base = 0xe8493b, shade = 0xb52e3f, deep = 0x6e2038 },
}
L.KORDER = { "sun", "bramble", "rain", "wind", "mud", "thorn" }

-- shapes: each returns inside(x, y) in design units -----------------------------------------------
local S = {}
function S.disc(cx, cy, r) return function(x, y) return (x - cx) ^ 2 + (y - cy) ^ 2 <= r * r end end
function S.ell(cx, cy, rx, ry) return function(x, y) return ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end end
function S.dome(cx, cy, rx, ry) return function(x, y) return y <= cy and ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end end
function S.rect(x0, y0, x1, y1) return function(x, y) return x >= x0 and x <= x1 and y >= y0 and y <= y1 end end
function S.rrect(x0, y0, x1, y1, r)
  return function(x, y)
    if x < x0 or x > x1 or y < y0 or y > y1 then return false end
    local dx = (x < x0 + r) and (x0 + r - x) or ((x > x1 - r) and (x - (x1 - r)) or 0)
    local dy = (y < y0 + r) and (y0 + r - y) or ((y > y1 - r) and (y - (y1 - r)) or 0)
    return dx * dx + dy * dy <= r * r
  end
end
function S.poly(pts)
  return function(px, py)
    local inside, n = false, #pts
    local j = n
    for i = 1, n do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
      j = i
    end
    return inside
  end
end
function S.line(x0, y0, x1, y1, w0, w1)   -- a capsule; w1 given = tapered
  w1 = w1 or w0
  local dx, dy = x1 - x0, y1 - y0; local len2 = dx * dx + dy * dy
  return function(x, y)
    local t = ((x - x0) * dx + (y - y0) * dy) / len2
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    local qx, qy = x0 + t * dx, y0 + t * dy
    local w = (w0 + (w1 - w0) * t) / 2
    return (x - qx) ^ 2 + (y - qy) ^ 2 <= w * w
  end
end
function S.arc(cx, cy, r, a0, a1, w)   -- ring segment, angles in degrees (0 = right, 90 = down), a0 < a1
  return function(x, y)
    local d = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    if math.abs(d - r) > w / 2 then return false end
    local a = math.deg(math.atan(y - cy, x - cx))
    while a < a0 do a = a + 360 end
    return a <= a1
  end
end
function S.lens(ax, ay, bx, by, h)   -- a leaf: the overlap of two circles through a and b, half-width h
  local mx, my = (ax + bx) / 2, (ay + by) / 2
  local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  local R = (len * len / 4 + h * h) / (2 * h)
  local nx, ny = -(by - ay) / len, (bx - ax) / len
  local c1x, c1y, c2x, c2y = mx + nx * (R - h), my + ny * (R - h), mx - nx * (R - h), my - ny * (R - h)
  return function(x, y) return (x - c1x) ^ 2 + (y - c1y) ^ 2 <= R * R and (x - c2x) ^ 2 + (y - c2y) ^ 2 <= R * R end
end
function S.star(cx, cy, n, r0, r1, rot)   -- n spikes, outer radius r0, inner r1
  local pts = {}
  for i = 0, 2 * n - 1 do
    local a = math.rad((rot or -90) + i * 180 / n); local r = (i % 2 == 0) and r0 or r1
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return S.poly(pts)
end
L.S = S

-- glyph raster: g = { W = design width, H = 17, { shape, colour [, "cut"] }, ... }; shadeOf = { colour -> its darker partner }
-- returns a canvas (art + 1 px ink outline) and its size
function L.glyph(g, scale, canvasH, shadeOf, depth)
  local Hd = g.H or 17
  local h = math.floor(canvasH * Hd / 17 + .5)
  local w = math.ceil(g.W * scale / 2 - 1e-6) * 2
  local art = L.cv(w + 2, h + 2)
  local n = 4
  for _, item in ipairs(g) do
    local f, col = item[1], item[2]
    for py = 0, h - 1 do for px = 0, w - 1 do
      local hit = 0
      for sy = 0, n - 1 do for sx = 0, n - 1 do
        local ux = g.W / 2 + (px + (sx + .5) / n - w / 2) / scale
        local uy = Hd / 2 + (py + (sy + .5) / n - h / 2) / scale
        if f(ux, uy) then hit = hit + 1 end
      end end
      if hit >= n * n / 2 then if col == "cut" then art:set(px + 1, py + 1, nil) else art:set(px + 1, py + 1, col) end end
    end end
  end
  -- the lower-right edge of a shaded colour goes one step darker (light from the upper left)
  local list = {}
  depth = depth or 1
  for y = 0, art.h - 1 do for x = 0, art.w - 1 do
    local c = art:get(x, y)
    if c and shadeOf[c] and art:get(x + depth, y + depth) == nil then list[#list + 1] = { x, y, shadeOf[c] } end
  end end
  for _, p in ipairs(list) do art:set(p[1], p[2], p[3]) end
  -- 1 px ink outline (4-neighbours)
  local out = {}
  for y = 0, art.h - 1 do for x = 0, art.w - 1 do
    if not art:get(x, y) and (art:get(x - 1, y) or art:get(x + 1, y) or art:get(x, y - 1) or art:get(x, y + 1)) then out[#out + 1] = { x, y } end
  end end
  for _, p in ipairs(out) do art:set(p[1], p[2], L.INK) end
  return art
end
-- put a glyph canvas on a piece-size layer so that its bounding box is centred on the body
function L.centre(c, art)
  local x0, y0, x1, y1 = art:bbox()
  local layer = L.cv(c.W, c.H)
  local bw, bh = x1 - x0 + 1, y1 - y0 + 1
  local ox = c.T + (c.BW - bw) // 2 - x0
  local oy = c.T + (c.BH - bh) // 2 - y0
  layer:blit(art, ox, oy)
  return layer, bw, bh
end

-- body layers shared by the three owners: base, bevel (lit top/left, shaded right, a 2 px lip at the bottom), rim
function L.body(c, R)
  local base, bevel, rim = L.cv(c.W, c.H), L.cv(c.W, c.H), L.cv(c.W, c.H)
  local hand = c.name == "hand"
  local t = hand and 2 or 1   -- bevel thickness
  local function free(x, y) return L.inBody(c, x, y) and not L.isRim(c, x, y) end
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do
    if L.inBody(c, x, y) then
      local X, Y = c.T + x, c.T + y
      if L.isRim(c, x, y) then rim:set(X, Y, R.rim)
      else
        base:set(X, Y, R.base)
        local up, left, down, right = 99, 99, 99, 99   -- steps to the rim in each direction
        for k = 1, 2 * t + 1 do
          if up == 99 and not free(x, y - k) then up = k end
          if left == 99 and not free(x - k, y) then left = k end
          if down == 99 and not free(x, y + k) then down = k end
          if right == 99 and not free(x + k, y) then right = k end
        end
        if down <= t then bevel:set(X, Y, R.deep)
        elseif down <= 2 * t then bevel:set(X, Y, R.shade)
        elseif right <= t then bevel:set(X, Y, R.shade)
        elseif up <= t then bevel:set(X, Y, R.light)
        elseif left <= t then bevel:set(X, Y, R.light) end
      end
    end
  end end
  -- the glint: a short hi run on the top bevel and one more pixel on the left one
  local g0 = c.R + 1
  for i = 0, (hand and 8 or 5) do for k = 1, t do bevel:set(c.T + g0 + i, c.T + k, R.hi) end end
  for k = 1, t do for i = 0, (hand and 2 or 1) do bevel:set(c.T + k, c.T + g0 + i, R.hi) end end
  return base, bevel, rim
end
return L

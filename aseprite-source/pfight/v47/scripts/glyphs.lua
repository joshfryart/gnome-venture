-- glyphs.lua : seven hand-built type glyphs (cream, 1 px ink outline). art box gW x gH (strip 18x19, hand 32x32), outline adds 1 px per side.
local L = dofile(debug.getinfo(1, "S").source:match("@(.*/)") .. "lib47.lua")
local CREAM, CREAMSH, INK, GOLD, GOLDSH = L.CREAM, L.CREAMSH, L.INK, L.GOLD, L.GOLDSH
local G = {}

local CREAMHI = 0xfffbe8
local function shade(g, depth)  -- lower-right edge of cream shapes goes one step darker (light from the upper left)
  local list = {}
  for y = 0, g.h - 1 do for x = 0, g.w - 1 do
    if g:get(x, y) == CREAM and g:get(x + depth, y + depth) == nil then list[#list + 1] = { x, y } end
  end end
  for _, p in ipairs(list) do g:set(p[1], p[2], CREAMSH) end
end

local draw = {}
function draw.hurt(g, W, H, P, hand)
  local w, sp, s = 3, 5, 3
  if hand then w, sp, s = 6, 9, 6 end
  for k = 0, 2 do
    local a = s + k * sp
    g:poly({ { a, 0 }, { a + w, 0 }, { a - s + (hand and 2 or 1.5), H }, { a - s, H } }, CREAM)
  end
  shade(g, hand and 2 or 1)
end

function draw.guard(g, W, H, P, hand)
  local cx = W / 2
  g:poly({ { 0, 0 }, { W, 0 }, { W, .5 * H }, { .84 * W, .76 * H }, { cx + 1.2, H }, { cx - 1.2, H }, { .16 * W, .76 * H }, { 0, .5 * H } }, CREAM)
  shade(g, hand and 2 or 1)
  local i = hand and 5 or 3
  local pts = { { i, i }, { W - i, i }, { W - i, .48 * H }, { .82 * W, .72 * H - 1 }, { cx + .6, H - i - 1 }, { cx - .6, H - i - 1 }, { .18 * W, .72 * H - 1 }, { i, .48 * H } }
  g:poly(pts, P.base)
  local half = {}
  for _, p in ipairs(pts) do if p[1] <= cx + .6 then half[#half + 1] = p end end
  g:poly({ { i, i }, { cx, i }, { cx, H - i - 1 }, { cx - .6, H - i - 1 }, { .18 * W, .72 * H - 1 }, { i, .48 * H } }, P.light)
  if hand then g:rect(cx - 1, i + 3, cx, H - i - 5, CREAM) g:rect(i + 4, .38 * H, W - i - 5, .38 * H + 1, CREAM) end
end

function draw.heal(g, W, H, P, hand)
  local a, b = 6, 7
  if hand then a, b = 10, 10 end
  local x0, y0 = (W - a) // 2, (H - b) // 2
  g:rect(x0, 0, x0 + a - 1, H - 1, CREAM)
  g:rect(0, y0, W - 1, y0 + b - 1, CREAM)
  local cut = hand and 2 or 1
  for _, p in ipairs({ { x0, 0 }, { x0 + a - 1, 0 }, { x0, H - 1 }, { x0 + a - 1, H - 1 }, { 0, y0 }, { 0, y0 + b - 1 }, { W - 1, y0 }, { W - 1, y0 + b - 1 } }) do
    g:rect(p[1] - (p[1] == x0 + a - 1 and 0 or 0), p[2], p[1], p[2], nil)
    if cut == 2 then
      local dx = (p[1] == 0 or p[1] == x0) and 1 or -1; local dy = (p[2] == 0 or p[2] == y0) and 1 or -1
      if p[2] == 0 or p[2] == H - 1 then g:set(p[1] + dx, p[2], nil) else g:set(p[1], p[2] + dy, nil) end
    end
  end
  shade(g, hand and 2 or 1)
  local t = hand and 3 or 2
  g:rect(x0 + t, t, x0 + a - 1 - t, H - 1 - t, P.base)
  g:rect(t, y0 + t, W - 1 - t, y0 + b - 1 - t, P.base)
  g:rect(x0 + t, t, x0 + t, H - 1 - t, P.light)  -- lit left edge of the inlay
  g:rect(t, y0 + t, W - 1 - t, y0 + t, P.light)
end

function draw.charm(g, W, H, P, hand)
  local r = hand and 7 or 4
  local cx, cy = W / 2, H / 2
  g:disc(r, cy, r, CREAM); g:disc(W - r, cy, r, CREAM)
  g:disc(cx, r, r, CREAM); g:disc(cx, H - r, r, CREAM)
  if hand then local o = 8.3; for _, s in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do g:disc(cx + s[1] * o, cy + s[2] * o, 4.6, CREAM) end end
  shade(g, hand and 2 or 1)
  local rc = hand and 5.6 or 3.3
  g:disc(cx, cy, rc + 1, INK)
  g:disc(cx, cy, rc, GOLD)
  g:disc(cx + 0.8, cy + 0.8, rc - 1.2, GOLDSH)
  g:disc(cx - 0.4, cy - 0.4, rc - 1.6, GOLD)
  if hand then for _, s in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do g:rect(cx + s[1] * 11.5 - 1, cy + s[2] * 11.5 - 1, cx + s[1] * 11.5, cy + s[2] * 11.5, P.light) end end
end

function draw.soothe(g, W, H, P, hand)  -- a calm feather, tip upper right, quill lower left
  for y = 0, H - 1 do for x = 0, W - 1 do
    local nx, ny = (x + .5) / W, (y + .5) / H
    local t, p = (nx + (1 - ny)) / 2, (nx - (1 - ny)) / 2
    local w = 0.27 * math.sin(math.pi * math.min(1, t * 1.1 + 0.02)) ^ 0.75
    if t < 0.22 then w = math.min(w, hand and 0.05 or 0.06) end
    w = math.max(w, 0.04)
    if math.abs(p) <= w then g:set(x, y, CREAM) end
  end end
  shade(g, hand and 2 or 1)
  for y = 0, H - 1 do for x = 0, W - 1 do   -- quill
    local nx, ny = (x + .5) / W, (y + .5) / H
    local t, p = (nx + (1 - ny)) / 2, (nx - (1 - ny)) / 2
    if math.abs(p) <= (hand and 0.03 or 0.02) and t > 0.12 and t < 0.9 and g:get(x, y) then g:set(x, y, P.shade) end
  end end
  if hand then  -- barb notches
    for _, t0 in ipairs({ 0.35, 0.5, 0.65 }) do
      for sgn = -1, 1, 2 do
        local x = ((t0 + sgn * 0.14) + (0)) 
      end
    end
  end
end

function draw.trick(g, W, H, P, hand)
  local cx, cy = W / 2, H / 2
  local ri = hand and 5.2 or 3.4
  local tw = 1
  local hv = (H % 2 == 1) and .5 or 1
  g:poly({ { cx - tw, 0 }, { cx + tw, 0 }, { cx + ri, cy - ri }, { W, cy - hv }, { W, cy + hv }, { cx + ri, cy + ri }, { cx + tw, H }, { cx - tw, H }, { cx - ri, cy + ri }, { 0, cy + hv }, { 0, cy - hv }, { cx - ri, cy - ri } }, CREAM)
  shade(g, hand and 2 or 1)
  if hand then
    g:disc(cx, cy, 4.4, GOLD); g:disc(cx + .8, cy + .8, 3.2, GOLDSH); g:disc(cx - .3, cy - .3, 2.8, GOLD)
  else
    g:rect(cx - 1, cy - 1.5, cx, cy - .5, GOLD); g:rect(cx, cy - .5, cx, cy - .5, GOLDSH)
  end
end

function draw.item(g, W, H, P, hand)
  local k = hand and 1.8 or 1
  local lidH, neckH = math.floor(3 * k), math.floor(2 * k)
  local lx = math.floor(3 * k)
  g:rect(lx, 0, W - 1 - lx, lidH - 1, P.mark)
  g:rect(lx + 1, lidH, W - 2 - lx, lidH + neckH - 1, CREAM)
  g:rect(0, lidH + neckH, W - 1, H - 1, CREAM)
  g:set(0, lidH + neckH, nil); g:set(W - 1, lidH + neckH, nil); g:set(0, H - 1, nil); g:set(W - 1, H - 1, nil)
  if hand then g:set(1, lidH + neckH, nil); g:set(W - 2, lidH + neckH, nil); g:set(1, H - 1, nil); g:set(W - 2, H - 1, nil) end
  shade(g, hand and 2 or 1)
  g:rect(lx, 0, W - 1 - lx, 0, P.light)               -- lit lid top
  local ly0 = lidH + neckH + math.floor(3 * k)
  g:rect(math.floor(3 * k), ly0, W - 1 - math.floor(3 * k), H - 1 - math.floor(2.5 * k), P.base)
  g:rect(math.floor(3 * k), ly0, W - 1 - math.floor(3 * k), ly0, P.light)
  if hand then g:rect(6, ly0 + 5, W - 7, ly0 + 6, CREAM) g:rect(6, ly0 + 9, W - 13, ly0 + 10, CREAM) else g:rect(5, ly0 + 3, W - 6, ly0 + 3, CREAM) end
end

-- returns a canvas (gW+2) x (gH+2): cream art + 1 px ink outline (8-neighbour)
function G.make(cfg, tname)
  local P = L.TYPES[tname]
  local hand = cfg.name == "hand"
  local W, H = cfg.gW, cfg.gH
  local g = L.cv(W, H)
  draw[tname](g, W, H, P, hand)
  local x0, y0, x1, y1 = g:bbox()
  assert(x0 == 0 and y0 == 0 and x1 == W - 1 and y1 == H - 1, ("glyph %s %s bbox %d,%d..%d,%d expected 0,0..%d,%d"):format(cfg.name, tname, x0, y0, x1, y1, W - 1, H - 1))
  local o = L.cv(W + 2, H + 2)
  for y = 0, H - 1 do for x = 0, W - 1 do if g:get(x, y) then
    for dy = -1, 1 do for dx = -1, 1 do o:set(x + 1 + dx, y + 1 + dy, INK) end end
  end end end
  o:blit(g, 1, 1)
  for y = 1, H do for x = 1, W do   -- 1 px highlight row along the lit top edge
    if o:get(x, y) == CREAM and o:get(x, y - 1) == INK and o:get(x, y + 1) ~= INK then o:set(x, y, CREAMHI) end
  end end
  if tname == "hurt" then   -- claw tips pick up the type colour
    for y = H - (hand and 4 or 2), H do for x = 1, W do local v = o:get(x, y); if v == CREAM or v == CREAMSH then o:set(x, y, P.light) end end end
  end
  return o
end
return G

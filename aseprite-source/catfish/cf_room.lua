-- cf_room.lua : Cat Fish step 6a (claude/catfish-art-brief.md): the room scene and its 4 upgrade overlays.
-- Stitched Toy, gvlib "scene" mode (art-style-guide Part D + Part E): drawn on a 160 x 100 grid, written at 2x
-- nearest (320 x 200), no black border, three-tone umber outline on raised objects only, one crescent per object,
-- stepped bands (no gradients, no dither), day light from the upper left.
-- Run: AppRun -b --script cf_room.lua        Writes test/cf-room.png and test/cf-room-<key>.png (+ .aseprite).
--   cf-room.png           base, fully opaque, <= 32 colours: striped wallpaper, wood crown, chair rail and skirting,
--                         blue wainscot panels, honey plank floor in stepped bands, green window (view, no bird)
--                         with a sill plant, a framed fish picture mid-wall, a low cupboard (books, yarn) with a
--                         yarn basket, wall right of it left bare for the post, a tufted floor cushion back left.
--   cf-room-sunbeam.png   light through the window: a lit shaft on the wall under the sill (one step) and a
--                         window-shaped patch on the floor (two steps, mullion-cross shadow). Made by relighting the
--                         base pixels under the shape, so plank seams and trim stay visible through the light.
--   cf-room-rug.png       oval green felt rug, cream braid band, gold hem stitch at the edge only, cream fringe.
--   cf-room-scratch.png   sisal scratch post on a green felt base, green cap, pink pompom, floor shadow (right side).
--   cf-room-window.png    a robin perched on the bottom bar of the lower-right pane, clipped to the glass.
-- Overlays are the same 320 x 200 size, alpha 0/255, and do not overlap each other, so any stacking order gives
-- the same picture (suggested: sunbeam, rug, scratch, window, then the cats).
-- Layout for code (exported px): floor y 124..199; calm walking band y 160..196 (cat feet line about y 184,
-- i.e. a 64 x 64 cat drawn at y 124); the rug spans x 74..263, y 160..197; the scratch post holds x 268..319,
-- so three cats fit at x 20..256. Window panes x 30..107, y 18..59; sunbeam patch on the floor x 52..150.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local C = GV.C
local W, H = 160, 100

local function canvas() return GV.canvas{ w = W, h = H, mode = "scene", out = 2 } end
-- felt(hex): 4 felt steps (rim, base, shade, gloss): deep = shade, bounce = base, so a part adds few colours
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function rows(c, y, list) for i, hex in ipairs(list) do c:fill(c:rect(0, y + i - 1, W - 1, y + i - 1), hex) end end

-------------------------------------------------------------------------------- palette
local WOOD  = { rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#5e2f1e" }
local FLOOR = { b = "#d9a660", m = "#c78d52", d = "#b07a45" }       -- plank rows, front to back
local WALL  = { base = "#f2dfb6", stripe = "#e8cc98" }
local WAIN  = { rim = "#b9cfd9", base = "#8eaabf", shade = "#6f8aa8" }
local GREEN = felt("#5f9e48", { rim = "#8cc064", shade = "#3f7a3a", gloss = "#c8e08a", dot = "#c8e08a" })
local SKY   = { hi = "#c8e8f4", lo = "#9ccfe8", hill = "#8cc064", hillS = "#5f9e48", cloud = "#f1ece0" }
local PINK  = felt("#e46a9b", { rim = "#f29abb", shade = "#b8466e", gloss = "#f29abb", dot = "#f29abb" })
local GOLD  = felt("#e8a317", { rim = "#f5cf6a", shade = "#b8661a", gloss = "#f5cf6a", dot = "#f5cf6a" })
local TERRA = felt("#c8643c", { rim = "#e08a5a", shade = "#8a4f2a", gloss = "#e08a5a", dot = "#e08a5a" })
local WOODR = felt(WOOD.base, { rim = WOOD.rim, shade = WOOD.shade, gloss = WOOD.rim, dot = WOOD.rim })
-- one step darker on the floor (contact shadows), shared by base and overlays
local DOWN = { [FLOOR.b] = FLOOR.m, [FLOOR.m] = FLOOR.d, [FLOOR.d] = WOOD.shade, [WOOD.shade] = WOOD.deep,
               [WOOD.rim] = FLOOR.m, [WOOD.base] = WOOD.shade, [C.ol1] = C.ol2, [C.ol2] = C.ol3 }

-------------------------------------------------------------------------------- geometry
local WIN = { x0 = 11, y0 = 5, x1 = 57, y1 = 33 }                    -- window frame (outer)
local PANES = { { 15, 9, 32, 12 }, { 36, 9, 53, 12 }, { 15, 16, 32, 29 }, { 36, 16, 53, 29 } }   -- small top lights
local SHELF = { x0 = 91, y0 = 40, x1 = 137, y1 = 64 }   -- left of the post
local PX = -9                                                        -- picture shift (was x 74..100)
local RUG = { cx = 84, cy = 88, rx = 44, ry = 8 }

-------------------------------------------------------------------------------- base
local function drawBase(c)
  -- wallpaper with soft stripes
  c:fill(c:rect(0, 0, W - 1, 40), WALL.base)
  for x = 0, W - 1 do if x % 12 == 4 or x % 12 == 5 then c:fill(c:rect(x, 4, x, 35), WALL.stripe) end end
  -- crown moulding, chair rail, wainscot, skirting: stepped rows lit from above
  rows(c, 0, { WOOD.rim, WOOD.base, WOOD.shade, C.ol1, WALL.stripe })
  rows(c, 35, { C.ol1, WOOD.rim, WOOD.base, WOOD.shade, C.ol2, WAIN.shade })
  c:fill(c:rect(0, 41, W - 1, 55), WAIN.base)
  for x0 = 0, W - 1, 20 do                                           -- recessed panels: dark top/left, lit bottom/right
    c:fill(c:rect(x0 + 3, 44, x0 + 16, 52), WAIN.base)
    c:fill(c:rect(x0 + 3, 44, x0 + 16, 44), WAIN.shade); c:fill(c:rect(x0 + 3, 44, x0 + 3, 52), WAIN.shade)
    c:fill(c:rect(x0 + 4, 52, x0 + 16, 52), WAIN.rim); c:fill(c:rect(x0 + 16, 45, x0 + 16, 52), WAIN.rim)
  end
  rows(c, 56, { C.ol2, WOOD.rim, WOOD.base, WOOD.base, WOOD.shade, C.ol3 })
  -- floor: plank rows in stepped bands (back row in the wall's shade), quiet 1 px seams, staggered joints
  local R = { { 62, 66, FLOOR.d, WOOD.shade, 10 }, { 67, 72, FLOOR.m, FLOOR.d, 34 }, { 73, 80, FLOOR.b, FLOOR.m, 22 },
              { 81, 89, FLOOR.b, FLOOR.m, 46 }, { 90, 99, FLOOR.b, FLOOR.m, 4 } }
  for i, r in ipairs(R) do
    c:fill(c:rect(0, r[1], W - 1, r[2]), r[3])
    if i > 1 then c:fill(c:rect(0, r[1], W - 1, r[1]), R[i - 1][3] == r[3] and r[4] or DOWN[R[i - 1][3]] or r[4]) end
    for x = r[5], W - 1, 52 do c:fill(c:rect(x, r[1] + 1, x, r[2]), r[4]) end
  end

  -- window: view first (sky bands, hill, cloud), then the frame, sill and pane contours
  local view = c:rect(15, 9, 53, 29)
  c:bands(view, { SKY.hi, SKY.lo, SKY.lo })
  local hill = c:ellipse(23, 33, 15, 7):add(c:ellipse(48, 34, 14, 7)):clip(view)
  c:fill(hill, SKY.hill)
  hill:each(function(x, y) if not hill:has(x - 1, y - 1) then c:px(x, y, SKY.hillS) end end)
  c:fill(c:rrect(20, 20, 28, 22, 1):add(c:rect(22, 19, 25, 19)), SKY.cloud)
  local outer = c:rect(WIN.x0, WIN.y0, WIN.x1, WIN.y1)
  local frame = outer:copy()
  for _, p in ipairs(PANES) do frame:cut(c:rect(p[1], p[2], p[3], p[4])) end
  c:part(frame, GREEN, { light = outer, cres = 3, gloss = { 14, 7 }, outline = false })
  c:outline(outer)
  for _, p in ipairs(PANES) do                                       -- 1 px inner contour, glass glint
    local pm = c:rect(p[1], p[2], p[3], p[4])
    pm:edge():each(function(x, y) c:px(x, y, (y == p[2] or x == p[1]) and C.ol2 or C.ol3) end)
    c:paint({ ".gg", "g.." }, p[1] + 2, p[2] + 2, { g = SKY.cloud })
  end
  -- sill (wood ledge) and a terracotta pot with a sprig on its left end
  c:part(c:rrect(7, 32, 61, 36, 1), WOODR, { cres = 2, gloss = false })
  c:part(c:ellipse(17, 25, 2, 2):add(c:ellipse(20, 24, 2, 2.5)), GREEN, { cres = 2, gloss = false })
  c:part(c:rrect(16, 28, 21, 32, 1):add(c:rect(15, 28, 22, 29)), TERRA, { cres = 2, gloss = false })

  -- framed fish picture on a nail
  c:fill(c:line({ { 87 + PX, 4 }, { 78 + PX, 10 } }, 1):add(c:line({ { 87 + PX, 4 }, { 96 + PX, 10 } }, 1)), C.ol2)
  local pic = c:rect(74 + PX, 9, 100 + PX, 28)
  local inner = c:rect(78 + PX, 13, 96 + PX, 24)
  c:part(pic:copy():cut(inner), GOLD, { light = pic, cres = 3, gloss = false, outline = false })
  c:outline(pic)
  c:fill(inner, WAIN.rim)
  inner:edge():each(function(x, y) c:px(x, y, (y == 13 or x == 78 + PX) and C.ol2 or WAIN.base) end)
  local fish = c:ellipse(86 + PX, 18.5, 5, 3):add(c:poly({ { 90 + PX, 18 }, { 95 + PX, 15 }, { 95 + PX, 23 } }))
  c:fill(fish, TERRA.base)
  fish:each(function(x, y) if not fish:has(x + 1, y + 1) then c:px(x, y, TERRA.shade) end end)
  c:px(83 + PX, 17, C.ol3); c:px(85 + PX, 16, TERRA.rim); c:px(86 + PX, 16, TERRA.rim)

  -- low cupboard: floor shadow, body, top board, two cubbies (books; yarn), feet
  for x = SHELF.x0 - 1, SHELF.x1 + 4 do for y = 63, 66 do
    if y <= 64 or x >= SHELF.x0 + 3 then local h = c:get(x, y) c:px(x, y, DOWN[h] or h) end
  end end
  local body = c:rect(SHELF.x0, SHELF.y0, SHELF.x1, SHELF.y1)
  local top = c:rrect(SHELF.x0 - 3, SHELF.y0 - 3, SHELF.x1 + 3, SHELF.y0, 1)
  local X = SHELF.x0 - 112                                            -- cupboard details were drawn at x0 = 112
  local cub1, cub2 = c:rect(116 + X, 45, 131 + X, 59), c:rect(135 + X, 45, 150 + X, 59)
  c:part(body:copy():cut(cub1):cut(cub2), WOODR, { light = body, cres = 4, gloss = false })
  c:part(top, WOODR, { cres = 2, gloss = false })
  for _, m in ipairs({ cub1, cub2 }) do
    c:fill(m, WOOD.deep)
    local x0, y0, x1 = m:bbox()
    c:fill(c:rect(x0, y0, x1, y0), C.ol3)                            -- shadow under the shelf board
  end
  c:part(c:rect(118 + X, 49, 120 + X, 59), GREEN, { flat = true, outline = false })   -- books, 1 px gaps
  c:part(c:rect(122 + X, 47, 124 + X, 59), WAIN, { flat = true, outline = false })
  c:part(c:rect(126 + X, 50, 128 + X, 59), PINK, { flat = true, outline = false })
  c:fill(c:rect(118 + X, 52, 120 + X, 52), GOLD.rim); c:fill(c:rect(122 + X, 50, 124 + X, 50), GOLD.rim)
  c:part(c:ellipse(142 + X, 54.5, 5, 4.5), PINK, { cres = 3, gloss = false, outline = false })   -- yarn ball
  c:fill(c:line({ { 139 + X, 51 }, { 145 + X, 57 } }, 1):add(c:line({ { 138 + X, 54 }, { 142 + X, 58 } }, 1)), PINK.shade)
  -- yarn basket on top (the wall right of the cupboard stays clear for the scratch post overlay)
  local bask = c:rrect(118 + X, 29, 136 + X, 36, 2)
  c:part(c:ellipse(122 + X, 28, 3.5, 3.5), WAIN, { cres = 2, gloss = false })
  c:part(c:ellipse(129 + X, 27, 4, 4), PINK, { cres = 2, gloss = false })
  c:part(bask, GOLD, { cres = 2, gloss = false })
  for x = 120 + X, 134 + X, 3 do c:fill(c:rect(x, 31, x, 34), GOLD.shade) end
  c:seam({ { 119 + X, 30 }, { 135 + X, 30 } }, { gap = GOLD.shade })

  -- floor cushion, back left: floor shadow, then a round pink cushion with a button and an edge stitch
  c:ellipse(18, 68, 15, 2.5):each(function(x, y) local h = c:get(x, y) c:px(x, y, DOWN[h] or h) end)
  local cush = c:ellipse(16, 62, 13, 6)
  c:part(cush, PINK, { cres = 4, gloss = { 8, 59 }, stitch = true })
  for _, l in ipairs({ { { 9, 62 }, { 13, 63 } }, { { 19, 63 }, { 23, 62 } }, { { 16, 65 }, { 16, 66 } } }) do
    c:fill(c:line(l, 1), PINK.shade)                                 -- tufted creases from the button
  end
  c:button(15, 61)
end

-------------------------------------------------------------------------------- overlays
local base = canvas()
drawBase(base)
local function B(x, y) return base:get(x, y) end
local function relight(hex, step)                                    -- hue toward warm yellow, lighter
  local h, s, l = GV.hsl(hex)
  local d = ((45 - h + 540) % 360) - 180
  local a = 8 * step
  h = math.abs(d) <= a and 45 or h + (d > 0 and a or -a)
  return GV.fromHsl(h, math.min(1, s * 1.06 + 0.06 * step), l + (1 - l) * (0.2 * step))
end
local function shadow(c, m) m:each(function(x, y) local h = B(x, y) c:px(x, y, DOWN[h] or relight(h, -1)) end) end

local overlays = {}

overlays.sunbeam = function(c)
  -- shaft on the wall under the sill: the panes' width, slanting down-right (light from the upper left).
  -- 2 px edges one step, core two steps, the mullion's shadow a slanted one-step bar through it
  local shaft = c:poly({ { 15, 37 }, { 54, 37 }, { 65, 62 }, { 26, 62 } })
  local sCore = c:poly({ { 18, 37 }, { 51, 37 }, { 62, 62 }, { 29, 62 } })
  local sBar = c:line({ { 34.5, 37 }, { 45.5, 61 } }, 2)
  shaft:each(function(x, y)
    c:px(x, y, relight(B(x, y), (sCore:has(x, y) and not sBar:has(x, y)) and 2 or 1))
  end)
  -- floor patch: the window's image, skewed on; outer 2 px one step, inside two, mullion cross one
  local patch = c:poly({ { 26, 62 }, { 65, 62 }, { 75, 80 }, { 36, 80 } })
  local core = c:poly({ { 29, 64 }, { 62, 64 }, { 71, 78 }, { 39, 78 } })
  local bars = c:line({ { 45.5, 62 }, { 55.5, 79 } }, 3):add(c:rect(30, 70, 72, 71))
  patch:each(function(x, y)
    local step = (core:has(x, y) and not bars:has(x, y)) and 2 or 1
    c:px(x, y, relight(B(x, y), step))
  end)
end

overlays.rug = function(c)
  local m = c:ellipse(RUG.cx, RUG.cy, RUG.rx, RUG.ry)
  local side = m:shift(0, 1):cut(m)
  shadow(c, m:shift(1, 2):cut(m):cut(side))
  c:fill(side, "#2f5a2a")
  local fr = c:mask()                                                -- cream fringe at both ends
  for _, y in ipairs({ 85, 88, 91 }) do fr:add(c:rect(38, y, 40, y)):add(c:rect(128, y, 130, y)) end
  c:fill(fr, "#e8d0a0")
  local P = c:part(m, GREEN, { cres = 3, gloss = { 62, 82 }, outline = false })
  local band = c:ellipse(RUG.cx, RUG.cy, 32, 5):cut(c:ellipse(RUG.cx, RUG.cy, 29, 3.5))
  band:each(function(x, y) c:px(x, y, (x - RUG.cx) + 4 * (y - RUG.cy) > 14 and "#c49a60" or "#e8d0a0") end)
  -- gold hem stitch 1 px inside the edge, 2 on / 1 off along the ring
  local ring = m:shrink(1):edge()
  local pts = {}
  ring:each(function(x, y) pts[#pts + 1] = { x, y, math.atan(((y - RUG.cy) / RUG.ry), ((x - RUG.cx) / RUG.rx)) } end)
  table.sort(pts, function(a, b) return a[3] < b[3] end)
  for i, p in ipairs(pts) do
    if i % 3 ~= 0 and not c.gl.s[c:key(p[1], p[2])] then c:px(p[1], p[2], c.shd[c:key(p[1], p[2])] and C.goldS or C.gold) end
  end
  return P
end

overlays.scratch = function(c)
  -- stands on its own against the bare wall right of the cupboard (x 138..158), cap below its top board, shorter than the wall
  shadow(c, c:ellipse(148, 97, 13, 2.5))
  local SI = felt("#d9b46a", { gloss = "#f0d08a", dot = "#f0d08a", rim = "#f0d08a", shade = "#a8783a" })
  local postm = c:rect(144, 54, 151, 91)
  local p = c:build{
    { "post", postm, SI, { cres = 3, gloss = false } },
    { "base", c:rrect(138, 90, 158, 96, 2), GREEN, { cres = 3, gloss = { 141, 91 } } },
    { "cap", c:rrect(140, 50, 155, 55, 2), GREEN, { cres = 2, gloss = { 142, 51 } } },
  }
  for y0 = 57, 88, 3 do                                              -- rope wraps: shade groove, lit ridge above
    for x = 144, 151 do
      local y = y0 + math.floor((x - 144) / 4)
      if c.own[c:key(x, y)] == p.post then c:px(x, y, SI.shade) end
      local k2 = c:key(x, y - 1)
      if c.own[k2] == p.post and not c.shd[k2] then c:px(x, y - 1, SI.rim) end
    end
  end
  c:seam({ { 140, 93 }, { 156, 93 } }, { gap = GREEN.shade })
  local cord = c:line({ { 154, 56 }, { 155, 62 } }, 1)
  c:fill(cord, "#a8783a")
  c:part(c:ellipse(155.5, 65, 2.5, 2.5), PINK, { cres = 2, gloss = false })
  c:px(154, 64, PINK.rim)
end

overlays.window = function(c)
  -- robin outside, seen through the lower-right pane, perched on the bottom bar (fills the glass,
  -- x 37..52, y 17..28): round brown back, orange face and breast, cream belly, tail cocked up to the left
  local robin = {
    ".........uuuu...",
    "........urrrhu..",
    ".......urrhhhhu.",
    ".......uhOOOeOkk",
    "uuu....uOOOOOOu.",
    "urhu..uhOOOooou.",
    ".urhuuhhOOoooou.",
    "..urhhhhhOooocu.",
    "...ushhhhhoocccu",
    "....usssshhcccu.",
    ".....uusssssuu..",
    ".........u..u...",
  }
  for _, r in ipairs(robin) do assert(#r == 16) end
  c:paint(robin, 37, 17, { u = "ol3", r = "#c98a4a", h = "#9a6b3f", s = "#7a4a1f", O = "#f08a24", o = "#e0501f",
                           e = "ol3", k = "#e8a317", c = "#e8d0a0" })
end

-------------------------------------------------------------------------------- save
local function report(name, t) print(name .. ": " .. GV.report(t)) end
report("cf-room", base:save(OUT .. "cf-room.aseprite", OUT .. "cf-room.png"))
for _, key in ipairs({ "sunbeam", "rug", "scratch", "window" }) do
  local c = canvas()
  overlays[key](c)
  report("cf-room-" .. key, c:save(OUT .. "cf-room-" .. key .. ".aseprite", OUT .. "cf-room-" .. key .. ".png"))
end

-- cf_room.lua : Cat Fish room scene and its 4 upgrade overlays (claude/catfish-art-brief.md), v2 layout:
-- the room IS the whole play scene. Code draws a 64 x 64 cat on the floor centre, a toy wand hung from the
-- ceiling hook, a fishing line and 3 dangling 48 x 48 plush fish over this art; side cats sit at the edges.
-- Stitched Toy, gvlib "scene" mode (art-style-guide Part D + Part E): drawn on a 160 x 100 grid, written at 2x
-- nearest (320 x 200), no black border, three-tone umber outline on raised objects only, one crescent per object,
-- stepped bands (no gradients, no dither), day light from the upper left (the window).
-- Run: AppRun -b --script cf_room.lua        Writes test/cf-room.png and test/cf-room-<key>.png (+ .aseprite).
--   cf-room.png           base, opaque, <= 32 colours. Left: a small sash window running off the edge (warm
--                         sky, valance on a rod, warm wall glow round it), a pink tufted cushion and a blue yarn ball
--                         on the floor. Top: wood crown with a brass cup hook and a pink thread knot (wand anchor).
--                         Right: a wall shelf (plant, books), a small framed fish picture under it, a terracotta food
--                         bowl on the floor. Middle: calm striped wallpaper, blue wainscot, honey planks with wear.
--   cf-room-sunbeam.png   window light: a slanted shaft under the sill (one step) and a window-shaped patch on the
--                         floor behind the rug (two steps, bar and mullion shadows). Relights the base pixels.
--   cf-room-rug.png       flat green felt oval under the active cat, cream braid, gold hem stitch, cream fringe.
--   cf-room-scratch.png   sisal scratch post on a green base at the far right, cap, pink pompom, floor shadow.
--   cf-room-window.png    a small robin perched on the bottom bar of the lower pane, clipped to the glass.
-- Overlays are 320 x 200, alpha 0/255, never share a pixel, never cover a base object (any stacking order works).
-- Layout for code (exported px, also in room-layout.json): wand hook knot (66, 12); play zone x 70..250,
-- y 120..190 (no furniture); calm upper wall x 40..280, y 0..70; cat feet line y 184.
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

-------------------------------------------------------------------------------- palette (base: 30 colours)
local WOOD  = { rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#5e2f1e" }
local FLOOR = { b = "#d9a660", m = "#c78d52", d = "#b07a45" }       -- plank rows, front to back
local WALL  = { base = "#f2dfb6", stripe = "#e8cc98", glow = "#f8e8c4", far = "#dcbc88" }
local WAIN  = { rim = "#b9cfd9", base = "#8eaabf", shade = "#6f8aa8", deep = "#6f8aa8", bounce = "#8eaabf",
                gloss = "#b9cfd9", dot = "#b9cfd9" }
local GREEN = felt("#5f9e48", { rim = "#8cc064", shade = "#3f7a3a", gloss = "#c8e08a", dot = "#c8e08a" })
local SKY   = { hi = "#c8e8f4", lo = "#9ccfe8", hill = "#8cc064", hillS = "#5f9e48", cloud = "#f1ece0" }
local PINK  = felt("#e46a9b", { rim = "#f29abb", shade = "#b8466e", gloss = "#f29abb", dot = "#f29abb" })
local GOLD  = felt("#e8a317", { rim = "#f5cf6a", shade = "#b8661a", gloss = "#f5cf6a", dot = "#f5cf6a" })
local TERRA = felt("#c8643c", { rim = "#e08a5a", shade = "#8a4f2a", gloss = "#e08a5a", dot = "#e08a5a" })
local WOODR = felt(WOOD.base, { rim = WOOD.rim, shade = WOOD.shade, gloss = WOOD.rim, dot = WOOD.rim })
-- one step darker on the floor (contact shadows), shared by base and overlays
local DOWN = { [FLOOR.b] = FLOOR.m, [FLOOR.m] = FLOOR.d, [FLOOR.d] = WOOD.shade, [WOOD.shade] = WOOD.deep,
               [WOOD.base] = WOOD.shade, [C.ol1] = C.ol2, [C.ol2] = C.ol3 }

-------------------------------------------------------------------------------- geometry (grid px; export = x2)
local WIN   = { x0 = -4, y0 = 8, x1 = 13, y1 = 34 }                   -- window frame, runs off the left edge
local PANES = { { -1, 12, 3, 19 }, { 6, 12, 10, 19 }, { -1, 23, 10, 31 } }   -- two top lights, one lower sash
local HOOK  = { x = 33, y = 3 }                                        -- cup hook under the crown; knot at y 6
local CUSH  = { cx = 15, cy = 89, rx = 14, ry = 4.5 }                  -- nap cat lies on it (front left)
local YARN  = { cx = 33, cy = 93, r = 3 }
local BOWL  = { x0 = 142, x1 = 155, y0 = 92, y1 = 98 }                 -- food bowl, front right
local SHELF = { x0 = 140, x1 = 159, y = 16 }                           -- wall shelf board (top row)
local PIC   = { x0 = 142, y0 = 22, x1 = 157, y1 = 35 }                 -- framed picture under the shelf
local RUG   = { cx = 80, cy = 91.5, rx = 38, ry = 6 }

-- outline that stays out of `keep` (e.g. the glass) : same tones as c:outline
local function outlineOut(c, m, keep)
  local g1, g2 = m:grow(c.ol), m:grow(c.ol + c.olx)
  g2:each(function(x, y)
    if not m:has(x, y) and not keep:has(x, y) and (g1:has(x, y) or c:s(x, y) > c.tx) then c:px(x, y, c:tone(x, y)) end
  end)
end
-- small-prop outline, lit per object: `ol` px all round (+1 on the object's lower right), three umber tones by
-- the object's own light side. Drawn BEFORE the parts of a group so neighbours never paint over each other.
local function propOutline(c, m, ol, keep)
  ol = ol or 1
  local x0, y0, x1, y1 = m:bbox()
  local mcx, mcy, r = (x0 + x1) / 2, (y0 + y1) / 2, ((x1 - x0) + (y1 - y0)) / 2
  local g1, g2 = m:grow(ol), m:grow(ol + 1)
  g2:each(function(x, y)
    local s = (x - mcx) + (y - mcy)
    if not m:has(x, y) and not (keep and keep:has(x, y)) and (g1:has(x, y) or s > r * 0.35) then
      c:px(x, y, s < -r * 0.45 and C.ol1 or (s < r * 0.1 and C.ol2 or C.ol3))
    end
  end)
end

-------------------------------------------------------------------------------- base
local glass = nil
local function drawBase(c)
  -- wallpaper, soft stripes, crown shadow row, then one warm stepped glow band round the window
  c:fill(c:rect(0, 0, W - 1, 40), WALL.base)
  for x = 0, W - 1 do if x % 12 == 4 or x % 12 == 5 then c:fill(c:rect(x, 4, x, 34), WALL.stripe) end end
  rows(c, 0, { WOOD.rim, WOOD.base, WOOD.shade, C.ol1, WALL.stripe })
  c:rect(0, 5, 27, 34):each(function(x, y)
    local h = c:get(x, y)
    c:px(x, y, h == WALL.base and WALL.glow or (h == WALL.stripe and WALL.base or h))
  end)
  c:rect(138, 5, W - 1, 34):each(function(x, y)                     -- far right, away from the window: one step down
    local h = c:get(x, y)
    c:px(x, y, h == WALL.base and WALL.stripe or (h == WALL.stripe and WALL.far or h))
  end)
  -- chair rail, wainscot, skirting: stepped rows lit from above
  rows(c, 35, { C.ol1, WOOD.rim, WOOD.base, WOOD.shade, C.ol2, WAIN.shade })
  c:fill(c:rect(0, 41, W - 1, 55), WAIN.base)
  for x0 = 0, W - 1, 20 do                                           -- recessed panels: dark top/left, lit bottom/right
    c:fill(c:rect(x0 + 3, 44, x0 + 3, 52), WAIN.shade); c:fill(c:rect(x0 + 3, 44, x0 + 16, 44), WAIN.shade)
    c:fill(c:rect(x0 + 4, 52, x0 + 16, 52), WAIN.rim); c:fill(c:rect(x0 + 16, 45, x0 + 16, 52), WAIN.rim)
  end
  rows(c, 56, { C.ol2, WOOD.rim, WOOD.base, WOOD.base, WOOD.shade, C.ol3 })
  -- floor: plank rows in stepped bands (back row darkest), 1 px seams, staggered joints with nail heads
  local R = { { 62, 66, FLOOR.d, WOOD.shade, 10 }, { 67, 72, FLOOR.m, FLOOR.d, 34 }, { 73, 80, FLOOR.b, FLOOR.m, 22 },
              { 81, 89, FLOOR.b, FLOOR.m, 46 }, { 90, 99, FLOOR.b, FLOOR.m, 4 } }
  for i, r in ipairs(R) do
    c:fill(c:rect(0, r[1], W - 1, r[2]), r[3])
    if i > 1 then c:fill(c:rect(0, r[1], W - 1, r[1]), R[i - 1][3] == r[3] and r[4] or DOWN[R[i - 1][3]] or r[4]) end
    for x = r[5], W - 1, 52 do
      c:fill(c:rect(x, r[1] + 1, x, r[2]), r[4])
      c:px(x - 2, r[1] + 2, DOWN[r[3]]); c:px(x + 2, r[2] - 1, DOWN[r[3]])   -- nail heads either side of the joint
    end
  end
  -- plank wear: scuffs (one step down), worn light streaks on the back rows, a few knots
  local scuff = { { 20, 64, 4, "l" }, { 98, 65, 3, "l" }, { 132, 63, 3, "l" },
                  { 8, 69, 3 }, { 58, 70, 4 }, { 112, 68, 3 }, { 148, 71, 2 },
                  { 14, 76, 4 }, { 70, 78, 3 }, { 128, 75, 5 }, { 92, 74, 2 },
                  { 60, 84, 3 }, { 102, 87, 4 }, { 140, 83, 3 }, { 24, 82, 3 },
                  { 52, 96, 4 }, { 88, 98, 3 }, { 122, 94, 4 } }
  for _, s in ipairs(scuff) do
    for x = s[1], s[1] + s[3] - 1 do
      local h = c:get(x, s[2])
      c:px(x, s[2], s[4] == "l" and (h == FLOOR.d and FLOOR.m or FLOOR.b) or (DOWN[h] or h))
    end
  end
  for _, k in ipairs({ { 86, 68 }, { 40, 76 }, { 116, 85 } }) do      -- knots: dark eye in a one-step ring
    local h = c:get(k[1], k[2])
    local ring, eye = DOWN[h], DOWN[DOWN[h]] or DOWN[h]
    c:paint({ "reer" }, k[1] - 1, k[2], { r = ring, e = eye })
  end

  -- window: view (warm sky bands, hills, cloud), then the frame, valance and rod, sill, pane contours
  local view = c:rect(-1, 12, 10, 31)
  c:bands(view, { SKY.hi, SKY.hi, SKY.lo, SKY.lo, SKY.cloud })
  local hill = c:ellipse(1, 33, 9, 5):add(c:ellipse(11, 34, 7, 6)):clip(view)
  c:fill(hill, SKY.hill)
  hill:each(function(x, y) if not hill:has(x - 1, y - 1) then c:px(x, y, SKY.hillS) end end)
  c:fill(c:rrect(1, 14, 6, 15, 1):add(c:rect(2, 13, 4, 13)), SKY.cloud)
  local outer = c:rect(WIN.x0, WIN.y0, WIN.x1, WIN.y1)
  local frame = outer:copy()
  glass = c:mask()
  for _, p in ipairs(PANES) do glass:add(c:rect(p[1], p[2], p[3], p[4])) end
  frame:cut(glass)
  c:part(frame, GREEN, { light = outer, cres = 3, gloss = false, outline = false })
  c:outline(outer)
  -- sill: a wood ledge on the chair rail
  c:part(c:rrect(0, 34, 15, 38, 1), WOODR, { cres = 2, gloss = false })
  -- curtain rod (wood, gold finial) and a scalloped terracotta valance with a gold hem stitch
  local rod = c:rect(0, 5, 15, 6)
  c:part(rod, WOODR, { flat = true, outline = false })
  outlineOut(c, rod, glass:copy():add(c:rect(0, 8, 13, 13)))
  c:part(c:ellipse(16.5, 5.5, 1.5, 1.5), GOLD, { flat = true, outline = false })
  local val = c:rect(0, 7, 13, 10)
  for x = 0, 13 do if x % 4 ~= 3 then val:set(x, 11) end end
  c:part(val, TERRA, { cres = 2, gloss = false, outline = false })
  outlineOut(c, val, glass)
  for x = 0, 13 do if x % 4 == 2 then c:px(x, 11, TERRA.shade) elseif x % 4 == 3 then c:px(x, 10, TERRA.shade) end end
  c:fill(c:rect(0, 7, 13, 7), TERRA.rim)
  for _, p in ipairs(PANES) do                                       -- 1 px inner contour, glass glint
    local pm = c:rect(p[1], p[2], p[3], p[4])
    pm:edge():each(function(x, y) c:px(x, y, (y == p[2] or x == p[1]) and C.ol2 or C.ol3) end)
    c:paint({ ".gg", "g.." }, math.max(p[1], 0) + 1, p[2] + 2, { g = SKY.cloud })
  end

  -- ceiling cup hook with a pink thread knot: the wand hangs from the knot (export 66, 12)
  c:paint({ ".gGGs", ".G.G.", "..s..", ".pPq.", ".p.q." }, HOOK.x - 2, HOOK.y,
          { g = GOLD.rim, G = GOLD.base, s = GOLD.shade, P = PINK.base, p = PINK.rim, q = PINK.shade })

  -- right wall: shelf with a potted plant and books, picture under it. Small props get a 1 px per-object
  -- outline drawn first, then their fills, so neighbours never paint over each other.
  local plant = { "..g..g..", ".gGg.Gs.", "gGGsgGGs", ".gGsGGs.", "..sGGs..",
                  "rrTTTTTs", ".rTTTTs.", ".rTTTss.", ".rTTTss.", "..rTss.." }
  local books = { "gg......", "Gg..pp..", "gg..Pp..", "ggbbpp..", "Ggbbpp..", "ggBbPp..", "ggbbpp..", "ggbbpp.." }
  local plantM, booksM = c:ascii(plant, 141, 6), c:ascii(books, 151, 8)
  local shelfM = c:rrect(SHELF.x0, SHELF.y, SHELF.x1 + 2, SHELF.y + 2, 1)
  propOutline(c, shelfM)
  propOutline(c, plantM); propOutline(c, booksM)
  c:part(shelfM, WOODR, { cres = 2, gloss = false, outline = false })
  c:paint(plant, 141, 6, { g = GREEN.rim, G = GREEN.base, s = GREEN.shade, r = TERRA.rim, T = TERRA.base, t = TERRA.shade })
  c:paint(c:get(141, 11) and { "........", "........", "........", "........", "........", "...gg..." } or {}, 141, 6,
          { g = GOLD.rim })                                          -- gold band on the pot
  c:paint(books, 151, 8, { g = GREEN.rim, G = GOLD.rim, b = WAIN.base, B = GOLD.rim, p = PINK.base, P = GOLD.rim })
  for y = 8, 15 do if c:get(152, y) == GREEN.rim then c:px(152, y, GREEN.base) end end
  for y = 10, 15 do if c:get(154, y) == WAIN.base then c:px(154, y, WAIN.shade) end end
  for y = 9, 15 do if c:get(156, y) == PINK.base then c:px(156, y, PINK.shade) end end
  for y = 10, 15 do if c:get(153, y) == WAIN.base then c:px(153, y, WAIN.rim) end end
  for y = 9, 15 do if c:get(155, y) == PINK.base then c:px(155, y, PINK.rim) end end

  local pic = c:rect(PIC.x0, PIC.y0, PIC.x1, PIC.y1)
  local inner = c:rect(PIC.x0 + 2, PIC.y0 + 2, PIC.x1 - 2, PIC.y1 - 2)
  propOutline(c, pic)
  c:part(pic:copy():cut(inner), GOLD, { light = pic, cres = 2, gloss = false, outline = false })
  c:fill(inner, WAIN.rim)
  inner:edge():each(function(x, y) c:px(x, y, (y == PIC.y0 + 2 or x == PIC.x0 + 2) and C.ol2 or WAIN.base) end)
  local FX, FY = PIC.x0 + 6, (PIC.y0 + PIC.y1) / 2
  local fish = c:ellipse(FX, FY, 3, 2):add(c:poly({ { FX + 2, FY - 0.5 }, { FX + 6, FY - 3 }, { FX + 6, FY + 3 } }))
  c:fill(fish, TERRA.base)
  fish:each(function(x, y) if not fish:has(x + 1, y + 1) then c:px(x, y, TERRA.shade) end end)
  c:px(FX - 2, math.floor(FY), C.ol3); c:px(FX - 1, math.floor(FY) - 1, TERRA.rim); c:px(FX, math.floor(FY) - 1, TERRA.rim)

  -- floor, front left: pink tufted cushion (side band with a hem seam), blue yarn ball with a loose thread
  c:ellipse(CUSH.cx + 2, CUSH.cy + 7, CUSH.rx + 1, 1.5):each(function(x, y) local h = c:get(x, y) c:px(x, y, DOWN[h] or h) end)
  local top = c:ellipse(CUSH.cx, CUSH.cy, CUSH.rx, CUSH.ry)
  local side = top:shift(0, 2):add(top:shift(0, 1)):cut(top)
  local cushM = top:copy():add(side)
  propOutline(c, cushM, 2)
  c:part(cushM, PINK, { cres = 3, gloss = false, outline = false })
  c:fill(side, PINK.shade)
  side:each(function(x, y) if not cushM:has(x, y + 1) then c:px(x, y, PINK.deep == PINK.shade and "#8a3a5a" or PINK.deep) end end)
  c:seam({ { CUSH.cx - 13, CUSH.cy + 4 }, { CUSH.cx - 6, CUSH.cy + 6 }, { CUSH.cx + 6, CUSH.cy + 6 },
           { CUSH.cx + 13, CUSH.cy + 4 } }, { gap = PINK.shade })
  c:stitch(top)
  c:gloss(top, PINK, { 8, 86 })
  for _, l in ipairs({ { { 6, 88 }, { 11, 89 } }, { { 18, 89 }, { 23, 88 } }, { { 15, 91 }, { 15, 92 } } }) do
    c:fill(c:line(l, 1), PINK.shade)                                 -- tufted creases from the button
  end
  c:button(13, 87)

  c:fill(c:line({ { 30, 96 }, { 27, 97 }, { 23, 97 }, { 20, 98 } }, 1), WAIN.shade)   -- loose thread
  c:ellipse(YARN.cx + 1, YARN.cy + 3.5, 4, 1):each(function(x, y) local h = c:get(x, y) c:px(x, y, DOWN[h] or h) end)
  local yarn = c:ellipse(YARN.cx, YARN.cy, YARN.r, YARN.r)
  propOutline(c, yarn)
  c:part(yarn, WAIN, { cres = 2, gloss = false, outline = false })
  for _, l in ipairs({ { { 31, 91 }, { 35, 95 } }, { { 30, 93 }, { 33, 96 } }, { { 33, 90 }, { 36, 93 } } }) do
    c:line(l, 1):clip(yarn):each(function(x, y) c:px(x, y, WAIN.shade) end)
  end
  c:px(31, 91, WAIN.rim); c:px(32, 90, WAIN.rim)

  -- floor, front right: terracotta food bowl, kibble heap, a cream fish on the front
  local BX = (BOWL.x0 + BOWL.x1) / 2
  c:ellipse(BX + 1, BOWL.y1 + 1, 8, 1):each(function(x, y) local h = c:get(x, y) c:px(x, y, DOWN[h] or h) end)
  local bowl = c:poly({ { BOWL.x0, BOWL.y0 + 1 }, { BOWL.x1 + 1, BOWL.y0 + 1 }, { BOWL.x1 - 2, BOWL.y1 + 1 },
                         { BOWL.x0 + 3, BOWL.y1 + 1 } }):add(c:ellipse(BX, BOWL.y0 + 1, 6.5, 1.5))
  local heap = c:ascii({ "..kkkk..", ".kkkkkk.", "kkkkkkkk" }, BOWL.x0 + 3, BOWL.y0 - 2)
  propOutline(c, bowl:copy():add(heap), 2)
  c:part(bowl, TERRA, { cres = 3, gloss = false, outline = false })
  c:fill(c:ellipse(BX, BOWL.y0 + 0.5, 5, 1), TERRA.shade)            -- opening
  c:paint({ "..kKkK..", ".kKkkKk.", "kKkKkkKk" }, BOWL.x0 + 3, BOWL.y0 - 2, { k = WOOD.rim, K = WOOD.base })
  c:fill(c:rect(BOWL.x0 + 1, BOWL.y0 + 3, BOWL.x1 - 1, BOWL.y0 + 3), TERRA.rim)       -- glazed band
  c:paint({ ".cc.c", "cccc.", ".cc.c" }, math.floor(BX) - 2, BOWL.y0 + 4, { c = SKY.cloud })   -- fish emblem
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

local rugMask = base:ellipse(RUG.cx, RUG.cy, RUG.rx, RUG.ry)
local overlays = {}

overlays.sunbeam = function(c)
  -- shaft under the sill, widening down-right (light from the upper left): 2 px edges one step, core two steps,
  -- the sash bar's shadow a slanted one-step band through it
  local shaft = c:poly({ { 3, 39 }, { 17, 39 }, { 92, 62 }, { 54, 62 } })
  local sCore = c:poly({ { 6, 39 }, { 14, 39 }, { 88, 62 }, { 58, 62 } })
  local sBar = c:poly({ { 9, 39 }, { 11, 39 }, { 76, 62 }, { 71, 62 } })
  shaft:each(function(x, y)
    c:px(x, y, relight(B(x, y), (sCore:has(x, y) and not sBar:has(x, y)) and 2 or 1))
  end)
  -- floor patch behind the rug: the window's image laid on the planks; back half = lower sash, front half = the
  -- two top lights split by the mullion; outer 2 px one step, glass two steps, bar and mullion one step
  local patch = c:poly({ { 54, 62 }, { 92, 62 }, { 120, 84 }, { 80, 84 } })
  patch:cut(rugMask:grow(2))
  local core = c:poly({ { 58, 64 }, { 89, 64 }, { 114, 83 }, { 85, 83 } })
  local bars = c:rect(0, 71, W - 1, 72):add(c:line({ { 84.5, 73 }, { 97.5, 83 } }, 2))
  patch:each(function(x, y)
    c:px(x, y, relight(B(x, y), (core:has(x, y) and not bars:has(x, y)) and 2 or 1))
  end)
end

overlays.rug = function(c)
  local m = c:ellipse(RUG.cx, RUG.cy, RUG.rx, RUG.ry)
  local side = m:shift(0, 1):cut(m)
  shadow(c, m:shift(1, 2):cut(m):cut(side))
  c:fill(side, "#2f5a2a")
  local fr = c:mask()                                                -- cream fringe at both ends
  for _, y in ipairs({ 89, 92, 95 }) do fr:add(c:rect(RUG.cx - RUG.rx - 2, y, RUG.cx - RUG.rx - 1, y))
                                         :add(c:rect(RUG.cx + RUG.rx + 1, y, RUG.cx + RUG.rx + 2, y)) end
  c:fill(fr:cut(m), "#e8d0a0")
  local P = c:part(m, GREEN, { cres = 3, gloss = { RUG.cx - 22, RUG.cy - 4 }, outline = false })
  local band = c:ellipse(RUG.cx, RUG.cy, 30, 4.5):cut(c:ellipse(RUG.cx, RUG.cy, 27, 3))
  band:each(function(x, y) c:px(x, y, (x - RUG.cx) + 4 * (y - RUG.cy) > 14 and "#c49a60" or "#e8d0a0") end)
  -- little cream cross-stitches in the centre field, kept off the cat's feet line (y 92)
  for _, p in ipairs({ { RUG.cx - 12, RUG.cy - 1 }, { RUG.cx + 12, RUG.cy - 1 } }) do
    c:paint({ "c.c", ".c.", "c.c" }, p[1] - 1, p[2] - 2, { c = "#e8d0a0" })
  end
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
  -- far right, in front of the wainscot under the picture; stays clear of the bowl (front right)
  local keep = base:rect(BOWL.x0 - 3, BOWL.y0 - 3, W - 1, H - 1)
  shadow(c, c:ellipse(151, 89, 10, 1.5):cut(keep))
  local SI = felt("#d9b46a", { gloss = "#f0d08a", dot = "#f0d08a", rim = "#f0d08a", shade = "#a8783a" })
  local postm = c:rect(147, 46, 154, 84)
  local p = c:build{
    { "post", postm, SI, { cres = 3, gloss = false } },
    { "base", c:rrect(141, 83, 160, 88, 2), GREEN, { cres = 3, gloss = { 144, 84 } } },
    { "cap", c:rrect(143, 42, 158, 47, 2), GREEN, { cres = 2, gloss = { 145, 43 } } },
  }
  for y0 = 49, 81, 3 do                                              -- rope wraps: shade groove, lit ridge above
    for x = 147, 154 do
      local y = y0 + math.floor((x - 147) / 4)
      if c.own[c:key(x, y)] == p.post then c:px(x, y, SI.shade) end
      local k2 = c:key(x, y - 1)
      if c.own[k2] == p.post and not c.shd[k2] then c:px(x, y - 1, SI.rim) end
    end
  end
  c:seam({ { 143, 85 }, { 158, 85 } }, { gap = GREEN.shade })
  c:fill(c:line({ { 157, 48 }, { 157, 53 } }, 1), "#a8783a")
  c:part(c:ellipse(157.5, 56, 2, 2), PINK, { cres = 2, gloss = false })
  c:px(157, 55, PINK.rim)
  -- the outline must not land on the bowl
  keep:each(function(x, y) c.pix[c:key(x, y)] = nil end)
end

overlays.window = function(c)
  -- robin outside, in the lower sash (x 0..10, y 23..31), perched on the bottom bar, facing right
  local robin = {
    "....uuuu..",
    "...urrhhu.",
    "..urhOeOkk",
    "u.uhOOOOu.",
    "ruuhOOoou.",
    ".rhhhOooou",
    "..ushhcccu",
    "...uussuu.",
  }
  for _, r in ipairs(robin) do assert(#r == 10) end
  c:paint(robin, 0, 23, { u = "ol3", r = "#c98a4a", h = "#9a6b3f", s = "#7a4a1f", O = "#f08a24", o = "#e0501f",
                          e = "ol3", k = "#e8a317", c = "#e8d0a0" })
  for k in pairs(c.pix) do local x, y = c:xy(k) if not glass:has(x, y) or not base:inside(x, y) then c.pix[k] = nil end end
end

-------------------------------------------------------------------------------- save
local function report(name, t) print(name .. ": " .. GV.report(t)) end
report("cf-room", base:save(OUT .. "cf-room.aseprite", OUT .. "cf-room.png"))
for _, key in ipairs({ "sunbeam", "rug", "scratch", "window" }) do
  local c = canvas()
  overlays[key](c)
  report("cf-room-" .. key, c:save(OUT .. "cf-room-" .. key .. ".aseprite", OUT .. "cf-room-" .. key .. ".png"))
end

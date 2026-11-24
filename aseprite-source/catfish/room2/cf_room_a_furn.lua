-- cf_room_a_furn.lua : Cat Fish room A P3 furniture cut-out sprites (room2/room_a_spec.md s3, s5).
-- Stitched Toy via gvlib scene mode, drawn on half grid (export size / 2), written 2x nearest.
-- Run: AppRun -b --script cf_room_a_furn.lua   -> room2/out_furn/cf-room2-<key>.png/.aseprite + furniture.json
-- One transparent PNG per piece at the spec's export size. Floor pieces carry a baked 1-bit contact shadow
-- (#9a6b3f = #4a2c1a at 35% on #c78d52; 0.8 x width ellipse, 4 px tall) on their bottom rows.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out_furn/"
local C = GV.C
local SHADOW = "#9a6b3f"

local function ramp(rim, base, shade)
  return { rim = rim, base = base, shade = shade, deep = shade, bounce = base, gloss = rim, dot = rim, pale = false }
end
local PINK  = ramp("#f29abb", "#e46a9b", "#b8466e")
local GREEN = ramp("#8cc064", "#5f9e48", "#3f7a3a")
local MOSS  = ramp("#a4b86a", "#7ab55c", "#4a8a3e")
local GOLD  = ramp(C.gold, C.goldS, "#b8661a")
local TERRA = ramp("#e08a5a", "#c8643c", "#8a4f2a")
local WOOD  = ramp("#d9a660", "#b07a45", "#8a4f2a")
local SISAL = ramp("#f0d08a", "#d9b46a", "#a8783a")
local BLUE  = ramp("#b9cfd9", "#8eaabf", "#6f8aa8")
local RED   = ramp("#f2793a", "#dd3a2a", "#ae2a2a")
local TEAL  = ramp("#8fcbd8", "#3f8fb0", "#2f6290")
local YEL   = ramp("#fff1c8", "#e8a317", "#b8661a")
local GREY  = ramp("#c9c5bc", "#8b8f96", "#5b6470")
local CREAM = "#f2e4c0"
local WEFT = "#4f8c41"

local items, FAILS = {}, {}

-- make(key, wE, hE, meta, fn): canvas of (wE/2 x hE/2) grid; fn(c, S) draws; S.part adds a felt part to the silhouette.
local function make(key, wE, hE, meta, fn)
  local c = GV.canvas{ w = wE // 2, h = hE // 2, mode = "scene", out = 2, ol = 1, olx = 1, cres = 2, deep = 2 }
  local sil = c:mask()
  local S = { w = wE // 2, h = hE // 2 }
  function S.part(m, r, o)
    o = o or {}; o.outline = false
    local P = c:part(m, r, o); sil:add(m); return P
  end
  function S.flat(m, hex) c:fill(m, hex); sil:add(m) end
  fn(c, S)
  if not meta.noline then
    local cy0 = c.cy
    for _, b in ipairs(meta.olbands or {}) do          -- {y0, y1, cy}: re-centre the outline tone per stacked part
      c.cy = b[3]
      local g1, g2 = sil:grow(c.ol), sil:grow(c.ol + c.olx)
      for k in pairs(g2.s) do
        local x, y = c:xy(k)
        if y >= b[1] and y <= b[2] and not sil.s[k] and c:inside(x, y) and not c.pix[k]
           and (g1.s[k] or c:s(x, y) > c.tx) then c.pix[k] = c:tone(x, y) end
      end
    end
    c.cy = cy0
    c:outline(sil, { keep = true })
    local D4 = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
    for _ = 1, 2 do                                    -- pinholes -> dark, stray outline px -> removed
      local fillL, killL = {}, {}
      for y = 0, S.h - 1 do for x = 0, S.w - 1 do
        local n, ns = 0, 0
        for _, d in ipairs(D4) do
          local nx, ny = x + d[1], y + d[2]
          if nx >= 0 and ny >= 0 and nx < S.w and ny < S.h then
            if c.pix[c:key(nx, ny)] then n = n + 1 end
            if sil:has(nx, ny) then ns = ns + 1 end
          end
        end
        local has = c.pix[c:key(x, y)]
        if not has and n >= 3 then fillL[#fillL + 1] = { x, y }
        elseif has and not sil:has(x, y) and n <= 1 and ns == 0 then killL[#killL + 1] = { x, y } end
      end end
      for _, p in ipairs(fillL) do c:px(p[1], p[2], "#2a1a10") end
      for _, p in ipairs(killL) do c.pix[c:key(p[1], p[2])] = nil end
    end
  end
  if meta.shadow then                                  -- footprint shadow, shifted 1 grid right (light from upper left)
    local x0, x1 = meta.foot[1], meta.foot[2]
    local m = c:mask()
    for x = x0, x1 + 1 do m:set(x, S.h - 2) end
    for x = x0 + 2, x1 + 1 do m:set(x, S.h - 1) end
    if meta.shadow_over then                           -- tiny sprites: the shadow replaces outline px (not body px) so it stays visible
      for y = S.h - 2, S.h - 1 do for x = 0, S.w - 1 do if not sil:has(x, y) then c.pix[c:key(x, y)] = nil end end end
    end
    c.grounds[#c.grounds + 1] = { m, SHADOW }
  end
  local f = key
  local t = c:save(OUT .. "cf-room2-" .. f .. ".aseprite", OUT .. "cf-room2-" .. f .. ".png")
  print(string.format("%-12s ", f) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0 and t.colours <= 16 and t.w == wE and t.h == hE) then FAILS[#FAILS + 1] = f end
  meta.key, meta.w, meta.h, meta.colours = key, wE, hE, t.colours
  items[#items + 1] = meta
end

local function mround(v) return math.floor(v + 0.5) end

-------------------------------------------------------------------------------- floor: cushion (80 x 36)
make("cushion", 80, 36, { anchor = { 64, 240 }, u = 0.24, d = 0.12, upgrade = "base", shadow = true, foot = { 3, 36}, kind = "floor", perch = { { 64, 226 } } }, function(c, S)
  local top = c:ellipse(19.5, 7, 17, 6)
  local side = top:shift(0, 1):add(top:shift(0, 2)):cut(top)
  S.part(top:copy():add(side), PINK, { cres = 3, gloss = false })
  c:fill(side, PINK.shade)
  side:each(function(x, y) if not top:has(x, y + 1) and not side:has(x, y + 1) then c:px(x, y, "#8a3a5a") end end)
  c:seam({ { 5, 12 }, { 12, 14 }, { 27, 14 }, { 34, 12 } }, { gap = PINK.shade })
  c:stitch(top)
  local inner = c:ellipse(19.5, 7.5, 11, 3.5)               -- dip: far/upper-left wall in shade, near/lower-right wall lit
  c:fill(inner, PINK.base)
  c:fill(inner:copy():cut(inner:shift(1, 1)), PINK.shade)
  c:fill(inner:copy():cut(inner:shift(-1, -1)), PINK.rim)
  c:gloss(top, PINK, { 8, 3 })
  c:button(19, 8)
end)

-------------------------------------------------------------------------------- floor: plain bowl (36 x 18), fancy bowl (44 x 22)
make("bowl-plain", 36, 18, { anchor = { 418, 244 }, u = 0.76, d = 0.10, upgrade = "base", shadow = true, foot = { 3, 15 }, shadow_over = true, kind = "floor" }, function(c, S)
  local rows = {
    "....RRRRRRRRRR....",
    "..RRSSSSSSSSSSRR..",
    ".RRSkkKKKkkKKKSRB.",
    ".RRSKKKkkKKKkkSRB.",
    "..RRRRRRRRRRRRRBB.",
    "...BBBBBBBBBBBSS..",
    "....SSSSSSSSSS....",
  }
  S.flat(c:ascii(rows, 0, 1), TERRA.base)
  c:paint(rows, 0, 1, { R = TERRA.rim, B = TERRA.base, S = TERRA.shade, k = WOOD.rim, K = WOOD.base })
end)

make("bowl", 44, 22, { anchor = { 418, 244 }, u = 0.76, d = 0.10, upgrade = "bowl", shadow = true, foot = { 5, 16 }, shadow_over = true, kind = "floor", covers = "bowl-plain" }, function(c, S)
  local foot = c:rect(7, 8, 14, 8)
  local body = c:rect(5, 6, 16, 7)
  local rim = c:ellipse(10.5, 3.5, 9.5, 3)
  local open = c:ellipse(10.5, 3.5, 7.5, 2)
  S.part(foot, GOLD, { cres = 2, gloss = false })
  S.part(body, PINK, { cres = 2, gloss = false })
  S.part(rim, PINK, { cres = 2, gloss = false })
  local ox0, oy0 = open:bbox()
  open:each(function(x, y)
    if y == oy0 then c:px(x, y, PINK.shade)
    else
      local dy, col = y - oy0, WOOD.base
      if dy == 1 and x % 5 < 2 then col = WOOD.rim
      elseif dy == 2 and (x + 2) % 5 < 2 then col = WOOD.rim
      elseif dy >= 3 then col = WOOD.shade end
      c:px(x, y, col)
    end
  end)
  open:each(function(x, y) if c:get(x, y) == WOOD.rim and c:get(x - 1, y) ~= WOOD.rim and c:get(x + 1, y) ~= WOOD.rim then c:px(x, y, WOOD.base) end end)
  local _, _, _, ry1 = rim:bbox()
  rim:each(function(x, y) if y == ry1 then c:px(x, y, PINK.rim) end end)
  c:paint({ "g.g.g.g" }, 7, 7, { g = CREAM })
end)

-------------------------------------------------------------------------------- floor: rug (278 x 62 quad), no shadow
make("rug", 278, 62, { anchor = { 240, 248 }, u = { 0.30, 0.70 }, d = { 0.08, 0.44 }, upgrade = "rug", kind = "floor-decal", noline = true,
                       under_cats = true, origin = { 101, 186 },
                       note = "top corners moved in to the floor seam lines through VP (240,-83): spec s5 showed 124/356, now 127/353",
                       quad = { { 101, 247 }, { 379, 247 }, { 353, 186 }, { 127, 186 } } }, function(c, S)
  local function trap(inset)
    local t = c:mask()
    for y = inset, 30 - inset do
      local yy = y - y % 2                                  -- 4 px export steps
      local off = mround(13 * (30 - yy) / 30) + inset
      for x = off, 138 - off do t:set(x, y) end
    end
    return t
  end
  local m = trap(0)
  S.part(m, GREEN, { cres = 2, gloss = { 24, 4 } })
  local band = trap(3):cut(trap(5))
  c:fill(band, "#e8d0a0")
  for i, y in ipairs({6, 8, 10, 12, 15, 18, 21, 24}) do      -- spacing grows toward the viewer
    for x = 0, 138 do
      if (x + 2 * i) % 4 < 2 and c:get(x, y) == GREEN.base then c:px(x, y, WEFT) end
    end
    for x = 0, 138 do                                         -- drop lone weft px (stitch/tuft clipped them)
      if c:get(x, y) == WEFT and c:get(x - 1, y) ~= WEFT and c:get(x + 1, y) ~= WEFT then c:px(x, y, GREEN.base) end
    end
  end
  c:stitch(m)
  for _, p in ipairs({ { 28, 15 }, { 49, 15 }, { 70, 15 }, { 91, 15 }, { 112, 15 } }) do   -- flat tufts in the field
    c:paint({ "..c..", "cgggc", "..c.." }, p[1] - 2, p[2] - 1, { c = "#e8d0a0", g = GREEN.rim })
  end
  c:fill(m:edge(), GREEN.shade)                                 -- decal edge, no raised outline
  for x = 0, 138 do if m:has(x, 30) then c:px(x, 30, "#4a2c1a") end end   -- 2 px front lip
  for x = 0, 138 do if m:has(x, 30) and x % 3 == 0 then c:px(x, 30, "#e8d0a0") end end
end)

-------------------------------------------------------------------------------- floor: toybox (44 x 34)
make("toybox", 44, 34, { anchor = { 104, 132 }, u = 0.20, d = 0.82, upgrade = "toybox", shadow = true, foot = { 1, 20 }, shadow_over = true, kind = "floor" }, function(c, S)
  S.flat(c:rect(2, 4, 19, 4), WOOD.rim)                                           -- back rim
  S.flat(c:rect(2, 5, 19, 6), "#4a2c1a")                                          -- dark interior
  local yarn = c:ellipse(6, 4, 3, 3)
  S.part(c:poly({ { 13, 5 }, { 15, 2 }, { 19, 0 }, { 19, 3 }, { 17, 5 }, { 19, 7 }, { 14, 7 } }), PINK, { cres = 2, gloss = false, contact = false })
  S.part(yarn, BLUE, { cres = 2, gloss = false, contact = false })
  c:fill(c:line({ { 4, 3 }, { 8, 7 } }, 1):clip(yarn), BLUE.shade)
  c:fill(c:line({ { 6, 2 }, { 9, 5 } }, 1):clip(yarn), BLUE.shade)
  S.part(c:rect(1, 8, 20, 13), WOOD, { cres = 3, gloss = false, contact = false, contour = false, rim = false })   -- front face
  S.flat(c:rect(1, 7, 20, 7), WOOD.rim)                                           -- front rim cuts the toys
  c:fill(c:rect(2, 8, 20, 8), WOOD.shade)                                         -- under-lip shadow
  c:px(3, 9, "#f5cf6a"); c:px(4, 9, "#f5cf6a")
  c:fill(c:rect(1, 10, 20, 11), PINK.base)                                        -- felt band
  c:fill(c:rect(1, 10, 20, 10), PINK.rim)
  c:fill(c:rect(1, 11, 20, 11), PINK.shade)
  c:seam({ { 2, 12 }, { 19, 12 } }, { free = true })
  c:button(9, 9)
  c:fill(c:rect(6,9,8,9), WOOD.shade)
  c:fill(c:rect(14,9,17,9), WOOD.shade)
  c:fill(c:rect(2,13,20,13), WOOD.base)
  c:fill(c:rect(4,13,7,13), WOOD.shade)
  c:fill(c:rect(13,13,15,13), WOOD.shade)
  c:px(16,13, WOOD.shade); c:px(17,13, WOOD.rim)
  c:fill(c:rect(1, 8, 1, 13), WOOD.rim)
end)

-------------------------------------------------------------------------------- floor: cat tree (52 x 112)
make("cattree", 52, 112, { anchor = { 434, 170 }, u = 0.86, d = 0.55, upgrade = "cattree", shadow = true, foot = { 1, 24 }, kind = "floor",
                           perch = { { 434, 152 }, { 434, 114 }, { 434, 74 } }, olbands = { {0,12,9},{13,25,19},{26,33,29},{34,43,38},{44,55,49} } }, function(c, S)
  local function post(y0, y1)
    local m = c:rect(10, y0, 15, y1)
    S.part(m, SISAL, { cres = 2, gloss = false, contour = false })
    local T = {"RRRBBS", "BBRRBS", "SSSSSS"}
    for y = y0 + 1, y1 - 1 do c:paint({T[(y - y0 - 1) % 3 + 1]}, 10, y, {R = SISAL.rim, B = SISAL.base, S = SISAL.shade}) end
    return m
  end
  local function slab(cx, cy, rx, ry, ramp, gl, edgecol)             -- ellipse top + 2-row front edge
    local top = c:ellipse(cx, cy, rx, ry)
    local edge = top:shift(0, 1):add(top:shift(0, 2)):cut(top)
    S.part(top:copy():add(edge), ramp, { cres = 3, gloss = false })
    c:fill(edge, edgecol or GREEN.shade)
    if gl then c:gloss(top, ramp, gl) end
    return top, edge
  end
  slab(12.5, 48, 11.5, 3, GREEN, { 4, 46 })                 -- base
  post(31, 48)                                              -- lower post
  slab(12.5, 29, 10.5, 2.5, GREEN, { 5, 27 })               -- mid
  -- hanging bell toy on the middle slab
  S.part(c:line({ { 2, 33 }, { 2, 35 } }, 1), SISAL, { flat = true })
  S.part(c:ellipse(2.5, 38, 2, 2), GOLD, { cres = 2, gloss = false })
  post(10, 29)                                              -- upper post
  slab(12.5, 8, 8, 2, PINK, false, PINK.shade)             -- top bed
  c:paint({
    ".....RRRRRRRR.....",
    ".RRRSSSSSSSSSSBBB.",
    ".RRBBBBBBBBBBBBBS.",
    ".BBBBRRRRRRRRBBSS.",
    ".SSSSBBBBBBSSSSSS.",
    ".SSSSSSSSSSSSSSSS.",
    ".....SSSSSSSS.....",
  }, 4, 6, { R = PINK.rim, B = PINK.base, S = PINK.shade })
  c:seam({ { 5, 11 }, { 20, 11 } }, { gap = PINK.shade })
  c:seam({ { 2, 52 }, { 23, 52 } }, { gap = GREEN.shade })
  c:seam({ { 3, 32 }, { 22, 32 } }, { gap = GREEN.shade })
end)

-------------------------------------------------------------------------------- floor: scratch post (28 x 76)
make("scratch", 28, 76, { anchor = { 22, 184 }, u = 0.12, d = 0.45, upgrade = "scratch", shadow = true, foot = { 1, 12 }, kind = "floor", olbands = { {0,9,5},{10,29,19},{30,37,33} } }, function(c, S)
  local base = c:ellipse(6.5, 31, 6, 2)
  S.part(base:copy():add(base:shift(0, 1)), GREEN, { cres = 2, gloss = { 3, 30 } })
  c:fill(base:shift(0, 1):cut(base), GREEN.shade)
  local post = c:rect(4, 7, 9, 31)
  S.part(post, SISAL, { cres = 2, gloss = false, contour = false })
  do
    local T, y0, y1 = {"RRRBBS", "BRRRBS", "SSSSSS"}, 7, 31
    for y = y0 + 1, y1 - 1 do c:paint({T[(y - y0 - 1) % 3 + 1]}, 4, y, {R = SISAL.rim, B = SISAL.base, S = SISAL.shade}) end
  end
  S.part(c:ellipse(6.5, 3, 2.5, 2.5), PINK, { cres = 2, gloss = { 5, 2 } })
  local cap = c:ellipse(6.5, 6.5, 5, 1.5)
  S.part(cap:copy():add(cap:shift(0, 1)), GREEN, { cres = 2, gloss = { 3, 6 }, contour = false })
  c:fill(cap:shift(0, 1):cut(cap), GREEN.shade)
  c:fill(c:rect(5, 5, 8, 5), GREEN.shade)                   -- ball contact
  c:seam({ { 2, 32 }, { 11, 32 } }, { gap = GREEN.shade })
end)

-------------------------------------------------------------------------------- wall: cat flap (24 x 22)
make("catflap", 24, 22, { anchor = { 240, 109 }, u = 0.5, d = 1.0, upgrade = "catflap", kind = "wall" }, function(c, S)
  S.part(c:rect(1, 1, 10, 9), WOOD, { cres = 2, gloss = { 2, 2 } })
  local pane = c:rect(3, 3, 8, 7)
  S.part(pane, BLUE, { cres = 1, deep = 0, gloss = false, rim = false, bounce = false, contour = "#4a2c1a" })
  c:fill(c:rect(3, 3, 3, 7), BLUE.rim)
  c:paint({ ".p.", "ppp" }, 5, 5, { p = PINK.base })
  c:px(3, 8, GOLD.base); c:px(8, 8, GOLD.base)
  c:fill(c:rect(3,1,5,1), WOOD.base)
end)

-------------------------------------------------------------------------------- yarn: ball (18 x 18) and patch (40 x 20)
make("yarnball", 18, 18, { anchor = { 154, 204 }, u = 0.36, d = 0.32, upgrade = "base", shadow = false, kind = "floor", origin = { 145, 186 } }, function(c, S)
  local ball = c:ellipse(4.5, 3.5, 3, 3)
  S.part(ball, BLUE, { cres = 2, gloss = { 3, 1 } })
  for _, l in ipairs({ { { 1, 3 }, { 5, 7 } }, { { 2, 1 }, { 7, 6 } } }) do
    c:line(l, 1):clip(ball):each(function(x, y) if not c.gl.s[c:key(x, y)] and c:get(x, y) ~= BLUE.shade then c:px(x, y, BLUE.shade) end end)
  end
end)

make("yarnpatch", 40, 20, { anchor = { 154, 204 }, u = 0.36, d = 0.32, upgrade = "base", kind = "floor-decal", origin = { 134, 184 }, noline = true }, function(c, S)
  -- resting yarn: the ball's shadow (ball sits at 145,187 inside this patch) and the loose thread lying on the boards
  local m = c:mask()
  for x = 7, 16 do m:set(x, 8) end
  for x = 8, 15 do m:set(x, 9) end
  c.grounds[#c.grounds + 1] = { m, SHADOW }
  for _, p in ipairs({ { 2, 9 }, { 3, 9 }, { 4, 8 }, { 5, 8 }, { 6, 8 }, { 7, 8 } }) do c:px(p[1], p[2], BLUE.base) end
  c:px(2, 9, BLUE.shade); c:px(4, 8, BLUE.rim); c:px(5, 8, BLUE.rim); c:px(7, 8, BLUE.shade)
end)

make("yarnpatch-rug", 40, 20, { anchor = { 154, 204 }, u = 0.36, d = 0.32, upgrade = "rug", covers = "yarnpatch", kind = "floor-decal", origin = { 134, 184 }, noline = true }, function(c, S)
  -- resting yarn: the ball's shadow (ball sits at 145,187 inside this patch) and the loose thread lying on the boards
  local m = c:mask()
  for x = 7, 16 do m:set(x, 8) end
  for x = 8, 15 do m:set(x, 9) end
  c.grounds[#c.grounds + 1] = { m, GREEN.shade }
  for _, p in ipairs({ { 2, 9 }, { 3, 9 }, { 4, 8 }, { 5, 8 }, { 6, 8 }, { 7, 8 } }) do c:px(p[1], p[2], BLUE.base) end
  c:px(2, 9, BLUE.shade); c:px(4, 8, BLUE.rim); c:px(5, 8, BLUE.rim); c:px(7, 8, BLUE.shade)
end)


-------------------------------------------------------------------------------- wall: bookshelf items, plant, pet-shelf items
make("books", 40, 18, { anchor = { 134, 94 }, u = 0.5 + (134 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "stands on shelf y 94; spec books 6..8 x 12..14" }, function(c, S)
  local B = { { 1, 3, 7, RED }, { 5, 7, 6, MOSS }, { 9, 12, 7, TEAL }, { 14, 16, 6, YEL } }
  for _, b in ipairs(B) do
    S.part(c:rect(b[1], 8 - b[3], b[2], 7), b[4], { flat = true })
    c:fill(c:rect(b[1] + 1, 8 - b[3], b[2], 8 - b[3]), CREAM)               -- page block seen from above
    c:fill(c:rect(b[1], 5, b[2], 5), b[4].rim)
  end
  c:px(10, 3, CREAM); c:px(11, 3, CREAM)
end)

make("bookstack", 36, 18, { anchor = { 170, 80 }, u = 0.5 + (170 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "stands on shelf y 80" }, function(c, S)
  S.part(c:rect(3, 6, 15, 7), TEAL, { flat = true })
  S.part(c:rect(2, 4, 14, 5), RED, { flat = true })
  S.part(c:rect(4, 2, 14, 3), MOSS, { flat = true })
  c:fill(c:rect(3, 7, 15, 7), TEAL.shade); c:fill(c:rect(2, 5, 14, 5), RED.shade)
  c:fill(c:rect(4, 2, 14, 2), MOSS.rim); c:fill(c:rect(4, 3, 14, 3), MOSS.base)    -- top book: top face lit
  c:paint({"pp"}, 13, 4, {p = CREAM}); c:paint({"pp"}, 14, 6, {p = CREAM})
end)

make("plant", 32, 60, { anchor = { 416, 110 }, u = 0.5 + (416 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "pot 404..427 x 90..109, leaves to y 50", olbands = { {0,18,9},{19,29,24} } }, function(c, S)
  local pot = c:poly({ { 2, 19 }, { 14, 19 }, { 13, 28 }, { 3, 28 } })
  S.part(pot, TERRA, { cres = 3, gloss = { 4, 21 } })
  c:fill(c:rect(2, 19, 14, 20), TERRA.rim)
  c:fill(c:rect(2, 21, 14, 21), TERRA.shade)
  c:seam({ { 3, 24 }, { 13, 24 } }, { gap = TERRA.shade })
  c:fill(c:rect(4, 19, 12, 19), "#5e2f1e")                   -- soil row, leaves rise from it
  local function leaf(pts, g) S.part(c:poly(pts), g or MOSS, { cres = 2, gloss = false, contact = false, contour = false }) end
  leaf({ { 2, 5 }, { 5, 9 }, { 8, 19 }, { 2, 19 }, { 1, 10 } })
  leaf({ { 13, 5 }, { 10, 9 }, { 8, 19 }, { 14, 19 }, { 14, 10 } })
  leaf({ { 8, 1 }, { 11, 5 }, { 11, 19 }, { 5, 19 }, { 5, 5 } })
  c:px(7, 3, MOSS.rim); c:px(7, 4, MOSS.rim); c:px(3, 7, MOSS.rim); c:px(12, 7, MOSS.rim)
  for _, r in ipairs({ { 8, 5, 8, 16 }, { 3, 10, 3, 16 }, { 13, 10, 13, 16 } }) do
    for y = r[2], r[4] do for x = r[1], r[3] do
      local g = c:get(x, y)
      if g == MOSS.base or g == MOSS.rim then c:px(x, y, MOSS.shade) end
    end end
  end
  c:fill(c:rect(4,26,11,26), TERRA.base)
  c:fill(c:rect(5,23,8,23), TERRA.rim)
end)

make("petfish", 20, 24, { anchor = { 128, 64 }, u = 0.5 + (128 - 240) / 396, d = 1.0, upgrade = "pets", kind = "wall", slot = "shelf-a" }, function(c, S)
  local O = ramp("#ffc27a", "#f2793a", "#b8452f")
  S.part(c:poly({ { 6, 5 }, { 9, 1 }, { 9, 9 }, { 6, 9 } }), YEL, { cres = 2, gloss = false })
  S.part(c:ellipse(4.5, 7, 3.5, 3.5), O, { cres = 2, gloss = { 3, 5 } })
  c:px(3, 7, "#2a1a10")
  c:seam({ { 6, 5 }, { 6, 9 } }, { free = true })
end)

make("petmouse", 20, 24, { anchor = { 176, 64 }, u = 0.5 + (176 - 240) / 396, d = 1.0, upgrade = "pets", kind = "wall", slot = "shelf-b" }, function(c, S)
  S.part(c:ellipse(3.5, 5, 2, 2), PINK, { cres = 1, gloss = false })
  S.part(c:ellipse(7, 4, 2, 2), PINK, { cres = 1, gloss = false })
  S.part(c:ellipse(5, 8, 4, 3), GREY, { cres = 2, gloss = { 3, 6 } })
  c:px(2, 8, "#2a1a10"); c:px(1, 9, PINK.base)
  S.flat(c:line({ { 9, 9 }, { 9, 6 } }, 1), PINK.rim)
end)

make("petbell", 20, 24, { anchor = { 128, 64 }, u = 0.5 + (128 - 240) / 396, d = 1.0, upgrade = "pets", kind = "wall", slot = "shelf-a" }, function(c, S)
  S.part(c:rrect(1, 8, 8, 10, 1), PINK, { cres = 2, gloss = false })
  S.part(c:ellipse(4.5, 5.5, 3, 3), GOLD, { cres = 2, gloss = { 3, 3 } })
  c:fill(c:rect(3, 7, 6, 7), GOLD.shade)
  c:px(4, 8, GOLD.shade)
end)

make("petframe", 24, 30, { anchor = { 152, 52 }, u = 0.5 + (152 - 240) / 396, d = 1.0, upgrade = "pets", kind = "wall", slot = "frame" }, function(c, S)
  local out = c:rect(1, 1, 10, 13)
  S.part(out, WOOD, { cres = 2, gloss = { 2, 2 } })
  local mat = c:rect(3, 3, 8, 11)
  c:fill(mat, CREAM)
  mat:edge():each(function(x, y) if y == 3 or x == 3 then c:px(x, y, "#8a4f2a") end end)
  c:paint({ ".ss..", "ssss.", ".sssp", "..s.." }, 4, 6, { s = TERRA.base, p = TERRA.shade })
  c:px(5, 7, TERRA.rim)
  c:px(2,2,"#8a4f2a"); c:px(9,12,"#8a4f2a")
  c:fill(c:rect(4,1,6,1), "#b07a45")
end)

-------------------------------------------------------------------------------- furniture.json
local function jv(v)
  if type(v) == "table" then
    local isarr = #v > 0
    local p = {}
    if isarr then for _, x in ipairs(v) do p[#p + 1] = jv(x) end return "[" .. table.concat(p, ",") .. "]" end
    return "{}"
  elseif type(v) == "string" then return '"' .. v .. '"'
  elseif type(v) == "boolean" then return tostring(v)
  else return string.format("%.4g", v) end
end
local KEYS = { "file", "size", "anchor_px", "anchor", "origin", "u", "d", "z", "upgrade", "kind", "shadow", "slot", "covers", "under_cats", "quad", "perch", "note", "colours" }
local lines = {}
for _, it in ipairs(items) do
  local o = {}
  it.file = "cf-room2-" .. it.key .. ".png"
  it.size = { it.w, it.h }
  it.anchor_px = { it.w // 2, it.h }                 -- feet bottom-centre inside the sprite (bottom edge)
  it.origin = it.origin or { it.anchor[1] - it.w // 2, it.anchor[2] - it.h }
  it.z = it.anchor[2]
  it.shadow = it.shadow or false
  for _, k in ipairs(KEYS) do if it[k] ~= nil then o[#o + 1] = '"' .. k .. '":' .. jv(it[k]) end end
  lines[#lines + 1] = '    "' .. it.key .. '": {' .. table.concat(o, ", ") .. "}"
end
local f = io.open(OUT .. "furniture.json", "w")
f:write('{\n  "note": "Room A P3 furniture. Export px on the 480x270 plate. anchor = feet bottom-centre (x, y of the sprite bottom edge); origin = sprite top-left; z = sort key = anchor y (furniture before cats on ties). Sprites are authored at their own depth scale. Shadow colour #9a6b3f baked (on #c78d52).",\n')
f:write('  "sprites": {\n' .. table.concat(lines, ",\n") .. "\n  }\n}\n")
f:close()
print(#FAILS == 0 and "ALL OK" or ("FAILS: " .. table.concat(FAILS, ",")))

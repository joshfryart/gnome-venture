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
  if not meta.noline then c:outline(sil, { keep = true }) end
  if meta.shadow then                                  -- 2 grid rows (4 px), 0.8 x width, tapered
    local rx, cx = math.floor(0.4 * S.w + 0.5), S.w // 2
    local m = c:mask()
    for x = cx - rx, cx + rx - 1 do m:set(x, S.h - 2) end
    for x = cx - rx + 1, cx + rx - 2 do m:set(x, S.h - 1) end
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

-------------------------------------------------------------------------------- floor: cushion (80 x 30)
make("cushion", 80, 30, { anchor = { 64, 240 }, u = 0.24, d = 0.12, upgrade = "base", shadow = true, kind = "floor" }, function(c, S)
  local top = c:ellipse(19.5, 4.5, 17, 4)
  local side = top:shift(0, 2):add(top:shift(0, 1)):cut(top)
  S.part(top:copy():add(side), PINK, { cres = 3, gloss = false })
  c:fill(side, PINK.shade)
  side:each(function(x, y) if not top:has(x, y + 1) and not side:has(x, y + 1) then c:px(x, y, "#8a3a5a") end end)
  c:seam({ { 6, 9 }, { 12, 10 }, { 27, 10 }, { 33, 9 } }, { gap = PINK.shade })
  c:stitch(top)
  c:gloss(top, PINK, { 9, 2 })
  for _, l in ipairs({ { { 11, 4 }, { 15, 5 } }, { { 24, 5 }, { 28, 4 } }, { { 19, 7 }, { 19, 8 } } }) do
    c:fill(c:line(l, 1), PINK.shade)
  end
  c:button(18, 3)
end)

-------------------------------------------------------------------------------- floor: plain bowl (36 x 14), fancy bowl (44 x 18)
make("bowl-plain", 36, 14, { anchor = { 418, 244 }, u = 0.76, d = 0.10, upgrade = "base", shadow = true, kind = "floor" }, function(c, S)
  S.flat(c:ascii({ "..kkkk..", ".kkkkkk." }, 5, 1), WOOD.rim)
  local bowl = c:poly({ { 2, 3 }, { 16, 3 }, { 14, 5 }, { 4, 5 } }):add(c:ellipse(8.5, 3, 6.5, 1.5))
  S.part(bowl, TERRA, { cres = 2, gloss = false })
  c:fill(c:ellipse(8.5, 3, 5, 0.6), TERRA.shade)
  c:paint({ "..kKkK..", ".kKkkKk." }, 5, 1, { k = WOOD.rim, K = WOOD.base })
  c:fill(c:rect(3, 4, 14, 4), TERRA.rim)
end)

make("bowl", 44, 18, { anchor = { 418, 244 }, u = 0.76, d = 0.10, upgrade = "bowl", shadow = true, kind = "floor", covers = "bowl-plain" }, function(c, S)
  S.flat(c:ascii({ "..kkkkkk..", ".kkkkkkkk." }, 6, 1), WOOD.rim)
  local foot = c:rrect(5, 5, 16, 6, 1)
  local bowl = c:poly({ { 2, 3 }, { 20, 3 }, { 17, 5 }, { 5, 5 } }):add(c:ellipse(10.5, 3, 8.5, 1.5))
  S.part(foot, GOLD, { cres = 2, gloss = false })
  S.part(bowl, PINK, { cres = 2, gloss = false })
  c:fill(c:ellipse(10.5, 3, 6.5, 0.6), PINK.shade)
  c:paint({ "..kKkKkK..", ".kKkkKkkK." }, 6, 1, { k = WOOD.rim, K = WOOD.base })
  c:fill(c:rect(3, 4, 19, 4), PINK.rim)
  c:paint({ "g.g.g" }, 8, 4, { g = CREAM })
  c:seam({ { 6, 6 }, { 15, 6 } }, { free = true })
end)

-------------------------------------------------------------------------------- floor: rug (278 x 62 quad), no shadow
make("rug", 278, 62, { anchor = { 240, 248 }, u = { 0.30, 0.70 }, d = { 0.08, 0.44 }, upgrade = "rug", kind = "floor-decal",
                       under_cats = true, origin = { 101, 186 },
                       quad = { { 101, 247 }, { 379, 247 }, { 356, 186 }, { 124, 186 } } }, function(c, S)
  local function trap(inset)
    local t = c:mask()
    for y = inset, 30 - inset do
      local yy = y - y % 2                                  -- 4 px export steps
      local off = mround(11.5 * (30 - yy) / 30) + inset
      for x = off, 138 - off do t:set(x, y) end
    end
    return t
  end
  local m = trap(0)
  S.part(m, GREEN, { cres = 2, gloss = { 24, 4 } })
  local band = trap(3):cut(trap(5))
  band:each(function(x, y) c:px(x, y, (x - 69) + 3 * (y - 15) > 40 and "#c49a60" or "#e8d0a0") end)
  c:stitch(m)
  for _, p in ipairs({ { 28, 15 }, { 49, 15 }, { 70, 15 }, { 91, 15 }, { 112, 15 } }) do   -- diamond tufts in the field
    c:paint({ ".c.", "cgc", ".c." }, p[1] - 1, p[2] - 1, { c = "#e8d0a0", g = GREEN.rim })
  end
end)

-------------------------------------------------------------------------------- floor: toybox (44 x 34)
make("toybox", 44, 34, { anchor = { 104, 132 }, u = 0.20, d = 0.82, upgrade = "toybox", shadow = true, kind = "floor" }, function(c, S)
  local yarn = c:ellipse(6, 3.5, 3, 3)
  S.part(c:poly({ { 13, 6 }, { 15, 3 }, { 19, 1 }, { 19, 4 }, { 17, 6 }, { 19, 8 }, { 14, 8 } }), PINK, { cres = 2, gloss = false })
  S.part(yarn, BLUE, { cres = 2, gloss = false })
  c:fill(c:line({ { 4, 2 }, { 8, 6 } }, 1):clip(yarn), BLUE.shade)
  c:fill(c:line({ { 6, 1 }, { 9, 4 } }, 1):clip(yarn), BLUE.shade)
  S.part(c:rect(1, 6, 20, 12), WOOD, { cres = 3, gloss = { 4, 8 } })
  c:fill(c:rect(1, 9, 20, 10), PINK.base)                                         -- felt band
  c:fill(c:rect(1, 9, 20, 9), PINK.rim)
  c:fill(c:rect(1, 10, 20, 10), PINK.shade)
  c:fill(c:rect(1, 6, 20, 6), WOOD.rim)
  c:seam({ { 2, 11 }, { 19, 11 } }, { free = true })
  c:button(9, 8)
  c:fill(c:rect(1, 6, 1, 12), WOOD.rim)
end)

-------------------------------------------------------------------------------- floor: cat tree (52 x 112)
make("cattree", 52, 112, { anchor = { 434, 170 }, u = 0.86, d = 0.55, upgrade = "cattree", shadow = true, kind = "floor" }, function(c, S)
  local function post(y0, y1)
    local m = c:rect(10, y0, 15, y1)
    S.part(m, SISAL, { cres = 2, gloss = false })
    for y = y0 + 1, y1 - 1, 3 do c:fill(c:rect(10, y, 15, y), SISAL.shade); c:fill(c:rect(10, y - 1, 14, y - 1), SISAL.rim) end
    return m
  end
  post(13, 28); post(33, 47)
  -- hanging bell toy on the middle slab
  S.part(c:line({ { 4, 33 }, { 4, 38 } }, 1), SISAL, { flat = true })
  S.part(c:ellipse(4.5, 40, 2, 2), GOLD, { cres = 2, gloss = false })
  S.part(c:rrect(1, 47, 24, 52, 2), GREEN, { cres = 3, gloss = { 4, 48 } })
  S.part(c:rrect(2, 28, 23, 33, 2), GREEN, { cres = 3, gloss = { 5, 29 } })
  S.part(c:rrect(4, 9, 21, 14, 2), GREEN, { cres = 3, gloss = { 7, 10 } })
  S.part(c:ellipse(12.5, 6.5, 7.5, 3), PINK, { cres = 3, gloss = { 8, 4 } })
  c:seam({ { 3, 50 }, { 22, 50 } }, { gap = GREEN.shade })
  c:seam({ { 4, 31 }, { 21, 31 } }, { gap = GREEN.shade })
end)

-------------------------------------------------------------------------------- floor: scratch post (28 x 76)
make("scratch", 28, 76, { anchor = { 22, 184 }, u = 0.12, d = 0.45, upgrade = "scratch", shadow = true, kind = "floor" }, function(c, S)
  local post = c:rect(4, 7, 9, 29)
  S.part(post, SISAL, { cres = 2, gloss = false })
  for y = 9, 28, 3 do c:fill(c:rect(4, y, 9, y), SISAL.shade); c:fill(c:rect(4, y - 1, 8, y - 1), SISAL.rim) end
  S.part(c:ellipse(6.5, 3, 2.5, 2.5), PINK, { cres = 2, gloss = { 5, 2 } })
  S.part(c:rrect(2, 5, 11, 8, 1), GREEN, { cres = 2, gloss = { 3, 5 } })
  S.part(c:rrect(1, 29, 12, 33, 2), GREEN, { cres = 2, gloss = { 2, 30 } })
  c:seam({ { 3, 31 }, { 10, 31 } }, { gap = GREEN.shade })
end)

-------------------------------------------------------------------------------- wall: cat flap (24 x 22)
make("catflap", 24, 22, { anchor = { 240, 109 }, u = 0.5, d = 1.0, upgrade = "catflap", kind = "wall" }, function(c, S)
  S.part(c:rect(1, 1, 10, 9), WOOD, { cres = 2, gloss = { 2, 2 } })
  local pane = c:rect(3, 3, 8, 7)
  S.part(pane, BLUE, { cres = 1, deep = 0, gloss = false, rim = false, bounce = false, contour = "#4a2c1a" })
  c:fill(c:rect(3, 3, 3, 7), BLUE.rim)
  c:paint({ ".p.", "ppp" }, 5, 5, { p = PINK.base })
  c:px(3, 8, GOLD.base); c:px(8, 8, GOLD.base)
end)

-------------------------------------------------------------------------------- yarn: ball (18 x 18) and patch (40 x 20)
make("yarnball", 18, 18, { anchor = { 154, 204 }, u = 0.36, d = 0.32, upgrade = "base", shadow = true, kind = "floor", origin = { 145, 187 } }, function(c, S)
  local ball = c:ellipse(4.5, 3.5, 3, 3)
  S.part(ball, BLUE, { cres = 2, gloss = { 3, 1 } })
  for _, l in ipairs({ { { 1, 3 }, { 5, 7 } }, { { 2, 1 }, { 7, 6 } } }) do
    c:line(l, 1):clip(ball):each(function(x, y) if not c.gl.s[c:key(x, y)] and c:get(x, y) ~= BLUE.shade then c:px(x, y, BLUE.shade) end end)
  end
end)

make("yarnpatch", 40, 20, { anchor = { 154, 204 }, u = 0.36, d = 0.32, upgrade = "base", kind = "floor-decal", origin = { 134, 186 }, noline = true }, function(c, S)
  -- resting yarn: the ball's shadow (ball sits at 145,187 inside this patch) and the loose thread lying on the boards
  local m = c:mask()
  for x = 7, 16 do m:set(x, 8) end
  for x = 8, 15 do m:set(x, 9) end
  c.grounds[#c.grounds + 1] = { m, SHADOW }
  for _, p in ipairs({ { 2, 9 }, { 3, 9 }, { 4, 8 }, { 5, 8 }, { 6, 8 }, { 7, 8 } }) do c:px(p[1], p[2], BLUE.base) end
  c:px(2, 9, BLUE.shade); c:px(4, 8, BLUE.rim); c:px(5, 8, BLUE.rim); c:px(7, 8, BLUE.shade)
end)

-------------------------------------------------------------------------------- wall: bookshelf items, plant, pet-shelf items
make("books", 40, 18, { anchor = { 134, 94 }, u = 0.5 + (134 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "stands on shelf y 94; spec books 6..8 x 12..14" }, function(c, S)
  local B = { { 1, 3, 7, RED }, { 5, 7, 6, MOSS }, { 9, 12, 7, TEAL }, { 14, 16, 6, YEL } }
  for _, b in ipairs(B) do
    S.part(c:rect(b[1], 8 - b[3], b[2], 7), b[4], { flat = true })
    c:fill(c:rect(b[1], 8 - b[3] + 1, b[2], 8 - b[3] + 1), b[4].shade)
  end
  c:px(10, 3, CREAM); c:px(11, 3, CREAM)
end)

make("bookstack", 36, 18, { anchor = { 170, 80 }, u = 0.5 + (170 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "stands on shelf y 80" }, function(c, S)
  S.part(c:rect(3, 6, 15, 7), TEAL, { flat = true })
  S.part(c:rect(2, 4, 14, 5), RED, { flat = true })
  S.part(c:rect(4, 2, 14, 3), MOSS, { flat = true })
  c:fill(c:rect(3, 7, 15, 7), TEAL.shade); c:fill(c:rect(2, 5, 14, 5), RED.shade); c:fill(c:rect(4, 3, 14, 3), MOSS.shade)
  c:px(15, 6, CREAM); c:px(14, 4, CREAM)
end)

make("plant", 32, 60, { anchor = { 416, 110 }, u = 0.5 + (416 - 240) / 396, d = 1.0, upgrade = "base", kind = "wall", note = "pot 404..427 x 90..109, leaves to y 50" }, function(c, S)
  local function leaf(pts, g) S.part(c:poly(pts), g or MOSS, { cres = 2, gloss = false }) end
  leaf({ { 2, 5 }, { 5, 9 }, { 8, 18 }, { 2, 18 }, { 1, 10 } })
  leaf({ { 13, 5 }, { 10, 9 }, { 8, 18 }, { 14, 18 }, { 14, 10 } })
  leaf({ { 8, 1 }, { 11, 5 }, { 11, 18 }, { 5, 18 }, { 5, 5 } })
  c:px(7, 3, MOSS.rim); c:px(7, 4, MOSS.rim); c:px(3, 7, MOSS.rim); c:px(12, 7, MOSS.rim)
  local pot = c:poly({ { 2, 19 }, { 14, 19 }, { 13, 28 }, { 3, 28 } })
  S.part(pot, TERRA, { cres = 3, gloss = { 4, 21 } })
  c:fill(c:rect(1, 19, 14, 20), TERRA.rim)
  c:fill(c:rect(2, 21, 14, 21), TERRA.shade)
  c:seam({ { 3, 24 }, { 13, 24 } }, { gap = TERRA.shade })
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
local KEYS = { "file", "size", "anchor_px", "anchor", "origin", "u", "d", "z", "upgrade", "kind", "shadow", "slot", "covers", "under_cats", "quad", "note", "colours" }
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

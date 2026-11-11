-- Gnome hovel (slim home page): cutaway of a mushroom-and-timber burrow home, 480x270.
-- Slots left plain for layers (mock-b3): floor y220-269, wall 150,80 40x32, window 56,62 48x48, shelf 300,84 64x40,
-- rug 168,224 112x24, lamp 276,180 16x40, pet 18,188 48x32. Gnome stands at 214,172 32x48. Banner = crop y104..224.
-- quirk: a tiny red-cap mushroom sprouting from the top of the main beam.
-- Run: /tmp/aseq1/squashfs-root/AppRun -b --script-param out=<dir>/ --script room.lua
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/hovel/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "hovel-room" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, abs, atan, sqrt = math.floor, math.max, math.min, math.abs, math.atan, math.sqrt
local TIMB, OAK, CREAM, ROSE, GOLD, STONE, IRON, SBLUE, LEAF, BARN, TEAL = S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GOLD, S.STONE, S.IRON, S.SBLUE, S.LEAF, S.BARN, S.TEAL
local rect, rr, poly, obj, tex, hash = S.rect, S.rr, S.poly, S.obj, S.tex, S.hash
local INK = "#2b1c26"
local function P(x, y, col) c:put(x, y, col) end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local function inkrim(m) c:rim(m, INK) end
local PL = {"#7e6058", "#a8846c", "#c8a688", "#dcc0a0", "#ead4b4", "#f4e4c6"}   -- warm plaster

---------------------------------------------------------------- back wall: speckled plaster
tex(rect(0, 0, W - 1, 219), function(x, y)
  local n = hash(x, y, 7)
  if n > .985 then return PL[3] end
  if n < .012 then return PL[5] end
  if hash(floor(x / 5), floor(y / 4), 9) > .9 and n > .6 then return PL[3] end   -- soft trowel patches
  return PL[4]
end)
-- a few hairline cracks
for _, k in ipairs{{30, 128, 1}, {258, 150, -1}, {372, 72, 1}} do
  local x, y = k[1], k[2]
  for i = 0, 9 do P(x, y, PL[2]); x = x + k[3]; if i % 3 ~= 1 then y = y + 1 end end
end
-- warm window light washed down and right across the wall (stepped)
S.glow(84, 118, 96, "#fff2cc", .32, {0, 40, 300, 178})
-- cool shade along the far right of the room
tex(rect(408, 40, 471, 177), function(x, y) local cur = c:get(x, y); if cur == PL[4] and (x + y) % 1 == 0 and x > 440 then return PL[3] end end)

---------------------------------------------------------------- ceiling: the gill underside of the mushroom cap
local GL = {"#6e3a4a", "#9a5a62", "#c48478", "#dca692", "#ecc4aa", "#f6dcc0"}
tex(rect(0, 0, W - 1, 31), function(x, y)
  local a = atan(x - 240, y + 120)
  local k = floor(a * 70)
  local edge = (a * 70 - k) < .22
  local band = (y < 4) and 2 or ((y < 12) and 3 or ((y < 22) and 4 or 5))
  if edge then band = band - 1 end
  if hash(k, 0, 3) > .7 and not edge then band = band + (y > 12 and 1 or 0) end
  return GL[max(1, min(6, band))]
end)
-- lip of the cap: a soft scalloped edge hanging over the beam
for x = 0, W - 1 do
  local lip = 31 + ((x % 24 < 12) and 1 or 0) + ((x % 24 == 11 or x % 24 == 12) and 1 or 0)
  for y = 28, lip do P(x, y, (y == lip) and GL[2] or GL[6]) end
end

---------------------------------------------------------------- main beam, posts, corner timbers
local function beamTex(m, base) S.planks(m, TIMB, { vert = false, w = 9, base = base or 4, seed = 4 }) end
inkrim(rect(0, 34, W - 1, 42)); beamTex(rect(0, 35, W - 1, 41), 4)
R(0, 35, W - 1, 35, TIMB[6]); R(0, 41, W - 1, 41, TIMB[2])
for x = 6, W, 48 do P(x, 38, TIMB[1]); P(x + 1, 38, TIMB[5]) end                  -- peg heads
for x = 0, W - 1 do if (x * 7) % 11 < 9 then P(x, 43, PL[2]) end end              -- beam throws a shade on the plaster
local function post(x0, x1, tag)
  local m = rect(x0, 43, x1, 219)
  inkrim(m); S.planks(m, TIMB, { w = 99, base = 3, seed = tag })
  for y = 43, 219 do P(x0, y, TIMB[5]); P(x1, y, TIMB[2]); if hash(x0, floor(y / 6), tag) > .8 then P(x0 + 3, y, TIMB[2]) end end
  for _, y in ipairs{48, 212} do R(x0, y, x1, y + 1, IRON[3]); P(x0 + 1, y, IRON[5]) end   -- iron straps
  for y = 43, 219 do P(x1 + 2, y, PL[3]) end
end
post(0, 7, 1); post(472, 479, 2); post(204, 211, 3); post(398, 405, 4)
-- knee braces from posts to beam
local function brace(x0, dir)
  for i = 0, 13 do
    local x, y = x0 + dir * (13 - i), 43 + i
    P(x - dir, y, INK); P(x, y, TIMB[4]); P(x + dir, y, TIMB[3]); P(x + 2 * dir, y, TIMB[3]); P(x + 3 * dir, y, INK)
  end
end
brace(212, 1); brace(203, -1); brace(406, 1); brace(397, -1); brace(8, 1); brace(471, -1)

-- quirk: a little red-cap mushroom pushing up out of the beam
do
  local mx = 120
  R(mx, 30, mx + 1, 34, CREAM[5]); P(mx + 1, 31, CREAM[3]); P(mx + 1, 33, CREAM[3])
  local cap = poly{{mx - 4, 30}, {mx - 2, 27}, {mx + 3, 27}, {mx + 5, 30}}
  inkrim(cap); c:fillMask(cap, BARN[4])
  R(mx - 3, 29, mx + 4, 30, BARN[3]); P(mx - 1, 28, BARN[6]); P(mx, 28, BARN[6])
  P(mx + 2, 28, CREAM[6]); P(mx - 2, 29, CREAM[6]); P(mx + 3, 30, CREAM[5])
  P(mx - 1, 34, INK); P(mx + 2, 34, INK); P(mx - 1, 31, INK); P(mx + 2, 32, INK); P(mx - 1, 32, INK); P(mx - 1, 33, INK); P(mx + 2, 31, INK); P(mx + 2, 33, INK)
end

---------------------------------------------------------------- wainscot: oak boards under a top rail
do
  local m = rect(8, 180, 471, 219)
  S.planks(m, OAK, { w = 8, base = 3, seed = 11 })
  R(8, 176, 471, 177, OAK[5]); R(8, 178, 471, 178, OAK[3]); R(8, 179, 471, 179, OAK[1]); R(8, 175, 471, 175, INK)
  for x = 8, 471 do if x % 8 == 4 and hash(x, 1, 5) > .5 then P(x, 186, OAK[2]) end end   -- nail heads
end
-- re-ink the posts' edges over the wainscot rail
for _, p in ipairs{{-1, 8}, {203, 212}, {397, 406}, {471, 480}} do for y = 175, 219 do P(p[1], y, INK); P(p[2], y, INK) end end

---------------------------------------------------------------- an old root nosing through the plaster (upper left corner)
do
  local pts = {{9, 44}, {16, 48}, {22, 50}, {27, 55}, {29, 61}, {33, 64}}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for t = 0, n do
      local x = floor(a[1] + (b[1] - a[1]) * t / n + .5); local y = floor(a[2] + (b[2] - a[2]) * t / n + .5)
      P(x, y - 1, INK); P(x, y, S.DIRT[4]); P(x, y + 1, S.DIRT[2]); P(x, y + 2, INK)
    end
  end
  P(33, 65, S.DIRT[3]); P(34, 66, INK); P(18, 51, S.DIRT[3]); P(18, 52, S.DIRT[3]); P(19, 53, INK)
end

---------------------------------------------------------------- window sill (the window layer sits in 56..103 x 62..109)
do
  local m = rect(52, 110, 107, 113)
  inkrim(m); obj(m, OAK, { base = 4, lit = 1, shade = 1 })
  R(54, 115, 105, 115, PL[2])
  for _, x in ipairs{58, 100} do local b = rect(x, 115, x + 1, 119); inkrim(b); c:fillMask(b, OAK[2]) end
end

---------------------------------------------------------------- hanging herb bundles from the beam
local function herbs(x, len, ramp)
  for y = 43, 43 + len do P(x, y, "#c8a070") end
  R(x - 2, 44 + len, x + 2, 45 + len, BARN[3])                                         -- red twine wrap
  for i = 0, 11 do
    local dx = floor((i - 5.5) * .7 + .5)
    for k = 0, 5 + (i % 3) do
      local col = (dx < 0) and ramp[5] or ((dx > 1) and ramp[2] or ramp[3])
      if k == 5 + (i % 3) then col = ramp[4] end
      P(x + floor(dx * (k + 2) / 6), 46 + len + k, col)
    end
  end
  for y = 46 + len, 56 + len do for xx = x - 6, x + 6 do
    local cur = c:get(xx, y)
    if cur and (cur == ramp[2] or cur == ramp[3] or cur == ramp[4] or cur == ramp[5]) then
      for _, d in ipairs{{1, 0}, {-1, 0}, {0, 1}} do
        local nc = c:get(xx + d[1], y + d[2])
        if nc and nc ~= ramp[2] and nc ~= ramp[3] and nc ~= ramp[4] and nc ~= ramp[5] and nc ~= BARN[3] then P(xx + d[1], y + d[2], INK) end
      end
    end
  end end
end
herbs(158, 8, LEAF); herbs(250, 5, {"#4a2a3a", "#6a3c52", "#8a5274", "#ac6e94", "#c890b0", "#e4b4cc"}); herbs(352, 10, LEAF)

---------------------------------------------------------------- noticeboard 40x40 at 222..261 x 92..131
do
  local fr = rect(222, 92, 261, 131)
  inkrim(fr); obj(fr, TIMB, { base = 4 })
  local cork = rect(225, 95, 258, 128)
  tex(cork, function(x, y)
    local n = hash(x, y, 21)
    if n > .86 then return "#9a6a40" elseif n < .1 then return "#d8a874" end
    return "#c08a58"
  end)
  R(225, 95, 258, 95, "#8a5a38"); R(225, 95, 225, 128, "#8a5a38")            -- frame's shadow on the cork
  local function note(x0, y0, x1, y1, ramp, pin, lines)
    local m = rect(x0, y0, x1, y1); inkrim(m); c:fillMask(m, ramp[5])
    R(x0, y1, x1, y1, ramp[3]); R(x1, y0, x1, y1, ramp[3])
    for i, l in ipairs(lines) do R(x0 + 2, y0 + 3 + i * 3, x0 + 2 + l, y0 + 3 + i * 3, ramp[2]) end
    local px = floor((x0 + x1) / 2)
    R(px, y0 - 1, px + 1, y0, pin[1]); P(px, y0 - 1, pin[2])
    R(x0 + 1, y1 + 1, x1 + 1, y1 + 1, "#7a4a30")                               -- note shadow on the cork
  end
  note(228, 99, 241, 113, CREAM, {BARN[4], BARN[6]}, {8, 6, 9})
  note(244, 101, 255, 112, {"", "#6a7aa8", "#9ab0d0", "", "#cfe0f0"}, {GOLD[4], GOLD[6]}, {6, 7})
  note(230, 117, 240, 126, {"", "#9a5a70", "#d8a0b0", "", "#f4d0d8"}, {TEAL[4], TEAL[6]}, {})
  -- a doodled toadstool on the pink card
  P(234, 120, "#9a3a48"); P(235, 120, "#9a3a48"); P(236, 120, "#9a3a48"); P(233, 121, "#9a3a48"); P(237, 121, "#9a3a48")
  P(235, 122, "#7a4a40"); P(235, 123, "#7a4a40")
  -- a pressed fern frond pinned at the lower right
  for i = 0, 8 do P(246 + i, 125 - floor(i / 2), LEAF[3]); if i % 2 == 0 then P(246 + i, 124 - floor(i / 2) - 1, LEAF[5]); P(247 + i, 126 - floor(i / 2), LEAF[2]) end end
  P(245, 126, INK)
end

---------------------------------------------------------------- coat peg with a striped scarf (right wall, above the table)
do
  local m = rect(372, 116, 393, 119); inkrim(m); obj(m, OAK, { base = 4, lit = 1, shade = 1 })
  for _, x in ipairs{376, 388} do local p = rect(x, 120, x + 1, 122); inkrim(p); c:fillMask(p, OAK[2]) end
  local sc = poly{{373, 120}, {381, 120}, {380, 150}, {374, 150}}
  inkrim(sc)
  tex(sc, function(x, y)
    local k = floor((y - 120) / 4) % 2
    local base = (k == 0) and TEAL or GOLD
    return base[(x <= 374) and 5 or ((x >= 379) and 3 or 4)]
  end)
  for x = 374, 380, 2 do P(x, 151, (x % 4 == 0) and GOLD[4] or TEAL[4]); P(x, 152, INK) end
end

---------------------------------------------------------------- bed 128x60 at 72..199 x 160..219
do
  R(80, 213, 196, 219, "#6a4a52")                                             -- shadow under the bed (on the boards)
  -- quirk of the bed: one striped sock dropped underneath
  local sock = poly{{150, 214}, {156, 214}, {156, 217}, {161, 217}, {161, 219}, {150, 219}}
  tex(sock, function(x, y) return (x % 3 == 0) and ROSE[5] or CREAM[5] end); for x = 150, 161 do P(x, 213, INK) end
  -- headboard (left): two posts with mushroom-cap knobs and a carved panel
  local hb = rect(72, 166, 85, 219)
  inkrim(hb); obj(hb, TIMB, { base = 4 })
  local panel = rect(75, 171, 82, 192); c:fillMask(panel, TIMB[3]); R(75, 171, 82, 171, TIMB[2]); R(76, 192, 82, 192, TIMB[5])
  for _, y in ipairs{176, 182, 188} do R(76, y, 81, y, TIMB[4]) end
  local knob = poly{{70, 166}, {73, 161}, {84, 161}, {87, 166}}
  inkrim(knob); c:fillMask(knob, BARN[4]); R(71, 165, 86, 166, BARN[2]); R(75, 162, 79, 162, BARN[6]); P(82, 163, CREAM[6]); P(76, 164, CREAM[6])
  -- footboard (right), lower
  local fb = rect(188, 180, 199, 219)
  inkrim(fb); obj(fb, TIMB, { base = 3 })
  local fk = poly{{186, 180}, {189, 176}, {198, 176}, {201, 180}}
  inkrim(fk); c:fillMask(fk, BARN[4]); R(187, 179, 200, 180, BARN[2]); R(190, 177, 193, 177, BARN[6])
  -- side rail and legs
  local rail = rect(86, 202, 187, 210)
  inkrim(rail); S.planks(rail, OAK, { vert = false, w = 9, base = 4, seed = 2 }); R(86, 202, 187, 202, OAK[6]); R(86, 210, 187, 210, OAK[2])
  for _, x in ipairs{90, 182} do local l = rect(x, 211, x + 3, 219); inkrim(l); obj(l, OAK, { base = 3, lit = 0 }) end
  -- mattress (cream ticking)
  local mat = rect(86, 192, 187, 201)
  inkrim(mat)
  tex(mat, function(x, y) if y == 201 then return CREAM[3] end; if (x - 86) % 6 == 0 then return "#c4b0b8" end; return CREAM[5] end)
  -- pillow
  local pil = rr(87, 182, 108, 192, 3)
  inkrim(pil); obj(pil, CREAM, { base = 5, lit = 1 }); P(91, 184, CREAM[6]); P(92, 184, CREAM[6])
  for x = 96, 99 do P(x, 188, CREAM[3]) end                                    -- dent where a head lay
  -- quilt: patchwork squares, rose and gold and teal, a gold stitched hem, folded back at the top
  local q = poly{{108, 186}, {186, 186}, {187, 189}, {187, 205}, {104, 205}, {104, 190}}
  inkrim(q)
  local PAT = { ROSE, GOLD, TEAL, ROSE, S.VIOLET, GOLD }
  tex(q, function(x, y)
    local i, j = floor((x - 104) / 10), floor((y - 186) / 7)
    local r = PAT[(i + j * 2) % #PAT + 1]
    local lx, ly = (x - 104) % 10, (y - 186) % 7
    local tone = 4
    if ly == 0 or lx == 0 then tone = 3 end
    if ly == 1 and lx > 0 and lx < 4 then tone = 5 end
    if y >= 203 then tone = 2 end
    return r[tone]
  end)
  R(104, 190, 104, 205, ROSE[2])
  local fold = poly{{108, 186}, {186, 186}, {186, 190}, {106, 190}}            -- turned-down top sheet
  c:fillMask(fold, CREAM[5]); R(106, 190, 186, 190, CREAM[3]); R(110, 187, 140, 187, CREAM[6])
  for x = 106, 186 do if x % 3 ~= 2 then P(x, 202, GOLD[5]) end end
end

---------------------------------------------------------------- table 56x36 at 316..371 x 184..219 (with a teapot and a mug)
do
  local top = rect(316, 184, 371, 188)
  inkrim(top); S.planks(top, OAK, { vert = false, w = 99, base = 4, seed = 7 }); R(316, 184, 371, 184, OAK[6]); R(316, 188, 371, 188, OAK[2])
  P(371, 186, OAK[5]); P(316, 186, OAK[5])
  local ap = rect(320, 189, 367, 193); inkrim(ap); c:fillMask(ap, OAK[2]); R(320, 189, 367, 189, OAK[1])
  for _, x in ipairs{321, 362} do local l = rect(x, 194, x + 4, 219); inkrim(l); obj(l, OAK, { base = 3, lit = 0 }); R(x, 194, x + 4, 194, OAK[1]) end
  local st = rect(326, 208, 361, 210); inkrim(st); obj(st, OAK, { base = 3, lit = 1, shade = 1 })
  R(326, 219, 362, 219, "#6a4a52")
  -- teapot: plump body, spout to the left, lid a touch askew
  local body = rr(329, 172, 344, 183, 4)
  local spout = poly{{321, 172}, {324, 172}, {330, 178}, {330, 181}, {327, 181}}
  local handle = rect(345, 175, 348, 180):cut(rect(345, 177, 346, 178))
  local lid = poly{{331, 168}, {341, 167}, {342, 171}, {331, 172}}
  local all = body:copy():add(spout):add(handle):add(lid)
  inkrim(all)
  c:fillMask(spout, TEAL[3]); P(322, 173, TEAL[5])
  c:fillMask(handle, TEAL[2])
  tex(body, function(x, y)
    if x <= 331 and y <= 176 then return TEAL[6] end
    if x >= 342 or y >= 182 then return TEAL[2] end
    if y <= 174 then return TEAL[5] end
    return TEAL[4]
  end)
  R(330, 178, 343, 178, CREAM[5]); for x = 331, 342, 3 do P(x, 179, BARN[4]) end   -- painted band with red dots
  c:fillMask(lid, TEAL[4]); R(331, 171, 342, 171, TEAL[2]); P(333, 169, TEAL[6])
  local kb = rect(335, 165, 337, 166); inkrim(kb); c:fillMask(kb, GOLD[5])
  P(332, 174, CREAM[6]); P(333, 174, CREAM[6])
  -- mug
  local mug = rect(353, 177, 359, 183); local mh = rect(360, 178, 361, 181)
  local mm = mug:copy():add(mh); inkrim(mm)
  c:fillMask(mug, BARN[4]); R(353, 177, 359, 177, BARN[6]); R(358, 178, 359, 183, BARN[2]); R(353, 178, 353, 182, BARN[5])
  c:fillMask(mh, BARN[2]); P(361, 179, INK); P(361, 180, INK)
  R(354, 178, 357, 178, "#5a3424")                                              -- cocoa
end

---------------------------------------------------------------- front door 44x112 at 420..463 x 108..219 (arched)
do
  local d = rect(420, 128, 463, 219):add(c:ellipse(441.5, 128, 21.5, 20):cut(rect(0, 129, W, H)))
  -- stone surround
  local sur = d:grow(4):cut(d)
  sur:clip(rect(0, 0, W - 1, 219))
  inkrim(d:grow(4):clip(rect(0, 0, W - 1, 219)))
  tex(sur, function(x, y)
    local k = floor((y + floor(x / 6) * 3) / 7)
    local n = hash(floor(x / 6), k, 41)
    local tone = (n > .6) and 5 or ((n > .25) and 4 or 3)
    if (y + floor(x / 6) * 3) % 7 == 0 then tone = 2 end
    if x > 441 and tone > 3 then tone = tone - 1 end
    return STONE[tone]
  end)
  -- door boards
  inkrim(d)
  tex(d, function(x, y)
    local k = floor((x - 420) / 7); local p = (x - 420) % 7
    if p == 0 then return OAK[1] end
    local tone = (k % 2 == 0) and 4 or 3
    if p == 1 then tone = tone + 1 end
    if hash(x, floor(y / 4), 13) > .94 then tone = tone - 1 end
    if x >= 460 then tone = tone - 1 end
    return OAK[max(1, min(6, tone))]
  end)
  -- iron strap hinges with nail heads
  for _, y in ipairs{136, 198} do
    R(420, y, 452, y + 2, IRON[3]); R(420, y, 452, y, IRON[5]); R(420, y + 3, 452, y + 3, IRON[1])
    R(453, y, 455, y + 2, IRON[3]); P(455, y + 1, IRON[1])
    for x = 424, 450, 6 do P(x, y + 1, IRON[6]) end
  end
  -- little peep window with a cross bar
  local pw = rect(436, 116, 447, 127)
  inkrim(pw)
  tex(pw, function(x, y)
    if x == 441 or y == 121 then return OAK[2] end
    if x - 436 + y - 116 < 6 then return "#c8e4f0" end
    return SBLUE[5]
  end)
  P(437, 117, CREAM[6])
  -- latch bar
  local lb = rect(452, 166, 458, 168); inkrim(lb); c:fillMask(lb, IRON[4]); R(452, 166, 458, 166, IRON[6])
  local kn = rect(455, 169, 456, 173); inkrim(kn); c:fillMask(kn, IRON[3]); P(455, 169, IRON[5])
  -- quirk: a sprig of heather tucked behind the top hinge
  for i = 0, 6 do P(428 - i, 134 - i, LEAF[3]) end
  for _, p in ipairs{{423, 128}, {421, 129}, {424, 130}, {422, 131}, {425, 132}} do P(p[1], p[2], "#b070b8"); P(p[1] + 1, p[2], "#d098d4") end
  -- doorstep
  local ds = rect(414, 216, 469, 219); inkrim(ds); obj(ds, STONE, { base = 4, lit = 1, shade = 1 })
end

---------------------------------------------------------------- floor: neutral boards (every floor layer replaces this)
do
  local m = rect(0, 220, W - 1, H - 1)
  tex(m, function(x, y)
    local row = floor((y - 220) / 7); local ly = (y - 220) % 7
    local off = (row % 2) * 31
    local seam = ((x + off) % 62 == 0)
    if ly == 0 or seam then return "#6e625c" end
    if ly == 1 then return "#a89a8e" end
    if hash(floor((x + off) / 62), row, 51) > .5 then return "#948678" end
    return "#8c7e72"
  end)
  R(0, 220, W - 1, 220, INK)
  R(0, 221, W - 1, 221, "#5e5054")
end

-- the gnome's stand spot needs nothing; the banner crop is y104..224.
c:save{ aseprite = OUT .. "hovel-room.aseprite", png = OUT .. "hovel-room.png" }
HP.report(c)
print("ok")

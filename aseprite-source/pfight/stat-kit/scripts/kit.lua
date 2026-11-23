-- kit.lua : the stat kit art. Opus drawing pass (redraw of the Sonnet scaffold; the first pass is kept in the session scratchpad).
-- One script draws every source and every PNG, into ../strip and ../hand (each .aseprite with named layers + a flat .png):
--   sock-<size>-any-knob / -hole   "any" edge: kite head on a short neck, a 3-strand twine (body red / mind violet / craft gold)
--   env-<size>-spring              Spring env piece: the v48 Sun tile with a blossom-pink stitch, hand-drawn blossom glyph
--   snare-<size>                   hidden snare: dashed twine noose, three woven leaves, a knot with two loose ends (cell overlay)
--   badges-<size>                  four stat badges Nimble Lore Luck Sense (one row; 11x11 / 18x18 plates as parts48 badges)
--   stolen-<size>                  steel fish-hook with a violet thread still through its eye (14x14 / 24x24)
-- Run:  cd aseprite-source/pfight/stat-kit/scripts && /tmp/aseq/squashfs-root/AppRun -b --script kit.lua && python3 build.py
-- Small art is hand-placed letter grids (G.* below); only geometry that must fit other parts (socket outline, snare ring) is computed.
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local V47 = D .. "../../v47/scripts/"
local V48 = D .. "../../v48/"
local OUT = D .. "../"
local L = dofile(V47 .. "lib47.lua")
local INK = L.INK

local PAL = {
  K = INK,
  P = 0xf9b8cf, p = 0xe8789f, q = 0xb4486f,                     -- blossom pink
  Y = 0xffe38a, y = 0xf5b82e, o = 0xd98322,                     -- gold eye
  G = 0x9bd46e, g = 0x5fae48, h = 0x3c7f3a, H = 0x2c5e2e,       -- leaf greens
  c = L.CREAM, d = L.CREAMSH,                                   -- badge glyph cream
  S = 0xdfe6ee, s = 0x9aa6b5, t = 0x5f6b7e,                     -- hook steel (light is not white)
  V = 0xd2bcf8, v = 0xa982ec, w = 0x7a5cc0,                     -- thread violet (mind family hue)
  m = 0xc4dc8a, x = 0x6f9a48,                                   -- snare twine: pale, green
}

-- hand-placed pixel grids (Opus drawing pass). "." = empty; letters = palette keys in PAL
local G = {}
G.glyph = {
  ["strip"] = {
    "........PPp.......",
    ".......PPppq......",
    "..PPp..Pppqq.PPq..",
    ".PPpppqPppq.PPppq.",
    ".Pppppqq.YY.qpppq.",
    "..qpppqoYyyoqppq..",
    "...qqqPoyyoPpqq...",
    "....PPpqooqPPppq..",
    "...PPpppq.qPpppq..",
    "....qppqhg.qqppq..",
    ".GG..qq.hg..qq.GG.",
    "GgggG...hg....GSgh",
    ".hgggghhhg..Gggghh",
    "..hhhhghhg.Gggghh.",
    ".......hghhgghhh..",
    "........hg........",
    "........hg........",
  },
  ["hand"] = {
    "..............PPPPp.............",
    "............PPPPpppq............",
    "...........PPPppppppq...........",
    "...........PPpppppppq...........",
    "....PPPp...PPpppppppq...PPPp....",
    "..PPPPppq..qPpppppppq..PPpppq...",
    ".PPPppppq...qqpppppqq.PPppppppq.",
    ".PPpppppppq...qqqqq..PPpppppppq.",
    ".Ppppppppppq.YYYyyo.Ppppppppppq.",
    "..qpppppppppYYyyyyyoqppppppppq..",
    "...qqppppppqYyyyyyyoqpppppppq...",
    ".....qqqpppqoyyyyyooqpppqqq.....",
    ".......PPPPpqoyyyoo.PPpppq......",
    "......PPPppppqooooqPPppppppq....",
    ".....PPppppppq.qq.qPpppppppq....",
    ".....Pppppppppq...Pppppppppq....",
    "......qpppppppq..qPppppppppq....",
    ".......qqppppq.hg.qppppppqq.....",
    ".........qqqq..hg..qqqqqq.......",
    ".GGGG..........hg......GGGGG....",
    "GGgggggG.......hg....GGgggggh...",
    ".Gggggggggh....hg...GgggSsgggh..",
    ".hhggggggggghh.hg..Gggggsgggggh.",
    "...hhgggggggggghg.Gggggggggghh..",
    ".....hhhgggggggghggggggggghh....",
    ".........hhhhhhhhggghhhhhh......",
    "...............hgh..............",
    "...............hg...............",
    "...............hg...............",
    "...............hg...............",
  },
}
G.icon = {
  ["nimble-s"] = {
    ".........",
    "cc..cc...",
    ".cc..cc..",
    "..cc..cc.",
    "...cc..cc",
    "..cd..cd.",
    ".cd..cd..",
    "cd..cd...",
    ".........",
  },
  ["lore-s"] = {
    ".cccccK..",
    ".cccccdK.",
    ".cKKKccd.",
    ".ccccccd.",
    ".cKKKKcd.",
    ".ccccccd.",
    ".cKKKccd.",
    ".ccccccd.",
    ".ddddddd.",
  },
  ["luck-s"] = {
    ".cc...cc.",
    "cccc.cccc",
    "cccc.cccd",
    ".ccc.cdd.",
    ".........",
    ".ccc.ccc.",
    "cccc.cccd",
    ".cdd.Kdd.",
    ".....K...",
  },
  ["sense-s"] = {
    ".....cccc",
    "...cccccc",
    "..ccccccd",
    ".cccccKcd",
    ".ccccKccd",
    ".cccKccd.",
    ".ccKcdd..",
    ".cKdd....",
    "K........",
  },
  ["nimble-h"] = {
    "..............",
    "ccc....ccc....",
    ".ccc....ccc...",
    "..ccc....ccc..",
    "...ccc....ccc.",
    "....ccc....ccc",
    ".....ccc....cc",
    ".....ccd....cd",
    "....ccd....ccd",
    "...ccd....ccd.",
    "..ccd....ccd..",
    ".ccd....ccd...",
    "ccd....ccd....",
    "..............",
  },
  ["lore-h"] = {
    ".cccccccK.....",
    ".cccccccdK....",
    ".cccccccddK...",
    ".ccccccccccd..",
    ".cKKKKKKcccd..",
    ".ccccccccccd..",
    ".cKKKKKKKKcd..",
    ".ccccccccccd..",
    ".cKKKKKcccKd..",
    ".ccccccccccK..",
    ".cKKKKKKKccd..",
    ".ccccccccccd..",
    ".dddddddddddd.",
    "..............",
  },
  ["luck-h"] = {
    "..............",
    "..ccc...ccc...",
    ".ccccc.ccccc..",
    ".ccccc.ccccc..",
    ".ccccc.ccccd..",
    "..cccc.cccd...",
    "..............",
    "..cccc.cccc...",
    ".ccccc.ccccd..",
    ".ccccc.ccccd..",
    ".ccccd.cccdd..",
    "..cdd.K.ddd...",
    ".......K......",
    "........K.....",
  },
  ["sense-h"] = {
    ".........ccccc",
    "......cccccccc",
    "....ccccccccdc",
    "...cccccccccdd",
    "..cccccccccKcd",
    ".ccccccccKKccd",
    ".cccccccKccccd",
    ".ccccccKccccd.",
    ".cccccKccccdd.",
    ".ccccKccccdd..",
    ".cccKccccdd...",
    "..cKddddd.....",
    ".K............",
    "K.............",
  },
}
G.stolen = {
  ["strip"] = {
    "VV..........",
    ".vVv....sSs.",
    "...wvVvwSvt.",
    "........sSt.",
    ".........St.",
    ".S.......St.",
    ".SSs.....St.",
    ".sSt.....St.",
    ".sS......St.",
    "..sS....sSt.",
    "..tsSSSSSt..",
    "...tttttt...",
  },
  ["hand"] = {
    "...............sSSs...",
    "VVv...........sSvvSt...",
    ".vVVv.....wvvVvvvwSt...",
    "...wvVVvvvw...sSSSt....",
    "..............sSt......",
    "..............sSt......",
    "..............sSt......",
    "..............sSt......",
    "..S...........sSt......",
    ".SSs..........sSt......",
    ".SSSs.........sSt......",
    ".sSsss........sSt......",
    ".sSs..........sSt......",
    ".sSS..........sSt......",
    "..sSs........sSSt......",
    "..sSSs......sSStt......",
    "...tsSSSsssSSStt.......",
    "....ttsSSSSStt.........",
    "......tttttt...........",
    ".......................",
    ".......................",
    ".......................",
  },
}
G.snare = {
  ["leafv-s"] = {
    ".G.",
    "GGg",
    "Ggh",
    "Ggh",
    ".gh",
    ".h.",
  },
  ["leafh-s"] = {
    ".GGg..",
    "GgggGh",
    "..ghh.",
  },
  ["knot-s"] = {
    "x...m",
    ".mxx.",
    ".xgh.",
  },
  ["leafv-h"] = {
    "..G..",
    ".GGg.",
    ".GGgh",
    "GGggh",
    "GGggh",
    "GgHgh",
    "Ggghh",
    ".gHh.",
    ".ghh.",
    "..h..",
  },
  ["leafh-h"] = {
    "...GGGg....",
    ".GGGgggggh.",
    "GgHHHHHggghh",
    "..gggghhhh..",
    "....hhh.....",
  },
  ["knot-h"] = {
    "m.........",
    ".xm.....m.",
    "..xm...x..",
    "...mGgx...",
    "..mGggh...",
    "..xgghh...",
    "...hhh....",
  },
}

local function save(path, w, h, layers)
  app.fs.makeAllDirectories(app.fs.filePath(path))
  local spr = Sprite(w, h, ColorMode.RGB)
  for i, l in ipairs(layers) do
    local layer = (i == 1) and spr.layers[1] or spr:newLayer()
    layer.name = l.name
    local img = Image(w, h, ColorMode.RGB)
    for y = 0, h - 1 do for x = 0, w - 1 do
      local c = l.cv:get(x, y)
      if c then img:putPixel(x, y, app.pixelColor.rgba((c >> 16) & 255, (c >> 8) & 255, c & 255, 255)) end
    end end
    spr:newCel(layer, 1, img, Point(0, 0))
    if l.hidden then layer.isVisible = false end
  end
  spr:saveAs(path .. ".aseprite")
  spr:saveCopyAs(path .. ".png")
  spr:close()
end

-- stamp a letter grid at (ox, oy); outline = true adds a 1 px ink line on the 4-neighbours outside the drawing
local function stamp(cv, rows, ox, oy, outline, flip)
  local pts = {}
  for j, row in ipairs(rows) do
    local n = #row
    for i = 1, n do
      local ch = flip and row:sub(n - i + 1, n - i + 1) or row:sub(i, i)
      local col = PAL[ch]
      if col then pts[(oy + j - 1) * 10000 + ox + i - 1] = col end
    end
  end
  if outline then
    for k in pairs(pts) do
      local x, y = k % 10000, k // 10000
      for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local kk = (y + o[2]) * 10000 + x + o[1]
        if not pts[kk] then cv:set(x + o[1], y + o[2], INK) end
      end
    end
  end
  for k, col in pairs(pts) do cv:set(k % 10000, k // 10000, col) end
end
local function gsize(rows) return #rows[1], #rows end

local SIZES = { strip = { k = 1, name = "strip" }, hand = { k = 30 / 17, name = "hand" } }
for _, n in ipairs({ "strip", "hand" }) do for a, b in pairs(L.CFG[n]) do SIZES[n][a] = b end end
local ORDER = { "strip", "hand" }

---------------------------------------------------------------- 1. "any" sockets: a kite head on a short neck, a three-strand twine
-- strands run diagonally; each strand is shaded across its width (light, base, shade) so the bands read as twisted rope, not stripes
local STR = {
  { L.FAMLIGHT.body, L.FAM.body, 0xb03e34, 0x7c2a26 },
  { L.FAMLIGHT.mind, L.FAM.mind, 0x7a5cc0, 0x543f8c },
  { L.FAMLIGHT.craft, L.FAM.craft, 0xc08a10, 0x8a600c },
}
local S_FILL, S_LIGHT, S_SHADE = 0x808081, 0x909091, 0xa0a0a1   -- markers, mapped to strand colours at the end
local function inAny(c, len, u, i)
  if u < 0 or u > len - 1 or i < 0 or i > c.T - 1 then return false end
  local k = c.k
  local dx, y = math.abs(u - (len - 1) / 2), (i + .5) * (k == 1 and 1.045 or 1)
  if dx <= 2.5 * k and y <= 2.8 * k then return true end
  local e = (k == 1) and 1.1 or 1.2   -- < 2: a kite (diamond) head, not a ball
  return (dx / (6.4 * k)) ^ e + (math.abs(y - 7.2 * k) / (5.7 * k)) ^ e <= 1
end
local function strand(x, y, c, side)  -- the twist keeps one handedness on the board: flip the diagonal on left/right sides
  local t = (side == "top" or side == "bottom") and (x - y) or (x + y)
  local p = (c.k == 1) and 3 or 5
  return (math.floor(t / p) % 3) + 1, t % p, p
end
local function recolour(cv, c, side, ring)
  for y = 0, cv.h - 1 do for x = 0, cv.w - 1 do
    local v = cv:get(x, y)
    if v == S_FILL or v == S_LIGHT or v == S_SHADE then
      local b, ph, p = strand(x, y, c, side)
      local s = STR[b]
      local col
      if ring then col = (v == S_LIGHT) and s[1] or (v == S_SHADE) and s[3] or s[2]
      elseif p == 3 then col = (ph == 0) and s[1] or (ph == 1) and s[2] or s[3]
      else col = (ph == 0) and s[1] or (ph <= 2) and s[2] or (ph == 3) and s[3] or s[4] end
      if not ring and v == S_LIGHT and ph ~= p - 1 then col = s[1] end   -- the lit rim up-left
      if not ring and v == S_SHADE and ph == 0 then col = s[2] end
      cv:set(x, y, col)
    end
  end end
end
local function knobSide(c, side)
  local len = L.sideLen(c, side)
  local cv = L.cv(c.W, c.H)
  local inK2 = function(u, v) return u >= 0 and u <= len - 1 and inAny(c, len, u, math.max(v - 1, 0)) and v <= c.T end
  local list = {}
  for v = 0, c.T do for u = 0, len - 1 do if inK2(u, v) then
    local x, y = L.sideXY(c, side, u, v)
    local edge = not (inK2(u - 1, v) and inK2(u + 1, v) and inK2(u, v + 1) and (v == 0 or inK2(u, v - 1)))
    list[#list + 1] = { x, y, edge }
  end end end
  for _, p in ipairs(list) do cv:set(p[1], p[2], p[3] and INK or S_FILL) end
  for _, p in ipairs(list) do
    local x, y = p[1], p[2]
    if not p[3] then
      local function ink(xx, yy) return cv:get(xx, yy) == INK end
      if ink(x - 1, y) or ink(x, y - 1) then cv:set(x, y, S_LIGHT)
      elseif ink(x + 1, y) or ink(x, y + 1) then cv:set(x, y, S_SHADE) end
    end
  end
  recolour(cv, c, side)
  return cv
end
local function holeSide(c, side)
  local len = L.sideLen(c, side)
  local ring, cut = L.cv(c.W, c.H), L.cv(c.W, c.H)
  local inH, r1 = {}, {}
  for d = 0, c.T - 1 do for u = 0, len - 1 do
    if inAny(c, len, u, d) then local x, y = L.sideXY(c, side, u, -d); cut:set(x, y, L.ERASE); inH[y * 1000 + x] = true end
  end end
  local function adj(set, x, y) for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do if set[(y + o[2]) * 1000 + x + o[1]] then return true end end return false end
  for d = -2, c.T + 1 do for u = -2, len + 1 do
    local x, y = L.sideXY(c, side, u, -d)
    if not inH[y * 1000 + x] and adj(inH, x, y) and L.inBody(c, x - c.T, y - c.T) then ring:set(x, y, INK); r1[y * 1000 + x] = true end
  end end
  for d = -2, c.T + 1 do for u = -2, len + 1 do
    local x, y = L.sideXY(c, side, u, -d)
    if not inH[y * 1000 + x] and not r1[y * 1000 + x] and adj(r1, x, y) and L.inBody(c, x - c.T, y - c.T) and not L.isRim(c, x - c.T, y - c.T) then
      local col = S_FILL
      if r1[(y + 1) * 1000 + x] or r1[y * 1000 + x + 1] then col = S_SHADE
      elseif r1[(y - 1) * 1000 + x] or r1[y * 1000 + x - 1] then col = S_LIGHT end
      ring:set(x, y, col)
    end
  end end
  recolour(ring, c, side, true)
  return ring, cut
end
local function socks(c, kind)
  local tile = L.cv(c.W, c.H)   -- hidden neutral test tile
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do if L.inBody(c, x, y) then tile:set(c.T + x, c.T + y, L.isRim(c, x, y) and INK or 0x8a7a66) end end end
  local layers, cuts = { { name = "test-tile (hidden)", cv = tile, hidden = true } }, L.cv(c.W, c.H)
  for _, side in ipairs(L.SIDES) do
    if kind == "knob" then layers[#layers + 1] = { name = "knob-" .. side, cv = knobSide(c, side) }
    else
      local ring, cut = holeSide(c, side)
      layers[#layers + 1] = { name = "hole-rim-" .. side, cv = ring }
      cuts:blit(cut, 0, 0)
    end
  end
  if kind == "hole" then layers[#layers + 1] = { name = "erase-marker", cv = cuts } end
  save(OUT .. c.name .. "/sock-" .. c.name .. "-any-" .. kind, c.W, c.H, layers)
end

---------------------------------------------------------------- 2. Spring env piece: the v48 Sun tile, stitch recoloured, a hand-drawn blossom
local SPRING = 0xd0608c            -- blossom pink stitch (the Sun stitch is 0xd98322)
local function spring(c)
  local src = app.open(V48 .. c.name .. "/env-" .. c.name .. "-sun.aseprite")
  local gl
  for _, l in ipairs(src.layers) do
    if l.name == "stitch" then
      local img = l.cels[1].image
      for y = 0, img.height - 1 do for x = 0, img.width - 1 do
        local p = img:getPixel(x, y)
        if app.pixelColor.rgbaA(p) > 0 and app.pixelColor.rgbaR(p) == 0xd9 and app.pixelColor.rgbaG(p) == 0x83 and app.pixelColor.rgbaB(p) == 0x22 then
          img:putPixel(x, y, app.pixelColor.rgba((SPRING >> 16) & 255, (SPRING >> 8) & 255, SPRING & 255, 255))
        end
      end end
    elseif l.name == "glyph" then gl = l end
  end
  src:deleteLayer(gl)
  local layer = src:newLayer(); layer.name = "glyph"
  local rows = G.glyph[c.name]
  local gw, gh = gsize(rows)
  local cx = c.name == "hand" and 69.5 or 40.5        -- atlas glyph_centre
  local cy = c.name == "hand" and 61.5 or 36.0
  local g = L.cv(c.W, c.H)
  stamp(g, rows, math.floor(cx - gw / 2 + .5), math.floor(cy - gh / 2 + .5), true)
  local img = Image(c.W, c.H, ColorMode.RGB)
  for y = 0, c.H - 1 do for x = 0, c.W - 1 do
    local v = g:get(x, y)
    if v then img:putPixel(x, y, app.pixelColor.rgba((v >> 16) & 255, (v >> 8) & 255, v & 255, 255)) end
  end end
  src:newCel(layer, 1, img, Point(0, 0))
  local base = OUT .. c.name .. "/env-" .. c.name .. "-spring"
  src:saveAs(base .. ".aseprite")
  layer.isVisible = false; src:saveCopyAs(base .. "-tile.png")             -- the tile alone (no glyph), as envtiles
  for _, l in ipairs(src.layers) do l.isVisible = (l == layer) end
  src:saveCopyAs(base .. "-glyph.png")                                     -- the glyph alone, as envglyphs
  src:close()
end

---------------------------------------------------------------- 3. snare: a board-cell overlay (body/pitch size). Faint by dashing, never by alpha.
local function snare(c)
  local W, H = c.BW, c.BH
  local strip = c.name == "strip"
  local rx, ry, gap = strip and 17.5 or 30, strip and 14.5 or 25, strip and 10 or 8      -- gap: degrees each side of the top knot
  local on, off = strip and 4 or 6, strip and 2 or 3                                     -- dash, in px of arc
  local cx, cy, rm = W / 2, H / 2, (rx + ry) / 2
  local P = 2 * math.pi * math.sqrt((rx * rx + ry * ry) / 2)
  local lo, hi = strip and -1 or -1.5, strip and 1 or 1.5
  local ring = L.cv(W, H)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local d = (math.sqrt((dx / rx) ^ 2 + (dy / ry) ^ 2) - 1) * rm
    local deg = (math.deg(math.atan(dy, dx)) + 90) % 360
    if deg >= gap and deg <= 360 - gap and d >= lo and d < hi then
      local ph = ((deg - gap) / 360 * P) % (on + off)
      if ph < on then
        local col
        if d >= hi - 1 then col = INK                                                     -- ink on the outside
        elseif not strip and d < lo + 1 then col = (ph < on - 1) and PAL.m or PAL.x      -- pale on the inside
        else col = (ph < 1.2) and PAL.m or (ph >= on - 1.2) and PAL.h or PAL.x end      -- each dash a twisted strand
        ring:set(x, y, col)
      end
    end
  end end
  local sz = strip and "s" or "h"
  local top = L.cv(W, H)
  local lv, lh, kn = G.snare["leafv-" .. sz], G.snare["leafh-" .. sz], G.snare["knot-" .. sz]
  local lw, lhh = gsize(lv)
  local function rnd(v) return math.floor(v + .5) end
  stamp(top, lv, rnd(cx - rx - lw / 2), rnd(cy - lhh / 2) + 1, true)
  stamp(top, lv, rnd(cx + rx - lw / 2), rnd(cy - lhh / 2) - 1, true, true)
  local hw, hh = gsize(lh)
  stamp(top, lh, rnd(cx - hw / 2) + 2, rnd(cy + ry - hh / 2), true)
  local kw, kh = gsize(kn)
  stamp(top, kn, rnd(cx - kw / 2), rnd(cy - ry - kh / 2) - (strip and 1 or 2), true)
  save(OUT .. c.name .. "/snare-" .. c.name, W, H, { { name = "loop", cv = ring }, { name = "leaves+knot", cv = top } })
end

---------------------------------------------------------------- 4. stat badges: the parts48 plate (ink frame, cut corners, flat fill), a cream glyph
local STATS = { "nimble", "lore", "luck", "sense" }
local BG = { nimble = 0xa8523a, lore = 0x3a5fa8, luck = 0x3f8a4a, sense = 0x2f8a86 }
local function plate(n, bg)
  local p = L.cv(n, n)
  p:rect(0, 0, n - 1, n - 1, INK); p:rect(1, 1, n - 2, n - 2, bg)
  p:set(0, 0, nil); p:set(n - 1, 0, nil); p:set(0, n - 1, nil); p:set(n - 1, n - 1, nil)
  p:set(1, 1, INK); p:set(n - 2, 1, INK); p:set(1, n - 2, INK); p:set(n - 2, n - 2, INK)
  return p
end
local function badges(c)
  local n = c.badge
  local row, layers = L.cv(n * 4, n), {}
  for i, s in ipairs(STATS) do
    local b = plate(n, BG[s])
    stamp(b, G.icon[s .. (n == 11 and "-s" or "-h")], n == 11 and 1 or 2, n == 11 and 1 or 2, false)
    row:blit(b, (i - 1) * n, 0)
    local lc = L.cv(n * 4, n); lc:blit(b, (i - 1) * n, 0)
    layers[#layers + 1] = { name = s, cv = lc }
  end
  save(OUT .. c.name .. "/badges-" .. c.name, n * 4, n, layers)
end

---------------------------------------------------------------- 5. stolen mark: steel fish-hook, tip up-left, the violet thread still through its eye
local function stolen(c)
  local s = (c.name == "hand") and 24 or 14
  local cv = L.cv(s, s)
  stamp(cv, G.stolen[c.name], 1, 1, true)
  save(OUT .. c.name .. "/stolen-" .. c.name, s, s, { { name = "mark", cv = cv } })
end

for _, n in ipairs(ORDER) do
  local c = SIZES[n]
  socks(c, "knob"); socks(c, "hole")
  spring(c); snare(c); badges(c); stolen(c)
  print("built", n)
end

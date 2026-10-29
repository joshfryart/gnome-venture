-- cf_badges.lua : Cat Fish badges (9) and ribbons (5), step 5b of claude/catfish-art-brief.md. Stitched Toy via gvlib.
-- Run: AppRun -b --script cf_badges.lua      Writes test/cf-badge-<key>.png + .aseprite and test/cf-ribbon-<tier>.png
-- + .aseprite (64 x 64, icon mode: 1 px #000000 border last, umber outline under it, margin >= 3, alpha 0/255).
--
-- BADGES: one shared enamel-pin base so the nine read as a set: a round metal rim (5 px ring, enamel comma on its
-- lit upper left) holding a felt field sewn in with a gold edge stitch at the join; each badge has its own field
-- colour and one clear emblem. The rim colour is the tier: bronze, silver, gold (book12 / book_half / book_full
-- run bronze -> silver -> gold; first_cat and nap1 bronze, odd_eyed and nap5 silver, full_house and legendary gold).
--   first_cat  orange tabby cat face on teal              full_house  red-roofed house, a cat in each lit window
--   odd_eyed   white cat face, one blue and one amber eye legendary   grey cat with a gold crown and gold sparkles
--   nap1       curled sleeping cream cat + one z         nap5        the same sleeping cat + five tiny stars
--   book12     open book, 12 pips (6 a page)             book_half   left page of coat swatches filled, right empty
--   book_full  every swatch filled, gold clasp and corners, gold glow round the book
-- Cat faces reuse the cat template look: head felt one tone lighter than the ears, locked 5x5 eyes with the umber
-- ring, pink nose, muzzle; odd_eyed tints the iris exactly like cf_overlays.lua (ring minus its upper-left 3 px).
--
-- RIBBONS: one rosette shape (scalloped pleat ring, an inner pleat ring, a centre button, two notched tails)
-- that differs by colour and size. Pleats are radial 1 px fold lines in the ring's shade; the inner ring's folds
-- sit half a pleat round from the outer ring's. Gold thread only at the join of the inner ring and the pleats.
-- No text: the centre carries pips (blue 1, red 2, white 3) or a star (best).
--   best   big rosette, purple pleats round a gold ring, purple button with a gold star, three tails
--   blue / red / white  the standard rosette; white is cream-white felt (pale: lit-side outline one step darker,
--          so it reads on light and dark chips)
--   part   small green rosette, plain button with two thread holes, short tails
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local C = GV.C

-- 4-tone felt ramp (base, shade, rim, gloss) in gvlib's 7 slots, like the cat coat
local function felt(base, shade, rim, gloss) return { base = base, shade = shade, deep = shade, bounce = base, rim = rim, gloss = gloss or rim, dot = gloss or rim } end
local METAL = {
  bronze = felt("#b8743a", "#844423", "#e09a5a", "#f8cf98"),
  silver = felt("#aeb2bf", "#73748a", "#dfe1e6", "#f6f4ee"),
  gold   = felt("#e8a317", "#b8661a", "#f5cf6a", "#fff1c8"),
}
local CAT = {
  orange = { shade = "#a8502e", base = "#d9803f", light = "#f2b277", gloss = "#fbe2b4" },
  grey   = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" },
  cream  = { shade = "#b9a68c", base = "#dccbb0", light = "#f1e6d2", gloss = "#fdf6e8" },
  white  = { shade = "#bab0c0", base = "#e6dfd2", light = "#f4efe6", gloss = "#fbf6ec" },
}
local function coat(t) return felt(t.base, t.shade, t.light, t.gloss) end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK = "#e8909e"
local EYE = { blue = "#4f9fe0", amber = "#e0902a" }
local CX, CY = 31, 31

local results = {}
local function save(c, name)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local line = string.format("%-22s ", name) .. GV.report(t)
  print(line)
  assert(t.semi == 0 and t.margin >= 3 and t.bw == 0, name .. ": check failed")
  if t.colours > 20 then print("WARN " .. name .. ": " .. t.colours .. " colours (cap 20)") end
  results[#results + 1] = line
  return t
end
local function mirror(c, m) local n = c:mask() m:each(function(x, y) n:set(2 * CX - x, y) end) return n end

-- ======================================== badges ========================================
-- base: rim ring + felt field + gold edge stitch at the join; returns the canvas and the field mask
local function badgeBase(rim, field)
  local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
  local outer = c:ellipse(CX, CY, 24)
  local face = c:ellipse(CX, CY, 19)
  c:build{
    { "rim", outer, METAL[rim], { gloss = { 13, 16 } } },
    { "field", face, field, { gloss = false, cres = 4 } },
  }
  c:stitch(face)
  return c, face
end

-- cat face emblem centred on (cx, cy): head about 25 x 18, ears up to cy - 12
local function catFace(c, cx, cy, t, eyes)
  local head = c:ellipse(cx, cy, 12, 8.5):add(c:ellipse(cx, cy + 3, 12.5, 6))
  local earL = c:poly({ { cx - 12, cy + 1 }, { cx - 11, cy - 12 }, { cx - 3, cy - 6 } }):grow(1)
  local earR = mirror(c, earL)
  local p = c:build{
    { "earL", earL, coat(t), { cres = 2, gloss = false } },
    { "earR", earR, coat(t), { cres = 2, gloss = false } },
    { "head", head, coatHi(t), { gloss = { cx - 9, cy - 5 } } },
  }
  local inL = c:poly({ { cx - 10, cy - 3 }, { cx - 10, cy - 10 }, { cx - 5, cy - 6 } }):cut(head)
  c:fill(inL, PINK); c:fill(mirror(c, inL), PINK)
  c:fill(c:ellipse(cx, cy + 5, 3, 1.5), t.gloss)
  c:paint({ "ppp", ".p." }, cx - 1, cy + 3, { p = PINK })
  c:paint({ "u.u" }, cx - 1, cy + 5, { u = "ol2" })
  for i, ex in ipairs({ cx - 8, cx + 4 }) do
    local ey = cy - 3
    c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, ex - 1, ey - 1, { u = "umber" })
    c:eye(ex, ey)
    if eyes then -- iris: the ring round the pupil minus its upper-left 3 px (cf_overlays.lua rule)
      for _, d in ipairs({ {3, 0}, {4, 1}, {4, 2}, {4, 3}, {1, 4}, {2, 4}, {3, 4}, {0, 3}, {0, 2} }) do c:px(ex + d[1], ey + d[2], eyes[i]) end
    end
  end
  return p, head
end

-- 4-point sparkle (5 x 5) or a tiny plus star (3 x 3)
local function sparkle(c, x, y, a, b) c:paint({ "..a..", "..a..", "aabaa", "..a..", "..a.." }, x - 2, y - 2, { a = a, b = b }) end
local function star3(c, x, y, a, b) c:paint({ ".a.", "aba", ".a." }, x - 1, y - 1, { a = a, b = b }) end

local BADGE = {}
BADGE.first_cat = function()
  local c = badgeBase("bronze", felt("#3f8fb0", "#2f6290", "#5fa8c4"))
  local t = CAT.orange
  catFace(c, CX, CY + 2, t)
  -- tabby forehead: three short strokes in the coat shade, an "M"
  c:paint({ "s.s.s", "s.s.s", "..s.." }, CX - 2, CY - 5, { s = t.base })
  return c
end
BADGE.odd_eyed = function()
  local c = badgeBase("silver", felt("#b8456a", "#8a2f55", "#d9667f"))
  catFace(c, CX, CY + 2, CAT.white, { EYE.blue, EYE.amber })
  return c
end
BADGE.legendary = function()
  local c = badgeBase("gold", felt("#a8241f", "#6b1b2c", "#c8402a"))
  local G = METAL.gold
  catFace(c, CX, CY + 5, CAT.grey)
  local crown = c:poly({ { 23, 27 }, { 23, 18 }, { 27, 23 }, { 31, 15 }, { 35, 23 }, { 39, 18 }, { 39, 27 } })
  crown:add(c:rect(22, 24, 40, 28))
  c:part(crown, G, { cres = 2, gloss = false })
  c:paint({ "gg", "gg" }, 22, 16, { g = G.gloss }); c:paint({ "gg", "gg" }, 38, 16, { g = G.gloss })
  c:paint({ "gg", "gg" }, 30, 13, { g = G.gloss })
  c:paint({ "bb", "bb" }, 30, 24, { b = EYE.blue })
  for x = 23, 39, 3 do c:px(x, 27, G.shade) end
  sparkle(c, 16, 24, G.rim, G.gloss); sparkle(c, 46, 26, G.rim, G.gloss); star3(c, 44, 17, G.rim, G.gloss)
  return c
end
BADGE.full_house = function()
  local c = badgeBase("gold", felt("#3e2f66", "#291d4a", "#5a4890"))
  local G = METAL.gold
  local roof = c:poly({ { 15, 30 }, { 31, 15 }, { 48, 30 } }):add(c:rect(16, 28, 46, 30))
  local walls = c:rect(19, 29, 43, 44)
  c:build{
    { "chim", c:rect(39, 17, 42, 26), felt("#9a6b3f", "#7a4a1f", "#c98a4a"), { flat = true } },
    { "walls", walls, felt("#e9b98a", "#c47a52", "#f9d49c", "#ffe2a8"), { cres = 3, gloss = false } },
    { "roof", roof, felt("#dd3a2a", "#ae2a2a", "#f2793a", "#ff9158"), { cres = 3, gloss = { 22, 26 } } },
  }
  -- lit windows, each with a cat silhouette looking out (two gold eye pixels)
  for _, wx in ipairs({ 21, 33 }) do
    c:fill(c:rect(wx, 32, wx + 8, 41), G.gloss)
    c:fill(c:rect(wx, 37, wx + 8, 41), G.rim)
    c:paint({
      ".x.....x.",
      ".xx...xx.",
      ".xxxxxxx.",
      ".xgxxxgx.",
      ".xxxxxxx.",
    }, wx, 37, { x = "umber", g = G.rim })
  end
  c:fill(c:ellipse(31, 24, 2), G.gloss)
  c:seam({ { 16, 30 }, { 47, 30 } }, { gap = "#ae2a2a" })
  star3(c, 19, 21, G.rim, G.gloss); star3(c, 45, 36, G.rim, G.gloss)
  return c
end

-- curled sleeping cat (cream), head on the left, tail round the front
local function sleeper(c, t)
  local body = c:ellipse(34, 39, 13, 8)
  local head = c:ellipse(22, 37, 8.5, 7)
  local earL = c:poly({ { 15, 35 }, { 15, 27 }, { 20, 31 } }):grow(1)
  local earR = c:poly({ { 23, 31 }, { 28, 27 }, { 29, 34 } }):grow(1)
  local tail = c:line({ { 46, 40 }, { 45, 45 }, { 39, 47 }, { 30, 47 } }, 4)
  c:build{
    { "body", body, coat(t), { gloss = { 30, 33 } } },
    { "earL", earL, coat(t), { cres = 2, gloss = false } },
    { "earR", earR, coat(t), { cres = 2, gloss = false } },
    { "head", head, coatHi(t), { gloss = { 16, 33 } } },
    { "tail", tail, coat(t), { cres = 2, gloss = false } },
  }
  c:fill(c:poly({ { 16, 33 }, { 16, 29 }, { 19, 31 } }):cut(head), PINK)
  c:paint({ "u...u", ".uuu." }, 16, 37, { u = "umber" })
  c:paint({ "u...u", ".uuu." }, 23, 37, { u = "umber" })
  c:paint({ "pp" }, 21, 40, { p = PINK })
  c:seam({ { 36, 34 }, { 40, 33 }, { 44, 35 } })
end
local NAVY = felt("#2a3c6c", "#1e2a50", "#3f5a8c")
BADGE.nap1 = function()
  local c = badgeBase("bronze", NAVY)
  sleeper(c, CAT.cream)
  -- one z, 2 px strokes, cream with a hand umber outline (a part's inner contour ate the thin diagonal)
  local z = c:ascii({ "zzzzzzz", "zzzzzzz", "....zz.", "...zz..", "..zz...", ".zz....", "zzzzzzz", "zzzzzzz" }, 36, 15)
  c:fill(z:grow(1):cut(z), C.ol3)
  c:fill(z, "#f2e4c0")
  c:paint({ "gg" }, 36, 15, { g = "#fff3c8" })
  return c
end
BADGE.nap5 = function()
  local c = badgeBase("silver", NAVY)
  sleeper(c, CAT.cream)
  local G = METAL.gold
  for _, p in ipairs({ { 18, 25 }, { 24, 19 }, { 31, 16 }, { 38, 19 }, { 44, 25 } }) do star3(c, p[1], p[2], G.rim, G.gloss) end
  return c
end

-- open book: cover behind two cream pages bowed at the top, kept inside the field (corners clear of the rim)
local GREEN = felt("#4f9a45", "#2f6a3a", "#7ab55c")
local PAGE = felt("#f1ece0", "#d8c49a", "#fff3c8")
local COVER = { { 17, 22 }, { 31, 25 }, { 46, 22 }, { 46, 42 }, { 31, 45 }, { 17, 42 } }
local function book(c, cover)
  local pl = c:poly({ { 18, 22 }, { 24, 20 }, { 31, 23 }, { 31, 41 }, { 24, 39 }, { 18, 41 } })
  return c:build{
    { "cover", c:poly(COVER), cover, { cres = 3, gloss = false } },
    { "pl", pl, PAGE, { cres = 3, gloss = false, pale = false } },
    { "pr", mirror(c, pl), PAGE, { cres = 3, gloss = false, pale = false } },
  }
end
-- 2 cols x 3 rows of 4 x 4 cells per page; f(x, y, i) paints cell i (1..12, left page first)
local function cells(f)
  local i = 0
  for _, cols in ipairs({ { 20, 25 }, { 34, 39 } }) do
    for r = 0, 2 do for k = 1, 2 do
      i = i + 1
      f(cols[k], 25 + r * 5, i)
    end end
  end
end
local RED = felt("#dd3a2a", "#ae2a2a", "#f2793a")
BADGE.book12 = function()
  local c = badgeBase("bronze", GREEN)
  book(c, RED)
  cells(function(x, y) c:paint({ ".uu.", "uuuu", "uuuu", ".uu." }, x, y, { u = "umber" }) end)
  return c
end
-- coat swatches use colours already on the badge (ginger, grey, umber black, brown, red, green): no new colours
local function swatch(c, x, y, col) c:paint({ "ssss", "ssss", "ssss", "ssss" }, x, y, { s = col }); c:px(x, y, PAGE.gloss) end
local function empty(c, x, y) c:paint({ "dddd", "d..d", "d..d", "dddd" }, x, y, { d = PAGE.shade }) end
BADGE.book_half = function()
  local c = badgeBase("silver", GREEN)
  book(c, RED)
  local S = { "#e8a317", METAL.silver.shade, C.ol3, C.ol1, RED.base, GREEN.base }
  cells(function(x, y, i) if i <= 6 then swatch(c, x, y, S[i]) else empty(c, x, y) end end)
  return c
end
BADGE.book_full = function()
  local c, face = badgeBase("gold", GREEN)
  local G = METAL.gold
  -- glow: gold light hugging the book (1 px), then a 1 px band of light felt, gold twinkles above it
  local cov = c:poly(COVER)
  c:fill(cov:grow(2):clip(face:shrink(3)), GREEN.rim)
  c:fill(cov:grow(1):clip(face:shrink(3)), G.rim)
  book(c, RED)
  local S = { "#e8a317", G.shade, C.ol3, C.ol1, RED.base, GREEN.base, "#e8a317", C.ol1, C.ol3, G.shade, GREEN.base, RED.base }
  cells(function(x, y, i) swatch(c, x, y, S[i]) end)
  -- gold clasp: corner caps on the cover and a strap with a stud on the right edge
  c:paint({ "gg", "g." }, 17, 22, { g = G.rim }); c:paint({ "gg", ".g" }, 44, 22, { g = G.rim })
  c:paint({ "g.", "gg" }, 17, 41, { g = G.base }); c:paint({ ".g", "gg" }, 44, 41, { g = G.base })
  c:part(c:rect(44, 29, 48, 34), G, { flat = true })
  c:px(46, 31, G.gloss); c:px(47, 32, G.shade)
  star3(c, 22, 17, G.rim, G.gloss); star3(c, 40, 17, G.rim, G.gloss); star3(c, 31, 15, G.rim, G.gloss)
  return c
end

for _, k in ipairs({ "first_cat", "full_house", "odd_eyed", "legendary", "nap1", "nap5", "book12", "book_half", "book_full" }) do
  save(BADGE[k](), "cf-badge-" .. k)
end

-- ======================================== ribbons ========================================
-- rosette at (cx, cy): pleat disc radius R (scallops reach R + 2), inner ring 0.62 R, button 0.36 R
local function rosette(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
  local cx, cy, R = CX, o.cy, o.R
  local outer = c:ellipse(cx, cy, R)
  local n = o.n or 16
  for i = 0, n - 1 do
    local a = (i + 0.5) * 2 * math.pi / n
    outer:add(c:ellipse(cx + math.cos(a) * R, cy + math.sin(a) * R, 2))
  end
  local ri, rb = math.floor(R * 0.62 + 0.5), math.floor(R * 0.36 + 0.5)
  local inner = c:ellipse(cx, cy, ri)
  local button = c:ellipse(cx, cy, rb)
  -- tails: notched strips hanging from behind the rosette
  local list = {}
  for i, tl in ipairs(o.tails) do
    local m = c:line({ { cx + tl[1], cy + 2 }, { cx + tl[2], o.tailEnd } }, o.tw)
    local ex = cx + tl[2]
    m:cut(c:poly({ { ex - o.tw, o.tailEnd + 4 }, { ex, o.tailEnd - 2 }, { ex + o.tw, o.tailEnd + 4 } }))
    list[#list + 1] = { "tail" .. i, m, tl[3], { cres = 2, gloss = false } }
  end
  list[#list + 1] = { "outer", outer, o.outer, { gloss = { cx - R + 3, cy - R + 5 }, pale = o.pale } }
  list[#list + 1] = { "inner", inner, o.inner, { cres = 3, gloss = false, pale = o.pale } }
  list[#list + 1] = { "button", button, o.button, { cres = 2, gloss = false } }
  local p = c:build(list)
  -- pleat folds: radial 1 px shade lines; inner ring folds offset by half a pleat
  local function folds(P, r0, r1, off, k)
    for i = 0, k - 1 do
      local a = (i + off) * 2 * math.pi / k
      for r = r0, r1, 0.5 do
        local x, y = math.floor(cx + math.cos(a) * r + 0.5), math.floor(cy + math.sin(a) * r + 0.5)
        local kk = c:key(x, y)
        if c.own[kk] == P and not c.gl.s[kk] then c:px(x, y, P.r.shade) end
      end
    end
  end
  folds(p.outer, ri + 2, R + 1, 0.5, n)
  folds(p.inner, rb + 2, ri - 1, 0, o.ni or 12)
  c:stitch(inner)
  if o.centre then o.centre(c, cx, cy) end
  return c
end
local WHITE = felt("#e6dfd2", "#bab0c0", "#fbf6ec", "#fbf6ec")
local BLUE = felt("#3f8fb0", "#2f6290", "#8fcbd8", "#c8ecdc")
local REDR = felt("#dd3a2a", "#ae2a2a", "#f2793a", "#ff9158")
local PURPLE = felt("#7a5cc0", "#4e3a8a", "#a894dc", "#c3b2ea")
local MOSS = felt("#4f9a45", "#2f6a3a", "#7ab55c", "#c8d77a")
local function pips(nn)
  return function(c, cx, cy)
    local P = { { { 0, 0 } }, { { -2, 0 }, { 2, 0 } }, { { -2, 1 }, { 2, 1 }, { 0, -2 } } }
    for _, d in ipairs(P[nn]) do c:paint({ "uu", "uu" }, cx + d[1] - 1, cy + d[2] - 1, { u = "umber" }) end
  end
end
local STD = { cy = 24, R = 14, tw = 6, tailEnd = 52, n = 16 }
local function std(t) local o = {} for k, v in pairs(STD) do o[k] = v end for k, v in pairs(t) do o[k] = v end return o end
local RIB = {}
RIB.best = function()
  local G = METAL.gold
  return rosette{ cy = 25, R = 17, tw = 6, tailEnd = 53, n = 18, ni = 14,
    tails = { { -4, -14, PURPLE }, { 4, 14, PURPLE }, { 0, 0, G } },
    outer = PURPLE, inner = G, button = PURPLE,
    centre = function(c, cx, cy)
      c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, cx - 2, cy - 2, { g = G.rim })
      c:px(cx, cy - 1, G.gloss)
    end }
end
RIB.blue = function() return rosette(std{ tails = { { -3, -12, BLUE }, { 3, 12, BLUE } }, outer = BLUE, inner = BLUE, button = METAL.gold, centre = pips(1) }) end
RIB.red = function() return rosette(std{ tails = { { -3, -12, REDR }, { 3, 12, REDR } }, outer = REDR, inner = REDR, button = METAL.gold, centre = pips(2) }) end
RIB.white = function() return rosette(std{ tails = { { -3, -12, WHITE }, { 3, 12, WHITE } }, outer = WHITE, inner = WHITE, button = METAL.gold, centre = pips(3), pale = true }) end
RIB.part = function()
  return rosette{ cy = 26, R = 10, tw = 5, tailEnd = 48, n = 12, ni = 8,
    tails = { { -2, -8, MOSS }, { 2, 8, MOSS } }, outer = MOSS, inner = MOSS, button = METAL.gold,
    centre = function(c, cx, cy) c:px(cx - 1, cy - 1, C.hole); c:px(cx + 1, cy + 1, C.hole) end }
end
for _, k in ipairs({ "best", "blue", "red", "white", "part" }) do save(RIB[k](), "cf-ribbon-" .. k) end

-- cf_overlays.lua : Cat Fish cat overlay layers (step 3 of claude/catfish-art-brief.md), Stitched Toy via gvlib.
-- Run: AppRun -b --script cf_overlays.lua       Reads test/cf-cat-grey-<frame>.png, writes into test/:
--   A. eyes   cf-eyes-ring-<f>.png (placeholder 'eye_ring' hex) + cf-eyes-<amber|green|blue|hazel>-<f>.png, 5 frames
--   B. marks  cf-pat-<tabby|tuxedo|calico|pointed|spotted>-grey-<f>.png on idleA, pounce, catch, nap
--   C. parts  cf-ears-folded-<f>.png + cf-ears-mask-<f>.png, cf-tail-bobtail-<f>.png + cf-tail-mask-<f>.png
--   plus cf-overlays-<f>.aseprite (one layer per overlay, hidden, over the base cat) to look at in Aseprite.
--
-- LAYER ORDER (renderer): body, pattern, ears, tail, eyes. A replacement part works in two steps: clear the
-- mask's pixels (alpha 255 = clear) from the body AND pattern layers below, then draw the part on top. The
-- mask covers the original ear/tail felt, inner pink, its inner contour on the head/body, its umber outline
-- and its black border. The part layer also carries the few head/body pixels the clear removed (head-top
-- outline, body felt and edge stitch that the old tail covered), so  base - mask + part  equals a true
-- render of the cat with that part (checked pixel-exact below). Patterns are not drawn on replacement parts.
--
-- COLOURS. Overlays use the grey template's own tones so tools/catfish_recolor.py derives them per coat:
--   template (tones.json): shade #57516f  base #8a859b  light #cdc9d3  gloss #f1ebe3
--   extra roles (tones_overlays.json): coat_deep #3d3654 (a dark mark over the crescent), patch_white family
--   (fixed white felt, tuxedo and calico), eye_ring (placeholder for the iris ring; the 4 finals are tinted).
-- A MARK never paints new shapes of shading: it steps the tone of each coat pixel under it, so the base cat's
-- crescent, rim, bounce and contact shadows stay where they are:
--   dark  = one tone down  (gloss rim -> light, light -> base, base -> shade, shade -> deep); the enamel comma
--           itself is left alone so the gloss still reads on a stripe.
--   light = one tone up    (shade -> base, base -> light, light -> gloss).
--   white = patch_white by role: rim/comma -> pw_gloss, felt -> pw, crescent -> pw_shade, deep -> pw_deep.
--   Roles come from the part's ramp: body/legs/tail/ears use coat (rim light, felt base, crescent shade); head
--   and paws use coatHi (rim gloss, felt light, crescent base, deep shade).
-- Marks only touch coat-tone pixels of cat parts, so they never cover eyes, nose, inner ears, stitches, the
-- fish, the outline or the border: every overlay is clipped to the silhouette interior by construction.
--
-- EYES (approved decision): the locked disc stays. The 1 px ring inside the disc is the 12 cream px round the
-- 3x3 pupil; tinting all 12 hid the cream completely, so the iris is the ring minus its upper-left 3 px
-- (the lit side keeps a cream crescent, like a glint on the eye's glaze): 9 tinted px per eye.
-- Closed eyes (catch happy squint, nap sleep arcs) show no iris: their eye files are written but EMPTY
-- (fully transparent) so the renderer can stack 5 eye layers for every frame without special cases.
-- Odd-eyed cats: the renderer takes the left eye from one colour's file and the right from another
-- (left eye x < 25 + ox, right eye x >= 25 + ox; ox per frame below).
--
-- GEOMETRY. The frame drawing code below is a copy of cf_test.lua pass 6 (idleA, pounce, catch, nap) with
-- switches for the ears (orig / none / fold) and tail (orig / none / bob). The script re-renders each base
-- frame and asserts it matches the committed cf-cat-grey PNG pixel for pixel, so a later cf_test edit that
-- moves the cat makes this script stop with an error instead of writing overlays that no longer line up.
-- Frame offsets (head, eyes): idleA 0,0  pounce 16,0  catch 0,0  nap 0,18  stalk 15,20.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local pc = app.pixelColor

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local DEEP = "#3d3654"
local PW = { gloss = "#fbf6ec", base = "#e6dfd2", shade = "#bab0c0", deep = "#8d829a" }
local EYE_RING = "#ff00ff" -- placeholder: the recolour script swaps it for the eye colour
local EYES = { amber = "#e0902a", green = "#7cb342", blue = "#4f9fe0", hazel = "#a89436" }
local TONE = { [DEEP] = 0, [GREY.shade] = 1, [GREY.base] = 2, [GREY.light] = 3, [GREY.gloss] = 4 }
local BYTONE = { [0] = DEEP, GREY.shade, GREY.base, GREY.light, GREY.gloss }

-- ===================== copy of cf_test.lua pass 6 (keep in step; checked against the PNGs) =====================
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3
local STITCH_ONLY = nil -- set while rendering a replacement-part variant: body pixels the base cat showed
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
local function edgeStitch(c, m, P, o)
  o = o or {}
  local s1 = m:shrink(1); local s2 = s1:shrink(1)
  local x0, y0, x1, y1 = m:bbox()
  local cx, cy = o.cx or (x0 + x1) / 2, o.cy or (y0 + y1) / 2
  local ring = {}
  for k in pairs(s1.s) do
    if not s2.s[k] then
      local x, y = c:xy(k)
      if c:inside(x, y) then ring[#ring + 1] = { x, y, k, math.atan(y - cy, x - cx) } end
    end
  end
  table.sort(ring, function(a, b) return a[4] < b[4] end)
  local on, off = o.on or 2, o.off or 1
  for i, p in ipairs(ring) do
    local k = p[3]
    local lit = (p[1] - cx) + (p[2] - cy) <= (o.lit or 1e9)
    local skip = STITCH_ONLY and not STITCH_ONLY[p[2] * 64 + p[1]] -- (overlays) no new dash on body a part used to hide
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit and not skip then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
-- folded ear (Scottish fold), idleA coords, left side; the right one is its mirror about x = 25.
-- The flap is folded forward and down over the head's top corner, so the silhouette shows a low round cap
-- instead of a point. Built after the head (sits on it): gets the inner contour and a contact shadow.
local function foldMask(c, ox, oy)
  local L = c:poly({ {11, 13}, {14, 9}, {19, 8.5}, {22.5, 11}, {21, 14}, {16, 16}, {12, 16} })
  local R = c:mask()
  L:each(function(x, y) R:set(50 - x, y) end)
  return L:shift(ox, oy), R:shift(ox, oy)
end
local function catHead(c, ox, oy, ears)
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local earL = c:poly({ {10 + ox, 21 + oy}, {12 + ox, 7 + oy}, {23 + ox, 13 + oy} }):grow(1)
  local earR = c:poly({ {27 + ox, 13 + oy}, {38 + ox, 7 + oy}, {40 + ox, 21 + oy} }):grow(1)
  local list = {}
  if ears == "orig" then
    list[#list + 1] = { "earL", earL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "earR", earR, g, { cres = 2, gloss = false } }
  end
  list[#list + 1] = { "head", head, h, { gloss = { 14 + ox, 15 + oy } } }
  if ears == "fold" then
    local fL, fR = foldMask(c, ox, oy)
    list[#list + 1] = { "foldL", fL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "foldR", fR, g, { cres = 2, gloss = false } }
  end
  return list, head
end
local function eyeRing(c, x, y)
  c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y, mode)
  if mode == "happy" then c:paint({ ".uuu.", "uu.uu", "u...u" }, x, y + 1, { u = "umber" })
  elseif mode == "sleep" then c:paint({ "u...u", "uu.uu", ".uuu." }, x, y + 1, { u = "umber" })
  else eyeRing(c, x, y); c:eye(x, y) end
end
local function catFace(c, ox, oy, head, eyes, ears)
  if ears == "orig" then
    c:fill(c:poly({ {13 + ox, 18 + oy}, {13 + ox, 9 + oy}, {21 + ox, 14 + oy} }):cut(head), PINK)
    c:fill(c:poly({ {29 + ox, 14 + oy}, {37 + ox, 9 + oy}, {37 + ox, 18 + oy} }):cut(head), PINK)
  elseif ears == "fold" then -- fold crease: one shade line where the flap turns over (lit side of the flap)
    local fL, fR = foldMask(c, ox, oy)
    local function crease(m, pts)
      for _, p in ipairs(pts) do
        local x, y = p[1] + ox, p[2] + oy
        if m:has(x, y) and c:get(x, y) ~= GREY.shade then c:px(x, y, GREY.shade) end
      end
    end
    crease(fL, { {13, 12}, {14, 12}, {15, 11}, {16, 11}, {17, 11}, {18, 11} })
    crease(fR, { {37, 12}, {36, 12}, {35, 11}, {34, 11}, {33, 11}, {32, 11} })
  end
  c:fill(c:ellipse(25 + ox, 27 + oy, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  catEye(c, 14 + ox, 19 + oy, eyes); catEye(c, 32 + ox, 19 + oy, eyes)
end
local function paw(c, cx, cy, toes, rx, ry)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
  c.names[P] = "paw"
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = GREY.base }) end
end
local function tailTip(c, tail, region, seam) tint(c, region:clip(tail), GREY.base, GREY.light); c:seam(seam) end
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local function build(c, list)
  local p = c:build(list)
  for n, P in pairs(p) do c.names[P] = n end
  return p
end
local function bobEntry(c, m) return { "bob", m, coat(GREY), { cres = 2, gloss = false } } end

-- each frame: o.ears = orig|none|fold, o.tail = orig|none|bob. Returns the canvas (not finished) and info.
local FR = {}
FR.idleA = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0, o.ears)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = { {38, 52}, {45, 52}, {50, 49}, {52, 44}, {52, 38}, {51, 34} }
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(41.5, 49.5, 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(46, 30, 56, 36), { { 49, 37 }, { 53, 37 } }) end
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, "open", o.ears)
  return c, { ox = 0, oy = 0, tpts = tpts, p = p }
end
FR.pounce = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local OX, OY = 16, 0
  local H, head = catHead(c, OX, OY, o.ears)
  local A = math.atan(-10, 24)
  local body = rell(c, 28, 37, 15, 7, A)
  local tpts = { {17, 38}, {12, 35}, {9, 30}, {9, 24}, {12, 20} }
  local tail = c:line(tpts, 5)
  local legF = c:line({ {38, 33}, {44, 37}, {48, 39} }, 4)
  local legN = c:line({ {36, 38}, {41, 42}, {45, 44} }, 4)
  local legB = c:line({ {17, 40}, {13, 41}, {12, 41} }, 4)
  local legH = c:line({ {22, 44}, {17, 47}, {14, 49} }, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(13.5, 33.5, 4, 3.5)) end
  list[#list + 1] = { "legB", legB, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "legF", legF, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "body", body, g, { gloss = { 18, 36 } } }
  list[#list + 1] = { "legH", legH, g, { cres = 2, gloss = false } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  list[#list + 1] = { "legN", legN, g, { cres = 2, gloss = false } }
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(5, 15, 18, 23), { { 7, 24 }, { 11, 24 } }) end
  paw(c, 50.5, 39.5); paw(c, 47.5, 45.5)
  paw(c, 10.5, 41.5); paw(c, 11.5, 49.5)
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open", o.ears)
  c:ground(30.5, 57.5, 5.5, 1, "#4a2c1a")
  return c, { ox = OX, oy = OY, tpts = tpts, p = p, A = A }
end
FR.catch = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0, o.ears)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = { {38, 52}, {45, 51}, {50, 46}, {52, 39}, {51, 33}, {47, 30} }
  local tail = c:line(tpts, 5)
  local F = { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f2a860", base = "#dc6f2c", shade = GV.ramp("#dc6f2c").shade }
  F.deep, F.bounce = F.shade, F.shade
  local FIN = { gloss = "#f2c14e", dot = "#f2c14e", rim = "#f2c14e", base = "#f2c14e", shade = GV.ramp("#f2c14e").shade }
  FIN.deep, FIN.bounce = FIN.shade, FIN.shade
  local fish = c:ellipse(23, 41, 9, 5.5)
  local fTail = c:poly({ {30, 41}, {39, 34}, {40, 38}, {37, 41}, {40, 44}, {39, 48} })
  local fFin = c:poly({ {18, 37}, {21, 33}, {26, 33}, {29, 37} })
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(41.5, 49.5, 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  list[#list + 1] = { "fTail", fTail, FIN, { cres = 2, deep = 0, bounce = false, gloss = false } }
  list[#list + 1] = { "fFin", fFin, FIN, { cres = 2, deep = 0, bounce = false, gloss = false } }
  list[#list + 1] = { "fish", fish, F, { cres = 2, deep = 0, bounce = false, gloss = false } }
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(42, 26, 52, 32), { { 48, 29 }, { 49, 33 } }) end
  tint(c, c:ellipse(23, 45, 7, 1.5):clip(fish), F.base, F.rim)
  c:paint({ "..gg", ".g..", "g..." }, 19, 37, { g = F.gloss }); c:px(21, 38, F.dot)
  c:paint({ "s.s", ".s." }, 25, 41, { s = F.shade })
  c:seam({ { 18, 37 }, { 19, 40 }, { 18, 44 } })
  c:eye(15, 39, true)
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  paw(c, 16.5, 45.5, true, 3.5, 2.5); paw(c, 28.5, 46, true, 3.5, 2.5)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, "happy", o.ears)
  return c, { ox = 0, oy = 0, tpts = tpts, p = p }
end
FR.nap = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local OX, OY = 0, 18
  local H, head = catHead(c, OX, OY, o.ears)
  local body = c:ellipse(36, 42, 20, 10)
  local thigh = c:ellipse(45, 42, 8, 7)
  local tpts = { {50, 35}, {53, 38}, {54, 44}, {51, 50}, {46, 53}, {38, 54} }
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(54, 34.5, 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 30, 35 } } }
  list[#list + 1] = { "thigh", thigh, g, { cres = 2, gloss = false } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } } end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(30, 48, 41, 58), { { 42, 52 }, { 42, 56 } }) end
  edgeStitch(c, body, p.body, { ymax = 46, lit = LIT })
  catFace(c, OX, OY, head, "sleep", o.ears)
  return c, { ox = OX, oy = OY, tpts = tpts, p = p }
end
-- ================================================ end of copy =================================================

local KEY = { "idleA", "pounce", "catch", "nap" }
local ALL = { "idleA", "pounce", "catch", "nap", "stalk" }
local OFF = { idleA = { 0, 0 }, pounce = { 16, 0 }, catch = { 0, 0 }, nap = { 0, 18 }, stalk = { 15, 20 } }
local CLOSED = { catch = true, nap = true }

-- ---------- pixel tables: [y*64+x] = "#hex" ----------
local function hex(v) return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
local function loadPNG(path)
  local img = Image{ fromFile = path }
  local t = {}
  for y = 0, 63 do for x = 0, 63 do
    local v = img:getPixel(x, y)
    if pc.rgbaA(v) == 255 then t[y * 64 + x] = hex(v) elseif pc.rgbaA(v) ~= 0 then error(path .. ": semi alpha") end
  end end
  return t
end
local function pixOf(c)
  c:finish()
  local t = {}
  for y = 0, 63 do for x = 0, 63 do t[y * 64 + x] = c.pix[c:key(x, y)] end end
  return t
end
local function toImage(t)
  local img = Image(64, 64, ColorMode.RGB)
  img:clear(pc.rgba(0, 0, 0, 0))
  for i, h in pairs(t) do
    local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
    img:putPixel(i % 64, i // 64, pc.rgba(r, g, b, 255))
  end
  return img
end
local function savePNG(name, t)
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = toImage(t)
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
  local n, seen = 0, {}
  for _, h in pairs(t) do if not seen[h] then seen[h] = true; n = n + 1 end end
  if n > 8 then print("WARN " .. name .. ": " .. n .. " colours (cap 8)") end
  return n
end
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local written, report = {}, {}
local function emit(name, t, group)
  local n = savePNG(name, t)
  written[#written + 1] = { name = name, t = t, group = group }
  report[#report + 1] = string.format("%-30s px=%4d colours=%d", name, count(t), n)
end

-- ---------- base frames: re-render, compare with the committed PNG ----------
local BASE, INFO, CAN = {}, {}, {}
for _, f in ipairs(KEY) do
  local c, info = FR[f]({ ears = "orig", tail = "orig" })
  local file = loadPNG(OUT .. "cf-cat-grey-" .. f .. ".png")
  local mine = pixOf(c)
  for i = 0, 4095 do
    if file[i] ~= mine[i] then error(string.format("%s: re-render differs from cf-cat-grey PNG at %d,%d (%s vs %s): copy is out of step with cf_test.lua", f, i % 64, i // 64, tostring(file[i]), tostring(mine[i]))) end
  end
  BASE[f], INFO[f], CAN[f] = file, info, c
end
BASE.stalk = loadPNG(OUT .. "cf-cat-grey-stalk.png")

-- ================================ A. eyes ================================
-- iris = the 12 cream px round the pupil minus the upper-left 3 (kept cream, lit side)
local IRIS = { {3, 0}, {4, 1}, {4, 2}, {4, 3}, {1, 4}, {2, 4}, {3, 4}, {0, 3}, {0, 2} }
for _, f in ipairs(ALL) do
  local ox, oy = OFF[f][1], OFF[f][2]
  local function eyes(col)
    local t = {}
    if CLOSED[f] then return t end
    for _, ex in ipairs({ 14, 32 }) do
      for _, d in ipairs(IRIS) do
        local x, y = ex + ox + d[1], 19 + oy + d[2]
        assert(BASE[f][y * 64 + x] == GV.C.halo, f .. ": eye ring px is not cream at " .. x .. "," .. y)
        t[y * 64 + x] = col
      end
    end
    return t
  end
  emit("cf-eyes-ring-" .. f, eyes(EYE_RING), "eyes")
  for _, e in ipairs({ "amber", "green", "blue", "hazel" }) do emit("cf-eyes-" .. e .. "-" .. f, eyes(EYES[e]), "eyes") end
end

-- ================================ B. pattern marks ================================
local HI = { head = true, paw = true }
local CATPART = { head = true, paw = true, body = true, tail = true, earL = true, earR = true, thigh = true,
  legB = true, legF = true, legH = true, legN = true }
-- apply a list of {mask, op} (later entries win) to frame f, return the overlay pixel table
local function marks(f, list)
  local c, base = CAN[f], BASE[f]
  local op = {}
  for _, e in ipairs(list) do e[1]:each(function(x, y) op[y * 64 + x] = e[2] end) end
  local out = {}
  for i, o in pairs(op) do
    local x, y = i % 64, i // 64
    local k = c:key(x, y)
    local P = c.own[k]
    local name = P and c.names[P]
    local h = base[i]
    local tn = h and TONE[h]
    if name and CATPART[name] and tn then
      local comma = c.gl.s[k]
      local new
      local role = tn - (HI[name] and 1 or 0) -- 3 rim, 2 felt, 1 crescent, 0 deep (coat: light rim)
      if o == "dark" then
        if not comma then new = BYTONE[math.max(0, tn - 1)] end
      elseif o == "darkLit" then -- rings on a 5 px tail: the crescent stays clean so the rings do not plaid
        if not comma and role >= 2 then new = BYTONE[tn - 1] end
      elseif o == "light" then
        new = BYTONE[math.min(4, tn + 1)]
      elseif o == "white" then
        if comma or role >= 3 then new = PW.gloss elseif role == 2 then new = PW.base
        elseif role == 1 then new = PW.shade else new = PW.deep end
      end
      if new and new ~= h then out[i] = new end
    end
  end
  return out
end
local function partMask(f, names)
  local c = CAN[f]
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local P = c.own[c:key(x, y)]
    if P and names[c.names[P]] then m:set(x, y) end
  end end
  return m
end
local function S(t) local s = {} for _, v in ipairs(t) do s[v] = true end return s end
-- mask from ascii rows at idleA head coords, shifted by the frame offset
local function headAscii(f, rows, x0, y0)
  return CAN[f]:ascii(rows, x0 + OFF[f][1], y0 + OFF[f][2])
end
-- bands across a polyline (tail rings): pixels of mask m whose arc position t (from the first point) has
-- (t - start) % period < width; tip = also mark everything past L - tip
local function rings(f, pts, m, start, period, width, tip)
  local c = CAN[f]
  local segs, L = {}, 0
  for i = 1, #pts - 1 do
    local ax, ay, bx, by = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
    segs[#segs + 1] = { ax, ay, bx, by, len, L }
    L = L + len
  end
  local out = c:mask()
  m:each(function(x, y)
    local best, bt = 1e9, 0
    for si, s in ipairs(segs) do
      local dx, dy = s[3] - s[1], s[4] - s[2]
      local u = ((x - s[1]) * dx + (y - s[2]) * dy) / (s[5] * s[5])
      local uc = u
      if si > 1 then uc = math.max(0, uc) end
      if si < #segs then uc = math.min(1, uc) end
      local px, py = s[1] + dx * uc, s[2] + dy * uc
      local d = (x - px) ^ 2 + (y - py) ^ 2
      if d < best then best, bt = d, s[6] + uc * s[5] end
    end
    if (bt >= start and (bt - start) % period < width) or (tip and bt > L - tip) then out:set(x, y) end
  end)
  return out
end
-- stripes across an axis through (cx,cy) at angle a: pixels with |u - t| < w/2 for t in ts and v in [v0,v1]
-- (u along the axis, v across it, v < 0 = the back / upper side). taper: width shrinks by 1 for v > vt.
local function stripes(f, cx, cy, a, ts, w, v0, v1, vt)
  local c = CAN[f]
  local m, ca, sa = c:mask(), math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx - 0.5, y + 0.5 - cy - 0.5
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if v >= v0 and v <= v1 then
      local ww = (vt and v > vt) and (w - 1) or w
      for _, t in ipairs(ts) do if math.abs(u - t) < ww / 2 then m:set(x, y) end end
    end
  end end
  return m
end
local function lines(f, list, w)
  local c, m = CAN[f], CAN[f]:mask()
  for _, l in ipairs(list) do m:add(c:line(l, w or 2)) end
  return m
end

-- --- head marks shared by all frames (idleA coords) ---
local TABBY_HEAD = { -- forehead "M", eye-corner lines and cheek stripes; x0 = 10, y0 = 11, mirror about x 25
  "..............xxx..............",
  "..........xx..xxx..xx..........",
  "...........xx..x..xx...........",
  "............x..x..x............",
  "............xx.x.xx............",
  ".............x...x.............",
  "...............................",
  "...............................",
  "...............................",
  "...............................",
  "xx...........................xx",
  "...............................",
  "...............................",
  ".xxx.......................xxx.",
  "...xx.....................xx...",
  "...............................",
  ".xxx.......................xxx.",
  "...xx.....................xx...",
}
local function tabby(f)
  local I = INFO[f]
  local L = {}
  L[#L + 1] = { headAscii(f, TABBY_HEAD, 10, 11), "dark" }
  local tail = partMask(f, S{ "tail" })
  L[#L + 1] = { rings(f, I.tpts, tail, 3, 6, 3, nil), "darkLit" }
  L[#L + 1] = { rings(f, I.tpts, tail, 1e9, 1, 0, 4), "dark" } -- dark tip
  local body = partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" })
  local st
  if f == "idleA" or f == "catch" then -- front view: short stripes curling in from both flanks
    local L2 = {}
    for _, y in ipairs({ 37, 42, 47 }) do -- 2 px lines; mirror of x for a 2 px pen is 49 - x
      L2[#L2 + 1] = { {10, y}, {14, y}, {18, y + 3} }
      L2[#L2 + 1] = { {39, y}, {35, y}, {31, y + 3} }
    end
    st = lines(f, L2, 2)
  elseif f == "pounce" then -- side view: stripes across the back, tapering toward the belly
    st = stripes(f, 28, 37, I.A, { -11, -6, -1, 4, 9 }, 2, -8, 1, -2)
    st:add(lines(f, { { {20, 44}, {18, 47} }, { {41, 40}, {42, 43} }, { {44, 34}, {45, 37} } }, 2))
  elseif f == "nap" then -- loaf from the side: stripes down over the back and round the haunch
    st = stripes(f, 46, 42, 0, { -4, 1, 6 }, 2, -11, -1, -4)
    st:add(lines(f, { { {41, 39}, {44, 42}, {45, 46} }, { {46, 37}, {49, 41}, {50, 45} } }, 1))
  end
  L[#L + 1] = { st:clip(body), "dark" }
  return marks(f, L)
end

local MUZZLE = { -- white muzzle, chin and a narrow blaze up the nose (x0 = 19, y0 = 18)
  "......x......",
  ".....xxx.....",
  ".....xxx.....",
  ".....xxx.....",
  "....xxxxx....",
  "...xxxxxxx...",
  "..xxxxxxxxx..",
  ".xxxxxxxxxxx.",
  "xxxxxxxxxxxxx",
  "xxxxxxxxxxxxx",
  ".xxxxxxxxxxx.",
  "..xxxxxxxxx..",
  "...xxxxxxx...",
  "....xxxxx....",
}
local function bib(f, big)
  local c = CAN[f]
  if f == "idleA" or f == "catch" then
    return big and c:ellipse(25, 46, 10, 9) or c:ellipse(25, 40, 5, 10):add(c:poly({ {19, 29}, {31, 29}, {25, 38} }))
  elseif f == "pounce" then
    return big and rell(c, 32, 41, 13, 4.5, INFO[f].A) or rell(c, 36, 40, 7, 3.5, INFO[f].A)
  elseif f == "nap" then
    return big and c:rect(14, 47, 40, 53):add(c:ellipse(46, 50, 7, 3)) or c:rect(14, 47, 38, 53)
  end
end
local function tuxedo(f)
  local L = {}
  L[#L + 1] = { headAscii(f, MUZZLE, 19, 18), "white" }
  L[#L + 1] = { bib(f, false):clip(partMask(f, S{ "body" })), "white" }
  L[#L + 1] = { partMask(f, S{ "paw" }), "white" }
  return marks(f, L)
end

local function calico(f)
  local c, I = CAN[f], INFO[f]
  local ox, oy = I.ox, I.oy
  local L = {}
  -- dark patch over the left ear and forehead corner, one at the right cheek's back edge
  local hp = c:poly({ {6, 4}, {22, 9}, {22, 14}, {18, 17}, {12, 19}, {7, 17} }):shift(ox, oy)
  hp:add(c:poly({ {30, 6}, {40, 6}, {42, 16}, {37, 14}, {33, 11} }):shift(ox, oy))
  L[#L + 1] = { hp:clip(partMask(f, S{ "head", "earL", "earR" })), "dark" }
  -- white: muzzle, a big bib and paws
  L[#L + 1] = { headAscii(f, MUZZLE, 19, 18), "white" }
  L[#L + 1] = { bib(f, true):clip(partMask(f, S{ "body" })), "white" }
  L[#L + 1] = { partMask(f, S{ "paw" }), "white" }
  -- dark patches on the body and tail
  local body = partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" })
  local bp
  if f == "idleA" or f == "catch" then
    bp = c:poly({ {28, 30}, {41, 33}, {42, 44}, {35, 43}, {31, 37} }):add(c:poly({ {8, 47}, {14, 44}, {17, 49}, {14, 56}, {8, 56} }))
  elseif f == "pounce" then
    bp = c:poly({ {17, 33}, {27, 28}, {31, 31}, {28, 37}, {20, 39} }):add(c:poly({ {37, 30}, {44, 32}, {46, 37}, {40, 36} }))
  elseif f == "nap" then
    bp = c:poly({ {40, 31}, {52, 31}, {56, 38}, {50, 44}, {43, 41} })
  end
  L[#L + 1] = { bp:clip(body), "dark" }
  local tail = partMask(f, S{ "tail" })
  L[#L + 1] = { rings(f, I.tpts, tail, 7, 100, 7, nil), "dark" }
  return marks(f, L)
end

local function pointed(f)
  local c, I = CAN[f], INFO[f]
  local L = {}
  -- light body (one tone up), then the dark points on top
  L[#L + 1] = { partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" }), "light" }
  L[#L + 1] = { partMask(f, S{ "earL", "earR", "paw" }), "dark" }
  -- diamond face mask: muzzle, nose bridge and round the eyes, cheeks and brow stay light
  local mask = c:poly({ {25, 14}, {35, 20}, {37.5, 26}, {31, 31.5}, {19, 31.5}, {12.5, 26}, {15, 20} }):shift(I.ox, I.oy)
  L[#L + 1] = { mask:clip(partMask(f, S{ "head" })), "dark" }
  local tail = partMask(f, S{ "tail" })
  local L2 = 0
  for i = 1, #I.tpts - 1 do L2 = L2 + math.sqrt((I.tpts[i + 1][1] - I.tpts[i][1]) ^ 2 + (I.tpts[i + 1][2] - I.tpts[i][2]) ^ 2) end
  L[#L + 1] = { rings(f, I.tpts, tail, L2 * 0.45, 1000, 1000, nil), "dark" }
  -- dark lower legs in the pounce (socks up to the knee)
  if f == "pounce" then L[#L + 1] = { lines(f, { { {44, 37}, {48, 39} }, { {41, 42}, {45, 44} }, { {13, 41}, {12, 41} }, { {17, 47}, {14, 49} } }, 4):clip(partMask(f, S{ "legB", "legF", "legH", "legN" })), "dark" } end
  return marks(f, L)
end

-- spots: a staggered grid jittered by a fixed hash, mixing beans, small diamonds and open rosettes (two
-- commas round a coat-colour centre); a stamp is kept only where it sits wholly inside the cat parts named
-- (shrunk by 1, so no spot touches an edge or a contour). Open 1 px rings read as bubbles, a plain grid of
-- squares read as polka dots and 4-corner rosettes read as little window frames: all tried and dropped.
local ROS = {
  { ".xxx", "xxxx", "xxx." },           -- bean
  { "xx..", "x...", "...x", "..xx" },   -- open rosette: two commas facing each other round a coat centre
  { ".x.", "xxx", ".x." },              -- small diamond
  { "xxx.", "xxxx", ".xxx" },           -- bean, turned
}
local function spotted(f)
  local c, I = CAN[f], INFO[f]
  local L = {}
  local function stampAll(names, step, ox0, oy0, shrink)
    local pm = partMask(f, S(names)):shrink(shrink or 1)
    local m = c:mask()
    local row = 0
    for y = oy0, 60, step - 1 do
      row = row + 1
      for x = ox0 + ((row % 2) * (step // 2)), 60, step do
        local hsh = (x * 73 + y * 151 + row * 31) % 97
        local jx, jy = (hsh % 3) - 1, ((hsh // 3) % 3) - 1
        local r = ROS[(hsh % 4) + 1]
        local st = c:ascii(r, x + jx, y + jy)
        local ok = true
        st:each(function(sx, sy) if not pm:has(sx, sy) then ok = false end end)
        if ok then m:add(st) end
      end
    end
    return m
  end
  local front = f == "idleA" or f == "catch" -- slim side-view bodies (pounce, nap) let spots reach the edge
  local m = stampAll({ "body", "thigh" }, front and 7 or 6, 1, 1, front and 1 or 0)
  m:add(stampAll({ "legB", "legF", "legH", "legN" }, 5, 0, 0))
  -- tail: broken rings (a ring with every third pixel row left out) and a dark tip
  local tail = partMask(f, S{ "tail" })
  local tr = rings(f, I.tpts, tail, 3, 6, 2, 3)
  L[#L + 1] = { m, "dark" }
  L[#L + 1] = { tr, "darkLit" }
  -- head: a few dots on the forehead and cheeks
  L[#L + 1] = { headAscii(f, { -- x0 = 10, y0 = 12, mirror about x 25
    "............xx...xx............",
    "...............................",
    "...............x...............",
    "...............x...............",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "xx...........................xx",
    "x.............................x",
    "...............................",
    ".xx.........................xx.",
  }, 10, 12), "dark" }
  return marks(f, L)
end

local PAT = { tabby = tabby, tuxedo = tuxedo, calico = calico, pointed = pointed, spotted = spotted }
for _, f in ipairs(KEY) do
  for _, name in ipairs({ "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    emit("cf-pat-" .. name .. "-grey-" .. f, PAT[name](f), "pat")
  end
end

-- ================================ C. replacement parts ================================
local function diff(a, b) local m = {} for i = 0, 4095 do if a[i] ~= b[i] then m[i] = true end end return m end
for _, f in ipairs(KEY) do
  for _, slot in ipairs({ { "ears", "folded", "fold" }, { "tail", "bobtail", "bob" } }) do
    local o0 = { ears = "orig", tail = "orig" }
    local oN = { ears = "orig", tail = "orig" }; oN[slot[1]] = "none"
    local oR = { ears = "orig", tail = "orig" }; oR[slot[1]] = slot[3]
    -- variants keep the base cat's stitch dashes only (body that the old part hid gets no new dash; else a
    -- lone gold pixel appears in the part layer and pushes it over the 8-colour cap)
    STITCH_ONLY = {}
    for y = 0, 63 do for x = 0, 63 do
      local P = CAN[f].own[CAN[f]:key(x, y)]
      if P and CAN[f].names[P] == "body" then STITCH_ONLY[y * 64 + x] = true end
    end end
    local none = pixOf((FR[f](oN)))
    local repl = pixOf((FR[f](oR)))
    STITCH_ONLY = nil
    local base = BASE[f]
    local M = diff(base, none)                  -- everything the original part put on the base
    local keep = diff(none, repl)               -- what the replacement adds over the part-less cat
    local mask, part = {}, {}
    for i in pairs(M) do mask[i] = "#ffffff" end
    for i in pairs(M) do if repl[i] then part[i] = repl[i] end end
    for i in pairs(keep) do if repl[i] then part[i] = repl[i] end end
    -- check: base - mask + part == true render of the replacement
    for i = 0, 4095 do
      local v = base[i]
      if mask[i] then v = nil end
      if part[i] then v = part[i] end
      if v ~= repl[i] then error(string.format("%s %s: composite differs at %d,%d", f, slot[1], i % 64, i // 64)) end
    end
    emit("cf-" .. slot[1] .. "-" .. slot[2] .. "-" .. f, part, "part")
    emit("cf-" .. slot[1] .. "-mask-" .. f, mask, "mask")
  end
end

-- ---------- one .aseprite per frame: base + every overlay as a hidden layer (for looking, not exporting) ----------
for _, f in ipairs(ALL) do
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.layers[1].name = "cf-cat-grey-" .. f
  spr.cels[1].image = toImage(BASE[f])
  for _, w in ipairs(written) do
    if w.name:sub(-#f - 1) == "-" .. f then
      local L = spr:newLayer()
      L.name = w.name
      L.isVisible = false
      spr:newCel(L, spr.frames[1], toImage(w.t), Point(0, 0))
    end
  end
  spr:saveAs(OUT .. "cf-overlays-" .. f .. ".aseprite")
  spr:close()
end

-- ---------- tones_overlays.json ----------
local J = {
  '{',
  '  "_note": "Colour roles in the Cat Fish overlay PNGs that are not the 4 grey template tones (tones.json). derive: coat_shade|coat_deep|coat_light = take that tone of the coat ramp; fixed = never recolour; eye_ring = replace with the eye colour. Written by aseprite-source/catfish/cf_overlays.lua.",',
  '  "coat_deep":        { "hex": "' .. DEEP .. '", "derive": "coat_deep",  "use": "dark mark over the crescent (one tone below shade)" },',
  '  "patch_white_gloss": { "hex": "' .. PW.gloss .. '", "derive": "fixed", "use": "tuxedo/calico white patch: rim and enamel" },',
  '  "patch_white":       { "hex": "' .. PW.base .. '", "derive": "fixed", "use": "tuxedo/calico white patch: felt" },',
  '  "patch_white_shade": { "hex": "' .. PW.shade .. '", "derive": "fixed", "use": "tuxedo/calico white patch: crescent, toe lines" },',
  '  "patch_white_deep":  { "hex": "' .. PW.deep .. '", "derive": "fixed", "use": "tuxedo/calico white patch: deep crescent, contact shadow" },',
  '  "eye_ring":          { "hex": "' .. EYE_RING .. '", "derive": "eye_ring", "use": "iris ring placeholder in cf-eyes-ring-<frame>.png" },',
  '  "eye_amber":         { "hex": "' .. EYES.amber .. '", "derive": "fixed", "use": "tinted iris, cf-eyes-amber-*" },',
  '  "eye_green":         { "hex": "' .. EYES.green .. '", "derive": "fixed", "use": "tinted iris, cf-eyes-green-*" },',
  '  "eye_blue":          { "hex": "' .. EYES.blue .. '", "derive": "fixed", "use": "tinted iris, cf-eyes-blue-*" },',
  '  "eye_hazel":         { "hex": "' .. EYES.hazel .. '", "derive": "fixed", "use": "tinted iris, cf-eyes-hazel-*" },',
  '  "mask":              { "hex": "#ffffff", "derive": "fixed", "use": "cf-ears-mask-*/cf-tail-mask-* only: alpha 255 = clear this pixel below; not a drawn colour" }',
  '}',
}
local fh = io.open(here .. "/tones_overlays.json", "w")
fh:write(table.concat(J, "\n") .. "\n")
fh:close()

for _, r in ipairs(report) do print(r) end
print(#written .. " PNG files written")

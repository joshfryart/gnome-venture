-- cf_frames_s3.lua : Cat Fish animation slice S3, grey cat body frames jump, happy, tailflick, eartwitch and the
-- tiny sprites cf-z (sleeping 'z') and cf-sparkle-1..3 (glitter twinkle), Stitched Toy via gvlib.
-- Run: AppRun -b --script cf_frames_s3.lua     Writes test/cf-cat-grey-<jump|happy|tailflick|eartwitch>.png + .aseprite
--      and test/cf-z.png, test/cf-sparkle-<1|2|3>.png (+ .aseprite), then
--      AppRun -b --script cf_overlays_s3.lua   (patterns, folded ears, bobtail, masks, eyes; frames-alias-s3.json).
-- Also loaded as a library by cf_overlays_s3.lua: with the global CF_S3_LIB set it only returns the frame code
-- (M.FR) and draws nothing, so the bodies and the overlays come from ONE copy of the geometry.
--
-- Same template as cf_cats.lua / cf_frames2.lua (the 4 grey tones, fixed accents, separate tail/ear/body/head/paw
-- parts, edge stitch on the lit half only, eyes as the locked disc with an umber ring). The shared head, face, paw
-- and tail-tip code below is a clean copy of cf_overlays.lua's (that script writes files when loaded, so it cannot
-- be dofile'd), with its ear switch (orig / none / fold), tail switch (orig / none / bob), per-ear offsets,
-- folded-flap offsets and the stitch guard. New switches here, all off by default:
--   * an ear offset may carry a tip move {dx, dy, tdx, tdy}: only the ear's tip (and 3/4 of it, the inner pink's
--     tip) moves, the base stays on the head, so the ear tilts instead of sliding (eartwitch);
--   * catFace takes a mouth mode ("smile": raised umber corners round an open mouth, dark-pink inside, pink tongue);
--   * paw takes toes = "up" (toe lines on the top edge: a paw raised with its toes to the sky).
-- With the new switches at their defaults the code draws exactly what cf_cats / cf_overlays draw: the script
-- re-renders idleA and stops unless it matches test/cf-cat-grey-idleA.png pixel for pixel.
--
-- Frame offsets (head, eyes; add to idle A's eye boxes at 14,19 and 32,19; odd-eye split at x = 25 + ox):
--   jump 7,2 (eyes open)   happy 0,0 (happy squint, no iris)   tailflick 0,0   eartwitch 0,0 (both eyes as idleA)
-- jump: straight-up leap, drawn at ground level (the page adds a 16 px translateY arc). Body stretched tall and
--   narrow under the head, both forelegs reaching up past the cheeks with the paws above the ear line (toes up),
--   hind legs hanging straight down with pointed feet, tail trailing low to the right.
-- happy: after a catch. idleA's head with the catch frame's happy squint (^ ^) and an open smile; body tucked
--   for a little hop (shorter, feet tucked up 3 px), front paws raised in front of the chest, tail high with the
--   tip flicked out, a slim umber floor shadow below the gap (like pounce).
-- tailflick: ALIAS of idleA. Same head, ears, body and paws; only the tail differs: swung up high along the right
--   side, tip hooked back toward the head (idleA's tip ends straight up at 51,34). Its tip stays clear of the ear
--   so no hole closes between tail, head and body.
-- eartwitch: ALIAS of idleA. Same everything but the right ear: its tip tilts 2 px out and 2 px down (the base
--   stays put), the inner pink follows 3/4 of the way. A folded right flap drops 1,1 the same way.
-- Tiny sprites (8x8, hand-set pixels, 1 px #000000 border round the shape, alpha 0/255):
--   cf-z: a felt 'z' (dusk-lavender ramp: lit top edge, shade on the lower right), 2 px diagonal stroke.
--   cf-sparkle-1/2/3: four-point twinkle round a 2x2 light core (gold ramp): 1 grow (short arms), 2 full (arms to
--   the tips, light centre), 3 fade (grow's small shape dimmed: gold core, no light centre, darker arms).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local pc = app.pixelColor
local M = { GV = GV, OUT = OUT, here = here }

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3
M.GREY, M.coat, M.coatHi, M.PINK, M.PINKS = GREY, coat, coatHi, PINK, PINKS

-- ===================== shared template (clean copy of cf_overlays.lua; keep in step; checked) =====================
-- M.STITCH_ONLY: set by the overlay script while rendering a replacement-part variant (body pixels the base cat
-- showed); no new stitch dash on body that the old part used to hide.
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
    local skip = M.STITCH_ONLY and not M.STITCH_ONLY[p[2] * 64 + p[1]]
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit and not skip then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
-- folded ear (Scottish fold) at idleA coords, left; the right one is its mirror about x = 25. dL, dR: flap offsets.
local Z = { 0, 0 }
local function foldMask(c, ox, oy, dL, dR)
  local L = c:poly({ {11, 13}, {14, 9}, {19, 8.5}, {22.5, 11}, {21, 14}, {16, 16}, {12, 16} })
  local R = c:mask()
  L:each(function(x, y) R:set(50 - x, y) end)
  dL, dR = dL or Z, dR or Z
  return L:shift(ox + dL[1], oy + dL[2]), R:shift(ox + dR[1], oy + dR[2])
end
M.foldMask = foldMask
-- ear offset e = {dx, dy [, tdx, tdy]}: the whole ear moves dx,dy; the tip moves a further tdx,tdy (S3)
local function tipOf(e) return e[3] or 0, e[4] or 0 end
local function catHead(c, ox, oy, eL, eR, ears, fL, fR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local tx, ty = tipOf(eL)
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a + tx, 7 + b + ty}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  tx, ty = tipOf(eR)
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a + tx, 7 + b + ty}, {40 + a, 21 + b} }):grow(1)
  local list = {}
  if ears == "orig" then
    list[#list + 1] = { "earL", earL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "earR", earR, g, { cres = 2, gloss = false } }
  end
  list[#list + 1] = { "head", head, h, { gloss = { 14 + ox, 15 + oy } } }
  if ears == "fold" then
    local mL, mR = foldMask(c, ox, oy, fL, fR)
    list[#list + 1] = { "foldL", mL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "foldR", mR, g, { cres = 2, gloss = false } }
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
local function catFace(c, ox, oy, head, eyes, eL, eR, ears, fL, fR, mouth)
  eL, eR = eL or Z, eR or Z
  if ears == "orig" then
    local a, b = ox + eL[1], oy + eL[2]
    local tx, ty = tipOf(eL)
    tx, ty = tx * 0.75, ty * 0.75
    c:fill(c:poly({ {13 + a, 18 + b}, {13 + a + tx, 9 + b + ty}, {21 + a, 14 + b} }):cut(head), PINK)
    a, b = ox + eR[1], oy + eR[2]
    tx, ty = tipOf(eR)
    tx, ty = tx * 0.75, ty * 0.75
    c:fill(c:poly({ {29 + a, 14 + b}, {37 + a + tx, 9 + b + ty}, {37 + a, 18 + b} }):cut(head), PINK)
  elseif ears == "fold" then
    local mL, mR = foldMask(c, ox, oy, fL, fR)
    fL, fR = fL or Z, fR or Z
    local function crease(m, d, pts)
      for _, p in ipairs(pts) do
        local x, y = p[1] + ox + d[1], p[2] + oy + d[2]
        if m:has(x, y) and c:get(x, y) ~= GREY.shade then c:px(x, y, GREY.shade) end
      end
    end
    crease(mL, fL, { {13, 12}, {14, 12}, {15, 11}, {16, 11}, {17, 11}, {18, 11} })
    crease(mR, fR, { {37, 12}, {36, 12}, {35, 11}, {34, 11}, {33, 11}, {32, 11} })
  end
  c:fill(c:ellipse(25 + ox, 27 + oy, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  if mouth == "smile" then -- S3: open smile, corners raised, dark-pink mouth with a pink tongue
    c:paint({ "u.....u", ".uuuuu.", ".uqqqu.", "..upu.." }, 22 + ox, 26 + oy, { u = "ol2", q = PINKS, p = PINK })
    c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  else
    c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  end
  catEye(c, 14 + ox, 19 + oy, eyes); catEye(c, 32 + ox, 19 + oy, eyes)
end
-- toes: nil/true = toe lines below the centre (paw on the floor), false = none, "up" = on the top edge (S3)
local function paw(c, cx, cy, toes, rx, ry)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
  c.names[P] = "paw"
  if toes == "up" then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) - 2, { s = GREY.base })
  elseif toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = GREY.base }) end
  return P
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
M.rell = rell
local function build(c, list)
  local p = c:build(list)
  for n, P in pairs(p) do c.names[P] = n end
  return p
end
local function bobEntry(c, m) return { "bob", m, coat(GREY), { cres = 2, gloss = false } } end
local function newCanvas() local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {} return c end
-- ======================================= end of copy =======================================

-- ===== frames. Each takes o = { ears = orig|none|fold, tail = orig|none|bob } and returns canvas, info =====
local FR = {}
local BOB = { idleA = { 44.5, 50.5 }, jump = { 43.5, 46.5 }, happy = { 43.5, 47.5 } }
M.BOB = BOB

-- idleA (copy of cf_cats.lua / cf_overlays.lua; the two aliases below are this with one switch changed)
local IDLE_TAIL = { {38, 52}, {45, 52}, {50, 49}, {52, 44}, {52, 38}, {51, 34} }
local IDLE_TIP = { rect = { 46, 30, 56, 36 }, seam = { { 49, 37 }, { 53, 37 } } }
-- tailflick: same root as idleA (so a bobtail and the root's marks stay put), then up high and hooked back in
local FLICK_TAIL = { {38, 52}, {45, 52}, {50, 49}, {53, 43}, {54, 36}, {53, 29}, {51, 25}, {48, 23} }
local FLICK_TIP = { rect = { 44, 18, 58, 28 }, seam = { { 51, 28 }, { 56, 26 } } }
local function idleLike(o, v)
  local c = newCanvas()
  local g = coat(GREY)
  local EL, ER = v.eL, v.eR
  local fL, fR = v.fL, v.fR
  local H, head = catHead(c, 0, 0, EL, ER, o.ears, fL, fR)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = v.tpts
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(BOB.idleA[1], BOB.idleA[2], 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then local r = v.tip.rect; tailTip(c, tail, c:rect(r[1], r[2], r[3], r[4]), v.tip.seam) end
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, "open", EL, ER, o.ears, fL, fR)
  return c, { ox = 0, oy = 0, tpts = tpts, p = p, eL = EL, eR = ER, fL = fL, fR = fR }
end
FR.idleA = function(o) return idleLike(o, { tpts = IDLE_TAIL, tip = IDLE_TIP }) end
FR.tailflick = function(o) return idleLike(o, { tpts = FLICK_TAIL, tip = FLICK_TIP }) end
-- eartwitch: right ear tip 2 out, 2 down (base fixed); folded right flap drops 1,1
M.TWITCH = { eR = { 0, 0, 2, 2 }, fR = { 1, 1 } }
FR.eartwitch = function(o) return idleLike(o, { tpts = IDLE_TAIL, tip = IDLE_TIP, eR = M.TWITCH.eR, fR = M.TWITCH.fR }) end

-- jump: straight-up leap at ground level
M.JUMP = {
  legL = { {21, 35}, {15, 27}, {12, 16} }, legR = { {43, 35}, {49, 27}, {52, 16} },   -- forelegs reaching up
  hindL = { {27, 45}, {26, 50}, {25, 52} }, hindR = { {37, 45}, {38, 50}, {39, 52} },  -- hind legs hanging
  tail = { {38, 47}, {44, 50}, {49, 50}, {52, 47}, {53, 43} },                       -- trailing low, tip lifted
}
FR.jump = function(o)
  local c = newCanvas()
  local g = coat(GREY)
  local J = M.JUMP
  local OX, OY = 7, 2
  local H, head = catHead(c, OX, OY, nil, nil, o.ears)
  local body = c:ellipse(32, 41, 10, 8.5)                                -- stretched: narrow, tall under the chin
  local legL, legR = c:line(J.legL, 5), c:line(J.legR, 5)
  local hindL, hindR = c:line(J.hindL, 5), c:line(J.hindR, 5)
  local tpts = J.tail
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(BOB.jump[1], BOB.jump[2], 4, 3.5)) end
  list[#list + 1] = { "legB", hindR, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "legH", hindL, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "legF", legL, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "legN", legR, g, { cres = 2, gloss = false } }
  list[#list + 1] = { "body", body, g, { gloss = { 25, 36 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(50, 38, 58, 45), { { 51, 46 }, { 55, 46 } }) end
  paw(c, 12, 11, "up", 3.5, 3.5); paw(c, 52, 11, "up", 3.5, 3.5)        -- front paws up above the ear line
  paw(c, 24.5, 53.5, true, 3, 2.5); paw(c, 39.5, 53.5, true, 3, 2.5)    -- hind feet pointed down
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open", nil, nil, o.ears)
  return c, { ox = OX, oy = OY, tpts = tpts, p = p }
end

-- happy: hop with a happy squint and an open smile
M.HAPPY = { tail = { {38, 47}, {45, 46}, {49, 43}, {51, 37}, {51, 31}, {52, 26}, {54, 23} } }
FR.happy = function(o)
  local c = newCanvas()
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0, nil, nil, o.ears)
  local body = c:ellipse(25, 43, 14, 7.5):add(c:ellipse(25, 40, 12, 7))   -- tucked: 4 px shorter than idleA
  local tpts = M.HAPPY.tail
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c, c:ellipse(BOB.happy[1], BOB.happy[2], 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 15, 38 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(47, 16, 60, 26), { { 49, 27 }, { 54, 27 } }) end
  paw(c, 18.5, 49); paw(c, 31.5, 49)                                       -- hind feet tucked up off the floor
  paw(c, 14, 37, "up", 3.5, 3); paw(c, 36, 37, "up", 3.5, 3)               -- front paws raised at the chest
  edgeStitch(c, body, p.body, { cy = 42, lit = LIT })
  catFace(c, 0, 0, head, "happy", nil, nil, o.ears, nil, nil, "smile")
  c:ground(25, 58.5, 10, 0.8, "#4a2c1a")                                   -- slim floor shadow under the hop
  return c, { ox = 0, oy = 0, tpts = tpts, p = p }
end

M.FR = FR
M.OFF = { idleA = { 0, 0 }, jump = { 7, 2 }, happy = { 0, 0 }, tailflick = { 0, 0 }, eartwitch = { 0, 0 } }
M.CLOSED = { happy = true }

-- ---------- pixel tables: [y*64+x] = "#hex" ----------
local function hex(v) return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
function M.loadPNG(path)
  local img = Image{ fromFile = path }
  local t = {}
  for y = 0, img.height - 1 do for x = 0, img.width - 1 do
    local v = img:getPixel(x, y)
    if pc.rgbaA(v) == 255 then t[y * img.width + x] = hex(v) elseif pc.rgbaA(v) ~= 0 then error(path .. ": semi alpha") end
  end end
  return t
end
function M.pixOf(c)
  c:finish()
  local t = {}
  for y = 0, 63 do for x = 0, 63 do t[y * 64 + x] = c.pix[c:key(x, y)] end end
  return t
end
function M.toImage(t, w, h)
  w, h = w or 64, h or 64
  local img = Image(w, h, ColorMode.RGB)
  img:clear(pc.rgba(0, 0, 0, 0))
  for i, hx in pairs(t) do
    local r, g, b = tonumber(hx:sub(2, 3), 16), tonumber(hx:sub(4, 5), 16), tonumber(hx:sub(6, 7), 16)
    img:putPixel(i % w, i // w, pc.rgba(r, g, b, 255))
  end
  return img
end
function M.same(a, b) for i = 0, 4095 do if a[i] ~= b[i] then return false, i end end return true end

if CF_S3_LIB then return M end

-- ======================================= draw =======================================
local results = {}
local function check(name, t, cat)
  local line = string.format("%-24s ", name) .. GV.report(t)
  print(line)
  assert(t.semi == 0, name .. ": semi alpha")
  if cat then assert(t.margin >= 3 and t.colours <= 24, name .. ": margin/colour check failed") end
  results[#results + 1] = line
end

-- idleA re-render must match the committed PNG, else this copy is out of step with cf_cats.lua
do
  local c = FR.idleA({ ears = "orig", tail = "orig" })
  local ok, i = M.same(M.pixOf(c), M.loadPNG(OUT .. "cf-cat-grey-idleA.png"))
  assert(ok, "idleA re-render differs from cf-cat-grey-idleA.png at " .. tostring(i and (i % 64 .. "," .. i // 64)))
  print("idleA re-render matches cf-cat-grey-idleA.png")
end

for _, f in ipairs({ "jump", "happy", "tailflick", "eartwitch" }) do
  local c = FR[f]({ ears = "orig", tail = "orig" })
  local name = "cf-cat-grey-" .. f
  check(name, c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png"), true)
end

-- ---------- tiny sprites: hand-set 8x8 pixels, then a 1 px #000000 border on every empty px 4-adjacent to art ----------
local function tiny(name, rows, legend)
  local t = {}
  for y, row in ipairs(rows) do for x = 1, #row do
    local v = legend[row:sub(x, x)]
    if v then t[(y - 1) * 8 + (x - 1)] = v end
  end end
  local add = {}
  for y = 0, 7 do for x = 0, 7 do
    if not t[y * 8 + x] then
      for _, d in ipairs({ {1, 0}, {-1, 0}, {0, 1}, {0, -1} }) do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 0 and ny >= 0 and nx < 8 and ny < 8 and t[ny * 8 + nx] then add[y * 8 + x] = true; break end
      end
    end
  end end
  for i in pairs(add) do t[i] = "#000000" end
  local spr = Sprite(8, 8, ColorMode.RGB)
  spr.cels[1].image = M.toImage(t, 8, 8)
  spr:saveAs(OUT .. name .. ".aseprite")
  spr:saveCopyAs(OUT .. name .. ".png")
  local img = spr.cels[1].image
  local tt = GV.check(img)
  spr:close()
  check(name, tt, false)
end
-- z: dusk-lavender felt (lit edge rim, base, shade lower right); letter 6x6 inside the 8x8 with its border
local DUSK = GV.R.dusk
tiny("cf-z", {
  "........",
  ".LLLLLL.",
  "....bs..",
  "...bs...",
  "..bs....",
  ".bs.....",
  ".Lbbbbs.",
  "........",
}, { L = DUSK.dot, b = DUSK.rim, s = DUSK.base })
local GOLD = { light = "#fff8e0", rim = GV.C.gold, base = "#e8a317", shade = "#b8661a" }
tiny("cf-sparkle-1", { -- grow: 2x2 core and 1 px arms
  "........",
  "........",
  "...rb...",
  "..rLLb..",
  "..rLLs..",
  "...bs...",
  "........",
  "........",
}, { L = GOLD.light, r = GOLD.rim, b = GOLD.base, s = GOLD.shade })
tiny("cf-sparkle-2", { -- full: arms out to the tips, light centre, lit upper-left halves
  "........",
  "...rb...",
  "...rb...",
  ".rrLLbb.",
  ".rrLLss.",
  "...bs...",
  "...bs...",
  "........",
}, { L = GOLD.light, r = GOLD.rim, b = GOLD.base, s = GOLD.shade })
tiny("cf-sparkle-3", { -- fade: grow's small shape again, dimmed: gold core (the light centre has gone out), dark arms
  "........",
  "........",
  "...bs...",
  "..brbs..",
  "..bbss..",
  "...ss...",
  "........",
  "........",
}, { r = GOLD.rim, b = GOLD.base, s = GOLD.shade })

print(#results .. " files written")

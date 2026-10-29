-- cf_frames_s2.lua : Cat Fish active-play slice S2, grey cat body frames swatA, swatB, blink (Stitched Toy, gvlib).
-- Run: AppRun -b --script cf_frames_s2.lua     Writes test/cf-cat-grey-<swatA|swatB|blink>.png + .aseprite, then
--      AppRun -b --script cf_overlays_s2.lua   (patterns, folded ears, bobtail, masks, eyes for these frames).
-- Also loaded as a library by cf_overlays_s2.lua: with the global CF_S2_LIB set it only returns the frame code
-- (M.FR) and draws nothing, so the bodies and the overlays come from ONE copy of the geometry.
--
-- Same template as cf_frames2.lua (the 4 grey tones, fixed accents, separate tail/ear/body/head/paw parts, edge
-- stitch on the lit half only, eyes as the locked disc with an umber ring). The shared head, face, paw and
-- tail-tip code below is a clean copy of cf_overlays.lua's (that script writes files when loaded, so it cannot be
-- dofile'd), with its ear switch (orig / none / fold), per-ear offsets, folded-flap offsets and the stitch guard.
-- New here: catFace takes a mouth mode ("open": a small open mouth, umber rim round a dark-pink inside) and
-- paws can carry pink pads (a raised paw seen from below) or spread claws (eye cream, a fixed accent).
-- With every new switch left at its default the code draws exactly what cf_frames2 / cf_overlays draw: the
-- script re-renders idleA and stops unless it matches test/cf-cat-grey-idleA.png pixel for pixel.
--
-- Frame offsets (head, eyes; add to idle A's eye boxes at 14,19 and 32,19; odd-eye split at x = 25 + ox):
--   swatA -2,3  (eyes open, head tilted like idleB: left ear dips 1 px, right ear lifts 1 px)
--   swatB  7,6  (eyes open, mouth open)
--   blink  0,0  (ALIAS of idleA: same body, head, ears, tail; only the eyes are closed, nap's sleep arcs)
-- Body offsets (where idleA's body marks land; used by cf_overlays_s2.lua): swatA -2,0 (lower body 1 px left,
--   chest 3 px left: the lean back), swatB is a side view (marks follow its own body axis, like stalk/pounce).
-- swatA: wind-up. Sitting, leaning back (upper body shifted left over the seat), head tilted up toward the toy,
--   the right foreleg raised high beside the cheek, paw up at the upper right showing its pink pads, the other
--   front paw and a hind foot on the floor, tail lying out to the lower right with the tip cocked up.
-- swatB: strike. Lunged forward-right off a crouched haunch: head low and forward, the right foreleg shot out
--   straight to the right with the claws spread (three cream claws past the toe lines), the left forepaw planted
--   under the chin, tail up behind in a hook, mouth open.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK, PINKS = "#e8909e", "#c66a80"
local CREAM = GV.C.halo -- eye cream #f2e4c0, a fixed accent: the claws
local LIT = 3
local M = { GREY = GREY, coat = coat, coatHi = coatHi }

-- ===================== shared template (copy of cf_overlays.lua / cf_frames2.lua) =====================
local STITCH_ONLY = nil -- set by cf_overlays_s2 while rendering a replacement-part variant (see cf_overlays.lua)
function M.setStitchOnly(t) STITCH_ONLY = t end
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
    local skip = STITCH_ONLY and not STITCH_ONLY[p[2] * 64 + p[1]]
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit and not skip then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
local Z = { 0, 0 }
local function foldMask(c, ox, oy, dL, dR)
  local L = c:poly({ {11, 13}, {14, 9}, {19, 8.5}, {22.5, 11}, {21, 14}, {16, 16}, {12, 16} })
  local R = c:mask()
  L:each(function(x, y) R:set(50 - x, y) end)
  dL, dR = dL or Z, dR or Z
  return L:shift(ox + dL[1], oy + dL[2]), R:shift(ox + dR[1], oy + dR[2])
end
M.foldMask = foldMask
local function catHead(c, ox, oy, eL, eR, ears, fL, fR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a, 7 + b}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a, 7 + b}, {40 + a, 21 + b} }):grow(1)
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
-- mouth: nil = the template's "u.u"; "open" = small open mouth under the nose: umber rim, dark-pink inside
local function catFace(c, ox, oy, head, eyes, eL, eR, ears, fL, fR, mouth)
  eL, eR = eL or Z, eR or Z
  if ears == "orig" then
    local a, b = ox + eL[1], oy + eL[2]
    c:fill(c:poly({ {13 + a, 18 + b}, {13 + a, 9 + b}, {21 + a, 14 + b} }):cut(head), PINK)
    a, b = ox + eR[1], oy + eR[2]
    c:fill(c:poly({ {29 + a, 14 + b}, {37 + a, 9 + b}, {37 + a, 18 + b} }):cut(head), PINK)
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
  if mouth == "open" then
    c:paint({ "u.u", "uqu", ".u." }, 24 + ox, 27 + oy, { u = "ol2", q = PINKS })
  else
    c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  end
  catEye(c, 14 + ox, 19 + oy, eyes); catEye(c, 32 + ox, 19 + oy, eyes)
end
local function paw(c, cx, cy, toes, rx, ry)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
  if c.names then c.names[P] = "paw" end
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = GREY.base }) end
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
local function bobEntry(m) return { "bob", m, coat(GREY), { cres = 2, gloss = false } } end
-- ======================================= end of copy =======================================

-- per-frame data the overlay script needs too
M.OFF = { idleA = { 0, 0 }, blink = { 0, 0 }, swatA = { -2, 3 }, swatB = { 7, 6 } }
M.EARS = { swatA = { { -1, 1 }, { 0, -1 } } }    -- per-ear offsets (from the head offset); swatB: none
M.FOLD = { swatA = { { -1, 1 }, { 0, -1 } } }    -- folded flaps ride with their ear (idleB's tilt)
M.BOB = { idleA = { 44.5, 50.5 }, swatA = { 42.5, 51.5 }, swatB = { 11.5, 40.5 } } -- on the old tail root
M.BODY_OFF = { swatA = { -2, 0 } }

local FR = {}
M.FR = FR
-- o.ears = orig|none|fold, o.tail = orig|none|bob (cf_overlays.lua's switches); o.eyes overrides the eye mode
FR.idleA = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0, nil, nil, o.ears)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = { {38, 52}, {45, 52}, {50, 49}, {52, 44}, {52, 38}, {51, 34} }
  local tail = c:line(tpts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c:ellipse(M.BOB.idleA[1], M.BOB.idleA[2], 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(46, 30, 56, 36), { { 49, 37 }, { 53, 37 } }) end
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, o.eyes or "open", nil, nil, o.ears)
  return c, { ox = 0, oy = 0, tpts = tpts, p = p }
end
-- blink: idleA with the eyes shut (nap's sleep arcs); nothing else may differ (checked below)
FR.blink = function(o)
  local o2 = {}
  for k, v in pairs(o) do o2[k] = v end
  o2.eyes = "sleep"
  return FR.idleA(o2)
end

-- ===== swatA: wind-up. Leaning back on the seat, head tilted up, right forepaw raised high at the upper right =====
FR.swatA = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local OX, OY = M.OFF.swatA[1], M.OFF.swatA[2]
  local EL, ER = M.EARS.swatA[1], M.EARS.swatA[2]
  local fL, fR = M.FOLD.swatA[1], M.FOLD.swatA[2]
  local H, head = catHead(c, OX, OY, EL, ER, o.ears, fL, fR)
  -- idleA's body, the seat 1 px left and the chest 3 px left: the cat sits back away from the toy
  local body = c:ellipse(24, 46.5, 15, 8.5):add(c:ellipse(22, 41, 12, 8))
  local tpts = { {37, 53}, {45, 54}, {50, 52}, {53, 48}, {54, 44} }   -- out along the floor, tip cocked up
  local tail = c:line(tpts, 5)
  local apts = { {34, 42}, {40, 36}, {43, 29}, {46, 22} }            -- raised foreleg, elbow out, up past the cheek
  local arm = c:line(apts, 6)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c:ellipse(M.BOB.swatA[1], M.BOB.swatA[2], 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 13, 40 } } }
  list[#list + 1] = { "legN", arm, g, { cres = 2, gloss = false } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(50, 38, 60, 47), { { 51, 48 }, { 57, 48 } }) end
  paw(c, 16.5, 53)                                                    -- the other front paw on the floor
  paw(c, 29.5, 54, true, 4, 2)                                        -- hind foot peeking out
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  -- the raised paw, palm to us: three toe beans and the main pad in pink (fixed accent)
  paw(c, 47.5, 16.5, false, 5, 4)
  c:paint({ ".pp.pp.pp.", "..........", "...pppp...", "....qq...." }, 43, 14, { p = PINK, q = PINKS })
  catFace(c, OX, OY, head, o.eyes or "open", EL, ER, o.ears, fL, fR)
  return c, { ox = OX, oy = OY, tpts = tpts, p = p, apts = apts, fL = fL, fR = fR, eL = EL, eR = ER }
end

-- ===== swatB: strike. Lunged forward-right, right foreleg shot out straight, claws spread, tail up, mouth open =====
FR.swatB = function(o)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}
  local g = coat(GREY)
  local OX, OY = M.OFF.swatB[1], M.OFF.swatB[2]
  local H, head = catHead(c, OX, OY, nil, nil, o.ears)
  local A = -0.2                                                      -- body axis rising toward the chest
  local body = rell(c, 22, 45, 14, 8, A)
  local thigh = rell(c, 13, 47, 7, 7.5, -0.4)                         -- crouched haunch, weight back
  local tpts = { {13, 41}, {9, 36}, {8, 30}, {8, 24}, {9, 19} }       -- up behind the rump
  local tail = c:line(tpts, 5)
  local lpts = { {28, 47}, {29, 52} }                                 -- left foreleg planted under the chin
  local leg = c:line(lpts, 5)
  local apts = { {32, 47}, {40, 44}, {46, 42} }                       -- right foreleg shot out to the right
  local arm = c:line(apts, 5)
  local list = {}
  if o.tail == "orig" then list[#list + 1] = { "tail", tail, g, { cres = 2, gloss = false } }
  elseif o.tail == "bob" then list[#list + 1] = bobEntry(c:ellipse(M.BOB.swatB[1], M.BOB.swatB[2], 4, 3.5)) end
  list[#list + 1] = { "body", body, g, { gloss = { 14, 40 } } }
  list[#list + 1] = { "thigh", thigh, g, { cres = 2, gloss = { 9, 42 } } }
  list[#list + 1] = { "legF", leg, g, { cres = 2, gloss = false } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  list[#list + 1] = { "legN", arm, g, { cres = 2, gloss = false } }  -- in front of the chin: the strike
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(3, 12, 15, 23), { { 5, 24 }, { 11, 24 } }) end
  paw(c, 13.5, 54)                                                    -- hind paw under the haunch
  paw(c, 29.5, 54)                                                    -- planted forepaw
  edgeStitch(c, body, p.body, { lit = -5 })                          -- back only: no collar of dashes under the chin
  catFace(c, OX, OY, head, o.eyes or "open", nil, nil, o.ears, nil, nil, "open")
  -- the striking paw, toes to the right: two toe lines and three claws fanned out past the tip (eye cream)
  paw(c, 49.5, 42, false, 4.5, 3)
  c:paint({ "ss", "..", "ss" }, 51, 41, { s = GREY.base })
  local claws = c:ascii({ ".x", "x.", "..", "xx", "..", "x.", ".x" }, 55, 39)
  c.sil:add(claws); c:fill(claws, CREAM)
  return c, { ox = OX, oy = OY, tpts = tpts, p = p, A = A, apts = apts, lpts = lpts }
end

if CF_S2_LIB then return M end

-- ================================ draw and save the bodies ================================
local pc = app.pixelColor
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
local O = { ears = "orig", tail = "orig" }

-- 1. the copied template must still draw idleA exactly as committed
do
  local file, mine = loadPNG(OUT .. "cf-cat-grey-idleA.png"), pixOf((FR.idleA(O)))
  for i = 0, 4095 do
    if file[i] ~= mine[i] then error(string.format("idleA re-render differs at %d,%d: template copy out of step", i % 64, i // 64)) end
  end
end

-- 2. save the three bodies
for _, f in ipairs({ "swatA", "swatB", "blink" }) do
  local c = FR[f](O)
  local name = "cf-cat-grey-" .. f
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-6s ", f) .. GV.report(t))
  assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24, name .. ": check failed")
end

-- 3. blink is an alias of idleA: only the two eye boxes (7x7 round 14,19 and 32,19) may differ
do
  local a, b = loadPNG(OUT .. "cf-cat-grey-idleA.png"), loadPNG(OUT .. "cf-cat-grey-blink.png")
  local n = 0
  for i = 0, 4095 do
    if a[i] ~= b[i] then
      local x, y = i % 64, i // 64
      local inBox = y >= 18 and y <= 24 and ((x >= 13 and x <= 19) or (x >= 31 and x <= 37))
      if not inBox then error(string.format("blink differs from idleA outside the eyes at %d,%d", x, y)) end
      n = n + 1
    end
  end
  print("blink  alias of idleA: " .. n .. " px differ, all inside the eye boxes")
end

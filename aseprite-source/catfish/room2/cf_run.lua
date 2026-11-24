-- cf_run.lua : Cat Fish grey template cat, 8-frame SIDE RUN cycle facing right (Stitched Toy, via gvlib).
-- Run: AppRun -b --script cf_run.lua    Writes out/cf-run-grey-1..8.png, out/cf-run-grey.aseprite (8 frames),
-- out/cf-run-grey-sheet.png (512x64, 1 row).
-- Template: the shared head/face/paw/tail code is a clean copy of cf_frames_s4.lua's (same 4 grey tones, fixed
-- accents, locked eyes, edge stitch on the lit half). The head is idle A's head, unchanged, moved by (OX, OY).
-- The run is a bound/half-gallop: each leg follows one foot path over 8 phases (stance on the idle baseline
-- y = 53, then lift, tuck and reach). Hind legs run 4 phases after the fore legs (extended / gathered), and the
-- far legs lag their near partner by one phase. Body bobs 0,+1,0,-1 twice per cycle (contact, down, passing, up);
-- the tail tip moves opposite to the bob. Far legs/paws use a darker felt so they sit behind.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local function coatDk(t) return { gloss = t.base, dot = t.base, rim = t.base, base = t.shade, shade = t.shade, deep = t.shade, bounce = t.shade } end
local function pawDk(t) return { gloss = t.light, dot = t.light, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3

-- ======================= shared template (copy of cf_frames_s4.lua) =======================
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
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
local Z = { 0, 0 }
local function catHead(c, ox, oy, eL, eR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a, 7 + b}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a, 7 + b}, {40 + a, 21 + b} }):grow(1)
  return {
    { "earL", earL, g, { cres = 2, gloss = false } },
    { "earR", earR, g, { cres = 2, gloss = false } },
    { "head", head, h, { gloss = { 14 + ox, 15 + oy } } },
  }, head
end
local function eyeRing(c, x, y)
  c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y) eyeRing(c, x, y); c:eye(x, y) end
local function catFace(c, ox, oy, head, eL, eR)
  eL, eR = eL or Z, eR or Z
  local a, b = ox + eL[1], oy + eL[2]
  c:fill(c:poly({ {13 + a, 18 + b}, {13 + a, 9 + b}, {21 + a, 14 + b} }):cut(head), PINK)
  a, b = ox + eR[1], oy + eR[2]
  c:fill(c:poly({ {29 + a, 14 + b}, {37 + a, 9 + b}, {37 + a, 18 + b} }):cut(head), PINK)
  c:fill(c:ellipse(25 + ox, 27 + oy, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  catEye(c, 14 + ox, 19 + oy); catEye(c, 32 + ox, 19 + oy)
end
local function paw(c, cx, cy, ramp, toes, rx, ry, toeHex)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), ramp or coatHi(GREY), { flat = true })
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = toeHex or GREY.base }) end
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
-- =========================================== end of copy ===========================================

-- ============================== POSE DATA (the artist's numbers) ==============================
local GROUND = 53                       -- paw centre y on the ground (idle A's paws sit at 53)
-- foot path per phase 0..7: { dx from the leg root, absolute y }. Phase 0 = contact (paw reaching ahead lands).
local FORE = { {8, 53}, {4, 53}, {0, 53}, {-4, 51}, {-5, 47}, {-2, 44}, {3, 45}, {8, 49} }
local HIND = { {4, 53}, {1, 53}, {-2, 53}, {-5, 52}, {-6, 48}, {-4, 45}, {0, 45}, {4, 49} }
local BOB  = { 0, 1, 0, -1, 0, 1, 0, -1 }          -- body dy per frame: contact, down, passing, up (x2)
local ROCK = { 0.05, 0.05, 0, -0.05, -0.05, -0.05, 0, 0.05 } -- body tilt (rad, + = nose down)
local HEAD = { 15, 8 }                              -- head offset from idle A (OX, OY) before bob
local EAR_L, EAR_R = { -1, 2 }, { 1, 2 }            -- ears laid back / out
local EARDY = { 0, 1, 0, 0, 0, 1, 0, 0 }           -- ears flatten 1 px more on the down frames
local BODY = { 23, 38, 15, 8.5 }                  -- cx, cy, rx, ry
local SHOULDER, HIP = { 34, 42 }, { 16, 41 }
local THIGH = { 5.5, 6 }                            -- near haunch rx, ry (rides 1/4 toward the hind foot)
local LEGW_N, LEGW_F = 5, 4
-- tail centre line at bob 0; tip points get -BOB * TAILK extra dy (bounces opposite)
local TAIL = { {13, 34}, {10, 31}, {8, 26}, {8, 21}, {9, 17} }
local TAILK = { 0, 0.5, 1, 2, 2.5 }
local TIPX = { 0, 1, 1, 0, 0, 1, 1, 0 }           -- tip sway (x) per frame, last two points
-- ===============================================================================================

local function legPts(root, foot, sgn)
  local dx, dy = foot[1] - root[1], foot[2] - root[2]
  local d = math.sqrt(dx * dx + dy * dy)
  local L0 = 13
  local bend = math.max(0, (L0 - d)) * 0.6
  local mx, my = root[1] + dx / 2 + sgn * bend, root[2] + dy / 2
  return { { root[1], root[2] }, { math.floor(mx + 0.5), math.floor(my + 0.5) }, { foot[1], foot[2] - 1 } }
end

local function frame(f)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local b = BOB[f]
  local OX, OY = HEAD[1], HEAD[2] + BOB[(f + 6) % 8 + 1] -- head follows the body one frame late
  local eL, eR = { EAR_L[1], EAR_L[2] + EARDY[f] }, { EAR_R[1], EAR_R[2] + EARDY[f] }
  local H, head = catHead(c, OX, OY, eL, eR)
  local body = rell(c, BODY[1], BODY[2] + b, BODY[3], BODY[4], ROCK[f])
  local tp = {}
  for i, p in ipairs(TAIL) do tp[i] = { p[1] + (i >= 4 and TIPX[f] or 0), math.floor(p[2] + b - b * TAILK[i] + 0.5) } end
  local tail = c:line(tp, 5)
  local ph = f - 1
  local function foot(tbl, root, phase)
    local q = tbl[(phase % 8) + 1]
    return { root[1] + q[1], q[2] }
  end
  local sh = { SHOULDER[1], SHOULDER[2] + b }
  local hp = { HIP[1], HIP[2] + b }
  local fN = foot(FORE, sh, ph)
  local fF = foot(FORE, sh, ph - 1)
  local hN = foot(HIND, hp, ph + 4)
  local hF = foot(HIND, hp, ph + 3)
  local dk = coatDk(GREY)
  local legFF = c:line(legPts({ sh[1] - 1, sh[2] - 1 }, fF, 1), LEGW_F)
  local legHF = c:line(legPts({ hp[1] + 1, hp[2] - 1 }, hF, -1), LEGW_F)
  local legFN = c:line(legPts(sh, fN, 1), LEGW_N)
  local tc = { math.floor(hp[1] + (hN[1] - hp[1]) * 0.25 + 0.5), math.floor(hp[2] + (hN[2] - hp[2]) * 0.15 + 0.5) }
  local thigh = c:ellipse(tc[1] + 0.5, tc[2], THIGH[1], THIGH[2])
  local legHN = c:line(legPts(tc, hN, -1), LEGW_N)
  local p = c:build{
    { "legFF", legFF, dk, { cres = 2, gloss = false } },
    { "legHF", legHF, dk, { cres = 2, gloss = false } },
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 14, 33 + b } } },
    { "legHN", legHN, g, { cres = 2, gloss = false } },
    { "thigh", thigh, g, { cres = 2, gloss = false } },
    { "legFN", legFN, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
  }
  local tip = tp[#tp]
  tailTip(c, tail, c:rect(tip[1] - 6, tip[2] - 6, tip[1] + 6, tip[2] + 3), { { tip[1] - 3, tip[2] + 4 }, { tip[1] + 2, tip[2] + 4 } })
  -- far paws (darker) are drawn first so near paws sit on top
  paw(c, fF[1] + 0.5, fF[2], pawDk(GREY), true, 3.5, 2.5, GREY.shade)
  paw(c, hF[1] + 0.5, hF[2], pawDk(GREY), true, 3.5, 2.5, GREY.shade)
  paw(c, hN[1] + 0.5, hN[2], nil, true, 4, 2.5)
  paw(c, fN[1] + 0.5, fN[2], nil, true, 4, 2.5)
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, eL, eR)
  return c
end

local names = {}
for f = 1, 8 do
  local c = frame(f)
  local name = "cf-run-grey-" .. f
  local t = c:save(nil, OUT .. name .. ".png")
  print(string.format("run%d ", f) .. GV.report(t))
  assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24, name .. ": check failed")
  names[#names + 1] = OUT .. name .. ".png"
end

-- 8-frame .aseprite (125 ms per frame = 8 fps) and a 1-row sheet
local spr = Sprite(64, 64, ColorMode.RGB)
for i = 2, 8 do spr:newEmptyFrame() end
local sheet = Image(64 * 8, 64, ColorMode.RGB)
for i, fn in ipairs(names) do
  local img = Image{ fromFile = fn }
  spr:newCel(spr.layers[1], spr.frames[i], img, Point(0, 0))
  spr.frames[i].duration = 0.125
  sheet:drawImage(img, Point((i - 1) * 64, 0))
end
spr:saveAs(OUT .. "cf-run-grey.aseprite")
spr:close()
local s2 = Sprite(64 * 8, 64, ColorMode.RGB)
s2.cels[1].image = sheet
s2:saveCopyAs(OUT .. "cf-run-grey-sheet.png")
s2:close()
print("ok")

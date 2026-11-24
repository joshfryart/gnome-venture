-- cf_run80.lua : Cat Fish grey template, 12-frame SIDE RUN v2 (80x64, facing right), per run80_spec.md.
-- Run: AppRun -b --script cf_run80.lua
-- Writes out80/cf-cat-grey-run01..12.png, cf-ears-mask-run01..12.png, cf-tail-mask-run01..12.png,
-- cf-run80-grey.aseprite (12 frames, 60 ms, layers outline/legs-far/tail/body/legs-near/ears/head+face),
-- cf-run80-sheet.png (960x64). Previews are made by make_view80.py (python3 + PIL).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out80/"

-- ============================== POSE TABLE (the art director's numbers) ==============================
local BX = 34            -- body centre column, never moves
local GROUND = 53        -- planted paw centre y
local FRAMEMS = 60
-- per frame: BY body centre y, L body length (even), arch (<0 humps back), tilt,
-- S near shoulder, H near hip, hx/hy head, ex/ey ear offset, tail dy for P2/P3/P4
local POSE = {
  { BY=38, L=36, arch=0, tilt=4, S={47,43}, H={21,41}, head={56,23}, ear={-1,0}, tdy={-2,-2,-2} }, -- 1
  { BY=39, L=34, arch=0, tilt=3, S={46,44}, H={22,42}, head={55,24}, ear={-1,0}, tdy={-2,-3,-3} }, -- 2
  { BY=38, L=32, arch=-2, tilt=1, S={45,42}, H={23,42}, head={54,25}, ear={-2,1}, tdy={-1,-2,-4} }, -- 3
  { BY=37, L=30, arch=-3, tilt=0, S={44,41}, H={24,41}, head={53,24}, ear={-1,0}, tdy={0,-2,-3} }, -- 4
  { BY=36, L=28, arch=-5, tilt=-2, S={43,40}, H={25,40}, head={52,23}, ear={0,-1}, tdy={1,0,-2} }, -- 5
  { BY=37, L=30, arch=-3, tilt=-4, S={44,40}, H={24,42}, head={53,22}, ear={0,-1}, tdy={2,2,0} }, -- 6
  { BY=38, L=32, arch=-2, tilt=-4, S={45,41}, H={23,43}, head={54,23}, ear={-1,0}, tdy={2,2,2} }, -- 7
  { BY=37, L=34, arch=-1, tilt=-3, S={46,41}, H={22,42}, head={55,24}, ear={-2,1}, tdy={2,3,3} }, -- 8
  { BY=36, L=36, arch=0, tilt=-2, S={47,40}, H={21,40}, head={56,23}, ear={-1,0}, tdy={1,2,4} }, -- 9
  { BY=35, L=36, arch=2, tilt=0, S={47,39}, H={21,39}, head={56,22}, ear={0,-1}, tdy={0,2,3} }, -- 10
  { BY=36, L=36, arch=1, tilt=2, S={47,40}, H={21,40}, head={56,21}, ear={0,-1}, tdy={-1,0,2} }, -- 11
  { BY=37, L=36, arch=0, tilt=4, S={47,42}, H={21,40}, head={56,22}, ear={-1,0}, tdy={-2,-2,0} }, -- 12
}
local LEGS = {
  { nf={57,51}, ff={52,53}, nh={{13,46},{15,48}}, fh={{13,45},{15,47}} },
  { nf={55,53}, ff={47,53}, nh={{18,46},{20,48}}, fh={{17,45},{19,47}} },
  { nf={50,53}, ff={42,53}, nh={{21,46},{24,48}}, fh={{20,45},{23,47}} },
  { nf={45,53}, ff={40,49}, nh={{24,46},{27,48}}, fh={{23,46},{26,48}} },
  { nf={43,48}, ff={41,46}, nh={{26,46},{29,49}}, fh={{25,46},{28,50}} },
  { nf={44,46}, ff={43,45}, nh={{28,46},{30,50}}, fh={{25,49},{28,53}} },
  { nf={48,45}, ff={46,45}, nh={{26,49},{29,53}}, fh={{21,49},{23,53}} },
  { nf={52,45}, ff={50,45}, nh={{22,49},{24,53}}, fh={{17,49},{18,53}} },
  { nf={56,45}, ff={54,46}, nh={{18,49},{19,53}}, fh={{15,47},{12,50}} },
  { nf={58,46}, ff={56,46}, nh={{16,47},{13,50}}, fh={{12,46},{10,49}} },
  { nf={59,47}, ff={57,47}, nh={{13,45},{11,48}}, fh={{12,46},{11,48}} },
  { nf={58,49}, ff={54,51}, nh={{14,46},{13,48}}, fh={{12,45},{13,47}} },
}
-- shape constants
local BONE = { fore1 = 7, fore2 = 7, hind1 = 7, hind2 = 7 }
local TAIL_OFF = { {0,0}, {-4,-2}, {-8,-2}, {-11,-1}, {-13,-4} }   -- from root R = (rear+6, BY-6)
-- ====================================================================================================

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local function coatDk(t) return { gloss = t.base, dot = t.base, rim = t.base, base = t.shade, shade = t.shade, deep = t.shade, bounce = t.shade } end
local function pawDk(t) return { gloss = t.light, dot = t.light, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3

-- ======================= shared template (copy of cf_run.lua / cf_frames_s4.lua) =======================
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
local function eyeRing(c, x, y)
  c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y) eyeRing(c, x, y); c:eye(x, y) end
local function paw(c, cx, cy, ramp, toes, rx, ry, toeHex)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), ramp or coatHi(GREY), { flat = true })
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = toeHex or GREY.base }) end
  return P
end
local function tailTip(c, tail, region, seam) tint(c, region:clip(tail), GREY.base, GREY.light); c:seam(seam) end
-- ===========================================================================================================

local function round(v) return math.floor(v + 0.5) end
-- 2-bone IK: joint between root r and target t; dir = -1 picks the solution with smaller x (elbow back), +1 larger x (knee fwd)
local function ik(r, t, l1, l2, dir)
  local dx, dy = t[1] - r[1], t[2] - r[2]
  local d = math.sqrt(dx * dx + dy * dy)
  if d >= l1 + l2 - 0.01 or d < 0.01 then return { round(r[1] + dx * l1 / (l1 + l2)), round(r[2] + dy * l1 / (l1 + l2)) } end
  local a = (l1 * l1 - l2 * l2 + d * d) / (2 * d)
  local h = math.sqrt(math.max(0, l1 * l1 - a * a))
  local ux, uy = dx / d, dy / d
  local mx, my = r[1] + ux * a, r[2] + uy * a
  local p1 = { mx - uy * h, my + ux * h }
  local p2 = { mx + uy * h, my - ux * h }
  local pick = ((p1[1] - p2[1]) * dir >= 0) and p1 or p2
  return { round(pick[1]), round(pick[2]) }
end

local LAYER_OF = { earF = "ears", earN = "ears", legFF = "legs-far", legHF = "legs-far", pawFF = "legs-far", pawHF = "legs-far",
  tail = "tail", body = "body", chest = "body", haunch = "body", legHN = "legs-near", legFN = "legs-near",
  pawHN = "legs-near", pawFN = "legs-near", head = "head+face" }

local info = {}   -- per-frame data for self-check
local function frame(f)
  local P, Lg = POSE[f], LEGS[f]
  local c = GV.canvas{ w = 80, h = 64, mode = "sticker" }
  local g, h, dk = coat(GREY), coatHi(GREY), coatDk(GREY)
  local BY, L = P.BY, P.L
  local rear, front = BX - L // 2, BX + L // 2
  local ts = P.tilt >= 3 and 1 or (P.tilt <= -3 and -1 or 0)
  local S, H = { front - 5, P.S[2] }, { rear + 5, P.H[2] }
  local Sf, Hf = { S[1] - 1, S[2] - 1 }, { H[1] + 1, H[2] - 1 }
  local hx, hy = S[1] + 9, P.head[2]
  local ex, ey = P.ear[1], P.ear[2]
  local pe = POSE[(f - 2) % 12 + 1].ear
  local exF, eyF = pe[1], pe[2]

  -- legs
  local nfE = ik(S, Lg.nf, BONE.fore1, BONE.fore2, -1)
  local ffE = ik(Sf, Lg.ff, BONE.fore1, BONE.fore2, -1)
  local nhK = ik(H, Lg.nh[1], BONE.hind1, BONE.hind2, 1)
  local fhK = ik(Hf, Lg.fh[1], BONE.hind1, BONE.hind2, 1)

  local earF = c:poly({ {hx + 1, hy - 7}, {hx + 5 + exF, hy - 13 + eyF}, {hx + 8, hy - 6} }):grow(1)
  local legFF = c:line({ Sf, ffE }, 5):add(c:line({ ffE, Lg.ff }, 3))
  local legHF = c:line({ Hf, fhK }, 5):add(c:line({ fhK, Lg.fh[1] }, 3)):add(c:line({ Lg.fh[1], Lg.fh[2] }, 3))
  -- tail
  local R = { rear + 6, BY - 6 }
  local tp = {}
  for i, o in ipairs(TAIL_OFF) do
    local dy = (i >= 3) and P.tdy[i - 2] or 0
    tp[i] = { R[1] + o[1], R[2] + o[2] + dy }
  end
  local tail = c:line({ tp[1], tp[2], tp[3] }, 5):add(c:line({ tp[3], tp[4], tp[5] }, 3))
  -- body capsule
  local body = c:line({ { rear + 7, BY - 2 * ts }, { BX, BY + P.arch }, { front - 7, BY + 2 * ts } }, 15)
  local chest = c:ellipse(S[1] + 1, S[2] - 5, 6, 6.5)
  local legHN = c:line({ H, nhK }, 5):add(c:line({ nhK, Lg.nh[1] }, 5)):add(c:line({ Lg.nh[1], Lg.nh[2] }, 3))
  local haunch = c:ellipse(H[1] - 1, H[2] - 4, 7.5, 7):add(c:line({ H, nhK }, 6))
  local legFN = c:line({ S, nfE }, 6):add(c:line({ nfE, Lg.nf }, 4))
  local earN = c:poly({ {hx - 8, hy - 5}, {hx - 5 + ex, hy - 13 + ey}, {hx + 1, hy - 7} }):grow(1)
  local head = c:ellipse(hx, hy, 12, 9.5):add(c:ellipse(hx + 2, hy + 4, 11, 6)):add(c:ellipse(hx + 11, hy + 4, 3.5, 3.5))

  local p = c:build{
    { "earF",  earF,  g,  { cres = 2, gloss = false } },
    { "legFF", legFF, dk, { cres = 2, gloss = false } },
    { "legHF", legHF, dk, { cres = 2, gloss = false } },
    { "tail",  tail,  g,  { cres = 2, gloss = false } },
    { "body",  body,  g,  { gloss = { rear + 8, BY - 4 } } },
    { "chest", chest, g },
    { "legHN", legHN, g,  { cres = 2, gloss = false } },
    { "haunch", haunch, g, { cres = 1, gloss = false } },
    { "legFN", legFN, g,  { cres = 2, gloss = false } },
    { "earN",  earN,  g,  { cres = 2, gloss = false } },
    { "head",  head,  h,  { gloss = { hx - 5, hy - 5 } } },
  }
  tint(c, head:clip(c:rect(hx - 12, hy + 3, hx + 8, hy + 10)), GREY.light, GREY.base)
  local tip = tp[5]
  tailTip(c, tail, c:rect(tip[1] - 3, tip[2] - 3, tip[1] + 3, tip[2] + 3), { { tip[1] - 3, tip[2] + 2 }, { tip[1] + 2, tip[2] + 2 } })
  -- paws
  p.pawFF = paw(c, Lg.ff[1] + 0.5, Lg.ff[2], pawDk(GREY), true, 3.5, 2.5, GREY.shade)
  p.pawHF = paw(c, Lg.fh[2][1] + 0.5, Lg.fh[2][2], pawDk(GREY), true, 3.5, 2.5, GREY.shade)
  p.pawHN = paw(c, Lg.nh[2][1] + 0.5, Lg.nh[2][2], nil, true, 4, 2.5)
  p.pawFN = paw(c, Lg.nf[1] + 0.5, Lg.nf[2], nil, true, 4, 2.5)
  edgeStitch(c, body, p.body, { lit = LIT })
  edgeStitch(c, head, p.head, { lit = LIT })
  -- face
  c:fill(c:poly({ {hx - 6, hy - 7}, {hx - 5 + ex, hy - 11 + ey}, {hx - 1, hy - 7} }):cut(head), PINK)
  catEye(c, hx + 4, hy - 3)
  c:paint({ "pp", "pp" }, hx + 13, hy + 1, { p = PINK })
  c:px(hx + 13, hy + 3, PINKS)
  c:fill(c:ellipse(hx + 11, hy + 5, 2, 1), GREY.gloss)
  c:paint({ "uu" }, hx + 12, hy + 6, { u = "ol2" })
  c:px(hx + 9, hy + 4, GREY.shade); c:px(hx + 10, hy + 6, GREY.shade); c:px(hx + 8, hy + 6, GREY.shade)

  info[f] = { c = c, p = p, tp = tp, R = R, rear = rear, front = front, nfE = nfE, ffE = ffE, nhK = nhK, fhK = fhK }
  return c, p
end

-- split the finished canvas into disjoint layer images by part ownership
local function layerImages(c, p)
  local owner = {}
  for name, part in pairs(p) do owner[part] = LAYER_OF[name] end
  local imgs, pc = {}, app.pixelColor
  local function get(n) if not imgs[n] then imgs[n] = Image(80, 64, ColorMode.RGB); imgs[n]:clear(pc.rgba(0, 0, 0, 0)) end return imgs[n] end
  for _, n in ipairs{ "outline", "legs-far", "tail", "body", "legs-near", "ears", "head+face" } do get(n) end
  for k, hex in pairs(c.pix) do
    local x, y = c:xy(k)
    if c:inside(x, y) then
      local r, gg, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
      get(owner[c.own[k]] or "outline"):putPixel(x, y, pc.rgba(r, gg, b, 255))
    end
  end
  return imgs
end

local function maskImage(c, p, names)
  local img, pc = Image(80, 64, ColorMode.RGB), app.pixelColor
  img:clear(pc.rgba(0, 0, 0, 0))
  local set = {}
  for _, n in ipairs(names) do set[p[n]] = true end
  for k in pairs(c.pix) do
    local x, y = c:xy(k)
    if c:inside(x, y) and set[c.own[k]] then img:putPixel(x, y, pc.rgba(255, 255, 255, 255)) end
  end
  return img
end

local files, layerSets = {}, {}
local checks = {}
for f = 1, 12 do
  local c, p = frame(f)
  local name = string.format("cf-cat-grey-run%02d", f)
  local t = c:save(nil, OUT .. name .. ".png")
  checks[f] = t
  print(string.format("run%02d ", f) .. GV.report(t))
  files[f] = OUT .. name .. ".png"
  layerSets[f] = layerImages(c, p)
  maskImage(c, p, { "earF", "earN" }):saveAs(string.format("%scf-ears-mask-run%02d.png", OUT, f))
  maskImage(c, p, { "tail" }):saveAs(string.format("%scf-tail-mask-run%02d.png", OUT, f))
end

-- .aseprite with layers
local spr = Sprite(80, 64, ColorMode.RGB)
for i = 2, 12 do spr:newEmptyFrame() end
local order = { "outline", "legs-far", "tail", "body", "legs-near", "ears", "head+face" }
spr.layers[1].name = order[1]
for i = 2, #order do spr:newLayer().name = order[i] end
for _, lname in ipairs(order) do
  local layer
  for _, l in ipairs(spr.layers) do if l.name == lname then layer = l end end
  for f = 1, 12 do spr:newCel(layer, spr.frames[f], layerSets[f][lname], Point(0, 0)) end
end
for f = 1, 12 do spr.frames[f].duration = FRAMEMS / 1000 end
spr:saveAs(OUT .. "cf-run80-grey.aseprite")
spr:close()
-- sheet 800x64
local sheet = Image(960, 64, ColorMode.RGB)
for f = 1, 12 do sheet:drawImage(Image{ fromFile = files[f] }, Point((f - 1) * 80, 0)) end
local s2 = Sprite(960, 64, ColorMode.RGB)
s2.cels[1].image = sheet
s2:saveCopyAs(OUT .. "cf-run80-sheet.png")
s2:close()

-- ============================== SELF-CHECK (spec section 5) ==============================
local ok = true
local function chk(cond, msg) print((cond and "PASS " or "FAIL ") .. msg); if not cond then ok = false end end
local maxCol, minMargin, semi = 0, 99, 0
for f = 1, 12 do maxCol = math.max(maxCol, checks[f].colours); minMargin = math.min(minMargin, checks[f].margin); semi = semi + checks[f].semi end
chk(maxCol <= 15, "colours (excluding transparent) max " .. maxCol .. " (<=15 + transparent = 16)")
chk(semi == 0, "alpha only 0/255 (semi=" .. semi .. ")")
chk(minMargin >= 3, "transparent margin min " .. minMargin)
-- planted paws: bottom felt row 55
local plantOK, plantMsg = true, ""
for f = 1, 12 do
  local I, Lg = info[f], LEGS[f]
  for _, q in ipairs{ { "pawFN", Lg.nf }, { "pawFF", Lg.ff }, { "pawHN", Lg.nh[2] }, { "pawHF", Lg.fh[2] } } do
    if q[2][2] == GROUND then
      local _, _, _, y1 = I.p[q[1]].m:bbox()
      if y1 ~= 55 then plantOK = false; plantMsg = plantMsg .. string.format(" F%d %s bottom=%d", f, q[1], y1) end
    end
  end
end
chk(plantOK, "planted paws bottom felt row 55" .. plantMsg)
-- body column constant: centre of the body mask
local cxs, bys = {}, {}
for f = 1, 12 do
  local x0, y0, x1, y1 = info[f].p.body.m:bbox()
  cxs[f] = (x0 + x1) / 2; bys[f] = POSE[f].BY
end
local same = true
for f = 2, 12 do if cxs[f] ~= cxs[1] then same = false end end
chk(same, "body column constant (centres " .. table.concat(cxs, ",") .. ")")
local bmin, bmax = 99, 0
for f = 1, 12 do bmin = math.min(bmin, bys[f]); bmax = math.max(bmax, bys[f]) end
chk(bmax - bmin == 4, "body vertical travel " .. (bmax - bmin))
-- loop continuity: joint deltas (paws, hocks, shoulder, hip, head, body BY)
local function dmax(a, b)
  local m = 0
  local function d(p, q) m = math.max(m, math.abs(p[1] - q[1]), math.abs(p[2] - q[2])) end
  d(POSE[a].S, POSE[b].S); d(POSE[a].H, POSE[b].H); d(POSE[a].head, POSE[b].head)
  m = math.max(m, math.abs(POSE[a].BY - POSE[b].BY))
  for _, k in ipairs{ "nf", "ff" } do d(LEGS[a][k], LEGS[b][k]) end
  for _, k in ipairs{ "nh", "fh" } do d(LEGS[a][k][1], LEGS[b][k][1]); d(LEGS[a][k][2], LEGS[b][k][2]) end
  return m
end
local worst, parts = 0, {}
for f = 1, 12 do local n = f % 12 + 1; local d = dmax(f, n); worst = math.max(worst, d); parts[#parts + 1] = d end
chk(worst <= 7 and parts[12] <= 2, "joint deltas between neighbours max " .. worst .. " (per pair " .. table.concat(parts, ",") .. "; F12->F1 " .. parts[12] .. ")")
-- head profile / tail / leg lengths / F5 gap / extents
local tailOK, legOK = true, true
for f = 1, 12 do
  local I = info[f]
  if I.tp[5][1] < 9 then tailOK = false end
  local S, H, Lg = POSE[f].S, POSE[f].H, LEGS[f]
  local function dist(a, b) return math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2) end
  local hk = { { H, Lg.nh[1] }, { { H[1] + 1, H[2] - 1 }, Lg.fh[1] } }
  for _, q in ipairs(hk) do local d = dist(q[1], q[2]); if d < 4 or d > 13 then legOK = false; print(string.format("  F%d hip-hock %.1f", f, d)) end end
  for _, q in ipairs{ { S, Lg.nf }, { { S[1] - 1, S[2] - 1 }, Lg.ff }, { H, Lg.nh[2] }, { { H[1] + 1, H[2] - 1 }, Lg.fh[2] } } do
    if q[2][2] == GROUND and dist(q[1], q[2]) < 10 then legOK = false end
  end
end
chk(tailOK, "tail tip x >= 9 in all frames")
chk(legOK, "planted legs measure >= 10 px root to paw")
do
  local function gap(A, B) local ax0, ay0, ax1, ay1 = A.m:bbox(); local bx0, by0, bx1, by1 = B.m:bbox()
    return math.max(ax0 - bx1, bx0 - ax1, ay0 - by1, by0 - ay1) end
  local g1, g2 = gap(info[5].p.pawFF, info[5].p.pawHF), gap(info[5].p.pawFF, info[5].p.pawHN)
  chk(g1 >= 1 and g2 >= 1, "F5 gap between far fore paw and hind paws (" .. g1 .. "," .. g2 .. " px)")
end
local ext = true
for f = 1, 12 do
  local I = info[f]
  local gx0, gy0, gx1, gy1 = 99, 99, -1, -1
  for _, part in pairs(I.p) do
    local x0, y0, x1, y1 = part.m:bbox()
    if x0 then gx0 = math.min(gx0, x0); gy0 = math.min(gy0, y0); gx1 = math.max(gx1, x1); gy1 = math.max(gy1, y1) end
  end
  if gx0 < 6 or gy0 < 6 or gx1 > 72 or gy1 > 56 then ext = false; print(string.format("  F%d felt extents %d,%d..%d,%d", f, gx0, gy0, gx1, gy1)) end
end
chk(ext, "felt inside x 6..72, y 6..56")
local hmin, hmax = 99, 0
for f = 1, 12 do for _, q in ipairs{ { POSE[f].H, LEGS[f].nh[1] }, { { POSE[f].H[1] + 1, POSE[f].H[2] - 1 }, LEGS[f].fh[1] } } do local d = math.sqrt((q[1][1] - q[2][1]) ^ 2 + (q[1][2] - q[2][2]) ^ 2); hmin = math.min(hmin, d); hmax = math.max(hmax, d) end end
print(string.format("hip-hock range %.1f..%.1f", hmin, hmax))
print(ok and "ALL CHECKS PASS" or "SOME CHECKS FAILED")

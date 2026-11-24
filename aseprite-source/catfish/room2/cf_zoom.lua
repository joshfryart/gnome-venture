-- cf_zoom.lua : Cat Fish grey template, 6-frame ZOOMIES sprint (80x64, facing right), per props_zoomie_spec.md section 4.
-- Built from cf_run80.lua (same parts / ramps / IK / helpers). Run: AppRun -b --script cf_zoom.lua
-- Writes out_zoom/cf-cat-grey-zoom01..06.png, cf-ears-mask-zoomNN.png, cf-tail-mask-zoomNN.png,
-- cf-zoom-grey.aseprite (6 frames, 50 ms, 7 layers), cf-zoom-sheet.png (480x64). Previews: make_view_zoom.py.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out_zoom/"

-- ============================== POSE TABLE (the art director's numbers) ==============================
local BX = 33            -- body centre column, never moves
local GROUND = 53        -- planted paw centre y
local FRAMEMS = 50
local NF = 6
-- per frame: BY, L, arch, tilt, head hy (hx = S.x+9, from L), tail offsets P0..P4 incl. dy
local POSE = {
  { BY=43, L=32, arch=-2, tilt=0,  hy=35, tdy={1,2,2} },   -- Z1 crouch-launch
  { BY=40, L=38, arch=0,  tilt=-3, hy=31, tdy={0,1,1} },   -- Z2 hind push
  { BY=38, L=40, arch=0,  tilt=0,  hy=30, tdy={-1,-1,-2} }, -- Z3 full flight
  { BY=40, L=38, arch=0,  tilt=3,  hy=31, tdy={0,0,0} },   -- Z4 fore contact
  { BY=39, L=30, arch=-3, tilt=0,  hy=30, tdy={1,1,2} },   -- Z5 gathered, hind contact
  { BY=41, L=34, arch=-1, tilt=-4, hy=31, tdy=nil, up=true }, -- Z6 skid, tail up
}
local TAIL_UP = { {0,0}, {-3,-2}, {-5,-5}, {-6,-9}, {-5,-12} }
-- Z3 far paws nudged apart from near (spec 63,46 / 14,46) so four paws read
local LEGS = {
  { nf={52,53}, ff={49,53}, nh={{19,50},{22,53}}, fh={{21,49},{25,53}} },
  { nf={58,48}, ff={54,49}, nh={{18,49},{16,53}}, fh={{21,49},{20,53}} },
  { nf={67,45}, ff={59,46}, nh={{15,46},{11,47}}, fh={{17,45},{18,46}} },
  { nf={61,53}, ff={57,53}, nh={{21,46},{18,48}}, fh={{23,45},{21,47}} },
  { nf={46,49}, ff={43,48}, nh={{27,50},{26,53}}, fh={{30,50},{30,53}} },
  { nf={65,53}, ff={61,53}, nh={{24,50},{24,53}}, fh={{27,50},{28,53}} },
}
-- shape constants
local BONE = { fore1 = 7, fore2 = 7, hind1 = 7, hind2 = 7 }
local TAIL_OFF = { {0,0}, {-3,0}, {-6,-1}, {-8,-1}, {-10,-1} }   -- from root R = (rear+6, BY-5)
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

-- elbow/knee that keeps the limb's felt (joint y + 3) inside y 56: shorten the bones (7 -> 5) while the joint hangs too low
local function ikc(r, t, dir, w)
  local j
  for l = 7, 5, -1 do j = ik(r, t, l, l, dir); if j[2] + (w or 3) <= 56 then return j, l end end
  return j, 5
end
local info = {}   -- per-frame data for self-check
local function frame(f)
  local P, Lg = POSE[f], LEGS[f]
  local c = GV.canvas{ w = 80, h = 64, mode = "sticker" }
  local g, h, dk = coat(GREY), coatHi(GREY), coatDk(GREY)
  local BY, L = P.BY, P.L
  local rear, front = BX - L // 2, BX + L // 2
  local ts = P.tilt >= 3 and 1 or (P.tilt <= -3 and -1 or 0)
  local S, H = { front - 5, BY + 4 }, { rear + 5, BY + 3 }
  local Sf, Hf = { S[1] - 1, S[2] - 1 }, { H[1] + 1, H[2] - 1 }
  local hx, hy = S[1] + 9, P.hy

  -- legs
  local nfE = ikc(S, Lg.nf, -1, 3)
  local ffE = ikc(Sf, Lg.ff, -1, 2)
  local nhK = ik(H, Lg.nh[1], BONE.hind1, BONE.hind2, 1)
  local fhK = ik(Hf, Lg.fh[1], BONE.hind1, BONE.hind2, 1)

  local earF = c:poly({ {hx + 1, hy - 9}, {hx - 3, hy - 9}, {hx - 9, hy - 12} }):grow(1)
  local legFF = c:line({ Sf, ffE }, 5):add(c:line({ ffE, Lg.ff }, 3))
  local legHF = c:line({ Hf, fhK }, 5):add(c:line({ fhK, Lg.fh[1] }, 3)):add(c:line({ Lg.fh[1], Lg.fh[2] }, 3))
  -- tail
  local R = { rear + 6, BY - 5 }
  local tp = {}
  for i, o in ipairs(P.up and TAIL_UP or TAIL_OFF) do
    local dy = (i >= 3 and not P.up) and P.tdy[i - 2] or 0
    tp[i] = { R[1] + o[1], R[2] + o[2] + dy }
  end
  local tail = c:line({ tp[1], tp[2], tp[3] }, 5):add(c:line({ tp[3], tp[4], tp[5] }, 3))
  -- body capsule
  local body = c:line({ { rear + 7, BY - 2 * ts }, { BX, BY + P.arch }, { front - 7, BY + 2 * ts } }, 13)
  local chest = c:ellipse(S[1] + 1, S[2] - 5, 6, 5.5)
  local legHN = c:line({ H, nhK }, 5):add(c:line({ nhK, Lg.nh[1] }, 5)):add(c:line({ Lg.nh[1], Lg.nh[2] }, 3))
  local haunch = c:ellipse(H[1] - 1, H[2] - 4, 7.5, 6):add(c:line({ H, nhK }, 6))
  local legFN = c:line({ S, nfE }, 6):add(c:line({ nfE, Lg.nf }, 4))
  local earN = c:poly({ {hx - 2, hy - 9}, {hx - 7, hy - 7}, {hx - 13, hy - 10} }):grow(1)
  local head = c:ellipse(hx, hy, 12, 8.5):add(c:ellipse(hx + 2, hy + 4, 11, 6)):add(c:ellipse(hx + 11, hy + 4, 3.5, 3.5))

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
for f = 1, NF do
  local c, p = frame(f)
  local name = string.format("cf-cat-grey-zoom%02d", f)
  local t = c:save(nil, OUT .. name .. ".png")
  checks[f] = t
  print(string.format("zoom%02d ", f) .. GV.report(t))
  files[f] = OUT .. name .. ".png"
  layerSets[f] = layerImages(c, p)
  maskImage(c, p, { "earF", "earN" }):saveAs(string.format("%scf-ears-mask-zoom%02d.png", OUT, f))
  maskImage(c, p, { "tail" }):saveAs(string.format("%scf-tail-mask-zoom%02d.png", OUT, f))
end

-- .aseprite with layers
local spr = Sprite(80, 64, ColorMode.RGB)
for i = 2, NF do spr:newEmptyFrame() end
local order = { "outline", "legs-far", "tail", "body", "legs-near", "ears", "head+face" }
spr.layers[1].name = order[1]
for i = 2, #order do spr:newLayer().name = order[i] end
for _, lname in ipairs(order) do
  local layer
  for _, l in ipairs(spr.layers) do if l.name == lname then layer = l end end
  for f = 1, NF do spr:newCel(layer, spr.frames[f], layerSets[f][lname], Point(0, 0)) end
end
for f = 1, NF do spr.frames[f].duration = FRAMEMS / 1000 end
spr:saveAs(OUT .. "cf-zoom-grey.aseprite")
spr:close()
-- sheet 800x64
local sheet = Image(480, 64, ColorMode.RGB)
for f = 1, NF do sheet:drawImage(Image{ fromFile = files[f] }, Point((f - 1) * 80, 0)) end
local s2 = Sprite(480, 64, ColorMode.RGB)
s2.cels[1].image = sheet
s2:saveCopyAs(OUT .. "cf-zoom-sheet.png")
s2:close()

-- ============================== SELF-CHECK (spec section 4 checks) ==============================
local ok = true
local function chk(cond, msg) print((cond and "PASS " or "FAIL ") .. msg); if not cond then ok = false end end
local function dist(a, b) return math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2) end
local maxCol, minMargin, semi = 0, 99, 0
for f = 1, NF do maxCol = math.max(maxCol, checks[f].colours); minMargin = math.min(minMargin, checks[f].margin); semi = semi + checks[f].semi end
chk(maxCol <= 15, "colours max " .. maxCol .. " (+transparent <= 16)")
chk(semi == 0, "alpha only 0/255 (semi=" .. semi .. ")")
chk(minMargin >= 3, "transparent margin min " .. minMargin)
local plantOK, plantMsg = true, ""
for f = 1, NF do
  local I, Lg = info[f], LEGS[f]
  for _, q in ipairs{ { "pawFN", Lg.nf }, { "pawFF", Lg.ff }, { "pawHN", Lg.nh[2] }, { "pawHF", Lg.fh[2] } } do
    if q[2][2] == GROUND then
      local _, _, _, y1 = I.p[q[1]].m:bbox()
      if y1 ~= 55 then plantOK = false; plantMsg = plantMsg .. string.format(" Z%d %s bottom=%d", f, q[1], y1) end
    end
  end
end
chk(plantOK, "planted paws bottom felt row 55" .. plantMsg)
local same = true
for f = 1, NF do local x0, _, x1 = info[f].p.body.m:bbox(); if (x0 + x1) / 2 ~= BX - 0.5 and (x0 + x1) / 2 ~= BX + 0.5 and (x0 + x1) / 2 ~= BX then same = false end end
chk(same, "body column centred on BX")
-- joint deltas (Z1->Z2, Z2..Z5, Z5->Z2 loop seam, Z5->Z6), limit 12 (hock/knee not counted by IK)
local function joints(f)
  local P, Lg = POSE[f], LEGS[f]
  local rear, front = BX - P.L // 2, BX + P.L // 2
  local S, H = { front - 5, P.BY + 4 }, { rear + 5, P.BY + 3 }
  return { S, H, { S[1] + 9, P.hy }, Lg.nf, Lg.ff, Lg.nh[1], Lg.nh[2], Lg.fh[1], Lg.fh[2] }
end
local function dmax(a, b)
  local A, B, m = joints(a), joints(b), math.abs(POSE[a].BY - POSE[b].BY)
  for i = 1, #A do m = math.max(m, math.abs(A[i][1] - B[i][1]), math.abs(A[i][2] - B[i][2])) end
  return m
end
local pairsL = { { 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 5 }, { 5, 2 }, { 5, 6 } }
local worst, ds = 0, {}
for _, q in ipairs(pairsL) do local d = dmax(q[1], q[2]); worst = math.max(worst, d); ds[#ds + 1] = "Z" .. q[1] .. ">Z" .. q[2] .. "=" .. d end
chk(worst <= 12, "joint steps max " .. worst .. " (" .. table.concat(ds, " ") .. ")")
local tailOK, tailUp, legOK, ext = true, true, true, true
for f = 1, NF do
  local I = info[f]
  if I.tp[5][1] < 9 then tailOK = false end
  if not POSE[f].up then for i = 1, 5 do if I.R[2] - I.tp[i][2] > 3 then tailUp = false; print(string.format("  Z%d tail P%d %d above R", f, i, I.R[2] - I.tp[i][2])) end end end
  local gx0, gy0, gx1, gy1 = 99, 99, -1, -1
  for _, part in pairs(I.p) do
    local x0, y0, x1, y1 = part.m:bbox()
    if x0 then gx0 = math.min(gx0, x0); gy0 = math.min(gy0, y0); gx1 = math.max(gx1, x1); gy1 = math.max(gy1, y1) end
  end
  if gy1 > 56 then for n,part in pairs(I.p) do local _,_,_,yy=part.m:bbox(); if yy and yy>56 then print("   over:",n,yy) end end end
  if gx0 < 6 or gy0 < 6 or gx1 > 72 or gy1 > 56 then ext = false; print(string.format("  Z%d felt extents %d,%d..%d,%d", f, gx0, gy0, gx1, gy1)) end
  -- ears never above skull top (hy - 8.5 -> row hy-9 of head); report ear top vs head top
  local _, ey0 = I.p.earN.m:bbox(); local _, hy0 = I.p.head.m:bbox()
  local _, ey1 = I.p.earF.m:bbox()
  print(string.format("  Z%d ear top y %d/%d, skull top y %d", f, ey0, ey1, hy0))
end
chk(tailOK, "tail tip x >= 9")
chk(tailUp, "tail <= 3 px above R (except Z6)")
chk(ext, "felt inside x 6..72, y 6..56")
-- Z3: four separate paws + daylight under the body
do
  local I, ok3 = info[3], true
  local ks = { "pawFN", "pawFF", "pawHN", "pawHF" }
  for a = 1, 4 do for b = a + 1, 4 do
    local A, B = I.p[ks[a]].m, I.p[ks[b]].m
    local ax0, ay0, ax1, ay1 = A:bbox(); local bx0, by0, bx1, by1 = B:bbox()
    local gp = math.max(ax0 - bx1, bx0 - ax1, ay0 - by1, by0 - ay1)
    if gp < 0 then print("  Z3 paws overlap " .. ks[a] .. " " .. ks[b]) end
  end end
  local _, _, _, by1 = I.p.body.m:bbox()
  local _, py0 = I.p.pawFN.m:bbox()
  print("  Z3 body bottom " .. by1 .. ", lowest paw top " .. py0)
end
print(ok and "ALL CHECKS PASS" or "SOME CHECKS FAILED")

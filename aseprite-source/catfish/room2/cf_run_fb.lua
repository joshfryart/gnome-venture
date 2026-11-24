-- cf_run_fb.lua : Cat Fish grey template, RUN-TOWARD / RUN-AWAY cycles (8 frames, 64x64), per run_fb_spec.md.
-- Run: AppRun -b --script cf_run_fb.lua ; previews: python3 make_view_fb.py
-- Writes out_fb/cf-cat-grey-run{toward,away}01..08.png, cf-ears-mask-/cf-tail-mask-run{view}0N.png,
-- cf-run{view}-grey.aseprite (7 layers, 70 ms), cf-run{view}-sheet.png (512x64).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out_fb/"

-- ============================== POSE TABLES (art director's numbers) ==============================
local CX, GROUND, FRAMEMS = 32, 53, 70
-- shared: BY body centre y, sq squash, hd head dx,dy, eL/eR ear offsets (idle catHead)
local SH = {
  { BY=45, sq= 0, hd={ 0,-1}, eL={ 0, 0}, eR={ 0, 0} }, -- 1 fore contact
  { BY=46, sq= 2, hd={ 1, 0}, eL={ 0, 1}, eR={ 0, 0} }, -- 2 fore compress
  { BY=45, sq= 1, hd={ 1, 1}, eL={-1, 1}, eR={ 1, 0} }, -- 3 fore push
  { BY=43, sq=-1, hd={ 0, 0}, eL={ 0,-1}, eR={ 0,-1} }, -- 4 flight gathered
  { BY=45, sq= 0, hd={ 0,-1}, eL={ 0, 0}, eR={ 0, 0} }, -- 5 hind contact
  { BY=46, sq= 2, hd={-1, 0}, eL={ 0, 0}, eR={ 0, 1} }, -- 6 hind compress
  { BY=44, sq= 1, hd={-1, 0}, eL={-1, 0}, eR={ 1, 1} }, -- 7 hind push
  { BY=42, sq=-2, hd={ 0,-1}, eL={ 0,-1}, eR={ 0,-1} }, -- 8 flight extended
}
-- TOWARD: fore L {x,y,size S/M/L}, hind L {x,y}, tail tx,ty (R = mirror of L[f-1])
local TW = {
  { fore={22,53,"M"}, hind={13,47}, tx= 0, ty= 0 },
  { fore={22,53,"M"}, hind={13,46}, tx=-1, ty= 0 },
  { fore={23,51,"M"}, hind={14,46}, tx=-1, ty= 1 },
  { fore={24,48,"S"}, hind={14,48}, tx= 0, ty= 2 },
  { fore={23,47,"M"}, hind={14,50}, tx= 1, ty= 0 },
  { fore={22,49,"L"}, hind={14,50}, tx= 2, ty= 0 },
  { fore={21,51,"L"}, hind={13,49}, tx= 2, ty= 1 },
  { fore={21,52,"L"}, hind={13,48}, tx= 1, ty= 2 },
}
-- AWAY: hind L paw {x,y,rx,ry,mode(u tucked / p pad / h heel)}, fore L (far) {x,y}, tail s3,s4, ty
local AW = {
  { hind={20,46,5,3.5,"p"},   fore={17,49}, s={0,0}, ty= 0 },
  { hind={23,46,4,2.5,"u"},   fore={17,49}, s={0,1}, ty=-1 },
  { hind={25,47,4,2,"u"},     fore={18,47}, s={1,2}, ty=-1 },
  { hind={25,50,4,2.5,"h"},   fore={20,46}, s={2,3}, ty= 1 },
  { hind={24,53,4.5,2.5,"h"}, fore={19,45}, s={2,4}, ty=-1 },
  { hind={24,53,4.5,2.5,"h"}, fore={17,45}, s={2,3}, ty=-1 },
  { hind={22,50,4.5,3,"p"},   fore={16,46}, s={1,2}, ty= 1 },
  { hind={21,48,5,3.5,"p"},   fore={16,48}, s={0,1}, ty= 2 },
}
-- ====================================================================================================

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local function coatDk(t) return { gloss = t.base, dot = t.base, rim = t.base, base = t.shade, shade = t.shade, deep = t.shade, bounce = t.shade } end
local function pawDk(t) return { gloss = t.light, dot = t.light, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3

-- ======================= shared template (copy of cf_run80.lua / cf_frames_s4.lua) =======================
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
local Z = { 0, 0 }
local function catHead(c, ox, oy, eL, eR, k, ramp)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), ramp or coatHi(GREY)
  local function M(x, y) return 25 + (x - 25) * k + ox, 21 + (y - 21) * k + oy end
  local function P(pts, a, b) local o = {} for i, q in ipairs(pts) do local x, y = M(q[1], q[2]); o[i] = { x + a, y + b } end return o end
  local head = c:ellipse(25 + ox, 21 + (20.5 - 21) * k + oy, 15 * k, 9.5 * k):add(c:ellipse(25 + ox, 21 + (24.5 - 21) * k + oy, 15.5 * k, 7.5 * k))
  local earL = c:poly(P({ {10, 21}, {12, 7}, {23, 13} }, eL[1], eL[2])):grow(1)
  local earR = c:poly(P({ {27, 13}, {38, 7}, {40, 21} }, eR[1], eR[2])):grow(1)
  local gl = (k < 0.82) and { 12 + ox, 15 + oy } or { M(14, 15) }
  return { { "earL", earL, g, { cres = 2, gloss = false } }, { "earR", earR, g, { cres = 2, gloss = false } },
           { "head", head, h, { gloss = gl } } }, head
end
local function catFaceOpen(c, ox, oy, head, eL, eR, k)
  eL, eR = eL or Z, eR or Z
  local function M(x, y) return 25 + (x - 25) * k + ox, 21 + (y - 21) * k + oy end
  local function P(pts, a, b) local o = {} for i, q in ipairs(pts) do local x, y = M(q[1], q[2]); o[i] = { x + a, y + b } end return o end
  local function R(x, y) local a, b = M(x, y); return math.floor(a + 0.5), math.floor(b + 0.5) end
  c:fill(c:poly(P({ {13, 18}, {13, 9}, {21, 14} }, eL[1], eL[2])):cut(head), PINK)
  c:fill(c:poly(P({ {29, 14}, {37, 9}, {37, 18} }, eR[1], eR[2])):cut(head), PINK)
  local nx, ny = R(25, 27)
  c:fill(c:ellipse(nx, ny, 3 * k, 1.5 * k), GREY.gloss)
  local px, py = R(24, 25)
  c:paint({ "ppp", ".q." }, px, py, { p = PINK, q = PINKS })
  local mx, my = R(24, 27)
  c:paint({ "u.u" }, mx, my, { u = "ol2" })
  local ke = 0.9
  local function E(x, y) return math.floor(25 + (x - 25) * ke + ox + 0.5), math.floor(21 + (y - 21) * k + oy + 0.5) end
  local x1, y1 = E(14, 19); catEye(c, x1, y1)
  local x2, y2 = E(32, 19); catEye(c, x2, y2)
end
local function paw(c, cx, cy, ramp, toes, rx, ry, toeHex)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), ramp or coatHi(GREY), { flat = true })
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = toeHex or GREY.base }) end
  return P
end
local function tailTip(c, tail, region, seam) tint(c, region:clip(tail), GREY.base, GREY.light); c:seam(seam) end
-- ===========================================================================================================

local function mir(q) return { 64 - q[1], q[2], q[3], q[4], q[5] } end
local function lastf(f) return (f - 2) % 8 + 1 end
local g, h, dk = coat(GREY), coatHi(GREY), coatDk(GREY)

local LAYER_OF = {
  tail = "tail", legHL = "legs-far", legHR = "legs-far", pawHL = "legs-far", pawHR = "legs-far",
  shoulders = "body", chest = "body", legFL = "legs-near", legFR = "legs-near", pawFL = "legs-near", pawFR = "legs-near",
  earL = "ears", earR = "ears", head = "head+face",
  -- away
  legFFL = "legs-far", legFFR = "legs-far", pawFFL = "legs-far", pawFFR = "legs-far", pawUL = "legs-far", pawUR = "legs-far",
  back = "body", rump = "body", hauL = "body", hauR = "body",
  legNL = "legs-near", legNR = "legs-near", pawNL = "legs-near", pawNR = "legs-near",
}

-- fore paw ascii masks
local PAWM = {
  S = {}, M = {},
  L = { "..#########..", ".###########.", "#############", "#############", "#############", "#############", ".###########." },
}
PAWM.S = { ".#######.", "#########", "#########", "#########", ".#######." }
PAWM.M = { "..#######..", ".#########.", "###########", "###########", "###########", ".#########." }
local function forePaw(c, q)
  local rows = PAWM[q[3]]
  local w, hgt = #rows[1], #rows
  local x0, y0 = q[1] - math.floor(w / 2), q[2] + 2 - (hgt - 1)
  local P = c:part(c:mask():ascii(rows, x0, y0), h, { flat = true })
  local nb = (q[3] == "L") and 3 or 2
  for r = hgt - nb, hgt - 1 do
    c:px(x0 + math.floor(w / 2) - 2, y0 + r, GREY.base); c:px(x0 + math.floor(w / 2) + 2, y0 + r, GREY.base)
  end
  return P
end
local function mirf(q) return { 64 - q[1], q[2], q[3] } end

-- records: info[view][f] = { paws = { name = {x,y,planted?} }, head, ears, tip, p, c }
local KT, KA = 0.85, 0.80
local function toward(f)
  local S, T = SH[f], TW[f]
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local p = {}
  local BY, sq = S.BY, S.sq
  local pv = TW[lastf(f)]
  local foreL, foreR = T.fore, mirf(pv.fore)
  local hindL, hindR = T.hind, { 64 - pv.hind[1], pv.hind[2] }
  -- 1 tail (beside right haunch)
  local Tx, Ty = 52 + T.tx, BY - 11 + T.ty
  local tail = c:line({ {44, BY}, {49, BY - 4}, {Tx, Ty} }, 5)
  p.tail = c:part(tail, g, { cres = 2, gloss = false })
  tailTip(c, tail, c:rect(Tx - 3, Ty - 3, Tx + 3, Ty + 3), { {Tx - 3, Ty + 2}, {Tx + 2, Ty + 2} })
  -- 2 hind legs/paws (far)
  p.legHL = c:part(c:line({ {CX - 11, BY + 1}, {hindL[1], hindL[2]} }, 5), dk, { cres = 2, gloss = false })
  p.legHR = c:part(c:line({ {CX + 11, BY + 1}, {hindR[1], hindR[2]} }, 5), dk, { cres = 2, gloss = false })
  p.pawHL = paw(c, hindL[1], hindL[2], pawDk(GREY), true, 4, 2.5, GREY.shade)
  p.pawHR = paw(c, hindR[1], hindR[2], pawDk(GREY), true, 4, 2.5, GREY.shade)
  -- 3-4 shoulders, chest
  local sh = c:ellipse(CX, BY - 6, 16, 5)
  p.shoulders = c:part(sh, g)
  local ch = c:ellipse(CX, BY, 15 + sq, 6 - sq)
  p.chest = c:part(ch, g, { gloss = { 27, BY - 3 } })
  -- 5-6 forelegs, fore paws
  p.legFL = c:part(c:line({ {CX - 7, BY + 2}, {foreL[1], foreL[2] - 1} }, 7), g, { cres = 2, gloss = false })
  p.legFR = c:part(c:line({ {CX + 7, BY + 2}, {foreR[1], foreR[2] - 1} }, 7), g, { cres = 2, gloss = false })
  p.pawFL = forePaw(c, foreL)
  p.pawFR = forePaw(c, foreR)
  -- 7 ears, head
  local ox, oy = 7 + S.hd[1], 5 + S.hd[2]
  local list, head = catHead(c, ox, oy, S.eL, S.eR, KT)
  for n, P in pairs(c:build(list)) do p[n] = P end
  -- 8 stitch
  edgeStitch(c, ch, p.chest, { lit = LIT }); edgeStitch(c, sh, p.shoulders, { lit = LIT }); edgeStitch(c, head, p.head, { lit = LIT })
  -- 9 face
  catFaceOpen(c, ox, oy, head, S.eL, S.eR, KT)
  local I = { c = c, p = p, BY = BY, head = { ox, oy }, tip = { Tx, Ty },
    ears = { { ox + S.eL[1], oy + S.eL[2] }, { ox + S.eR[1], oy + S.eR[2] } },
    paws = { foreL = foreL, foreR = foreR, hindL = hindL, hindR = hindR },
    plant = { pawFL = foreL[2] == GROUND, pawFR = foreR[2] == GROUND, pawHL = hindL[2] == 50, pawHR = hindR[2] == 50 },
    plantRow = { pawFL = 55, pawFR = 55, pawHL = 52, pawHR = 52 }, bodyNames = { "chest" } }
  return c, p, I
end

local HAU = {
  "....#####....", "..#########..", ".###########.", ".###########.", "#############", "#############", "#############",
  "#############", "#############", ".###########.", ".###########.", "..#########..", "...#######...",
}
local function away(f)
  local S, T = SH[f], AW[f]
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local p = {}
  local BY, sq = S.BY, S.sq
  local pv = AW[lastf(f)]
  local hindL, hindR = T.hind, mir(pv.hind)
  local foreL, foreR = T.fore, { 64 - pv.fore[1], pv.fore[2] }
  -- 1 far fore legs / paws
  p.legFFL = c:part(c:line({ {CX - 9, BY - 6}, {foreL[1], foreL[2]} }, 4), dk, { cres = 2, gloss = false })
  p.legFFR = c:part(c:line({ {CX + 9, BY - 6}, {foreR[1], foreR[2]} }, 4), dk, { cres = 2, gloss = false })
  p.pawFFL = paw(c, foreL[1], foreL[2], pawDk(GREY), true, 3.5, 2, GREY.shade)
  p.pawFFR = paw(c, foreR[1], foreR[2], pawDk(GREY), true, 3.5, 2, GREY.shade)
  -- 2 tucked hind paws
  if hindL[5] == "u" then p.pawUL = paw(c, hindL[1], hindL[2], h, false, hindL[3], hindL[4]) end
  if hindR[5] == "u" then p.pawUR = paw(c, hindR[1], hindR[2], h, false, hindR[3], hindR[4]) end
  -- 3-4 ears, back of head (coat ramp g, no pale dome)
  local ox, oy = 7 + S.hd[1], 4 + S.hd[2]
  local list, head = catHead(c, ox, oy, S.eL, S.eR, KA, g)
  for n, P in pairs(c:build(list)) do p[n] = P end
  -- 5-6 back, rump
  local backM = c:ellipse(CX, BY - 8, 10, 6)
  p.back = c:part(backM, g)
  local rump = c:ellipse(CX, BY - 1, 12.5 + sq, 8.5 - sq)
  p.rump = c:part(rump, g, { gloss = { 25, BY - 6 } })
  -- 7 haunches (13x13 mask)
  local hdL = (f == 7 or f == 8) and 1 or 0
  local hdR = (f == 8 or f == 1) and 1 or 0
  local function haunch(side, hd)
    local cx, cy = side == "L" and CX - 7 or CX + 7, BY + 1 + hd
    local m = c:mask():ascii(HAU, cx - 6, cy - 6)
    local P = c:part(m, g, { cres = 2, gloss = { cx - 2, cy - 3 } })
    edgeStitch(c, m, P, { lit = LIT })
    return P
  end
  p.hauL = haunch("L", hdL); p.hauR = haunch("R", hdR)
  -- 8-9 hind legs and near paws
  local function hind(side, q)
    if q[5] == "u" then return end
    local hx = side == "L" and CX - 8 or CX + 8
    p["leg" .. "N" .. side] = c:part(c:line({ {hx, BY + 4}, {q[1], q[2]} }, 5), g, { cres = 2, gloss = false })
  end
  hind("L", hindL); hind("R", hindR)
  local function nearPaw(side, q)
    if q[5] == "u" then return end
    p["pawN" .. side] = paw(c, q[1], q[2], h, false, q[3], q[4])
    if q[5] == "p" then
      local cx, cy = q[1], q[2]
      c:paint({ "ppp", "ppp", "qqq" }, cx - 1, cy, { p = PINK, q = PINKS })
      c:px(cx - 2, cy - 2, PINK); c:px(cx, cy - 3, PINK); c:px(cx + 2, cy - 2, PINK)
    end
  end
  nearPaw("L", hindL); nearPaw("R", hindR)
  -- 10 tail: question-mark hook on the right
  local tp = { {33, BY - 6}, {40, BY - 7}, {46, BY - 10}, {50 + T.s[1], BY - 14 + T.ty}, {48 + T.s[2], BY - 19 + T.ty} }
  local tail = c:line({ tp[1], tp[2], tp[3] }, 5):add(c:line({ tp[3], tp[4], tp[5] }, 4))
  p.tail = c:part(tail, g, { cres = 2, gloss = false })
  local tip = tp[5]
  tailTip(c, tail, c:rect(tip[1] - 3, tip[2] - 3, tip[1] + 3, tip[2] + 3), { {tip[1] - 3, tip[2] + 2}, {tip[1] + 2, tip[2] + 2} })
  -- 11 stitch
  edgeStitch(c, rump, p.rump, { lit = LIT, ymax = BY }); edgeStitch(c, head, p.head, { lit = LIT })
  edgeStitch(c, backM, p.back, { lit = LIT })
  local I = { c = c, p = p, BY = BY, head = { ox, oy }, tip = tip,
    ears = { { ox + S.eL[1], oy + S.eL[2] }, { ox + S.eR[1], oy + S.eR[2] } },
    paws = { hindL = hindL, hindR = hindR, foreL = foreL, foreR = foreR },
    plant = { pawNL = hindL[2] == 53, pawNR = hindR[2] == 53, pawFFL = foreL[2] == 49, pawFFR = foreR[2] == 49 },
    plantRow = { pawNL = 55, pawNR = 55, pawFFL = 51, pawFFR = 51 }, bodyNames = { "rump" } }
  return c, p, I
end

local VIEWS = { toward = toward, away = away }
local NAMES = { "toward", "away" }
local order = { "outline", "legs-far", "tail", "body", "legs-near", "ears", "head+face" }

local function layerImages(c, p)
  local owner = {}
  for name, part in pairs(p) do owner[part] = LAYER_OF[name] end
  local imgs, pc = {}, app.pixelColor
  for _, n in ipairs(order) do imgs[n] = Image(64, 64, ColorMode.RGB); imgs[n]:clear(pc.rgba(0, 0, 0, 0)) end
  for k, hex in pairs(c.pix) do
    local x, y = c:xy(k)
    if c:inside(x, y) then
      local r, gg, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
      imgs[owner[c.own[k]] or "outline"]:putPixel(x, y, pc.rgba(r, gg, b, 255))
    end
  end
  return imgs
end
local function maskImage(c, p, names)
  local img, pc = Image(64, 64, ColorMode.RGB), app.pixelColor
  img:clear(pc.rgba(0, 0, 0, 0))
  local set = {}
  for _, n in ipairs(names) do if p[n] then set[p[n]] = true end end
  for k in pairs(c.pix) do
    local x, y = c:xy(k)
    if c:inside(x, y) and set[c.own[k]] then img:putPixel(x, y, pc.rgba(255, 255, 255, 255)) end
  end
  return img
end

local ok = true
local function chk(cond, msg) print((cond and "PASS " or "FAIL ") .. msg); if not cond then ok = false end end

for _, view in ipairs(NAMES) do
  print("=========== " .. view)
  local files, layerSets, checks, info = {}, {}, {}, {}
  for f = 1, 8 do
    local c, p, I = VIEWS[view](f)
    local name = string.format("cf-cat-grey-run%s%02d", view, f)
    local t = c:save(nil, OUT .. name .. ".png")
    checks[f], info[f] = t, I
    print(string.format("%s%02d ", view, f) .. GV.report(t))
    files[f] = OUT .. name .. ".png"
    layerSets[f] = layerImages(c, p)
    maskImage(c, p, { "earL", "earR" }):saveAs(string.format("%scf-ears-mask-run%s%02d.png", OUT, view, f))
    maskImage(c, p, { "tail" }):saveAs(string.format("%scf-tail-mask-run%s%02d.png", OUT, view, f))
  end
  local spr = Sprite(64, 64, ColorMode.RGB)
  for _ = 2, 8 do spr:newEmptyFrame() end
  spr.layers[1].name = order[1]
  for i = 2, #order do spr:newLayer().name = order[i] end
  for _, lname in ipairs(order) do
    local layer
    for _, l in ipairs(spr.layers) do if l.name == lname then layer = l end end
    for f = 1, 8 do spr:newCel(layer, spr.frames[f], layerSets[f][lname], Point(0, 0)) end
  end
  for f = 1, 8 do spr.frames[f].duration = FRAMEMS / 1000 end
  spr:saveAs(OUT .. "cf-run" .. view .. "-grey.aseprite")
  spr:close()
  local sheet = Image(512, 64, ColorMode.RGB)
  for f = 1, 8 do sheet:drawImage(Image{ fromFile = files[f] }, Point((f - 1) * 64, 0)) end
  local s2 = Sprite(512, 64, ColorMode.RGB)
  s2.cels[1].image = sheet
  s2:saveCopyAs(OUT .. "cf-run" .. view .. "-sheet.png")
  s2:close()

  -- ===== self-check =====
  local maxCol, minMargin, semi = 0, 99, 0
  for f = 1, 8 do maxCol = math.max(maxCol, checks[f].colours); minMargin = math.min(minMargin, checks[f].margin); semi = semi + checks[f].semi end
  chk(maxCol <= 16, view .. " colours max " .. maxCol .. " (as reported by GV.check; <=16)")
  chk(semi == 0, view .. " alpha only 0/255 (semi=" .. semi .. ")")
  chk(minMargin >= 3, view .. " margin min " .. minMargin)
  local extOK, extMsg = true, ""
  local plantOK, plantMsg = true, ""
  local cxs = {}
  for f = 1, 8 do
    local I = info[f]
    local gx0, gy0, gx1, gy1 = 99, 99, -1, -1
    for _, part in pairs(I.p) do
      local x0, y0, x1, y1 = part.m:bbox()
      if x0 then gx0 = math.min(gx0, x0); gy0 = math.min(gy0, y0); gx1 = math.max(gx1, x1); gy1 = math.max(gy1, y1) end
    end
    if gx0 < 6 or gy0 < 6 or gx1 > 57 or gy1 > 57 then extOK = false; extMsg = extMsg .. string.format(" F%d %d,%d..%d,%d", f, gx0, gy0, gx1, gy1) end
    for pn, pl in pairs(I.plant) do
      if pl and I.p[pn] then
        local _, _, _, y1 = I.p[pn].m:bbox()
        if y1 ~= I.plantRow[pn] then plantOK = false; plantMsg = plantMsg .. string.format(" F%d %s bottom=%d(want %d)", f, pn, y1, I.plantRow[pn]) end
      end
    end
    local x0, _, x1 = I.p[I.bodyNames[1]].m:bbox()
    cxs[f] = (x0 + x1) / 2
  end
  chk(extOK, view .. " felt extents inside x/y 6..57" .. extMsg)
  chk(plantOK, view .. " planted paws bottom rows" .. plantMsg)
  local same = true
  for f = 2, 8 do if cxs[f] ~= cxs[1] then same = false end end
  chk(same, view .. " body-mask centre x constant (" .. table.concat(cxs, ",") .. ")")
  -- joint deltas
  local function pts(I)
    local t = { head = I.head, tip = I.tip, earL = I.ears[1], earR = I.ears[2] }
    for k, q in pairs(I.paws) do t[k] = { q[1], q[2] } end
    return t
  end
  local function dmax(a, b)
    local A, B, m, who = pts(info[a]), pts(info[b]), 0, ""
    for k, q in pairs(A) do
      local d = math.max(math.abs(q[1] - B[k][1]), math.abs(q[2] - B[k][2]))
      if d > m then m = d; who = k end
    end
    return m, who
  end
  local worst, seam, per = 0, 0, {}
  for f = 1, 8 do
    local n = f % 8 + 1
    local d, who = dmax(f, n)
    per[#per + 1] = d .. "(" .. who .. ")"
    worst = math.max(worst, d)
    if f == 8 then seam = d end
  end
  chk(seam <= 2, view .. " loop seam F8->F1 max delta " .. seam)
  chk(worst <= 3, view .. " neighbour joint deltas max " .. worst .. " [" .. table.concat(per, " ") .. "]")
  -- tail tip top and part thickness
  local tmin = 99
  for f = 1, 8 do local _, y0 = info[f].p.tail.m:bbox(); tmin = math.min(tmin, y0) end
  print(view .. " tail felt top y min " .. tmin .. " (spec >= 14 for away)")
  local tipOK, tipMsg = true, ""
  for f = 1, 8 do
    local t = info[f].tip
    if view == "toward" and (t[1] < 51 or t[1] > 54) then tipOK = false; tipMsg = tipMsg .. " F" .. f .. " x" .. t[1] end
    if view == "away" and t[1] < 47 then tipOK = false; tipMsg = tipMsg .. " F" .. f .. " x" .. t[1] end
  end
  chk(tipOK, view .. " tail tip clear of head (toward x51..54, away x>=47)" .. tipMsg)
  if view == "away" then chk(tmin >= 14, "away tail felt top >= 14") end
end
print(ok and "ALL CHECKS PASS" or "SOME CHECKS FAILED")

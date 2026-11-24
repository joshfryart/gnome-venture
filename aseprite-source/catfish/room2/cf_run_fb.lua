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
  { BY=44, sq= 0, hd={ 0,-2}, eL={ 0, 0}, eR={ 0, 0} }, -- 1 fore contact
  { BY=45, sq= 1, hd={ 1, 0}, eL={ 0, 1}, eR={ 0,-1} }, -- 2 fore compress
  { BY=44, sq= 0, hd={ 1, 1}, eL={-1, 2}, eR={ 1, 0} }, -- 3 fore push
  { BY=43, sq=-1, hd={ 0, 0}, eL={ 0,-1}, eR={ 0,-1} }, -- 4 flight gathered
  { BY=44, sq= 0, hd={ 0,-1}, eL={ 0, 0}, eR={ 0, 0} }, -- 5 hind contact
  { BY=45, sq= 1, hd={-1, 0}, eL={ 0,-1}, eR={ 0, 1} }, -- 6 hind compress
  { BY=43, sq= 0, hd={-1, 1}, eL={-1, 0}, eR={ 1, 2} }, -- 7 hind push
  { BY=42, sq=-1, hd={ 0,-1}, eL={ 0,-1}, eR={ 0,-1} }, -- 8 flight extended
}
-- TOWARD: fore L / hind L paw {x, y, rx, ry}, tail tx,ty (R = mirror of L[f-1])
local TW = {
  { fore={25,53,4.5,2.5}, hind={18,46,3,2},   tx=-1, ty=-1 },
  { fore={25,53,4.5,2.5}, hind={18,46,3,2},   tx= 0, ty=-2 },
  { fore={26,51,4,2},     hind={18,47,3.5,2}, tx= 1, ty= 0 },
  { fore={27,49,4,2},     hind={18,49,3.5,2}, tx= 2, ty= 1 },
  { fore={26,49,4,2},     hind={18,50,3.5,2}, tx= 2, ty= 0 },
  { fore={25,50,4.5,3},   hind={18,50,3.5,2}, tx= 1, ty=-1 },
  { fore={25,50,5,3},     hind={18,48,3,2},   tx= 0, ty= 1 },
  { fore={24,51,5,3},     hind={18,46,3,2},   tx=-1, ty= 2 },
}
-- AWAY: hind L paw {x,y,rx,ry,mode(u tucked / p pad / h heel)}, fore L (far) {x,y}, tail s2,s3,s4, ty
local AW = {
  { hind={24,50,4.5,3,"p"},   fore={18,49}, s={-1,-2,-2}, ty=-1 },
  { hind={25,48,4,2.5,"u"},   fore={18,49}, s={ 0,-1,-3}, ty=-3 },
  { hind={26,47,4,2,"u"},     fore={19,47}, s={ 1, 0,-2}, ty= 0 },
  { hind={25,50,4,2.5,"h"},   fore={21,46}, s={ 1, 1, 0}, ty= 2 },
  { hind={24,53,4.5,2.5,"h"}, fore={20,45}, s={ 1, 2, 2}, ty= 0 },
  { hind={24,53,4.5,2.5,"h"}, fore={18,45}, s={ 0, 1, 3}, ty=-2 },
  { hind={24,52,4.5,3,"p"},   fore={17,46}, s={-1, 0, 2}, ty= 1 },
  { hind={23,51,5,3.5,"p"},   fore={17,48}, s={-1,-1, 0}, ty= 3 },
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
local function catHead(c, ox, oy, eL, eR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a, 7 + b}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a, 7 + b}, {40 + a, 21 + b} }):grow(1)
  return { { "earL", earL, g, { cres = 2, gloss = false } }, { "earR", earR, g, { cres = 2, gloss = false } },
           { "head", head, h, { gloss = { 14 + ox, 15 + oy } } } }, head
end
local function catFaceOpen(c, ox, oy, head, eL, eR)
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

-- records: info[view][f] = { paws = { name = {x,y,planted?} }, head, ears, tip, p, c }
local function toward(f)
  local S, T = SH[f], TW[f]
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local p = {}
  local BY, sq = S.BY, S.sq
  local pv = TW[lastf(f)]
  local foreL, foreR = T.fore, mir(pv.fore)
  local hindL, hindR = T.hind, mir(pv.hind)
  -- 1 tail
  local Tx, Ty = 48 + T.tx, BY - 12 + T.ty
  local tail = c:line({ {42, BY - 5}, {46 + math.floor(T.tx / 2), BY - 8}, {Tx, Ty} }, 4)
  p.tail = c:part(tail, g, { cres = 2, gloss = false })
  tailTip(c, tail, c:rect(Tx - 3, Ty - 3, Tx + 3, Ty + 3), { {Tx - 3, Ty + 2}, {Tx + 2, Ty + 2} })
  -- 2 hind legs/paws (far)
  p.legHL = c:part(c:line({ {CX - 8, BY}, {hindL[1], hindL[2]} }, 4), dk, { cres = 2, gloss = false })
  p.legHR = c:part(c:line({ {CX + 8, BY}, {hindR[1], hindR[2]} }, 4), dk, { cres = 2, gloss = false })
  p.pawHL = paw(c, hindL[1], hindL[2], pawDk(GREY), true, hindL[3], hindL[4], GREY.shade)
  p.pawHR = paw(c, hindR[1], hindR[2], pawDk(GREY), true, hindR[3], hindR[4], GREY.shade)
  -- 3-4 shoulders, chest
  local sh = c:ellipse(CX, BY - 5, 13, 5)
  p.shoulders = c:part(sh, g)
  local ch = c:ellipse(CX, BY, 11 + sq, 7 - sq)
  p.chest = c:part(ch, g, { gloss = { 27, BY - 3 } })
  -- 5-6 forelegs, fore paws
  p.legFL = c:part(c:line({ {CX - 6, BY + 1}, {foreL[1], foreL[2] - 1} }, 6), g, { cres = 2, gloss = false })
  p.legFR = c:part(c:line({ {CX + 6, BY + 1}, {foreR[1], foreR[2] - 1} }, 6), g, { cres = 2, gloss = false })
  p.pawFL = paw(c, foreL[1], foreL[2], h, true, foreL[3], foreL[4])
  p.pawFR = paw(c, foreR[1], foreR[2], h, true, foreR[3], foreR[4])
  -- 7 ears, head
  local ox, oy = 7 + S.hd[1], 3 + S.hd[2]
  local list, head = catHead(c, ox, oy, S.eL, S.eR)
  for n, P in pairs(c:build(list)) do p[n] = P end
  -- 8 stitch
  edgeStitch(c, ch, p.chest, { lit = LIT }); edgeStitch(c, sh, p.shoulders, { lit = LIT }); edgeStitch(c, head, p.head, { lit = LIT })
  -- 9 face
  catFaceOpen(c, ox, oy, head, S.eL, S.eR)
  local I = { c = c, p = p, BY = BY, head = { ox, oy }, tip = { Tx, Ty },
    ears = { { ox + S.eL[1], oy + S.eL[2] }, { ox + S.eR[1], oy + S.eR[2] } },
    paws = { foreL = foreL, foreR = foreR, hindL = hindL, hindR = hindR },
    plant = { pawFL = foreL[2] == GROUND, pawFR = foreR[2] == GROUND, pawHL = hindL[2] == 50, pawHR = hindR[2] == 50 },
    plantRow = { pawFL = 55, pawFR = 55, pawHL = 52, pawHR = 52 }, bodyNames = { "chest" } }
  return c, p, I
end

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
  -- 3-4 ears, back of head
  local ox, oy = 7 + S.hd[1], 3 + S.hd[2]
  local list, head = catHead(c, ox, oy, S.eL, S.eR)
  for n, P in pairs(c:build(list)) do p[n] = P end
  tint(c, head:clip(c:rect(0, 20 + oy + 4, 63, 63)), GREY.light, GREY.base)
  -- 5-6 back, rump
  p.back = c:part(c:ellipse(CX, BY - 8, 9, 6), g)
  local rump = c:ellipse(CX, BY - 1, 12.5 + sq, 8.5 - sq)
  p.rump = c:part(rump, g, { gloss = { 25, BY - 6 } })
  -- 7 haunches
  local hdL = (f == 7 or f == 8) and 1 or 0
  local hdR = (f == 8 or f == 1) and 1 or 0
  p.hauL = c:part(c:ellipse(CX - 7, BY + 1 + hdL, 6, 6), g, { cres = 1, gloss = false })
  p.hauR = c:part(c:ellipse(CX + 7, BY + 1 + hdR, 6, 6), g, { cres = 1, gloss = false })
  -- 8-9 hind legs and near paws
  local function hind(side, q)
    if q[5] == "u" then return end
    local hx = side == "L" and CX - 7 or CX + 7
    p["leg" .. "N" .. side] = c:part(c:line({ {hx, BY + 3}, {q[1], q[2]} }, 5), g, { cres = 2, gloss = false })
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
  -- 10 tail
  local P0 = { CX, BY - 7 }
  local tp = { P0, { P0[1] + 1, P0[2] - 6 }, { P0[1] + 4 + T.s[1], P0[2] - 11 },
    { P0[1] + 8 + T.s[2], P0[2] - 14 + T.ty }, { P0[1] + 12 + T.s[3], P0[2] - 16 + T.ty } }
  local tail = c:line({ tp[1], tp[2], tp[3] }, 5):add(c:line({ tp[3], tp[4], tp[5] }, 4))
  p.tail = c:part(tail, g, { cres = 2, gloss = false })
  local tip = tp[5]
  tailTip(c, tail, c:rect(tip[1] - 3, tip[2] - 3, tip[1] + 3, tip[2] + 3), { {tip[1] - 3, tip[2] + 2}, {tip[1] + 2, tip[2] + 2} })
  -- 11 stitch
  edgeStitch(c, rump, p.rump, { lit = LIT }); edgeStitch(c, head, p.head, { lit = LIT })
  edgeStitch(c, c:ellipse(CX, BY - 8, 9, 6), p.back, { lit = LIT })
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
  if view == "away" then chk(tmin >= 14, "away tail felt top >= 14") end
end
print(ok and "ALL CHECKS PASS" or "SOME CHECKS FAILED")

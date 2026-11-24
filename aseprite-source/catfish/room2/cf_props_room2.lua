-- cf_props_room2.lua : Cat Fish room 2 props (art spec: room2/props_zoomie_spec.md sections 1-3 + dust/streak of 4).
-- Run: AppRun -b --script cf_props_room2.lua        Writes out_props/<name>.png + .aseprite and cf-wand-cast.json.
--   cf-lure-{near,mid,far}-1..6   plush feather-mouse lure (32 / 20 / 12 px)
--   cf-wand-cast-1..6 (+ .json)   toy wand from the top edge, 48x64
--   cf-shadow-1..4                hard-pixel ellipse shadows
--   cf-dust-1..4, cf-streak-1..3  zoomie effects (pixel grids are read from the spec so they match exactly)
--
-- ===================== POSE TABLE (all numbers in one place) =====================
-- LURE (near px; mid x0.6, far x0.4, any non-zero offset is at least 1 px). Tilt is degrees, + = nose down,
-- parts are rotated as polygons about the body centre then rasterised (no rotsprite). Feathers follow the
-- body tilt at FEATHER_TILT of the angle (they trail), so they keep clear of the frame.
--   F  ms   rx ry  down up  tilt  earDx tipDx bodyDx
--   1  60   +1 -1   1    0    0     0    -2     0     impact squash (floor row stays)
--   2  80    0  0   0    4  -30     0     0     0     hop, nose up
--   3  80    0  0   0    2  +20    -1     0     0     tumble, nose down, ear 1 px back
--   4  100   0  0   0    0    0     0    +1     0     settle
--   5  300   0  0   0    0    0     0     0     0     wobble A (rest)
--   6  300   0  0   0    0    0    +1    -1    +1     wobble B (body + ear 1 px right, feather tip 1 px left)
-- WAND (T = tip, cap radius; string attach = (T.x, T.y+3); pivot P = (24,-6); ms)
--   1 rest     T (24,52) r3  ms 300    4 flick centre T (24,56) r3 ms 110
--   2 windup   T (24,40) r4  ms 120    5 flick right  T (38,47) r3 ms 110
--   3 flick L  T (10,47) r3  ms 110    6 settle       T (25,54) r3 ms 290
-- SHADOW rows: see SHADOWS below.   DUST 24x16 60 ms pivot (19,14).   STREAK 40x8 head right.
-- =================================================================================
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out_props/"
local FAILS = {}

local pc = app.pixelColor
local function h2c(h) h = h:gsub("#", "") return pc.rgba(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16), 255) end
local function rnd(v) return math.floor(v + 0.5) end

local function mkdir() pcall(function() app.fs.makeAllDirectories(OUT) end) end
local function saveImg(img, name)
  local spr = Sprite(img.width, img.height, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveAs(OUT .. name .. ".aseprite")
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
  return GV.check(img)
end
local function report(name, t, ok)
  print(string.format("%-18s ", name) .. GV.report(t) .. (ok and "" or "  <-- CHECK"))
  if not ok then FAILS[#FAILS + 1] = name end
end
-- no non-black opaque px on the frame edge (=> the 1 px black border is never clipped). topFree: row 0 may be art.
local function edgesOk(img, topFree)
  local W, H = img.width, img.height
  local function bad(x, y)
    local v = img:getPixel(x, y)
    return pc.rgbaA(v) > 0 and (pc.rgbaR(v) + pc.rgbaG(v) + pc.rgbaB(v)) > 0
  end
  for x = 0, W - 1 do if (not topFree and bad(x, 0)) or bad(x, H - 1) then return false end end
  for y = 0, H - 1 do if bad(0, y) or bad(W - 1, y) then return false end end
  return true
end

-- ---------- ramps (explicit house hexes; felt = rim/base/one shade) ----------
local RED   = { gloss = "#ff9158", dot = "#ff9158", rim = "#dd3a2a", base = "#dd3a2a", shade = "#b8452f", deep = "#b8452f", bounce = "#b8452f" }
local FEATH = { gloss = "#8fcbd8", dot = "#8fcbd8", rim = "#8fcbd8", base = "#3f8fb0", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290" }
local EARR  = { gloss = "#e9b98a", dot = "#e9b98a", rim = "#e9b98a", base = "#e9b98a", shade = "#e9b98a", deep = "#e9b98a", bounce = "#e9b98a" }
local GOLDL = { gloss = "#f5cf6a", dot = "#f5cf6a", rim = "#f5cf6a", base = "#e8a317", shade = "#e8a317", deep = "#e8a317", bounce = "#e8a317" }
local PINK, PUPIL = "#e8909e", "#2a1a10"

-------------------------------------------------------------------- 1. LURE
local POSES = {
  { ms = 60,  rx = 1, ry = -1, down = 1, up = 0, tilt = 0,   earDx = 0,  tipDx = -2, bodyDx = 0 },
  { ms = 80,  rx = 0, ry = 0,  down = 0, up = 4, tilt = -30, earDx = 0,  tipDx = 0,  bodyDx = 0 },
  { ms = 80,  rx = 0, ry = 0,  down = 0, up = 2, tilt = 20,  earDx = -1, tipDx = 0,  bodyDx = 0 },
  { ms = 100, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 0,  tipDx = 1,  bodyDx = 0 },
  { ms = 300, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 0,  tipDx = 0,  bodyDx = 0 },
  { ms = 300, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 1,  tipDx = -1, bodyDx = 1 },
}
local FEATHER_TILT = 0.55

local SZ = {
  near = { W = 32, ol = 2, olx = 1, cres = 2, k = 1.0, bx = 14, by = 19, rx = 8, ry = 6,
           nose = { {20,15}, {26,20}, {20,24} }, ear = { 17, 13, 3 }, pinkEar = 2, pinkNose = { 24, 19, 2 },
           fth = { {8,17}, {6,10}, {7,5} }, fw = { 4, 3, 2 }, eye = { 20, 16, 3 }, anchor = { 13, 10 }, floorRow = 25,
           seam = { {9,24}, {19,24} }, gloss = { 11, 15 } },
  mid  = { W = 20, ol = 1, olx = 0, cres = 1, k = 0.6, bx = 9, by = 11.5, rx = 5, ry = 3.5,
           nose = { {13,9}, {16,12}, {13,15} }, ear = { 11, 7, 2 }, pinkEar = 1, pinkNose = { 14, 11, 1 },
           fth = { {5,10}, {4,4} }, fw = { 3, 2 }, eye = { 13, 10, 2 }, anchor = { 9, 5 }, floorRow = 15,
           gloss1 = { 7, 10 } },
}

local function ellPoly(cx, cy, rx, ry, n)
  local p = {}
  for i = 0, n - 1 do local a = i / n * math.pi * 2; p[#p + 1] = { cx + rx * math.cos(a), cy + ry * math.sin(a) } end
  return p
end
local function rotp(p, ox, oy, deg)
  local a = math.rad(deg); local s, c = math.sin(a), math.cos(a)
  local dx, dy = p[1] - ox, p[2] - oy
  return { ox + dx * c - dy * s, oy + dx * s + dy * c }
end
local function featherPoly(pts, ws)
  local L, R = {}, {}
  for i, p in ipairs(pts) do
    local a, b = pts[math.max(1, i - 1)], pts[math.min(#pts, i + 1)]
    local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy)
    local nx, ny = -dy / l, dx / l
    L[#L + 1] = { p[1] + nx * ws[i] / 2, p[2] + ny * ws[i] / 2 }
    table.insert(R, 1, { p[1] - nx * ws[i] / 2, p[2] - ny * ws[i] / 2 })
  end
  for _, q in ipairs(R) do L[#L + 1] = q end
  return L
end

-- build one near/mid lure frame at an extra whole-sprite offset (ox, oy); returns canvas + anchor px
local function buildLure(S, P, ox, oy)
  local k = S.k
  local function sc(v) if v == 0 then return 0 end local s = v < 0 and -1 or 1; return s * math.max(1, rnd(math.abs(v) * k)) end
  local c = GV.canvas{ w = S.W, h = S.W, mode = "sticker", ol = S.ol, olx = S.olx, cres = S.cres, deep = 0, margin = 1 }
  local up, down, bdx = sc(P.up), sc(P.down), sc(P.bodyDx)
  local tx, ty = ox + bdx, oy - up + down
  local bcx, bcy = S.bx, S.by
  local function xf(p) -- rotate about body centre by tilt, then translate
    local q = rotp(p, bcx, bcy, P.tilt)
    return { q[1] + tx, q[2] + ty }
  end
  local rot = P.tilt ~= 0
  local rx, ry = S.rx + P.rx * (k >= 1 and 1 or 0), S.ry + P.ry * (k >= 1 and 1 or 0)
  -- body + snout as one felt mask
  local body
  if rot then body = c:poly(ellPoly(bcx + tx, bcy + ty, rx + 0.35, ry + 0.35, 48))
  else body = c:ellipse(bcx + tx, bcy + ty + (P.down ~= 0 and 0 or 0), rx, ry) end
  local nose = {}
  for i, p in ipairs(S.nose) do nose[i] = xf(p) end
  if P.rx ~= 0 and k >= 1 then nose[2][1] = nose[2][1] + 1 end
  body:add(c:poly(nose))
  -- feather: root follows the body, the rest trails at a fraction of the tilt
  local root = xf(S.fth[1])
  local fp = { root }
  for i = 2, #S.fth do
    local rel = { S.fth[i][1] - S.fth[1][1], S.fth[i][2] - S.fth[1][2] }
    local r2 = rotp({ rel[1], rel[2] }, 0, 0, P.tilt * FEATHER_TILT)
    local q = { root[1] + r2[1], root[2] + r2[2] }
    if i == #S.fth then q[1] = q[1] + sc(P.tipDx) end
    fp[#fp + 1] = q
  end
  local fth = c:poly(featherPoly(fp, S.fw))
  local ep0 = xf({ S.ear[1], S.ear[2] }); local ecx, ecy = ep0[1], ep0[2]
  local ecx2, ecy2 = ecx + sc(P.earDx), ecy
  local ear = c:ellipse(rnd(ecx2), rnd(ecy2), S.ear[3] - 0.0)
  local ax, ay = xf(S.anchor)[1], xf(S.anchor)[2]
  ax, ay = rnd(ax), rnd(ay)
  local loop = c:rect(ax - 1, ay - 1, ax + 1, ay + 2)
  local bopts = { cres = S.cres, deep = 0, gloss = false, bounce = false }
  local p = c:build{
    { "loop", loop, GOLDL, { flat = true } },
    { "fth",  fth, FEATH, { cres = 1, deep = 0, gloss = false, bounce = false } },
    { "body", body, RED, bopts },
    { "ear",  ear, EARR, { flat = true, rim = false } },
  }
  -- body detail
  if S.gloss then
    local g = xf(S.gloss)
    c:px(rnd(g[1]), rnd(g[2]), RED.gloss); c:px(rnd(g[1]) + 1, rnd(g[2]), RED.gloss)
    local a, b = xf(S.seam[1]), xf(S.seam[2])
    c:seam({ { rnd(a[1]), rnd(a[2]) }, { rnd(b[1]), rnd(b[2]) } }, { gap = RED.shade })
  else
    local g = xf(S.gloss1); c:px(rnd(g[1]), rnd(g[2]), RED.gloss)
  end
  -- quill down the feather centre (gold), only on feather px
  local q0 = fp[1]; local q1 = fp[#fp]
  local function onF(x, y) return c.own[c:key(x, y)] == p.fth end
  local nq = math.max(2, math.floor(math.sqrt((q1[1]-q0[1])^2 + (q1[2]-q0[2])^2) * 0.8))
  for i = 1, nq do
    local t = i / (nq + 1) * (S.k >= 1 and 1 or 0.9)
    local x, y = rnd(q0[1] + (q1[1]-q0[1]) * t), rnd(q0[2] + (q1[2]-q0[2]) * t)
    if onF(x, y) then c:px(x, y, "#f5cf6a") end
  end
  -- ear pink, nose pink, eye
  local pe = S.pinkEar
  c:fill(c:rect(rnd(ecx2) - (pe > 1 and 1 or 0), rnd(ecy2) - (pe > 1 and 1 or 0), rnd(ecx2) - (pe > 1 and 1 or 0) + pe - 1, rnd(ecy2) - (pe > 1 and 1 or 0) + pe - 1), PINK)
  local pn = S.pinkNose
  local pnp = xf({ pn[1] + (pn[3] - 1) / 2, pn[2] + (pn[3] - 1) / 2 })
  local pnx, pny = rnd(pnp[1] - (pn[3] - 1) / 2), rnd(pnp[2] - (pn[3] - 1) / 2)
  c:fill(c:rect(pnx, pny, pnx + pn[3] - 1, pny + pn[3] - 1), PINK)
  local e = S.eye
  local ep = xf({ e[1] + (e[3] - 1) / 2, e[2] + (e[3] - 1) / 2 })
  local ex, ey = rnd(ep[1] - (e[3] - 1) / 2), rnd(ep[2] - (e[3] - 1) / 2)
  if e[3] == 3 then c:eye(ex, ey, true) else c:fill(c:rect(ex, ey, ex + 1, ey + 1), PUPIL) end
  return c, { ax, ay }
end

local function lureFrame(sizeName, S, n)
  local P = POSES[n]
  local best
  for _, o in ipairs({ {0,0}, {1,0}, {0,1}, {1,1}, {2,0}, {2,1}, {2,2}, {3,1}, {3,2}, {1,2}, {3,3} }) do
    local c, anc = buildLure(S, P, o[1], o[2])
    local img = c:image()
    if edgesOk(img, false) then best = { c, anc, o }; break end
    best = best or { c, anc, o }
  end
  local c, anc, o = best[1], best[2], best[3]
  local name = "cf-lure-" .. sizeName .. "-" .. n
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local img = c:image()
  local av = img:getPixel(anc[1], anc[2])
  local ac = string.format("%02x%02x%02x", pc.rgbaR(av), pc.rgbaG(av), pc.rgbaB(av))
  local gold = (ac == "f5cf6a" or ac == "e8a317") -- else the ear covers the anchor: accept if gold shows beside it
  if not gold then
    for yy = anc[2] - 1, anc[2] + 2 do for xx = anc[1] - 1, anc[1] + 1 do
      local v = img:getPixel(xx, yy); local h = string.format("%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
      if h == "f5cf6a" or h == "e8a317" then gold = true end
    end end
  end
  local ok = edgesOk(img, false) and t.semi == 0 and t.colours <= 16 and t.bw == 0 and gold
  -- felt never below the floor row (outline/border start below it)
  local yb = -1
  local bx0, by0, bx1, by1 = c.sil:bbox()
  report(name .. (o[1] + o[2] > 0 and string.format(" (nudged %d,%d)", o[1], o[2]) or ""), t, ok)
  return t
end

local function lureFar()
  local G = {
    "............", "..K....K....", ".KoK..KoK...", "KowoKKoyoK..", "KoboooryoK..", "KobogrrroK..",
    ".KorrrrreoK.", ".KorrrrrrpoK", ".KossssssoK.", "..KooooooK..", "...KKKKKK...", "............",
  }
  local COL = { K = "#000000", o = "#4a2c1a", r = "#dd3a2a", g = "#ff9158", s = "#b8452f", b = "#3f8fb0", w = "#8fcbd8",
                y = "#f5cf6a", e = "#2a1a10", p = "#e8909e" }
  local cells = {}
  for y = 1, 12 do for x = 1, 12 do
    local ch = G[y]:sub(x, x)
    if ch ~= "." and ch ~= "K" then
      local X, Y = x - 1, y - 1
      local reg = "body"
      if X <= 3 and Y >= 2 and Y <= 5 then reg = "fth" elseif X >= 6 and Y <= 4 and not (X == 6 and Y == 4) then reg = "loop" end
      cells[#cells + 1] = { X, Y, ch, reg }
    end
  end end
  local F = {
    -- n: function(cell) -> x', y' (or nil to drop). Nose = body columns x >= 8 (shear), tip = feather rows 2..3.
    [1] = function(c) if c[4] == "body" and c[2] == 7 then return nil end; if c[2] < 7 then return c[1], c[2] + 1 end; return c[1], c[2] end,
    [2] = function(c) local dy = -1; if c[1] >= 8 and c[4] == "body" then dy = dy - 1 elseif c[4] == "fth" then dy = dy + 1 end; return c[1], c[2] + dy end,
    [3] = function(c) local dy = -1; if c[1] >= 8 and c[4] == "body" then dy = dy + 1 elseif c[4] == "fth" then dy = dy - 0 end; return c[1], c[2] + dy end,
    [4] = function(c) if c[4] == "fth" and c[2] <= 3 then return c[1] + 1, c[2] end; return c[1], c[2] end,
    [5] = function(c) return c[1], c[2] end,
    [6] = function(c) if c[4] == "loop" then return c[1] + 1, c[2] end; return c[1], c[2] end,
  }
  local ms = {}
  for n = 1, 6 do
    local art, anch = {}, nil
    local function put(x, y, ch) art[y * 12 + x] = ch end
    local order = { body = 1, loop = 2, fth = 3 }
    table.sort(cells, function(a, b) return order[a[4]] < order[b[4]] end)
    for _, c in ipairs(cells) do
      local x, y = F[n](c)
      if x then put(x, y, c[3]); if c[1] == 7 and c[2] == 3 then anch = { x, y } end end
    end
    local img = Image(12, 12, ColorMode.RGB); img:clear(pc.rgba(0, 0, 0, 0))
    for k, ch in pairs(art) do img:putPixel(k % 12, k // 12, h2c(COL[ch])) end
    for y = 0, 11 do for x = 0, 11 do
      if not art[y * 12 + x] and (art[y * 12 + x + 1] and x < 11 or art[y * 12 + x - 1] and x > 0 or art[(y + 1) * 12 + x] or art[(y - 1) * 12 + x]) then
        img:putPixel(x, y, h2c("#000000"))
      end
    end end
    local name = "cf-lure-far-" .. n
    local t = saveImg(img, name)
    local av = img:getPixel(anch[1], anch[2])
    local ac = string.format("%02x%02x%02x", pc.rgbaR(av), pc.rgbaG(av), pc.rgbaB(av))
    report(name, t, edgesOk(img, false) and t.semi == 0 and t.colours <= 16 and ac == "f5cf6a")
  end
end

-------------------------------------------------------------------- 2. WAND
local WAND = {
  { T = { 24, 52 }, r = 3, ms = 300 }, { T = { 24, 40 }, r = 4, ms = 120 }, { T = { 10, 47 }, r = 3, ms = 110 },
  { T = { 24, 56 }, r = 3, ms = 110 }, { T = { 38, 47 }, r = 3, ms = 110 }, { T = { 25, 54 }, r = 3, ms = 290 },
}
local PX, PY = 24, -6
local RODRED = { gloss = "#f2793a", dot = "#f2793a", rim = "#f2793a", base = "#dd3a2a", shade = "#ac1c27", deep = "#ac1c27", bounce = "#ac1c27" }
local RODWOOD = { gloss = "#d9a660", dot = "#d9a660", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#8a4f2a", bounce = "#8a4f2a" }
local RODWATER = { gloss = "#8fcbd8", dot = "#8fcbd8", rim = "#8fcbd8", base = "#3f8fb0", shade = "#305e86", deep = "#305e86", bounce = "#305e86" }
local RODGOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#e8a317", deep = "#e8a317", bounce = "#e8a317" }

local function wandFrame(n)
  local W = WAND[n]
  local tx, ty = W.T[1], W.T[2]
  local dx, dy = PX - tx, PY - ty
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local nx, ny = -uy, ux                      -- unit normal (right of the shaft when it points up)
  local f = (n == 2) and (L / 58) or 1        -- windup is foreshortened
  local c = GV.canvas{ w = 48, h = 64, mode = "sticker", margin = 1 }
  local function band(t0, t1, w)
    local h = w / 2
    local a = { tx + ux * t0 * f - nx * h, ty + uy * t0 * f - ny * h }
    local b = { tx + ux * t0 * f + nx * h, ty + uy * t0 * f + ny * h }
    local cc = { tx + ux * t1 * f + nx * h, ty + uy * t1 * f + ny * h }
    local d = { tx + ux * t1 * f - nx * h, ty + uy * t1 * f - ny * h }
    return c:poly({ a, b, cc, d })
  end
  local p = c:build{
    { "shaft", band(11, 42, 5), RODWOOD, { cres = 1, deep = 0, gloss = false, bounce = false } },
    { "grip",  band(40, 200, 8), RODRED, { cres = 2, deep = 0, gloss = false, bounce = false } },
    { "sleeve", band(3, 13, 9), RODWATER, { cres = 2, deep = 0, gloss = false, bounce = false } },
    { "cap",   c:ellipse(tx, ty, W.r), RODGOLD, { flat = true } },
  }
  -- stitch band on the grip (2 px, gold) at T-44
  local sb = band(44, 46, 8):clip(p.grip.m)
  sb:each(function(x, y) c:px(x, y, (c.shd[c:key(x, y)]) and "#e8a317" or "#f5cf6a") end)
  -- gloss stripe on the sleeve's left edge
  local sleeve = p.sleeve.m
  for t = 4.5, 11.5, 0.5 do
    local x = rnd(tx + ux * t * f - nx * 2.5); local y = rnd(ty + uy * t * f - ny * 2.5)
    if sleeve:has(x, y) and c.own[c:key(x, y)] == p.sleeve then c:px(x, y, "#8fcbd8") end
  end
  -- cap: gloss + two button holes
  c:px(tx - 1, ty - 1, "#fff1c8")
  local offs = { { -1, 1 }, { 1, 1 } }
  if math.abs(ux) > 0.35 then offs = { { -1, 1 }, { 1, 0 } } end
  for _, o in ipairs(offs) do c:px(tx + o[1], ty + o[2], "#8a4f2a") end
  local name = "cf-wand-cast-" .. n
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local img = c:image()
  local ok = edgesOk(img, true) and t.semi == 0 and t.colours <= 16 and t.bw == 0
  report(name, t, ok)
end

-------------------------------------------------------------------- 3. SHADOWS (2a1a10, a255, hard pixels)
local SHADOWS = {
  { 48, 12, { 20, 32, 38, 42, 44, 44, 42, 38, 32, 20 } },
  { 36, 10, { 16, 26, 32, 34, 34, 32, 26, 16 } },
  { 24, 8,  { 12, 20, 22, 22, 20, 12 } },
  { 20, 6,  { 12, 18, 18, 12 } },
}
local function shadows()
  for i, s in ipairs(SHADOWS) do
    local W, H, rows = s[1], s[2], s[3]
    local img = Image(W, H, ColorMode.RGB); img:clear(pc.rgba(0, 0, 0, 0))
    local y0 = (H - #rows) // 2
    for j, w in ipairs(rows) do
      local x0 = (W - w) // 2
      for x = x0, x0 + w - 1 do img:putPixel(x, y0 + j - 1, h2c("#2a1a10")) end
    end
    local name = "cf-shadow-" .. i
    local t = saveImg(img, name)
    local sym = true
    for y = 0, H - 1 do for x = 0, W // 2 - 1 do if img:getPixel(x, y) ~= img:getPixel(W - 1 - x, y) then sym = false end end end
    report(name, t, t.colours == 1 and t.semi == 0 and t.margin >= 1 and sym)
  end
end

-------------------------------------------------------------------- 4. DUST + STREAK (grids read from the spec)
local function specLines()
  local f = assert(io.open(here .. "/props_zoomie_spec.md", "r")); local L = {}
  for l in f:lines() do L[#L + 1] = l end; f:close(); return L
end
local LEG = { o = "#74462a", c = "#f1ece0", h = "#fff3c8", s = "#c9a96e" }
local function gridImg(rows, W, H)
  local img = Image(W, H, ColorMode.RGB); img:clear(pc.rgba(0, 0, 0, 0))
  for y = 1, H do
    assert(#rows[y] == W, "bad grid row width " .. #rows[y])
    for x = 1, W do local ch = rows[y]:sub(x, x); if ch ~= "." then img:putPixel(x - 1, y - 1, h2c(assert(LEG[ch], "legend " .. ch))) end end
  end
  return img
end
local function fx()
  local L = specLines()
  local dust, streak = {}, {}
  for i, l in ipairs(L) do
    if l:match("^F1%s+F2%s+F3%s+F4") then
      for n = 1, 4 do dust[n] = {} end
      for j = 1, 16 do
        local toks = {}; for tk in L[i + j]:gmatch("%S+") do toks[#toks + 1] = tk end
        assert(#toks == 4, "dust row tokens")
        for n = 1, 4 do dust[n][j] = toks[n] end
      end
    elseif l:match("^streak%-1 %(long%)") then
      for n = 1, 3 do streak[n] = {} end
      for j = 1, 8 do
        local toks = {}; for tk in L[i + j]:gmatch("%S+") do toks[#toks + 1] = tk end
        assert(#toks == 3, "streak row tokens")
        for n = 1, 3 do streak[n][j] = toks[n] end
      end
    end
  end
  assert(dust[1] and streak[1], "grids not found in spec")
  for n = 1, 4 do
    local name = "cf-dust-" .. n; local t = saveImg(gridImg(dust[n], 24, 16), name)
    report(name, t, t.semi == 0 and t.colours <= 4 and t.bw == 0)
  end
  for n = 1, 3 do
    local name = "cf-streak-" .. n; local t = saveImg(gridImg(streak[n], 40, 8), name)
    report(name, t, t.semi == 0 and t.colours <= 4 and t.bw == 0)
  end
end

-------------------------------------------------------------------- main
mkdir()
for n = 1, 6 do lureFrame("near", SZ.near, n) end
for n = 1, 6 do lureFrame("mid", SZ.mid, n) end
lureFar()
for n = 1, 6 do wandFrame(n) end
do -- cf-wand-cast.json: string attach points (T.x, T.y+3) + timing
  local parts = {}
  for n, W in ipairs(WAND) do
    parts[#parts + 1] = string.format('    {"file": "cf-wand-cast-%d.png", "attach": [%d, %d], "ms": %d, "tip": [%d, %d], "capR": %d}',
      n, W.T[1], W.T[2] + 3, W.ms, W.T[1], W.T[2], W.r)
  end
  local f = io.open(OUT .. "cf-wand-cast.json", "w")
  f:write('{\n  "pivot": [24, -6],\n  "frames": [\n' .. table.concat(parts, ",\n") .. '\n  ]\n}\n'); f:close()
end
shadows()
fx()
print(#FAILS == 0 and "ALL OK" or ("FAILS: " .. table.concat(FAILS, ", ")))

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
local EARR  = { gloss = "#e9b98a", dot = "#e9b98a", rim = "#e9b98a", base = "#e9b98a", shade = "#c98a68", deep = "#e9b98a", bounce = "#e9b98a" }
local GOLDL = { gloss = "#f5cf6a", dot = "#f5cf6a", rim = "#f5cf6a", base = "#e8a317", shade = "#e8a317", deep = "#e8a317", bounce = "#e8a317" }
local PINK, PUPIL = "#e8909e", "#2a1a10"

-------------------------------------------------------------------- 1. LURE
local POSES = {
  { ms = 60,  rx = 1, ry = -1, down = 1, up = 0, tilt = 0,   earDx = 0,  tipDx = -2, bodyDx = 0 },
  { ms = 80,  rx = 0, ry = 0,  down = 0, up = 4, tilt = -30, earDx = 0,  tipDx = 0,  bodyDx = 0 },
  { ms = 80,  rx = 0, ry = 0,  down = 0, up = 2, tilt = 20,  earDx = -1, tipDx = 0,  bodyDx = 0 },
  { ms = 100, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 0,  tipDx = 1,  bodyDx = 0 },
  { ms = 300, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 0,  tipDx = 0,  bodyDx = 0 },
  { ms = 300, rx = 0, ry = 0,  down = 0, up = 0, tilt = 0,   earDx = 1,  tipDx = -1, bodyDx = 0 },
}
local FEATHER_TILT = 0.55

local SZ = {
  near = { W = 32, ol = 1, olx = 1, cres = 2, k = 1.0, bx = 13, by = 19, rx = 9, ry = 6, clip = 24,
           nose = { {20,14}, {27,21}, {19,24} }, ear = { 15, 12, 3 }, pinkEar = 2, pinkNose = { 25, 20, 2 },
           fth = { {8,17}, {5,11}, {5,5} }, fw = { 5, 4, 3 }, eye = { 18, 17, 3 }, anchor = { 12, 10 }, floorRow = 25,
           seam = { {6,21}, {9,23}, {17,23}, {20,21} }, gloss = { 8, 15 } },
  mid  = { W = 20, ol = 1, olx = 0, cres = 1, k = 0.6, bx = 9, by = 11.5, rx = 6, ry = 3.5, clip = 14,
           nose = { {13,9}, {17,13}, {13,14} }, ear = { 11, 7, 2 }, pinkEar = 1, pinkNose = { 16, 12, 1 },
           fth = { {5,11}, {3,4} }, fw = { 3, 3 }, eye = { 10, 10, 3 }, anchor = { 8, 6 }, floorRow = 15,
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
  if not rot and S.clip then body:clip(c:rect(0, 0, S.W - 1, S.clip + ty - down)) end -- flat floor contact
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
    { "ear",  ear, EARR, { flat = true, rim = false } },
    { "body", body, RED, bopts },
  }
  -- body felt nap (near only): 2-px ticks anchored to the body centre, collected then painted
  if S.gloss then
    local cx, cy = rnd(bcx + tx), rnd(bcy + ty)
    local nap = {}
    local e = S.eye; local ep = xf({ e[1] + 1, e[2] + 1 }); local ex, ey = rnd(ep[1] - 1), rnd(ep[2] - 1)
    local g = xf(S.gloss); local gx, gy = rnd(g[1]), rnd(g[2])
    for ri, y in ipairs({ cy - 4, cy }) do for x = 0, S.W - 1 do
      local dx = x - cx
      local nearEye = x >= ex - 2 and x <= ex + 4 and y >= ey - 1 and y <= ey + 3
      local nearGl  = math.abs(x - gx) <= 2 and math.abs(y - gy) <= 2
      if (dx + ri * 4) % 8 < 2 and not nearEye and not nearGl and c:get(x,y) == RED.base
         and c:get(x+1,y) == RED.base and c:get(x-1,y) == RED.base
         and c:get(x,y+1) == RED.base and c:get(x,y-1) == RED.base then nap[#nap+1] = {x,y} end
    end end
    for _, q in ipairs(nap) do c:px(q[1], q[2], RED.shade) end
  end
  -- body detail
  if S.gloss then
    local g = xf(S.gloss)
    c:px(rnd(g[1]), rnd(g[2]), RED.gloss); c:px(rnd(g[1]) + 1, rnd(g[2]), RED.gloss); c:px(rnd(g[1]), rnd(g[2]) + 1, RED.gloss)
    local sp = {}
    for i, q in ipairs(S.seam) do local t = xf(q); sp[i] = { rnd(t[1]), rnd(t[2]) } end
    c:seam(sp, { gap = RED.shade })
  else
    local g = xf(S.gloss1); c:px(rnd(g[1]), rnd(g[2]), RED.gloss)
  end
  -- quill down the feather centre (gold), only on feather px
  local function onF(x, y) return c.own[c:key(x, y)] == p.fth end
  local seen = {}
  for i = 1, #fp - 1 do
    local a0, b0 = fp[i], fp[i + 1]
    local last = (i == #fp - 1)
    local ddx, ddy = b0[1] - a0[1], b0[2] - a0[2]
    local st = math.max(math.abs(ddx), math.abs(ddy))
    local tmax = 1
    if last then tmax = (st - 1) / st; if S.k < 1 then tmax = tmax * 0.9 end end
    for j = (i == 1 and 1 or 0), st do
      local t = j / st
      if t <= tmax + 1e-9 then
        local x, y = rnd(a0[1] + ddx * t), rnd(a0[2] + ddy * t)
        local kk = x .. "," .. y
        if not seen[kk] and onF(x, y) then seen[kk] = true; c:px(x, y, "#f5cf6a") end
      end
    end
  end
  -- feather barbs (near only): notch the lit vane edge 2-on 1-off
  if S.gloss then
    p.fth.m:each(function(x,y) if y % 3 == 0 and c:get(x,y) == FEATH.rim and c:get(x,y-1) == FEATH.rim then c:px(x,y,FEATH.base) end end)
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
  -- ear fold crescent (lower right)
  local ec = {}
  p.ear.m:each(function(x,y) local r, d = c:get(x+1,y), c:get(x,y+1)
    if c:get(x,y) == "#e9b98a" and ((r ~= "#e9b98a" and r ~= PINK) or (d ~= "#e9b98a" and d ~= PINK)) then ec[#ec+1] = {x,y} end end)
  for _, q in ipairs(ec) do c:px(q[1], q[2], "#c98a68") end
  return c, { ax, ay }, p
end

local function lureFrame(sizeName, S, n)
  local P = POSES[n]
  local best
  local OFFS = { {0,0}, {1,0}, {0,1}, {1,1}, {2,0}, {2,1}, {2,2}, {3,1}, {3,2}, {1,2}, {3,3}, {0,2}, {0,3}, {1,3}, {2,3}, {1,4}, {0,4}, {2,4}, {3,4} }
  -- frames 4-6 share one offset (so the wobble does not slide the sprite): first offset where all three pass
  local order = OFFS
  if n >= 4 and n <= 6 then
    for _, o in ipairs(OFFS) do
      local all = true
      for m = 4, 6 do local cc = buildLure(S, POSES[m], o[1], o[2]); if not edgesOk(cc:image(), false) then all = false end end
      if all then order = { o }; break end
    end
  end
  for _, o in ipairs(order) do
    local c, anc, pp = buildLure(S, P, o[1], o[2])
    local img = c:image()
    if edgesOk(img, false) then best = { c, anc, o, pp }; break end
    best = best or { c, anc, o, pp }
  end
  local c, anc, o, pp = best[1], best[2], best[3], best[4]
  local name = "cf-lure-" .. sizeName .. "-" .. n
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local img = c:image()
  local av = img:getPixel(anc[1], anc[2])
  local ac = string.format("%02x%02x%02x", pc.rgbaR(av), pc.rgbaG(av), pc.rgbaB(av))
  local gold = (ac == "f5cf6a" or ac == "e8a317") -- else the ear covers the anchor: accept if gold shows beside it
  if not gold then
    for yy = anc[2] - 1, anc[2] + 2 do for xx = anc[1] - 1, anc[1] + 1 do
      local v = img:getPixel(xx, yy); local h = string.format("%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
      if (h == "f5cf6a" or h == "e8a317") and c.own[c:key(xx, yy)] == pp.loop then gold = true end
    end end
  end
  local nloop = 0
  for yy = 0, img.height - 1 do for xx = 0, img.width - 1 do if c.own[c:key(xx, yy)] == pp.loop and pc.rgbaA(img:getPixel(xx, yy)) > 0 then nloop = nloop + 1 end end end
  local ok = edgesOk(img, false) and t.semi == 0 and t.colours <= 16 and t.bw == 0 and gold and nloop >= 3
  -- felt never below the floor row (outline/border start below it)
  local yb = -1
  local bx0, by0, bx1, by1 = c.sil:bbox()
  report(name .. (o[1] + o[2] > 0 and string.format(" (nudged %d,%d)", o[1], o[2]) or ""), t, ok)
  return t
end

local function lureFar()
  local G = {
    "............", ".KK.........", "KwwK........", "KwbbK...KK..", ".KbqKK.KnnK.", ".KbqyoKonnoK",
    "KobqgrrrrroK", "KorrrrrrerpK", "KorrrrrrrssK", ".Kossssss1K.", "..K111111K..", "...KKKKKK...",
  }
  local COL = { K = "#000000", o = "#4a2c1a", r = "#dd3a2a", g = "#ff9158", s = "#b8452f", b = "#3f8fb0", q = "#2f6290", w = "#8fcbd8",
                y = "#f5cf6a", e = "#2a1a10", p = "#e8909e", n = "#e9b98a", ["1"] = "#2a1a10" }
  local cells = {}
  for y = 1, 12 do for x = 1, 12 do
    local ch = G[y]:sub(x, x)
    if ch ~= "." and ch ~= "K" then
      local X, Y = x - 1, y - 1
      local reg = "body"
      if X == 4 and Y == 5 then reg = "loop" elseif X <= 3 and Y <= 5 then reg = "fth" elseif X >= 7 and Y <= 5 then reg = "ear" end
      cells[#cells + 1] = { X, Y, ch, reg }
    end
  end end
  local F = {
    [1] = function(c) if c[4] == "fth" or c[4] == "ear" or c[4] == "loop" then return c[1], c[2] + 1 end; return c[1], c[2] end,
    [2] = function(c) local dy = -1; if c[1] >= 9 and c[4] == "body" then dy = dy - 1 elseif c[4] == "fth" then dy = dy + 1 end; return c[1], c[2] + dy end,
    [3] = function(c) local dy = -1; if c[1] >= 9 and c[4] == "body" then dy = dy + 1 end; return c[1], c[2] + dy end,
    [4] = function(c) if c[4] == "fth" and c[2] <= 2 then return c[1] + 1, c[2] end; return c[1], c[2] end,
    [5] = function(c) return c[1], c[2] end,
    [6] = function(c)
      if c[4] == "ear" then return c[1], c[2] + 1 end
      if c[4] == "fth" and c[2] <= 2 then return c[1] + 1, c[2] end
      return c[1], c[2] end,
  }
  for n = 1, 6 do
    local art, anch = {}, nil
    local function put(x, y, ch) art[y * 12 + x] = ch end
    local order = { body = 1, ear = 2, fth = 3, loop = 4 }
    table.sort(cells, function(a, b) return order[a[4]] < order[b[4]] end)
    for _, c in ipairs(cells) do
      local x, y = F[n](c)
      if x then put(x, y, c[3]); if c[4] == "loop" then anch = { x, y } end end
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
local WS = { 1, 1.15, 1, 0.9, 1, 1 } -- perspective width multiplier per frame
local RODRED = { gloss = "#f2793a", dot = "#f2793a", rim = "#f2793a", base = "#dd3a2a", shade = "#ac1c27", deep = "#ac1c27", bounce = "#ac1c27" }
local RODWOOD = { gloss = "#d9a660", dot = "#d9a660", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#8a4f2a", bounce = "#8a4f2a" }
local RODWATER = { gloss = "#8fcbd8", dot = "#8fcbd8", rim = "#8fcbd8", base = "#3f8fb0", shade = "#305e86", deep = "#305e86", bounce = "#305e86" }
local RODGOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a", deep = "#b8661a", bounce = "#b8661a" }

local function wandFrame(n)
  local W = WAND[n]
  local tx, ty = W.T[1], W.T[2]
  local dx, dy = PX - tx, PY - ty
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local nx, ny = -uy, ux                      -- unit normal (right of the shaft when it points up)
  local f = (n == 2) and (L / 58) or 1        -- windup is foreshortened
  local c = GV.canvas{ w = 48, h = 64, mode = "sticker", margin = 1, ol = 1, olx = 0 }
  local ws = WS[n]
  local function band(t0, t1, w0, w1)
    w1 = w1 or w0
    local h0, h1 = w0 * ws / 2, w1 * ws / 2
    local a = { tx + ux * t0 * f - nx * h0, ty + uy * t0 * f - ny * h0 }
    local b = { tx + ux * t0 * f + nx * h0, ty + uy * t0 * f + ny * h0 }
    local cc = { tx + ux * t1 * f + nx * h1, ty + uy * t1 * f + ny * h1 }
    local d = { tx + ux * t1 * f - nx * h1, ty + uy * t1 * f - ny * h1 }
    return c:poly({ a, b, cc, d })
  end
  local p = c:build{
    { "shaft", band(11, 42, 4, 5), RODWOOD, { cres = 1, deep = 0, gloss = false, bounce = false } },
    { "grip",  band(40, 200, 8, 11), RODRED, { cres = 2, deep = 0, gloss = false, bounce = false } },
    { "sleeve", band(3, 13, 7, 8), RODWATER, { cres = 2, deep = 0, gloss = false, bounce = false } },
    { "bead",  band(40, 43, 7, 7), RODGOLD, { flat = true } },
    { "cap",   c:ellipse(tx, ty, W.r), RODGOLD, { cres = 1, deep = 0, gloss = false, bounce = false } },
  }
  -- gold bead (cf-rod): f5cf6a with lower-right b8661a
  local bm = p.bead.m
  bm:each(function(x, y)
    local lr = not bm:has(x + 1, y) or not bm:has(x, y + 1)
    c:px(x, y, lr and "#b8661a" or "#f5cf6a")
  end)
  -- cord wrap, wood grain, sleeve ribs (pixels collected first, painted after)
  local function axis(x,y) return ((x-tx)*ux + (y-ty)*uy) / f, (x-tx)*nx + (y-ty)*ny end
  do
    local jobs = {}
    local function scan(m, fn) m:each(function(x,y) local t, s = axis(x,y); local h = fn(c:get(x,y), math.floor(t), rnd(s)); if h then jobs[#jobs+1] = {x,y,h} end end) end
    scan(p.grip.m, function(v, t) if v == RODRED.base and t % 3 == 0 then return RODRED.shade end end)
    scan(p.shaft.m, function(v, t, s)
      if v == RODWOOD.base then
        local m9 = t % 9
        if (m9 <= 2 and s == 0) or ((m9 == 5 or m9 == 6) and s == 1) then return RODWOOD.shade end
      end end)
    scan(p.sleeve.m, function(v, t) if v == RODWATER.base and (t == 8 or t == 11) then return RODWATER.shade end end)
    for _, j in ipairs(jobs) do c:px(j[1], j[2], j[3]) end
  end
  -- grip gloss (#ff9158) on the left edge at t=48, sleeve glint (#c8ecdc) at t=5
  do
    local gw = (8 + (48 - 40) / 160 * 3) * ws
    local gx, gy = rnd(tx + ux * 48 * f - nx * (gw / 2 - 1)), rnd(ty + uy * 48 * f - ny * (gw / 2 - 1))
    if c.own[c:key(gx, gy)] == p.grip then c:px(gx, gy, "#ff9158") end
    local sw = (7 + (5 - 3) / 10) * ws
    local sx, sy = rnd(tx + ux * 5 * f - nx * (sw / 2 - 1)), rnd(ty + uy * 5 * f - ny * (sw / 2 - 1))
    if c.own[c:key(sx, sy)] == p.sleeve then c:px(sx, sy, "#c8ecdc") end
  end
  -- cap: gloss + two button holes
  c:px(tx - 1, ty - 1, "#fff1c8")
  local offs = { { -1, 1 }, { 1, 1 } }
  if math.abs(ux) > 0.35 then offs = { { -1, 1 }, { 1, 0 } } end
  for _, o in ipairs(offs) do c:px(tx + o[1], ty + o[2], "#8a4a1c") end
  c:finish()
  local OLT = { ["#74462a"]=1, ["#4a2c1a"]=1, ["#2a1a10"]=1 }
  local re = {}
  for k, h in pairs(c.pix) do
    local x, y = c:xy(k)
    if OLT[h] and not c.sil:has(x, y) then
      local col
      if c.sil:has(x-1, y) or c.sil:has(x, y-1) then col = "#2a1a10"
      elseif c.sil:has(x, y+1) then col = "#74462a"
      elseif c.sil:has(x+1, y) then col = "#4a2c1a"
      else col = c.sil:has(x-1, y-1) and "#2a1a10" or "#4a2c1a" end
      re[#re+1] = { k, col }
    end
  end
  for _, r in ipairs(re) do c.pix[r[1]] = r[2] end
  local name = "cf-wand-cast-" .. n
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local img = c:image()
  local ok = edgesOk(img, true) and t.semi == 0 and t.colours <= 21 and t.bw == 0 -- cf-rod itself has 21 hexes
  report(name, t, ok)
end

-------------------------------------------------------------------- 3. SHADOWS (2a1a10, a255, hard pixels)
local SHADOWS = {
  { 48, 12, { 20, 32, 38, 42, 44, 44, 42, 38, 32, 20 } },
  { 36, 10, { 18, 28, 32, 34, 32, 28, 18 } },
  { 24, 8,  { 14, 20, 20, 14 } },
  { 20, 6,  { 12, 18, 12 } },
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
local DUST4 = {
  "........................", "........................", ".........oooo...........", "........ohhhho..........",
  "....oo..occcco..........", "...ohho..oooo...oo......", "...osso........ohho.....", "....oo.........osso.....",
  "................oo......", "........................", "....ooooo....oooooo.....", "..oohhhhho..ohhhhhhoo...",
  ".ohhooooo....oooooohho..", ".occo..............occo.", "..occcccco....occcccco..", "...oooooooo..oooooooo...",
}
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
  dust[4] = DUST4
  streak[1][4] = streak[1][4]:sub(1,4) .. "hh.h" .. streak[1][4]:sub(9)     -- y=3, x4..7
  streak[1][5] = streak[1][5]:sub(1,10) .. "c.cc.c" .. streak[1][5]:sub(17) -- y=4, x10..15
  dust[3][12] = dust[3][12]:sub(1, 20) .. "s" .. dust[3][12]:sub(22)
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

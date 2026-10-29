-- cf_overlays_s2.lua : Cat Fish overlay layers for the S2 active-play frames (swatA, swatB, blink), via gvlib.
-- Run after cf_frames_s2.lua:  AppRun -b --script cf_overlays_s2.lua      Reads test/cf-cat-grey-<f>.png, writes test/:
--   swatA, swatB (FULL frames, the same set as the key frames):
--     cf-pat-<tabby|tuxedo|calico|pointed|spotted>-grey-<f>.png, cf-ears-folded-<f>.png + cf-ears-mask-<f>.png,
--     cf-tail-bobtail-<f>.png + cf-tail-mask-<f>.png, cf-eyes-ring-<f>.png + cf-eyes-<amber|green|blue|hazel>-<f>.png
--   blink (ALIAS of idleA, see frames-alias-s2.json): only cf-eyes-ring-blink.png + cf-eyes-<colour>-blink.png, all
--     EMPTY (closed eyes show no iris: the nap rule). Its pattern, ears, tail and masks are idleA's files; this
--     script proves they fit: blink - idleA mask + idleA part == a fresh render of blink with that part.
--   plus cf-overlays-<f>.aseprite (base + every overlay as a hidden layer) to look at in Aseprite.
-- Nothing else is written, and no existing file is read for writing (tones_overlays.json is not rewritten: the
-- swat overlays use exactly its roles).
--
-- The frame geometry comes from cf_frames_s2.lua (loaded as a library with CF_S2_LIB, so one copy of the code
-- draws the bodies and these overlays). Every base is re-rendered and must match its committed PNG pixel for
-- pixel, and idleA must match test/cf-cat-grey-idleA.png, before anything is written.
-- The mark code (marks, rings, stripes, lines, partMask, headAscii, TABBY_HEAD, MUZZLE, the five pattern
-- functions, the replacement-part mask/check) is a copy of cf_overlays.lua (it writes files when loaded, so it
-- cannot be dofile'd), parametrized for the two new frames; see that file for the colour and mask rules.
-- ANCHORING (markings stay on the same body spot as idleA):
--   swatA is idleA's body leaning back (seat 1 px left, chest 3 px left). Its body marks are idleA's marks pushed
--   through LEAN: x += -1 - round((47 - y) / 5), clamped to -3..-1 (y 47 -> -1, y 42 -> -2, y 37 and up -> -3),
--   so a stripe at chest height moves with the chest and one at the seat moves with the seat. Head marks ride the
--   head offset (-2,3) like every frame; calico ear patches and folded flaps ride their ear (idleB's tilt).
--   The raised foreleg (legN) gets bored's treatment: tabby bands (as bored), calico patch on its root, pointed sock.
--   swatB is a side view like stalk / pounce: back stripes across its own body axis, stalk's haunch arcs moved
--   onto its haunch, bands along both forelegs; the bib sits on the chest under the chin.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
CF_S2_LIB = true
local S2 = dofile(here .. "/cf_frames_s2.lua")
CF_S2_LIB = nil
local OUT = here .. "/test/"
local pc = app.pixelColor

local GREY = S2.GREY
local DEEP = "#3d3654"
local PW = { gloss = "#fbf6ec", base = "#e6dfd2", shade = "#bab0c0", deep = "#8d829a" }
local PW_EDGE = "#463e5e"
local EYE_RING = "#ff00ff"
local EYES = { amber = "#e0902a", green = "#7cb342", blue = "#4f9fe0", hazel = "#a89436" }
local TONE = { [DEEP] = 0, [GREY.shade] = 1, [GREY.base] = 2, [GREY.light] = 3, [GREY.gloss] = 4 }
local BYTONE = { [0] = DEEP, GREY.shade, GREY.base, GREY.light, GREY.gloss }
local FR, OFF, rell, foldMask = S2.FR, S2.OFF, S2.rell, S2.foldMask

local FULL = { "swatA", "swatB" }
local CLOSED = { blink = true }

-- ---------- pixel tables: [y*64+x] = "#hex" (copy of cf_overlays.lua) ----------
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
  assert(n <= 8, name .. ": " .. n .. " colours (cap 8)")
  return n
end
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local written, report = {}, {}
local function emit(name, t, group)
  local n = savePNG(name, t)
  written[#written + 1] = { name = name, t = t, group = group }
  report[#report + 1] = string.format("%-30s px=%4d colours=%d", name, count(t), n)
end

-- ---------- base frames: re-render, compare with the committed PNGs ----------
local BASE, INFO, CAN = {}, {}, {}
for _, f in ipairs({ "idleA", "swatA", "swatB", "blink" }) do
  local c, info = FR[f]({ ears = "orig", tail = "orig" })
  local file = loadPNG(OUT .. "cf-cat-grey-" .. f .. ".png")
  local mine = pixOf(c)
  for i = 0, 4095 do
    if file[i] ~= mine[i] then error(string.format("%s: re-render differs from cf-cat-grey PNG at %d,%d (%s vs %s): run cf_frames_s2.lua first / copy out of step", f, i % 64, i // 64, tostring(file[i]), tostring(mine[i]))) end
  end
  BASE[f], INFO[f], CAN[f] = file, info, c
end

-- ================================ A. eyes ================================
local IRIS = { {2, 0}, {3, 0}, {4, 1}, {4, 2}, {4, 3}, {1, 4}, {2, 4}, {3, 4}, {0, 3}, {0, 2} } -- as cf_overlays.lua
for _, f in ipairs({ "swatA", "swatB", "blink" }) do
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

-- ================================ B. pattern marks (copy of cf_overlays.lua, swat branches) ================================
local HI = { head = true, paw = true }
local CATPART = { head = true, paw = true, body = true, tail = true, earL = true, earR = true, thigh = true,
  legB = true, legF = true, legH = true, legN = true }
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
      local role = tn - (HI[name] and 1 or 0)
      if o == "dark" then
        if not comma then new = BYTONE[math.max(0, tn - 1)] end
      elseif o == "dark2" then
        if not comma then new = BYTONE[math.max(0, tn - 2)] end
      elseif o == "darkLit" then
        if not comma and role >= 2 then new = BYTONE[tn - 1] end
      elseif o == "dark2Lit" then
        if not comma and role >= 2 then new = BYTONE[math.max(0, tn - 2)] end
      elseif o == "light" then
        new = BYTONE[math.min(4, tn + 1)]
      elseif o == "white" then
        if comma or role >= 3 then new = PW.gloss elseif role == 2 then new = PW.base
        elseif role == 1 then new = PW.shade else new = PW.deep end
      end
      if new and new ~= h then out[i] = new end
    end
  end
  local isW = { [PW.gloss] = true, [PW.base] = true, [PW.shade] = true, [PW.deep] = true }
  local edge = {}
  for i, v in pairs(out) do
    if isW[v] then
      local x, y = i % 64, i // 64
      for _, d in ipairs({ {1, 0}, {-1, 0}, {0, 1}, {0, -1} }) do
        local j = (y + d[2]) * 64 + x + d[1]
        local nv = out[j] or base[j]
        if nv and TONE[nv] and TONE[nv] >= 1 then edge[i] = true; break end
      end
    end
  end
  for i in pairs(edge) do out[i] = PW_EDGE end
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
local function headAscii(f, rows, x0, y0)
  return CAN[f]:ascii(rows, x0 + OFF[f][1], y0 + OFF[f][2])
end
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
-- NEW (S2): swatA's lean. idleA body coords -> swatA: the seat moves 1 px left, the chest 3 px (see header)
local function leanDx(y) return math.max(-3, math.min(-1, -1 - math.floor((47 - y) / 5 + 0.5))) end
local function lean(f, m)
  local n = CAN[f]:mask()
  m:each(function(x, y) n:set(x + leanDx(y), y) end)
  return n
end

local TABBY_HEAD = {
  ".........xx...xxx...xx.........",
  ".........xxx..xxx..xxx.........",
  "..........xx..xxx..xx..........",
  "..........xxx.xxx.xxx..........",
  "...........xx..x..xx...........",
  "...............x...............",
  "...............................",
  "...............................",
  "...............................",
  "...............................",
  "xxx.........................xxx",
  "xx...........................xx",
  "...............................",
  "xxxx.......................xxxx",
  ".xxxx.....................xxxx.",
  "...............................",
  "xxxx.......................xxxx",
  ".xxxx.....................xxxx.",
}
local function tabby(f)
  local I = INFO[f]
  local L = {}
  L[#L + 1] = { headAscii(f, TABBY_HEAD, 10, 11), "dark2" }
  local tail = partMask(f, S{ "tail" })
  L[#L + 1] = { rings(f, I.tpts, tail, 3, 6, 3, nil), "dark2Lit" }
  L[#L + 1] = { rings(f, I.tpts, tail, 1e9, 1, 0, 4), "dark2" }
  local body = partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" })
  local st
  if f == "swatA" then -- idleA's flank stripes through the lean, bands up the raised foreleg (bored's)
    local L2 = {}
    for _, y in ipairs({ 37, 42, 47 }) do
      L2[#L2 + 1] = { {10, y}, {14, y}, {18, y + 3} }
      L2[#L2 + 1] = { {40, y}, {36, y}, {32, y + 3} }
    end
    st = lean(f, lines(f, L2, 3))
    st:add(rings(f, I.apts, partMask(f, S{ "legN" }), 4, 5, 2, nil))
  elseif f == "swatB" then -- side view: stalk's back stripes on its own axis, haunch arcs, foreleg bands
    st = stripes(f, 22, 45, I.A, { -10, -5, 0, 5 }, 3, -8, 1, -2)
    st:add(lines(f, { { {10, 41}, {7, 45}, {7, 50} }, { {15, 41}, {12, 45}, {12, 51} } }, 2))
    st:add(rings(f, I.apts, partMask(f, S{ "legN" }), 3, 5, 2, nil))
  end
  L[#L + 1] = { st:clip(body), "dark2" }
  return marks(f, L)
end

local MUZZLE = {
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
  if f == "swatA" then -- idleA's bib through the lean
    return lean(f, big and c:ellipse(25, 46, 10, 9) or c:ellipse(25, 40, 5, 10):add(c:poly({ {19, 29}, {31, 29}, {25, 38} })))
  elseif f == "swatB" then -- the chest under the chin, between the planted foreleg and the haunch
    return big and c:ellipse(26, 45, 8, 6) or c:ellipse(27, 44.5, 5, 4)
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
  local pL = c:poly({ {5, 3}, {24, 8}, {24, 15}, {19, 19}, {12, 21}, {6, 19} })
  local pR = c:poly({ {29, 4}, {42, 4}, {43, 19}, {37, 17}, {31, 12} })
  local hp = pL:shift(ox, oy):add(pR:shift(ox, oy)):clip(partMask(f, S{ "head" }))
  local eL, eR = I.eL or { 0, 0 }, I.eR or { 0, 0 }
  hp:add(pL:shift(ox + eL[1], oy + eL[2]):clip(partMask(f, S{ "earL" })))
  hp:add(pR:shift(ox + eR[1], oy + eR[2]):clip(partMask(f, S{ "earR" })))
  L[#L + 1] = { hp, "dark2" }
  L[#L + 1] = { headAscii(f, MUZZLE, 19, 18), "white" }
  L[#L + 1] = { bib(f, true):clip(partMask(f, S{ "body" })), "white" }
  L[#L + 1] = { partMask(f, S{ "paw" }), "white" }
  local body = partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" })
  local bp
  if f == "swatA" then -- idleA's two flank patches through the lean, running up the raised foreleg's root
    bp = lean(f, c:poly({ {27, 30}, {42, 31}, {43, 50}, {37, 47}, {33, 40}, {29, 37} }):add(c:poly({ {7, 40}, {15, 38}, {18, 45}, {16, 57}, {7, 57} })))
    bp:add(rings(f, I.apts, partMask(f, S{ "legN" }), 0, 100, 9, nil)) -- the foreleg's root carries the flank patch
  elseif f == "swatB" then -- a saddle over the back behind the head, the haunch patch (stalk's), the striking leg's root
    bp = c:poly({ {14, 36}, {24, 35}, {27, 41}, {20, 44}, {15, 41} }):add(c:poly({ {5, 41}, {13, 39}, {19, 47}, {14, 55}, {5, 53} }))
  end
  L[#L + 1] = { bp:clip(body), "dark2" }
  local tail = partMask(f, S{ "tail" })
  L[#L + 1] = { rings(f, I.tpts, tail, 0, 100, 11, nil), "dark2" }
  return marks(f, L)
end

local function pointed(f)
  local c, I = CAN[f], INFO[f]
  local L = {}
  L[#L + 1] = { partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" }), "light" }
  L[#L + 1] = { partMask(f, S{ "earL", "earR", "paw" }), "dark" }
  local mask = c:poly({ {25, 14}, {35, 20}, {37.5, 26}, {31, 31.5}, {19, 31.5}, {12.5, 26}, {15, 20} }):shift(I.ox, I.oy)
  L[#L + 1] = { mask:clip(partMask(f, S{ "head" })), "dark" }
  L[#L + 1] = { partMask(f, S{ "tail" }), "dark" }
  local fL, fR = foldMask(c, I.ox, I.oy, I.fL, I.fR)
  L[#L + 1] = { fL:add(fR):clip(partMask(f, S{ "head" })), "dark2" }
  -- socks on the forelegs that move (like the pounce): the raised / striking forearm, swatB's planted leg
  if f == "swatA" then L[#L + 1] = { lines(f, { { {41, 31}, {46, 22} } }, 6):clip(partMask(f, S{ "legN" })), "dark" }
  elseif f == "swatB" then L[#L + 1] = { lines(f, { { {40, 44}, {46, 42} }, { {29, 50}, {29, 52} } }, 5):clip(partMask(f, S{ "legN", "legF" })), "dark" } end
  return marks(f, L)
end

local ROS = {
  { ".xxx", "xxxx", "xxxx", "xxx." },
  { ".xx.", "xxxx", ".xx." },
  { "xx..", "xxx.", ".xxx", "..xx" },
  { "xxx.", "xxxx", ".xxx" },
}
local function spotted(f)
  local c, I = CAN[f], INFO[f]
  local L = {}
  -- dx (S2): shift the whole grid (hash included) dx px, as cf_overlays' dy does for bored
  local function stampAll(names, step, ox0, oy0, shrink, dy, dx)
    dy, dx = dy or 0, dx or 0
    local pm = partMask(f, S(names)):shrink(shrink or 1)
    local m = c:mask()
    local row = 0
    for y = oy0 + dy, 60, step - 1 do
      row = row + 1
      for x = ox0 + dx + ((row % 2) * (step // 2)), 60, step do
        local hsh = ((x - dx) * 73 + (y - dy) * 151 + row * 31) % 97
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
  local front = f == "swatA"
  -- swatA: idleA's grid moved 2 px left (the lean's middle); spots are whole stamps, so they shift as one
  local m = stampAll({ "body", "thigh" }, front and 6 or 5, 1, 1, front and 1 or 0, 0, front and -2 or 0)
  m:add(stampAll({ "legB", "legF", "legH", "legN" }, 5, 0, 0))
  local tail = partMask(f, S{ "tail" })
  local tr = rings(f, I.tpts, tail, 3, 6, 3, 3)
  L[#L + 1] = { m, "dark2" }
  L[#L + 1] = { tr, "dark2Lit" }
  L[#L + 1] = { headAscii(f, {
    "...........xx.....xx...........",
    "...........xx.....xx...........",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "...............................",
    "xx...........................xx",
    "xx...........................xx",
    "...............................",
    ".xx.........................xx.",
    ".xx.........................xx.",
  }, 10, 12), "dark2" }
  return marks(f, L)
end

local PAT = { tabby = tabby, tuxedo = tuxedo, calico = calico, pointed = pointed, spotted = spotted }
for _, f in ipairs(FULL) do
  for _, name in ipairs({ "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    emit("cf-pat-" .. name .. "-grey-" .. f, PAT[name](f), "pat")
  end
end

-- ================================ C. replacement parts (copy of cf_overlays.lua) ================================
local function diff(a, b) local m = {} for i = 0, 4095 do if a[i] ~= b[i] then m[i] = true end end return m end
local FELT = { [GREY.base] = true, [GREY.light] = true, [GREY.gloss] = true }
local function stitchOnly(f)
  local t = {}
  for y = 0, 63 do for x = 0, 63 do
    local P = CAN[f].own[CAN[f]:key(x, y)]
    if P and CAN[f].names[P] == "body" then t[y * 64 + x] = true end
  end end
  S2.setStitchOnly(t)
end
local function composite(base, mask, part)
  local t = {}
  for i = 0, 4095 do
    local v = base[i]
    if mask[i] then v = nil end
    if part[i] then v = part[i] end
    t[i] = v
  end
  return t
end
for _, f in ipairs(FULL) do
  for _, slot in ipairs({ { "ears", "folded", "fold" }, { "tail", "bobtail", "bob" } }) do
    local oN = { ears = "orig", tail = "orig" }; oN[slot[1]] = "none"
    local oR = { ears = "orig", tail = "orig" }; oR[slot[1]] = slot[3]
    stitchOnly(f)
    local none = pixOf((FR[f](oN)))
    local repl = pixOf((FR[f](oR)))
    S2.setStitchOnly(nil)
    local base = BASE[f]
    local M = diff(base, none)
    local keep = diff(none, repl)
    local mask, part = {}, {}
    for i in pairs(M) do if repl[i] then part[i] = repl[i] end end
    for i in pairs(keep) do if repl[i] then part[i] = repl[i] end end
    for i in pairs(M) do if not (part[i] and FELT[part[i]]) then mask[i] = "#ffffff" end end
    for i, v in pairs(part) do if not FELT[v] then mask[i] = "#ffffff" end end
    -- check: base - mask + part == true render of the replacement
    local comp = composite(base, mask, part)
    for i = 0, 4095 do
      if comp[i] ~= repl[i] then error(string.format("%s %s: composite differs at %d,%d", f, slot[1], i % 64, i // 64)) end
    end
    emit("cf-" .. slot[1] .. "-" .. slot[2] .. "-" .. f, part, "part")
    emit("cf-" .. slot[1] .. "-mask-" .. f, mask, "mask")
  end
end

-- ---------- blink alias check: idleA's committed parts and masks fit blink pixel for pixel ----------
do
  for _, slot in ipairs({ { "ears", "folded", "fold" }, { "tail", "bobtail", "bob" } }) do
    local mask = loadPNG(OUT .. "cf-" .. slot[1] .. "-mask-idleA.png")
    local part = loadPNG(OUT .. "cf-" .. slot[1] .. "-" .. slot[2] .. "-idleA.png")
    local oR = { ears = "orig", tail = "orig" }; oR[slot[1]] = slot[3]
    stitchOnly("blink")
    local repl = pixOf((FR.blink(oR)))
    S2.setStitchOnly(nil)
    local comp = composite(BASE.blink, mask, part)
    for i = 0, 4095 do
      if comp[i] ~= repl[i] then error(string.format("blink %s: idleA part/mask composite differs at %d,%d", slot[1], i % 64, i // 64)) end
    end
    report[#report + 1] = "blink  idleA " .. slot[1] .. " part + mask: composite == fresh render (pixel exact)"
  end
  -- idleA's patterns: no mark may sit on a pixel blink changed (they only mark coat px; idleA's eyes are not coat)
  local d = diff(BASE.idleA, BASE.blink)
  for _, name in ipairs({ "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    local pat = loadPNG(OUT .. "cf-pat-" .. name .. "-grey-idleA.png")
    local hole = 0
    for i in pairs(d) do
      assert(not pat[i], "blink: idleA " .. name .. " mark on a changed eye px")
      -- a lid px that is now coat felt with marks within 5 px left AND right (left unmarked = a 'hole')
      local x, y = i % 64, i // 64
      local lft, rgt = false, false
      for k = 1, 5 do
        if pat[y * 64 + x - k] then lft = true end
        if pat[y * 64 + x + k] then rgt = true end
      end
      if TONE[BASE.blink[i] or ""] and lft and rgt then hole = hole + 1 end
    end
    report[#report + 1] = string.format("blink  idleA %-7s fits (unmarked lid px inside its marks: %d)", name, hole)
  end
end

-- ---------- one .aseprite per frame: base + its own overlays as hidden layers ----------
for _, f in ipairs({ "swatA", "swatB", "blink" }) do
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

for _, r in ipairs(report) do print(r) end
print(#written .. " PNG files written")

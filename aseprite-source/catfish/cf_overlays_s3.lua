-- cf_overlays_s3.lua : Cat Fish overlay layers for animation slice S3 (jump, happy, tailflick, eartwitch), via gvlib.
-- Run after cf_frames_s3.lua:  AppRun -b --script cf_overlays_s3.lua      Writes into test/:
--   jump, happy (FULL frames): cf-eyes-ring-<f>.png + cf-eyes-<amber|green|blue|hazel>-<f>.png (happy: empty files,
--     its eyes are closed like catch), cf-pat-<tabby|tuxedo|calico|pointed|spotted>-grey-<f>.png,
--     cf-ears-folded-<f>.png + cf-ears-mask-<f>.png, cf-tail-bobtail-<f>.png + cf-tail-mask-<f>.png
--   tailflick, eartwitch (ALIASES of idleA): only the layers that differ from idleA's (see below), and
--   frames-alias-s3.json (next to this script) saying, per layer, whether it is the frame's own or idleA's.
--   plus cf-overlays-<f>.aseprite (base + this script's layers for f, hidden) to look at in Aseprite.
-- The frame geometry is NOT copied: it is cf_frames_s3.lua's M.FR (loaded as a library), so bodies and overlays
-- come from one copy. The mark, part and mask code below is a clean copy of cf_overlays.lua's (that script writes
-- every file when loaded, so it cannot be dofile'd); only the per-frame mark placement is new.
--
-- CHECKS (the script stops on any failure):
--   * every frame re-renders to its committed cf-cat-grey PNG pixel for pixel (idleA: cf_cats.lua's PNG);
--   * idleA run through this copy gives exactly the committed idleA patterns, folded ears, bobtail, masks and eyes,
--     so the copy is in step with cf_overlays.lua and the alias comparisons below mean something;
--   * replacement parts: base - mask + part == a fresh render of the cat with that part (as cf_overlays.lua);
--   * aliases: for every coat-layer combination (no pattern or each of the 5; ears orig/folded; tail orig/bobtail)
--     the stack built from the alias JSON (own layer where listed, else idleA's) equals the stack built from
--     layers computed for the alias frame itself, pixel for pixel; eye ring pixels sit where idleA's do.
--
-- ALIAS SCHEME (simplest correct): an alias frame has its own full body PNG (the whole cat, like any frame, so the
-- page never patches a body). Every other layer is computed for the alias frame too, and written only if it differs
-- from idleA's file; otherwise the JSON points at idleA's. Expected result: tailflick owns its body, the bobtail
-- part + mask and the patterns that mark the tail (tabby, calico, pointed, spotted); tuxedo has no tail marks and
-- the folded ears, ear mask and eyes are idleA's. eartwitch owns its body, the folded ears + mask and the patterns
-- that mark the ears (pointed, calico, and any other whose marks touch the moved ear); bobtail, tail mask and eyes
-- are idleA's. The JSON lists what actually came out.
--
-- MARK PLACEMENT for the full frames (marks ride the body: same tone-step rules as cf_overlays.lua):
--   jump: front view, so idleA's flank stripes are redrawn round the narrow body (centre x 32), with bands on the
--     raised forelegs and the hanging hind legs; tuxedo bib on the chest under the chin; calico patches on the left
--     shoulder (running up the left foreleg) and the right hip; spots on a front-view grid.
--   happy: idleA's body (same head, same chest, 4 px shorter below) keeps idleA's stripes, bib and patches.
--   Head marks of all frames ride the head offset (OFF), tail marks follow each frame's tail polyline.
CF_S3_LIB = true
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local M = dofile(here .. "/cf_frames_s3.lua")
CF_S3_LIB = nil
local GV, OUT, FR, OFF = M.GV, M.OUT, M.FR, M.OFF
local pc = app.pixelColor

local GREY = M.GREY
local DEEP = "#3d3654"
local PW = { gloss = "#fbf6ec", base = "#e6dfd2", shade = "#bab0c0", deep = "#8d829a" }
local PW_EDGE = "#463e5e"
local EYE_RING = "#ff00ff"
local EYES = { amber = "#e0902a", green = "#7cb342", blue = "#4f9fe0", hazel = "#a89436" }
local EYE_NAMES = { "ring", "amber", "green", "blue", "hazel" }
local PATS = { "tabby", "tuxedo", "calico", "pointed", "spotted" }
local TONE = { [DEEP] = 0, [GREY.shade] = 1, [GREY.base] = 2, [GREY.light] = 3, [GREY.gloss] = 4 }
local BYTONE = { [0] = DEEP, GREY.shade, GREY.base, GREY.light, GREY.gloss }
local loadPNG, pixOf, toImage, same = M.loadPNG, M.pixOf, M.toImage, M.same

local ALIAS = { tailflick = true, eartwitch = true }
local FULL = { "jump", "happy" }
local DRAWN = { "idleA", "jump", "happy", "tailflick", "eartwitch" }
local IDLE_BODY = { idleA = true, tailflick = true, eartwitch = true, happy = true } -- idleA's body marks apply

-- ---------- output ----------
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local function ncol(t) local n, seen = 0, {} for _, h in pairs(t) do if not seen[h] then seen[h] = true; n = n + 1 end end return n end
local written, report = {}, {}
local function emit(name, t)
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = toImage(t)
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
  local n = ncol(t)
  if n > 8 then print("WARN " .. name .. ": " .. n .. " colours (cap 8)") end
  written[#written + 1] = { name = name, t = t }
  report[#report + 1] = string.format("%-34s px=%4d colours=%d", name, count(t), n)
end

-- ---------- base frames: re-render, compare with the PNG ----------
local BASE, INFO, CAN = {}, {}, {}
for _, f in ipairs(DRAWN) do
  local c, info = FR[f]({ ears = "orig", tail = "orig" })
  local file = loadPNG(OUT .. "cf-cat-grey-" .. f .. ".png")
  local ok, i = same(pixOf(c), file)
  if not ok then error(string.format("%s: re-render differs from cf-cat-grey PNG at %d,%d: run cf_frames_s3.lua first", f, i % 64, i // 64)) end
  BASE[f], INFO[f], CAN[f] = file, info, c
end
local function committed(name) return loadPNG(OUT .. name .. ".png") end

-- ================================ A. eyes (copy of cf_overlays.lua) ================================
local IRIS = { {2, 0}, {3, 0}, {4, 1}, {4, 2}, {4, 3}, {1, 4}, {2, 4}, {3, 4}, {0, 3}, {0, 2} }
local function eyes(f, col)
  local t = {}
  if M.CLOSED[f] then return t end
  local ox, oy = OFF[f][1], OFF[f][2]
  for _, ex in ipairs({ 14, 32 }) do
    for _, d in ipairs(IRIS) do
      local x, y = ex + ox + d[1], 19 + oy + d[2]
      assert(BASE[f][y * 64 + x] == GV.C.halo, f .. ": eye ring px is not cream at " .. x .. "," .. y)
      t[y * 64 + x] = col
    end
  end
  return t
end
local function eyeCol(e) return e == "ring" and EYE_RING or EYES[e] end
local EYE = {}
for _, f in ipairs(DRAWN) do
  EYE[f] = {}
  for _, e in ipairs(EYE_NAMES) do EYE[f][e] = eyes(f, eyeCol(e)) end
end
for _, e in ipairs(EYE_NAMES) do
  assert(same(EYE.idleA[e], committed("cf-eyes-" .. e .. "-idleA")), "idleA eyes copy out of step: " .. e)
end

-- ================================ B. pattern marks (copy of cf_overlays.lua) ================================
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
local function headAscii(f, rows, x0, y0) return CAN[f]:ascii(rows, x0 + OFF[f][1], y0 + OFF[f][2]) end
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
local function lines(f, list, w)
  local c, m = CAN[f], CAN[f]:mask()
  for _, l in ipairs(list) do m:add(c:line(l, w or 2)) end
  return m
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
local J = M.JUMP
local function tabby(f)
  local I = INFO[f]
  local L = {}
  L[#L + 1] = { headAscii(f, TABBY_HEAD, 10, 11), "dark2" }
  local tail = partMask(f, S{ "tail" })
  L[#L + 1] = { rings(f, I.tpts, tail, 3, 6, 3, nil), "dark2Lit" }
  L[#L + 1] = { rings(f, I.tpts, tail, 1e9, 1, 0, 4), "dark2" }
  local body = partMask(f, S{ "body", "thigh", "legB", "legF", "legH", "legN" })
  local st
  if IDLE_BODY[f] then -- idleA's front-view flank stripes (3 px lines, mirror about x 25)
    local L2 = {}
    for _, y in ipairs({ 37, 42, 47 }) do
      L2[#L2 + 1] = { {10, y}, {14, y}, {18, y + 3} }
      L2[#L2 + 1] = { {40, y}, {36, y}, {32, y + 3} }
    end
    st = lines(f, L2, 3)
  elseif f == "jump" then -- the same flank stripes round the narrow body (mirror about x 32), bands on the legs
    local L2 = {}
    for _, y in ipairs({ 37, 42 }) do
      L2[#L2 + 1] = { {21, y}, {24, y}, {27, y + 2} }
      L2[#L2 + 1] = { {43, y}, {40, y}, {37, y + 2} }
    end
    st = lines(f, L2, 3)
    st:add(rings(f, J.legL, partMask(f, S{ "legF" }), 3, 5, 2, nil))
    st:add(rings(f, J.legR, partMask(f, S{ "legN" }), 3, 5, 2, nil))
    st:add(rings(f, J.hindL, partMask(f, S{ "legH" }), 4, 5, 2, nil))
    st:add(rings(f, J.hindR, partMask(f, S{ "legB" }), 4, 5, 2, nil))
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
  if IDLE_BODY[f] then
    return big and c:ellipse(25, 46, 10, 9) or c:ellipse(25, 40, 5, 10):add(c:poly({ {19, 29}, {31, 29}, {25, 38} }))
  elseif f == "jump" then -- chest under the chin (chin at y 34)
    return big and c:ellipse(32, 42, 8, 8) or c:ellipse(32, 40, 4, 7):add(c:poly({ {27, 31}, {37, 31}, {32, 38} }))
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
  if IDLE_BODY[f] then
    bp = c:poly({ {27, 30}, {42, 31}, {43, 50}, {37, 47}, {33, 40}, {29, 37} }):add(c:poly({ {7, 40}, {15, 38}, {18, 45}, {16, 57}, {7, 57} }))
  elseif f == "jump" then -- left shoulder patch running up the left foreleg, a patch on the right hip
    bp = c:poly({ {20, 31}, {29, 33}, {28, 41}, {21, 44} }):add(c:poly({ {35, 42}, {44, 39}, {44, 52}, {36, 52} }))
    bp:add(partMask(f, S{ "legF" }))
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
  local fL, fR = M.foldMask(c, I.ox, I.oy, I.fL, I.fR)
  L[#L + 1] = { fL:add(fR):clip(partMask(f, S{ "head" })), "dark2" }
  if f == "jump" then -- socks: the hanging hind legs below the body and the raised forelegs' upper half
    L[#L + 1] = { lines(f, { { {26, 50}, {25, 52} }, { {38, 50}, {39, 52} }, { {15, 27}, {12, 16} }, { {49, 27}, {52, 16} } }, 5):clip(partMask(f, S{ "legB", "legF", "legH", "legN" })), "dark" }
  end
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
  local function stampAll(names, step, ox0, oy0, shrink)
    local pm = partMask(f, S(names)):shrink(shrink or 1)
    local m = c:mask()
    local row = 0
    for y = oy0, 60, step - 1 do
      row = row + 1
      for x = ox0 + ((row % 2) * (step // 2)), 60, step do
        local hsh = (x * 73 + y * 151 + row * 31) % 97
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
  -- every S3 frame is a front view (idleA's body, or jump's narrow upright one): idleA's grid, step 6, shrink 1
  local m = stampAll({ "body", "thigh" }, 6, 1, 1, 1)
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
local PATF = { tabby = tabby, tuxedo = tuxedo, calico = calico, pointed = pointed, spotted = spotted }

-- ================================ C. replacement parts (copy of cf_overlays.lua) ================================
local SLOTS = { { "ears", "folded", "fold" }, { "tail", "bobtail", "bob" } }
local FELT = { [GREY.base] = true, [GREY.light] = true, [GREY.gloss] = true }
local function diff(a, b) local m = {} for i = 0, 4095 do if a[i] ~= b[i] then m[i] = true end end return m end
local REPL = {} -- REPL[f][slot] = fresh render with the part
local function partOf(f, slot)
  local oN = { ears = "orig", tail = "orig" }; oN[slot[1]] = "none"
  local oR = { ears = "orig", tail = "orig" }; oR[slot[1]] = slot[3]
  M.STITCH_ONLY = {}
  for y = 0, 63 do for x = 0, 63 do
    local P = CAN[f].own[CAN[f]:key(x, y)]
    if P and CAN[f].names[P] == "body" then M.STITCH_ONLY[y * 64 + x] = true end
  end end
  local none = pixOf((FR[f](oN)))
  local repl = pixOf((FR[f](oR)))
  M.STITCH_ONLY = nil
  local base = BASE[f]
  local Mk = diff(base, none)
  local keep = diff(none, repl)
  local mask, part = {}, {}
  for i in pairs(Mk) do if repl[i] then part[i] = repl[i] end end
  for i in pairs(keep) do if repl[i] then part[i] = repl[i] end end
  for i in pairs(Mk) do if not (part[i] and FELT[part[i]]) then mask[i] = "#ffffff" end end
  for i, v in pairs(part) do if not FELT[v] then mask[i] = "#ffffff" end end
  for i = 0, 4095 do
    local v = base[i]
    if mask[i] then v = nil end
    if part[i] then v = part[i] end
    if v ~= repl[i] then error(string.format("%s %s: composite differs at %d,%d", f, slot[1], i % 64, i // 64)) end
  end
  REPL[f] = REPL[f] or {}; REPL[f][slot[1]] = repl
  return part, mask
end

-- ================================ compute every layer for every frame ================================
-- LAY[f][role] = pixel table; roles: pat-<p>, ears-folded, ears-mask, tail-bobtail, tail-mask, eyes-<e>
local LAY = {}
for _, f in ipairs(DRAWN) do
  LAY[f] = {}
  for _, p in ipairs(PATS) do LAY[f]["pat-" .. p] = PATF[p](f) end
  for _, slot in ipairs(SLOTS) do
    local part, mask = partOf(f, slot)
    LAY[f][slot[1] .. "-" .. slot[2]] = part
    LAY[f][slot[1] .. "-mask"] = mask
  end
  for _, e in ipairs(EYE_NAMES) do LAY[f]["eyes-" .. e] = EYE[f][e] end
end
local function fileOf(role, f)
  local kind, rest = role:match("^(%a+)%-(.+)$")
  if kind == "pat" then return "cf-pat-" .. rest .. "-grey-" .. f end
  return "cf-" .. kind .. "-" .. rest .. "-" .. f
end
local ROLES = {}
for _, p in ipairs(PATS) do ROLES[#ROLES + 1] = "pat-" .. p end
for _, r in ipairs({ "ears-folded", "ears-mask", "tail-bobtail", "tail-mask" }) do ROLES[#ROLES + 1] = r end
for _, e in ipairs(EYE_NAMES) do ROLES[#ROLES + 1] = "eyes-" .. e end
-- idleA through this copy == the committed idleA layers
for _, r in ipairs(ROLES) do
  assert(same(LAY.idleA[r], committed(fileOf(r, "idleA"))), "idleA " .. r .. ": this copy is out of step with cf_overlays.lua")
end
print("idleA layers through this copy match the committed idleA files (" .. #ROLES .. " files)")

-- ================================ write ================================
local SRC = {} -- SRC[f][role] = "own" | "idleA"
for _, f in ipairs(FULL) do
  SRC[f] = {}
  for _, r in ipairs(ROLES) do emit(fileOf(r, f), LAY[f][r]); SRC[f][r] = "own" end
end
for _, f in ipairs({ "tailflick", "eartwitch" }) do
  SRC[f] = {}
  for _, r in ipairs(ROLES) do
    if same(LAY[f][r], LAY.idleA[r]) then SRC[f][r] = "idleA"
    else emit(fileOf(r, f), LAY[f][r]); SRC[f][r] = "own" end
  end
end
-- ears/tail part + mask go together: if either of a pair is own, write both (the mask belongs to its part)
for _, f in ipairs({ "tailflick", "eartwitch" }) do
  for _, k in ipairs({ { "ears-folded", "ears-mask" }, { "tail-bobtail", "tail-mask" } }) do
    if SRC[f][k[1]] ~= SRC[f][k[2]] then
      for _, r in ipairs(k) do if SRC[f][r] == "idleA" then emit(fileOf(r, f), LAY[f][r]); SRC[f][r] = "own" end end
    end
  end
end

-- ================================ alias stack check ================================
-- stack like tools/catfish_recolor.py compose(): base, clear masks (base and pattern), parts, pattern, eyes
local function stack(base, pat, parts, masks, eye)
  local img, pt = {}, {}
  for i, v in pairs(base) do img[i] = v end
  if pat then for i, v in pairs(pat) do pt[i] = v end end
  for _, m in ipairs(masks) do for i in pairs(m) do img[i] = nil; pt[i] = nil end end
  for _, p in ipairs(parts) do for i, v in pairs(p) do img[i] = v end end
  for i, v in pairs(pt) do img[i] = v end
  if eye then for i, v in pairs(eye) do img[i] = v end end
  return img
end
local function combo(f, get)
  for _, p in ipairs({ false, "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    for _, ears in ipairs({ false, true }) do
      for _, tail in ipairs({ false, true }) do
        local parts, masks = {}, {}
        if ears then parts[#parts + 1] = get("ears-folded"); masks[#masks + 1] = get("ears-mask") end
        if tail then parts[#parts + 1] = get("tail-bobtail"); masks[#masks + 1] = get("tail-mask") end
        local img = stack(BASE[f], p and get("pat-" .. p), parts, masks, get("eyes-amber"))
        coroutine.yield(img, string.format("%s pat=%s ears=%s tail=%s", f, tostring(p), tostring(ears), tostring(tail)))
      end
    end
  end
end
local function stacks(f, get) return coroutine.wrap(function() combo(f, get) end) end
for _, f in ipairs({ "tailflick", "eartwitch" }) do
  local a = stacks(f, function(r) return SRC[f][r] == "own" and LAY[f][r] or LAY.idleA[r] end)
  local b = stacks(f, function(r) return LAY[f][r] end)
  local n = 0
  while true do
    local ia, la = a(); local ib = b()
    if not ia then break end
    local ok, i = same(ia, ib)
    if not ok then error("alias stack differs: " .. la .. string.format(" at %d,%d", i % 64, i // 64)) end
    n = n + 1
  end
  -- grey, one part, no pattern: the JSON stack equals a fresh render with that part
  for _, k in ipairs({ { "ears", "ears-folded", "ears-mask" }, { "tail", "tail-bobtail", "tail-mask" } }) do
    local g = function(r) return SRC[f][r] == "own" and LAY[f][r] or LAY.idleA[r] end
    local img = stack(BASE[f], nil, { g(k[2]) }, { g(k[3]) }, nil)
    assert(same(img, REPL[f][k[1]]), f .. " " .. k[1] .. ": JSON stack differs from a fresh render")
  end
  print(f .. ": " .. n .. " alias stacks equal the frame's own stacks; part stacks equal fresh renders")
end
-- info: a bobtail cat should not flick at all; compare tailflick+bobtail with idleA+bobtail per pattern
local same_bob = {}
for _, p in ipairs({ false, "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
  local function st(f) return stack(BASE[f], p and LAY[f]["pat-" .. p], { LAY[f]["tail-bobtail"] }, { LAY[f]["tail-mask"] }, nil) end
  local ok = same(st("tailflick"), st("idleA"))
  same_bob[#same_bob + 1] = (p or "none") .. "=" .. (ok and "same" or "differs")
end
print("tailflick+bobtail vs idleA+bobtail: " .. table.concat(same_bob, " "))
local same_fold = {}
for _, p in ipairs({ false, "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
  local function st(f) return stack(BASE[f], p and LAY[f]["pat-" .. p], { LAY[f]["ears-folded"] }, { LAY[f]["ears-mask"] }, nil) end
  same_fold[#same_fold + 1] = (p or "none") .. "=" .. (same(st("eartwitch"), st("idleA")) and "same" or "differs")
end
print("eartwitch+folded vs idleA+folded: " .. table.concat(same_fold, " "))

-- ================================ .aseprite per frame ================================
for _, f in ipairs({ "jump", "happy", "tailflick", "eartwitch" }) do
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

-- ================================ frames-alias-s3.json ================================
local function q(s) return '"' .. s .. '"' end
local function aliasJSON(f, notes)
  local own, base, lay = { q("body") }, {}, { '"body": "cf-cat-grey-' .. f .. '.png"' }
  for _, r in ipairs(ROLES) do
    if SRC[f][r] == "own" then own[#own + 1] = q(r) else base[#base + 1] = q(r) end
    lay[#lay + 1] = q(r) .. ": " .. q(SRC[f][r] == "own" and fileOf(r, f) .. ".png" or fileOf(r, "idleA") .. ".png")
  end
  return '  ' .. q(f) .. ': {\n    "kind": "alias",\n    "base": "idleA",\n    "own": [' .. table.concat(own, ", ") ..
    '],\n    "from_base": [' .. table.concat(base, ", ") .. '],\n    "files": {\n      ' ..
    table.concat(lay, ",\n      ") ..
    '\n    },\n    "notes": ' .. q(notes) .. '\n  }'
end
local Jf = {
  '{',
  '  "_note": "Animation slice S3 (aseprite-source/catfish/cf_frames_s3.lua + cf_overlays_s3.lua). Layer roles: body = cf-cat-grey-<f>; pat-<p> = cf-pat-<p>-grey-<f>; ears-folded/ears-mask, tail-bobtail/tail-mask, eyes-<ring|amber|green|blue|hazel> = cf-<role>-<f>. Grey template names: recolour per coat as for every frame. kind full = every layer is the frame\'s own, named with the frame. kind alias = the body is own; each other layer is either own (its file named with the alias frame) or the base frame\'s file, as listed in files. Stack order as tools/catfish_recolor.py compose(): body, clear ear/tail masks from body and pattern, parts, pattern, eyes. Every alias stack was checked pixel-equal to the stack of layers computed for the alias frame itself. Eye split (odd eyes): jump x = 32, happy has closed eyes (no iris; 25), aliases as idleA (25).",',
  '  "jump": { "kind": "full", "eye_split": 32, "notes": "Straight-up leap drawn at ground level (feet on idleA\'s floor line); add the 16 px translateY arc in code. Eyes open." },',
  '  "happy": { "kind": "full", "eye_split": 25, "notes": "After a catch: happy squint (eye files are empty, like catch), open smile, tail high, little hop with a floor shadow in the frame." },',
  aliasJSON("tailflick", "idleA with only the tail moved (up high, tip hooked back). Patterns that mark the tail are own; a bobtail cat shows no flick (" .. table.concat(same_bob, " ") .. " against idleA+bobtail).") .. ',',
  aliasJSON("eartwitch", "idleA with the right ear tip tilted 2 px out and 2 px down (base fixed); a folded right flap drops 1,1. Patterns that mark the ears are own.") ,
  '}',
}
local fh = io.open(M.here .. "/frames-alias-s3.json", "w")
fh:write(table.concat(Jf, "\n") .. "\n")
fh:close()

for _, r in ipairs(report) do print(r) end
print(#written .. " PNG files written")
for _, f in ipairs({ "tailflick", "eartwitch" }) do
  local o, b = {}, {}
  for _, r in ipairs(ROLES) do if SRC[f][r] == "own" then o[#o + 1] = r else b[#b + 1] = r end end
  print(f .. " own: body " .. table.concat(o, " ") .. " | idleA: " .. table.concat(b, " "))
end

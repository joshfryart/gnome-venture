-- collar.lua : Cat Fish 2.2.x collar overlay (art22). A felt neck band in the GREY 4-tone template
-- (tones.json: shade #57516f, base #8a859b, light #cdc9d3, gloss #f1ebe3) with a small gold bell on the front
-- where the frame shows the chest. tools/catfish_recolor.py later swaps the 4 grey tones to the 6 collar colours
-- (rose, mint, sky, gold, violet, red); umber outline, gold thread and the bell are fixed accents.
-- Run: AppRun -b --script collar.lua
-- Reads game/assets/img/catfish/cf-cat-grey-<f>.png (registration only, never written) and writes
-- art22/out/cf-collar-<f>.png (64x64 transparent overlay, same canvas) + .aseprite (collar layer over a hidden
-- reference layer of the grey cat).
-- Per frame: idleA / catch: band under the chin, sags 1 px in the middle; catch tucks behind the fish (no bell,
-- the fish hides the chest). pounce: head is idleA's +16 x, band rises to the left where the neck turns to the
-- body and tucks behind the right forepaw. nap: head lies on its side, the band is an upright strip where the
-- head meets the curled body, ending under the low chin with the bell peeking out.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local C = GV.C
local OUT = here .. "/out/"
local SRC = here .. "/../../../game/assets/img/catfish/"
local pc = app.pixelColor

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local BELL = { o = C.ol3, d = C.ol2, G = "#fff1c8", L = C.gold, B = C.goldS, S = "#e38111" }
local FISH = { ["#f2c14e"] = 1, ["#e38111"] = 1, ["#dc6f2c"] = 1, ["#ffc27a"] = 1, ["#fff1c8"] = 1, ["#ac3b1d"] = 1, ["#f2a860"] = 1 }

local function hex(v) return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
local function loadPNG(path)
  local img = Image{ fromFile = path }
  local t = {}
  for y = 0, 63 do for x = 0, 63 do
    local v = img:getPixel(x, y)
    if pc.rgbaA(v) == 255 then t[y * 64 + x] = hex(v) end
  end end
  return t
end
local function toImage(t)
  local img = Image(64, 64, ColorMode.RGB)
  img:clear(pc.rgba(0, 0, 0, 0))
  for i, h in pairs(t) do
    img:putPixel(i % 64, i // 64, pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255))
  end
  return img
end

-- bell, 7 x 6, top row sits on the band's lower outline
local BELLROWS = {
  "..ooo..",
  ".oGLBo.",
  "oLLBBBo",
  "oddddSo",
  ".oBBSo.",
  "..ooo..",
}

-- band(t, f): f.dir "h" (slices are columns x0..x1, cross runs down from top(x)) or "v" (slices are rows y0..y1,
-- cross runs right from left(y)). Cross = outline, light, base, shade, outline.
local function band(cat, f)
  local t = {}
  local n0, n1 = f.from, f.to
  local function put(x, y, h)
    if x < 0 or y < 0 or x > 63 or y > 63 then return end
    if f.skip and f.skip(x, y, cat) then return end
    t[y * 64 + x] = h
  end
  for s = n0, n1 do
    local a = f.at(s)
    local first, last = s == n0, s == n1
    local near0, near1 = s - n0, n1 - s
    for k = 0, 4 do
      local h
      if k == 0 then h = C.ol2
      elseif k == 4 then h = C.ol3
      elseif k == 1 then h = (near0 >= 3 and near0 <= 4) and GREY.gloss or GREY.light
      elseif k == 2 then h = (near1 <= f.cres) and GREY.shade or GREY.base
      else h = GREY.shade end
      -- rounded ends: the end slice is outline, its corners cut
      if first or last then
        if k == 0 or k == 4 then h = nil else h = first and C.ol2 or C.ol3 end
      end
      -- gold thread, 2 on / 1 off along the middle of the band (shaded pixels get the darker thread)
      if h and k == 2 and near0 >= 3 and near1 >= 3 and (s - n0) % 3 ~= 0 then
        h = (near1 <= f.cres) and C.goldS or C.gold
      end
      if h then
        if f.dir == "h" then put(s, a + k, h) else put(a + k, s, h) end
      end
    end
  end
  return t
end

local function stampBell(t, x0, y0)
  for r, row in ipairs(BELLROWS) do
    for c = 1, #row do
      local ch = row:sub(c, c)
      if ch ~= "." then t[(y0 + r - 1) * 64 + x0 + c - 1] = BELL[ch] end
    end
  end
end

-- add the 1 px #000000 border where the collar now reaches past the cat's silhouette
local function border(t, cat)
  local add = {}
  for i in pairs(t) do
    local x, y = i % 64, i // 64
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local nx, ny = x + d[1], y + d[2]
      if nx >= 0 and ny >= 0 and nx <= 63 and ny <= 63 then
        local j = ny * 64 + nx
        if not t[j] and not cat[j] then add[j] = "#000000" end
      end
    end
  end
  for j, h in pairs(add) do t[j] = h end
end

local function sag(c, w, base)  -- top row: base, one lower within w of the centre column
  return function(x) return (math.abs(x - c) < w) and base + 1 or base end
end

local FRAMES = {
  idleA = { dir = "h", from = 12, to = 38, at = sag(25, 10, 32), cres = 6, bell = { 22, 37 } },
  catch = { dir = "h", from = 12, to = 38, at = sag(25, 10, 32), cres = 6,
            skip = function(x, y, cat)  -- behind the fish and its 1 px outline
              for dy = -1, 1 do for dx = -1, 1 do
                if FISH[cat[(y + dy) * 64 + x + dx] or ""] then return true end
              end end
              return false
            end },
  pounce = { dir = "h", from = 28, to = 46,
             at = function(x) if x <= 29 then return 30 elseif x <= 33 then return 31 else return 32 end end,
             cres = 5, bell = { 38, 36 },
             skip = function(x, y, cat) return x >= 46 and y >= 32 and y <= 36 and cat[y * 64 + x] ~= GREY.shade and false end },
  nap = { dir = "v", from = 30, to = 49, at = function(y) return 40 end, cres = 5, bell = { 38, 49 } },
}

for _, name in ipairs({ "idleA", "pounce", "catch", "nap" }) do
  local f = FRAMES[name]
  local cat = loadPNG(SRC .. "cf-cat-grey-" .. name .. ".png")
  local t = band(cat, f)
  if f.bell then stampBell(t, f.bell[1], f.bell[2]) end
  border(t, cat)
  -- png: the collar alone
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = toImage(t)
  spr.layers[1].name = "collar"
  spr:saveCopyAs(OUT .. "cf-collar-" .. name .. ".png")
  -- aseprite: hidden grey cat reference under the collar layer
  local ref = spr:newLayer()
  ref.name = "ref cf-cat-grey-" .. name
  spr:newCel(ref, spr.frames[1], toImage(cat), Point(0, 0))
  ref.stackIndex = 1
  ref.isVisible = false
  spr:saveAs(OUT .. "cf-collar-" .. name .. ".aseprite")
  spr:close()
  local n, cols = 0, {}
  for _, h in pairs(t) do if not cols[h] then cols[h] = true; n = n + 1 end end
  print(name .. ": colours " .. n)
end

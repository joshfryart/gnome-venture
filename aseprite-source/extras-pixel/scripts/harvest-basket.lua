-- harvest-basket.lua : wicker harvest basket (harvest.js), Stitched Toy, 64x64 sticker.
-- Three same-canvas PNGs that stack (back, heap, front), like chest.lua:
--   harvest-basket-back.png  : back rim, dark inside + back weave edge, black border, ground shadow
--   harvest-basket-heap.png  : mound of mixed produce over the rim (its own border where it rises above)
--   harvest-basket-front.png : front weave, front rim band with seam, side handle loops, gold buttons
--   harvest-basket.png = back + heap + front ; harvest-basket-empty.png = back + front
-- harvest-basket.aseprite holds Back, Heap, Front as named layers.
-- Families: wood preset (body weave), soil #9a6b3f (rims), soil dark #3d2a1c
-- (inside), soil #c9a96e (handles), red preset, ember #f08a24 (orange), moss preset + leaf preset (greens),
-- dusk rim #7b66b4 (purple, borrowed dusk family), gold (thread, buttons).
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/extras-pixel/"
local C = GV.C
local W = GV.R.wood
local RIM = GV.ramp("#9a6b3f")

local CX = 31.5
local function rimOuter(c) return c:ellipse(CX, 24, 23, 8):add(c:ellipse(CX, 26, 23, 8)) end
local function inner(c) return c:ellipse(CX, 24, 20, 5.5) end
local function allm(c)
  return rimOuter(c):add(c:poly({ { 10, 27 }, { 55, 27 }, { 50, 52 }, { 14, 52 } })):add(c:ellipse(CX, 50, 17.5, 4))
end

local BACK, FRONT = {}, {}

local function back(c)
  local A = allm(c)
  local ring = c:ellipse(CX, 24, 23, 8):cut(inner(c)):cut(c:rect(0, 24, 63, 63))
  local pr = c:part(ring, RIM, { gloss = false, light = A })
  -- back weave edge: diagonal ticks along the far rim
  ring:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == RIM.base then c:px(x, y, RIM.shade) end end)
  local ins = inner(c)
  c:part(ins, GV.ramp("#3d2a1c"), { flat = true, rim = false, contact = false, gloss = false, contour = false })
  -- inner face of the back wall: woven stakes in the top 3 rows of the opening
  ins:each(function(x, y)
    if not ins:has(x, y - 3) then
      local col = (x % 4 == 0) and "#3d2a1c" or ((not ins:has(x, y - 1)) and "#7a4a1f" or "#5e2f1e")
      c:px(x, y, col)
    end
  end)
  BACK = { ring, ins }
end

local function heap(c)
  local open = inner(c):add(c:rect(12, 6, 51, 30))
  local function blob(m) return m:clip(open) end
  c:build{
    { "plum",   blob(c:ellipse(42, 20, 6, 5)), GV.ramp("#7b66b4"), {} },
    { "greens", blob(c:ellipse(19, 21, 7, 5):add(c:ellipse(15, 18, 3, 3))), "leaf", {} },
    { "orange", blob(c:ellipse(26, 17, 5.5, 5.5)), GV.ramp("#f08a24"), {} },
    { "sprout", blob(c:ellipse(47, 24, 4, 3)), "moss", {} },
    { "red",    blob(c:ellipse(35.5, 15, 5, 5)), "red", {} },
  }
  -- stalk nubs: two tiny stems so the round ones read as produce
  c:px(36, 9, GV.R.leaf.base); c:px(36, 8, GV.R.leaf.shade)
  c:px(26, 11, GV.R.leaf.base)
end

local function front(c)
  local A = allm(c)
  -- body (front weave)
  local body = c:poly({ { 10, 27 }, { 55, 27 }, { 50, 52 }, { 14, 52 } }):add(c:ellipse(CX, 50, 17.5, 4))
  c:part(body, "wood", { gloss = false, light = A })
  -- basket weave: horizontal strands of 4 rows that bow down in the middle, stakes offset per row
  body:each(function(x, y)
    local cur = c:get(x, y)
    local tone
    if cur == W.base then tone = { "#d9a660", W.base, W.base, W.shade }
    elseif cur == W.shade then tone = { W.base, W.shade, W.shade, W.deep }
    else return end
    local u = (x - CX) / 23
    local yy = y - math.floor(3 * (1 - u * u) + 0.5)
    local r = yy // 4
    local row = yy % 4
    local ph = (x + (r % 2) * 3) % 6
    local col = tone[row + 1]
    if ph == 0 and row < 3 then col = tone[4] end
    c:px(x, y, col)
  end)
  -- front rim band (rolled wicker) with gold seam
  local band = rimOuter(c):cut(inner(c)):cut(c:rect(0, 0, 63, 23))
  c:part(band, RIM, { gloss = { 13, 27 }, light = A })
  band:each(function(x, y) if (x - y) % 4 == 0 and c:get(x, y) == RIM.base then c:px(x, y, RIM.shade) end end)
  local pts = {}
  for i = 0, 40 do
    local t = math.pi * i / 40
    pts[#pts + 1] = { math.floor(CX + 21.5 * math.cos(t) + 0.5), math.floor(25 + 6.5 * math.sin(t) + 0.5) }
  end
  c:seam(pts)
  -- folded-down side handle loops, hinged under the rim
  local hs = {}
  for _, hx in ipairs({ 11, 52 }) do
    local loop = c:ellipse(hx, 37, 4, 6):cut(c:ellipse(hx, 38, 1, 3)):cut(c:rect(0, 0, 63, 31))
    hs[#hs + 1] = loop
    c:part(loop, GV.ramp("#c9a96e"), { gloss = false, light = A })
  end
  c:button(9, 30); c:button(50, 30)
  FRONT = { body, band, hs[1], hs[2], c:rect(9, 30, 12, 33), c:rect(50, 30, 53, 33) }
end

local function canvas(withHeap)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  back(c)
  if withHeap then heap(c) end
  front(c)
  c:ground(CX, 56, 20, 1.5)
  c:finish()
  return c
end

local cE = canvas(false)   -- empty composite
local cF = canvas(true)    -- full composite

-- front layer: front fill + its outline (not over back fill); never the black border
local fsil = cE:mask()
for _, m in ipairs(FRONT) do fsil:add(m) end
local bsil = cE:mask()
for _, m in ipairs(BACK) do bsil:add(m) end
local near = fsil:grow(3)
local isOl = { [C.ol1] = true, [C.ol2] = true, [C.ol3] = true }
local Fp, Bp, Hp = {}, {}, {}
for k, h in pairs(cE.pix) do
  if fsil.s[k] or (near.s[k] and isOl[h] and not bsil.s[k]) then Fp[k] = h end
end
for k, h in pairs(cE.pix) do if not Fp[k] then Bp[k] = h end end
for k, h in pairs(cF.pix) do if not Fp[k] and cE.pix[k] ~= h then Hp[k] = h end end

local function stack(...)
  local t = {}
  for _, L in ipairs({ ... }) do for k, h in pairs(L) do t[k] = h end end
  return t
end
local function holder(pix)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.done = true; c.pix = pix
  return c
end

local full, empty = stack(Bp, Hp, Fp), stack(Bp, Fp)
local diff = 0
for k, h in pairs(cF.pix) do if full[k] ~= h then diff = diff + 1 end end
for k in pairs(full) do if not cF.pix[k] then diff = diff + 1 end end

local P = O .. "png/"
local cb, ch, cf = holder(Bp), holder(Hp), holder(Fp)
local tb = cb:save(O .. "aseprite/harvest-basket-back.aseprite", P .. "harvest-basket-back.png")
local th = ch:save(nil, P .. "harvest-basket-heap.png")
local tf = cf:save(nil, P .. "harvest-basket-front.png")
local tA = holder(full):save(nil, P .. "harvest-basket.png")
local tE = holder(empty):save(nil, P .. "harvest-basket-empty.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "Back"
spr.cels[1].image = cb:image()
local L = spr:newLayer(); L.name = "Heap"; spr:newCel(L, 1, ch:image(), Point(0, 0))
L = spr:newLayer(); L.name = "Front"; spr:newCel(L, 1, cf:image(), Point(0, 0))
spr:saveAs(O .. "aseprite/harvest-basket.aseprite")
spr:close()
os.remove(O .. "aseprite/harvest-basket-back.aseprite")

print("harvest-basket       " .. GV.report(tA))
print("harvest-basket-empty " .. GV.report(tE))
print("harvest-basket-back  " .. GV.report(tb))
print("harvest-basket-heap  " .. GV.report(th))
print("harvest-basket-front " .. GV.report(tf))
print("stack-vs-render diff px = " .. diff)
for _, t in ipairs({ tA, tE, tb, th, tf }) do assert(t.semi == 0 and t.bw == 0) end
assert(tA.margin >= 3 and tE.margin >= 3)

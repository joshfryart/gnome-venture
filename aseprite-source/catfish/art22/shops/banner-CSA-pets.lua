-- banner-CSA-pets.lua : shop banner for Spice Bazaar Pets (Spicepeak, CSA). Cat Fish pet shops (art22).
-- A cat-eared, two-storey carved-wood pet shop in a foothill bazaar town: red tiled roofs with cat-ear ridge
-- ends, a round cat-face window, marigold garlands under the eave, shelves of yarn balls and fish toys, spice
-- baskets and a ginger cat napping on a cushion on the counter. Prayer-flag bunting and snowy peaks behind.
-- 240x60 grid written at 2x = 480x120 (same as game/assets/img/scenes/banner-*.png), opaque, no text,
-- gold hem stitch top and bottom, fixed 24-colour palette (Part E banner cap).
-- Run: AppRun -b --script banner-CSA-pets.lua  -> ../out/banner-CSA-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1 }

-- the whole palette (24); every ramp below draws only from it
local PAL = {
  "#74462a", "#4a2c1a", "#2a1a10",                         -- umber outline
  "#ecc58a", "#d9a660", "#b07a45", "#8a4f2a", "#5e2f1e",   -- wood
  "#ff9158", "#f2793a", "#dd3a2a", "#ae2a2a",              -- red (roof tiles, cushion, spice)
  "#fff1c8", "#f5cf6a", "#e8a317", "#b8661a",              -- gold (marigold, cat, fish sign)
  "#f1ece0", "#d8c49a",                                    -- cream (walls, snow, sacks)
  "#c4e4f1", "#d8eef6",                                    -- sky
  "#9a8fa8",                                               -- far peaks
  "#3f8fb0", "#2f6290",                                    -- teal (glass, shutters, yarn)
  "#7ab55c",                                               -- green (plants)
}
local WOOD  = { gloss = "#ecc58a", dot = "#fff1c8", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#8a4f2a" }
local DWOOD = { gloss = "#b07a45", dot = "#d9a660", rim = "#b07a45", base = "#8a4f2a", shade = "#5e2f1e", deep = "#4a2c1a", bounce = "#5e2f1e" }
local RED   = { gloss = "#ff9158", dot = "#fff1c8", rim = "#f2793a", base = "#dd3a2a", shade = "#ae2a2a", deep = "#5e2f1e", bounce = "#ae2a2a" }
local ORNG  = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#ff9158", base = "#f2793a", shade = "#ae2a2a", deep = "#5e2f1e", bounce = "#b8661a" }
local GOLD  = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a", deep = "#8a4f2a", bounce = "#b8661a" }
local CREAM = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#fff1c8", base = "#f1ece0", shade = "#d8c49a", deep = "#b07a45", bounce = "#d8c49a" }
local TEAL  = { gloss = "#d8eef6", dot = "#d8eef6", rim = "#c4e4f1", base = "#3f8fb0", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290" }
local GREEN = { gloss = "#f5cf6a", dot = "#fff1c8", rim = "#7ab55c", base = "#7ab55c", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290" }

local function part(m, r, o) return c:part(m, r, o) end
local function tri(x0, y0, x1, y1, x2, y2) return c:poly({ { x0, y0 }, { x1, y1 }, { x2, y2 } }) end

---------------------------------------------------------------- sky and far peaks (no outline)
c:bands(c:rect(0, 0, W - 1, 38), { "#c4e4f1", "#d8eef6", "#d8eef6", "#fff1c8" })
local function peak(ax, ay, x0, x1, base)
  local m = c:poly({ { x0, base }, { ax, ay }, { x1, base } })
  c:fill(m, "#9a8fa8")
  -- snow cap: zigzag lower edge
  local depth = math.floor((base - ay) * 0.38)
  local sn = c:mask()
  m:each(function(x, y)
    local zig = ((x // 3) % 2 == 0) and 0 or 2
    if y <= ay + depth + zig then sn:set(x, y) end
  end)
  c:fill(sn, "#f1ece0")
  -- lit left flank of the snow
  sn:each(function(x, y) if not m:has(x - 1, y) then c:px(x, y, "#fff1c8") end end)
end
peak(26, 9, -6, 60, 38); peak(66, 4, 34, 104, 38); peak(176, 6, 136, 214, 38); peak(218, 11, 190, 252, 38)
-- low warm haze ridge
c:fill(c:poly({ { 0, 38 }, { 0, 31 }, { 30, 29 }, { 70, 32 }, { 120, 30 }, { 170, 32 }, { 210, 29 }, { 240, 31 }, { 240, 38 } }), "#d8c49a")

---------------------------------------------------------------- ground (no outline)
c:fill(c:rect(0, 50, W - 1, H - 1), "#d9a660")
c:fill(c:rect(0, 50, W - 1, 50), "#ecc58a")
for i = 0, 40 do
  local x, y = (i * 37) % 236 + 1, 53 + (i * 7) % 5
  c:px(x, y, "#b07a45"); c:px(x + 1, y, "#b07a45")
end

---------------------------------------------------------------- prayer-flag bunting (behind the houses' fronts)
local flagCols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c", "#f1ece0" }
local function bunting(x0, y0, x1, y1, sag, phase)
  local n = math.abs(x1 - x0)
  local pts = {}
  for i = 0, n do
    local t = i / n
    local x = math.floor(x0 + (x1 - x0) * t + 0.5)
    local y = math.floor(y0 + (y1 - y0) * t + sag * math.sin(t * math.pi) + 0.5)
    pts[#pts + 1] = { x, y }
    c:px(x, y, "#8a4f2a")
  end
  local k = phase
  for i = 4, #pts - 3, 6 do
    local p = pts[i]
    c:paint({ "aaa", "aa.", "a.." }, p[1] - 1, p[2] + 1, { a = flagCols[(k % 5) + 1] })
    k = k + 1
  end
end
bunting(2, 14, 92, 9, 6, 0)
bunting(148, 9, 238, 14, 6, 2)

---------------------------------------------------------------- left houses (midground)
-- house A: cream wall, flat wood roof, stall awning and spice heaps
part(c:rect(2, 22, 36, 50), CREAM, { gloss = false })
part(c:rrect(0, 19, 38, 22, 1), WOOD, { gloss = false })
part(c:rect(8, 26, 14, 31), TEAL, { flat = true })
part(c:rect(24, 26, 30, 31), TEAL, { flat = true })
local awnA = c:poly({ { 0, 34 }, { 39, 34 }, { 41, 39 }, { -2, 39 } })
part(awnA, RED, { gloss = false })
awnA:each(function(x, y) if (x // 4) % 2 == 1 and y < 38 then c:px(x, y, "#f1ece0") end end)
part(c:rect(2, 44, 36, 50), WOOD, { gloss = false })
for i, col in ipairs({ RED, GOLD, ORNG, GOLD }) do
  local x = 4 + (i - 1) * 8
  part(c:poly({ { x, 44 }, { x + 3, 40 }, { x + 4, 40 }, { x + 7, 44 } }), col, { flat = true })
end
-- house B: taller, sloped wood roof, carved balcony
part(c:rect(42, 20, 72, 50), CREAM, { gloss = false })
part(c:poly({ { 38, 21 }, { 76, 21 }, { 68, 13 }, { 46, 13 } }), WOOD, { gloss = false })
part(c:rect(48, 25, 54, 31), TEAL, { flat = true })
part(c:rect(60, 25, 66, 31), TEAL, { flat = true })
part(c:rrect(44, 33, 70, 36, 0), DWOOD, { flat = true })
for x = 46, 68, 3 do c:px(x, 34, "#d9a660") end
part(c:rect(51, 39, 63, 50), TEAL, { gloss = false })   -- door

---------------------------------------------------------------- right houses (midground)
part(c:rect(168, 20, 200, 50), CREAM, { gloss = false })
part(c:poly({ { 164, 21 }, { 204, 21 }, { 196, 13 }, { 172, 13 } }), WOOD, { gloss = false })
part(c:rect(174, 25, 180, 31), TEAL, { flat = true })
part(c:rect(188, 25, 194, 31), TEAL, { flat = true })
part(c:rrect(170, 33, 198, 36, 0), DWOOD, { flat = true })
for x = 172, 196, 3 do c:px(x, 34, "#d9a660") end
part(c:rect(177, 39, 189, 50), TEAL, { gloss = false })
part(c:rect(204, 23, 238, 50), CREAM, { gloss = false })
part(c:rrect(202, 20, 240, 23, 1), WOOD, { gloss = false })
part(c:rect(210, 27, 216, 32), TEAL, { flat = true })
part(c:rect(226, 27, 232, 32), TEAL, { flat = true })
local awnD = c:poly({ { 201, 35 }, { 240, 35 }, { 242, 40 }, { 199, 40 } })
part(awnD, GOLD, { gloss = false })
awnD:each(function(x, y) if (x // 4) % 2 == 0 and y < 39 then c:px(x, y, "#f1ece0") end end)
part(c:rect(204, 44, 238, 50), WOOD, { gloss = false })
for i, col in ipairs({ ORNG, RED, GOLD, RED }) do
  local x = 206 + (i - 1) * 8
  part(c:poly({ { x, 44 }, { x + 3, 40 }, { x + 4, 40 }, { x + 7, 44 } }), col, { flat = true })
end

---------------------------------------------------------------- the pet shop (focal)
-- upper roof with cat-ear ridge ends
local roofU = c:poly({ { 90, 15 }, { 150, 15 }, { 141, 7 }, { 99, 7 } })
roofU:add(tri(98, 8, 102, 1, 107, 8)):add(tri(133, 8, 138, 1, 142, 8))
local pU = part(roofU, RED, { gloss = { 100, 9 } })
-- inner ears (cream) and tile rows
c:fill(tri(101, 7, 102, 4, 105, 7):clip(pU.m), "#f1ece0")
c:fill(tri(135, 7, 138, 4, 139, 7):clip(pU.m), "#f1ece0")
for x = 94, 146, 4 do c:px(x, 12, "#ae2a2a"); c:px(x + 2, 10, "#ae2a2a") end
-- upper storey wall with carved beams
part(c:rect(92, 15, 148, 26), CREAM, { gloss = false })
part(c:rect(92, 15, 148, 16), DWOOD, { flat = true })
-- side lattice windows
for _, x0 in ipairs({ 96, 134 }) do
  part(c:rect(x0, 18, x0 + 10, 25), WOOD, { flat = true })
  part(c:rect(x0 + 2, 19, x0 + 8, 24), TEAL, { flat = true })
  for y = 19, 24 do c:px(x0 + 5, y, "#8a4f2a") end
  for x = x0 + 2, x0 + 8 do c:px(x, 21, "#8a4f2a") end
end
-- round cat-face window: wood ring, ears, teal glass, whisker carving
local ring = c:ellipse(120, 20.5, 6.5, 5.5)
ring:add(tri(113, 18, 114, 12, 118, 16)):add(tri(122, 16, 126, 12, 127, 18))
part(ring, WOOD, { flat = true })
local glass = c:ellipse(120, 20.5, 4.5, 3.5)
part(glass, TEAL, { flat = true })
c:px(118, 20, "#f5cf6a"); c:px(122, 20, "#f5cf6a")             -- lamp-lit cat eyes in the glass
c:px(120, 22, "#2f6290"); c:px(119, 23, "#2f6290"); c:px(121, 23, "#2f6290")
-- lower eave, wide
local eave = c:poly({ { 74, 31 }, { 166, 31 }, { 157, 26 }, { 83, 26 } })
local pE = part(eave, RED, { gloss = { 86, 27 } })
for x = 80, 160, 4 do c:px(x, 29, "#ae2a2a") end
-- shop front: dark interior with shelves
part(c:rect(88, 31, 152, 46), DWOOD, { flat = true, contact = false })
for _, y in ipairs({ 37, 42 }) do c:fill(c:rect(89, y, 151, y), "#b07a45"); c:fill(c:rect(89, y + 1, 151, y + 1), "#5e2f1e") end
-- shelf goods: yarn balls, fish toys, a little cat bed
local function yarn(x, y, r) local m = c:ellipse(x, y, 2.5, 2.5) part(m, r, { flat = true }) c:px(x, y, r.shade) c:px(x - 1, y + 1, r.shade) end
yarn(93, 35, RED); yarn(99, 35, TEAL); yarn(105, 35, GOLD)
yarn(136, 35, TEAL); yarn(142, 35, RED); yarn(148, 35, CREAM)
for _, fx in ipairs({ 92, 140 }) do
  part(c:poly({ { fx, 39 }, { fx + 6, 39 }, { fx + 8, 41 }, { fx + 6, 42 }, { fx, 42 } }):add(tri(fx - 3, 38, fx, 40, fx - 3, 43)), GOLD, { flat = true })
  c:px(fx + 6, 40, "#4a2c1a")
end
part(c:rrect(100, 38, 110, 42, 1), CREAM, { flat = true })
c:fill(c:rect(102, 39, 108, 40), "#dd3a2a")
-- kitten peeking from the shelf bed (closed happy eyes)
part(c:ellipse(105, 37, 2.5, 2):add(tri(102, 36, 103, 33, 105, 35)):add(tri(105, 35, 107, 33, 108, 36)), GOLD, { flat = true })
c:px(104, 37, "#4a2c1a"); c:px(106, 37, "#4a2c1a")
-- the hanging hook-and-bell chime in the opening centre
c:fill(c:rect(120, 31, 120, 34), "#8a4f2a")
part(c:ellipse(120, 36, 2, 2), GOLD, { flat = true })
c:px(120, 37, "#8a4f2a")
-- posts
part(c:rect(84, 31, 88, 50), WOOD, { gloss = false })
part(c:rect(152, 31, 156, 50), WOOD, { gloss = false })
-- marigold garland swags under the eave, with hanging strands at the posts
local function swag(x0, x1, y0, sag)
  local n = x1 - x0
  for i = 0, n, 2 do
    local t = i / n
    local x = x0 + i
    local y = math.floor(y0 + sag * math.sin(t * math.pi) + 0.5)
    c:paint({ "ab", "bc" }, x, y, { a = "#f5cf6a", b = "#f2793a", c = "#ae2a2a" })
  end
end
swag(89, 105, 31, 4); swag(105, 135, 31, 3); swag(135, 151, 31, 4)
for y = 32, 42, 2 do c:paint({ "ab", "bc" }, 86, y, { a = "#f5cf6a", b = "#f2793a", c = "#ae2a2a" }) end
for y = 32, 42, 2 do c:paint({ "ab", "bc" }, 153, y, { a = "#f5cf6a", b = "#f2793a", c = "#ae2a2a" }) end
-- counter
local counter = c:rrect(86, 45, 154, 51, 1)
local pC = part(counter, WOOD, { gloss = { 90, 46 } })
for x = 90, 150, 10 do c:fill(c:rect(x, 48, x + 6, 49), "#8a4f2a") end
-- spice baskets on the counter (left)
for i, col in ipairs({ RED, GOLD, ORNG }) do
  local x = 90 + (i - 1) * 11
  part(c:poly({ { x, 41 }, { x + 4, 38 }, { x + 5, 38 }, { x + 9, 41 } }), col, { flat = true })
  part(c:rrect(x, 41, x + 9, 45, 1), DWOOD, { flat = true })
  c:px(x + 2, 43, "#b07a45"); c:px(x + 5, 43, "#b07a45"); c:px(x + 8, 43, "#b07a45")
end
-- ginger cat napping on a red cushion (right of the counter)
local cushion = c:rrect(124, 41, 150, 45, 2)
local pK = part(cushion, RED, { gloss = false })
c:seam({ { 126, 43 }, { 148, 43 } })
local body = c:ellipse(139, 38.5, 9, 3.5)
local head = c:ellipse(128.5, 37.5, 4.5, 3.5)
head:add(tri(124, 36, 125, 31, 128, 34)):add(tri(129, 34, 132, 31, 133, 36))
local tail = c:line({ { 147, 40 }, { 150, 43 }, { 151, 47 }, { 149, 49 } }, 2)
local cat = body:copy():add(head)
part(body, GOLD, { light = cat, gloss = { 135, 36 } })
part(head, GOLD, { light = cat, gloss = false, contour = false })
part(tail, GOLD, { flat = true })
-- tabby stripes, closed smiling eyes, nose
for _, x in ipairs({ 136, 140, 144 }) do c:px(x, 36, "#b8661a"); c:px(x + 1, 36, "#b8661a") end
c:px(126, 37, "#4a2c1a"); c:px(127, 38, "#4a2c1a")
c:px(130, 38, "#4a2c1a"); c:px(131, 37, "#4a2c1a")
c:px(128, 39, "#ae2a2a"); c:px(129, 39, "#ae2a2a")
-- hanging fish sign (no text) on a bracket from the left post
c:fill(c:rect(76, 31, 84, 31), "#5e2f1e")
c:px(78, 32, "#5e2f1e"); c:px(82, 32, "#5e2f1e")
local fish = c:ellipse(80, 36.5, 5, 3):add(tri(73, 33, 76, 36, 73, 40))
part(fish, GOLD, { gloss = { 78, 35 } })
c:px(83, 36, "#2a1a10")
c:px(79, 35, "#b8661a"); c:px(79, 37, "#b8661a"); c:px(80, 36, "#b8661a")
-- potted marigolds either side of the step
for _, px0 in ipairs({ 76, 158 }) do
  part(c:rrect(px0, 45, px0 + 6, 51, 1), ORNG, { gloss = false })
  local bush = c:ellipse(px0 + 3, 42.5, 4, 3)
  part(bush, GREEN, { flat = true })
  c:paint({ "a.b", ".c.", "b.a" }, px0 + 2, 41, { a = "#e8a317", b = "#f2793a", c = "#f5cf6a" })
end
-- doorstep
part(c:rect(80, 51, 160, 53), CREAM, { flat = true })

---------------------------------------------------------------- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

---------------------------------------------------------------- palette guard: snap any stray colour to PAL
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local okset = {}
for _, h in ipairs(PAL) do okset[h] = true end
local stray = 0
for k, h in pairs(c.pix) do
  if not okset[h] then
    stray = stray + 1
    local r, g, b = rgb(h)
    local best, bd = PAL[1], 1e9
    for _, q in ipairs(PAL) do
      local r2, g2, b2 = rgb(q)
      local d = (r - r2) ^ 2 + (g - g2) ^ 2 + (b - b2) ^ 2
      if d < bd then best, bd = q, d end
    end
    c.pix[k] = best
  end
end
print("stray colours snapped: " .. stray)

local t = c:save(OUT .. "banner-CSA-pets.aseprite", OUT .. "banner-CSA-pets.png")
print(GV.report(t))
assert(t.semi == 0 and t.w == 480 and t.h == 120)

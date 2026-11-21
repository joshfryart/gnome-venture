-- harvest-puff.lua : dust puff when a plant is pulled (harvest-art-spec group 4).
-- Strip 96x24 = 4 frames of 24x24: 1 tight cloud, 2 round puffs, 3 spread with gaps,
-- 4 three faint crumbs. Cream family (GV.R.cream) + stone #c9c5bc / #8b8f96.
-- Scene mode (no auto outline / black border: FX this small would drown in a 2 px pen);
-- outline is hand-placed 1 px umber (pale rule: #4a2c1a, #2a1a10 lower right), frames 1-2 only.
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/extras-pixel/"
local F, N = 24, 4
local c = GV.canvas{ w = F * N, h = F, mode = "scene" }
local R = GV.R.cream
local STONE, STONE_D = "#c9c5bc", "#8b8f96"

-- one shaded cloud mask at frame offset ox: base, 1 px gloss nub upper-left, lower-right
-- crescent (shade, deep only when outlined), optional 1 px pale-safe outline
local function cloud(m, o)
  local x0, y0, x1, y1 = m:bbox()
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  m:each(function(x, y)
    local col = o.base or R.base
    if not m:has(x + 2, y + 2) then col = o.shade or R.shade end
    if o.deep and not m:has(x + 1, y + 1) and (x - cx) + (y - cy) > 0 then col = R.deep end
    c:px(x, y, col)
  end)
  if o.outline then
    local ring = m:grow(1):cut(m)
    ring:each(function(x, y)
      c:px(x, y, ((x - cx) + (y - cy) > 2) and GV.C.ol3 or GV.C.ol2)
    end)
  end
  for _, g in ipairs(o.gloss or {}) do c:px(g[1], g[2], R.gloss) end
end
local function E(ox, cx, cy, rx, ry) return c:ellipse(ox + cx, cy, rx, ry) end

-- frame 1: tight cloud hugging the soil line
local ox = 0
local m = E(ox, 11.5, 17, 5, 3):add(E(ox, 9, 15, 3, 3)):add(E(ox, 14.5, 14.5, 3, 3))
cloud(m, { outline = true, deep = true, gloss = { { ox + 8, 13 }, { ox + 9, 13 } } })

-- frame 2: three round puffs, bigger, lobes clearly separate on top
ox = 24
local sideL, sideR, top = E(ox, 6, 16, 4, 4), E(ox, 17, 16, 4, 4), E(ox, 11.5, 10.5, 4.5, 4.5)
m = sideL:copy():add(sideR):add(top):add(E(ox, 11.5, 18, 6, 1.5)):add(E(ox, 11.5, 15.5, 3, 2.5))
cloud(m, { outline = true, deep = true,
  gloss = { { ox + 4, 14 }, { ox + 3, 15 }, { ox + 9, 8 }, { ox + 10, 7 }, { ox + 15, 14 } } })
-- frame 3: spread with gaps, no outline, lighter crescent
ox = 48
for _, b in ipairs({ { 3.5, 14, 2.5, 2.5 }, { 19.5, 13, 2.5, 2.5 }, { 11.5, 7, 3, 2.5 }, { 7.5, 19.5, 1.5, 1.5 }, { 16, 19.5, 1.5, 1.5 } }) do
  cloud(E(ox, b[1], b[2], b[3], b[4]), { shade = STONE })
end
c:px(ox + 2, 13, R.gloss); c:px(ox + 18, 12, R.gloss); c:px(ox + 10, 6, R.gloss)

-- frame 4: three faint crumbs, drifting up and out
ox = 72
c:paint({ "ab", "bd" }, ox + 1, 10, { a = STONE, b = STONE, d = STONE_D })
c:paint({ "ab", "bd" }, ox + 20, 9, { a = STONE, b = STONE, d = STONE_D })
c:paint({ "a" }, ox + 11, 3, { a = STONE })

local t = c:save(nil, O .. "png/harvest-puff.png")
-- framed .aseprite: 4 frames of 24x24, 80 ms each (~320 ms)
local strip = c:image()
local spr = Sprite(F, F, ColorMode.RGB)
for i = 1, N do
  if i > 1 then spr:newEmptyFrame(i) end
  local img = Image(F, F, ColorMode.RGB)
  img:drawImage(strip, Point(-(i - 1) * F, 0))
  spr:newCel(spr.layers[1], i, img, Point(0, 0))
  spr.frames[i].duration = 0.08
end
spr:saveAs(O .. "aseprite/harvest-puff.aseprite")
spr:close()
print("harvest-puff " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.w == 96 and t.h == 24)

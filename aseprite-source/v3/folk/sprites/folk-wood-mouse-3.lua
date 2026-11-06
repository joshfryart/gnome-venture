-- folk-wood-mouse-3 sprite (folk F1_2) variant: 3
local VAR = 3
local NAME = "folk-wood-mouse-3"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local function R(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
local INK = "#2b1c26"
local PINK = R("#f8c0b0", "#e8968e", "#b86a78", "#7e4a62")
local BELLY = R("#fbeed2", "#ecd6b0", "#c8a890", "#94788a")
local FUR = ({ R("#e0a060", "#b8743c", "#8a4f34", "#5e3434"), R("#d8b88a", "#a88a68", "#7a6058", "#4f3e4a"), R("#f0a868", "#c86a3a", "#93453a", "#633040") })[VAR]
local GREEN = R("#a8d468", "#6aa848", "#3f7a4a", "#2c4f48")
local STRAW = R("#f8e09a", "#e0b860", "#b08848", "#7a5a44")
local TEAL = R("#7fd6c8", "#3aa8a0", "#2a7480", "#24485e")
local RUST = R("#d89a62", "#a86440", "#7a4038", "#4e2c3a")
local LEATH = R("#c8945a", "#946038", "#683e34", "#422a32")
local ROLL = R("#eed8b0", "#c8a878", "#967860", "#5e4a52")
local GLOW = R("#fff2a8", "#f8c848", "#d88a30", "#9a5430")
local METAL = R("#d0cad8", "#9a90a8", "#686078", "#443c54")
local PLUM = R("#c890c8", "#9a5a9a", "#6c3c78", "#46284e")
local APRON = R("#fff4dc", "#f0dcb8", "#c8b0a0", "#8a7888")
local RED = R("#ff9a7a", "#e05a48", "#a83a44", "#6e2a3e")
local WOOD = R("#e8c088", "#c08a54", "#8a5a40", "#5a3a38")
local DISC = ({ R("#d8f0b0", "#b8d88a", "#8ab474", "#5f8a62"), R("#b8eee4", "#8ccfc4", "#62a8a6", "#427e86"), R("#f0d0e8", "#d8a8d0", "#b080b0", "#845a8c") })[VAR]
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tt, ex = p.b or 0, p.tt or 0, p.ear or 0
  local function P(m, r, o) c:part(m, r, o or { band = 1, nopop = true, inner = false }) return m end
  c:groundShadow(32, 89.5, 13, 3)
  -- long thin wood-mouse tail curling up behind
  P(c:line({ { 40, 84 }, { 47, 87 }, { 53, 84 }, { 55, 78 }, { 54 + tt, 72 } }, 2), FUR)
  if VAR == 2 then -- travel pack + bedroll behind
    P(c:rrect(17, 62 + b, 46, 80 + b, 3), LEATH, { band = 2, pop = { x = 19, y = 64 + b } })
    P(c:rrect(15, 57 + b, 48, 62 + b, 2), ROLL, { band = 1, pop = { x = 16, y = 58 + b } })
    for _, x in ipairs{ 17, 18, 45, 46 } do for y = 58, 61 do c:put(x, y + b, TEAL.shade) end end
  end
  for _, x in ipairs{ 27, 37 } do P(c:ellipse(x + 0.5, 88, 3.5, 2), PINK) end
  P(c:rect(25, 58 + b, 38, 66 + b), FUR)
  local CL = VAR == 1 and FUR or VAR == 2 and RUST or PLUM
  local body = c:ellipse(32, 75 + b, 12, 11):clip(c:rect(0, 0, 63, 87))
  P(body, CL, { band = 2, pop = { x = 25, y = 68 + b } })
  if VAR == 1 then
    P(c:ellipse(32, 72 + b, 6, 5):clip(body), BELLY)
    local dg = body:copy():clip(c:rect(0, 77 + b, 63, 87)):add(c:rect(26, 70 + b, 37, 77 + b))
    P(dg, GREEN, { band = 2, nopop = true })
    P(c:line({ { 27, 70 + b }, { 25, 65 + b } }, 2), GREEN) P(c:line({ { 36, 70 + b }, { 38, 65 + b } }, 2), GREEN)
    c:put(27, 71 + b, STRAW.hi) c:put(36, 71 + b, STRAW.hi)
    for x = 29, 34 do if x % 2 == 0 then c:put(x, 74 + b, GREEN.shade) end end
  elseif VAR == 2 then
    P(c:rect(20, 79 + b, 44, 80 + b):clip(body), LEATH) c:put(31, 79 + b, GLOW.base) c:put(32, 79 + b, GLOW.base)
    P(c:rrect(21, 61 + b, 42, 65 + b, 2), TEAL, { band = 1, pop = { x = 23, y = 62 + b } })
    local hs = p.hs or 0
    P(c:poly{ { 34, 64 + b }, { 39, 64 + b }, { 39 + hs, 74 + b }, { 35 + hs, 74 + b } }, TEAL, { band = 1, nopop = true })
    for x = 35, 39, 2 do c:put(x + hs, 75 + b, TEAL.shade) end
    c:put(36 + hs, 69 + b, TEAL.deep) c:put(37 + hs, 69 + b, TEAL.deep) c:put(38 + hs, 69 + b, TEAL.deep)
  else
    local ap = c:rrect(25, 68 + b, 38, 87, 2):clip(body)
    P(ap, APRON, { band = 1, pop = { x = 26, y = 69 + b } })
    P(c:rrect(28, 77 + b, 35, 81 + b, 1), APRON, { band = 1, nopop = true })
    for x = 28, 35 do if (x + 1) % 2 == 0 then c:put(x, 76 + b, PLUM.shade) end end
  end
  -- props held in paws (behind paw)
  if VAR == 1 then
    P(c:rect(44, 75 + b, 45, 81 + b), WOOD)
    P(c:poly{ { 42, 82 + b }, { 47, 82 + b }, { 44.5, 88 + b } }, METAL, { band = 1, pop = { x = 43, y = 82 + b }, inner = false })
  elseif VAR == 3 then
    P(c:line({ { 45, 80 + b }, { 48, 64 + b } }, 2), WOOD)
    P(c:ellipse(48.5, 61 + b, 3.5, 2.5), WOOD, { band = 1, pop = { x = 46, y = 59 + b }, inner = false })
    c:put(48, 60 + b, WOOD.deep) c:put(49, 60 + b, WOOD.deep)
  end
  local AR = VAR == 1 and FUR or CL
  for _, x in ipairs{ 19.5, 44.5 } do P(c:ellipse(x, 74 + b, 3, 4.5), AR) P(c:ellipse(x, 79 + b, 2.5, 2), PINK) end
  if VAR == 2 then
    c:put(18, 81 + b, METAL.shade) c:put(21, 81 + b, METAL.shade)
    P(c:rect(17, 82 + b, 22, 82 + b), METAL)
    P(c:rect(17, 83 + b, 22, 86 + b), GLOW, { band = 1, pop = { x = 18, y = 84 + b }, inner = false })
    c:put(17, 84 + b, METAL.base) c:put(22, 85 + b, METAL.shade)
    P(c:rect(16, 87 + b, 23, 87 + b), METAL)
  end
  local function ear(cx, dx, dy)
    P(c:ellipse(cx + dx, 37 + b + dy, 6.5, 6.5), FUR, { band = 2, nopop = true, inner = false })
    P(c:ellipse(cx + dx + 0.5, 37.5 + b + dy, 4, 4.5), PINK, { band = 1, pop = { x = math.floor(cx + dx) - 2, y = 35 + b + dy }, inner = false })
  end
  if VAR ~= 1 then ear(19, 0, 0) ear(45, ex, -ex) end
  local head = c:ellipse(32, 50 + b, 14.5, 11.5)
  P(head, FUR, { band = 2, pop = { x = 24, y = 41 + b } })
  P(c:ellipse(32, 57 + b, 7, 4.5), BELLY)
  P(c:ellipse(32, 56.5 + b, 2, 1.5), PINK, { band = 1, pop = { x = 31, y = 55 + b }, inner = false })
  c:put(31, 59 + b, PINK.deep) c:put(32, 59 + b, PINK.deep) c:put(30, 60 + b, PINK.deep) c:put(33, 60 + b, PINK.deep)
  for _, q in ipairs{ { 26, 57 }, { 27, 59 }, { 37, 57 }, { 36, 59 } } do c:put(q[1], q[2] + b, FUR.shade) end
  c:cheek(21, 55 + b) c:cheek(41, 55 + b)
  local function eye(x, y)
    if p.blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
    for dy = 0, 3 do for dx = 0, 3 do if not ((dx == 0 or dx == 3) and (dy == 0 or dy == 3)) then c:put(x + dx, y + dy, INK) end end end
    c:put(x + 1, y + 1, "#f4e8d8") c:put(x + 2, y + 2, "#4e3a5e")
  end
  eye(22, 49 + b) eye(38, 49 + b)
  if VAR == 1 then
    local hm = c:ellipse(32, 43 + b, 17, 4):add(c:rrect(24, 34 + b, 39, 43 + b, 3))
    P(hm, STRAW, { band = 2, pop = { x = 26, y = 35 + b } })
    for x = 16, 48 do if x % 3 == 0 and hm:has(x, 45 + b) then c:put(x, 45 + b, STRAW.shade) end end
    for x = 25, 38 do if x % 2 == 0 then c:put(x, 37 + b, STRAW.shade) end end
    P(c:rect(24, 40 + b, 39, 41 + b), GREEN)
    P(c:ellipse(37, 38 + b, 1.5, 1), GREEN) P(c:ellipse(39, 36.5 + b, 1.5, 1.5), GREEN) c:put(38, 37 + b, GREEN.deep)
    ear(19, 0, -2) ear(45, ex, -2 - ex)
  elseif VAR == 3 then
    local k = head:copy():clip(c:rect(0, 0, 63, 43 + b))
    P(k, RED, { band = 1, pop = { x = 24, y = 41 + b } })
    P(c:ellipse(45, 42 + b, 2.5, 2), RED) P(c:poly{ { 46, 42 + b }, { 51, 39 + b }, { 50, 44 + b } }, RED)
    for _, q in ipairs{ { 26, 41 }, { 30, 39 }, { 35, 40 }, { 39, 41 }, { 33, 42 } } do if k:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, APRON.hi) end end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local PS = { { b = 0 }, { b = 1, tt = -1, hs = 1 }, { b = 0 }, { b = 0, blink = true, ear = 1, tt = 1 } }
local frames = {}
for _, p in ipairs(PS) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")

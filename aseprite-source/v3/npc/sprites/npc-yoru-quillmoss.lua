-- npc-yoru-quillmoss sprite (npc2 P1_40) species: harvest mouse (scribe)
-- 64x96 2.5D idle(4). Calm old scribe mouse: violet robe with gold hem, moss skullcap with a sprout,
-- big round ears, long pink tail. Prop: an ink-dipped quill feather held upright.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/npc/sprites/"
local NAME = "npc-yoru-quillmoss"
local FUR  = { hi = "#e9c79e", base = "#c8966e", shade = "#8f6678", deep = "#5c4060" }
local PINK = { hi = "#f8b4bc", base = "#e27c94", shade = "#a94e78", deep = "#6f3258" }
local ROBE = { hi = "#a283d6", base = "#7458ae", shade = "#4f3a86", deep = "#35275e" }
local MOSS = { hi = "#b4d46a", base = "#76a03e", shade = "#46704a", deep = "#2f4a44" }
local CRM  = { hi = "#f8eed6", base = "#ecd9b6", shade = "#c4aca4", deep = "#8c768c" }
local GOLD = { hi = "#ffe08a", base = "#f0b440", shade = "#c07a3c", deep = "#84503e" }

local function blade(ax, ay, bx, by, wf)
  local m = HP.mask()
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local n = math.ceil(L * 3)
  for i = 0, n do
    local t = i / n
    local cx, cy = ax + dx * t, ay + dy * t
    local w = wf(t)
    local s = -w
    repeat m:set(math.floor(cx + nx * s), math.floor(cy + ny * s)) s = s + 0.34 until s > w
  end
  return m
end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, e, q, tw = p.b or 0, p.e or 0, p.q or 0, p.tw or 0
  c:groundShadow(32, 89, 13, 2.5)
  -- long tail curling up behind on the right
  c:part(c:line({ { 41, 84 }, { 50, 85 }, { 56, 80 + tw }, { 55, 74 + tw }, { 53, 72 + tw } }, 2), PINK, { band = 1, nopop = true })
  -- feet (fixed)
  for _, fx in ipairs{ 26.5, 37.5 } do c:part(c:ellipse(fx, 88, 3.5, 2), PINK, { band = 1, nopop = true }) end
  -- robe: round chest, flared hem fixed at y=86
  local robe = c:ellipse(32, 72 + b, 11, 11)
  robe:add(c:poly{ { 22, 74 + b }, { 42, 74 + b }, { 45, 86 }, { 19, 86 } })
  c:part(robe, ROBE, { band = 3, pop = { x = 25, y = 66 + b } })
  for y = 77 + b, 84 do c:put(33, y, ROBE.shade) end
  for x = 18, 46 do
    if robe:has(x, 85) then c:put(x, 85, GOLD.base) end
    if robe:has(x, 86) then c:put(x, 86, x > 36 and GOLD.deep or GOLD.shade) end
  end
  c:put(21, 85, GOLD.hi) c:put(22, 85, GOLD.hi)
  -- moss stole
  local st = c:ellipse(32, 62 + b, 10.5, 3)
  for _, x in ipairs{ 23, 27, 31, 35, 39 } do st:add(HP.ellipse(x, 64 + b, 1.5, 1.5)) end
  c:part(st, MOSS, { band = 1, pop = { x = 25, y = 61 + b } })
  -- left sleeve + paw
  c:part(c:ellipse(21, 70 + b, 3, 4.5), ROBE, { band = 1, nopop = true })
  c:part(c:ellipse(21, 75 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- right sleeve, quill, paw on top
  c:part(c:ellipse(43, 69 + b, 3, 4.5), ROBE, { band = 2, nopop = true })
  local qm = blade(45, 80 + b, 54 + q, 42 + b, function(t) if t < 0.22 then return 0 end return 2.6 * math.sin((t - 0.18) / 0.82 * math.pi) end)
  c:part(qm, CRM, { band = 1, nopop = true })
  c:fillMask(c:line({ { 46, 76 + b }, { 53 + q, 44 + b } }, 1):clip(qm), CRM.shade)
  for y = 78 + b, 80 + b do qm:each(function(x, yy) if yy == y then c:put(x, yy, ROBE.deep) end end) end
  c:part(c:ellipse(44, 74 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- ears (settle by e)
  for _, ex in ipairs{ 18, 46 } do
    c:part(c:ellipse(ex, 32 + b + e, 7, 6.5), FUR, { band = 2, nopop = true })
    c:part(c:ellipse(ex + (ex < 32 and 0.5 or -0.5), 33 + b + e, 4, 3.5), PINK, { band = 1, nopop = true })
  end
  -- head
  local head = c:ellipse(32, 44 + b, 14, 11.5)
  c:part(head, FUR, { band = 3, pop = { x = 24, y = 39 + b } })
  -- moss skullcap (top of head seen from above) + sprout
  local cap = head:copy():clip(c:rect(0, 0, 63, 37 + b))
  for x = 20, 44, 4 do cap:add(HP.ellipse(x, 37 + b, 1.5, 1.5)) end
  c:part(cap, MOSS, { band = 2, pop = { x = 27, y = 34 + b } })
  for _, d in ipairs{ { 25, 35 }, { 33, 34 }, { 38, 36 }, { 29, 36 } } do c:put(d[1], d[2] + b, MOSS.hi) end
  for _, d in ipairs{ { 36, 34 }, { 30, 34 }, { 41, 35 } } do c:put(d[1], d[2] + b, MOSS.shade) end
  c:fillMask(c:line({ { 33, 33 + b }, { 34, 28 + b } }, 1), MOSS.shade)
  c:part(c:ellipse(31.5, 27 + b, 2, 1), MOSS, { band = 1, nopop = true })
  c:part(c:ellipse(36.5, 26 + b, 2, 1), MOSS, { band = 1, nopop = true })
  -- face: eyes, muzzle, nose, whiskers
  if p.blink then
    for _, x in ipairs{ 24, 36 } do for i = 0, 3 do c:put(x + i, 43 + b, P.ink) end end
  else eye(c, 24, 40 + b) eye(c, 36, 40 + b) end
  c:part(c:ellipse(32, 48 + b, 6, 3.5), CRM, { band = 1, nopop = true })
  c:put(31, 45 + b, PINK.hi) c:put(32, 45 + b, PINK.base) c:put(31, 46 + b, PINK.base) c:put(32, 46 + b, PINK.shade)
  c:put(31, 49 + b, FUR.deep) c:put(32, 49 + b, FUR.deep)
  for _, d in ipairs{ { 23, 48 }, { 22, 47 }, { 23, 50 }, { 22, 51 }, { 40, 48 }, { 41, 47 }, { 40, 50 }, { 41, 51 } } do c:put(d[1], d[2] + b, FUR.deep) end
  c:put(23, 45 + b, PINK.hi) c:put(40, 45 + b, PINK.base)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local function build(frames, base)
  local pc = app.pixelColor
  local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
  local imgs = {}
  for f, c in ipairs(frames) do
    local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
    for y = 0, 95 do for x = 0, 63 do local h = c:get(x, y) if h then im:putPixel(x, y, rgba(h)) end end end
    imgs[f] = im
  end
  local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * 64, 0)) end
  local s = Sprite(256, 96, ColorMode.RGB) s.cels[1].image = strip s:saveCopyAs(base .. ".png") s:close()
  local spr = Sprite(64, 96, ColorMode.RGB)
  for _ = 2, 4 do spr:newEmptyFrame() end
  for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
  local tg = spr:newTag(1, 4) tg.name = "idle"
  spr:saveAs(base .. ".aseprite") spr:close()
end

local F = {}
for _, p in ipairs{ { b = 0 }, { b = 1, e = 1, q = -1, tw = 1 }, { b = 0 }, { b = 0, blink = true, tw = -2 } } do F[#F + 1] = frame(p) end
build(F, out .. NAME)
print(NAME .. " ok")

-- npc-yoru-quillmoss portrait (npc2 P1_40) species: harvest mouse (scribe)
-- 80x100 head+shoulders. Same design as the sprite: violet robe, moss stole + skullcap with sprout,
-- big round pink-lined ears, cream muzzle, whiskers. Prop: ink-dipped quill held up in the left paw.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/npc/portraits/"
local NAME = "npc-yoru-quillmoss"
local FUR  = { hi = "#e9c79e", base = "#c8966e", shade = "#8f6678", deep = "#5c4060" }
local PINK = { hi = "#f8b4bc", base = "#e27c94", shade = "#a94e78", deep = "#6f3258" }
local ROBE = { hi = "#a283d6", base = "#7458ae", shade = "#4f3a86", deep = "#35275e" }
local MOSS = { hi = "#b4d46a", base = "#76a03e", shade = "#46704a", deep = "#2f4a44" }
local CRM  = { hi = "#f8eed6", base = "#ecd9b6", shade = "#c4aca4", deep = "#8c768c" }
local GOLD = { hi = "#ffe08a", base = "#f0b440", shade = "#c07a3c", deep = "#84503e" }
local BG   = { base = "#a9cf86", shade = "#7fa86c", deep = "#5a8058" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
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

-- robe shoulders
local robe = c:ellipse(39.5, 108, 33, 36):clip(c:rect(0, 72, 79, 99))
c:part(robe, ROBE, { band = 3, pop = { x = 16, y = 84 } })
c:fillMask(c:line({ { 31, 84 }, { 29, 99 } }, 1):clip(robe), ROBE.shade)
c:fillMask(c:line({ { 50, 86 }, { 52, 99 } }, 1):clip(robe), ROBE.deep)
for x = 0, 79 do if robe:has(x, 98) then c:put(x, 98, GOLD.base) c:put(x, 99, x > 50 and GOLD.deep or GOLD.shade) end end
-- moss stole with tufted edge + gold clasp
local st = c:ellipse(39.5, 74, 20, 5)
for x = 22, 58, 4 do st:add(HP.ellipse(x, 78, 2, 2)) end
c:part(st, MOSS, { band = 2, pop = { x = 26, y = 71 } })
for _, d in ipairs{ { 24, 74 }, { 31, 76 }, { 45, 75 }, { 52, 77 }, { 36, 73 } } do c:put(d[1], d[2], MOSS.hi) end
c:part(c:rrect(37, 77, 42, 81, 1), GOLD, { band = 1, pop = { x = 38, y = 78 } })
-- ears
for _, ex in ipairs{ 16, 63 } do
  c:part(c:ellipse(ex, 30, 10, 10), FUR, { band = 2, pop = { x = ex - 6, y = 25 } })
  c:part(c:ellipse(ex + (ex < 40 and 0.5 or -0.5), 31.5, 6, 6.5), PINK, { band = 2, pop = { x = ex - 3, y = 27 } })
end
-- head
local head = c:ellipse(39.5, 52, 20.5, 17)
for _, q in ipairs{ { 20, 58 }, { 22, 62 }, { 59, 58 }, { 57, 62 } } do head:add(HP.ellipse(q[1], q[2], 2, 2)) end
c:part(head, FUR, { band = 3, pop = { x = 27, y = 43 } })
-- moss skullcap + sprout
local cap = head:copy():clip(c:rect(0, 0, 79, 41))
for x = 22, 58, 4 do cap:add(HP.ellipse(x, 41.5, 2, 2)) end
cap:add(c:line({ { 40, 36 }, { 41, 28 } }, 1))
cap:add(c:ellipse(37, 27, 3, 1.5)) cap:add(c:ellipse(45, 26, 3, 1.5))
c:part(cap, MOSS, { band = 2, pop = { x = 28, y = 37 } })
cap:each(function(x, y) if y > 35 and y < 41 and HP.hash and HP.hash(x, y, 7) > 0.85 then c:put(x, y, MOSS.hi) end end)
for _, d in ipairs{ { 30, 38 }, { 36, 37 }, { 44, 38 }, { 50, 39 }, { 26, 40 } } do c:put(d[1], d[2], MOSS.hi) end
for _, d in ipairs{ { 47, 36 }, { 33, 40 }, { 53, 40 } } do c:put(d[1], d[2], MOSS.shade) end
-- face
c:eyeLocked(29, 47) c:eyeLocked(46, 47)
for _, x in ipairs{ 29, 30, 31, 48, 49, 50 } do c:put(x, 45, FUR.deep) end
c:part(c:ellipse(39.5, 60, 10, 6.5), CRM, { band = 2, pop = { x = 33, y = 56 } })
c:part(c:ellipse(39.5, 56.5, 3, 2), PINK, { band = 1, pop = { x = 38, y = 55 } })
for _, d in ipairs{ { 39, 59 }, { 40, 59 }, { 36, 61 }, { 37, 62 }, { 38, 62 }, { 39, 61 }, { 40, 61 }, { 41, 62 }, { 42, 62 }, { 43, 61 } } do c:put(d[1], d[2], FUR.deep) end
for _, d in ipairs{ { 24, 56 }, { 25, 56 }, { 26, 56 }, { 53, 56 }, { 54, 56 }, { 55, 56 } } do c:put(d[1], d[2], PINK.base) end
c:put(24, 56, PINK.hi) c:put(53, 56, PINK.hi)
-- quill held up in the left paw
local qm = blade(25, 97, 9, 37, function(t) if t < 0.22 then return 0 end return 4 * math.sin((t - 0.18) / 0.82 * math.pi) end)
for _, t in ipairs{ 0.45, 0.62, 0.8 } do qm:cut(HP.ellipse(25 - 16 * t + 4, 97 - 60 * t + 1, 0.8, 0.8)) end
c:part(qm, CRM, { band = 2, nopop = true })
c:fillMask(c:line({ { 23, 88 }, { 10, 40 } }, 1):clip(qm), CRM.shade)
qm:each(function(x, y) if y >= 93 then c:put(x, y, ROBE.deep) end end)
c:part(c:ellipse(25, 96, 5, 4), ROBE, { band = 1, nopop = true })
c:part(c:ellipse(23, 88, 4, 3.5), FUR, { band = 2, pop = { x = 21, y = 86 } })
c:finish{ outline = true }
-- whiskers
for _, w in ipairs{ { { 29, 59 }, { 16, 55 } }, { { 29, 62 }, { 16, 64 } }, { { 50, 59 }, { 67, 55 } }, { { 50, 62 }, { 68, 64 } } } do
  c:fillMask(c:line(w, 1), FUR.deep)
end
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

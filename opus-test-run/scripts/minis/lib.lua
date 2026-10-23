-- minis/lib.lua : toy-miniature archetypes (Part E "Toy miniatures"). 3/4 view, faces right, stands on a round base, 1 px black border (gvx adds it).
-- Archetypes: bug, worm, snail, quad, bird, snake, crab, frog, spider, golem, wisp, octo, folk. Each takes (c, g) with g = { cx, by, u, B, A, hi, big, feat }.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local GV = X.GV
local L = { X = X, GV = GV }
local floor = math.floor
local function rd(v) return floor(v + 0.5) end

-- flat ramp (base / shade / rim) from one hex: shade and rim from GV.ramp, no extra tones, so each figure stays under its colour cap
function L.flat(hex, shade)
  local r = X.ramp(hex)
  return X.ramp(hex, { shade = shade or r.shade, deep = shade or r.shade, bounce = shade or r.shade, rim = hex, gloss = hex, dot = hex })
end
local OP = { gloss = false, cres = 2, deep = 0 }
L.OP = OP
local function part(c, m, r, o) c:part(m, r, o or OP) end
L.part = part

-- coordinate helper: figure space (a to the right, b up from the feet) -> canvas
local function P(g, a, b) return g.cx + a * g.u, g.by - b * g.u end
local function E(c, g, a, b, rx, ry) local x, y = P(g, a, b); return c:ellipse(rd(x), rd(y), math.max(1, rd(rx * g.u)), math.max(1, rd((ry or rx) * g.u))) end
local function Rc(c, g, a0, b0, a1, b1) local x0, y0 = P(g, a0, b0); local x1, y1 = P(g, a1, b1); return c:rect(rd(math.min(x0, x1)), rd(math.min(y0, y1)), rd(math.max(x0, x1)), rd(math.max(y0, y1))) end
local function Poly(c, g, pts) local t = {}; for _, p in ipairs(pts) do local x, y = P(g, p[1], p[2]); t[#t + 1] = { rd(x), rd(y) } end return c:poly(t) end
local function Limb(c, g, pts) local t = {}; for _, p in ipairs(pts) do local x, y = P(g, p[1], p[2]); t[#t + 1] = { rd(x), rd(y) } end c:limb(t) end
local function eye(c, g, a, b) local x, y = P(g, a, b); if g.big then c:eye(rd(x) - 2, rd(y) - 2) else c:eye(rd(x) - 1, rd(y) - 1, true) end end
local function smile(c, g, a, b) if g.big then local x, y = P(g, a, b); c:paint({ "u...u", ".uuu." }, rd(x) - 2, rd(y), { u = "umber" }) end end
local function dots(c, g, list, hex) for _, d in ipairs(list) do local x, y = P(g, d[1], d[2]); c:px(rd(x), rd(y), hex); if g.u >= 1.5 then c:px(rd(x) + 1, rd(y), hex) end end end

-- base: soil/stone/etc. ellipse disc. kind = "party" (moss, gold edge stitch) | "enemy" (given ramp, no stitching) | "boss" (wider, seam and button)
function L.base(c, w, h, kind, ramp)
  local u = (w <= 56) and 1 or (w <= 64 and 1.1 or (w <= 80 and 1.4 or 2))
  local rx = rd(w * (kind == "boss" and 0.36 or 0.33)); local ry = rd(4 * u + 1); local th = rd(5 * u)
  local cx = (w - 1) / 2; local cy = h - 3 - 4 - th - ry + ry   -- top-face centre
  local by = h - 4 - th - ry
  local side = ramp or L.flat("#9a6b3f", "#7a4a1f")
  part(c, c:ellipse(cx, by + th, rx, ry), side, { gloss = false, cres = 2, deep = 0 })
  part(c, c:rect(cx - rx, by, cx + rx, by + th), side, { gloss = false, flat = true, outline = false })
  part(c, c:ellipse(cx, by, rx, ry), ramp and ramp or L.flat("#9a6b3f", "#7a4a1f"), { gloss = false, cres = 2, deep = 0 })
  if kind == "party" then
    for i = 0, 360, 24 do local a = math.rad(i); local x, y = cx + math.cos(a) * (rx - 2), by + math.sin(a) * (ry - 1.5); c:px(rd(x), rd(y), "#f5cf6a") end
  elseif kind == "boss" then
    c:seam({ { cx - rx + 4, by + th - 1 }, { cx + rx - 4, by + th - 1 } }, { free = true }); c:button(rd(cx) - 2, rd(by + th) - 3)
  end
  return cx, by, u
end

-- ===== archetypes =====
local A = {}
function A.bug(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  for _, l in ipairs({ { -8, 0, -11, 6 }, { 0, 0, 0, 7 }, { 8, 0, 11, 6 } }) do Limb(c, g, { { l[1] + 2, 10 }, { l[3], 4 }, { l[1] + (l[3] > 0 and 4 or 0), 0 } }) end
  if f.wings then part(c, E(c, g, -12, 22, 8, 7), Ac, OP); part(c, E(c, g, -6, 25, 7, 6), Ac, OP) end
  part(c, E(c, g, -6, 15, 14, 10), B, { gloss = false, cres = 3, deep = 0 })           -- abdomen / shell
  if f.shell then part(c, E(c, g, -8, 17, 9, 6), Ac, OP) end
  if f.stripes then for i = -2, 1 do local x, y = P(g, -6 + i * 5, 15); c:fill(c:rect(rd(x), rd(y - 8 * g.u), rd(x) + 1, rd(y + 6 * g.u)), "#4a2c1a") end end
  if f.spots then dots(c, g, { { -10, 20 }, { -4, 22 }, { -2, 12 }, { -12, 14 } }, "#2a1a10") end
  part(c, E(c, g, 10, 17, 9, 8), B, { gloss = false, cres = 3, deep = 0 })              -- big head
  eye(c, g, 8, 19); eye(c, g, 14, 19); smile(c, g, 11, 12)
  if f.horns then part(c, Poly(c, g, { { 8, 24 }, { 6, 33 }, { 11, 25 } }), Ac, OP); part(c, Poly(c, g, { { 12, 25 }, { 17, 34 }, { 17, 24 } }), Ac, OP) end
  if f.pincers then part(c, Poly(c, g, { { 17, 14 }, { 24, 12 }, { 19, 10 } }), Ac, OP); part(c, Poly(c, g, { { 17, 12 }, { 24, 8 }, { 19, 8 } }), Ac, OP) end
  if not f.horns then Limb(c, g, { { 8, 24 }, { 5, 31 } }); Limb(c, g, { { 13, 24 }, { 16, 31 } }); part(c, Rc(c, g, 3, 31, 6, 34), GV.R.leg, { flat = true, gloss = false }); part(c, Rc(c, g, 15, 31, 18, 34), GV.R.leg, { flat = true, gloss = false }) end
end
function A.worm(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  local n = f.segs or 5
  for i = n, 1, -1 do
    local t = (i - 1) / (n - 1); local a = -16 + t * 28; local b = 6 + math.sin(t * math.pi) * 8 + t * 6
    part(c, E(c, g, a, b, 6.5 - (1 - t) * 1.5, 5.5), (i % 2 == 0 and f.band) and Ac or B, { gloss = false, cres = 2, deep = 0 })
    if f.spots and i % 2 == 1 then local x, y = P(g, a, b + 2); c:px(rd(x), rd(y), "#2a1a10") end
    if f.legs then Limb(c, g, { { a, b - 4 }, { a - 1, 0 } }) end
  end
  part(c, E(c, g, 14, 17, 9, 8), B, { gloss = false, cres = 3, deep = 0 })
  eye(c, g, 12, 19); eye(c, g, 18, 19); smile(c, g, 15, 13)
  if f.glow then local x, y = P(g, -16, 12); c:fill(c:ellipse(rd(x), rd(y), 2, 2), "#f5cf6a") end
  if f.horns then part(c, Poly(c, g, { { 12, 24 }, { 10, 32 }, { 15, 25 } }), Ac, OP) end
end
function A.snail(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  part(c, E(c, g, 4, 6, 17, 6), B, { gloss = false, cres = 2, deep = 0 })              -- foot/body
  part(c, E(c, g, -7, 17, 12, 12), Ac, { gloss = false, cres = 4, deep = 0 })          -- shell
  part(c, E(c, g, -7, 17, 6, 6), Ac, { gloss = false, flat = true })
  local x, y = P(g, -7, 17); c:fill(c:rect(rd(x) - 1, rd(y) - 1, rd(x) + 1, rd(y) + 1), "#4a2c1a")
  part(c, E(c, g, 14, 12, 8, 8), B, { gloss = false, cres = 3, deep = 0 })
  eye(c, g, 12, 14); eye(c, g, 17, 14); smile(c, g, 14, 8)
  Limb(c, g, { { 13, 18 }, { 11, 26 } }); Limb(c, g, { { 17, 18 }, { 20, 26 } })
  part(c, Rc(c, g, 9, 26, 12, 29), GV.R.leg, { flat = true, gloss = false }); part(c, Rc(c, g, 19, 26, 22, 29), GV.R.leg, { flat = true, gloss = false })
  if f.spots then dots(c, g, { { 0, 6 }, { 6, 5 }, { -3, 7 } }, "#2a1a10") end
end
function A.quad(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  local legs = { { -10, 0 }, { -4, 0 }, { 6, 0 }, { 12, 0 } }
  for i, l in ipairs(legs) do part(c, Rc(c, g, l[1] - 2, 9, l[1] + 2, 0), (i == 1 or i == 3) and B or B, { gloss = false, flat = true }) end
  if f.tail then part(c, Poly(c, g, { { -17, 18 }, { -26, 22 }, { -22, 14 } }), Ac or B, OP) else part(c, Poly(c, g, { { -16, 16 }, { -22, 20 }, { -20, 13 } }), B, OP) end
  part(c, E(c, g, -3, 15, 15, 9), B, { gloss = false, cres = 3, deep = 0 })
  if f.stripes then for i = -2, 1 do local x, y = P(g, -3 + i * 5, 15); c:fill(c:rect(rd(x), rd(y - 8 * g.u), rd(x) + 1, rd(y - 3 * g.u)), "#4a2c1a") end end
  if f.spots then dots(c, g, { { -8, 19 }, { -2, 21 }, { 4, 18 }, { -6, 13 } }, "#2a1a10") end
  if f.mane then part(c, E(c, g, 8, 21, 11, 11), Ac, OP) end
  if f.spikes then for i = 0, 3 do part(c, Poly(c, g, { { -12 + i * 6, 23 }, { -10 + i * 6, 31 }, { -8 + i * 6, 23 } }), Ac, OP) end end
  part(c, E(c, g, 11, 20, 10, 9), B, { gloss = false, cres = 3, deep = 0 })           -- big head
  if f.snout then part(c, E(c, g, 20, 17, 8, 3), B, OP) else part(c, E(c, g, 19, 17, 5, 4), Ac or B, { gloss = false, flat = true }) end
  if not f.horns and not f.antlers and not f.nohear then part(c, Poly(c, g, { { 6, 27 }, { 8, 33 }, { 12, 27 } }), B, OP); part(c, Poly(c, g, { { 12, 27 }, { 15, 33 }, { 17, 26 } }), B, OP) end
  if f.horns then part(c, Poly(c, g, { { 6, 27 }, { 4, 35 }, { 10, 28 } }), Ac, OP); part(c, Poly(c, g, { { 13, 28 }, { 18, 35 }, { 17, 26 } }), Ac, OP) end
  if f.antlers then for _, d in ipairs({ { 8, 4 }, { 15, 18 } }) do Limb(c, g, { { d[1], 28 }, { d[1] + (d[1] < 12 and -3 or 3), 36 } }); Limb(c, g, { { d[1] + (d[1] < 12 and -2 or 2), 33 }, { d[1] + (d[1] < 12 and -7 or 7), 36 } }) end end
  if f.tusks then part(c, Poly(c, g, { { 17, 15 }, { 22, 12 }, { 18, 12 } }), Ac, OP) end
  eye(c, g, 10, 22); eye(c, g, 17, 22); smile(c, g, 13, 15)
end
function A.bird(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  Limb(c, g, { { -1, 9 }, { -1, 4 }, { -2, 0 } }); Limb(c, g, { { 6, 9 }, { 7, 4 }, { 8, 0 } })
  part(c, Poly(c, g, { { -12, 16 }, { -23, 20 }, { -19, 10 } }), Ac, OP)              -- tail
  part(c, E(c, g, 0, 17, 13, 11), B, { gloss = false, cres = 4, deep = 0 })
  part(c, E(c, g, -3, 16, 8, 6), Ac, OP)                                              -- wing
  part(c, E(c, g, 9, 27, 9, 8), B, { gloss = false, cres = 3, deep = 0 })             -- head
  part(c, Poly(c, g, { { 17, 28 }, { 24, 25 }, { 17, 23 } }), f.beak or GV.R.gold, { gloss = false, flat = true })
  if f.crest then for i = 0, 2 do part(c, Poly(c, g, { { 4 + i * 4, 34 }, { 5 + i * 4, 40 }, { 7 + i * 4, 34 } }), Ac, OP) end end
  if f.ears then part(c, Poly(c, g, { { 3, 33 }, { 2, 41 }, { 8, 34 } }), B, OP); part(c, Poly(c, g, { { 11, 34 }, { 16, 41 }, { 15, 32 } }), B, OP) end
  eye(c, g, 7, 29); eye(c, g, 13, 29)
  if f.longlegs then Limb(c, g, { { 2, 9 }, { 2, 0 } }) end
end
function A.snake(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  local pts = { { -18, 5 }, { -12, 7 }, { -4, 5 }, { 4, 8 }, { 10, 12 }, { 13, 19 } }
  for i = 1, #pts do local p = pts[i]; part(c, E(c, g, p[1], p[2], 5.5, 5), (i % 2 == 0 and f.band) and Ac or B, { gloss = false, cres = 2, deep = 0 }) end
  part(c, E(c, g, 14, 26, 9, 8), B, { gloss = false, cres = 3, deep = 0 })
  if f.hood then part(c, E(c, g, 10, 26, 12, 9), Ac, OP); part(c, E(c, g, 14, 26, 9, 8), B, { gloss = false, cres = 3, deep = 0 }) end
  eye(c, g, 11, 28); eye(c, g, 17, 28); smile(c, g, 14, 22)
  if f.snout then part(c, E(c, g, 21, 24, 7, 3), B, OP) end
  if f.spots then dots(c, g, { { -12, 9 }, { -4, 8 }, { 4, 11 } }, "#2a1a10") end
end
function A.crab(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  for _, l in ipairs({ -12, -6, 6, 12 }) do Limb(c, g, { { l, 9 }, { l + (l < 0 and -5 or 5), 5 }, { l + (l < 0 and -6 or 6), 0 } }) end
  part(c, E(c, g, 0, 13, 18, 9), B, { gloss = false, cres = 4, deep = 0 })
  if f.shell then part(c, E(c, g, -6, 19, 12, 10), Ac, { gloss = false, cres = 3, deep = 0 }) end
  Limb(c, g, { { -6, 20 }, { -8, 27 } }); Limb(c, g, { { 6, 20 }, { 8, 27 } })
  eye(c, g, -8, 29); eye(c, g, 8, 29)
  for s = -1, 1, 2 do                                                                    -- big claws
    part(c, E(c, g, s * 20, 19, 7, 6), Ac or B, { gloss = false, cres = 3, deep = 0 })
    local x, y = P(g, s * 24, 21); c:fill(c:rect(rd(x) - 1, rd(y) - 5, rd(x) + 1, rd(y) - 1), "#2a1a10")
  end
  smile(c, g, 0, 8)
  if f.tail then Limb(c, g, { { -12, 16 }, { -20, 24 }, { -16, 32 } }); part(c, Poly(c, g, { { -18, 32 }, { -14, 32 }, { -16, 37 } }), Ac, OP) end
end
function A.frog(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  part(c, E(c, g, -9, 4, 6, 4), B, { gloss = false, flat = true }); part(c, E(c, g, 10, 4, 6, 4), B, { gloss = false, flat = true })
  part(c, E(c, g, 0, 12, 17, 11), B, { gloss = false, cres = 4, deep = 0 })
  part(c, E(c, g, -7, 23, 6, 5), B, OP); part(c, E(c, g, 7, 23, 6, 5), B, OP)         -- eye bumps
  eye(c, g, -7, 24); eye(c, g, 7, 24)
  if f.spots then dots(c, g, { { -12, 12 }, { -6, 16 }, { 4, 17 }, { 12, 12 }, { 0, 8 } }, f.spotcol or "#2a1a10") end
  if g.big then local x, y = P(g, 0, 8); c:paint({ "u.....u", ".uuuuu." }, rd(x) - 3, rd(y), { u = "umber" }) end
  if f.belly then part(c, E(c, g, 2, 7, 10, 5), Ac, { gloss = false, flat = true }) end
end
function A.spider(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  for i, a in ipairs({ -14, -8, 8, 14 }) do Limb(c, g, { { a / 2, 14 }, { a, 22 }, { a * 1.3, 4 }, { a * 1.4, 0 } }) end
  part(c, E(c, g, -6, 14, 12, 9), B, { gloss = false, cres = 3, deep = 0 })
  if f.spots then dots(c, g, { { -8, 18 }, { -3, 16 } }, "#2a1a10") end
  part(c, E(c, g, 9, 17, 8, 7), B, { gloss = false, cres = 3, deep = 0 })
  eye(c, g, 7, 19); eye(c, g, 13, 19); smile(c, g, 10, 13)
end
function A.golem(c, g)
  local B, Ac, f = g.B, g.A, g.feat or {}
  part(c, Rc(c, g, -9, 8, -3, 0), B, { gloss = false, flat = true }); part(c, Rc(c, g, 3, 8, 9, 0), B, { gloss = false, flat = true })
  part(c, c:rrect(rd(P(g, -13, 0)), rd(select(2, P(g, 0, 26))), rd(P(g, 13, 0)), rd(select(2, P(g, 0, 8))), 3), B, { gloss = false, cres = 4, deep = 0 })
  part(c, E(c, g, -19, 18, 5, 8), B, OP); part(c, E(c, g, 19, 18, 5, 8), B, OP)
  part(c, c:rrect(rd(P(g, -10, 0)), rd(select(2, P(g, 0, 40))), rd(P(g, 10, 0)), rd(select(2, P(g, 0, 26))), 3), B, { gloss = false, cres = 3, deep = 0 })
  if f.moss then part(c, E(c, g, -4, 38, 7, 3), Ac, OP); part(c, E(c, g, 8, 18, 4, 3), Ac, OP) end
  if f.crack then local x, y = P(g, 1, 36); c:fill(c:rect(rd(x), rd(y) - 6, rd(x), rd(y)), "#2a1a10"); c:fill(c:rect(rd(x), rd(y), rd(x) + 2, rd(y) + 3), "#2a1a10") end
  eye(c, g, -4, 33); eye(c, g, 5, 33)
  if f.crystal then part(c, Poly(c, g, { { -8, 40 }, { -6, 47 }, { -3, 40 } }), Ac, OP); part(c, Poly(c, g, { { 3, 40 }, { 6, 49 }, { 9, 40 } }), Ac, OP) end
end
function A.wisp(c, g)
  local B, Ac = g.B, g.A
  part(c, Poly(c, g, { { -10, 8 }, { -12, 18 }, { -6, 30 }, { 0, 40 }, { 6, 30 }, { 12, 18 }, { 10, 8 } }), B, { gloss = false, cres = 3, deep = 0 })
  part(c, E(c, g, 0, 16, 9, 9), Ac, { gloss = false, flat = true })
  part(c, E(c, g, 0, 11, 11, 4), B, { gloss = false, flat = true })
  eye(c, g, -4, 18); eye(c, g, 4, 18); smile(c, g, 0, 11)
end
function A.octo(c, g)
  local B, Ac = g.B, g.A
  for i = -3, 3 do local a = i * 4.6; Limb(c, g, { { a * 0.6, 12 }, { a, 6 }, { a * 1.3 + (i % 2 == 0 and 3 or -3), 1 } }) end
  part(c, E(c, g, 0, 24, 14, 14), B, { gloss = false, cres = 4, deep = 0 })
  if g.feat and g.feat.spots then dots(c, g, { { -6, 34 }, { 0, 36 }, { 6, 33 } }, "#f5cf6a") end
  eye(c, g, -6, 22); eye(c, g, 6, 22); smile(c, g, 0, 15)
end
-- folk: chibi villager / crew. g.feat = { species, face (hex), hat ("none"|"cap"|"point"|"straw"|"hood"), hatc, cloth (hex), cloth2 }
function A.folk(c, g)
  local f = g.feat or {}
  local face = L.flat(f.face or "#d9a660"); local cloth = L.flat(f.cloth or "#e8a317"); local hat = L.flat(f.hatc or "#dd3a2a")
  -- boots, body, arms
  part(c, E(c, g, -5, 2, 4, 2), L.flat("#8a4f2a"), { gloss = false, flat = true }); part(c, E(c, g, 6, 2, 4, 2), L.flat("#8a4f2a"), { gloss = false, flat = true })
  part(c, Poly(c, g, { { -9, 3 }, { -11, 17 }, { 11, 17 }, { 10, 3 } }), cloth, { gloss = false, cres = 3, deep = 0 })
  if f.apron then part(c, Poly(c, g, { { -5, 4 }, { -6, 15 }, { 6, 15 }, { 5, 4 } }), L.flat("#f2e4c0"), { gloss = false, flat = true }) end
  c:seam({ { P(g, 0, 16) }, { P(g, 0, 5) } }, {})
  Limb(c, g, { { -10, 15 }, { -14, 9 } }); Limb(c, g, { { 11, 15 }, { 15, 10 } })
  -- species ears / wings / shell behind the head
  local sp = f.species or "mouse"
  if sp == "butterfly" or sp == "moth" or sp == "dragonfly" then part(c, E(c, g, -12, 28, 8, 9), L.flat(f.wing or "#f6b8cf"), OP); part(c, E(c, g, 14, 28, 6, 8), L.flat(f.wing or "#f6b8cf"), OP) end
  if sp == "snail" then part(c, E(c, g, -9, 26, 8, 8), L.flat(f.shell or "#c9a96e"), { gloss = false, cres = 3, deep = 0 }) end
  if sp == "tortoise" then part(c, E(c, g, -4, 24, 10, 9), L.flat(f.shell or "#9a6b3f"), { gloss = false, cres = 3, deep = 0 }) end
  if sp == "hare" then part(c, E(c, g, -5, 40, 3, 9), face, OP); part(c, E(c, g, 6, 40, 3, 9), face, OP) end
  if sp == "mouse" or sp == "bat" or sp == "mole" then part(c, E(c, g, -9, 30, 4, 4), face, OP); part(c, E(c, g, 10, 30, 4, 4), face, OP) end
  if sp == "bat" then part(c, Poly(c, g, { { -10, 34 }, { -14, 44 }, { -4, 36 } }), face, OP); part(c, Poly(c, g, { { 9, 36 }, { 14, 44 }, { 12, 33 } }), face, OP) end
  if sp == "hedgehog" then for i = 0, 5 do part(c, Poly(c, g, { { -11 + i * 4.5, 31 }, { -10 + i * 4.5, 38 }, { -7 + i * 4.5, 31 } }), L.flat(f.spike or "#7a4a1f"), OP) end end
  -- head
  part(c, E(c, g, 1, 27, 11, 10), face, { gloss = false, cres = 3, deep = 0 })
  if sp == "ladybird" then dots(c, g, { { -6, 33 }, { 1, 36 }, { 8, 33 } }, "#2a1a10") end
  if sp == "bee" then for i = 0, 1 do local x, y = P(g, -4 + i * 8, 27); c:fill(c:rect(rd(x), rd(y - 8 * g.u), rd(x), rd(y + 8 * g.u)), "#2a1a10") end end
  if sp == "snail" or sp == "beetle" or sp == "grasshopper" or sp == "ladybird" or sp == "bee" or sp == "butterfly" or sp == "dragonfly" or sp == "moth" then
    Limb(c, g, { { -3, 35 }, { -6, 42 } }); Limb(c, g, { { 6, 35 }, { 9, 42 } }); part(c, Rc(c, g, -8, 42, -5, 45), GV.R.leg, { flat = true, gloss = false }); part(c, Rc(c, g, 8, 42, 11, 45), GV.R.leg, { flat = true, gloss = false }) end
  if sp == "frog" then part(c, E(c, g, -6, 36, 4, 3), face, OP); part(c, E(c, g, 8, 36, 4, 3), face, OP) end
  if sp == "wren" then part(c, Poly(c, g, { { 11, 28 }, { 17, 26 }, { 11, 24 } }), GV.R.gold, { gloss = false, flat = true }) end
  eye(c, g, -3, 28); eye(c, g, 6, 28); if sp ~= "wren" then smile(c, g, 2, 21) end
  -- hat
  local h = f.hat or "cap"
  if h == "point" then part(c, Poly(c, g, { { -9, 34 }, { 1, 50 }, { 11, 34 } }), hat, { gloss = false, cres = 3, deep = 0 }); part(c, Rc(c, g, -11, 33, 13, 35), hat, { gloss = false, flat = true })
  elseif h == "straw" then part(c, E(c, g, 1, 35, 13, 3), L.flat("#f5cf6a"), OP); part(c, E(c, g, 1, 38, 7, 4), L.flat("#f5cf6a"), OP)
  elseif h == "cap" then part(c, E(c, g, 1, 36, 10, 5):cut(c:rect(0, rd(select(2, P(g, 0, 33))), 200, 200)), hat, { gloss = false, cres = 3, deep = 0 })
  elseif h == "hood" then part(c, E(c, g, 1, 31, 13, 12):cut(c:rect(0, rd(select(2, P(g, 0, 28))), 200, 200)), hat, { gloss = false, cres = 3, deep = 0 }) end
end

L.A = A
L.P, L.E, L.Rc, L.Poly = P, E, Rc, Poly

-- build one miniature. s = { slug, size = small|medium|large|boss|party, arch, col, acc, base = ramp hex pair, kind = "enemy"|"party"|"boss", feat = {...} }
local SIZES = { small = { 56, 64, 16, 1.0 }, medium = { 56, 64, 16, 1.2 }, large = { 80, 80, 20, 1.55 }, boss = { 112, 112, 24, 2.3 }, party = { 64, 80, 20, 1.5 } }
local BASES = { soil = { "#9a6b3f", "#7a4a1f" }, stone = { "#8b8f96", "#5b6470" }, sand = { "#f5cf6a", "#c9a96e" }, snow = { "#f1ece0", "#c8ecdc" }, clay = { "#a8582f", "#7a4a1f" }, water = { "#3f8fb0", "#25637d" }, moss = { "#7ab55c", "#4f9a45" }, dusk = { "#7a5cc0", "#4e3a8a" } }
function L.mini(s, folder)
  local sz = SIZES[s.size]; local w, h, cap, u = sz[1], sz[2], sz[3], sz[4]
  local c = X.canvas{ mode = "sticker", w = w, h = h }
  X.layer(c, "objects")
  local bs = BASES[s.base or "soil"]
  local kind = s.kind or (s.size == "boss" and "boss" or (s.size == "party" and "party" or "enemy"))
  local cx, by = L.base(c, w, h, kind, L.flat(bs[1], bs[2]))
  local FIT = { bug = { 26, 34 }, worm = { 24, 30 }, snail = { 24, 31 }, quad = { 27, 37 }, bird = { 25, 42 }, snake = { 27, 36 }, crab = { 29, 38 }, frog = { 19, 29 }, spider = { 21, 29 }, golem = { 25, 50 }, wisp = { 14, 41 }, octo = { 19, 39 }, folk = { 23, 51 } }
  local ft = FIT[s.arch]
  local uu = math.min(u * (s.scale or 1), (by - 5) / ft[2], ((w - 1) / 2 - 5) / ft[1])
  local g = { cx = cx, by = by, u = uu, B = L.flat(s.col, s.shade), A = L.flat(s.acc or s.col, s.accshade), big = (uu >= 1.15), feat = s.feat or {} }
  A[s.arch](c, g)
  X.save(c, "mini-" .. s.slug, folder or "mini", { w = w, h = h, cap = cap })
  return c
end
return L

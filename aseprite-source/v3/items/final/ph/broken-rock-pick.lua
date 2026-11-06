-- broken-rock-pick (aB12_2, Opus single pass). Geologist's hammer on a diagonal: forged steel shank with a stacked
-- leather-washer grip and steel butt cap; head = square hammer face one side, slim curved pick the other.
-- Material: bevelled steel, sheen + spec, washer stripes on leather, AO at the head-shank joint.
-- broken: a corner of the hammer face sheared off with a crack running in, the grip torn open, the corner chip flies.
-- quirk: a tiny amethyst crystal speared on the pick point.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-rock-pick")
local AME = { "#35295f", "#5a459e", "#8a6fd0", "#b39ae6", "#d8c8f6", "#fff4d6" }
local ux, uy = -0.59, 0.81          -- along handle (from head down-left)
local px, py = 0.81, 0.59           -- along head (toward hammer, lower-right)
local Hx, Hy = 37, 18
local Ex, Ey = Hx + ux * 40, Hy + uy * 40
-- shank + grip
local sm, sT = A.taper(c, function(t) return Hx + ux * 40 * t, Hy + uy * 40 * t end, function(t) return t < 0.45 and 1.4 or 2.0 end)
local steel, grip = HP.mask(), HP.mask()
sm:each(function(x, y) if sT[K(x, y)] < 0.45 then steel:set(x, y) else grip:set(x, y) end end)
local cap = HP.mask() grip:each(function(x, y) if sT[K(x, y)] > 0.95 then cap:set(x, y) end end) grip:cut(cap)
-- head masks
local pick = A.taper(c, A.bez(Hx, Hy, Hx - px * 10, Hy - py * 10 + 1.5, Hx - px * 19, Hy - py * 19 + 4), function(t) return 0.6 + 2.0 * (1 - t) end)
local hamm = c:poly{ { Hx + px * 1 - ux * 3.4, Hy + py * 1 - uy * 3.4 }, { Hx + px * 10 - ux * 3.4, Hy + py * 10 - uy * 3.4 },
  { Hx + px * 10 + ux * 3.4, Hy + py * 10 + uy * 3.4 }, { Hx + px * 1 + ux * 3.4, Hy + py * 1 + uy * 3.4 } }
local head = pick:copy():add(hamm)
A.lit(c, steel, A.STEEL, { R = 1.2, bias = A.ao(steel, { head }, 2, -1) })
local gi = A.lit(c, grip, A.LEATH, { R = 1.8, wrap = 0.3, bias = A.ao(grip, { steel }, 1, -1) })
grip:each(function(x, y) local t = sT[K(x, y)] if math.floor(t * 40 * 1.0) % 2 == 0 then
  local i = gi[K(x, y)] c:put(x, y, A.LEATH[math.max(1, i - 1)]) end end)
A.lit(c, cap, A.STEEL, { R = 1 })
local hi, hn = A.lit(c, head, A.STEEL, { R = 2, wrap = 0.3 })
A.streak(c, head, hi, A.STEEL, 46, 2)
A.bevel(c, head, 0, -1, A.STEEL[6])
-- striking face: darker flat end plane
hamm:each(function(x, y) if not hamm:has(x + 1, y) or not hamm:has(x, y + 1) then if (x - Hx) * px + (y - Hy) * py > 8.6 then c:px(x, y, A.STEEL[3]) end end end)
local sx, sy = A.specAt(head, hn) c:px(sx, sy, A.SPEC)
-- damage: sheared corner + crack
local corner = c:poly{ { 50, 21 }, { 46, 29 }, { 52, 29 } }
A.erase(c, corner)
A.gap(c, { { 45, 23 }, { 43, 22 }, { 42, 24 } }, 1)
c:px(46, 22, A.STEEL[6]) c:px(45, 26, A.STEEL[5])
A.chip(c, { { 53, 31 }, { 57, 32 }, { 54, 35 } }, A.STEEL)
c:px(54, 32, A.SPEC)
-- grip torn: gap + curling leather flap
A.gap(c, { { 22, 40 }, { 25, 42 } }, 1)
local flap = c:poly{ { 25, 42 }, { 29, 43 }, { 28, 45 } }
A.lit(c, flap, A.LEATH, { R = 1 })
-- quirk: amethyst on the pick point
local tx, ty = Hx - px * 19, Hy - py * 19 + 4
local am = c:poly{ { tx - 2, ty - 4 }, { tx + 1, ty - 6 }, { tx + 2, ty - 2 }, { tx, ty + 1 }, { tx - 2, ty - 1 } }
A.lit(c, am, AME, { R = 1 })
c:px(math.floor(tx), math.floor(ty - 4), AME[6]) c:px(math.floor(tx - 1), math.floor(ty - 2), AME[2])
A.save(c)

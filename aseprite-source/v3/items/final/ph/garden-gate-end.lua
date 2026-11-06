-- garden-gate-end (Opus single pass, aB33_1). The last stretch of a picket run coming toward the viewer in 2:1 iso
-- (down-right), stopping at a stout square end post propped by a diagonal kicker brace; flat cap board on top.
-- Material: 6-tone wood with grain streaks, deep seams + contact shadow at every crossing, AO feet, end grain on the
-- brace foot and cap board, an iron nail head on the brace.
-- quirk: someone has hung their little red gnome hat on the end post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs = math.floor, math.abs
local c = A.new("garden-gate-end")
local CX, GY = 42, 55
c:groundShadow(CX + 2, GY + 1, 12, 2)
local function gy(x) return GY - (CX - x) / 2 end
local LT = { -0.3, 0 }

-- rails coming down-right into the post
for _, hh in ipairs({ 7, 17 }) do
  A.part(A.isoRail(6, CX - 3, CX, GY - hh - 1, 0.5, 2), A.RAIL, { R = 1, tilt = LT, grain = { dir = "h", seed = hh } })
end
-- pickets far (upper-left) to near
for j = 5, 0, -1 do
  local x0 = CX - 10 - 5 * j
  local m = A.picketMask(x0, 3, floor(gy(x0 + 1) + 0.5), 21, true)
  A.part(m, A.PICK, { R = 1.2, tilt = LT, grain = { dir = "v", seed = 50 + j }, bias = A.footAO(m, 1) })
end
-- stout end post (8 px)
local pm, pn = A.isoPost(CX, GY, 4, 33)
A.part(pm, A.POST, { n = pn, bias = A.footAO(pm, 2), grain = { dir = "v", seed = 9, dens = 0.5 } })
for y = GY - 32, GY - 2 do if pm:has(CX - 1, y) and (y % 8 ~= 5) then A.set(CX - 1, y, A.POST, 5) end end
-- cap board: a flat slab overhanging the post top
local cb = HP.mask()
local ty = GY - 33
for x = CX - 6, CX + 5 do
  local d = (x < CX) and (CX - x) or (x - CX + 1)
  for y = ty - 6 + floor(d / 2), ty - floor(d / 2) + 1 do cb:set(x, y) end
end
local cn = {}
local _, by0, _, by1 = cb:bbox()
cb:each(function(x, y)
  local d = (x < CX) and (CX - x) or (x - CX + 1)
  local front = y >= ty - floor(d / 2)
  cn[K(x, y)] = front and ((x < CX) and A.nrm(-0.7, 0.1, 0.7) or A.nrm(0.8, 0.1, 0.6)) or A.nrm(-0.1, -0.85, 0.5)
end)
A.part(cb, A.RAIL, { n = cn })
-- kicker brace on the outside of the post
local br = HP.line({ { CX + 4, GY - 19 }, { CX + 13, GY } }, 3):cut(pm)
A.part(br, A.RAIL, { R = 1.2, grain = { dir = "v", seed = 77 } })
A.set(CX + 13, GY, A.RAIL, 6) A.set(CX + 12, GY, A.RAIL, 5)
A.set(CX + 6, GY - 15, A.IRON, 1) A.set(CX + 5, GY - 16, A.IRON, 5)

-- quirk: little red gnome hat hung on the cap, tip flopping over
local hat = HP.poly{ { CX - 4, ty - 5 }, { CX + 3, ty - 5 }, { CX + 1, ty - 11 }, { CX + 4, ty - 15 }, { CX + 6, ty - 14 }, { CX, ty - 14 } }
local brim = HP.rect(CX - 5, ty - 6, CX + 4, ty - 4)
A.part(hat, A.RED, { R = 1.6 })
A.part(brim, A.RED, { R = 1, bias = {} })
A.px(CX - 3, ty - 9, A.CREAM)
A.save(c)

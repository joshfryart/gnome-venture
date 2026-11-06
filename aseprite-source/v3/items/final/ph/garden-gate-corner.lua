-- garden-gate-corner (Opus single pass, aB33_1). A 90 degree picket corner seen in 2:1 iso from outside: a square
-- oak corner post (lit left face, shaded right face, pale end-grain top under a ball finial) with two short runs of
-- four pointed pickets receding up-left and up-right on twin rails.
-- Material: 6-tone wood with grain streaks, the two runs lit differently by their facing, contact shadow + deep seam
-- where pickets cross the rails, AO at the post foot, end grain ring on the post top.
-- quirk: a red toadstool has popped up at the foot of the corner post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor = math.floor
local c = A.new("garden-gate-corner")
local CX, GY = 32, 55
c:groundShadow(CX, GY + 1, 9, 2)
local function gy(x) return GY - math.abs(CX - x) / 2 end

-- rails (behind pickets)
for _, hh in ipairs({ 7, 17 }) do
  A.part(A.isoRail(8, 29, CX, GY - hh, 0.5, 2), A.RAIL, { R = 1, tilt = { -0.3, 0 }, grain = { dir = "h", seed = hh } })
  A.part(A.isoRail(35, 56, CX, GY - hh, -0.5, 2):cut(HP.rect(0, 0, 34, 63)), A.RAIL, { R = 1, tilt = { 0.35, 0 }, grain = { dir = "h", seed = hh + 5 } })
end
-- pickets far to near
for j = 3, 0, -1 do
  local xl = 25 - 5 * j
  local ml = A.picketMask(xl, 3, floor(gy(xl + 1) + 0.5), 22, true)
  A.part(ml, A.PICK, { R = 1.2, tilt = { -0.3, 0 }, grain = { dir = "v", seed = 30 + j }, bias = A.footAO(ml, 1) })
  local xr = 36 + 5 * j
  local mr = A.picketMask(xr, 3, floor(gy(xr + 1) + 0.5), 22, true)
  A.part(mr, A.PICK, { R = 1.2, tilt = { 0.35, 0 }, grain = { dir = "v", seed = 40 + j }, bias = A.footAO(mr, 1) })
end
-- corner post
local pm, pn, top = A.isoPost(CX, GY, 3, 31)
local bias = A.footAO(pm, 2)
local idx = A.part(pm, A.POST, { n = pn, bias = bias, grain = { dir = "v", seed = 7, dens = 0.45 } })
-- front edge highlight + end grain ring
for y = GY - 30, GY - 2 do if pm:has(CX - 1, y) and (y % 7 ~= 3) then A.set(CX - 1, y, A.POST, 5) end end
A.set(CX - 1, GY - 33, A.POST, 4) A.set(CX, GY - 33, A.POST, 4)
-- ball finial on a neck
local nk = HP.rect(CX - 1, GY - 36, CX, GY - 34)
A.part(nk, A.POST, { R = 1 })
local fb = HP.ellipse(CX - 0.5, GY - 39, 2.5, 2.5)
A.part(fb, A.POST, { n = X.sphere(CX - 0.5, GY - 39, 2.5, fb) })

-- quirk: toadstool at the post foot
local st = HP.rect(27, 53, 28, 56)
A.part(st, { "#6e5a6a", "#a8919a", "#cdbdb8", "#e6d8cc", "#f6ecdc", "#fff4d6" }, { R = 1 })
local cap = HP.ellipse(27.5, 52, 2.5, 1.5)
A.part(cap, A.RED, { R = 1.4 })
A.px(26, 51, A.CREAM) A.px(29, 52, A.CREAM)
A.save(c)

-- garden-gate-cross (Opus single pass, aB33_1). A four-way picket junction in 2:1 iso: a tall square oak post with
-- a pyramid cap where four short runs meet (two behind it, two in front), each run three pointed pickets on twin rails.
-- Material: 6-tone wood, grain streaks, runs lit by facing, deep seams + contact shadow where boards overlap,
-- AO at every foot, pale end grain on the rail stubs.
-- quirk: a little red arrow sign is nailed to the post, pointing the way down the garden.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs = math.floor, math.abs
local c = A.new("garden-gate-cross")
local CX, GY = 32, 44
c:groundShadow(CX, GY + 1, 7, 2)
local H = 18
local LT, DK = { -0.3, 0 }, { 0.35, 0 }

-- a run: dirx -1/+1, diry -1 (back) / +1 (front); faces lit by facing
local function run(dirx, diry, seed)
  local slope = dirx * diry * 0.5
  local tilt = (dirx * diry < 0) and LT or DK
  local function gy(x) return GY + diry * abs(x - CX) / 2 end
  local xa, xb
  if dirx < 0 then xa, xb = CX - 21, CX - 4 else xa, xb = CX + 3, CX + 20 end
  for _, hh in ipairs({ 5, 13 }) do
    A.part(A.isoRail(xa, xb, CX, GY - hh, slope, 2), A.RAIL, { R = 1, tilt = tilt, grain = { dir = "h", seed = seed + hh } })
    -- pale end grain on the outer stub
    local ex = dirx < 0 and xa or xb
    local ey = floor(GY - hh + (ex - CX) * slope + 0.5)
    A.set(ex, ey, A.RAIL, 6) A.set(ex, ey + 1, A.RAIL, 5)
  end
  local order = {}
  for j = 0, 2 do order[#order + 1] = j end
  if diry < 0 then order = { 2, 1, 0 } end           -- back runs: far (outer) first
  for _, j in ipairs(order) do
    local x0 = dirx < 0 and (CX - 9 - 5 * j) or (CX + 6 + 5 * j)
    local m = A.picketMask(x0, 3, floor(gy(x0 + 1) + 0.5), H, true)
    A.part(m, A.PICK, { R = 1.2, tilt = tilt, grain = { dir = "v", seed = seed + j }, bias = A.footAO(m, 1) })
  end
end
run(-1, -1, 10)
run(1, -1, 20)

-- centre post with a pyramid cap
local pm, pn = A.isoPost(CX, GY, 3, 27)
A.part(pm, A.POST, { n = pn, bias = A.footAO(pm, 2), grain = { dir = "v", seed = 3, dens = 0.45 } })
for y = GY - 26, GY - 2 do if pm:has(CX - 1, y) and (y % 6 ~= 2) then A.set(CX - 1, y, A.POST, 5) end end
local cap = HP.mask()
local ty = GY - 27 - 3
for x = CX - 4, CX + 3 do
  local d = (x < CX) and (CX - x) or (x - CX + 1)
  for y = ty - (5 - d), ty + 1 - floor(d / 2) do cap:set(x, y) end
end
local cn = {}
cap:each(function(x, y) cn[K(x, y)] = (x < CX) and A.nrm(-0.6, -0.5, 0.6) or A.nrm(0.7, -0.3, 0.6) end)
A.part(cap, A.RAIL, { n = cn })
A.set(CX - 1, ty - 4, A.RAIL, 6) A.set(CX - 2, ty - 3, A.RAIL, 6)

-- quirk: arrow sign nailed on the lit face
local sg = HP.poly{ { CX - 13, GY - 19 }, { CX - 5, GY - 19 }, { CX - 5, GY - 15 }, { CX - 13, GY - 15 }, { CX - 15, GY - 17 } }
A.part(sg, A.RED, { R = 1.2 })
A.set(CX - 7, GY - 17, A.IRON, 2) A.px(CX - 12, GY - 18, A.CREAM)

run(-1, 1, 30)
run(1, 1, 40)
A.save(c)

-- garden-gate (Opus single pass, aB33_1). Front view of a swinging picket gate hung between two slim oak posts with
-- ball finials. Nine pointed pine pickets whose tips sweep up in an arch; two rails and a Z brace on the near side.
-- Material: pillow-lit 6-tone wood with broken grain streaks, AO seams + contact shadow where boards cross,
-- iron strap hinges with a bright bevel edge and dark bolt holes, a ring latch; ball finials sphere-lit.
-- quirk: a little brass bell hangs from the latch post to ring when the gate opens.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, pi = math.floor, math.sin, math.pi
local c = A.new("garden-gate")
c:groundShadow(32, 56, 25, 2)

-- posts (4 px) with ball finials
local function post(x0, seed)
  local m = HP.rect(x0, 13, x0 + 3, 56)
  -- neck + cap plate
  m:add(HP.rect(x0 - 1, 12, x0 + 4, 13))
  A.part(m, A.POST, { R = 1.5, grain = { dir = "v", seed = seed, dens = 0.5 }, bias = A.footAO(m, 2) })
  local b = HP.ellipse(x0 + 1.5, 9, 2.5, 2.5)
  A.part(b, A.POST, { n = X.sphere(x0 + 1.5, 9, 2.5, b) })
end
post(9, 3)
post(51, 11)

-- pickets, tips arching up toward the middle
for i = 0, 8 do
  local x0 = 14 + i * 4
  local t = (x0 + 1 - 14) / 34
  local top = floor(25 - 7 * sin(pi * t) + 0.5)
  local m = A.picketMask(x0, 3, 52, 52 - top + 1, true)
  A.part(m, A.PICK, { R = 1.2, grain = { dir = "v", seed = 20 + i, dens = 0.45 }, bias = A.footAO(m, 1) })
end

-- rails + Z brace (near side)
local r1 = HP.rect(13, 29, 50, 31)
local r2 = HP.rect(13, 45, 50, 47)
A.part(r1, A.RAIL, { R = 1.2, grain = { dir = "h", seed = 41, dens = 0.5 } })
A.part(r2, A.RAIL, { R = 1.2, grain = { dir = "h", seed = 42, dens = 0.5 } })
local br = HP.line({ { 17, 44 }, { 46, 32 } }, 3):cut(r1):cut(r2)
A.part(br, A.RAIL, { R = 1.2 })

-- iron strap hinges from the left post onto the rails
for _, y in ipairs({ 30, 46 }) do
  local h = HP.rect(10, y - 1, 21, y)
  h:add(HP.rect(20, y - 1, 22, y + 1))
  A.part(h, A.IRON, { R = 1, cuts = { 0.2, 0.4, 0.56, 0.7, 0.86 } })
  A.set(12, y, A.IRON, 1) A.set(18, y, A.IRON, 1)        -- bolt holes
  A.set(11, y - 1, A.IRON, 6)                            -- bright bevel tip
end
-- ring latch on the right post
local lm = HP.rect(47, 37, 52, 38)
A.part(lm, A.IRON, { R = 1 })
local ring = HP.ellipse(52.5, 41, 1.5, 2):cut(HP.ellipse(52.5, 41, 0.5, 1))
A.part(ring, A.IRON, { R = 1 })
A.set(51, 40, A.IRON, 6)

-- quirk: brass bell hanging from a nail on the latch post
A.set(53, 19, A.IRON, 2) A.set(53, 20, A.IRON, 3)
local bell = HP.poly{ { 54, 21 }, { 55, 21 }, { 57, 25 }, { 57, 26 }, { 52, 26 }, { 52, 25 } }
bell:add(HP.rect(52, 21, 57, 26):clip(HP.ellipse(54.5, 24, 2.6, 3.2)))
bell:add(HP.rect(51, 26, 58, 26))
A.part(bell, A.BRASS, { R = 1.6 })
A.set(54, 27, A.BRASS, 2) A.set(55, 27, A.BRASS, 3)        -- clapper
A.px(53, 22, A.CREAM)                                      -- glint
A.save(c)

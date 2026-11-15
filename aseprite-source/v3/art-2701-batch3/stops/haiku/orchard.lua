-- orchard.lua : "Orchard camp" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline, hash = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline, F.hash

-- an old apple tree laden with fruit
local function fruitTree(x, yb, h, seed)
  F.tree(x, yb, h, seed)
  local cx, cy = x, yb - h * .62
  for i = 1, 12 do
    local fx = math.floor(cx + (hash(i, seed, 40) - .5) * h * .7)
    local fy = math.floor(cy + (hash(i, seed, 41) - .5) * h * .5)
    px(fx, fy, L.produce.base) px(fx + 1, fy, L.produce.hi)
  end
end
-- a small canvas tent with a door slit
local function tent(x, yb, w, h, r)
  local m = c:poly{ { x - w // 2, yb }, { x, yb - h }, { x + w // 2, yb } }
  rimOf(m, r) part(m, r, { sep = true })
  vline(x, yb - h // 2, yb, r.deep)
  hline(x - w // 2, x + w // 2, yb, L.timber.deep)
end

-- orchard rows on both sides of the road
fruitTree(50, 170, 36, 2)
fruitTree(128, 186, 40, 3)
fruitTree(372, 178, 38, 4)
fruitTree(448, 150, 30, 5)
tent(108, 212, 34, 22, L.awnB)
tent(410, 212, 30, 20, L.awnA)

-- ladders against two trees
part(c:line({ { 62, 196 }, { 70, 170 } }, 1), L.timber, { nopop = true, noshade = true })
part(c:line({ { 380, 206 }, { 392, 176 } }, 1), L.timber, { nopop = true, noshade = true })

-- the cider press: stone base, timber frame, a barrel
local base = rect(300, 178, 336, 190)
rimOf(base, L.stone) part(base, L.stone, { sep = true })
F.courses(base, 178, 4, 8, L.stone)
local frame = F.union(rect(302, 160, 304, 178), rect(332, 160, 334, 178), rect(302, 160, 334, 162))
rimOf(frame, L.timber) part(frame, L.timber, { nopop = true })
vline(318, 162, 176, L.timber.hi)
F.barrel(346, 200, L.board)
F.barrel(358, 200, L.board)

-- crates of apples by the path
for _, x in ipairs({ 196, 214 }) do
  local crate = rect(x, 206, x + 12, 214)
  rimOf(crate, L.board) part(crate, L.board, { sep = true })
  for k = 0, 3 do px(x + 2 + k * 2, 206, L.produce.base) px(x + 3 + k * 2, 205, L.produce.hi) end
end

-- a sign on the left path
F.sign(214, 152, 26, 12)

F.finish()

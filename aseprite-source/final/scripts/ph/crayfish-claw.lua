-- crayfish-claw: one long crayfish chela lying on the diagonal, fingers slightly open.
-- Family: the Mud Crayfish shell (GV.ramp("#8c4a1a") + carapace GV.ramp("#a5663a")), flowerpot brown.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = GV.ramp("#8c4a1a")
local cara = GV.ramp("#a5663a")

-- local frame: u runs along the claw (lower-left -> upper-right), v across it (+v = lower-right side)
local OX, OY, K = 11, 52, 0.92
local DX, DY = 0.77, -0.64
local NX, NY = 0.64, 0.77
local function P(u, v) u, v = u*K, v*K return { math.floor(OX + u*DX + v*NX + 0.5), math.floor(OY + u*DY + v*NY + 0.5) } end
local function shape(t) local o = {} for i, q in ipairs(t) do o[i] = P(q[1], q[2]) end return c:poly(o) end

-- arm stub (carpus), cut flat at the back
local arm = shape({ {0,-5}, {11,-6}, {11,6}, {0,5} }):closed(1)
-- palm (propodus): a fat oval
local palm = shape({ {9,-7}, {14,-11}, {22,-12}, {29,-11}, {34,-7}, {35,0}, {34,7}, {28,10}, {20,11}, {13,9}, {9,6} }):closed(2)
-- fixed finger (lower-right side), tapering to a tip that hooks up
local fixed = shape({ {30,0}, {42,0}, {50,-1}, {55,-3}, {58,-1}, {55,3}, {46,6}, {38,9}, {30,9} }):closed(1)
-- movable finger (dactyl, upper-left side), opened into a V, tip hooking down
local dact = shape({ {27,-10}, {34,-13}, {42,-15}, {49,-16}, {54,-14}, {55,-10}, {50,-11}, {42,-8}, {34,-5}, {27,-3} }):closed(1)

local p = c:build{
  { "arm",   arm,   shell },
  { "dact",  dact,  cara, { gloss = P(36, -11) } },
  { "fixed", fixed, cara, { gloss = P(38, 2) } },
  { "palm",  palm,  cara },
}
-- teeth: cream nubs along the inner edges of the V
local T = "#f1ece0"
for _, u in ipairs({ 39, 46 }) do
  local q = P(u, 1.6); c:px(q[1], q[2], T); c:px(q[1] + 1, q[2], T)
end
for _, u in ipairs({ 38, 46 }) do
  local q = P(u, -6.5 - (u - 38) * 0.35); c:px(q[1], q[2], T); c:px(q[1], q[2] + 1, T)
end
-- bean bumps on the palm (crayfish tubercles), glazed
for _, q in ipairs({ { 19, -6 }, { 26, -6 }, { 22, 2 }, { 29, 3 } }) do
  local a = P(q[1], q[2])
  c:spot(c:rect(a[1], a[2], a[1] + 1, a[2] + 1), "#5e2f1e", "#8a4f2a")
end
-- the joint between arm and palm: a seam with its button
c:seam({ P(10.5, -6), P(10.5, 6) })
local b = P(10.5, -6); c:button(b[1] - 1, b[2] - 1)

local t = c:save(D .. "final/aseprite/ph/crayfish-claw.aseprite", PNG .. "crayfish-claw.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

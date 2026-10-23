-- crayfish-claw: one long crayfish chela lying on the diagonal, fingers slightly open.
-- Family: the Mud Crayfish shell (GV.ramp("#8c4a1a") + carapace GV.ramp("#a5663a")), flowerpot brown.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = GV.ramp("#8c4a1a")
local cara = GV.ramp("#a5663a")

-- local frame: u runs along the claw (lower-left -> upper-right), v across it (+v = lower-right side)
local OX, OY, K = 8, 54, 1
local DX, DY = 0.77, -0.64
local NX, NY = 0.64, 0.77
local function P(u, v) u, v = u*K, v*K return { math.floor(OX + u*DX + v*NX + 0.5), math.floor(OY + u*DY + v*NY + 0.5) } end
local function shape(t) local o = {} for i, q in ipairs(t) do o[i] = P(q[1], q[2]) end return c:poly(o) end

-- arm stub (carpus), cut flat at the back
local arm = shape({ {2,-5}, {12,-6}, {12,6}, {2,5} }):closed(1)
-- palm (propodus): a fat oval
local palm = shape({ {10,-7}, {15,-11}, {23,-12}, {30,-11}, {35,-7}, {36,0}, {35,7}, {29,10}, {21,11}, {14,9}, {10,6} }):closed(2)
-- fixed finger (lower-right side), tapering to a point
local fixed = shape({ {31,0}, {44,0}, {53,-1}, {60,-3}, {58,1}, {52,4}, {44,7}, {37,9}, {31,9} }):closed(1)
-- movable finger (dactyl, upper-left side), opened into a V, tip hooking in
local dact = shape({ {28,-10}, {36,-13}, {44,-15}, {51,-15}, {56,-13}, {58,-10}, {52,-11}, {44,-8}, {36,-5}, {28,-3} }):closed(1)

local p = c:build{
  { "arm",   arm,   shell },
  { "dact",  dact,  cara, { gloss = P(38, -11) } },
  { "fixed", fixed, cara, { gloss = P(40, 2) } },
  { "palm",  palm,  cara },
}
-- darker shell-brown finger tips: swap carapace tones for shell tones of the same step
local swap = {}
for _, k in ipairs({ "gloss", "dot", "rim", "base", "shade", "deep", "bounce" }) do swap[cara[k]] = shell[k] end
local tips = shape({ {50,-24}, {70,-24}, {70,14}, {50,14} }):clip(dact:copy():add(fixed))
tips:each(function(x, y) local v = c:get(x, y) if swap[v] then c:px(x, y, swap[v]) end end)
-- teeth: cream nubs along the inner edges of the V
local T = "#f1ece0"
for _, u in ipairs({ 38, 45 }) do
  local q = P(u, 1.5); c:px(q[1], q[2], T); c:px(q[1] + 1, q[2], T)
end
for _, u in ipairs({ 39, 46 }) do
  local q = P(u, -6.3 - (u - 39) * 0.37); c:px(q[1], q[2], T); c:px(q[1], q[2] + 1, T)
end
-- bean bumps on the palm (crayfish tubercles), glazed
for _, q in ipairs({ { 20, -6 }, { 27, -6 }, { 23, 2 }, { 30, 3 } }) do
  local a = P(q[1], q[2])
  c:spot(c:rect(a[1], a[2], a[1] + 1, a[2] + 1), "#5e2f1e", "#8a4f2a")
end
-- the joint between arm and palm: a seam with its button
c:seam({ P(11.5, -6), P(11.5, 6) })
local b = P(11.5, -6); c:button(b[1] - 1, b[2] - 1)

local t = c:save(D .. "final/aseprite/ph/crayfish-claw.aseprite", PNG .. "crayfish-claw.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

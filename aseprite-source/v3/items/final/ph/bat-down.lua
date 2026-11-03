local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bat-down: a folded bat wing: dark ribbed membrane stretched over curved finger bones, with a puff of soft grey down at the shoulder. quirk: a single tiny claw hooks over the top bone.
local c = D.new("bat-down")
local WG = { "#1c1624", "#33283e", "#4e3f58", "#6a5874", "#8a7894", "#b0a2b8" }
local mem = c:poly{ {14, 40}, {20, 22}, {34, 14}, {46, 18}, {54, 30}, {50, 50}, {42, 42}, {34, 52}, {28, 42}, {20, 50} }
D.lit(mem, WG, 5)
for _, e in ipairs{ {20, 50}, {28, 42}, {34, 52}, {42, 42}, {50, 50} } do D.ln(14, 24, e[1], e[2] - 1, "#1c1624") end
D.ln(14, 24, 34, 14, "#8a7894") D.ln(14, 25, 34, 15, "#b0a2b8") D.ln(34, 14, 54, 30, "#6a5874")
D.lit(D.ell(14, 26, 9, 7, 0.3), { "#4a4a52", "#6a6a74", "#8a8a96", "#aaaab6", "#cacad2", "#eceaf2" }, 4)
for _, p in ipairs{{9, 22}, {12, 20}, {17, 20}, {8, 28}, {11, 32}, {17, 32}} do D.ln(p[1], p[2], p[1] - 1, p[2] - 2, "#cacad2") end
D.px(33, 11, "#e8e0f0") D.px(34, 11, "#e8e0f0") D.px(34, 10, "#e8e0f0")
D.fin()

local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bok-choy-kimchi")
-- bok-choy-kimchi: tall jar of red-chilli kimchi with red-and-white gingham lid, bok choy leaf visible through the glass. quirk: a chilli flake spills down the glass.
D.shadow(32, 58, 14, 2)
D.vbody(18, 20, 46, 56, 5, D.GLASS)
D.c:fillMask(D.c:rect(20, 28, 44, 55), "#d4403a")
for _, p in ipairs{{22,32},{28,36},{36,31},{40,40},{24,44},{32,48},{38,52},{26,52}} do D.E(p[1], p[2], 3, 1.6, (p[1] % 3 - 1) * 0.5, D.LEAF2, 1.2) D.px(p[1] - 1, p[2] - 1, "#e6f0c0") end
for _, p in ipairs{{30,30},{23,38},{35,44},{42,46},{29,41}} do D.px(p[1], p[2], "#a82c3c") D.px(p[1] + 1, p[2], "#ff9a78") end
D.ln(21, 24, 21, 50, "#eafaf6") D.ln(22, 26, 22, 34, "#d4f0f0")
D.P({{16,12},{48,12},{49,20},{15,20}}, D.RED, 1.5)
for x = 16, 48, 4 do D.c:fillMask(D.c:rect(x, 12, x + 1, 20), "#fff4d6") end
for y = 14, 18, 4 do D.ln(15, y, 49, y, "#fff4d6") end
D.ln(15, 20, 49, 20, "#6e2038") D.ln(16, 13, 48, 13, "#7a2036")
D.px(44, 33, "#a82c3c") D.px(44, 34, "#d4403a") D.px(45, 35, "#ee6a50")
D.fin()

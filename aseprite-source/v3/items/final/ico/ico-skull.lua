-- ico-skull first draft. bone-white skull with dark sockets and teeth. quirk: a pink flower tucked in by the brow, hairline crack on the other side
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-skull")
local B = D.CRM
D.lit(c, D.ell(32, 27, 19, 17), B, 7)
D.lit(c, c:rrect(20, 36, 44, 53, 3), B, 4)
D.lit(c, c:ellipse(32, 27, 15, 5):clip(c:rect(0, 40, 63, 41)), B, 1)
-- sockets
D.lit(c, D.ell(24, 30, 5, 5.5), { "#150f22", "#251a3c", "#35295f", "#35295f", "#4a3a80", "#4a3a80" }, 2)
D.lit(c, D.ell(40, 30, 5, 5.5), { "#150f22", "#251a3c", "#35295f", "#35295f", "#4a3a80", "#4a3a80" }, 2)
D.lit(c, c:poly{ {32, 35}, {29, 41}, {35, 41} }, { "#150f22", "#251a3c", "#35295f", "#35295f", "#4a3a80", "#4a3a80" }, 1)
-- teeth
D.R(c, 24, 47, 40, 47, "#a88a6a")
for x = 27, 37, 4 do D.R(c, x, 47, x, 53, "#a88a6a") end
-- crack
D.polyline(c, { {20, 14}, {23, 18}, {21, 22}, {24, 25} }, "#a88a6a")
-- flower
for _, p in ipairs{ {44, 13}, {47, 13}, {45, 10}, {45, 16} } do D.lit(c, c:ellipse(p[1], p[2], 2, 2), D.PINK, 1) end
D.R(c, 44, 12, 46, 14, "#ffd45a")
D.fin()

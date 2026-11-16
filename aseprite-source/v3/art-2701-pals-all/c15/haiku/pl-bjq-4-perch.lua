-- Gold Spike Tiara (pl-bjq-4), perch 36x36. Hand-drawn at size: four spikes over a bubble heap on the perch.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-4-perch", 36), H.P
H.ledge(c)
c:part(c:ellipse(9, 24, 5, 4), "sea", { sep = true })
c:part(c:ellipse(27, 24, 5, 4), "sea", { sep = true })
c:part(c:ellipse(18, 25, 6, 5), "sky", { sep = true })
local spikes = {
  { {2,20},{6,6},{10,19} }, { {10,18},{15,3},{20,18} },
  { {20,18},{25,4},{28,19} }, { {27,20},{33,8},{34,22} },
}
for _, s in ipairs(spikes) do c:part(c:poly(s), "gold", { sep = true }) end
c:eyeSmall(15, 22)
c:eyeSmall(21, 22)
for _, p in ipairs({ {17,27},{18,28},{19,28},{20,27} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(5, 30)
H.done(c, "pl-bjq-4-perch")

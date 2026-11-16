-- Chilli Chime (sp-chilli-chime), yard sprite 64x64. Haiku pass, c06.
-- Common, brewroot. A round moss-green pal with a garland of red chillies and little gold bells.
-- quirk: the garland's bells chime, shown as two cream sound ticks beside the bells.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-chilli-chime-yard", 64)

-- body
local body = c:ellipse(32, 41, 17, 15)
c:part(body, "moss", { pop = { x = 22, y = 32, horizontal = true } })

-- garland string
local string1 = c:line({ { 8, 14 }, { 20, 22 }, { 32, 25 }, { 44, 22 }, { 56, 14 } }, 1)
c:part(string1, "wood", { noshade = true })

-- chillies hanging from the string
local chillies = {
  { 13, 17, 15, 24 }, { 21, 22, 23, 29 }, { 36, 24, 38, 31 }, { 45, 21, 47, 27 }, { 51, 15, 53, 22 },
}
for _, ch in ipairs(chillies) do
  local x0, y0, x1, y1 = ch[1], ch[2], ch[3], ch[4]
  local m = c:poly{ { x0, y0 }, { x0 + 2, y0 }, { x1, y1 }, { x1 - 1, y1 + 1 }, { x0 - 1, y0 + 2 } }
  c:part(m, "ember", { pop = { x = x0, y = y0 + 1, horizontal = false } })
end

-- gold bells under two of the chillies
for _, b in ipairs({ { 22, 33 }, { 46, 30 } }) do
  local bell = c:ellipse(b[1], b[2], 2, 2)
  c:part(bell, "gold", { band = 1 })
  H.dot(c, b[1], b[2] + 2, P.gold.deep)
end

-- sound ticks (quirk)
H.dots(c, { { 8, 32 }, { 6, 34 }, { 57, 32 }, { 59, 34 } }, P.cream)

-- face
c:eyeLocked(23, 37)
c:eyeLocked(37, 37)
c:cheek(19, 43)
c:cheek(42, 43)
H.dots(c, { { 30, 44 }, { 31, 45 }, { 32, 45 }, { 33, 44 } }, P.ink)

-- little leafy feet
c:part(c:ellipse(22, 55, 4, 2), "moss", { band = 1 })
c:part(c:ellipse(42, 55, 4, 2), "moss", { band = 1 })

H.done(c, "sp-chilli-chime-yard")

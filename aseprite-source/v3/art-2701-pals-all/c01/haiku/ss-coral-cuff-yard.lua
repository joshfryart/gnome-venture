-- Coral Cuff (ss-coral-cuff), yard 64x64. Haiku first pass, c01. Rootwarden, uncommon, Sunsprinkle.
-- A chunky petal-pink cuff band with a gold trim, four small coral reefs on its top knobs.
-- quirk: the four reefs (one per knob) with a cream sparkle on each tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("ss-coral-cuff-yard", 64)
local P = H.P

c:groundShadow(32, 58, 22, 3)

-- four coral reefs on four knobs (drawn first, the cuff overlaps their feet)
for _, x in ipairs({ 13, 25, 38, 50 }) do
  c:part(c:rect(x, 20, x + 2, 32), "ember", { band = 1 })
  c:part(c:ellipse(x + 1.5, 19, 4, 4), "ember")
  c:px(x - 2, 23, P.ember.base) c:px(x - 1, 22, P.ember.base)
  c:px(x + 4, 24, P.ember.base) c:px(x + 5, 23, P.ember.base)
  c:sparkle(x + 1, 16)
end

-- the cuff band
local cuff = c:rrect(8, 30, 56, 52, 11)
c:part(cuff, "petal", { band = 3 })
-- gold trim along the lower edge and a gold stitch line
c:hem(50, 14, 50)
c:stitch({ { 12, 40 }, { 52, 40 } })

-- the face on the band
c:eyeLocked(20, 36)
c:eyeLocked(38, 36)
c:cheek(16, 43) c:cheek(44, 43)
for x = 29, 34 do c:px(x, 44, P.ink) end
c:px(28, 43, P.ink) c:px(35, 43, P.ink)

H.done(c, "ss-coral-cuff-yard")

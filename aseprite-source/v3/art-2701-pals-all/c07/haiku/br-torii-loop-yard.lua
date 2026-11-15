-- Torii Loop (br-torii-loop), yard 64x64. Haiku first pass, c07. Seedkeeper, uncommon, Blossomreach.
-- A round gold hopper with a red torii gate on its head and a looped ember tail.
-- quirk: the gate on its head, with two sky motion dots behind it (it hops through gates).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("br-torii-loop-yard", 64)

c:groundShadow(32, 60, 16, 3)
-- looped tail behind the body
local ring = c:ellipse(51, 42, 6, 6)
ring:cut(c:ellipse(51, 42, 3, 3))
c:part(ring, "ember")
-- stubby legs
c:part(c:rect(22, 50, 25, 57), "wood")
c:part(c:rect(38, 50, 41, 57), "wood")
-- body
c:part(c:ellipse(32, 38, 16, 15), "gold", { band = 3 })
-- torii gate on the head (posts stand into the body)
c:part(c:rect(18, 15, 46, 17), "ember")
c:part(c:rect(22, 20, 42, 21), "ember")
c:part(c:rect(21, 18, 23, 26), "ember")
c:part(c:rect(41, 18, 43, 26), "ember")
c:px(19, 14, P.ember.deep) c:px(45, 14, P.ember.deep)
-- hop dots (quirk)
c:px(6, 26, P.sky.base) c:px(9, 33, P.sky.base) c:px(5, 40, P.sky.hi)
-- face
c:eyeLocked(24, 33)
c:eyeLocked(36, 33)
c:cheek(21, 40) c:cheek(40, 40)
c:px(30, 41, P.ink) c:px(31, 42, P.ink) c:px(32, 42, P.ink) c:px(33, 41, P.ink)

M.done(c, "br-torii-loop-yard")

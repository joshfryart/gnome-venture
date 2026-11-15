-- Acorn Nip (seedkeeper): an acorn that walks on tiny feet. Quirk: a spare acorn wedged in the cap, forgotten there.
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 59, 17, 2)
  c:part(H.E(24, 55, 4, 3), "wood", { band = 1 })
  c:part(H.E(40, 55, 4, 3), "wood", { band = 1 })
  c:part(H.E(32, 41, 15, 17), "gold")
  c:part(H.RR(14, 17, 50, 33, 7), "wood")
  if H.big then
    for y = 19, 32, 3 do for x = 16, 48 do if ((x + y) % 6 == 0) then local a = H.S(x) local b = H.S(y) c:px(a, b, P.wood.deep) end end end
  end
  c:part(H.R(30, 8, 33, 17), "wood", { band = 1 })
  c:part(H.Pg({ {34,10},{43,6},{45,11},{37,13} }), "moss", { band = 1 })
  -- the forgotten spare acorn
  c:part(H.E(21, 22, 3.5, 4), "gold", { band = 1 })
  c:part(H.R(18, 17, 24, 20), "wood", { band = 1, nopop = true })
  H.eye(26, 40) H.eye(38, 40)
  H.cheek(21, 46) H.cheek(41, 46)
  c:px(H.S(32), H.S(46), P.wood.deep)
  c:sparkle(H.S(46), H.S(30))
end

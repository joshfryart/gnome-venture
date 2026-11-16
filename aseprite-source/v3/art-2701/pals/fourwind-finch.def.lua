-- Fourwind Finch (wayfinder): round blue finch. Quirk: four tail feathers fan out like a compass rose (N E S W).
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 59, 14, 2)
  -- legs
  c:part(H.R(27, 50, 28, 57), "gold", { band = 1, nopop = true })
  c:part(H.R(36, 50, 37, 57), "gold", { band = 1, nopop = true })
  c:part(H.R(24, 57, 29, 58), "gold", { band = 1, nopop = true })
  c:part(H.R(34, 57, 39, 58), "gold", { band = 1, nopop = true })
  -- compass feathers: four, each a different colour tip
  c:part(H.Pg({ {14,46},{4,44},{4,50},{16,50} }), "dusk", { band = 1 })   -- W
  c:part(H.Pg({ {50,46},{60,44},{60,50},{48,50} }), "dusk", { band = 1 }) -- E
  c:part(H.Pg({ {28,50},{22,60},{28,60},{32,52} }), "dusk", { band = 1 }) -- S
  -- body
  c:part(H.E(32, 38, 16, 15), "sky")
  c:part(H.E(32, 46, 9, 7), "ember", { noshade = true, band = 1 })
  -- wing
  c:part(H.Pg({ {16,34},{26,30},{30,44},{20,48} }), "dusk", { band = 1 })
  -- N feather = head crest
  c:part(H.Pg({ {30,24},{26,8},{34,8},{36,24} }), "dusk", { band = 1 })
  -- beak
  c:part(H.Pg({ {44,32},{54,36},{44,40} }), "gold", { band = 1 })
  H.eye(38, 31)
  H.cheek(36, 40)
  c:sparkle(H.S(14), H.S(22))
end

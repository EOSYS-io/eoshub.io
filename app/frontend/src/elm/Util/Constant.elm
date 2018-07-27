module Util.Constant exposing (..)

-- module for collect unit constants
-- [time]
-- default   : millisec
-- constants : sec, min, hour, day


second : Int
second =
    1000


minute : Int
minute =
    60 * 1000


hour : Int
hour =
    60 * 60 * 1000


day : Int
day =
    24 * 60 * 60 * 1000



-- [digital prefix]
-- default   : 1
-- constants : kilo, mega, giga, tera


kilo : Int
kilo =
    1024


mega : Int
mega =
    1024 * 1024


giga : Int
giga =
    1024 * 1024 * 1024


tera : Int
tera =
    1024 * 1024 * 1024 * 1024

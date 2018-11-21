module Util.Constant exposing
    ( day
    , giga
    , hour
    , kilo
    , mega
    , millisec
    , minute
    , second
    , tera
    )

-- module for collect unit constants
-- [time]
-- default   : micro sec
-- constants : ms, sec, min, hour, day


millisec : Int
millisec =
    1000


second : Int
second =
    1000 * millisec


minute : Int
minute =
    60 * second


hour : Int
hour =
    60 * minute


day : Int
day =
    24 * hour



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

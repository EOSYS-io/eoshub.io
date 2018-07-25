module Util.Validation exposing (..)

import Regex exposing (regex, contains)


isAccount : String -> Bool
isAccount query =
    contains (regex "^[a-z.1-5]{1,12}$") query


isPublicKey : String -> Bool
isPublicKey query =
    contains (regex "^EOS[\\w]{50}$") query


checkAccountName : String -> Bool
checkAccountName query =
    contains (regex "^[a-z.1-5]{12,12}$") query

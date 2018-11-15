module Test.Data.Common exposing (tests)

import Data.Common exposing (..)
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


tests =
    let
        authorityJson =
            "{\"threshold\":3,\"keys\":[{\"key\":\"EOS6eFyNhE7d387tnKpQEKXR9MQ1c9hsJ28Ddyi5Cism1JHJiDauX\",\"weight\":1}],\"accounts\":[{\"permission\":{\"actor\":\"eosnewyorkio\",\"permission\":\"bpgovproxy\"},\"weight\":1},{\"permission\":{\"actor\":\"eospacificbp\",\"permission\":\"bpgovproxy\"},\"weight\":1},{\"permission\":{\"actor\":\"eosyskoreabp\",\"permission\":\"bpgovproxy\"},\"weight\":1}],\"waits\":[{\"wait_sec\":1,\"weight\":1}]}"

        authority =
            { threshold = 3
            , keys =
                [ { key = "EOS6eFyNhE7d387tnKpQEKXR9MQ1c9hsJ28Ddyi5Cism1JHJiDauX"
                  , weight = 1
                  }
                ]
            , accounts =
                [ { permission =
                        { actor = "eosnewyorkio"
                        , permission = "bpgovproxy"
                        }
                  , weight = 1
                  }
                , { permission =
                        { actor = "eospacificbp"
                        , permission = "bpgovproxy"
                        }
                  , weight = 1
                  }
                , { permission =
                        { actor = "eosyskoreabp"
                        , permission = "bpgovproxy"
                        }
                  , weight = 1
                  }
                ]
            , waits =
                [ { waitSec = 1
                  , weight = 1
                  }
                ]
            }

        authorityValue =
            Encode.object
                [ ( "accounts"
                  , Encode.list
                        [ Encode.object
                            [ ( "permission"
                              , Encode.object
                                    [ ( "actor", Encode.string "eosnewyorkio" )
                                    , ( "permission", Encode.string "bpgovproxy" )
                                    ]
                              )
                            , ( "weight", Encode.int 1 )
                            ]
                        , Encode.object
                            [ ( "permission"
                              , Encode.object
                                    [ ( "actor", Encode.string "eospacificbp" )
                                    , ( "permission", Encode.string "bpgovproxy" )
                                    ]
                              )
                            , ( "weight", Encode.int 1 )
                            ]
                        , Encode.object
                            [ ( "permission"
                              , Encode.object
                                    [ ( "actor", Encode.string "eosyskoreabp" )
                                    , ( "permission", Encode.string "bpgovproxy" )
                                    ]
                              )
                            , ( "weight", Encode.int 1 )
                            ]
                        ]
                  )
                , ( "threshold", Encode.int 3 )
                , ( "waits"
                  , Encode.list
                        [ Encode.object
                            [ ( "wait_sec", Encode.int 1 )
                            , ( "weight", Encode.int 1 )
                            ]
                        ]
                  )
                , ( "keys"
                  , Encode.list
                        [ Encode.object
                            [ ( "key", Encode.string "EOS6eFyNhE7d387tnKpQEKXR9MQ1c9hsJ28Ddyi5Cism1JHJiDauX" )
                            , ( "weight", Encode.int 1 )
                            ]
                        ]
                  )
                ]
    in
    describe "Data.Common"
        [ test "authorityDecoder" <|
            \() ->
                Expect.equal (Ok authority)
                    (Decode.decodeString authorityDecoder authorityJson)
        , test "encodeAuthority" <|
            \() ->
                Expect.equal (encodeAuthority authority) authorityValue
        ]

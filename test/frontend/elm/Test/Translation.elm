module Test.Translation exposing (tests)

import Expect
import Test exposing (..)
import Translation exposing (I18n(Login), Language(Chinese, English, Korean), getMessages, translate)


tests : Test
tests =
    describe "Translation module"
        [ describe "getMessages"
            [ test "Success" <|
                \() ->
                    Expect.equal
                        { korean = "로그인"
                        , english = "Sign In"
                        , chinese = "登入"
                        }
                        (getMessages Login)
            ]
        , describe "translate"
            [ test "korean" <|
                \() -> Expect.equal "로그인" (translate Korean Login)
            , test "english" <|
                \() -> Expect.equal "Sign In" (translate English Login)
            , test "chinese" <|
                \() -> Expect.equal "登入" (translate Chinese Login)
            ]
        ]

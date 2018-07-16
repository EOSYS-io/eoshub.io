module Test.Translation exposing (tests)

import Expect
import Translation exposing (Language(Korean, English), I18n(Success), translate, getMessages)
import Test exposing (..)


tests : Test
tests =
    describe "Translation module"
        [ describe "getMessages"
            [ test "Success" <|
                \() ->
                    Expect.equal
                        { korean = "성공!"
                        , english = "Success!"
                        }
                        (getMessages Success)
            ]
        , describe "translate"
            [ test "korean" <|
                \() -> Expect.equal "성공!" (translate Korean Success)
            , test "english" <|
                \() -> Expect.equal "Success!" (translate English Success)
            ]
        ]

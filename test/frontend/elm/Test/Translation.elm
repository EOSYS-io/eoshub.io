module Test.Translation exposing (tests)

import Expect
import Test exposing (..)
import Translation exposing (I18n(Hello), Language(Chinese, English, Korean), getMessages, translate)


tests : Test
tests =
    describe "Translation module"
        [ describe "getMessages"
            [ test "Success" <|
                \() ->
                    Expect.equal
                        { korean = "안녕하세요"
                        , english = "Hello"
                        , chinese = "哈罗!"
                        }
                        (getMessages Hello)
            ]
        , describe "translate"
            [ test "korean" <|
                \() -> Expect.equal "안녕하세요" (translate Korean Hello)
            , test "english" <|
                \() -> Expect.equal "Hello" (translate English Hello)
            , test "chinese" <|
                \() -> Expect.equal "哈罗!" (translate Chinese Hello)
            ]
        ]

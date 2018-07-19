module Translation exposing (Language(Korean, English), I18n(..), translate, getMessages)


type Language
    = English
    | Korean


type alias Messages =
    { korean : String
    , english : String
    }


type I18n
    = Success
    | Login
    | NewAccount
    | OpenCloseSidebar
    | Hello
    | WelcomeEosHub
    | IfYouHaveEos
    | IfYouAreNew
    | AttachableWallet1
    | AttachableWallet2
    | FurtherUpdate1
    | FurtherUpdate2
    | HowToAttach
    | Attach
    | ChangeWallet
    | MyAccount
    | SignOut
    | TotalAmount
    | StakedAmount
    | UnstakedAmount
    | FastTransactionPossible
    | ManageStaking
    | WhatIsStaking
    | Transfer
    | TransferDesc
    | Vote
    | VoteDesc
    | RamMarket
    | RamMarketDesc
    | Application
    | ApplicationDesc
    | ProxyVote
    | ProxyVoteDesc
    | Faq
    | FaqDesc
    | TransferSucceeded String
    | TransferFailed String
    | UnknownError
    | CheckDetail
    | CheckError
    | Close
    | TransferInfo1
    | TransferInfo2
    | TransferHelp
    | TransferableAmount
    | CheckAccountName
    | ReceiverAccountName
    | OverTransferableAmount
    | Memo


translate : Language -> I18n -> String
translate language i18n =
    let
        { english, korean } =
            getMessages i18n
    in
        case language of
            English ->
                english

            Korean ->
                korean



-- Internal helper function.
-- Note(heejae): Please write i18n messages in this function.


getMessages : I18n -> Messages
getMessages i18n =
    case i18n of
        Success ->
            { korean = "성공!", english = "Success!" }

        Login ->
            { korean = "로그인", english = "Sign In" }

        NewAccount ->
            { korean = "신규계정생성", english = "Create New" }

        OpenCloseSidebar ->
            { korean = "사이드바 영역 열기/닫기", english = "Open/Close sidebar" }

        Hello ->
            { korean = "안녕하세요", english = "Hello" }

        WelcomeEosHub ->
            { korean = "이오스 허브입니다", english = "Welcome to EOS Hub" }

        IfYouHaveEos ->
            { korean = "이오스 계정이 있으시면 로그인을,"
            , english = "If you have an EOS account, sign in"
            }

        IfYouAreNew ->
            { korean = "이오스가 처음이라면 신규계정을 생성해주세요!"
            , english = "If you are a newbie, create a new account!"
            }

        AttachableWallet1 ->
            { korean = "이오스 허브와 연동이"
            , english = "Attachable wallets"
            }

        AttachableWallet2 ->
            { korean = "가능한 EOS 지갑입니다", english = "for EOS Hub" }

        FurtherUpdate1 ->
            { korean = "추후 업데이트를 통해 연동가능한"
            , english = "Wait for further updates to include"
            }

        FurtherUpdate2 ->
            { korean = "지갑수를 늘려갈 예정이오니 조금만 기다려주세요!"
            , english = "more wallets!"
            }

        HowToAttach ->
            { korean = "지갑연동방법 알아보기", english = "How to attach" }

        Attach ->
            { korean = "연동하기", english = "Attach" }

        ChangeWallet ->
            { korean = "지갑 변경하기", english = "Change wallet" }

        MyAccount ->
            { korean = "내 계정 보기", english = "My Account" }

        SignOut ->
            { korean = "로그아웃", english = "Sign Out" }

        TotalAmount ->
            { korean = "총 보유 수량", english = "Total Amount" }

        UnstakedAmount ->
            { korean = "보관 취소 토큰", english = "Unstaked Amount" }

        StakedAmount ->
            { korean = "보관한 토큰", english = "Staked Amount" }

        FastTransactionPossible ->
            { korean = "원할한 트랜잭션 사용이 가능합니다"
            , english = "Fast transactions possible"
            }

        ManageStaking ->
            { korean = "보관 토큰 관리하기", english = "Manage staking" }

        WhatIsStaking ->
            { korean = "토큰 보관이 뭔가요?", english = "What is staking?" }

        Transfer ->
            { korean = "전송하기", english = "Transfer" }

        TransferDesc ->
            { korean = "여기서 토큰을 보내실 수 있어요", english = "Send tokens here" }

        Vote ->
            { korean = "투표하기", english = "Vote" }

        VoteDesc ->
            { korean = "홀더라면 투표를!", english = "Vote with your EOS" }

        RamMarket ->
            { korean = "램마켓", english = "Ram Market" }

        RamMarketDesc ->
            { korean = "램을 사고 팔 수 있어요", english = "Buy or sell RAM here" }

        Application ->
            { korean = "어플리케이션", english = "Application" }

        ApplicationDesc ->
            { korean = "이오스 기반의 다양한 서비스들을 만나보세요"
            , english = "Meet interesting applications based on EOS"
            }

        ProxyVote ->
            { korean = "대리투표", english = "Proxy Voting" }

        ProxyVoteDesc ->
            { korean = "맡겨 두시면 대신 투표 해드립니다"
            , english = "Delegate your vote to a proxy"
            }

        Faq ->
            { korean = "FAQ", english = "FAQ" }

        FaqDesc ->
            { korean = "이오스에 대해 궁금하신 내용들을 정리했어요"
            , english = "All you need to know about EOS Hub"
            }

        TransferSucceeded receiver ->
            { korean = receiver ++ "에게 전송완료!"
            , english = "Successfully transferred to " ++ receiver ++ "!"
            }

        TransferFailed code ->
            { korean = code ++ " 코드오류로 전송실패"
            , english = "Failed with error code " ++ code
            }

        UnknownError ->
            { korean = "알 수 없는 에러!", english = "Unknown Error!" }

        CheckDetail ->
            { korean = "+ 내역 보러가기", english = "+ Check details" }

        CheckError ->
            { korean = "+ 오류 확인하러가기", english = "+ Check error details" }

        Close ->
            { korean = "닫기", english = "Close" }

        TransferInfo1 ->
            { korean = "총 보유수량과 전송가능한 수량은"
            , english = "Total amount and transferable amount can be "
            }

        TransferInfo2 ->
            { korean = "보관 취소중인 수량에 따라 다를 수 있습니다."
            , english = "different depending on unstaking amounts"
            }

        TransferHelp ->
            { korean = "전송이 혹시 처음이신가요?", english = "Need help?" }

        TransferableAmount ->
            { korean = "전송 가능한 수량", english = "Transferable amount" }

        CheckAccountName ->
            { korean = "알맞는 계정인지 확인해 주세요.", english = "Please check the account name" }

        ReceiverAccountName ->
            { korean = "받는 계정", english = "Receiver's Account Name" }

        OverTransferableAmount ->
            { korean = "전송 가능한 수량보다 많아요!", english = "Over transferable amount!" }

        Memo ->
            { korean = "메모하기", english = "Memo" }

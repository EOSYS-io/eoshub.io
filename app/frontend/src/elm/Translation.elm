module Translation exposing (Language(Korean, English, Chinese), I18n(..), translate, getMessages)


type Language
    = English
    | Korean
    | Chinese


type alias Messages =
    { korean : String
    , english : String
    , chinese : String
    }


type I18n
    = EmptyMessage
    | DebugMessage String
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
    | MemoTooLong
    | MemoNotMandatory
    | UnderConstruction1
    | UnderConstruction2
    | UnderConstructionDesc1
    | UnderConstructionDesc2
    | ConfirmEmailSent
    | AlreadyExistEmail
    | AccountCreationFailure


translate : Language -> I18n -> String
translate language i18n =
    let
        { english, korean, chinese } =
            getMessages i18n
    in
        case language of
            English ->
                english

            Korean ->
                korean

            Chinese ->
                chinese



-- Internal helper function.
-- Note(heejae): Please write i18n messages in this function.


getMessages : I18n -> Messages
getMessages i18n =
    case i18n of
        EmptyMessage ->
            { korean = ""
            , english = ""
            , chinese = ""
            }

        DebugMessage error ->
            { korean = error
            , english = error
            , chinese = error
            }

        Login ->
            { korean = "로그인"
            , english = "Sign In"
            , chinese = "登入"
            }

        NewAccount ->
            { korean = "신규계정 만들기"
            , english = "Create New"
            , chinese = "创建账户"
            }

        OpenCloseSidebar ->
            { korean = "사이드바 영역 열기/닫기"
            , english = "Open/Close sidebar"
            , chinese = "Open/Close sidebar"
            }

        Hello ->
            { korean = "안녕하세요"
            , english = "Hello"
            , chinese = "哈罗!"
            }

        WelcomeEosHub ->
            { korean = "이오스 허브입니다"
            , english = "Welcome to EOS Hub"
            , chinese = "欢迎使用eoshub"
            }

        IfYouHaveEos ->
            { korean = "이오스 계정이 있으시면 로그인을,"
            , english = "If you have an EOS account, sign in"
            , chinese = "如果您有EOS账户请进行账户联动,"
            }

        IfYouAreNew ->
            { korean = "이오스가 처음이라면 신규계정을 생성해주세요!"
            , english = "If you are a newbie, create a new account!"
            , chinese = "如果没有EOS账户请先进行注册!"
            }

        AttachableWallet1 ->
            { korean = "이오스 허브와 연동이"
            , english = "Attachable wallets"
            , chinese = "能够联动的钱包"
            }

        AttachableWallet2 ->
            { korean = "가능한 EOS 지갑입니다"
            , english = "for EOS Hub"
            , chinese = ""
            }

        FurtherUpdate1 ->
            { korean = "추후 업데이트를 통해 연동가능한"
            , english = "Wait for further updates to include"
            , chinese = "通过更新逐渐增加"
            }

        FurtherUpdate2 ->
            { korean = "지갑수를 늘려갈 예정이오니 조금만 기다려주세요!"
            , english = "more wallets!"
            , chinese = "能够联动的钱包数量"
            }

        HowToAttach ->
            { korean = "지갑연동방법 알아보기"
            , english = "How to attach"
            , chinese = "了解钱包联动"
            }

        Attach ->
            { korean = "연동하기"
            , english = "Attach"
            , chinese = "联动"
            }

        ChangeWallet ->
            { korean = "지갑 변경하기"
            , english = "Change wallet"
            , chinese = "转换钱包"
            }

        MyAccount ->
            { korean = "내 계정 보기"
            , english = "My Account"
            , chinese = "查看我的账户"
            }

        SignOut ->
            { korean = "로그아웃"
            , english = "Sign Out"
            , chinese = "退出"
            }

        TotalAmount ->
            { korean = "총 보유 수량"
            , english = "Total Amount"
            , chinese = "总数量"
            }

        UnstakedAmount ->
            { korean = "보관 취소 토큰"
            , english = "Unstaked Amount"
            , chinese = "unstaking代币"
            }

        StakedAmount ->
            { korean = "보관한 토큰"
            , english = "Staked Amount"
            , chinese = "staking代币"
            }

        FastTransactionPossible ->
            { korean = "원할한 트랜잭션 사용이 가능합니다"
            , english = "Fast transactions possible"
            , chinese = "可以进行交易"
            }

        ManageStaking ->
            { korean = "보관 토큰 관리하기"
            , english = "Manage staking"
            , chinese = "管理staking代币"
            }

        WhatIsStaking ->
            { korean = "토큰 보관이 뭔가요?"
            , english = "What is staking?"
            , chinese = "什么是管理staking代币?"
            }

        Transfer ->
            { korean = "전송하기"
            , english = "Transfer"
            , chinese = "传送"
            }

        TransferDesc ->
            { korean = "여기서 토큰을 보내실 수 있어요"
            , english = "Send tokens here"
            , chinese = "去传送代币"
            }

        Vote ->
            { korean = "투표하기"
            , english = "Vote"
            , chinese = "投票"
            }

        VoteDesc ->
            { korean = "토큰 홀더라면 투표하실 수 있어요"
            , english = "Vote with your EOS"
            , chinese = "持有EOS币的用户可以进行投票"
            }

        RamMarket ->
            { korean = "램마켓"
            , english = "Ram Market"
            , chinese = "RAM市场"
            }

        RamMarketDesc ->
            { korean = "램을 사고 팔 수 있어요"
            , english = "Buy or sell RAM here"
            , chinese = "去买卖RAM"
            }

        Application ->
            { korean = "어플리케이션"
            , english = "Application"
            , chinese = "应用"
            }

        ApplicationDesc ->
            { korean = "이오스 기반의 다양한 서비스들을 만나보세요"
            , english = "Meet interesting applications based on EOS"
            , chinese = "请体验各种各样的应用"
            }

        ProxyVote ->
            { korean = "대리투표"
            , english = "Proxy Voting"
            , chinese = "代理投票"
            }

        ProxyVoteDesc ->
            { korean = "맡겨 두시면 대신 투표 해드립니다"
            , english = "Delegate your vote to a proxy"
            , chinese = "我们可以为您代理投票"
            }

        Faq ->
            { korean = "FAQ"
            , english = "FAQ"
            , chinese = "常见问题"
            }

        FaqDesc ->
            { korean = "이오스에 대해 궁금하신 내용들을 정리했어요"
            , english = "All you need to know about EOS Hub"
            , chinese = "总结了有关EOS的常见问题"
            }

        TransferSucceeded receiver ->
            { korean = receiver ++ "에게 전송완료!"
            , english = "Successfully transferred to " ++ receiver ++ "!"
            , chinese = "向" ++ receiver ++ "传送完毕!"
            }

        TransferFailed code ->
            { korean = code ++ " 코드오류로 전송실패"
            , english = "Failed with error code " ++ code
            , chinese = "由于" ++ code ++ "代码错误传送失败!"
            }

        UnknownError ->
            { korean = "알 수 없는 에러!"
            , english = "Unknown Error!"
            , chinese = "未知错误!"
            }

        CheckDetail ->
            { korean = "+ 내역 보러가기"
            , english = "+ Check details"
            , chinese = " +去看详情"
            }

        CheckError ->
            { korean = "+ 오류 확인하러가기"
            , english = "+ Check error details"
            , chinese = "去看错误"
            }

        Close ->
            { korean = "닫기"
            , english = "Close"
            , chinese = "关"
            }

        TransferInfo1 ->
            { korean = "총 보유수량과 전송가능한 수량은"
            , english = "Total amount and transferable amount can be "
            , chinese = "在unstaking过程中有可能产生"
            }

        TransferInfo2 ->
            { korean = "보관 취소중인 수량에 따라 다를 수 있습니다."
            , english = "different depending on unstaking amounts"
            , chinese = "代币总数量与可传送代币数量的不一致"
            }

        TransferHelp ->
            { korean = "전송이 혹시 처음이신가요?"
            , english = "Need help?"
            , chinese = "您是第一次进行传送的吗?"
            }

        TransferableAmount ->
            { korean = "전송 가능한 수량"
            , english = "Transferable amount"
            , chinese = "可传送数量"
            }

        CheckAccountName ->
            { korean = "알맞는 계정인지 확인해 주세요."
            , english = "Please check the account name"
            , chinese = "请先确认是否合适的账户名"
            }

        ReceiverAccountName ->
            { korean = "받는 계정"
            , english = "Receiver's Account Name"
            , chinese = "接受账户"
            }

        OverTransferableAmount ->
            { korean = "전송 가능한 수량보다 많아요!"
            , english = "Over transferable amount!"
            , chinese = "多于能够传送的数量！"
            }

        Memo ->
            { korean = "메모하기"
            , english = "Memo"
            , chinese = "记录"
            }

        MemoTooLong ->
            { korean = "256 바이트 이상은 불가능합니다."
            , english = "Memo is too long!"
            , chinese = "备忘录太长了!"
            }

        MemoNotMandatory ->
            { korean = "필수는 아니에요 :)"
            , english = "Optional :)"
            , chinese = "选填"
            }

        UnderConstruction1 ->
            { korean = "여기는 아직"
            , english = "Comming soon!"
            , chinese = "这里还在"
            }

        UnderConstruction2 ->
            { korean = "공사중이에요!"
            , english = ""
            , chinese = "工事当中"
            }

        UnderConstructionDesc1 ->
            { korean = "추후 업데이트 될 예정이오니"
            , english = "This page will be updated soon"
            , chinese = "我们会短时间内进行更新"
            }

        UnderConstructionDesc2 ->
            { korean = "조금만 기다려주세요!"
            , english = "We appreciate your patience!"
            , chinese = "请各位尽情等待!"
            }

        ConfirmEmailSent ->
            { korean = "이메일을 확인해주세요!"
            , english = "Please check your email!"
            , chinese = "请检查您的电子邮件！"
            }

        AlreadyExistEmail ->
            { korean = "이미 존재하는 이메일입니다."
            , english = "This email already exists"
            , chinese = "此电子邮件已存在"
            }

        AccountCreationFailure ->
            { korean = "EOS 계정 생성에 실패했습니다."
            , english = "Failed to create EOS account"
            , chinese = "无法创建EOS帐户"
            }

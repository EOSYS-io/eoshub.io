module Translation exposing (Language(Korean, English, Chinese), I18n(..), translate, getMessages, toLanguage, toLocale)


type Language
    = English
    | Korean
    | Chinese


toLanguage : String -> Language
toLanguage locale =
    case locale of
        "ko" ->
            Korean

        "en" ->
            English

        "zh-cn" ->
            Chinese

        _ ->
            Korean


toLocale : Language -> String
toLocale language =
    case language of
        Korean ->
            "ko"

        English ->
            "en"

        Chinese ->
            "zh-cn"


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
    | AccountCreationProgressEmail
    | AccountCreationProgressKeypair
    | AccountCreationProgressCreateNew
    | AccountCreationConfirmEmail
    | AccountCreationClickConfirmLink
    | AccountCreationEmailValid
    | AccountCreationEmailInvalid
    | AccountCreationEmailSend
    | AccountCreationAlreadyHaveAccount
    | AccountCreationLoginLink
    | AccountCreationEmailConfirmed
    | ClickNext
    | Next


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
            , chinese = "您好!"
            }

        WelcomeEosHub ->
            { korean = "이오스 허브입니다"
            , english = "Welcome to EOS Hub"
            , chinese = "我是eoshub"
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
            , chinese = "能够与eoshub"
            }

        AttachableWallet2 ->
            { korean = "가능한 EOS 지갑입니다"
            , english = "for EOS Hub"
            , chinese = "联动的钱包"
            }

        FurtherUpdate1 ->
            { korean = "추후 업데이트를 통해 연동가능한"
            , english = "Wait for further updates to include"
            , chinese = "通过更新我们将逐渐扩"
            }

        FurtherUpdate2 ->
            { korean = "지갑수를 늘려갈 예정이오니 조금만 기다려주세요!"
            , english = "more wallets!"
            , chinese = "展能够联动的钱包数量"
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
            , chinese = "传送代币"
            }

        Vote ->
            { korean = "투표하기"
            , english = "Vote"
            , chinese = "投票"
            }

        VoteDesc ->
            { korean = "토큰 홀더라면 투표하실 수 있어요"
            , english = "Vote with your EOS"
            , chinese = "EOS币持有者都可以投票"
            }

        RamMarket ->
            { korean = "램마켓"
            , english = "Ram Market"
            , chinese = "RAM市场"
            }

        RamMarketDesc ->
            { korean = "램을 사고 팔 수 있어요"
            , english = "Buy or sell RAM here"
            , chinese = "买卖RAM"
            }

        Application ->
            { korean = "어플리케이션"
            , english = "Application"
            , chinese = "应用"
            }

        ApplicationDesc ->
            { korean = "이오스 기반의 다양한 서비스들을 만나보세요"
            , english = "Meet interesting applications based on EOS"
            , chinese = "请体验基于EOS的各种各样的应用"
            }

        ProxyVote ->
            { korean = "대리투표"
            , english = "Proxy Voting"
            , chinese = "代理投票"
            }

        ProxyVoteDesc ->
            { korean = "맡겨 두시면 대신 투표 해드립니다"
            , english = "Delegate your vote to a proxy"
            , chinese = "我们能够为您代理投票"
            }

        Faq ->
            { korean = "FAQ"
            , english = "FAQ"
            , chinese = "常见问题"
            }

        FaqDesc ->
            { korean = "이오스에 대해 궁금하신 내용들을 정리했어요"
            , english = "All you need to know about EOS Hub"
            , chinese = "我们总结了有关EOS的常见问题"
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
            , chinese = "在unstaking的过程当中有可能产生代币"
            }

        TransferInfo2 ->
            { korean = "보관 취소중인 수량에 따라 다를 수 있습니다."
            , english = "different depending on unstaking amounts"
            , chinese = "的总数量与能够传送的代币数量的误差"
            }

        TransferHelp ->
            { korean = "전송이 혹시 처음이신가요?"
            , english = "Need help?"
            , chinese = "您是第一次进行传送的吗?"
            }

        TransferableAmount ->
            { korean = "전송 가능한 수량"
            , english = "Transferable amount"
            , chinese = "能够传送的数量"
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
            , chinese = "不是必填事项 :)"
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

        AccountCreationProgressEmail ->
            { korean = "인증하기"
            , english = "Email"
            , chinese = "认证"
            }

        AccountCreationProgressKeypair ->
            { korean = "키 생성"
            , english = "Key pair"
            , chinese = "密钥生成"
            }

        AccountCreationProgressCreateNew ->
            { korean = "계정 생성"
            , english = "Create New"
            , chinese = "创建一个帐户"
            }

        AccountCreationConfirmEmail ->
            { korean = "새로운 계정을 만들기 위해 이메일을 인증하세요!"
            , english = "Type in your email address to make a new account!"
            , chinese = "验证您的电子邮件以创建新帐户！"
            }

        AccountCreationClickConfirmLink ->
            { korean = "받으신 메일의 링크를 클릭해주세요."
            , english = "Confirm by clicking the link in the email you receive"
            , chinese = "单击您收到的电子邮件中的链接进行确认"
            }

        AccountCreationEmailValid ->
            { korean = "올바른 이메일 주소입니다."
            , english = "Valid email address"
            , chinese = "这是一个有效的电子邮件地址。"
            }

        AccountCreationEmailInvalid ->
            { korean = "잘못된 이메일 주소입니다."
            , english = "Invalid email address"
            , chinese = "电子邮件地址无效。"
            }

        AccountCreationEmailSend ->
            { korean = "링크 보내기"
            , english = "Send Link"
            , chinese = "发送链接"
            }

        AccountCreationAlreadyHaveAccount ->
            { korean = "이미 이오스 계정이 있으신가요?"
            , english = "Already have an EOS account?"
            , chinese = "已经有一个eos帐户？"
            }

        AccountCreationLoginLink ->
            { korean = "로그인하기"
            , english = "Sign in"
            , chinese = "签到"
            }

        AccountCreationEmailConfirmed ->
            { korean = "이메일 인증완료!"
            , english = "Email Confirmed!"
            , chinese = "电子邮件已确认！"
            }

        ClickNext ->
            { korean = "다음으로 넘어가주세요"
            , english = "Click Next"
            , chinese = "点击下一步"
            }

        Next ->
            { korean = "다음"
            , english = "Next"
            , chinese = "下一个"
            }

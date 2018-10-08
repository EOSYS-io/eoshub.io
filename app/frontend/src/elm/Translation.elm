module Translation exposing
    ( I18n(..)
    , Language(Chinese, English, Korean)
    , getMessages
    , toLanguage
    , toLocale
    , translate
    )


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
    | HowToUseEosHub
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
    | TransactionPossible
    | ManageStaking
    | WhatIsStaking
    | Transfer
    | TransferHereDesc
    | ManageResource
    | ManageResourceDesc
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
    | Confirm
    | TransferInfo1
    | TransferInfo2
    | TransferHelp
    | TransferDesc
    | TransferableAmount
    | CheckAccountName
    | ReceiverAccountName
    | AccountExample
    | ValidAccountI18n
    | TransferAmount
    | InvalidAmount
    | OverTransferableAmount
    | Transferable
    | TransferableAmountDesc
    | Memo
    | MemoTooLong
    | MemoNotMandatory
    | ConfirmEmailSent
    | AlreadyExistEmail
    | AccountCreationFailure
    | AccountCreationProgressEmail
    | AccountCreationProgressKeypair
    | AccountCreationProgressCreateNew
    | AccountCreationConfirmEmail
    | AccountCreationEnterEmail
    | AccountCreationEnterVerificationCode
    | AccountCreationEmailValid
    | AccountCreationEmailInvalid
    | AccountCreationSendEmail
    | AccountCreationAlreadyHaveAccount
    | AccountCreationLoginLink
    | AccountCreationEmailConfirmed
    | AccountCreationAgreeEosConstitution
    | AccountCreationButton
    | ClickNext
    | Next
    | AccountCreationEmailConfirmFailure
    | AccountCreationKeypairGeneration
    | AccountCreationKeypairRegenerate
    | AccountCreationKeypairCaution
    | PublicKey
    | PrivateKey
    | CopyAll
    | AccountCreationNameValid
    | AccountCreationNameInvalid
    | AccountCreation
    | AccountCreationNameCondition
    | AccountCreationInput
    | AccountCreationNamePlaceholder
    | AccountCreationCongratulation
    | AccountCreationWelcome
    | AccountCreationYouCanSignIn
    | AccountCreationGoHome
    | Search
    | SearchDescribe
    | SearchAccount
    | SearchResultAccount
    | Account
    | Resource
    | Transactions
    | Number
    | Type
    | Time
    | Info
    | All
    | ShowMore
    | SearchPublicKey
    | SearchResultPublicKey
    | StakePossible String String
    | StakePossibleAmountDesc
    | OverStakePossibleAmount
    | DelegatebwSucceeded String
    | DelegatebwFailed String
    | UndelegatebwSucceeded String
    | UndelegatebwFailed String
    | UnstakeInvalidQuantity String
    | UnstakeOverValidQuantity String
    | UnstakePossible
    | BuyramSucceeded String
    | BuyramFailed String
    | SellramSucceeded String
    | SellramFailed String
    | VoteSucceeded String
    | VoteFailed String
    | VoteProxyPhilosophy


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

        HowToUseEosHub ->
            { korean = "이오스허브 사용법 보기"
            , english = "How to use eoshub"
            , chinese = "查看eoshub使用说明"
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

        TransactionPossible ->
            { korean = "트랜잭션 가능"
            , english = "Transactions possible"
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

        TransferHereDesc ->
            { korean = "여기서 토큰을 보내실 수 있어요"
            , english = "Send tokens here"
            , chinese = "去传送代币"
            }

        ManageResource ->
            { korean = "리소스 관리"
            , english = "Manage Resource"
            , chinese = "管理资源"
            }

        ManageResourceDesc ->
            { korean = "CPU, 네트워크 자원관리를 하실 수 있어요"
            , english = "Manage CPU, Network"
            , chinese = "在这儿可以管理CPU和网络资源"
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

        Confirm ->
            { korean = "확인"
            , english = "Confirm"
            , chinese = "确认"
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

        TransferDesc ->
            { korean = "원하시는 수량만큼 토큰을 전송하세요 :)"
            , english = "Transfer Tokens"
            , chinese = "去传送代币"
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
            { korean = "전송하실 계정의 이름을 입력하세요."
            , english = "Receiver's Account Name"
            , chinese = "请输入被传送的账户名"
            }

        AccountExample ->
            { korean = "계정이름 예시: eoshubby"
            , english = "Example: eoshubby"
            , chinese = "例子: eoshubby"
            }

        ValidAccountI18n ->
            { korean = "올바른 계정입니다."
            , english = "Valid Account"
            , chinese = ""
            }

        TransferAmount ->
            { korean = "전송하실 수량을 입력하세요"
            , english = "Type in the amount to send"
            , chinese = "请输入要传送的数量"
            }

        InvalidAmount ->
            { korean = "유효하지 않은 수량입니다."
            , english = "Invalid amount!"
            , chinese = "金额无效"
            }

        OverTransferableAmount ->
            { korean = "전송 가능한 수량보다 많아요!"
            , english = "Over transferable amount!"
            , chinese = "多于能够传送的数量！"
            }

        Transferable ->
            { korean = "전송 가능한 수량입니다."
            , english = "Transferable amount"
            , chinese = "可传送的数量"
            }

        TransferableAmountDesc ->
            { korean = "최대 전송가능한 수량만큼 입력 가능합니다."
            , english = "Type in up to the transferable amount"
            , chinese = "只能输入可传送的数量范围内"
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
            { korean = "이메일 인증"
            , english = "Email Authentication"
            , chinese = "邮件验证"
            }

        AccountCreationEnterEmail ->
            { korean = "이메일을 입력해주세요."
            , english = "Please enter your e-mail."
            , chinese = "请输入您的电子邮件。"
            }

        AccountCreationEnterVerificationCode ->
            { korean = "메일로 전송된 코드를 입력해주세요."
            , english = "Please enter the code sent by e-mail."
            , chinese = "请输入通过电子邮件发送的代码。"
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

        AccountCreationSendEmail ->
            { korean = "코드 전송"
            , english = "Send Code"
            , chinese = "代码转移"
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
            { korean = "이메일 인증이 완료되었습니다."
            , english = "Email Confirmed!"
            , chinese = "电子邮件验证已完成。"
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

        AccountCreationEmailConfirmFailure ->
            { korean = "일치하지 않는 코드입니다."
            , english = "Unmatched code"
            , chinese = "无与伦比的代码。"
            }

        AccountCreationKeypairGeneration ->
            { korean = "키 생성"
            , english = "Key pair generation"
            , chinese = "密钥生成"
            }

        AccountCreationKeypairRegenerate ->
            { korean = "새로 고침"
            , english = "Regenerate"
            , chinese = "刷新"
            }

        AccountCreationKeypairCaution ->
            { korean = "* 계정의 소유권을 증명하는 정보이니 꼭 복사하여 안전하게 보관하세요!"
            , english = "* Make sure you copy it and keep it safe, as this information proves ownership of your account!"
            , chinese = "* 请确保您复制并保证其安全，因为此信息证明了您帐户的所有权！"
            }

        PublicKey ->
            { korean = "퍼블릭 키"
            , english = "Public Key"
            , chinese = "公钥"
            }

        PrivateKey ->
            { korean = "프라이빗 키"
            , english = "Private Key"
            , chinese = "私钥"
            }

        CopyAll ->
            { korean = "한번에 복사하기"
            , english = "Copy All"
            , chinese = "立即复制"
            }

        AccountCreationNameValid ->
            { korean = "가능한 계정이에요"
            , english = "Available"
            , chinese = "这是一个可能的帐户。"
            }

        AccountCreationNameInvalid ->
            { korean = "불가능한 계정이에요"
            , english = "Unavailable"
            , chinese = "这是一个不可能的帐户。"
            }

        AccountCreation ->
            { korean = "신규계정 만들기"
            , english = "Create a new account"
            , chinese = "创建一个新帐户"
            }

        AccountCreationNameCondition ->
            { korean = "영어 소문자와 숫자(1~5)의 조합으로 12글자만 가능합니다."
            , english = "The combination of English lower case letters and numbers (1 to 5) allows only 12 letters."
            , chinese = "英文小写字母和数字（1到5）的组合仅允许12个字母。"
            }

        AccountCreationInput ->
            { korean = "계정명 입력"
            , english = "Enter account name"
            , chinese = "输入帐户名称"
            }

        AccountCreationNamePlaceholder ->
            { korean = "ex) eoshuby12345"
            , english = "ex) eoshuby12345"
            , chinese = "ex) eoshuby12345"
            }

        AccountCreationAgreeEosConstitution ->
            { korean = "EOS Constitution에 동의합니다."
            , english = "I agree to the EOS Constitution."
            , chinese = "我同意EOS Constitution。"
            }

        AccountCreationButton ->
            { korean = "계정 만들기"
            , english = "Create"
            , chinese = "创建"
            }

        AccountCreationCongratulation ->
            { korean = "축하합니다!"
            , english = "Congratulations!"
            , chinese = "恭喜！"
            }

        AccountCreationWelcome ->
            { korean = "새로운 계정을 만들었어요."
            , english = "A new account is created"
            , chinese = "我创建了一个新帐户"
            }

        AccountCreationYouCanSignIn ->
            { korean = "이제 홈에서 로그인하실 수 있습니다."
            , english = "Now you can Sign In"
            , chinese = "现在你可以登录了"
            }

        AccountCreationGoHome ->
            { korean = "메인으로 가기"
            , english = "Go Home"
            , chinese = "回家"
            }

        Search ->
            { korean = "검색"
            , english = "Search"
            , chinese = "查询"
            }

        SearchDescribe ->
            { korean = "계정명, 공개 키 검색하기"
            , english = "Search account name or public key"
            , chinese = "查询账户名，公匙"
            }

        SearchAccount ->
            { korean = "계정 검색"
            , english = "Search account "
            , chinese = "查询账户"
            }

        SearchResultAccount ->
            { korean = "검색하신 계정에 대한 정보입니다 :)"
            , english = "Search result"
            , chinese = "如下为查询到的账户信息"
            }

        Account ->
            { korean = "계정 이름"
            , english = "Account"
            , chinese = "账户名"
            }

        Resource ->
            { korean = "리소스"
            , english = "Resource"
            , chinese = "资源"
            }

        Transactions ->
            { korean = "트랜잭션"
            , english = "Transactions"
            , chinese = "交易"
            }

        Number ->
            { korean = "번호"
            , english = "No."
            , chinese = "号码"
            }

        Type ->
            { korean = "타입"
            , english = "Type"
            , chinese = "种类"
            }

        Time ->
            { korean = "시간"
            , english = "Time"
            , chinese = "时间"
            }

        Info ->
            { korean = "정보"
            , english = "Info"
            , chinese = "信息"
            }

        All ->
            { korean = "전체"
            , english = "All"
            , chinese = "全部"
            }

        ShowMore ->
            { korean = "더보기"
            , english = "Show more"
            , chinese = "更多"
            }

        SearchPublicKey ->
            { korean = "공개 키 검색"
            , english = "Search Public Key"
            , chinese = "查询公匙"
            }

        SearchResultPublicKey ->
            { korean = "검색하신 공개 키에 대한 정보입니다 :)"
            , english = "Search result of the public key"
            , chinese = "如下为查询到的公匙信息"
            }

        StakePossible cpu net ->
            { korean = "한 CPU " ++ cpu ++ " / NET " ++ net ++ " 스테이크 됩니다."
            , english = "한 CPU " ++ cpu ++ " / NET " ++ net ++ " 스테이크 됩니다."
            , chinese = "한 CPU " ++ cpu ++ " / NET " ++ net ++ " 스테이크 됩니다."
            }

        StakePossibleAmountDesc ->
            { korean = "보유한 수량만큼 스테이크 할 수 있습니다."
            , english = ""
            , chinese = ""
            }

        OverStakePossibleAmount ->
            { korean = "스테이크 가능한 수량보다 많습니다."
            , english = ""
            , chinese = ""
            }

        DelegatebwSucceeded receiver ->
            { korean = receiver ++ "에게 스테이크 완료!"
            , english = ""
            , chinese = ""
            }

        DelegatebwFailed code ->
            { korean = code ++ " 코드오류로 스테이크 실패"
            , english = "Failed with error code " ++ code
            , chinese = ""
            }

        UndelegatebwSucceeded receiver ->
            { korean = receiver ++ "으로 언스테이크 완료!"
            , english = ""
            , chinese = ""
            }

        UndelegatebwFailed code ->
            { korean = code ++ " 코드오류로 언스테이크 실패"
            , english = "Failed with error code " ++ code
            , chinese = ""
            }

        UnstakeInvalidQuantity resourceType ->
            { korean = resourceType ++ "의 수량입력이 잘못되었습니다"
            , english = ""
            , chinese = resourceType ++ "数量输入有误"
            }

        UnstakeOverValidQuantity resourceType ->
            { korean = "언스테이크 가능한 " ++ resourceType ++ " 수량을 초과하였습니다."
            , english = ""
            , chinese = ""
            }

        UnstakePossible ->
            { korean = "언스테이크 가능합니다 :)"
            , english = ""
            , chinese = "可以进行Unstake：）"
            }

        BuyramSucceeded str ->
            { korean = str ++ " 에게 구매 완료."
            , english = ""
            , chinese = ""
            }

        BuyramFailed code ->
            { korean = code ++ " 코드오류로 램 구매 실패"
            , english = ""
            , chinese = ""
            }

        SellramSucceeded _ ->
            { korean = "판매 완료!"
            , english = ""
            , chinese = ""
            }

        SellramFailed code ->
            { korean = code ++ " 코드오류로 램 판매 실패"
            , english = ""
            , chinese = ""
            }

        VoteSucceeded _ ->
            { korean = "투표 성공"
            , english = ""
            , chinese = ""
            }

        VoteFailed code ->
            { korean = code ++ " 코드오류로 투표 실패"
            , english = ""
            , chinese = ""
            }

        VoteProxyPhilosophy ->
            { korean = "DPOS 기반의 EOS 블록체인은 신뢰 받는 블록 생성자들에 의해서 운영이 될 때 비로소 그 가치를 발휘할 수있습니다. 신뢰의 척도로는 다음과 같은 3가지 기준을 세웠습니다. 첫번째는 기술적인 역량 보유 여부이며, 두번째는 거버넌스 및 커뮤니티 기여 여부이고, 마지막으로 세번째는 올바른 비전과 방향성 제시 여부입니다. 우리 eoshub는 EOS 생태계의 발전적 가치를 지향하며, 이를 위해 가장 신뢰할 수 있고 블록 생성의 자격이 있는 BP들에게 투표합니다."
            , english = "EOS Blockchain is secured and utilized only when the Block Producers have the trustworthiness. Trustworthiness could be measured by three important criteria. Technical Excellence, Governance and Community Engagement, and Sharing the Vision and Value of Their Own. We, the Eoshub, aim for the advancement and improvement of EOS ecosystem and will vote for BPs who deserve the empowerment."
            , chinese = ""
            }

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
    | IfYouHaveEos
    | IfYouAreNew
    | AttachableWallet1
    | AttachableWallet2
    | FurtherUpdate1
    | FurtherUpdate2
    | HowToAttach
    | HowToAttachLink
    | Attach
    | ChangeWallet
    | MyAccount
    | SignOut
    | TotalAmount
    | StakedAmount
    | UnstakedAmount
    | TransactionOptimal
    | TransactionFine
    | TransactionAttention
    | TransactionWarning
    | ManageStaking
    | WhatIsStaking
    | Transfer
    | TransferHereDesc
    | ManageResourceDesc
    | Vote
    | SimplifiedVote
    | VoteDesc
    | RamMarket
    | RamMarketDesc
    | GoToTelegramLink
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
    | TransferAmount
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
    | AccountCreationKeypairCopiedToClipboard
    | PublicKey
    | PrivateKey
    | CopyAll
    | AccountCreationNameValid
    | AccountCreationNameInvalid
    | AccountCreationNameAlreadyExist
    | AccountCreation
    | AccountCreationNameCondition
    | AccountCreationInput
    | AccountCreationNamePlaceholder
    | AccountCreationPayment
    | PaymentVirtualAccount
    | PaymentTotalAmount
    | AccountCreationWaitPaymentMsg1
    | AccountCreationWaitPaymentMsg2
    | PaymentComplete
    | AccountCreationCongratulation
    | AccountCreationWelcome
    | AccountCreationYouCanSignIn
    | AccountCreationGoHome
    | Search
    | SearchDescribe
    | SearchAccount
    | SearchResultAccount
    | Account
    | SelfStaked
    | StakedTo
    | StakedBy
    | Resource
    | Transactions
    | TxId
    | Type
    | Time
    | Info
    | All
    | ShowMore
    | SearchPublicKey
    | SearchResultPublicKey
    | DelegatebwSucceeded String
    | DelegatebwFailed String
    | UndelegatebwSucceeded String
    | UndelegatebwFailed String
    | InvalidQuantityInput String
    | OverValidQuantityInput String
    | UnstakePossible
    | BuyramSucceeded String
    | BuyramFailed String
    | SellramSucceeded String
    | SellramFailed String
    | VoteSucceeded String
    | VoteFailed String
    | RamPrice
    | RamYield
    | MyRam
    | Buy
    | Sell
    | BuyableAmount
    | BuyForOtherAccount
    | TypeBuyAmount
    | BuyFeeCharged
    | SellableAmount
    | SellFeeCharged
    | Volume
    | AccountField
    | EnterReceiverAccountName
    | AccountNotExist
    | AccountIsValid
    | AccountIsInvalid
    | ApproximateQuantity String String
    | Max
    | To String
    | DoProxyVote
    | VotePhilosophy
    | VotePhilosophyDesc
    | ProxiedEos
    | ProxiedAccounts
    | VotedBp
    | VoteStatus
    | VoteRate
    | TotalVotedEos
    | TotalEosSupply
    | TypeSellAmount
    | Rank
    | SearchBpCandidate
    | Poll
    | Sent
    | Received
    | Claimrewards
    | Ram
    | Delegatebw
    | Undelegatebw
    | Regproxy
    | Voteproducer
    | NewaccountTx
    | AvailableCapacity
    | TotalCapacity String
    | UsedCapacity String
    | Permissions
    | Permission
    | Threshold
    | Keys
    | Stake
    | Unstake
    | Delegate
    | Undelegate
    | AutoAllocation
    | StakeAvailableAmount
    | SetManually
    | TypeStakeAmount
    | NeverExceedStakeAmount
    | AutoStakeAmountDesc String String Bool
    | ExceedStakeAmount
    | InvalidInputAmount
    | RecommendedStakeAmount String String
    | Cancel
    | TypeUnstakeAmount
    | DelegateAvailableAmount
    | DelegatedList
    | TypeAccountToDelegate
    | TypeDelegateAmount
    | ExceedDelegateAmount
    | NeverExceedDelegateAmount
    | DelegatedAmount String
    | Select
    | TypeAccount
    | SelectAccountToUndelegate
    | StakePossible
    | DelegatePossible
    | UndelegatePossible
    | NotFoundDesc


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
            , chinese = "创建新的账户"
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
            , english = "Welcome to EOS Hub!"
            , chinese = "哈罗！我是eoshub"
            }

        IfYouHaveEos ->
            { korean = "EOS 계정이 있으면 로그인을,"
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

        HowToAttachLink ->
            { korean = "https://medium.com/eosys/%EC%8A%A4%EC%BC%80%ED%84%B0-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%97%B0%EB%8F%99-aaaf6a98b1b7"
            , english = "https://medium.com/eosys/scatter-installation-attachment-4795b7a0202"
            , chinese = "https://medium.com/eosys/scatter-%E5%AE%89%E8%A3%85-%E7%BB%91%E5%AE%9A-171788b91c13"
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
            { korean = "총 보유량"
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

        TransactionOptimal ->
            { korean = "트랜잭션 최상"
            , english = "Tx Optimal"
            , chinese = "交易速度流畅"
            }

        TransactionFine ->
            { korean = "트랜잭션 원활"
            , english = "Tx Fine"
            , chinese = "交易速度上"
            }

        TransactionAttention ->
            { korean = "트랜잭션 주의"
            , english = "Tx Attention"
            , chinese = "交易速度中"
            }

        TransactionWarning ->
            { korean = "트랜잭션 경고"
            , english = "Tx Warning"
            , chinese = "交易速度下"
            }

        ManageStaking ->
            { korean = "CPU / NET 관리"
            , english = "Manage CPU / NET"
            , chinese = "CPU / NET管理"
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
            { korean = "여기서 토큰을 보낼 수 있어요"
            , english = "Send tokens here"
            , chinese = "去传送代币"
            }

        ManageResourceDesc ->
            { korean = "리소스를 관리할 수 있어요"
            , english = "Manage your resource"
            , chinese = "可以管理资源"
            }

        Vote ->
            { korean = "투표하기"
            , english = "Vote"
            , chinese = "投票"
            }

        SimplifiedVote ->
            { korean = "투표"
            , english = "Vote"
            , chinese = "投票"
            }

        VoteDesc ->
            { korean = "EOS로 투표할 수 있어요"
            , english = "Vote with your EOS"
            , chinese = "EOS币持有者可以进行投票"
            }

        RamMarket ->
            { korean = "RAM Market"
            , english = "RAM Market"
            , chinese = "RAM市场"
            }

        RamMarketDesc ->
            { korean = "램을 사고 팔 수 있어요"
            , english = "Buy or Sell RAM here"
            , chinese = "可以买卖RAM"
            }

        GoToTelegramLink ->
            { korean = "https://t.me/EOSYSIOKR"
            , english = "https://t.me/EOSYSIO"
            , chinese = "https://t.me/EOSYSIO"
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
            , english = "Proxy Vote"
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

        TransferAmount ->
            { korean = "전송하실 수량을 입력하세요"
            , english = "Type in the amount to send"
            , chinese = "请输入要传送的数量"
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
            , english = "Email Verification"
            , chinese = "邮件认证"
            }

        AccountCreationEnterEmail ->
            { korean = "이메일을 입력해주세요."
            , english = "Enter your email"
            , chinese = "请输入邮件"
            }

        AccountCreationEnterVerificationCode ->
            { korean = "메일로 전송된 코드를 입력해주세요."
            , english = "Enter the code from your email"
            , chinese = "请输入代码"
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
            , english = "Send"
            , chinese = "发送代码"
            }

        AccountCreationAlreadyHaveAccount ->
            { korean = "이미 EOS 계정이 있나요?"
            , english = "Already have an EOS account?"
            , chinese = "是否已经持有EOS账户？"
            }

        AccountCreationLoginLink ->
            { korean = "로그인"
            , english = "Sign in"
            , chinese = "登入"
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
            , english = "Create a keypair"
            , chinese = "生成密匙对"
            }

        AccountCreationKeypairRegenerate ->
            { korean = "새로 고침"
            , english = "Refresh"
            , chinese = "刷新"
            }

        AccountCreationKeypairCaution ->
            { korean = "* 계정의 소유권을 증명하는 정보이니 꼭 복사하여 안전하게 보관하세요!"
            , english = "* Ensure safe storage of your keypair, as it proves the account ownership."
            , chinese = "* 唯一能够证明账户的所属权的信息，一定要把它复制并保管在安全的地方！"
            }

        AccountCreationKeypairCopiedToClipboard ->
            { korean = "키가 클립보드에 복사되었습니다. 안전한 곳에 붙여넣어 보관하세요!"
            , english = "The key has been copied to the clipboard. Please paste it in a safe place!"
            , chinese = "密钥已复制到剪贴板。 请将它粘贴在安全的地方！"
            }

        PublicKey ->
            { korean = "퍼블릭 키"
            , english = "Public Key"
            , chinese = "公匙"
            }

        PrivateKey ->
            { korean = "프라이빗 키"
            , english = "Private Key"
            , chinese = "私匙"
            }

        CopyAll ->
            { korean = "한번에 복사하기"
            , english = "Copy keypair"
            , chinese = "一键复制"
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

        AccountCreationNameAlreadyExist ->
            { korean = "이미 존재하는 계정입니다."
            , english = "This account already exists."
            , chinese = "此帐户已存在。"
            }

        AccountCreation ->
            { korean = "신규계정 만들기"
            , english = "Make a new account"
            , chinese = "创建新的账户"
            }

        AccountCreationNameCondition ->
            { korean = "영어 소문자와 숫자(1~5)의 조합으로 12글자만 가능합니다."
            , english = "Only 12 characters - lowercase letters and numbers (1~5) - are possible"
            , chinese = "由小写英文字母和数字1～5组成的12位字符"
            }

        AccountCreationInput ->
            { korean = "계정명 입력"
            , english = "Enter account name"
            , chinese = "输入账户名"
            }

        AccountCreationNamePlaceholder ->
            { korean = "ex) eoshuby12345"
            , english = "ex) eoshuby12345"
            , chinese = "ex) eoshuby12345"
            }

        AccountCreationPayment ->
            { korean = "결제정보"
            , english = "Billing Information"
            , chinese = "帐单信息"
            }

        PaymentVirtualAccount ->
            { korean = "가상계좌"
            , english = "Virtual Account"
            , chinese = "虚拟账户"
            }

        PaymentTotalAmount ->
            { korean = "총 결제금액"
            , english = "Total"
            , chinese = "付款总额"
            }

        AccountCreationWaitPaymentMsg1 ->
            { korean = "입금 후 결제완료 버튼을 눌러주세요."
            , english = "Click the payment completion button after deposit."
            , chinese = "付款后请点击付款完成按钮。"
            }

        AccountCreationWaitPaymentMsg2 ->
            { korean = "입금을 하셨는지 다시 한번 확인하고 결제완료를 눌러주세요."
            , english = "Check again that you have made the deposit and click Finish Payment."
            , chinese = "请再次检查您是否已支付押金，然后单击“完成付款”。"
            }

        PaymentComplete ->
            { korean = "결제완료"
            , english = "Payment Complete"
            , chinese = "付款已完成"
            }

        AccountCreationAgreeEosConstitution ->
            { korean = "EOS 헌법에 동의합니다."
            , english = "I agree to the EOS Constitution."
            , chinese = "同意EOS宪法上的内容"
            }

        AccountCreationButton ->
            { korean = "계정 만들기"
            , english = "Create account"
            , chinese = "创建账户"
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
            { korean = "계정 / 퍼블릭 키"
            , english = "Account / Public Key"
            , chinese = "账户名，公匙"
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

        SelfStaked ->
            { korean = "셀프 스테이크"
            , english = "Self Staked"
            , chinese = "Self Staked"
            }

        StakedTo ->
            { korean = "스테이크 해준 양"
            , english = "Self to others"
            , chinese = "Self to others"
            }

        StakedBy ->
            { korean = "스테이크 받은 양"
            , english = "Staked by others"
            , chinese = "Staked by others"
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

        TxId ->
            { korean = "트랜잭션 id"
            , english = "Tx id"
            , chinese = "Tx id"
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

        DelegatebwSucceeded receiver ->
            { korean = receiver ++ "에게 임대 완료!"
            , english = "Delegatebw to " ++ receiver ++ " successful!"
            , chinese = "向" ++ receiver ++ "租借成功！"
            }

        DelegatebwFailed code ->
            { korean = code ++ " 코드오류로 임대 실패"
            , english = "Failed with error code " ++ code
            , chinese = code ++ "编码有误，租借失败"
            }

        UndelegatebwSucceeded receiver ->
            { korean = receiver ++ " 임대취소 완료!"
            , english = "Undelegate to " ++ receiver ++ " successful!"
            , chinese = receiver ++ "取消租借成功！"
            }

        UndelegatebwFailed code ->
            { korean = code ++ " 코드오류로 임대취소 실패"
            , english = "Failed with error code " ++ code
            , chinese = code ++ "编码有误，取消租借失败"
            }

        InvalidQuantityInput resourceType ->
            { korean = resourceType ++ "의 수량입력이 잘못되었습니다"
            , english = "Invalid " ++ resourceType ++ " amount"
            , chinese = resourceType ++ "数量输入有误"
            }

        OverValidQuantityInput resourceType ->
            { korean = "가능한 " ++ resourceType ++ " 수량을 초과하였습니다."
            , english = "The " ++ resourceType ++ " input exceeds the available balance."
            , chinese = "超过了可输入的" ++ resourceType ++ "数量"
            }

        StakePossible ->
            { korean = "스테이크 가능합니다 :)"
            , english = "Ready to stake :)"
            , chinese = "可以进行Stake :）"
            }

        UnstakePossible ->
            { korean = "언스테이크 가능합니다 :)"
            , english = "Ready to unstake :)"
            , chinese = "可以进行Unstake :）"
            }

        DelegatePossible ->
            { korean = "임대 가능합니다 :)"
            , english = "Ready to delegate :)"
            , chinese = "可以进行租出去 :）"
            }

        UndelegatePossible ->
            { korean = "임대취소 가능합니다 :)"
            , english = "Ready to undelegate :)"
            , chinese = "可以进行租回来 :）"
            }

        BuyramSucceeded receiver ->
            { korean = receiver ++ " 에게 구매 완료."
            , english = "Bought RAM to " ++ receiver
            , chinese = "向" ++ receiver ++ "购买成功"
            }

        BuyramFailed code ->
            { korean = code ++ " 코드오류로 램 구매 실패"
            , english = "Failed to buy RAM due to " ++ code
            , chinese = code ++ "编码有误，RAM购买失败"
            }

        SellramSucceeded _ ->
            { korean = "판매 완료!"
            , english = "Successfully sold RAM!"
            , chinese = "销售成功！"
            }

        SellramFailed code ->
            { korean = code ++ " 코드오류로 램 판매 실패"
            , english = "Failed to sell RAM due to " ++ code
            , chinese = code ++ "编码有误，RAM销售失败"
            }

        VoteSucceeded _ ->
            { korean = "투표 성공"
            , english = "Vote Complete"
            , chinese = "投票成功"
            }

        VoteFailed code ->
            { korean = code ++ " 코드오류로 투표 실패"
            , english = "Failed to vote due to " ++ code
            , chinese = code ++ "编码有误，投票失败"
            }

        DoProxyVote ->
            { korean = "대리투표 하기"
            , english = "Vote by Proxy"
            , chinese = "代理投票"
            }

        VotePhilosophy ->
            { korean = "투표 철학"
            , english = "Voting Philosophy"
            , chinese = "投票哲学"
            }

        VotePhilosophyDesc ->
            { korean = "EOS 블록체인은 블록 프로듀서들이 EOS 거버넌스 및 커뮤니티 발전을 위해 기여할 때 비로소 가치를 발현할 수 있습니다. BPGovernance는 EOS New York, EOS Pacific, 그리고 EOSYS가 합작하여 만든 최초의 다중 서명 프록시로 regproducer 합의문 준수, EOS 거버넌스 참여 및 커뮤니티 형성 3가지 기준을 주요 척도로 하여 올바른 BP 선정에 기여합니다."
            , english = "EOS is valuable when Block Producers strive for the development of EOS governance and community overall. BPGovernance, a proxy started by EOS New York, EOS Pacific, and EOSYS, is the first multi-signature proxy to vote for a Block Producer who must demonstrate evident of: Compliance with the regproducer agreement, Contribution to the EOS governance, and Active Involvement in the community."
            , chinese = "EOS区块链是BP对Governance及社区的发展做出贡献时才能体现其价值。BPGovernance是由EOS NEW YORK，EOS Pacific和EOSYS联合发起的多种签名代理（multi-signature proxy）项目。该项目以遵守regproducer协议，参与EOS Governance以及社区建立为主要标准为选择正确的BP进行代理投票。"
            }

        ProxiedEos ->
            { korean = "위임된 EOS"
            , english = "Proxied EOS"
            , chinese = "被委托的EOS"
            }

        ProxiedAccounts ->
            { korean = "위임된 계정"
            , english = "Proxied Accounts"
            , chinese = "被委托的账户"
            }

        VotedBp ->
            { korean = "투표 받은 BP"
            , english = "Voted BP"
            , chinese = "被投票的节点"
            }

        VoteStatus ->
            { korean = "투표 현황"
            , english = "Vote Status"
            , chinese = "投票情况"
            }

        RamPrice ->
            { korean = "RAM 가격"
            , english = "RAM Price"
            , chinese = "RAM价格"
            }

        RamYield ->
            { korean = "RAM 점유율"
            , english = "Overall RAM"
            , chinese = "RAM占有率"
            }

        MyRam ->
            { korean = "나의 RAM"
            , english = "My RAM"
            , chinese = "我的RAM"
            }

        Buy ->
            { korean = "구매"
            , english = "Buy"
            , chinese = "购买"
            }

        Sell ->
            { korean = "판매"
            , english = "Sell"
            , chinese = "销售"
            }

        BuyableAmount ->
            { korean = "구매 가능 수량"
            , english = "Available Balance"
            , chinese = "可购买数量"
            }

        BuyForOtherAccount ->
            { korean = "타계정 구매"
            , english = "Buy for other account"
            , chinese = "给其他账户购买"
            }

        TypeBuyAmount ->
            { korean = "구매할 수량을 입력하세요"
            , english = "Enter amount to buy"
            , chinese = "请输入要购买的数量"
            }

        TypeSellAmount ->
            { korean = "판매할 수량을 입력하세요"
            , english = "Enter amount to sell"
            , chinese = "请输入要销售的数量"
            }

        BuyFeeCharged ->
            { korean = "구매시 0.5%의 수수료가 발생합니다"
            , english = "When buying, 0.5% fee is charged"
            , chinese = "购买时发生0.5%的手续费"
            }

        SellFeeCharged ->
            { korean = "판매시 0.5%의 수수료가 발생합니다"
            , english = "When selling, 0.5% fee is charged"
            , chinese = "销售时发生0.5%的手续费"
            }

        SellableAmount ->
            { korean = "판매 가능 수량"
            , english = "Available RAM Amount"
            , chinese = "可销售数量"
            }

        Volume ->
            { korean = "거래량"
            , english = "Quantity"
            , chinese = "交易量"
            }

        AccountField ->
            { korean = "계정"
            , english = "Account"
            , chinese = "账户"
            }

        EnterReceiverAccountName ->
            { korean = "RAM 구매 받을 계정명을 입력해주세요"
            , english = "Enter account name"
            , chinese = "请输入被购买RAM的账户"
            }

        AccountNotExist ->
            { korean = "존재하지 않는 계정입니다"
            , english = "This account does not exist"
            , chinese = "该账户不存在"
            }

        AccountIsValid ->
            { korean = "올바른 계정입니다"
            , english = "Valid account"
            , chinese = "账户名正确"
            }

        AccountIsInvalid ->
            { korean = "잘못된 입력입니다"
            , english = "Invalid account"
            , chinese = "输入有误"
            }

        ApproximateQuantity quantity unit ->
            { korean = "약 " ++ quantity ++ " " ++ unit
            , english = "approx. " ++ quantity ++ " " ++ unit
            , chinese = "大约" ++ quantity ++ " " ++ unit
            }

        Max ->
            { korean = "최대"
            , english = "Max"
            , chinese = "最多"
            }

        To target ->
            { korean = target ++ " 에게"
            , english = "To " ++ target
            , chinese = "致" ++ target
            }

        VoteRate ->
            { korean = "총 투표율"
            , english = "Total Vote %"
            , chinese = "总投票率"
            }

        TotalVotedEos ->
            { korean = "EOS 총 투표량"
            , english = "Total EOS Votes"
            , chinese = "被投票的EOS"
            }

        TotalEosSupply ->
            { korean = "EOS 총 공급량"
            , english = "Total EOS Supply"
            , chinese = "全部EOS"
            }

        Rank ->
            { korean = "순위"
            , english = "Rank"
            , chinese = "排名"
            }

        SearchBpCandidate ->
            { korean = "BP 후보 검색"
            , english = "Search BP Candidate"
            , chinese = "查询BP候选人"
            }

        Poll ->
            { korean = "득표"
            , english = "Votes"
            , chinese = "得票"
            }

        Sent ->
            { korean = "보냄"
            , english = "Sent"
            , chinese = "Sent"
            }

        Received ->
            { korean = "받음"
            , english = "Received"
            , chinese = "Received"
            }

        Claimrewards ->
            { korean = "보상 청구"
            , english = "Claimrewards"
            , chinese = "Claimrewards"
            }

        Ram ->
            { korean = "램"
            , english = "Ram"
            , chinese = "Ram"
            }

        Delegatebw ->
            { korean = "자원 임대"
            , english = "Delegatebw"
            , chinese = "Delegatebw"
            }

        Undelegatebw ->
            { korean = "자원 임대 취소"
            , english = "Undelegatebw"
            , chinese = "Undelegatebw"
            }

        Regproxy ->
            { korean = "프록시 등록"
            , english = "Regproxy"
            , chinese = "Regproxy"
            }

        Voteproducer ->
            { korean = "블록 생성자 투표"
            , english = "Voteproducer"
            , chinese = "Voteproducer"
            }

        NewaccountTx ->
            { korean = "계정 생성"
            , english = "Newaccount"
            , chinese = "Newaccount"
            }

        AvailableCapacity ->
            { korean = "사용 가능 용량"
            , english = "Available"
            , chinese = "能够使用"
            }

        TotalCapacity capacity ->
            { korean = "총 용량: " ++ capacity
            , english = "Total: " ++ capacity
            , chinese = "总量: " ++ capacity
            }

        UsedCapacity capacity ->
            { korean = "사용된 용량: " ++ capacity
            , english = "Used: " ++ capacity
            , chinese = "已被使用: " ++ capacity
            }

        Permissions ->
            { korean = "보유 권한"
            , english = "Permissions"
            , chinese = "保有权限"
            }

        Permission ->
            { korean = "권한"
            , english = "Permission"
            , chinese = "权限"
            }

        Threshold ->
            { korean = "임계값"
            , english = "Threshold"
            , chinese = "临界值"
            }

        Keys ->
            { korean = "키값"
            , english = "Keys"
            , chinese = "Key值"
            }

        Stake ->
            { korean = "스테이크"
            , english = "Stake"
            , chinese = "Stake"
            }

        Unstake ->
            { korean = "언스테이크"
            , english = "Unstake"
            , chinese = "Unstake"
            }

        Delegate ->
            { korean = "임대하기"
            , english = "Delegate"
            , chinese = "租出去"
            }

        Undelegate ->
            { korean = "임대취소하기"
            , english = "Undelegate"
            , chinese = "租回来"
            }

        AutoAllocation ->
            { korean = "CPU, NET에 각각 4:1의 비율로 자동 분배됩니다"
            , english = "Auto-set in 4:1 to CPU, NET"
            , chinese = "在CPU和NET以4:1的比率进行自动分配"
            }

        StakeAvailableAmount ->
            { korean = "스테이크 가능 수량"
            , english = "Available Balance"
            , chinese = "可stake数量"
            }

        SetManually ->
            { korean = "직접설정"
            , english = "Edit"
            , chinese = "亲自设定"
            }

        TypeStakeAmount ->
            { korean = "스테이크 할 수량을 입력하세요"
            , english = "Enter the amount to stake"
            , chinese = "请输入要stake的数量"
            }

        NeverExceedStakeAmount ->
            { korean = "스테이크 가능 수량만큼 입력 가능합니다"
            , english = "The input cannot exceed the available balance"
            , chinese = "只能输入可stake的数量范围内"
            }

        AutoStakeAmountDesc cpu net isManual ->
            { korean =
                "CPU "
                    ++ cpu
                    ++ " EOS / NET "
                    ++ net
                    ++ " EOS 만큼 스테이크 됩니다 "
                    ++ (if isManual then
                            ""

                        else
                            "(자동설정)"
                       )
            , english =
                "Stake "
                    ++ cpu
                    ++ " EOS to CPU / "
                    ++ net
                    ++ " EOS to NET"
                    ++ (if isManual then
                            ""

                        else
                            " (Auto-set)"
                       )
            , chinese =
                "进行CPU "
                    ++ cpu
                    ++ "EOS / NET "
                    ++ net
                    ++ "EOS stake"
                    ++ (if isManual then
                            ""

                        else
                            " （自动设定）"
                       )
            }

        ExceedStakeAmount ->
            { korean = "스테이크 가능 수량을 초과했습니다"
            , english = "The input exceeds the available balance"
            , chinese = "超过了可输入数量"
            }

        InvalidInputAmount ->
            { korean = "수량 입력이 잘못되었습니다"
            , english = "Invalid input amount"
            , chinese = "输入数量有误"
            }

        RecommendedStakeAmount cpu net ->
            { korean = "CPU와 NET에 각각 최소 " ++ cpu ++ ", " ++ net ++ " 이상 스테이크 해주세요"
            , english = "Please stake over " ++ cpu ++ " and " ++ net ++ " for CPU and NET"
            , chinese = "请各在CPU和NET至少stake" ++ cpu ++ "和" ++ net ++ "以上"
            }

        Cancel ->
            { korean = "취소"
            , english = "Cancel"
            , chinese = "取消"
            }

        TypeUnstakeAmount ->
            { korean = "언스테이크 할 수량을 입력하세요"
            , english = "Enter amount to unstake"
            , chinese = "请输入要unstake的数量"
            }

        DelegateAvailableAmount ->
            { korean = "임대 가능 수량"
            , english = "Available Balance"
            , chinese = "可租数量"
            }

        NeverExceedDelegateAmount ->
            { korean = "임대 가능 수량만큼 입력 가능합니다"
            , english = "The input cannot exceed the available balance"
            , chinese = "输入数量不能超过可租数量"
            }

        DelegatedList ->
            { korean = "임대 받은 계정 리스트"
            , english = "List of delegated accounts"
            , chinese = "被租的账户名单"
            }

        TypeAccountToDelegate ->
            { korean = "임대 받을 계정명을 입력하세요"
            , english = "Enter account name to delegate"
            , chinese = "请输入被租的账户名"
            }

        TypeDelegateAmount ->
            { korean = "임대 할 수량을 입력하세요"
            , english = "Enter amount to delegate"
            , chinese = "请输入要租的数量"
            }

        ExceedDelegateAmount ->
            { korean = "임대 가능 수량을 초과했습니다"
            , english = "The input exceeds the available balance"
            , chinese = "超过了可租数量"
            }

        DelegatedAmount resourceType ->
            { korean = resourceType ++ " 임대 수량"
            , english = resourceType ++ " delegated"
            , chinese = resourceType ++ "的可租数量"
            }

        Select ->
            { korean = "선택"
            , english = "Select"
            , chinese = "选择"
            }

        TypeAccount ->
            { korean = "계정명을 입력하세요"
            , english = "Enter account name"
            , chinese = "请输入账户名"
            }

        SelectAccountToUndelegate ->
            { korean = "임대취소 할 계정명을 선택하세요"
            , english = "Select account name to undelegate"
            , chinese = "输入要撤回租借的账户名"
            }

        NotFoundDesc ->
            { korean = "페이지를 찾을 수 없습니다."
            , english = "Not found"
            , chinese = "未找到"
            }

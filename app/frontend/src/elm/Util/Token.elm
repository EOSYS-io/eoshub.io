-- Token information is copied and modified from
-- https://github.com/eoscafe/eos-airdrops/blob/master/tokens.json


module Util.Token exposing (Token, tokens)


type alias Token =
    { name : String
    , symbol : String
    , contractAccount : String
    }


tokens : List Token
tokens =
    [ { name = "AdderalCoin"
      , symbol = "ADD"
      , contractAccount = "eosadddddddd"
      }
    , { name = "Atidium"
      , symbol = "ATD"
      , contractAccount = "eosatidiumio"
      }
    , { name = "ATMOS"
      , symbol = "ATMOS"
      , contractAccount = "novusphereio"
      }
    , { name = "BEAN"
      , symbol = "BEAN"
      , contractAccount = "thebeantoken"
      }
    , { name = "EOS BET"
      , symbol = "BET"
      , contractAccount = "betdividends"
      }
    , { name = "eosBLACK"
      , symbol = "BLACK"
      , contractAccount = "eosblackteam"
      }
    , { name = "BOID"
      , symbol = "BOID"
      , contractAccount = "boidcomtoken"
      }
    , { name = "Chaince"
      , symbol = "CET"
      , contractAccount = "eosiochaince"
      }
    , { name = "Challenge DAC"
      , symbol = "CHL"
      , contractAccount = "challengedac"
      }
    , { name = "DABBLE"
      , symbol = "DAB"
      , contractAccount = "eoscafekorea"
      }
    , { name = "DEOS Games"
      , symbol = "DEOS"
      , contractAccount = "thedeosgames"
      }
    , { name = "DICE"
      , symbol = "DICE"
      , contractAccount = "betdicetoken"
      }
    , { name = "EDNA"
      , symbol = "EDNA"
      , contractAccount = "ednazztokens"
      }
    , { name = "The EOS Button"
      , symbol = "EBT"
      , contractAccount = "theeosbutton"
      }
    , { name = "EETH"
      , symbol = "EETH"
      , contractAccount = "ethsidechain"
      }
    , { name = "eosCASH"
      , symbol = "ECASH"
      , contractAccount = "horustokenio"
      }
    , { name = "eosDAC"
      , symbol = "EOSDAC"
      , contractAccount = "eosdactokens"
      }
    , { name = "EOX Commerce"
      , symbol = "EOX"
      , contractAccount = "eoxeoxeoxeox"
      }
    , { name = "EOS Sports Bets"
      , symbol = "ESB"
      , contractAccount = "esbcointoken"
      }
    , { name = "EOS"
      , symbol = "EOS"
      , contractAccount = "eosio.token"
      }
    , { name = "EVR "
      , symbol = "EVR"
      , contractAccount = "eosvrtokenss"
      }
    , { name = "GrandpaETH"
      , symbol = "ETH"
      , contractAccount = "grandpacoins"
      }
    , { name = "Horus Pay"
      , symbol = "HORUS"
      , contractAccount = "horustokenio"
      }
    , { name = "Infinicoin"
      , symbol = "INF"
      , contractAccount = "infinicoinio"
      }
    , { name = "IPOS"
      , symbol = "IPOS"
      , contractAccount = "oo1122334455"
      }
    , { name = "Everipedia"
      , symbol = "IQ"
      , contractAccount = "everipediaiq"
      }
    , { name = "GrandpaBTC"
      , symbol = "BTC"
      , contractAccount = "grandpacoins"
      }
    , { name = "GrandpaDOGE"
      , symbol = "DOGE"
      , contractAccount = "grandpacoins"
      }
    , { name = "iRespo"
      , symbol = "IRESPO"
      , contractAccount = "irespotokens"
      }
    , { name = "KARMA"
      , symbol = "KARMA"
      , contractAccount = "therealkarma"
      }
    , { name = "MEET.ONE"
      , symbol = "MEETONE"
      , contractAccount = "eosiomeetone"
      }
    , { name = "Lelego"
      , symbol = "LLG"
      , contractAccount = "llgonebtotal"
      }
    , { name = "Oracle Chain"
      , symbol = "OCT"
      , contractAccount = "octtothemoon"
      }
    , { name = "Poorman "
      , symbol = "POOR"
      , contractAccount = "poormantoken"
      }
    , { name = "PUBLYTO"
      , symbol = "PUB"
      , contractAccount = "publytoken11"
      }
    , { name = "RIDL"
      , symbol = "RIDL"
      , contractAccount = "ridlridlcoin"
      }
    , { name = "TRYBE"
      , symbol = "TRYBE"
      , contractAccount = "trybenetwork"
      }
    , { name = "WiZZ"
      , symbol = "WIZZ"
      , contractAccount = "wizznetwork1"
      }
    , { name = "WECASH"
      , symbol = "WECASH"
      , contractAccount = "weosservices"
      }
    , { name = "ZKS"
      , symbol = "ZKS"
      , contractAccount = "zkstokensr4u"
      }
    , { name = "Crypto Peso"
      , symbol = "PSO"
      , contractAccount = "cryptopesosc"
      }
    , { name = "CADEOS.io"
      , symbol = "ADE"
      , contractAccount = "buildertoken"
      }
    ]

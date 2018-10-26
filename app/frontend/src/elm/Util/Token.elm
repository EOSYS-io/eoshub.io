-- Token information is copied and modified from
-- https://github.com/eoscafe/eos-airdrops/blob/master/tokens.json


module Util.Token exposing (Token, tokens)


type alias Token =
    { name : String
    , symbol : String
    , contractAccount : String
    , precision : Int
    }


tokens : List Token
tokens =
    [ { name = "AdderalCoin"
      , symbol = "ADD"
      , contractAccount = "eosadddddddd"
      , precision = 4
      }
    , { name = "Atidium"
      , symbol = "ATD"
      , contractAccount = "eosatidiumio"
      , precision = 4
      }
    , { name = "ATMOS"
      , symbol = "ATMOS"
      , contractAccount = "novusphereio"
      , precision = 3
      }
    , { name = "BEAN"
      , symbol = "BEAN"
      , contractAccount = "thebeantoken"
      , precision = 4
      }
    , { name = "EOS BET"
      , symbol = "BET"
      , contractAccount = "betdividends"
      , precision = 4
      }
    , { name = "eosBLACK"
      , symbol = "BLACK"
      , contractAccount = "eosblackteam"
      , precision = 4
      }
    , { name = "BOID"
      , symbol = "BOID"
      , contractAccount = "boidcomtoken"
      , precision = 4
      }
    , { name = "Chaince"
      , symbol = "CET"
      , contractAccount = "eosiochaince"
      , precision = 4
      }
    , { name = "Challenge DAC"
      , symbol = "CHL"
      , contractAccount = "challengedac"
      , precision = 4
      }
    , { name = "DABBLE"
      , symbol = "DAB"
      , contractAccount = "eoscafekorea"
      , precision = 4
      }
    , { name = "DEOS Games"
      , symbol = "DEOS"
      , contractAccount = "thedeosgames"
      , precision = 4
      }
    , { name = "DICE"
      , symbol = "DICE"
      , contractAccount = "betdicetoken"
      , precision = 4
      }
    , { name = "EDNA"
      , symbol = "EDNA"
      , contractAccount = "ednazztokens"
      , precision = 4
      }
    , { name = "The EOS Button"
      , symbol = "EBT"
      , contractAccount = "theeosbutton"
      , precision = 4
      }
    , { name = "EETH"
      , symbol = "EETH"
      , contractAccount = "ethsidechain"
      , precision = 4
      }
    , { name = "eosCASH"
      , symbol = "ECASH"
      , contractAccount = "horustokenio"
      , precision = 4
      }
    , { name = "eosDAC"
      , symbol = "EOSDAC"
      , contractAccount = "eosdactokens"
      , precision = 4
      }
    , { name = "EOX Commerce"
      , symbol = "EOX"
      , contractAccount = "eoxeoxeoxeox"
      , precision = 4
      }
    , { name = "EOS Sports Bets"
      , symbol = "ESB"
      , contractAccount = "esbcointoken"
      , precision = 4
      }
    , { name = "EOS"
      , symbol = "EOS"
      , contractAccount = "eosio.token"
      , precision = 4
      }
    , { name = "EVR "
      , symbol = "EVR"
      , contractAccount = "eosvrtokenss"
      , precision = 4
      }
    , { name = "GrandpaETH"
      , symbol = "ETH"
      , contractAccount = "grandpacoins"
      , precision = 4
      }
    , { name = "Horus Pay"
      , symbol = "HORUS"
      , contractAccount = "horustokenio"
      , precision = 4
      }
    , { name = "Infinicoin"
      , symbol = "INF"
      , contractAccount = "infinicoinio"
      , precision = 4
      }
    , { name = "IPOS"
      , symbol = "IPOS"
      , contractAccount = "oo1122334455"
      , precision = 4
      }
    , { name = "Everipedia"
      , symbol = "IQ"
      , contractAccount = "everipediaiq"
      , precision = 3
      }
    , { name = "GrandpaBTC"
      , symbol = "BTC"
      , contractAccount = "grandpacoins"
      , precision = 4
      }
    , { name = "GrandpaDOGE"
      , symbol = "DOGE"
      , contractAccount = "grandpacoins"
      , precision = 4
      }
    , { name = "iRespo"
      , symbol = "IRESPO"
      , contractAccount = "irespotokens"
      , precision = 6
      }
    , { name = "KARMA"
      , symbol = "KARMA"
      , contractAccount = "therealkarma"
      , precision = 4
      }
    , { name = "MEET.ONE"
      , symbol = "MEETONE"
      , contractAccount = "eosiomeetone"
      , precision = 4
      }
    , { name = "Lelego"
      , symbol = "LLG"
      , contractAccount = "llgonebtotal"
      , precision = 4
      }
    , { name = "Oracle Chain"
      , symbol = "OCT"
      , contractAccount = "octtothemoon"
      , precision = 4
      }
    , { name = "Poorman "
      , symbol = "POOR"
      , contractAccount = "poormantoken"
      , precision = 4
      }
    , { name = "PUBLYTO"
      , symbol = "PUB"
      , contractAccount = "publytoken11"
      , precision = 4
      }
    , { name = "RIDL"
      , symbol = "RIDL"
      , contractAccount = "ridlridlcoin"
      , precision = 4
      }
    , { name = "TRYBE"
      , symbol = "TRYBE"
      , contractAccount = "trybenetwork"
      , precision = 4
      }
    , { name = "WiZZ"
      , symbol = "WIZZ"
      , contractAccount = "wizznetwork1"
      , precision = 4
      }
    , { name = "WECASH"
      , symbol = "WECASH"
      , contractAccount = "weosservices"
      , precision = 4
      }
    , { name = "Crypto Peso"
      , symbol = "PSO"
      , contractAccount = "cryptopesosc"
      , precision = 4
      }
    , { name = "CADEOS.io"
      , symbol = "ADE"
      , contractAccount = "buildertoken"
      , precision = 4
      }
    ]

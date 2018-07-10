# README

## Build status
Alpha: [![Build Status](https://travis-ci.org/EOSYS-io/eoshub.io.svg?branch=alpha)](https://travis-ci.org/EOSYS-io/eoshub.io)

## Dependencies
- Ruby 2.5.1
- Rails 5.2.0
- Elm 0.18.0

## Preinstall
- Ruby - https://gorails.com/setup/osx/10.13-high-sierra#ruby
- Postgresql
  ```
  brew install postgresql

  # To have launchd start postgresql at login:
  brew services start postgresql
  ```

## Setup
```
git clone git@github.com:EOSYS-io/eoshub.io.git
cd eoshub.io
gem install bundler
bundle install

cp ${MASTER_KEY_PATH}/master.key config

touch .env
echo "DATABASE_URL=postgresql://${OSX_USERNAME}:@localhost/eoshub_dev" >> .env
echo "TEST_DATABASE_URL=postgresql://${OSX_USERNAME}:@localhost/eoshub_test" >> .env

# Install yarn and elm dependencies.
yarn install
yarn run elm package install -y

rails db:create
```

## Run
```
rails s(erver)
```
```
bin/webpack-dev-server # for development
```

## Test
- Elm
  ```
  yarn run elm-test # Run this command on the project root directory.
  ```
  - Make sure that elm-package.json in test/frontend should contain all dependencies of
  elm-packge.json in the root directory.

- Rails
  ```
  docker pull eosys/eos-wallet-node-alpha
  # EOS_ACCOUNT and EOS_PRIVATE_KEY for mainnet
  docker run -d -p 5000:80 --name eos-wallet-node -e "EOS_PRIVATE_KEY=$EOS_PRIVATE_KEY" -e "EOS_ACCOUNT=$EOS_ACCOUNT" eosys/eos-wallet-node-alpha
  rails t(est)
  ```

## Frontend Source Location
```
app/frontend
```

## CI
- Travis https://travis-ci.org/
- DockerHub https://hub.docker.com/r/eosys/eoshub.io/

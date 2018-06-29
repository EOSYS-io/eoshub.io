# README

## Dependencies
- Ruby 2.5.1
- Rails 5.2.0
- Elm 0.18.0

## Preinstall
- Installing Ruby - https://gorails.com/setup/osx/10.13-high-sierra#ruby
- Postgresql - https://gorails.com/setup/osx/10.13-high-sierra#postgresql

## Setup
```
git clone git@github.com:chain-partners/eoshub.io.git
cd eoshub.io
gem install bundler
bundle install
touch .env
echo "DATABASE_URL=postgresql://${OSX_USERNAME}:@localhost/eoshub_dev" > .env
rails db:create
cp ${MASTER_KEY_PATH}/master.key config
```

## Run
```
rails s(erver)
bin/webpack-dev-server # for development
```

## Elm Source Location
app/javascript

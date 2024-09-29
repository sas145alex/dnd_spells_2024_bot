# Dependencies
* Ruby (version specified in `.ruby-version`)
* Postgres 16

# Setup
1. Run `make setup`
2. Fill `.env` with proper data

# Development & Test
1. Run `make web` to setup local dev server on 3000 port
2. Run `make bot` to active message poller for your dev-bot
3. Run `make test` to run test suite

# Deployment
You can use any deployment platform (Heroku for instance), but remember
that in production it is better use bot in webhook-mode, not in poller-mode.
To do so run `bundle exec rails telegram:bot:set_webhook RAILS_ENV=production` 
on initial deploy and re-run it each time your domain or bot-token changes

More about it [github/telegram-bot-rb](https://github.com/telegram-bot-rb/telegram-bot/wiki/Deployment#setup-for-rails-app)

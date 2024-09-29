setup:
	bundle
	cp --update=none .env.test .env
	bundle exec rails db:create db:migrate db:seed

web:
	bundle exec rails s

bot:
	bundle exec rails telegram:bot:poller

test:
	bundle exec rspec

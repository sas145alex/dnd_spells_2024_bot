setup:
	bundle
	cp --update=none .env.test .env
	bundle exec rails db:create db:migrate db:seed

web:
	bin/dev

bot:
	bin/rails telegram:bot:poller

jobs:
	bin/jobs

test:
	bundle exec rspec

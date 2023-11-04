# README

## Versions

| Name | Version |
| --- | --- |
| Ruby | 3.2.2 |
|Rails | 7.0.7.2 |

## Start development
```
# after clone this repo
$ cd kakeibo_on_rails
$ docker compose up
# another tab
$ ngrok http 3000
=> input LineMessagingAPI webhook url 'https://***/callback'

# db setup
$ docker compose exec web bin/rails db:create
$ docker compose exec web bin/rails db:migrate
```

  

---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

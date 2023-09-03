FROM ruby:3.2
WORKDIR /app

# install packages
RUN apt-get update -qq && apt-get install -y sqlite3 libsqlite3-dev

# add Gemfile and invoke 'bundle install'
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# copy other files
COPY . /app
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]

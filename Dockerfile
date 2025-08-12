FROM ruby:2.5.8
WORKDIR /app
CMD gem build ey-core.gemspec && gem install ey-core-*.gem && ey-core help && bash

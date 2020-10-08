FROM  ruby:2.6
WORKDIR /root
COPY . /root
RUN gem install bundler -v "2.1.4"
RUN bundle install
CMD ["exe/swimmy"]
FROM ruby:2.5
WORKDIR /webapp
COPY server.rb /webapp/server.rb
EXPOSE 80
CMD ["ruby", "server.rb"]
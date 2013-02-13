http = require('http')
express = require('express')

mongoose = require 'mongoose'
Message = require "./models/message.coffee"
User = require "./models/user.coffee"

mongoose.connect "mongodb://localhost/geochat"

# configure foursquare for api
foursquare_config = {
  'secrets' : {
    'clientId' : 'clientId',
    'clientSecret' : 'clientSecret',
    'redirectUrl' : 'http://geochat.com'
  }
  foursquare: {
    version: '20120101'
  }
}
foursquare = require('node-foursquare')(foursquare_config)


app = express()
server = http.createServer(app)

io = require('socket.io').listen(server)

io.set("log level", 2)

require("./sockets.coffee")(io)

require('./routes/api.coffee')(app, foursquare)

# start listening
port = process.env.PORT || 5000
server.listen port, ->
  console.log "Listening to port #{port}"

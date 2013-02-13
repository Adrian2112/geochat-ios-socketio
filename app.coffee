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

io.sockets.on 'connection', (socket) ->
  console.log("Hey Scottie!")
  joinedRoom = null
  user = null
  access_token = null

  socket.on 'join room', (data) ->
    console.log data
    socket.join data.room
    joinedRoom = data.room
    access_token = data.access_token

    Message.find {place_id: joinedRoom}, [], { sort: [['created_at', -1]], limit: 10 }, (err, messages) ->
      if messages
        messages = messages.reverse()
        
        socket.emit("init messages", {messages: messages})

    User.find {access_token: access_token}, [], {}, (err,obj) ->
      user = obj[0]
      console.log "user: #{JSON.stringify user}"
      socket.broadcast.to(joinedRoom).emit("new user", user)
     
  socket.on 'new message', (message) ->
    if  joinedRoom
      # protected variables
      message.place_id = joinedRoom
      message.user_id = user._id
      message.photo = user.photo
      message.user = user.name

      # create message object and save to the DB
      new_message = (new Message(message))
      new_message.save()

      # get te message in pure json
      json_message = new_message.toObject()
      
      socket.broadcast.to(joinedRoom).emit("new message", { messages: [json_message] })


require('./routes/api.coffee')(app, foursquare)

# start listening
port = process.env.PORT || 5000
server.listen port, ->
  console.log "Listening to port #{port}"

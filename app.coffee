app = require('http').createServer()
io = require('socket.io').listen(app)

mongoose = require 'mongoose'
Message = require "./models/message.coffee"

mongoose.connect "mongodb://localhost/geochat"

port = process.env.PORT || 5000

app.listen(port)
console.log "Listening to port #{port}"

io.set("log level", 2)

io.sockets.on 'connection', (socket) ->
  console.log("Hey Scottie!")
  joinedRoom = null
  user = null

  socket.on 'join room', (data) ->
    console.log data
    socket.join data.room
    joinedRoom = data.room
    user = data.user
    socket.broadcast.to(joinedRoom).emit("new user", data.user)
     
  socket.on 'new message', (message) ->
    console.log message
    console.log joinedRoom
    if  joinedRoom
      # protected variables
      message.place_id = joinedRoom
      message.user = user

      # create message object and save to the DB
      new_message = (new Message(message))
      new_message.save()

      # get te message in pure json
      json_message = new_message.toObject()
      
      # set message information for broadcast
      json_message.user = user
      
      socket.broadcast.to(joinedRoom).emit("new message", { messages: [json_message] })

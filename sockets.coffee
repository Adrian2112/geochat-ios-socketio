mongoose = require 'mongoose'
Message = require "./models/message.coffee"
User = require "./models/user.coffee"
Venue = require "./models/venue.coffee"

module.exports = (io) ->

  io.sockets.on 'connection', (socket) ->
    console.log("Hey Scottie!")
    joinedRoom = null
    user = null
    access_token = null

    socket.on 'join room', (data) ->
      console.log data
      socket.join data.room
      joinedRoom = data.room

      Venue.set_users_in joinedRoom, io.sockets.clients(joinedRoom).length, (err, result) ->
        console.log err, result
        socket.broadcast.to(joinedRoom).emit("users count", {count: result.users_in})
        socket.emit("users count", {count: result.users_in})
        console.log "users coutn #{result.users_in}"

      access_token = data.access_token

      Message.find {place_id: joinedRoom}, {}, { sort: [['created_at', -1]], limit: 10 }, (err, messages) ->
        if messages
          messages = messages.reverse()
          
          socket.emit("init messages", {messages: messages})

      User.find {access_token: access_token}, {}, {}, (err,obj) ->
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

    socket.on 'disconnect', ->
      console.log "disconnected #{joinedRoom}"
      Venue.set_users_in joinedRoom, io.sockets.clients(joinedRoom).length - 1, (err, result) ->
        console.log err, result
        socket.broadcast.to(joinedRoom).emit("users count", {count: result.users_in})
        socket.emit("users count", {count: result.users_in})
        console.log "users count #{result.users_in}"

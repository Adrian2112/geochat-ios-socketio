User = require "../models/user.coffee"
_ = require("underscore")

module.exports = (app, foursquare) ->

  app.get '/register/:access_token', (req, res) ->

    console.log "registering user with access_token #{req.params.acces_token}"

    foursquare.Users.getUser 'self', req.params.access_token, (err, response) ->

      if err != null or response == null
        res.json("error")

      else
        user = response.user
        user_info = {
          name: "#{user.firstName} #{user.lastName}"
          gender: user.gender
          photo: "#{user.photo.prefix}100x100#{user.photo.suffix}"
          foursquare_id: user.id
          access_token: req.params.access_token
        }


        User.findOne {foursquare_id: response.user.id}, (err,obj) ->

          if obj == null
            user = new User(user_info)
            user.save()
            res.json(user)

          else
            _.extend(obj, user_info)
            obj.save ->
              res.json(obj)



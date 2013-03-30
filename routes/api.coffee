User = require "../models/user.coffee"
Venue = require "../models/venue.coffee"
_ = require("underscore")

module.exports = (app, foursquare) ->

  app.get '/register/:access_token', (req, res) ->

    console.log "registering user with access_token #{req.params.access_token}"

    foursquare.Users.getUser 'self', req.params.access_token, (err, response) ->

      if err != null or response == null
        res.json("error")

      else
        user = response.user
        user_info = {
          name: "#{user.firstName} #{user.lastName}"
          gender: user.gender
          photo: user.photo
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


  app.get '/:access_token/venues/search/:latlng', (req, res) ->
    latlng = req.params.latlng.split(",")
    lat = latlng[0]
    lng = latlng[1]

    foursquare.Venues.search lat, lng, null, {}, req.params.access_token, (error, results) ->

      ids = _.map results.venues, (e, i) -> e.id

      Venue.find { foursquare_id: { $in: ids } }, (err, venues_results) ->

        users_in_venue = {}

        _.each venues_results, (e, i) ->
          users_in_venue[e.foursquare_id] = e.users_in

        json = _.map results.venues, (venue, i) ->
          categories = venue.categories
          icon = if categories.length > 0 then categories[0].icon else  ''
          {
            id: venue.id
            name: venue.name
            distance: venue.location.distance
            image: "#{icon.prefix}44#{icon.name}"
            users_in: users_in_venue[venue.id] || 0
          }

        res.json(json)


mongoose = require('mongoose')

Schema = mongoose.Schema

venueSchema = new Schema({
  foursquare_id: String
  users_in: {type: Number, default: 0}
})

venueSchema.statics.set_users_in = (venue_id, users_in, callback) ->
  this.findOneAndUpdate({foursquare_id: venue_id}, {  users_in: users_in }, {new: true, upsert: true, select: 'users_in'}, callback)


module.exports = mongoose.model('Venue',venueSchema)


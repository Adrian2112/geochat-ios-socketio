mongoose = require('mongoose')

Schema = mongoose.Schema

userSchema = new Schema({
  created_at: {type: Date, default: Date.now}
  name: String
  gender: String
  photo: String
  foursquare_id: Number
  access_token: String
})

module.exports = mongoose.model('User',userSchema)

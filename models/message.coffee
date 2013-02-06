mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

protect = (v) -> null

messageSchema = new Schema({
    created_at: {type: Date, default: Date.now, set: protect}
    user: String
    message: String
    place_id: String
})



module.exports = mongoose.model('Message', messageSchema)

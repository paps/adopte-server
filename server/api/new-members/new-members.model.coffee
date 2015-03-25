'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

newMembersSchema = new Schema {
    date: Date
    id: Number
}

module.exports = mongoose.model 'NewMembers', newMembersSchema

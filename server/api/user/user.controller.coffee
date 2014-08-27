"use strict"

User = require("./user.model")
passport = require("passport")
config = require("../../config/config")
jwt = require("jsonwebtoken")

validationError = (res, err) ->
    res.json 422, err


###
Get list of users
restriction: 'admin'
###
exports.index = (req, res) ->
    User.find {}, "-salt -hashedPassword", (err, users) ->
        return res.send(500, err) if err
        res.json 200, users


###
Creates a new user
###
exports.create = (req, res, next) ->
    newUser = new User(req.body)
    newUser.provider = "local"
    newUser.role = "user"
    newUser.save (err, user) ->
        return validationError(res, err) if err
        token = jwt.sign(
            _id: user._id
        , config.secrets.session,
            expiresInMinutes: 60 * 5
        )
        res.json token: token


###
Get a single user
###
exports.show = (req, res, next) ->
    userId = req.params.id
    User.findById userId, (err, user) ->
        return next(err) if err
        return res.send(404) unless user
        res.json user.profile


###
Deletes a user
restriction: 'admin'
###
exports.destroy = (req, res) ->
    User.findByIdAndRemove req.params.id, (err, user) ->
        return res.send(500, err) if err
        res.send 204


###
Change a users password
###
exports.changePassword = (req, res, next) ->
    userId = req.user._id
    oldPass = String(req.body.oldPassword)
    newPass = String(req.body.newPassword)
    User.findById userId, (err, user) ->
        if user.authenticate(oldPass)
            user.password = newPass
            user.save (err) ->
                return validationError(res, err) if err
                return res.send 200
        else
            return res.send 403


###
Get my info
###
exports.me = (req, res, next) ->
    userId = req.user._id
    User.findOne
        _id: userId
    , "-salt -hashedPassword", (err, user) -> # don't ever give out the password or salt
        return next(err) if err
        return res.json(404) unless user
        res.json user


###
Authentication callback
###
exports.authCallback = (req, res, next) ->
    res.redirect "/"

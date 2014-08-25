"use strict"
mongoose = require("mongoose")
passport = require("passport")
config = require("../config/environment")
jwt = require("jsonwebtoken")
expressJwt = require("express-jwt")
compose = require("composable-middleware")
User = require("../api/user/user.model")
validateJwt = expressJwt(secret: config.secrets.session)

###
Attaches the user object to the request if authenticated
Otherwise returns 403
###
isAuthenticated = ->

    # Validate jwt
    # allow access_token to be passed through query parameter as well
    # Attach user to request
    compose().use((req, res, next) ->
        req.headers.authorization = "Bearer " + req.query.access_token    if req.query and req.query.hasOwnProperty("access_token")
        validateJwt req, res, next
        return
    ).use (req, res, next) ->
        User.findById req.user._id, (err, user) ->
            return next(err)    if err
            return res.send(401)    unless user
            req.user = user
            next()
            return

        return


###
Checks if the user role meets the minimum requirements of the route
###
hasRole = (roleRequired) ->
    throw new Error("Required role needs to be set")    unless roleRequired
    compose().use(isAuthenticated()).use meetsRequirements = (req, res, next) ->
        if config.userRoles.indexOf(req.user.role) >= config.userRoles.indexOf(roleRequired)
            next()
        else
            res.send 403
        return


###
Returns a jwt token signed by the app secret
###
signToken = (id) ->
    jwt.sign
        _id: id
    , config.secrets.session,
        expiresInMinutes: 60 * 5


###
Set token cookie directly for oAuth strategies
###
setTokenCookie = (req, res) ->
    unless req.user
        return res.json(404,
            message: "Something went wrong, please try again."
        )
    token = signToken(req.user._id, req.user.role)
    res.cookie "token", JSON.stringify(token)
    res.redirect "/"
    return

exports.isAuthenticated = isAuthenticated
exports.hasRole = hasRole
exports.signToken = signToken
exports.setTokenCookie = setTokenCookie

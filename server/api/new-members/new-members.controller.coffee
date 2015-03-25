'use strict'

NewMembers = require './new-members.model'

handleError = (res, err) ->
    res.send 500, err

exports.add = (req, res) ->
    id = parseInt req.params.id, 10
    if (id is null) or (not isFinite(id)) then return handleError res, 'Invalid id parameter'
    newMember =
        date: Date.now()
        id: id
    NewMembers.create newMember, (err, newMember) ->
        return handleError(res, err) if err
        res.json 201, newMember
        console.log "* Nouveau ID max: " + id

exports.getBiggest = (req, res) ->
    NewMembers.findOne
        $query: {}
        $orderby:
            id: -1,
        (err, newMember) ->
            return handleError(res, err) if err
            res.json 200, newMember

'use strict'

Stats = require './new-members.model'

handleError = (res, err) ->
    res.send 500, err

parseDate = (d) ->
    year = parseInt d.substr 0, 4
    month = parseInt d.substr 5, 2
    day = parseInt d.substr 8, 2
    return new Date year, month - 1, day, 12

exports.add = (req, res) ->
    id = parseInt req.params.id, 10
    if (id is null) or (not isFinite(id)) then return handleError res, 'Invalid id parameter'
    newMember =
        date: date
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

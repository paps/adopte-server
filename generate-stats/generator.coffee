async = require 'async'
needle = require 'needle'

json =
    contacts: require './contacts.json'
    visits: require './visits.json'

config = require '../server/config/config'

subscribeDate = config.adopte.subscribeDate
serverUrl = config.adopte.serverUrl

dryRun = yes

oneDay = 24 * 60 * 60 * 1000

parseDate = (d) ->
    year = parseInt d.substr 0, 4
    month = parseInt d.substr 5, 2
    day = parseInt d.substr 8, 2
    return new Date year, month - 1, day, 12

curDate = parseDate subscribeDate
csv = []

while curDate.getTime() < Date.now()
    nbContacts = 0
    for c in json.contacts.results
        d = parseDate c.date
        if d.getTime() <= curDate.getTime()
            ++nbContacts
    nbVisits = 0
    for v in json.visits.results
        d = parseDate v.date
        if d.getTime() <= curDate.getTime()
            ++nbVisits
    console.log curDate.toDateString() + ": " + nbContacts + " contacts, " + nbVisits + " visits"
    csv.push
        date: new Date curDate.getTime()
        contacts: nbContacts
        visits: nbVisits
    curDate = new Date curDate.getTime() + oneDay

if not dryRun
    iterator = (entry, done) ->
        dateStr = entry.date.getFullYear() + '-' + (entry.date.getMonth() + 1) + '-' + entry.date.getDate()
        needle.get serverUrl + 'api/stats/add/' + entry.contacts + '/' + entry.visits + '/' + dateStr + '?key=' + config.adopte.key, (err) ->
            if err
                console.log dateStr + ' FAILED! ' + err.toString()
            else
                console.log dateStr + ' OK'
            done()
    async.eachSeries csv, iterator, () ->
        console.log 'Done!'

###
// ==UserScript==
// @name        aum
// @namespace   http://www.adopteunmec.com
// @include     http://www.adopteunmec.com/*
// @version     1
// @grant       none
// ==/UserScript==
###


round = (n, decimals) -> (Math.round n * Math.pow(10, decimals)) / (Math.pow 10, decimals)


betterTitle = () ->
    titleEl = document.getElementsByTagName('title')[0]
    setTitle = () ->
        nbMails = parseInt ($ '#mails a').text()
        nbPaniers = parseInt ($ '#basket a').text()
        nbVisites = parseInt ($ '#visites a').text()
        nbChats = parseInt ($ '#chat a').text()
        titleEl.innerHTML = 'AuM (' + nbMails + ', ' + nbPaniers + ', ' + nbVisites + ', ' + nbChats + ')'
    docEl = document.documentElement
    docEl.addEventListener 'DOMSubtreeModified', (evt) ->
        t = evt.target
        if (t == titleEl || (t.parentNode && t.parentNode == titleEl))
            setTitle()
    setTitle()


pageProfileMec = () ->

    ($ 'blockquote.title').css('font-family', 'Arial').css('font-size', '14px')


pageProfileMeuf = () ->

    ($ 'blockquote.title').css('font-family', 'Arial').css('font-size', '14px')

    removeX = (elem) -> elem.text elem.text().replace(' x', '')

    ($ '#popularity > h2').text 'Popularité++'
    ($ 'td.equals').remove()
    ($ 'td.count').remove()
    ($ 'tr.total > th').text 'Score'
    ($ '#popularity table tr td:contains(" x ") strong').remove()

    points =
        mails: parseInt (removeX $ '#popularity table tr td:eq(0)').text()
        charmes: parseInt (removeX $ '#popularity table tr td:eq(1)').text()
        visites: parseInt (removeX $ '#popularity table tr td:eq(2)').text()
        paniers: parseInt (removeX $ '#popularity table tr td:eq(3)').text()

    charmeRate = ($ '<tr>')
    charmeRate.append ($ '<th>').text 'C / V'
    charmeRate.append ($ '<td>').text (round (points.charmes / points.visites) * 100, 2) + ' %'
    ($ '#popularity > table').append charmeRate

    mailRate = ($ '<tr>')
    mailRate.append ($ '<th>').text 'M / C'
    mailRate.append ($ '<td>').text (round (points.mails / points.charmes) * 100, 2) + ' %'
    ($ '#popularity > table').append mailRate

    ($ 'a.charm').click () ->
        alert 'Charme !'


($ document).ready () ->

    if ($ '#flash-points').length
        ($ '#flash-points').remove()
    if ($ '#search-engine .fields').length
        ($ '#search-engine .fields').hide()
    if ($ '#profile-complete-rate').length
        ($ '#profile-complete-rate').hide()
    betterTitle()

    if ($ '#view_description_girl').length
        pageProfileMeuf()
    else if ($ '#view_description_boy').length
        pageProfileMec()

    ($ 'body').css('background', 'rgb(223, 239, 254)')

Prompt = require 'prompt'
Promise = require 'promise'
Request = require 'request'

cred =
  url:'https://proxy22.iitd.ernet.in/cgi-bin/proxy.cgi'
  loggedin: false
  requestTimeout: 3000
  retryTimeout: 2000
  refreshTimeout: 120000

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

getSessionID = -> new Promise retry = (next) ->
  console.log "Obtaining Session ID"
  Request {url:cred.url,timeout:cred.requestTimeout}, (error, response, body) ->
    if error
      console.log error,"\nRetrying in 2s..."
      setTimeout (-> retry next), cred.retryTimeout
    else
      cred.sessionid=(/"sessionid".+?value="([^"]+?)">/i.exec body)[1]
      console.log "Session ID:"+cred.sessionid
      next()
    return
  return

login = ->new Promise retry= (next,fail) ->
  console.log "Logging in..."
  Request {url: cred.url, timeout: cred.requestTimeout, form: {sessionid: cred.sessionid, action: 'Validate', userid: cred.user, pass: cred.password}}, (err,resp,body) ->
      cred.loggedin=false
      if err
        console.log err,"\nretrying in 2s..."
        setTimeout (-> login next, fail), cred.retryTimeout
      else if body.match /you are logged in successfully/i
        console.log "Login successful. Press any key to logout"
        cred.loggedin=true
        next()
      else if body.match /Either your userid and/i
        console.log "Invalid credentials! Aborting"
        fail()
      else if logged_user=(/([\w]+?) already logged in/i.exec body)
        logged_user=logged_user[1]
        console.log "Already logged in as #{logged_user}. retrying in 2s..."
        setTimeout (-> logout().then -> retry next, fail), cred.retryTimeout
      else if body.match /Session expired/i
        console.log "Session expired."
        getSessionID().then ->login().then(next).catch(fail)
      else
        console.log "Unknown response. Retrying in 2s..."
        setTimeout (-> login next, fail), cred.retryTimeout
      return
  return

refresh = ->
  unless cred.loggedin
    return
  console.log "Refreshing..."
  Request {url:cred.url,timeout:cred.requestTimeout, form: {sessionid: cred.sessionid, action: 'Refresh'}}, (err,resp,body) ->
    cred.loggedin=false
    if err
      console.log err,"\nRetrying in 2s..."
      setTimeout (->login next, fail), cred.retryTimeout
    else if body.match /you are logged in successfully/i
      console.log "Success. Press any key to logout"
      cred.loggedin=true
      setTimeout refresh, cred.refreshTimeout
    else if body.match /Session expired/i
      console.log "Session expired."
      getSessionID().then ->login().then(refresh)
    return
  return

logout = -> new Promise retry =(next)->
  console.log "Logging out.."
  Request {url:cred.url,timeout:cred.requestTimeout, form: {sessionid: cred.sessionid, action: 'logout'}}, (err,resp,body) ->
    cred.loggedin=false
    if err
      console.log err,"\nRetrying in 2s..."
      setTimeout (->retry next), cred.retryTimeout
    else if body.match /logged out from/i
      console.log "Success"
      next()
    else if body.match /Session expired/i
      console.log "Session expired."
      next()
    return
  return

Prompt.start()

new Promise (next) ->
  Promp.get [
      name: 'username'
      {name: 'password',hidden: true}
    ], (er, val) ->
      console.log(er,val);
      cred.user=val.username
      cred.password=val.password
      next()
      return
.then -> getSessionID()
.then -> login()
.then -> refresh()
###
process.stdin.setRawMode true
process.stdin.setEncoding 'utf8'
process.stdin.resume()
process.stdin.on 'data', (chunk) ->
  #chunk = process.stdin.read()
  if(!chunk?)
    return
  console.log chunk.toString()
  key = chunk.toString()[0]
  if cred.loggedin
    logout().then -> console.log "Press q to login again"
  else if cred.password? and key is 'q'
    getSessionID().then ->login().then(refresh)
###
do keepBusy= ->
  setTimeout keepBusy,10000
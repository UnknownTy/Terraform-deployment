const express = require('express')
const path = require('path')
const fs = require('fs')

module.exports = function({database, authorize, generateAccessToken}) {
  const router = express.Router()

  function sendUser({res, user}) {
    const accessToken = generateAccessToken({id: user.id, fullName: user.full_name, email: user.email, username: user.username})
    res.cookie('token', accessToken)
    res.send({ accessToken: accessToken })
  }

  // Create a new user
  router.post('/', async function(req, res) {
    let {username, email, password} = req.body
    if (typeof user === 'string') {
      user = JSON.parse(user)
    }
  
    try {
      const dbuser = await database.createUser({username, email, password})
      console.log("Created user", dbuser)
      sendUser({res, user: dbuser})
    } catch (error) {
      console.error(error)
      res.send({error: error.message})
    }
  })

  
  router.post('/login', async function(req, res) {
    const credentials = req.body

    try {
      const user = await database.getUser(credentials)
      sendUser({res, user})
    } catch (error) {
      console.log(error)
      res.status(401).send({error: error.message})
    }
  })
  
  // router.get('/me', authorize, async function(req, res, next) {
  //   const user = await database.getUser({id: req.user.id})
  //   sendUser({res, user})
  // })

  router.post('/logout', function(req, res, next) {
    res.cookie('token', {expires: Date.now()});
    res.send({user: null})
  })

  // Get a user's posts
  router.get('/:id/posts', async function(req, res, next) {
    res.send({})
  })

  return router
}

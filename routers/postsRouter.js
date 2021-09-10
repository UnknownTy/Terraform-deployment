const express = require('express')

module.exports = function({database, authorize, imageUpload}) {
  const router = express.Router()

  router.get('/', authorize, async (req, res) => {
    const user = req.user
    const {limit, search, skip} = req.query
    try {
      const posts = await database.getPosts({user, limit: +limit, search, skip: +skip})
      res.send({posts})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
    
  })

  router.get('/:id', authorize, async (req, res) => {
    const user = req.user
    const postId = req.params.id
    try {
      const post = await database.getPost({user, postId})
      console.log(post)
      res.send({post})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
  })

  router.get('/:id/comments', authorize, async (req, res) => {
    const postId = req.params.id
    try {
      const comments = await database.getPostComments({postId})
      res.send({comments: comments})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
  })

  router.post('/:id/comments', authorize, async (req, res) => {
    const user = req.user
    const commentDetails = req.body
    const postId = req.params.id
    try {
      const comment = await database.createComment({commentDetails, postId, user})
      console.log({comment, commentDetails, postId})
      res.send({comment: comment})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
  })

  router.post('/:id/likes', authorize, async (req, res) => {
    const user = req.user
    const postId = req.params.id
    try {
      const like = await database.createLike({postId, user})
      console.log({like, postId})
      res.send({like})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
  })

  router.delete('/:id/likes', authorize, async (req, res) => {
    const user = req.user
    const postId = req.params.id
    try {
      const like = await database.deleteLike({postId, user})
      console.log({like, postId})
      res.send({like})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
    }
  })

  router.post('/', authorize, imageUpload, async (req, res) => {
    const user = req.user
    const postDetails = req.body

    if (postDetails.type === 'url' && postDetails.imageUrl.length < 11) {
      res.status(422).send({error: "Enter a valid image url"})
      return
    }
    if (postDetails.type === 'file') {
      if (!req.file || !req.file.filename) {
        res.status(422).send({error: "Select a valid image"})
        return
      }
      postDetails.filename = req.file.filename
      postDetails.imageUrl = `/api/postImages/${req.file.filename}`
    }
    try {
      console.log("create post")
      console.log({postDetails, user})
      const post = await database.createPost({postDetails, user})
      console.log({user, post})
      res.send({post: post})
    } catch (error) {
      console.error(error)
      res.status(500).send({error: error.message})
      
    }
  })

  return router
}
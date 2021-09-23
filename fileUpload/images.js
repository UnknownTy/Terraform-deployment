const fs = require("fs")
const path = require("path")

const express = require("express")

const s3Manager = require("./s3manager")

const multer = require("multer")

module.exports = function ({ uploadsPath, bucketName, region }) {
  const s3 = bucketName ? s3Manager({ bucketName, region }) : null

  const upload = multer({ dest: uploadsPath })

  let postImageUpload = !s3
    ? upload.single("image")
    : [
        upload.single("image"),
        async (req, res, next) => {
          if (req.body.type !== "file") {
            next()
            return
          }
          if (!req.file || !req.file.filename) {
            res.status(422).send({ error: "Select a valid image" })
            return
          }
          const file = path.join(uploadsPath, req.file.filename)
          try {
            const data = await s3.upload({ file })
            console.log(data)
            fs.unlink(file, (err) => {
              if (err) {
                console.error(err)
              }
            })
            next()
          } catch (error) {
            console.error(error)
            res.status(500).send({ error: "Couldn't upload image" })
          }
        },
      ]

  const imagesRouter = express.Router()

  imagesRouter.get("/api/postImages/:filename", (req, res) => {
    const { filename } = req.params
    if (!s3) {
      res.sendFile(path.join(uploadsPath, filename))
      return
    }
    const stream = s3.getStream({ fileKey: filename })
    stream.pipe(res)
  })

  return {
    router: imagesRouter,
    postImageUpload,
  }
}

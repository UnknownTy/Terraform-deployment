const { MongoClient, ObjectId } = require('mongodb')
const bcrypt = require('bcryptjs')

module.exports = async function () {

  const url = process.env.MONGO_DB_URL || 'mongodb://localhost:27017'
  const dbName = process.env.MONGO_DB_NAME || 'socialSomething'
  const client = new MongoClient(url, { useUnifiedTopology: true, useNewUrlParser: true })

  await client.connect()

  const db = client.db(dbName)
  const posts = db.collection('posts')
  const users = db.collection('users')
  const comments = db.collection('comments')
  const likes = db.collection('likes')

  async function getPosts({ user, search = null, limit = 100, skip = 0 }) {
    // return await posts.find({}).sort({ "timestamp": -1 }).skip(skip).limit(limit).toArray()

    const aggregateOptions = [
      {
        $lookup: {
          from: 'likes',
          as: 'likes',
          let: {
            'postId': '$_id',
          },
          pipeline: [
            {
              $match: { 
                $expr: {
                  $and: [ 
                    { $eq: ['$postId', '$$postId'] },
                    { $eq: ['$user._id', ObjectId(user._id)] }
                  ]
                } 
              }
            }
          ]
        },
      },
      { $addFields: {
        "liked": { "$size": "$likes" }
      }},
      { $project: {
        "likes": 0
      }},
    ]
    if (search) {
      aggregateOptions.push({
        $match: { 
          $expr: {
            $or: [ 
              { $regexMatch: {input: '$description', regex: new RegExp(`${search}`), options: "i" }},
              { $regexMatch: {input: '$user.username', regex: new RegExp(`${search}`), options: "i" }}
            ]
          } 
        }
      })
    }
    return await posts.aggregate(aggregateOptions).sort({ timestamp: -1, likes: 1}).skip(skip).limit(limit || 20).toArray()
  }

  async function getPost({ postId, user }) {
    const results = await posts.aggregate([
      {
        $match: {
          _id: ObjectId(postId),
        }
      },
      {
        // $lookup: {
        //   from: 'comments',
        //   localField: '_id',
        //   foreignField: 'postId',
        //   as: 'comments',
        // }
        $lookup: {
          from: 'comments',
          as: 'comments',
          let: {
            'postId': '$_id'
          },
          pipeline: [
            {
              $match: { $expr: { $eq: ['$postId', '$$postId'] } }
            }, {
              '$sort': { 'timestamp': -1 }
            },
            { $limit: 20 },
          ]
        }
      },
      {
        $lookup: {
        from: 'likes',
        as: 'likes',
        let: {
          'postId': '$_id',
        },
        pipeline: [
          {
            $match: { 
              $expr: {
                $and: [ 
                  { $eq: ['$postId', '$$postId'] },
                  { $eq: ['$user._id', ObjectId(user._id)] }
                ]
              } 
            }
          }
        ]
      },
    },
    { $addFields: {
      "liked": { "$size": "$likes" }
    }},
    { $project: {
      "likes": 0
    }}

    ]).limit(1).toArray()

    return results[0]
  }

  async function getPostComments({ postId }) {
    return await comments.find({ postId: ObjectId(postId) }).sort({ "timestamp": -1 }).toArray()
  }


  async function createPost({ postDetails, user }) {
    const result = await posts.insertOne({
      ...postDetails,
      totalLikes: 0,
      totalComments: 0,
      timestamp: Date.now(),
      user: { username: user.username, _id: ObjectId(user.id) }
    })
    return result.ops[0]
  }

  async function createComment({ commentDetails, postId, user }) {

    const session = client.startSession()
    session.startTransaction()
    try {
      const result = await comments.insertOne({
        ...commentDetails,
        postId: ObjectId(postId),
        user: { username: user.username, _id: ObjectId(user.id) },
        timestamp: Date.now()
      })

      const update = {
        $inc: {
          "totalComments": 1
        }
      }

      await posts.findOneAndUpdate({ "_id": ObjectId(postId) }, update)
      await session.commitTransaction()
      return result.ops[0]
    } catch (error) {
      await session.abortTransaction()
      throw error
    } finally {
      await session.endSession()
    }

  }

  async function createLike({ postId, user }) {

    const like = await likes.findOne({postId: ObjectId(postId), "user._id": ObjectId(user.id) })
    if (like) {
      return like
    }

    const session = client.startSession()
    session.startTransaction()
    try {
      const result = await likes.insertOne({
        postId: ObjectId(postId),
        user: { username: user.username, _id: ObjectId(user.id) },
        timestamp: Date.now()
      })

      const update = {
        $inc: {
          "totalLikes": 1
        }
      }

      await posts.findOneAndUpdate({ "_id": ObjectId(postId) }, update)
      await session.commitTransaction()
      return result.ops[0]
    } catch (error) {
      await session.abortTransaction()
      throw error
    } finally {
      await session.endSession()
    }

  }

  async function deleteLike({ postId, user }) {
    const session = client.startSession()
    session.startTransaction()
    try {
      const like = await likes.findOneAndDelete({postId: ObjectId(postId), "user._id": ObjectId(user.id) })
      if (!like.value) {
        throw Error("No like exists for this user")
      }

      const update = {
        $inc: {
          "totalLikes": -1
        }
      }

      await posts.findOneAndUpdate({ "_id": ObjectId(postId) }, update)
      await session.commitTransaction()
      return like.value
    } catch (error) {
      await session.abortTransaction()
      throw error
    } finally {
      await session.endSession()
    }

  }

  async function getUser(options) {
    const user = await users.findOne({ username: options.username })
    if (!user) {
      throw Error("Invalid username")
    }

    if (!options.password) {
      return user
    }

    const same = await bcrypt.compare(options.password, user.password)

    if (!same) {
      throw Error("Passwords don't match")
    }

    return user
  }

  async function createUser({ email, username, password }) {
    const encrypted = await bcrypt.hash(password, 12)
    const user = await users.findOne({ $or: [{ username }, { email }] })
    if (user) {
      throw Error("username or email already taken")
    }
    const result = await users.insertOne({
      email,
      username,
      password: encrypted,
      timestamp: Date.now(),
    })

    return result.ops[0]
  }

  return {
    getPosts,
    createPost,
    getUser,
    createUser,
    createComment,
    getPostComments,
    getPost,
    createLike,
    deleteLike
  }
}




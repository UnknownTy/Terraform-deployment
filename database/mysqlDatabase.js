const mysql = require("mysql2")
const bcrypt = require("bcrypt")



module.exports = async function ({host, user, password, database}) {

  const config = {
    host: host || "localhost",
    user: user || "root",
    database: database || "",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  }
  if (password) {
    config.password = password
  }
  const pool = mysql.createPool(config)

  const promisePool = pool.promise()

  async function getPosts({ user, search = null, limit = 100, skip = 0 }) {
    let params = [user.id]
    let query = `
  SELECT posts.id, posts.created, imageUrl, description, totalLikes, totalComments, 
  JSON_OBJECT('id', posts.user_id, 'email', email, 'username', username) as user, 
  IF(likes.id is null, FALSE, TRUE) liked
  FROM posts
  JOIN users
  ON posts.user_id = users.id
  LEFT JOIN likes
  ON likes.post_id = posts.id AND likes.user_id = ?
  `

    if (search) {
      query += `
    WHERE description LIKE ?
    `
      params.push("%" + search + "%")
    }

    query += `
    LIMIT ?
  `
    params.push(limit)

    const [rows, fields] = await promisePool.query(query, params)
    return rows
  }

  async function getPost({ postId, user }) {
    const [rows, fields] = await promisePool.query(
      `
  SELECT posts.id, posts.created, imageUrl, description, totalLikes, totalComments, 
  JSON_OBJECT('id', posts.user_id, 'email', users.email, 'username', users.username) as user,
  IF(likes.id is null, FALSE, TRUE) liked
  FROM posts
  JOIN users
  ON posts.user_id = users.id
  LEFT JOIN likes
  ON likes.post_id = posts.id AND likes.user_id = ?
  WHERE posts.id = ?
  Limit 1
  `,
      [user.id, postId]
    )
    const post = rows[0]
    post.comments = await getPostComments({ postId })
    return rows[0]
  }

  async function getPostComments({ postId }) {
    const [rows, fields] = await promisePool.query(
      `
    select comments.id, comments.content as text, JSON_OBJECT('id', users.id, 'username', users.username) as user 
    from comments
    join users
    on comments.user_id = users.id
    where comments.post_id = ?
    `,
      [postId]
    )
    return rows
  }

  async function getComment({ commentId }) {
    const [rows, fields] = await promisePool.query(
      `
    select comments.id, comments.content as text, JSON_OBJECT('id', users.id, 'username', users.username) as user 
    from comments
    join users
    on comments.user_id = users.id
    where comments.id = ?
    `,
      [commentId]
    )
    return rows[0]
  }

  async function createPost({ postDetails, user }) {
    const [result] = await promisePool.query(
      `
    INSERT INTO posts (imageUrl, description, user_id)
    VALUES (?, ?, ?)
 `,
      [postDetails.imageUrl, postDetails.description, user.id]
    )

    const post = await getPost({ postId: result.insertId, user })
    return post
  }

  async function createComment({ commentDetails, postId, user }) {
    const { text } = commentDetails
    let [result] = await promisePool.query(
      `
      INSERT INTO comments ( user_id, post_id, content)
      VALUES (?, ?, ?)
      `,
      [user.id, postId, text]
    )

    const comment = await getComment({ commentId: result.insertId })
    return comment
  }

  async function createLike({ postId, user }) {
    let [result] = await promisePool.query(
      `
      INSERT INTO likes ( user_id, post_id)
      VALUES (?, ?)
      `,
      [user.id, postId]
    )

    return result.insertId
  }

  async function deleteLike({ postId, user }) {
    let [result] = await promisePool.query(
      `
      DELETE FROM likes 
      WHERE user_id = ?
      AND post_id = ?
      `,
      [user.id, postId]
    )

    return result
  }

  async function getUser(options) {
    let [existingUsers] = await promisePool.query(
      `
  select id, email, username, password
  from users
  where email = ? 
  or username = ?
  `,
      [options.email, options.username]
    )
    const user = existingUsers[0]
    if (!user) {
      throw Error("Invalid username")
    }

    if (!options.password) {
      return { email: user.email, username: user.username }
    }

    const same = await bcrypt.compare(options.password, user.password)

    if (!same) {
      throw Error("Passwords don't match")
    }

    return user
  }

  async function createUser({ email, username, password }) {
    let [existingUsers] = await promisePool.query(
      `
  select email 
  from users
  where email = ? 
  or username = ?
  `,
      [email, username]
    )

    if (existingUsers.length > 0) {
      throw Error("username or email already taken")
    }
    const encrypted = await bcrypt.hash(password, 12)
    let [result] = await promisePool.query(
      `
  INSERT INTO users ( password, email, username)
  VALUES (?, ?, ?)
  `,
      [encrypted, email, username]
    )
    let [rows] = await promisePool.query(
      `
  select id, username, email 
  from users
  where id = ?
  `,
      [result.insertId]
    );

    return rows[0]
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
    deleteLike,
  }
}

-- database

DROP DATABASE IF EXISTS social_something;
CREATE DATABASE social_something;
USE social_something;

-- tables

DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id integer PRIMARY KEY AUTO_INCREMENT,
  created TIMESTAMP NOT NULL DEFAULT NOW(),
  `password` VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL,
  dob DATE
);
CREATE TABLE posts (
  id integer PRIMARY KEY AUTO_INCREMENT,
  created TIMESTAMP NOT NULL DEFAULT NOW(),
  imageUrl VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  totalLikes INTEGER NOT NULL DEFAULT 0,
  totalComments INTEGER NOT NULL DEFAULT 0,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) references users(id)
);
CREATE TABLE comments (
  id integer PRIMARY KEY AUTO_INCREMENT,
  created TIMESTAMP NOT NULL DEFAULT NOW(),
  `content` TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);
CREATE TABLE likes (
  id integer PRIMARY KEY AUTO_INCREMENT,
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);

-- triggers


DROP TRIGGER IF EXISTS  increment_like_count;

DELIMITER //

CREATE TRIGGER increment_like_count 
AFTER INSERT ON likes 
FOR EACH ROW 
BEGIN
  UPDATE posts
  SET totalLikes = totalLikes+1
  WHERE id = NEW.post_id;
END//

DELIMITER ;


DROP TRIGGER IF EXISTS  decrement_like_count;

DELIMITER //

CREATE TRIGGER decrement_like_count 
AFTER DELETE ON likes 
FOR EACH ROW 
BEGIN
  UPDATE posts
  SET totalLikes = totalLikes-1
  WHERE id = OLD.post_id;
END//

DELIMITER ;


DROP TRIGGER IF EXISTS  increment_comment_count;

DELIMITER //

CREATE TRIGGER increment_comment_count 
AFTER INSERT ON comments 
FOR EACH ROW 
BEGIN
  UPDATE posts
  SET totalComments = totalComments+1
  WHERE id = NEW.post_id;
END//

DELIMITER ;


DROP TRIGGER IF EXISTS  decrement_comment_count;

DELIMITER //

CREATE TRIGGER decrement_comment_count 
AFTER DELETE ON comments 
FOR EACH ROW 
BEGIN
  UPDATE posts
  SET totalComments = totalComments-1
  WHERE id = OLD.post_id;
END//

DELIMITER ;
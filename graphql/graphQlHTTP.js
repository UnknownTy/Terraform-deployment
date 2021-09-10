var { graphqlHTTP } = require("express-graphql")
var { buildSchema } = require("graphql")

module.exports = function ({
  database,
  authorize,
  generateAccessToken, 
  imageUpload,
}) {

  var schema = buildSchema(`
  type Query {
    hello: String
  }
`);
  // The root provides a resolver function for each API endpoint
  var root = {
    hello: () => {
      return "Hello world!";
    },
  };

  return graphqlHTTP({
    schema: schema,
    rootValue: root,
    graphiql: true,
  });
}
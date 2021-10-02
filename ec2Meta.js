const axios = require('axios')

const baseURL = "http://169.254.169.254/latest/meta-data"

const instance = axios.create({
  baseURL,
  timeout: 1000
})

async function ec2Meta() {
  const result = await instance.get()
  return result.data
}
exports.ec2Meta = ec2Meta

async function ipv4() {
  const result = await instance.get('/local-ipv4')
  return result.data
}
exports.ipv4 = ipv4

async function publicIPv4() {
  const result = await instance.get("/public-ipv4");
  return result.data;
}
exports.publicIPv4 = publicIPv4;

async function instanceId() {
  const result = await instance.get('/instance-id')
  return result.data
}
exports.instanceId = instanceId

async function amiID() {
  const result = await instance.get("/ami-id");
  return result.data;
}
exports.amiID = amiID;

async function hostname() {
  const result = await instance.get('/hostname')
  return result.data
}
exports.hostname = hostname

// ipv4().then(console.log)
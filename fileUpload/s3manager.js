// Load the AWS SDK for Node.js
const AWS = require('aws-sdk')

function s3Manager({bucketName, region}) {

  // Set the region 
  AWS.config.update({region})

  // Create S3 service object
  const s3 = new AWS.S3({apiVersion: '2006-03-01'})

  function upload({file}) {
    return new Promise((resolve, reject) => {
      // call S3 to retrieve upload file to specified bucket
      let uploadParams = {Bucket: bucketName, Key: '', Body: ''}

      // Configure the file stream and obtain the upload parameters
      let fs = require('fs')
      let fileStream = fs.createReadStream(file)
      fileStream.on('error', function(err) {
        console.log('File Error', err)
      })
      uploadParams.Body = fileStream
      let path = require('path')
      uploadParams.Key = path.basename(file)

      // call S3 to retrieve upload file to specified bucket
      s3.upload (uploadParams, function (err, data) {
        if (err) {
          reject(err)
        } if (data) {
          resolve(data)
        }
      })
    })
  }

  function getStream({fileKey}) {
    console.log('Trying to download file', fileKey)
    
    let options = {
        Bucket: bucketName,
        Key: fileKey,
    }

    let fileStream = s3.getObject(options).createReadStream()
    return fileStream
  }
  
  return { getStream, upload }
}
module.exports = s3Manager
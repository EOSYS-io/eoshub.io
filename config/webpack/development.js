process.env.NODE_ENV = process.env.NODE_ENV || 'development'
const WriteFilePlugin = require('write-file-webpack-plugin')

const environment = require('./environment')

environment.plugins.append(
  'WriteFilePlugin',
  new WriteFilePlugin()
);

module.exports = environment.toWebpackConfig()

process.env.NODE_ENV = process.env.NODE_ENV || 'alpha'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()

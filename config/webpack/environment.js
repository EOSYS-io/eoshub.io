const { environment } = require('@rails/webpacker')
const elm =  require('./loaders/elm')
require('dotenv').config();

environment.loaders.append('elm', elm)
module.exports = environment

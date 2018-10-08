const { environment } = require('@rails/webpacker')
const elm =  require('./loaders/elm')
const CopyWebpackPlugin = require('copy-webpack-plugin')
require('dotenv').config();

environment.loaders.append('elm', elm)
environment.plugins.append(
  'CopyWebpackPlugin',
  new CopyWebpackPlugin([
    {
      from: 'charting_library/static',
      to: 'charting_library/static',
      context: 'vendor/assets/charting_library',
	},
    {
      from: 'conf',
      to: 'conf',
      context: 'app/frontend/src',
	}
  ])
);

module.exports = environment

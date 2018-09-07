var rp = require('request-promise').defaults({json: true})

const api_root = 'https://min-api.cryptocompare.com'
const history = {}

function getLanguageFromURL() {
  const regex = new RegExp('[\\?&]lang=([^&#]*)');
  const results = regex.exec(window.location.search);
  return results === null ? null : decodeURIComponent(results[1].replace(/\+/g, ' '));
}

export default {
	history: history,
    getBars: function(symbolInfo, resolution, from, to, first, limit) {
		var split_symbol = symbolInfo.name.split(/[:/]/)
			const url = resolution === 'D' ? '/data/histoday' : resolution >= 60 ? '/data/histohour' : '/data/histominute'
			const qs = {
					e: split_symbol[0],
					fsym: split_symbol[1],
					tsym: split_symbol[2],
					toTs:  to ? to : '',
					limit: limit ? limit : 2000, 
					// aggregate: 1//resolution 
				}
			// console.log({qs})

        return rp({
                url: `${api_root}${url}`,
                qs,
            })
            .then(data => {
                console.log({data})
				if (data.Response && data.Response === 'Error') {
					console.log('CryptoCompare API error:',data.Message)
					return []
				}
				if (data.Data.length) {
					console.log(`Actually returned: ${new Date(data.TimeFrom * 1000).toISOString()} - ${new Date(data.TimeTo * 1000).toISOString()}`)
					var bars = data.Data.map(el => {
						return {
							time: el.time * 1000, //TradingView requires bar time in ms
							low: el.low,
							high: el.high,
							open: el.open,
							close: el.close,
							volume: el.volumefrom 
						}
					})
						if (first) {
							var lastBar = bars[bars.length - 1]
							history[symbolInfo.name] = {lastBar: lastBar}
						}
					return bars
				} else {
					return []
				}
			})
}
}
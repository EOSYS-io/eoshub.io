import historyProvider from './historyProvider';
import { chartConfig } from '../config';

function onReady(callback) {
  setTimeout(() => callback(chartConfig), 0);
}

// We don't need to search symbols.
// args: userInput, exchange, symbolType, onResultReadyCallback
function searchSymbols() {}

function resolveSymbol(symbolName, onSymbolResolvedCallback, onResolveErrorCallback) {
  // expects a symbolInfo object in response
  // console.log('resolveSymbol:',{symbolName})
  var split_data = symbolName.split(/[:/]/)
  // console.log({split_data})
  var symbol_stub = {
   name: symbolName,
   description: '',
   type: 'crypto',
   session: '24x7',
   timezone: 'Etc/UTC',
   ticker: symbolName,
   exchange: split_data[0],
   minmov: 1,
   pricescale: 100000000,
   has_intraday: true,
   intraday_multipliers: ['1', '60'],
   supported_resolution:  supportedResolutions,
   volume_precision: 8,
   data_status: 'streaming',
  }

  if (split_data[2].match(/USD|EUR|JPY|AUD|GBP|KRW|CNY/)) {
   symbol_stub.pricescale = 100
  }
  setTimeout(function() {
   onSymbolResolvedCallback(symbol_stub)
   console.log('Resolving that symbol....', symbol_stub)
  }, 0)
}

function getBars(symbolInfo, resolution, from, to, onHistoryCallback, onErrorCallback, firstDataRequest) {
  const bars = historyProvider.getBars(symbolInfo, resolution, from, to, firstDataRequest)
  .then(bars => {
    if (bars.length) {
      onHistoryCallback(bars, {noData: false})
    } else {
      onHistoryCallback(bars, {noData: true})
    }
  }).catch(err => {
    console.log({err})
    onErrorCallback(err)
  })
}

// TODO(heejae): Implement below two functions when socket API is implemented.
function subscribeBars(symbolInfo, resolution, onRealtimeCallback, listenerGUID, onResetCacheNeededCallback) {
}

function unsubscribeBars(listenerGUID) {}

function calculateHistoryDepth(resolution, resolutionBack, intervalBack) {
  let daysCount = 0;
  if (resolution === 'D') {
    daysCount = requiredPeriodsCount;
  } else if (resolution === 'M') {
    daysCount = 31 * requiredPeriodsCount;
  } else if (resolution === 'W') {
    daysCount = 7 * requiredPeriodsCount;
  } else {
    daysCount = requiredPeriodsCount * resolution / (24 * 60);
  }
  return daysCount * 24 * 60 * 60;
}

// optional functions.
// args: symbolInfo, startDate, endDate, onDataCallback, resolution
function getMarks() {}
// args; symbolInfo, startDate, endDate, onDataCallback, resolution
function getTimeScaleMarks() {}
// args: callback
function getServerTime() {}

export {
  onReady,
  searchSymbols,
  resolveSymbol,
  getBars,
  subscribeBars,
  unsubscribeBars,
  calculateHistoryDepth,
  getMarks,
  getTimeScaleMarks,
  getServerTime,
};

import historyProvider from './historyProvider';
import { chartConfig } from '../config';

function onReady(callback) {
  setTimeout(() => callback(chartConfig), 0);
}

// We don't need to search symbols.
// args: userInput, exchange, symbolType, onResultReadyCallback
function searchSymbols() {}

function resolveSymbol(symbolName, onSymbolResolvedCallback) {
  // expects a symbolInfo object in response
  const splitData = symbolName.split(/[:/]/);
  const name = `${symbolName[1]}/${symbolName[2]}`;
  const { supportedResolutions } = chartConfig;
  const symbolStub = {
    name,
    description: 'Eos ram prices per kilo bytes',
    type: 'crypto',
    session: '24x7',
    timezone: 'Asia/Seoul',
    ticker: name,
    exchange: splitData[0],
    minmov: 1,
    pricescale: 100000000,
    has_intraday: true,
    has_daily: true,
    has_empty_bars: true,
    has_no_volume: true,
    has_weekly_and_monthly: false,
    intraday_multipliers: ['1', '3', '5', '15', '30', '60', '240'],
    supported_resolutions: supportedResolutions,
    volume_precision: 8,
    data_status: 'streaming',
    baseType: splitData[1],
    quoteType: splitData[2],
  };

  setTimeout(() => {
    onSymbolResolvedCallback(symbolStub);
  }, 0);
}

function getBars(
  symbolInfo, resolution, from, to, onHistoryCallback, onErrorCallback, firstDataRequest,
) {
  historyProvider.getBars(symbolInfo, resolution, from, to, firstDataRequest)
    .then((bars) => {
      if (bars.length) {
        onHistoryCallback(bars, { noData: false });
      } else {
        onHistoryCallback(bars, { noData: true });
      }
    }).catch((err) => {
      console.log(err);
      onErrorCallback(err);
    });
}

// TODO(heejae): Implement below two functions when socket API is implemented.
// args: symbolInfo, resolution, onRealtimeCallback, listenerGUID, onResetCacheNeededCallback
function subscribeBars() {}

// args: listenerGUID
function unsubscribeBars() {}

function calculateHistoryDepth() {}

// optional functions.
// args: symbolInfo, startDate, endDate, onDataCallback, resolution
function getMarks() {}
// args; symbolInfo, startDate, endDate, onDataCallback, resolution
function getTimeScaleMarks() {}
// args: callback
function getServerTime() {}

export default {
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

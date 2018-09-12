import dataFeed from './dataFeed';

export default async function loadTV() {
  // See details of this features on http://tradingview.github.io/featuresets.html
  const disabledFeatures = [
    'save_chart_properties_to_local_storage',
    'use_localstorage_for_settings',
    'create_volume_indicator_by_default',
    'header_undo_redo',
    'header_symbol_search',
    'symbol_search_hot_key',
    'header_saveload',
    'create_volume_indicator_by_default',
    'border_around_the_chart',
    'display_market_status',
    'pane_context_menu',
    'go_to_date',
    'header_compare',
    'BarSetHeikenAshi',
    'use_localstorage_for_settings',
  ];

  const overrides = {
    'mainSeriesProperties.style': 1, // Default chart : 1. Candle.
    'mainSeriesProperties.candleStyle.upColor': '#c61919',
    'mainSeriesProperties.candleStyle.downColor': '#0b5db3',
    'mainSeriesProperties.candleStyle.wickUpColor': '#c61919',
    'mainSeriesProperties.candleStyle.wickDownColor': '#0b5db3',
    'mainSeriesProperties.candleStyle.borderUpColor': '#c61919',
    'mainSeriesProperties.candleStyle.borderDownColor': '#0b5db3',
    'mainSeriesProperties.hollowCandleStyle.upColor': '#c61919',
    'mainSeriesProperties.hollowCandleStyle.downColor': '#0b5db3',
    'mainSeriesProperties.hollowCandleStyle.wickUpColor': '#c61919',
    'mainSeriesProperties.hollowCandleStyle.wickDownColor': '#0b5db3',
    'mainSeriesProperties.hollowCandleStyle.borderUpColor': '#c61919',
    'mainSeriesProperties.hollowCandleStyle.borderDownColor': '#0b5db3',
    'mainSeriesProperties.haStyle.upColor': '#c61919',
    'mainSeriesProperties.haStyle.downColor': '#0b5db3',
    'mainSeriesProperties.haStyle.wickUpColor': '#c61919',
    'mainSeriesProperties.haStyle.wickDownColor': '#0b5db3',
    'mainSeriesProperties.haStyle.borderUpColor': '#c61919',
    'mainSeriesProperties.haStyle.borderDownColor': '#0b5db3',
    'study_Overlay@tv-basicstudies.style': 1,
    'study_Overlay@tv-basicstudies.lineStyle.color': '#351c75',
  };

  const timeFramesOption = [
    { text: '1w', resolution: 'D', description: '1 Week' },
    { text: '1d', resolution: '60', description: '1 Day' },
  ];

  const widgetOptions = {
    debug: false,
    fullscreen: false,
    autosize: true,
    symbol: 'EOS RAM:EOS/KB',
    datafeed: dataFeed,
    interval: '15',
    container_id: 'tv-chart-container',
    library_path: 'assets/packs/charting_library/',
    locale: 'en',
    timezone: 'Asia/Seoul',
    disabled_features: disabledFeatures,
    enabled_features: [],
    client_id: 'tradingview.com',
    user_id: 'public_user_id',
    overrides,
    studies_overrides: {},
    time_frames: timeFramesOption,
  };

  // Lazy import.
  window.tradingView = await System.import('charting_library.min'); // eslint-disable-line no-undef
  const tvWidget = new window.tradingView.widget(widgetOptions); // eslint-disable-line
}

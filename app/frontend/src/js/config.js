const scatterConfig = {
  blockchain: 'eos',
  chainId: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
  host: 'rpc.eosys.io',
  port: '443',
};

const eosjsConfig = {
  broadcast: true,
  chainId: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
  sign: true,
};

const chartConfig = {
  supportedResolutions: ['1', '3', '5', '15', '30', '60', '240', 'D', 'W'],
  supports_marks: false,
  supports_search: false,
  supports_group_request: false,
};

export { scatterConfig, eosjsConfig, chartConfig };

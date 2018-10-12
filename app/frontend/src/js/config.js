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
  supportsMarks: false,
  supportsSearch: false,
  supportsGroupRequest: false,
};

function getEoshubHost() {
  if (process.env.RAILS_ENV === 'alpha') {
    return 'http://alpha.eoshub.io';
  }
  if (process.env.RAILS_ENV === 'production') {
    return 'https://eoshub.io';
  }
  return 'http://localhost:3000';
}

const eoshubHost = getEoshubHost();

export {
  scatterConfig,
  eosjsConfig,
  chartConfig,
  eoshubHost,
};

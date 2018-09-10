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
  if (process.env.NODE_ENV === 'alpha') {
    return 'http://ecs-first-run-alb-1125793223.ap-northeast-2.elb.amazonaws.com';
  }
  if (process.env.NODE_ENV === 'production') {
    return '';
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

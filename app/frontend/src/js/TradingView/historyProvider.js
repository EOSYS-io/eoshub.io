import axios from 'axios';
import _ from 'lodash';

import { eoshubHost } from '../config';

function transformResolutionToSeconds(resolution) {
  if (resolution === 'W') {
    return 7 * 24 * 60 * 60;
  }
  if (resolution === 'D') {
    return 24 * 60 * 60;
  }
  // By default, it uses minutes.
  return resolution * 60;
}

function getBars(symbolInfo, resolution, from, to, firstDataReq) {
  const intvl = transformResolutionToSeconds(resolution);
  const url = `${eoshubHost}/eos_ram_price_histories/data`;
  // Returning promise.
  return axios({
    method: 'get',
    url,
    params: {
      intvl,
      from,
      to: firstDataReq ? new Date().getTime() : to,
    },
  }).then(({ status, data }) => {
    console.log(data);
    if (status !== 200) {
      console.log('API Error: ', data.msg);
      return [];
    }

    return _.map(data, (elem) => {
      const {
        start_time, // eslint-disable-line
        open,
        close,
        high,
        low,
      } = elem;

      return {
        time: new Date(start_time).getTime() * 1000,
        high,
        low,
        open,
        close,
      };
    });
  });
}

export default {
  getBars,
};

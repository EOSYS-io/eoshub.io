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
      to: firstDataReq ? Math.round(new Date().getTime() / 1000) : to * 1000,
    },
  }).then(({ status, data }) => {
    if (status !== 200) {
      console.log('API Error: ', data.msg);
      return [];
    }

    return _.map(data, (elem) => {
      const {
        start_time, // eslint-disable-line
        end_time, // eslint-disable-line
        open,
        close,
        high,
        low,
      } = elem;

      return {
        time: (new Date(start_time).getTime() + new Date(end_time).getTime()) / 2,
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

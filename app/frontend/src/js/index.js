// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import '../stylesheets/style.scss';

import eos from 'eosjs';

import Elm from '../elm/Main'; // eslint-disable-line import/no-unresolved
import {
  getWalletStatus,
  authenticateAccount,
  invalidateAccount,
  getAuthInfo,
} from './wallet';
import { scatterConfig, eosjsConfig } from './config';
import {
  getElm,
  getScatter,
  updateElm,
  updateScatter,
} from './state';

function createResponseStatus() {
  const { account, authority } = getScatter();
  return {
    status: getWalletStatus(),
    account,
    authority,
  };
}

function createScatterReponse(code, type, msg) {
  if (code === 200) return { code: 200, type_: '', message: '' };
  return {
    code,
    type_: !type ? '' : type,
    message: !msg ? '' : msg,
  };
}

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-target');

  if (!target) {
    return;
  }

  const app = Elm.Main.embed(target);

  app.ports.checkWalletStatus.subscribe(async () => {
    app.ports.receiveWalletStatus.send(createResponseStatus());
  });

  app.ports.authenticateAccount.subscribe(async () => {
    let response = createScatterReponse(200);
    try {
      await authenticateAccount();
    } catch (err) {
      if (err.isError && err.isError === true) {
        // Deal with scatter error.
        const { code, type, message } = err;
        response = createScatterReponse(code, type, message);
      }
    }
    app.ports.receiveWalletStatus.send(createResponseStatus());
    app.ports.receiveScatterResponse.send(response);
  });

  app.ports.invalidateAccount.subscribe(async () => {
    try {
      await invalidateAccount();
    } catch (err) {
      if (err.isError && err.isError === true) {
        // Deal with scatter error.
        const { code, type, message } = err;
        app.ports.receiveScatterResponse.send(createScatterReponse(code, type, message));
      }
    }
    app.ports.receiveWalletStatus.send(createResponseStatus());
  });

  app.ports.pushAction.subscribe(async ({ account, action, payload }) => {
    let response = createScatterReponse(200);
    try {
      const { eosjsClient } = getScatter();
      const contract = await eosjsClient.contract(account);
      await contract[action](payload);
    } catch (err) {
      if (err.isError && err.isError === true) {
        // Deal with scatter error.
        const { code, type, message } = err;
        response = createScatterReponse(code, type, message);
      }
    }
    app.ports.receiveScatterResponse.send(response);
  });

  updateElm(app);
});

document.addEventListener('scatterLoaded', () => {
  const { scatter } = window;

  // Setting window.scatter to null is recommended.
  window.scatter = null;

  const eosjs = scatter.eos(scatterConfig, eos, eosjsConfig, 'https');
  let scatterState = {
    scatterClient: scatter,
    eosjsClient: eosjs,
    account: '',
    authority: '',
  };

  if (scatter.identity) {
    const { authority, name } = getAuthInfo(scatter.identity);
    scatterState = {
      ...scatterState,
      account: name,
      authority,
    };
  }

  updateScatter(scatterState);
  const app = getElm();
  app.ports.receiveWalletStatus.send(createResponseStatus());
});

// TODO(heejae): This function is a temporary work cause it makes an assumption that
// elm and scatter finish loading after 0.5 seconds from beginning.
// Need to find a good way to handle scatter not found.
window.setTimeout(
  () => {
    const { scatterClient } = getScatter();
    if (!scatterClient) {
      const app = getElm();
      app.ports.receiveWalletStatus.send(createResponseStatus());
    }
  },
  500,
);

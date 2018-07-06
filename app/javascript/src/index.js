// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import eos from 'eosjs';

import Elm from './elm/Main'; // eslint-disable-line import/no-unresolved
import { getWalletStatus, authenticateAccount, invalidateAccount } from './js/wallet';
import { scatterConfig, eosjsConfig } from './js/config';
import { getScatter, updateScatter } from './js/state';

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
    type_: type,
    message: msg,
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
});

document.addEventListener('scatterLoaded', () => {
  const { scatter } = window;
  // Setting window.scatter to null is recommended.
  window.scatter = null;

  const eosjs = scatter.eos(scatterConfig, eos, eosjsConfig, 'https');
  const stateScatter = getScatter();
  updateScatter({
    ...stateScatter,
    scatterClient: scatter,
    eosjsClient: eosjs,
  });
});

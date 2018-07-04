// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import eos from 'eosjs';

import Elm from '../Main'; // eslint-disable-line import/no-unresolved
import { getWalletStatus, authenticateAccount, invalidateAccount } from './wallet';
import { scatterConfig, eosjsConfig } from './config';
import { getScatter, updateScatter } from './state';

function createResponseStatus() {
  const { account, authority } = getScatter();
  return {
    status: getWalletStatus(),
    account,
    authority,
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
    try {
      await authenticateAccount();
    } catch (err) {
      console.error(err);
    }
    app.ports.receiveWalletStatus.send(createResponseStatus());
  });

  app.ports.invalidateAccount.subscribe(async () => {
    try {
      await invalidateAccount();
    } catch (err) {
      console.error(err);
    }
    app.ports.receiveWalletStatus.send(createResponseStatus());
  });

  app.ports.pushAction.subscribe(async ({ account, action, payload }) => {
    try {
      const { eosjsClient } = getScatter();
      const contract = await eosjsClient.contract(account);
      await contract[action](payload);
    } catch (err) {
      console.error(err);
    }
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

// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import eos from 'eosjs';

import Elm from '../Main'; // eslint-disable-line import/no-unresolved
import { checkWalletStatus, authenticateAccount, invalidateAccount } from './wallet';
import { scatterConfig, eosjsConfig } from './config';
import { getScatter, updateScatter } from './state';

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-target');

  if (!target) {
    return;
  }

  const app = Elm.Main.embed(target);

  app.ports.checkWalletStatus.subscribe(() => {
    const walletStatus = checkWalletStatus();
    app.ports.receiveWalletStatus.send(walletStatus);
  });

  app.ports.authenticateAccount.subscribe(async () => {
    try {
      await authenticateAccount();
    } catch (err) {
      console.error(err);
    }
  });

  app.ports.invalidateAccount.subscribe(async () => {
    try {
      await invalidateAccount();
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
    scatter,
    eosjs,
  });
});

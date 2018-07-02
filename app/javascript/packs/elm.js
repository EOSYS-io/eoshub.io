import eos from 'eosjs';

import Elm from '../Main'; // eslint-disable-line import/no-unresolved
import { checkWalletStatus, authenticateAccount } from './wallet';
import { scatterConfig, eosjsConfig } from './config';
import { getScatter, updateScatter } from './state';
// Must import babel-polyfill to support ES7!
import 'babel-polyfill';

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
  authenticateAccount();
});

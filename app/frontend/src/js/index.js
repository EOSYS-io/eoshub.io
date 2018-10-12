// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import '../stylesheets/style.scss';

import eos from 'eosjs';
import ecc from 'eosjs-ecc';
import loadTV from './TradingView/loader';


import Elm from '../elm/Main'; // eslint-disable-line import/no-unresolved
import {
  getWalletStatus,
  authenticateAccount,
  invalidateAccount,
  getAuthInfo,
} from './wallet';
import { scatterConfig, eosjsConfig } from './config';
import {
  getScatter,
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

function createPushActionReponse(code, action, type, msg) {
  return {
    code,
    action,
    type_: !type ? '' : type,
    message: !msg ? '' : msg,
  };
}

const target = document.getElementById('elm-target');

const app = Elm.Main.embed(target, {
  node_env: process.env.NODE_ENV,
});

console.info(`node_env: ${process.env.NODE_ENV}`);

app.ports.checkWalletStatus.subscribe(async () => {
  // the delay is required to wait for loading scatter or changing component subscription
  window.setTimeout(
    () => {
      app.ports.receiveWalletStatus.send(createResponseStatus());
    },
    500,
  );
});

// TODO(heejae): After wallet auth success/error message popup is devised,
// deal with cases.
app.ports.authenticateAccount.subscribe(async () => {
  try {
    await authenticateAccount();
  } catch (err) {
    if (err.isError && err.isError === true) {
      // Deal with scatter error.
      console.error(err);
    }
  }
  app.ports.receiveWalletStatus.send(createResponseStatus());
});

app.ports.invalidateAccount.subscribe(async () => {
  try {
    await invalidateAccount();
  } catch (err) {
    if (err.isError && err.isError === true) {
      // Deal with scatter error.
      console.error(err);
    }
  }
  app.ports.receiveWalletStatus.send(createResponseStatus());
});

app.ports.pushAction.subscribe(async ({ account, action, payload }) => {
  try {
    const { eosjsClient } = getScatter();
    const contract = await eosjsClient.contract(account);
    await contract[action](payload);
    app.ports.receivePushActionResponse.send(createPushActionReponse(200, action));
  } catch (err) {
    if (err.isError && err.isError === true) {
      // Deal with scatter error.
      const { code, type, message } = err;
      if (type === 'signature_rejected') { return; }

      app.ports.receivePushActionResponse.send(
        createPushActionReponse(code, action, type, message),
      );
    }
  }
});

app.ports.generateKeys.subscribe(async () => {
  ecc.PrivateKey.randomKey().then((privateKey) => {
    // Create a new random private key
    const privateWif = privateKey.toWif();

    // Convert to a public key
    const pubkey = ecc.PrivateKey.fromString(privateWif).toPublic().toString();

    const keys = { privateKey: privateWif, publicKey: pubkey };
    app.ports.receiveKeys.send(keys);
  });
});

app.ports.copy.subscribe(async () => {
  document.querySelector('#key').select();
  document.execCommand('copy');
});

app.ports.loadChart.subscribe(async () => {
  requestAnimationFrame(async () => {
    await loadTV();
  });
});

app.ports.openWindow.subscribe(async ({ url, width, height }) => {
  const specs = `top=${(window.screen.height - height) * 0.5},left=${(window.screen.width - width) * 0.5},width=${width},height=${height}`;
  window.open(url, '_blank', specs);
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
  app.ports.receiveWalletStatus.send(createResponseStatus());
});

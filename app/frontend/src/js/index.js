// Must import babel-polyfill only one time to support ES7!
import 'babel-polyfill';
import '../stylesheets/style.scss';

import ScatterJS from 'scatterjs-core';
import ScatterEOS from 'scatterjs-plugin-eosjs';
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
  rails_env: process.env.RAILS_ENV,
});

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
      return;
    }

    try {
      // Handle blockchain errors.
      const errObject = JSON.parse(err);
      console.log(errObject);
      if (errObject.code === 500 && errObject.error) {
        const { name, code, what } = errObject.error;
        app.ports.receivePushActionResponse.send(
          createPushActionReponse(code, action, name, what),
        );
      }
    } catch (e) {
      console.error(e);
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

function initScatter() {
  // const ScatterJS = await System.import('scatterjs-core'); // eslint-disable-line no-undef
  ScatterJS.plugins(new ScatterEOS());
  ScatterJS.scatter.connect('eoshub.io').then((connected) => {
    if (!connected) {
      console.error('Failed to connect with Scatter.');
      return;
    }

    const { scatter } = ScatterJS;

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
    window.ScatterJS = null;
  });
}

initScatter();

import _ from 'lodash';

import walletStatus from './constant';
import { scatterConfig } from './config';
import { getScatter, updateScatter } from './state';

// TODO(heejae): Make this file as an interface. It just deal with Scatter wallet for now.
function getWalletStatus() {
  const { scatterClient, account, authority } = getScatter();
  if (scatterClient) {
    if (account && authority) {
      return walletStatus.authenticated;
    }

    return walletStatus.loaded;
  }

  return walletStatus.notFound;
}

// NOTE(heejae): Please wrap async functions with try-catch when in usage.
// Async functions throw an exception when something goes wrong.
async function authenticateAccount() {
  const scatter = getScatter();
  const { chainId, blockchain } = scatterConfig;

  const { scatterClient } = scatter;
  if (!scatterClient) {
    throw new Error('Scatter must be installed to authenticate.');
  }

  if (scatterClient.identity) {
    await scatterClient.forgetIdentity();
  }

  const { accounts } = await scatterClient.getIdentity({
    accounts: [{ chainId, blockchain }],
  });
  const eosAccounts = _.filter(
    accounts,
    account => account.blockchain === 'eos',
  );
  if (_.isEmpty(eosAccounts)) {
    throw new Error('User must have at least one eos account.');
  }

  const { authority, name } = _.head(accounts);
  updateScatter({
    ...scatter,
    account: name,
    authority,
  });
}

async function invalidateAccount() {
  const scatter = getScatter();
  if (scatter.scatterClient && scatter.scatterClient.identity) {
    await scatter.scatterClient.forgetIdentity();
    updateScatter({
      ...scatter,
      account: '',
      autority: '',
    });
  }
}

export { getWalletStatus, authenticateAccount, invalidateAccount };

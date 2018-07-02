import _ from 'lodash';

import walletStatus from './constant';
import { scatterConfig } from './config';
import { getScatter, updateScatter } from './state';

// TODO(heejae): Make this file as an interface. It just deal with Scatter wallet for now.
function checkWalletStatus() {
  const { scatter, account, permission } = getScatter();
  if (scatter) {
    if (account && permission) {
      return walletStatus.authenticated;
    }

    return walletStatus.loaded;
  }

  return walletStatus.notFound;
}

// NOTE(heejae): Please wrap async functions with try-catch in usage.
// It throws an exception when something goes wrong.
async function authenticateAccount() {
  const scatter = getScatter();
  const { chainId, blockchain } = scatterConfig;

  if (scatter.scatter.identity) {
    await scatter.scatter.forgetIdentity();
  }

  const { accounts } = await scatter.scatter.getIdentity({ accounts: [{ chainId, blockchain }] });
  const eosAccounts = _.filter(
    accounts,
    account => account.blockchain === 'eos',
  );
  if (_.isEmpty(eosAccounts)) {
    throw new Error();
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
  if (scatter.scatter.identity) {
    await scatter.scatter.forgetIdentity();
  }

  updateScatter({
    ...scatter,
    account: '',
    autority: '',
  });
}

export { checkWalletStatus, authenticateAccount, invalidateAccount };

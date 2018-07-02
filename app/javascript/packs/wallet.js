import walletStatus from './constant';
import { getScatter } from './state';

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
};

export { checkWalletStatus };

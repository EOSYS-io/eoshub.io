import { getScatter } from './state';
import { walletStatus } from './constant';

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

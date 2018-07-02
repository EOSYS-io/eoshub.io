import Elm from '../Main'; // eslint-disable-line import/no-unresolved
import { checkWalletStatus } from './wallet';

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

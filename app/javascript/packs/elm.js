// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import Elm from '../Main'
import { checkWalletStatus } from './wallet'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-target')

  if (!target) {
    return;  
  }

  const app = Elm.Main.embed(target);

  app.ports.checkWalletStatus.subscribe(() => {
    const walletStatus = checkWalletStatus();
    app.ports.receiveWalletStatus.send(walletStatus);
  });
})

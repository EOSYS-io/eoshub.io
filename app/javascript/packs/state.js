let walletStates = {
  scatter: {
    scatter: null,
    eosjs: null,
    account: '',
    permission: '',
  },
};

function getScatter() {
  return walletStates.scatter;
}

function updateScatter(newScatter) {
  walletStates = {
    ...walletStates,
    scatter: newScatter,
  };
}

export { getScatter, updateScatter };
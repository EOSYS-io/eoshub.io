let walletStates = {
  scatter: {
    scatterClient: null,
    eosjsClient: null,
    account: '',
    authority: '',
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

let state = {
  scatter: {
    scatterClient: null,
    eosjsClient: null,
    account: '',
    authority: '',
  },
};

function getScatter() {
  return state.scatter;
}

function updateScatter(newScatter) {
  state = {
    ...state,
    scatter: newScatter,
  };
}


export {
  getScatter,
  updateScatter,
};

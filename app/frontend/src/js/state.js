let state = {
  scatter: {
    scatterClient: null,
    eosjsClient: null,
    account: '',
    authority: '',
  },
  elm: null,
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

function getElm() {
  return state.elm;
}

function updateElm(elm) {
  state = {
    ...state,
    elm,
  };
}

export {
  getElm,
  getScatter,
  updateElm,
  updateScatter,
};

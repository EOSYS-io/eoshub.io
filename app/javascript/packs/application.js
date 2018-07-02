// import Eos from 'eosjs';
import { getScatter, updateScatter } from './state';

document.addEventListener('scatterLoaded', () => {
  const scatter = window.scatter;
  // Setting window.scatter to null is recommended.
  window.scatter = null;
  const stateScatter = getScatter();
  updateScatter({
    ...stateScatter,
    scatter,
  });
});

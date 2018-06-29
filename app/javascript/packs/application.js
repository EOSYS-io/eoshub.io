document.addEventListener('scatterLoaded', scatterExtension => {
  const scatter = window.scatter;
  window.scatter = null;
  scatter.requireVersion(3.0);
})
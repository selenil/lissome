export function createLissomeHook(modules) {
  return {
    mounted() {
      modules[this.el.dataset.name]?.(this);
    },
  };
}

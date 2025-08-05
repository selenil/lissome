export function createLissomeHook(modules) {
  return {
    mounted() {
      const entryFn = this.el.dataset.entryfn
      modules[this.el.dataset.name][entryFn]?.(this)
    },
  }
}

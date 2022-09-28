export default {
  isAllLoaded: false,
  mounted() {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && this.isAllLoaded === false) {
          this.pushEvent("load_more_tracks", {})
        }
      },
      { rootMargin: "0px", threshold: 1.0, }
    );
    this.observer.observe(this.el)
    this.handleEvent("all_items_loaded", data => {
      this.isAllLoaded = true
    })
  },
  beforeDestroy() {
    this.observer.unobserve(this.el)
  }
}

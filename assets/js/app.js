// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
//import "../css/app.css"
// If you want to use Phoenix channels, run `mix help phx.gen.channel`

// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

import "mdn-polyfills/Object.assign"
import "mdn-polyfills/CustomEvent"
import "mdn-polyfills/String.prototype.startsWith"
import "mdn-polyfills/Array.from"
import "mdn-polyfills/Array.prototype.find"
import "mdn-polyfills/Array.prototype.some"
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "mdn-polyfills/Node.prototype.remove"
import "child-replace-with-polyfill"
import "url-search-params-polyfill"
import "formdata-polyfill"
import "classlist-polyfill"
import "new-event-polyfill"
import "@webcomponents/template"
import "shim-keyboard-event-key"
import "core-js/features/set"
import "core-js/features/url"

import topbar from "../vendor/topbar"

window.spotifyReady = false
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let isAllLoaded = false
let hooks = {
  Playback2312: {
    deviceId: null,
    player: null,
    initializePlayer() {
      this.player = new Spotify.Player({
        name: "ExPotify",
        getOAuthToken: (cb) => {
          cb(this.token)
        }
      })

      window.addEventListener("keyup", (event) => {
        switch (event.keyCode) {
          case 32:
            this.player.togglePlay()
          default:
            console.log("something else..")
        }
      })

      this.player.addListener("ready", ({ device_id }) => {
        this.deviceId = device_id
        this.pushEvent("init_device", { device_id })
      })

      this.player.addListener('initialization_error', ({ message }) => {
        console.error(message);
      })

      this.player.addListener('authentication_error', ({ message }) => {
        console.error(message);
      })

      this.player.addListener('account_error', ({ message }) => {
        console.error(message);
      })

      this.player.addListener('playback_error', ({ message }) => {
        console.error(message);
      })
    },
    mounted() {
      this.handleEvent("init_token", ({ token }) => {
        this.token = token
        if (window.spotifyReady) {
            console.log('222313512316')
            this.initializePlayer()
            this.player.connect()
        }
      })
    },
    updated() {

    }
  },
  Scroll: {
    mounted() {
      this.observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting && isAllLoaded === false) {
            this.pushEvent("load_more", {})
          }
        },
        { rootMargin: "0px", threshold: 1.0, }
      );

      this.observer.observe(this.el);
      this.handleEvent("all_loaded", data => {
        isAllLoaded = true
      })
    },
    beforeDestroy() {
      this.observer.unobserve(this.el)
    }
  },
}

let liveSocket = new LiveSocket("/live", Socket, {hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

window.addEventListener("phx:page-loading-start", () => {
  if(!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 200)
  }
})

window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled)
  topBarScheduled = undefined
  topbar.hide()
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.onSpotifyWebPlaybackSDKReady = () => {
  window.spotifyReady = true
}
console.log('tekjhsdas')

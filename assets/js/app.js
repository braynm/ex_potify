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

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let isAllLoaded = false
let hooks = {
  Scroll: {
    mounted() {
      this.observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting && isAllLoaded === false) {
            console.log('testing....')
            this.pushEvent("load_more", {})
          }
        },
        { rootMargin: "0px", threshold: 1.0, }
      );

      this.observer.observe(this.el);
      this.handleEvent("all_loaded", data => {
        isAllLoaded = true
      })
    }
  },
  beforeDestroy() {
    this.observer.unobserve(this.el)
  }
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
  console.log('hey..asdsadasd')
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
  const token = 'BQCh27vuG3MFcnQyAuBBxL0iqBb2gKrybi6_dEYdoVASE_n-h7s6nRUR3GN1rKnsKSMAciDPY8x6mmKuEUJDEYGZ7EUsZt52M85nymSH1365GW9f-p1Rwq8pg5gO9m9q3j8KW7FRekUIgOFXZ736e8ya7F2Id6rvtFjdGXyuFcgBDpDcOebyPy3E3_7LvlYc8Gu9XTEu58ceJXShQDaxdisIuN_RnDKJu0slreby2QaRh7S9nb9SV9Avm-KzpWrhE_LRLNr0Zg6S_JO_i-UeG7l3kTeKbrU-SL_a5lxB';
  const player = new Spotify.Player({
    name: 'ExPotify',
    getOAuthToken: cb => {
     cb(token);
    },
    volume: 1
  });


  let togglePlay = false
  player.addListener('initialization_error', ({ message }) => {
    console.error(message);
  });

  player.addListener('authentication_error', ({ message }) => {
    console.error(message);
  });

  player.addListener('account_error', ({ message }) => {
    console.error(message);
  });

  player.addListener('playback_error', ({ message }) => {
    console.error(message);
  });

  function millisToMinutesAndSeconds(millis) {
    const minutes = Math.floor(millis / 60000);
    const seconds = ((millis % 60000) / 1000).toFixed(0);
    return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
  }

  const track = document.getElementById('track')
  const currentDuration = document.getElementById('currentDuration')
  const totalDuration = document.getElementById('duration')
  let progressInPercentage = 0
  let progress = 0
  let timing = setInterval(() => {}, 1000)
  player.addListener('player_state_changed', ({
   position,
    duration,
    track_window: { current_track },
    paused
  }) => {
    console.log('Currently Playing', current_track);
    console.log('Position in Song', position);
    console.log('Duration of Song', duration);
    totalDuration.textContent = millisToMinutesAndSeconds(duration)

    track.max = duration
    progressPerSec = duration / 1000

    clearInterval(timing)

    if (paused) {
      togglePlay = false
    } else {
      timing  = setInterval(() => {
        track.value = position !== 0 ? position : progressPerSec
        console.log({ position, duration, currentPos: progressPerSec })
        currentDuration.textContent = millisToMinutesAndSeconds(progressPerSec)

        progressPerSec = position !== 0 ? position + 1000 : progressPerSec + 1000
        position = 0

      }, 1000)
      player.resume()
    }
  });


  player.connect()

  player.addListener('ready', ({ device_id }) => {
    console.log('Ready with Device ID', device_id);
  });
}



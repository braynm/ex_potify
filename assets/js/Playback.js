function millisToMinutesAndSeconds(millis) {
  const minutes = Math.floor(millis / 60000);
  const seconds = ((millis % 60000) / 1000).toFixed(0);
  return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
}


export default {
  deviceId: null,
  player: null,
  progress: 0,
  trackTimer: setInterval(() => {}, 1000),
  trackId: null,
  initializePlayer() {
    const currentDuration = document.getElementById('currentDuration')
    const track = document.getElementById('track')
    const totalDuration = document.getElementById('duration')

    this.player = new Spotify.Player({
      name: "ExPotify",
      getOAuthToken: (cb) => {
        cb(this.token)
      }
    })

    window.addEventListener("keyup", (event) => {
      switch (event.keyCode) {
        case 32:
          console.log(event.preventDefault)
          this.player.togglePlay()
          event.preventDefault()
        default:
      }

    })

    this.player.addListener("ready", ({ device_id }) => {
      this.deviceId = device_id
      this.pushEvent("init_device", { device_id })
    })

    this.player.addListener('initialization_error', ({ message }) => {
      console.error(message)
    })

    this.player.addListener('authentication_error', ({ message }) => {
      console.error(message)
    })

    this.player.addListener('account_error', ({ message }) => {
      console.error(message)
    })

    this.player.addListener('playback_error', ({ message }) => {
      console.error(message)
    })

    this.player.addListener('player_state_changed', ({ paused, position, duration, ...others }) => {
      let progressPerSec = duration / 1000
      totalDuration.textContent = millisToMinutesAndSeconds(duration)
      clearInterval(this.trackTimer)
      const trackObj = others.track_window.current_track
      const trackId = trackObj.id
      if (trackId !== this.trackId) {
        const img = trackObj.album ? trackObj.album.images.find(img => img.size === 'SMALL') : { url: '' }
        this.trackId = trackId
        const payload = {
          id: trackObj.id,
          name: trackObj.name,
          artist: trackObj.artists[0].name,
          uri: trackObj.uri,
          img: img.url
        }
        this.pushEventTo("#playback-control", "select_track", payload, (reply, ref) => {})
        const trackItems = document.getElementsByClassName('track')
        for (let index = 0; index < trackItems.length; index++) {
          trackItems.item(index).classList.remove('track-active')
        }

        const selectedTrack = document.getElementById(`track-${trackObj.id}`)
        if (selectedTrack) {
          selectedTrack.classList.add('track-active')
        }
      }

      if (paused) {
      } else {
        this.trackTimer = setInterval(() => {
          track.value = position !== 0 ? position : progressPerSec
          track.max = duration
          currentDuration.textContent = millisToMinutesAndSeconds(progressPerSec)
          progressPerSec = position !== 0 ? position + 1000 : progressPerSec + 1000
          position = 0
        }, 1000)
      }
    })
  },
  mounted() {
    this.handleEvent("init_token", ({ token }) => {
      this.token = token
      if (window.spotifyReady) {
        this.initializePlayer()
        this.player.connect()
      }
    })

    this.handleEvent("player_state_changed", (params => {
      this.player.getCurrentState().then(console.log)
      if (params.paused) {
        this.player.pause()
      } else {
        this.player.resume()
      }
    }))
  }
}

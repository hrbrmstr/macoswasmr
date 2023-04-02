const msg = document.getElementById("message")
const shw = document.getElementById("show")

msg.innerHTML = `<p></p>`
shw.innerText = ``

msg.innerHTML += `<p>we are isolated ${crossOriginIsolated}</p>`
msg.innerHTML += `<p>importing webr</p>`

import { WebR } from '/webr.mjs'

msg.innerHTML += `<p>webr theoretically imported</p>`
msg.innerHTML += `<p>init webr</p>`

const webR = new WebR({
  baseUrl: "/",
  serviceWorkerUrl: "/"
});

msg.innerHTML += `<p>webr is in theory imported</p>`

shw.innerText += `webR keys before: ${JSON.stringify(Object.keys(webR).join("\n"))}`

await webR.init();

shw.innerText += `webR keys after: ${JSON.stringify(Object.keys(webR).join("\n"))}`

import { createApp } from "vue";
import PrimeVue from "primevue/config";
import Aura from "@primevue/themes/aura";
import "primeicons/primeicons.css";
import "@fontsource/ibm-plex-sans/400.css";
import "@fontsource/ibm-plex-sans/500.css";
import "@fontsource/ibm-plex-sans/600.css";
import "@fontsource/ibm-plex-serif/600.css";
import App from "./App.vue";
import { router } from "./router";
import "./styles.css";

const app = createApp(App);
app.use(router);
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
      // Hub = light Aura; Survival (.skin-doomsday) = dark Aura
      darkModeSelector: ".skin-doomsday",
      cssLayer: false,
    },
  },
});
app.mount("#app");

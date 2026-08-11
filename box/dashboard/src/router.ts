import { createRouter, createWebHistory } from "vue-router";
import HomeView from "./views/HomeView.vue";
import SetupView from "./views/SetupView.vue";
import SettingsView from "./views/SettingsView.vue";
import LoginView from "./views/LoginView.vue";
import { fetchStatus } from "./api";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", name: "home", component: HomeView, meta: { auth: true } },
    { path: "/setup", name: "setup", component: SetupView },
    { path: "/login", name: "login", component: LoginView },
    { path: "/settings", name: "settings", component: SettingsView, meta: { auth: true } },
  ],
});

router.beforeEach(async (to) => {
  if (to.name === "setup" || to.name === "login") return true;
  try {
    const s = await fetchStatus();
    if (!s.setup_complete && to.name !== "setup") {
      return { name: "setup" };
    }
    if (s.setup_complete && s.auth_required && !s.authenticated && to.meta.auth) {
      return { name: "login", query: { next: to.fullPath } };
    }
  } catch {
    /* API down — let the view show the error */
  }
  return true;
});

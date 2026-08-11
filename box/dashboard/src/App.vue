<script setup lang="ts">
import { computed, onMounted, watch } from "vue";
import { RouterLink, RouterView, useRoute, useRouter } from "vue-router";
import Button from "primevue/button";
import { detectSkin, skinClass, type Skin } from "./skin";
import { useI18n } from "./i18n";
import { useBoxStatus } from "./useBoxStatus";
import { postLogout } from "./api";

const route = useRoute();
const router = useRouter();
const skin = computed<Skin>(() => detectSkin());
const { t } = useI18n();
const { status, refreshStatus } = useBoxStatus();

const brand = computed(() =>
  skin.value === "doomsday" ? t.value("brandSurvival") : t.value("brandHub"),
);
const modeLabel = computed(() =>
  skin.value === "doomsday" ? t.value("modeSurvival") : t.value("modeHub"),
);

const claimed = computed(() => Boolean(status.value?.setup_complete));
const authed = computed(() => Boolean(status.value?.authenticated));
const claimShell = computed(
  () => route.path === "/setup" || status.value?.setup_complete === false,
);

onMounted(async () => {
  document.documentElement.classList.add(skinClass(skin.value));
  await refreshStatus();
});

watch(skin, (next, prev) => {
  document.documentElement.classList.remove(skinClass(prev));
  document.documentElement.classList.add(skinClass(next));
});

async function signOut() {
  await postLogout();
  await refreshStatus();
  await router.push("/login");
}
</script>

<template>
  <div class="shell" :class="{ 'shell-claim': claimShell && !claimed }">
    <header class="shell-header">
      <p class="brand">{{ brand }}</p>
      <span class="mode-pill">{{ modeLabel }}</span>
    </header>

    <nav v-if="claimed && authed" class="top" aria-label="Primary">
      <RouterLink to="/">{{ t("navHome") }}</RouterLink>
      <RouterLink to="/settings">{{ t("navSettings") }}</RouterLink>
      <Button type="button" size="small" severity="secondary" :label="t('signOut')" @click="signOut" />
    </nav>

    <RouterView />
  </div>
</template>

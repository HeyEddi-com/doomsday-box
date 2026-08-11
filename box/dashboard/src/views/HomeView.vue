<script setup lang="ts">
import { computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import Message from "primevue/message";
import { detectSkin } from "../skin";
import { useI18n } from "../i18n";
import { refreshStatus, useBoxStatus } from "../useBoxStatus";

const router = useRouter();
const skin = detectSkin();
const { t } = useI18n();
const { status, error, loading } = useBoxStatus();

const title = computed(() =>
  skin === "doomsday" ? t.value("homeTitleSurvival") : t.value("homeTitleHub"),
);
const lead = computed(() =>
  skin === "doomsday" ? t.value("homeLeadSurvival") : t.value("homeLeadHub"),
);
const modeLabel = computed(() =>
  skin === "doomsday" ? t.value("modeSurvival") : t.value("modeHub"),
);

onMounted(async () => {
  await refreshStatus();
  if (status.value && !status.value.setup_complete) {
    await router.replace("/setup");
  }
});
</script>

<template>
  <section class="claim-enter">
    <h1>{{ title }}</h1>
    <p class="lead">{{ lead }}</p>

    <Message v-if="error" severity="error" :closable="false">
      {{ t("homeApiError") }}: {{ error }}
    </Message>

    <div v-else-if="loading && !status" class="panel">
      <p class="muted" style="margin: 0">{{ t("homeLoading") }}</p>
    </div>

    <div v-else-if="status" class="panel">
      <h2>{{ status.product }}</h2>
      <p class="muted" style="margin-bottom: 0.35rem">v{{ status.version }}</p>
      <div class="status-line">
        <span class="pill">{{ t("statusArch") }} {{ status.arch }}</span>
        <span class="pill">
          {{ t("statusSetup") }}
          {{
            status.setup_complete
              ? t("statusSetupDone")
              : t("statusSetupNeeded")
          }}
        </span>
        <span class="pill">{{ t("statusMode") }} {{ modeLabel }}</span>
      </div>
      <p class="muted" style="margin: 0.75rem 0 0">
        {{ t("statusNames") }}: {{ status.hostnames.join(" · ") }}
      </p>
    </div>
  </section>
</template>

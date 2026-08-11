<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import Accordion from "primevue/accordion";
import AccordionPanel from "primevue/accordionpanel";
import AccordionHeader from "primevue/accordionheader";
import AccordionContent from "primevue/accordioncontent";
import Select from "primevue/select";
import Message from "primevue/message";
import { detectSkin } from "../skin";
import { useI18n, type Locale } from "../i18n";
import { fetchOperatorStatus, type OperatorStatus } from "../api";

const skin = detectSkin();
const { t, locale, setLocale } = useI18n();
const op = ref<OperatorStatus | null>(null);
const opError = ref("");

const lead = computed(() =>
  skin === "doomsday"
    ? t.value("settingsLeadSurvival")
    : t.value("settingsLeadHub"),
);

const localeOptions = computed(() => [
  { label: t.value("localeEn"), value: "en" as Locale },
  { label: t.value("localeEs"), value: "es" as Locale },
]);

onMounted(async () => {
  try {
    op.value = await fetchOperatorStatus();
  } catch (e) {
    opError.value = e instanceof Error ? e.message : "operator status unavailable";
  }
});
</script>

<template>
  <section class="claim-enter">
    <h1>{{ t("settingsTitle") }}</h1>
    <p class="lead">{{ lead }}</p>

    <div class="panel">
      <h2>{{ t("settingsUpdates") }}</h2>
      <p class="muted" style="margin: 0">{{ t("settingsUpdatesBody") }}</p>
    </div>

    <div class="panel">
      <h2>{{ t("settingsPower") }}</h2>
      <p class="muted" style="margin: 0">{{ t("settingsPowerBody") }}</p>
    </div>

    <Accordion class="panel" :value="[]" multiple>
      <AccordionPanel value="advanced">
        <AccordionHeader>{{ t("advanced") }}</AccordionHeader>
        <AccordionContent>
          <p class="advanced-note">{{ t("advancedHint") }}</p>
          <p class="advanced-note">{{ t("advancedNever") }}</p>

          <div class="field">
            <label for="locale-settings">{{ t("localeLabel") }}</label>
            <Select
              input-id="locale-settings"
              :model-value="locale"
              :options="localeOptions"
              option-label="label"
              option-value="value"
              @update:model-value="(v: Locale) => setLocale(v)"
            />
          </div>

          <h2 style="margin-top: 1.25rem">{{ t("remoteShell") }}</h2>
          <Message v-if="opError" severity="warn" :closable="false">{{ opError }}</Message>
          <p v-else class="muted">
            <span class="pill">{{
              op?.remote_admin_enabled ? t("remoteOn") : t("remoteOff")
            }}</span>
          </p>
          <p class="advanced-note">{{ t("remoteHint") }}</p>

          <p class="advanced-note" style="margin-top: 1rem">{{ t("founderTips") }}</p>
          <div class="mono-block">
            doombox-enable-operator --pubkey '…' --enable-ssh<br />
            doombox-disable-remote-admin<br />
            doombox-enable-claim-kiosk<br />
            doombox-install-rootless-podman<br />
            doombox-show-setup-pin (local console only)<br />
            doombox-factory-reset-claim (local console only; refuses SSH)
          </div>
        </AccordionContent>
      </AccordionPanel>
    </Accordion>
  </section>
</template>

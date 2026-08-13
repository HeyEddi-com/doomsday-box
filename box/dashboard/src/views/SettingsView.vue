<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import Accordion from "primevue/accordion";
import AccordionPanel from "primevue/accordionpanel";
import AccordionHeader from "primevue/accordionheader";
import AccordionContent from "primevue/accordioncontent";
import Select from "primevue/select";
import Message from "primevue/message";
import Button from "primevue/button";
import ToggleSwitch from "primevue/toggleswitch";
import ProgressSpinner from "primevue/progressspinner";
import { detectSkin } from "../skin";
import { useI18n, type Locale } from "../i18n";
import {
  fetchOperatorStatus,
  fetchRemoteDesktop,
  setRemoteDesktop,
  type OperatorStatus,
  type RemoteDesktopStatus,
} from "../api";

const skin = detectSkin();
const { t, locale, setLocale } = useI18n();
const op = ref<OperatorStatus | null>(null);
const opError = ref("");
const desktop = ref<RemoteDesktopStatus | null>(null);
const desktopError = ref("");
const desktopLoading = ref(true);
/** True while POST is in flight or while waiting for container Ready after enable. */
const desktopBusy = ref(false);
let pollTimer: ReturnType<typeof setInterval> | null = null;

const lead = computed(() =>
  skin === "doomsday"
    ? t.value("settingsLeadSurvival")
    : t.value("settingsLeadHub"),
);

const localeOptions = computed(() => [
  { label: t.value("localeEn"), value: "en" as Locale },
  { label: t.value("localeEs"), value: "es" as Locale },
]);

const isStarting = computed(
  () =>
    Boolean(desktop.value?.desired) &&
    (desktopBusy.value || !desktop.value?.running),
);

const isStopping = computed(
  () =>
    Boolean(desktop.value) &&
    !desktop.value!.desired &&
    (desktopBusy.value || desktop.value!.running),
);

const statusPill = computed(() => {
  if (!desktop.value) return t.value("remoteDesktopOff");
  if (isStopping.value) return t.value("remoteDesktopStopping");
  if (desktop.value.running) return t.value("remoteDesktopRunning");
  if (isStarting.value) return t.value("remoteDesktopStarting");
  return t.value("remoteDesktopStopped");
});

async function refreshDesktop() {
  desktop.value = await fetchRemoteDesktop();
}

function stopPoll() {
  if (pollTimer) {
    clearInterval(pollTimer);
    pollTimer = null;
  }
}

function startPollUntilSettled(wantRunning: boolean) {
  stopPoll();
  let tries = 0;
  pollTimer = setInterval(() => {
    void (async () => {
      tries += 1;
      try {
        await refreshDesktop();
        const done = wantRunning
          ? Boolean(desktop.value?.running)
          : !desktop.value?.running;
        if (done || tries >= 120) {
          // ~4 min at 2s interval
          desktopBusy.value = false;
          stopPoll();
        }
      } catch {
        if (tries >= 120) {
          desktopBusy.value = false;
          stopPoll();
        }
      }
    })();
  }, 2000);
}

onMounted(async () => {
  try {
    op.value = await fetchOperatorStatus();
  } catch (e) {
    opError.value = e instanceof Error ? e.message : "operator status unavailable";
  }
  try {
    await refreshDesktop();
    if (desktop.value?.desired && !desktop.value.running) {
      desktopBusy.value = true;
      startPollUntilSettled(true);
    } else if (!desktop.value?.desired && desktop.value?.running) {
      desktopBusy.value = true;
      startPollUntilSettled(false);
    }
  } catch (e) {
    desktopError.value =
      e instanceof Error ? e.message : "remote desktop status unavailable";
  } finally {
    desktopLoading.value = false;
  }
});

onUnmounted(() => stopPoll());

async function onRefreshDesktop() {
  try {
    await refreshDesktop();
    if (
      (desktop.value?.desired && desktop.value.running) ||
      (!desktop.value?.desired && !desktop.value?.running)
    ) {
      desktopBusy.value = false;
      stopPoll();
    }
  } catch (e) {
    desktopError.value =
      e instanceof Error ? e.message : "remote desktop status unavailable";
  }
}

async function toggleDesktop(enabled: boolean) {
  desktopError.value = "";
  desktopBusy.value = true;

  // Optimistic UI so the toggle and pills match immediately
  if (desktop.value) {
    desktop.value = {
      ...desktop.value,
      desired: enabled,
      running: enabled ? desktop.value.running : false,
      message: enabled
        ? t.value("remoteDesktopStartingBody")
        : t.value("remoteDesktopBusy"),
    };
  }

  try {
    desktop.value = await setRemoteDesktop(enabled);
    if (enabled) {
      if (desktop.value.running) {
        desktopBusy.value = false;
        stopPoll();
      } else {
        startPollUntilSettled(true);
      }
    } else if (desktop.value.running) {
      startPollUntilSettled(false);
    } else {
      desktopBusy.value = false;
      stopPoll();
    }
  } catch (e) {
    desktopError.value = e instanceof Error ? e.message : "update failed";
    desktopBusy.value = false;
    stopPoll();
    try {
      await refreshDesktop();
    } catch {
      /* keep error */
    }
  }
}
</script>

<template>
  <section class="claim-enter">
    <h1>{{ t("settingsTitle") }}</h1>
    <p class="lead">{{ lead }}</p>

    <div class="panel">
      <h2>{{ t("remoteDesktop") }}</h2>
      <p class="muted">{{ t("remoteDesktopLead") }}</p>
      <Message severity="info" :closable="false" class="desktop-protect">
        {{ t("remoteDesktopProtected") }}
      </Message>
      <Message v-if="desktopError" severity="warn" :closable="false">{{ desktopError }}</Message>
      <div v-if="desktopLoading" class="desktop-loading" role="status" aria-live="polite">
        <ProgressSpinner
          style="width: 2rem; height: 2rem"
          stroke-width="6"
          animation-duration="0.9s"
        />
        <div>
          <p class="desktop-loading-title">{{ t("remoteDesktopLoading") }}</p>
        </div>
      </div>
      <template v-else-if="desktop">
        <div class="desktop-toggle-row">
          <label for="remote-desktop-toggle">{{ t("remoteDesktopEnableLabel") }}</label>
          <ToggleSwitch
            input-id="remote-desktop-toggle"
            :model-value="desktop.desired"
            :disabled="desktopBusy"
            @update:model-value="(v: boolean) => toggleDesktop(v)"
          />
        </div>

        <div
          v-if="isStarting || isStopping"
          class="desktop-loading"
          role="status"
          aria-live="polite"
        >
          <ProgressSpinner
            style="width: 2rem; height: 2rem"
            stroke-width="6"
            animation-duration="0.9s"
          />
          <div>
            <p class="desktop-loading-title">
              {{ isStopping ? t("remoteDesktopStopping") : t("remoteDesktopStarting") }}
            </p>
            <p class="advanced-note" style="margin: 0">
              {{ isStopping ? t("remoteDesktopStoppingBody") : t("remoteDesktopStartingBody") }}
            </p>
          </div>
        </div>

        <p class="muted">
          <span class="pill">{{
            desktop.desired ? t("remoteDesktopOn") : t("remoteDesktopOff")
          }}</span>
          <span class="pill" style="margin-left: 0.5rem">{{ statusPill }}</span>
          <span v-if="desktop.docker_control" class="pill" style="margin-left: 0.5rem">{{
            t("remoteDesktopControlOn")
          }}</span>
        </p>
        <p v-if="!isStarting && !isStopping" class="advanced-note">{{ desktop.message }}</p>
        <div style="display: flex; flex-wrap: wrap; gap: 0.75rem; margin-top: 0.75rem">
          <a
            class="desktop-open-link"
            href="/desktop/"
            target="_blank"
            rel="noopener noreferrer"
            :aria-disabled="!desktop.running"
            :class="{ 'is-disabled': !desktop.running }"
            @click="(e) => { if (!desktop?.running) e.preventDefault(); }"
          >
            {{ t("remoteDesktopOpen") }}
          </a>
          <Button
            v-if="isStarting || isStopping"
            severity="secondary"
            :label="t('remoteDesktopRefresh')"
            @click="onRefreshDesktop"
          />
        </div>
        <p
          v-if="!desktop.running && !isStarting && !isStopping"
          class="advanced-note"
          style="margin-top: 0.75rem"
        >
          {{ t("remoteDesktopOpenHint") }}
        </p>
      </template>
    </div>

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
            doombox-enable-remote-desktop<br />
            doombox-disable-remote-desktop<br />
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

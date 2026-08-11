<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import Button from "primevue/button";
import InputText from "primevue/inputtext";
import Password from "primevue/password";
import Select from "primevue/select";
import Message from "primevue/message";
import Accordion from "primevue/accordion";
import AccordionPanel from "primevue/accordionpanel";
import AccordionHeader from "primevue/accordionheader";
import AccordionContent from "primevue/accordioncontent";
import { postSetup } from "../api";
import { detectSkin } from "../skin";
import { useI18n, type Locale } from "../i18n";
import { refreshStatus, useBoxStatus } from "../useBoxStatus";

const router = useRouter();
const skin = detectSkin();
const { t, locale, setLocale } = useI18n();
const { status } = useBoxStatus();

const claimCode = ref("");
const password = ref("");
const confirm = ref("");
const networkMode = ref("lan");
const busy = ref(false);
const message = ref("");
const error = ref("");
const locked = ref(false);

const title = computed(() =>
  skin === "doomsday" ? t.value("setupTitleSurvival") : t.value("setupTitleHub"),
);
const lead = computed(() =>
  skin === "doomsday" ? t.value("setupLeadSurvival") : t.value("setupLeadHub"),
);

const networkOptions = computed(() => [
  { label: t.value("networkLan"), value: "lan" },
  { label: t.value("networkBridge"), value: "bridge" },
  { label: t.value("networkAp"), value: "ap" },
]);

const localeOptions = computed(() => [
  { label: t.value("localeEn"), value: "en" as Locale },
  { label: t.value("localeEs"), value: "es" as Locale },
]);

onMounted(async () => {
  await refreshStatus();
  if (status.value?.setup_complete || status.value?.setup_open === false) {
    locked.value = true;
    error.value = t.value("claimedLocked");
  }
});

async function submit() {
  error.value = "";
  message.value = "";
  if (claimCode.value.trim().length < 6) {
    error.value = t.value("errClaimShort");
    return;
  }
  if (password.value.length < 8) {
    error.value = t.value("errPasswordShort");
    return;
  }
  if (password.value !== confirm.value) {
    error.value = t.value("errPasswordMatch");
    return;
  }
  busy.value = true;
  try {
    const res = await postSetup({
      claim_code: claimCode.value.trim().toUpperCase(),
      admin_password: password.value,
      network_mode: networkMode.value,
    });
    message.value = res.message;
    await refreshStatus();
    await router.push("/");
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Setup failed";
  } finally {
    busy.value = false;
  }
}
</script>

<template>
  <section class="claim-enter">
    <h1>{{ title }}</h1>
    <p class="lead">{{ lead }}</p>

    <Message v-if="error" severity="error" :closable="false">{{ error }}</Message>
    <Message v-else-if="message" severity="success" :closable="false">{{ message }}</Message>

    <div class="panel stack">
      <div class="field">
        <label for="claim">{{ t("claimLabel") }}</label>
        <InputText
          id="claim"
          v-model="claimCode"
          class="claim-input"
          autocomplete="one-time-code"
          autocapitalize="characters"
          spellcheck="false"
          :disabled="locked"
          :placeholder="t('claimPlaceholder')"
        />
      </div>

      <div class="field">
        <label for="pw">{{ t("passwordLabel") }}</label>
        <Password
          input-id="pw"
          v-model="password"
          :feedback="false"
          toggle-mask
          :disabled="locked"
          fluid
          autocomplete="new-password"
        />
      </div>

      <div class="field">
        <label for="pw2">{{ t("confirmLabel") }}</label>
        <Password
          input-id="pw2"
          v-model="confirm"
          :feedback="false"
          toggle-mask
          :disabled="locked"
          fluid
          autocomplete="new-password"
        />
      </div>

      <div class="row">
        <Button
          type="button"
          :disabled="busy || locked"
          :label="busy ? t('claiming') : t('claimCta')"
          @click="submit"
        />
      </div>
    </div>

    <Accordion class="panel" :value="[]" multiple>
      <AccordionPanel value="advanced">
        <AccordionHeader>{{ t("advanced") }}</AccordionHeader>
        <AccordionContent>
          <p class="advanced-note">{{ t("advancedHint") }}</p>

          <div class="field">
            <label for="locale">{{ t("localeLabel") }}</label>
            <Select
              input-id="locale"
              :model-value="locale"
              :options="localeOptions"
              option-label="label"
              option-value="value"
              @update:model-value="(v: Locale) => setLocale(v)"
            />
          </div>

          <div class="field" style="margin-top: 0.85rem">
            <label for="mode">{{ t("networkMode") }}</label>
            <Select
              input-id="mode"
              v-model="networkMode"
              :options="networkOptions"
              option-label="label"
              option-value="value"
              :disabled="locked"
            />
          </div>

          <p class="advanced-note" style="margin-top: 1rem">{{ t("founderTips") }}</p>
          <div class="mono-block">
            sudo doombox-show-setup-pin<br />
            sudo doombox-factory-reset-claim<br />
            cat $STORAGE/compose/SETUP_PIN.txt
          </div>
          <p class="advanced-note" style="margin-top: 0.75rem">
            Factory reset is local console only (refuses SSH). There is no reset in this web UI or API.
          </p>
        </AccordionContent>
      </AccordionPanel>
    </Accordion>
  </section>
</template>

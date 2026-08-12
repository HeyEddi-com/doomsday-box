<script setup lang="ts">
import { computed, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import Button from "primevue/button";
import Password from "primevue/password";
import Message from "primevue/message";
import { postLogin } from "../api";
import { useI18n } from "../i18n";
import { refreshStatus } from "../useBoxStatus";
import { safeNextPath } from "../nextPath";

const router = useRouter();
const route = useRoute();
const { t } = useI18n();
const password = ref("");
const busy = ref(false);
const error = ref("");

const nextPath = computed(() => safeNextPath(route.query.next));
const afterDesktop = computed(() => nextPath.value?.startsWith("/desktop") ?? false);

async function submit() {
  error.value = "";
  busy.value = true;
  try {
    await postLogin(password.value);
    await refreshStatus();
    const next = nextPath.value;
    if (next?.startsWith("/desktop")) {
      window.location.assign(next);
      return;
    }
    await router.push(next || "/");
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Sign-in failed";
  } finally {
    busy.value = false;
  }
}
</script>

<template>
  <section class="claim-enter">
    <h1>{{ t("loginTitle") }}</h1>
    <p class="lead">{{ afterDesktop ? t("loginLeadDesktop") : t("loginLead") }}</p>
    <Message v-if="error" severity="error" :closable="false">{{ error }}</Message>
    <div class="panel stack">
      <div class="field">
        <label for="login-pw">{{ t("passwordLabel") }}</label>
        <Password
          input-id="login-pw"
          v-model="password"
          :feedback="false"
          toggle-mask
          fluid
          autocomplete="current-password"
          @keyup.enter="submit"
        />
      </div>
      <div class="row">
        <Button
          type="button"
          :disabled="busy || password.length < 1"
          :label="busy ? t('signingIn') : t('signIn')"
          @click="submit"
        />
      </div>
    </div>
  </section>
</template>

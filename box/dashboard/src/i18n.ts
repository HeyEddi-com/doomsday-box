import { computed, ref } from "vue";

export type Locale = "en" | "es";

const STORAGE_KEY = "doombox.locale";

function readLocale(): Locale {
  try {
    const v = localStorage.getItem(STORAGE_KEY);
    if (v === "es" || v === "en") return v;
  } catch {
    /* ignore */
  }
  return "en";
}

export const locale = ref<Locale>(readLocale());

export function setLocale(next: Locale) {
  locale.value = next;
  try {
    localStorage.setItem(STORAGE_KEY, next);
  } catch {
    /* ignore */
  }
}

const messages = {
  en: {
    brandHub: "HeyEddi · Hub",
    brandSurvival: "HeyEddi · Survival",
    modeHub: "Hub",
    modeSurvival: "Survival",
    navHome: "Home",
    navSetup: "Setup",
    navSettings: "Settings",
    setupTitleHub: "Claim your box",
    setupTitleSurvival: "Claim this node",
    setupLeadHub:
      "Enter the one-time code from the box (screen, sticker, or console). A stranger on your network cannot finish setup without it.",
    setupLeadSurvival:
      "Physical presence required. The claim code lives on the box, never in this browser. That keeps first-run off the open LAN.",
    claimLabel: "Claim code",
    claimPlaceholder: "From the box",
    passwordLabel: "Dashboard password",
    confirmLabel: "Confirm password",
    claimCta: "Claim this box",
    claiming: "Claiming…",
    claimedLocked:
      "This box is already claimed. Factory reset on the device is required to run setup again.",
    errClaimShort: "Enter the claim code from the box.",
    errPasswordShort: "Use at least 8 characters for the dashboard password.",
    errPasswordMatch: "Passwords do not match.",
    advanced: "Advanced",
    advancedHint: "Operator and founder tools. Not required for normal claim.",
    networkMode: "Network mode (placeholder)",
    networkLan: "LAN only (default)",
    networkBridge: "Inline bridge (later)",
    networkAp: "Wi-Fi AP (later)",
    founderTips: "Console helpers (device access)",
    homeTitleHub: "Your network. Your data.",
    homeTitleSurvival: "Offline when it matters.",
    homeLeadHub: "Personal cloud, media, and local AI on hardware you own.",
    homeLeadSurvival:
      "Protection, offline archives, and local AI stay available when the wider network does not.",
    homeLoading: "Loading status…",
    homeApiError: "Could not reach the box API",
    statusArch: "Arch",
    statusSetup: "Setup",
    statusSetupDone: "claimed",
    statusSetupNeeded: "needed",
    statusMode: "Mode",
    statusNames: "Names",
    settingsTitle: "Settings",
    settingsLeadHub: "Updates, power, and household preferences.",
    settingsLeadSurvival: "Updates, power, and operator controls for this node.",
    settingsUpdates: "Updates",
    settingsUpdatesBody: "Signed update channel lands in a later stage. The box stays usable offline without it.",
    settingsPower: "Power",
    settingsPowerBody: "Reboot and shutdown controls will appear here for owners on the local network.",
    localeLabel: "Language",
    localeEn: "English",
    localeEs: "Español",
    loginTitle: "Sign in",
    loginLead: "Use the dashboard password you set when you claimed this box.",
    loginLeadDesktop:
      "Sign in to the hub first. After that you will open remote desktop automatically.",
    signIn: "Sign in",
    signingIn: "Signing in…",
    signOut: "Sign out",
    remoteShell: "Remote shell (SSH)",
    remoteOn: "Enabled on this box",
    remoteOff: "Off (safe default)",
    remoteHint:
      "Enable or disable only at the local console. The web UI cannot turn SSH on or factory-reset the box.",
    advancedNever: "Never available here: claim PIN, factory reset, full root.",
    remoteDesktop: "Remote desktop",
    remoteDesktopLead:
      "Full Linux desktop in the browser — install Cursor there to code on this box. No SSH required.",
    remoteDesktopProtected:
      "Protected: open the hub, sign in, then open remote desktop. Unsigned visits are sent to login. No public host port.",
    remoteDesktopEnableLabel: "Enable remote desktop",
    remoteDesktopOn: "Enabled",
    remoteDesktopOff: "Off",
    remoteDesktopRunning: "Ready",
    remoteDesktopStopped: "Stopped",
    remoteDesktopStarting: "Starting…",
    remoteDesktopStopping: "Stopping…",
    remoteDesktopLoading: "Loading remote desktop controls…",
    remoteDesktopControlOn: "UI can start/stop",
    remoteDesktopOpen: "Open remote desktop",
    remoteDesktopOpenHint: "Turn it on and wait until status shows Ready, then open the link in a new tab.",
    remoteDesktopStartingBody:
      "Starting the desktop. First run downloads a large image — this can take several minutes. Keep this tab open.",
    remoteDesktopStoppingBody: "Stopping the desktop. This usually finishes in a few seconds.",
    remoteDesktopRefresh: "Refresh status",
    remoteDesktopEnable: "Enable",
    remoteDesktopDisable: "Disable",
    remoteDesktopBusy: "Updating…",
    remoteDesktopHint:
      "First start may take a few minutes while the desktop image downloads.",
    homeRemoteDesktop: "Remote desktop",
    homeRemoteDesktopOpen: "Open remote desktop",
    homeRemoteDesktopSettings: "Manage in Settings",
  },
  es: {
    brandHub: "HeyEddi · Hub",
    brandSurvival: "HeyEddi · Supervivencia",
    modeHub: "Hub",
    modeSurvival: "Supervivencia",
    navHome: "Inicio",
    navSetup: "Configuración",
    navSettings: "Ajustes",
    setupTitleHub: "Reclama tu caja",
    setupTitleSurvival: "Reclama este nodo",
    setupLeadHub:
      "Introduce el código de un solo uso de la caja (pantalla, pegatina o consola). Quien esté en tu red no puede terminar el setup sin él.",
    setupLeadSurvival:
      "Se requiere presencia física. El código vive en la caja, nunca en este navegador. Así el primer arranque no queda abierto en la LAN.",
    claimLabel: "Código de reclamo",
    claimPlaceholder: "Desde la caja",
    passwordLabel: "Contraseña del panel",
    confirmLabel: "Confirmar contraseña",
    claimCta: "Reclamar esta caja",
    claiming: "Reclamando…",
    claimedLocked:
      "Esta caja ya está reclamada. Hace falta un restablecimiento de fábrica en el dispositivo para volver a configurar.",
    errClaimShort: "Introduce el código de reclamo de la caja.",
    errPasswordShort: "Usa al menos 8 caracteres para la contraseña.",
    errPasswordMatch: "Las contraseñas no coinciden.",
    advanced: "Avanzado",
    advancedHint: "Herramientas de operador. No hacen falta para un reclamo normal.",
    networkMode: "Modo de red (provisional)",
    networkLan: "Solo LAN (predeterminado)",
    networkBridge: "Puente en línea (después)",
    networkAp: "Wi-Fi AP (después)",
    founderTips: "Ayudas de consola (acceso al dispositivo)",
    homeTitleHub: "Tu red. Tus datos.",
    homeTitleSurvival: "Fuera de línea cuando importa.",
    homeLeadHub: "Nube personal, medios e IA local en hardware que controlas.",
    homeLeadSurvival:
      "Protección, archivos sin conexión e IA local siguen disponibles cuando la red amplia no.",
    homeLoading: "Cargando estado…",
    homeApiError: "No se pudo alcanzar la API de la caja",
    statusArch: "Arquitectura",
    statusSetup: "Setup",
    statusSetupDone: "reclamada",
    statusSetupNeeded: "pendiente",
    statusMode: "Modo",
    statusNames: "Nombres",
    settingsTitle: "Ajustes",
    settingsLeadHub: "Actualizaciones, energía y preferencias del hogar.",
    settingsLeadSurvival: "Actualizaciones, energía y controles de operador.",
    settingsUpdates: "Actualizaciones",
    settingsUpdatesBody:
      "El canal de actualizaciones firmadas llega en una etapa posterior. La caja sigue usable sin conexión.",
    settingsPower: "Energía",
    settingsPowerBody:
      "Reinicio y apagado aparecerán aquí para propietarios en la red local.",
    localeLabel: "Idioma",
    localeEn: "English",
    localeEs: "Español",
    loginTitle: "Iniciar sesión",
    loginLead: "Usa la contraseña del panel que definiste al reclamar esta caja.",
    loginLeadDesktop:
      "Primero inicia sesión en el hub. Después se abrirá el escritorio remoto automáticamente.",
    signIn: "Entrar",
    signingIn: "Entrando…",
    signOut: "Salir",
    remoteShell: "Shell remoto (SSH)",
    remoteOn: "Activado en esta caja",
    remoteOff: "Apagado (predeterminado seguro)",
    remoteHint:
      "Activa o desactiva solo en la consola local. La web no puede encender SSH ni hacer factory reset.",
    advancedNever: "Nunca disponible aquí: PIN de reclamo, factory reset, root completo.",
    remoteDesktop: "Escritorio remoto",
    remoteDesktopLead:
      "Escritorio Linux completo en el navegador — instala Cursor ahí para programar en esta caja. Sin SSH.",
    remoteDesktopProtected:
      "Protegido: entra al hub, inicia sesión, luego abre el escritorio remoto. Sin sesión te manda a login. Sin puerto público.",
    remoteDesktopEnableLabel: "Activar escritorio remoto",
    remoteDesktopOn: "Activado",
    remoteDesktopOff: "Apagado",
    remoteDesktopRunning: "Listo",
    remoteDesktopStopped: "Detenido",
    remoteDesktopStarting: "Arrancando…",
    remoteDesktopStopping: "Deteniendo…",
    remoteDesktopLoading: "Cargando controles del escritorio remoto…",
    remoteDesktopControlOn: "La UI puede iniciar/parar",
    remoteDesktopOpen: "Abrir escritorio remoto",
    remoteDesktopOpenHint:
      "Actívalo y espera a que el estado diga Listo; luego abre el enlace en una pestaña nueva.",
    remoteDesktopStartingBody:
      "Arrancando el escritorio. La primera vez descarga una imagen grande — puede tardar varios minutos. Deja esta pestaña abierta.",
    remoteDesktopStoppingBody: "Deteniendo el escritorio. Suele tardar unos segundos.",
    remoteDesktopRefresh: "Actualizar estado",
    remoteDesktopEnable: "Activar",
    remoteDesktopDisable: "Desactivar",
    remoteDesktopBusy: "Actualizando…",
    remoteDesktopHint:
      "El primer arranque puede tardar unos minutos mientras se descarga la imagen.",
    homeRemoteDesktop: "Escritorio remoto",
    homeRemoteDesktopOpen: "Abrir escritorio remoto",
    homeRemoteDesktopSettings: "Gestionar en Ajustes",
  },
} as const;

export type MessageKey = keyof typeof messages.en;

export function useI18n() {
  const t = computed(() => {
    const pack = messages[locale.value];
    return (key: MessageKey) => pack[key];
  });
  return { locale, setLocale, t };
}

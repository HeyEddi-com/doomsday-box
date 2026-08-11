import { ref, type Ref } from "vue";
import { fetchStatus, type BoxStatus } from "./api";

const status: Ref<BoxStatus | null> = ref(null);
const error = ref("");
const loading = ref(false);

export async function refreshStatus() {
  loading.value = true;
  error.value = "";
  try {
    status.value = await fetchStatus();
  } catch (e) {
    error.value = e instanceof Error ? e.message : "API unreachable";
  } finally {
    loading.value = false;
  }
}

export function useBoxStatus() {
  return { status, error, loading, refreshStatus };
}

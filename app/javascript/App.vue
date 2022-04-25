<template>
  <div>
    <div class="search">
      <input v-model="keyword" />
      <button v-on:click="updateChart()">検索</button>
    </div>

    <Suspense>
      <ScatterChart
        :key="resetKey"
        v-if="resetFlag"
        v-bind:keyword="keyword"
      />
    </Suspense>
  </div>
</template>

<script>
import ScatterChart from "./src/scatterChart";
import { ref } from "vue";

export default {
  components: {
    ScatterChart,
  },

  setup(props, context) {
    let resetFlag = ref(false);
    let resetKey = ref(0);
    let keyword = ref<String>('');

    function updateChart() {
      if (keyword.value) {
        resetFlag.value = true;
        resetKey.value++;
      } else {
        resetFlag.value = false;
      }
    }

    return {
      keyword,
      updateChart,
      resetFlag,
      resetKey,
    };
  },
};
</script>
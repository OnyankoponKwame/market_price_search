<template>
  <div>
    <div class="search">
      <input v-model="keyword" />
      <button v-on:click="updateChart()">検索</button>
    </div>

    <!-- <div class="shiborikomi">
      <input v-model="price_min" />
      <input v-model="price_max" />
    </div> -->

    <Suspense>
      <ScatterChart
        :key="resetKey"
        v-if="resetFlag"
        :keyword="keyword"
        :sale_array="sale_array"
        :sold_array="sold_array"
      />
    </Suspense>
    <Suspense>
      <BarChart 
      :key="resetKey" 
      v-if="resetFlag" 
      :keyword="keyword"
      :data_array="data_array"
      :label_array="label_array"
         />
    </Suspense>
  </div>
</template>

<script>
import ScatterChart from "./components/scatterChart";
import BarChart from "./components/barChart";
import { ref } from "vue";

export default {
  components: {
    ScatterChart,
    BarChart,
  },

  setup(props, context) {
    let resetFlag = ref(false);
    let resetKey = ref(0);
    let keyword = ref<String>('');
    let sale_array = ref([]);
    let sold_array = ref([]);
    let data_array = ref([]);
    let label_array = ref([]);

    const updateChart = async () => {
      if (keyword.value) {
        let params = { keyword: keyword.value };
        let query = new URLSearchParams(params);
        await fetch(`/api/v1/items?${query}`)
          .then((response) => {
            if (!response.ok) {
              throw new Error(`Country not found (${response.status})`);
            }
            return response.json();
          })
          // ここでjson形式のdataになる
          .then((json) => {
            sale_array.value = [];
            sold_array.value = [];
            data_array.value = [];
            label_array.value = [];
            for (let elem of JSON.parse(json["sale_array"])) {
              let x = elem[0];
              let y = elem[1];
              sale_array.value.push({ x: x, y: y });
            }
            for (let elem of JSON.parse(json["sold_array"])) {
              let x = elem[0];
              let y = elem[1];
              sold_array.value.push({ x: x, y: y });
            }
            data_array.value = json["data_array"]
            label_array.value = json["label_array"]

          });

        resetFlag.value = true;
        resetKey.value++;
      } else {
        resetFlag.value = false;
      }
    };

    return {
      keyword,
      updateChart,
      resetFlag,
      resetKey,
      sale_array,
      sold_array,
      data_array,
      label_array
    };
  },
};
</script>
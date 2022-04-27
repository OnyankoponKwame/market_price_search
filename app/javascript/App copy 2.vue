<template>
  <div>
    <div class="search">
      <input v-model="keyword" />
      <button v-on:click="getjson()">検索</button>
            <button v-on:click="updateChart()">検索</button>
    </div>

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
      />
      </Suspense>
  </div>
</template>

<script>
import ScatterChart from "./components/scatterChart";
import BarChart from "./components/barChart";
import { ref,reactive } from "vue";
// import { Chart } from 'chart.js';
// import Chart from 'chart.js/auto';

export default {
  components: {
    ScatterChart,
    BarChart
  },

  setup(props, context) {
    let resetFlag = ref(false);
    let resetKey = ref(0);
    let keyword = ref<String>('');
    let sale_array = ref([]);
    let sold_array = ref([]);

    const getjson = async() => {
      let params = { keyword: keyword }
      let query = new URLSearchParams(params);
      let data = await fetch(`/api/v1/items?${query}`);
      let json = await data.json()
      for (let elem of JSON.parse(json['sale_array'])) {
        var x = elem[0];
        var y = elem[1];
        sale_array.value.push({ x: x, y: y });
      };

      for (let elem of JSON.parse(json['sold_array'])) {
        var x = elem[0];
        var y = elem[1];
        sold_array.value.push({ x: x, y: y });
      };
    }
    const updateChart = () => {
      if (keyword.value) {
        // let params = { keyword: keyword }
        // let query = new URLSearchParams(params);
        // fetch(`/api/v1/items?${query}`)
        //     .then((response) => {
        //         // 国が見つからなくてもfetchはfulfilledを返すので、手動でerrorを投げる
        //         // errorをthrowするとpromiseはrejectedを投げる（= catchで受け取れる）
        //         if (!response.ok) {
        //             throw new Error(`Country not found (${response.status})`);
        //         }

        //         // 受け取ったresponseはjson形式にする必要があるが、response.json()も非同期であるため、thenで受け取る必要がある
        //         return response.json();
        //     })
        //     // ここでjson形式のdataになる
        //     .then((json) => {
        //         // console.log(data[0]);
        //               for (let elem of JSON.parse(json['sale_array'])) {
        //                 var x = elem[0];
        //                 var y = elem[1];
        //                 sale_array.value.push({ x: x, y: y });
        //               };

        //               for (let elem of JSON.parse(json['sold_array'])) {
        //                 var x = elem[0];
        //                 var y = elem[1];
        //                 sold_array.value.push({ x: x, y: y });
        //               };
        //     });
        getjson()

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
      sale_array,
      sold_array,
      getjson
    };
  },
};
</script>